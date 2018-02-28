local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Development (write anything here)
------------------------------------------------------------

local enable = false
local size = 16
local showSolo = false
local myGUID = UnitGUID("player")

if not enable then return end

-- events handled
local COMBAT_EVENTS = {
	SWING_DAMAGE = false,

	SPELL_DAMAGE = true,
	SPELL_MISSED = false,
	SPELL_PERIODIC_DAMAGE = false,
	-- Heal
	SPELL_HEAL = true,
	SPELL_PERIODIC_HEAL = false,
	-- Aura
	SPELL_AURA_APPLIED = true,
	SPELL_AURA_REMOVED = true,
	-- Cast
	SPELL_CAST_START = true,
	SPELL_CAST_SUCCESS = true,
	SPELL_CAST_FAILED = false,
	-- Summon
	SPELL_SUMMON = true,
	-- Units
	UNIT_DIED = true,
	UNIT_DESTROYED = true,
	
}

-- text color based on spell school
local SPELL_SCHOOL_COLOR = {
	[0]  = { 1., 1., 1. },		-- NONE
	[1]	 = { 1., 1., .0 },		-- PHYSICAL
	[2]  = { 1., .9, .5 },		-- HOLY
	[4]  = { 1., .5, .0 },		-- FIRE
	[8]  = { .3, 1., .3 },		-- NATURE
	[16] = { .5, 1., 1. },		-- FROST
	[32] = { .5, .5, 1. },		-- SHADOW
	[64] = { 1., .5, 1. },		-- ARCANE
}

-- create an escape sequence to insert icon texture into a string.
local function IconEscapeSequence(texture, size1, size2, xoffset, yoffset, dimx, dimy, coordx1, coordx2, coordy1, coordy2)
	local fmt = "|T%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"
	return string.format(fmt, texture, size1, size2, xoffset, yoffset, dimx, dimy, coordx1, coordx2, coordy1, coordy2)
end

-- return a color base on spell/abilitie school.
local function UpdateMsgColor(school)
	local r, g, b = 1., 1., 1.
	if school then
		if (SPELL_SCHOOL_COLOR[school]) then
			r, g, b = unpack(SPELL_SCHOOL_COLOR[school])
		end
	end
	return r, g, b
end

local function UnitBelongToPlayer(unitFlag)
	return (CombatLog_Object_IsA(unitFlag, COMBATLOG_FILTER_ME) or
			CombatLog_Object_IsA(unitFlag, COMBATLOG_FILTER_MINE) or
			CombatLog_Object_IsA(unitFlag, COMBATLOG_FILTER_MY_PET))
end

-- function to filter combat log events.
local function ProcessCombatLog(self, timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...) 
	if not COMBAT_EVENTS[combatEvent] then return end
	
	-- if not destGUID then destGUID = myGUID end
	
	-- if sourceGUID ~= myGUID and destGUID ~= myGUID then return end
	-- if showSolo and sourceGUID ~= myGUID then return end
	
	if not UnitBelongToPlayer(sourceFlags) then return end
	
	-- prefix
	local spellID, spellName, spellSchool = ...
	local spellIcon = GetSpellTexture(spellID)
	
	-- icons
	local icon
	if (spellIcon) then
		icon = IconEscapeSequence(spellIcon, size, size, 0, 0, 64, 64, 5, 59, 5, 59)
	end
	
	-- text color based on school color
	local r, g, b = UpdateMsgColor(spellSchool)
	
	-- show event info (good way to get spellIDs)
	print(format("|cff%02x%02x%02x", 255 * r, 255 * g, 255 * b), icon, combatEvent, sourceName, destName, ...)
end

local function OnEvent(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		ProcessCombatLog(self, ...)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", OnEvent)