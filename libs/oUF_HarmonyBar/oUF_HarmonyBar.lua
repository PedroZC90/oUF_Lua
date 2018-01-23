local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_HarmonyBar is unable to locate oUF install.")

local _, class = UnitClass("player")

if (class ~= "MONK") then return end

-- sourced from FrameXML/Constants.lua
local SPEC_MONK_WINDWALKER = SPEC_MONK_WINDWALKER or 3
local SPELL_POWER_CHI = SPELL_POWER_CHI or 12

local colors = {
	[1] = {.69, .31, .31, 1},
	[2] = {.65, .42, .31, 1},
	[3] = {.65, .63, .35, 1},
	[4] = {.46, .63, .35, 1},
	[5] = {.33, .63, .33, 1},
	[6] = {.20, .63, .33, 1},
}

local function Update(self, event, unit, powerType)
	--if (unit ~= self.unit and (powerType and powerType ~= "CHI")) then return end
	if (unit ~= self.unit and powerType ~= "CHI") then return end
	
	local element = self.HarmonyBar
	
	-- function = PreUpdate(self, unit)
	-- self = self.HarmonyBar
	if (element.PreUpdate) then element:PreUpdate(unit) end
	
	local cur = UnitPower("player", SPELL_POWER_CHI)
	local max = UnitPowerMax("player", SPELL_POWER_CHI)
	
	if (cur) then
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
	
	-- PostUpdate(self, unit, cur, max, powerType)
	-- self = self.HarmonyBar
	if (element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, powerType)
	end
end

local function Path(self, ...)
	return (self.HarmonyBar.Override or Update)(self, ...)
end

local function UpdateMaxChi(self)
	local element = self.HarmonyBar
	
	local Ascencion = select(4, GetTalentInfo(3, 2, 1))
	
	if (Ascencion) then
		for i = 1, #element do
			element[i]:SetWidth(element[i].Ascencion)
			element[i]:Show()
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

local function Visibility(self, event, unit)
	local element = self.HarmonyBar
	
	local spec = GetSpecialization()
	if (spec == SPEC_MONK_WINDWALKER) then
		element:Show()
	else
		element:Hide()
		for i = 1, #element do
			element[i]:Hide()
		end
	end
	
	Path(self, event, unit, "CHI")
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "CHI")
end

local function Enable(self, unit)
	if (unit ~= "player") then return end
	
	local element = self.HarmonyBar
	if (element) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Visibility)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateMaxChi)
		
		for i = 1, #element do
			local bar = element[i]
			if (bar:IsObjectType("StatusBar")) then
				if (not bar:GetStatusBarTexture()) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end
				
				-- code
				bar:SetStatusBarColor(unpack(colors[i]))
				bar:SetMinMaxValues(0, 1)
			end
		end
		
		UpdateMaxChi(self)
		element:Hide()
		
		return true
	end
end

local function Disable(self)
	if (self.HarmonyBar) then
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Visibility)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateMaxChi)
	end
end

oUF:AddElement("HarmonyBar", Path, Enable, Disable)