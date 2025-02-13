-- stylua: ignore
local SUPPORTED_KEYS = {
	{ on = "0"}, { on = "1"}, { on = "2"}, { on = "3"}, { on = "4"},
	{ on = "5"}, { on = "6"}, { on = "7"}, { on = "8"}, { on = "9"},
	{ on = "A"}, { on = "B"}, { on = "C"}, { on = "D"}, { on = "E"},
	{ on = "F"}, { on = "G"}, { on = "H"}, { on = "I"}, { on = "J"},
	{ on = "K"}, { on = "L"}, { on = "M"}, { on = "N"}, { on = "O"},
	{ on = "P"}, { on = "Q"}, { on = "R"}, { on = "S"}, { on = "T"},
	{ on = "U"}, { on = "V"}, { on = "W"}, { on = "X"}, { on = "Y"}, { on = "Z"},
	{ on = "a"}, { on = "b"}, { on = "c"}, { on = "d"}, { on = "e"},
	{ on = "f"}, { on = "g"}, { on = "h"}, { on = "i"}, { on = "j"},
	{ on = "k"}, { on = "l"}, { on = "m"}, { on = "n"}, { on = "o"},
	{ on = "p"}, { on = "q"}, { on = "r"}, { on = "s"}, { on = "t"},
	{ on = "u"}, { on = "v"}, { on = "w"}, { on = "x"}, { on = "y"}, { on = "z"},
}

local _send_notification = ya.sync(
	function(state, message)
		ya.notify {
			title = "Bookmarks",
			content = message,
			timeout = state.notify.timeout,
		}
	end
)

local _get_real_index = ya.sync(function(state, idx)
	for key, value in pairs(state.bookmarks) do
		if value.on == SUPPORTED_KEYS[idx].on then
			return key
		end
	end
	return nil
end)

local _get_bookmark_file = ya.sync(function(state)
	local folder = cx.active.current

	if state.file_pick_mode == "parent" or not folder.hovered then
		return { url = folder.cwd, is_parent = true }
	end
	return { url = folder.hovered.url, is_parent = false }
end)

local _generate_description = ya.sync(function(state, file)
	-- if this is true, we don't have information about the folder, so just return the folder url
	if file.is_parent then
		return tostring(file.url)
	end

	if state.desc_format == "parent" then
		return tostring(file.url:parent())
	end
	-- full description
	return tostring(file.url)
end)

local _load_state = ya.sync(function(state)
	ps.sub_remote("@bookmarks", function(body)
		if not state.bookmarks and body then
			state.bookmarks = {}
			for _, value in pairs(body) do
				table.insert(state.bookmarks, value)
			end
		end
	end)
end)

local _save_state = ya.sync(function(state, bookmarks)
	if not bookmarks then
		ps.pub_to(0, "@bookmarks", nil)
		return
	end

	local save_state = {}
	if state.persist == "all" then
		save_state = bookmarks
	else -- VIM mode
		local idx = 1
		for _, value in pairs(bookmarks) do
			-- Only save bookmarks in upper case keys
			if string.match(value.on, "%u") then
				save_state[idx] = value
				idx = idx + 1
			end
		end
	end

	ps.pub_to(0, "@bookmarks", save_state)
end)

local _save_last_directory = ya.sync(function(state, persist)
	if persist then
		ps.sub_remote("@bookmarks-lastdir", function(body) state.curr_dir = body end)
	end

	ps.sub("cd", function()
		local file = _get_bookmark_file()
		state.last_dir = state.curr_dir

		if persist and state.last_dir then
			ps.pub_to(0, "@bookmarks-lastdir", state.last_dir)
		end

		state.curr_dir = {
			on = "'",
			desc = _generate_description(file),
			path = tostring(file.url),
			is_parent = file.is_parent,
		}
	end)

	ps.sub("hover", function()
		local file = _get_bookmark_file()
		state.curr_dir.desc = _generate_description(file)
		state.curr_dir.path = tostring(file.url)
	end)
end)

-- ***********************************************
-- **============= C O M M A N D S =============**
-- ***********************************************

