vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.cursorline = true -- highlight current cursor line

-- tabs & indentation
opt.tabstop = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- turn on termguicolors for colorschemes
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Term Toggle Function
local term_buf = nil
local term_win = nil

function TermToggle(height)
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.cmd("hide")
  else
    vim.cmd("botright new")
    local new_buf = vim.api.nvim_get_current_buf()
    vim.cmd("resize " .. height)
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      vim.cmd("buffer " .. term_buf) -- go to terminal buffer
      vim.cmd("bd " .. new_buf) -- cleanup new buffer
    else
      vim.cmd("terminal")
      term_buf = vim.api.nvim_get_current_buf()
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.signcolumn = "no"
    end
    vim.cmd("startinsert!")
    term_win = vim.api.nvim_get_current_win()
  end
end

-- Term Toggle Keymaps
vim.keymap.set("n", "<C-t>", ":lua TermToggle(20)<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-t>", "<Esc>:lua TermToggle(20)<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>:lua TermToggle(20)<CR>", { noremap = true, silent = true })

-- Run code
local run_code = function()
  local filepath = vim.fn.expand("%")
  local nameonly = vim.fn.expand("%:t")
  local dirname = vim.fn.expand("%:h")
  local extension = vim.fn.expand("%:e")
  local basename = string.gsub(nameonly, "." .. extension, "")
  local filetype = vim.bo.filetype

  local cmd = nil

  if filetype == "python" then
    cmd = ":!python " .. filepath
  elseif filetype == "cpp" then
    cmd = "!cd " .. dirname .. " && g++ " .. nameonly .. " -o " .. basename .. " && echo && echo && ./" .. basename
  end

  if cmd then
    vim.cmd("w")
    vim.cmd(cmd)
  else
    print("No interpreter or compiler defined for filetype: '" .. filetype .. "'")
  end
end

vim.keymap.set("n", "<F12>", run_code, { noremap = true, silent = true })
