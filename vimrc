"plugins
call plug#begin('~/.vim/plugged')
" Plugin outside ~/.vim/plugged with post-update hook
 Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
 Plug 'junegunn/fzf.vim'
 Plug 'lambdalisue/fern.vim'
 Plug 'yangyagami/cppDefGenerator'
 Plug 'ludovicchabant/vim-gutentags'
 Plug 'skywind3000/gutentags_plus'
 Plug 'bfrg/vim-cpp-modern'
 Plug 'romgrk/doom-one.vim'
 Plug 'vim-airline/vim-airline'
 Plug 'vim-airline/vim-airline-themes'
call plug#end()


" common settings
syntax on
set noswapfile
set number
set relativenumber
set termguicolors
set wildmenu
set tabstop=8
set shiftwidth=8
set softtabstop=8
set encoding=utf-8
set ruler
set backspace=indent,eol,start
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
color doom-one


" Airline settings
let g:airline_powerline_fonts = 1
let g:airline_theme = "molokai"
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ' row:'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.colnr = ' col:'
let g:airline_section_z_term = '%l/%L'


" tags settings
" keymap	desc
" <leader>cs	Find symbol (reference) under cursor
" <leader>cg	Find symbol definition under cursor
" <leader>cd	Functions called by this function
" <leader>cc	Functions calling this function
" <leader>ct	Find text string under cursor
" <leader>ce	Find egrep pattern under cursor
" <leader>cf	Find file name under cursor
" <leader>ci	Find files #including the file name under cursor
" <leader>ca	Find places where current symbol is assigned
" <leader>cz	Find current word in ctags database

" enable gtags module
let g:gutentags_modules = ['ctags', 'gtags_cscope']
" config project root markers.
let g:gutentags_project_root = ['.root']
" generate datebases in my cache directory, prevent gtags files polluting my project
let g:gutentags_cache_dir = expand('~/.cache/tags')
" change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1
let g:gutentags_define_advanced_commands = 1


" keybindings
vnoremap <leader>gd :call GenerateCppDef()<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>b :ls<CR>:b<SPACE>
nnoremap <leader>o :b#<CR>
nnoremap <leader>e :Fern . -drawer -toggle<CR>
nnoremap <leader>t :bo term<CR><C-w>N:resize 10<CR>i

" autocommands
autocmd FileType python set tabstop=4 softtabstop=4 shiftwidth=4
autocmd FileType cpp set colorcolumn=80
autocmd FileType h set colorcolumn=80
autocmd FileType c set tabstop=8 softtabstop=8 shiftwidth=8 colorcolumn=80
autocmd FileType qml set tabstop=4 softtabstop=4 shiftwidth=4 colorcolumn=80
