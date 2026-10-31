-- ============================================================
-- CINEX HUB | KUROMI EDITION (MOBILE BULLETPROOF FIX)
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- Limpeza de tentativas anteriores
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "CinexHub_Mobile" then gui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then ScreenGui.Parent = gethui()
else pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) end
ScreenGui.Name = "CinexHub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999

-- TEMA
local C = {
    BG = Color3.fromRGB(22, 16, 34), SIDEBAR = Color3.fromRGB(38, 28, 54),
    PANEL = Color3.fromRGB(32, 23, 48), PANELB = Color3.fromRGB(52, 40, 74),
    ACCENT = Color3.fromRGB(175, 95, 255), ACCENT2 = Color3.fromRGB(210, 145, 255),
    TOG_OFF = Color3.fromRGB(65, 50, 90), TOG_ON = Color3.fromRGB(155, 75, 240),
    TEXT = Color3.fromRGB(238, 232, 250), SUBTEXT = Color3.fromRGB(155, 138, 185),
    BORDER = Color3.fromRGB(85, 58, 128), ACTIVE_BG = Color3.fromRGB(58, 42, 82)
}
local FONT_BOLD, FONT_SEMI, FONT_REG = Enum.Font.GothamBold, Enum.Font.GothamSemibold, Enum.Font.Gotham

local function New(class, props, parent) local i = Instance.new(class) for k,v in pairs(props or {}) do i[k] = v end if parent then i.Parent = parent end return i end
local function Corner(parent, r) return New("UICorner", {CornerRadius=UDim.new(0, r or 8)}, parent) end
local function Stroke(parent, thick, col) return New("UIStroke", {Thickness=thick or 1, Color=col or C.BORDER}, parent) end
local function Lbl(parent, text, size, col, xalign, font) 
    return New("TextLabel", {BackgroundTransparency=1, Text=text, Font=font or FONT_REG, TextSize=size or 13, TextColor3=col or C.TEXT, TextXAlignment=xalign or Enum.TextXAlignment.Left, Size=UDim2.fromScale(1,1), ZIndex=5}, parent) 
end
local function tw(obj, t, props) TweenService:Create(obj, TweenInfo.new(t), props):Play() end

-- BOTÃO FLUTUANTE
local FloatBtn = New("TextButton", {
    Size = UDim2.fromOffset(45, 45), Position = UDim2.fromOffset(20, 100),
    BackgroundColor3 = C.ACCENT, Text = "C", Font = FONT_BOLD, TextSize = 20, TextColor3 = C.TEXT, Visible = false, ZIndex = 10
}, ScreenGui)
Corner(FloatBtn, 22); Stroke(FloatBtn, 2, C.BORDER)

-- JANELA PRINCIPAL
local Main = New("Frame", {
    Size = UDim2.fromScale(0.90, 0.85),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.BG,
    ZIndex = 2
}, ScreenGui)
Corner(Main, 12); Stroke(Main, 2, C.BORDER)

FloatBtn.MouseButton1Click:Connect(function() FloatBtn.Visible = false; Main.Visible = true end)

