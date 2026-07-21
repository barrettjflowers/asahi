 -- ~/.config/nvim/init.lua
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = ""
vim.opt.mouse = ""

-- blinking cursor
vim.opt.guicursor =
  "n-v-c:block," ..
  "i-ci-ve:ver25-blinkwait175-blinkoff150-blinkon175," ..
  "r-cr:hor20," ..
  "o:hor50"

-- plugins
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/stevearc/oil.nvim" },

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },

	{ src = "https://github.com/nvim-lua/plenary.nvim"},
	{ src = "https://github.com/hrsh7th/nvim-cmp"},
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp"},
	{ src = "https://github.com/hrsh7th/cmp-buffer"},
	{ src = "https://github.com/hrsh7th/cmp-path"},
	{ src = "https://github.com/supermaven-inc/supermaven-nvim"},
})

-- LSP init
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.lua_ls = {
  capabilities = capabilities,
}
vim.lsp.config.rust_analyzer = {
  capabilities = capabilities,
}
vim.lsp.config.ts_ls = {
  capabilities = capabilities,
}
vim.lsp.config.html = {
  capabilities = capabilities,
}
vim.lsp.config.svelte = {
  capabilities = capabilities,
}

vim.lsp.enable({ "lua_ls", "rust_analyzer", "ts_ls", "html", "svelte" })

-- init plugins
require "mini.pick".setup()
require "mason".setup()
require "oil".setup()

local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if ok then
  treesitter.setup({
    ensure_installed = { "svelte", "typescript", "javascript" },
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

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- supermaven
require("supermaven-nvim").setup({
  disable_keymaps = true,
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
    { name = "supermaven" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- styling
require "vague".setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
vim.api.nvim_set_hl(0, "Normal", { bg = nil })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = nil })
