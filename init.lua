-- [[ Option configure ]] --
local opt = vim.opt
local g = vim.g
local keymap = vim.keymap
-- Editor block
opt.encoding="utf-8"
opt.number = true
opt.cursorline = true
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true

-- Tabs block
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Search block
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true

g.mapleader = "\\"

-- [[ Keysmaps ]] --
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically


-- [[ CMD commands ]] --

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Github Light theme
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		priority = 1000,
		config = function()
			require("github-theme").setup({
			bold = false})
			vim.cmd("colorscheme github_light_colorblind")
		end
  },

	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {"SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons"},
		opts = {}
	},

	-- Blankline
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		main = "ibl",
		opts = {enabled = true, indent = {char = "|"}}
	},

	-- Line status
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {"nvim-tree/nvim-web-devicons", "linrongbin16/lsp-progress.nvim"},
		opts = {options = {theme = "ayu_dark"}},
		sections = {
			lualine_c = {
				"filename",
				file_status = true,
				newfile_status = false,
				path = 4,
				symbols = {modified = "[+]", readonly = "[-]"}
			}
		}
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			ts_config = {lua = {"string"}}
		}
	},

  -- LSP configs
	{
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.pyright.setup({})

      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
				},
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },

	-- Telescope configs
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
            },
          },
        },
      })

      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Search by text' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffer search' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help' })
    end,
  },

	-- Tree catalog configs
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup()

      vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { desc = 'Open tree folder' })
    end,
  },
})

vim.o.termguicolors = true

