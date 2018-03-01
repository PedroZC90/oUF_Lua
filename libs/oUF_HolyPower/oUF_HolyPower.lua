local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_HolyPower is unable to locate oUF install.")

local _, class = UnitClass("player")

if (class ~= "PALADIN") then return end

-- sourced from FrameXML/Constants.lua
local SPEC_PALADIN_RETRIBUTION = SPEC_PALADIN_RETRIBUTION or 3
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER or 9

local function Update(self, event, unit, powerType)
	if not (unit == self.unit and (powerType and powerType == "HOLY_POWER")) then return end
	
	local element = self.HolyPower
	
	-- function = PreUpdate(self, unit)
	-- self = self.HolyPower
	if (element.PreUpdate) then element:PreUpdate(unit) end
	
	local cur = UnitPower("player", SPELL_POWER_HOLY_POWER)
	local max = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
	
	for i = 1, max do
		if (i > cur) then
			element[i]:Hide()	-- PROBLEM HERE (on create a char)
			element[i]:SetValue(0)
		else
			element[i]:Show()
			element[i]:SetValue(1)
		end
	end
	
	-- PostUpdate(self, unit, cur, max, powerType)
	-- self = self.HolyPower
	if (element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, powerType)
	end
end

local function Path(self, ...)
	return (self.HolyPower.Override or Update)(self, ...)
end

local function Visibility(self, event, unit)
	local element = self.HolyPower
	
	local spec = GetSpecialization
	if (spec == SPEC_PALADIN_RETRIBUTION) then
		element:Show()
	else
		element:Hide()
		for i = 1, #element do
			element[i]:Hide()
		end
	end
	
	Path(self, event, unit, "HOLY_POWER")
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "HOLY_POWER")
end

local function Enable(self, unit)
	if (unit ~= "player") then return end
	
	local element = self.HolyPower
	if (element) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER_FREQUENT", Visibility)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)
		
		local r, g, b = unpack(self.colors.power["HOLY_POWER"])
		for i = 1, #element do
			local bar = element[i]
			if (bar:IsObjectType("StatusBar")) then
				if (not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end
				
				bar:SetStatusBarColor(r, g, b)
				bar:SetMinMaxValues(0, 1)
			end
		end
		
		element:Hide()
		
		return true
	end
end

local function Disable(self)
	if (self.HolyPower) then
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Visibility)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	end
end

oUF:AddElement("HolyPower", Visibility, Enable, Disable)