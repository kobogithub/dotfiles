-- ~/.config/nvim/init.lua - Configuración básica de Neovim

-- Configuración general
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Búsqueda
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Interfaz
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Mapeos básicos
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Guardar archivo" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Cerrar ventana" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Limpiar búsqueda" })

-- Navegación entre ventanas
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Ventana abajo" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Ventana arriba" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })

-- Mover líneas
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover línea abajo" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover línea arriba" })

-- Centrar cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Configuración de colores (básica)
vim.cmd.colorscheme("default")