-- stylua: ignore
local MOTIONS_AND_OP_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- commands
	{ on = "d" }, { on = "v" }, { on = "y" }, { on = "x" },
	-- tab commands
	{ on = "t" }, { on = "L" }, { on = "H" }, { on = "w" },
	{ on = "W" }, { on = "<" }, { on = ">" }, { on = "~" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }, { on = "h" }, { on = "l" }, { on = "<Down>" }, { on = "<Up>" }, { on = "<Left>" }, { on = "<Right>" }
}

-- stylua: ignore
local MOTION_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }, { on = "h" }, { on = "l" }, { on = "<Down>" }, { on = "<Up>" }, { on = "<Left>" }, { on = "<Right>" }
}

-- stylua: ignore
local DIRECTION_KEYS = {
	{ on = "j" }, { on = "k" }, { on = "<Down>" }, { on = "<Up>" },
	-- tab movement
	{ on = "t" }
}

local SHOW_NUMBERS_ABSOLUTE = 0
local SHOW_NUMBERS_RELATIVE = 1
local SHOW_NUMBERS_RELATIVE_ABSOLUTE = 2

local ENTER_MODE_FIRST = 0
local ENTER_MODE_CACHE = 1
local ENTER_MODE_CACHE_OR_FIRST = 2

-----------------------------------------------
----------------- R E N D E R -----------------
-----------------------------------------------

