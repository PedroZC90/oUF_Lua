local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Lua was unable to locate oUF install.")

local T, C, L, G = unpack(select(2, ...))

if not C.nameplates.enable then return end

local fontName, fontSize, fontStyle = C.media.pixelfont, 10, "THINOUTLINE"
local blankTex = C.media.blankTex
local normTex = C.media.normTex
local glowTex = C.media.glowTex

local inset = 1
local backdrop = {
	bgFile = blankTex,
	insets = { top = -inset, bottom = -inset, left = -inset, right = -inset },
}

local scaleH = 768 / T.ScreenHeight -- 0.71

local UpdateNameplateCVars = {
	-- important, strongly recommend to set these to 1
    nameplateGlobalScale = scaleH,
    NamePlateHorizontalScale = scaleH,
    NamePlateVerticalScale = 1,
    -- optional, you may use any values
    nameplateLargerScale = 1,
    nameplateMaxScale = 1,
    nameplateMinScale = 1,
    nameplateSelectedScale = 1,
    nameplateSelfScale = .71,
	-- disable player/friendly nameplates
	nameplateShowFriends  = 0,
	nameplateShowSelf = 0,
}

local NameplateStyle = function(self)
	
	-- backdrop for every units
	self:SetSize(182, 12)
	self:SetPoint("CENTER", 0, 0)
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
	Health.colorClass = true
	Health.colorReaction = true
	
	Health.PostUpdate = T.PostUpdateHealthNameplates
	
	-- Name
	local Name = Health:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOM", Health, "TOP", 0, 7)
	Name:SetJustifyH("CENTER")
	Name:SetFont(fontName, fontSize, fontStyle)
	self:Tag(Name, "[oUF_Lua:namecolor][oUF_Lua:namelong] [oUF_Lua:diffcolor][level] [classification]")
	
	-- Castbar:
	if C.nameplates.castbar then
		local Castbar = CreateFrame("StatusBar", nil, self)
		Castbar:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -7)
		Castbar:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -7)
		Castbar:SetHeight(self:GetHeight())
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
	
	if C.nameplates.debuffs then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 22)
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.size = 20
		Debuffs.spacing = 7
		Debuffs.num = 7
		Debuffs:SetWidth(Debuffs.num * Debuffs.size + (Debuffs.num - 1) * Debuffs.spacing)
		Debuffs:SetHeight(Debuffs.size)
		
		-- an option to show only our debuffs on target
		Debuffs.onlyShowPlayer = true
		Debuffs.PostCreateIcon = T.PostCreateAura
		Debuffs.PostUpdateIcon = T.PostUpdateAura
		
		self.Debuffs = Debuffs
	end
	
	-- Raid Target
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
    RaidTarget:SetPoint("RIGHT", Health, "LEFT", -10, 0)
	RaidTarget:SetSize(30, 30)
	
	self.Health = Health
	self.Name = Name
	self.RaidTargetIndicator = RaidTarget
	
end

oUF:RegisterStyle("oUF_Nameplate", NameplateStyle)
oUF:SpawnNamePlates("oUF_Nameplate", nil, UpdateNameplateCVars)