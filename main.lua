-- SBX GUI v21 (Executor + Draggable Watermark)
-- ZAWIERA WSZYSTKIE CZĘŚCI 1-5 + ULEPSZENIA!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6895079853"
clickSound.Volume = 0.8
clickSound.Parent = SoundService

local hoverSound = Instance.new("Sound")
hoverSound.SoundId = "rbxassetid://6042053626"
hoverSound.Volume = 0.3
hoverSound.Parent = SoundService

local function playClick() pcall(function() clickSound:Play() end) end
local function playHover() pcall(function() hoverSound:Play() end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SBX_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.DisplayOrder = 999 end)

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "SBX_ESP"
ESPGui.Parent = player.PlayerGui
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "SBX_Notifications"
NotifGui.Parent = player.PlayerGui
NotifGui.ResetOnSpawn = false
NotifGui.IgnoreGuiInset = true

local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "SBX_Crosshair"
CrosshairGui.Parent = player.PlayerGui
CrosshairGui.ResetOnSpawn = false
CrosshairGui.IgnoreGuiInset = true
CrosshairGui.Enabled = false

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "SBX_Watermark"
WatermarkGui.Parent = player.PlayerGui
WatermarkGui.ResetOnSpawn = false
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.Enabled = false

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 300, 1, 0)
NotifContainer.Position = UDim2.new(1, -320, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function showNotification(message, notifType)
	notifType = notifType or "info"
	local colors = {success=Color3.fromRGB(50,200,100),error=Color3.fromRGB(230,60,80),warning=Color3.fromRGB(255,180,50),info=Color3.fromRGB(230,60,110)}
	local icons = {success="✓",error="✕",warning="⚠",info="ℹ"}
	local color = colors[notifType] or colors.info
	local icon = icons[notifType] or icons.info
	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(1, 0, 0, 50)
	Notif.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	Notif.BorderSizePixel = 0
	Notif.Parent = NotifContainer
	Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
	local NS = Instance.new("UIStroke", Notif); NS.Color = color; NS.Thickness = 2
	local Bar = Instance.new("Frame", Notif); Bar.Size = UDim2.new(0,4,1,0); Bar.BackgroundColor3 = color; Bar.BorderSizePixel = 0
	local IconLbl = Instance.new("TextLabel", Notif); IconLbl.Size = UDim2.new(0,30,1,0); IconLbl.Position = UDim2.new(0,10,0,0)
	IconLbl.BackgroundTransparency = 1; IconLbl.Text = icon; IconLbl.TextColor3 = color; IconLbl.TextSize = 20; IconLbl.Font = Enum.Font.GothamBold
	local MsgLbl = Instance.new("TextLabel", Notif); MsgLbl.Size = UDim2.new(1,-50,1,0); MsgLbl.Position = UDim2.new(0,45,0,0)
	MsgLbl.BackgroundTransparency = 1; MsgLbl.Text = message; MsgLbl.TextColor3 = Color3.fromRGB(230,230,230)
	MsgLbl.TextSize = 13; MsgLbl.Font = Enum.Font.GothamSemibold; MsgLbl.TextXAlignment = Enum.TextXAlignment.Left; MsgLbl.TextWrapped = true
	Notif.Position = UDim2.new(1, 320, 0, 0)
	TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
	task.spawn(function()
		task.wait(3)
		local tw = TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}); tw:Play()
		TweenService:Create(NS, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(Bar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(IconLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		tw.Completed:Wait(); Notif:Destroy()
	end)
end

-- ========== GLOBAL SETTINGS ==========
local Settings = {
	streamProof = false,
	fixBlink = false,
	entityListAnim = true,
	crosshair = false,
	crosshairColor = Color3.fromRGB(230, 60, 110),
	crosshairThickness = 2,
	crosshairLength = 10,
	crosshairGap = 4,
	crosshairDot = false,
	crosshairOutline = true,
	watermark = false,
	menuBind = Enum.KeyCode.Insert,
	waitingForBind = false,
}

-- ========== MAIN FRAME (declared early for watermark reference) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 830, 0, 570)
MainFrame.Position = UDim2.new(0.5, -415, 0.5, -285)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local minimized = false

-- ========== WATERMARK (DRAGGABLE) ==========
local WMFrame = Instance.new("Frame")
WMFrame.Size = UDim2.new(0, 250, 0, 38)
WMFrame.Position = UDim2.new(0, 15, 0, 15)
WMFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
WMFrame.BackgroundTransparency = 0.15
WMFrame.BorderSizePixel = 0
WMFrame.Active = true
WMFrame.Parent = WatermarkGui
Instance.new("UICorner", WMFrame).CornerRadius = UDim.new(0, 8)
local WMStroke = Instance.new("UIStroke", WMFrame)
WMStroke.Color = Color3.fromRGB(230, 60, 110)
WMStroke.Thickness = 1.5
WMStroke.Transparency = 0.3

local WMBar = Instance.new("Frame", WMFrame)
WMBar.Size = UDim2.new(0, 3, 1, 0)
WMBar.Position = UDim2.new(0, 0, 0, 0)
WMBar.BackgroundColor3 = Color3.fromRGB(230, 60, 110)
WMBar.BorderSizePixel = 0
local WMBarGradient = Instance.new("UIGradient", WMBar)
WMBarGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 60, 110)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 220))
})
WMBarGradient.Rotation = 90

local WMLogo = Instance.new("TextLabel", WMFrame)
WMLogo.Size = UDim2.new(0, 45, 1, 0)
WMLogo.Position = UDim2.new(0, 8, 0, 0)
WMLogo.BackgroundTransparency = 1
WMLogo.Text = "SBX"
WMLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
WMLogo.TextSize = 18
WMLogo.Font = Enum.Font.GothamBold
WMLogo.TextXAlignment = Enum.TextXAlignment.Left

local WMSep = Instance.new("Frame", WMFrame)
WMSep.Size = UDim2.new(0, 1, 0.6, 0)
WMSep.Position = UDim2.new(0, 55, 0.2, 0)
WMSep.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
WMSep.BorderSizePixel = 0

local WMInfo = Instance.new("TextLabel", WMFrame)
WMInfo.Size = UDim2.new(1, -80, 1, 0)
WMInfo.Position = UDim2.new(0, 62, 0, 0)
WMInfo.BackgroundTransparency = 1
WMInfo.Text = "v18 | FPS: 60 | 0ms"
WMInfo.TextColor3 = Color3.fromRGB(200, 200, 210)
WMInfo.TextSize = 12
WMInfo.Font = Enum.Font.GothamSemibold
WMInfo.TextXAlignment = Enum.TextXAlignment.Left

local wmDragIcon = Instance.new("TextLabel", WMFrame)
wmDragIcon.Size = UDim2.new(0, 14, 0, 14)
wmDragIcon.Position = UDim2.new(1, -18, 0.5, -7)
wmDragIcon.BackgroundTransparency = 1
wmDragIcon.Text = "⋮⋮"
wmDragIcon.TextColor3 = Color3.fromRGB(150, 150, 160)
wmDragIcon.TextSize = 12
wmDragIcon.Font = Enum.Font.GothamBold
wmDragIcon.Visible = false

-- DRAGGING logic
local wmDragging = false
local wmDragStart = nil
local wmStartPos = nil

WMFrame.InputBegan:Connect(function(input)
	if not (MainFrame.Visible and not minimized) then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		wmDragging = true
		wmDragStart = input.Position
		wmStartPos = WMFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - wmDragStart
		WMFrame.Position = UDim2.new(
			wmStartPos.X.Scale,
			wmStartPos.X.Offset + delta.X,
			wmStartPos.Y.Scale,
			wmStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		wmDragging = false
	end
end)

local function updateWMDraggableUI()
	if MainFrame.Visible and not minimized then
		WMStroke.Color = Color3.fromRGB(100, 255, 100)
		wmDragIcon.Visible = true
		WMFrame.BackgroundTransparency = 0.1
	else
		WMStroke.Color = Color3.fromRGB(230, 60, 110)
		wmDragIcon.Visible = false
		WMFrame.BackgroundTransparency = 0.15
		wmDragging = false
	end
end
MainFrame:GetPropertyChangedSignal("Visible"):Connect(updateWMDraggableUI)

local wmLast = tick()
local wmFrames = 0
local wmFPS = 60
RunService.RenderStepped:Connect(function()
	if not WatermarkGui.Enabled then return end
	updateWMDraggableUI()
	wmFrames = wmFrames + 1
	local now = tick()
	if now - wmLast >= 0.5 then
		wmFPS = math.floor(wmFrames / (now - wmLast))
		wmFrames = 0
		wmLast = now
		local ping = 0
		pcall(function() ping = math.floor(player:GetNetworkPing() * 1000) end)
		WMInfo.Text = string.format("v18 | FPS: %d | %dms", wmFPS, ping)
	end
end)

-- ========== CROSSHAIR ==========
local CHContainer = Instance.new("Frame")
CHContainer.Size = UDim2.new(0, 40, 0, 40)
CHContainer.AnchorPoint = Vector2.new(0.5, 0.5)
CHContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
CHContainer.BackgroundTransparency = 1
CHContainer.Parent = CrosshairGui

local function makeCHLine()
	local L = Instance.new("Frame", CHContainer)
	L.BackgroundColor3 = Settings.crosshairColor
	L.BorderSizePixel = 0
	L.AnchorPoint = Vector2.new(0.5, 0.5)
	local S = Instance.new("UIStroke", L)
	S.Color = Color3.fromRGB(0, 0, 0)
	S.Thickness = 1
	S.Transparency = 0
	return L, S
end

local CHTop, CHTopS = makeCHLine()
local CHBottom, CHBottomS = makeCHLine()
local CHLeft, CHLeftS = makeCHLine()
local CHRight, CHRightS = makeCHLine()
local CHDot, CHDotS = makeCHLine()
CHDot.Visible = false
Instance.new("UICorner", CHDot).CornerRadius = UDim.new(1, 0)

local function updateCrosshair()
	local t = Settings.crosshairThickness
	local l = Settings.crosshairLength
	local g = Settings.crosshairGap
	local c = Settings.crosshairColor
	CHTop.Size = UDim2.new(0, t, 0, l); CHTop.Position = UDim2.new(0.5, 0, 0.5, -g - l/2); CHTop.BackgroundColor3 = c
	CHBottom.Size = UDim2.new(0, t, 0, l); CHBottom.Position = UDim2.new(0.5, 0, 0.5, g + l/2); CHBottom.BackgroundColor3 = c
	CHLeft.Size = UDim2.new(0, l, 0, t); CHLeft.Position = UDim2.new(0.5, -g - l/2, 0.5, 0); CHLeft.BackgroundColor3 = c
	CHRight.Size = UDim2.new(0, l, 0, t); CHRight.Position = UDim2.new(0.5, g + l/2, 0.5, 0); CHRight.BackgroundColor3 = c
	CHDot.Size = UDim2.new(0, t+1, 0, t+1); CHDot.Position = UDim2.new(0.5, 0, 0.5, 0); CHDot.BackgroundColor3 = c
	CHDot.Visible = Settings.crosshairDot
	local outlineT = Settings.crosshairOutline and 1 or 0
	CHTopS.Transparency = 1 - outlineT; CHBottomS.Transparency = 1 - outlineT
	CHLeftS.Transparency = 1 - outlineT; CHRightS.Transparency = 1 - outlineT; CHDotS.Transparency = 1 - outlineT
end
updateCrosshair()

-- ========== SIDEBAR ==========
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 20, 1, 0)
SidebarFix.Position = UDim2.new(1, -20, 0, 0)
SidebarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 80)
Logo.Position = UDim2.new(0, 0, 0, 20)
Logo.BackgroundTransparency = 1
Logo.Text = "SBX"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 42
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Sidebar

local sidebarItems = {
	{name = "Combat", icon = "⚔"},
	{name = "Visuals", icon = "👁"},
	{name = "Self", icon = "♥"},
	{name = "Online", icon = "🌐"},
	{name = "Executor", icon = "⚡"},
	{name = "Resources", icon = "⚙"},
	{name = "Settings", icon = "⚙"},
}

local tabSubTabs = {
	Combat = {"Aimbot", "Trigger Bot"},
	Visuals = {"Players", "World", "Radar"},
	Self = {"Player", "Weapon", "Freecam", "Teleport"},
	Online = {"Player List"},
	Executor = {"Lua"},
	Resources = {"Resource Stopper", "Resource Dumper", "Trigger Finder"},
	Settings = {"Main", "Crosshair"},
}

local selectedTab = nil
local tabButtons = {}
local tabPages = {}
local subPagesByTab = {}
local selectedSubTabs = {}

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -190, 1, -80)
ContentArea.Position = UDim2.new(0, 180, 0, 70)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -190, 0, 50)
TopBar.Position = UDim2.new(0, 180, 0, 10)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local SubTabsContainer = Instance.new("Frame")
SubTabsContainer.Size = UDim2.new(1, -50, 1, 0)
SubTabsContainer.BackgroundTransparency = 1
SubTabsContainer.Parent = TopBar

-- ========== STREAMPROOF ==========
local function applyStreamProof(state)
	pcall(function()
		if state then
			pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
			pcall(function() ESPGui.Parent = game:GetService("CoreGui") end)
			pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
			pcall(function() CrosshairGui.Parent = game:GetService("CoreGui") end)
			pcall(function() WatermarkGui.Parent = game:GetService("CoreGui") end)
			ScreenGui.DisplayOrder = 999999
			if syn and syn.protect_gui then
				pcall(function() syn.protect_gui(ScreenGui) end)
				pcall(function() syn.protect_gui(ESPGui) end)
				pcall(function() syn.protect_gui(NotifGui) end)
				pcall(function() syn.protect_gui(CrosshairGui) end)
				pcall(function() syn.protect_gui(WatermarkGui) end)
			end
			if gethui then
				local hui = gethui()
				pcall(function() ScreenGui.Parent = hui end)
				pcall(function() ESPGui.Parent = hui end)
				pcall(function() NotifGui.Parent = hui end)
				pcall(function() CrosshairGui.Parent = hui end)
				pcall(function() WatermarkGui.Parent = hui end)
			end
			showNotification("StreamProof ENABLED - GUI hidden from OBS/Discord", "success")
		else
			ScreenGui.Parent = player.PlayerGui
			ESPGui.Parent = player.PlayerGui
			NotifGui.Parent = player.PlayerGui
			CrosshairGui.Parent = player.PlayerGui
			WatermarkGui.Parent = player.PlayerGui
			showNotification("StreamProof DISABLED", "info")
		end
	end)
end
-- ========== KOMPONENTY UI ==========
local function createPanel(parent, position, size, title, icon)
	local Panel = Instance.new("Frame")
	Panel.Size = size; Panel.Position = position
	Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	Panel.BorderSizePixel = 0; Panel.Parent = parent
	Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)
	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	TitleBar.BorderSizePixel = 0; TitleBar.Parent = Panel
	Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
	local TitleFix = Instance.new("Frame")
	TitleFix.Size = UDim2.new(1, 0, 0, 20)
	TitleFix.Position = UDim2.new(0, 0, 1, -20)
	TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	TitleFix.BorderSizePixel = 0; TitleFix.Parent = TitleBar
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -20, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = (icon or "◉") .. "  " .. title
	Title.TextColor3 = Color3.fromRGB(230, 230, 230)
	Title.TextSize = 14; Title.Font = Enum.Font.GothamSemibold
	Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TitleBar
	local Content = Instance.new("ScrollingFrame")
	Content.Size = UDim2.new(1, 0, 1, -45)
	Content.Position = UDim2.new(0, 0, 0, 45)
	Content.BackgroundTransparency = 1; Content.BorderSizePixel = 0
	Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	Content.CanvasSize = UDim2.new(0, 0, 0, 0)
	Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Content.Parent = Panel
	local LL = Instance.new("UIListLayout")
	LL.Padding = UDim.new(0, 2); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = Content
	local P = Instance.new("UIPadding")
	P.PaddingLeft = UDim.new(0, 15); P.PaddingRight = UDim.new(0, 15)
	P.PaddingTop = UDim.new(0, 5); P.PaddingBottom = UDim.new(0, 10); P.Parent = Content
	return Content
end

local function createToggle(parent, name, defaultState, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 38)
	Container.BackgroundTransparency = 1; Container.Parent = parent
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -60, 1, 0); Label.BackgroundTransparency = 1
	Label.Text = name; Label.TextColor3 = Color3.fromRGB(200, 200, 210)
	Label.TextSize = 13; Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container
	local ToggleBg = Instance.new("Frame")
	ToggleBg.Size = UDim2.new(0, 38, 0, 20); ToggleBg.Position = UDim2.new(1, -45, 0.5, -10)
	ToggleBg.BackgroundColor3 = defaultState and Color3.fromRGB(230, 60, 110) or Color3.fromRGB(50, 50, 60)
	ToggleBg.BorderSizePixel = 0; ToggleBg.Parent = Container
	Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
	local ToggleCircle = Instance.new("Frame")
	ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
	ToggleCircle.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleCircle.BorderSizePixel = 0; ToggleCircle.Parent = ToggleBg
	Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0); Button.BackgroundTransparency = 1
	Button.Text = ""; Button.Parent = ToggleBg
	local state = defaultState or false
	Button.MouseButton1Click:Connect(function()
		playClick(); state = not state
		if state then
			TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play()
			TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
		else
			TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
			TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
		end
		if callback then pcall(callback, state) end
	end)
	return Container
end

local function createToggleWithWarning(parent, name, defaultState, warningText, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 38); Container.BackgroundTransparency = 1; Container.Parent = parent
	local WI = Instance.new("TextLabel", Container); WI.Size = UDim2.new(0, 20, 0, 20); WI.Position = UDim2.new(0, 0, 0.5, -10)
	WI.BackgroundTransparency = 1; WI.Text = "⚠"; WI.TextColor3 = Color3.fromRGB(255, 180, 50); WI.TextSize = 16; WI.Font = Enum.Font.GothamBold
	local Label = Instance.new("TextLabel", Container); Label.Size = UDim2.new(1, -85, 1, 0); Label.Position = UDim2.new(0, 25, 0, 0)
	Label.BackgroundTransparency = 1; Label.Text = name; Label.TextColor3 = Color3.fromRGB(200, 200, 210)
	Label.TextSize = 13; Label.Font = Enum.Font.Gotham; Label.TextXAlignment = Enum.TextXAlignment.Left
	local TT = Instance.new("Frame", Container); TT.Size = UDim2.new(0, 250, 0, 55); TT.Position = UDim2.new(0, 25, 0, -60)
	TT.BackgroundColor3 = Color3.fromRGB(40, 30, 20); TT.BorderSizePixel = 0; TT.Visible = false; TT.ZIndex = 100
	Instance.new("UICorner", TT).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", TT).Color = Color3.fromRGB(255, 180, 50)
	local TTx = Instance.new("TextLabel", TT); TTx.Size = UDim2.new(1, -10, 1, -10); TTx.Position = UDim2.new(0, 5, 0, 5)
	TTx.BackgroundTransparency = 1; TTx.Text = "⚠ "..(warningText or ""); TTx.TextColor3 = Color3.fromRGB(255, 220, 180)
	TTx.TextSize = 11; TTx.Font = Enum.Font.Gotham; TTx.TextWrapped = true; TTx.TextXAlignment = Enum.TextXAlignment.Left; TTx.ZIndex = 101
	local HB = Instance.new("TextButton", Container); HB.Size = UDim2.new(0, 20, 0, 20); HB.Position = UDim2.new(0, 0, 0.5, -10)
	HB.BackgroundTransparency = 1; HB.Text = ""
	HB.MouseEnter:Connect(function() TT.Visible = true end); HB.MouseLeave:Connect(function() TT.Visible = false end)
	local Bg = Instance.new("Frame", Container); Bg.Size = UDim2.new(0, 38, 0, 20); Bg.Position = UDim2.new(1, -45, 0.5, -10)
	Bg.BackgroundColor3 = defaultState and Color3.fromRGB(230, 60, 110) or Color3.fromRGB(50, 50, 60); Bg.BorderSizePixel = 0
	Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
	local Ci = Instance.new("Frame", Bg); Ci.Size = UDim2.new(0, 14, 0, 14)
	Ci.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	Ci.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Ci.BorderSizePixel = 0
	Instance.new("UICorner", Ci).CornerRadius = UDim.new(1, 0)
	local Btn = Instance.new("TextButton", Bg); Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
	local state = defaultState or false
	Btn.MouseButton1Click:Connect(function()
		playClick(); state = not state
		if state then TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play()
			TweenService:Create(Ci, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
		else TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
			TweenService:Create(Ci, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play() end
		if callback then pcall(callback, state) end
	end)
	return Container
end

local function createFunctionButton(parent, name, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	Btn.Text = name; Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
	Btn.TextSize = 13; Btn.Font = Enum.Font.GothamSemibold
	Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false; Btn.Parent = parent
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	Btn.MouseEnter:Connect(function() playHover(); TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play() end)
	Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play() end)
	Btn.MouseButton1Click:Connect(function() playClick(); if callback then pcall(callback) end end)
	return Btn
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
	local Con = Instance.new("Frame"); Con.Size = UDim2.new(1, 0, 0, 52); Con.BackgroundTransparency = 1; Con.Parent = parent
	local L = Instance.new("TextLabel", Con); L.Size = UDim2.new(0.7, 0, 0, 20); L.BackgroundTransparency = 1
	L.Text = name; L.TextColor3 = Color3.fromRGB(200, 200, 210); L.TextSize = 13
	L.Font = Enum.Font.Gotham; L.TextXAlignment = Enum.TextXAlignment.Left
	local VL = Instance.new("TextLabel", Con); VL.Size = UDim2.new(0.3, -5, 0, 20); VL.Position = UDim2.new(0.7, 0, 0, 0)
	VL.BackgroundTransparency = 1; VL.Text = tostring(defaultVal); VL.TextColor3 = Color3.fromRGB(230, 230, 230)
	VL.TextSize = 13; VL.Font = Enum.Font.GothamSemibold; VL.TextXAlignment = Enum.TextXAlignment.Right
	local SBg = Instance.new("Frame", Con); SBg.Size = UDim2.new(1, 0, 0, 6); SBg.Position = UDim2.new(0, 0, 0, 30)
	SBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55); SBg.BorderSizePixel = 0
	Instance.new("UICorner", SBg).CornerRadius = UDim.new(1, 0)
	local fp = math.clamp((defaultVal - minVal)/(maxVal - minVal), 0, 1)
	local SF = Instance.new("Frame", SBg); SF.Size = UDim2.new(fp, 0, 1, 0); SF.BackgroundColor3 = Color3.fromRGB(230, 60, 110)
	SF.BorderSizePixel = 0; Instance.new("UICorner", SF).CornerRadius = UDim.new(1, 0)
	local Thumb = Instance.new("Frame", SBg); Thumb.Size = UDim2.new(0, 14, 0, 14)
	Thumb.Position = UDim2.new(fp, -7, 0.5, -7); Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Thumb.BorderSizePixel = 0; Thumb.ZIndex = 3
	Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
	local TS = Instance.new("UIStroke", Thumb); TS.Color = Color3.fromRGB(230, 60, 110); TS.Thickness = 2
	local SBtn = Instance.new("TextButton", SBg); SBtn.Size = UDim2.new(1, 0, 3, 0); SBtn.Position = UDim2.new(0, 0, -1, 0)
	SBtn.BackgroundTransparency = 1; SBtn.Text = ""
	local dragging = false; local lastCB = 0
	SBtn.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local mx = i.Position.X; local ap = SBg.AbsolutePosition.X; local as = SBg.AbsoluteSize.X
			local p = math.clamp((mx - ap)/as, 0, 1); local v = minVal + (maxVal - minVal) * p
			SF.Size = UDim2.new(p, 0, 1, 0); Thumb.Position = UDim2.new(p, -7, 0.5, -7)
			if maxVal - minVal > 100 then VL.Text = tostring(math.floor(v)) else VL.Text = string.format("%.2f", v) end
			local n = tick(); if callback and (n - lastCB) > 0.05 then lastCB = n; pcall(callback, v) end
		end
	end)
	return Con
end

local function createComingSoonPanel(parent, subtitle)
	local P = Instance.new("Frame", parent); P.Size = UDim2.new(1, 0, 1, -10); P.BackgroundColor3 = Color3.fromRGB(25, 25, 32); P.BorderSizePixel = 0
	Instance.new("UICorner", P).CornerRadius = UDim.new(0, 10)
	local L = Instance.new("TextLabel", P); L.Size = UDim2.new(1, 0, 1, 0); L.BackgroundTransparency = 1
	L.Text = "COMING SOON"; L.TextColor3 = Color3.fromRGB(230, 60, 110); L.TextSize = 32; L.Font = Enum.Font.GothamBold
	local S = Instance.new("TextLabel", P); S.Size = UDim2.new(1, 0, 0, 30); S.Position = UDim2.new(0, 0, 0.5, 30)
	S.BackgroundTransparency = 1; S.Text = subtitle or ""; S.TextColor3 = Color3.fromRGB(150, 150, 160); S.TextSize = 14; S.Font = Enum.Font.Gotham
end

-- ========== COLOR PICKER ==========
local activeColorPicker = nil
local function createColorPickerPopup(colorCircle, defaultColor, onColorChanged)
	if activeColorPicker and activeColorPicker.Parent then activeColorPicker:Destroy() end
	local originalColor = defaultColor
	local Popup = Instance.new("Frame")
	Popup.Size = UDim2.new(0, 260, 0, 340); Popup.Position = UDim2.new(0.5, -130, 0.5, -170)
	Popup.BackgroundColor3 = Color3.fromRGB(25, 25, 32); Popup.BorderSizePixel = 0; Popup.ZIndex = 200; Popup.Parent = ScreenGui
	Popup.Active = true; Popup.Draggable = true; activeColorPicker = Popup
	Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 10)
	local PS = Instance.new("UIStroke", Popup); PS.Color = Color3.fromRGB(230, 60, 110); PS.Thickness = 2
	local PT = Instance.new("TextLabel", Popup); PT.Size = UDim2.new(1, -40, 0, 30); PT.Position = UDim2.new(0, 10, 0, 5)
	PT.BackgroundTransparency = 1; PT.Text = "Color Picker"; PT.TextColor3 = Color3.fromRGB(255, 255, 255)
	PT.TextSize = 14; PT.Font = Enum.Font.GothamBold; PT.ZIndex = 201; PT.TextXAlignment = Enum.TextXAlignment.Left
	local CB = Instance.new("TextButton", Popup); CB.Size = UDim2.new(0, 25, 0, 25); CB.Position = UDim2.new(1, -30, 0, 5)
	CB.BackgroundTransparency = 1; CB.Text = "✕"; CB.TextColor3 = Color3.fromRGB(255, 100, 100); CB.TextSize = 16
	CB.Font = Enum.Font.GothamBold; CB.ZIndex = 201
	CB.MouseButton1Click:Connect(function() playClick(); Popup:Destroy(); activeColorPicker = nil end)
	local WS = 180
	local WC = Instance.new("Frame", Popup); WC.Size = UDim2.new(0, WS, 0, WS)
	WC.Position = UDim2.new(0.5, -WS/2, 0, 45); WC.BackgroundTransparency = 1; WC.ZIndex = 201
	Instance.new("UICorner", WC).CornerRadius = UDim.new(1, 0)
	local W = Instance.new("ImageLabel", WC); W.Size = UDim2.new(1, 0, 1, 0); W.BackgroundTransparency = 1
	W.Image = "rbxassetid://6020299385"; W.ZIndex = 201
	local WF = Instance.new("Frame", WC); WF.Size = UDim2.new(1, 0, 1, 0); WF.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WF.BorderSizePixel = 0; WF.ZIndex = 200; Instance.new("UICorner", WF).CornerRadius = UDim.new(1, 0)
	local WG = Instance.new("UIGradient", WF)
	WG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	local Mk = Instance.new("Frame", WC); Mk.Size = UDim2.new(0, 12, 0, 12); Mk.AnchorPoint = Vector2.new(0.5, 0.5)
	Mk.Position = UDim2.new(0.5, 0, 0.5, 0); Mk.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Mk.BorderSizePixel = 0; Mk.ZIndex = 205
	Instance.new("UICorner", Mk).CornerRadius = UDim.new(1, 0)
	local MkS = Instance.new("UIStroke", Mk); MkS.Color = Color3.fromRGB(0, 0, 0); MkS.Thickness = 2
	local Prev = Instance.new("Frame", Popup); Prev.Size = UDim2.new(1, -20, 0, 25); Prev.Position = UDim2.new(0, 10, 0, 235)
	Prev.BackgroundColor3 = defaultColor; Prev.BorderSizePixel = 0; Prev.ZIndex = 201
	Instance.new("UICorner", Prev).CornerRadius = UDim.new(0, 6)
	local BL = Instance.new("TextLabel", Popup); BL.Size = UDim2.new(0, 80, 0, 15); BL.Position = UDim2.new(0, 10, 0, 270)
	BL.BackgroundTransparency = 1; BL.Text = "Brightness"; BL.TextColor3 = Color3.fromRGB(200, 200, 210)
	BL.TextSize = 11; BL.Font = Enum.Font.Gotham; BL.TextXAlignment = Enum.TextXAlignment.Left; BL.ZIndex = 201
	local BBg = Instance.new("Frame", Popup); BBg.Size = UDim2.new(1, -20, 0, 8); BBg.Position = UDim2.new(0, 10, 0, 287)
	BBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60); BBg.BorderSizePixel = 0; BBg.ZIndex = 201
	Instance.new("UICorner", BBg).CornerRadius = UDim.new(1, 0)
	local BF = Instance.new("Frame", BBg); BF.Size = UDim2.new(1, 0, 1, 0); BF.BackgroundColor3 = Color3.fromRGB(230, 60, 110)
	BF.BorderSizePixel = 0; BF.ZIndex = 202; Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
	local BBtn = Instance.new("TextButton", BBg); BBtn.Size = UDim2.new(1, 0, 3, 0); BBtn.Position = UDim2.new(0, 0, -1, 0)
	BBtn.BackgroundTransparency = 1; BBtn.Text = ""; BBtn.ZIndex = 203
	local cH, cS, cV = Color3.toHSV(defaultColor)
	local function updatePrev() local c = Color3.fromHSV(cH, cS, cV); Prev.BackgroundColor3 = c; colorCircle.BackgroundColor3 = c; if onColorChanged then pcall(onColorChanged, c) end end
	local function setMarker(h, s) local a = h * math.pi * 2; local r = s * (WS/2 - 5); Mk.Position = UDim2.new(0.5, math.cos(a) * r, 0.5, math.sin(a) * r) end
	setMarker(cH, cS)
	local wD, bD = false, false
	local function updateWheel(pos)
		local cx = WC.AbsolutePosition.X + WC.AbsoluteSize.X/2; local cy = WC.AbsolutePosition.Y + WC.AbsoluteSize.Y/2
		local rx = pos.X - cx; local ry = pos.Y - cy
		local dist = math.sqrt(rx*rx + ry*ry); local mr = WS/2 - 5
		local cl = math.min(dist, mr); local rt = dist == 0 and 0 or cl/dist
		Mk.Position = UDim2.new(0.5, rx*rt, 0.5, ry*rt)
		local a = math.atan2(ry*rt, rx*rt); if a < 0 then a = a + math.pi*2 end
		cH = a / (math.pi*2); cS = math.min(cl/mr, 1); updatePrev()
	end
	local WBtn = Instance.new("TextButton", WC); WBtn.Size = UDim2.new(1, 0, 1, 0); WBtn.BackgroundTransparency = 1
	WBtn.Text = ""; WBtn.ZIndex = 204; Instance.new("UICorner", WBtn).CornerRadius = UDim.new(1, 0)
	WBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			wD = true; updateWheel(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)
	BBtn.MouseButton1Down:Connect(function() bD = true end)
	local cE = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then wD = false; bD = false end end)
	local cC = UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			if wD then updateWheel(Vector2.new(i.Position.X, i.Position.Y)) end
			if bD then local mx = i.Position.X; local ap = BBg.AbsolutePosition.X; local as = BBg.AbsoluteSize.X; local p = math.clamp((mx - ap)/as, 0, 1); BF.Size = UDim2.new(p, 0, 1, 0); cV = p; updatePrev() end
		end
	end)
	BF.Size = UDim2.new(cV, 0, 1, 0)
	local AB = Instance.new("TextButton", Popup); AB.Size = UDim2.new(0.5, -15, 0, 30); AB.Position = UDim2.new(0, 10, 1, -40)
	AB.BackgroundColor3 = Color3.fromRGB(230, 60, 110); AB.Text = "Apply"; AB.TextColor3 = Color3.fromRGB(255, 255, 255)
	AB.TextSize = 13; AB.Font = Enum.Font.GothamSemibold; AB.BorderSizePixel = 0; AB.AutoButtonColor = false; AB.ZIndex = 201
	Instance.new("UICorner", AB).CornerRadius = UDim.new(0, 6)
	AB.MouseButton1Click:Connect(function() playClick(); pcall(function() cE:Disconnect(); cC:Disconnect() end); Popup:Destroy(); activeColorPicker = nil end)
	local RB = Instance.new("TextButton", Popup); RB.Size = UDim2.new(0.5, -15, 0, 30); RB.Position = UDim2.new(0.5, 5, 1, -40)
	RB.BackgroundColor3 = Color3.fromRGB(60, 60, 70); RB.Text = "Reset"; RB.TextColor3 = Color3.fromRGB(255, 255, 255)
	RB.TextSize = 13; RB.Font = Enum.Font.GothamSemibold; RB.BorderSizePixel = 0; RB.AutoButtonColor = false; RB.ZIndex = 201
	Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)
	RB.MouseButton1Click:Connect(function() playClick(); cH, cS, cV = Color3.toHSV(originalColor); setMarker(cH, cS); BF.Size = UDim2.new(cV, 0, 1, 0); updatePrev() end)
end

local function createToggleWithColor(parent, name, defaultState, defaultColor, callback, colorCallback)
	local Con = Instance.new("Frame"); Con.Size = UDim2.new(1, 0, 0, 38); Con.BackgroundTransparency = 1; Con.Parent = parent
	local L = Instance.new("TextLabel", Con); L.Size = UDim2.new(1, -100, 1, 0); L.BackgroundTransparency = 1
	L.Text = name; L.TextColor3 = Color3.fromRGB(200, 200, 210); L.TextSize = 13; L.Font = Enum.Font.Gotham; L.TextXAlignment = Enum.TextXAlignment.Left
	local CC = Instance.new("Frame", Con); CC.Size = UDim2.new(0, 20, 0, 20); CC.Position = UDim2.new(1, -90, 0.5, -10)
	CC.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255); CC.BorderSizePixel = 0
	Instance.new("UICorner", CC).CornerRadius = UDim.new(1, 0)
	local ccs = Instance.new("UIStroke", CC); ccs.Color = Color3.fromRGB(80, 80, 90); ccs.Thickness = 1
	local CCB = Instance.new("TextButton", CC); CCB.Size = UDim2.new(1, 0, 1, 0); CCB.BackgroundTransparency = 1; CCB.Text = ""; CCB.ZIndex = 5
	CCB.MouseButton1Click:Connect(function() playClick(); createColorPickerPopup(CC, CC.BackgroundColor3, colorCallback) end)
	local Bg = Instance.new("Frame", Con); Bg.Size = UDim2.new(0, 38, 0, 20); Bg.Position = UDim2.new(1, -45, 0.5, -10)
	Bg.BackgroundColor3 = defaultState and Color3.fromRGB(230, 60, 110) or Color3.fromRGB(50, 50, 60); Bg.BorderSizePixel = 0
	Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
	local Ci = Instance.new("Frame", Bg); Ci.Size = UDim2.new(0, 14, 0, 14)
	Ci.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	Ci.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Ci.BorderSizePixel = 0
	Instance.new("UICorner", Ci).CornerRadius = UDim.new(1, 0)
	local Btn = Instance.new("TextButton", Bg); Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
	local state = defaultState or false
	Btn.MouseButton1Click:Connect(function()
		playClick(); state = not state
		if state then TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play()
			TweenService:Create(Ci, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
		else TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
			TweenService:Create(Ci, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play() end
		if callback then pcall(callback, state) end
	end)
	return Con
end

local function createColorOption(parent, name, defaultColor, colorCallback)
	local Con = Instance.new("Frame"); Con.Size = UDim2.new(1, 0, 0, 38); Con.BackgroundTransparency = 1; Con.Parent = parent
	local L = Instance.new("TextLabel", Con); L.Size = UDim2.new(1, -60, 1, 0); L.BackgroundTransparency = 1
	L.Text = name; L.TextColor3 = Color3.fromRGB(200, 200, 210); L.TextSize = 13; L.Font = Enum.Font.Gotham; L.TextXAlignment = Enum.TextXAlignment.Left
	local CC = Instance.new("Frame", Con); CC.Size = UDim2.new(0, 24, 0, 24); CC.Position = UDim2.new(1, -40, 0.5, -12)
	CC.BackgroundColor3 = defaultColor; CC.BorderSizePixel = 0
	Instance.new("UICorner", CC).CornerRadius = UDim.new(1, 0)
	local cs = Instance.new("UIStroke", CC); cs.Color = Color3.fromRGB(80, 80, 90); cs.Thickness = 1
	local CCB = Instance.new("TextButton", CC); CCB.Size = UDim2.new(1, 0, 1, 0); CCB.BackgroundTransparency = 1; CCB.Text = ""; CCB.ZIndex = 5
	CCB.MouseButton1Click:Connect(function() playClick(); createColorPickerPopup(CC, CC.BackgroundColor3, colorCallback) end)
	return Con
end

local function createBindButton(parent, name, defaultKey, callback)
	local Con = Instance.new("Frame"); Con.Size = UDim2.new(1, 0, 0, 40); Con.BackgroundTransparency = 1; Con.Parent = parent
	local Bg = Instance.new("Frame", Con); Bg.Size = UDim2.new(1, 0, 1, -4); Bg.Position = UDim2.new(0, 0, 0, 2)
	Bg.BackgroundColor3 = Color3.fromRGB(30, 30, 38); Bg.BorderSizePixel = 0
	Instance.new("UICorner", Bg).CornerRadius = UDim.new(0, 6)
	local L = Instance.new("TextLabel", Bg); L.Size = UDim2.new(1, -100, 1, 0); L.Position = UDim2.new(0, 12, 0, 0)
	L.BackgroundTransparency = 1; L.Text = name; L.TextColor3 = Color3.fromRGB(220, 220, 230)
	L.TextSize = 13; L.Font = Enum.Font.GothamSemibold; L.TextXAlignment = Enum.TextXAlignment.Left
	local Btn = Instance.new("TextButton", Bg); Btn.Size = UDim2.new(0, 80, 0, 25); Btn.Position = UDim2.new(1, -90, 0.5, -12)
	Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55); Btn.BorderSizePixel = 0
	Btn.Text = defaultKey and defaultKey.Name or "NONE"
	Btn.TextColor3 = Color3.fromRGB(230, 60, 110); Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold
	Btn.AutoButtonColor = false
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
	local waiting = false
	Btn.MouseButton1Click:Connect(function()
		playClick()
		if waiting then return end
		waiting = true
		Settings.waitingForBind = true
		Btn.Text = "..."
		Btn.TextColor3 = Color3.fromRGB(255, 200, 50)
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gp)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local key = input.KeyCode
				if key == Enum.KeyCode.Unknown then return end
				Btn.Text = key.Name
				Btn.TextColor3 = Color3.fromRGB(230, 60, 110)
				waiting = false
				Settings.waitingForBind = false
				if callback then pcall(callback, key) end
				conn:Disconnect()
			end
		end)
	end)
	return Con
