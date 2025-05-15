-- ██╗   ██╗ █████╗ ███████╗██╗
-- ╚██╗ ██╔╝██╔══██╗╚══███╔╝██║
--  ╚████╔╝ ███████║  ███╔╝ ██║
--   ╚██╔╝  ██╔══██║ ███╔╝  ██║
--    ██║   ██║  ██║███████╗██║
--    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝
--
-- Yazi Config File by Arfan Zubi

require("full-border"):setup {
	type = ui.Border.ROUNDED,
}

require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })

require("bookmarks"):setup({
	last_directory = { enable = true, persist = true, mode="dir" },
	persist = "all",
	desc_format = "full",
	file_pick_mode = "hover",
	custom_desc_input = false,
	notify = {
		enable = true,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})
