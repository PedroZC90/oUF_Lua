local T, C, L, G = unpack(select(2, ...))
if not (C.plugins.enable and C.plugins.raidcd) then return end
------------------------------------------------------------
-- Raid Cooldown
-- Author: Allez
------------------------------------------------------------
local raidcd = {
	["max"] = 10,				-- max number of displayed bars.
	-- bars
	["barwidth"] = 200,			-- set bar width.
	["iconsize"] = 23,			-- set icons height.
	["statusbarheight"] = 3,	-- set status bar height. (if set to 'auto', to status bar height will be equal to icon size)
}

local RAID_COOLDOWNS = {
	-- Priest
		-- Discipline
		[33206] = 4.0,		-- Pain Suppression
		[62618] = 3.0,		-- Power World: Barrier
		-- Holy
		[47788] = 4.0,		-- Guardian Spirit
		[64843] = 3.0,		-- Divine Hymn
		[64901] = 6.0,		-- Symbol of Hope
		-- Shadow
		[15286] = 3.0,		-- Vampiric Embrace
		-- [47585] = 2.0,		-- Dispersion
------------------------------------------------------------
	-- Druid
	[20484] = 10.0, 		-- Rebirth
		-- Balance
		[29166] = 3.0,		-- Innervate
		-- Guardian
		[61336] = 2.0,		-- Survival Instincts
		-- Restoration
		[740] = 3.0,		-- Tranquility
		[102342] = 1.5,		-- Ironbark
------------------------------------------------------------	
	-- Monk
		[122278] = 2.0,		-- Dampen Harm
		-- Brewmaster
		[115176] = 5.0, 	-- Zen Meditation
		[120954] = 7.0,		-- Fortifying Brew (Brewmaster)
		-- Mistweaver
		[115310] = 3.0, 	-- Revival
		[116849] = 3.0, 	-- Life Cocoon
		[198664] = 3.0,		-- Invoke Chi-Ji, the Red Crane
		-- Windwalker
------------------------------------------------------------
	-- Shaman
		-- Elemental
		-- Enhancement
		-- [120668] = 300,	-- Stormlash Totem
		-- Restoration
		[98008] = 3.0,		-- Spirit Link Totem
		[108280] = 3.0,		-- Healing Tide Totem
		[157153] = 0.5,		-- Cloudburst Totem
		[198838] = 1.0,		-- Earthen Shield Totem
		[207399] = 5.0,		-- Ancestral Protection Totem
		
		[108271] = 1.5,			-- Astral Shift
		[108281] = 2.0,			-- Ancestral Guidance
		[114050] = 3.0,			-- Ascendance
------------------------------------------------------------
	-- Warlock
	[20707] = 10,			-- Soulstone
------------------------------------------------------------
	-- Paladin
		-- Holy
		[31821] = 3,		-- Aura Mastery
		-- Protection
		[633] = 10,			-- Lay on Hands
		[642] = 5,			-- Divine Shield
	-- Warrior
		-- Arms / Fury
		[97462] = 3,		-- Commanding Shout
		-- Protection
		[871] = 4,			-- Shield Wall
------------------------------------------------------------		
	-- removed spells
	-- [10060]  = 120,	-- Power Infusion
	-- [115213] = 180, -- Avert Harm
	-- [16190] = 180, -- Mana Tide Totem
}

local COMBAT_EVENTS = {
	SPELL_RESSURECT = true,
	SPELL_CAST_SUCCESS = true,
	SPELL_ARUA_APPLIED = true,
}

local ZONE_TYPES = {
	none = false,	-- when outside an instance
	pvp = false,	-- when in a battleground
	arena = true,	-- when in an arena
	party = true,	-- when in a 5-man instance
	raid = true,	-- when in a raid instance
	-- nil when in an unknown kind of instance, eg. in a scenario
}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local band = bit.band
local format = string.format
local floor = math.floor
local bars = {}
local fontName, fontSize, fontStyle = C.media.pixelfont, 10, "THINOUTLINE, MONOCHROME"

local frame = CreateFrame("Frame", "RaidCD", UIParent)
frame:SetPoint("LEFT", UIParent, "LEFT", 40, 200)
frame:SetSize(raidcd.barwidth, raidcd.iconsize)
frame:SetTemplate("Transparent")

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetPoint("CENTER")
text:SetJustifyH("CENTER")
text:SetFont(fontName, fontSize, fontStyle)
text:SetText("RaidCD")

frame:SetFrameLevel(10)
frame:Hide()

-- convert seconds to day/hour/minute
local function FormatTime(s)
	local minute = 60
	if (s >= minute) then
		return format("%dm", ceil(s / minute))
	elseif (s >= (minute / 12)) then
		return format("%ds", s)
	else
		return format("%.1fs", s)
	end
end

-- update bars positions.
local UpdatePositions = function()
	for i = 1, #bars do
		bars[i]:ClearAllPoints()
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
		else
			bars[i]:SetPoint("TOPLEFT", bars[i - 1], "BOTTOMLEFT", 0, -7)
		end
		bars[i].id = i
		
		if (i <= raidcd.max) then
			bars[i]:Show()
		else
			bars[i]:Hide()
		end
	end