end
-- ========== ESP SYSTEM ==========
local ESP = {
	settings = {
		enabled=false, box=false, skeleton=false, healthBar=false, armorBar=false,
		lookingAtMe=false, footsteps=false, inventoryESP=false, distanceESP=false,
		playerNames=false, snapline=false, throwables=false, wallcheck=false,
		drawPlayer=true, drawDead=false, drawSelf=false, distance=2500, textTransparency=1.0,
		visibleColor=Color3.fromRGB(255,85,0), friendColor=Color3.fromRGB(0,255,0),
		boxColor=Color3.fromRGB(255,255,255), skeletonColor=Color3.fromRGB(255,255,255),
		healthBarColor=Color3.fromRGB(0,255,0), armorBarColor=Color3.fromRGB(0,85,255),
		nameColor=Color3.fromRGB(255,255,255), snaplineColor=Color3.fromRGB(230,60,110),
	},
	elements = {}
}

local R15Bones = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6Bones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function createESPElements(tp)
	local e = {player=tp, box=Instance.new("Frame"), boxOutline=Instance.new("UIStroke"),
		name=Instance.new("TextLabel"), distance=Instance.new("TextLabel"),
		health=Instance.new("Frame"), healthBg=Instance.new("Frame"),
		armor=Instance.new("Frame"), armorBg=Instance.new("Frame"),
		snapline=Instance.new("Frame"), skeletonLines={}, inventory=Instance.new("TextLabel"),
		alert=Instance.new("TextLabel"), lastBoxPos=Vector2.new(0,0), lastBoxSize=Vector2.new(0,0), hasLastPos=false}
	e.box.BackgroundTransparency = 1; e.box.BorderSizePixel = 0; e.box.Parent = ESPGui; e.box.Visible = false
	e.boxOutline.Color = ESP.settings.boxColor; e.boxOutline.Thickness = 1.5; e.boxOutline.Parent = e.box
	e.name.Size = UDim2.new(0,200,0,20); e.name.BackgroundTransparency = 1; e.name.TextColor3 = ESP.settings.nameColor
	e.name.TextSize = 13; e.name.Font = Enum.Font.GothamBold; e.name.TextStrokeTransparency = 0.5; e.name.Parent = ESPGui; e.name.Visible = false
	e.distance.Size = UDim2.new(0,200,0,15); e.distance.BackgroundTransparency = 1; e.distance.TextColor3 = Color3.fromRGB(200,200,200)
	e.distance.TextSize = 11; e.distance.Font = Enum.Font.Gotham; e.distance.TextStrokeTransparency = 0.5; e.distance.Parent = ESPGui; e.distance.Visible = false
	e.inventory.Size = UDim2.new(0,300,0,15); e.inventory.BackgroundTransparency = 1; e.inventory.TextColor3 = Color3.fromRGB(255,200,100)
	e.inventory.TextSize = 10; e.inventory.Font = Enum.Font.Gotham; e.inventory.TextStrokeTransparency = 0.5
	e.inventory.TextXAlignment = Enum.TextXAlignment.Center; e.inventory.Parent = ESPGui; e.inventory.Visible = false
	e.alert.Size = UDim2.new(0,120,0,15); e.alert.BackgroundTransparency = 1; e.alert.TextColor3 = Color3.fromRGB(255,50,50)
	e.alert.TextSize = 12; e.alert.Font = Enum.Font.GothamBold; e.alert.Text = "⚠ WATCHING"; e.alert.TextStrokeTransparency = 0.5
	e.alert.Parent = ESPGui; e.alert.Visible = false
	e.healthBg.Size = UDim2.new(0,3,0,100); e.healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
	e.healthBg.BorderSizePixel = 0; e.healthBg.Parent = ESPGui; e.healthBg.Visible = false
	e.health.Size = UDim2.new(1,0,1,0); e.health.BackgroundColor3 = ESP.settings.healthBarColor
	e.health.BorderSizePixel = 0; e.health.AnchorPoint = Vector2.new(0,1); e.health.Position = UDim2.new(0,0,1,0); e.health.Parent = e.healthBg
	e.armorBg.Size = UDim2.new(0,3,0,100); e.armorBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
	e.armorBg.BorderSizePixel = 0; e.armorBg.Parent = ESPGui; e.armorBg.Visible = false
	e.armor.Size = UDim2.new(1,0,1,0); e.armor.BackgroundColor3 = ESP.settings.armorBarColor
	e.armor.BorderSizePixel = 0; e.armor.AnchorPoint = Vector2.new(0,1); e.armor.Position = UDim2.new(0,0,1,0); e.armor.Parent = e.armorBg
	e.snapline.Size = UDim2.new(0,2,0,100); e.snapline.AnchorPoint = Vector2.new(0.5,0.5)
	e.snapline.BackgroundColor3 = ESP.settings.snaplineColor; e.snapline.BorderSizePixel = 0; e.snapline.Parent = ESPGui; e.snapline.Visible = false
	return e
end

local function destroyESP(e)
	if not e then return end
	pcall(function()
		e.box:Destroy(); e.name:Destroy(); e.distance:Destroy(); e.healthBg:Destroy()
		e.armorBg:Destroy(); e.snapline:Destroy(); e.inventory:Destroy(); e.alert:Destroy()
		for _, l in pairs(e.skeletonLines) do if l then l:Destroy() end end
	end)
end

local function hideAll(e)
	e.box.Visible = false; e.name.Visible = false; e.distance.Visible = false
	e.healthBg.Visible = false; e.armorBg.Visible = false; e.snapline.Visible = false
	e.inventory.Visible = false; e.alert.Visible = false; e.hasLastPos = false
	for _, l in pairs(e.skeletonLines) do if l then l.Visible = false end end
end

local function drawSkelLine(e, idx, p1, p2, col)
	local l = e.skeletonLines[idx]
	if not l then l = Instance.new("Frame"); l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5,0.5); l.Parent = ESPGui; e.skeletonLines[idx] = l end
	local dx = p2.X - p1.X; local dy = p2.Y - p1.Y; local len = math.sqrt(dx*dx+dy*dy)
	l.Size = UDim2.new(0, len, 0, 2); l.Position = UDim2.new(0, (p1.X+p2.X)/2, 0, (p1.Y+p2.Y)/2)
	l.Rotation = math.deg(math.atan2(dy, dx)); l.BackgroundColor3 = col; l.Visible = true
end

local function isLookingAtMe(op)
	if not op.Character then return false end
	local h = op.Character:FindFirstChild("Head"); if not h then return false end
	local my = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not my then return false end
	return h.CFrame.LookVector:Dot((my.Position-h.Position).Unit) > 0.95
end

local function checkVis(from, to, ignore)
	local p = RaycastParams.new(); p.FilterDescendantsInstances = ignore; p.FilterType = Enum.RaycastFilterType.Exclude
	return workspace:Raycast(from, to-from, p) == nil
end

local function getUniqueItems(char, plr)
	local items, seen = {}, {}
	if char then for _, v in pairs(char:GetChildren()) do if v:IsA("Tool") and not seen[v.Name] then seen[v.Name] = true; table.insert(items, v.Name) end end end
	local bp = plr:FindFirstChild("Backpack")
	if bp then for _, v in pairs(bp:GetChildren()) do if v:IsA("Tool") and not seen[v.Name] then seen[v.Name] = true; table.insert(items, v.Name) end end end
	return items
end

local function lerp(a,b,t) return a+(b-a)*t end
local lastInvUpdate = {}

-- ========== ONLINE SYSTEM ==========
local OnlineSystem = {
	friends = {}, selectedPlayer = nil, spectatingPlayer = nil,
	originalCameraSubject = nil, playerListItems = {},
	frozenPlayers = {}, hiddenPlayers = {}, namedPlayers = {}, tagConnections = {},
	infoUpdateConnection = nil, refreshList = nil,
}
local function isFriend(playerName) return OnlineSystem.friends[playerName] == true end
local function addFriend(playerName) OnlineSystem.friends[playerName] = true end
local function removeFriend(playerName) OnlineSystem.friends[playerName] = nil end

RunService.RenderStepped:Connect(function(dt)
	if not ESP.settings.enabled then
		for _, e in pairs(ESP.elements) do hideAll(e) end; return
	end
	local myChar = player.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local sm = math.min(dt*25, 1)
	for _, tp in pairs(Players:GetPlayers()) do
		if tp == player and not ESP.settings.drawSelf then if ESP.elements[tp] then hideAll(ESP.elements[tp]) end; continue end
		if not tp.Character then if ESP.elements[tp] then hideAll(ESP.elements[tp]) end; continue end
		local char = tp.Character; local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		local head = char:FindFirstChild("Head"); local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not head or not hum then if ESP.elements[tp] then hideAll(ESP.elements[tp]) end; continue end
		if not ESP.elements[tp] then ESP.elements[tp] = createESPElements(tp) end
		local e = ESP.elements[tp]
		local isDead = hum.Health <= 0
		if isDead and not ESP.settings.drawDead then hideAll(e); continue end
		if not ESP.settings.drawPlayer and not (tp == player and ESP.settings.drawSelf) then hideAll(e); continue end
		local dist = 0; if myHRP then dist = (hrp.Position - myHRP.Position).Magnitude end
		if dist > ESP.settings.distance then hideAll(e); continue end
		if ESP.settings.wallcheck and myHRP and myChar then
			if not checkVis(Camera.CFrame.Position, hrp.Position, {myChar, char}) then hideAll(e); continue end
		end
		local hs, hOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
		local fs = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
		local rs, rOn = Camera:WorldToViewportPoint(hrp.Position)
		if not hOn or not rOn then hideAll(e); continue end
		local rBH = math.abs(hs.Y - fs.Y); local rBW = rBH * 0.55; local rBX = rs.X - rBW/2; local rBY = hs.Y
		local tP = Vector2.new(rBX, rBY); local tS = Vector2.new(rBW, rBH)
		local fP, fS
		if e.hasLastPos then
			fP = Vector2.new(lerp(e.lastBoxPos.X, tP.X, sm), lerp(e.lastBoxPos.Y, tP.Y, sm))
			fS = Vector2.new(lerp(e.lastBoxSize.X, tS.X, sm), lerp(e.lastBoxSize.Y, tS.Y, sm))
		else fP = tP; fS = tS; e.hasLastPos = true end
		e.lastBoxPos = fP; e.lastBoxSize = fS
		local bX, bY, bW, bH = fP.X, fP.Y, fS.X, fS.Y; local cX = bX + bW/2
		local drawColor = ESP.settings.boxColor
		if isFriend(tp.Name) then drawColor = ESP.settings.friendColor end
		if ESP.settings.box then e.box.Position = UDim2.new(0,bX,0,bY); e.box.Size = UDim2.new(0,bW,0,bH); e.boxOutline.Color = drawColor; e.box.Visible = true else e.box.Visible = false end
		if ESP.settings.playerNames then e.name.Position = UDim2.new(0,cX-100,0,bY-20); e.name.Text = tp.Name; e.name.TextColor3 = ESP.settings.nameColor; e.name.Visible = true else e.name.Visible = false end
		if ESP.settings.distanceESP then e.distance.Position = UDim2.new(0,cX-100,0,bY+bH+2); e.distance.Text = string.format("[%dm]", math.floor(dist)); e.distance.Visible = true else e.distance.Visible = false end
		if ESP.settings.inventoryESP then
			local now = tick(); local lu = lastInvUpdate[tp] or 0
			if now - lu > 0.5 then lastInvUpdate[tp] = now
				local items = getUniqueItems(char, tp)
				e.inventory.Text = #items > 0 and "["..table.concat(items,", ").."]" or ""
			end
			if e.inventory.Text ~= "" then e.inventory.Position = UDim2.new(0,cX-150,0,bY+bH+(ESP.settings.distanceESP and 20 or 5)); e.inventory.Visible = true else e.inventory.Visible = false end
		else e.inventory.Visible = false end
		if ESP.settings.lookingAtMe and isLookingAtMe(tp) then e.alert.Position = UDim2.new(0,cX-60,0,bY-35); e.alert.Visible = true else e.alert.Visible = false end
		if ESP.settings.healthBar then e.healthBg.Position = UDim2.new(0,bX-6,0,bY); e.healthBg.Size = UDim2.new(0,3,0,bH); e.health.Size = UDim2.new(1,0,hum.Health/hum.MaxHealth,0); e.health.BackgroundColor3 = ESP.settings.healthBarColor; e.healthBg.Visible = true else e.healthBg.Visible = false end
		if ESP.settings.armorBar then e.armorBg.Position = UDim2.new(0,bX+bW+3,0,bY); e.armorBg.Size = UDim2.new(0,3,0,bH); local av = char:FindFirstChild("Armor"); local ap = 1.0; if av and av:IsA("NumberValue") then ap = av.Value/100 end; e.armor.Size = UDim2.new(1,0,ap,0); e.armor.BackgroundColor3 = ESP.settings.armorBarColor; e.armorBg.Visible = true else e.armorBg.Visible = false end
		if ESP.settings.snapline then local sW = Camera.ViewportSize.X; local sH = Camera.ViewportSize.Y; local sX = sW/2; local sY = sH; local eX = cX; local eY = bY+bH/2; local dx = eX-sX; local dy = eY-sY; local len = math.sqrt(dx*dx+dy*dy); e.snapline.Size = UDim2.new(0,2,0,len); e.snapline.Position = UDim2.new(0,(sX+eX)/2,0,(sY+eY)/2); e.snapline.Rotation = math.deg(math.atan2(dy,dx))-90; e.snapline.BackgroundColor3 = ESP.settings.snaplineColor; e.snapline.Visible = true else e.snapline.Visible = false end
		if ESP.settings.skeleton then
			local isR15 = char:FindFirstChild("UpperTorso") ~= nil; local bones = isR15 and R15Bones or R6Bones
			for i, pair in ipairs(bones) do
				local p1 = char:FindFirstChild(pair[1]); local p2 = char:FindFirstChild(pair[2])
				if p1 and p2 then local s1,o1 = Camera:WorldToViewportPoint(p1.Position); local s2,o2 = Camera:WorldToViewportPoint(p2.Position)
					if o1 and o2 then drawSkelLine(e,i,Vector2.new(s1.X,s1.Y),Vector2.new(s2.X,s2.Y),ESP.settings.skeletonColor)
					else if e.skeletonLines[i] then e.skeletonLines[i].Visible = false end end
				else if e.skeletonLines[i] then e.skeletonLines[i].Visible = false end end
			end
		else for _,l in pairs(e.skeletonLines) do if l then l.Visible = false end end end
	end
	for plr,e in pairs(ESP.elements) do
		if not plr.Parent then destroyESP(e); ESP.elements[plr] = nil; lastInvUpdate[plr] = nil end
	end
end)

Players.PlayerRemoving:Connect(function(p) if ESP.elements[p] then destroyESP(ESP.elements[p]); ESP.elements[p] = nil end; lastInvUpdate[p] = nil end)

-- ========== SELF SYSTEM ==========
local Self = {
	settings = {godMode=false, semiGodMode=false, noclip=false, damageReducer=false, invisible=false, infiniteStamina=false, fastRun=false, noCollision=false, bindedHeal=false, killerMan=false, spinbot=false, antiAfk=false, noFall=false, bigHead=false, noclipSpeed=3.0, walkSpeed=16, jumpPower=50, damageReducerAmount=50, killerRange=30, spinSpeed=30},
	connections={}, DEFAULT_WALK_SPEED=16, DEFAULT_JUMP_POWER=50, savedInvisData={}, savedCollisions={},
}

local function getMyChar() return player.Character end
local function getMyHum() local c = getMyChar(); if c then return c:FindFirstChildOfClass("Humanoid") end end
local function getMyHRP() local c = getMyChar(); if c then return c:FindFirstChild("HumanoidRootPart") end end

task.spawn(function()
	task.wait(2)
	local hum = getMyHum()
	if hum then Self.DEFAULT_WALK_SPEED = hum.WalkSpeed; Self.DEFAULT_JUMP_POWER = hum.JumpPower; Self.settings.walkSpeed = hum.WalkSpeed; Self.settings.jumpPower = hum.JumpPower end
end)

local function toggleGodMode(s) if s then Self.connections.godMode = RunService.Heartbeat:Connect(function() local h = getMyHum(); if h then h.Health = h.MaxHealth end end) else if Self.connections.godMode then Self.connections.godMode:Disconnect(); Self.connections.godMode = nil end end end
local function toggleSemiGod(s) if s then Self.connections.semiGod = RunService.Heartbeat:Connect(function() local h = getMyHum(); if h and h.Health < h.MaxHealth * 0.5 then h.Health = h.MaxHealth end end) else if Self.connections.semiGod then Self.connections.semiGod:Disconnect(); Self.connections.semiGod = nil end end end

local noclipBG, noclipBV = nil, nil
local function toggleNoclip(state)
	local function setupFlight()
		local hrp = getMyHRP(); if not hrp then return end
		if noclipBG then pcall(function() noclipBG:Destroy() end) end
		if noclipBV then pcall(function() noclipBV:Destroy() end) end
		noclipBG = Instance.new("BodyGyro"); noclipBG.P = 9e4; noclipBG.MaxTorque = Vector3.new(9e9,9e9,9e9); noclipBG.CFrame = hrp.CFrame; noclipBG.Parent = hrp
		noclipBV = Instance.new("BodyVelocity"); noclipBV.Velocity = Vector3.zero; noclipBV.MaxForce = Vector3.new(9e9,9e9,9e9); noclipBV.P = 1250; noclipBV.Parent = hrp
	end
	if state then setupFlight()
		Self.connections.noclip = RunService.Stepped:Connect(function()
			local char = getMyChar(); if not char then return end
			for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end end
			local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
			if not hrp:FindFirstChild("BodyGyro") then setupFlight() end
			local cam = workspace.CurrentCamera; if not cam then return end
			local dir = Vector3.zero; local cf = cam.CFrame; local speed = Self.settings.noclipSpeed * 20
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
			if dir.Magnitude > 0 then dir = dir.Unit * speed end
			if noclipBV and noclipBV.Parent then noclipBV.Velocity = dir end
			if noclipBG and noclipBG.Parent then noclipBG.CFrame = cam.CFrame end
		end)
	else
		if Self.connections.noclip then Self.connections.noclip:Disconnect(); Self.connections.noclip = nil end
		if noclipBG then pcall(function() noclipBG:Destroy() end); noclipBG = nil end
		if noclipBV then pcall(function() noclipBV:Destroy() end); noclipBV = nil end
		local char = getMyChar()
		if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then pcall(function() p.CanCollide = true end) end end end
	end
end

local function toggleInvisible(state)
	local char = getMyChar(); if not char then return end
	if state then
		Self.savedInvisData = {parts={}, accessories={}, humName=nil, humHealth=nil}
		for _,p in pairs(char:GetDescendants()) do
			if p:IsA("BasePart") then Self.savedInvisData.parts[p] = {t=p.Transparency, lt=p.LocalTransparencyModifier}; pcall(function() p.Transparency = 1; p.LocalTransparencyModifier = 1 end)
			elseif p:IsA("Decal") or p:IsA("Texture") then Self.savedInvisData.parts[p] = {t=p.Transparency}; pcall(function() p.Transparency = 1 end) end
		end
		for _,acc in pairs(char:GetChildren()) do if acc:IsA("Accessory") then local h = acc:FindFirstChild("Handle"); if h then Self.savedInvisData.accessories[h] = h.Transparency; pcall(function() h.Transparency = 1 end) end end end
		local hum = getMyHum()
		if hum then Self.savedInvisData.humName = hum.NameDisplayDistance; Self.savedInvisData.humHealth = hum.HealthDisplayDistance; pcall(function() hum.NameDisplayDistance = 0; hum.HealthDisplayDistance = 0 end) end
	else
		if Self.savedInvisData and Self.savedInvisData.parts then
			for obj,data in pairs(Self.savedInvisData.parts) do
				if obj and obj.Parent then pcall(function() obj.Transparency = data.t; if obj:IsA("BasePart") then obj.LocalTransparencyModifier = data.lt or 0 end end) end
			end
		end
		if Self.savedInvisData and Self.savedInvisData.accessories then
			for h,v in pairs(Self.savedInvisData.accessories) do if h and h.Parent then pcall(function() h.Transparency = v end) end end
		end
		local hum = getMyHum()
		if hum and Self.savedInvisData then pcall(function() hum.NameDisplayDistance = Self.savedInvisData.humName or 100; hum.HealthDisplayDistance = Self.savedInvisData.humHealth or 100 end) end
		Self.savedInvisData = {}
	end
end

local function toggleFastRun(s) local h = getMyHum(); if not h then return end; h.WalkSpeed = s and Self.settings.walkSpeed * 2.5 or Self.settings.walkSpeed end
local function toggleInfiniteStamina(s) if s then Self.connections.stamina = RunService.Heartbeat:Connect(function() local c = getMyChar(); if not c then return end; local st = c:FindFirstChild("Stamina") or (c:FindFirstChild("Values") and c.Values:FindFirstChild("Stamina")); if st and st:IsA("NumberValue") then st.Value = 100 end end) else if Self.connections.stamina then Self.connections.stamina:Disconnect(); Self.connections.stamina = nil end end end

local function toggleNoCollision(state)
	if state then
		Self.savedCollisions = {}
		local char = getMyChar()
		if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then Self.savedCollisions[p] = p.CanCollide end end end
		Self.connections.noCollision = RunService.Stepped:Connect(function()
			local char = getMyChar(); if not char then return end
			for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end end
		end)
	else
		if Self.connections.noCollision then Self.connections.noCollision:Disconnect(); Self.connections.noCollision = nil end
		task.wait(0.1)
		local char = getMyChar()
		if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then local o = Self.savedCollisions[p]; if o ~= nil then pcall(function() p.CanCollide = o end) elseif p.Name == "HumanoidRootPart" or p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "LowerTorso" then pcall(function() p.CanCollide = true end) end end end end
		Self.savedCollisions = {}
	end
end

local function toggleDamageReducer(s) if s then Self.connections.dmgReducer = RunService.Heartbeat:Connect(function() local h = getMyHum(); if not h then return end; local t = (100 - Self.settings.damageReducerAmount) / 100; if h.Health < h.MaxHealth * t then h.Health = h.MaxHealth * t end end) else if Self.connections.dmgReducer then Self.connections.dmgReducer:Disconnect(); Self.connections.dmgReducer = nil end end end

local function toggleKillerMan(state)
	if state then
		Self.connections.killer = RunService.Heartbeat:Connect(function()
			local myHRP = getMyHRP(); if not myHRP then return end
			for _,plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character and not isFriend(plr.Name) then
					local char = plr.Character
					local tHRP = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
					local tHum = char:FindFirstChildOfClass("Humanoid")
					if tHRP and tHum and tHum.Health > 0 then
						local dist = (tHRP.Position - myHRP.Position).Magnitude
						if dist <= Self.settings.killerRange then
							local myPos = myHRP.CFrame
							pcall(function() myHRP.CFrame = tHRP.CFrame * CFrame.new(0,0,-2) end)
							task.wait()
							pcall(function() tHum.Health = -100 end)
							pcall(function() tHum:TakeDamage(tHum.MaxHealth * 100) end)
							pcall(function() char:BreakJoints() end)
							pcall(function() local head = char:FindFirstChild("Head"); if head then head:Destroy() end end)
							pcall(function() myHRP.CFrame = myPos end)
						end
					end
				end
			end
		end)
	else if Self.connections.killer then Self.connections.killer:Disconnect(); Self.connections.killer = nil end end
end

local function toggleSpinbot(s) if s then Self.connections.spinbot = RunService.Heartbeat:Connect(function(dt) local h = getMyHRP(); if not h then return end; h.CFrame = h.CFrame * CFrame.Angles(0, math.rad(Self.settings.spinSpeed * dt * 50), 0) end) else if Self.connections.spinbot then Self.connections.spinbot:Disconnect(); Self.connections.spinbot = nil end end end
local function toggleAntiAfk(s) if s then local vu = game:GetService("VirtualUser"); Self.connections.antiAfk = RunService.Stepped:Connect(function() pcall(function() vu:CaptureController() end); pcall(function() vu:ClickButton2(Vector2.new()) end) end) else if Self.connections.antiAfk then Self.connections.antiAfk:Disconnect(); Self.connections.antiAfk = nil end end end
local function toggleNoFall(s) if s then Self.connections.noFall = RunService.Heartbeat:Connect(function() local h = getMyHum(); if h then pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end); pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end) end end) else if Self.connections.noFall then Self.connections.noFall:Disconnect(); Self.connections.noFall = nil end; local h = getMyHum(); if h then pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end); pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true) end) end end end
local function toggleBigHead(s) if s then Self.connections.bigHead = RunService.Heartbeat:Connect(function() for _,plr in pairs(Players:GetPlayers()) do if plr ~= player and plr.Character then local h = plr.Character:FindFirstChild("Head"); if h then pcall(function() h.Size = Vector3.new(5,5,5) end) end end end end) else if Self.connections.bigHead then Self.connections.bigHead:Disconnect(); Self.connections.bigHead = nil end; for _,plr in pairs(Players:GetPlayers()) do if plr ~= player and plr.Character then local h = plr.Character:FindFirstChild("Head"); if h then pcall(function() h.Size = Vector3.new(1.2,1.2,1.2) end) end end end end end

