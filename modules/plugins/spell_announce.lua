local T, C, L, G = unpack(select(2, ...))
if not (C.plugins.enable and C.plugins.spellannounce) then return end
------------------------------------------------------------
-- Spell Announce
-- Author: Duffed
-- Editor: Luaerror
------------------------------------------------------------

local chat = "SAY"
local myName, myGUID
local format = string.format

local COMBAT_EVENTS = {
	SPELL_CAST_SUCCESS = true,
	SPELL_CAST_FAILED = true,
	SPELL_AURA_APPLIED = true,
	SPELL_AURA_REMOVED = true,
	SPELL_SUMMON = true,
	SPELL_HEAL = true,
	UNIT_DESTROYED = true,
	UNIT_DIED = true,
}

--[[
	AURA	- announce spells that apply aura(buffs) casted by player or casted on player.
	ALL		- announce spells that apply an aura at many units, announce just if player is affected.
	CAST	- announce spells casted by the player only, that don't necessary apply any aura (example: Power Word: Barrier, Healing Rain, ...)
	CHANNEL	- announce spells channeled by the player only. (example: Divine Hymn, Tranquility, ...)
	SUMMON	- announce spells casted by player that summon an unit. (example: Totems, ...)
	CC		- announce crowd control or debuff casted on player.							
--]]
local SUMMONED_UNITS = {}
local SPELL_ANNOUNCE = {
	AURA = {
	-- Priest
		[10060] = true,		-- Power Infusion
		-- Discipline
		[33206] = true,		-- Pain Suppression
		-- Holy
		[27827] = true,		-- Spirit of Redemption
		[47788] = true,		-- Guardian Spirit
		[64901] = true,		-- Symbol of Hope
		-- Shadow
		[15286] = true,		-- Vampiric Embrace
		[47585] = true,		-- Dispersion
		
	-- Monk
		[122278] = true,	-- Dampen Harm
		-- Brewmaster
		[120954] = true,	-- Fortifying Brew
		-- Mistweaver
		[116849] = true,	-- Life Cocoon
		[243435] = true,	-- Fortifying Brew
	
	-- Druid
		-- Balance
		[29166] = true,		-- Innervate
		-- Feral
		[77764] = true,		-- Stampeding Roar (Cat Form)
		-- Guardian
		[61336] = true,		-- Survival Instincts
		[77761] = true,		-- Stampeding Roar (Bear Form)
		-- Restoration
		[102342] = true,	-- Ironbark
		[102351] = true,	-- Cenarion Ward
	
	-- Paladin
		[1022] = true,			-- Blessing of Protection
		[1044] = true,			-- Blessing of Freedom
		[642] = true,			-- Divine Shield
		-- Holy
		[31821] = true,			-- Aura Mastery
		-- Protection
		[31850]	= true,			-- Ardent Defender
	
	-- Warrior
		-- Arms / Fury
		[97462] = true,			-- Commanding Shout
		-- Protection
		[871] = true,			-- Shield Wall
	},
	ALL = {
		[2825] = true,			-- Bloodlust (Shaman Horde)
		[32182] = true,			-- Heroism (Shaman Alliance)
		[80353] = true,			-- Time Warp (Mage)
		[90355] = true,			-- Ancient Hysteria	(Core Hound)
		[160452] = true,		-- Netherwinds (Nether Ray)
	},
	CAST = {
	-- Priest
		-- Discipline
		[62618] = 10,		-- Power Word: Barrier
	
	-- Shaman
		-- Restoration
		[73920]  = 10,		-- Healing Rain
	
	-- Paladin
		[633] = true,		-- Lay on Hands
		-- Holy
		[114158] = 14,		-- Light's Hammer
	},
	CHANNEL = {
	-- Priest
		-- Holy
		[64843] = true,		-- Divine Hymn

	-- Monk
		-- Brewmaster
		[115176] = true,	-- Zen Meditation
		-- Mistweaver
		[191837] = true,	-- Essence Font
	
	-- Druid
		-- Restoration
		[740] = true,		-- Tranquility
	
	-- Paladin
		-- Protection
		[204150] = true,	-- Aegis of Light
	},
	SUMMON = {
	-- Monk
		-- Mistweaver
		[198664] = true,	-- Invoke Chi-Ji, the Red Crane
	
	-- Druid
		-- Restoration
		[145205] = true,	-- Efflorescence
	
	-- Shaman
		-- Restoration
		[5394] = true,		-- Healing Stream Totem
		[98008] = true,		-- Spirit Link Totem
		[108280] = true,	-- Healing Tide Totem
		[157153] = true,	-- Cloudburst Totem
		[198838] = true,	-- Earthen Shield Totem
		[207399] = true,	-- Ancestral Protection Totem
	},
	DEBUFF = {
		-- Priest
		[605] = true,		-- Mind Control
		[8122] = true,		-- Psychic Scream
		[205364] = true,		-- Mind Control (Talent)
		-- Monk
		[115078] = true,	-- Paralysis
		[198909] = true,	-- Song of Chi-Ji
		[119381] = true,	-- Leg Sweep
		-- Shaman
		[51514]	 = true,	-- Hex
	},
}

