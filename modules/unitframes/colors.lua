local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Colors:
------------------------------------------------------------

T.UnitColors = {
	tapped = { .55, .57, .61 },
	disconnected = { .60, .60, .60 },
	runes = {
		[1] = { .69, .31, .31 },
		[2] = { .31, .45, .63 },
		[3] = { .33, .69, .33 },
		[4] = { .84, .75, .65 },
	},
	reaction = {
		[1] = { .87, .37, .37 },	-- Hated
		[2] = { .87, .37, .37 },	-- Hostile
		[3] = { .87, .37, .37 },	-- Unfriendly
		[4] = { .85, .77, .36 },	-- Neutral
		[5] = { .30, .67, .30 },	-- Friendly
		[6] = { .30, .67, .30 },	-- Honored
		[7] = { .30, .67, .30 },	-- Revered
		[8] = { .30, .67, .30 },	-- Exalted
		[9] = { .00, .50, .90 },	-- ??
	},
	class = {
		["WARRIOR"]		= { .78, .61, .43 },	-- 1 
		["PALADIN"]		= { .96, .55, .73 },	-- 2
		["HUNTER"]		= { .67, .84, .45 },	-- 3
		["ROGUE"]		= { 1.0, .95, .32 },	-- 4
		["PRIEST"]		= { .83, .83, .83 },	-- 5
		["DEATHKNIGHT"]	= { .77, .12, .24 },	-- 6
		["SHAMAN"]		= { .16, .31, .61 },	-- 7
		["MAGE"]		= { .41, .80, 1.0 },	-- 8
		["WARLOCK"]		= { .58, .51, .79 },	-- 9
		["MONK"]		= { .00, 1.0, .59 },	-- 10
		["DRUID"]		= { 1.0, .49, .03 },	-- 11
		["DEMONHUNTER"]	= { .64, .19, .79 },	-- 12
	},
	power = {
		["MANA"] 			= { .31, .45, .63 },	-- 0
		["RAGE"] 			= { .69, .31, .31 },	-- 1
		["FOCUS"] 			= { .71, .43, .27 },	-- 2 
		["ENERGY"] 			= { .65, .65, .35 },	-- 3
		["COMBO_POINTS"] 	= { 1.0, .96, .41 },	-- 4
		["RUNES"] 			= { .55, .57, .61 },	-- 5
		["RUNIC_POWER"] 	= { .00, .82, 1.0 },	-- 6
		["SOUL_SHARDS"] 	= { .50, .32, .55 },	-- 7
		["LUNAR_POWER"] 	= { .30, .52, .90 },	-- 8
		["HOLY_POWER"] 		= { .95, .90, .60 },	-- 9
		["ALTPOWER"]		= { .00, .80, .80 },	-- 10
		["MAELSTROM"] 		= { .00, .50, 1.0 },	-- 11
		["CHI"]				= { .71, 1.0, .92 },	-- 12
		["INSANITY"] 		= { .40, .00, .80 },	-- 13
		["ARCANE_CHARGES"] 	= { .31, .45, .63 },	-- 16
		["FURY"] 			= { .79, .26, .99 },	-- 17
		["PAIN"] 			= { 1.0, .61, .00 },	-- 18
		["AMMOSLOT"] 		= { .80, .60, .00 }, 
		["FUEL"] 			= { .00, .55, .50 },
		["STAGGER"] = {
						[1] = {	.33, .69, .33 },
						[2] = {	.85, .77, .36 },
						[3] = { .69, .31, .31 },
		},
	},
}

-- tbl = T.UnitColors.power
-- local y = 0
-- for key, color in pairs(tbl) do
	-- local r, g, b = unpack(color)
	-- local f = CreateFrame("StatusBar", nil, UIParent)
	-- f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -20 - y)
	-- f:SetSize(30, 15)
	-- f:SetStatusBarTexture(C.media.blankTex)
	-- f:SetStatusBarColor(r, g, b)
	-- f:SetBorder("Default")
	
	-- y = y + f:GetHeight() + 7
-- end