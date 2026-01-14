" ~/.vimrc - Configuración básica de Vim

" Configuración general
set nocompatible
set number
set relativenumber
set ruler
set showcmd
set showmode
set wildmenu
set wildmode=longest,list

" Indentación
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" Búsqueda
set hlsearch
set incsearch
set ignorecase
set smartcase

" Interfaz
set laststatus=2
set splitbelow
set splitright
set scrolloff=8
set sidescrolloff=8

" Colores
syntax enable
set background=dark
colorscheme default

" Mapeos útiles
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>

" Navegación entre ventanas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l