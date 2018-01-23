local T, C, L, G = unpack(select(2, ...))

-- return unit status (offline, dead, ghost)
local GetUnitStatus = function(unit)
	
	if not UnitIsConnected(unit) then
		return L.unit_OFFLINE
	elseif UnitIsDead(unit) then
		return L.unit_DEAD
	elseif UnitIsGhost(unit) then
		return L.unit_GHOST
	else
		return false
	end
end

-- calculate an integer size for elements like chi/runes/combo-points
-- to perfectly fit a frame width.
-- equation: width = number * size + (number - 1) * spacing
T.GetElementSize = function(width, number, spacing)
	-- calculate size for n equal elements
	local size = (width - (number - 1) * spacing) / number
	-- calculate error, delta = (size - (INT)size) * number
	-- delta goes from 0 to 1, if n = 1 then we need one more element to fit
	local delta = (size - math.floor(size)) * number
	return math.floor(size), delta
end

------------------------------------------------------------
-- oUF Functions:
------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Lua is unable to locate oUF install.")

------------------------------------------------------------
-- Health
------------------------------------------------------------

-- post update health info value
T.PostUpdateHealth = function(self, unit, cur, max)
	local status = GetUnitStatus(unit)
	
	if (status) then
		self.value:SetFormattedText("|cffD7BEA5%s|r", status)
	else
		local r, g, b
		if (cur ~= max) then
			r, g, b = T.RGBColorGradient(cur, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if ((unit == "targettarget") or (unit == "focus") or (unit == "focustarget") or (unit == "pet")) then
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, T.ShortValue(cur))
			elseif (unit and unit:find("arena%d")) then
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, T.ShortValue(cur))
			elseif (unit and unit:find("boss%d")) then
				self.value:SetFormattedText("|cffAF4F4F%s|r |cffBFBFBF-|r |cff%02x%02x%02x%.1f%%|r", T.ShortValue(cur), r * 255, g * 255, b * 255, 100 * (cur / max))
			else
				if C.unitframes.showtotalhpmp then
					self.value:SetFormattedText("|cffAF4F4F%s|r |cffBFBFBF|||r |cff%02x%02x%02x%s|r", T.ShortValue(cur), r * 255, g * 255, b * 255, T.ShortValue(max))
				else
					self.value:SetFormattedText("|cffAF4F4F%s|r |cffBFBFBF-|r |cff%02x%02x%02x%.1f%%|r", T.ShortValue(cur), r * 255, g * 255, b * 255, 100 * (cur / max))
				end
			end
		else
			r, g, b = 0.33, 0.59, 0.33
			if (unit == "player" or unit == "target") then
				self.value:SetFormattedText("|cff%02x%02x%02x%d|r", r * 255, g * 255, b * 255, max)
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, T.ShortValue(max))
			end
		end
	end
end

-- update health info value for raid unit.
T.PostUpdateHealthRaid = function(self, unit, cur, max)
	local status = GetUnitStatus(unit)
	
	if (status) then
		self.value:SetFormattedText("|cffD7BEA5%s|r", status)
	else
		local r, g, b
		if (cur ~= max) then
			r, g, b = T.RGBColorGradient(cur, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			self.value:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, T.ShortValue(max - cur))
		else
			self.value:SetText("")
		end
	end
end

------------------------------------------------------------
-- Power
------------------------------------------------------------

-- move target name, hiding power value when not in pvp.
local UpdateNameAnchor = function(self)
	self.Name:ClearAllPoints()
	if (self.Power.value:GetText() and UnitIsEnemy("player", "target") and C.unitframes.targetpowerpvponly) 
		or (self.Power.value:GetText() and not C.unitframes.targetpowerpvponly) then
		self.Name:SetPoint("CENTER", self.Health, "CENTER", 0, 1)
		self.Name:SetJustifyH("CENTER")
	else
		self.Power.value:SetAlpha(0)
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 5, 1)
		self.Name:SetJustifyH("LEFT")
	end
end

