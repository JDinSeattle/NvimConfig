return {
	-- 🔭 文件导航增强
	{
		"nvim-neo-tree/neo-tree.nvim",
	},

	-- 💡 更好的代码注释
	{
		"folke/todo-comments.nvim",
	},

	-- 🪟 窗口分割导航（tmux 风格）
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
		},
	},

	-- 🔤 更好的 f/t 跳转
	{
		"folke/flash.nvim",
	},

	-- 📊 Git 集成增强
	{
		"lewis6991/gitsigns.nvim",
	},
}
