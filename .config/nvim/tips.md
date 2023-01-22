- Algjör óþarfi að hafa whole doc textobj, nota frekar bara :%y (hvað ertað fara gera annað en yank?)

- Muna markin S(nippets)/S(tærðfræði), I(celandic layout), 
    K(eymaps), O(ptions), P(lugins), etc

- Getur gert 
   echo join(map(split(globpath(&rtp, 'ftplugin/*.vim'), '\n'), 'fnamemodify(v:val, ":t:r")'), "\n") * seinni stjarnan bara til að fokka ekki upp highlighting á þessu skjali
   til að sjá allar ftplugin gerðirnar

- Getur valið kóða og gert !python td fyrir python kóða, 
    það keyrir hann og skiptir textanum út fyrir outputið

- Ctrl-o og alt-LYKILL fyrir normal mode commands í insert mode

- Þegar þú ert að horfá fólk tala þá ertu ekki að upplifa það sem þau
    eru að upplifa sem sem skýrir að þú finnur ekki væbið

- Ctrl-u í insert mode strokar alla línuna (nema leading whitespace)

- :so til að sourcea current file

- The diagnostic framework is an extension to existing error handling functionality such as the |quickfix| list.

- \v í leitarstreng gerir hann very magic svo þarft ekki að escapea stöff,
  gætir íhugað að remappa / í /\v og gera shortcut fyrir :%s/\v

- Nokkrir hlutir ólíkir milli vim regex og venjulegs:

Perl    Vim     Explanation
---------------------------
x?      x\=     Match 0 or 1 of x
x+      x\+     Match 1 or more of x
(xyz)   \(xyz\) Use brackets to group matches
x{n,m}  x\{n,m} Match n to m of x
x*?     x\{-}   Match 0 or 1 of x, non-greedy
x+?     x\{-1,} Match 1 or more of x, non-greedy
\b      \< \>   Word boundaries
$n      \n      Backreferences for previously grouped matches

- Ástæðan fyrir muninum er söguleg: þegar vim festi þetta var svona regex
  standardinn 
