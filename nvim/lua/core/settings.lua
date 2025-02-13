--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- Neovim Lua Config File by Arfan Zubi
-- SETTINGS

-- Set termguicolors to enable highlight groups
opt.termguicolors = true

-- UTF8 encoding
opt.encoding = "UTF-8"

-- Enabling clipboard
opt.clipboard = "unnamedplus"

-- Persistent undo
opt.undofile = true

-- Line numbers
opt.number = true

-- Relative line numbers
opt.relativenumber = true

-- Horizontal cursor line
opt.cursorline = true

-- Vertical cursor line
opt.cursorcolumn = true

-- Shift width
opt.shiftwidth = 4

-- Tab width
opt.tabstop = 4

-- Space characters instead of tabs
opt.expandtab = true

-- Disable backup files
opt.backup = false
opt.writebackup = false

-- Always show the signcolumn
opt.signcolumn = "yes"

-- Do not let cursor scroll below or above N number of lines when scrolling
opt.scrolloff = 10

-- Wrap lines
opt.wrap = true

-- Preserve indentation of virtual line
opt.breakindent = true

-- Search highlighting
opt.hlsearch = false

-- Incrementally highlight matching characters while typing
opt.incsearch = true

-- Ignoring capital letters during search
opt.ignorecase = true

-- Overriding ignorecase option if searching for capital letters
opt.smartcase = true

-- Showing matching words during search
opt.showmatch = true

-- Showing partial command on last line
opt.showcmd = true

-- Showing mode on last line
opt.showmode = false

-- Command history
opt.history = 1000

-- Auto completion menu after pressing TAB
opt.wildmenu = true

-- Bash-like completion
opt.wildmode = "list:full"

-- Ignoring files with certain extensions
opt.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"

-- Command completion in popup menu
opt.wildoptions = "pum"
--opt.pumblend = 7   -- Make popup translucent
opt.pumheight = 20 -- Max amount of items

-- Mouse support
opt.mouse = "a"

-- Hide End-Of-Buffer symbol (~)
opt.fillchars:append({ eob = " " })

-- Settings for line highlighting
opt.list = true

-- Settings for cmp-spell
opt.spell = true
opt.spelllang = { "en_us", "de" }

-- Opening new split panes to right and below
opt.splitright = true
opt.splitbelow = true

-- Disable netrw (native VIM file explorer)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- GUI settings
opt.guifont = { "FiraCode Nerd Font", ":h14" }

-- Disabling providers (if downloaded Neovim from one of this providers don't delete!)
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0
