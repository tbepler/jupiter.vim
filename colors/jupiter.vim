
set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "jupiter"

if has("gui_running") || &t_Co == 88 || &t_Co == 256
  let s:low_color = 0
else
  let s:low_color = 1
endif

" Color approximation functions by Henry So, Jr. and David Liang {{{
" Added to jellybeans.vim by Daniel Herbert

" returns an approximate grey index for the given grey level
fun! s:grey_number(x)
  if &t_Co == 88
    if a:x < 23
      return 0
    elseif a:x < 69
      return 1
    elseif a:x < 103
      return 2
    elseif a:x < 127
      return 3
    elseif a:x < 150
      return 4
    elseif a:x < 173
      return 5
    elseif a:x < 196
      return 6
    elseif a:x < 219
      return 7
    elseif a:x < 243
      return 8
    else
      return 9
    endif
  else
    if a:x < 14
      return 0
    else
      let l:n = (a:x - 8) / 10
      let l:m = (a:x - 8) % 10
      if l:m < 5
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual grey level represented by the grey index
fun! s:grey_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 46
    elseif a:n == 2
      return 92
    elseif a:n == 3
      return 115
    elseif a:n == 4
      return 139
    elseif a:n == 5
      return 162
    elseif a:n == 6
      return 185
    elseif a:n == 7
      return 208
    elseif a:n == 8
      return 231
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 8 + (a:n * 10)
    endif
  endif
endfun

" returns the palette index for the given grey index
fun! s:grey_color(n)
  if &t_Co == 88
    if a:n == 0
      return 16
    elseif a:n == 9
      return 79
    else
      return 79 + a:n
    endif
  else
    if a:n == 0
      return 16
    elseif a:n == 25
      return 231
    else
      return 231 + a:n
    endif
  endif
endfun

" returns an approximate color index for the given color level
fun! s:rgb_number(x)
  if &t_Co == 88
    if a:x < 69
      return 0
    elseif a:x < 172
      return 1
    elseif a:x < 230
      return 2
    else
      return 3
    endif
  else
    if a:x < 75
      return 0
    else
      let l:n = (a:x - 55) / 40
      let l:m = (a:x - 55) % 40
      if l:m < 20
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual color level for the given color index
fun! s:rgb_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 139
    elseif a:n == 2
      return 205
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 55 + (a:n * 40)
    endif
  endif
endfun

" returns the palette index for the given R/G/B color indices
fun! s:rgb_color(x, y, z)
  if &t_Co == 88
    return 16 + (a:x * 16) + (a:y * 4) + a:z
  else
    return 16 + (a:x * 36) + (a:y * 6) + a:z
  endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun! s:color(r, g, b)
  " get the closest grey
  let l:gx = s:grey_number(a:r)
  let l:gy = s:grey_number(a:g)
  let l:gz = s:grey_number(a:b)

  " get the closest color
  let l:x = s:rgb_number(a:r)
  let l:y = s:rgb_number(a:g)
  let l:z = s:rgb_number(a:b)

  if l:gx == l:gy && l:gy == l:gz
    " there are two possibilities
    let l:dgr = s:grey_level(l:gx) - a:r
    let l:dgg = s:grey_level(l:gy) - a:g
    let l:dgb = s:grey_level(l:gz) - a:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_level(l:gx) - a:r
    let l:dg = s:rgb_level(l:gy) - a:g
    let l:db = s:rgb_level(l:gz) - a:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      " use the grey
      return s:grey_color(l:gx)
    else
      " use the color
      return s:rgb_color(l:x, l:y, l:z)
    endif
  else
    " only one possibility
    return s:rgb_color(l:x, l:y, l:z)
  endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun! s:rgb(rgb)
  let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
  let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
  let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
  return s:color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun! s:X(group, fg, bg, attr, lcfg, lcbg)
  if s:low_color
    let l:fge = empty(a:lcfg)
    let l:bge = empty(a:lcbg)

    if !l:fge && !l:bge
      exec "hi ".a:group." ctermfg=".a:lcfg." ctermbg=".a:lcbg
    elseif !l:fge && l:bge
      exec "hi ".a:group." ctermfg=".a:lcfg." ctermbg=NONE"
    elseif l:fge && !l:bge
      exec "hi ".a:group." ctermfg=NONE ctermbg=".a:lcbg
    endif
  else
    let l:fge = empty(a:fg)
    let l:bge = empty(a:bg)

    if !l:fge && !l:bge
      exec "hi ".a:group." guifg=#".a:fg." guibg=#".a:bg." ctermfg=".s:rgb(a:fg)." ctermbg=".s:rgb(a:bg)
    elseif !l:fge && l:bge
      exec "hi ".a:group." guifg=#".a:fg." guibg=NONE ctermfg=".s:rgb(a:fg)." ctermbg=NONE"
    elseif l:fge && !l:bge
      exec "hi ".a:group." guifg=NONE guibg=#".a:bg." ctermfg=NONE ctermbg=".s:rgb(a:bg)
    endif
  endif

  if a:attr == ""
    exec "hi ".a:group." gui=none cterm=none"
  else
    let l:noitalic = join(filter(split(a:attr, ","), "v:val !=? 'italic'"), ",")
    if empty(l:noitalic)
      let l:noitalic = "none"
    endif
    exec "hi ".a:group." gui=".a:attr." cterm=".l:noitalic
  endif
