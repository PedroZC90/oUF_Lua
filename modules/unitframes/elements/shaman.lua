local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for shaman class.
T.ClassElements["SHAMAN"] = function(self)
	-- Additional Power (Elemental - Maelstrom)
	if C.unitframes.addpower then
		local AddPower = CreateFrame("StatusBar", self:GetName() .. "ShamanMana", self)
		AddPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		AddPower:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		AddPower:SetHeight(3)
		AddPower:SetStatusBarTexture(blankTex)
		AddPower:SetFrameStrata(self.Health:GetFrameStrata())
		AddPower:SetFrameLevel(self.Health:GetFrameLevel())
		AddPower:SetBorder("Default")
		
		AddPower.bg = AddPower:CreateTexture(nil, "BORDER")
		AddPower.bg:SetAllPoints(AddPower)
		AddPower.bg:SetTexture(blankTex)
		AddPower.bg:SetColorTexture(1.,1.,1.,.0)
		
		AddPower.colorClass = false
		AddPower.colorPower = true
		AddPower.bg.multiplier = 0.3
		
		self.AdditionalPower = AddPower
		
		-- Additional Power Prediction
		local altBar = CreateFrame("StatusBar", nil, AddPower)
		altBar:SetReverseFill(true)
		altBar:SetPoint("TOP")
		altBar:SetPoint("BOTTOM")
		altBar:SetPoint("RIGHT", AddPower:GetStatusBarTexture(), "RIGHT", 0, 0)
		altBar:SetWidth(AddPower:GetWidth())
		altBar:SetStatusBarTexture(blankTex)
		altBar:SetStatusBarColor(.0,.0,.0,.7)

		self.PowerPrediction.altBar = altBar
	end
	
	-- Totems
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