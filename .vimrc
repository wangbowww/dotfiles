" ============================================================
" Basic settings
" ============================================================

set nocompatible
set encoding=utf-8

syntax enable
filetype plugin indent on

set number
set relativenumber
set cursorline
set showcmd
set showmatch
set ruler
set laststatus=2

set hidden
set autoread
set backspace=indent,eol,start


" ============================================================
" Indentation
" ============================================================

set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent


" ============================================================
" Search
" ============================================================

set ignorecase
set smartcase
set incsearch
set hlsearch

" Press Space to clear search highlighting.
nnoremap <silent> <Space> :nohlsearch<CR>


" ============================================================
" Interface
" ============================================================

set mouse=a
set wildmenu
set wildmode=longest:full,full
set scrolloff=5
set sidescrolloff=5

if has('termguicolors')
  set termguicolors
endif

set background=dark


" ============================================================
" Persistent undo
" ============================================================

if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undo

  if !isdirectory(expand('~/.vim/undo'))
    call mkdir(expand('~/.vim/undo'), 'p')
  endif
endif


" ============================================================
" Temporary files
" ============================================================

set nobackup
set nowritebackup
set noswapfile


" ============================================================
" Clipboard
" ============================================================

if has('unnamedplus')
  set clipboard=unnamedplus
elseif has('clipboard')
  set clipboard=unnamed
endif


" ============================================================
" Useful mappings
" ============================================================

" Keep the selection after changing indentation.
vnoremap < <gv
vnoremap > >gv

" Move between split windows using Ctrl + h/j/k/l.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
