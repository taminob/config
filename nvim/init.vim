call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf.vim'

call plug#end()

" enable highlighting
syntax on

" enable line numbers
set number relativenumber

" enable mouse in vim
set mouse=a

" enable tabs
set autoindent noexpandtab tabstop=4 shiftwidth=4
" configure search (smartcase: case-sensitive when any uppercase char)
set incsearch ignorecase smartcase hlsearch

" shortcuts
":inoremap kj <Esc>
":nnoremap kj <C-C>

"copy selection:
:vnoremap <C-q> "+y

:nnoremap <C-f> :Files <Enter>
:nnoremap <C-g> :Rg