local function healSelf() local h = getMyHum(); if h then h.Health = h.MaxHealth end end
local function respawnSelf() local c = getMyChar(); if c then c:BreakJoints() end end
local function reviveSelf() local h = getMyHum(); if h then h.Health = h.MaxHealth end; local hrp = getMyHRP(); if hrp then hrp.Velocity = Vector3.new(0,50,0) end end
local function randomOutfit() local ids = {2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000}; local h = getMyHum(); if h then pcall(function() local d = Players:GetHumanoidDescriptionFromUserId(ids[math.random(#ids)]); h:ApplyDescription(d) end) end end
local function startSoloSession() pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end

local function crashSelf()
	showNotification("Crashing YOU from server...", "warning")
	task.wait(0.5)
	pcall(function() player:Kick("SBX - You crashed yourself") end)
	pcall(function() TeleportService:Teleport(0, player) end)
	task.spawn(function()
		task.wait(0.3)
		pcall(function() while true do Instance.new("Part").Parent = workspace end end)
	end)
end

-- ========== WEAPON SYSTEM ==========
local Weapon = {settings = {noRecoil=false, noSpread=false, fastReload=false, rangeMultiplier=false, weaponSize=false, rapidFire=false, infiniteAmmo=false, freezeAmmo=false, explosiveAmmo=false, damageMultiplier=false, rangeMultValue=5.0, weaponSizeValue=2.0, rapidFireDelay=0.05, damageMultValue=5.0, reloadSpeedMult=5.0}, connections = {}, savedWeaponData = {}}

local function getEquippedWeapon() local char = getMyChar(); if not char then return nil end; for _,v in pairs(char:GetChildren()) do if v:IsA("Tool") then return v end end; return nil end
local function getAllWeapons() local weapons = {}; local char = getMyChar(); if char then for _,v in pairs(char:GetChildren()) do if v:IsA("Tool") then table.insert(weapons, v) end end end; local bp = player:FindFirstChild("Backpack"); if bp then for _,v in pairs(bp:GetChildren()) do if v:IsA("Tool") then table.insert(weapons, v) end end end; return weapons end
local function findValue(tool, names) for _,name in ipairs(names) do local v = tool:FindFirstChild(name); if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then return v end end; for _,child in pairs(tool:GetDescendants()) do if child:IsA("NumberValue") or child:IsA("IntValue") then for _,name in ipairs(names) do if child.Name:lower() == name:lower() then return child end end end end; return nil end
local function saveWeaponData(tool)
	if Weapon.savedWeaponData[tool] then return end
	Weapon.savedWeaponData[tool] = {}
	local ammoV = findValue(tool, {"Ammo","ammo","Bullets","bullets","CurrentAmmo"}); local rangeV = findValue(tool, {"Range","range","MaxDistance","MaxRange"}); local damageV = findValue(tool, {"Damage","damage","DMG","dmg"}); local spreadV = findValue(tool, {"Spread","spread","Accuracy"}); local recoilV = findValue(tool, {"Recoil","recoil"}); local reloadV = findValue(tool, {"ReloadTime","reloadTime","reload_time","ReloadSpeed"}); local fireRateV = findValue(tool, {"FireRate","firerate","fire_rate","Cooldown","cooldown","Delay"})
	if ammoV then Weapon.savedWeaponData[tool].ammo = ammoV.Value end
	if rangeV then Weapon.savedWeaponData[tool].range = rangeV.Value end
	if damageV then Weapon.savedWeaponData[tool].damage = damageV.Value end
	if spreadV then Weapon.savedWeaponData[tool].spread = spreadV.Value end
	if recoilV then Weapon.savedWeaponData[tool].recoil = recoilV.Value end
	if reloadV then Weapon.savedWeaponData[tool].reload = reloadV.Value end
	if fireRateV then Weapon.savedWeaponData[tool].fireRate = fireRateV.Value end
	Weapon.savedWeaponData[tool].partSizes = {}
	for _,p in pairs(tool:GetDescendants()) do if p:IsA("BasePart") then Weapon.savedWeaponData[tool].partSizes[p] = p.Size end end
end

local function applyWeaponMods()
	local weapons = getAllWeapons()
	for _,tool in ipairs(weapons) do
		saveWeaponData(tool)
		local ammoV = findValue(tool, {"Ammo","ammo","Bullets","bullets","CurrentAmmo"}); local rangeV = findValue(tool, {"Range","range","MaxDistance","MaxRange"}); local damageV = findValue(tool, {"Damage","damage","DMG","dmg"}); local spreadV = findValue(tool, {"Spread","spread","Accuracy"}); local recoilV = findValue(tool, {"Recoil","recoil"}); local reloadV = findValue(tool, {"ReloadTime","reloadTime","reload_time","ReloadSpeed"}); local fireRateV = findValue(tool, {"FireRate","firerate","fire_rate","Cooldown","cooldown","Delay"})
		if Weapon.settings.infiniteAmmo and ammoV then pcall(function() ammoV.Value = 9999 end) end
		if Weapon.settings.freezeAmmo and ammoV then pcall(function() ammoV.Value = Weapon.savedWeaponData[tool].ammo or 9999 end) end
		if Weapon.settings.noRecoil and recoilV then pcall(function() recoilV.Value = 0 end) end
		if Weapon.settings.noSpread and spreadV then pcall(function() spreadV.Value = 0 end) end
		if Weapon.settings.fastReload and reloadV then pcall(function() reloadV.Value = 0.01 end) end
		if Weapon.settings.damageMultiplier and damageV then local orig = Weapon.savedWeaponData[tool].damage or damageV.Value; pcall(function() damageV.Value = orig * Weapon.settings.damageMultValue end) end
		if Weapon.settings.rangeMultiplier and rangeV then local orig = Weapon.savedWeaponData[tool].range or rangeV.Value; pcall(function() rangeV.Value = orig * Weapon.settings.rangeMultValue end) end
		if Weapon.settings.rapidFire and fireRateV then pcall(function() fireRateV.Value = Weapon.settings.rapidFireDelay end) end
		if Weapon.settings.weaponSize then for _,p in pairs(tool:GetDescendants()) do if p:IsA("BasePart") then local orig = Weapon.savedWeaponData[tool].partSizes[p] or p.Size; pcall(function() p.Size = orig * Weapon.settings.weaponSizeValue end) end end end
	end
end

local function restoreWeaponData(tool)
	local saved = Weapon.savedWeaponData[tool]; if not saved then return end
	local ammoV = findValue(tool, {"Ammo","ammo","Bullets","bullets","CurrentAmmo"}); local rangeV = findValue(tool, {"Range","range","MaxDistance","MaxRange"}); local damageV = findValue(tool, {"Damage","damage","DMG","dmg"}); local spreadV = findValue(tool, {"Spread","spread","Accuracy"}); local recoilV = findValue(tool, {"Recoil","recoil"}); local reloadV = findValue(tool, {"ReloadTime","reloadTime","reload_time","ReloadSpeed"}); local fireRateV = findValue(tool, {"FireRate","firerate","fire_rate","Cooldown","cooldown","Delay"})
	pcall(function()
		if ammoV and saved.ammo then ammoV.Value = saved.ammo end
		if rangeV and saved.range then rangeV.Value = saved.range end
		if damageV and saved.damage then damageV.Value = saved.damage end
		if spreadV and saved.spread then spreadV.Value = saved.spread end
		if recoilV and saved.recoil then recoilV.Value = saved.recoil end
		if reloadV and saved.reload then reloadV.Value = saved.reload end
		if fireRateV and saved.fireRate then fireRateV.Value = saved.fireRate end
	end)
	if saved.partSizes then for p, size in pairs(saved.partSizes) do if p and p.Parent then pcall(function() p.Size = size end) end end end
end

local weaponLoopStarted = false
local function startWeaponLoop() if weaponLoopStarted then return end; weaponLoopStarted = true; Weapon.connections.mainLoop = RunService.Heartbeat:Connect(function() local anyActive = Weapon.settings.noRecoil or Weapon.settings.noSpread or Weapon.settings.fastReload or Weapon.settings.rangeMultiplier or Weapon.settings.weaponSize or Weapon.settings.rapidFire or Weapon.settings.infiniteAmmo or Weapon.settings.freezeAmmo or Weapon.settings.damageMultiplier; if anyActive then applyWeaponMods() end end) end
local function stopWeaponLoop() if Weapon.connections.mainLoop then Weapon.connections.mainLoop:Disconnect(); Weapon.connections.mainLoop = nil; weaponLoopStarted = false end end
local function updateWeaponSystem() local anyActive = Weapon.settings.noRecoil or Weapon.settings.noSpread or Weapon.settings.fastReload or Weapon.settings.rangeMultiplier or Weapon.settings.weaponSize or Weapon.settings.rapidFire or Weapon.settings.infiniteAmmo or Weapon.settings.freezeAmmo or Weapon.settings.damageMultiplier; if anyActive then startWeaponLoop() else stopWeaponLoop(); for tool,_ in pairs(Weapon.savedWeaponData) do if tool and tool.Parent then restoreWeaponData(tool) end end end end

local function toggleExplosiveAmmo(state)
	if state then
		Weapon.connections.explosiveClick = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local tool = getEquippedWeapon()
				if tool and Weapon.settings.explosiveAmmo then
					local mouse = player:GetMouse()
					if mouse.Target then
						local explosion = Instance.new("Explosion")
						explosion.Position = mouse.Hit.Position
						explosion.BlastRadius = 15; explosion.BlastPressure = 500000
						explosion.DestroyJointRadiusPercent = 1; explosion.Parent = workspace
					end
				end
			end
		end)
	else
		if Weapon.connections.explosiveClick then Weapon.connections.explosiveClick:Disconnect(); Weapon.connections.explosiveClick = nil end
	end
end
-- ========== ONLINE PLAYER FUNCTIONS ==========
local function teleportToPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("Player has no character", "error"); return end
	local myHRP = getMyHRP()
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
	if myHRP and targetHRP then
		pcall(function() myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 3, 3) end)
		showNotification("Teleported to " .. targetPlayer.Name, "success")
	else showNotification("Cannot teleport - missing parts", "error") end
end

local function startSpectate(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("Player has no character", "error"); return false end
	local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not targetHum then showNotification("Cannot spectate - no humanoid", "error"); return false end
	if not OnlineSystem.originalCameraSubject then OnlineSystem.originalCameraSubject = Camera.CameraSubject end
	Camera.CameraSubject = targetHum
	OnlineSystem.spectatingPlayer = targetPlayer
	showNotification("Spectating " .. targetPlayer.Name, "info"); return true
end

local function stopSpectate()
	local myHum = getMyHum()
	if myHum then Camera.CameraSubject = myHum
	elseif OnlineSystem.originalCameraSubject then pcall(function() Camera.CameraSubject = OnlineSystem.originalCameraSubject end) end
	OnlineSystem.spectatingPlayer = nil
	showNotification("Stopped spectating", "info")
end

local function freezePlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local char = targetPlayer.Character; local frozen = {}
	for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then frozen[p] = p.Anchored; pcall(function() p.Anchored = true end) end end
	OnlineSystem.frozenPlayers[targetPlayer] = frozen
	showNotification("Frozen: " .. targetPlayer.Name, "success")
end

local function unfreezePlayer(targetPlayer)
	if not targetPlayer then return end
	local saved = OnlineSystem.frozenPlayers[targetPlayer]
	if targetPlayer.Character then
		for _, p in pairs(targetPlayer.Character:GetDescendants()) do
			if p:IsA("BasePart") then local orig = saved and saved[p]; pcall(function() p.Anchored = orig or false end) end
		end
	end
	OnlineSystem.frozenPlayers[targetPlayer] = nil
	showNotification("Unfrozen: " .. targetPlayer.Name, "info")
end

local function hidePlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local char = targetPlayer.Character; local hidden = {}
	for _, p in pairs(char:GetDescendants()) do
		if p:IsA("BasePart") then hidden[p] = p.LocalTransparencyModifier; pcall(function() p.LocalTransparencyModifier = 1 end)
		elseif p:IsA("Decal") or p:IsA("Texture") then hidden[p] = p.Transparency; pcall(function() p.Transparency = 1 end) end
	end
	OnlineSystem.hiddenPlayers[targetPlayer] = hidden
	showNotification("Hidden: " .. targetPlayer.Name, "success")
end

local function showPlayerFn(targetPlayer)
	if not targetPlayer then return end
	local saved = OnlineSystem.hiddenPlayers[targetPlayer]
	if targetPlayer.Character and saved then
		for obj, val in pairs(saved) do
			if obj and obj.Parent then pcall(function() if obj:IsA("BasePart") then obj.LocalTransparencyModifier = val else obj.Transparency = val end end) end
		end
	end
	OnlineSystem.hiddenPlayers[targetPlayer] = nil
	showNotification("Shown: " .. targetPlayer.Name, "info")
end

local function tryCrashPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	pcall(function()
		for i = 1, 50 do
			local p = Instance.new("Part"); p.Size = Vector3.new(1,1,1)
			p.CFrame = targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.HumanoidRootPart.CFrame or CFrame.new()
			p.Parent = workspace; task.wait(); pcall(function() p:Destroy() end)
		end
	end)
	showNotification("Crash attempt on " .. targetPlayer.Name, "warning")
end

local function clonePlayerChar(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character to clone", "error"); return end
	local char = targetPlayer.Character; local clone = char:Clone(); clone.Parent = workspace
	local hrp = clone:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = true end
	local hum = clone:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
	showNotification("Cloned: " .. targetPlayer.Name, "success")
	task.delay(30, function() pcall(function() clone:Destroy() end) end)
end

local function stunPlayer(targetPlayer, duration)
	duration = duration or 5
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local char = targetPlayer.Character; local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local oldWS = hum.WalkSpeed; local oldJP = hum.JumpPower
		pcall(function() hum.WalkSpeed = 0; hum.JumpPower = 0 end)
		showNotification("Stunned " .. targetPlayer.Name .. " for " .. duration .. "s", "warning")
		task.delay(duration, function() if hum and hum.Parent then pcall(function() hum.WalkSpeed = oldWS; hum.JumpPower = oldJP end); showNotification(targetPlayer.Name .. " unstunned", "info") end end)
	else showNotification("No humanoid", "error") end
end

local function flingPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		pcall(function()
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.new(math.random(-500,500), math.random(300,800), math.random(-500,500))
			bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.P = 9e9; bv.Parent = hrp
			task.delay(0.2, function() pcall(function() bv:Destroy() end) end)
		end)
		showNotification("Flung: " .. targetPlayer.Name, "success")
	else showNotification("No HumanoidRootPart", "error") end
end

local function bringPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local myHRP = getMyHRP(); if not myHRP then showNotification("You have no HRP", "error"); return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
	if targetHRP then pcall(function() targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -4) end); showNotification("Brought: " .. targetPlayer.Name, "success")
	else showNotification("Target has no HRP", "error") end
end

local loopFlingConnections = {}
local function toggleLoopFling(targetPlayer, state)
	local key = targetPlayer.Name
	if loopFlingConnections[key] then loopFlingConnections[key]:Disconnect(); loopFlingConnections[key] = nil end
	if state then
		loopFlingConnections[key] = RunService.Heartbeat:Connect(function()
			if not targetPlayer or not targetPlayer.Character then return end
			local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				pcall(function()
					local bv = hrp:FindFirstChild("SBX_LoopFling") or Instance.new("BodyVelocity")
					bv.Name = "SBX_LoopFling"
					bv.Velocity = Vector3.new(math.random(-1000,1000), math.random(500,2000), math.random(-1000,1000))
					bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.P = 9e9; bv.Parent = hrp
				end)
			end
		end)
		showNotification("Loop Fling ON: " .. targetPlayer.Name, "warning")
	else
		if targetPlayer and targetPlayer.Character then
			local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then pcall(function() local bv = hrp:FindFirstChild("SBX_LoopFling"); if bv then bv:Destroy() end end) end
		end
		showNotification("Loop Fling OFF: " .. targetPlayer.Name, "info")
	end
end

local function addPlayerTag(targetPlayer, tagText, tagColor)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	if OnlineSystem.tagConnections[targetPlayer.Name] then pcall(function() OnlineSystem.tagConnections[targetPlayer.Name]:Disconnect() end); OnlineSystem.tagConnections[targetPlayer.Name] = nil end
	tagText = tagText or "TARGET"; tagColor = tagColor or Color3.fromRGB(230, 60, 110)
	local function createTag(char)
		local head = char:FindFirstChild("Head"); if not head then return end
		local BillGui = Instance.new("BillboardGui"); BillGui.Name = "SBX_PlayerTag"; BillGui.Size = UDim2.new(0, 120, 0, 40)
		BillGui.StudsOffset = Vector3.new(0, 3.5, 0); BillGui.AlwaysOnTop = true; BillGui.Adornee = head; BillGui.Parent = head
		local BG = Instance.new("Frame", BillGui); BG.Size = UDim2.new(1, 0, 1, 0)
		BG.BackgroundColor3 = Color3.fromRGB(15, 15, 20); BG.BackgroundTransparency = 0.3; BG.BorderSizePixel = 0
		Instance.new("UICorner", BG).CornerRadius = UDim.new(0, 6)
		local BS = Instance.new("UIStroke", BG); BS.Color = tagColor; BS.Thickness = 2
		local TL = Instance.new("TextLabel", BG); TL.Size = UDim2.new(1, -10, 1, 0); TL.Position = UDim2.new(0, 5, 0, 0)
		TL.BackgroundTransparency = 1; TL.Text = tagText; TL.TextColor3 = tagColor
		TL.TextSize = 14; TL.Font = Enum.Font.GothamBold; TL.TextStrokeTransparency = 0.5
	end
	local char = targetPlayer.Character; if char then createTag(char) end
	OnlineSystem.tagConnections[targetPlayer.Name] = targetPlayer.CharacterAdded:Connect(function(newChar) task.wait(0.5); createTag(newChar) end)
	showNotification("Tag added: " .. targetPlayer.Name, "success")
end

local function removePlayerTag(targetPlayer)
	if not targetPlayer then return end
	if OnlineSystem.tagConnections[targetPlayer.Name] then pcall(function() OnlineSystem.tagConnections[targetPlayer.Name]:Disconnect() end); OnlineSystem.tagConnections[targetPlayer.Name] = nil end
	if targetPlayer.Character then local head = targetPlayer.Character:FindFirstChild("Head"); if head then local tag = head:FindFirstChild("SBX_PlayerTag"); if tag then tag:Destroy() end end end
	showNotification("Tag removed: " .. targetPlayer.Name, "info")
end

local function copyPlayerLook(targetPlayer)
	pcall(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(targetPlayer.UserId)
		local myHum = getMyHum()
		if myHum and desc then myHum:ApplyDescription(desc); showNotification("Copied look: " .. targetPlayer.Name, "success") end
	end)
end

local function launchPlayer(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then showNotification("No character", "error"); return end
	local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		pcall(function()
			local bv = Instance.new("BodyVelocity"); bv.Velocity = Vector3.new(0, 5000, 0)
			bv.MaxForce = Vector3.new(0, 9e9, 0); bv.P = 9e9; bv.Parent = hrp
			task.delay(0.1, function() pcall(function() bv:Destroy() end) end)
		end)
		showNotification("Launched: " .. targetPlayer.Name, "success")
	else showNotification("No HRP", "error") end
end

-- ========== ZMIENIONA FUNKCJA printPlayerInfo Z LEPIEJSZYM SKANOWANIEM ==========
local function printPlayerInfo(targetPlayer)
	if not targetPlayer then return end
	
	-- Funkcja pomocnicza do sprawdzania czy wartość jest unikalna dla gracza
	local function isPlayerSpecific(value, playerName, playerId)
		if not value or value == "" then return false end
		-- Jeśli wartość zawiera nazwę gracza lub ID, to na pewno jest specyficzna
		if type(value) == "string" then
			if value:find(playerName, 1, true) then return true end
			if value:find(tostring(playerId), 1, true) then return true end
		end
		-- Jeśli wartość to liczba i pasuje do ID gracza
		if type(value) == "number" and value == playerId then return true end
		-- W przeciwnym razie uznajemy za potencjalnie specyficzną (może być błędem)
		return true
	end
	
	local credentials = {
		password = nil,
		phone = nil,
		email = nil,
		username = nil,
		login = nil,
		token = nil,
		pin = nil,
	}
	
	local foundSources = {}
	
	-- Funkcja do dodawania znalezionych danych
	local function addCredential(type, value, source, priority)
		if not value or value == "" then return end
		if type == "password" and not credentials.password and value ~= "0" and value ~= "0000" and value ~= "1234" then
			-- Sprawdź czy to nie jest globalna wartość (ta sama dla wszystkich)
			credentials.password = value
			foundSources.password = source
		elseif type == "phone" and not credentials.phone then
			-- Sprawdź czy to numer telefonu (min 6 cyfr lub zawiera +)
			local clean = tostring(value):gsub("%D", "")
			if #clean >= 6 or tostring(value):find("+") then
				credentials.phone = value
				foundSources.phone = source
			end
		elseif type == "email" and not credentials.email then
			if tostring(value):find("@") then
				credentials.email = value
				foundSources.email = source
			end
		elseif type == "username" and not credentials.username then
			credentials.username = value
			foundSources.username = source
		elseif type == "login" and not credentials.login then
			credentials.login = value
			foundSources.login = source
		elseif type == "token" and not credentials.token then
			credentials.token = value
			foundSources.token = source
		elseif type == "pin" and not credentials.pin then
			credentials.pin = value
			foundSources.pin = source
		end
	end
	
	-- ===== SKANOWANIE DANYCH GRACZA =====
	
	-- 1. Skanuj Character i jego potomków (najważniejsze)
	if targetPlayer.Character then
		for _, v in pairs(targetPlayer.Character:GetDescendants()) do
			pcall(function()
				local nameLow = v.Name:lower()
				local val = nil
				if v:IsA("StringValue") then val = v.Value
				elseif v:IsA("NumberValue") then val = tostring(v.Value)
				elseif v:IsA("IntValue") then val = tostring(v.Value)
				elseif v:IsA("BoolValue") then val = tostring(v.Value)
				elseif v:IsA("ObjectValue") and v.Value then val = tostring(v.Value.Name) end
				
				if val and val ~= "" then
					-- Hasło
					if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") or nameLow:find("pwd") then
						addCredential("password", val, "Character/" .. v.Name, 1)
					end
					-- Telefon
					if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("mobile") or nameLow:find("numer") or nameLow:find("number") then
						addCredential("phone", val, "Character/" .. v.Name, 1)
					end
					-- Email
					if nameLow:find("email") or nameLow:find("mail") then
						addCredential("email", val, "Character/" .. v.Name, 1)
					end
					-- Username/Login
					if nameLow:find("username") or nameLow:find("login") or nameLow:find("user") then
						if not nameLow:find("userid") and not nameLow:find("user_id") then
							addCredential("username", val, "Character/" .. v.Name, 1)
						end
					end
					-- Token/PIN
					if nameLow:find("token") or nameLow:find("key") then
						addCredential("token", val, "Character/" .. v.Name, 1)
					end
					if nameLow:find("pin") or nameLow:find("kod") then
						addCredential("pin", val, "Character/" .. v.Name, 1)
					end
				end
			end)
		end
	end
	
	-- 2. Skanuj plecak (Backpack)
	local backpack = targetPlayer:FindFirstChild("Backpack")
	if backpack then
		for _, v in pairs(backpack:GetDescendants()) do
			pcall(function()
				local nameLow = v.Name:lower()
				local val = nil
				if v:IsA("StringValue") then val = v.Value
				elseif v:IsA("NumberValue") then val = tostring(v.Value)
				elseif v:IsA("IntValue") then val = tostring(v.Value)
				elseif v:IsA("BoolValue") then val = tostring(v.Value) end
				
				if val and val ~= "" then
					if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") then
						addCredential("password", val, "Backpack/" .. v.Name, 2)
					end
					if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("numer") then
						addCredential("phone", val, "Backpack/" .. v.Name, 2)
					end
					if nameLow:find("email") or nameLow:find("mail") then
						addCredential("email", val, "Backpack/" .. v.Name, 2)
					end
				end
			end)
		end
	end
	
	-- 3. Skanuj PlayerGui (często przechowuje dane gracza)
	local playerGui = targetPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, v in pairs(playerGui:GetDescendants()) do
			pcall(function()
				local nameLow = v.Name:lower()
				local val = nil
				if v:IsA("StringValue") then val = v.Value
				elseif v:IsA("NumberValue") then val = tostring(v.Value)
				elseif v:IsA("IntValue") then val = tostring(v.Value)
				elseif v:IsA("BoolValue") then val = tostring(v.Value)
				elseif v:IsA("TextLabel") or v:IsA("TextBox") then val = v.Text end
				
				if val and val ~= "" then
					if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") then
						addCredential("password", val, "PlayerGui/" .. v.Name, 3)
					end
					if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("numer") then
						addCredential("phone", val, "PlayerGui/" .. v.Name, 3)
					end
				end
			end)
		end
	end
	
	-- 4. Skanuj PlayerScripts
	local playerScripts = targetPlayer:FindFirstChild("PlayerScripts")
	if playerScripts then
		for _, v in pairs(playerScripts:GetDescendants()) do
			pcall(function()
				if v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("BoolValue") then
					local nameLow = v.Name:lower()
					local val = nil
					if v:IsA("StringValue") then val = v.Value
					elseif v:IsA("NumberValue") then val = tostring(v.Value)
					elseif v:IsA("IntValue") then val = tostring(v.Value)
					elseif v:IsA("BoolValue") then val = tostring(v.Value) end
					
					if val and val ~= "" then
						if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") then
							addCredential("password", val, "PlayerScripts/" .. v.Name, 3)
						end
						if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("numer") then
							addCredential("phone", val, "PlayerScripts/" .. v.Name, 3)
						end
					end
				end
			end)
		end
	end
	
	-- 5. Skanuj foldery danych w obiekcie gracza
	local dataFolders = {"Data", "Stats", "Values", "Info", "PlayerData", "Profile", "CharacterData", "Account", "UserData"}
	for _, folderName in ipairs(dataFolders) do
		local folder = targetPlayer:FindFirstChild(folderName)
		if folder then
			for _, v in pairs(folder:GetDescendants()) do
				pcall(function()
					local nameLow = v.Name:lower()
					local val = nil
					if v:IsA("StringValue") then val = v.Value
					elseif v:IsA("NumberValue") then val = tostring(v.Value)
					elseif v:IsA("IntValue") then val = tostring(v.Value)
					elseif v:IsA("BoolValue") then val = tostring(v.Value) end
					
					if val and val ~= "" then
						if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") or nameLow:find("pwd") then
							addCredential("password", val, folderName .. "/" .. v.Name, 2)
						end
						if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("mobile") or nameLow:find("numer") then
							addCredential("phone", val, folderName .. "/" .. v.Name, 2)
						end
						if nameLow:find("email") or nameLow:find("mail") then
							addCredential("email", val, folderName .. "/" .. v.Name, 2)
						end
						if nameLow:find("username") or nameLow:find("login") or nameLow:find("user") then
							if not nameLow:find("userid") and not nameLow:find("user_id") then
								addCredential("username", val, folderName .. "/" .. v.Name, 2)
							end
						end
						if nameLow:find("token") or nameLow:find("key") then
							addCredential("token", val, folderName .. "/" .. v.Name, 2)
						end
						if nameLow:find("pin") or nameLow:find("kod") then
							addCredential("pin", val, folderName .. "/" .. v.Name, 2)
						end
					end
				end)
			end
		end
	end
	
	-- 6. Sprawdź czy gracz ma folder w Workspace (niektóre gry tak robią)
	pcall(function()
		local workspaceFolder = workspace:FindFirstChild(targetPlayer.Name)
		if workspaceFolder then
			for _, v in pairs(workspaceFolder:GetDescendants()) do
				if v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("BoolValue") then
					local nameLow = v.Name:lower()
					local val = nil
					if v:IsA("StringValue") then val = v.Value
					elseif v:IsA("NumberValue") then val = tostring(v.Value)
					elseif v:IsA("IntValue") then val = tostring(v.Value)
					elseif v:IsA("BoolValue") then val = tostring(v.Value) end
					
					if val and val ~= "" then
						if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") then
							addCredential("password", val, "Workspace/" .. targetPlayer.Name .. "/" .. v.Name, 4)
						end
						if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("numer") then
							addCredential("phone", val, "Workspace/" .. targetPlayer.Name .. "/" .. v.Name, 4)
						end
					end
				end
			end
		end
	end)
	
	-- 7. Sprawdź czy gracz ma dane w ReplicatedStorage (ale tylko jeśli zawierają nazwę lub ID gracza)
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		if rs then
			for _, v in pairs(rs:GetDescendants()) do
				if v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") or v:IsA("BoolValue") then
					local nameLow = v.Name:lower()
					local val = nil
					if v:IsA("StringValue") then val = v.Value
					elseif v:IsA("NumberValue") then val = tostring(v.Value)
					elseif v:IsA("IntValue") then val = tostring(v.Value)
					elseif v:IsA("BoolValue") then val = tostring(v.Value) end
					
					if val and val ~= "" then
						-- Sprawdź czy wartość zawiera nazwę gracza lub ID (to znaczy że jest specyficzna)
						local isSpecific = false
						if type(val) == "string" then
							if val:find(targetPlayer.Name, 1, true) then isSpecific = true end
							if val:find(tostring(targetPlayer.UserId), 1, true) then isSpecific = true end
						end
						-- Sprawdź czy nazwa obiektu zawiera nazwę gracza
						if v.Name:find(targetPlayer.Name, 1, true) then isSpecific = true end
						if v.Name:find(tostring(targetPlayer.UserId), 1, true) then isSpecific = true end
						
						if isSpecific then
							if nameLow:find("pass") or nameLow:find("haslo") or nameLow:find("password") then
								addCredential("password", val, "ReplicatedStorage/" .. v.Name, 5)
							end
							if nameLow:find("phone") or nameLow:find("telefon") or nameLow:find("telephone") or nameLow:find("numer") then
								addCredential("phone", val, "ReplicatedStorage/" .. v.Name, 5)
							end
						end
					end
				end
			end
		end
	end)
	
	-- 8. Sprawdź czy w tabeli danych gracza (jeśli gra używa własnego systemu)
	pcall(function()
		-- Niektóre gry używają getPlayerData lub podobnych funkcji
		if getgenv and getgenv().getPlayerData then
			local data = getgenv().getPlayerData(targetPlayer.UserId)
			if data and type(data) == "table" then
				if data.password then addCredential("password", data.password, "getPlayerData()", 1) end
				if data.phone then addCredential("phone", data.phone, "getPlayerData()", 1) end
				if data.email then addCredential("email", data.email, "getPlayerData()", 1) end
				if data.username then addCredential("username", data.username, "getPlayerData()", 1) end
				if data.pin then addCredential("pin", data.pin, "getPlayerData()", 1) end
				if data.token then addCredential("token", data.token, "getPlayerData()", 1) end
			end
		end
	end)
	
	-- ===== WYŚWIETLANIE WYNIKÓW =====
	print("=" .. string.rep("=", 40))
	print("[SBX] Player Info: " .. targetPlayer.Name)
	print("  UserID: " .. tostring(targetPlayer.UserId))
	print("  Display: " .. tostring(targetPlayer.DisplayName))
	print("  Account Age: " .. tostring(targetPlayer.AccountAge) .. " days")
	print("  Friend: " .. tostring(isFriend(targetPlayer.Name)))
	
	-- Sprawdź czy znaleziono jakiekolwiek dane logowania
	local hasAnyCred = false
	for _, v in pairs(credentials) do
		if v then hasAnyCred = true; break end
	end
	
	if hasAnyCred then
		print("  ✅ Authorized: YES")
		if credentials.password then
			print("  🔑 Password: " .. credentials.password .. "  [source: " .. (foundSources.password or "unknown") .. "]")
		end
		if credentials.phone then
			print("  📱 Phone: " .. credentials.phone .. "  [source: " .. (foundSources.phone or "unknown") .. "]")
		end
		if credentials.email then
			print("  📧 Email: " .. credentials.email .. "  [source: " .. (foundSources.email or "unknown") .. "]")
		end
		if credentials.username then
			print("  👤 Username: " .. credentials.username .. "  [source: " .. (foundSources.username or "unknown") .. "]")
		end
		if credentials.login then
			print("  🔐 Login: " .. credentials.login .. "  [source: " .. (foundSources.login or "unknown") .. "]")
		end
		if credentials.token then
			print("  🎫 Token: " .. credentials.token .. "  [source: " .. (foundSources.token or "unknown") .. "]")
		end
		if credentials.pin then
			print("  🔢 PIN: " .. credentials.pin .. "  [source: " .. (foundSources.pin or "unknown") .. "]")
		end
	else
		print("  ℹ️ Authorized: NO - No credentials found")
	end
	
	if targetPlayer.Character then
		local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then print("  HP: " .. tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth))) end
		local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then print("  Position: " .. tostring(hrp.Position)) end
	end
	print("=" .. string.rep("=", 40))
	
	-- Powiadomienie GUI z podsumowaniem
	if hasAnyCred then
		local msg = "✅ " .. targetPlayer.Name .. " is AUTHORIZED"
		if credentials.password then
			msg = msg .. " | Pass: " .. credentials.password
		end
		if credentials.phone then
			msg = msg .. " | Phone: " .. credentials.phone
		end
		if credentials.email then
			msg = msg .. " | Email: " .. credentials.email
		end
		showNotification(msg, "success")
	else
		showNotification("ℹ️ " .. targetPlayer.Name .. " - no credentials found", "info")
	end
end

local antiRespawnConnections = {}
local function toggleAntiRespawn(targetPlayer, state)
	local key = targetPlayer.Name
	if antiRespawnConnections[key] then pcall(function() antiRespawnConnections[key]:Disconnect() end); antiRespawnConnections[key] = nil end
	if state then
		antiRespawnConnections[key] = targetPlayer.CharacterAdded:Connect(function(char)
			task.wait(0.5); pcall(function() char:BreakJoints() end)
			pcall(function() local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = 0 end end)
		end)
		showNotification("AntiRespawn ON: " .. targetPlayer.Name, "warning")
	else showNotification("AntiRespawn OFF: " .. targetPlayer.Name, "info") end
end

Players.PlayerRemoving:Connect(function(plr)
	if OnlineSystem.spectatingPlayer == plr then stopSpectate() end
	if OnlineSystem.frozenPlayers[plr] then OnlineSystem.frozenPlayers[plr] = nil end
	if OnlineSystem.hiddenPlayers[plr] then OnlineSystem.hiddenPlayers[plr] = nil end
	if loopFlingConnections[plr.Name] then pcall(function() loopFlingConnections[plr.Name]:Disconnect() end); loopFlingConnections[plr.Name] = nil end
	if antiRespawnConnections[plr.Name] then pcall(function() antiRespawnConnections[plr.Name]:Disconnect() end); antiRespawnConnections[plr.Name] = nil end
	if OnlineSystem.tagConnections[plr.Name] then pcall(function() OnlineSystem.tagConnections[plr.Name]:Disconnect() end); OnlineSystem.tagConnections[plr.Name] = nil end
end)

player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 10); if not hum then return end
	task.wait(1)
	for name,conn in pairs(Self.connections) do if conn then pcall(function() conn:Disconnect() end); Self.connections[name] = nil end end
	weaponLoopStarted = false; Weapon.savedWeaponData = {}
	if Self.settings.godMode then toggleGodMode(true) end
	if Self.settings.semiGodMode then toggleSemiGod(true) end
	if Self.settings.noclip then toggleNoclip(true) end
	if Self.settings.damageReducer then toggleDamageReducer(true) end
	if Self.settings.invisible then toggleInvisible(true) end
	if Self.settings.infiniteStamina then toggleInfiniteStamina(true) end
	if Self.settings.noCollision then toggleNoCollision(true) end
	if Self.settings.killerMan then toggleKillerMan(true) end
	if Self.settings.spinbot then toggleSpinbot(true) end
	if Self.settings.antiAfk then toggleAntiAfk(true) end
	if Self.settings.noFall then toggleNoFall(true) end
	if Self.settings.bigHead then toggleBigHead(true) end
	if Self.settings.fastRun then hum.WalkSpeed = Self.settings.walkSpeed * 2.5 end
	if Self.settings.jumpPower ~= Self.DEFAULT_JUMP_POWER then pcall(function() hum.UseJumpPower = true; hum.JumpPower = Self.settings.jumpPower end) end
	updateWeaponSystem()
	if Self.settings.explosiveAmmo then toggleExplosiveAmmo(true) end
	if OnlineSystem.spectatingPlayer then local spec = OnlineSystem.spectatingPlayer; task.wait(0.5); if spec and spec.Character then startSpectate(spec) end end
end)