endfun
" }}}

"define some colors - from badwolf colorscheme
let s:plain          = 'f8f6f2'
let s:snow           = 'ffffff'
let s:coal           = '000000'
let s:brightgravel   = 'd9cec3'
let s:lightgravel    = '998f84'
let s:gravel         = '857f78'
let s:mediumgravel   = '666462'
let s:deepgravel     = '45413b'
let s:deepergravel   = '35322d'
let s:darkgravel     = '242321'
let s:blackgravel    = '1c1b1a'
let s:blackestgravel = '141413'
let s:dalespale      = 'fade3e'
let s:dirtyblonde    = 'f4cf86'
let s:taffy          = 'ff2c4b'
let s:saltwatertaffy = '8cffba'
let s:tardis         = '0a9dff'
let s:orange         = 'ffa724'
let s:lime           = 'aeee00'
let s:dress          = 'ff9eb8'
let s:toffee         = 'b88853'
let s:coffee         = 'c7915b'
let s:darkroast      = '88633f'

let s:skyblue        = "8fbfdc"
let s:steelblue      = "c6b6ee"
let s:darkblue       = "8197bf"
let s:golden         = "fad07a"
let s:paleorange     = "ffb964"
let s:olive          = "99ad6a"
let s:darkolive      = "556633"
let s:palegreen      = "799d6a"
let s:terracotta     = "cf6a4c"

let s:blackboard     = "050505"
let s:lilac          = "8d469a" 

" Configuration options
if !exists('g:jupiter_gutter_color')
    let s:gutter = s:blackboard
endif

if exists('g:jupiter_tabline')
    if g:jupiter_tabline == 0
        let s:tabline = s:blackestgravel
    elseif  g:jupiter_tabline == 1
        let s:tabline = s:blackgravel
    elseif  g:jupiter_tabline == 2
        let s:tabline = s:darkgravel
    elseif  g:jupiter_tabline == 3
        let s:tabline = s:deepgravel
    else
        let s:tabline = s:blackestgravel
    endif
else
    let s:tabline = s:blackgravel
endif

if !exists("g:jupiter_bg_color")
  let g:jupiter_bg_color = s:blackestgravel
end
let g:jupiter_bg_color = s:blackboard

call s:X( "Normal", s:plain, g:jupiter_bg_color, "", "White", "" )
set background=dark

