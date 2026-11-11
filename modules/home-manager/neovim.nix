{
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
let
  # Same JDK the scala module uses for sbt/bloop
  metals = pkgsUnstable.metals.override { jre = config.programs.java.package; };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nordic-nvim
      nord-nvim
      nvim-tree-lua
      toggleterm-nvim
      vim-rooter
      snacks-nvim
      nvim-web-devicons
      nvim-metals
    ];
    extraPackages = with pkgs; [
      fd
      ripgrep
    ];
    extraConfig = ''
      set noruler
      set laststatus=0
      " Status lines still appear above horizontal splits (e.g. the terminal): draw them as a plain separator
      set statusline=%#WinSeparator#%{repeat('─',winwidth(0))}
      " The cell where a vertical separator meets that line is drawn with the statusline fill char
      set fillchars+=stl:┴,stlnc:┴
      set number relativenumber
      set clipboard+=unnamedplus
      colorscheme nord
      highlight! link StatusLine WinSeparator
      highlight! link StatusLineNC WinSeparator
      highlight! link StatusLineTerm WinSeparator
      highlight! link StatusLineTermNC WinSeparator
      let g:rooter_silent_chdir = 1
    '';
    initLua = ''
      vim.opt.termguicolors = true
      -- Paths hidden from the tree via the right-click menu, saved per project (cwd) in this file
      local tree_hidden_file = ".nvim-tree-hidden"
      local tree_hidden = { cwd = nil, paths = {} }
      local function tree_hidden_paths()
        local cwd = vim.fn.getcwd()
        if tree_hidden.cwd ~= cwd then
          tree_hidden.cwd, tree_hidden.paths = cwd, { [cwd .. "/" .. tree_hidden_file] = true }
          local f = io.open(cwd .. "/" .. tree_hidden_file)
          if f then
            for line in f:lines() do
              if line ~= "" then tree_hidden.paths[cwd .. "/" .. line] = true end
            end
            f:close()
          end
        end
        return tree_hidden.paths
      end
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        prefer_startup_root = false,
        sync_root_with_cwd = true,
        filters = {
          git_ignored = true,
          custom = function(path) return tree_hidden_paths()[path] == true end,
        },
        git = { timeout = 2000 },
        -- Reveal and highlight the current editor file in the tree
        update_focused_file = { enable = true },
        -- Show a > b > c.txt as a/b > c.txt when b is a's only child
        renderer = { group_empty = true },
      })
      require("toggleterm").setup({
        open_mapping = '<C-\\>',
        direction = "horizontal",
        size = 15,
        start_in_insert = true,
        shade_terminals = false,
      })
      vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
      -- Right-click menu entries to hide tree nodes, only enabled inside NvimTree
      local tree_api = require("nvim-tree.api")
      -- Nodes to act on: the visual selection, else the marked nodes, else the node under the cursor
      local function tree_selected_nodes(visual)
        if visual then
          local first, last = vim.fn.line("v"), vim.fn.line(".")
          if first > last then first, last = last, first end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
          local nodes = {}
          for l = first, last do
            vim.api.nvim_win_set_cursor(0, { l, 0 })
            table.insert(nodes, tree_api.tree.get_node_under_cursor())
          end
          return nodes
        end
        local marked = tree_api.marks.list()
        if #marked > 0 then
          tree_api.marks.clear()
          return marked
        end
        return { tree_api.tree.get_node_under_cursor() }
      end
      function _G.NvimTreeHideNode(visual)
        local cwd = vim.fn.getcwd()
        local f = io.open(cwd .. "/" .. tree_hidden_file, "a")
        for _, node in ipairs(tree_selected_nodes(visual)) do
          local rel = node and node.absolute_path and vim.fs.relpath(cwd, node.absolute_path)
          if rel and rel ~= "." then
            if f then f:write(rel .. "\n") end
            tree_hidden_paths()[node.absolute_path] = true
          end
        end
        if f then f:close() end
        tree_api.tree.reload()
      end
      function _G.NvimTreeUnhideAll()
        os.remove(vim.fn.getcwd() .. "/" .. tree_hidden_file)
        tree_hidden.cwd = nil
        tree_api.tree.reload()
      end
      vim.cmd([[
        nmenu PopUp.Hide\ in\ tree <Cmd>lua NvimTreeHideNode(false)<CR>
        vmenu PopUp.Hide\ in\ tree <Cmd>lua NvimTreeHideNode(true)<CR>
        amenu PopUp.Unhide\ all <Cmd>lua NvimTreeUnhideAll()<CR>
      ]])
      vim.api.nvim_create_autocmd("MenuPopup", {
        callback = function()
          local state = vim.bo.filetype == "NvimTree" and "enable" or "disable"
          vim.cmd("nmenu " .. state .. [[ PopUp.Hide\ in\ tree]])
          vim.cmd("vmenu " .. state .. [[ PopUp.Hide\ in\ tree]])
          vim.cmd("amenu " .. state .. [[ PopUp.Unhide\ all]])
        end
      })
      require("snacks").setup({ picker = { enabled = true }, notifier = { enabled = true } })
      -- LSP progress (e.g. Metals indexing/compiling) as a notification with a spinner, as there's no statusline
      vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(ev)
          local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
          vim.notify(vim.lsp.status(), "info", {
            id = "lsp_progress",
            title = "LSP Progress",
            opts = function(notif)
              notif.icon = ev.data.params.value.kind == "end" and " "
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
          })
        end,
      })
      -- Errors inline at the end of the line, like errorlens in VSCodium
      vim.diagnostic.config({ virtual_text = true })
      -- Completion popup while typing for any LSP that supports it
      vim.opt.completeopt = { "menuone", "noselect", "popup" }
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/completion") then
            -- autotrigger only fires on the server's trigger characters (like "."), so add identifier characters too
            local provider = client.server_capabilities.completionProvider
            provider.triggerCharacters = provider.triggerCharacters or {}
            if not vim.list_contains(provider.triggerCharacters, "a") then
              for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
                table.insert(provider.triggerCharacters, c)
              end
            end
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end
      })
      -- Accept completions like VS Code: Tab takes the highlighted (or first) item, Enter only once one is highlighted
      vim.keymap.set("i", "<Tab>", function()
        if vim.fn.pumvisible() == 0 then return "<Tab>" end
        return vim.fn.complete_info({ "selected" }).selected == -1 and "<C-n><C-y>" or "<C-y>"
      end, { expr = true })
      vim.keymap.set("i", "<CR>", function()
        if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then return "<C-y>" end
        return "<CR>"
      end, { expr = true })
      -- Back/forward through jumps (e.g. after go to definition) like VS Code's ctrl+- / ctrl+shift+-, and the mouse side buttons
      vim.keymap.set("n", "<C-->", "<C-o>", { desc = "Go back" })
      vim.keymap.set("n", "<C-S-->", "<C-i>", { desc = "Go forward" })
      vim.keymap.set("n", "<C-_>", "<C-i>", { desc = "Go forward" })
      vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Go back" })
      vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Go forward" })
      -- Go to definition with option+click
      vim.keymap.set({ "n", "i" }, "<M-LeftMouse>", "<LeftMouse><Cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
      -- Clicking a symbol in normal mode shows its signature/docs in a popup, which closes when the cursor moves
      vim.keymap.set("n", "<LeftMouse>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true), "nx", false)
        if vim.bo.buftype == "" and #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
          vim.lsp.buf.hover({ silent = true, border = "rounded" })
        end
      end, { desc = "Click and show hover" })
      -- Clear a :command from the command line once it has run, unless it printed something (output or an error)
      vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function()
          if vim.fn.getcmdtype() ~= ":" or vim.v.event.abort then return end
          local typed = ":" .. vim.fn.getcmdline()
          vim.schedule(function()
            local shown = ""
            for c = 1, math.min(#typed, vim.o.columns) do shown = shown .. vim.fn.screenstring(vim.o.lines, c) end
            if shown == typed:sub(1, vim.o.columns) then vim.cmd.echo([[""]]) end
          end)
        end
      })
      local metals_config = require("metals").bare_config()
      metals_config.settings = { metalsBinaryPath = "${metals}/bin/metals" }
      -- Report progress through standard LSP progress (shown above) rather than a statusline
      metals_config.init_options.statusBarProvider = "off"
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
        pattern = { "scala", "sbt", "java" },
        callback = function() require("metals").initialize_or_attach(metals_config) end,
      })
      -- The default directory colour (NonText) is unreadable with nord
      vim.api.nvim_set_hl(0, "SnacksPickerFile", { fg = "#ECEFF4" })
      vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "#81A1C1" })
      vim.keymap.set({ 'n', 'i' }, '<C-p>', function()
        -- With only NvimTree open (e.g. `nvim .`) give the picker an editor window, or it replaces the tree
        local has_editor = vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(w)
          return vim.api.nvim_win_get_config(w).relative == "" and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == ""
        end)
        if not has_editor then
          vim.cmd("botright vnew")
          -- Keep the tree at nvim-tree's default width instead of half the screen
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "NvimTree" then vim.api.nvim_win_set_width(w, 30) end
          end
        end
        Snacks.picker.smart({ layout = { preset = "vscode" }, hidden = true })
      end, { noremap = true, silent = true })
      vim.keymap.set({ 'n', 'i' }, '<C-S-p>', function()
        Snacks.picker.commands({
          layout = { preset = "vscode" },
          -- Run commands that need no arguments right away; the rest (and builtins) go to the cmdline
          confirm = function(picker, item)
            local nargs = item and item.command and item.command.nargs
            if nargs == "0" or nargs == "?" or nargs == "*" then
              picker:close()
              vim.schedule(function()
                vim.fn.histadd("cmd", item.cmd)
                local ok, err = pcall(vim.cmd, item.cmd)
                if not ok then vim.notify(err, vim.log.levels.ERROR) end
              end)
            else
              Snacks.picker.actions.cmd(picker, item)
            end
          end,
        })
      end, { noremap = true, silent = true })
      -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close
      -- QuitPre rather than BufEnter, so closing a picker over a lone tree doesn't quit nvim
      vim.api.nvim_create_autocmd("QuitPre", {
        group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
        callback = function()
          local wins = vim.api.nvim_list_wins()
          local tree_wins, floating = {}, 0
          for _, w in ipairs(wins) do
            if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w)):match("NvimTree_") then table.insert(tree_wins, w) end
            if vim.api.nvim_win_get_config(w).relative ~= "" then floating = floating + 1 end
          end
          if #wins - floating - #tree_wins == 1 then
            for _, w in ipairs(tree_wins) do vim.api.nvim_win_close(w, true) end
          end
        end
      })
    '';
  };
}
