"plugins
call plug#begin('~/.vim/plugged')
" Plugin outside ~/.vim/plugged with post-update hook
 Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
 Plug 'lambdalisue/fern.vim'
 Plug 'yangyagami/cppDefGenerator'
call plug#end()

" settings
syntax on
set number
set relativenumber
set termguicolors
set wildmenu
set tabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
color wildcharm

" keybindings
vnoremap <leader>gd :call GenerateCppDef()<CR>
nnoremap <leader>ff :FZF<CR>
nnoremap <leader>b :ls<CR>:b<SPACE>
nnoremap <leader>o :b#<CR>
nnoremap <leader>e :Fern . -drawer -toggle<CR>
nnoremap <leader>t :bo term<CR><C-w>N:resize 10<CR>i
