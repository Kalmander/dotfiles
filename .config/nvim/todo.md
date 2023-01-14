- Halda winbarinu? Þarf þá klárlega að gera 
	zen mode shortcut sem togglar það 
	í leiðinni... Gæti líka sett þær 
	upplýsingar í statusline. 

- Stilla lualine 

- Setja upp og fara vel gegnum telescope 
	með like a billion maps

- Keyboard layout

- Ókei er búinn að bootstrappa cmp, lsp og luasnip 
        en þarf klárlega að grokka það betur. 
        Sama gildir í rauninni um treesitter.

- Ég bætti eftirfarandi í ObsidianFollowLink:
```lua
-- óskiljanlega þá skippaði gæinn að skoða top dir, bæti 
-- því við hér...
local note_path = Path:new(vim.fs.normalize(tostring(client.dir))) / note_file_name
if note_path:is_file() then
        table.insert(notes, note_path)
end
```
Big brain mundi forka, geri kannski seinna...
