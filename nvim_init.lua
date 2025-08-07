vim.opt.swapfile = false
vim.opt.number = true
vim.opt.autoindent = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 3
vim.opt.laststatus = 2
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "if mode() != 'c' | checktime | endif"
})

vim.cmd.colorscheme("desert")
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.highlight({ "Cursor", "guifg=white guibg=white" })
vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
	pattern = "*",
	command =
	"set guicursor=n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
})
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
	pattern = "*",
	command = "echohl WarningMsg | echo \"File changed on disk. Buffer reloaded.\" | echohl None"
})
vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend" }, {
	pattern = "*",
	command = "set guicursor=a:block-blinkon0"
})
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50"

vim.g.mapleader = ','

vim.cmd(':au FocusLost * silent! wa')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	-- install all the plugins you need here

	-- lsp config for elixir-ls support
	'neovim/nvim-lspconfig',

	-- cmp framework for auto-completion support
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',

	-- treesitter for syntax highlighting and more
	{ 'nvim-treesitter/nvim-treesitter',          run = ':TSUpdate' },

	'tpope/vim-surround',
	'tpope/vim-fugitive',
	'nvim-lua/plenary.nvim',
	{
		'nvim-telescope/telescope.nvim',
		requires = { { 'nvim-lua/plenary.nvim' } }
	},
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	{
		'nvim-tree/nvim-tree.lua',
		lazy = false,
		config = function()
			require("nvim-tree").setup {}
		end,
	},

	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },

	{
		'folke/trouble.nvim',
		opts = {},
		cmd = "Trouble",
	},
	checker = { enabled = true }
})

require('nvim-treesitter.configs').setup {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	ensure_installed = { "javascript", "json", "lua", "elixir", "heex", "python", "bash" },
}

require("mason").setup()
require("mason-lspconfig").setup {
	ensure_installed = { "lua_ls", "lexical", "terraformls", "pylsp", "bashls" },
}

local telescope = require("telescope")
local telescopeConfig = require("telescope.config")


-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

require('telescope').setup {
	defaults = {
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")
-- lspconfig.elixirls.setup {
-- 	cmd = { "elixir-ls" },
-- 	capabilities = capabilities,
-- }
lspconfig.lexical.setup {
	cmd = { "/Users/gwenny/workspace/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.cwd()
	end,
	filetypes = { "elixir", "eelixir", "heex" },
	capabilities = capabilities,
}

require("lspconfig").terraformls.setup {
	capabilities = capabilities
}

require("lspconfig").pylsp.setup {
	capabilities = capabilities
}

require("lspconfig").lua_ls.setup {
	capabilities = capabilities
}

require("lspconfig").bashls.setup {
	capabilities = capabilities
}

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<leader>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

local cmp = require("cmp")
cmp.setup {
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body) -- native neo vim snippets
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" }
	}
}

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

vim.keymap.set('n', '<leader>v', ':vsp<CR>')
vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>a', ':Telescope live_grep<CR>')
vim.keymap.set('v', '<leader>a', ':Telescope grep_string<CR>')
vim.keymap.set('n', '\\', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '|', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
