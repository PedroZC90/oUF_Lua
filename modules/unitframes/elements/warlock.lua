local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for warlock class.
T.ClassElements["WARLOCK"] = function(self)
	
	-- Soul Shards
	if C.unitframes.soulshards then
		local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self)
		SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		SoulShards:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		SoulShards:SetHeight(10)
		
		local max = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)
		local size, delta = T.GetElementSize(self:GetWidth(), max, 7)
		
		for i = 1, max do
			SoulShards[i] = CreateFrame("StatusBar", SoulShards:GetName() .. i, self)
			SoulShards[i]:SetHeight(SoulShards:GetHeight())
			SoulShards[i]:SetStatusBarTexture(blankTex)
			SoulShards[i]:SetBorder("Default")
			
			if (delta > 0 and i <= delta) then
				SoulShards[i]:SetWidth(size + 1)
			else
				SoulShards[i]:SetWidth(size)
			end
			
			if (i == 1) then
				SoulShards[i]:SetPoint("TOPLEFT", SoulShards, "TOPLEFT", 0, 0)
			else
				SoulShards[i]:SetPoint("TOPLEFT", SoulShards[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		self.ClassPower = SoulShards
	end
end