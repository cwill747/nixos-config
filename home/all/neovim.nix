{ config, pkgs, ... }:

# IMPORTANT QUOTING RULES FOR THIS FILE:
# When writing Lua code in extraLuaConfig, use double quotes ("") for empty strings,
# NOT single quotes (''). Single quotes cause Nix parsing errors.
# Example: return "" ✓    return '' ✗

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Enable Python support
    withPython3 = true;
    withNodeJs = true;

    # Neovim plugins - using nixpkgs where available
    plugins = with pkgs.vimPlugins; [
      # Core/Sensible defaults
      vim-sensible

      # Treesitter for syntax highlighting
      nvim-treesitter.withAllGrammars

      # Git integration
      vim-fugitive
      vim-rhubarb  # GitHub integration
      gitsigns-nvim

      # File management
      nvim-tree-lua
      nvim-web-devicons

      # LSP and completion (modern setup)
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip          # LuaSnip completion source
      luasnip              # Modern snippet engine
      friendly-snippets    # Pre-built snippets collection

      # LSP enhancements
      lsp_signature-nvim   # Function signature help
      trouble-nvim         # Better diagnostics UI

      # Note: Using Nix-managed LSP servers instead of Mason for better reproducibility

      # Telescope (fuzzy finder)
      telescope-nvim
      plenary-nvim

      # Status line
      lualine-nvim
      nvim-web-devicons

      # Color scheme
      gruvbox

      # Text manipulation
      vim-surround
      vim-abolish
      comment-nvim
      vim-multiple-cursors

      # Movement and search
      vim-sneak

      # Utility
      vim-dispatch
      editorconfig-vim
      vim-test
      vim-better-whitespace
      rainbow_parentheses-vim
      vim-rooter

      # Language support (most handled by LSP + Treesitter now)
      vim-css-color    # Visual color preview (unique functionality not provided by LSP)
    ];

    extraLuaConfig = ''
      -- ============================================================================
      -- BASIC EDITING CONFIGURATION
      -- ============================================================================

      -- Leader key
      vim.g.mapleader = " "

      -- Remember more commands and search history
      vim.opt.history = 10000

      -- Encoding and display
      vim.opt.encoding = "UTF-8"
      vim.opt.hidden = true
      vim.opt.backup = false
      vim.opt.writebackup = false
      vim.opt.cmdheight = 2
      vim.opt.updatetime = 300

      -- Mouse and UI
      vim.opt.mouse = "a"
      vim.opt.wildoptions = "pum"
      vim.opt.pumblend = 20
      vim.opt.cursorline = true
      vim.opt.relativenumber = true

      -- Folding
      vim.opt.foldmethod = "indent"
      vim.opt.foldlevel = 99
      vim.opt.foldenable = true

      -- Concealment
      vim.opt.conceallevel = 2
      vim.g.vim_markdown_conceal_code_blocks = 0

      -- Command line
      vim.opt.showcmd = true
      vim.opt.wildmode = "full"
      vim.opt.wildmenu = true
      vim.opt.joinspaces = false
      vim.opt.wrap = false
      vim.opt.number = true
      vim.opt.ttyfast = true
      vim.opt.laststatus = 2
      vim.opt.ttimeout = true
      vim.opt.ttimeoutlen = 10

      -- Shell and terminal
      vim.opt.shell = "fish"
      vim.opt.termguicolors = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true

      -- Scrolling
      vim.opt.scrolloff = 3

      -- Whitespace and indentation
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.shiftround = true
      vim.opt.expandtab = true
      vim.opt.autoindent = true
      vim.opt.smartindent = true

      -- Persistent undo
      vim.opt.undofile = true
      vim.opt.undodir = vim.fn.expand("$HOME/.config/nvim/undo")
      vim.opt.undolevels = 1000
      vim.opt.undoreload = 10000

      -- ============================================================================
      -- CLIPBOARD CONFIGURATION (OSC 52 for remote sessions)
      -- ============================================================================

      -- Function to set OSC 52 clipboard
      local function set_osc52_clipboard()
        local function my_paste()
          local content = vim.fn.getreg '"'
          return vim.split(content, '\n')
        end

        vim.g.clipboard = {
          name = 'OSC 52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy '+',
            ['*'] = require('vim.ui.clipboard.osc52').copy '*',
          },
          paste = {
            ['+'] = my_paste,
            ['*'] = my_paste,
          },
        }
      end

      -- Check if the current session is a remote WezTerm session based on the WezTerm executable
      local function check_wezterm_remote_clipboard(callback)
        local wezterm_executable = vim.uv.os_getenv 'WEZTERM_EXECUTABLE'

        if wezterm_executable and wezterm_executable:find('wezterm-mux-server', 1, true) then
          callback(true) -- Remote WezTerm session found
        else
          callback(false) -- No remote WezTerm session
        end
      end

      -- Schedule the setting after `UiEnter` because it can increase startup-time.
      vim.schedule(function()
        vim.opt.clipboard:append 'unnamedplus'

        -- Standard SSH session handling
        if vim.uv.os_getenv 'SSH_CLIENT' ~= nil or vim.uv.os_getenv 'SSH_TTY' ~= nil then
          set_osc52_clipboard()
        else
          check_wezterm_remote_clipboard(function(is_remote_wezterm)
            if is_remote_wezterm then
              set_osc52_clipboard()
            end
          end)
        end
      end)

      -- Backspace behavior
      vim.opt.backspace = "eol,start,indent"
      vim.opt.whichwrap:append("<,>,h,l")

      -- Auto reload if file changed
      vim.opt.autoread = true

      -- ============================================================================
      -- COLOR SCHEME AND APPEARANCE
      -- ============================================================================

      -- Set colorscheme (t_Co is not needed in modern Neovim with termguicolors)
      -- vim.cmd("colorscheme gruvbox")  -- Temporarily disabled for debugging
      vim.g.gruvbox_contrast_dark = "medium"

      -- Enable syntax highlighting
      vim.cmd("syntax on")

      -- Whitespace visualization
      vim.opt.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·"
      vim.opt.list = false

      -- Custom highlights
      vim.cmd("highlight Normal guibg=NONE")
      vim.cmd("highlight EasyMotionTargetDefault guifg=#ffb400")
      vim.cmd("highlight NonText guifg=#354751")
      vim.cmd("highlight VertSplit guifg=#212C32")
      vim.cmd("highlight WildMenu guibg=NONE guifg=#87bb7c")
      vim.cmd("highlight CursorLineNr guibg=NONE")

      -- Whitespace highlighting
      vim.cmd("highlight ExtraWhitespace ctermbg=red guibg=red")
      vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])

      -- ============================================================================
      -- PLUGIN CONFIGURATION
      -- ============================================================================

      -- Comment.nvim setup (modern commenting)
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = '^$',
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
        extra = {
          above = 'gcO',
          below = 'gco',
          eol = 'gcA',
        },
        mappings = {
          basic = true,
          extra = true,
        },
      })

      -- vim-sneak configuration (simple 2-character motion)
      vim.g['sneak#label'] = 1  -- Enable label mode for easier targeting
      vim.g['sneak#use_ic_scs'] = 1  -- Use ignorecase and smartcase
      vim.g['sneak#s_next'] = 1  -- Use ; and , for next/previous
      vim.g['sneak#map_netrw'] = 0  -- Don't map in netrw

      -- EditorConfig
      vim.g.EditorConfig_exclude_patterns = {"fugitive://.*", "scp://.*"}
      vim.g.EditorConfig_disable_rules = {"max_line_length"}

            -- Lualine
      require('lualine').setup {
        options = {
          theme = 'gruvbox',
          component_separators = '|',
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            {
              'filename',
              path = 0, -- Just filename
              fmt = function(str)
                -- Custom filename function equivalent to LightLineFilename
                local name = ""
                local subs = vim.split(vim.fn.expand('%'), "/")
                for i, s in ipairs(subs) do
                  local parent = name
                  if i == #subs then
                    name = (#parent > 0) and parent .. '/' .. s or s
                  elseif i == 1 then
                    name = s
                  else
                    local part = string.sub(s, 1, 10)
                    name = (#parent > 0) and parent .. '/' .. part or part
                  end
                end
                return name
              end
            },
            {
              'diagnostics',
              sources = {'nvim_lsp'},
            }
          },
          lualine_c = {
            {
              function()
                if vim.bo.readonly then return '[RO]' end
                return ""
              end,
              color = { fg = '#ff6c6b' }
            },
            {
              function()
                if vim.bo.modified then return '[+]' end
                return ""
              end,
              color = { fg = '#98be65' }
            }
          },
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {
            'branch',
            'location'
          }
        }
      }

      -- Rooter
      vim.g.rooter_change_directory_for_non_project_files = "current"
      vim.g.rooter_patterns = {"Cargo.toml", "package.json", ".git/"}

      -- Multiple Cursor
      vim.g.multi_cursor_use_default_mapping = 0
      vim.g.multi_cursor_start_word_key = "<C-d>"
      vim.g.multi_cursor_select_all_word_key = "<C-L>"
      vim.g.multi_cursor_start_key = "g<C-d>"
      vim.g.multi_cursor_select_all_key = "g<C-L>"
      vim.g.multi_cursor_next_key = "<C-d>"
      vim.g.multi_cursor_prev_key = "<C-p>"
      vim.g.multi_cursor_skip_key = "<C-i>"
      vim.g.multi_cursor_quit_key = "<Esc>"

      -- ============================================================================
      -- KEY MAPPINGS
      -- ============================================================================

      -- Basic mappings
      vim.keymap.set("i", "<C-c>", "<ESC>")
      vim.keymap.set("i", "jk", "<ESC>")
      vim.keymap.set("n", "<CR>", ":nohlsearch<CR>")

      -- Disable recording (q key)
      vim.keymap.set("", "q", "<Nop>")

      -- Tab navigation
      vim.keymap.set("", "<leader>1", "1gt")
      vim.keymap.set("", "<leader>2", "2gt")
      vim.keymap.set("", "<leader>3", "3gt")
      vim.keymap.set("", "<leader>4", "4gt")
      vim.keymap.set("", "<leader>5", "5gt")
      vim.keymap.set("", "<leader>6", "6gt")
      vim.keymap.set("", "<leader>7", "7gt")
      vim.keymap.set("", "<leader>8", "8gt")
      vim.keymap.set("", "<leader>9", "9gt")
      vim.keymap.set("", "<leader>0", ":tablast<CR>")
      vim.keymap.set("n", "H", "gT")
      vim.keymap.set("n", "L", "gt")

      -- Window management
      vim.keymap.set("n", "<Leader>w", ":w<CR>")
      vim.keymap.set("n", "<Leader>l", ":vsplit<CR>")
      vim.keymap.set("n", "<Leader>k", ":split<CR>")
      vim.keymap.set("n", "<Leader>wh", ":wincmd h<CR>")
      vim.keymap.set("n", "<Leader>wl", ":wincmd l<CR>")
      vim.keymap.set("n", "<Leader>wk", ":wincmd k<CR>")
      vim.keymap.set("n", "<Leader>wj", ":wincmd j<CR>")
      vim.keymap.set("n", "<Leader>w=", ":wincmd =<CR>")
      vim.keymap.set("n", "<Leader>wb", ":e#<CR>")
      vim.keymap.set("n", "<Leader>qq", ":bd<CR>")

      -- Buffer and tab management
      vim.keymap.set("n", "<Leader>tn", ":tabn<CR>")
      vim.keymap.set("n", "<Leader>tp", ":tabp<CR>")
      vim.keymap.set("n", "<Leader>tc", ":tabe<CR>")
      vim.keymap.set("n", "<Leader>tx", ":tabclose<CR>")

      -- Git mappings (Fugitive) - using 'G' prefix to avoid LSP conflicts
      vim.keymap.set("n", "<Leader>G", ":Git<CR>")
      vim.keymap.set("n", "<Leader>Ga", ":Git add %:p<CR><CR>")
      vim.keymap.set("n", "<Leader>Gs", ":Git status<CR>")
      vim.keymap.set("n", "<Leader>Gc", ":Git commit<CR>")
      vim.keymap.set("n", "<Leader>Gd", ":Gvdiff<CR>")
      vim.keymap.set("n", "<Leader>Ge", ":Gedit<CR>")
      vim.keymap.set("n", "<Leader>GR", ":Gread<CR>")  -- Changed from gr to GR
      vim.keymap.set("n", "<Leader>Gw", ":Gwrite<CR><CR>")
      vim.keymap.set("n", "<Leader>Gl", ":silent! Git log<CR>")
      vim.keymap.set("n", "<Leader>Gp", ":Ggrep ")
      vim.keymap.set("n", "<Leader>Gm", ":Gmove ")
      vim.keymap.set("n", "<Leader>Gb", ":Git branch ")
      vim.keymap.set("n", "<Leader>Go", ":Git checkout ")

      -- Gitsigns mappings (modern git integration - consistent with diagnostic navigation)
      vim.keymap.set("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})
      vim.keymap.set("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
      vim.keymap.set("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
      vim.keymap.set("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
      vim.keymap.set("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
      vim.keymap.set("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
      vim.keymap.set("n", "<leader>hp", ":Gitsigns preview_hunk<CR>")
      vim.keymap.set("n", "<leader>hb", ":Gitsigns blame_line<CR>")
      vim.keymap.set("n", "<leader>tb", ":Gitsigns toggle_current_line_blame<CR>")

      -- Telescope mappings
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
      vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")

      -- nvim-tree
      vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>")

      -- Scrolling remaps
      vim.keymap.set("n", "<C-k>", "<C-u>")
      vim.keymap.set("n", "<C-j>", "<C-d>")

      -- Delete without copying
      vim.keymap.set("n", "d", '"_d')
      vim.keymap.set("v", "d", '"_d')

      -- Duplicate selection
      vim.keymap.set("v", "D", "y'>p")

      -- Emacs-like movement in insert mode
      vim.keymap.set("i", "<C-n>", "<Down>")
      vim.keymap.set("i", "<C-p>", "<Up>")
      vim.keymap.set("i", "<C-f>", "<Right>")
      vim.keymap.set("i", "<C-b>", "<Left>")
      vim.keymap.set("i", "<C-e>", "<C-o>$")
      vim.keymap.set("i", "<C-a>", "<C-o>^")

      -- Commenting (Comment.nvim uses gcc/gc by default, but keep mm for compatibility)
      vim.keymap.set("n", "mm", "gcc", { remap = true })
      vim.keymap.set("v", "mm", "gc", { remap = true })

      -- vim-sneak (2-character movement)
      -- s/S are mapped by default, but you can use leader variants if preferred
      vim.keymap.set("", "<Leader>s", "<Plug>Sneak_s")
      vim.keymap.set("", "<Leader>S", "<Plug>Sneak_S")

      -- Sudo write
      vim.keymap.set("c", "w!!", "w !sudo tee %")

      -- Toggle settings
      vim.keymap.set("n", "<leader>x", ":set cursorcolumn!<CR>")
      vim.keymap.set("", "<leader>#", ":set number!<CR>")

      -- ============================================================================
      -- USER COMMANDS
      -- ============================================================================

      -- Command fixes
      vim.api.nvim_create_user_command("WQ", "wq", {})
      vim.api.nvim_create_user_command("Wq", "wq", {})
      vim.api.nvim_create_user_command("W", "w", {})
      vim.api.nvim_create_user_command("Q", "q", {})

      -- ============================================================================
      -- AUTOCOMMANDS
      -- ============================================================================

      -- Whitespace highlighting autocommands
      local whitespace_group = vim.api.nvim_create_augroup("WhitespaceHighlight", {clear = true})
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = whitespace_group,
        pattern = "*",
        callback = function()
          vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
        end
      })
      vim.api.nvim_create_autocmd("InsertEnter", {
        group = whitespace_group,
        pattern = "*",
        callback = function()
          vim.fn.matchadd("ExtraWhitespace", [[\s\+\%#\@<!$]])
        end
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
        group = whitespace_group,
        pattern = "*",
        callback = function()
          vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
        end
      })
      vim.api.nvim_create_autocmd("BufWinLeave", {
        group = whitespace_group,
        pattern = "*",
        callback = function()
          vim.fn.clearmatches()
        end
      })

      -- Auto remove trailing spaces
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          vim.cmd("%s/\\s\\+$//e")
        end
      })

      -- Git commit settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gitcommit",
        callback = function()
          vim.opt_local.textwidth = 79
          vim.opt_local.colorcolumn = "80"
        end
      })

      -- Markdown settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.number = false
          vim.opt_local.textwidth = 80
          vim.opt_local.formatoptions:append("t")
          vim.opt_local.spell = true
        end
      })

      -- ============================================================================
      -- MODERN LSP SETUP (using Nix-managed servers for reproducibility)
      -- ============================================================================

      -- Modern file tree setup
      require('nvim-tree').setup({
        disable_netrw = true,
        hijack_netrw = true,
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { '.git', 'node_modules', '.cache' },
        },
        git = {
          enable = true,
          ignore = true,
          timeout = 500,
        },
      })

      -- Modern git signs setup
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      })

      -- Treesitter configuration
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true },
        indent = { enable = true },
      }

      -- LuaSnip setup (modern snippet engine)
      local luasnip = require('luasnip')
      require("luasnip.loaders.from_vscode").lazy_load() -- Load friendly-snippets

      -- Trouble setup (better diagnostics UI)
      require("trouble").setup()

      -- LSP Signature setup (function signatures while typing)
      require('lsp_signature').setup({
        bind = true,
        handler_opts = {
          border = "rounded"
        },
        hint_prefix = "🔍 ",
        zindex = 200,
      })

      -- Enhanced nvim-cmp setup with LuaSnip
      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
          { name = 'path', priority = 250 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Add icons
            local icons = {
              Text = "📝",
              Method = "🔧",
              Function = "⚡",
              Constructor = "🏗️ ",
              Field = "🏷️ ",
              Variable = "📦",
              Class = "🎭",
              Interface = "🔌",
              Module = "📚",
              Property = "🔑",
              Unit = "📏",
              Value = "💎",
              Enum = "📊",
              Keyword = "🔤",
              Snippet = "✂️ ",
              Color = "🎨",
              File = "📄",
              Reference = "🔗",
              Folder = "📁",
              EnumMember = "📊",
              Constant = "🔒",
              Struct = "🏢",
              Event = "⚡",
              Operator = "➕",
              TypeParameter = "📝",
            }
                         vim_item.kind = string.format('%s %s', icons[vim_item.kind] or "", vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      -- Command line completion (same as before)
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })

      -- Enhanced LSP setup with better capabilities and handlers
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- Enhanced diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          source = 'if_many',
        },
        float = {
          source = 'always',
          border = 'rounded',
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- LSP keymaps - CRITICAL MISSING PIECE!
      local on_attach = function(client, bufnr)
        local opts = {buffer = bufnr, remap = false}

        -- Navigation
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
        vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
        vim.keymap.set("n", "go", function() vim.lsp.buf.type_definition() end, opts)
        vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "gS", function() vim.lsp.buf.signature_help() end, opts)  -- Changed to avoid vim-sneak conflict

        -- Documentation
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)

        -- Code actions
        vim.keymap.set({"n", "v"}, "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)

        -- Diagnostics (fixed direction: [ = previous, ] = next)
        vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "<leader>dl", function() vim.diagnostic.setloclist() end, opts)

        -- Trouble keymaps
        vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
        vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)
        vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", opts)
        vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", opts)
        vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", opts)
        vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", opts)

        -- Formatting
        vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end, opts)
      end

      -- Configure language servers with enhanced settings
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = {'vim'} },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          }
        }
      })

      -- Python with enhanced settings
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
            }
          }
        }
      })

      -- TypeScript with enhanced settings
      lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          }
        }
      })

      -- Enhanced Rust Analyzer
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            checkOnSave = {
              command = 'clippy',
            },
          }
        }
      })

      -- Other language servers with basic enhanced setup
      local servers = {
        'gopls', 'nil_ls', 'marksman', 'taplo',
        'yamlls', 'bashls', 'dockerls', 'terraformls'
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end
    '';
  };

  # Create undo directory
  home.file.".config/nvim/undo/.keep".text = "";

  # Additional packages that neovim might need
  home.packages = with pkgs; [
    # Language servers (Nix-managed for reproducibility)
    lua-language-server          # Lua
    pyright                      # Python
    nodePackages.typescript-language-server  # TypeScript/JavaScript
    rust-analyzer               # Rust
    gopls                       # Go
    nil                         # Nix
    marksman                    # Markdown
    taplo                       # TOML
    yaml-language-server        # YAML
    nodePackages.bash-language-server  # Bash
    nodePackages.dockerfile-language-server-nodejs  # Docker
    terraform-ls                # Terraform (if you use it)

    # Tools that vim plugins might use
    ripgrep  # for telescope live_grep
    fd       # for telescope find_files
    nodejs   # for various plugins

    # Formatters and linters (Nix-managed)
    black    # Python formatter
    ruff     # Python linter/formatter (faster than black+flake8)
    nodePackages.prettier # JavaScript/CSS/etc formatter
    stylua   # Lua formatter
    shfmt    # Shell script formatter
    nixpkgs-fmt  # Nix formatter
    yamlfmt  # YAML formatter

    # Other development tools
    tig      # text-mode interface for git
    tree-sitter  # For treesitter parsers
  ];
}
