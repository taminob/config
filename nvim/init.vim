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
Plug 'zivyangll/git-blame.vim'
"Plug 'ervandew/supertab'
Plug 'tpope/vim-commentary' " comment support; shortcut: 'gcc'
Plug 'ethanholz/nvim-lastplace' " remember cursor position in files

call plug#end()

" execute on new machine
function NvimSetup()
:PlugInstall
:CocInstall coc-markdownlint coc-texlab coc-json coc-sh coc-rust-analyzer coc-clangd coc-cmake coc-css coc-html coc-tsserver coc-pyright
endfunction
command NvimSetup exec NvimSetup()

command NvimEdit edit ~/.config/nvim/init.vim

" set <leader> key to <space>
let mapleader = " "

" colorizer init
set termguicolors
lua require'colorizer'.setup()
set notermguicolors

" overwrite goto definition keys with coc
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gD <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)

" switch between source/header files
command -nargs=0 ClangdSwitchSourceHeader CocCommand clangd.switchSourceHeader
" resolve symbol info under the cursor
command -nargs=0 ClangdSymbolInfo CocCommand clangd.symbolInfo
" show memory usage
command -nargs=0 ClangdMemoryUsage CocCommand clangd.memoryUsage
" show AST
command -nargs=0 -range ClangdAst CocCommand clangd.ast

" rust-analyze
command -nargs=0 RustFlycheck CocCommand rust-analyzer.runFlycheck
" docs for symbol under the cursor
command -nargs=0 RustDoc CocCommand rust-analyzer.openDocs
" docs for symbol under the cursor
command -nargs=0 RustExplain CocCommand rust-analyzer.explainError

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')
nnoremap <C-i> :Format<CR>
vnoremap <C-i> <Plug>(coc-format-selected)

" LSP features
nnoremap gR <Plug>(coc-refactor)
nnoremap gN <Plug>(coc-rename)
nnoremap gq <Plug>(coc-fix-current)

" which-key init
"lua require'which-key'.setup()

" lastplace init
lua require 'nvim-lastplace'.setup{}

" git-blame keybinding
nnoremap <Leader>b :<C-u>call gitblame#echo()<CR>

" vim-commentary: C++ use // instead of block comment
autocmd FileType cpp setlocal commentstring=//\ %s

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

" Exit with a non-zero exit code (e.g. abort git commit)
command Abort :cq

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

set fileformat=unix
set fileformats=unix,dos

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
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:⎵,precedes:<,extends:>

" configure search (smartcase: case-sensitive when any uppercase char)
" append '\C' to enable case-sensitive search for lowercase patterns
set incsearch ignorecase smartcase hlsearch

" increase command history
set history=1000

" use clipboard for yanking
set clipboard+=unnamedplus

""" predefined macros
" custom comment macro
"function DefineCommentMacros(comment_symbols)
"	let @c ="I" . a:comment_symbols . " \<Esc>j"
"	let @u = "I" . repeat("\<Del>", len(a:comment_symbols)) . "\<Del>\<Esc>j"
"endfunction
"autocmd FileType * call DefineCommentMacros('//')
"autocmd FileType python call DefineCommentMacros('#')
"autocmd FileType vim call DefineCommentMacros('"')

""" shortcuts
" disable arrows
"noremap <Up> <Nop>
"noremap <Down> <Nop>
"noremap <Left> <Nop>
"noremap <Right> <Nop>

":inoremap kj <Esc>
":nnoremap kj <C-C>

" trigger InsertLeave autocmd on C-c
inoremap <C-c> <Esc>

" copy selection:
vnoremap <C-s> "+y

" clear highlighting on escape in normal mode
nnoremap <Esc> :noh<Enter><Esc>
"nnoremap <Esc>^[ <Esc>^[

" allow to edit between characters
" TODO: generic implementation to allow more characters and usage with a to delete inclusive (f)
"function DefineEditBetween(c)
"	nnoremap <expr> di . a:c T . a:c . dt . a:c
"	nnoremap <expr> ci . a:c T . a:c . ct . a:c
"	nnoremap <expr> yi . a:c T . a:c . yt . a:c
"endfunction
"call DefineEditBetween('=')
nnoremap di\| T\|dt\|
nnoremap ci\| T\|ct\|
nnoremap yi\| T\|yt\|
nnoremap vi\| T\|vt\|

nnoremap di_ T_dt_
nnoremap ci_ T_ct_
nnoremap yi_ T_yt_
nnoremap vi_ T_vt_

nnoremap di- T-dt-
nnoremap ci- T-ct-
nnoremap yi- T-yt-
nnoremap vi- T-vt-

nnoremap di<Space> T dt |
nnoremap ci<Space> T ct |
nnoremap yi<Space> T yt |
nnoremap vi<Space> T vt |

nnoremap di/ T/dt/
nnoremap ci/ T/ct/
nnoremap yi/ T/yt/
nnoremap vi/ T/vt/

nnoremap di, T,dt,
nnoremap ci, T,ct,
nnoremap yi, T,yt,
nnoremap vi, T,vt,

nnoremap di. T.dt.
nnoremap ci. T.ct.
nnoremap yi. T.yt.
nnoremap vi. T.vt.

" allow to surround in visual mode
" TODO: remove " because it makes selecting register impossible?
vnoremap " c""<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap ' c''<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap ( c()<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap { c{}<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap [ c[]<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap \| c\|\|<Esc>Pzo| " zo to open fold (in case autofold is enabled)
vnoremap ` c``<Esc>Pzo| " zo to open fold (in case autofold is enabled)

" move between lines, including auto-break lines
" TODO: map previous J/K to another key
nnoremap J gj
nnoremap K gk

" jump with t to next match (even if not in line); TODO: not working
"function JumpWithT()
"	let l:c = getcharstr()
"	:call search(escape(l:c, '\.(){}'), 'Wz')
"endfunction
"nnoremap <silent> t :exec JumpWithT()<CR>

" use tab for completion; coc#pum#confirm() for confirming selection
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" use Ctrl+Space to show completions
inoremap <silent><expr> <C-space> coc#refresh()

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
vnoremap <C-h> :s///g| " '<,'> inserted automatically

" use 2 spaces instead of tabs
nnoremap <C-t> :set tabstop=4 shiftwidth=4 expandtab<CR>
nnoremap <Leader><C-t> :set tabstop=2 shiftwidth=2 expandtab<CR>

"free: C-p, C-n, C-k, C-j, C-h, C-s, C-q, C-@, C-_
