return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "pylint" },
      cpp = { "cpplint" },
    }
    -- Find the virtualenv of the Python project containing the current buffer:
    -- an activated $VIRTUAL_ENV, an in-project .venv (uv, poetry, venv), or a pipenv venv.
    local venv_cache = {}
    local function find_venv()
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV
      end
      local root = vim.fs.root(0, { ".venv", "Pipfile" })
      if not root then
        return nil
      end
      if venv_cache[root] == nil then
        local venv = false
        if vim.fn.isdirectory(root .. "/.venv") == 1 then
          venv = root .. "/.venv"
        elseif vim.fn.executable("pipenv") == 1 then
          local res = vim.system({ "pipenv", "--venv" }, { cwd = root, text = true }):wait()
          if res.code == 0 then
            venv = vim.trim(res.stdout)
          end
        end
        venv_cache[root] = venv
      end
      return venv_cache[root] or nil
    end

    local function venv_pylint(venv)
      return venv and vim.fn.executable(venv .. "/bin/pylint") == 1 and venv .. "/bin/pylint" or nil
    end

    -- Prefer the venv's own pylint; otherwise run Mason's pylint with the venv's
    -- site-packages added (addsitedir processes .pth files, so editable installs resolve).
    local pylint = lint.linters.pylint
    local pylint_args = vim.deepcopy(pylint.args)
    pylint.cmd = function()
      return venv_pylint(find_venv()) or "pylint"
    end
    pylint.args = {
      function()
        local venv = find_venv()
        if not venv or venv_pylint(venv) then
          return "--init-hook=pass"
        end
        local site_packages = vim.fn.glob(venv .. "/lib/python*/site-packages", false, true)[1]
        if not site_packages then
          return "--init-hook=pass"
        end
        return ("--init-hook=import site; site.addsitedir(%q)"):format(site_packages)
      end,
      unpack(pylint_args),
    }

    lint.linters.cpplint.args = {
      "--filter",
      "-legal/copyright,-whitespace/braces",
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