if !exists("g:jupiter_use_lowcolor_black") || g:jupiter_use_lowcolor_black
    let s:termBlack = "Black"
else
    let s:termBlack = "Grey"
endif

if version >= 700
  "call s:X( "CursorLine", "", s:darkgravel, "", "", s:termBlack )
  hi clear CursorLine
  call s:X( "CursorColumn", "", s:darkgravel, "", "", s:termBlack )
  call s:X( "CursorLineNR", s:dalespale, "", "none", "White", "" )
 
  call s:X( "MatchParen", s:darkgravel, s:dalespale, "bold", "", "" )

  call s:X( "TabLine", s:plain, s:tabline, "", "", s:termBlack )
  call s:X( "TabLineFill", s:plain, s:tabline, "", "", s:termBlack )
  call s:X( "TabLineSel", s:coal , s:tardis, "", s:termBlack,"White")

  " Auto-completion
  " call s:X("Pmenu","ffffff","606060","","White",s:termBlack)
  " call s:X("PmenuSel","101010","eeeeee","",s:termBlack,"White")
  call s:X( "Pmenu", s:plain, s:deepergravel, "", "", "" )
  call s:X( "PmenuSel", s:coal, s:tardis, "bold", "", "" )
  call s:X( "PmenuSbar", "", s:deepergravel, "", "", "" )
  call s:X( "PmenuThumb", s:brightgravel, "", "", "", "" )
endif

"call s:X("Visual","","404040","","",s:termBlack)
call s:X( "Visual", "", s:deepgravel, "", "", "" )
call s:X( "VisualNOS", "",  s:deepgravel, "", "", "" )

"call s:X("Cursor",g:jellybeans_background_color,"b0d0f0","","","")
call s:X( "Cursor",  s:coal, s:tardis, "bold", "", "" )
call s:X( "vCursor", s:coal, s:tardis, "bold", "", "" )
call s:X( "iCursor", s:coal, s:tardis, "", "", "" )

"call s:X("StatusLine","000000","dddddd","italic","","White")
"call s:X("StatusLineNC","ffffff","403c41","italic","White","Black")
call s:X( "StatusLine", s:coal, s:tardis, "bold", "", "White" )
call s:X( "StatusLineNC", s:snow, s:deepgravel, "bold", "White", "Black" )

"call s:X("VertSplit","777777","403c41","",s:termBlack,s:termBlack)
call s:X( "VertSplit", s:snow, s:deepgravel , "", s:termBlack, s:termBlack )

call s:X( "WildMenu", "f0a0c0", "302028", "", "Magenta", "")

"call s:X("LineNr","605958",g:jellybeans_background_color,"none",s:termBlack,"")
call s:X( "LineNr", s:mediumgravel, s:gutter, "", "", "" )

call s:X( "Folded","a0a8b0","384048","italic",s:termBlack,"")
call s:X( "FoldColumn", "535D66", s:gutter, "", "", s:termBlack )
call s:X( "SignColumn", "777777", s:gutter, "", "", s:termBlack )
call s:X( "ColorColumn","","000000","","",s:termBlack)

"call s:X("Directory","dad085","","","Yellow","")
call s:X( "Directory", s:dirtyblonde, "", "", "Yellow", "" )

"call s:X("Title","70b950","","bold","Green","")
call s:X( "Title", s:lime, "", "", "Green", "" )

"call s:X("ErrorMsg","","902020","","","DarkRed")
"hi! link Error ErrorMsg
"hi! link MoreMsg Special
"call s:X("Question","65C254","","","Green","")
call s:X( "ErrorMsg", s:taffy, "", "bold", "", "DarkRed" )
hi! link Error ErrorMsg
call s:X( "MoreMsg", s:dalespale, "", "bold", "", "Yellow" )
call s:X( "ModeMsg", s:golden, "", "bold", "", "Yellow" )
call s:X( "Question", s:golden, "", "bold", "", "Yellow" )
call s:X( "WarningMsg", s:dress, "", "bold", "", "Red" )

