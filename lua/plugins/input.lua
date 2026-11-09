-- ------------------------------------------------- Input / IME -------------------------------------------------
-- Input Method Editor (IME) plugins for typing in non-English languages.
-- Mission: Support typing in Vietnamese and other languages via IME (vietnamese.nvim).
return {
	-- Vietnamese input method support
	{
		dir = "/home/stilux/Data/workspace/neovim-plugins/vietnamese.nvim",
		event = "InsertEnter",
		opts = {},
	},
}
