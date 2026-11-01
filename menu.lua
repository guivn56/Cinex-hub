-- ============================================================
-- CINEX HUB | KUROMI EDITION (GLASSMORPHISM REFINADO)
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

if _G.CinexCleanup then pcall(_G.CinexCleanup) end

-- ================= TEMA (TONALIDADE DA FOTO) =================
local C = {
    BG = Color3.fromRGB(18, 12, 28), SIDEBAR = Color3.fromRGB(25, 18, 38),
    PANEL = Color3.fromRGB(35, 25, 50), PANELB = Color3.fromRGB(50, 35, 70),
    ACCENT = Color3.fromRGB(185, 105, 255), ACCENT2 = Color3.fromRGB(215, 150, 255),
    TOG_OFF = Color3.fromRGB(60, 45, 80), TOG_ON = Color3.fromRGB(170, 85, 255),
    TEXT = Color3.fromRGB(240, 235, 255), SUBTEXT = Color3.fromRGB(150, 130, 180),
    BORDER = Color3.fromRGB(85, 60, 120), ACTIVE_BG = Color3.fromRGB(65, 45, 95),
    STAR = Color3.fromRGB(220, 180, 255)
}
local FONT_BOLD, FONT_SEMI, FONT_REG = Enum.Font.GothamBold, Enum.Font.GothamSemibold, Enum.Font.Gotham

-- ================= GUI ROOT =================
local ScreenGui = Instance.new("ScreenGui")
if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then ScreenGui.Parent = gethui()
else pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) end
ScreenGui.Name = "CinexHub_Kuromi"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999

-- ================= HELPERS =================
local function New(class, props, parent) local i = Instance.new(class) for k,v in pairs(props or {}) do i[k] = v end if parent then i.Parent = parent end return i end
local function Corner(parent, r) return New("UICorner", {CornerRadius=UDim.new(0, r or 8)}, parent) end
local function Stroke(parent, thick, col) return New("UIStroke", {Thickness=thick or 1, Color=col or C.BORDER, Transparency=0.5}, parent) end
local function Lbl(parent, text, size, col, xalign, font) 
    return New("TextLabel", {BackgroundTransparency=1, Text=text, Font=font or FONT_REG, TextSize=size or 13, TextColor3=col or C.TEXT, TextXAlignment=xalign or Enum.TextXAlignment.Left, Size=UDim2.fromScale(1,1), ZIndex=5}, parent) 
end
local function tw(obj, t, props) TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

-- ================= MAIN FRAME =================
local Main = New("Frame", {
    Size = UDim2.fromScale(0.90, 0.85), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.BG, BackgroundTransparency = 0.15, ZIndex = 2
}, ScreenGui)
Corner(Main, 12); Stroke(Main, 1.5, C.BORDER)

-- ================= DRAG SYSTEM =================
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

-- ================= TOPBAR =================
local Topbar = New("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.2, ZIndex = 3}, Main)
Corner(Topbar, 12); Stroke(Topbar, 1, C.BORDER)
Lbl(Topbar, "  ✦ CINEX HUB | KUROMI", 14, C.ACCENT, Enum.TextXAlignment.Left, FONT_BOLD)

-- SEARCH BAR
local Search = New("Frame", {Size = UDim2.new(0.4, 0, 0, 32), Position = UDim2.new(0.3, 0, 0, 9), BackgroundColor3 = C.PANEL, BackgroundTransparency = 0.4, ZIndex = 4}, Topbar)
Corner(Search, 8); Stroke(Search, 1, C.BORDER)
Lbl(Search, "  🔍  Search settings...", 12, C.SUBTEXT, Enum.TextXAlignment.Left, FONT_REG)

-- CLOSE BTN
local KX = New("TextButton", {Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -40, 0, 10), BackgroundColor3 = C.PANELB, BackgroundTransparency = 0.2, Text = "✕", TextColor3 = C.TEXT, Font = FONT_BOLD, TextSize = 14, ZIndex = 4}, Topbar)
Corner(KX, 6)
KX.MouseButton1Click:Connect(function() Main.Visible = false; FloatBtn.Visible = true end)

-- ================= SIDEBAR =================
local Sidebar = New("Frame", {Size = UDim2.new(0.24, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundColor3 = C.SIDEBAR, BackgroundTransparency = 0.2, ZIndex = 3}, Main)
local NavList = New("Frame", {Size = UDim2.new(1, 0, 1, -120), BackgroundTransparency = 1, ZIndex = 4}, Sidebar)
New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, NavList)
New("UIListLayout", {Padding = UDim.new(0, 4)}, NavList)

-- KUROMI CARD
local Card = New("Frame", {Size = UDim2.new(1, -20, 0, 90), Position = UDim2.new(0, 10, 1, -100), BackgroundColor3 = C.PANEL, BackgroundTransparency = 0.2, ZIndex = 4}, Sidebar)
Corner(Card, 10); Stroke(Card, 1, C.BORDER)
Lbl(Card, "CINEX HUB / KUROMI...", 12, C.TEXT, Enum.TextXAlignment.Center, FONT_BOLD).Position = UDim2.fromOffset(0, 15)
local BegBtn = New("TextButton", {Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundColor3 = C.PANELB, BackgroundTransparency = 0.3, Text = "Switch to Beginner", Font = FONT_SEMI, TextSize = 12, TextColor3 = C.TEXT, ZIndex = 5}, Card)
Corner(BegBtn, 6); Stroke(BegBtn, 1, C.BORDER)

