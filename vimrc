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
call plug#end()

" common settings
syntax on
set noswapfile
set number
set relativenumber
set termguicolors
set wildmenu
set tabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
set ruler
set backspace=indent,eol,start
set colorcolumn=80
color industry

" tags settings
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
autocmd FileType python set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType cpp set tabstop=2 softtabstop=2 shiftwidth=2 expandtab colorcolumn=80
autocmd FileType h set tabstop=2 softtabstop=2 shiftwidth=2 expandtab colorcolumn=80
