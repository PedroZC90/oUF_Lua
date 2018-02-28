local F, C, L, G = unpack(select(2, ...))
if not (C.plugins.enable and C.plugins.interrupt) then return end
------------------------------------------------------------
-- Interrupt Announce by Elv22
------------------------------------------------------------

local channel = "SAY"

local function OnEvent(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, extraSpellID, extraSpellName = ...
		
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			channel = "INSTANCE_CHAT"
		elseif IsInRaid("player") then
			channel = "RAID"
		elseif IsInGroup("player") then
			channel = "PARTY"
		else
			channel = "SAY"
		end
		
		if eventType == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") then
			SendChatMessage("Interrupted " .. destName .. ": " .. GetSpellLink(extraSpellID) .."!", channel)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", OnEvent)