end

-- stop cooldown bar.
local StopTimer = function(bar)
	bar:SetScript("OnUpdate", nil)
	bar:Hide()
	table.remove(bars, bar.id)
	UpdatePositions()
end

-- update status bar.
local OnUpdate = function(self, elapsed)
	local curTime = GetTime()
	if self.endTime < curTime then
		StopTimer(self)
		return
	end
	self.statusbar:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
	self.right:SetText(FormatTime(self.endTime - curTime))
end

-- display tooltip.
local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddDoubleLine(self.spell, self.right:GetText())
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Show()
end

-- hide tooltip.
local OnLeave = function(self)
	GameTooltip:Hide()
end

-- send a chat message.
local OnMouseDown = function(self, button)
	if button == "LeftButton" then
		if IsInRaid() then
			chat = "RAID"
		elseif IsInGroup() then
			chat = "PARTY"
		else
			chat = "SAY"
		end
		SendChatMessage(format("Cooldown: %s - %s (%s remaining)!", self.caster, self.spell, self.right:GetText()), chat)
	elseif button == "RightButton" then
		StopTimer(self)
	end
end

-- create cooldown bar
local function CreateBar()
	local bar = CreateFrame("Frame", nil, UIParent)
	bar:SetSize(frame:GetSize())
	bar:SetFrameStrata("LOW")

	local button = CreateFrame("Button", nil, bar)
	button:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -7, 0)
	button:SetSize(raidcd.iconsize, raidcd.iconsize)
	button:SetBorder("Default")
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(button)
	icon:SetTexCoord(.08,.92,.08,.92)

	local statusbar = CreateFrame("StatusBar", nil, bar)
	statusbar:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 7, 0)
	statusbar:SetStatusBarTexture(C.media.normTex)
	statusbar:SetMinMaxValues(0, 100)
	statusbar:SetFrameLevel(bar:GetFrameLevel() - 1)
	statusbar:SetBorder("Default")
	
	if (raidcd.statusbarheight == 'auto') then
		statusbar:SetSize(bar:GetSize())
	else
		statusbar:SetSize(raidcd.barwidth, raidcd.statusbarheight)
	end
	
	local left = bar:CreateFontString(nil, "OVERLAY")
	left:SetPoint("LEFT", statusbar, 3, 12)
	left:SetJustifyH("LEFT")
	left:SetFont(fontName, fontSize, fontStyle)

	local right = bar:CreateFontString(nil, "OVERLAY")
	right:SetPoint("RIGHT", statusbar, -2, 12)
	right:SetJustifyH("RIGHT")
	right:SetFont(fontName, fontSize, fontStyle)
	
	bar.button = button
	bar.icon = icon
	bar.statusbar = statusbar
	bar.left = left
	bar.right = right
	
	return bar
end

-- start a new cooldown bar
local function StartTimer(sourceName, spellID)
	local name, rank, icon = GetSpellInfo(spellID)
	for k, v in pairs(bars) do
		if (v.caster == sourceName and v.spell == name) then
			return
		end
	end
	
	local bar = CreateBar()
	
	local now = GetTime()
	local cooldown = RAID_COOLDOWNS[spellID] * 60
	bar.caster = sourceName
	bar.spell = name
	bar.startTime = now
	bar.endTime = now + cooldown
	
	bar.left:SetText(sourceName)
	bar.right:SetText(FormatTime(cooldown))
	
	if (icon) then
		bar.icon:SetTexture(icon)
	end
	
	local color = RAID_CLASS_COLORS[select(2, UnitClass(sourceName))]
	bar.statusbar:SetStatusBarColor(color.r, color.g, color.b)
	
	bar:EnableMouse(true)
	bar:SetScript("OnUpdate", OnUpdate)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	bar:SetScript("OnMouseDown", OnMouseDown)
	
	table.insert(bars, bar)
	
	table.sort(bars, function(a, b)
		if (a.endTime == b.endTime) then
			return a.spell < b.spell
		end
		return a.endTime < b.endTime
	end)
	
	UpdatePositions()
end

-- function to process combat log events.
local function ProcessCombatLog(self, timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if COMBAT_EVENTS[combatEvent] then
		local spellID, spellName, spellSchool = ...
		local inInstance, instanceType = IsInInstance()
		
		if (RAID_COOLDOWNS[spellID] and ZONE_TYPES[instanceType]) then
			StartTimer(sourceName, spellID)
		end
	end
end

-- function to handle events.
local function OnEvent(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		ProcessCombatLog(self, ...)
	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		local inInstance, instanceType = IsInInstance()
		if (instanceType == "arena") then
			for k, v in pairs(bars) do
				StopTimer(v)
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", OnEvent)

-- Test Mode
SLASH_RAIDCD1 = "/raidcd"
SlashCmdList["RAIDCD"] = function(msg)
	local max = math.random(5, 20)
	local i = 0
	for spellID, cooldown in pairs(RAID_COOLDOWNS) do
		StartTimer(T.myName, spellID)
		if (i > max) then
			break
		end
		i = i + 1
	end
end