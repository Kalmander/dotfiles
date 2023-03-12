local cmp = require("cmp")
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load() -- þarft fyrir friendly snippets

local kind_icons = {
        Text = "",
        Method = "m",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
}

---- CMP -----------------------------------------------------------------------
cmp.setup({
        snippet = {
                expand = function(args)
                        ls.lsp_expand(args.body) -- For `luasnip` users.
                end,
        },
        mapping = {

                ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<c-d>"] = cmp.mapping.scroll_docs(4),
                ["<c-u>"] = cmp.mapping.scroll_docs(-4),
                ["<c-e>"] = cmp.mapping.abort(),
                ["<c-j>"] = cmp.mapping(
                        cmp.mapping.confirm({
                                behavior = cmp.ConfirmBehavior.Insert,
                                select = true,
                        }),
                        { "i", "c" }
                ),
                -- ["<M-y>"] = cmp.mapping(
                -- 	cmp.mapping.confirm({
                -- 		behavior = cmp.ConfirmBehavior.Replace,
                -- 		select = false,
                -- 	}),
                -- 	{ "i", "c" }
                -- ),
                --
                -- ["<c-space>"] = cmp.mapping({
                -- 	i = cmp.mapping.complete(),
                -- 	c = function(
                -- 		_ --[[fallback]]
                -- 	)
                -- 		if cmp.visible() then
                -- 			if not cmp.confirm({ select = true }) then
                -- 				return
                -- 			end
                -- 		else
                -- 			cmp.complete()
                -- 		end
                -- 	end,
                -- }),
        },
        formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                        -- Kind icons
                        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                        vim_item.menu = ({
                                nvim_lsp = "[LSP]",
                                luasnip = "[Snippet]",
                                buffer = "[Buffer]",
                                path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                end,
        },
        sources = {
                { name = "luasnip" },
                { name = "jupyter" },
                { name = "nvim_lsp" },
                { name = "cmp_nvim_r" },
                -- { name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
                { name = "buffer", keyword_length = 5 },
                { name = "path" },
        },
        confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = false,
        },
        window = {
                documentation = {
                        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                },
        },
        experimental = {
                ghost_text = false,
                native_menu = false,
        },
        enable_autosnippets = true,
})

---- LUASNIP -------------------------------------------------------------------
ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
})

vim.keymap.set({ "i", "s" }, "<c-l>", function()
        if ls.jumpable(1) then
                ls.jump(1)
        end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-k>", function()
        if ls.jumpable(-1) then
                ls.jump(-1)
        end
end, { silent = true })

-- <c-l> is selecting within a list of options.
-- This is useful for choice nodes (introduced in the forthcoming episode 2)
-- vim.keymap.set("i", "<tab>", function()
-- 	if ls.choice_active() then
-- 		ls.change_choice(1)
-- 	end
-- end)

-- vim.keymap.set("i", "<c-u>", require("luasnip.extras.select_choice"))

