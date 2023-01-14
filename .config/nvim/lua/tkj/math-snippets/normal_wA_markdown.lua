local ls = require("luasnip")

local normal_wA = {
	ls.parser.parse_snippet({ trig = "mk", name = "Math" }, "$${1:${TM_SELECTED_TEXT}}$ $0"),
	ls.parser.parse_snippet({ trig = "dm", name = "Block Math" }, "$$\n${1:${TM_SELECTED_TEXT}}\n$$ $0"),
	ls.parser.parse_snippet({ trig = "-ð", name = "Checkbox" }, "- [ ] $0"),
	ls.parser.parse_snippet({ trig = "gaboo", name = "Setning" }, [[\setning{$1}{$0}]]),
	ls.parser.parse_snippet({ trig = "þþaa", name = "þþaa stytting" }, [[þ.þ.a.a.]]),
}

return normal_wA
