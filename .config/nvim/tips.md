- Muna markin S(nippets)/S(tærðfræði), I(celandic layout), 
    K(eymaps), O(ptions), P(lugins), etc

- Getur gert 
   echo join(map(split(globpath(&rtp, 'ftplugin/*.vim'), '\n'), 'fnamemodify(v:val, ":t:r")'), "\n") 
   til að sjá allar ftplugin gerðirnar

- Getur valið kóða og gert !python td fyrir python kóða, 
    það keyrir hann og skiptir textanum út fyrir outputið

- Ctrl-o og alt-LYKILL fyrir normal mode commands í insert mode

- Þegar þú ert að horfá fólk tala þá ertu ekki að upplifa það sem þau
    eru að upplifa sem sem skýrir að þú finnur ekki væbið

- Ctrl-u í insert mode strokar alla línuna (nema leading whitespace)

- :so til að sourcea current file

- The diagnostic framework is an extension to existing error handling functionality such as the |quickfix| list.