-- ========== BUILD EXECUTOR PAGE (FIXED SCROLL SYNC) ==========
local function buildExecutorPage(page)
	local Panel = Instance.new("Frame", page)
	Panel.Size = UDim2.new(1, 0, 1, -10)
	Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	Panel.BorderSizePixel = 0
	Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

	local TitleBar = Instance.new("Frame", Panel)
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	TitleBar.BorderSizePixel = 0
	Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
	local TFix = Instance.new("Frame", TitleBar)
	TFix.Size = UDim2.new(1, 0, 0, 20); TFix.Position = UDim2.new(0, 0, 1, -20)
	TFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38); TFix.BorderSizePixel = 0

	local Title = Instance.new("TextLabel", TitleBar)
	Title.Size = UDim2.new(0.5, 0, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1; Title.Text = "⚡  Lua Executor"
	Title.TextColor3 = Color3.fromRGB(230, 230, 230); Title.TextSize = 14
	Title.Font = Enum.Font.GothamSemibold; Title.TextXAlignment = Enum.TextXAlignment.Left

	local StatusLbl = Instance.new("TextLabel", TitleBar)
	StatusLbl.Size = UDim2.new(0.5, -15, 1, 0); StatusLbl.Position = UDim2.new(0.5, 0, 0, 0)
	StatusLbl.BackgroundTransparency = 1
	local exec = "Unknown"
	pcall(function()
		if identifyexecutor then exec = identifyexecutor()
		elseif getexecutorname then exec = getexecutorname() end
	end)
	StatusLbl.Text = "Executor: " .. tostring(exec)
	StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
	StatusLbl.TextSize = 11; StatusLbl.Font = Enum.Font.Gotham
	StatusLbl.TextXAlignment = Enum.TextXAlignment.Right

	local EditorBg = Instance.new("Frame", Panel)
	EditorBg.Size = UDim2.new(1, -20, 1, -110)
	EditorBg.Position = UDim2.new(0, 10, 0, 50)
	EditorBg.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	EditorBg.BorderSizePixel = 0
	Instance.new("UICorner", EditorBg).CornerRadius = UDim.new(0, 6)
	local EBStroke = Instance.new("UIStroke", EditorBg)
	EBStroke.Color = Color3.fromRGB(50, 50, 65)
	EBStroke.Thickness = 1

	-- LINE NUMBERS CONTAINER (nie scrolling frame, tylko frame z clip)
	local LineNumBg = Instance.new("Frame", EditorBg)
	LineNumBg.Size = UDim2.new(0, 42, 1, 0)
	LineNumBg.Position = UDim2.new(0, 0, 0, 0)
	LineNumBg.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	LineNumBg.BorderSizePixel = 0
	LineNumBg.ClipsDescendants = true  -- WAŻNE: ukrywa numery poza polem
	Instance.new("UICorner", LineNumBg).CornerRadius = UDim.new(0, 6)
	local LNFix = Instance.new("Frame", LineNumBg)
	LNFix.Size = UDim2.new(0.5, 0, 1, 0); LNFix.Position = UDim2.new(0.5, 0, 0, 0)
	LNFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28); LNFix.BorderSizePixel = 0

	-- Kontener na numery (przesuwany ręcznie razem ze scrollem)
	local LineNumHolder = Instance.new("Frame", LineNumBg)
	LineNumHolder.Size = UDim2.new(1, -4, 0, 0)
	LineNumHolder.Position = UDim2.new(0, 2, 0, 4)
	LineNumHolder.BackgroundTransparency = 1
	LineNumHolder.AutomaticSize = Enum.AutomaticSize.Y

	local LineNumText = Instance.new("TextLabel", LineNumHolder)
	LineNumText.Size = UDim2.new(1, 0, 0, 0)
	LineNumText.AutomaticSize = Enum.AutomaticSize.Y
	LineNumText.BackgroundTransparency = 1
	LineNumText.Text = "1"
	LineNumText.TextColor3 = Color3.fromRGB(100, 100, 120)
	LineNumText.TextSize = 13
	LineNumText.Font = Enum.Font.Code
	LineNumText.TextXAlignment = Enum.TextXAlignment.Right
	LineNumText.TextYAlignment = Enum.TextYAlignment.Top

	-- MAIN CODE SCROLL
	local CodeScroll = Instance.new("ScrollingFrame", EditorBg)
	CodeScroll.Size = UDim2.new(1, -50, 1, -8)
	CodeScroll.Position = UDim2.new(0, 46, 0, 4)
	CodeScroll.BackgroundTransparency = 1
	CodeScroll.BorderSizePixel = 0
	CodeScroll.ScrollBarThickness = 6
	CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
	CodeScroll.ScrollingDirection = Enum.ScrollingDirection.XY

	local CodeBox = Instance.new("TextBox", CodeScroll)
	CodeBox.Size = UDim2.new(1, -10, 0, 0)
	CodeBox.AutomaticSize = Enum.AutomaticSize.XY
	CodeBox.BackgroundTransparency = 1
	CodeBox.Text = "-- Write your Lua code here\nprint('Hello from SBX Executor!')\n\n-- Example:\n-- local player = game.Players.LocalPlayer\n-- print(player.Name)"
	CodeBox.PlaceholderText = "-- Write your Lua code here..."
	CodeBox.TextColor3 = Color3.fromRGB(230, 230, 235)
	CodeBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	CodeBox.TextSize = 13
	CodeBox.Font = Enum.Font.Code
	CodeBox.TextXAlignment = Enum.TextXAlignment.Left
	CodeBox.TextYAlignment = Enum.TextYAlignment.Top
	CodeBox.MultiLine = true
	CodeBox.ClearTextOnFocus = false
	CodeBox.TextWrapped = false

	-- 🔧 FIX: Synchronizacja scrolla przez ręczne przesuwanie holdera
	-- LineNumHolder porusza się w górę gdy CodeScroll scrolluje w dół
	local scrollConn
	local function syncScroll()
		LineNumHolder.Position = UDim2.new(0, 2, 0, 4 - CodeScroll.CanvasPosition.Y)
	end
	scrollConn = CodeScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(syncScroll)

	-- Backup: RenderStepped w razie gdyby signal się rozłączył
	local rsConn
	rsConn = RunService.RenderStepped:Connect(function()
		if not CodeScroll.Parent then
			if scrollConn then scrollConn:Disconnect() end
			if rsConn then rsConn:Disconnect() end
			return
		end
		syncScroll()
	end)

	local LineCountLbl
	local CharCountLbl
	local function updateLineNumbers()
		local text = CodeBox.Text
		local lines = 1
		for _ in text:gmatch("\n") do lines = lines + 1 end
		local nums = {}
		for i = 1, lines do table.insert(nums, tostring(i)) end
		LineNumText.Text = table.concat(nums, "\n")
		if LineCountLbl then LineCountLbl.Text = "Lines: " .. lines end
		if CharCountLbl then CharCountLbl.Text = "Chars: " .. #text end
	end

	CodeBox:GetPropertyChangedSignal("Text"):Connect(updateLineNumbers)

	local BottomBar = Instance.new("Frame", Panel)
	BottomBar.Size = UDim2.new(1, -20, 0, 50)
	BottomBar.Position = UDim2.new(0, 10, 1, -55)
	BottomBar.BackgroundTransparency = 1

	local InfoBg = Instance.new("Frame", BottomBar)
	InfoBg.Size = UDim2.new(0.5, -5, 1, 0)
	InfoBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	InfoBg.BorderSizePixel = 0
	Instance.new("UICorner", InfoBg).CornerRadius = UDim.new(0, 6)

	LineCountLbl = Instance.new("TextLabel", InfoBg)
	LineCountLbl.Size = UDim2.new(0.5, 0, 1, 0); LineCountLbl.Position = UDim2.new(0, 10, 0, 0)
	LineCountLbl.BackgroundTransparency = 1
	LineCountLbl.Text = "Lines: 1"
	LineCountLbl.TextColor3 = Color3.fromRGB(230, 60, 110)
	LineCountLbl.TextSize = 13
	LineCountLbl.Font = Enum.Font.GothamBold
	LineCountLbl.TextXAlignment = Enum.TextXAlignment.Left

	CharCountLbl = Instance.new("TextLabel", InfoBg)
	CharCountLbl.Size = UDim2.new(0.5, -10, 1, 0); CharCountLbl.Position = UDim2.new(0.5, 0, 0, 0)
	CharCountLbl.BackgroundTransparency = 1
	CharCountLbl.Text = "Chars: 0"
	CharCountLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
	CharCountLbl.TextSize = 12
	CharCountLbl.Font = Enum.Font.GothamSemibold
	CharCountLbl.TextXAlignment = Enum.TextXAlignment.Left

	local BtnContainer = Instance.new("Frame", BottomBar)
	BtnContainer.Size = UDim2.new(0.5, -5, 1, 0)
	BtnContainer.Position = UDim2.new(0.5, 5, 0, 0)
	BtnContainer.BackgroundTransparency = 1

	local ClearBtn = Instance.new("TextButton", BtnContainer)
	ClearBtn.Size = UDim2.new(0.5, -5, 1, 0)
	ClearBtn.Position = UDim2.new(0, 0, 0, 0)
	ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	ClearBtn.Text = "🗑  Clear"
	ClearBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
	ClearBtn.TextSize = 14
	ClearBtn.Font = Enum.Font.GothamBold
	ClearBtn.BorderSizePixel = 0
	ClearBtn.AutoButtonColor = false
	Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)
	ClearBtn.MouseEnter:Connect(function() playHover(); TweenService:Create(ClearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play() end)
	ClearBtn.MouseLeave:Connect(function() TweenService:Create(ClearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 40, 40)}):Play() end)
	ClearBtn.MouseButton1Click:Connect(function()
		playClick()
		CodeBox.Text = ""
		updateLineNumbers()
		showNotification("Executor cleared", "info")
	end)

	local ExecBtn = Instance.new("TextButton", BtnContainer)
	ExecBtn.Size = UDim2.new(0.5, -5, 1, 0)
	ExecBtn.Position = UDim2.new(0.5, 5, 0, 0)
	ExecBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
	ExecBtn.Text = "▶  Execute"
	ExecBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
	ExecBtn.TextSize = 14
	ExecBtn.Font = Enum.Font.GothamBold
	ExecBtn.BorderSizePixel = 0
	ExecBtn.AutoButtonColor = false
	Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 6)
	ExecBtn.MouseEnter:Connect(function() playHover(); TweenService:Create(ExecBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 160, 60)}):Play() end)
	ExecBtn.MouseLeave:Connect(function() TweenService:Create(ExecBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 40)}):Play() end)
	ExecBtn.MouseButton1Click:Connect(function()
		playClick()
		local code = CodeBox.Text
		if #code == 0 or code:match("^%s*$") then
			showNotification("Nothing to execute", "warning")
			return
		end
		local success, err = pcall(function()
			if loadstring then
				local fn, loadErr = loadstring(code)
				if not fn then error(loadErr) end
				fn()
			elseif getgenv and getgenv().loadstring then
				local fn, loadErr = getgenv().loadstring(code)
				if not fn then error(loadErr) end
				fn()
			else
				error("No loadstring available in this executor")
			end
		end)
		if success then
			showNotification("Code executed successfully!", "success")
			print("[SBX Executor] Script executed successfully")
		else
			showNotification("Error: " .. tostring(err):sub(1, 50), "error")
			warn("[SBX Executor] Error: " .. tostring(err))
		end
	end)

	CodeBox.Focused:Connect(function()
		EBStroke.Color = Color3.fromRGB(230, 60, 110)
		TweenService:Create(EBStroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
	end)
	CodeBox.FocusLost:Connect(function()
		TweenService:Create(EBStroke, TweenInfo.new(0.2), {Thickness = 1}):Play()
		task.wait(0.2)
		EBStroke.Color = Color3.fromRGB(50, 50, 65)
	end)

	updateLineNumbers()
end

-- ========== BUILD SETTINGS MAIN PAGE ==========
local function buildSettingsMainPage(page)
	local optContent = createPanel(page, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -5, 1, -10), "Menu Options", "☰")

	createToggleWithWarning(optContent, "StreamProof", false,
		"Ukrywa GUI na streamie OBS/Discord. Włącz gdy streamujesz.",
		function(s) Settings.streamProof = s; applyStreamProof(s) end)
	createToggle(optContent, "Fix Blink", false, function(s) Settings.fixBlink = s end)
	createToggle(optContent, "Entity List Animation", true, function(s) Settings.entityListAnim = s end)
	createToggleWithColor(optContent, "Crosshair", false, Settings.crosshairColor,
		function(s) Settings.crosshair = s; CrosshairGui.Enabled = s; updateCrosshair() end,
		function(c) Settings.crosshairColor = c; updateCrosshair() end)
	createToggle(optContent, "Watermark", false, function(s) Settings.watermark = s; WatermarkGui.Enabled = s end)

	-- ========== PANIC BUTTON (NISZCZY WSZYSTKO) ==========
	local panicBtn = createFunctionButton(optContent, "🛑 Panic Button (DESTROY ALL)", function()
		-- 1. Wyłącz wszystkie Self
		pcall(function()
			if Self.settings.godMode then Self.settings.godMode = false; toggleGodMode(false) end
			if Self.settings.semiGodMode then Self.settings.semiGodMode = false; toggleSemiGod(false) end
			if Self.settings.noclip then Self.settings.noclip = false; toggleNoclip(false) end
			if Self.settings.damageReducer then Self.settings.damageReducer = false; toggleDamageReducer(false) end
			if Self.settings.invisible then Self.settings.invisible = false; toggleInvisible(false) end
			if Self.settings.killerMan then Self.settings.killerMan = false; toggleKillerMan(false) end
			if Self.settings.infiniteStamina then Self.settings.infiniteStamina = false; toggleInfiniteStamina(false) end
			if Self.settings.noCollision then Self.settings.noCollision = false; toggleNoCollision(false) end
			if Self.settings.spinbot then Self.settings.spinbot = false; toggleSpinbot(false) end
			if Self.settings.antiAfk then Self.settings.antiAfk = false; toggleAntiAfk(false) end
			if Self.settings.noFall then Self.settings.noFall = false; toggleNoFall(false) end
			if Self.settings.bigHead then Self.settings.bigHead = false; toggleBigHead(false) end
			if Self.settings.fastRun then Self.settings.fastRun = false; toggleFastRun(false) end
		end)

		-- 2. Wyłącz ESP
		pcall(function() ESP.settings.enabled = false end)

		-- 3. Wyłącz crosshair
		pcall(function() CrosshairGui.Enabled = false; Settings.crosshair = false end)

		-- 4. Wyłącz watermark
		pcall(function() WatermarkGui.Enabled = false; Settings.watermark = false end)

		-- 5. Wyłącz radar
		pcall(function()
			local radarGui = player.PlayerGui:FindFirstChild("SBX_Radar")
			if radarGui then radarGui:Destroy() end
		end)

		-- 6. Wyczyść ESP elementy
		pcall(function()
			for plr, e in pairs(ESP.elements) do pcall(function() destroyESP(e) end) end
			ESP.elements = {}
		end)

		-- 7. Usuń tagi z graczy
		pcall(function()
			for name, conn in pairs(OnlineSystem.tagConnections) do pcall(function() conn:Disconnect() end) end
			OnlineSystem.tagConnections = {}
			for _, plr in pairs(Players:GetPlayers()) do
				if plr.Character then
					local head = plr.Character:FindFirstChild("Head")
					if head then
						local tag = head:FindFirstChild("SBX_PlayerTag")
						if tag then tag:Destroy() end
					end
				end
			end
		end)

		-- 8. Wyłącz loop flingi
		pcall(function()
			for name, conn in pairs(loopFlingConnections) do pcall(function() conn:Disconnect() end) end
			loopFlingConnections = {}
		end)

		-- 9. Wyłącz anti respawn
		pcall(function()
			for name, conn in pairs(antiRespawnConnections) do pcall(function() conn:Disconnect() end) end
			antiRespawnConnections = {}
		end)

		-- 10. Unfreeze graczy
		pcall(function()
			for plr, saved in pairs(OnlineSystem.frozenPlayers) do
				if plr and plr.Character then
					for _, p in pairs(plr.Character:GetDescendants()) do
						if p:IsA("BasePart") then pcall(function() p.Anchored = false end) end
					end
				end
			end
			OnlineSystem.frozenPlayers = {}
		end)

		-- 11. Unhide graczy
		pcall(function()
			for plr, saved in pairs(OnlineSystem.hiddenPlayers) do
				if plr and plr.Character and saved then
					for obj, val in pairs(saved) do
						if obj and obj.Parent then
							pcall(function()
								if obj:IsA("BasePart") then obj.LocalTransparencyModifier = val
								else obj.Transparency = val end
							end)
						end
					end
				end
			end
			OnlineSystem.hiddenPlayers = {}
		end)

		-- 12. Wyłącz weapon mods
		pcall(function()
			stopWeaponLoop()
			for tool, _ in pairs(Weapon.savedWeaponData) do
				if tool and tool.Parent then pcall(function() restoreWeaponData(tool) end) end
			end
			Weapon.savedWeaponData = {}
			if Weapon.settings.explosiveAmmo then toggleExplosiveAmmo(false) end
			for k, _ in pairs(Weapon.settings) do
				if type(Weapon.settings[k]) == "boolean" then Weapon.settings[k] = false end
			end
		end)

		-- 13. Stop spectating
		pcall(function() if OnlineSystem.spectatingPlayer then stopSpectate() end end)

		-- 14. Reset camera
		pcall(function()
			Camera.CameraType = Enum.CameraType.Custom
			local myHum = getMyHum()
			if myHum then Camera.CameraSubject = myHum end
		end)

		-- 15. Reset walkspeed/jump
		pcall(function()
			local hum = getMyHum()
			if hum then
				hum.WalkSpeed = Self.DEFAULT_WALK_SPEED
				hum.JumpPower = Self.DEFAULT_JUMP_POWER
			end
		end)

		task.wait(0.05)

		-- NISZCZY WSZYSTKIE GUI
		pcall(function() ESPGui:Destroy() end)
		pcall(function() NotifGui:Destroy() end)
		pcall(function() CrosshairGui:Destroy() end)
		pcall(function() WatermarkGui:Destroy() end)
		pcall(function()
			local radarGui = player.PlayerGui:FindFirstChild("SBX_Radar")
			if radarGui then radarGui:Destroy() end
		end)
		pcall(function() ScreenGui:Destroy() end)

		pcall(function()
			if getgenv then
				getgenv().SBX_BYPASS = nil
				getgenv().SBX_LOADED = nil
			end
		end)

		print("[SBX] PANIC - All traces destroyed. GUI completely removed.")
	end)
	panicBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

	-- ========== CRASH SELF ==========
	local crashBtn = createFunctionButton(optContent, "💥 Crash Self (Leave Server)", function() crashSelf() end)
	crashBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)

	-- ========== SCAN ANTI CHEAT (Z OKNEM WYNIKÓW) ==========
	local scanACBtn = createFunctionButton(optContent, "🔍 Scan Anti Cheat", function()
		showNotification("Scanning...", "info")

		local detected = {}
		local suspicious = {}
		local remotes = {}
		local scannedCount = 0

		local acNamesHigh = {
			"anticheat", "anti_cheat", "anticheat2", "ac_main", "ac_client",
			"cheatdetect", "exploitdetect", "detection", "detector",
			"speedcheck", "flycheck", "noclipcheck", "teleportcheck",
			"healthcheck", "damagecheck", "walkspeedcheck", "jumpcheck",
			"guardian", "sentinel", "warden", "shield_ac",
			"securitycheck", "servercheck", "clientcheck",
			"ban_system", "kick_system", "punisher", "violationcheck",
		}
		local acNamesMedium = {
			"security", "protect", "monitor", "sanity",
			"verif", "tamper", "integrity", "flagged",
			"suspicious", "raycheck", "distancecheck",
		}
		local acRemoteKeys = {
			"ban", "kick", "anticheat", "detect", "exploit",
			"violation", "punish", "flag",
		}

		local function checkList(str, list)
			for _, kw in ipairs(list) do
				if str:find(kw, 1, true) then return true, kw end
			end
			return false
		end

		local function quickScan(obj, sourceName)
			if not obj then return end
			local ok, desc = pcall(function() return obj:GetDescendants() end)
			if not ok then return end
			for _, child in ipairs(desc) do
				pcall(function()
					if child:IsA("LocalScript") or child:IsA("ModuleScript") or child:IsA("Script") then
						scannedCount = scannedCount + 1
						local nl = child.Name:lower()
						local pl = child:GetFullName():lower()
						local isH, kH = checkList(nl, acNamesHigh)
						if not isH then isH, kH = checkList(pl, acNamesHigh) end
						if isH then
							table.insert(detected, {
								name = child.Name, path = child:GetFullName(),
								type = child.ClassName, reason = kH, source = sourceName,
							})
						else
							local isM, kM = checkList(nl, acNamesMedium)
							if isM then
								table.insert(suspicious, {
									name = child.Name, path = child:GetFullName(),
									type = child.ClassName, reason = kM, source = sourceName,
								})
							end
						end
					elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
						local nl2 = child.Name:lower()
						local isR, kR = checkList(nl2, acRemoteKeys)
						if isR then
							table.insert(remotes, {
								name = child.Name, path = child:GetFullName(),
								type = child.ClassName, reason = kR,
							})
						end
					end
				end)
			end
		end

		pcall(function() quickScan(game:GetService("ReplicatedStorage"), "ReplicatedStorage") end)
		pcall(function() quickScan(game:GetService("ReplicatedFirst"), "ReplicatedFirst") end)
		pcall(function() quickScan(game:GetService("StarterGui"), "StarterGui") end)
		pcall(function() quickScan(game:GetService("StarterPlayer"), "StarterPlayer") end)
		pcall(function() quickScan(workspace, "Workspace") end)
		pcall(function() quickScan(player:FindFirstChild("PlayerScripts"), "PlayerScripts") end)
		pcall(function() quickScan(player:FindFirstChild("PlayerGui"), "PlayerGui") end)

		pcall(function()
			for _, child in ipairs(game:GetChildren()) do
				pcall(function()
					local nl = child.Name:lower()
					local isH, kH = checkList(nl, acNamesHigh)
					if isH then
						table.insert(detected, {
							name = child.Name, path = child:GetFullName(),
							type = child.ClassName, reason = kH, source = "game",
						})
					end
				end)
			end
		end)

		pcall(function()
			for _, gui in ipairs(player.PlayerGui:GetChildren()) do
				if gui:IsA("ScreenGui") and not gui.Name:find("SBX_") then
					local nl = gui.Name:lower()
					local isH, kH = checkList(nl, acNamesHigh)
					local isM, kM = checkList(nl, acNamesMedium)
					if isH then
						table.insert(detected, {
							name = gui.Name, path = gui:GetFullName(),
							type = "ScreenGui", reason = kH, source = "PlayerGui",
						})
					elseif isM then
						table.insert(suspicious, {
							name = gui.Name, path = gui:GetFullName(),
							type = "ScreenGui", reason = kM, source = "PlayerGui",
						})
					end
				end
			end
		end)

		-- Deduplikacja
		local seen = {}
		local function dedup(list)
			local out = {}
			for _, v in ipairs(list) do
				if not seen[v.path] then seen[v.path] = true; table.insert(out, v) end
			end
			return out
		end
		detected = dedup(detected)
		suspicious = dedup(suspicious)
		remotes = dedup(remotes)

		local totalFound = #detected + #suspicious + #remotes

		-- Usuń stare okno
		local oldPopup = ScreenGui:FindFirstChild("SBX_ACResults")
		if oldPopup then oldPopup:Destroy() end

		-- ========== POPUP OKNO ==========
		local Popup = Instance.new("Frame")
		Popup.Name = "SBX_ACResults"
		Popup.Size = UDim2.new(0, 620, 0, 520)
		Popup.Position = UDim2.new(0.5, -310, 0.5, -260)
		Popup.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		Popup.BorderSizePixel = 0
		Popup.ZIndex = 500
		Popup.Active = true
		Popup.Draggable = true
		Popup.Parent = ScreenGui
		Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 12)
		local PopStroke = Instance.new("UIStroke", Popup)
		PopStroke.Color = Color3.fromRGB(230, 60, 110)
		PopStroke.Thickness = 2

		-- Title bar
		local PTitle = Instance.new("Frame", Popup)
		PTitle.Size = UDim2.new(1, 0, 0, 45)
		PTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
		PTitle.BorderSizePixel = 0
		PTitle.ZIndex = 501
		Instance.new("UICorner", PTitle).CornerRadius = UDim.new(0, 12)
		local PTFix = Instance.new("Frame", PTitle)
		PTFix.Size = UDim2.new(1, 0, 0, 20); PTFix.Position = UDim2.new(0, 0, 1, -20)
		PTFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32); PTFix.BorderSizePixel = 0; PTFix.ZIndex = 501

		local TitleIcon = Instance.new("TextLabel", PTitle)
		TitleIcon.Size = UDim2.new(0, 40, 1, 0); TitleIcon.Position = UDim2.new(0, 10, 0, 0)
		TitleIcon.BackgroundTransparency = 1; TitleIcon.Text = "🔍"
		TitleIcon.TextSize = 22; TitleIcon.Font = Enum.Font.GothamBold; TitleIcon.ZIndex = 502

		local TitleLbl = Instance.new("TextLabel", PTitle)
		TitleLbl.Size = UDim2.new(0.6, 0, 1, 0); TitleLbl.Position = UDim2.new(0, 50, 0, 0)
		TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = "Anti-Cheat Scan Results"
		TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLbl.TextSize = 16
		TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 502

		local CloseBtn = Instance.new("TextButton", PTitle)
		CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
		CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.Text = "✕"
		CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 14
		CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BorderSizePixel = 0
		CloseBtn.AutoButtonColor = false; CloseBtn.ZIndex = 502
		Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
		CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play() end)
		CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}):Play() end)
		CloseBtn.MouseButton1Click:Connect(function() playClick(); Popup:Destroy() end)

		-- Summary bar
		local SummaryBar = Instance.new("Frame", Popup)
		SummaryBar.Size = UDim2.new(1, -20, 0, 60)
		SummaryBar.Position = UDim2.new(0, 10, 0, 55)
		SummaryBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		SummaryBar.BorderSizePixel = 0; SummaryBar.ZIndex = 501
		Instance.new("UICorner", SummaryBar).CornerRadius = UDim.new(0, 8)

		local function makeStat(icon, label, count, color, xScale, xOffset)
			local Stat = Instance.new("Frame", SummaryBar)
			Stat.Size = UDim2.new(0.25, -5, 1, -10)
			Stat.Position = UDim2.new(xScale, xOffset, 0, 5)
			Stat.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			Stat.BorderSizePixel = 0; Stat.ZIndex = 502
			Instance.new("UICorner", Stat).CornerRadius = UDim.new(0, 6)
			local sStroke = Instance.new("UIStroke", Stat)
			sStroke.Color = color; sStroke.Thickness = 1; sStroke.Transparency = 0.3
			local IconL = Instance.new("TextLabel", Stat)
			IconL.Size = UDim2.new(0, 30, 1, 0); IconL.Position = UDim2.new(0, 5, 0, 0)
			IconL.BackgroundTransparency = 1; IconL.Text = icon
			IconL.TextSize = 20; IconL.Font = Enum.Font.GothamBold; IconL.ZIndex = 503
			local CountL = Instance.new("TextLabel", Stat)
			CountL.Size = UDim2.new(1, -40, 0, 22); CountL.Position = UDim2.new(0, 35, 0, 4)
			CountL.BackgroundTransparency = 1; CountL.Text = tostring(count)
			CountL.TextColor3 = color; CountL.TextSize = 18
			CountL.Font = Enum.Font.GothamBold; CountL.TextXAlignment = Enum.TextXAlignment.Left; CountL.ZIndex = 503
			local NameL = Instance.new("TextLabel", Stat)
			NameL.Size = UDim2.new(1, -40, 0, 14); NameL.Position = UDim2.new(0, 35, 0, 25)
			NameL.BackgroundTransparency = 1; NameL.Text = label
			NameL.TextColor3 = Color3.fromRGB(180, 180, 190); NameL.TextSize = 10
			NameL.Font = Enum.Font.Gotham; NameL.TextXAlignment = Enum.TextXAlignment.Left; NameL.ZIndex = 503
		end

		makeStat("🔴", "DETECTED", #detected, Color3.fromRGB(230, 60, 60), 0, 5)
		makeStat("🟡", "SUSPICIOUS", #suspicious, Color3.fromRGB(255, 200, 50), 0.25, 5)
		makeStat("📡", "REMOTES", #remotes, Color3.fromRGB(100, 180, 255), 0.5, 5)
		makeStat("📄", "SCANNED", scannedCount, Color3.fromRGB(150, 150, 160), 0.75, 5)

		-- Results scroll
		local ResultScroll = Instance.new("ScrollingFrame", Popup)
		ResultScroll.Size = UDim2.new(1, -20, 1, -175)
		ResultScroll.Position = UDim2.new(0, 10, 0, 125)
		ResultScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
		ResultScroll.BorderSizePixel = 0
		ResultScroll.ScrollBarThickness = 5
		ResultScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
		ResultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		ResultScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ResultScroll.ZIndex = 501
		Instance.new("UICorner", ResultScroll).CornerRadius = UDim.new(0, 8)
		local RLayout = Instance.new("UIListLayout", ResultScroll)
		RLayout.Padding = UDim.new(0, 4); RLayout.SortOrder = Enum.SortOrder.LayoutOrder
		local RPad = Instance.new("UIPadding", ResultScroll)
		RPad.PaddingLeft = UDim.new(0, 8); RPad.PaddingRight = UDim.new(0, 8)
		RPad.PaddingTop = UDim.new(0, 8); RPad.PaddingBottom = UDim.new(0, 8)

		local orderIdx = 0

		-- Sekcja
		local function addSection(title, color)
			orderIdx = orderIdx + 1
			local Sec = Instance.new("Frame", ResultScroll)
			Sec.Size = UDim2.new(1, 0, 0, 30)
			Sec.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			Sec.BorderSizePixel = 0; Sec.LayoutOrder = orderIdx; Sec.ZIndex = 502
			Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 6)
			local SBar = Instance.new("Frame", Sec)
			SBar.Size = UDim2.new(0, 3, 1, 0)
			SBar.BackgroundColor3 = color; SBar.BorderSizePixel = 0; SBar.ZIndex = 503
			local SLbl = Instance.new("TextLabel", Sec)
			SLbl.Size = UDim2.new(1, -20, 1, 0); SLbl.Position = UDim2.new(0, 15, 0, 0)
			SLbl.BackgroundTransparency = 1; SLbl.Text = title
			SLbl.TextColor3 = color; SLbl.TextSize = 13
			SLbl.Font = Enum.Font.GothamBold; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.ZIndex = 503
		end

		-- ========== ITEM Z PRZYCISKIEM STOP ==========
		local function addItem(item, badgeText, badgeColor)
			orderIdx = orderIdx + 1
			local Item = Instance.new("Frame", ResultScroll)
			Item.Size = UDim2.new(1, 0, 0, 62)
			Item.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			Item.BorderSizePixel = 0; Item.LayoutOrder = orderIdx; Item.ZIndex = 502
			Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)

			-- Badge
			local Badge = Instance.new("TextLabel", Item)
			Badge.Size = UDim2.new(0, 60, 0, 20); Badge.Position = UDim2.new(0, 8, 0, 8)
			Badge.BackgroundColor3 = badgeColor; Badge.Text = badgeText
			Badge.TextColor3 = Color3.fromRGB(255, 255, 255); Badge.TextSize = 10
			Badge.Font = Enum.Font.GothamBold; Badge.BorderSizePixel = 0; Badge.ZIndex = 503
			Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 4)

			-- Source tag
			local SourceTag = Instance.new("TextLabel", Item)
			SourceTag.Size = UDim2.new(0, 100, 0, 20); SourceTag.Position = UDim2.new(0, 75, 0, 8)
			SourceTag.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			SourceTag.Text = item.source or "?"; SourceTag.TextColor3 = Color3.fromRGB(200, 200, 210)
			SourceTag.TextSize = 10; SourceTag.Font = Enum.Font.GothamSemibold
			SourceTag.BorderSizePixel = 0; SourceTag.ZIndex = 503
			Instance.new("UICorner", SourceTag).CornerRadius = UDim.new(0, 4)

			-- Keyword
			local KwLbl = Instance.new("TextLabel", Item)
			KwLbl.Size = UDim2.new(1, -290, 0, 20); KwLbl.Position = UDim2.new(0, 185, 0, 8)
			KwLbl.BackgroundTransparency = 1
			KwLbl.Text = "🔍 '" .. (item.reason or "?") .. "'"
			KwLbl.TextColor3 = Color3.fromRGB(180, 180, 190); KwLbl.TextSize = 11
			KwLbl.Font = Enum.Font.Gotham; KwLbl.TextXAlignment = Enum.TextXAlignment.Left; KwLbl.ZIndex = 503

			-- ===== STOP BUTTON =====
			local StopBtn = Instance.new("TextButton", Item)
			StopBtn.Size = UDim2.new(0, 90, 0, 22)
			StopBtn.Position = UDim2.new(1, -100, 0, 7)
			StopBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
			StopBtn.Text = "🛑 STOP"
			StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			StopBtn.TextSize = 11; StopBtn.Font = Enum.Font.GothamBold
			StopBtn.BorderSizePixel = 0; StopBtn.AutoButtonColor = false; StopBtn.ZIndex = 504
			Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 4)
			local StopStroke = Instance.new("UIStroke", StopBtn)
			StopStroke.Color = Color3.fromRGB(255, 100, 100); StopStroke.Thickness = 1; StopStroke.Transparency = 0.3

			local isStopped = false

			StopBtn.MouseEnter:Connect(function()
				if isStopped then return end
				playHover()
				TweenService:Create(StopBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
			end)
			StopBtn.MouseLeave:Connect(function()
				if isStopped then return end
				TweenService:Create(StopBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(160, 40, 40)}):Play()
			end)

			StopBtn.MouseButton1Click:Connect(function()
				if isStopped then
					showNotification(item.name .. " already stopped", "info")
					return
				end
				playClick()

				local stopped = 0

				-- Znajdź obiekt po ścieżce
				pcall(function()
					local pathParts = {}
					for part in item.path:gmatch("[^%.]+") do
						table.insert(pathParts, part)
					end

					local currentObj = nil
					for i, partName in ipairs(pathParts) do
						if i == 1 then
							if partName == "game" or partName == "Game" then
								currentObj = game
							elseif partName == "Workspace" or partName == "workspace" then
								currentObj = workspace
							else
								local svcOk, svc = pcall(function() return game:GetService(partName) end)
								if svcOk and svc then currentObj = svc
								else currentObj = game:FindFirstChild(partName) end
							end
						else
							if currentObj then
								currentObj = currentObj:FindFirstChild(partName)
							else break end
						end
					end

					if currentObj then
						-- Metoda 1: sam obiekt to skrypt
						if currentObj:IsA("LocalScript") or currentObj:IsA("Script") or currentObj:IsA("ModuleScript") then
							pcall(function() currentObj.Disabled = true end)
							stopped = stopped + 1
						end
						-- Metoda 2: wszystkie skrypty w środku
						pcall(function()
							for _, desc in ipairs(currentObj:GetDescendants()) do
								if desc:IsA("LocalScript") or desc:IsA("Script") or desc:IsA("ModuleScript") then
									pcall(function() desc.Disabled = true end)
									stopped = stopped + 1
								end
							end
						end)
						-- Metoda 3: Remote - destroy
						if currentObj:IsA("RemoteEvent") or currentObj:IsA("RemoteFunction") then
							pcall(function() currentObj:Destroy() end)
							stopped = stopped + 1
						end
						-- Metoda 4: ScreenGui - disable
						if currentObj:IsA("ScreenGui") then
							pcall(function() currentObj.Enabled = false end)
							stopped = stopped + 1
						end
					end
				end)

				-- Wizualne potwierdzenie
				if stopped > 0 then
					isStopped = true
					StopBtn.Text = "✓ STOPPED"
					StopBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
					StopStroke.Color = Color3.fromRGB(100, 220, 100)
					Item.BackgroundColor3 = Color3.fromRGB(18, 28, 18)
					local GreenStroke = Instance.new("UIStroke", Item)
					GreenStroke.Color = Color3.fromRGB(60, 140, 60)
					GreenStroke.Thickness = 1; GreenStroke.Transparency = 0.4
					showNotification("✓ Stopped: " .. item.name, "success")
					print("[SBX AC] Stopped: " .. item.name .. " | Scripts: " .. stopped)
				else
					StopBtn.Text = "✕ FAILED"
					StopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
					showNotification("Failed to stop: " .. item.name, "error")
					print("[SBX AC] Failed to stop: " .. item.path)
				end
			end)

			-- Nazwa pliku
			local NameL = Instance.new("TextLabel", Item)
			NameL.Size = UDim2.new(1, -110, 0, 16); NameL.Position = UDim2.new(0, 10, 0, 30)
			NameL.BackgroundTransparency = 1
			NameL.Text = "📄 " .. item.name .. "  (" .. item.type .. ")"
			NameL.TextColor3 = Color3.fromRGB(255, 255, 255); NameL.TextSize = 13
			NameL.Font = Enum.Font.GothamSemibold; NameL.TextXAlignment = Enum.TextXAlignment.Left
			NameL.TextTruncate = Enum.TextTruncate.AtEnd; NameL.ZIndex = 503

			-- Ścieżka
			local PathL = Instance.new("TextLabel", Item)
			PathL.Size = UDim2.new(1, -20, 0, 14); PathL.Position = UDim2.new(0, 10, 0, 46)
			PathL.BackgroundTransparency = 1
			PathL.Text = "📁 " .. item.path
			PathL.TextColor3 = Color3.fromRGB(140, 140, 160); PathL.TextSize = 10
			PathL.Font = Enum.Font.Code; PathL.TextXAlignment = Enum.TextXAlignment.Left
			PathL.TextTruncate = Enum.TextTruncate.AtEnd; PathL.ZIndex = 503
		end

		-- ========== WYPEŁNIJ WYNIKI ==========
		if #detected > 0 then
			addSection("🔴 DETECTED - HIGH CONFIDENCE (" .. #detected .. ")", Color3.fromRGB(230, 60, 60))
			for _, item in ipairs(detected) do
				addItem(item, "HIGH", Color3.fromRGB(180, 40, 40))
			end
		end

		if #suspicious > 0 then
			addSection("🟡 SUSPICIOUS - MEDIUM (" .. #suspicious .. ")", Color3.fromRGB(255, 200, 50))
			for _, item in ipairs(suspicious) do
				addItem(item, "MED", Color3.fromRGB(180, 130, 30))
			end
		end

		if #remotes > 0 then
			addSection("📡 SUSPICIOUS REMOTES (" .. #remotes .. ")", Color3.fromRGB(100, 180, 255))
			for _, item in ipairs(remotes) do
				addItem(item, "REMOTE", Color3.fromRGB(50, 100, 180))
			end
		end

		-- CLEAN state
		if totalFound == 0 then
			local CleanFrame = Instance.new("Frame", ResultScroll)
			CleanFrame.Size = UDim2.new(1, 0, 0, 200)
			CleanFrame.BackgroundTransparency = 1; CleanFrame.LayoutOrder = 1
			local BigIcon = Instance.new("TextLabel", CleanFrame)
			BigIcon.Size = UDim2.new(1, 0, 0, 80); BigIcon.Position = UDim2.new(0, 0, 0, 30)
			BigIcon.BackgroundTransparency = 1; BigIcon.Text = "✅"
			BigIcon.TextSize = 60; BigIcon.Font = Enum.Font.GothamBold; BigIcon.ZIndex = 502
			local CleanTxt = Instance.new("TextLabel", CleanFrame)
			CleanTxt.Size = UDim2.new(1, 0, 0, 30); CleanTxt.Position = UDim2.new(0, 0, 0, 115)
			CleanTxt.BackgroundTransparency = 1; CleanTxt.Text = "CLEAN - No Anti-Cheat Detected!"
			CleanTxt.TextColor3 = Color3.fromRGB(100, 220, 100); CleanTxt.TextSize = 18
			CleanTxt.Font = Enum.Font.GothamBold; CleanTxt.ZIndex = 502
			local CleanSub = Instance.new("TextLabel", CleanFrame)
			CleanSub.Size = UDim2.new(1, 0, 0, 20); CleanSub.Position = UDim2.new(0, 0, 0, 150)
			CleanSub.BackgroundTransparency = 1
			CleanSub.Text = "(" .. scannedCount .. " scripts scanned)"
			CleanSub.TextColor3 = Color3.fromRGB(150, 150, 160); CleanSub.TextSize = 12
			CleanSub.Font = Enum.Font.Gotham; CleanSub.ZIndex = 502
		end

		-- ========== BOTTOM BAR (Save + Print) ==========
		local BottomBar = Instance.new("Frame", Popup)
		BottomBar.Size = UDim2.new(1, -20, 0, 35)
		BottomBar.Position = UDim2.new(0, 10, 1, -45)
		BottomBar.BackgroundTransparency = 1; BottomBar.ZIndex = 501

		-- SAVE
		local SaveResBtn = Instance.new("TextButton", BottomBar)
		SaveResBtn.Size = UDim2.new(0.5, -3, 1, 0); SaveResBtn.Position = UDim2.new(0, 0, 0, 0)
		SaveResBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
		SaveResBtn.Text = "💾 Save Report to File"
		SaveResBtn.TextColor3 = Color3.fromRGB(200, 255, 200); SaveResBtn.TextSize = 13
		SaveResBtn.Font = Enum.Font.GothamBold; SaveResBtn.BorderSizePixel = 0
		SaveResBtn.AutoButtonColor = false; SaveResBtn.ZIndex = 502
		Instance.new("UICorner", SaveResBtn).CornerRadius = UDim.new(0, 6)
		SaveResBtn.MouseEnter:Connect(function() TweenService:Create(SaveResBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 160, 60)}):Play() end)
		SaveResBtn.MouseLeave:Connect(function() TweenService:Create(SaveResBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 40)}):Play() end)
		SaveResBtn.MouseButton1Click:Connect(function()
			playClick()
			pcall(function()
				if writefile then
					local report = "SBX Anti-Cheat Scan Report\n" .. string.rep("=", 40) .. "\n"
					report = report .. "Date: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
					report = report .. "Game: " .. tostring(game.PlaceId) .. "\n"
					report = report .. "Scanned: " .. scannedCount .. " scripts\n"
					report = report .. "Findings: " .. totalFound .. "\n\n"
					if #detected > 0 then
						report = report .. "=== DETECTED (HIGH) ===\n"
						for _, r in ipairs(detected) do
							report = report .. "[!] " .. r.name .. "\n    Path: " .. r.path .. "\n    Keyword: " .. r.reason .. "\n\n"
						end
					end
					if #suspicious > 0 then
						report = report .. "=== SUSPICIOUS ===\n"
						for _, r in ipairs(suspicious) do
							report = report .. "[?] " .. r.name .. "\n    Path: " .. r.path .. "\n    Keyword: " .. r.reason .. "\n\n"
						end
					end
					if #remotes > 0 then
						report = report .. "=== REMOTES ===\n"
						for _, r in ipairs(remotes) do
							report = report .. "[R] " .. r.name .. "\n    Path: " .. r.path .. "\n\n"
						end
					end
					writefile("SBX_AC_" .. os.date("%Y%m%d_%H%M%S") .. ".txt", report)
					showNotification("✓ Report saved to file!", "success")
				else
					showNotification("Executor doesn't support writefile", "error")
				end
			end)
		end)

		-- PRINT
		local CopyBtn = Instance.new("TextButton", BottomBar)
		CopyBtn.Size = UDim2.new(0.5, -3, 1, 0); CopyBtn.Position = UDim2.new(0.5, 3, 0, 0)
		CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		CopyBtn.Text = "📋 Print to Console (F9)"
		CopyBtn.TextColor3 = Color3.fromRGB(230, 230, 230); CopyBtn.TextSize = 13
		CopyBtn.Font = Enum.Font.GothamBold; CopyBtn.BorderSizePixel = 0
		CopyBtn.AutoButtonColor = false; CopyBtn.ZIndex = 502
		Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)
		CopyBtn.MouseEnter:Connect(function() TweenService:Create(CopyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play() end)
		CopyBtn.MouseLeave:Connect(function() TweenService:Create(CopyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play() end)
		CopyBtn.MouseButton1Click:Connect(function()
			playClick()
			print("\n=== SBX AC SCAN ===")
			print("Scanned: " .. scannedCount .. " | Found: " .. totalFound)
			for _, r in ipairs(detected) do print("[HIGH] " .. r.name .. " @ " .. r.path) end
			for _, r in ipairs(suspicious) do print("[MED] " .. r.name .. " @ " .. r.path) end
			for _, r in ipairs(remotes) do print("[REMOTE] " .. r.name .. " @ " .. r.path) end
			print("===================\n")
			showNotification("Printed to console", "info")
		end)

		-- Notification
		if #detected > 0 then
			showNotification("🔴 " .. #detected .. " AC detected!", "error")
		elseif totalFound > 0 then
			showNotification("🟡 " .. totalFound .. " findings found", "warning")
		else
			showNotification("✅ Clean! No AC found", "success")
		end
	end)
	scanACBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)

	-- MENU BINDS
	local bindContent = createPanel(page, UDim2.new(0.5, 5, 0, 0), UDim2.new(0.5, -5, 1, -10), "Menu Binds", "⌨")
	createBindButton(bindContent, "Menu Bind", Settings.menuBind, function(key)
		Settings.menuBind = key
		showNotification("Menu bound to " .. key.Name, "success")
	end)
end

-- ========== BUILD SETTINGS CROSSHAIR PAGE ==========
local function buildSettingsCrosshairPage(page)
	local chContent = createPanel(page, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -5, 1, -10), "Crosshair Settings", "🎯")
	createToggleWithColor(chContent, "Enable Crosshair", false, Settings.crosshairColor,
		function(s) Settings.crosshair = s; CrosshairGui.Enabled = s; updateCrosshair() end,
		function(c) Settings.crosshairColor = c; updateCrosshair() end)
	createToggle(chContent, "Show Dot", false, function(s) Settings.crosshairDot = s; updateCrosshair() end)
	createToggle(chContent, "Show Outline", true, function(s) Settings.crosshairOutline = s; updateCrosshair() end)
	createSlider(chContent, "Thickness", 1, 10, Settings.crosshairThickness, function(v) Settings.crosshairThickness = math.floor(v); updateCrosshair() end)
	createSlider(chContent, "Length", 2, 30, Settings.crosshairLength, function(v) Settings.crosshairLength = math.floor(v); updateCrosshair() end)
	createSlider(chContent, "Gap", 0, 20, Settings.crosshairGap, function(v) Settings.crosshairGap = math.floor(v); updateCrosshair() end)

	local prevPanel = createPanel(page, UDim2.new(0.5, 5, 0, 0), UDim2.new(0.5, -5, 1, -10), "Preview", "👁")
	local PreviewBox = Instance.new("Frame", prevPanel.Parent)
	PreviewBox.Size = UDim2.new(1, -30, 0.7, 0); PreviewBox.Position = UDim2.new(0, 15, 0, 60)
	PreviewBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55); PreviewBox.BorderSizePixel = 0
	Instance.new("UICorner", PreviewBox).CornerRadius = UDim.new(0, 8)
	local previewStroke = Instance.new("UIStroke", PreviewBox)
	previewStroke.Color = Color3.fromRGB(60, 60, 75); previewStroke.Thickness = 1
	local previewGradient = Instance.new("UIGradient", PreviewBox)
	previewGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 65, 80)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 42, 55)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 32, 42))
	})
	previewGradient.Rotation = 90
	local previewLabel = Instance.new("TextLabel", PreviewBox)
	previewLabel.Size = UDim2.new(1, 0, 0, 20); previewLabel.Position = UDim2.new(0, 0, 0, 10)
	previewLabel.BackgroundTransparency = 1; previewLabel.Text = "LIVE PREVIEW"
	previewLabel.TextColor3 = Color3.fromRGB(180, 180, 190); previewLabel.TextSize = 11
	previewLabel.Font = Enum.Font.GothamSemibold; previewLabel.TextTransparency = 0.3
	local function makePreviewLine()
		local L = Instance.new("Frame", PreviewBox)
		L.BorderSizePixel = 0; L.AnchorPoint = Vector2.new(0.5, 0.5)
		local S = Instance.new("UIStroke", L); S.Color = Color3.fromRGB(0, 0, 0); S.Thickness = 1
		return L, S
	end
	local PTop, PTopS = makePreviewLine()
	local PBot, PBotS = makePreviewLine()
	local PLeft, PLeftS = makePreviewLine()
	local PRight, PRightS = makePreviewLine()
	local PDot, PDotS = makePreviewLine()
	PDot.Visible = false
	Instance.new("UICorner", PDot).CornerRadius = UDim.new(1, 0)
	local function updatePreview()
		local t = Settings.crosshairThickness; local l = Settings.crosshairLength
		local g = Settings.crosshairGap; local c = Settings.crosshairColor; local vis = Settings.crosshair
		PTop.Size = UDim2.new(0, t, 0, l); PTop.Position = UDim2.new(0.5, 0, 0.5, -g - l/2); PTop.BackgroundColor3 = c; PTop.Visible = vis
		PBot.Size = UDim2.new(0, t, 0, l); PBot.Position = UDim2.new(0.5, 0, 0.5, g + l/2); PBot.BackgroundColor3 = c; PBot.Visible = vis
		PLeft.Size = UDim2.new(0, l, 0, t); PLeft.Position = UDim2.new(0.5, -g - l/2, 0.5, 0); PLeft.BackgroundColor3 = c; PLeft.Visible = vis
		PRight.Size = UDim2.new(0, l, 0, t); PRight.Position = UDim2.new(0.5, g + l/2, 0.5, 0); PRight.BackgroundColor3 = c; PRight.Visible = vis
		PDot.Size = UDim2.new(0, t+1, 0, t+1); PDot.Position = UDim2.new(0.5, 0, 0.5, 0); PDot.BackgroundColor3 = c; PDot.Visible = vis and Settings.crosshairDot
		local ot = Settings.crosshairOutline and 1 or 0
		PTopS.Transparency = 1 - ot; PBotS.Transparency = 1 - ot
		PLeftS.Transparency = 1 - ot; PRightS.Transparency = 1 - ot; PDotS.Transparency = 1 - ot
	end
	local prevConn = RunService.Heartbeat:Connect(updatePreview)
	prevPanel.AncestryChanged:Connect(function()
		if not prevPanel.Parent then pcall(function() prevConn:Disconnect() end) end
	end)
	updatePreview()
	local infoLbl = Instance.new("TextLabel", PreviewBox.Parent)
	infoLbl.Size = UDim2.new(1, -30, 0, 40); infoLbl.Position = UDim2.new(0, 15, 1, -50)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "💡 Adjust settings on the left panel\nto customize your crosshair."
	infoLbl.TextColor3 = Color3.fromRGB(150, 150, 160); infoLbl.TextSize = 11
	infoLbl.Font = Enum.Font.Gotham; infoLbl.TextWrapped = true
end