-- post update power info value.
T.PostUpdatePower = function(self, unit, cur, min, max)
	local parent = self:GetParent()
	local pType, pToken = UnitPowerType(unit)
	local color = parent.colors.power[pToken]
	
	if (color) then
		self.value:SetTextColor(color[1], color[2], color[3])
	end
	
	if ((not UnitIsPlayer(unit)) and (not GetUnitStatus(unit)) or (not UnitPlayerControlled(unit))) then
		self.value:SetText("")
	else
		if (cur ~= max) then
			if (pType == 0) then
				if ((unit == "targettarget") or (unit == "focus") or (unit == "focustarget") or (unit == "pet")) then
					self.value:SetText(T.ShortValue(cur))
				elseif (unit and unit:find("arena%d")) then
					self.value:SetText(T.ShortValue(cur))
				elseif (unit and unit:find("boss%d")) then
					self.value:SetFormattedText("%.1f%% |cffBFBFBF-|r %s", 100 * (cur / max), T.ShortValue(cur))
				else
					if C.unitframes.showtotalhpmp then
						self.value:SetFormattedText("%s |cffBFBFBF|||r %s", T.ShortValue(max), T.ShortValue(cur))
					else
						self.value:SetFormattedText("%.1f%% |cffBFBFBF-|r %s", 100 * (cur / max), T.ShortValue(cur))
					end
				end
			else
				self.value:SetText(T.ShortValue(cur))
			end
		else
			if (unit == "player" or unit == "target") then
				self.value:SetText(max)
			else
				self.value:SetText(T.ShortValue(max))
			end
		end
	end
	if (parent.Name and unit == "target") then
		-- if target isn't a player, hide power value and place name to the left.
		UpdateNameAnchor(parent)
	end
end

------------------------------------------------------------
-- Castbar
------------------------------------------------------------

-- display casting time.
T.CustomCastTimeText = function(self, duration)
	self.Time:SetFormattedText("%.1f / %.1f", self.channeling and duration or self.max - duration, self.max)
end

-- display casting delay time.
T.CustomCastDelayText = function(self, duration)
	self.Time:SetFormattedText("%.1f / %.1f |cffff0000%s%.1f|r", self.channeling and duration or self.max - duration, self.max, self.channeling and "-" or "+", self.delay)
end

-- change castbar color if it's a interruptible spell.
local checkInterrupt = function(self, unit)
	if (unit == "vehicle") then unit = "player" end
	
	if (self.notInterruptible and UnitCanAttack("player", unit)) then
		self:SetStatusBarColor(.69, .31, .31, .5)
	else
		self:SetStatusBarColor(.31, .45, .63, .5)
	end
end

-- update castbar checking if spell is interruptible.
T.PostUpdateCast = function(self, unit, name, castID, spellID)
	checkInterrupt(self, unit)
end

-- update castbar checking if channeling is interruptible.
T.PostUpdateChannel = function(self, unit, name, spellID)
	checkInterrupt(self, unit)
end

------------------------------------------------------------
-- Auras
------------------------------------------------------------

-- create a timer on a buff or debuff.
local UpdateAuraTimer = function(self, elapsed)
	-- self.expiration: time at which the aura will expire.
	-- self.elapsed: time elapsed since the aura were applied.
	-- GetTime(): current time.
	if (self.expiration) then
		self.elapsed = (self.elapsed or 0) + elapsed
		if (self.elapsed >= 0.1) then
			if (not self.first) then
				self.expiration = self.expiration - self.elapsed
			else
				self.expiration = self.expiration - GetTime()
				self.first = false
			end
			
			if (self.expiration > 0) then
				local time = T.FormatTime(self.expiration)
				self.remaining:SetText(time)
				if (self.expiration <= 5) then
					self.remaining:SetTextColor(.99,.31,.31)
				else
					self.remaining:SetTextColor(1.,1.,1.)
				end
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

-- create a skin for all unitframes auras.
T.PostCreateAura = function(self, button)
	-- button skin
	button:SetBorder("Default")
	
	-- cooldown
	button.cd:SetReverse(true)
	button.cd:SetHideCountdownNumbers(true)
	button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	
	-- artwork
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.icon:SetTexCoord(.08,.92,.08,.92)
	button.icon:SetDrawLayer("ARTWORK")
	
	-- count
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, 2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C.media.pixelfont, 10, "THINOUTLINE")
	button.count:SetTextColor(.84,.75,.65)
	
	-- create a parent for aura string so that they appear over the cooldown widget
	local overlayFrame = CreateFrame("Frame", nil, button)
	overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 2)
	
	-- make the buffs/debuffs counter appear above the icon
	button.count:SetParent(overlayFrame)
	--button.count:ClearAllPoints()
	
	-- remaining time to aura expire
	button.remaining = button:CreateFontString(nil, "OVERLAY")
	button.remaining:SetPoint("CENTER", button, "CENTER", 2, 1)
	button.remaining:SetJustifyH("CENTER")
	button.remaining:SetFont(C.media.pixelfont, 10, "OUTLINE")
	button.remaining:SetTextColor(1.,1.,1.)
	button.remaining:SetParent(overlayFrame)
