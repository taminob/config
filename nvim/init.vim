call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf.vim' " file browser
Plug 'nvim-lua/plenary.nvim' " telescope dependency
Plug 'nvim-telescope/telescope.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'} " language server support
Plug 'norcalli/nvim-colorizer.lua' " colorizer to highlight color strings
"Plug 'folke/which-key.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-sandwich'
Plug 'airblade/vim-gitgutter'
"Plug 'tpope/vim-fugitive'
"Plug 'ervandew/supertab'

call plug#end()

" execute on new machine
function NvimSetup()
:PlugInstall
:CocInstall coc-markdownlint coc-texlab coc-json coc-sh coc-rust-analyzer coc-clangd coc-cmake coc-css coc-html coc-tsserver coc-pyright coc-solargraph
endfunction
command NvimSetup exec NvimSetup()

" colorizer init
set termguicolors
lua require'colorizer'.setup()
set notermguicolors

" which-key init
"lua require'which-key'.setup()

" signcolumn style for gitgutter
highlight SignColumn guibg=bg ctermbg=NONE
highlight GitGutterAdd    guifg=#009900 ctermfg=2 ctermbg=NONE
highlight GitGutterChange guifg=#bbbb00 ctermfg=3 ctermbg=NONE
highlight GitGutterDelete guifg=#ff2222 ctermfg=1 ctermbg=NONE

" reload config
command Reload :source $MYVIMRC

" enable/disable colorize plugin
command Colorize set termguicolors
command Uncolorize set notermguicolors

" write as root (terminal required error)
"command Sudow :w !sudo tee \%

" delay in ms after which vim writes swap file (also updates gitgutter)
set updatetime=500

" enable highlighting
syntax on

" enable line numbers
set number relativenumber

" enable mouse in vim
set mouse=a

" highlight cursor position horizontally and vertically
"set cursorline cursorcolumn

" enable tabs
set autoindent noexpandtab tabstop=4 shiftwidth=4 softtabstop=-1
filetype plugin on
filetype indent on

" tab completion for :cd/:e; also ignore binary file formats
set wildmode=longest:full,full
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" set column border
"set cc=80

" enable spell checking
"set spell

" fold based on syntax; open:'zo',close:'zc',open_all:'zr',close_all:'zm'
set foldmethod=syntax
autocmd FileType python setlocal foldmethod=indent
set foldopen+=jump,search " open fold on jump/search
set foldnestmax=1 " only fold top-level functions
autocmd BufWinEnter * normal zR " unfold all folds at begin

" show tabs and eol
set list
set listchars=tab:▸\ ,trail:·,eol:¬

" configure search (smartcase: case-sensitive when any uppercase char)
set incsearch ignorecase smartcase hlsearch

" increase command history
set history=1000

""" shortcuts
" disable arrows
"noremap <Up> <Nop>
"noremap <Down> <Nop>
"noremap <Left> <Nop>
"noremap <Right> <Nop>

":inoremap kj <Esc>
":nnoremap kj <C-C>

" copy selection:
vnoremap <C-s> "+y

" clear highlighting on escape in normal mode
nnoremap <Esc> :noh<Enter><Esc>
nnoremap <Esc>^[ <Esc>^[

" use tab for completion
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use <c-space>for trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" search for visual selection and exit visual mode
vnoremap / *<CR><Esc>
"vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" move between buffers
nnoremap <C-j> :bprev<CR>
nnoremap <C-k> :bnext<CR>

" fzf controls:
" might require `chmod +x ~/.config/nvim/plugged/fzf.vim/bin/*.sh`
nnoremap <C-e> :Files<CR>
nnoremap <C-g> :Rg<CR>

" replace in whole file
nnoremap <C-h> :%s///g
vnoremap <C-h> :'<,'>s///g

" use 2 spaces instead of tabs
nnoremap <C-t> :set tabstop=2 shiftwidth=2 expandtab<CR>

"free: C-p, C-n, C-k, C-j, C-h, C-s, C-q, C-@, C-_
