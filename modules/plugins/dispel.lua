local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Dispel Announce by Foof
------------------------------------------------------------
if not C.plugins.dispel then return end

local band = bit.band
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE	-- 0x00000001

local channel = "SAY"

local dispel = {
	-- test
	[163771] = true,	-- Dreadful Roar (Grimfrost Wolfslayer - Frostfire Ridge)
	
	-- add more spellID here
}

local OnEvent = function(self, event, ...)
	timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType = ...
	if (band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= COMBATLOG_OBJECT_AFFILIATION_MINE or sourceGUID ~= UnitGUID("player")) then return end
	
	for spell, check in pairs(dispel) do
		local name, _, _, _, _, _, _ = GetSpellInfo(spell)
		if (check and extraSpellName == name) then
			if eventType == "SPELL_DISPEL" then
				SendChatMessage(destName..": "..extraSpellName.." removed!", Channel)
			elseif eventType == "SPELL_STOLEN" then
				SendChatMessage(destName..": "..extraSpellName.." stolen!", Channel)
			elseif eventType == "SPELL_DISPEL_FAILED" then
				SendChatMessage(destName..": "..extraSpellName.." dispel FAILED!", Channel)
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", OnEvent)