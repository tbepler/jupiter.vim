
set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "yoyodyne"

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
" base grey-scale colors
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
let s:blackboard     = "050505"

"accent colors
let s:tardis         = '0a9dff'
let s:lime           = 'aeee00'
let s:taffy          = 'ff2c4b'
let s:dalespale      = 'fade3e'

let s:blue1 = [ "E1DFEE", "8879D1", "5A45C3", "3113C7", "1F0892" ]
let s:blue2 = [ "C5CFFF", "7EA7BD", "3D7B9C", "0F6A9B", "045079" ]

let s:notorange = {}
let s:notorange.pale = "FFD59A"
let s:notorange.base = "FFBA58"
let s:notorange.bright = "FFA019"
let s:notorange.brightest = "FF9500"

let s:yellow = {}
"let s:yellow.palest = "FFF0A4"
let s:yellow.pale = "FFEF9a"
let s:yellow.base = "FFE458"
let s:yellow.bright = "FFDA19"
let s:yellow.brightest = "FFD600"

let s:red = {}
"let s:red.palest = "FFAAA4"
let s:red.pale = "FFA29A"
let s:red.base = "FF6458"
let s:red.bright = "FF2A19"
let s:red.brightest = "FF1300"

let s:mitred = "A31F34"

let s:blue = {}
"let s:blue.palest = "AAD7FF"
let s:blue.pale = "9BCBF6"
let s:blue.base = "5FACF2"
let s:blue.bright = "2792F2"
let s:blue.brightest = "0280F0"

let s:skyblue        = "8fbfdc"
let s:steelblue      = "c6b6ee"
let s:darkblue       = "8197bf"
let s:golden         = "fad07a"
let s:paleorange     = "ffb964"
let s:terracotta     = "cf6a4c"

" Configuration options
if !exists('g:jupiter_gutter_color')
    let s:gutter = s:blackboard
endif

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
  call s:X( "CursorLine", "", s:darkgravel, "", "", s:termBlack )
  call s:X( "CursorColumn", "", s:darkgravel, "", "", s:termBlack )
  call s:X( "CursorLineNR", s:dalespale, "", "none", "White", "" )
 
  call s:X( "MatchParen", s:darkgravel, s:dalespale, "bold", "", "" )

  call s:X( "TabLine", s:plain, s:tabline, "", "", s:termBlack )
  call s:X( "TabLineFill", s:plain, s:tabline, "", "", s:termBlack )
  call s:X( "TabLineSel", s:coal , s:tardis, "", s:termBlack,"White")

  " Auto-completion
  call s:X( "Pmenu", s:brightgravel, s:deepergravel, "", "", "" )
  call s:X( "PmenuSel", s:coal, s:tardis, "bold", "", "" )
  call s:X( "PmenuSbar", s:tardis, s:deepergravel, "", "", "" )
  call s:X( "PmenuThumb", s:brightgravel, s:tardis, "", "", "" )
endif

"call s:X("Visual","","404040","","",s:termBlack)
call s:X( "Visual", "", s:darkgravel, "", "", "" )
call s:X( "VisualNOS", "",  s:darkgravel, "", "", "" )

"call s:X("Cursor",g:jellybeans_background_color,"b0d0f0","","","")
call s:X( "Cursor",  s:coal, s:tardis, "bold", "", "" )
call s:X( "vCursor", s:coal, s:tardis, "bold", "", "" )
call s:X( "iCursor", s:coal, s:tardis, "", "", "" )

call s:X( "StatusLine", s:coal, s:tardis, "bold", "", "" )
call s:X( "StatusLineNC", s:snow, s:deepgravel, "bold", "", "" )

call s:X( "VertSplit", s:snow, s:deepgravel , "", s:termBlack, s:termBlack )

call s:X( "WildMenu", s:dalespale, s:deepgravel, "", "Magenta", "")

"call s:X("LineNr","605958",g:jellybeans_background_color,"none",s:termBlack,"")
call s:X( "LineNr", s:mediumgravel, s:gutter, "", "", "" )

