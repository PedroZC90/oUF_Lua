local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ArcaneCharges is unable to locate oUF install.")

local _, class = UnitClass("player")

if (class ~= "MAGE") then return end

-- sourced from FrameXML/Constants.lua
local SPEC_MAGE_ARCANE = SPEC_MAGE_ARCANE or 1
local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES or 16

local function Update(self, event, unit, powerType)
	if not (unit == self.unit and (powerType and powerType == "ARCANE_CHARGES")) then return end
	
	local element = self.ArcaneCharges
	
	-- function = PreUpdate(self, unit)
	-- self = self.ArcaneCharges
	if (element.PreUpdate) then element:PreUpdate(unit) end
	
	local cur = UnitPower("player", SPELL_POWER_ARCANE_CHARGES)
	local max = UnitPowerMax("player", SPELL_POWER_ARCANE_CHARGES)
	
	for i = 1, max do
		if (i > cur) then
			element[i]:Hide()
			element[i]:SetValue(0)
		else
			element[i]:Show()
			element[i]:SetValue(1)
		end
	end
	
	-- PostUpdate(self, unit, cur, max, powerType)
	-- self = self.ArcaneCharges
	if (element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, powerType)
	end
end

local function Path(self, ...)
	return (self.ArcaneCharges.Override or Update)(self, ...)
end

local function Visibility(self, event, unit)
	local element = self.ArcaneCharges
	
	local spec = GetSpecialization
	if (spec == SPEC_MAGE_ARCANE) then
		element:Show()
	else
		element:Hide()
		for i = 1, #element do
			element[i]:Hide()
		end
	end
	
	Path(self, event, unit, "ARCANE_CHARGES")
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "ARCANE_CHARGES")
end

local function Enable(self, unit)
	if (unit ~= "player") then return end
	
	local element = self.ArcaneCharges
	if (element) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Visibility)
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", Visibility)
		
		local r, g, b = unpack(self.colors.power["ARCANE_CHARGES"])
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
	if (self.ArcaneCharges) then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Visibility)
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", Visibility)
	end
end

oUF:AddElement("ArcaneCharges", Path, Enable, Disable)