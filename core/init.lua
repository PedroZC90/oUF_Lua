------------------------------------------------------------
-- Initialization of oUF_Lua Engine
------------------------------------------------------------
local Addon, Engine = ...

Engine[1] = {}	-- T: Table = Function, Constants, Variables and etc.
Engine[2] = {}	-- C: Configurations
Engine[3] = {}	-- L: Localization
Engine[4] = {}	-- G: Globals (Optional)

-- System:
Engine[1].WindowedMode = Display_DisplayModeDropDown:windowedmode()
Engine[1].Fullscreen = Display_DisplayModeDropDown:fullscreenmode()
Engine[1].Resolution = (GetCurrentResolution() > 0) and select(GetCurrentResolution(), GetScreenResolutions()) or nil
Engine[1].ScreenHeight = tonumber(string.match(Engine[1].Resolution, "%d+x(%d+)"))
Engine[1].ScreenWidth = tonumber(string.match(Engine[1].Resolution, "(%d+)x+%d"))
-- Game Info:
Engine[1].Client = GetLocale()
Engine[1].WoWPatch, Engine[1].WoWBuild, Engine[1].WoWPatchReleaseDate, Engine[1].TocVersion = GetBuildInfo()
Engine[1].WoWBuild = tonumber(Engine[1].WoWBuild)
-- Player Info:
Engine[1].myName = select(1, UnitName("player"))
Engine[1].myClass = select(2, UnitClass("player"))
Engine[1].myLevel = UnitLevel("player")
Engine[1].myRealm = GetRealmName()
-- Addon:
Engine[1].AddonName = GetAddOnMetadata(Addon, "Title")
Engine[1].AddonVersion = GetAddOnMetadata(Addon, "Version")
Engine[1].Dummy = function() return end

-- local uiscale = 0.71
-- local mult = 768 / string.match(Engine[1].Resolution, "%d+x(%d+)") / uiscale

-- print addon info on login.
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("PLAYER_LOGIN")
-- f:RegisterEvent("ADDON_LOADED")
-- f:SetScript("OnEvent", function(self, event, name)
	-- if (name == "oUF_Lua") then
		-- print(Engine[1].AddonName .. " " .. Engine[1].AddonVersion)
		-- print("Interface: " .. Engine[1].TocVersion)
		-- print("World of Warcraft " .. Engine[1].WoWPatch .. " (" .. Engine[1].WoWBuild .. ")")
	-- end
-- end)

oUFLua = Engine		-- Allow other addons to use the Engine