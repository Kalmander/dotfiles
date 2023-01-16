local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local with_priority = require("tkj.math-snippets.util.utils").with_priority

local math_iA = {
	s(
		{
			trig = "(%a)bar",
			wordTrig = false,
			regTrig = true,
			name = "bar",
			priority = 100,
		},
		f(function(_, snip)
			return string.format("\\overline{%s}", snip.captures[1])
		end, {})
	),
	s(
		{
			trig = "(%a)hat",
			wordTrig = false,
			regTrig = true,
			name = "hat",
			priority = 100,
		},
		f(function(_, snip)
			return string.format("\\hat{%s}", snip.captures[1])
		end, {})
	),

	ls.parser.parse_snippet({ trig = "td", name = "to the ... power ^{}" }, "^{$1}$0"),
	ls.parser.parse_snippet({ trig = "rd", name = "to the ... power ^{()}" }, "^{($1)}$0"),
	ls.parser.parse_snippet({ trig = "cb", name = "Cube ^3" }, "^3"),
	ls.parser.parse_snippet({ trig = "sr", name = "Square ^2" }, "^2"),

	ls.parser.parse_snippet({ trig = "EE", name = "exists" }, "\\exists"),
	ls.parser.parse_snippet({ trig = "AA", name = "forall" }, "\\forall"),
	ls.parser.parse_snippet({ trig = "xnn", name = "xn" }, "x_{n}"),
	ls.parser.parse_snippet({ trig = "ynn", name = "yn" }, "y_{n}"),
	ls.parser.parse_snippet({ trig = "xii", name = "xi" }, "x_{i}"),
	ls.parser.parse_snippet({ trig = "yii", name = "yi" }, "y_{i}"),
	ls.parser.parse_snippet({ trig = "xjj", name = "xj" }, "x_{j}"),
	ls.parser.parse_snippet({ trig = "yjj", name = "yj" }, "y_{j}"),
	ls.parser.parse_snippet({ trig = "xp1", name = "x" }, "x_{n+1}"),
	ls.parser.parse_snippet({ trig = "xmm", name = "x" }, "x_{m}"),
	ls.parser.parse_snippet({ trig = "R0+", name = "R0+" }, "\\mathbb{R}_0^+"),

	ls.parser.parse_snippet({ trig = "notin", name = "not in " }, "\\not\\in"),

	ls.parser.parse_snippet({ trig = "cc", name = "subset" }, "\\subset"),

	with_priority(ls.parser.parse_snippet({ trig = "<->", name = "leftrightarrow" }, "\\leftrightarrow"), 200),
	with_priority(ls.parser.parse_snippet({ trig = "...", name = "ldots" }, "\\ldots"), 100),
	ls.parser.parse_snippet({ trig = "!>", name = "mapsto" }, "\\mapsto"),
	ls.parser.parse_snippet({ trig = "iff", name = "iff" }, "\\iff"),
	ls.parser.parse_snippet({ trig = "ooo", name = "\\infty" }, "\\infty"),
	ls.parser.parse_snippet({ trig = "rij", name = "mrij" }, "(${1:x}_${2:n})_{${3:$2}\\in${4:\\N}}$0"),
	ls.parser.parse_snippet({ trig = "nabl", name = "nabla" }, "\\nabla"),
	ls.parser.parse_snippet({ trig = "<!", name = "normal" }, "\\triangleleft"),
	ls.parser.parse_snippet({ trig = "floor", name = "floor" }, "\\left\\lfloor $1 \\right\\rfloor$0"),
	ls.parser.parse_snippet({ trig = "mcal", name = "mathcal" }, "\\mathcal{$1}$0"),
	ls.parser.parse_snippet({ trig = "mbb", name = "mathbb" }, "\\mathbb{$1}$0"),
	ls.parser.parse_snippet({ trig = "//", name = "Fraction" }, "\\frac{$1}{$2}$0"),
	ls.parser.parse_snippet({ trig = "\\\\\\", name = "setminus" }, "\\setminus"),
	with_priority(ls.parser.parse_snippet({ trig = "->", name = "to" }, "\\to"), 100),

	ls.parser.parse_snippet({ trig = "letw", name = "let omega" }, "Let $\\Omega \\subset \\C$ be open."),
	ls.parser.parse_snippet({ trig = "nnn", name = "bigcap" }, "\\bigcap_{${1:i \\in ${2: I}}} $0"),
	ls.parser.parse_snippet({ trig = "norm", name = "norm" }, "\\|$1\\|$0"),
	ls.parser.parse_snippet({ trig = "<>", name = "hokje" }, "\\diamond"),
	ls.parser.parse_snippet({ trig = ">>", name = ">>" }, "\\gg"),
	ls.parser.parse_snippet({ trig = "<<", name = "<<" }, "\\ll"),

	ls.parser.parse_snippet({ trig = "stt", name = "text subscript" }, "_\\text{$1} $0"),
	ls.parser.parse_snippet({ trig = "tt", name = "text" }, "\\text{$1}$0"),

	ls.parser.parse_snippet({ trig = "xx", name = "cross" }, "\\times"),

	with_priority(ls.parser.parse_snippet({ trig = "**", name = "cdot" }, "\\cdot"), 100),

	ls.parser.parse_snippet(
		{ trig = "cvec", name = "column vector" },
		"\\begin{pmatrix} ${1:x}_${2:1}\\\\ \\vdots\\\\ $1_${2:n} \\end{pmatrix}"
	),
	ls.parser.parse_snippet({ trig = "ceil", name = "ceil" }, "\\left\\lceil $1 \\right\\rceil $0"),
	ls.parser.parse_snippet({ trig = "empty", name = "emptyset" }, "\\emptyset"),
	ls.parser.parse_snippet({ trig = "RR", name = "R" }, "\\mathbb{R}"),
	ls.parser.parse_snippet({ trig = "CC", name = "C" }, "\\mathbb{C}"),
	ls.parser.parse_snippet({ trig = "QQ", name = "Q" }, "\\mathbb{Q}"),
	ls.parser.parse_snippet({ trig = "ZZ", name = "Z" }, "\\mathbb{Z}"),
	ls.parser.parse_snippet({ trig = "UU", name = "cup" }, "\\cup"),
	ls.parser.parse_snippet({ trig = "NN", name = "n" }, "\\mathbb{N}"),
	ls.parser.parse_snippet({ trig = "||", name = "mid" }, " \\mid"),
	ls.parser.parse_snippet({ trig = "Nn", name = "cap" }, "\\cap"),
	ls.parser.parse_snippet({ trig = "bmat", name = "bmat" }, "\\begin{bmatrix} $1 \\end{bmatrix} $0"),
	ls.parser.parse_snippet({ trig = "uuu", name = "bigcup" }, "\\bigcup_{${1:i \\in ${2: I}}} $0"),
	ls.parser.parse_snippet({ trig = "DD", name = "D" }, "\\mathbb{D}"),
	ls.parser.parse_snippet({ trig = "HH", name = "H" }, "\\mathbb{H}"),
	ls.parser.parse_snippet({ trig = "lll", name = "l" }, "\\ell"),
	with_priority(
		ls.parser.parse_snippet(
			{ trig = "dint", name = "integral" },
			"\\int_{${1:-\\infty}}^{${2:\\infty}} ${3:${TM_SELECTED_TEXT}} $0"
		),
		300
	),

	ls.parser.parse_snippet({ trig = "==", name = "equals" }, [[&= $1 \\\\]]),
	ls.parser.parse_snippet({ trig = "!=", name = "not equals" }, "\\neq"),
	ls.parser.parse_snippet({ trig = "compl", name = "complement" }, "^{c}"),
	ls.parser.parse_snippet({ trig = "__", name = "subscript" }, "_{$1}$0"),
	ls.parser.parse_snippet({ trig = "=>", name = "implies" }, "\\implies"),
	ls.parser.parse_snippet({ trig = "=<", name = "implied by" }, "\\impliedby"),
	ls.parser.parse_snippet({ trig = "<<", name = "<<" }, "\\ll"),

	ls.parser.parse_snippet({ trig = "<=", name = "leq" }, "\\le"),
	ls.parser.parse_snippet({ trig = ">=", name = "geq" }, "\\ge"),
	ls.parser.parse_snippet({ trig = "invs", name = "inverse" }, "^{-1}"),
	ls.parser.parse_snippet({ trig = "~~", name = "~" }, "\\sim"),
	ls.parser.parse_snippet({ trig = "conj", name = "conjugate" }, "\\overline{$1}$0"),

        -- TKJ 
        -- TKJ griskir
        ls.parser.parse_snippet(
                { trig =  "@a", name =  "alpha" },
                "\\alpha"
        ),
        ls.parser.parse_snippet(
                { trig =  "@b", name =  "beta"  },
                "\\beta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@c", name =  "chi"  },
                "\\chi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@d", name =  "delta"  },
                "\\delta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@e", name =  "epsilon"  },
                "\\epsilon"
        ),
        ls.parser.parse_snippet(
                { trig =  "@ve", name =  "varepsilon"},
                "\\varepsilon"
        ),
        ls.parser.parse_snippet(
                { trig =  "@f", name =  "phi"},
                "\\phi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@vf", name =  "varphi"},
                "\\varphi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@g", name =  "gamma"},
                "\\gamma"
        ),
        ls.parser.parse_snippet(
                { trig =  "@h", name =  "eta"},
                "\\eta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@i", name =  "iota"},
                "\\iota"
        ),
        ls.parser.parse_snippet(
                { trig =  "@k", name =  "kappa"},
                "\\kappa"
        ),
        ls.parser.parse_snippet(
                { trig =  "@l", name =  "lambda"},
                "\\lambda"
        ),
        ls.parser.parse_snippet(
                { trig =  "@m", name =  "mu"},
                "\\mu"
        ),
        ls.parser.parse_snippet(
                { trig =  "@n", name =  "nu"},
                "\\nu"
        ),
        ls.parser.parse_snippet(
                { trig =  "@p", name =  "pi"},
                "\\pi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@q", name =  "theta"},
                "\\theta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@vq", name =  "vartheta"},
                "\\vartheta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@r", name =  "rho"},
                "\\rho"
        ),
        ls.parser.parse_snippet(
                { trig =  "@s", name =  "sigma"},
                "\\sigma"
        ),
        ls.parser.parse_snippet(
                { trig =  "@vs", name =  "varsigma"},
                "\\varsigma"
        ),
        ls.parser.parse_snippet(
                { trig =  "@t", name =  "tau"},
                "\\tau"
        ),
        ls.parser.parse_snippet(
                { trig =  "@u", name =  "upsilon"},
                "\\upsilon"
        ),
        ls.parser.parse_snippet(
                { trig =  "@o", name =  "omega"},
                "\\omega"
        ),
        ls.parser.parse_snippet(
                { trig =  "@&", name =  "wedge"},
                "\\wedge"
        ),
        ls.parser.parse_snippet(
                { trig =  "@x", name =  "xi"},
                "\\xi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@y", name =  "psi"},
                "\\psi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@z", name =  "zeta"},
                "\\zeta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@D", name =  "Delta"},
                "\\Delta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@F", name =  "Phi"},
                "\\Phi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@G", name =  "Gamma"},
                "\\Gamma"
        ),
        ls.parser.parse_snippet(
                { trig =  "@Q", name =  "Theta"},
                "\\Theta"
        ),
        ls.parser.parse_snippet(
                { trig =  "@L", name =  "Lambda"},
                "\\Lambda"
        ),
        ls.parser.parse_snippet(
                { trig =  "@X", name =  "Xi"},
                "\\Xi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@Y", name =  "Psi"},
                "\\Psi"
        ),
        ls.parser.parse_snippet(
                { trig =  "@S", name =  "Sigma"},
                "\\Sigma"
        ),
        ls.parser.parse_snippet(
                { trig =  "@U", name =  "Upsilon"},
                "\\Upsilon"
        ),
        ls.parser.parse_snippet(
                { trig =  "@W", name =  "Omega"},
                "\\Omega"
        ),
        ls.parser.parse_snippet(
                { trig =  "@(", name =  "left( ... right)"},
                "\\left( ${1:${TM_SELECTED_TEXT}} \\right)"
        ),
        ls.parser.parse_snippet(
                { trig =  "@{", name =  "left{ ... right}"},
                "\\left\\{ ${1:${TM_SELECTED_TEXT}} \\right\\\\\\}"
        ),
        ls.parser.parse_snippet(
                { trig =  "@[", name =  "left[ ... right]"},
                "\\left[ ${1:${TM_SELECTED_TEXT}} \\right]"
        ),
}

return math_iA
