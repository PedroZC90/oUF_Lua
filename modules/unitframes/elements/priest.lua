local T, C, L, G = unpack(select(2, ...))

local fontName, fontSize, fontStyle = C.media.pixelfont, 10, "THINOUTLINE"
local blankTex = C.media.blankTex

-- specific elements for priest class.
T.ClassElements["PRIEST"] = function(self)
	
	-- Additional Power (Shadow - Insanity)
	if C.unitframes.addpower then
		local AddPower = CreateFrame("StatusBar", self:GetName() .. "PriestMana", self)
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
	
	-- Weakened Soul
	if C.unitframes.weakenedsoul then
		local ws = CreateFrame("StatusBar", nil, self)
		ws:SetAllPoints(self.Power)
		ws:SetStatusBarTexture(blankTex)
		ws:SetStatusBarColor(.75,.04,.04)
		ws:SetFrameLevel(self.Power:GetFrameLevel() + 1)
		
		self.WeakenedSoul = ws
	end
end