local render_motion_setup = ya.sync(function(_)
	ya.render()

	Status.motion = function() return ui.Span("") end

	Status.children_redraw = function(self, side)
		local lines = {}
		if side == self.RIGHT then
			lines[1] = self:motion(self)
		end
		for _, c in ipairs(side == self.RIGHT and self._right or self._left) do
			lines[#lines + 1] = (type(c[1]) == "string" and self[c[1]] or c[1])(self)
		end
		return ui.Line(lines)
	end

	-- TODO: check why it doesn't work line this
	-- Status:children_add(function() return ui.Span("") end, 1000, Status.RIGHT)
end)

local render_motion = ya.sync(function(_, motion_num, motion_cmd)
	ya.render()

	Status.motion = function(self)
		if not motion_num then
			return ui.Span("")
		end

		local style = self:style()

		local motion_span
		if not motion_cmd then
			motion_span = ui.Span(string.format("  %3d ", motion_num))
		else
			motion_span = ui.Span(string.format(" %3d%s ", motion_num, motion_cmd))
		end

		return ui.Line {
			ui.Span(THEME.status.separator_open):fg(style.main.bg),
			motion_span:style(style.main),
			ui.Span(THEME.status.separator_close):fg(style.main.bg),
			ui.Span(" "),
		}
	end
end)

local render_numbers = ya.sync(function(_, mode)
	ya.render()

	Entity.number = function(_, index, file, hovered)
		local idx
		if mode == SHOW_NUMBERS_RELATIVE then
			idx = math.abs(hovered - index)
		elseif mode == SHOW_NUMBERS_ABSOLUTE then
			idx = file.idx
		else -- SHOW_NUMBERS_RELATIVE_ABSOLUTE
			if hovered == index then
				idx = file.idx
			else
				idx = math.abs(hovered - index)
			end
		end

		-- emulate vim's hovered offset
		if idx >= 100 then
			return ui.Span(string.format("%4d ", idx))
		elseif hovered == index then
			return ui.Span(string.format("%3d  ", idx))
		else
			return ui.Span(string.format(" %3d ", idx))
		end
	end

	Current.redraw = function(self)
		local files = self._folder.window
		if #files == 0 then
			return self:empty()
		end

		local hovered_index
		for i, f in ipairs(files) do
			if f:is_hovered() then
				hovered_index = i
				break
			end
		end

		local entities, linemodes = {}, {}
		for i, f in ipairs(files) do
			linemodes[#linemodes + 1] = Linemode:new(f):redraw()

			local entity = Entity:new(f)
			entities[#entities + 1] = ui.Line({ Entity:number(i, f, hovered_index), entity:redraw() }):style(entity:style())
		end

		return {
			ui.List(entities):area(self._area),
			ui.Text(linemodes):area(self._area):align(ui.Text.RIGHT),
		}
	end
end)

local function render_clear() render_motion() end

-----------------------------------------------
--------- C O M M A N D   P A R S E R ---------
-----------------------------------------------

local get_keys = ya.sync(function(state) return state._only_motions and MOTION_KEYS or MOTIONS_AND_OP_KEYS end)

local function normal_direction(dir)
	if dir == "<Down>" then
		return "j"
	elseif dir == "<Up>" then
		return "k"
	elseif dir == "<Left>" then
		return "h"
	elseif dir == "<Right>" then
		return "l"
	end
	return dir
end

local function get_cmd(first_char, keys)
	local last_key
	local lines = first_char or ""

	while true do
		render_motion(tonumber(lines))
		local key = ya.which { cands = keys, silent = true }
		if not key then
			return nil, nil, nil
		end

		last_key = keys[key].on
		if not tonumber(last_key) then
			last_key = normal_direction(last_key)
			break
		end

		lines = lines .. last_key
	end

	render_motion(tonumber(lines), last_key)

	-- command direction
	local direction
	if last_key == "g" or last_key == "v" or last_key == "d" or last_key == "y" or last_key == "x" then
		DIRECTION_KEYS[#DIRECTION_KEYS + 1] = {
			on = last_key,
		}
		local direction_key = ya.which { cands = DIRECTION_KEYS, silent = true }
		if not direction_key then
			return nil, nil, nil
		end

		direction = DIRECTION_KEYS[direction_key].on
		direction = normal_direction(direction)
	end

	return tonumber(lines), last_key, direction
end

local function is_tab_command(command)
	local tab_commands = { "t", "L", "H", "w", "W", "<", ">", "~" }
	for _, cmd in ipairs(tab_commands) do
		if command == cmd then
			return true
		end
	end
	return false
end

local get_active_tab = ya.sync(function(_) return cx.tabs.idx end)

local get_cache_or_first_dir = ya.sync(function(state)
	if state._enter_mode == ENTER_MODE_CACHE then
		return nil
	elseif state._enter_mode == ENTER_MODE_CACHE_OR_FIRST then
		local hovered_file = cx.active.current.hovered

		if  hovered_file ~= nil and hovered_file.cha.is_dir then
			return cx.active.current.cursor
		end
	end

	local files = cx.active.current.files
	local index = 1

	for i = 1, #files do
		if files[i].cha.is_dir then
			index = i
			break
		end
	end

	return index - 1
end)
-----------------------------------------------
---------- E N T R Y   /   S E T U P ----------
-----------------------------------------------

return {
	entry = function(_, job)
		local initial_value

		local args = job.args
		-- this is checking if the argument is a valid number
		if #args > 0 then
			initial_value = tostring(tonumber(args[1]))
			if initial_value == "nil" then
				return
			end
		end

		local lines, cmd, direction = get_cmd(initial_value, get_keys())
		if not lines or not cmd then
			-- command was cancelled
			render_clear()
			return
		end

		if cmd == "g" then
			if direction == "g" then
				ya.manager_emit("arrow", { -99999999 })
				ya.manager_emit("arrow", { lines - 1 })
				render_clear()
				return
			elseif direction == "j" then
				cmd = "j"
			elseif direction == "k" then
				cmd = "k"
			elseif direction == "t" then
				ya.manager_emit("tab_switch", { lines - 1 })
				render_clear()
				return
			else
				-- no valid direction
				render_clear()
				return
			end
		end

		if cmd == "j" then
			ya.manager_emit("arrow", { lines })
		elseif cmd == "k" then
			ya.manager_emit("arrow", { -lines })
		elseif cmd == "h" then
			for _ = 1, lines do
				ya.manager_emit("leave", {})
			end
		elseif cmd == "l" then
			for _ = 1, lines do
				ya.manager_emit("enter", {})
				local file_idx = get_cache_or_first_dir()
				if file_idx then
					ya.manager_emit("arrow", { -99999999 })
					ya.manager_emit("arrow", { file_idx })
				end
			end
		elseif is_tab_command(cmd) then
			if cmd == "t" then
				for _ = 1, lines do
					ya.manager_emit("tab_create", {})
				end
			elseif cmd == "H" then
				ya.manager_emit("tab_switch", { -lines, relative = true })
			elseif cmd == "L" then
				ya.manager_emit("tab_switch", { lines, relative = true })
			elseif cmd == "w" then
				ya.manager_emit("tab_close", { lines - 1 })
			elseif cmd == "W" then
				local curr_tab = get_active_tab()
				local del_tab = curr_tab + lines - 1
				for _ = curr_tab, del_tab do
					ya.manager_emit("tab_close", { curr_tab - 1 })
				end
				ya.manager_emit("tab_switch", { curr_tab - 1 })
			elseif cmd == "<" then
				ya.manager_emit("tab_swap", { -lines })
			elseif cmd == ">" then
				ya.manager_emit("tab_swap", { lines })
			elseif cmd == "~" then
				local jump = lines - get_active_tab()
				ya.manager_emit("tab_swap", { jump })
			end
		else
			ya.manager_emit("visual_mode", {})
			-- invert direction when user specifies it
			if direction == "k" then
				ya.manager_emit("arrow", { -lines })
			elseif direction == "j" then
				ya.manager_emit("arrow", { lines })
			else
				ya.manager_emit("arrow", { lines - 1 })
			end
			ya.manager_emit("escape", {})

			if cmd == "d" then
				ya.manager_emit("remove", {})
			elseif cmd == "y" then
				ya.manager_emit("yank", {})
			elseif cmd == "x" then
				ya.manager_emit("yank", { cut = true })
			end
		end

		render_clear()
	end,
	setup = function(state, args)
		if not args then
			return
		end

		-- initialize state variables
		state._only_motions = args["only_motions"] or false

		if args["show_motion"] then
			render_motion_setup()
		end

		if args["enter_mode"] == "cache" then
			state._enter_mode = ENTER_MODE_CACHE
		elseif args["enter_mode"] == "first" then
			state._enter_mode = ENTER_MODE_FIRST
		elseif args["enter_mode"] == "cache_or_first" then
			state._enter_mode = ENTER_MODE_CACHE_OR_FIRST
		else
			state._enter_mode = ENTER_MODE_CACHE_OR_FIRST
		end

		if args["show_numbers"] == "absolute" then
			render_numbers(SHOW_NUMBERS_ABSOLUTE)
		elseif args["show_numbers"] == "relative" then
			render_numbers(SHOW_NUMBERS_RELATIVE)
		elseif args["show_numbers"] == "relative_absolute" then
			render_numbers(SHOW_NUMBERS_RELATIVE_ABSOLUTE)
		end
	end,
}
