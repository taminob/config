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
set autoindent noexpandtab tabstop=4 shiftwidth=4 softtabstop=-1
filetype plugin indent off
" configure search (smartcase: case-sensitive when any uppercase char)
set incsearch ignorecase smartcase hlsearch

""" shortcuts
" disable arrows
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

":inoremap kj <Esc>
":nnoremap kj <C-C>

" copy selection:
:vnoremap <C-s> "+y

" clear highlighting on escape in normal mode
nnoremap <Esc> :noh<Enter><Esc>
nnoremap <Esc>^[ <Esc>^[

" move between buffers
nnoremap <C-j> :bprev<CR>
nnoremap <C-k> :bnext<CR>

" fzf controls:
:nnoremap <C-e> :Files<CR>
:nnoremap <C-g> :Rg<CR>

" replace
:nnoremap <C-h> :%s///g

"free: C-p, C-n, C-k, C-j, C-h, C-s, C-q, C-@, C-_
