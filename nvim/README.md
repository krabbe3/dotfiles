# Neovim

Neovim config using Lazy.nvim, Rose Pine theme, and Lua-based plugin management.

## Target Version

**Neovim v0.11.5** (pinned by `setup_full.sh`; treesitter + lspconfig config target this version)

## Structure

```
nvim/
└── .config/nvim/
    ├── init.lua                    # Entry point — lazy, keymaps, options, autocommands
    ├── .editorconfig               # EditorConfig settings
    ├── lazy-lock.json              # Pinned plugin versions (gitignored)
    └── lua/
        ├── config/
        │   └── lazy.lua            # Lazy.nvim spec
        ├── plugins/                # Plugin specs (16 plugins)
        └── user/
            ├── autocommands.lua    # Black format-on-save for .py
            ├── keymaps.lua         # Core keybindings
            └── options.lua         # Editor options (tabs, numbers, search)
```

## Installed Plugins

| # | Plugin | Purpose |
|---|--------|---------|
| 1 | [saghen/blink.cmp](https://github.com/saghen/blink.cmp) | Blazing fast autocompletion (replaces nvim-cmp) |
| 2 | [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet provider for blink.cmp |
| 3 | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server configuration |
| 4 | [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Lua dev support (loaded only for Lua files) |
| 5 | [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | Package manager for external tools |
| 6 | [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Mason ↔ LSPconfig bridge |
| 7 | [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Auto-install Mason tools |
| 8 | [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol |
| 9 | [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI panels |
| 10 | [mfussenegger/nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python debugpy adapter |
| 11 | [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Virtual text during debugging |
| 12 | [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) | Git integration |
| 13 | [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) | File bookmarks |
| 14 | [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |
| 15 | [echasnovski/mini.icons](https://github.com/echasnovski/mini.icons) | File type icons (glyph style) |
| 16 | [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless vim ↔ tmux navigation |
| 17 | [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer (replaces netrw) |
| 18 | [rose-pine/neovim](https://github.com/rose-pine/neovim) | Rose Pine colorscheme |
| 19 | [folke/snacks.nvim](https://github.com/folke/snacks.nvim) | Dashboard, picker, explorer, indent, notifier, etc. |
| 20 | [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| 21 | [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | FZF ranking for Telescope |
| 22 | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting + incremental selection |
| 23 | [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Context window (function signatures above code) |
| 24 | [mbbill/undotree](https://github.com/mbbill/undotree) | Visual undo history tree |

### Disabled (commented out)

| Plugin | Notes |
|--------|-------|
| [epwalsh/obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Vault at `~/brain` (config present but disabled) |

### LSPs & Tools (via Mason)

| Tool | Purpose |
|------|---------|
| `lua_ls` | Lua language server |
| `pylsp` | Python language server |
| `black` | Python formatter (auto on save, line 79) |
| `debugpy` | Python debugger |
| `basedpyright` | Python type checker |

## Clipboard

**OSC 52** — works over SSH without xclip/xsel.

## Keybindings

Leader key: `<space>`

### Core (`user/keymaps.lua`)

| Mode | Key | Action |
|------|-----|--------|
| n | `Q` | Disabled (`<nop>`) |
| n | `jk` / `<space>jk` | Escape to normal mode |
| i | `jk` | Escape to normal mode |
| v | `<space>jk` | Escape to normal mode |
| n | `J` | Join lines, keep cursor at EOL |
| v | `J` | Move selected lines down + auto-indent |
| v | `K` | Move selected lines up + auto-indent |
| n | `<C-u>` / `<C-d>` | Half-page scroll with centering |
| n | `n` / `N` | Search navigate with centering |
| n | `<space>p` | Paste without overwriting register |
| n | `<space>y` / `<space>Y` | Yank to system clipboard (`+`) |
| v | `<space>y` | Yank selection to system clipboard |
| n | `<space>d` | Delete to void register (`_`) |
| v | `<space>d` | Delete selection to void register |
| n | `<space>c` | Change word under cursor (whole file) |
| n | `<space>x` | `chmod +x` current file |
| n | `<space><space>` | Source current file |
| n | `<space>\|` | Vertical split |
| n | `<space>-` | Horizontal split |

### Blink Completion (`plugins/blink_completion.lua`)

| Key | Action |
|-----|--------|
| `<C-space>` | Open menu / show docs |
| `<Tab>` | Select next completion (fallback if menu closed) |
| `<S-Tab>` | Select previous completion (fallback if menu closed) |
| `<C-n>` / `<C-p>` | Select next / previous item |
| `↑` / `↓` | Select next / previous item |
| `<C-e>` | Hide menu |
| `<C-k>` | Toggle signature help |
| `<C-f>` | Scroll documentation up |
| `<C-b>` | Scroll documentation down |

### DAP — Debugger (`plugins/dap.lua`) — `<space>d`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>dt` | Toggle breakpoint |
| n | `<space>dc` | Clear all breakpoints |
| n | `<space>ds` | Start / continue |
| n | `<space>dr` | Restart debugging session |
| n | `<space>dd` | Terminate / kill debugging |
| n | `<space>dl` | Step into |
| n | `<space>dj` | Step over |
| n | `<space>dh` | Step out |
| n | `<space>di` | Evaluate / hover variable under cursor |
| n | `<space>jk` | Close floating window (in dapui context) |

### Fugitive — Git (`plugins/fugitive.lua`) — `<space>g`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>gs` | Open Git status (`:Git`) |

### Harpoon — Bookmarks (`plugins/harpoon.lua`) — `<space>t`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>ta` | Add current file to harpoon list |
| n | `<space>tr` | Remove current file from harpoon list |
| n | `<space>to` | Toggle harpoon quick-menu UI |
| n | `<space>th` | Select harpoon slot 1 |
| n | `<space>tj` | Select harpoon slot 2 |
| n | `<space>tk` | Select harpoon slot 3 |
| n | `<space>tl` | Select harpoon slot 4 |
| n | `<space>tp` | Previous harpoon entry |
| n | `<space>tn` | Next harpoon entry |

### LSP (`plugins/lsp.lua`) — `<space>s`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>scn` | Rename symbol |
| n | `<space>sca` | Code action |
| n | `<space>sfr` | Find references (quickfix list) |
| n | `<space>sfi` | Go to implementation |
| n | `<space>sd` | Go to definition |
| n | `<space>sb` | Go back |
| n | `<space>sh` | Hover definition |
| n | `<space>sff` | Format file |

### Oil — File Explorer (`plugins/oil.lua`) — `<space>x`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>xp` | Open / close Oil file explorer |
| n | `<space>~` | Go to home directory |
| n | `<space>x?` | Show Oil help (default keymaps) |
| n | `<space>xl` | Show file preview (vertical split) |
| n | `<space>h` | Go to parent directory |
| n | `<space>l` | Enter directory / select file |

### Telescope — Fuzzy Finder (`plugins/telescope.lua`) — `<space>f`

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>ff` | Find files |
| n | `<space>fg` | Find git-tracked files |
| n | `<space>fs` | Grep string (prompts for pattern) |
| i/n (telescope) | `<C-j>` / `<C-k>` | Move selection next / previous |
| i/n (telescope) | `<space>jk` | Close Telescope |
| n (telescope) | `<space>l` | Open file + center cursor |

### Treesitter — Incremental Selection (`plugins/treesitter.lua`)

| Mode | Key | Action |
|------|-----|--------|
| n | `gnn` | Init selection (select node under cursor) |
| n | `grn` | Incremental node selection (expand) |
| n | `grc` | Incremental scope selection |
| n | `grm` | Decremental node selection (shrink) |

### Tmux Navigator (`plugins/nvim_tmux_navigation.lua`)

| Mode | Key | Action |
|------|-----|--------|
| n | `<C-h>` | Navigate left (tmux pane / vim split) |
| n | `<C-j>` | Navigate down |
| n | `<C-k>` | Navigate up |
| n | `<C-l>` | Navigate right |
| n | `<C-\>` | Navigate to previous window |

### Undotree (`plugins/undotree.lua`)

| Mode | Key | Action |
|------|-----|--------|
| n | `<space>u` | Toggle undo tree |

## Editor Options

| Option | Value | Notes |
|--------|-------|-------|
| `shiftwidth` / `tabstop` / `softtabstop` | 4 | 4-space tabs |
| `expandtab` | true | Tabs → spaces |
| `smartindent` | true | Auto-indent |
| `wrap` | false | No line wrapping |
| `swapfile` | false | No swap files |
| `backup` | false | No backup files |
| `undodir` | `~/.vim/undodir` | Persistent undo |
| `undofile` | true | Per-file undo persistence |
| `relativenumber` | true | Relative line numbers |
| `number` (insert mode) | true | Absolute numbers in insert |
| `hlsearch` | false | No persistent search highlight |
| `incsearch` | true | Incremental search |
| `ignorecase` / `smartcase` | true | Smart case-insensitive search |
| `termguicolors` | true | True color support |
| `scrolloff` | 8 | Min lines around cursor |
| `signcolumn` | yes | Always show sign column |
| `updatetime` | 50 | ms for Lazy/LSP triggers |
| `colorcolumn` | 80 | Column guide at 80 chars |

## Autocommands

| Trigger | Pattern | Action |
|---------|---------|--------|
| `BufWritePost` | `*.py` | Auto-format with **Black** (line 79) via Mason |
| `BufWritePre` | `*.lua` (on LSP attach) | Auto-format with lua_ls |

## TODOs

- [ ] LSP hardening (enable basedpyright / ruff, uncommented)
- [ ] Debugger (DAP) testing and refinement
- [x] Icons for Oil file explorer (mini.icons)
- [ ] Obsidian.nvim re-enable for `~/brain` vault
