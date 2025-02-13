--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- Neovim Lua Config File by Arfan Zubi
-- SETUPS

-- NvimTree
require("nvim-tree").setup()

-- Alpha startup screen / dashboard
require("alpha").setup(require("alpha.themes.startify").config)
require("alpha.themes.dashboard").section.footer.val = require("alpha.fortune")() -- Quotes

-- Lualine status bar
require("lualine").setup({
    options = {
        theme = "auto",
        component_separators = " ",
        section_separators = { left = "", right = "" },
    },
})

-- Nvim Autopairs
require("nvim-autopairs").setup()

-- Git signs
require("gitsigns").setup()

-- Line highlighting
require("ibl").setup({
    indent = { char = "┊" },
    scope = { enabled = false },
})

-- Hex color highlighting
require("colorizer").setup()

-- Noice
require("noice").setup({
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
    },
    presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = false,      -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true,        -- add a border to hover docs and signature help
    },
})
