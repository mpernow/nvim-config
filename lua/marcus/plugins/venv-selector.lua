return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
  },
  ft = "python", -- Load when opening Python files
  keys = {
    {
      "<leader>vs",
      "<cmd>VenvSelect<cr>",
      desc = "Select Python Virtual Environment",
    },
  },
  opts = {
    options = {}, -- plugin-wide options
    name = {
      "venv",
      ".venv",
      "env",
      ".env",
    },
    auto_refresh = true,
    search = {},
    search_venv_managers = true,
  },
}
