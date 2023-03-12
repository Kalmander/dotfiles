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
-- vim.g.maplocalleader = " "

require('lazy').setup('tkj.plugins')
require('tkj.options')
require('tkj.keymaps')
require('tkj.lsp')
require('tkj.cmp')

require("tkj.math-snippets").setup()
require("tkj.mathmode_keymap")
require("tkj.calendar")
