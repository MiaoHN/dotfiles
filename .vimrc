
" -------------------------------------------------------
" Options
" -------------------------------------------------------

syntax on
set nocompatible
set showmode
set showcmd
set hlsearch
set incsearch
set magic
set ignorecase
set smartcase
set copyindent
set showmatch
set number
set novisualbell
set noerrorbells
set relativenumber
set ruler
set nowrap
set nobackup
set nowb
set noswapfile
set wildmenu
set encoding=utf-8
set background=dark
set textwidth=80
set tabstop=2
set mouse=a
set laststatus=2
set shiftwidth=2
set showtabline=2
set softtabstop=2
set expandtab
set noshiftround
set scrolloff=3

"try
"  colorscheme desert
"catch
"endtry

" -------------------------------------------------------
" Keymap
" -------------------------------------------------------

let mapleader = " "
inoremap jj <esc>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <leader>h <c-w>h
nnoremap <leader>j <c-w>j
nnoremap <leader>k <c-w>k
nnoremap <leader>l <c-w>l

nnoremap <leader>e :Lexplore<CR>

nnoremap <tab> :bnext<CR>
nnoremap <s-tab> :bprevious<CR>

