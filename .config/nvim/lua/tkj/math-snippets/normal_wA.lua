local ls = require("luasnip")

local normal_wA = {
	ls.parser.parse_snippet({ trig = "mk", name = "Math" }, "\\$${1:${TM_SELECTED_TEXT}}\\$$0"),
	ls.parser.parse_snippet({ trig = "dm", name = "Block Math" }, "\\[\n${1:${TM_SELECTED_TEXT}}\n.\\] $0"),
	ls.parser.parse_snippet({ trig = "enq", name = "Enquote" }, [[\\enquote{${1:${TM_SELECTED_TEXT}}}$0]]),
	ls.parser.parse_snippet({ trig = "citee", name = "Cite" }, [[\\cite{${1:${TM_SELECTED_TEXT}}}$0]]),
	ls.parser.parse_snippet({ trig = "citee", name = "Cite" }, [[\\cite{${1:${TM_SELECTED_TEXT}}}$0]]),
	ls.parser.parse_snippet({ trig = "SET", name = "Setning" }, [[\\setning{${1:${TM_SELECTED_TEXT}}}{$2}$0]]),
	ls.parser.parse_snippet({ trig = "SON", name = "Sönnun" }, [[\\sonnun{${1:Sönnun}}{$2}$0]]),
	ls.parser.parse_snippet({ trig = "SKI", name = "Skilgreining" }, [[\\skilgreining{$1}{$2}$0]]),
	ls.parser.parse_snippet({ trig = "YRD", name = "Yriðing" }, [[\\yrding{$1}{$2}$0]]),
	ls.parser.parse_snippet({ trig = "HJA", name = "Hjálparsetning" }, [[\\lemma{$1}{$2}$0]]),
	ls.parser.parse_snippet({ trig = "bbold", name = "Bold text" }, [[\\textbf{$1}$0]]),
	ls.parser.parse_snippet({ trig = "item", name = "Item" }, [[\item]]),
}

return normal_wA
