-- ============================================================
-- CINEX HUB | KUROMI NIGHT EDITION (OLLIE EDITION)
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- TEMA
local C = {
    BG = Color3.fromRGB(22, 16, 34), SIDEBAR = Color3.fromRGB(38, 28, 54),
    PANEL = Color3.fromRGB(32, 23, 48), PANELB = Color3.fromRGB(52, 40, 74),
    PANELC = Color3.fromRGB(60, 46, 86), ACCENT = Color3.fromRGB(175, 95, 255),
    ACCENT2 = Color3.fromRGB(210, 145, 255), DIM = Color3.fromRGB(100, 55, 168),
    TOG_OFF = Color3.fromRGB(65, 50, 90), TOG_ON = Color3.fromRGB(155, 75, 240),
    TEXT = Color3.fromRGB(238, 232, 250), SUBTEXT = Color3.fromRGB(155, 138, 185),
    BORDER = Color3.fromRGB(85, 58, 128), ACTIVE_BG = Color3.fromRGB(58, 42, 82),
    BLACK = Color3.fromRGB(10, 6, 18), CARD = Color3.fromRGB(48, 34, 70),
    STAR = Color3.fromRGB(220, 180, 255)
}
local FONT_BOLD, FONT_SEMI, FONT_REG = Enum.Font.GothamBold, Enum.Font.GothamSemibold, Enum.Font.Gotham

-- GUI ROOT (Bypass)
local ScreenGui = Instance.new("ScreenGui")
if syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then ScreenGui.Parent = gethui()
else pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) end
ScreenGui.Name = "CinexHub_Kuromi"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

-- HELPERS
local function New(class, props, parent) local i = Instance.new(class) for k,v in pairs(props or {}) do i[k] = v end if parent then i.Parent = parent end return i end
local function Corner(parent, r) return New("UICorner", {CornerRadius=UDim.new(0, r or 8)}, parent) end
local function Stroke(parent, thick, col) return New("UIStroke", {Thickness=thick or 1, Color=col or C.BORDER}, parent) end
local function Lbl(parent, text, size, col, xalign, font) return New("TextLabel", {BackgroundTransparency=1, Text=text, Font=font or FONT_REG, TextSize=size or 13, TextColor3=col or C.TEXT, TextXAlignment=xalign or Enum.TextXAlignment.Left, Size=UDim2.fromScale(1,1)}, parent) end
local function tw(obj, t, props) TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end

-- ESTADO GLOBAL
_G.Cinex = { ESP = false, Box = false, Cross = false, CrossColor = C.ACCENT }

-- TAMANHOS
local MAIN_W = math.floor(Camera.ViewportSize.X * 0.90)
local MAIN_H = math.floor(Camera.ViewportSize.Y * 0.86)
local SIDE_W = math.max(180, math.floor(MAIN_W * 0.195))
local TOP_H, CONT_H = 54, MAIN_H - 54

-- ================= BOTÃO FLUTUANTE (FECHAR/ABRIR) =================
local FloatBtn = New("TextButton", {
    Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(20, 20),
    BackgroundColor3 = C.ACCENT, Text = "C", Font = FONT_BOLD, TextSize = 18, TextColor3 = C.TEXT, Visible = false
}, ScreenGui)
Corner(FloatBtn, 20); Stroke(FloatBtn, 2, C.BORDER)
FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false; Main.Visible = true
end)

-- ================= JANELA PRINCIPAL =================
local Main = New("Frame", {Size=UDim2.fromOffset(MAIN_W, MAIN_H), Position=UDim2.fromScale(0.5, 0.5), AnchorPoint=Vector2.new(0.5, 0.5), BackgroundColor3=C.BG}, ScreenGui)
Corner(Main, 12); Stroke(Main, 1.5, C.BORDER)

-- DRAG (SÓ NA TOPBAR)
local function MakeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; ds=i.Position; sp=target.AbsolutePosition end end)
    UserInputService.InputChanged:Connect(function(i) if drag then local d = i.Position - ds; target.Position = UDim2.fromOffset(sp.X+d.X, sp.Y+d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
end

-- TOPBAR
local Topbar = New("Frame", {Size=UDim2.new(1,0,0,TOP_H), BackgroundColor3=C.SIDEBAR}, Main); Corner(Topbar, 12); Stroke(Topbar, 1, C.BORDER)
local DragBg = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=1}, Topbar)
MakeDraggable(DragBg, Main)

