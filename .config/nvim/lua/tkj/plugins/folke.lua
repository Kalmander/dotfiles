return {
	"folke/twilight.nvim",
	{ "folke/which-key.nvim", config = true },
	-- { "folke/trouble.nvim", config = true, dependencies = "kyazdani42/nvim-web-devicons" },
	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({
				window = {
					backdrop = 1,
				},
				plugins = {
					-- disable some global vim options (vim.o...)
					-- comment the lines to not apply the options
					options = {
						enabled = true,
						ruler = false, -- disables the ruler text in the cmd line area
						showcmd = false, -- disables the command in the last line of the screen
					},
					twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
				},
			})


			local zen_modes = {
				normal = {
					window = {
						backdrop = 1,
						width = .99,
						height = .99,
					},
					plugins = {
						twilight = { enabled = false },
					},
				},
				super = {
					window = {
						backdrop = 1,
						width = .99,
						height = .99,
						options = {
							number = false,
							relativenumber = false,
							signcolumn = "no",
							cursorline = false,
							foldcolumn = "0",
							list = false,
						}
					},
					plugins = {
						twilight = { enabled = false },
					},
				},
				centered = {
					window = {
						backdrop = 1,
						width = .7,
						height = .99,
					},
					plugins = {
						twilight = { enabled = false },
					},
				},
				super_centered = {
					window = {
						backdrop = 1,
						width = .7,
						height = .99,
						options = {
							number = false,
							relativenumber = false,
							signcolumn = "no",
							cursorline = false,
							foldcolumn = "0",
							list = false,
						}
					},
					plugins = {
						twilight = { enabled = false },
					},
				},
			}
			local set_zen_mode = function(mode)
				if mode == 'off' then
					require("zen-mode").close()
					-- require("lualine").hide({ unhide = true })
					return
				end

				require("zen-mode").close()
				-- require("lualine").hide()
				require("zen-mode").open(zen_modes[mode])

				vim.api.nvim_set_hl(0, "kanTagBoys", { fg = "#595f6f", italic = true })
				vim.fn.matchadd('kanTagBoys', [[\#\{1\}[^[:space:]#]\+]])
				vim.api.nvim_set_hl(0, "Pomodorro", { fg = "#fc5d7c" })
				vim.fn.matchadd('Pomodorro', [[🍅]])
			end
			vim.keymap.set("n", "<leader>mm", function() set_zen_mode('off') end)
			vim.keymap.set("n", "<leader>mq", function() set_zen_mode('normal') end)
			vim.keymap.set("n", "<leader>mw", function() set_zen_mode('super') end)
			vim.keymap.set("n", "<leader>me", function() set_zen_mode('centered') end)
			vim.keymap.set("n", "<leader>mr", function() set_zen_mode('super_centered') end)
		end
	},

	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", },
		opts = {
			cmdline = {
				view = "cmdline",
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = false, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			mini = { timeout = 3000 },
			--
			-- Felur virtal text search
			--
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
					},
					opts = { skip = true },
				},
			},
		},
	}
}
