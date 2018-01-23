local T, C, L, G = unpack(select(2, ...))

local fontName, fontSize, fontStyle = C.media.pixelfont, 10, "THINOUTLINE"
local blankTex = C.media.blankTex

-- specific elements for monk class.
T.ClassElements["MONK"] = function(self)
	
	-- Stagger
	if C.unitframes.stagger then
		local Stagger = CreateFrame("StatusBar", self:GetName() .. "StaggerBar", self)
		Stagger:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		Stagger:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		Stagger:SetHeight(10)
		Stagger:SetStatusBarTexture(blankTex)
		Stagger:SetBorder("Default")
		
		local value = Stagger:CreateFontString(nil, "OVERLAY")
		value:SetPoint("CENTER", Stagger, "CENTER", 0, 2)
		value:SetJustifyH("CENTER")
		value:SetFont(fontName, fontSize, fontStyle)
		value:SetTextColor(.84,.75,.65)
		
		Stagger.PostUpdate = T.PostUpdateStagger
		
		Stagger.value = value
		self.Stagger = Stagger
	end
	
	-- Statue
	if C.unitframes.totem then
		
		local size = self.Health:GetHeight() + self.Power:GetHeight() + 3
		
		local Statues = CreateFrame("Frame", self:GetName() .. "StatueBar", self)
		Statues:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -7, 0)
		Statues:SetHeight(size)
		Statues:SetWidth(10)
		
		for i = 1, MAX_TOTEMS do
			local Statue = CreateFrame("StatusBar", Statues:GetName() .. i, self)
			Statue:SetHeight(Statues:GetHeight())
			Statue:SetStatusBarTexture(blankTex)
			Statue:SetBorder("Default")
			Statue:EnableMouse(true)
			Statue:SetWidth(Statues:GetWidth())
			Statue:SetOrientation("VERTICAL")
			
			if (i == 1) then
				Statue:SetPoint("TOPRIGHT", Statues, "TOPRIGHT", 0, 0)
			else
				Statue:SetPoint("TOPRIGHT", Statues[i - 1], "TOPLEFT", -7, 0)
			end

			Statues[i] = Statue
		end
		
		Statues.Override = T.UpdateTotems
		
		self.Totems = Statues
	end
	
	-- Harmony Bar
	if C.unitframes.harmonybar then
		local HarmonyBar = CreateFrame("Frame", self:GetName() .. "HarmonyBar", self)
		HarmonyBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
		HarmonyBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		HarmonyBar:SetHeight(10)
		
		local max = 6
		local sizeAscencion, deltaAscencion = T.GetElementSize(self:GetWidth(), max, 7)
		local sizeNone, deltaNone = T.GetElementSize(self:GetWidth(), 5, 7)
		
		for i = 1, max do
			HarmonyBar[i] = CreateFrame("StatusBar", HarmonyBar:GetName() .. i, self)
			HarmonyBar[i]:SetHeight(HarmonyBar:GetHeight())
			HarmonyBar[i]:SetStatusBarTexture(blankTex)
			HarmonyBar[i]:SetBorder("Default")
			
			if (deltaNone > 0 and i < deltaNone) then
				HarmonyBar[i].None = sizeNone + 1
			else
				HarmonyBar[i].None = sizeNone
			end
			
			if (deltaAscencion > 0 and i <= deltaAscencion) then
				HarmonyBar[i].Ascencion = sizeAscencion + 1
				HarmonyBar[i]:SetWidth(sizeAscencion + 1)
			else
				HarmonyBar[i].Ascencion = sizeAscencion
				HarmonyBar[i]:SetWidth(sizeAscencion)
			end
			
			if (i == 1) then
				HarmonyBar[i]:SetPoint("TOPLEFT", HarmonyBar, "TOPLEFT", 0, 0)
			else
				HarmonyBar[i]:SetPoint("TOPLEFT", HarmonyBar[i - 1], "TOPRIGHT", 7, 0)
			end
			
		end
		
		self.HarmonyBar = HarmonyBar
	end
end