-- Logo
Lbl(New("Frame", {Size=UDim2.fromOffset(158, 42), Position=UDim2.fromOffset(10, 6), BackgroundColor3=C.PANEL, ZIndex=2}, Topbar), "✦ CINEX HUB", 12, C.ACCENT, Enum.TextXAlignment.Center, FONT_BOLD)

-- Search Bar
local Search = New("Frame", {Size=UDim2.fromOffset(math.floor(MAIN_W * 0.38), 34), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), BackgroundColor3=C.PANEL, ZIndex=2}, Topbar)
Corner(Search, 8); Stroke(Search, 1, C.BORDER)
Lbl(Search, "  🔍  Search settings, e.g. silent aim, FOV...", 12, C.SUBTEXT, Enum.TextXAlignment.Left, FONT_REG)

-- Close Btn
local KX = New("TextButton", {Size=UDim2.fromOffset(24,24), Position=UDim2.fromOffset(MAIN_W-34, 15), BackgroundColor3=C.PANELB, Text="✕", TextColor3=C.TEXT, Font=FONT_BOLD, TextSize=10, ZIndex=3}, Topbar)
Corner(KX, 5)
KX.MouseButton1Click:Connect(function() Main.Visible=false; FloatBtn.Visible = true end)

-- ================= SIDEBAR =================
local Sidebar = New("Frame", {Size=UDim2.fromOffset(SIDE_W, CONT_H), Position=UDim2.fromOffset(0, TOP_H), BackgroundColor3=C.SIDEBAR, ZIndex=2}, Main)
local NavList = New("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.fromOffset(0,10), ZIndex=2}, Sidebar)
New("UIListLayout", {Padding=UDim.new(0,2)}, NavList)

-- Cartão Kuromi (Fundo)
local Card = New("Frame", {Name="KuroCard", Size=UDim2.new(1,-12,0,100), AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,6,1,-10), BackgroundColor3=C.CARD}, Sidebar)
Corner(Card, 10); Stroke(Card, 1, C.BORDER)
Lbl(Card, "CINEX HUB / KUROMI...", 11, C.TEXT, Enum.TextXAlignment.Center, FONT_BOLD).Position = UDim2.fromOffset(0, 20)
local BegBtn = New("TextButton", {Size=UDim2.new(1,-16,0,26), Position=UDim2.new(0,8,1,-34), BackgroundColor3=C.PANELB, Text="Switch to Beginner", Font=FONT_SEMI, TextSize=12, TextColor3=C.TEXT}, Card)
Corner(BegBtn, 7); Stroke(BegBtn, 1, C.BORDER)

-- ================= ÁREA DE CONTEÚDO =================
local Content = New("Frame", {Size=UDim2.new(1,-SIDE_W,0,CONT_H), Position=UDim2.fromOffset(SIDE_W, TOP_H), BackgroundColor3=C.BG, ZIndex=2}, Main)
local CatTitle = New("TextLabel", {Size=UDim2.fromOffset(300,28), Position=UDim2.fromOffset(20,16), BackgroundTransparency=1, Text="VISUALS", Font=FONT_BOLD, TextSize=20, TextColor3=C.TEXT, ZIndex=3}, Content)

-- ================= SISTEMA DE ABAS =================
local TABS = {
    {icon="⚔", label="Combat"}, {icon="◈", label="Visuals"}, {icon="⊞", label="Misc"},
    {icon="⚙", label="Config"}, {icon="▷", label="Quick start"}, {icon="★", label="Favorites"},
    {icon="⊡", label="Creator Presets"}, {icon="⌨", label="Keybinds"},
}
local Pages = {}
local tabBtns = {}

for _, tab in ipairs(TABS) do
    -- Cria a página em branco
    Pages[tab.label] = New("Frame", {Size=UDim2.new(1,-16,1,-80), Position=UDim2.fromOffset(8,72), BackgroundTransparency=1, Visible=false, ZIndex=3}, Content)
    New("UIListLayout", {Padding=UDim.new(0,6)}, Pages[tab.label])
end

