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
filetype plugin on
filetype indent on
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

" search for visual selection and exit visual mode
vnoremap / *<CR><Esc>
"vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" move between buffers
nnoremap <C-j> :bprev<CR>
nnoremap <C-k> :bnext<CR>

" fzf controls:
:nnoremap <C-e> :Files<CR>
:nnoremap <C-g> :Rg<CR>

" replace in whole file
:nnoremap <C-h> :%s///g
:vnoremap <C-h> :'<,'>s///g

" write as root (terminal required error)
"command Sudow :w !sudo tee \%

"free: C-p, C-n, C-k, C-j, C-h, C-s, C-q, C-@, C-_
