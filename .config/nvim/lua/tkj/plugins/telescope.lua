return {
	{
		"nvim-telescope/telescope.nvim",
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {

					prompt_prefix = " ",
					selection_caret = " ",
					path_display = { "smart" },
					layout_strategy = "vertical",
					scroll_strategy = "limit", -- default er cycle

					mappings = {
						i = {
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,

							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,

							["<C-c>"] = actions.close,

							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,

							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,

							["<C-b>"] = actions.results_scrolling_up,
							["<C-f>"] = actions.results_scrolling_down,
							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,

							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-l>"] = actions.complete_tag,
							["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
						},

						n = {
							["<esc>"] = actions.close,
							["<C-c>"] = actions.close,
							["q"] = actions.close,
							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,

							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

							["j"] = actions.move_selection_next,
							["k"] = actions.move_selection_previous,
							["H"] = actions.move_to_top,
							["M"] = actions.move_to_middle,
							["L"] = actions.move_to_bottom,

							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,
							["gg"] = actions.move_to_top,
							["G"] = actions.move_to_bottom,

							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,

							["<C-b>"] = actions.results_scrolling_up,
							["<C-f>"] = actions.results_scrolling_down,
							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,

							["?"] = actions.which_key,
						},
					},
				},
				pickers = {
					colorscheme = {
						enable_preview = true,
					},
					-- Default configuration for builtin pickers goes here:
					-- picker_name = {
					--   picker_config_key = value,
					--   ...
					-- }
					-- Now the picker_config_key will be applied every time you call this
					-- builtin picker
				},
				extensions = {
					-- Your extension configuration goes here:
					-- extension_name = {
					--   extension_config_key = value,
					-- }
					-- please take a look at the readme of the extension you want to configured
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
					lazy = {
						-- theme = 'ivy'
						layout_strategy = "bottom_pane",
						sorting_strategy = "ascending",
						border = false,
					},
					menufacture = {
						mappings = {
							main_menu = { [{ "i", "n" }] = "<C-^>" },
						},
					},
				},
			})
			telescope.load_extension("fzf")
			telescope.load_extension("projects")
			telescope.load_extension("env")
			telescope.load_extension("lazy")
			telescope.load_extension("luasnip")
			telescope.load_extension("dir")
			telescope.load_extension("menufacture")
		end,
	},
	{ "LinArcX/telescope-env.nvim" },
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				manual_mode = false, -- þarft þá að nota :ProjectRoot
				detection_methods = { "pattern" }, -- be default er lsp primary og pattern 2nd
				silent_chdir = false, -- true by default
				scope_chdir = "tab", -- global by default
				patterns = { ".git", "Makefile", ">.config", ">share" },
			})
		end,
	},
	{ "tsakirist/telescope-lazy.nvim" },
	{ "benfowler/telescope-luasnip.nvim" },
	{
		"princejoogie/dir-telescope.nvim",
		opts = {
			layout_strategy = "bottom_pane",
			sorting_strategy = "ascending",
			border = false,
		},
	},
	{
		"sudormrfbin/cheatsheet.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
	},
	{ "molecule-man/telescope-menufacture" },
}