local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ComboPoints is unable to locate oUF install.")

local _, class = UnitClass("player")

if not (class == "ROGUE" or class == "DRUID") then return end

-- sourced from FrameXML/Constants.lua
local SPELL_POWER_COMBO_POINTS = SPELL_POWER_COMBO_POINTS or 4
-- sourced from FrameXML/TargetFrame.lua
local MAX_COMBO_POINTS = MAX_COMBO_POINTS or 5
local CAT_FORM = CAT_FORM or 1

local colors = {
	[1] = {.69, .31, .31, 1},
	[2] = {.65, .42, .31, 1},
	[3] = {.65, .63, .35, 1},
	[4] = {.46, .63, .35, 1},
	[5] = {.33, .63, .33, 1},
	[6] = {.20, .63, .33, 1},
}

local function UpdateShapeShift(self, cur)
	local element = self.ComboPoints
	
	local form = GetShapeshiftFormID()
	if (form == CAT_FORM) then
		if (cur > 0) then
			element:Show()
		else
			element:Hide()
		end
	else
		for i = 1, #element do
			element[i]:Hide()
		end
	end
end

local function Update(self, event, unit, powerType)
	if (unit ~= self.unit and (powerType and powerType ~= "COMBO_POINTS")) then return end
	
	local element = self.ComboPoints
	
	-- function = PreUpdate(self, unit)
	-- self = self.ComboPoints
	if (element.PreUpdate) then element:PreUpdate(unit) end
	
	local cur = UnitPower("player", SPELL_POWER_COMBO_POINTS)
	local max = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS)
	
	if cur then
		for i = 1, max do
			if (i > cur) then
				element[i]:Hide()
				element[i]:SetValue(0)
			else
				element[i]:Show()
				element[i]:SetValue(1)
			end
		end
	end
	
	if (class == "ROGUE") then
		element:Show()
	elseif (class == "DRUID") then
		UpdateShapeShift(self, cur)
	end
	
	-- PostUpdate(self, unit, cur, max, powerType)
	-- self = self.ComboPoints
	if (element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, powerType)
	end
end

local function UpdateMaxCombo(self)
	local element = self.ComboPoints
	
	local Anticipation = select(4, GetTalentInfo(3, 2, 1))
	local Depper = select(4, GetTalentInfo(3, 1, 1))
	
	if (class == "ROGUE" and Anticipation) then
		for i = 1, #element do
			element[i]:SetWidth(element[i].Anticipation)
			element[i]:Show()
		end
	elseif (class == "ROGUE" and Depper) then
		for i = 1, #element do
			element[i]:SetWidth(element[i].Depper)
			if (i > 6) then
				element[i]:Hide()
			else
				element[i]:Show()
			end
		end
	else
		for i = 1, #element do
			element[i]:SetWidth(element[i].None)
			if (i > 5) then
				element[i]:Hide()
			else
				element[i]:Show()
			end
		end
	end
end

local function Path(self, ...)
	return (self.ComboPoints.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "COMBO_POINTS")
end

local function Enable(self, unit)
	if (unit ~= "player") then return end
	
	local element = self.ComboPoints
	if (element) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER", Path)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateMaxCombo)
		self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", Path)
		
		local r, g, b
		for i = 1, #element do
			local bar = element[i]
			if (bar:IsObjectType("StatusBar")) then
				if (not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end
				r, g, b = oUF.RGBColorGradient(i - 1, #element, 0.69, 0.31, 0.31, .85, .77, .36, 0.33, 0.59, 0.33)
				-- code
				bar:SetStatusBarColor(r, g, b)
				bar:SetMinMaxValues(0, 1)
			end
		end
		
		UpdateMaxCombo(self)
		--element:Hide()
		
		return true
	end
end

local function Disable(self)
	if (self.ComboPoints) then
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateMaxCombo)
		self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", Path)
	end
end

oUF:AddElement("ComboPoints", Path, Enable, Disable)