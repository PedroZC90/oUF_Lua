local T, C, L, G = unpack(select(2, ...))

-- dummy function that returns nothing.
local Dummy = function() return end

------------------------------------------------------------
-- API: Read DOCS\API.txt for more informations.
------------------------------------------------------------

-- set a object outside a anchor
local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then obj:ClearAllPoints() end
	
	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

-- set a object inside a anchor
local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then obj:ClearAllPoints() end
	
	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

-- set a template
local function SetTemplate(f, t, tex)
	local alpha = 1
	if (t == "Transparent") then alpha = 0.8 end
	local borderr, borderg, borderb = unpack(C.media.bordercolor)
	local backdropr, backdropg, backdropb = unpack(C.media.backdropcolor)
	local texture = C.media.blankTex
	
	if (tex) then texture = C.media.normTex end
	
	local inset = 1
	f:SetBackdrop({
		bgFile = texture,
		edgeFile = C.media.blankTex,
		tile = false, tileSize = 0, edgeSize = inset,
	})
	
	if (not f.isInsetDone) then
		f.insettop = f:CreateTexture(nil, "BORDER")
		f.insettop:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insettop:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, -1)
		f.insettop:SetHeight(1)
		f.insettop:SetColorTexture(.0,.0,.0)
		f.insettop:SetDrawLayer("BORDER", -7)

		f.insetbottom = f:CreateTexture(nil, "BORDER")
		f.insetbottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, -1)
		f.insetbottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
		f.insetbottom:SetHeight(1)
		f.insetbottom:SetColorTexture(.0,.0,.0)
		f.insetbottom:SetDrawLayer("BORDER", -7)

		f.insetleft = f:CreateTexture(nil, "BORDER")
		f.insetleft:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insetleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, -1)
		f.insetleft:SetWidth(1)
		f.insetleft:SetColorTexture(.0,.0,.0)
		f.insetleft:SetDrawLayer("BORDER", -7)

		f.insetright = f:CreateTexture(nil, "BORDER")
		f.insetright:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, 1)
		f.insetright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, -1)
		f.insetright:SetWidth(1)
		f.insetright:SetColorTexture(.0,.0,.0)
		f.insetright:SetDrawLayer("BORDER", -7)

		f.insetinsidetop = f:CreateTexture(nil, "BORDER")
		f.insetinsidetop:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsidetop:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, 1)
		f.insetinsidetop:SetHeight(1)
		f.insetinsidetop:SetColorTexture(.0,.0,.0)
		f.insetinsidetop:SetDrawLayer("BORDER", -7)

		f.insetinsidebottom = f:CreateTexture(nil, "BORDER")
		f.insetinsidebottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
		f.insetinsidebottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
		f.insetinsidebottom:SetHeight(1)
		f.insetinsidebottom:SetColorTexture(.0,.0,.0)
		f.insetinsidebottom:SetDrawLayer("BORDER", -7)

		f.insetinsideleft = f:CreateTexture(nil, "BORDER")
		f.insetinsideleft:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsideleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, 1)
		f.insetinsideleft:SetWidth(1)
		f.insetinsideleft:SetColorTexture(.0,.0,.0)
		f.insetinsideleft:SetDrawLayer("BORDER", -7)

		f.insetinsideright = f:CreateTexture(nil, "BORDER")
		f.insetinsideright:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
		f.insetinsideright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, 1)
		f.insetinsideright:SetWidth(1)
		f.insetinsideright:SetColorTexture(.0,.0,.0)
		f.insetinsideright:SetDrawLayer("BORDER", -7)

		f.isInsetDone = true
	end
	
	f:SetBackdropColor(backdropr, backdropg, backdropb, alpha)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local borders = {
	"insettop",
	"insetbottom",
	"insetleft",
	"insetright",
	"insetinsidetop",
	"insetinsidebottom",
	"insetinsideleft",
	"insetinsideright",
}

-- hide insets (border)
local function HideInsets(f)
	for i, border in pairs(borders) do
		if f[border] then
			f[border]:SetColorTexture(.0,.0,.0,.0)
		end
	end
end

-- create backdrop around (border) frame.
local function SetBorder(f, t, tex)
	if f.backdrop then return end
	if not t then t = "Default" end

	local b = CreateFrame("Frame", nil, f)
	b:SetOutside()
	b:SetTemplate(t, tex)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

-- change border color
local function SetBorderColor(f, r, g, b)
	if not f.backdrop then return end
	f.backdrop:SetBackdropBorderColor(r, g, b)
end

-- create shadow around frame.
local function CreateShadow(f, t)
	if f.shadow then return end
	if f.backdrop then f = f.backdrop end
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 3)
	shadow:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 3, -3)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetFrameLevel(1)
	
	local inset = 5
	local backdrop = {
		bgFile = nil,
		edgeFile = C.media.glowTex,
		tile = false, tileSize = 0, edgeSize = 3,
		insets = { top = inset, bottom = inset, left = inset, right = inset }
	}
	
	local alpha = 0.8
	if C.general.hideshadows then alpha = 0 end
	
	shadow:SetBackdrop(backdrop)
	shadow:SetBackdropColor(.0,.0,.0,.0)
	shadow:SetBackdropBorderColor(.0,.0,.0,alpha)
	
	f.shadow = shadow
end

-- kill unnecessary objects.
local function Kill(obj)
	if obj.UnregisterAllEvents then
		obj:UnregisterAllEvents()
	end
	obj.Show = Dummy
	obj:Hide()
end

------------------------------------------------------------
-- Merge oUF_Lua API with WoW API
------------------------------------------------------------

local function AddAPI(obj)
	local mt = getmetatable(obj).__index
	
	if not obj.SetOutside then mt.SetOutside = SetOutside end
	if not obj.SetInside then mt.SetInside = SetInside end
	if not obj.SetTemplate then mt.SetTemplate = SetTemplate end
	if not obj.HideInsets then mt.HideInsets = HideInsets end
	if not obj.SetBorder then mt.SetBorder = SetBorder end
	if not obj.SetBorderColor then mt.SetBorderColor = SetBorderColor end
	if not obj.SetShadow then mt.SetShadow = SetShadow end
	if not obj.Kill then mt.Kill = Kill end
end

local Handled = {["Frame"] = true}

local Object = CreateFrame("Frame")
AddAPI(Object)
AddAPI(Object:CreateTexture())
AddAPI(Object:CreateFontString())

Object = EnumerateFrames()

while Object do
	if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
		AddAPI(Object)
		Handled[Object:GetObjectType()] = true
	end
	
	Object = EnumerateFrames(Object)
end