local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Lua is unable to locate oUF install.")

local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Layout:
------------------------------------------------------------

local function Style(self, unit)
	if not unit then return end
	
	local parent = self:GetParent():GetName()
	
	if (unit == "player") then
		T.PlayerStyle(self, unit)
	elseif (unit == "target") then
		T.TargetStyle(self, unit)
	elseif (unit == "targettarget") then
		T.ToTStyle(self, unit)
	elseif (unit == "pet") then
		T.PetStyle(self, unit)
	elseif (unit == "focus") then
		T.FocusStyle(self, unit)
	elseif (unit == "focustarget") then
		T.FocusTargetStyle(self, unit)
	elseif (unit:find("boss%d")) then
		T.BossStyle(self, unit)
	elseif (unit:find("arena%d")) then
		T.ArenaStyle(self, unit)
	elseif (unit:find("raid")) then
		T.RaidStyle(self, unit)
	end
	-- unit:match("nameplate")
end

oUF:RegisterStyle("oUF_Lua:layout", Style)
oUF:Factory(function(self)
	self:SetActiveStyle("oUF_Lua:layout")
	
	local player = self:Spawn("player", "oUF_Player")
	player:SetPoint("CENTER", UIParent, "CENTER", -350, -300)
	
	local target = self:Spawn("target", "oUF_Target")
	target:SetPoint("CENTER", UIParent, "CENTER", 350, -300)
	
	local tot = self:Spawn("targettarget", "oUF_TargetTarget")
	tot:SetPoint("CENTER", UIParent, "CENTER", 0, -300)
	
	local pet = self:Spawn("pet", "oUF_Pet")
	pet:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -13)
	
	local focus = self:Spawn("focus", "oUF_Focus")
	focus:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -13)
	
	if C.unitframes.focustarget then
		local focustarget = self:Spawn("focustarget", "oUF_FocusTarget")
		focustarget:SetPoint("TOPLEFT", focus, "BOTTOMLEFT", 0, -13)
	end
	
	if C.unitframes.boss then
		local boss = {}
		for i = 1, 5 do
			boss[i] = oUF:Spawn("arena" .. i, "oUF_Boss" .. i)
			
			if (i == 1) then
				boss[i]:SetPoint("RIGHT", UIParent, "RIGHT", -150, -50)
			else
				boss[i]:SetPoint("BOTTOM", boss[i - 1], "TOP", 0, 50)
			end
		end
	end
	
	if C.unitframes.arena then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena" .. i, "oUF_Arena" .. i)
			
			if (i == 1) then
				arena[i]:SetPoint("RIGHT", UIParent, "RIGHT", -150, -50)
			else
				arena[i]:SetPoint("BOTTOM", arena[i - 1], "TOP", 0, 50)
			end
		end
	end
	
	if C.unitframes.raid then
		local raid = self:SpawnHeader("oUF_Raid", nil, 'raid,party,solo',
		-- Set header attributes: (http://wowprogramming.com/docs/secure_template/Group_Headers)
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height")) ]],
		'initial-width', 68,
		'initial-height', 34,
		'showRaid', true,
		'showParty', true,
		'showPlayer', true,
		'showSolo', C.unitframes.showSolo or false,
		'xOffset', 7,
		'yOffset', -3,
		'point', "LEFT",
		'groupFilter', '1,2,3,4,5,6,7,8',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'groupBy', 'GROUP',
		'maxColumns', math.ceil(40/C.unitframes.raidunitspercolumn or 5),
		'unitsPerColumn', C.unitframes.raidunitspercolumn or 5,
		'columnSpacing', 13,
		'columnAnchorPoint', "BOTTOM"
		)
		raid:SetPoint("LEFT", UIParent, "LEFT", 20, -200)
	end
end)