" for ctags
call s:X( "Tag", "", "", "bold", "", "" )

" ##### Syntax highlighting
call s:X( "Special", s:palegreen, "", "", "Green", "" )

" Comments
call s:X( "Comment", s:gravel, "", "italic", "Grey", "" ) "TODO
call s:X( "SpecialComment", s:gravel, "", "bold", "Grey", "" ) "TODO
call s:X( "Todo", s:lilac, s:dalespale, "italic,bold", s:termBlack, "Yellow" )

" Strings
call s:X( "String", s:olive, "", "", "Green", "")
call s:X( "StringDelimiter", s:darkolive, "", "", "DarkGreen", "" )

" Constants
call s:X( "Constant", s:lilac, "", "", "Red", "" )
call s:X( "Character", s:lilac, "", "", "Red", "" )
call s:X( "Boolean", s:lilac, "", "", "Red", "" )
call s:X( "Number", s:lilac, "", "", "Red", "" )
call s:X( "Float", s:lilac, "", "", "Red", "" )
call s:X( "SpecialChar", s:lilac, "", "", "Red", "" )

" Control flow
call s:X( "Statement",   s:orange, "", "", "", "" )
call s:X( "Keyword",     s:orange, "", "", "", "" )
call s:X( "Conditional", s:orange, "", "", "", "" )
call s:X( "Operator",    s:orange, "", "", "", "" )
call s:X( "Label",       s:orange, "", "", "", "" )
call s:X( "Repeat",      s:orange, "", "", "", "" )

call s:X("Delimiter","668799","","","Grey","")

"call s:X("Identifier",s:steelblue,"","","LightCyan","")
"call s:X("Function",s:golden,"","","Yellow","")
call s:X( "Identifier", s:terracotta, "", "", "Orange", "" )
call s:X( "Function", s:terracotta, "", "", "Orange", "" )

"call s:X("PreProc","8fbfdc","","","LightBlue","")
call s:X( "PreProc", s:lime, "", "", "Green", "" )
call s:X( "Macro", s:lime, "", "", "Green", "" )
call s:X( "Define", s:lime, "", "", "Green", "" )
call s:X( "PreCondit", s:lime, "", "bold", "Green", "" )

"call s:X("Structure",s:skyblue,"","","LightCyan","")
"hi! link Operator Structure
"call s:X("Statement",s:darkblue,"","","DarkBlue","")
call s:X( "Structure", s:taffy, "", "", "Red", "" )
call s:X( "StorageClass", s:taffy, "", "", "Red", "" )
call s:X( "Typedef", s:taffy, "", "", "Red", "" )

"call s:X("Type",s:paleorange,"","","Yellow","")
"call s:X("NonText","606060",g:jellybeans_background_color,"",s:termBlack,"")
call s:X( "Type", s:skyblue, "", "", "Red", "" ) "TODO
call s:X( "NonText", "606060", g:jupiter_bg_color, "", s:termBlack, "" )

call s:X( "Exception", s:lime, "", "", "", "" )

call s:X( "Error", s:snow, s:taffy, "bold", "", "" )
call s:X( "Debug", s:snow, "", "bold", "", "" )
call s:X( "Ignore", s.gravel, "", "", "", "" )

"call s:X("SpecialKey","444444","1c1c1c","",s:termBlack,"")
call s:X("Search","f0a0c0","302028","underline","Magenta","")


" Spell Checking
if has("spell")
  call s:X("SpellBad","","902020","underline","","DarkRed")
  call s:X("SpellCap","","0000df","underline","","Blue")
  call s:X("SpellRare","","540063","underline","","DarkMagenta")
  call s:X("SpellLocal","","2D7067","underline","","Green")
endif

" Diff
hi! link diffRemoved Constant
hi! link diffAdded String