-- DRAG SYSTEM
local dragging, dragInput, dragStart, startPos
local function MakeDrag(handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
end
MakeDrag(Main)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- TOPBAR
local Topbar = New("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = C.SIDEBAR, ZIndex = 3}, Main)
Corner(Topbar, 12); Stroke(Topbar, 1, C.BORDER)
Lbl(Topbar, "  CINEX HUB | KUROMI", 14, C.ACCENT, Enum.TextXAlignment.Left, FONT_BOLD)

-- CLOSE BTN
local KX = New("TextButton", {Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0, 10), BackgroundColor3 = C.PANELB, Text = "✕", TextColor3 = C.TEXT, Font = FONT_BOLD, TextSize = 14, ZIndex = 4}, Topbar)
Corner(KX, 6)
KX.MouseButton1Click:Connect(function() Main.Visible = false; FloatBtn.Visible = true end)

-- SIDEBAR
local Sidebar = New("Frame", {Size = UDim2.new(0.22, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundColor3 = C.SIDEBAR, ZIndex = 3}, Main)
local NavList = New("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 4}, Sidebar)
New("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center}, NavList)
New("UIPadding", {PaddingTop = UDim.new(0, 10)}, NavList)

-- CONTEÚDO
local Content = New("Frame", {Size = UDim2.new(0.78, 0, 1, -50), Position = UDim2.new(0.22, 0, 0, 50), BackgroundColor3 = C.BG, ZIndex = 3}, Main)
local CatTitle = New("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "VISUALS", Font = FONT_BOLD, TextSize = 20, TextColor3 = C.TEXT, ZIndex = 5}, Content)
local Scroll = New("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -50), Position = UDim2.fromOffset(10, 45), BackgroundTransparency = 1, ScrollBarThickness = 4, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4}, Content)
New("UIListLayout", {Padding = UDim.new(0, 8)}, Scroll)

-- PÁGINAS
local Pages = {}
local TABS = {
    {icon="⚔", label="Combat"}, {icon="◈", label="Visuals"}, {icon="⊞", label="Misc"},
    {icon="⚙", label="Config"}
}
for _, tab in ipairs(TABS) do
    Pages[tab.label] = New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4}, Content)
    New("UIListLayout", {Padding = UDim.new(0, 8)}, Pages[tab.label])
end

-- COMPONENTES
local function MakeToggle(parent, text, default, callback)
    local row = New("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.PANEL, ZIndex = 5}, parent)
    Corner(row, 8); Stroke(row, 1, C.BORDER)
    Lbl(row, "  "..text, 13, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    
    local state = default
    local track = New("Frame", {Size = UDim2.fromOffset(44, 24), Position = UDim2.new(1, -55, 0.5, -12), BackgroundColor3 = state and C.TOG_ON or C.TOG_OFF, ZIndex = 6}, row)
    Corner(track, 12)
    local knob = New("Frame", {Size = UDim2.fromOffset(20, 20), Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 7}, track)
    Corner(knob, 10)
    
    local btn = New("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 8}, track)
    btn.MouseButton1Click:Connect(function()
        state = not state
        tw(track, 0.15, {BackgroundColor3 = state and C.TOG_ON or C.TOG_OFF})
        tw(knob, 0.15, {Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)})
        if callback then callback(state) end
    end)
end

local function MakeButton(parent, text)
    local row = New("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.PANEL, ZIndex = 5}, parent)
    Corner(row, 8); Stroke(row, 1, C.BORDER)
    Lbl(row, "  "..text, 13, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    
    local pill = New("TextButton", {Size = UDim2.fromOffset(70, 28), Position = UDim2.new(1, -85, 0.5, -14), BackgroundColor3 = C.PANELB, Text = "UI", Font = FONT_SEMI, TextSize = 12, TextColor3 = C.TEXT, ZIndex = 6}, row)
    Corner(pill, 6); Stroke(pill, 1, C.BORDER)
end

-- ESTADO
_G.Cinex = { ESP = false, Box = false, Cross = false }

-- POPULANDO VISUALS
MakeToggle(Pages["Visuals"], "enable esp", true, function(s) _G.Cinex.ESP = s end)
MakeToggle(Pages["Visuals"], "box esp", true, function(s) _G.Cinex.Box = s end)
MakeButton(Pages["Visuals"], "box color")
MakeToggle(Pages["Visuals"], "enable crosshair", true, function(s) _G.Cinex.Cross = s end)

-- NAVEGAÇÃO
local function SetTab(name)
    for label, page in pairs(Pages) do page.Visible = (label == name) end
    CatTitle.Text = name:upper()
end
SetTab("Visuals")

for _, tab in ipairs(TABS) do
    local btn = New("TextButton", {Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = C.PANELB, Text = tab.icon.." "..tab.label, TextColor3 = C.TEXT, Font = FONT_SEMI, TextSize = 12, ZIndex = 5}, NavList)
    Corner(btn, 8); Stroke(btn, 1, C.BORDER)
    btn.MouseButton1Click:Connect(function()
        for _, other in pairs(NavList:GetChildren()) do
            if other:IsA("TextButton") then other.BackgroundColor3 = C.PANELB end
        end
        btn.BackgroundColor3 = C.ACCENT
        SetTab(tab.label)
    end)
end

-- LOOP DO ESP E CROSSHAIR
local Drawing = Drawing
local Drawings = {}
local function Render()
    if _G.Cinex.Box and _G.Cinex.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    if not Drawings[p] then Drawings[p] = Drawing.new("Square"); Drawings[p].Thickness = 1; Drawings[p].Filled = false end
                    local dist = (Camera.CFrame.Position - p.Character.Head.Position).Magnitude
                    local size = math.clamp(1500/dist, 20, 300)
                    Drawings[p].Size = Vector2.new(size, size*1.5)
                    Drawings[p].Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    Drawings[p].Color = C.ACCENT
                    Drawings[p].Visible = true
                elseif Drawings[p] then
                    Drawings[p].Visible = false
                end
            end
        end
    else
        for p, d in pairs(Drawings) do if d.Remove then d:Remove() end; Drawings[p] = nil end
    end

    if _G.Cinex.Cross then
        if not Drawings.Cross then Drawings.Cross = Drawing.new("Line"); Drawings.Cross.Thickness = 1.5 end
        local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
        Drawings.Cross.From = Vector2.new(cx-10, cy); Drawings.Cross.To = Vector2.new(cx+10, cy)
        Drawings.Cross.Color = C.ACCENT; Drawings.Cross.Visible = true
    elseif Drawings.Cross then
        Drawings.Cross.Visible = false
    end
end

RunService.RenderStepped:Connect(function() pcall(Render) end)
_G.CinexCleanup = function() ScreenGui:Destroy() end
