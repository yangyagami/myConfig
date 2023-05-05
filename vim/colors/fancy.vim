hi clear
syntax reset
set t_Co=256
set termguicolors
let g:colors_name = 'fancy'

let v:colornames['fancy_color1'] = '#99152B'
let v:colornames['fancy_color2'] = '#C93F59'
let v:colornames['fancy_color3'] = '#E95D51'
let v:colornames['fancy_color4'] = '#DA6C7D'
let v:colornames['fancy_color5'] = '#F5AEC0'

let v:colornames['fancy_color6'] = '#405449'
let v:colornames['fancy_color7'] = '#517B5F'
let v:colornames['fancy_color8'] = '#96C9A5'
let v:colornames['fancy_color9'] = '#75738F'
let v:colornames['fancy_color10'] = '#B7AEBD'

let v:colornames['fancy_color11'] = '#FFBC3B'
let v:colornames['fancy_color12'] = '#FF4545'
let v:colornames['fancy_color13'] = '#3C3C3C'

""let v:colornames['fancy_color16'] = '#161821'
let v:colornames['fancy_color16'] = '#111111'

hi Normal guibg=fancy_color16 guifg=white
hi Statement guifg=fancy_color12
hi PreProc guifg=fancy_color12
hi Type guifg=fancy_color8
hi Constant guifg=fancy_color11
hi Comment cterm=bold guifg=fancy_color9
hi CursorLine cterm=None guibg=fancy_color13
hi LineNr cterm=None guifg=fancy_color7
hi CursorLineNr cterm=None guifg=fancy_color8
hi Pmenu guibg=fancy_color16 guifg=white
hi link CocListLine Pmenu
hi link CocMenuSel PmenuSel
hi NonText guifg=fancy_color7
hi SignColumn guibg=fancy_color16

hi link cCustomFunc Function 
hi Identifier guifg=fancy_color10
hi Conceal cterm=underline guibg=fancy_color16 guifg=fancy_color11