end

-- post update auras to add a timer
T.PostUpdateAura = function(self, unit, button, index)
	local name, _, _, _, auraType, duration, expirationTime, unitCaster, isStealable, _, spellID = UnitAura(unit, index, button.filter)
	
	if (button) then
		if (button.filter == "HARMFUL") then
			-- debuffs caster ~= player are desaturated
			-- player debuffs have border color based on auraType
			if ((not UnitIsFriend("player", unit)) and (button.caster ~= "player") and (button.caster ~= "vehicle")) then
				button.icon:SetDesaturated(true)
				button:SetBorderColor(unpack(C.media.bordercolor))
			else
				local color = DebuffTypeColor[auraType or "none"]
				button.icon:SetDesaturated(false)
				button:SetBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			end
		else
			-- stealable enemy buffs are colored based on auraType.
			if (isStealable or auraType == "Magic") and (not UnitIsFriend("player", unit)) then
				local color = DebuffTypeColor[auraType or "none"]
				button:SetBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			else
				button:SetBorderColor(unpack(C.media.bordercolor))
			end
			button.icon:SetDesaturated(false)
		end
	end
	
	if (duration and (duration > 0)) then
		button.remaining:Show()
	else
		button.remaining:Hide()
	end
	
	button.duration = duration
	button.expiration = expirationTime
	button.first = true
	button:SetScript("OnUpdate", UpdateAuraTimer)
end

------------------------------------------------------------
-- Alternative Power
------------------------------------------------------------

-- post update alternative power bar
T.PostUpdateAltPower = function(self, unit, cur, min, max)
	if (not cur) or (not max) then return end
	
	local r, g, b = T.RGBColorGradient(cur, max, .0, .8, .0, .8, .8, .0, .8, .0, .0)
	self:SetStatusBarColor(r, g, b)
	
	if (self.Info) then
		if (cur ~= max) then
			self.Info:SetFormattedText("%s / %s", T.ShortValue(cur), T.ShortValue(max))
		else
			self.Info:SetFormattedText("%s", T.ShortValue(max))
		end
	end
	
	if (self.Name and self.powerName) then
		self.Name:SetFormattedText("%s", self.powerName)
	end
	
	-- NEED TO BE TESTED
	self.IsEnable = true
end

------------------------------------------------------------
-- Indicators
------------------------------------------------------------

-- update threat indicator.
T.UpdateThreat = function(self, event, unit)
	if (unit ~= self.unit) then return end
	
	local threat
	if UnitExists(unit) then
		threat = UnitThreatSituation(unit)
	end
	
	if (threat and threat > 2) then
		local r, g, b = .69, .31, .31 --GetThreatStatusColor(threat)
		self.Health:SetBorderColor(r, g, b)
		self.Power:SetBorderColor(r, g, b)
	else
		self.Health:SetBorderColor(unpack(C.media.bordercolor))
		self.Power:SetBorderColor(unpack(C.media.bordercolor))
	end
end

-- update raid roles textures.
T.UpdateRoleIcon = function(self, role)
	local element = self.GroupRoleIndicator
	local role = UnitGroupRolesAssigned(self.unit)
	
	if (role == "TANK") then
		element:SetTexture(C.media.roleTANK)
		element:Show()
	elseif (role == "HEALER") then
		element:SetTexture(C.media.roleHEALER)
		element:Show()
	-- elseif (role == "DAMAGER") then
		-- element:SetTexture(C.media.roleDPS)
		-- element:Show()
	else
		self.GroupRoleIndicator:Hide()
	end
end

------------------------------------------------------------
-- Totems
------------------------------------------------------------

-- update totem timer
local UpdateTotemTimer = function(self, elapsed)
	self.expiration = self.expiration - elapsed
	if (self.expiration > 0) then
		self:SetValue(self.expiration)
	else
		self:SetValue(0)
		self:SetScript("OnUpdate", nil)
	end
end

