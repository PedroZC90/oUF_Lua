local T, C, L, G = unpack(select(2, ...))
if not (C.plugins.loc and C.plugins.enable) then return end
------------------------------------------------------------
-- Loss of Control
------------------------------------------------------------

f = CreateFrame("Frame")
f:RegisterEvent("LOSS_OF_CONTROL_ADDED")
f:RegisterEvent("LOSS_OF_CONTROL_UPDATE")
f:SetScript("OnEvent",function()
	for b in pairs(ActionBarActionEventsFrame.frames) do
		b.cooldown:SetLossOfControlCooldown(0,0)
	end
end)