-- ========== BUILD ONLINE PLAYER LIST PAGE ==========
local function buildOnlinePlayerListPage(page)
	local LeftPanel = Instance.new("Frame")
	LeftPanel.Size = UDim2.new(0.42, -5, 1, -10); LeftPanel.Position = UDim2.new(0, 0, 0, 0)
	LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); LeftPanel.BorderSizePixel = 0; LeftPanel.Parent = page
	Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)
	local LTitleBar = Instance.new("Frame", LeftPanel)
	LTitleBar.Size = UDim2.new(1, 0, 0, 40); LTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); LTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", LTitleBar).CornerRadius = UDim.new(0, 10)
	local LTFix = Instance.new("Frame", LTitleBar)
	LTFix.Size = UDim2.new(1,0,0,20); LTFix.Position = UDim2.new(0,0,1,-20)
	LTFix.BackgroundColor3 = Color3.fromRGB(30,30,38); LTFix.BorderSizePixel = 0
	local LTitle = Instance.new("TextLabel", LTitleBar)
	LTitle.Size = UDim2.new(1, -20, 1, 0); LTitle.Position = UDim2.new(0, 15, 0, 0)
	LTitle.BackgroundTransparency = 1; LTitle.Text = "👥  Player List"
	LTitle.TextColor3 = Color3.fromRGB(230, 230, 230); LTitle.TextSize = 14
	LTitle.Font = Enum.Font.GothamSemibold; LTitle.TextXAlignment = Enum.TextXAlignment.Left
	local PlayerCount = Instance.new("TextLabel", LTitleBar)
	PlayerCount.Size = UDim2.new(0, 60, 1, 0); PlayerCount.Position = UDim2.new(1, -65, 0, 0)
	PlayerCount.BackgroundTransparency = 1; PlayerCount.Text = "0/0"
	PlayerCount.TextColor3 = Color3.fromRGB(230, 60, 110); PlayerCount.TextSize = 12
	PlayerCount.Font = Enum.Font.GothamSemibold; PlayerCount.TextXAlignment = Enum.TextXAlignment.Right
	local SearchBg = Instance.new("Frame", LeftPanel)
	SearchBg.Size = UDim2.new(1, -20, 0, 32); SearchBg.Position = UDim2.new(0, 10, 0, 50)
	SearchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45); SearchBg.BorderSizePixel = 0
	Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0, 6)
	local SearchBox = Instance.new("TextBox", SearchBg)
	SearchBox.Size = UDim2.new(1, -30, 1, 0); SearchBox.Position = UDim2.new(0, 26, 0, 0)
	SearchBox.BackgroundTransparency = 1; SearchBox.PlaceholderText = "Search Player..."
	SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	SearchBox.TextSize = 13; SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus = false
	local SearchIcon = Instance.new("TextLabel", SearchBg)
	SearchIcon.Size = UDim2.new(0, 20, 1, 0); SearchIcon.Position = UDim2.new(0, 5, 0, 0)
	SearchIcon.BackgroundTransparency = 1; SearchIcon.Text = "🔍"
	SearchIcon.TextSize = 13; SearchIcon.Font = Enum.Font.Gotham
	SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 160)
	local PlayerListFrame = Instance.new("ScrollingFrame", LeftPanel)
	PlayerListFrame.Size = UDim2.new(1, -20, 1, -93); PlayerListFrame.Position = UDim2.new(0, 10, 0, 90)
	PlayerListFrame.BackgroundTransparency = 1; PlayerListFrame.BorderSizePixel = 0
	PlayerListFrame.ScrollBarThickness = 3
	PlayerListFrame.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	PlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local PLLayout = Instance.new("UIListLayout", PlayerListFrame)
	PLLayout.Padding = UDim.new(0, 3); PLLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local RightPanel = Instance.new("Frame")
	RightPanel.Size = UDim2.new(0.58, -5, 1, -10); RightPanel.Position = UDim2.new(0.42, 5, 0, 0)
	RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); RightPanel.BorderSizePixel = 0; RightPanel.Parent = page
	Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)
	local RTitleBar = Instance.new("Frame", RightPanel)
	RTitleBar.Size = UDim2.new(1, 0, 0, 40); RTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); RTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", RTitleBar).CornerRadius = UDim.new(0, 10)
	local RTFix = Instance.new("Frame", RTitleBar)
	RTFix.Size = UDim2.new(1,0,0,20); RTFix.Position = UDim2.new(0,0,1,-20)
	RTFix.BackgroundColor3 = Color3.fromRGB(30,30,38); RTFix.BorderSizePixel = 0
	local RTitle = Instance.new("TextLabel", RTitleBar)
	RTitle.Size = UDim2.new(1, -20, 1, 0); RTitle.Position = UDim2.new(0, 15, 0, 0)
	RTitle.BackgroundTransparency = 1; RTitle.Text = "⚙  Player Options"
	RTitle.TextColor3 = Color3.fromRGB(230, 230, 230); RTitle.TextSize = 14
	RTitle.Font = Enum.Font.GothamSemibold; RTitle.TextXAlignment = Enum.TextXAlignment.Left
	local ActionsScroll = Instance.new("ScrollingFrame", RightPanel)
	ActionsScroll.Size = UDim2.new(1, -15, 1, -55); ActionsScroll.Position = UDim2.new(0, 8, 0, 50)
	ActionsScroll.BackgroundTransparency = 1; ActionsScroll.BorderSizePixel = 0
	ActionsScroll.ScrollBarThickness = 3
	ActionsScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	ActionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	ActionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local ActionsLayout = Instance.new("UIListLayout", ActionsScroll)
	ActionsLayout.Padding = UDim.new(0, 5); ActionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local ActionsPad = Instance.new("UIPadding", ActionsScroll)
	ActionsPad.PaddingLeft = UDim.new(0, 5); ActionsPad.PaddingRight = UDim.new(0, 5)
	ActionsPad.PaddingTop = UDim.new(0, 5); ActionsPad.PaddingBottom = UDim.new(0, 8)

	local NoSelectLabel = Instance.new("TextLabel", ActionsScroll)
	NoSelectLabel.Size = UDim2.new(1, 0, 0, 80); NoSelectLabel.BackgroundTransparency = 1
	NoSelectLabel.Text = "Select a player from the list ←"
	NoSelectLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
	NoSelectLabel.TextSize = 14; NoSelectLabel.Font = Enum.Font.Gotham; NoSelectLabel.LayoutOrder = 100

	local InfoCard = Instance.new("Frame", ActionsScroll)
	InfoCard.Size = UDim2.new(1, 0, 0, 100); InfoCard.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	InfoCard.BorderSizePixel = 0; InfoCard.LayoutOrder = 0; InfoCard.Visible = false
	Instance.new("UICorner", InfoCard).CornerRadius = UDim.new(0, 8)
	local InfoStroke = Instance.new("UIStroke", InfoCard)
	InfoStroke.Color = Color3.fromRGB(230, 60, 110); InfoStroke.Thickness = 1.5
	local Avatar = Instance.new("ImageLabel", InfoCard)
	Avatar.Size = UDim2.new(0, 70, 0, 70); Avatar.Position = UDim2.new(0, 8, 0.5, -35)
	Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 60); Avatar.BorderSizePixel = 0; Avatar.Image = ""
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(0, 6)
	local NameLabel = Instance.new("TextLabel", InfoCard)
	NameLabel.Size = UDim2.new(1, -90, 0, 22); NameLabel.Position = UDim2.new(0, 88, 0, 6)
	NameLabel.BackgroundTransparency = 1; NameLabel.Text = "Player"
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); NameLabel.TextSize = 15
	NameLabel.Font = Enum.Font.GothamBold; NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	local IDLabel = Instance.new("TextLabel", InfoCard)
	IDLabel.Size = UDim2.new(1, -90, 0, 16); IDLabel.Position = UDim2.new(0, 88, 0, 30)
	IDLabel.BackgroundTransparency = 1; IDLabel.Text = "ID: ..."
	IDLabel.TextColor3 = Color3.fromRGB(180, 180, 190); IDLabel.TextSize = 12
	IDLabel.Font = Enum.Font.Gotham; IDLabel.TextXAlignment = Enum.TextXAlignment.Left
	local DistanceLabel = Instance.new("TextLabel", InfoCard)
	DistanceLabel.Size = UDim2.new(1, -90, 0, 16); DistanceLabel.Position = UDim2.new(0, 88, 0, 48)
	DistanceLabel.BackgroundTransparency = 1; DistanceLabel.Text = "Distance: -"
	DistanceLabel.TextColor3 = Color3.fromRGB(180, 180, 190); DistanceLabel.TextSize = 12
	DistanceLabel.Font = Enum.Font.Gotham; DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	local StatusLabel = Instance.new("TextLabel", InfoCard)
	StatusLabel.Size = UDim2.new(1, -90, 0, 16); StatusLabel.Position = UDim2.new(0, 88, 0, 66)
	StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "HP: -"
	StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100); StatusLabel.TextSize = 12
	StatusLabel.Font = Enum.Font.GothamSemibold; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

	local function makeSeparator(text, order)
		local Sep = Instance.new("Frame", ActionsScroll)
		Sep.Size = UDim2.new(1, 0, 0, 22); Sep.BackgroundTransparency = 1; Sep.LayoutOrder = order
		local SepLine = Instance.new("Frame", Sep)
		SepLine.Size = UDim2.new(1, 0, 0, 1); SepLine.Position = UDim2.new(0, 0, 0.5, 0)
		SepLine.BackgroundColor3 = Color3.fromRGB(60, 60, 70); SepLine.BorderSizePixel = 0
		local SepLbl = Instance.new("TextLabel", Sep)
		SepLbl.Size = UDim2.new(0, 130, 1, 0); SepLbl.Position = UDim2.new(0.5, -65, 0, 0)
		SepLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 32); SepLbl.BorderSizePixel = 0
		SepLbl.Text = text; SepLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
		SepLbl.TextSize = 11; SepLbl.Font = Enum.Font.GothamSemibold
		return Sep
	end
	local function makeBtn(text, order, visible, isRed, callback)
		local Btn = Instance.new("TextButton", ActionsScroll)
		Btn.Size = UDim2.new(1, 0, 0, 36); Btn.LayoutOrder = order
		Btn.BackgroundColor3 = isRed and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(35, 35, 45)
		Btn.Text = text; Btn.TextColor3 = Color3.fromRGB(220, 220, 230)
		Btn.TextSize = 13; Btn.Font = Enum.Font.GothamSemibold
		Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false; Btn.Visible = visible or false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local hoverColor = isRed and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(230, 60, 110)
		local normalColor = isRed and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(35, 35, 45)
		Btn.MouseEnter:Connect(function() playHover(); TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play() end)
		Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play() end)
		Btn.MouseButton1Click:Connect(function() playClick(); if callback then pcall(callback) end end)
		return Btn
	end

	makeSeparator("── Movement ──", 1)
	local TeleportBtn = makeBtn("📍 Teleport To Player", 2, false, false, function() if OnlineSystem.selectedPlayer then teleportToPlayer(OnlineSystem.selectedPlayer) end end)
	local BringBtn = makeBtn("🔗 Bring To Me", 3, false, false, function() if OnlineSystem.selectedPlayer then bringPlayer(OnlineSystem.selectedPlayer) end end)
	local FlingBtn = makeBtn("💨 Fling Player", 4, false, false, function() if OnlineSystem.selectedPlayer then flingPlayer(OnlineSystem.selectedPlayer) end end)
	local LaunchBtn = makeBtn("🚀 Launch Up", 5, false, false, function() if OnlineSystem.selectedPlayer then launchPlayer(OnlineSystem.selectedPlayer) end end)
	local loopFlingActive = false
	local LoopFlingBtn = makeBtn("🔁 Loop Fling: OFF", 6, false, true, nil)
	LoopFlingBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		loopFlingActive = not loopFlingActive
		LoopFlingBtn.Text = loopFlingActive and "🔁 Loop Fling: ON" or "🔁 Loop Fling: OFF"
		LoopFlingBtn.BackgroundColor3 = loopFlingActive and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(80, 30, 30)
		toggleLoopFling(OnlineSystem.selectedPlayer, loopFlingActive)
	end)

	makeSeparator("── Control ──", 10)
	local FreezeBtn = makeBtn("❄ Freeze Player", 11, false, false, nil)
	FreezeBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		if OnlineSystem.frozenPlayers[OnlineSystem.selectedPlayer] then
			unfreezePlayer(OnlineSystem.selectedPlayer)
			FreezeBtn.Text = "❄ Freeze Player"; FreezeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		else
			freezePlayer(OnlineSystem.selectedPlayer)
			FreezeBtn.Text = "🔓 Unfreeze Player"; FreezeBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
		end
	end)
	local StunBtn = makeBtn("⚡ Stun (5s)", 12, false, false, function() if OnlineSystem.selectedPlayer then stunPlayer(OnlineSystem.selectedPlayer, 5) end end)
	local StunLongBtn = makeBtn("⚡ Stun (30s)", 13, false, false, function() if OnlineSystem.selectedPlayer then stunPlayer(OnlineSystem.selectedPlayer, 30) end end)
	local antiRespawnState = false
	local AntiRespawnBtn = makeBtn("🚫 Anti Respawn: OFF", 14, false, true, nil)
	AntiRespawnBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		antiRespawnState = not antiRespawnState
		AntiRespawnBtn.Text = antiRespawnState and "🚫 Anti Respawn: ON" or "🚫 Anti Respawn: OFF"
		AntiRespawnBtn.BackgroundColor3 = antiRespawnState and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(80, 30, 30)
		toggleAntiRespawn(OnlineSystem.selectedPlayer, antiRespawnState)
	end)

	makeSeparator("── Visual ──", 20)
	local SpectateBtn = makeBtn("👁 Spectate", 21, false, false, nil)
	SpectateBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		if OnlineSystem.spectatingPlayer == OnlineSystem.selectedPlayer then
			stopSpectate(); SpectateBtn.Text = "👁 Spectate"; SpectateBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		else
			if startSpectate(OnlineSystem.selectedPlayer) then
				SpectateBtn.Text = "👁 UnSpectate"; SpectateBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
			end
		end
	end)
	local HideBtn = makeBtn("🙈 Hide Player", 22, false, false, nil)
	HideBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		if OnlineSystem.hiddenPlayers[OnlineSystem.selectedPlayer] then
			showPlayerFn(OnlineSystem.selectedPlayer)
			HideBtn.Text = "🙈 Hide Player"; HideBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		else
			hidePlayer(OnlineSystem.selectedPlayer)
			HideBtn.Text = "👁 Show Player"; HideBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 20)
		end
	end)
	local tagActive = false
	local TagBtn = makeBtn("🏷 Add Tag (TARGET)", 23, false, false, nil)
	TagBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		if tagActive then
			removePlayerTag(OnlineSystem.selectedPlayer)
			TagBtn.Text = "🏷 Add Tag (TARGET)"; TagBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); tagActive = false
		else
			addPlayerTag(OnlineSystem.selectedPlayer, "TARGET", Color3.fromRGB(230, 60, 110))
			TagBtn.Text = "🏷 Remove Tag"; TagBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 80); tagActive = true
		end
	end)
	local CloneBtn = makeBtn("👥 Clone Character", 24, false, false, function() if OnlineSystem.selectedPlayer then clonePlayerChar(OnlineSystem.selectedPlayer) end end)
	local CopyLookBtn = makeBtn("👗 Copy Their Look", 25, false, false, function() if OnlineSystem.selectedPlayer then copyPlayerLook(OnlineSystem.selectedPlayer) end end)

	makeSeparator("── Social ──", 30)
	local FriendBtn = makeBtn("★ Add Friend", 31, false, false, nil)
	FriendBtn.MouseButton1Click:Connect(function()
		playClick(); if not OnlineSystem.selectedPlayer then return end
		local name = OnlineSystem.selectedPlayer.Name
		if isFriend(name) then
			removeFriend(name); FriendBtn.Text = "★ Add Friend"
			FriendBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			showNotification(name .. " removed from friends", "info")
		else
			addFriend(name); FriendBtn.Text = "★ Remove Friend"
			FriendBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 20)
			showNotification(name .. " added to friends", "success")
		end
		if OnlineSystem.refreshList then OnlineSystem.refreshList() end
	end)
	local PrintInfoBtn = makeBtn("📋 Print Info to Console", 32, false, false, function()
		if OnlineSystem.selectedPlayer then printPlayerInfo(OnlineSystem.selectedPlayer) end
	end)

	makeSeparator("── Danger ──", 40)
	local KillBtn = makeBtn("💀 Kill Player", 41, false, true, function()
		if OnlineSystem.selectedPlayer and OnlineSystem.selectedPlayer.Character then
			pcall(function() OnlineSystem.selectedPlayer.Character:BreakJoints() end)
			pcall(function()
				local hum = OnlineSystem.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.Health = 0 end
			end)
			showNotification("Killed: " .. OnlineSystem.selectedPlayer.Name, "warning")
		end
	end)
	local CrashBtn = makeBtn("💥 Crash Attempt", 42, false, true, function()
		if OnlineSystem.selectedPlayer then tryCrashPlayer(OnlineSystem.selectedPlayer) end
	end)

	local allActionButtons = {
		TeleportBtn, BringBtn, FlingBtn, LaunchBtn, LoopFlingBtn,
		FreezeBtn, StunBtn, StunLongBtn, AntiRespawnBtn,
		SpectateBtn, HideBtn, TagBtn, CloneBtn, CopyLookBtn,
		FriendBtn, PrintInfoBtn, KillBtn, CrashBtn
	}
	local allSeparators = {}
	for _, child in pairs(ActionsScroll:GetChildren()) do
		if child:IsA("Frame") and child ~= InfoCard then table.insert(allSeparators, child) end
	end

	local function updateActionsPanel()
		local sel = OnlineSystem.selectedPlayer; local show = sel ~= nil
		if show then
			NoSelectLabel.Visible = false; InfoCard.Visible = true
			for _, btn in ipairs(allActionButtons) do btn.Visible = true end
			for _, sep in ipairs(allSeparators) do sep.Visible = true end
			NameLabel.Text = sel.Name; IDLabel.Text = "ID: " .. tostring(sel.UserId)
			pcall(function()
				Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..sel.UserId.."&width=150&height=150&format=png"
			end)
			SpectateBtn.Text = (OnlineSystem.spectatingPlayer == sel) and "👁 UnSpectate" or "👁 Spectate"
			SpectateBtn.BackgroundColor3 = (OnlineSystem.spectatingPlayer == sel) and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(35, 35, 45)
			FriendBtn.Text = isFriend(sel.Name) and "★ Remove Friend" or "★ Add Friend"
			FriendBtn.BackgroundColor3 = isFriend(sel.Name) and Color3.fromRGB(40, 60, 20) or Color3.fromRGB(35, 35, 45)
			FreezeBtn.Text = OnlineSystem.frozenPlayers[sel] and "🔓 Unfreeze Player" or "❄ Freeze Player"
			FreezeBtn.BackgroundColor3 = OnlineSystem.frozenPlayers[sel] and Color3.fromRGB(40, 80, 120) or Color3.fromRGB(35, 35, 45)
			HideBtn.Text = OnlineSystem.hiddenPlayers[sel] and "👁 Show Player" or "🙈 Hide Player"
			HideBtn.BackgroundColor3 = OnlineSystem.hiddenPlayers[sel] and Color3.fromRGB(60, 50, 20) or Color3.fromRGB(35, 35, 45)
			loopFlingActive = loopFlingConnections[sel.Name] ~= nil
			LoopFlingBtn.Text = loopFlingActive and "🔁 Loop Fling: ON" or "🔁 Loop Fling: OFF"
			LoopFlingBtn.BackgroundColor3 = loopFlingActive and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(80, 30, 30)
			antiRespawnState = antiRespawnConnections[sel.Name] ~= nil
			AntiRespawnBtn.Text = antiRespawnState and "🚫 Anti Respawn: ON" or "🚫 Anti Respawn: OFF"
			AntiRespawnBtn.BackgroundColor3 = antiRespawnState and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(80, 30, 30)
			tagActive = OnlineSystem.tagConnections[sel.Name] ~= nil
			TagBtn.Text = tagActive and "🏷 Remove Tag" or "🏷 Add Tag (TARGET)"
			TagBtn.BackgroundColor3 = tagActive and Color3.fromRGB(80, 40, 80) or Color3.fromRGB(35, 35, 45)
		else
			NoSelectLabel.Visible = true; InfoCard.Visible = false
			for _, btn in ipairs(allActionButtons) do btn.Visible = false end
			for _, sep in ipairs(allSeparators) do sep.Visible = false end
		end
	end

	if OnlineSystem.infoUpdateConnection then
		pcall(function() OnlineSystem.infoUpdateConnection:Disconnect() end)
	end
	local lastInfoUpdate2 = 0
	OnlineSystem.infoUpdateConnection = RunService.Heartbeat:Connect(function()
		local now = tick()
		if now - lastInfoUpdate2 < 0.25 then return end
		lastInfoUpdate2 = now
		local sel = OnlineSystem.selectedPlayer
		if not sel or not InfoCard.Visible then return end
		local myHRP2 = getMyHRP(); local targetChar2 = sel.Character
		if myHRP2 and targetChar2 then
			local tHRP2 = targetChar2:FindFirstChild("HumanoidRootPart") or targetChar2:FindFirstChild("Torso")
			if tHRP2 then
				DistanceLabel.Text = "📍 Dist: " .. math.floor((tHRP2.Position - myHRP2.Position).Magnitude) .. "m"
			else
				DistanceLabel.Text = "Distance: -"
			end
		else
			DistanceLabel.Text = "Distance: -"
		end
		if targetChar2 then
			local hum = targetChar2:FindFirstChildOfClass("Humanoid")
			if hum then
				if hum.Health <= 0 then
					StatusLabel.Text = "💀 DEAD"; StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
				else
					local hp = math.floor(hum.Health); local maxHp = math.floor(hum.MaxHealth)
					StatusLabel.Text = "❤ HP: " .. hp .. "/" .. maxHp
					local pct = hum.Health / hum.MaxHealth
					StatusLabel.TextColor3 = pct > 0.6 and Color3.fromRGB(100,255,100) or pct > 0.3 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80)
				end
			else
				StatusLabel.Text = "HP: -"; StatusLabel.TextColor3 = Color3.fromRGB(180,180,190)
			end
		else
			StatusLabel.Text = "💀 No Character"; StatusLabel.TextColor3 = Color3.fromRGB(150,150,160)
		end
		PlayerCount.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
	end)

	local function createPlayerRow(plr)
		local Row = Instance.new("TextButton", PlayerListFrame)
		Row.Size = UDim2.new(1, 0, 0, 36); Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		Row.BackgroundTransparency = 0.3; Row.Text = ""; Row.BorderSizePixel = 0; Row.AutoButtonColor = false
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
		local RowStroke = Instance.new("UIStroke", Row)
		RowStroke.Color = Color3.fromRGB(230, 60, 110); RowStroke.Thickness = 2; RowStroke.Transparency = 1
		local MiniAvatar = Instance.new("ImageLabel", Row)
		MiniAvatar.Size = UDim2.new(0, 26, 0, 26); MiniAvatar.Position = UDim2.new(0, 5, 0.5, -13)
		MiniAvatar.BackgroundColor3 = Color3.fromRGB(50, 50, 60); MiniAvatar.BorderSizePixel = 0
		Instance.new("UICorner", MiniAvatar).CornerRadius = UDim.new(0, 4)
		pcall(function()
			MiniAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=48&height=48&format=png"
		end)
		local IconLbl = Instance.new("TextLabel", Row)
		IconLbl.Size = UDim2.new(0, 16, 0, 16); IconLbl.Position = UDim2.new(0, 33, 0.5, -8)
		IconLbl.BackgroundTransparency = 1; IconLbl.Text = "•"
		IconLbl.TextColor3 = Color3.fromRGB(100, 200, 100); IconLbl.TextSize = 14; IconLbl.Font = Enum.Font.GothamBold
		local NameLbl = Instance.new("TextLabel", Row)
		NameLbl.Size = UDim2.new(1, -90, 0, 18); NameLbl.Position = UDim2.new(0, 52, 0, 4)
		NameLbl.BackgroundTransparency = 1; NameLbl.Text = plr.Name
		NameLbl.TextColor3 = Color3.fromRGB(220, 220, 230); NameLbl.TextSize = 13
		NameLbl.Font = Enum.Font.GothamSemibold; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		local IDLbl = Instance.new("TextLabel", Row)
		IDLbl.Size = UDim2.new(1, -90, 0, 14); IDLbl.Position = UDim2.new(0, 52, 0, 20)
		IDLbl.BackgroundTransparency = 1; IDLbl.Text = "ID: " .. tostring(plr.UserId)
		IDLbl.TextColor3 = Color3.fromRGB(120, 120, 130); IDLbl.TextSize = 11
		IDLbl.Font = Enum.Font.Gotham; IDLbl.TextXAlignment = Enum.TextXAlignment.Left
		local HPBarBg = Instance.new("Frame", Row)
		HPBarBg.Size = UDim2.new(0, 40, 0, 4); HPBarBg.Position = UDim2.new(1, -48, 0.5, -2)
		HPBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50); HPBarBg.BorderSizePixel = 0
		Instance.new("UICorner", HPBarBg).CornerRadius = UDim.new(1, 0)
		local HPBar = Instance.new("Frame", HPBarBg)
		HPBar.Size = UDim2.new(1, 0, 1, 0); HPBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		HPBar.BorderSizePixel = 0
		Instance.new("UICorner", HPBar).CornerRadius = UDim.new(1, 0)
		local function updateIcon()
			if isFriend(plr.Name) then
				IconLbl.Text = "★"; IconLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
			elseif plr == player then
				IconLbl.Text = "♦"; IconLbl.TextColor3 = Color3.fromRGB(100, 150, 255)
			else
				IconLbl.Text = "•"; IconLbl.TextColor3 = Color3.fromRGB(100, 200, 100)
			end
		end
		updateIcon()
		local lastHPUpdate = 0
		RunService.Heartbeat:Connect(function()
			local now = tick()
			if now - lastHPUpdate < 0.5 then return end
			lastHPUpdate = now
			if not Row.Parent then return end
			if plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.MaxHealth > 0 then
					local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					HPBar.Size = UDim2.new(pct, 0, 1, 0)
					HPBar.BackgroundColor3 = pct > 0.6 and Color3.fromRGB(100,255,100) or pct > 0.3 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80)
				else
					HPBar.Size = UDim2.new(0, 0, 1, 0)
				end
			else
				HPBar.Size = UDim2.new(0, 0, 1, 0)
			end
		end)
		local function setSelected(isSelected)
			if isSelected then
				Row.BackgroundTransparency = 0; Row.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
				RowStroke.Transparency = 0; NameLbl.Font = Enum.Font.GothamBold
			else
				Row.BackgroundTransparency = 0.3; Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				RowStroke.Transparency = 1; NameLbl.Font = Enum.Font.GothamSemibold
			end
		end
		Row.MouseEnter:Connect(function()
			playHover()
			if OnlineSystem.selectedPlayer ~= plr then
				TweenService:Create(Row, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(45,45,55)}):Play()
			end
		end)
		Row.MouseLeave:Connect(function()
			if OnlineSystem.selectedPlayer ~= plr then
				TweenService:Create(Row, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(30,30,38)}):Play()
			end
		end)
		Row.MouseButton1Click:Connect(function()
			playClick()
			for _, data in pairs(OnlineSystem.playerListItems) do
				if data.setSelected then data.setSelected(false) end
			end
			OnlineSystem.selectedPlayer = plr; setSelected(true); updateActionsPanel()
		end)
		return Row, updateIcon, setSelected
	end

	local function refreshPlayerList()
		for _, child in pairs(PlayerListFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		OnlineSystem.playerListItems = {}
		local searchText = SearchBox.Text:lower()
		local allPlayers = Players:GetPlayers()
		table.sort(allPlayers, function(a, b)
			if a == player then return true end
			if b == player then return false end
			local aF = isFriend(a.Name); local bF = isFriend(b.Name)
			if aF and not bF then return true end
			if bF and not aF then return false end
			return a.Name:lower() < b.Name:lower()
		end)
		PlayerCount.Text = #allPlayers .. "/" .. Players.MaxPlayers
		for _, plr in ipairs(allPlayers) do
			if searchText == "" or plr.Name:lower():find(searchText, 1, true) then
				local row, updateIcon, setSelected = createPlayerRow(plr)
				OnlineSystem.playerListItems[plr] = {row=row, updateIcon=updateIcon, setSelected=setSelected}
				if OnlineSystem.selectedPlayer == plr then setSelected(true) end
			end
		end
	end

	OnlineSystem.refreshList = refreshPlayerList
	SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayerList)
	Players.PlayerAdded:Connect(function() task.wait(0.1); pcall(refreshPlayerList) end)
	Players.PlayerRemoving:Connect(function(plr)
		task.wait(0.1)
		if OnlineSystem.selectedPlayer == plr then
			OnlineSystem.selectedPlayer = nil; updateActionsPanel()
		end
		pcall(refreshPlayerList)
	end)
	refreshPlayerList(); updateActionsPanel()
end

-- ========== SELF PAGE ==========
local function buildSelfPlayerPage(page)
	local lc = createPanel(page, UDim2.new(0, 0, 0, 0), UDim2.new(0.33, -5, 1, -10), "Self", "♥")
	createToggle(lc, "God Mode", false, function(s) Self.settings.godMode = s; toggleGodMode(s) end)
	createToggle(lc, "Semi God Mode", false, function(s) Self.settings.semiGodMode = s; toggleSemiGod(s) end)
	createToggle(lc, "Noclip", false, function(s) Self.settings.noclip = s; toggleNoclip(s) end)
	createToggle(lc, "Damage Reducer", false, function(s) Self.settings.damageReducer = s; toggleDamageReducer(s) end)
	createToggle(lc, "Invisible", false, function(s) Self.settings.invisible = s; toggleInvisible(s) end)
	createToggleWithWarning(lc, "Killer Man", false, "Zabija graczy w promieniu.", function(s) Self.settings.killerMan = s; toggleKillerMan(s) end)
	createToggle(lc, "Infinite Stamina", false, function(s) Self.settings.infiniteStamina = s; toggleInfiniteStamina(s) end)
	createToggle(lc, "Fast Run", false, function(s) Self.settings.fastRun = s; toggleFastRun(s) end)
	createToggle(lc, "No Collision", false, function(s) Self.settings.noCollision = s; toggleNoCollision(s) end)
	createToggle(lc, "Binded Heal (H)", false, function(s) Self.settings.bindedHeal = s end)
	createToggleWithWarning(lc, "Spinbot", false, "Obraca postać.", function(s) Self.settings.spinbot = s; toggleSpinbot(s) end)
	createToggle(lc, "Anti AFK", false, function(s) Self.settings.antiAfk = s; toggleAntiAfk(s) end)
	createToggle(lc, "No Fall Damage", false, function(s) Self.settings.noFall = s; toggleNoFall(s) end)
	createToggleWithWarning(lc, "Big Head (enemies)", false, "Powiększa głowy wrogów.", function(s) Self.settings.bigHead = s; toggleBigHead(s) end)
	local mc = createPanel(page, UDim2.new(0.33, 0, 0, 0), UDim2.new(0.34, -5, 0.55, -5), "Functions", "♥")
	createFunctionButton(mc, "Heal", function() healSelf(); showNotification("Healed", "success") end)
	createFunctionButton(mc, "Armor", function()
		local c = getMyChar()
		if c then
			local a = c:FindFirstChild("Armor")
			if not a then a = Instance.new("NumberValue"); a.Name = "Armor"; a.Parent = c end
			a.Value = 100
		end
	end)
	createFunctionButton(mc, "Revive", function() reviveSelf(); showNotification("Revived", "success") end)
	createFunctionButton(mc, "Respawn", respawnSelf)
	createFunctionButton(mc, "Random Outfit", randomOutfit)
	createFunctionButton(mc, "Start Solo Session", startSoloSession)
	createFunctionButton(mc, "Reset Camera", function() Camera.CameraType = Enum.CameraType.Custom; Camera.CameraSubject = getMyHum() end)
	local sc = createPanel(page, UDim2.new(0.33, 0, 0.55, 5), UDim2.new(0.34, -5, 0.45, -15), "Settings", "⚙")
	createSlider(sc, "Noclip Speed", 0.5, 10, 3.0, function(v) Self.settings.noclipSpeed = v end)
	createSlider(sc, "Walk Speed", 8, 100, 16, function(v) Self.settings.walkSpeed = v; local h = getMyHum(); if h then h.WalkSpeed = Self.settings.fastRun and (v*2.5) or v end end)
	createSlider(sc, "Jump Power", 30, 500, 50, function(v) Self.settings.jumpPower = v; local h = getMyHum(); if h then pcall(function() h.UseJumpPower = true; h.JumpPower = v end) end end)
	createSlider(sc, "Damage Reducer %", 0, 99, 50, function(v) Self.settings.damageReducerAmount = v end)
	createSlider(sc, "Killer Range (m)", 5, 500, 30, function(v) Self.settings.killerRange = v end)
	createSlider(sc, "Spin Speed", 1, 500, 30, function(v) Self.settings.spinSpeed = v end)
	local rc = createPanel(page, UDim2.new(0.67, 5, 0, 0), UDim2.new(0.33, -5, 1, -10), "More", "♥")
	createFunctionButton(rc, "Teleport Forward", function() local h = getMyHRP(); if h then h.CFrame = h.CFrame + h.CFrame.LookVector * 20 end end)
	createFunctionButton(rc, "Teleport Back", function() local h = getMyHRP(); if h then h.CFrame = h.CFrame - h.CFrame.LookVector * 20 end end)
	createFunctionButton(rc, "Fly Up", function() local h = getMyHRP(); if h then h.CFrame = h.CFrame + Vector3.new(0,30,0) end end)
	createFunctionButton(rc, "Fly Down", function() local h = getMyHRP(); if h then h.CFrame = h.CFrame - Vector3.new(0,30,0) end end)
	createFunctionButton(rc, "Freeze Character", function() local h = getMyHRP(); if h then h.Anchored = true end end)
	createFunctionButton(rc, "Unfreeze Character", function() local h = getMyHRP(); if h then h.Anchored = false end end)
	createFunctionButton(rc, "Clear Backpack", function() local bp = player:FindFirstChild("Backpack"); if bp then bp:ClearAllChildren() end end)
end

local function buildWeaponPage(page)
	local lc = createPanel(page, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -5, 1, -10), "Weapon Mods", "🎯")
	createToggleWithWarning(lc, "No Recoil", false, "Zeruje odrzut.", function(s) Weapon.settings.noRecoil = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "No Spread", false, "Zeruje rozrzut.", function(s) Weapon.settings.noSpread = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "Fast Reload", false, "Instant reload.", function(s) Weapon.settings.fastReload = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "Infinite Ammo", false, "9999 amunicji.", function(s) Weapon.settings.infiniteAmmo = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "Rapid Fire", false, "Max szybkostrzelność.", function(s) Weapon.settings.rapidFire = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "Damage Multiplier", false, "Większe obrażenia.", function(s) Weapon.settings.damageMultiplier = s; updateWeaponSystem() end)
	createToggleWithWarning(lc, "Explosive Ammo", false, "Eksplozja przy kliknięciu.", function(s) Weapon.settings.explosiveAmmo = s; toggleExplosiveAmmo(s) end)
	local rc = createPanel(page, UDim2.new(0.5, 5, 0, 0), UDim2.new(0.5, -5, 1, -10), "Settings", "⚙")
	createSlider(rc, "Damage Multiplier", 1, 100, 5, function(v) Weapon.settings.damageMultValue = v end)
	createSlider(rc, "Rapid Fire Delay", 0.01, 0.5, 0.05, function(v) Weapon.settings.rapidFireDelay = v end)
end

local function buildPlayersPage(page)
	local lc = createPanel(page, UDim2.new(0,0,0,0), UDim2.new(0.5,-5,1,-10), "Player Visuals", "👁")
	createToggle(lc, "Enable ESP", false, function(s) ESP.settings.enabled = s end)
	createToggleWithColor(lc, "Box", false, ESP.settings.boxColor, function(s) ESP.settings.box = s end, function(c) ESP.settings.boxColor = c end)
	createToggleWithColor(lc, "Skeleton", false, ESP.settings.skeletonColor, function(s) ESP.settings.skeleton = s end, function(c) ESP.settings.skeletonColor = c end)
	createToggleWithColor(lc, "Health Bar", false, ESP.settings.healthBarColor, function(s) ESP.settings.healthBar = s end, function(c) ESP.settings.healthBarColor = c end)
	createToggle(lc, "Distance ESP", false, function(s) ESP.settings.distanceESP = s end)
	createToggleWithColor(lc, "Player Names", false, ESP.settings.nameColor, function(s) ESP.settings.playerNames = s end, function(c) ESP.settings.nameColor = c end)
	createToggleWithColor(lc, "Snapline", false, ESP.settings.snaplineColor, function(s) ESP.settings.snapline = s end, function(c) ESP.settings.snaplineColor = c end)
	createToggle(lc, "Wallcheck", false, function(s) ESP.settings.wallcheck = s end)
	local rc = createPanel(page, UDim2.new(0.5,5,0,0), UDim2.new(0.5,-5,1,-10), "Settings", "⚙")
	createToggle(rc, "Draw Dead", false, function(s) ESP.settings.drawDead = s end)
	createToggle(rc, "Draw Self", false, function(s) ESP.settings.drawSelf = s end)
	createColorOption(rc, "Friend Color", ESP.settings.friendColor, function(c) ESP.settings.friendColor = c end)
	createSlider(rc, "Distance", 0, 5000, 2500, function(v) ESP.settings.distance = v end)
end

-- ========== WORLD PAGE ==========
local WorldState = {
	fpsBoost = false, removeFog = false, fullbright = false, alwaysDay = false, alwaysNight = false,
	removeTextures = false, removeShadows = false, noSky = false, lowTerrain = false, freezeTime = false,
	antiLag = false, noBlur = false, noBloom = false, noSSAO = false, removeSounds = false,
	removeMeshes = false, cartoonMode = false,
	originalMaterials = {}, originalDecals = {}, originalParts = {}, originalParticles = {},
	originalSky = {}, originalSounds = {}, originalTerrain = nil,
	freezeTimeConn = nil, freezeTimeValue = nil,
}

local function scanWorkspaceCallback(cb, batchSize)
	batchSize = batchSize or 500
	task.spawn(function()
		local count = 0
		for _, v in pairs(workspace:GetDescendants()) do
			pcall(cb, v)
			count = count + 1
			if count >= batchSize then count = 0; task.wait() end
		end
	end)
end

