local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for paladin class.
T.ClassElements["PALADIN"] = function(self)
	
	-- Holy Power
	if C.unitframes.holypower then
		local HolyPower = CreateFrame("Frame", self:GetName() .. "HolyPower", self)
		HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		HolyPower:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		HolyPower:SetHeight(10)
		
		local max = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
		local size, delta = T.GetElementSize(self:GetWidth(), max, 7)
		
		for i = 1, max do
			HolyPower[i] = CreateFrame("StatusBar", HolyPower:GetName() .. i, self)
			HolyPower[i]:SetHeight(HolyPower:GetHeight())
			HolyPower[i]:SetStatusBarTexture(blankTex)
			HolyPower[i]:SetBorder("Default")
			
			if (delta > 0 and i <= delta) then
				HolyPower[i]:SetWidth(size + 1)
			else
				HolyPower[i]:SetWidth(size)
			end
			
			if (i == 1) then
				HolyPower[i]:SetPoint("TOPLEFT", HolyPower, "TOPLEFT", 0, 0)
			else
				HolyPower[i]:SetPoint("TOPLEFT", HolyPower[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		self.HolyPower = HolyPower
	end
	
	-- Consecration
	if C.unitframes.totem then
		
		local size = self.Health:GetHeight() + self.Power:GetHeight() + 3
		
		local Totems = CreateFrame("Frame", self:GetName() .. "TotemsBar", self)
		Totems:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -7, 0)
		Totems:SetHeight(size)
		Totems:SetWidth(10)
		
		for i = 1, MAX_TOTEMS do
			Totems[i] = CreateFrame("StatusBar", Totems:GetName() .. i, self)
			Totems[i]:SetHeight(Totems:GetHeight())
			Totems[i]:SetStatusBarTexture(blankTex)
			Totems[i]:SetBorder("Default")
			Totems[i]:EnableMouse(true)
			Totems[i]:SetWidth(Totems:GetWidth())
			Totems[i]:SetOrientation("VERTICAL")
			
			if (i == 1) then
				Totems[i]:SetPoint("TOPRIGHT", Totems, "TOPRIGHT", 0, 0)
			else
				Totems[i]:SetPoint("TOPRIGHT", Totems[i - 1], "TOPLEFT", -7, 0)
			end
		end
		
		Totems.Override = T.UpdateTotems
		
		self.Totems = Totems
	end
end