local T, C, L, G = unpack(select(2, ...))

local blankTex = C.media.blankTex

-- specific elements for rogue class.
T.ClassElements["ROGUE"] = function(self)
	
	-- Combo Points
	if C.unitframes.combopoints then
		local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self)
		ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		ComboPoints:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		ComboPoints:SetHeight(10)
		
		local max = 10
		local sizeAnticipation, deltaAnticipation = T.GetElementSize(self:GetWidth(), 10, 7)
		local sizeDepper, deltaDepper = T.GetElementSize(self:GetWidth(), 6, 7)
		local size, delta = T.GetElementSize(self:GetWidth(), 5, 7)
		
		for i = 1, max do
			ComboPoints[i] = CreateFrame("StatusBar", ComboPoints:GetName() .. i, self)
			ComboPoints[i]:SetHeight(ComboPoints:GetHeight())
			ComboPoints[i]:SetStatusBarTexture(blankTex)
			ComboPoints[i]:SetBorder("Default")
			ComboPoints[i]:SetWidth(30)
			
			-- max combo = 10
			if (deltaAnticipation > 0 and i <= deltaAnticipation) then
				ComboPoints[i].Anticipation = sizeAnticipation + 1
			else
				ComboPoints[i].Anticipation = sizeAnticipation
			end
			
			-- max combo = 6
			if (deltaDepper > 0 and i <= deltaDepper) then
				ComboPoints[i].Depper = sizeDepper + 1
			else
				ComboPoints[i].Depper = sizeDepper
			end
			
			-- max combo = 5
			if (delta > 0 and i <= delta) then
				ComboPoints[i].None = size + 1
			else
				ComboPoints[i].None = size
			end
			
			if (i == 1) then
				ComboPoints[i]:SetPoint("TOPLEFT", ComboPoints, "TOPLEFT", 0, 0)
			else
				ComboPoints[i]:SetPoint("TOPLEFT", ComboPoints[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		self.ComboPoints = ComboPoints
	end
end