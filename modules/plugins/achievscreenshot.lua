local T, C, L, G = unpack(select(2, ...))
-----------------------------------------------------------
-- Achievement ScreenShot by Blamdarot
------------------------------------------------------------
if not C.plugins.achievscreenshot then return end

local function TakeScreen(delay, func, ...)
	local waitTable = {}
	local waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
	waitFrame:SetScript("OnUpdate", function (self, elapse)
		local count = #waitTable
		local i = 1
		while (i <= count) do
			local waitRecord = table.remove(waitTable, i)
			local d = table.remove(waitRecord, 1)
			local f = table.remove(waitRecord, 1)
			local p = table.remove(waitRecord, 1)
			if (d > elapse) then
				table.insert(waitTable, i, { d - elapse, f, p })
				i = i + 1
			else
				count = count - 1
				f(unpack(p))
			end
		end
	end)
	table.insert(waitTable, { delay, func, {...} })
end

local function OnEvent(...)
	TakeScreen(1, Screenshot)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ACHIEVEMENT_EARNED")
f:SetScript("OnEvent", OnEvent)