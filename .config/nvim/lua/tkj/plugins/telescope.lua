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


			-- KEYMAPS -----------------------------
			local dropdown = require("telescope.themes").get_dropdown
			local tel = require("telescope.builtin")
			local tele = require("telescope").extensions
			local telem = require("telescope").extensions.menufacture
			local bottom = { layout_strategy = "bottom_pane", sorting_strategy = "ascending", border = false }

			local m = vim.keymap.set
			m('n', '<leader>F', tel.resume, { desc = 'Resume Previous Telescope' })
			m('n', "<leader>fk", tel.keymaps, { desc = 'Telescope Keymaps' })
			m('n', "<leader>fR", tel.registers, { desc = 'Telescope Registers' })
			m('n', "<leader>fm", tel.marks, { desc = 'Telescope Marks' })
			m('n', "<leader>fa", tel.man_pages, { desc = 'Telescope Man Pages' })
			m('n', "<leader>ft", tel.treesitter, { desc = 'Telescope Treesitter' })
			m('n', "<leader>fT", tel.builtin, { desc = 'Telescope Telescopes' })
			m('n', "<leader>fO", tel.vim_options, { desc = 'Telescope Vim Options' })
			m('n', "<leader>fC", tel.commands, { desc = 'Telescope User Commands' })
			m('n', "<leader>fE", tele.env.env, { desc = 'Telescope Environment Variables' })
			m('n', "<leader>fl", tele.lazy.lazy, { desc = "Telescope Lazy Plugins" })
			m('n', "<leader>fL", tele.luasnip.luasnip, { desc = "Telescope Plugins" })
			m('n', "<leader>fp", tele.projects.projects, { desc = 'Telescope Projects' })
			m('n', "<leader>fD", tele.dir.live_grep, { desc = 'Telescope Live Grep in Subdirectory' })
			m('n', "<leader>fh", function() tel.help_tags(bottom) end, { desc = 'Telescope Help Tags' })
			m('n', "<leader>fo", function() tel.oldfiles(bottom) end, { desc = 'Telescope Oldfiles' })
			m('n', "<leader>fg", function() tel.git_bcommits(bottom) end, { desc = 'Telescope Git Buffer Commits' })
			m('n', "<leader>fG", function() tel.git_commits(bottom) end, { desc = 'Telescope Git All Commits' })
			m('n', "<leader>fS", function() tel.git_status(bottom) end, { desc = 'Telescope Git Status' })
			m('n', "<leader>fr", function() tel.lsp_references(bottom) end, { desc = 'Telescope LSP References' })
			m('n', "<leader>fH", function() tel.highlights(bottom) end, { desc = 'Telescope Highlights' })
			m('n', "<leader>fb", function() tel.buffers(bottom) end, { desc = 'Telescope Buffers' })
			m('n', "<leader>fd", function() telem.live_grep(bottom) end, { desc = 'Telescope Live Grep CWD' })
			m('n', "<leader>fe", function() tel.current_buffer_fuzzy_find(bottom) end, { desc = 'Telescope Current Buffer' })
			m('n', "<leader>fs", function() telem.live_grep(bottom) end, { desc = 'Telescope Latex Snippets' })
			m('n', "<leader>ff",
				function()
					telem.find_files(dropdown({ previewer = false, prompt_title = 'Find Files Under CWD' }))
				end, { desc = 'Telescope Files Under CWD' })
			m('n', "<leader>fn",
				function()
					telem.find_files(dropdown({ previewer = false, cwd = "~/.config/nvim/", prompt_title = 'Search Neovim Config' }))
				end, { desc = 'Telescope NeoVim Config' })
			m('n', "<leader>fN",
				function()
					telem.live_grep( { cwd = '~/.config/nvim/', layout_strategy = "bottom_pane", sorting_strategy = "ascending", border = false } )
				end, { desc = 'Telescope NeoVim Config' })
			m('n', "<leader>fc", "<cmd>Cheatsheet<cr>", { desc = 'Cheatsheet' })

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
				silent_chdir = true, -- true by default
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