" VimDiff
call s:X("DiffAdd","D2EBBE","437019","","White","DarkGreen")
call s:X("DiffDelete","40000A","700009","","DarkRed","DarkRed")
call s:X("DiffChange","","2B5B77","","White","DarkBlue")
call s:X("DiffText","8fbfdc","000000","reverse","Yellow","")

" PHP
hi! link phpFunctions Function
hi! link phpSuperglobal Identifier
hi! link phpQuoteSingle StringDelimiter
hi! link phpQuoteDouble StringDelimiter
hi! link phpBoolean Constant
hi! link phpNull Constant
hi! link phpArrayPair Operator
hi! link phpOperator Normal
hi! link phpRelation Normal
hi! link phpVarSelector Identifier

" Python

hi! link pythonOperator     Operator
hi! link pythonBuiltin      Structure
hi! link pythonBuiltinObj   Structure
hi! link pythonBuiltinFunc  Structure
hi! link pythonEscape       Structure
hi! link pythonException    Exception
hi! link pythonExceptions   Exception
hi! link pythonPrecondit    PreCondit
hi! link pythonDecorator    Structure
call s:X( "pythonRun", s:gravel, "", "bold", "", "" )
call s:X( "pythonCoding", s:gravel, "", "bold", "", "" )

" LaTeX
"hi! link texStatement   Statement
"hi! link texMathZoneX   Operator
"hi! link texMathZoneA   Operator
"hi! link texMathZoneB   Operator
"hi! link texMathZoneC   Operator
"hi! link texMathZoneD   Operator
"hi! link texMathZoneE   Operator
"hi! link texMathZoneV   Operator
"hi! link texMath        Operator
"hi! link texMathMatcher Operator
"hi! link texRefLabel    Type
"call s:X( "texStatement", "tardis", "", "none" )
"call s:X( "texMathZoneX", "orange", "", "none" )
"call s:X( "texMathZoneA", "orange", "", "none" )
"call s:X( "texMathZoneB", "orange", "", "none" )
"call s:X( "texMathZoneC", "orange", "", "none" )
"call s:X( "texMathZoneD", "orange", "", "none" )
"call s:X( "texMathZoneE", "orange", "", "none" )
"call s:X( "texMathZoneV", "orange", "", "none" )
"call s:X( "texMathZoneX", "orange", "", "none" )
"call s:X( "texMath", "orange", "", "none" )
"call s:X( "texMathMatcher", "orange", "", "none" )
"call s:X( "texRefLabel", "dirtyblonde", "", "none" )
"call s:X( "texRefZone", "lime", "", "none" )
"call s:X( "texComment", "darkroast", "", "none" )
"call s:X( "texDelimiter", "orange", "", "none" )
"call s:X( "texZone", "brightgravel", "", "none" )

" Ruby
hi! link rubySharpBang Comment
call s:X("rubyClass","447799","","","DarkBlue","")
call s:X("rubyIdentifier","c6b6fe","","","Cyan","")
hi! link rubyConstant Type
hi! link rubyFunction Function

call s:X("rubyInstanceVariable","c6b6fe","","","Cyan","")
call s:X("rubySymbol","7697d6","","","Blue","")
hi! link rubyGlobalVariable rubyInstanceVariable
hi! link rubyModule rubyClass
call s:X("rubyControl","7597c6","","","Blue","")

hi! link rubyString String
hi! link rubyStringDelimiter StringDelimiter
hi! link rubyInterpolationDelimiter Identifier

call s:X("rubyRegexpDelimiter","540063","","","Magenta","")
call s:X("rubyRegexp","dd0093","","","DarkMagenta","")
call s:X("rubyRegexpSpecial","a40073","","","Magenta","")

call s:X("rubyPredefinedIdentifier","de5577","","","Red","")

" Erlang

hi! link erlangAtom rubySymbol
hi! link erlangBIF rubyPredefinedIdentifier
hi! link erlangFunction rubyPredefinedIdentifier
hi! link erlangDirective Statement
hi! link erlangNode Identifier

