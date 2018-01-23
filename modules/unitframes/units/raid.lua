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
-- oUF Raid:
------------------------------------------------------------
T.RaidStyle = function(self, unit)
	
	-- set our own colors
	self.colors = T.UnitColors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	-- backdrop for every units
	self:SetSize(68, 34)
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
	Health.value:SetPoint("CENTER", Health, "CENTER", 0, -7)
	Health.value:SetJustifyH("CENTER")
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
	
	Health.PostUpdate = T.PostUpdateHealthRaid
	
	-- oUF_AuraWatch requires to register self.Health
	self.Health = Health
	
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
	
	Power.frequentUpdates = true
	if C.unitframes.unicolor then
		Power.colorTapping = true
		Power.colorClass = true
		Power.colorReaction = true
		Power.bg:SetVertexColor(1.,1.,1.,.0)
		Power.bg.multiplier = 0.3
	else
		Power.colorPower = true
		Power.colorReaction = true
	end
	
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
	Name:SetPoint("CENTER", Health, "CENTER", 0, 7)
	Name:SetJustifyH("CENTER")
	Name:SetFont(fontName, fontSize, fontStyle)
	self:Tag(Name, "[oUF_Lua:namecolor][oUF_Lua:nameshort]")
	
	-- Raid Debuff Watch
	if C.unitframes.raiddebuffwatch then
		-- AuraWatch (corner and center icon)
		T.CreateAuraWatch(self, unit)
		
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame("Frame", nil, self)
		RaidDebuffs:SetPoint("CENTER", Health, "CENTER", 0, 0)
		RaidDebuffs:SetSize(20, 20)
		RaidDebuffs:SetFrameStrata(Health:GetFrameStrata())
		RaidDebuffs:SetFrameLevel(Health:GetFrameLevel() + 20)
		RaidDebuffs:SetBorder("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "OVERLAY")
		RaidDebuffs.icon:SetAllPoints(RaidDebuffs)
		RaidDebuffs.icon:SetTexCoord(.08,.92,.08,.92)
		
		RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
		RaidDebuffs.cd:SetAllPoints(RaidDebuffs)
		RaidDebuffs.cd:SetHideCountdownNumbers(true)
		
		RaidDebuffs.ShowDispelableDebudd = true
		RaidDebuffs.FilterDispelableDebuff = true
		RaidDebuffs.MatchBySpellName = true
		RaidDebuffs.ShowBossDebuff = true
		RaidDebuffs.BossDebuffPriority = 5
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 1)
		RaidDebuffs.count:SetFont(fontName, fontSize, fontStyle)
		RaidDebuffs.count:SetTextColor(.84,.75,.65)
		
		RaidDebuffs.SetDebuffTypeColor = RaidDebuffs.SetBorderColor
		RaidDebuffs.Debuffs = T.RaidDebuffsTracking
		
		self.RaidDebuffs = RaidDebuffs
	end
	
	-- Weakened Soul
	if (T.myClass == "PRIEST" and C.unitframes.weakenedsoul) then
		local ws = CreateFrame("StatusBar", nil, self)
		ws:SetAllPoints(Power)
		ws:SetStatusBarTexture(blankTex)
		ws:SetStatusBarColor(.75,.04,.04)
		ws:SetFrameLevel(Power:GetFrameLevel() + 1)
		
		self.WeakenedSoul = ws
	end
	
	-- Raid Target
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
    RaidTarget:SetPoint("CENTER", Health, "TOP", 0, 3)
	RaidTarget:SetSize(18, 18)
	RaidTarget:SetTexture(C.media.raidIcons)
	
	-- Ready Check
	local ReadyCheck = Power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetPoint("CENTER", Power, "CENTER", 0, 0)
	ReadyCheck:SetSize(12, 12)
	
	-- Role Icon
	local RoleIcon = Health:CreateTexture(nil, "OVERLAY")
	RoleIcon:SetPoint("CENTER", Health, "CENTER", 0, -9)
	RoleIcon:SetSize(12, 12)
	RoleIcon.Override = T.UpdateRoleIcon
	
	-- Resurrect
	if C.unitframes.showgroupresurrect then
		local Resurrect = Health:CreateTexture(nil, "OVERLAY")
		Resurrect:SetPoint("CENTER", Health, "CENTER", 0, 0)
		Resurrect:SetSize(12, 12)
		self.ResurrectIndicator = Resurrect
	end
	
	-- Threat
	local Threat = Health:CreateTexture(nil, "OVERLAY")
	Threat.Override = T.UpdateThreat
	
	-- Range
	local Range = {
		insideAlpha = 1,
		outsideAlpha = C.unitframes.rangealpha,
	}
	
	self.Power = Power
	self.PowerPrediction = {}
	self.PowerPrediction.mainBar = mainBar
	self.Name = Name
	self.RaidTargetIndicator = RaidTarget
	self.ReadyCheck = ReadyCheck
	self.GroupRoleIndicator = RoleIcon
	self.ThreatIndicator = Threat
	self.Range = Range
	
end