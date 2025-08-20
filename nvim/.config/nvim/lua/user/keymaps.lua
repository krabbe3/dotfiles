-- keymaps for my nvim setup
local opts = { noremap = true, silent = true }

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- quality of life changes
-- never press "Q"
keymap("n", "Q", "<nop>")


-- NORMAL mode keymaps
-- leader jk = esc in n
-- EXPERIMENTAL SEE IF THIS CAUSES PROBLEMS!!!!!!!!!!!!!!!!
keymap('n', '<leader>jk', '<ESC>', opts)
-- capital J appends line below cursor to eol -> keep cursor at position
keymap("n", "J", "mzJ'z")
-- half page jumping up and down with centering
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "<C-d>", "<C-d>zz")
-- search terms stay in the middle
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
-- keeps a highlighted variable when pasting -> does nor overwrite buffer (void)
keymap("n", "<leader>p", "\"_dP")
-- yanking in system clipboard (in normal mode) -> there is also option for v mode
keymap("n", "<leader>y", "\"+y")
keymap("n", "<leader>Y", "\"+Y")
-- deleting to void register
keymap("n", "<leader>d", "\"_d")
-- switch projects!!! NEEDS TMUX!
--keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux--sessionizer<CR>")

-- change name under cursor for whole file
keymap("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- make file executeable!!!
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = false })

-- source current file
keymap("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- split with leader | - like in tmux
vim.keymap.set('n', '<leader>|', ':vsplit<CR>', { desc = 'Vertical split' })
vim.keymap.set('n', '<leader>-', ':split<CR>', { desc = 'Horizontal split' })


-- INSERT mode keymaps
keymap('i', 'jk', '<ESC>', opts)

-- VISUAL mode keymaps
-- esc
keymap('v', '<leader>jk', '<ESC>', opts)
-- move and indent marked stuff = awesome
keymap("v", "J", ":m '>+1<cr>gv=gv")
keymap("v", "K", ":m '<-2<cr>gv=gv")
-- yank marked text to system clipboard in visual mode
keymap("v", "<leader>y", "\"+y")
-- deleting to void register
keymap("v", "<leader>d", "\"_d")