-- override totems update function
T.UpdateTotems = function(self, event, slot)
	local element = self.Totems
	if (slot > #element) then return end
	
	if(element.PreUpdate) then element:PreUpdate(slot) end
	
	local totem = element[slot]
	local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot)
	local r, g, b = unpack(self.colors.class[T.myClass])
	
	if (haveTotem) then
		totem.name = name
		totem.duration = duration
		totem.expiration = (startTime + duration) - GetTime()
		
		totem:SetMinMaxValues(0, duration)
		totem:SetScript("OnUpdate", UpdateTotemTimer)
		totem:SetStatusBarColor(r, g, b, 1.)
		
		if (totem.Icon) then
			totem.Icon:SetTexture(icon)
			totem.Icon:SetDesaturated(true)
		end
		
		totem:Show()
	else
		totem:SetScript("OnUpdate", function() return end)
		totem:Hide()
	end
	
	if(element.PostUpdate) then
		return element:PostUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

------------------------------------------------------------
-- Stagger
------------------------------------------------------------

-- post update stagger bar
T.PostUpdateStagger = function(self, cur, max)
	local perc = cur / max
	local colors = T.UnitColors.power[BREWMASTER_POWER_BAR_NAME or "STAGGER"]
	
	local r, g, b
	if (perc >= STAGGER_RED_TRANSITION) then
		r, g, b = unpack(colors[STAGGER_RED_INDEX or 3])	-- red
	elseif (perc > STAGGER_YELLOW_TRANSITION) then
		r, g, b = unpack(colors[STAGGER_YELLOW_INDEX or 2])	-- yellow
	else
		r, g, b = unpack(colors[STAGGER_GREEN_INDEX or 1])	-- green
	end
	
	self:SetStatusBarColor(r, g, b)
	self.value:SetFormattedText("(%.1f%%) %s / %s", 100 * (cur / max), T.ShortValue(cur), T.ShortValue(max))
	
	if (cur ~= 0) then
		self:Show()
	else
		self:Hide()
	end
end

------------------------------------------------------------
-- oUF_Experience
------------------------------------------------------------

-- override experience bar color.
T.UpdateExpColor = function(self, showHonor)
	self:SetStatusBarColor(.0,.40,1.,.5)
	self.Rested:SetStatusBarColor(1.,.0,1.,.2)
end

------------------------------------------------------------
-- oUF_AuraWatch
------------------------------------------------------------

-- position of indicators
local countOffsets = {
	TOPLEFT = { 6, 1 },
	TOPRIGHT = { -6, 1 },
	BOTTOMLEFT = { 6, 1 },
	BOTTOMRIGHT = { -6, 1 },
	LEFT = { 6, 1 },
	RIGHT = { -6, 1 },
	TOP = { 0, 0 },
	BOTTOM = { 0, 0 },
}

-- create aura icon
local CreateAuraWatchIcon = function(self, icon)
	icon:SetTemplate("Default")
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(.08,.92,.08,.92)
	icon.icon:SetDrawLayer("ARTWORK")
	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end
	icon.overlay:SetTexture()
end

-- create aura watch
T.CreateAuraWatch = function(self, unit)
	local auras = CreateFrame("Frame", self:GetName() .. "AuraWatch", self)
	auras:SetPoint("TOPLEFT", self.Health, 2, -2)
	auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.icons = {}
	auras.PostCreateIcon = CreateAuraWatchIcon
	auras.strictMatching = true
	
	if (not C.unitframes.auratimer) then
		auras.hideCooldown = true
	end
	
	local buffs = {}
	
	if (T.AuraWatchBuffs["ALL"]) then
		for key, value in pairs(T.AuraWatchBuffs["ALL"]) do
			tinsert(buffs, value)
		end
	end
	
	if (T.AuraWatchBuffs[T.myClass]) then
		for key, value in pairs(T.AuraWatchBuffs[T.myClass]) do
			tinsert(buffs, value)
		end
	end
	
	-- corner buffs
	if (buffs) then
		for key, spell in pairs(buffs) do
			local icon = CreateFrame("Frame", nil, auras)
			icon.spellID = spell[1]
			icon.anyUnit = spell[4]
			icon:SetSize(6, 6)
			icon:SetPoint(spell[2], 0, 0)
			
			icon.tex = icon:CreateTexture(nil, "OVERLAY")
			icon.tex:SetAllPoints(icon)
			icon.tex:SetTexture(C.media.blankTex)
			
			if (spell[3]) then
				icon.tex:SetVertexColor(unpack(spell[3]))
			else
				icon.tex:SetVertexColor(.8,.8,.8)
			end
			
			icon.count = icon:CreateFontString(nil, "OVERLAY")
			icon.count:SetPoint("CENTER", unpack(countOffsets[spell[2]]))
			icon.count:SetFont(C.media.pixelfont, 10, "THINOUTLINE")
			
			auras.icons[spell[1]] = icon
		end
	end
	
	self.AuraWatch = auras
end