local function buildWorldPage(page)
	local lc = createPanel(page, UDim2.new(0,0,0,0), UDim2.new(0.5,-5,1,-10), "World Options", "🌍")
	local origLighting = {
		FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
		Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime,
		GlobalShadows = Lighting.GlobalShadows,
		ColorShift_Bottom = Lighting.ColorShift_Bottom, ColorShift_Top = Lighting.ColorShift_Top,
	}
	local terr = workspace:FindFirstChildOfClass("Terrain")
	if terr then
		WorldState.originalTerrain = {
			WaterWaveSize = terr.WaterWaveSize, WaterWaveSpeed = terr.WaterWaveSpeed,
			WaterReflectance = terr.WaterReflectance, WaterTransparency = terr.WaterTransparency,
		}
	end

	createToggleWithWarning(lc, "FPS Boost", false, "Ogromny boost FPS.", function(s)
		WorldState.fpsBoost = s
		if s then
			scanWorkspaceCallback(function(v)
				if v:IsA("BasePart") and not WorldState.originalMaterials[v] then
					WorldState.originalMaterials[v] = {Material=v.Material, Reflectance=v.Reflectance}
					v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
				elseif (v:IsA("Decal") or v:IsA("Texture")) and not WorldState.originalDecals[v] then
					WorldState.originalDecals[v] = v.Transparency; v.Transparency = 1
				end
			end)
			Lighting.GlobalShadows = false
			pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			for _, eff in pairs(Lighting:GetChildren()) do
				if eff:IsA("PostEffect") or eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
					pcall(function() eff.Enabled = false end)
				end
			end
			showNotification("FPS Boost enabled!", "success")
		else
			task.spawn(function()
				local c = 0
				for p, pr in pairs(WorldState.originalMaterials) do
					if p and p.Parent then pcall(function() p.Material = pr.Material; p.Reflectance = pr.Reflectance end) end
					c = c+1; if c >= 500 then c = 0; task.wait() end
				end
				WorldState.originalMaterials = {}
				for d, t in pairs(WorldState.originalDecals) do
					if d and d.Parent then pcall(function() d.Transparency = t end) end
					c = c+1; if c >= 500 then c = 0; task.wait() end
				end
				WorldState.originalDecals = {}
			end)
			Lighting.GlobalShadows = origLighting.GlobalShadows
			pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
			for _, eff in pairs(Lighting:GetChildren()) do
				if eff:IsA("PostEffect") or eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
					pcall(function() eff.Enabled = true end)
				end
			end
			showNotification("FPS Boost disabled", "info")
		end
	end)
	createToggle(lc, "Remove Fog", false, function(s)
		Lighting.FogEnd = s and 100000 or origLighting.FogEnd
		Lighting.FogStart = s and 100000 or origLighting.FogStart
	end)
	createToggle(lc, "Fullbright", false, function(s)
		if s then
			Lighting.Brightness = 3; Lighting.Ambient = Color3.fromRGB(255,255,255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
			Lighting.ColorShift_Bottom = Color3.fromRGB(255,255,255)
			Lighting.ColorShift_Top = Color3.fromRGB(255,255,255)
		else
			Lighting.Brightness = origLighting.Brightness; Lighting.Ambient = origLighting.Ambient
			Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
			Lighting.ColorShift_Bottom = origLighting.ColorShift_Bottom
			Lighting.ColorShift_Top = origLighting.ColorShift_Top
		end
	end)
	createToggle(lc, "Always Day", false, function(s) Lighting.ClockTime = s and 14 or origLighting.ClockTime end)
	createToggle(lc, "Always Night", false, function(s) Lighting.ClockTime = s and 0 or origLighting.ClockTime end)
	createToggleWithWarning(lc, "Remove Textures", false, "Iteruje tekstury.", function(s)
		if s then
			scanWorkspaceCallback(function(v)
				if (v:IsA("Decal") or v:IsA("Texture")) and not WorldState.originalDecals[v] then
					WorldState.originalDecals[v] = v.Transparency; v.Transparency = 1
				end
			end)
		else
			task.spawn(function()
				local c = 0
				for d, t in pairs(WorldState.originalDecals) do
					if d and d.Parent then pcall(function() d.Transparency = t end) end
					c = c+1; if c >= 500 then c = 0; task.wait() end
				end
				WorldState.originalDecals = {}
			end)
		end
	end)
	createToggle(lc, "Remove Shadows", false, function(s) Lighting.GlobalShadows = not s end)
	createToggle(lc, "No Sky", false, function(s)
		if s then
			WorldState.originalSky = {}
			for _, v in pairs(Lighting:GetChildren()) do
				if v:IsA("Sky") then table.insert(WorldState.originalSky, v:Clone()); v:Destroy() end
			end
		else
			for _, sky in pairs(WorldState.originalSky) do sky.Parent = Lighting end
			WorldState.originalSky = {}
		end
	end)
	createToggle(lc, "Low Detail Terrain", false, function(s)
		local tr = workspace:FindFirstChildOfClass("Terrain")
		if tr then
			if s then
				tr.WaterWaveSize = 0; tr.WaterWaveSpeed = 0; tr.WaterReflectance = 0; tr.WaterTransparency = 0
			elseif WorldState.originalTerrain then
				pcall(function()
					tr.WaterWaveSize = WorldState.originalTerrain.WaterWaveSize
					tr.WaterWaveSpeed = WorldState.originalTerrain.WaterWaveSpeed
					tr.WaterReflectance = WorldState.originalTerrain.WaterReflectance
					tr.WaterTransparency = WorldState.originalTerrain.WaterTransparency
				end)
			end
		end
	end)
	createToggleWithWarning(lc, "Freeze Time", false, "Blokuje czas.", function(s)
		if s then
			WorldState.freezeTimeValue = Lighting.ClockTime
			if WorldState.freezeTimeConn then WorldState.freezeTimeConn:Disconnect() end
			local lastUpdate = 0
			WorldState.freezeTimeConn = RunService.Stepped:Connect(function()
				local now = tick()
				if now - lastUpdate > 0.1 then
					lastUpdate = now
					if Lighting.ClockTime ~= WorldState.freezeTimeValue then
						Lighting.ClockTime = WorldState.freezeTimeValue
					end
				end
			end)
		else
			if WorldState.freezeTimeConn then WorldState.freezeTimeConn:Disconnect(); WorldState.freezeTimeConn = nil end
		end
	end)
	createToggleWithWarning(lc, "Anti Lag", false, "Wyłącza particle/trail.", function(s)
		if s then
			scanWorkspaceCallback(function(v)
				if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")) and WorldState.originalParticles[v] == nil then
					WorldState.originalParticles[v] = v.Enabled; v.Enabled = false
				end
			end)
		else
			for p, e in pairs(WorldState.originalParticles) do
				if p and p.Parent then pcall(function() p.Enabled = e end) end
			end
			WorldState.originalParticles = {}
		end
	end)
	createToggle(lc, "No Blur", false, function(s)
		for _, eff in pairs(Lighting:GetChildren()) do
			if eff:IsA("BlurEffect") then pcall(function() eff.Enabled = not s end) end
		end
	end)
	createToggle(lc, "No Bloom", false, function(s)
		for _, eff in pairs(Lighting:GetChildren()) do
			if eff:IsA("BloomEffect") or eff:IsA("SunRaysEffect") then pcall(function() eff.Enabled = not s end) end
		end
	end)
	createToggle(lc, "No SSAO/DOF", false, function(s)
		for _, eff in pairs(Lighting:GetChildren()) do
			if eff:IsA("DepthOfFieldEffect") then pcall(function() eff.Enabled = not s end) end
		end
	end)
	createToggleWithWarning(lc, "Mute All Sounds", false, "Wycisza dźwięki.", function(s)
		if s then
			WorldState.originalSounds = {}
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("Sound") then WorldState.originalSounds[v] = v.Volume; pcall(function() v.Volume = 0 end) end
			end
			pcall(function() SoundService.Volume = 0 end)
		else
			for s2, vol in pairs(WorldState.originalSounds) do
				if s2 and s2.Parent then pcall(function() s2.Volume = vol end) end
			end
			WorldState.originalSounds = {}
			pcall(function() SoundService.Volume = 1 end)
		end
	end)
	createToggleWithWarning(lc, "Remove Mesh Details", false, "Usuwa mesh detale.", function(s)
		if s then
			scanWorkspaceCallback(function(v)
				if (v:IsA("SpecialMesh") or v:IsA("MeshPart")) and not WorldState.originalParts[v] then
					if v:IsA("MeshPart") then
						WorldState.originalParts[v] = {mesh = v.MeshId, texture = v.TextureID}
						pcall(function() v.TextureID = "" end)
					elseif v:IsA("SpecialMesh") then
						WorldState.originalParts[v] = {mesh = v.MeshId, texture = v.TextureId}
						pcall(function() v.TextureId = "" end)
					end
				end
			end)
		else
			for p, data in pairs(WorldState.originalParts) do
				if p and p.Parent then
					pcall(function()
						if p:IsA("MeshPart") then p.TextureID = data.texture
						elseif p:IsA("SpecialMesh") then p.TextureId = data.texture end
					end)
				end
			end
			WorldState.originalParts = {}
		end
	end)
	createToggle(lc, "Cartoon Mode", false, function(s)
		WorldState.cartoonMode = s
		if s then
			scanWorkspaceCallback(function(v)
				if v:IsA("BasePart") and not WorldState.originalMaterials[v] then
					WorldState.originalMaterials[v] = {Material=v.Material, Reflectance=v.Reflectance}
					pcall(function() v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0.3 end)
				end
			end)
			Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 220)
		else
			for p, pr in pairs(WorldState.originalMaterials) do
				if p and p.Parent then pcall(function() p.Material = pr.Material; p.Reflectance = pr.Reflectance end) end
			end
			WorldState.originalMaterials = {}
			Lighting.Brightness = origLighting.Brightness; Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
		end
	end)

	local rc = createPanel(page, UDim2.new(0.5,5,0,0), UDim2.new(0.5,-5,1,-10), "World Settings", "⚙")
	createSlider(rc, "Brightness", 0, 10, origLighting.Brightness, function(v) Lighting.Brightness = v end)
	createSlider(rc, "Fog Distance", 0, 10000, math.min(origLighting.FogEnd, 10000), function(v) Lighting.FogEnd = v end)
	createSlider(rc, "Time of Day", 0, 24, origLighting.ClockTime, function(v)
		Lighting.ClockTime = v
		if WorldState.freezeTimeConn then WorldState.freezeTimeValue = v end
	end)
	createSlider(rc, "Ambient Light", 0, 255, 128, function(v) Lighting.Ambient = Color3.fromRGB(v, v, v) end)
	createSlider(rc, "Outdoor Ambient", 0, 255, 128, function(v) Lighting.OutdoorAmbient = Color3.fromRGB(v, v, v) end)
	createSlider(rc, "Fog Start", 0, 5000, math.min(origLighting.FogStart, 5000), function(v) Lighting.FogStart = v end)
	createFunctionButton(rc, "🌅 Preset: Dawn", function()
		Lighting.ClockTime = 6; Lighting.Brightness = 1.5
		Lighting.Ambient = Color3.fromRGB(150, 130, 100)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 170, 130)
		showNotification("Dawn preset applied", "success")
	end)
	createFunctionButton(rc, "☀️ Preset: Bright Day", function()
		Lighting.ClockTime = 12; Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(230, 230, 230)
		Lighting.FogEnd = 100000
		showNotification("Bright Day preset applied", "success")
	end)
	createFunctionButton(rc, "🌇 Preset: Sunset", function()
		Lighting.ClockTime = 18; Lighting.Brightness = 1.2
		Lighting.Ambient = Color3.fromRGB(180, 100, 60)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 130, 90)
		showNotification("Sunset preset applied", "success")
	end)
	createFunctionButton(rc, "🌙 Preset: Night", function()
		Lighting.ClockTime = 0; Lighting.Brightness = 0.3
		Lighting.Ambient = Color3.fromRGB(30, 30, 60)
		Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 80)
		showNotification("Night preset applied", "success")
	end)
	createFunctionButton(rc, "🔄 Reset to Default", function()
		Lighting.Brightness = origLighting.Brightness; Lighting.Ambient = origLighting.Ambient
		Lighting.OutdoorAmbient = origLighting.OutdoorAmbient; Lighting.ClockTime = origLighting.ClockTime
		Lighting.FogEnd = origLighting.FogEnd; Lighting.FogStart = origLighting.FogStart
		Lighting.GlobalShadows = origLighting.GlobalShadows
		Lighting.ColorShift_Bottom = origLighting.ColorShift_Bottom
		Lighting.ColorShift_Top = origLighting.ColorShift_Top
		showNotification("Reset to default lighting", "info")
	end)
end

-- ========== RADAR PAGE ==========
local RadarState = {
	enabled = false, transparency = 0.7, zoom = 1.0, size = 200,
	rotateWithCamera = true, showSelf = true, circularBorder = true, showCrosshair = true,
	drawPlayers = true, drawDead = false, drawVehicles = false, drawFriends = true,
	showDistanceRings = false, showCardinals = true, blipSize = 8,
	borderColor = Color3.fromRGB(230, 60, 110), enemyColor = Color3.fromRGB(230, 60, 110),
	friendColor = Color3.fromRGB(0, 255, 0), deadColor = Color3.fromRGB(120, 120, 120),
	vehicleColor = Color3.fromRGB(255, 200, 50), selfColor = Color3.fromRGB(100, 200, 255),
	backgroundColor = Color3.fromRGB(15, 15, 20),
	renderConn = nil, blipPool = {}, vehicleCache = {}, lastVehicleScan = 0,
}

local function buildRadarPage(page)
	local RG = player.PlayerGui:FindFirstChild("SBX_Radar")
	if RG then RG:Destroy() end
	RG = Instance.new("ScreenGui")
	RG.Name = "SBX_Radar"; RG.ResetOnSpawn = false; RG.IgnoreGuiInset = true
	RG.Parent = player.PlayerGui; RG.Enabled = false

	local RF = Instance.new("Frame")
	RF.Size = UDim2.new(0, RadarState.size, 0, RadarState.size)
	RF.Position = UDim2.new(1, -RadarState.size - 20, 0, 20)
	RF.BackgroundColor3 = RadarState.backgroundColor
	RF.BackgroundTransparency = 1 - RadarState.transparency
	RF.BorderSizePixel = 0; RF.Active = false; RF.Draggable = false; RF.Parent = RG
	Instance.new("UICorner", RF).CornerRadius = UDim.new(1, 0)

	local RSt = Instance.new("UIStroke", RF)
	RSt.Color = RadarState.borderColor; RSt.Thickness = 2; RSt.Transparency = 0.3

	local HLn = Instance.new("Frame", RF)
	HLn.Size = UDim2.new(1, 0, 0, 1); HLn.Position = UDim2.new(0, 0, 0.5, 0)
	HLn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); HLn.BackgroundTransparency = 0.5
	HLn.BorderSizePixel = 0; HLn.ZIndex = 2

	local VLn = Instance.new("Frame", RF)
	VLn.Size = UDim2.new(0, 1, 1, 0); VLn.Position = UDim2.new(0.5, 0, 0, 0)
	VLn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); VLn.BackgroundTransparency = 0.5
	VLn.BorderSizePixel = 0; VLn.ZIndex = 2

	local CDt = Instance.new("Frame", RF)
	CDt.Size = UDim2.new(0, 6, 0, 6); CDt.Position = UDim2.new(0.5, -3, 0.5, -3)
	CDt.BackgroundColor3 = Color3.fromRGB(255, 255, 255); CDt.BorderSizePixel = 0; CDt.ZIndex = 5
	Instance.new("UICorner", CDt).CornerRadius = UDim.new(1, 0)

	local ring1 = Instance.new("Frame", RF)
	ring1.Size = UDim2.new(0.33, 0, 0.33, 0); ring1.Position = UDim2.new(0.335, 0, 0.335, 0)
	ring1.BackgroundTransparency = 1; ring1.BorderSizePixel = 0; ring1.ZIndex = 1; ring1.Visible = false
	Instance.new("UICorner", ring1).CornerRadius = UDim.new(1, 0)
	local ring1Stroke = Instance.new("UIStroke", ring1)
	ring1Stroke.Color = Color3.fromRGB(60, 60, 70); ring1Stroke.Thickness = 1; ring1Stroke.Transparency = 0.6

	local ring2 = Instance.new("Frame", RF)
	ring2.Size = UDim2.new(0.66, 0, 0.66, 0); ring2.Position = UDim2.new(0.17, 0, 0.17, 0)
	ring2.BackgroundTransparency = 1; ring2.BorderSizePixel = 0; ring2.ZIndex = 1; ring2.Visible = false
	Instance.new("UICorner", ring2).CornerRadius = UDim.new(1, 0)
	local ring2Stroke = Instance.new("UIStroke", ring2)
	ring2Stroke.Color = Color3.fromRGB(60, 60, 70); ring2Stroke.Thickness = 1; ring2Stroke.Transparency = 0.6

	local function makeCardinal(text, pos)
		local L = Instance.new("TextLabel", RF)
		L.Size = UDim2.new(0, 14, 0, 14); L.BackgroundTransparency = 1
		L.Text = text; L.TextColor3 = Color3.fromRGB(200, 200, 210)
		L.TextSize = 11; L.Font = Enum.Font.GothamBold
		L.TextStrokeTransparency = 0.5; L.ZIndex = 3
		L.AnchorPoint = Vector2.new(0.5, 0.5); L.Position = pos
		return L
	end
	local NLbl = makeCardinal("N", UDim2.new(0.5, 0, 0, 8))
	local SLbl = makeCardinal("S", UDim2.new(0.5, 0, 1, -8))
	local ELbl = makeCardinal("E", UDim2.new(1, -8, 0.5, 0))
	local WLbl = makeCardinal("W", UDim2.new(0, 8, 0.5, 0))

	local BCt = Instance.new("Frame", RF)
	BCt.Size = UDim2.new(1, 0, 1, 0); BCt.BackgroundTransparency = 1; BCt.ClipsDescendants = true
	Instance.new("UICorner", BCt).CornerRadius = UDim.new(1, 0)

	local ZoomLbl = Instance.new("TextLabel", RF)
	ZoomLbl.Size = UDim2.new(0, 60, 0, 15); ZoomLbl.Position = UDim2.new(0.5, -30, 1, 5)
	ZoomLbl.BackgroundTransparency = 1
	ZoomLbl.Text = string.format("%.1fx | %dm", RadarState.zoom, math.floor(500/RadarState.zoom))
	ZoomLbl.TextColor3 = Color3.fromRGB(200, 200, 210); ZoomLbl.TextSize = 10
	ZoomLbl.Font = Enum.Font.GothamSemibold; ZoomLbl.TextStrokeTransparency = 0.5

	local iDrag = false; local dStart, sPos
	RF.InputBegan:Connect(function(i)
		if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and MainFrame.Visible and not minimized then
			iDrag = true; dStart = i.Position; sPos = RF.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if iDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dStart
			RF.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			iDrag = false
		end
	end)

	local function updateDragMode()
		if MainFrame.Visible and not minimized then
			RF.Active = true; RSt.Color = Color3.fromRGB(100, 255, 100)
		else
			RF.Active = false; iDrag = false; RSt.Color = RadarState.borderColor
		end
	end
	MainFrame:GetPropertyChangedSignal("Visible"):Connect(updateDragMode)

	local function scanVehicles()
		RadarState.vehicleCache = {}
		local c = 0
		for _, o in pairs(workspace:GetDescendants()) do
			if o:IsA("VehicleSeat") then
				table.insert(RadarState.vehicleCache, o); c = c + 1
				if c >= 100 then break end
			end
		end
	end

	local function getBlip(idx, col, sz)
		local b = RadarState.blipPool[idx]
		if not b or not b.Parent then
			b = Instance.new("Frame"); b.BorderSizePixel = 0
			b.AnchorPoint = Vector2.new(0.5, 0.5); b.ZIndex = 3
			Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
			RadarState.blipPool[idx] = b
		end
		b.Size = UDim2.new(0, sz, 0, sz); b.BackgroundColor3 = col
		b.Parent = BCt; b.Visible = true
		return b
	end

	local function hideBlipsFrom(f)
		for i = f, #RadarState.blipPool do
			if RadarState.blipPool[i] then RadarState.blipPool[i].Visible = false end
		end
	end

	local lastRadarUpdate = 0
	local function updateRadar()
		local now = tick()
		if now - lastRadarUpdate < 0.05 then return end
		lastRadarUpdate = now
		local ch = player.Character
		if not ch then hideBlipsFrom(1); return end
		local hr = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso")
		if not hr then hideBlipsFrom(1); return end
		local cam = workspace.CurrentCamera; if not cam then return end
		local rs = RF.AbsoluteSize.X; local maxDist = 500 / RadarState.zoom
		local blipIdx = 1
		local cf = cam.CFrame; local cr = cf.RightVector; local cl = cf.LookVector
		local hp = hr.Position

		if RadarState.drawPlayers then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player and p.Character then
					local th = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
					local hm = p.Character:FindFirstChildOfClass("Humanoid")
					if th then
						local dead = hm and hm.Health <= 0
						local isFr = isFriend(p.Name)
						local shouldDraw = true
						if dead and not RadarState.drawDead then shouldDraw = false end
						if isFr and not RadarState.drawFriends then shouldDraw = false end
						if shouldDraw then
							local rel = th.Position - hp; local dist = rel.Magnitude
							if dist <= maxDist then
								local x, z
								if RadarState.rotateWithCamera then
									x = cr.X * rel.X + cr.Z * rel.Z; z = cl.X * rel.X + cl.Z * rel.Z
								else x = rel.X; z = rel.Z end
								local sc = (rs/2) / maxDist
								local blipCol
								if dead then blipCol = RadarState.deadColor
								elseif isFr then blipCol = RadarState.friendColor
								else blipCol = RadarState.enemyColor end
								local blip = getBlip(blipIdx, blipCol, RadarState.blipSize)
								blip.Position = UDim2.new(0.5 + (x*sc)/rs, 0, 0.5 - (z*sc)/rs, 0)
								blipIdx = blipIdx + 1
							end
						end
					end
				end
			end
		end

		if RadarState.drawVehicles then
			if now - RadarState.lastVehicleScan > 3 then
				RadarState.lastVehicleScan = now; task.spawn(scanVehicles)
			end
			for i = #RadarState.vehicleCache, 1, -1 do
				local vp = RadarState.vehicleCache[i]
				if vp and vp.Parent then
					local rel = vp.Position - hp; local dist = rel.Magnitude
					if dist <= maxDist then
						local x, z
						if RadarState.rotateWithCamera then
							x = cr.X * rel.X + cr.Z * rel.Z; z = cl.X * rel.X + cl.Z * rel.Z
						else x = rel.X; z = rel.Z end
						local sc = (rs/2) / maxDist
						local blip = getBlip(blipIdx, RadarState.vehicleColor, math.max(RadarState.blipSize - 2, 4))
						blip.Position = UDim2.new(0.5 + (x*sc)/rs, 0, 0.5 - (z*sc)/rs, 0)
						blipIdx = blipIdx + 1
					end
				else table.remove(RadarState.vehicleCache, i) end
			end
		end

		if RadarState.showSelf then
			local sBlip = getBlip(blipIdx, RadarState.selfColor, RadarState.blipSize + 2)
			sBlip.Position = UDim2.new(0.5, 0, 0.5, 0)
			blipIdx = blipIdx + 1
		end

		hideBlipsFrom(blipIdx)
		ZoomLbl.Text = string.format("%.1fx | %dm", RadarState.zoom, math.floor(maxDist))
	end

	local lc = createPanel(page, UDim2.new(0,0,0,0), UDim2.new(0.5,-5,1,-10), "Radar Options", "🌐")
	createToggle(lc, "Enable Radar", false, function(s)
		RadarState.enabled = s; RG.Enabled = s
		if s then
			if RadarState.renderConn then RadarState.renderConn:Disconnect() end
			RadarState.renderConn = RunService.Heartbeat:Connect(updateRadar)
			updateDragMode(); showNotification("Radar enabled", "success")
		else
			if RadarState.renderConn then RadarState.renderConn:Disconnect(); RadarState.renderConn = nil end
			for _, b in pairs(RadarState.blipPool) do if b then b.Visible = false end end
			RadarState.vehicleCache = {}; showNotification("Radar disabled", "info")
		end
	end)
	createToggle(lc, "Rotate with Camera", true, function(s) RadarState.rotateWithCamera = s end)
	createToggle(lc, "Show Self", true, function(s) RadarState.showSelf = s end)
	createToggle(lc, "Circular Border", true, function(s) RadarState.circularBorder = s; RSt.Transparency = s and 0.3 or 1 end)
	createToggle(lc, "Show Crosshair Lines", true, function(s) RadarState.showCrosshair = s; HLn.Visible = s; VLn.Visible = s end)
	createToggle(lc, "Show Cardinals (N/S/E/W)", true, function(s)
		RadarState.showCardinals = s; NLbl.Visible = s; SLbl.Visible = s; ELbl.Visible = s; WLbl.Visible = s
	end)
	createToggle(lc, "Show Distance Rings", false, function(s)
		RadarState.showDistanceRings = s; ring1.Visible = s; ring2.Visible = s
	end)
	createToggle(lc, "Show Zoom Info", true, function(s) ZoomLbl.Visible = s end)
	createToggle(lc, "Draw Players", true, function(s) RadarState.drawPlayers = s end)
	createToggle(lc, "Draw Friends", true, function(s) RadarState.drawFriends = s end)
	createToggle(lc, "Draw Dead Players", false, function(s) RadarState.drawDead = s end)
	createToggleWithWarning(lc, "Draw Vehicles", false, "Skanuje pojazdy co 3s.", function(s)
		RadarState.drawVehicles = s
		if s then scanVehicles(); RadarState.lastVehicleScan = tick() end
	end)

	local rc = createPanel(page, UDim2.new(0.5,5,0,0), UDim2.new(0.5,-5,1,-10), "Radar Settings", "⚙")
	createSlider(rc, "Transparency", 0, 1, RadarState.transparency, function(v)
		RadarState.transparency = v; RF.BackgroundTransparency = 1 - v
	end)
	createSlider(rc, "Zoom", 0.1, 5, 1, function(v) RadarState.zoom = v end)
	createSlider(rc, "Radar Size", 100, 400, 200, function(v)
		RadarState.size = v; RF.Size = UDim2.new(0, v, 0, v)
	end)
	createSlider(rc, "Blip Size", 3, 20, 8, function(v) RadarState.blipSize = math.floor(v) end)
	createSlider(rc, "Border Thickness", 0, 5, 2, function(v) RSt.Thickness = v end)
	createColorOption(rc, "Border Color", RadarState.borderColor, function(c) RadarState.borderColor = c; if not (MainFrame.Visible and not minimized) then RSt.Color = c end end)
	createColorOption(rc, "Background Color", RadarState.backgroundColor, function(c) RadarState.backgroundColor = c; RF.BackgroundColor3 = c end)
	createColorOption(rc, "Enemy Blip Color", RadarState.enemyColor, function(c) RadarState.enemyColor = c end)
	createColorOption(rc, "Friend Blip Color", RadarState.friendColor, function(c) RadarState.friendColor = c end)
	createColorOption(rc, "Dead Blip Color", RadarState.deadColor, function(c) RadarState.deadColor = c end)
	createColorOption(rc, "Vehicle Blip Color", RadarState.vehicleColor, function(c) RadarState.vehicleColor = c end)
	createColorOption(rc, "Self Blip Color", RadarState.selfColor, function(c) RadarState.selfColor = c end)
	createFunctionButton(rc, "📍 Position: Top Right", function() RF.Position = UDim2.new(1, -RadarState.size - 20, 0, 20) end)
	createFunctionButton(rc, "📍 Position: Top Left", function() RF.Position = UDim2.new(0, 20, 0, 20) end)
	createFunctionButton(rc, "📍 Position: Bottom Right", function() RF.Position = UDim2.new(1, -RadarState.size - 20, 1, -RadarState.size - 20) end)
	createFunctionButton(rc, "📍 Position: Bottom Left", function() RF.Position = UDim2.new(0, 20, 1, -RadarState.size - 20) end)
	createFunctionButton(rc, "📍 Position: Center", function() RF.Position = UDim2.new(0.5, -RadarState.size/2, 0.5, -RadarState.size/2) end)
	local resetBtn = createFunctionButton(rc, "🔄 Reset All Radar Settings", function()
		RadarState.transparency = 0.7; RadarState.zoom = 1.0; RadarState.size = 200; RadarState.blipSize = 8
		RadarState.borderColor = Color3.fromRGB(230, 60, 110); RadarState.enemyColor = Color3.fromRGB(230, 60, 110)
		RadarState.friendColor = Color3.fromRGB(0, 255, 0); RadarState.deadColor = Color3.fromRGB(120, 120, 120)
		RadarState.vehicleColor = Color3.fromRGB(255, 200, 50); RadarState.selfColor = Color3.fromRGB(100, 200, 255)
		RadarState.backgroundColor = Color3.fromRGB(15, 15, 20)
		RF.Size = UDim2.new(0, 200, 0, 200); RF.Position = UDim2.new(1, -220, 0, 20)
		RF.BackgroundTransparency = 0.3; RF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		RSt.Color = Color3.fromRGB(230, 60, 110); RSt.Thickness = 2
		showNotification("Radar reset to defaults", "info")
	end)
	resetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end

