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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    -- Plugins block
    {
	    "utilyre/barbecue.nvim",
	    name = "barbecue",
	    version = "*",
	    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
	    opts = {},
    },{
	    "lukas-reineke/indent-blankline.nvim",
	    event = "VeryLazy",
			main = "ibl",
			opts = { enabled = true, indent = {char = "|"} }
		},{
			"projekt0n/github-nvim-theme",
			name = "github-theme",
			lazy = false,
			priority = 1000,
			config = function()
				require("github-theme").setup({})
				vim.cmd("colorscheme github_light")
			end,
		},{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons", "linrongbin16/lsp-progress.nvim" },
			opts = { options = { theme = "ayu_dark"} },
			sections = {
				lualine_c = {
					"filename",
					file_status = true,
					newfile_status = false,
					path = 4,
					symbols = { modified = "[+]", readonly = "[-]" }
				}
			}
		},{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			opts = {
				check_ts = true,
				ts_config = { lua = { "string" } }
			}
		},{
			"nvim-tree/nvim-tree.lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = { actions = { open_file = { window_picker = { enable = false } } } },
			config = function(_, opts)
				vim.g.loaded_netrw = 1
				vim.g.loaded_netrwPlugin = 1
				require("nvim-tree").setup(opts)
		  end
		},{
			"nvim-treesitter/nvim-treesitter",
			event = "VeryLazy",
			dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
			build = ":TSUpdate",
			opts = {
				highlight = { enable = true },
				indent = { enable = true },
        auto_install = true,
				ensure_installed = { "lua", "python" },
			},
			config = function(_, opts)
				local configs = require("nvim-treesitter.configs")
				configs.setup(opts)
			end
		},{
			"nvim-telescope/telescope.nvim",
			lazy = true,
			dependencies = {
				{ "nvim-lua/plenary.nvim" },
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
					cond = function()
						return vim.fn.executable "make" == 1
					end
				},
			},
			opts = { defaults = { 
				layout_config = { vertical = { widht = 0.75 } },
				path_display = { filename_first = { reverse_directories = true} },
				}
			}
		},
		-- LSP related plugins
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
			dependencies = { 
				"L3MON4D3/LuaSnip", 
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lsp",
				"rafamadriz/friendly-snippets",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-cmdline"
			},
			config = function()
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				require("luasnip.loaders.from_vscode").lazy_load()
				luasnip.config.setup({})

				cmp.setup({
					snippet = {
						expand = function(args)
							luasnip_lsp_expand(args.body)
						end
					},
					completion = { completeopt = "menu,menuone,noinsert"},
					mapping = cmp.mapping.preset.insert {
						["<C-j>"] = cmp.mapping.select_next_item(),
						["<C-k>"] = cmp.mapping.select_prev_item(),
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete {},
						["<CR>"] = cmp.mapping.confirm {
							behavior = cmp.ConfirmBehavior.Replace,
							select = true
						},
						["<Tab>"] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							elseif luasnip.locally_jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, {"i", "s"})
					},
					sources = cmp.config.sources({
						{name = "nvim_lsp"},
						{name = "luasnip"},
						{name = "buffer"},
						{name = "path"}
					}),
					window = {
						completion = cmp.config.window.bordered(),
						documentation = cmp.config.window.bordered()
					}
				})
			end
		},{
			"neovim/nvim-lspconfig",
			event = "VeryLazy",
			dependencies = {
				{"williamboman/mason.nvim"}, 
				{"williamboman/mason-lspconfig.nvim"},
				{"j-hui/fidget.nvim", opts = {}},
			  {"folke/neodev.nvim", opts = {}}

		},
			config = function()
				require("mason").setup()
				require("mason-lspconfig").setup({
					ensure_installed = {"lua_ls", "pyright"}
				})

				local lspconfig = require("lspconfig")
				local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
				local lsp_attach = function(client, bufnr)
				end

				require("mason-lspconfig").setup_handlers({
					function(server_name)
						lspconfig[server_name].setup({
							on_attach = lsp_attach,
							capabilities = lsp_capabilities
						})
					end
				})

				lspconfig.lua_ls.setup {
					settings = {Lua = {diagnostics = {globals = {"vim"}}}}
				}
				lspconfig.pyright.setup{
					cmd = {"pyright-langserver", "--stdio"},
					filetypes = {"python"},
					settings = {python = {analysis= {
						autoSearchPaths = true,
						diagnosticMode = "openFilesOnly",
						useLibraryCodeForTypes = true
					}}},
					single_file_support = true
				}

				local open_floating_preview = vim.lsp.util.open_floating_preview
				function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
					opts = opts or {}
					opts.border = opts.border or "rounded"
					return open_floating_preview(contents, syntax, opts, ...)
				end
			end
		}
		-- End of plugins block
  },	

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- automatically check for plugin updates
  checker = { enabled = true },
})


-- [[ Option configure ]] --
local opt = vim.opt
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
opt.ignorecase = true
opt.smartcase = true
opt.showmatch = true



-- [[ Keysmaps ]] --
local keymap = vim.keymap

keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically



-- [[ CMD commands ]] --