local function setActiveTab(name)
    for _, t in pairs(tabBtns) do
        local isActive = t.label == name
        tw(t.bg, 0.15, {BackgroundColor3 = isActive and C.ACTIVE_BG or Color3.fromRGB(0,0,0)})
        t.bg.BackgroundTransparency = isActive and 0 or 1
        t.lbl.TextColor3 = isActive and C.TEXT or C.SUBTEXT
        t.bar.Visible = isActive
    end
    for label, page in pairs(Pages) do page.Visible = (label == name) end
    CatTitle.Text = name:upper()
end

-- Criando os botões da Sidebar
for i, tab in ipairs(TABS) do
    local row = New("Frame", {Size=UDim2.new(1,0,0,38), BackgroundTransparency=1, LayoutOrder=i}, NavList)
    local bar = New("Frame", {Size=UDim2.fromOffset(3, 22), Position=UDim2.fromOffset(0, 8), BackgroundColor3=C.ACCENT, Visible=false}, row)
    local bg = New("TextButton", {Size=UDim2.new(1,-4,0,34), Position=UDim2.fromOffset(4,2), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=1, Text=""}, row); Corner(bg, 7)
    Lbl(bg, tab.icon, 12, C.SUBTEXT, Enum.TextXAlignment.Center, FONT_BOLD).Size = UDim2.fromOffset(24, 24)
    local lbl = Lbl(bg, tab.label, 12, C.SUBTEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    lbl.Position = UDim2.fromOffset(36,0); lbl.Size = UDim2.new(1,-48,1,0)
    
    tabBtns[i] = {bg=bg, bar=bar, lbl=lbl, label=tab.label}
    bg.MouseButton1Click:Connect(function() setActiveTab(tab.label) end)
end

-- ================= COMPONENTES (UI) =================
local function MakeToggle(parent, labelText, default, callback)
    local row = New("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=C.PANEL}, parent); Corner(row, 7); Stroke(row, 1, C.BORDER)
    Lbl(New("Frame", {Size=UDim2.new(1,-64,1,0), Position=UDim2.fromOffset(10,0)}, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    local state = default
    local track = New("Frame", {Size=UDim2.fromOffset(42,22), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-28,0.5,0), BackgroundColor3=state and C.TOG_ON or C.TOG_OFF}, row); Corner(track, 11)
    local knob = New("Frame", {Size=UDim2.fromOffset(18,18), Position=state and UDim2.fromOffset(22,2) or UDim2.fromOffset(2,2), BackgroundColor3=Color3.new(1,1,1)}, track); Corner(knob, 9)
    local btn = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=""}, track)
    btn.MouseButton1Click:Connect(function()
        state = not state
        tw(track,0.18,{BackgroundColor3=state and C.TOG_ON or C.TOG_OFF})
        tw(knob,0.18,{Position=state and UDim2.fromOffset(22,2) or UDim2.fromOffset(2,2)})
        if callback then callback(state) end
    end)
    -- Star Icon
    Lbl(New("Frame", {Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-50,0.5,-10)}, row), "★", 12, C.STAR, Enum.TextXAlignment.Center)
end

local function MakeSlider(parent, labelText, minV, maxV, defV, callback)
    local row = New("Frame", {Size=UDim2.new(1,0,0,52), BackgroundColor3=C.PANEL}, parent); Corner(row, 7); Stroke(row, 1, C.BORDER)
    Lbl(New("Frame", {Size=UDim2.new(1,-48,0,20), Position=UDim2.fromOffset(10,6)}, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    local valLbl = New("TextLabel", {Size=UDim2.fromOffset(32,20), AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-30,0,6), BackgroundTransparency=1, Text=tostring(defV), Font=FONT_BOLD, TextSize=12, TextColor3=C.ACCENT2, TextXAlignment=Enum.TextXAlignment.Right}, row)
    local track = New("Frame", {Size=UDim2.new(1,-20,0,6), Position=UDim2.fromOffset(10,32), BackgroundColor3=C.TOG_OFF}, row); Corner(track, 3)
    local pct = (defV - minV) / (maxV - minV)
    local fill = New("Frame", {Size=UDim2.fromScale(pct,1), BackgroundColor3=C.ACCENT}, track); Corner(fill, 3)
    local knob = New("Frame", {Size=UDim2.fromOffset(14,14), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(pct,0,0.5,0), BackgroundColor3=Color3.new(1,1,1)}, track); Corner(knob, 7); Stroke(knob, 1.5, C.ACCENT)
    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel*(maxV-minV) + 0.5)
        rel = (val-minV)/(maxV-minV)
        fill.Size = UDim2.fromScale(rel,1); knob.Position = UDim2.new(rel,0,0.5,0); valLbl.Text = tostring(val)
        if callback then callback(val) end
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    UserInputService.InputChanged:Connect(function(i) if dragging then update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then update(i.Position.X) end end)
    Lbl(New("Frame", {Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-24,0.5,-10)}, row), "★", 12, C.STAR, Enum.TextXAlignment.Center)