-- delete unit from summoned table.
local function ClearSummonedUnits()
	local i = #SUMMONED_UNITS
	while (i > 0) do
		local info = SUMMONED_UNITS[i]
		if (time() - info.timestamp) >= 30 then
			table.remove(SUMMONED_UNITS, i)
		end
		i = i - 1
	end
end

-- delay to send a message.
local LastUpdate = 0
local WaitTable = {}
local function OnUpdate(self, elapsed)
	LastUpdate = LastUpdate + elapsed
	local count = #WaitTable
	
	local i = 1
	while (i <= count) do
		local info = WaitTable[i]
		info.delay = info.delay - elapsed
		
		if (info.delay > 0) then
			i = i + 1
		else
			count = count - 1
			SendChatMessage(format(info.msg, unpack(info.args)), chat)
			table.remove(WaitTable, i)
		end
	end
	
	-- some times combat log doesn't fire event UNIT_DIED for summoned units
	-- so, if an unit was summoned 30 or more seconds ago, delete it from the table.
	if (LastUpdate >= 15) then
		ClearSummonedUnits()
		LastUpdate = 0
	end
end

-- update wait table.
local function Delay(duration, msg, ...)
	if (type(duration) ~= "number") and (type(msg) ~= "string") then
		return false
	end
	
	local info = { 
		delay = duration,
		msg = msg,
		args = { ... },
	}
	-- add spell to wait list.
	table.insert(WaitTable, info)
	
	return true
end

