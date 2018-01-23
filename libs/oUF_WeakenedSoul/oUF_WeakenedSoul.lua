--[[
# Element: WeakenedSoul
Handles the visibility and updating of player's weakenedsoul debuff.

## Widget:
WeakenedSoul - A 'StatusBar" to represent the time left of weakened soul debuff.

## Sub-Widgets:
.Icon - A 'Texture' to represent weakened soul icon.

## Examples:

	local WeakenedSoul = CreateFrame("StatusBar", nil, self)
	WeakenedSoul:SetAllPoints(Power)
	WeakenedSoul:SetStatusBarTexture(normTex)
	WeakenedSoul:SetStatusBarColor(.80,.08,.08)
	WeakenedSoul:SetFrameLevel(Power:GetFrameLevel() + 1)

	local button = CreateFrame("Frame", nil, WeakenedSoul)
	button:SetPoint("TOPRIGHT", self, "TOPLEFT", -7, 0)
	button:SetSize(27, 27)

	local icon = WeakenedSoul:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	icon:SetTexCoord(.08,.92,.08,.92)

	WeakenedSoul.icon = icon
	self.WeakenedSoul = WeakenedSoul
	
--]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_WeakenedSoul as unable to locate oUF install")

SPELLID_WEAKENEDSOUL = 6788
SPELLID_POWER_WORD_SHIELD = 17

local function GetDebuffInfo(unit)
	if not UnitCanAssist("player", unit) then return end
	
	local i = 1
	repeat
		local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, "HARMFUL")
		
		if (spellID == 6788) then
			return true
		end
		
		i = i + 1
	until (not spellID)
end

local function UpdateBar(self, event, unit)
	local duration = self.duration
	local expiration = self.expiration - GetTime()
	local value
	if (expiration == 0 or duration == 0) then
		value = 0
	else
		value = 100 * (expiration / duration)
	end
	self:SetValue(value)
end

local function Update(self, event, unit)
	if (unit ~= self.unit) then return end
	
	local element = self.WeakenedSoul
	
	if (element.PreUpdate) then element:PreUpdate(unit) end
	
	if GetDebuffInfo(unit) then
		local name, _, icon, _, _, duration, expirationTime, caster = UnitDebuff(unit, GetSpellInfo(6788))
		
		element.duration = duration
		element.expiration = expirationTime
		element:Show()
		element:SetScript("OnUpdate", UpdateBar)
		
		if (element.icon) then element.icon:SetTexture(icon) end
	else
		element:Hide()
		element:SetScript("OnUpdate", nil)
	end
	
	if (element.PostUpdate) then element:PostUpdate(unit) end
end

local function Enable(self)
	local element = self.WeakenedSoul
	if (element) then
		self:RegisterEvent("UNIT_AURA", Update)
		
		element:SetMinMaxValues(0, 100)
		
		element.unit = self.unit
		
		return true
	end
end

local function Disable(self)
	if (self.WeakenedSoul) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("WeakenedSoul", Update, Enable, Disable)