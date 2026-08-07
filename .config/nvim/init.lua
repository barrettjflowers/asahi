-- ~/.config/nvim/init.lua

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = false
vim.o.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.statusline = " %f %m %= %l:%c "
vim.o.clipboard = ""
vim.opt.mouse = ""

-- overide string colors
vim.api.nvim_set_hl(0, "String", { ctermfg = 15 })
vim.api.nvim_set_hl(0, "StatusLine", { ctermfg = 15, ctermbg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC", { ctermfg = 8, ctermbg = "NONE" })

-- blinking cursor
vim.opt.guicursor =
  "n-v-c:block," ..
  "i-ci-ve:ver25-blinkwait175-blinkoff150-blinkon175," ..
  "r-cr:hor20," ..
  "o:hor50"

-- plugins
vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/stevearc/oil.nvim" },

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },

	{ src = "https://github.com/hrsh7th/nvim-cmp"},
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp"},
	{ src = "https://github.com/hrsh7th/cmp-buffer"},
	{ src = "https://github.com/hrsh7th/cmp-path"},
	{ src = "https://github.com/supermaven-inc/supermaven-nvim"},
	{ src = "https://github.com/stevearc/conform.nvim" },
})

-- LSP init
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs({ "lua_ls", "rust_analyzer", "ts_ls", "html", "svelte" }) do
  vim.lsp.config[server] = { capabilities = capabilities }
end

local enabled_servers = { "lua_ls", "rust_analyzer", "ts_ls", "html", "svelte" }
if vim.fn.executable("clangd") == 1 then
  vim.lsp.config.clangd = { capabilities = capabilities }
  table.insert(enabled_servers, "clangd")
end
vim.lsp.enable(enabled_servers)

-- init plugins
require "mini.pick".setup()
require "mason".setup()
require "oil".setup()

local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if ok then
  treesitter.setup({
    ensure_installed = { "svelte", "typescript", "javascript", "c" },
    highlight = { enable = true },
  })
end

-- maps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>g', ":Pick grep_live<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>0", ':set nonumber<CR> :set norelativenumber<CR> :lua vim.diagnostic.config({ signs = false })<CR>')

vim.keymap.set('n', '<leader>lf', function()
  require("conform").format({ lsp_fallback = true })
end)

-- supermaven
require("supermaven-nvim").setup({
  disable_keymaps = true,
})

-- formatting (clang-format for C/C++, lsp via dnf)
require("conform").setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
})

-- nvim-cmp setup
local cmp = require("cmp")
local supermaven_preview = require("supermaven-nvim.completion_preview")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif supermaven_preview.has_suggestion() then
        supermaven_preview.on_accept_suggestion()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})