call s:X( "Folded", s:yellow.pale, s:deepergravel, "italic", s:termBlack, "")
call s:X( "FoldColumn", "535D66", s:gutter, "", "", s:termBlack )
call s:X( "SignColumn", "777777", s:gutter, "", "", s:termBlack )
call s:X( "ColorColumn","","000000","","",s:termBlack)

call s:X( "Search", "", s:deepgravel, "bold", "", "" )

"call s:X("Directory","dad085","","","Yellow","")
call s:X( "Directory", s:dalespale, "", "", "Yellow", "" )

"call s:X("Title","70b950","","bold","Green","")
call s:X( "Title", s:lime, "", "", "Green", "" )

"call s:X("ErrorMsg","","902020","","","DarkRed")
"hi! link Error ErrorMsg
"hi! link MoreMsg Special
"call s:X("Question","65C254","","","Green","")
call s:X( "ErrorMsg", s:taffy, "", "bold", "", "DarkRed" )
call s:X( "MoreMsg", s:lightgravel, "", "bold", "", "Yellow" )
call s:X( "ModeMsg", s:lightgravel, "", "bold", "", "Yellow" )
call s:X( "Question", s:blue1[2], "", "bold", "", "Yellow" )
call s:X( "WarningMsg", s:yellow.base, "", "bold", "", "Red" )

" ##### Syntax groups
" *Comment
call s:X( "Comment", s:gravel, "", "italic", "", "" )
"
" *Constant
" String
" Character
" Number
" Boolean
" Float

" use pale blue for string and darker blue otherwise 
"call s:X( "Constant", "003CFF", "", "bold", "", "" )
call s:X( "Constant", "E05016", "", "bold", "", "" )
call s:X( "String", s:blue2[0], "", "", "", "" )
"
" *Identifier
" Function
"
" use pale yellow for identifiers
"call s:X( "Identifier", s:blue1[1], "", "", "", "Yellow" )
call s:X( "Identifier", "597BE3", "", "", "", "Yellow" )
"
" *Statement
" Conditional
" Repeat
" Label
" Operator
" Keyword
" Exception
"
" use red/orange for statements
call s:X( "Statement", "FCEC6D", "", "", "", "" )
call s:X( "Operator", "E0D316", "", "", "", "" )
call s:X( "Exception", s:lime, "", "bold", "", "" )
"
" *PreProc
" Include
" Define
" Macro
" PreCondit
"
"  pop pre-processor commands as lime
call s:X( "PreProc", s:lime, "", "", "", "" )
"
" *Type
" StorageClass
" Structure
" Typedef
"
"  use blues for types
call s:X( "Type", "8ED4FA", "", "", "", "" )
call s:X( "StorageClass", s:blue1[1], "", "", "", "" )
call s:X( "Structure", s:blue1[2], "", "", "", "" )
call s:X( "Typedef", s:blue1[2], "", "", "", "" )
"
" *Special
" SpecialChar
" Tag
" Delimiter
" SpecialComment
" Debug
call s:X( "Special", s:brightgravel, "", "italic", "", "" )
hi! link SpecialChar Constant
call s:X( "Delimiter", s:blue2[1], "", "", "", "" )

" *Underlined
"
" *Ignore
"
" *Error
call s:X( "Error", "", s:taffy, "", "", "" )
"
" *Todo
call s:X( "Todo", s:blue2[2], s:yellow.bright, "bold", "", "" )

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
hi! link pythonBuiltin      Type
hi! link pythonBuiltinObj   Type
hi! link pythonBuiltinFunc  Type
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
hi! link rubyClass Structure
hi! link rubyIdentifier Identifier
"call s:X("rubyClass","447799","","","DarkBlue","")
"call s:X("rubyIdentifier","c6b6fe","","","Cyan","")
hi! link rubyConstant Constant
hi! link rubyFunction Function
hi! link rubyInstanceVariable Identifier
"call s:X("rubyInstanceVariable","c6b6fe","","","Cyan","")
"call s:X("rubySymbol","7697d6","","","Blue","")
hi! link rubySymbol Operator
hi! link rubyGlobalVariable rubyInstanceVariable
hi! link rubyModule rubyClass
hi! link rubyControl Control
"call s:X("rubyControl","7597c6","","","Blue","")

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