local save_bookmark = ya.sync(function(state, idx)
	local file = _get_bookmark_file()

	state.bookmarks = state.bookmarks or {}

	local _idx = _get_real_index(idx)
	if not _idx then
		_idx = #state.bookmarks + 1
	end

	state.bookmarks[_idx] = {
		on = SUPPORTED_KEYS[idx].on,
		desc = _generate_description(file),
		path = tostring(file.url),
		is_parent = file.is_parent,
	}

	-- Custom sorting function
	table.sort(state.bookmarks, function(a, b)
		local key_a, key_b = a.on, b.on

		-- Numbers first
		if key_a:match("%d") and not key_b:match("%d") then
			return true
		elseif key_b:match("%d") and not key_a:match("%d") then
			return false
		end

		-- Uppercase before lowercase
		if key_a:match("%u") and key_b:match("%l") then
			return true
		elseif key_b:match("%u") and key_a:match("%l") then
			return false
		end

		-- Regular alphabetical sorting
		return key_a < key_b
	end)

	if state.persist then
		_save_state(state.bookmarks)
	end

	if state.notify and state.notify.enable then
		local message = state.notify.message.new
		message, _ = message:gsub("<key>", state.bookmarks[_idx].on)
		message, _ = message:gsub("<folder>", state.bookmarks[_idx].desc)
		_send_notification(message)
	end
end)

local all_bookmarks = ya.sync(function(state, append_last_dir)
	local bookmarks = {}

	if state.bookmarks then
		for _, value in pairs(state.bookmarks) do
			table.insert(bookmarks, value)
		end
	end

	if append_last_dir and state.last_dir then
		table.insert(bookmarks, state.last_dir)
	end

	return bookmarks
end)

local delete_bookmark = ya.sync(function(state, idx)
	if state.notify and state.notify.enable then
		local message = state.notify.message.delete
		message, _ = message:gsub("<key>", state.bookmarks[idx].on)
		message, _ = message:gsub("<folder>", state.bookmarks[idx].desc)
		_send_notification(message)
	end

	table.remove(state.bookmarks, idx)

	if state.persist then
		_save_state(state.bookmarks)
	end
end)

local delete_all_bookmarks = ya.sync(function(state)
	state.bookmarks = nil

	if state.persist then
		_save_state(nil)
	end

	if state.notify and state.notify.enable then
		_send_notification(state.notify.message.delete_all)
	end
end)

return {
	entry = function(_, job)
		local action = job.args[1]
		if not action then
			return
		end

		if action == "save" then
			local key = ya.which { cands = SUPPORTED_KEYS, silent = true }
			if key then
				save_bookmark(key)
			end
			return
		end

		if action == "delete_all" then
			return delete_all_bookmarks()
		end

		local bookmarks = all_bookmarks(action == "jump")
		local selected = #bookmarks > 0 and ya.which { cands = bookmarks }
		if not selected then
			return
		end

		if action == "jump" then
			if bookmarks[selected].is_parent then
				ya.manager_emit("cd", { bookmarks[selected].path })
			else
				ya.manager_emit("reveal", { bookmarks[selected].path })
			end
		elseif action == "delete" then
			delete_bookmark(selected)
		end
	end,
	setup = function(state, args)
		if not args then
			return
		end

		if type(args.last_directory) == "table" then
			if args.last_directory.enable then
				_save_last_directory(args.last_directory.persist)
			end
		end

		if args.persist == "all" or args.persist == "vim" then
			state.persist = args.persist
			_load_state()
		end

		if args.desc_format == "parent" then
			state.desc_format = "parent"
		else
			state.desc_format = "full"
		end

		if args.file_pick_mode == "parent" then
			state.file_pick_mode = "parent"
		else
			state.file_pick_mode = "hover"
		end

		state.notify = {
			enable = false,
			timeout = 1,
			message = {
				new = "New bookmark '<key>' -> '<folder>'",
				delete = "Deleted bookmark in '<key>'",
				delete_all = "Deleted all bookmarks",
			},
		}
		if type(args.notify) == "table" then
			if type(args.notify.enable) == "boolean" then
				state.notify.enable = args.notify.enable
			end
			if type(args.notify.timeout) == "number" then
				state.notify.timeout = args.notify.timeout
			end
			if type(args.notify.message) == "table" then
				if type(args.notify.message.new) == "string" then
					state.notify.message.new = args.notify.message.new
				end
				if type(args.notify.message.delete) == "string" then
					state.notify.message.delete = args.notify.message.delete
				end
				if type(args.notify.message.delete_all) == "string" then
					state.notify.message.delete_all = args.notify.message.delete_all
				end
			end
		end
	end,
}