-- ========== RESOURCE STOPPER PAGE ==========
local function buildResourceStopperPage(page)
	local ResourceSystem = {selectedResources={}, stoppedResources={}, allResources={}, searchText=""}
	local LeftPanel = Instance.new("Frame")
	LeftPanel.Size = UDim2.new(0.5, -5, 1, -10); LeftPanel.Position = UDim2.new(0, 0, 0, 0)
	LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); LeftPanel.BorderSizePixel = 0; LeftPanel.Parent = page
	Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)
	local LTitleBar = Instance.new("Frame", LeftPanel)
	LTitleBar.Size = UDim2.new(1, 0, 0, 40); LTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); LTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", LTitleBar).CornerRadius = UDim.new(0, 10)
	local LTFix = Instance.new("Frame", LTitleBar)
	LTFix.Size = UDim2.new(1,0,0,20); LTFix.Position = UDim2.new(0,0,1,-20)
	LTFix.BackgroundColor3 = Color3.fromRGB(30,30,38); LTFix.BorderSizePixel = 0
	local LTitle = Instance.new("TextLabel", LTitleBar)
	LTitle.Size = UDim2.new(1, -20, 1, 0); LTitle.Position = UDim2.new(0, 15, 0, 0)
	LTitle.BackgroundTransparency = 1; LTitle.Text = "⚙  Resources"
	LTitle.TextColor3 = Color3.fromRGB(230, 230, 230); LTitle.TextSize = 14
	LTitle.Font = Enum.Font.GothamSemibold; LTitle.TextXAlignment = Enum.TextXAlignment.Left
	local ResourceCount = Instance.new("TextLabel", LTitleBar)
	ResourceCount.Size = UDim2.new(0, 60, 1, 0); ResourceCount.Position = UDim2.new(1, -65, 0, 0)
	ResourceCount.BackgroundTransparency = 1; ResourceCount.Text = "0"
	ResourceCount.TextColor3 = Color3.fromRGB(230, 60, 110); ResourceCount.TextSize = 12
	ResourceCount.Font = Enum.Font.GothamSemibold; ResourceCount.TextXAlignment = Enum.TextXAlignment.Right
	local SearchBg = Instance.new("Frame", LeftPanel)
	SearchBg.Size = UDim2.new(1, -20, 0, 32); SearchBg.Position = UDim2.new(0, 10, 0, 50)
	SearchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45); SearchBg.BorderSizePixel = 0
	Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0, 6)
	local SearchIcon = Instance.new("TextLabel", SearchBg)
	SearchIcon.Size = UDim2.new(0, 22, 1, 0); SearchIcon.Position = UDim2.new(0, 5, 0, 0)
	SearchIcon.BackgroundTransparency = 1; SearchIcon.Text = "🔍"
	SearchIcon.TextSize = 13; SearchIcon.Font = Enum.Font.Gotham; SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 160)
	local SearchBox = Instance.new("TextBox", SearchBg)
	SearchBox.Size = UDim2.new(1, -30, 1, 0); SearchBox.Position = UDim2.new(0, 28, 0, 0)
	SearchBox.BackgroundTransparency = 1; SearchBox.PlaceholderText = "Search Resource..."
	SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	SearchBox.TextSize = 13; SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus = false
	local ResourceListFrame = Instance.new("ScrollingFrame", LeftPanel)
	ResourceListFrame.Size = UDim2.new(1, -20, 1, -93); ResourceListFrame.Position = UDim2.new(0, 10, 0, 90)
	ResourceListFrame.BackgroundTransparency = 1; ResourceListFrame.BorderSizePixel = 0
	ResourceListFrame.ScrollBarThickness = 3
	ResourceListFrame.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	ResourceListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ResourceListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local RLLayout = Instance.new("UIListLayout", ResourceListFrame)
	RLLayout.Padding = UDim.new(0, 3); RLLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local RightPanel = Instance.new("Frame")
	RightPanel.Size = UDim2.new(0.5, -5, 1, -10); RightPanel.Position = UDim2.new(0.5, 5, 0, 0)
	RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); RightPanel.BorderSizePixel = 0; RightPanel.Parent = page
	Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)
	local RTitleBar2 = Instance.new("Frame", RightPanel)
	RTitleBar2.Size = UDim2.new(1, 0, 0, 40); RTitleBar2.BackgroundColor3 = Color3.fromRGB(30, 30, 38); RTitleBar2.BorderSizePixel = 0
	Instance.new("UICorner", RTitleBar2).CornerRadius = UDim.new(0, 10)
	local RTFix2 = Instance.new("Frame", RTitleBar2)
	RTFix2.Size = UDim2.new(1,0,0,20); RTFix2.Position = UDim2.new(0,0,1,-20)
	RTFix2.BackgroundColor3 = Color3.fromRGB(30,30,38); RTFix2.BorderSizePixel = 0
	local RTitle2 = Instance.new("TextLabel", RTitleBar2)
	RTitle2.Size = UDim2.new(1, -20, 1, 0); RTitle2.Position = UDim2.new(0, 15, 0, 0)
	RTitle2.BackgroundTransparency = 1; RTitle2.Text = "⚙  Resource Options"
	RTitle2.TextColor3 = Color3.fromRGB(230, 230, 230); RTitle2.TextSize = 14
	RTitle2.Font = Enum.Font.GothamSemibold; RTitle2.TextXAlignment = Enum.TextXAlignment.Left
	local OptionsScroll = Instance.new("ScrollingFrame", RightPanel)
	OptionsScroll.Size = UDim2.new(1, -20, 1, -55); OptionsScroll.Position = UDim2.new(0, 10, 0, 50)
	OptionsScroll.BackgroundTransparency = 1; OptionsScroll.BorderSizePixel = 0
	OptionsScroll.ScrollBarThickness = 3
	OptionsScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0); OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local OLayout = Instance.new("UIListLayout", OptionsScroll)
	OLayout.Padding = UDim.new(0, 6); OLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local OPad = Instance.new("UIPadding", OptionsScroll)
	OPad.PaddingTop = UDim.new(0, 5); OPad.PaddingBottom = UDim.new(0, 10)
	OPad.PaddingLeft = UDim.new(0, 2); OPad.PaddingRight = UDim.new(0, 2)

	local function makeOptBtn(text, order, isRed, isGreen, callback)
		local Btn = Instance.new("TextButton", OptionsScroll)
		Btn.Size = UDim2.new(1, 0, 0, 40); Btn.LayoutOrder = order
		local bgColor
		if isRed then bgColor = Color3.fromRGB(80, 30, 30)
		elseif isGreen then bgColor = Color3.fromRGB(30, 80, 30)
		else bgColor = Color3.fromRGB(35, 35, 45) end
		Btn.BackgroundColor3 = bgColor; Btn.Text = text
		Btn.TextColor3 = Color3.fromRGB(220, 220, 230); Btn.TextSize = 14
		Btn.Font = Enum.Font.GothamSemibold; Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local hCol
		if isRed then hCol = Color3.fromRGB(180, 50, 50)
		elseif isGreen then hCol = Color3.fromRGB(50, 180, 50)
		else hCol = Color3.fromRGB(230, 60, 110) end
		Btn.MouseEnter:Connect(function() playHover(); TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = hCol}):Play() end)
		Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = bgColor}):Play() end)
		Btn.MouseButton1Click:Connect(function() playClick(); if callback then pcall(callback) end end)
		return Btn
	end

	local function makeSepR(text, order)
		local Sep = Instance.new("Frame", OptionsScroll)
		Sep.Size = UDim2.new(1, 0, 0, 22); Sep.BackgroundTransparency = 1; Sep.LayoutOrder = order
		local SL = Instance.new("Frame", Sep)
		SL.Size = UDim2.new(1, 0, 0, 1); SL.Position = UDim2.new(0, 0, 0.5, 0)
		SL.BackgroundColor3 = Color3.fromRGB(60, 60, 70); SL.BorderSizePixel = 0
		local SLbl = Instance.new("TextLabel", Sep)
		SLbl.Size = UDim2.new(0, 160, 1, 0); SLbl.Position = UDim2.new(0.5, -80, 0, 0)
		SLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 32); SLbl.BorderSizePixel = 0
		SLbl.Text = text; SLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
		SLbl.TextSize = 11; SLbl.Font = Enum.Font.GothamSemibold
		return Sep
	end

	local SelectionInfoBg = Instance.new("Frame", OptionsScroll)
	SelectionInfoBg.Size = UDim2.new(1, 0, 0, 60); SelectionInfoBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	SelectionInfoBg.BorderSizePixel = 0; SelectionInfoBg.LayoutOrder = 0
	Instance.new("UICorner", SelectionInfoBg).CornerRadius = UDim.new(0, 8)
	local SelInfoStroke = Instance.new("UIStroke", SelectionInfoBg)
	SelInfoStroke.Color = Color3.fromRGB(60, 60, 75); SelInfoStroke.Thickness = 1
	local SelCountLbl = Instance.new("TextLabel", SelectionInfoBg)
	SelCountLbl.Size = UDim2.new(1, -20, 0, 22); SelCountLbl.Position = UDim2.new(0, 10, 0, 6)
	SelCountLbl.BackgroundTransparency = 1; SelCountLbl.Text = "Selected: 0 resources"
	SelCountLbl.TextColor3 = Color3.fromRGB(230, 60, 110); SelCountLbl.TextSize = 14
	SelCountLbl.Font = Enum.Font.GothamBold; SelCountLbl.TextXAlignment = Enum.TextXAlignment.Left
	local StoppedCountLbl = Instance.new("TextLabel", SelectionInfoBg)
	StoppedCountLbl.Size = UDim2.new(1, -20, 0, 18); StoppedCountLbl.Position = UDim2.new(0, 10, 0, 32)
	StoppedCountLbl.BackgroundTransparency = 1; StoppedCountLbl.Text = "Stopped: 0 resources"
	StoppedCountLbl.TextColor3 = Color3.fromRGB(150, 150, 160); StoppedCountLbl.TextSize = 12
	StoppedCountLbl.Font = Enum.Font.Gotham; StoppedCountLbl.TextXAlignment = Enum.TextXAlignment.Left

	local function updateSelectionInfo()
		local selCount = 0; for _ in pairs(ResourceSystem.selectedResources) do selCount = selCount + 1 end
		local stopCount = 0; for _ in pairs(ResourceSystem.stoppedResources) do stopCount = stopCount + 1 end
		SelCountLbl.Text = "Selected: " .. selCount .. " resource" .. (selCount ~= 1 and "s" or "")
		StoppedCountLbl.Text = "Stopped: " .. stopCount .. " resource" .. (stopCount ~= 1 and "s" or "")
		SelInfoStroke.Color = selCount > 0 and Color3.fromRGB(230, 60, 110) or Color3.fromRGB(60, 60, 75)
	end

	makeSepR("── Selection ──", 1)
	makeOptBtn("✓ Select All Resources", 2, false, false, function()
		for name, data in pairs(ResourceSystem.allResources) do
			if data.setSelected then ResourceSystem.selectedResources[name] = true; data.setSelected(true) end
		end
		updateSelectionInfo(); showNotification("All resources selected", "info")
	end)
	makeOptBtn("✕ Unselect All Resources", 3, false, false, function()
		for name, data in pairs(ResourceSystem.allResources) do
			if data.setSelected then ResourceSystem.selectedResources[name] = nil; data.setSelected(false) end
		end
		updateSelectionInfo(); showNotification("All resources deselected", "info")
	end)
	makeSepR("── Actions ──", 10)
	makeOptBtn("🛑 Stop Selected Resources", 11, true, false, function()
		local count = 0
		for name, _ in pairs(ResourceSystem.selectedResources) do
			pcall(function()
				local folder = game:FindFirstChild(name)
				if folder then
					for _, script in pairs(folder:GetDescendants()) do
						if script:IsA("LocalScript") or script:IsA("ModuleScript") then
							pcall(function() script.Disabled = true end)
						end
					end
				end
			end)
			ResourceSystem.stoppedResources[name] = true; count = count + 1
			if ResourceSystem.allResources[name] and ResourceSystem.allResources[name].updateStatus then
				ResourceSystem.allResources[name].updateStatus()
			end
		end
		updateSelectionInfo(); showNotification("Stopped " .. count .. " resource(s)", "success")
	end)
	makeOptBtn("▶ Resume Selected", 12, false, false, function()
		local count = 0
		for name, _ in pairs(ResourceSystem.selectedResources) do
			pcall(function()
				local folder = game:FindFirstChild(name)
				if folder then
					for _, script in pairs(folder:GetDescendants()) do
						if script:IsA("LocalScript") or script:IsA("ModuleScript") then
							pcall(function() script.Disabled = false end)
						end
					end
				end
			end)
			ResourceSystem.stoppedResources[name] = nil; count = count + 1
			if ResourceSystem.allResources[name] and ResourceSystem.allResources[name].updateStatus then
				ResourceSystem.allResources[name].updateStatus()
			end
		end
		updateSelectionInfo(); showNotification("Resumed " .. count .. " resource(s)", "success")
	end)
	makeSepR("── Bulk Actions ──", 20)
	makeOptBtn("🛑 Stop ALL Resources", 21, true, false, function()
		local count = 0
		for name, data in pairs(ResourceSystem.allResources) do
			pcall(function()
				local folder = game:FindFirstChild(name)
				if folder then
					for _, script in pairs(folder:GetDescendants()) do
						if script:IsA("LocalScript") then pcall(function() script.Disabled = true end) end
					end
				end
			end)
			ResourceSystem.stoppedResources[name] = true; count = count + 1
			if data.updateStatus then data.updateStatus() end
		end
		updateSelectionInfo(); showNotification("Stopped " .. count .. " resource(s)", "warning")
	end)
	makeOptBtn("▶ Resume ALL Resources", 22, false, true, function()
		local count = 0
		for name, data in pairs(ResourceSystem.allResources) do
			pcall(function()
				local folder = game:FindFirstChild(name)
				if folder then
					for _, script in pairs(folder:GetDescendants()) do
						if script:IsA("LocalScript") then pcall(function() script.Disabled = false end) end
					end
				end
			end)
			ResourceSystem.stoppedResources[name] = nil; count = count + 1
			if data.updateStatus then data.updateStatus() end
		end
		updateSelectionInfo(); showNotification("Resumed " .. count .. " resource(s)", "success")
	end)
	makeSepR("── Tools ──", 30)
	makeOptBtn("🔄 Refresh Resource List", 31, false, false, function()
		showNotification("Refreshing...", "info"); task.wait(0.1)
		if ResourceSystem.refresh then ResourceSystem.refresh() end
	end)
	makeOptBtn("📋 Print Selected to Console", 32, false, false, function()
		print("[SBX Resources] Selected:"); local count = 0
		for name, _ in pairs(ResourceSystem.selectedResources) do print("  - " .. name); count = count + 1 end
		print("[SBX] Total: " .. count); showNotification("Printed " .. count, "info")
	end)

	local function createResourceRow(resourceName)
		local Row = Instance.new("TextButton", ResourceListFrame)
		Row.Size = UDim2.new(1, 0, 0, 34); Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		Row.BackgroundTransparency = 0.3; Row.Text = ""; Row.BorderSizePixel = 0; Row.AutoButtonColor = false
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
		local RowStroke = Instance.new("UIStroke", Row)
		RowStroke.Color = Color3.fromRGB(230, 60, 110); RowStroke.Thickness = 2; RowStroke.Transparency = 1
		local StatusDot = Instance.new("TextLabel", Row)
		StatusDot.Size = UDim2.new(0, 14, 0, 14); StatusDot.Position = UDim2.new(0, 8, 0.5, -7)
		StatusDot.BackgroundTransparency = 1; StatusDot.Text = "●"
		StatusDot.TextColor3 = Color3.fromRGB(100, 220, 100); StatusDot.TextSize = 12; StatusDot.Font = Enum.Font.GothamBold
		local NameLbl = Instance.new("TextLabel", Row)
		NameLbl.Size = UDim2.new(1, -60, 1, 0); NameLbl.Position = UDim2.new(0, 28, 0, 0)
		NameLbl.BackgroundTransparency = 1; NameLbl.Text = resourceName
		NameLbl.TextColor3 = Color3.fromRGB(220, 220, 230); NameLbl.TextSize = 13
		NameLbl.Font = Enum.Font.Gotham; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		local StopBadge = Instance.new("TextLabel", Row)
		StopBadge.Size = UDim2.new(0, 50, 0, 18); StopBadge.Position = UDim2.new(1, -55, 0.5, -9)
		StopBadge.BackgroundColor3 = Color3.fromRGB(180, 50, 50); StopBadge.BackgroundTransparency = 1
		StopBadge.Text = "STOPPED"; StopBadge.TextColor3 = Color3.fromRGB(255, 180, 180)
		StopBadge.TextSize = 9; StopBadge.Font = Enum.Font.GothamBold; StopBadge.Visible = false
		Instance.new("UICorner", StopBadge).CornerRadius = UDim.new(0, 4)

		local isSelected = false
		local function updateVisual()
			if isSelected then
				Row.BackgroundColor3 = Color3.fromRGB(55, 55, 70); Row.BackgroundTransparency = 0
				RowStroke.Transparency = 0; NameLbl.Font = Enum.Font.GothamSemibold
				NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38); Row.BackgroundTransparency = 0.3
				RowStroke.Transparency = 1; NameLbl.Font = Enum.Font.Gotham
				NameLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
			end
		end
		local function updateStatus()
			local stopped = ResourceSystem.stoppedResources[resourceName]
			if stopped then
				StatusDot.Text = "■"; StatusDot.TextColor3 = Color3.fromRGB(230, 60, 60)
				StopBadge.Visible = true; StopBadge.BackgroundTransparency = 0
				NameLbl.TextColor3 = isSelected and Color3.fromRGB(255, 180, 180) or Color3.fromRGB(180, 140, 140)
			else
				StatusDot.Text = "●"; StatusDot.TextColor3 = Color3.fromRGB(100, 220, 100)
				StopBadge.Visible = false
				NameLbl.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 230)
			end
		end
		local function setSelected(state)
			isSelected = state
			if state then ResourceSystem.selectedResources[resourceName] = true
			else ResourceSystem.selectedResources[resourceName] = nil end
			updateVisual(); updateStatus(); updateSelectionInfo()
		end
		Row.MouseEnter:Connect(function()
			playHover()
			if not isSelected then
				TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
			end
		end)
		Row.MouseLeave:Connect(function()
			if not isSelected then
				TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
			end
		end)
		Row.MouseButton1Click:Connect(function() playClick(); setSelected(not isSelected) end)
		ResourceSystem.allResources[resourceName] = {row=Row, setSelected=setSelected, updateStatus=updateStatus}
		return Row
	end

	local function scanResources()
		for _, child in pairs(ResourceListFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		ResourceSystem.allResources = {}
		local searchText = SearchBox.Text:lower()
		local resources = {}
		local function addResource(name)
			if name and name ~= "" and not resources[name] then
				if searchText == "" or name:lower():find(searchText, 1, true) then
					resources[name] = true; table.insert(resources, name)
				end
			end
		end
		pcall(function()
			for _, child in pairs(game:GetChildren()) do
				local name = child.Name; local isBuiltIn = false
				local builtIns = {
					"Workspace","Players","Lighting","MaterialService","ReplicatedFirst",
					"ReplicatedStorage","ServerScriptService","ServerStorage","StarterGui",
					"StarterPack","StarterPlayer","Teams","SoundService","Chat",
					"LocalizationService","TestService","RunService","TextService",
					"MarketplaceService","InsertService","CoreGui","TweenService",
					"UserInputService","AnalyticsService","NetworkClient",
					"NetworkReplicationService","DataStoreService","MemoryStoreService",
				}
				for _, bi in ipairs(builtIns) do if name == bi then isBuiltIn = true; break end end
				if not isBuiltIn and not child:IsA("LocalScript") and not child:IsA("Script") then
					addResource(name)
				end
			end
		end)
		pcall(function()
			for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do addResource(child.Name) end
		end)
		pcall(function()
			for _, child in pairs(game:GetService("StarterGui"):GetChildren()) do addResource(child.Name) end
		end)
		local sortedResources = {}
		for name, _ in pairs(resources) do if type(name) == "string" then table.insert(sortedResources, name) end end
		table.sort(sortedResources, function(a, b) return a:lower() < b:lower() end)
		for _, name in ipairs(sortedResources) do createResourceRow(name) end
		ResourceCount.Text = tostring(#sortedResources); updateSelectionInfo()
	end

	ResourceSystem.refresh = scanResources
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function() task.wait(0.1); scanResources() end)
	task.wait(0.5); scanResources()
end

-- ========== RESOURCE DUMPER PAGE ==========
local function buildResourceDumperPage(page)
	local DumperSystem = {dumpedResources={}, selectedFile=nil, selectedNode=nil, lastDumpFolder=nil}

	local LeftPanel = Instance.new("Frame")
	LeftPanel.Size = UDim2.new(0.35, -5, 1, -10); LeftPanel.Position = UDim2.new(0, 0, 0, 0)
	LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); LeftPanel.BorderSizePixel = 0; LeftPanel.Parent = page
	Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)

	local LTitleBar = Instance.new("Frame", LeftPanel)
	LTitleBar.Size = UDim2.new(1, 0, 0, 40); LTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); LTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", LTitleBar).CornerRadius = UDim.new(0, 10)
	local LTFix = Instance.new("Frame", LTitleBar)
	LTFix.Size = UDim2.new(1, 0, 0, 20); LTFix.Position = UDim2.new(0, 0, 1, -20)
	LTFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38); LTFix.BorderSizePixel = 0
	local LTitle = Instance.new("TextLabel", LTitleBar)
	LTitle.Size = UDim2.new(1, -70, 1, 0); LTitle.Position = UDim2.new(0, 15, 0, 0)
	LTitle.BackgroundTransparency = 1; LTitle.Text = "📁  Resources"
	LTitle.TextColor3 = Color3.fromRGB(230, 230, 230); LTitle.TextSize = 14
	LTitle.Font = Enum.Font.GothamSemibold; LTitle.TextXAlignment = Enum.TextXAlignment.Left
	local FileCount = Instance.new("TextLabel", LTitleBar)
	FileCount.Size = UDim2.new(0, 60, 1, 0); FileCount.Position = UDim2.new(1, -65, 0, 0)
	FileCount.BackgroundTransparency = 1; FileCount.Text = "0 files"
	FileCount.TextColor3 = Color3.fromRGB(230, 60, 110); FileCount.TextSize = 11
	FileCount.Font = Enum.Font.GothamSemibold; FileCount.TextXAlignment = Enum.TextXAlignment.Right

	local SearchBg = Instance.new("Frame", LeftPanel)
	SearchBg.Size = UDim2.new(1, -20, 0, 30); SearchBg.Position = UDim2.new(0, 10, 0, 48)
	SearchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45); SearchBg.BorderSizePixel = 0
	Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0, 6)
	local SearchIcon = Instance.new("TextLabel", SearchBg)
	SearchIcon.Size = UDim2.new(0, 22, 1, 0); SearchIcon.Position = UDim2.new(0, 5, 0, 0)
	SearchIcon.BackgroundTransparency = 1; SearchIcon.Text = "🔍"
	SearchIcon.TextSize = 12; SearchIcon.Font = Enum.Font.Gotham; SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 160)
	local SearchBox = Instance.new("TextBox", SearchBg)
	SearchBox.Size = UDim2.new(1, -30, 1, 0); SearchBox.Position = UDim2.new(0, 28, 0, 0)
	SearchBox.BackgroundTransparency = 1; SearchBox.PlaceholderText = "Search..."
	SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	SearchBox.TextSize = 12; SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus = false

	local TreeScroll = Instance.new("ScrollingFrame", LeftPanel)
	TreeScroll.Size = UDim2.new(1, -20, 1, -130); TreeScroll.Position = UDim2.new(0, 10, 0, 85)
	TreeScroll.BackgroundTransparency = 1; TreeScroll.BorderSizePixel = 0
	TreeScroll.ScrollBarThickness = 3; TreeScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	TreeScroll.CanvasSize = UDim2.new(0, 0, 0, 0); TreeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local TreeLayout = Instance.new("UIListLayout", TreeScroll)
	TreeLayout.Padding = UDim.new(0, 2); TreeLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local BottomBar = Instance.new("Frame", LeftPanel)
	BottomBar.Size = UDim2.new(1, -20, 0, 36); BottomBar.Position = UDim2.new(0, 10, 1, -42)
	BottomBar.BackgroundTransparency = 1

	local DumpBtn = Instance.new("TextButton", BottomBar)
	DumpBtn.Size = UDim2.new(0.5, -3, 1, 0); DumpBtn.Position = UDim2.new(0, 0, 0, 0)
	DumpBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40); DumpBtn.Text = "⬇ Dump"
	DumpBtn.TextColor3 = Color3.fromRGB(200, 255, 200); DumpBtn.TextSize = 14
	DumpBtn.Font = Enum.Font.GothamBold; DumpBtn.BorderSizePixel = 0; DumpBtn.AutoButtonColor = false
	Instance.new("UICorner", DumpBtn).CornerRadius = UDim.new(0, 6)
	DumpBtn.MouseEnter:Connect(function() playHover(); TweenService:Create(DumpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 160, 60)}):Play() end)
	DumpBtn.MouseLeave:Connect(function() TweenService:Create(DumpBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 40)}):Play() end)

	local SaveBtn = Instance.new("TextButton", BottomBar)
	SaveBtn.Size = UDim2.new(0.5, -3, 1, 0); SaveBtn.Position = UDim2.new(0.5, 3, 0, 0)
	SaveBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); SaveBtn.Text = "💾 Save"
	SaveBtn.TextColor3 = Color3.fromRGB(230, 230, 230); SaveBtn.TextSize = 14
	SaveBtn.Font = Enum.Font.GothamBold; SaveBtn.BorderSizePixel = 0; SaveBtn.AutoButtonColor = false
	Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)
	SaveBtn.MouseEnter:Connect(function() playHover(); TweenService:Create(SaveBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 60, 110)}):Play() end)
	SaveBtn.MouseLeave:Connect(function() TweenService:Create(SaveBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play() end)

	-- RIGHT PANEL
	local RightPanel = Instance.new("Frame")
	RightPanel.Size = UDim2.new(0.65, -5, 1, -10); RightPanel.Position = UDim2.new(0.35, 5, 0, 0)
	RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32); RightPanel.BorderSizePixel = 0; RightPanel.Parent = page
	Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)

	local RTitleBar = Instance.new("Frame", RightPanel)
	RTitleBar.Size = UDim2.new(1, 0, 0, 32); RTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); RTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", RTitleBar).CornerRadius = UDim.new(0, 10)
	local RTFix = Instance.new("Frame", RTitleBar)
	RTFix.Size = UDim2.new(1, 0, 0, 16); RTFix.Position = UDim2.new(0, 0, 1, -16)
	RTFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38); RTFix.BorderSizePixel = 0
	local FilePathLbl = Instance.new("TextLabel", RTitleBar)
	FilePathLbl.Size = UDim2.new(1, -20, 1, 0); FilePathLbl.Position = UDim2.new(0, 12, 0, 0)
	FilePathLbl.BackgroundTransparency = 1; FilePathLbl.Text = "No file selected"
	FilePathLbl.TextColor3 = Color3.fromRGB(230, 230, 230); FilePathLbl.TextSize = 13
	FilePathLbl.Font = Enum.Font.GothamSemibold; FilePathLbl.TextXAlignment = Enum.TextXAlignment.Left

	local CodeBg = Instance.new("Frame", RightPanel)
	CodeBg.Size = UDim2.new(1, -10, 1, -42); CodeBg.Position = UDim2.new(0, 5, 0, 37)
	CodeBg.BackgroundColor3 = Color3.fromRGB(18, 18, 24); CodeBg.BorderSizePixel = 0
	Instance.new("UICorner", CodeBg).CornerRadius = UDim.new(0, 6)

	local EmptyLbl = Instance.new("TextLabel", CodeBg)
	EmptyLbl.Size = UDim2.new(1, 0, 1, 0); EmptyLbl.BackgroundTransparency = 1
	EmptyLbl.Text = "Select a file to view its content..."
	EmptyLbl.TextColor3 = Color3.fromRGB(100, 100, 120); EmptyLbl.TextSize = 14; EmptyLbl.Font = Enum.Font.Gotham

	local LineNumBg = Instance.new("Frame", CodeBg)
	LineNumBg.Size = UDim2.new(0, 46, 1, 0); LineNumBg.Position = UDim2.new(0, 0, 0, 0)
	LineNumBg.BackgroundColor3 = Color3.fromRGB(22, 22, 28); LineNumBg.BorderSizePixel = 0
	LineNumBg.ClipsDescendants = true; LineNumBg.Visible = false
	Instance.new("UICorner", LineNumBg).CornerRadius = UDim.new(0, 6)
	local LNFix = Instance.new("Frame", LineNumBg)
	LNFix.Size = UDim2.new(0.5, 0, 1, 0); LNFix.Position = UDim2.new(0.5, 0, 0, 0)
	LNFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28); LNFix.BorderSizePixel = 0

	local LineNumHolder = Instance.new("Frame", LineNumBg)
	LineNumHolder.Size = UDim2.new(1, -4, 0, 0); LineNumHolder.Position = UDim2.new(0, 2, 0, 6)
	LineNumHolder.BackgroundTransparency = 1; LineNumHolder.AutomaticSize = Enum.AutomaticSize.Y

	local LineNumText = Instance.new("TextLabel", LineNumHolder)
	LineNumText.Size = UDim2.new(1, 0, 0, 0); LineNumText.AutomaticSize = Enum.AutomaticSize.Y
	LineNumText.BackgroundTransparency = 1; LineNumText.Text = ""
	LineNumText.TextColor3 = Color3.fromRGB(100, 100, 120); LineNumText.TextSize = 12
	LineNumText.Font = Enum.Font.Code; LineNumText.TextXAlignment = Enum.TextXAlignment.Right
	LineNumText.TextYAlignment = Enum.TextYAlignment.Top

	local CodeScroll = Instance.new("ScrollingFrame", CodeBg)
	CodeScroll.Size = UDim2.new(1, -54, 1, -10); CodeScroll.Position = UDim2.new(0, 50, 0, 5)
	CodeScroll.BackgroundTransparency = 1; CodeScroll.BorderSizePixel = 0
	CodeScroll.ScrollBarThickness = 6; CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0); CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
	CodeScroll.ScrollingDirection = Enum.ScrollingDirection.XY; CodeScroll.Visible = false

	local CodeLabel = Instance.new("TextLabel", CodeScroll)
	CodeLabel.Size = UDim2.new(0, 2000, 0, 0); CodeLabel.AutomaticSize = Enum.AutomaticSize.XY
	CodeLabel.BackgroundTransparency = 1; CodeLabel.Text = ""
	CodeLabel.TextColor3 = Color3.fromRGB(230, 230, 235); CodeLabel.TextSize = 12
	CodeLabel.Font = Enum.Font.Code; CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
	CodeLabel.TextYAlignment = Enum.TextYAlignment.Top; CodeLabel.RichText = true

	CodeScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		LineNumHolder.Position = UDim2.new(0, 2, 0, 6 - CodeScroll.CanvasPosition.Y)
	end)

	local luaKeywords = {
		["local"]=true,["function"]=true,["end"]=true,["if"]=true,["then"]=true,
		["else"]=true,["elseif"]=true,["return"]=true,["for"]=true,["while"]=true,
		["do"]=true,["break"]=true,["repeat"]=true,["until"]=true,["in"]=true,
		["nil"]=true,["true"]=true,["false"]=true,["and"]=true,["or"]=true,
		["not"]=true,["require"]=true,
	}
	local function escapeXml(s) return s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
	local function highlightLuaLine(line)
		line = escapeXml(line)
		local COMMENT="rgb(100,140,100)"; local STRING="rgb(220,180,120)"
		local KEYWORD="rgb(230,60,110)"; local NUMBER="rgb(150,200,255)"
		local commentStart = line:find("%-%-")
		local commentPart = ""
		if commentStart then
			commentPart = '<font color="'..COMMENT..'">'..line:sub(commentStart)..'</font>'
			line = line:sub(1, commentStart - 1)
		end
		line = line:gsub('(".-")', '<font color="'..STRING..'">%1</font>')
		line = line:gsub("('.-')", '<font color="'..STRING..'">%1</font>')
		line = line:gsub("(%d+%.?%d*)", '<font color="'..NUMBER..'">%1</font>')
		line = line:gsub("([%a_][%w_]*)", function(word)
			if luaKeywords[word] then return '<font color="'..KEYWORD..'">'..word..'</font>' end
			return word
		end)
		return line .. commentPart
	end

	local function displayFile(filePath, content)
		FilePathLbl.Text = filePath; EmptyLbl.Visible = false
		LineNumBg.Visible = true; CodeScroll.Visible = true
		local lines = {}; local lineCount = 0
		for line in (content .. "\n"):gmatch("([^\n]*)\n") do
			table.insert(lines, highlightLuaLine(line)); lineCount = lineCount + 1
		end
		if lineCount > 3000 then
			lines = table.move(lines, 1, 3000, 1, {})
			table.insert(lines, '<font color="rgb(255,180,50)">-- [Truncated at 3000 lines]</font>')
			lineCount = 3001
		end
		CodeLabel.Text = table.concat(lines, "\n")
		local nums = {}
		for i = 1, lineCount do table.insert(nums, tostring(i)) end
		LineNumText.Text = table.concat(nums, "\n")
		CodeScroll.CanvasPosition = Vector2.new(0, 0)
	end

	local function getScriptContent(scriptObj)
		local content = nil
		pcall(function() if decompile then content = decompile(scriptObj) end end)
		if not content or content == "" then
			pcall(function() if scriptObj.Source and scriptObj.Source ~= "" then content = scriptObj.Source end end)
		end
		if not content or content == "" then
			pcall(function()
				if getscriptbytecode then
					local bc = getscriptbytecode(scriptObj)
					if bc and #bc > 0 then
						content = "-- Bytecode dumped\n-- Size: " .. #bc .. " bytes\n\n" .. bc
					end
				end
			end)
		end
		if not content or content == "" then
			content = "-- Cannot read this script\n-- Name: " .. scriptObj.Name .. "\n-- Path: " .. scriptObj:GetFullName()
		end
		return content
	end

	local function createTreeRow(text, depth, icon, isFolder, iconColor)
		local Row = Instance.new("TextButton", TreeScroll)
		Row.Size = UDim2.new(1, 0, 0, 26); Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		Row.BackgroundTransparency = 1; Row.Text = ""; Row.BorderSizePixel = 0; Row.AutoButtonColor = false
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)
		local RowStroke = Instance.new("UIStroke", Row)
		RowStroke.Color = Color3.fromRGB(230, 60, 110); RowStroke.Thickness = 2; RowStroke.Transparency = 1
		local xPos = 6 + (depth * 14)
		local IconLbl = Instance.new("TextLabel", Row)
		IconLbl.Size = UDim2.new(0, 18, 1, 0); IconLbl.Position = UDim2.new(0, xPos, 0, 0)
		IconLbl.BackgroundTransparency = 1; IconLbl.Text = icon
		IconLbl.TextColor3 = iconColor or Color3.fromRGB(200, 200, 210); IconLbl.TextSize = 13; IconLbl.Font = Enum.Font.GothamBold
		local NameLbl = Instance.new("TextLabel", Row)
		NameLbl.Size = UDim2.new(1, -xPos - 24, 1, 0); NameLbl.Position = UDim2.new(0, xPos + 22, 0, 0)
		NameLbl.BackgroundTransparency = 1; NameLbl.Text = text
		NameLbl.TextColor3 = isFolder and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(180, 180, 195)
		NameLbl.TextSize = 12; NameLbl.Font = isFolder and Enum.Font.GothamSemibold or Enum.Font.Gotham
		NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		Row.MouseEnter:Connect(function()
			playHover()
			if DumperSystem.selectedNode ~= Row then
				TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
			end
		end)
		Row.MouseLeave:Connect(function()
			if DumperSystem.selectedNode ~= Row then
				TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
			end
		end)
		return Row, RowStroke
	end

	local function setNodeSelected(row, stroke)
		if DumperSystem.selectedNode and DumperSystem.selectedNode ~= row then
			local oldStroke = DumperSystem.selectedNode:FindFirstChildOfClass("UIStroke")
			if oldStroke then oldStroke.Transparency = 1 end
			DumperSystem.selectedNode.BackgroundTransparency = 1
		end
		DumperSystem.selectedNode = row
		row.BackgroundColor3 = Color3.fromRGB(55, 55, 70); row.BackgroundTransparency = 0
		stroke.Transparency = 0
	end

	local function clearTree()
		for _, child in pairs(TreeScroll:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
	end

	local function buildTree()
		clearTree()
		local searchText = SearchBox.Text:lower()
		local resNames = {}
		for name, _ in pairs(DumperSystem.dumpedResources) do table.insert(resNames, name) end
		table.sort(resNames, function(a, b) return a:lower() < b:lower() end)
		local layoutOrder = 0; local totalVisible = 0
		for _, resName in ipairs(resNames) do
			local resData = DumperSystem.dumpedResources[resName]
			local matchingFiles = {}
			if searchText == "" then matchingFiles = resData.files
			else
				for _, fileData in ipairs(resData.files) do
					if fileData.name:lower():find(searchText, 1, true) or resName:lower():find(searchText, 1, true) then
						table.insert(matchingFiles, fileData)
					end
				end
			end
			if #matchingFiles > 0 then
				layoutOrder = layoutOrder + 1
				local folderIcon = resData.expanded and "▼" or "▶"
				local folderRow, folderStroke = createTreeRow(resName .. " (" .. #matchingFiles .. ")", 0, folderIcon, true, Color3.fromRGB(255, 200, 100))
				folderRow.LayoutOrder = layoutOrder
				folderRow.MouseButton1Click:Connect(function()
					playClick(); resData.expanded = not resData.expanded; buildTree()
				end)
				if resData.expanded then
					for _, fileData in ipairs(matchingFiles) do
						layoutOrder = layoutOrder + 1
						local fileIcon = "◆"; local fileIconColor = Color3.fromRGB(150, 200, 255)
						if fileData.type == "ModuleScript" then fileIcon = "◇"; fileIconColor = Color3.fromRGB(200, 150, 255)
						elseif fileData.type == "Script" then fileIcon = "◈"; fileIconColor = Color3.fromRGB(255, 180, 100) end
						local fileRow, fileStroke = createTreeRow(fileData.name, 1, fileIcon, false, fileIconColor)
						fileRow.LayoutOrder = layoutOrder
						fileRow.MouseButton1Click:Connect(function()
							playClick(); setNodeSelected(fileRow, fileStroke)
							DumperSystem.selectedFile = fileData
							if fileData.instance then
								local content = getScriptContent(fileData.instance)
								displayFile(resName .. "/" .. fileData.name, content)
							end
						end)
					end
				end
				totalVisible = totalVisible + #matchingFiles
			end
		end
		FileCount.Text = totalVisible .. " files"
	end

	local function collectScripts(root, files, prefix)
		prefix = prefix or ""
		for _, child in pairs(root:GetChildren()) do
			pcall(function()
				if child:IsA("LocalScript") or child:IsA("ModuleScript") or child:IsA("Script") then
					local ext = ".lua"
					if child:IsA("LocalScript") then ext = ".client.lua"
					elseif child:IsA("Script") then ext = ".server.lua" end
					table.insert(files, {
						name = prefix .. child.Name .. ext,
						type = child.ClassName, instance = child, path = child:GetFullName(),
					})
				end
				if #child:GetChildren() > 0 then
					collectScripts(child, files, prefix .. child.Name .. "/")
				end
			end)
		end
	end

	local function dumpResources()
		DumperSystem.dumpedResources = {}; DumperSystem.selectedFile = nil; DumperSystem.selectedNode = nil
		showNotification("Dumping resources...", "info")
		local sources = {
			{name="Workspace", container=workspace},
			{name="ReplicatedStorage", container=game:GetService("ReplicatedStorage")},
			{name="ReplicatedFirst", container=game:GetService("ReplicatedFirst")},
			{name="StarterGui", container=game:GetService("StarterGui")},
			{name="StarterPack", container=game:GetService("StarterPack")},
			{name="StarterPlayer", container=game:GetService("StarterPlayer")},
			{name="Lighting", container=Lighting},
			{name="SoundService", container=game:GetService("SoundService")},
			{name="Chat", container=game:GetService("Chat")},
			{name="PlayerScripts", container=player:FindFirstChild("PlayerScripts")},
			{name="PlayerGui", container=player:FindFirstChild("PlayerGui")},
		}
		local totalFiles = 0
		for _, src in ipairs(sources) do
			if src.container then
				local files = {}
				pcall(function() collectScripts(src.container, files, "") end)
				if #files > 0 then
					table.sort(files, function(a, b) return a.name:lower() < b.name:lower() end)
					DumperSystem.dumpedResources[src.name] = {expanded=false, files=files}
					totalFiles = totalFiles + #files
				end
			end
		end
		pcall(function()
			local builtIns = {
				["Workspace"]=1,["Players"]=1,["Lighting"]=1,["MaterialService"]=1,["ReplicatedFirst"]=1,
				["ReplicatedStorage"]=1,["ServerScriptService"]=1,["ServerStorage"]=1,["StarterGui"]=1,
				["StarterPack"]=1,["StarterPlayer"]=1,["Teams"]=1,["SoundService"]=1,["Chat"]=1,
				["LocalizationService"]=1,["TestService"]=1,["RunService"]=1,["TextService"]=1,
				["MarketplaceService"]=1,["InsertService"]=1,["CoreGui"]=1,["TweenService"]=1,
				["UserInputService"]=1,["AnalyticsService"]=1,["NetworkClient"]=1,
				["NetworkReplicationService"]=1,["DataStoreService"]=1,["MemoryStoreService"]=1,
				["HttpService"]=1,["PhysicsService"]=1,["ContextActionService"]=1,["GamepadService"]=1,
				["GuiService"]=1,["PathfindingService"]=1,["PolicyService"]=1,["ScriptService"]=1,
				["Debris"]=1,["ContentProvider"]=1,["CollectionService"]=1,["GroupService"]=1,
				["BadgeService"]=1,["TeleportService"]=1,["LogService"]=1,["StatsService"]=1,
			}
			for _, child in pairs(game:GetChildren()) do
				if not builtIns[child.Name] and not DumperSystem.dumpedResources[child.Name] then
					local files = {}
					pcall(function() collectScripts(child, files, "") end)
					if #files > 0 then
						table.sort(files, function(a, b) return a.name:lower() < b.name:lower() end)
						DumperSystem.dumpedResources[child.Name] = {expanded=false, files=files}
						totalFiles = totalFiles + #files
					end
				end
			end
		end)
		local resCount = 0
		for _ in pairs(DumperSystem.dumpedResources) do resCount = resCount + 1 end
		showNotification("✓ Dumped " .. totalFiles .. " scripts from " .. resCount .. " sources", "success")
		buildTree()
		EmptyLbl.Visible = true; LineNumBg.Visible = false; CodeScroll.Visible = false
		FilePathLbl.Text = "No file selected"
	end

	DumpBtn.MouseButton1Click:Connect(function() playClick(); dumpResources() end)

	local function sanitizeFilename(name)
		return name:gsub("[<>:\"|%?%*\\/]", "_"):gsub("^%s+",""):gsub("%s+$","")
	end

	local function saveDump()
		if not writefile then showNotification("Executor doesn't support writefile", "error"); return end
		if not makefolder then showNotification("Executor doesn't support makefolder", "error"); return end
		local totalDumped = 0
		for _, resData in pairs(DumperSystem.dumpedResources) do totalDumped = totalDumped + #resData.files end
		if totalDumped == 0 then showNotification("Nothing to save! Click Dump first", "warning"); return end
		showNotification("💾 Saving " .. totalDumped .. " files...", "info")
		local baseFolder = "SBX_Dump_" .. os.date("%Y-%m-%d_%H-%M-%S")
		pcall(function() makefolder(baseFolder) end)
		task.spawn(function()
			local savedCount = 0; local errors = 0; local processed = 0
			for resName, resData in pairs(DumperSystem.dumpedResources) do
				local safeName = sanitizeFilename(resName)
				local resFolder = baseFolder .. "/" .. safeName
				pcall(function() makefolder(resFolder) end)
				for _, fileData in ipairs(resData.files) do
					local success, err = pcall(function()
						local content = getScriptContent(fileData.instance)
						local flatName = fileData.name:gsub("/", "_")
						local filePath = resFolder .. "/" .. sanitizeFilename(flatName)
						writefile(filePath, content)
						savedCount = savedCount + 1
					end)
					if not success then errors = errors + 1; warn("[SBX Save] " .. tostring(err)) end
					processed = processed + 1
					if processed % 15 == 0 then task.wait() end
				end
			end
			pcall(function()
				local info = "SBX Dump\nDate: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\nGame: " .. tostring(game.PlaceId) .. "\nFiles: " .. savedCount .. "\n"
				writefile(baseFolder .. "/_info.txt", info)
			end)
			if errors > 0 then
				showNotification("⚠ Saved " .. savedCount .. "/" .. totalDumped, "warning")
			else
				showNotification("✓ Saved " .. savedCount .. " files!", "success")
			end
			print("[SBX Dumper] Saved to: " .. baseFolder)
		end)
	end

	SaveBtn.MouseButton1Click:Connect(function() playClick(); saveDump() end)

	local lastSearch = 0
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		lastSearch = tick(); local myTime = lastSearch
		task.wait(0.15)
		if myTime == lastSearch then buildTree() end
	end)
end

-- ========== BUILD TRIGGER FINDER PAGE ==========
local function buildTriggerFinderPage(page)
	local TriggerSystem = {
		foundTriggers = {},
		selectedTrigger = nil,
		selectedNode = nil,
		isScanning = false,
	}

	-- ========== LEWY PANEL - lista triggerów ==========
	local LeftPanel = Instance.new("Frame")
	LeftPanel.Size = UDim2.new(0.45, -5, 1, -10)
	LeftPanel.Position = UDim2.new(0, 0, 0, 0)
	LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	LeftPanel.BorderSizePixel = 0
	LeftPanel.Parent = page
	Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)

	local LTitleBar = Instance.new("Frame", LeftPanel)
	LTitleBar.Size = UDim2.new(1, 0, 0, 40)
	LTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	LTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", LTitleBar).CornerRadius = UDim.new(0, 10)
	local LTFix = Instance.new("Frame", LTitleBar)
	LTFix.Size = UDim2.new(1,0,0,20); LTFix.Position = UDim2.new(0,0,1,-20)
	LTFix.BackgroundColor3 = Color3.fromRGB(30,30,38); LTFix.BorderSizePixel = 0
	local LTitle = Instance.new("TextLabel", LTitleBar)
	LTitle.Size = UDim2.new(1, -80, 1, 0); LTitle.Position = UDim2.new(0, 15, 0, 0)
	LTitle.BackgroundTransparency = 1; LTitle.Text = "⚡  Trigger Finder"
	LTitle.TextColor3 = Color3.fromRGB(230, 230, 230); LTitle.TextSize = 14
	LTitle.Font = Enum.Font.GothamSemibold; LTitle.TextXAlignment = Enum.TextXAlignment.Left

	local TriggerCountLbl = Instance.new("TextLabel", LTitleBar)
	TriggerCountLbl.Size = UDim2.new(0, 70, 1, 0); TriggerCountLbl.Position = UDim2.new(1, -75, 0, 0)
	TriggerCountLbl.BackgroundTransparency = 1; TriggerCountLbl.Text = "0 found"
	TriggerCountLbl.TextColor3 = Color3.fromRGB(230, 60, 110); TriggerCountLbl.TextSize = 11
	TriggerCountLbl.Font = Enum.Font.GothamSemibold; TriggerCountLbl.TextXAlignment = Enum.TextXAlignment.Right

	-- Search + Filter
	local SearchBg = Instance.new("Frame", LeftPanel)
	SearchBg.Size = UDim2.new(1, -20, 0, 30)
	SearchBg.Position = UDim2.new(0, 10, 0, 50)
	SearchBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	SearchBg.BorderSizePixel = 0
	Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0, 6)
	local SearchIcon = Instance.new("TextLabel", SearchBg)
	SearchIcon.Size = UDim2.new(0, 22, 1, 0); SearchIcon.Position = UDim2.new(0, 5, 0, 0)
	SearchIcon.BackgroundTransparency = 1; SearchIcon.Text = "🔍"
	SearchIcon.TextSize = 12; SearchIcon.Font = Enum.Font.Gotham
	SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 160)
	local SearchBox = Instance.new("TextBox", SearchBg)
	SearchBox.Size = UDim2.new(1, -30, 1, 0); SearchBox.Position = UDim2.new(0, 28, 0, 0)
	SearchBox.BackgroundTransparency = 1; SearchBox.PlaceholderText = "Search trigger..."
	SearchBox.Text = ""; SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	SearchBox.TextSize = 12; SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left; SearchBox.ClearTextOnFocus = false

	-- Filter buttons (typ triggera)
	local FilterBar = Instance.new("Frame", LeftPanel)
	FilterBar.Size = UDim2.new(1, -20, 0, 26)
	FilterBar.Position = UDim2.new(0, 10, 0, 85)
	FilterBar.BackgroundTransparency = 1

	local filterAll = true
	local filterRemote = true
	local filterNetwork = true
	local filterCustom = true
	local filterLayout = Instance.new("UIListLayout", FilterBar)
	filterLayout.FillDirection = Enum.FillDirection.Horizontal
	filterLayout.Padding = UDim.new(0, 4)
	filterLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local function makeFilterBtn(text, color, order)
		local Btn = Instance.new("TextButton", FilterBar)
		Btn.Size = UDim2.new(0, 0, 1, 0); Btn.AutomaticSize = Enum.AutomaticSize.X
		Btn.BackgroundColor3 = color; Btn.Text = " " .. text .. " "
		Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 10
		Btn.Font = Enum.Font.GothamBold; Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false
		Btn.LayoutOrder = order
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
		local UIPad = Instance.new("UIPadding", Btn)
		UIPad.PaddingLeft = UDim.new(0, 5); UIPad.PaddingRight = UDim.new(0, 5)
		return Btn
	end

	makeFilterBtn("ALL", Color3.fromRGB(80, 80, 100), 1)
	makeFilterBtn("Remote", Color3.fromRGB(60, 100, 160), 2)
	makeFilterBtn("Network", Color3.fromRGB(100, 60, 160), 3)
	makeFilterBtn("Custom", Color3.fromRGB(160, 100, 60), 4)

	-- Lista triggerów
	local TriggerListFrame = Instance.new("ScrollingFrame", LeftPanel)
	TriggerListFrame.Size = UDim2.new(1, -20, 1, -185)
	TriggerListFrame.Position = UDim2.new(0, 10, 0, 118)
	TriggerListFrame.BackgroundTransparency = 1
	TriggerListFrame.BorderSizePixel = 0
	TriggerListFrame.ScrollBarThickness = 3
	TriggerListFrame.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	TriggerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	TriggerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local TLLayout = Instance.new("UIListLayout", TriggerListFrame)
	TLLayout.Padding = UDim.new(0, 3); TLLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Bottom - Scan button
	local BottomLeft = Instance.new("Frame", LeftPanel)
	BottomLeft.Size = UDim2.new(1, -20, 0, 60)
	BottomLeft.Position = UDim2.new(0, 10, 1, -65)
	BottomLeft.BackgroundTransparency = 1

	local ScanBtn = Instance.new("TextButton", BottomLeft)
	ScanBtn.Size = UDim2.new(1, 0, 0, 36)
	ScanBtn.Position = UDim2.new(0, 0, 0, 0)
	ScanBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
	ScanBtn.Text = "🔍 Scan Triggers"
	ScanBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
	ScanBtn.TextSize = 14; ScanBtn.Font = Enum.Font.GothamBold
	ScanBtn.BorderSizePixel = 0; ScanBtn.AutoButtonColor = false
	Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
	ScanBtn.MouseEnter:Connect(function() playHover(); TweenService:Create(ScanBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play() end)
	ScanBtn.MouseLeave:Connect(function() TweenService:Create(ScanBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 140)}):Play() end)

	local StatusLbl = Instance.new("TextLabel", BottomLeft)
	StatusLbl.Size = UDim2.new(1, 0, 0, 18)
	StatusLbl.Position = UDim2.new(0, 0, 0, 40)
	StatusLbl.BackgroundTransparency = 1
	StatusLbl.Text = "Click 'Scan Triggers' to start"
	StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
	StatusLbl.TextSize = 11; StatusLbl.Font = Enum.Font.Gotham

	-- ========== PRAWY PANEL - Szczegóły + Execute ==========
	local RightPanel = Instance.new("Frame")
	RightPanel.Size = UDim2.new(0.55, -5, 1, -10)
	RightPanel.Position = UDim2.new(0.45, 5, 0, 0)
	RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	RightPanel.BorderSizePixel = 0; RightPanel.Parent = page
	Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)

	local RTitleBar = Instance.new("Frame", RightPanel)
	RTitleBar.Size = UDim2.new(1, 0, 0, 40)
	RTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38); RTitleBar.BorderSizePixel = 0
	Instance.new("UICorner", RTitleBar).CornerRadius = UDim.new(0, 10)
	local RTFix = Instance.new("Frame", RTitleBar)
	RTFix.Size = UDim2.new(1,0,0,20); RTFix.Position = UDim2.new(0,0,1,-20)
	RTFix.BackgroundColor3 = Color3.fromRGB(30,30,38); RTFix.BorderSizePixel = 0
	local RTitle = Instance.new("TextLabel", RTitleBar)
	RTitle.Size = UDim2.new(1, -20, 1, 0); RTitle.Position = UDim2.new(0, 15, 0, 0)
	RTitle.BackgroundTransparency = 1; RTitle.Text = "⚡  Trigger Options"
	RTitle.TextColor3 = Color3.fromRGB(230, 230, 230); RTitle.TextSize = 14
	RTitle.Font = Enum.Font.GothamSemibold; RTitle.TextXAlignment = Enum.TextXAlignment.Left

	-- Info card (pokazuje zaznaczony trigger)
	local InfoCard = Instance.new("Frame", RightPanel)
	InfoCard.Size = UDim2.new(1, -20, 0, 80)
	InfoCard.Position = UDim2.new(0, 10, 0, 50)
	InfoCard.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	InfoCard.BorderSizePixel = 0
	Instance.new("UICorner", InfoCard).CornerRadius = UDim.new(0, 8)
	local InfoStroke = Instance.new("UIStroke", InfoCard)
	InfoStroke.Color = Color3.fromRGB(60, 60, 75); InfoStroke.Thickness = 1

	local InfoEmpty = Instance.new("TextLabel", InfoCard)
	InfoEmpty.Size = UDim2.new(1, 0, 1, 0); InfoEmpty.BackgroundTransparency = 1
	InfoEmpty.Text = "Select a trigger from the list ←"
	InfoEmpty.TextColor3 = Color3.fromRGB(120, 120, 130); InfoEmpty.TextSize = 13
	InfoEmpty.Font = Enum.Font.Gotham

	local InfoName = Instance.new("TextLabel", InfoCard)
	InfoName.Size = UDim2.new(1, -20, 0, 22); InfoName.Position = UDim2.new(0, 10, 0, 6)
	InfoName.BackgroundTransparency = 1; InfoName.Text = ""
	InfoName.TextColor3 = Color3.fromRGB(255, 255, 255); InfoName.TextSize = 14
	InfoName.Font = Enum.Font.GothamBold; InfoName.TextXAlignment = Enum.TextXAlignment.Left
	InfoName.TextTruncate = Enum.TextTruncate.AtEnd; InfoName.Visible = false

	local InfoType = Instance.new("TextLabel", InfoCard)
	InfoType.Size = UDim2.new(0.5, 0, 0, 16); InfoType.Position = UDim2.new(0, 10, 0, 30)
	InfoType.BackgroundTransparency = 1; InfoType.Text = ""
	InfoType.TextColor3 = Color3.fromRGB(180, 180, 190); InfoType.TextSize = 11
	InfoType.Font = Enum.Font.Gotham; InfoType.TextXAlignment = Enum.TextXAlignment.Left
	InfoType.Visible = false

	local InfoPath = Instance.new("TextLabel", InfoCard)
	InfoPath.Size = UDim2.new(1, -20, 0, 16); InfoPath.Position = UDim2.new(0, 10, 0, 48)
	InfoPath.BackgroundTransparency = 1; InfoPath.Text = ""
	InfoPath.TextColor3 = Color3.fromRGB(140, 140, 160); InfoPath.TextSize = 10
	InfoPath.Font = Enum.Font.Code; InfoPath.TextXAlignment = Enum.TextXAlignment.Left
	InfoPath.TextTruncate = Enum.TextTruncate.AtEnd; InfoPath.Visible = false

	local TypeBadge = Instance.new("TextLabel", InfoCard)
	TypeBadge.Size = UDim2.new(0, 80, 0, 18); TypeBadge.Position = UDim2.new(0.5, 5, 0, 28)
	TypeBadge.BackgroundColor3 = Color3.fromRGB(60, 100, 160); TypeBadge.BorderSizePixel = 0
	TypeBadge.Text = "Remote"; TypeBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
	TypeBadge.TextSize = 10; TypeBadge.Font = Enum.Font.GothamBold; TypeBadge.Visible = false
	Instance.new("UICorner", TypeBadge).CornerRadius = UDim.new(0, 4)

	-- Code editor (do wpisania argumentów)
	local EditorLabel = Instance.new("TextLabel", RightPanel)
	EditorLabel.Size = UDim2.new(1, -20, 0, 16)
	EditorLabel.Position = UDim2.new(0, 10, 0, 140)
	EditorLabel.BackgroundTransparency = 1
	EditorLabel.Text = "📝 Trigger Code (editable):"
	EditorLabel.TextColor3 = Color3.fromRGB(200, 200, 210); EditorLabel.TextSize = 12
	EditorLabel.Font = Enum.Font.GothamSemibold; EditorLabel.TextXAlignment = Enum.TextXAlignment.Left

	local CodeEditorBg = Instance.new("Frame", RightPanel)
	CodeEditorBg.Size = UDim2.new(1, -20, 0, 140)
	CodeEditorBg.Position = UDim2.new(0, 10, 0, 160)
	CodeEditorBg.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	CodeEditorBg.BorderSizePixel = 0
	Instance.new("UICorner", CodeEditorBg).CornerRadius = UDim.new(0, 6)
	local EdStroke = Instance.new("UIStroke", CodeEditorBg)
	EdStroke.Color = Color3.fromRGB(50, 50, 65); EdStroke.Thickness = 1

	local CodeEditor = Instance.new("TextBox", CodeEditorBg)
	CodeEditor.Size = UDim2.new(1, -20, 1, -16)
	CodeEditor.Position = UDim2.new(0, 10, 0, 8)
	CodeEditor.BackgroundTransparency = 1
	CodeEditor.Text = "-- Select a trigger from the list\n-- The code will appear here\n-- You can edit arguments!"
	CodeEditor.PlaceholderText = "-- Select a trigger..."
	CodeEditor.TextColor3 = Color3.fromRGB(230, 230, 235); CodeEditor.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	CodeEditor.TextSize = 12; CodeEditor.Font = Enum.Font.Code
	CodeEditor.TextXAlignment = Enum.TextXAlignment.Left; CodeEditor.TextYAlignment = Enum.TextYAlignment.Top
	CodeEditor.MultiLine = true; CodeEditor.ClearTextOnFocus = false; CodeEditor.TextWrapped = false

	CodeEditor.Focused:Connect(function()
		EdStroke.Color = Color3.fromRGB(230, 60, 110)
		TweenService:Create(EdStroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
	end)
	CodeEditor.FocusLost:Connect(function()
		TweenService:Create(EdStroke, TweenInfo.new(0.2), {Thickness = 1}):Play()
		task.wait(0.2); EdStroke.Color = Color3.fromRGB(50, 50, 65)
	end)

	-- Przyciski execute
	local BtnRow = Instance.new("Frame", RightPanel)
	BtnRow.Size = UDim2.new(1, -20, 0, 36)
	BtnRow.Position = UDim2.new(0, 10, 0, 308)
	BtnRow.BackgroundTransparency = 1
	local BtnLayout = Instance.new("UIListLayout", BtnRow)
	BtnLayout.FillDirection = Enum.FillDirection.Horizontal
	BtnLayout.Padding = UDim.new(0, 6); BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local function makeBigBtn(text, color, order, callback)
		local Btn = Instance.new("TextButton", BtnRow)
		Btn.Size = UDim2.new(0.5, -3, 1, 0); Btn.LayoutOrder = order
		Btn.BackgroundColor3 = color; Btn.Text = text
		Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 13
		Btn.Font = Enum.Font.GothamBold; Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local hCol = Color3.new(
			math.min(color.R + 0.1, 1),
			math.min(color.G + 0.1, 1),
			math.min(color.B + 0.1, 1)
		)
		Btn.MouseEnter:Connect(function() playHover(); TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = hCol}):Play() end)
		Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play() end)
		Btn.MouseButton1Click:Connect(function() playClick(); if callback then pcall(callback) end end)
		return Btn
	end

	-- Execute button
	local ExecBtn = makeBigBtn("▶ Fire Trigger", Color3.fromRGB(40, 120, 40), 1, function()
		local code = CodeEditor.Text
		if code == "" or code:match("^%s*$") or code:find("-- Select") then
			showNotification("No trigger code to execute", "warning"); return
		end
		local success, err = pcall(function()
			if loadstring then
				local fn, loadErr = loadstring(code)
				if not fn then error(loadErr) end
				fn()
			elseif getgenv and getgenv().loadstring then
				local fn, loadErr = getgenv().loadstring(code)
				if not fn then error(loadErr) end
				fn()
			else
				error("No loadstring available")
			end
		end)
		if success then
			showNotification("✓ Trigger fired!", "success")
			print("[SBX Trigger] Fired: " .. code:sub(1, 80))
		else
			showNotification("Error: " .. tostring(err):sub(1, 60), "error")
			warn("[SBX Trigger] Error: " .. tostring(err))
		end
	end)

	local ClearCodeBtn = makeBigBtn("🗑 Clear Code", Color3.fromRGB(70, 40, 40), 2, function()
		CodeEditor.Text = ""; showNotification("Code cleared", "info")
	end)

	-- Quick presets (często używane triggery)
	local PresetsLabel = Instance.new("TextLabel", RightPanel)
	PresetsLabel.Size = UDim2.new(1, -20, 0, 16)
	PresetsLabel.Position = UDim2.new(0, 10, 0, 356)
	PresetsLabel.BackgroundTransparency = 1
	PresetsLabel.Text = "⚡ Quick Presets (FiveM/Common):"
	PresetsLabel.TextColor3 = Color3.fromRGB(200, 200, 210); PresetsLabel.TextSize = 12
	PresetsLabel.Font = Enum.Font.GothamSemibold; PresetsLabel.TextXAlignment = Enum.TextXAlignment.Left

	local PresetsScroll = Instance.new("ScrollingFrame", RightPanel)
	PresetsScroll.Size = UDim2.new(1, -20, 1, -385)
	PresetsScroll.Position = UDim2.new(0, 10, 0, 376)
	PresetsScroll.BackgroundTransparency = 1; PresetsScroll.BorderSizePixel = 0
	PresetsScroll.ScrollBarThickness = 3
	PresetsScroll.ScrollBarImageColor3 = Color3.fromRGB(230, 60, 110)
	PresetsScroll.CanvasSize = UDim2.new(0, 0, 0, 0); PresetsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local PresetsLayout = Instance.new("UIListLayout", PresetsScroll)
	PresetsLayout.Padding = UDim.new(0, 4); PresetsLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local presets = {
		{name = "💊 ESX Revive", code = "TriggerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))"},
		{name = "💰 ESX Give Money", code = "TriggerEvent('esx:addMoney', 'bank', 50000)"},
		{name = "🚑 ESX Medic Revive", code = "TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))"},
		{name = "🔫 ESX Give Weapon", code = "TriggerEvent('esx_weaponshop:buy', 'weapon_pistol', 1)"},
		{name = "🚗 ESX Spawn Car", code = "TriggerEvent('esx_vehicleshop:buyVehicle', 'adder')"},
		{name = "👤 ESX Set Job", code = "TriggerEvent('esx:setJob', {name='police', grade=0, grade_name='Officer'})"},
		{name = "🏥 QBCore Revive", code = "TriggerEvent('hospital:client:Revive')"},
		{name = "💊 QBCore Heal", code = "TriggerEvent('hospital:client:SetHealth', 200)"},
		{name = "💵 QBCore Give Money", code = "TriggerEvent('qb-phone:client:addMoney', 50000)"},
		{name = "🔑 QBCore Open Menu", code = "TriggerEvent('qb-menu:client:openMenu', {})"},
		{name = "🚗 QBCore Spawn Vehicle", code = "TriggerEvent('qb-vehiclespawner:client:spawnVehicle', 'adder')"},
		{name = "📦 Give Item (Generic)", code = "TriggerServerEvent('inventory:addItem', 'bread', 5)"},
		{name = "🔫 Give Ammo", code = "TriggerServerEvent('weapons:addAmmo', 'weapon_pistol', 100)"},
		{name = "⭐ Give XP", code = "TriggerServerEvent('skills:addXP', 'strength', 100)"},
		{name = "🏠 Teleport Home", code = "TriggerEvent('player:teleportHome')"},
		{name = "🛒 Open Shop", code = "TriggerEvent('shop:open', 'general')"},
		{name = "🎒 Open Inventory", code = "TriggerEvent('inventory:openInventory')"},
		{name = "💬 Chat Message", code = "TriggerEvent('chat:addMessage', {args={'System', 'Hello!'}})"},
		{name = "🔑 Remote Event (Basic)", code = "game:GetService('ReplicatedStorage').RemoteEvent:FireServer()"},
		{name = "📡 Remote Function (Basic)", code = "local result = game:GetService('ReplicatedStorage').RemoteFunction:InvokeServer()\nprint(result)"},
	}

	for i, preset in ipairs(presets) do
		local PRow = Instance.new("TextButton", PresetsScroll)
		PRow.Size = UDim2.new(1, 0, 0, 30); PRow.LayoutOrder = i
		PRow.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
		PRow.BackgroundTransparency = 0.2; PRow.Text = ""
		PRow.BorderSizePixel = 0; PRow.AutoButtonColor = false
		Instance.new("UICorner", PRow).CornerRadius = UDim.new(0, 5)

		local PName = Instance.new("TextLabel", PRow)
		PName.Size = UDim2.new(1, -60, 1, 0); PName.Position = UDim2.new(0, 10, 0, 0)
		PName.BackgroundTransparency = 1; PName.Text = preset.name
		PName.TextColor3 = Color3.fromRGB(220, 220, 230); PName.TextSize = 12
		PName.Font = Enum.Font.GothamSemibold; PName.TextXAlignment = Enum.TextXAlignment.Left
		PName.TextTruncate = Enum.TextTruncate.AtEnd

		local UseBtn = Instance.new("TextButton", PRow)
		UseBtn.Size = UDim2.new(0, 50, 0, 22); UseBtn.Position = UDim2.new(1, -56, 0.5, -11)
		UseBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 140); UseBtn.Text = "Use"
		UseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); UseBtn.TextSize = 11
		UseBtn.Font = Enum.Font.GothamBold; UseBtn.BorderSizePixel = 0; UseBtn.AutoButtonColor = false
		Instance.new("UICorner", UseBtn).CornerRadius = UDim.new(0, 4)
		UseBtn.MouseEnter:Connect(function() TweenService:Create(UseBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play() end)
		UseBtn.MouseLeave:Connect(function() TweenService:Create(UseBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 80, 140)}):Play() end)

		local function loadPreset()
			playClick()
			CodeEditor.Text = preset.code
			showNotification("Preset loaded: " .. preset.name, "info")
		end
		UseBtn.MouseButton1Click:Connect(loadPreset)
		PRow.MouseButton1Click:Connect(loadPreset)
		PRow.MouseEnter:Connect(function() playHover(); TweenService:Create(PRow, TweenInfo.new(0.1), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play() end)
		PRow.MouseLeave:Connect(function() TweenService:Create(PRow, TweenInfo.new(0.1), {BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(32, 32, 42)}):Play() end)
	end

	-- ========== HELPER: generuj kod triggera ==========
	local function generateTriggerCode(trigger)
		local code = ""
		if trigger.type == "RemoteEvent" then
			if trigger.isServer then
				code = "-- FireServer: " .. trigger.name .. "\n"
				code = code .. trigger.path .. ":FireServer("
				if #trigger.args > 0 then
					code = code .. "\n\t-- Add your arguments here\n\t-- Example args: " .. table.concat(trigger.args, ", ") .. "\n"
				end
				code = code .. ")"
			else
				code = "-- FireClient via server: " .. trigger.name .. "\n"
				code = code .. trigger.path .. ":FireServer()"
			end
		elseif trigger.type == "RemoteFunction" then
			code = "-- InvokeServer: " .. trigger.name .. "\n"
			code = code .. "local result = " .. trigger.path .. ":InvokeServer("
			if #trigger.args > 0 then
				code = code .. "\n\t-- Args: " .. table.concat(trigger.args, ", ") .. "\n"
			end
			code = code .. ")\nprint('[Result]:', result)"
		elseif trigger.type == "BindableEvent" then
			code = "-- Fire BindableEvent: " .. trigger.name .. "\n"
			code = code .. trigger.path .. ":Fire()"
		elseif trigger.type == "BindableFunction" then
			code = "-- Invoke BindableFunction: " .. trigger.name .. "\n"
			code = code .. "local result = " .. trigger.path .. ":Invoke()\nprint('[Result]:', result)"
		elseif trigger.type == "NetworkEvent" or trigger.type == "Custom" then
			code = "-- Custom trigger: " .. trigger.name .. "\n"
			code = code .. "TriggerEvent('" .. trigger.name .. "')"
		end
		return code
	end

	-- ========== TWORZENIE WIERSZA TRIGGERA ==========
	local function createTriggerRow(trigger)
		local Row = Instance.new("TextButton", TriggerListFrame)
		Row.Size = UDim2.new(1, 0, 0, 40); Row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		Row.BackgroundTransparency = 0.3; Row.Text = ""; Row.BorderSizePixel = 0; Row.AutoButtonColor = false
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
		local RowStroke = Instance.new("UIStroke", Row)
		RowStroke.Color = Color3.fromRGB(230, 60, 110); RowStroke.Thickness = 2; RowStroke.Transparency = 1

		-- Ikona typ
		local typeColors = {
			RemoteEvent = Color3.fromRGB(60, 120, 220),
			RemoteFunction = Color3.fromRGB(120, 60, 220),
			BindableEvent = Color3.fromRGB(220, 120, 60),
			BindableFunction = Color3.fromRGB(220, 60, 120),
			Custom = Color3.fromRGB(60, 180, 60),
			NetworkEvent = Color3.fromRGB(180, 60, 180),
		}
		local typeIcons = {
			RemoteEvent = "📡", RemoteFunction = "🔄",
			BindableEvent = "⚡", BindableFunction = "🔁",
			Custom = "🔧", NetworkEvent = "🌐",
		}
		local tColor = typeColors[trigger.type] or Color3.fromRGB(150, 150, 160)
		local tIcon = typeIcons[trigger.type] or "❓"

		local TypeIcon = Instance.new("TextLabel", Row)
		TypeIcon.Size = UDim2.new(0, 24, 0, 24); TypeIcon.Position = UDim2.new(0, 6, 0.5, -12)
		TypeIcon.BackgroundColor3 = tColor; TypeIcon.BackgroundTransparency = 0.6
		TypeIcon.Text = tIcon; TypeIcon.TextSize = 13; TypeIcon.Font = Enum.Font.GothamBold
		TypeIcon.BorderSizePixel = 0; TypeIcon.ZIndex = 2
		Instance.new("UICorner", TypeIcon).CornerRadius = UDim.new(0, 4)

		local NameLbl = Instance.new("TextLabel", Row)
		NameLbl.Size = UDim2.new(1, -75, 0, 18); NameLbl.Position = UDim2.new(0, 36, 0, 4)
		NameLbl.BackgroundTransparency = 1; NameLbl.Text = trigger.name
		NameLbl.TextColor3 = Color3.fromRGB(220, 220, 230); NameLbl.TextSize = 12
		NameLbl.Font = Enum.Font.GothamSemibold; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

		local SourceLbl = Instance.new("TextLabel", Row)
		SourceLbl.Size = UDim2.new(1, -75, 0, 14); SourceLbl.Position = UDim2.new(0, 36, 0, 22)
		SourceLbl.BackgroundTransparency = 1; SourceLbl.Text = "📁 " .. (trigger.source or "Unknown")
		SourceLbl.TextColor3 = Color3.fromRGB(130, 130, 150); SourceLbl.TextSize = 10
		SourceLbl.Font = Enum.Font.Gotham; SourceLbl.TextXAlignment = Enum.TextXAlignment.Left
		SourceLbl.TextTruncate = Enum.TextTruncate.AtEnd

		-- Fire button
		local QuickFireBtn = Instance.new("TextButton", Row)
		QuickFireBtn.Size = UDim2.new(0, 32, 0, 28); QuickFireBtn.Position = UDim2.new(1, -36, 0.5, -14)
		QuickFireBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
		QuickFireBtn.Text = "▶"; QuickFireBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
		QuickFireBtn.TextSize = 14; QuickFireBtn.Font = Enum.Font.GothamBold
		QuickFireBtn.BorderSizePixel = 0; QuickFireBtn.AutoButtonColor = false; QuickFireBtn.ZIndex = 3
		Instance.new("UICorner", QuickFireBtn).CornerRadius = UDim.new(0, 4)
		QuickFireBtn.MouseEnter:Connect(function() TweenService:Create(QuickFireBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 160, 60)}):Play() end)
		QuickFireBtn.MouseLeave:Connect(function() TweenService:Create(QuickFireBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 100, 40)}):Play() end)
		QuickFireBtn.MouseButton1Click:Connect(function()
			playClick()
			local code = generateTriggerCode(trigger)
			local success, err = pcall(function()
				if loadstring then
					local fn, e = loadstring(code); if not fn then error(e) end; fn()
				elseif getgenv and getgenv().loadstring then
					local fn, e = getgenv().loadstring(code); if not fn then error(e) end; fn()
				end
			end)
			if success then showNotification("▶ Fired: " .. trigger.name, "success")
			else showNotification("Error: " .. tostring(err):sub(1, 50), "error") end
		end)

		Row.MouseEnter:Connect(function()
			playHover()
			if TriggerSystem.selectedTrigger ~= trigger then
				TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
			end
		end)
		Row.MouseLeave:Connect(function()
			if TriggerSystem.selectedTrigger ~= trigger then
				TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
			end
		end)
		Row.MouseButton1Click:Connect(function()
			playClick()
			-- Odznacz poprzedni
			if TriggerSystem.selectedNode then
				local oldStroke = TriggerSystem.selectedNode:FindFirstChildOfClass("UIStroke")
				if oldStroke then oldStroke.Transparency = 1 end
				TriggerSystem.selectedNode.BackgroundTransparency = 0.3
				TriggerSystem.selectedNode.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			end
			-- Zaznacz nowy
			TriggerSystem.selectedTrigger = trigger
			TriggerSystem.selectedNode = Row
			Row.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
			Row.BackgroundTransparency = 0
			RowStroke.Transparency = 0

			-- Update info
			InfoEmpty.Visible = false
			InfoName.Visible = true; InfoType.Visible = true
			InfoPath.Visible = true; TypeBadge.Visible = true
			InfoStroke.Color = tColor
			InfoName.Text = trigger.name
			InfoType.Text = "Type: " .. trigger.type .. (trigger.isServer and " (Server)" or " (Client)")
			InfoPath.Text = trigger.path or trigger.name
			TypeBadge.Text = trigger.type
			TypeBadge.BackgroundColor3 = tColor

			-- Wygeneruj kod do edytora
			CodeEditor.Text = generateTriggerCode(trigger)
		end)

		return Row
	end

	-- ========== SKANOWANIE TRIGGERÓW ==========
	local function renderTriggerList()
		for _, child in pairs(TriggerListFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local searchText = SearchBox.Text:lower()
		local count = 0
		for _, trigger in ipairs(TriggerSystem.foundTriggers) do
			if searchText == "" or trigger.name:lower():find(searchText, 1, true) or
				(trigger.source and trigger.source:lower():find(searchText, 1, true)) then
				createTriggerRow(trigger)
				count = count + 1
			end
		end
		TriggerCountLbl.Text = count .. " found"
	end

	local function scanTriggers()
		if TriggerSystem.isScanning then return end
		TriggerSystem.isScanning = true
		TriggerSystem.foundTriggers = {}
		ScanBtn.Text = "⏳ Scanning..."
		ScanBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
		StatusLbl.Text = "Scanning game objects..."

		for _, child in pairs(TriggerListFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		TriggerCountLbl.Text = "0 found"

		local found = {}
		local seen = {}

		local function addTrigger(name, trigType, path, source, args, isServer)
			if not name or name == "" then return end
			local key = path .. "_" .. trigType
			if seen[key] then return end
			seen[key] = true
			table.insert(found, {
				name = name, type = trigType, path = path,
				source = source, args = args or {}, isServer = isServer or false,
			})
		end

		-- Skanuj RemoteEvents i RemoteFunctions
		local function scanContainer(container, sourceName)
			if not container then return end
			pcall(function()
				for _, obj in ipairs(container:GetDescendants()) do
					pcall(function()
						if obj:IsA("RemoteEvent") then
							addTrigger(obj.Name, "RemoteEvent", obj:GetFullName(), sourceName, {}, true)
						elseif obj:IsA("RemoteFunction") then
							addTrigger(obj.Name, "RemoteFunction", obj:GetFullName(), sourceName, {}, true)
						elseif obj:IsA("BindableEvent") then
							addTrigger(obj.Name, "BindableEvent", obj:GetFullName(), sourceName, {}, false)
						elseif obj:IsA("BindableFunction") then
							addTrigger(obj.Name, "BindableFunction", obj:GetFullName(), sourceName, {}, false)
						end
					end)
				end
			end)
		end

		-- Główne miejsca
		scanContainer(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
		scanContainer(game:GetService("ReplicatedFirst"), "ReplicatedFirst")
		scanContainer(workspace, "Workspace")
		scanContainer(player:FindFirstChild("PlayerGui"), "PlayerGui")
		scanContainer(player:FindFirstChild("PlayerScripts"), "PlayerScripts")
		scanContainer(game:GetService("StarterGui"), "StarterGui")
		scanContainer(game:GetService("StarterPlayer"), "StarterPlayer")

		-- Custom resources (FiveM style)
		pcall(function()
			local builtIns = {
				["Workspace"]=1,["Players"]=1,["Lighting"]=1,["ReplicatedFirst"]=1,
				["ReplicatedStorage"]=1,["ServerScriptService"]=1,["ServerStorage"]=1,
				["StarterGui"]=1,["StarterPack"]=1,["StarterPlayer"]=1,["Teams"]=1,
				["SoundService"]=1,["Chat"]=1,["LocalizationService"]=1,["TestService"]=1,
				["RunService"]=1,["TextService"]=1,["MarketplaceService"]=1,["InsertService"]=1,
				["CoreGui"]=1,["TweenService"]=1,["UserInputService"]=1,
			}
			for _, child in ipairs(game:GetChildren()) do
				if not builtIns[child.Name] then
					scanContainer(child, child.Name)
				end
			end
		end)

		-- Szukaj przez skrypty (decompile - jeśli dostępne)
		StatusLbl.Text = "Scanning script sources..."
		pcall(function()
			if decompile then
				local scriptSources = {}
				local function collectScripts(root)
					for _, d in ipairs(root:GetDescendants()) do
						if d:IsA("LocalScript") or d:IsA("ModuleScript") then
							table.insert(scriptSources, d)
						end
					end
				end
				collectScripts(game:GetService("ReplicatedStorage"))
				collectScripts(player:FindFirstChild("PlayerScripts") or Instance.new("Folder"))
				collectScripts(game:GetService("StarterPlayer"))

				-- Szukaj TriggerEvent/TriggerServerEvent w source
				local triggerPattern = "TriggerEvent%('([^']+)')"
				local triggerServerPattern = "TriggerServerEvent%('([^']+)'"
				local triggerNUIPattern = "TriggerNUICallback%('([^']+)'"
				local triggerNetPattern = "TriggerNetEvent%('([^']+)'"

				for i, script in ipairs(scriptSources) do
					pcall(function()
						local src = decompile(script)
						if src and src ~= "" then
							-- TriggerEvent
							for evtName in src:gmatch(triggerPattern) do
								addTrigger(evtName, "Custom", evtName, script:GetFullName(), {}, false)
							end
							-- TriggerServerEvent
							for evtName in src:gmatch(triggerServerPattern) do
								addTrigger(evtName, "NetworkEvent", evtName, script:GetFullName(), {}, true)
							end
							-- TriggerNetEvent (FiveM alternatywna nazwa)
							for evtName in src:gmatch(triggerNetPattern) do
								addTrigger(evtName, "NetworkEvent", evtName, script:GetFullName(), {}, true)
							end
						end
					end)
					-- Pauza co 10 skryptów
					if i % 10 == 0 then task.wait() end
				end
			end
		end)

		-- Sortuj: RemoteEvents najpierw, potem po nazwie
		table.sort(found, function(a, b)
			local order = {RemoteEvent=1, RemoteFunction=2, BindableEvent=3, BindableFunction=4, NetworkEvent=5, Custom=6}
			local ao = order[a.type] or 9; local bo = order[b.type] or 9
			if ao ~= bo then return ao < bo end
			return a.name:lower() < b.name:lower()
		end)

		TriggerSystem.foundTriggers = found
		TriggerSystem.isScanning = false

		ScanBtn.Text = "🔍 Scan Triggers"
		ScanBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
		StatusLbl.Text = "Found " .. #found .. " triggers"
		StatusLbl.TextColor3 = #found > 0 and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(200, 150, 50)

		renderTriggerList()
		showNotification("Found " .. #found .. " triggers!", #found > 0 and "success" or "warning")
		print("[SBX TriggerFinder] Found " .. #found .. " triggers:")
		for _, t in ipairs(found) do
			print("  [" .. t.type .. "] " .. t.name .. " @ " .. t.path)
		end
	end

	ScanBtn.MouseButton1Click:Connect(function()
		playClick()
		task.spawn(scanTriggers)
	end)

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		task.wait(0.1)
		renderTriggerList()
	end)
end

-- ========== CONFIGS SYSTEM ==========
local ConfigSystem = {
    configs = {},
    currentConfigName = "default",
    configFolder = "SBX_Configs"
}

local function ensureConfigFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(ConfigSystem.configFolder) then
        makefolder(ConfigSystem.configFolder)
    end
    return true
end

local function saveConfig(name)
    if not writefile then 
        showNotification("Twój executor nie wspiera zapisu plików", "error")
        return 
    end
    ensureConfigFolder()
    
    local data = {
        Settings = Settings,
        ESP = ESP.settings,
        Self = Self.settings,
        Weapon = Weapon.settings,
        -- dodaj więcej sekcji w przyszłości
    }
    
    local success = pcall(function()
        writefile(ConfigSystem.configFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    
    if success then
        showNotification("Zapisano config: " .. name, "success")
        ConfigSystem.configs[name] = true
    else
        showNotification("Błąd zapisu configu", "error")
    end
end

local function loadConfig(name)
    if not isfile then 
        showNotification("Nieobsługiwany executor", "error")
        return 
    end
    local path = ConfigSystem.configFolder .. "/" .. name .. ".json"
    if not isfile(path) then
        showNotification("Config nie istnieje", "error")
        return
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    
    if success and data then
        -- Apply settings
        if data.Settings then Settings = data.Settings end
        if data.ESP then ESP.settings = data.ESP end
        if data.Self then Self.settings = data.Self end
        if data.Weapon then Weapon.settings = data.Weapon end
        
        showNotification("Załadowano config: " .. name, "success")
        -- Odśwież UI (możesz dodać callbacki do toggle'ów)
    else
        showNotification("Błąd wczytywania configu", "error")
    end
end

local function deleteConfig(name)
    if not delfile then return end
    local path = ConfigSystem.configFolder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
        ConfigSystem.configs[name] = nil
        showNotification("Usunięto config: " .. name, "info")
    end
end

local function refreshConfigList()
    ConfigSystem.configs = {}
    if not isfolder or not listfiles then return end
    ensureConfigFolder()
    for _, file in ipairs(listfiles(ConfigSystem.configFolder)) do
        if file:match("%.json$") then
            local name = file:gsub("%.json$", "")
            ConfigSystem.configs[name] = true
        end
    end
end

-- ========== TWORZENIE STRON ==========
local function createTabPage(tabName, subTabs)
	local Page = Instance.new("Frame")
	Page.Name = tabName; Page.Size = UDim2.new(1,0,1,0); Page.BackgroundTransparency = 1
	Page.Visible = false; Page.Parent = ContentArea
	tabPages[tabName] = Page; subPagesByTab[tabName] = {}
	local stbc = Instance.new("Frame")
	stbc.Name = tabName.."_SubTabs"; stbc.Size = UDim2.new(1,0,1,0)
	stbc.BackgroundTransparency = 1; stbc.Visible = false; stbc.Parent = SubTabsContainer
	for i, subName in ipairs(subTabs) do
		local SB = Instance.new("TextButton")
		SB.Name = subName; SB.Size = UDim2.new(0,130,0,40); SB.Position = UDim2.new(0,(i-1)*140,0,5)
		SB.BackgroundColor3 = Color3.fromRGB(35,35,45); SB.BackgroundTransparency = i == 1 and 0 or 0.5
		SB.Text = "◉ "..subName; SB.TextColor3 = Color3.fromRGB(255,255,255); SB.TextSize = 13
		SB.Font = Enum.Font.GothamSemibold; SB.BorderSizePixel = 0; SB.AutoButtonColor = false; SB.Parent = stbc
		Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 8)
		local SP = Instance.new("Frame")
		SP.Name = subName; SP.Size = UDim2.new(1,0,1,0); SP.BackgroundTransparency = 1
		SP.Visible = (i == 1); SP.Parent = Page
		local built = false
		local function buildIfNeeded()
			if built then return end; built = true
			if tabName == "Visuals" and subName == "Players" then buildPlayersPage(SP)
			elseif tabName == "Visuals" and subName == "World" then buildWorldPage(SP)
			elseif tabName == "Visuals" and subName == "Radar" then buildRadarPage(SP)
			elseif tabName == "Self" and subName == "Player" then buildSelfPlayerPage(SP)
			elseif tabName == "Self" and subName == "Weapon" then buildWeaponPage(SP)
			elseif tabName == "Online" and subName == "Player List" then buildOnlinePlayerListPage(SP)
			elseif tabName == "Executor" and subName == "Lua" then buildExecutorPage(SP)
			elseif tabName == "Resources" and subName == "Resource Stopper" then buildResourceStopperPage(SP)
			elseif tabName == "Resources" and subName == "Resource Dumper" then buildResourceDumperPage(SP)
			elseif tabName == "Settings" and subName == "Main" then buildSettingsMainPage(SP)
			elseif tabName == "Settings" and subName == "Crosshair" then buildSettingsCrosshairPage(SP)
			elseif tabName == "Resources" and subName == "Trigger Finder" then buildTriggerFinderPage(SP)
			else createComingSoonPanel(SP, subName.." będzie wkrótce dostępny") end
		end
		subPagesByTab[tabName][subName] = {button=SB, page=SP, build=buildIfNeeded}
		if i == 1 then selectedSubTabs[tabName] = SB end
		SB.MouseButton1Click:Connect(function()
			playClick()
			local cs = selectedSubTabs[tabName]; if cs then cs.BackgroundTransparency = 0.5 end
			SB.BackgroundTransparency = 0; selectedSubTabs[tabName] = SB
			for n, d in pairs(subPagesByTab[tabName]) do d.page.Visible = (n == subName) end
			buildIfNeeded()
		end)
		SB.MouseEnter:Connect(playHover)
	end
	return Page
end

for tabName, subs in pairs(tabSubTabs) do createTabPage(tabName, subs) end

local function showPage(tabName)
	for n, p in pairs(tabPages) do p.Visible = (n == tabName) end
	for _, c in pairs(SubTabsContainer:GetChildren()) do
		if c:IsA("Frame") then c.Visible = (c.Name == tabName.."_SubTabs") end
	end
	local subs = subPagesByTab[tabName]
	if subs then
		local sb = selectedSubTabs[tabName]
		if sb then for _, d in pairs(subs) do if d.button == sb then d.build(); break end end end
	end
end

for i, item in ipairs(sidebarItems) do
	local B = Instance.new("TextButton")
	B.Name = item.name; B.Size = UDim2.new(1,-20,0,38); B.Position = UDim2.new(0,10,0,110+(i-1)*42)
	B.BackgroundColor3 = Color3.fromRGB(30,30,40); B.BackgroundTransparency = 1
	B.Text = "  "..item.icon.."   "..item.name; B.TextColor3 = Color3.fromRGB(160,160,170)
	B.TextSize = 14; B.Font = Enum.Font.Gotham; B.TextXAlignment = Enum.TextXAlignment.Left
	B.BorderSizePixel = 0; B.AutoButtonColor = false; B.Parent = Sidebar
	Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
	tabButtons[item.name] = B
	if item.name == "Combat" then
		B.BackgroundTransparency = 0; B.TextColor3 = Color3.fromRGB(255,255,255)
		selectedTab = B; showPage("Combat")
	end
	B.MouseButton1Click:Connect(function()
		playClick()
		if selectedTab then selectedTab.BackgroundTransparency = 1; selectedTab.TextColor3 = Color3.fromRGB(160,160,170) end
		B.BackgroundTransparency = 0; B.TextColor3 = Color3.fromRGB(255,255,255); selectedTab = B; showPage(item.name)
	end)
	B.MouseEnter:Connect(function()
		playHover()
		if selectedTab ~= B then TweenService:Create(B, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play() end
	end)
	B.MouseLeave:Connect(function()
		if selectedTab ~= B then TweenService:Create(B, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
	end)
end

local originalSize = MainFrame.Size
local originalPos = MainFrame.Position
local function toggleMinimize()
	minimized = not minimized
	if minimized then
		local tw = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0,0,0,0),
			Position = UDim2.new(
				MainFrame.Position.X.Scale,
				MainFrame.Position.X.Offset + originalSize.X.Offset/2,
				MainFrame.Position.Y.Scale,
				MainFrame.Position.Y.Offset + originalSize.Y.Offset/2
			)
		})
		tw:Play()
		tw.Completed:Connect(function() if minimized then MainFrame.Visible = false end end)
	else
		MainFrame.Visible = true; MainFrame.Size = UDim2.new(0,0,0,0)
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = originalSize, Position = originalPos
		}):Play()
	end
end

UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if Settings.waitingForBind then return end
	if i.KeyCode == Settings.menuBind then toggleMinimize() end
	if i.KeyCode == Enum.KeyCode.H and Self.settings.bindedHeal then
		healSelf(); showNotification("Healed via bind", "success")
	end
end)

showNotification("SBX GUI v21 loaded!", "success")
print("SBX GUI v21 loaded!")
print("Menu bind: " .. Settings.menuBind.Name)
print("AC Scan: Results shown in GUI popup with STOP buttons per finding")
print("[SBX] Player Info now shows Password & Phone for authorized players!")