" JavaScript

hi! link javaScriptValue Constant
hi! link javaScriptRegexpString rubyRegexp

" CoffeeScript

hi! link coffeeRegExp javaScriptRegexpString

" Lua

hi! link luaOperator Conditional

" C

hi! link cFormat Identifier
hi! link cOperator Constant

" Objective-C/Cocoa

hi! link objcClass Type
hi! link cocoaClass objcClass
hi! link objcSubclass objcClass
hi! link objcSuperclass objcClass
hi! link objcDirective rubyClass
hi! link objcStatement Constant
hi! link cocoaFunction Function
hi! link objcMethodName Identifier
hi! link objcMethodArg Normal
hi! link objcMessageName Identifier

" Vimscript

hi! link vimOper Normal

" HTML

hi! link htmlTag Statement
hi! link htmlEndTag htmlTag
hi! link htmlTagName htmlTag

" XML

hi! link xmlTag Statement
hi! link xmlEndTag xmlTag
hi! link xmlTagName xmlTag
hi! link xmlEqual xmlTag
hi! link xmlEntity Special
hi! link xmlEntityPunct xmlEntity
hi! link xmlDocTypeDecl PreProc
hi! link xmlDocTypeKeyword PreProc
hi! link xmlProcessingDelim xmlAttrib

" Debugger.vim

call s:X("DbgCurrent","DEEBFE","345FA8","","White","DarkBlue")
call s:X("DbgBreakPt","","4F0037","","","DarkMagenta")

" vim-indent-guides

if !exists("g:indent_guides_auto_colors")
  let g:indent_guides_auto_colors = 0
endif
call s:X("IndentGuidesOdd","","232323","","","")
call s:X("IndentGuidesEven","","1b1b1b","","","")

" Plugins, etc.

hi! link TagListFileName Directory
call s:X("PreciseJumpTarget","B9ED67","405026","","White","Green")

if !exists("g:jellybeans_background_color_256")
  let g:jellybeans_background_color_256=233
end
" Manual overrides for 256-color terminals. Dark colors auto-map badly.
if !s:low_color
  hi StatusLineNC ctermbg=235
  hi Folded ctermbg=236
  hi FoldColumn ctermbg=234
  hi SignColumn ctermbg=236
  hi CursorColumn ctermbg=234
  hi CursorLine ctermbg=234
  hi SpecialKey ctermbg=234
  exec "hi NonText ctermbg=".g:jellybeans_background_color_256
  exec "hi LineNr ctermbg=".g:jellybeans_background_color_256
  hi DiffText ctermfg=81
  exec "hi Normal ctermbg=".g:jellybeans_background_color_256
  hi DbgBreakPt ctermbg=53
  hi IndentGuidesOdd ctermbg=235
  hi IndentGuidesEven ctermbg=234
endif

if exists("g:jellybeans_overrides")
  fun! s:load_colors(defs)
    for [l:group, l:v] in items(a:defs)
      call s:X(l:group, get(l:v, 'guifg', ''), get(l:v, 'guibg', ''),
      \                 get(l:v, 'attr', ''),
      \                 get(l:v, 'ctermfg', ''), get(l:v, 'ctermbg', ''))
      if !s:low_color
        for l:prop in ['ctermfg', 'ctermbg']
          let l:override_key = '256'.l:prop
          if has_key(l:v, l:override_key)
            exec "hi ".l:group." ".l:prop."=".l:v[l:override_key]
          endif
        endfor
      endif
      unlet l:group
      unlet l:v
    endfor
  endfun
  call s:load_colors(g:jellybeans_overrides)
  delf s:load_colors
endif

" delete functions {{{
delf s:X
delf s:rgb
delf s:color
delf s:rgb_color
delf s:rgb_level
delf s:rgb_number
delf s:grey_color
delf s:grey_level
delf s:grey_number
" }}}