-- function to process COMBAT_LOG_EVENT_UNFILTERED
local function ProcessCombatLog(self, timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if not COMBAT_EVENTS[combatEvent] then return end
	
	-- spells casted by others are just important if destination is my character.
	if (sourceGUID ~= myGUID) and (destGUID ~= myGUID) then return end
	
	-- some spells destName returns nil
	-- if you don't have a target
	if not destName then
		destGUID = sourceGUID
		destName = sourceName
		destFlags = sourceFlags
	end
	
	local spellID, spellName, spellSchool = ...
	
	-- Auras
	for spell, check in pairs(SPELL_ANNOUNCE.AURA) do
		local name = GetSpellInfo(spell)
		if (check == true) and (spellName == name) then
			if (combatEvent == "SPELL_AURA_APPLIED") then
				local duration = select(6, UnitAura(destName, spellName))
				if (sourceGUID == myGUID) then
					if (destName ~= myName) then
						if (duration) then
							SendChatMessage(format("%s (%ds) casted on %s!", spellName, duration, destName), chat)
						else
							SendChatMessage(format("%s casted on %s!", spellName, destName), chat)
						end
					else
						if (duration) then
							SendChatMessage(format("%s (%ds) up!", spellName, duration), chat)
						else
							SendChatMessage(format("%s up!", spellName), chat)
						end
					end
				else
					if (destGUID == myGUID) then
						if (duration) then
							SendChatMessage(format("%s (%ds) on me!", spellName, duration), chat)
						else
							SendChatMessage(format("%s on me!", spellName), chat)
						end
					end
				end
			elseif (combatEvent == "SPELL_HEAL") then
				if (sourceGUID == myGUID) then
					local heal, overheal, absorbed, critical = select(4, ...)
					SendChatMessage(format("%s healed %s for %d!", spellName, destName, heal), chat)
				end
			elseif (combatEvent == "SPELL_AURA_REMOVED") then
				if (sourceGUID == myGUID) then
					if (destName ~= myName) then
						SendChatMessage(format("%s on %s is over!", spellName, destName), chat)
					else
						SendChatMessage(format("%s over!", spellName), chat)
					end
				elseif ((sourceGUID ~= myGUID) and (destGUID == myGUID)) then
					SendChatMessage(format("%s over!", spellName), chat)
				end
			end
		end
	end
	
	-- Spells that apply aura in area, just announce if player is affected.
	if SPELL_ANNOUNCE.ALL[spellID] then
		if (destGUID ~= myGUID) then return end
		if (combatEvent == "SPELL_AURA_APPLIED") then
			local duration = select(6, UnitAura(destName, spellName))
			SendChatMessage(format("%s (%ds) up!", spellName, duration), chat)
		elseif (combatEvent == "SPELL_AURA_REMOVED") then
			SendChatMessage(format("%s over!", spellName), chat)
		end
	end
	
	-- Casting Spells
	if SPELL_ANNOUNCE.CAST[spellID] then
		local duration = SPELL_ANNOUNCE.CAST[spellID]
		if (sourceGUID == myGUID) then
			if (combatEvent == "SPELL_CAST_SUCCESS") then
				SendChatMessage(format("%s up!", spellName), chat)
					
				-- add spell to wait table
				if (type(duration) == "number" and duration > 0) then
					Delay(duration, "%s over!", spellName)
				end
			elseif (combatEvent == "SPELL_AURA_REMOVED") and (duration == true) then
				SendChatMessage(format("%s over!", spellName), chat)
			end
		end
	end
	
	-- Channeling Spells
	if SPELL_ANNOUNCE.CHANNEL[spellID] then
		if (sourceGUID == myGUID) then
			if (combatEvent == "SPELL_CAST_SUCCESS") then
				SendChatMessage(format("Channeling %s!", spellName), chat)
			elseif (combatEvent == "SPELL_AURA_REMOVED") then
				if (destGUID == myGUID) then
					SendChatMessage(format("%s over!", spellName), chat)
				end
			end
		end
	end
	
	-- Summons
	if SPELL_ANNOUNCE.SUMMON[spellID] then
		if (combatEvent == "SPELL_SUMMON") then
			SendChatMessage(format("%s up!", spellName), chat)
			
			-- save summoned unit GUID and name
			table.insert(SUMMONED_UNITS, { timestamp = timestamp, GUID = destGUID, Name = destName, delay = 0 })
			
			if (#SUMMONED_UNITS > 1) then
				-- sort by timestamp
				table.sort(SUMMONED_UNITS, function(a, b)
					if (a.timestamp == b.timestamp) then
						return a.Name < b.Name
					end
					return a.timestamp > b.timestamp
				end)
			end
		end
	end
	
	-- if a unit die, verify if they were any of the summoned units.
	if (combatEvent == "UNIT_DIED") then
		for index, unit in ipairs(SUMMONED_UNITS) do
			if (unit.GUID == destGUID and unit.Name == destName) then
				SendChatMessage(format("%s over!", destName), chat)
				
				-- remove unit from table.
				table.remove(SUMMONED_UNITS, index)
			end
		end
	end
	
	-- Debuffs
	if SPELL_ANNOUNCE.DEBUFF[spellID] then
		-- Crowd Control type code
		if (destGUID == myGUID) then
			if (combatEvent == "SPELL_AURA_APPLIED") then
				local duration = select(6, UnitDebuff(destName, spellName))
				SendChatMessage(format("%s (%ds) on me!", spellName, duration), chat)
			elseif (combatEvent == "SPELL_AURA_REMOVED") then
				SendChatMessage(format("%s over!", spellName), chat)
			end
		end
	end
end

local function OnEvent(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		ProcessCombatLog(self, ...)
	elseif (event == "PLAYER_LOGIN") then
		self:Initialize()
	end
end

local f = CreateFrame("Frame")
--f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", OnUpdate)

function f:Initialize()
	myName = UnitName("player")
	myGUID = UnitGUID("player")
	
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

if IsLoggedIn() then
	f:Initialize()
else
	f:RegisterEvent("PLAYER_LOGIN")
end