--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- Neovim Lua Config File by Arfan Zubi
-- PLUGINS

return {
    -------- Appearance
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        }
    },

    "goolord/alpha-nvim",        -- Startup screen
    "nvim-lualine/lualine.nvim", -- Status line

    -------- Neovim Tools
    "stevearc/conform.nvim",              -- Formatter
    "mbbill/undotree",                    -- Undo tree
    require("plugins.configs.which-key"), -- Show keymaps

    {
        "nvim-tree/nvim-tree.lua", -- NvimTree
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    {
        "nvim-treesitter/nvim-treesitter", -- Treesitter
        build = ":TSUpdate"
    },
    {
        "hrsh7th/nvim-cmp", -- Auto completion
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",

            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
        }
    },
    {
        "nvim-telescope/telescope.nvim", -- Telescope
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "smartpde/telescope-recent-files",
            "tom-anders/telescope-vim-bookmarks.nvim"
        }
    },

    ------- LSP
    "williamboman/mason.nvim",           -- LSP packet manager
    "williamboman/mason-lspconfig.nvim", -- lspconfig integration
    "neovim/nvim-lspconfig",             -- LSP configuration

    ------- Editing Tools
    "lewis6991/gitsigns.nvim",             -- Git signs
    "lukas-reineke/indent-blankline.nvim", -- Line highlighting
    "windwp/nvim-autopairs",               -- Auto closing brackets, parenthesis etc.
    "norcalli/nvim-colorizer.lua",         -- Hex color highlighting
    "hiphish/rainbow-delimiters.nvim",     -- Brackets, parenthesis colorizing
    "MattesGroeger/vim-bookmarks",         -- Bookmarks
}
