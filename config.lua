local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Configurations
------------------------------------------------------------

C["general"] = {
	["hideshadows"] = true,									-- disable frames shadows.
}

C["unitframes"] = {
	-- general
	["enable"] = true,										-- enable unitframes layout.
	["unicolor"] = true,									-- enable unicolor theme.
	["smooth"] = false,										-- enable smooth colors (*unicolor = false)
	["healcomm"] = true,									-- enable health prediction support.
	["targetpowerpvponly"] = true,							-- enable target power value only on pvp.
	["colorpower"] = true,									-- enable power bar color based by power type.
	["altpower"] = true,									-- enable alternative power.
	["focustarget"] = false,								-- enable focus target unitframes.
	["rangealpha"] = 0.7,									-- set alpha when units are out of range.
	
	-- castbar
	["castbar"] = true,										-- enable castbar
	["castbaricon"] = true,									-- enable castbar spell icon.
	["castbarlatency"] = true,								-- enable castbar delay support.
	["totcastbar"] = false,									-- enable tot castbar.
	["petcastbar"] = false,									-- enable pet castbar.
	
	-- auras
	["targetauras"] = true,									-- enable target auras (buffs/debuffs).
	["totauras"] = false,									-- enable tot auras.
	["focusbuffs"] = true,									-- enable focus buffs/debuffs.
	["focustargetauras"] = true,							-- enable focus target buffs/debuffs.
	
	-- class
	["addpower"] = true,									-- enable additional power bar.
	["totem"] = true,										-- enable totem bar support (totems/statue/efflorescence/consecration/...)
	["weakenedsoul"] = true,								-- enable weakened soul.
	["stagger"] = true,										-- enable stagger bar.
	["harmonybar"] = true,									-- enable harmony bar (chi) for windwalker.
	["holypower"] = true,									-- enable holy power bar for paladin retribution.
	["combopoints"] = true,									-- enable combo points support for druid/rogue.
	["soulshards"] = true,									-- enable soul shards support.
	["arcanecharges"] = true,								-- enable arcane charges bar for arcane mage.
	["runes"] = true,										-- enable runes for deathknight.
	
	-- boss
	["boss"] = true,										-- enable boss unitframes.
	["bossauras"] = true,									-- enable boss auras.
	
	-- arena
	["arena"] = true,										-- enable arena unitframes.
	["arenaauras"] = true,									-- enable arena auras.
	
	-- raid
	["raid"] = true,										-- enable raid unitframes.
	["showSolo"] = true,									-- display raid frame when solo.
	["raidunitspercolumn"] = 5,								-- set the number of units per column.
	["showgroupresurrect"] = true,							-- enable raid resurrect icon.
	["raiddebuffwatch"] = true,								-- enable aura watch.
	["auratimer"] = true,
}

C["nameplates"] = {
	["enable"] = true,										-- enable nameplate style.
	["castbar"] = true,										-- enable nameplate castbar.
	["debuffs"] = true,										-- enable debuffs casted by player above nameplate.
}

C["plugins"] = {
	["dispel"] = true,										-- enable dispel announce.
	["interrupt"] = true,									-- enable interrupt announce.
	["achievscreenshot"] = true,							-- enable achievement auto screen-shot.
}

C["media"] = {
	-- Colors:
	["healthcolor"] = { .10, .10, .10 },					-- unitframes health color
	["bordercolor"] = { .125, .125, .125 },					-- unitframes border color.
	["backdropcolor"] = { .05, .05, .05 },					-- unitframes background color.
	
	-- Fonts:
	["font"] = [[Interface\AddOns\oUF_Lua\medias\fonts\normal_font.ttf]],			-- general font of oUF_Lua.
	["uffont"] = [[Interface\AddOns\oUF_Lua\medias\fonts\uf_font.ttf]],				-- general font of unitframes.
	["pixelfont"] = [[Interface\AddOns\oUF_Lua\medias\fonts\pixel_font.ttf]],		-- general font of oUF_Lua.
	
	-- Textures:
	["normTex"] = [[Interface\AddOns\oUF_Lua\medias\textures\normTex.tga]],			-- texture used for status bar (health, power, ...)
	["glowTex"] = [[Interface\AddOns\oUF_Lua\medias\textures\glowTex.tga]],			-- texture used to glow effect around some frames (castbar tick, ...)
	["bubbleTex"] = [[Interface\AddOns\oUF_Lua\medias\textures\bubbleTex.tga]],		-- texture used on unitframes combo points.
	["blankTex"] = [[Interface\AddOns\oUF_Lua\medias\textures\blankTex.tga]],		-- main texture for all borders, panels, etc.
	
	["raidIcons"] = [[Interface\AddOns\oUF_Lua\medias\textures\raidIcons.blp]],		-- texture used for raid target (skull, square, circle, ...)
	["roleDPS"] = [[Interface\AddOns\oUF_Lua\medias\textures\roleDPS.tga]],			-- texture used for DPS role at raid/group.
	["roleHEALER"] = [[Interface\AddOns\oUF_Lua\medias\textures\roleHEALER.tga]],	-- texture used for HEALER role at raid/group.
	["roleTANK"] = [[Interface\AddOns\oUF_Lua\medias\textures\roleTANK.tga]],		-- texture used for TANK role at raid/group.
	
	-- Sounds:
	["whisper"] = [[Interface\AddOns\oUF_Lua\medias\sounds\whisper.mp3]],
}