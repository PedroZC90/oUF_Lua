local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Lua is unable to locate oUF install.")

local T, C, L, G = unpack(select(2, ...))

local len = string.len
local byte = string.byte
local sub = string.sub
local format = string.format

------------------------------------------------------------
-- oUF Tags:
------------------------------------------------------------

-- return a string with a set number of characters.
local UTF8sub = function(name, size, dots)
	if not name then return end
	local bytes = len(name)
	if (bytes <= size) then
		return name
	else
		local lenght, pos = 0, 1
		while(pos <= bytes) do
			lenght = lenght + 1
			local c = byte(name, pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (lenght == size) then break end
		end

		if (lenght == size and pos <= bytes) then
			return sub(name, 1, pos - 1) .. (dots and "..." or "")
		else
			return name
		end
	end
end

-- return a color based on unit difficulty (level difference)
oUF.Tags.Events["oUF_Lua:diffcolor"] = "UNIT_LEVEL"
oUF.Tags.Methods["oUF_Lua:diffcolor"] = function(unit)
	local r, g, b
	local level = UnitLevel(unit)
	
	if (level < 1) then
		r, g, b = .69, .31, .31
	else
		local diflevel = UnitLevel("target") - UnitLevel("player")
		if (diflevel >= 5) then
			r, g, b = .69, .31, .31
		elseif (diflevel >= 3) then
			r, g, b = .71, .43, .27
		elseif (diflevel >= -2) then
			r, g, b = .84, .75, .65
		elseif (-diflevel <= GetQuestGreenRange()) then
			r, g, b = .33, .59, .33
		else
			r, g, b = .55, .57, .61
		end
	end
	
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- return unit color based on class/reaction
oUF.Tags.Events["oUF_Lua:namecolor"] = "UNIT_POWER"
oUF.Tags.Methods["oUF_Lua:namecolor"] = function(unit)
	local r, g, b
	local reaction = UnitReaction(unit, "player")
	
	if (UnitIsPlayer(unit)) then
		return _TAGS["raidcolor"](unit)
	elseif (reaction) then
		r, g, b = unpack(T.UnitColors.reaction[reaction])
		return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	else
		r, g, b = .84, .75, .65
		return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

-- return unit group role
local function GetGroupRole(unit)
	local isLeader = UnitIsGroupLeader(unit)
	local isAssistant = UnitIsGroupAssistant(unit) or UnitIsRaidOfficer(unit)
	if (isLeader) then
		return "|L| "
	elseif (isAssistant) then
		return "|A| "
	end
end

-- return a name shorter than 10 characters.
oUF.Tags.Events["oUF_Lua:nameshort"] = "UNIT_NAME_UPDAT PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["oUF_Lua:nameshort"] = function(unit)
	local name = UnitName(unit)
	local role = GetGroupRole(unit) or ""
	if (name) then
		return UTF8sub(role .. name, 10, false)
	end
end

-- return a name shorter than 15 characters.
oUF.Tags.Events["oUF_Lua:namemedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["oUF_Lua:namemedium"] = function(unit)
	local name = UnitName(unit)
	if (name) then
		return UTF8sub(name, 15, true)
	end
end

-- return a name shorter than 20 characters.
oUF.Tags.Events["oUF_Lua:namelong"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["oUF_Lua:namelong"] = function(unit)
	local name = UnitName(unit)
	if (name) then
		return UTF8sub(name, 20, true)
	end
end

-- return with unit is away.
oUF.Tags.Events["oUF_Lua:afk"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["oUF_Lua:afk"] = function(unit)
	if UnitIsAFK(unit) then
		return CHAT_FLAG_AFK
	end
end

-- return with unit is dnd.
oUF.Tags.Events["oUF_Lua:dnd"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags.Methods["oUF_Lua:dnd"] = function(unit)
	if UnitIsDND(unit) then
		return CHAT_FLAG_DND
	end
end

-- return if unit is dead.
oUF.Tags.Events["oUF_Lua:dead"] = "UNIT_HEALTH"
oUF.Tags.Methods["oUF_Lua:dead"] = function(unit)
	if UnitIsDead(unit) then
		return L.unit_DEAD
	elseif (UnitIsGhost(unit)) then
		return L.unit_GHOST
	end
end