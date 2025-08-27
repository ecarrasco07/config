vim.cmd([[set mouse=]])
vim.opt.winborder = "rounded"
vim.opt.hlsearch = false
vim.opt.tabstop = 2
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"

vim.o.timeout = false
vim.o.completeopt = 'menuone,noselect'
vim.opt.inccommand = 'split'

local map = vim.keymap.set
vim.g.mapleader = " "
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>v', ':e $MYVIMRC<CR>')
map('n', '<leader>z', ':e ~/.config/zsh/.zshrc<CR>')
map('n', '<leader>s', ':e #<CR>')
map('n', '<leader>S', ':sf #<CR>')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')
map({ 'n', 'v' }, '<leader>c', '1z=')

-- windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.pack.add({
	{ src = "https://github.com/EdenEast/nightfox.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", build = ":TSUpdate" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs"},
	{ 
		src = "https://github.com/Saghen/blink.cmp", 
		branch = 'v.1.6.0',
	},
	{ src = "https://github.com/nvim-lua/plenary.nvim"},
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = 'make'},
	{ src = "https://github.com/nvim-telescope/telescope.nvim"},
})

-- colors
require("nightfox").setup({ transparent = true })
vim.cmd("colorscheme nightfox")
vim.cmd(":hi statusline guibg=NONE")

-- Helper to update any packages if need. uncomment
-- vim.pack.update({"nvim-treesitter"})
-- vim.pack.del({"telescope.nvim"})

require "mason".setup()
require "oil".setup({
	float = {
		padding = 5,
		max_width = 90,
		max_height = 60,
	},
	delete_to_trash = true,
	view_opptions = {
		show_hidden = true
	}
})
require "nvim-autopairs".setup()

map('n', '<leader>e', ":Oil --float<CR>")
map('t', '', "")
map('t', '', "")
map('n', '<leader>lf', vim.lsp.buf.format)

-- Autocomplete and LSP
require "blink.cmp".setup({
	fuzzy = {
		implementation = "lua",
		use_frecency = true,
		use_proximity = true,
		prebuilt_binaries = {
			download = true,
		}
	},
	signature = {
		enabled = true,
	},
})

local capabilities = require("blink.cmp").get_lsp_capabilities()
-- Configure pyright
vim.lsp.config("*", {
  capabilities = capabilities,
})
-- Configure all enabled servers
vim.lsp.enable({ "pyright", "lua_ls" })

vim.diagnostic.config({
  virtual_text = { current_line = true }
})

-- configure treesitter
local parser_installed = {
		"python",
		"lua",
		"vim",
		"query",
		"markdown",
}
vim.defer_fn(function() require("nvim-treesitter").install(parser_installed) end, 1000)
require("nvim-treesitter").update()
-- auto-start highlights & indentation
vim.api.nvim_create_autocmd("FileType", {
		desc = "User: enable treesitter highlighting",
		callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start) -- errors for filetypes with no parser

				-- indent
				local noIndent = {}
				if hasStarted and not vim.list_contains(noIndent, ctx.match) then
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
		end,
})

--telescope config
require('telescope').setup {
	pickers = {
		find_files = {
			theme = "ivy"
		}
	},
	extensions = {
		fzf = {}
	}
}

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>st', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '/', function()
	builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
		winblend = 10,
		previewer = false,
	})
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
	builtin.live_grep {
		grep_open_files = true,
		prompt_title = 'Live Grep in Open Files',
	}
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>fn', function()
	builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

vim.keymap.set("n", "<space>fh", require('telescope.builtin').help_tags)
vim.keymap.set("n", "<space>fd", require('telescope.builtin').find_files)