end

local function MakePill(parent, labelText, pillText)
    local row = New("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=C.PANEL}, parent); Corner(row, 7); Stroke(row, 1, C.BORDER)
    Lbl(New("Frame", {Size=UDim2.new(1,-90,1,0), Position=UDim2.fromOffset(10,0)}, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)
    local pill = New("TextButton", {Size=UDim2.fromOffset(68,26), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-28,0.5,0), BackgroundColor3=C.PANELB, Text=pillText, Font=FONT_SEMI, TextSize=12, TextColor3=C.TEXT}, row)
    Corner(pill, 6); Stroke(pill, 1, C.BORDER)
    Lbl(New("Frame", {Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-50,0.5,-10)}, row), "★", 12, C.STAR, Enum.TextXAlignment.Center)
end

-- ================= POPULANDO A ABA VISUALS =================
MakePill(Pages["Visuals"], "esp font", "UI")
MakeSlider(Pages["Visuals"], "esp font size", 6, 30, 13, function(v) end)
MakeToggle(Pages["Visuals"], "infinite range", false)
MakeToggle(Pages["Visuals"], "enable esp", true, function(s) _G.Cinex.ESP = s end)
MakePill(Pages["Visuals"], "ESP enable bind", "None")
MakeToggle(Pages["Visuals"], "box esp", true, function(s) _G.Cinex.Box = s end)
MakePill(Pages["Visuals"], "box color", "Color")

MakePill(Pages["Visuals"], "crosshair font", "UI")
MakeToggle(Pages["Visuals"], "enable crosshair", true, function(s) _G.Cinex.Cross = s end)
MakePill(Pages["Visuals"], "crosshair color", "Color")
MakeToggle(Pages["Visuals"], "crosshair on target", true)
MakeSlider(Pages["Visuals"], "speed", 1, 10, 3, function(v) end)
MakeSlider(Pages["Visuals"], "radius", 5, 60, 25, function(v) end)
MakeSlider(Pages["Visuals"], "thickness", 1, 6, 1.5, function(v) end)
MakeSlider(Pages["Visuals"], "length", 5, 50, 20, function(v) end)

-- ================= LÓGICA DO JOGO =================
local Drawing = Drawing
local Drawings = {}

local function RenderESP()
    if not _G.Cinex.ESP or not _G.Cinex.Box then for p, d in pairs(Drawings) do if d.Remove then d:Remove() end; Drawings[p] = nil end; return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                if not Drawings[player] then Drawings[player] = Drawing.new("Square"); Drawings[player].Thickness = 1; Drawings[player].Filled = false end
                local dist = (Camera.CFrame.Position - head.Position).Magnitude
                local size = math.clamp(1500 / dist, 20, 300)
                Drawings[player].Size = Vector2.new(size, size * 1.5)
                Drawings[player].Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
                Drawings[player].Color = C.ACCENT; Drawings[player].Visible = true
            else
                if Drawings[player] then Drawings[player].Visible = false end
            end
        end
    end
end

local function RenderCross()
    if not Drawings.Crosshair then Drawings.Crosshair = Drawing.new("Line"); Drawings.Crosshair.Thickness = 1.5 end
    if _G.Cinex.Cross then
        local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        Drawings.Crosshair.From = Vector2.new(cx - 10, cy)
        Drawings.Crosshair.To = Vector2.new(cx + 10, cy)
        Drawings.Crosshair.Color = C.ACCENT
        Drawings.Crosshair.Visible = true
    else
        Drawings.Crosshair.Visible = false
    end
end

RunService.RenderStepped:Connect(function() pcall(RenderESP); pcall(RenderCross) end)

-- Iniciar na aba Visuals
setActiveTab("Visuals")
print("[CinexHub] Ollie Edition carregado. R SHIFT para fechar/abrir.")
