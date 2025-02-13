--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- Neovim Lua Config File by Arfan Zubi
-- MASON

local lspconfig = require("lspconfig")

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "dotls",
        "eslint",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "rust_analyzer",
        "sqlls",
        "taplo",
        "ts_ls",
        "yamlls",
    },
    automatic_installation = true,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- lspconfig setups for installed LSP servers via Mason
require("mason-lspconfig").setup_handlers({
    function(server_name)
        lspconfig[server_name].setup({
            capabilities = capabilities
        })
    end,
    ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "opt", "g", "kmap", "cmd", "Snacks" }
                    }
                }
            }
        })
    end,
})
