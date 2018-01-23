local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for deathknight class.
T.ClassElements["DEATHKNIGHT"] = function(self)
	
	-- Runes
	if C.unitframes.runes then
		local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self)
		Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		Runes:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		Runes:SetHeight(10)
		
		local max = UnitPowerMax("player", SPELL_POWER_RUNES)
		local size, delta = T.GetElementSize(self:GetWidth(), max, 7)
		
		for i = 1, max do
			Runes[i] = CreateFrame("StatusBar", Runes:GetName() .. i, self)
			Runes[i]:SetHeight(Runes:GetHeight())
			Runes[i]:SetStatusBarTexture(blankTex)
			Runes[i]:SetBorder("Default")
			
			if (delta > 0 and i < delta) then
				Runes[i]:SetWidth(size + 1)
			else
				Runes[i]:SetWidth(size)
			end
			
			if (i == 1) then
				Runes[i]:SetPoint("TOPLEFT", Runes, "TOPLEFT", 0, 0)
			else
				Runes[i]:SetPoint("TOPLEFT", Runes[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		Runes.colorSpec = true
		
		self.Runes = Runes
	end
end