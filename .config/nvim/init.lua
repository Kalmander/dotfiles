local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- folke segir mikilvægt að stilla leadrinn áður en 
-- lazy er loadað
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require('lazy').setup('tkj.plugins')

require('tkj.colorscheme')
require("tkj.keymaps")
require("tkj.options")
require("tkj.commands")
require("tkj.autocommands")

require("tkj.lsp")
require("tkj.cmp_and_luasnip")

require("tkj.input_layout")
require("tkj.math-snippets").setup()
require("tkj.calendar_options")
