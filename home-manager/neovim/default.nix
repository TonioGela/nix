{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nordic-nvim
      nvim-tree-lua
      vim-rooter
    ];
    extraConfig = ''
      set noruler
      set laststatus=0
      set number relativenumber
      set clipboard+=unnamedplus
      colorscheme nordic
      let g:rooter_silent_chdir = 1
    '';
    extraLuaConfig = ''
      vim.opt.termguicolors = true
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        prefer_startup_root = false,
        sync_root_with_cwd = true,
      })
      vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
      -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
        pattern = "NvimTree_*",
        callback = function()
          local layout = vim.api.nvim_call_function("winlayout", {})
          if layout[1] == "leaf" and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree" and layout[3] == nil then vim.cmd("confirm quit") end
        end
      })
    '';
  };
}
