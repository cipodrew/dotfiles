return {
	"mvllow/stand.nvim",
	version = "*",
	lazy = false,
	config = function()
		local stand = require("stand").setup({
			minute_interval = 60,
		})
	end,
}