-- ================= CONTEÚDO =================
local Content = New("Frame", {Size = UDim2.new(0.76, 0, 1, -50), Position = UDim2.new(0.24, 0, 0, 50), BackgroundColor3 = C.BG, BackgroundTransparency = 1, ZIndex = 3}, Main)
local CatTitle = New("TextLabel", {Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Text = "VISUALS", Font = FONT_BOLD, TextSize = 22, TextColor3 = C.TEXT, ZIndex = 5}, Content)
local Scroll = New("ScrollingFrame", {Size = UDim2.new(1, -20, 1, -60), Position = UDim2.fromOffset(10, 50), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = C.ACCENT, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4}, Content)
New("UIListLayout", {Padding = UDim.new(0, 6)}, Scroll)

-- ================= PÁGINAS =================
local Pages = {}
local TABS = {
    {icon="⚔", label="Combat"}, {icon="◈", label="Visuals"}, {icon="⊞", label="Misc"},
    {icon="⚙", label="Config"}
}
for _, tab in ipairs(TABS) do
    Pages[tab.label] = New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4}, Content)
    New("UIListLayout", {Padding = UDim.new(0, 6)}, Pages[tab.label])
end

-- ================= COMPONENTES =================
local function MakeToggle(parent, text, default, callback)
    local row = New("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.PANEL, BackgroundTransparency = 0.2, ZIndex = 5}, parent)
    Corner(row, 8); Stroke(row, 1, C.BORDER)
    Lbl(row, "  "..text, 13, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    
    -- Star Icon
    Lbl(row, "★", 14, C.STAR, Enum.TextXAlignment.Center).Position = UDim2.new(1, -85, 0, 12)
    Lbl(row, "★", 14, C.STAR, Enum.TextXAlignment.Center).Size = UDim2.fromOffset(20, 20)

    local state = default
    local track = New("Frame", {Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -50, 0.5, -11), BackgroundColor3 = state and C.TOG_ON or C.TOG_OFF, ZIndex = 6}, row)
    Corner(track, 11)
    local knob = New("Frame", {Size = UDim2.fromOffset(18, 18), Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 7}, track)
    Corner(knob, 9)
    
    local btn = New("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 8}, track)
    btn.MouseButton1Click:Connect(function()
        state = not state
        tw(track, 0.15, {BackgroundColor3 = state and C.TOG_ON or C.TOG_OFF})
        tw(knob, 0.15, {Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)})
        if callback then callback(state) end
    end)
end

local function MakeButton(parent, text, pillText)
    local row = New("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.PANEL, BackgroundTransparency = 0.2, ZIndex = 5}, parent)
    Corner(row, 8); Stroke(row, 1, C.BORDER)
    Lbl(row, "  "..text, 13, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)

    -- Star Icon
    Lbl(row, "★", 14, C.STAR, Enum.TextXAlignment.Center).Position = UDim2.new(1, -135, 0, 12)
    Lbl(row, "★", 14, C.STAR, Enum.TextXAlignment.Center).Size = UDim2.fromOffset(20, 20)
    
    local pill = New("TextButton", {Size = UDim2.fromOffset(70, 28), Position = UDim2.new(1, -100, 0.5, -14), BackgroundColor3 = C.PANELB, BackgroundTransparency = 0.3, Text = pillText or "UI", Font = FONT_SEMI, TextSize = 12, TextColor3 = C.TEXT, ZIndex = 6}, row)
    Corner(pill, 6); Stroke(pill, 1, C.BORDER)
end

-- ESTADO GLOBAL
_G.Cinex = { ESP = false, Box = false, Cross = false }

-- POPULANDO VISUALS (Mais limpo)
MakeToggle(Pages["Visuals"], "enable esp", true, function(s) _G.Cinex.ESP = s end)
MakeToggle(Pages["Visuals"], "box esp", true, function(s) _G.Cinex.Box = s end)
MakeToggle(Pages["Visuals"], "enable crosshair", true, function(s) _G.Cinex.Cross = s end)
MakeButton(Pages["Visuals"], "PC e Mobile", "Ativo")

-- NAVEGAÇÃO
local function SetTab(name)
    for label, page in pairs(Pages) do page.Visible = (label == name) end
    CatTitle.Text = name:upper()
end
SetTab("Visuals")

for _, tab in ipairs(TABS) do
    local btn = New("TextButton", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.PANELB, BackgroundTransparency = 0.3, Text = "  "..tab.icon.."  "..tab.label, TextColor3 = C.TEXT, Font = FONT_SEMI, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, NavList)
    Corner(btn, 8); Stroke(btn, 1, C.BORDER)
    btn.MouseButton1Click:Connect(function()
        for _, other in pairs(NavList:GetChildren()) do
            if other:IsA("TextButton") then tw(other, 0.1, {BackgroundColor3 = C.PANELB}) end
        end
        tw(btn, 0.1, {BackgroundColor3 = C.ACCENT})
        SetTab(tab.label)
    end)
end

-- ================= LÓGICA DO JOGO (ESP E CROSSHAIR) =================
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

-- KEYBIND (R SHIFT)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        if not Main.Visible then FloatBtn.Visible = true else FloatBtn.Visible = false end
    end
end)

_G.CinexCleanup = function() ScreenGui:Destroy() end
