-- You can delete entries from DB by this command. This command does not remove
-- the file itself, only from DB.
-- - delete the current opened file
--   - :FrecencyDelete
-- - delete the supplied path
--   - :FrecencyDelete /full/path/to/the/file
-- --]=====]
return {
	"nvim-telescope/telescope-frecency.nvim",
	config = function()
		require("telescope").setup({
			extensions = {
				frecency = {
					show_scores = false, -- Default: false
					show_filter_column = false, -- Default: true
				},
			},
		})
		require("telescope").load_extension("frecency")
	end,
}
