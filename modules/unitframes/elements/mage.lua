local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for mage class.
T.ClassElements["MAGE"] = function(self)
	
	-- Arcane Charges
	if C.unitframes.arcanecharges then
		local ArcaneCharges = CreateFrame("Frame", self:GetName() .. "ArcaneCharges", self)
		ArcaneCharges:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		ArcaneCharges:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		ArcaneCharges:SetHeight(10)
		
		local max = UnitPowerMax("player", SPELL_POWER_ARCANE_CHARGES)
		local size, delta = T.GetElementSize(self:GetWidth(), max, 7)
		
		for i = 1, max do
			ArcaneCharges[i] = CreateFrame("StatusBar", ArcaneCharges:GetName() .. i, self)
			ArcaneCharges[i]:SetHeight(ArcaneCharges:GetHeight())
			ArcaneCharges[i]:SetStatusBarTexture(blankTex)
			ArcaneCharges[i]:SetBorder("Default")
			
			if (delta > 0 and i <= delta) then
				ArcaneCharges[i]:SetWidth(size + 1)
			else
				ArcaneCharges[i]:SetWidth(size)
			end
			
			if (i == 1) then
				ArcaneCharges[i]:SetPoint("TOPLEFT", ArcaneCharges, "TOPLEFT", 0, 0)
			else
				ArcaneCharges[i]:SetPoint("TOPLEFT", ArcaneCharges[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		self.ArcaneCharges = ArcaneCharges
	end
	
	-- Rune of Power
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