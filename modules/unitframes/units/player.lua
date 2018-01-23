local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Lua is unable to locate oUF install.")

local T, C, L, G = unpack(select(2, ...))

if not C.unitframes.enable then return end

local fontName, fontSize, fontStyle = C.media.pixelfont, 10, "THINOUTLINE"
local blankTex = C.media.blankTex
local normTex = C.media.normTex
local glowTex = C.media.glowTex

local inset = 1
local backdrop = {
	bgFile = blankTex,
	insets = { top = -inset, bottom = -inset, left = -inset, right = -inset },
}

------------------------------------------------------------
-- oUF Player:
------------------------------------------------------------
T.PlayerStyle = function(self, unit)
	
	-- set our own colors
	self.colors = T.UnitColors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	-- backdrop for every units
	self:SetSize(254, 21)
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(.0,.0,.0,.0)
	self:SetBackdropBorderColor(.0,.0,.0,.0)
	
	-- Health
	local Health = CreateFrame("StatusBar", self:GetName() .. "HealthBar", self)
	Health:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	Health:SetSize(self:GetSize())
	Health:SetStatusBarTexture(blankTex)
	Health:SetBorder("Default")
	
	Health.bg = Health:CreateTexture(nil, "BORDER")
	Health.bg:SetAllPoints(Health)
	Health.bg:SetTexture(blankTex)
	Health.bg:SetColorTexture(1.,1.,1.,.0)
	
	Health.value = Health:CreateFontString(nil, "OVERLAY")
	Health.value:SetPoint("RIGHT", Health, "RIGHT", -5, 1)
	Health.value:SetJustifyH("RIGHT")
	Health.value:SetFont(fontName, fontSize, fontStyle)
	
	Health.frequentUpdates = true
	if C.unitframes.unicolor then
		Health.colorTapping = false
		Health.colorDisconnected = false
		Health.colorClass = false
		Health:SetStatusBarColor(unpack(C.media.healthcolor))
		Health.bg:SetVertexColor(1.,1.,1.,.0)
	else
		Health.colorTapping = true
		Health.colorDisconnected = true
		Health.colorClass = true
		Health.colorReaction = true
		Health.colorSmooth = C.unitframes.smooth
	end
	
	Health.PostUpdate = T.PostUpdateHealth
	
	-- Health Prediction
	if C.unitframes.healcomm then
		local myBar = CreateFrame("StatusBar", nil, Health)
		myBar:SetPoint("TOPLEFT", Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		myBar:SetPoint("BOTTOMLEFT", Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		myBar:SetWidth(self:GetWidth())
		myBar:SetStatusBarTexture(blankTex)
		myBar:SetStatusBarColor(.31,.45,.63,.5)
		myBar:SetFrameStrata(self:GetFrameStrata())
		
		local otherBar = CreateFrame("StatusBar", nil, Health)
		otherBar:SetPoint("TOPLEFT", myBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		otherBar:SetPoint("BOTTOMLEFT", myBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		otherBar:SetWidth(self:GetWidth())
		otherBar:SetStatusBarTexture(blankTex)
		otherBar:SetStatusBarColor(.31,.45,.63,.5)
		otherBar:SetFrameStrata(self:GetFrameStrata())
		
		local absorbBar = CreateFrame("StatusBar", nil, Health)
		absorbBar:SetPoint("TOPLEFT", otherBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		absorbBar:SetPoint("BOTTOMLEFT", otherBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		absorbBar:SetWidth(self:GetWidth())
		absorbBar:SetStatusBarTexture(blankTex)
		absorbBar:SetStatusBarColor(.31,.45,.63,.5)
		absorbBar:SetFrameStrata(self:GetFrameStrata())
		
		local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
		healAbsorbBar:SetPoint("TOPLEFT", Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		healAbsorbBar:SetPoint("BOTTOMLEFT", Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		healAbsorbBar:SetWidth(self:GetWidth())
		healAbsorbBar:SetStatusBarTexture(blankTex)
		healAbsorbBar:SetStatusBarColor(.31,.45,.63,.5)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameStrata(self:GetFrameStrata())
		
		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			maxOverflow = 1.0,
			frequentUpdates = true,
		}
	end
	
	-- Power
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -3)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0. -3)
	Power:SetHeight(3)
	Power:SetStatusBarTexture(blankTex)
	Power:SetFrameStrata(Health:GetFrameStrata())
	Power:SetFrameLevel(Health:GetFrameLevel())
	Power:SetBorder("Default")
	
	Power.bg = Power:CreateTexture(nil, "BORDER")
	Power.bg:SetAllPoints(Power)
	Power.bg:SetTexture(blankTex)
	Power.bg:SetColorTexture(1.,1.,1.,.0)
	
	Power.value = Power:CreateFontString(nil, "OVERLAY")
	Power.value:SetPoint("LEFT", Health, "LEFT", 5, 1)
	Power.value:SetJustifyH("LEFT")
	Power.value:SetFont(fontName, fontSize, fontStyle)
	
	Power.frequentUpdates = true
	if C.unitframes.unicolor then
		Power.colorTapping = true
		Power.colorClass = not C.unitframes.colorpower
		Power.colorPower = C.unitframes.colorpower
		Power.colorReaction = true
		Power.bg:SetVertexColor(1.,1.,1.,.0)
		Power.bg.multiplier = 0.3
	else
		Power.colorPower = true
		Power.colorReaction = true
	end
	
	Power.PostUpdate = T.PostUpdatePower
	
	-- Power Prediction
	local mainBar = CreateFrame("StatusBar", nil, Power)
	mainBar:SetReverseFill(true)
	mainBar:SetPoint("TOP")
	mainBar:SetPoint("BOTTOM")
	mainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT", 0, 0)
	mainBar:SetWidth(Power:GetWidth())
	mainBar:SetStatusBarTexture(blankTex)
	mainBar:SetStatusBarColor(.0,.0,.0,.7)
	
	-- Name
	local Name = Health:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("CENTER", Health, "CENTER", 0, 1)
	Name:SetJustifyH("CENTER")
	Name:SetFont(fontName, fontSize, fontStyle)
	self:Tag(Name, "[oUF_Lua:namecolor][oUF_Lua:namelong]")
	
	-- Castbar:
	if C.unitframes.castbar then
		local Castbar = CreateFrame("StatusBar", nil, self)
		Castbar:SetPoint("CENTER", UIParent, "CENTER", 0, -270)
		Castbar:SetSize(350, 20)
		Castbar:SetStatusBarTexture(blankTex)
		Castbar:SetStatusBarColor(.31,.45,.63,.5)
		Castbar:SetBorder("Default")

		Castbar.bg = Castbar:CreateTexture(nil, "BACKGROUND")
		Castbar.bg:SetAllPoints()
		Castbar.bg:SetTexture(blankTex)
		Castbar.bg:SetColorTexture(1.,1.,1.,.0)
		
		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
		Castbar.Spark:SetSize(1, Castbar:GetHeight())
		Castbar.Spark:SetTexture(glowTex)
		Castbar.Spark:SetColorTexture(.31,.45,.63)
		Castbar.Spark:SetBlendMode("ADD")

		Castbar.Time = Castbar:CreateFontString(nil, "OVERLAY")
		Castbar.Time:SetPoint("RIGHT", Castbar, "RIGHT", -5, 1)
		Castbar.Time:SetJustifyH("RIGHT")
		Castbar.Time:SetFont(fontName, fontSize, fontStyle)
		Castbar.Time:SetTextColor(.84,.75,.65)

		Castbar.Text = Castbar:CreateFontString(nil, "OVERLAY")
		Castbar.Text:SetPoint("LEFT", Castbar, "LEFT", 5, 1)
		Castbar.Text:SetJustifyH("LEFT")
		Castbar.Text:SetFont(fontName, fontSize, fontStyle)
		Castbar.Text:SetTextColor(.84,.75,.65)
		
		if C.unitframes.castbaricon then
			Castbar.Button = CreateFrame("Frame", nil, Castbar)
			Castbar.Button:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -7, 0)
			Castbar.Button:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
			Castbar.Button:SetBorder()
			
			Castbar.Icon = Castbar:CreateTexture(nil, "ARTWORK")
			Castbar.Icon:SetPoint("TOPLEFT", Castbar.Button, "TOPLEFT", 0, 0)
			Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar.Button, "BOTTOMRIGHT", 0, 0)
			Castbar.Icon:SetTexCoord(.08,.92,.08,.92)
		end
		
		if C.unitframes.castbarlatency then
			Castbar.SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
			Castbar.SafeZone:SetTexture(blankTex)
			Castbar.SafeZone:SetVertexColor(.69,.31,.31,.75)
		end
		
		Castbar.CustomTimeText = T.CustomCastTimeText
		Castbar.CustomDelayText = T.CustomCastDelayText
		Castbar.PostCastStart = T.PostUpdateCast
		Castbar.PostChannelStart = T.PostUpdateChannel
		
		self.Castbar = Castbar
	end
	
	-- Alternative Bar
	if C.unitframes.altpower then
		local AltPower = CreateFrame("StatusBar", nil, self)
		AltPower:SetPoint("TOP", UIParent, "TOP", 0, -10)
		AltPower:SetSize(350, 20)
		AltPower:SetStatusBarTexture(blankTex)
		AltPower:SetBorder("Default")
		
		AltPower.Name = AltPower:CreateFontString(nil, "OVERLAY")
		AltPower.Name:SetPoint("LEFT", AltPower, "LEFT", 5, 1)
		AltPower.Name:SetJustifyH("LEFT")
		AltPower.Name:SetFont(fontName, fontSize, fontStyle)
		AltPower.Name:SetTextColor(.84,.75,.65)
		
		AltPower.Info = AltPower:CreateFontString(nil, "OVERLAY")
		AltPower.Info:SetPoint("RIGHT", AltPower, "RIGHT", -5, 1)
		AltPower.Info:SetJustifyH("RIGHT")
		AltPower.Info:SetFont(fontName, fontSize, fontStyle)
		AltPower.Info:SetTextColor(.84,.75,.65)
		
		AltPower.PostUpdate = T.PostUpdateAltPower
		
		self.AlternativePower = AltPower
	end
	
	-- Experience Bar
	if (T.myLevel ~= MAX_PLAYER_LEVEL) then
		local Exp = CreateFrame("StatusBar", self:GetName() .. "_ExpBar", self)
		Exp:SetPoint("TOP", UIParent, "TOP", 0, -10)
		Exp:SetSize(350, 10)
		Exp:SetStatusBarTexture(blankTex)
		Exp:SetBorder("Default")
		Exp:EnableMouse(true)
		
		local Rested = CreateFrame("StatusBar", nil, Exp)
		Rested:SetAllPoints(Exp)
		Rested:SetStatusBarTexture(blankTex)
		Rested:SetStatusBarColor(1.,.0,1.,.2)
		
		Exp.bg = Rested:CreateTexture(nil, "BACKGROUND")
		Exp.bg:SetAllPoints(Exp)
		Exp.bg:SetTexture(blankTex)
		Exp.bg:SetColorTexture(1.,1.,1.,.0)
		
		local Info = Exp:CreateFontString(nil, "OVERLAY")
		Info:SetPoint("CENTER", Exp, "CENTER", 0, 1)
		Info:SetFont(fontName, fontSize, fontStyle)
		Info:SetTextColor(.84,.75,.65)
		self:Tag(Info, '([experience:per]%) [experience:cur] / [experience:max] - [experience:perrested]%')
		
		-- options
		Exp.inAlpha = 1
		Exp.outAlpha = 0
		
		-- update bar color.
		Exp.OverrideUpdateColor = T.UpdateExpColor
		
		Exp.Rested = Rested
		self.Experience = Exp
	end
	
	-- Reputation Bar
	if (T.myLevel == MAX_PLAYER_LEVEL) then
		local Rep = CreateFrame("StatusBar", self:GetName() .. "_RepBar", self)
		Rep:SetPoint("TOP", UIParent, "TOP", 0, -10)
		Rep:SetSize(350, 10)
		Rep:SetStatusBarTexture(blankTex)
		Rep:SetBorder("Default")
		Rep:EnableMouse(true)
		
		Rep.bg = Rep:CreateTexture(nil, "BACKGROUND")
		Rep.bg:SetAllPoints(Rep)
		Rep.bg:SetTexture(blankTex)
		Rep.bg:SetColorTexture(1.,1.,1.,.0)

		local Info = Rep:CreateFontString(nil, "OVERLAY")
		Info:SetPoint("CENTER", Rep, "CENTER", 0, 1)
		Info:SetFont(fontName, fontSize, fontStyle)
		Info:SetTextColor(.84,.75,.65)
		self:Tag(Info, '[reputation:faction] [reputation:cur] / [reputation:max]')
		
		-- options
		Rep.colorStanding = true
		Rep.inAlpha = 1
		Rep.outAlpha = 0
		
		self.Reputation = Rep
	end
	
	-- Raid Target
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
    RaidTarget:SetPoint("CENTER", Health, "TOP", 0, 3)
	RaidTarget:SetSize(18, 18)
	RaidTarget:SetTexture(C.media.raidIcons)
	
	-- Combat Indicator
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetPoint("CENTER", Health, "TOPLEFT", -1	, 3)
	Combat:SetSize(18, 18)
	Combat:SetVertexColor(.69,.31,.31)
	
	-- Master Looter
	local MasterLooter = Health:CreateTexture(nil, "OVERLAY")
	MasterLooter:SetPoint("CENTER", Health, "TOPRIGHT", -1, 3)
	MasterLooter:SetSize(18, 18)
	
	self.Health = Health
	self.Power = Power
	self.PowerPrediction = {}
	self.PowerPrediction.mainBar = mainBar
	self.Name = Name
	self.RaidTargetIndicator = RaidTarget
	self.CombatIndicator = Combat
	self.MasterLooterInficator = MasterLooter
	
	-- class features
	T.ClassElements[T.myClass](self)
end