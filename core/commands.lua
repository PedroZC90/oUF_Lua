local T, C, L, G = unpack(select(2, ...))
------------------------------------------------------------
-- Commands
------------------------------------------------------------

-- Reload UI
SLASH_RELOADUI1 = "/reload"
SLASH_RELOADUI2 = "/rl"
SlashCmdList["RELOADUI"] = ReloadUI

-- Test Bosses/Arena Frames
SLASH_TESTUI1 = "/testui"
SlashCmdList["TESTUI"] = function()
	local name = "oUF_"
	
	if C.unitframes.arena then
		for i = 1, 5 do
			_G[name .. "Arena" .. i].unit = "player"
			_G[name .. "Arena" .. i].Hide = function() end
			_G[name .. "Arena" .. i]:Show()
			
		end
	end
	
	if C.unitframes.boss then
		for i = 1, 5 do
			_G[name .. "Boss" .. i].unit = "player"
			_G[name .. "Boss" .. i].Hide = function() end
			_G[name .. "Boss" .. i]:Show()
		end
	end
	
	--[[for _, frames in pairs({"Pet", "Focus", "FocusTarget", "TargetTarget"}) do
		_G[name .. frames].unit = "player"
		_G[name .. frames].Hide = function() end
		_G[name .. frames]:Show()
	end--]]
end

-- Print oUF_Lua Info
SLASH_ADDONINFO1 = "/lua"
SlashCmdList["ADDONINFO"] = function (msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	
	if (cmd == "version") then
		print(T.AddonName .. " " .. T.AddonVersion)
	elseif (cmd == "wow") then
		print("Interface: " .. T.TocVersion)
		print("World of Warcraft " .. T.WoWPatch .. " (" .. T.WoWBuild .. ")")
	elseif (cmd == "info") then
		print(T.AddonName .. " " .. T.AddonVersion)
		print("Interface: " .. T.TocVersion)
		print("World of Warcraft " .. T.WoWPatch .. " (" .. T.WoWBuild .. ")")
	end
end