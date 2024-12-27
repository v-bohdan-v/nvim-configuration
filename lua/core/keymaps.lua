local opts = {noremap = true, silent = true}

vim.g.mapleader = " "

vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w <CR>", opts)
vim.keymap.set("n", "<C-q>", "<cmd> q <CR>", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevios<CR>", opts)
vim.keymap.set("n", "<leader>x", ":Bdelete!<CR>", opts)
vim.keymap.set("n", "<leader>b", "<cmd> enew <CR>", opts)

-- Neotree
vim.keymap.set("n", "<leader>nt", "<cmd> Neotree<CR>", opts)
