-- ============================================================
--  CINEX HUB | KUROMI NIGHT EDITION  v2.6.20
--  Compatível: PC (Synapse/Wave/Swift) + Mobile (Delta/Codex/Fluxus)
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

-- ── THEME ────────────────────────────────────────────────────
local C = {
    BG         = Color3.fromRGB(22,  16,  34),
    SIDEBAR    = Color3.fromRGB(38,  28,  54),
    PANEL      = Color3.fromRGB(32,  23,  48),
    PANELB     = Color3.fromRGB(52,  40,  74),
    PANELC     = Color3.fromRGB(60,  46,  86),
    ACCENT     = Color3.fromRGB(175, 95, 255),
    ACCENT2    = Color3.fromRGB(210,145, 255),
    DIM        = Color3.fromRGB(100, 55, 168),
    TOG_OFF    = Color3.fromRGB(65,  50,  90),
    TOG_ON     = Color3.fromRGB(155, 75, 240),
    TEXT       = Color3.fromRGB(238,232,250),
    SUBTEXT    = Color3.fromRGB(155,138,185),
    BORDER     = Color3.fromRGB(85,  58, 128),
    ACTIVE_BG  = Color3.fromRGB(58,  42,  82),
    BLACK      = Color3.fromRGB(10,   6,  18),
    CARD       = Color3.fromRGB(48,  34,  70),
    STAR_ACT   = Color3.fromRGB(220,180, 255),
    STAR_INACT = Color3.fromRGB(80,  60, 110),
}

local FONT_BOLD   = Enum.Font.GothamBold
local FONT_SEMI   = Enum.Font.GothamSemibold
local FONT_REG    = Enum.Font.Gotham

-- ── GUI ROOT ─────────────────────────────────────────────────
local ScreenGui
if syn and syn.protect_gui then
    ScreenGui = Instance.new("ScreenGui")
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = gethui()
else
    local ok = pcall(function()
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end
ScreenGui.Name          = "CinexHub_Kuromi"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn  = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder  = 1000

-- ── HELPERS ──────────────────────────────────────────────────
local function New(class, props, parent)
    local i = Instance.new(class)
    for k,v in pairs(props or {}) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function Corner(parent, r)
    return New("UICorner", {CornerRadius=UDim.new(0, r or 8)}, parent)
end

local function Stroke(parent, thick, col)
    return New("UIStroke", {
        Thickness=thick or 1,
        Color=col or C.BORDER,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    }, parent)
end

local function Pad(parent, t,b,l,r)
    return New("UIPadding",{
        PaddingTop=UDim.new(0,t or 6),
        PaddingBottom=UDim.new(0,b or 6),
        PaddingLeft=UDim.new(0,l or 8),
        PaddingRight=UDim.new(0,r or 8),
    }, parent)
end

local function Lbl(parent, text, size, col, xalign, font)
    return New("TextLabel",{
        BackgroundTransparency=1,
        Text=text, Font=font or FONT_REG,
        TextSize=size or 13, TextColor3=col or C.TEXT,
        TextXAlignment=xalign or Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        Size=UDim2.fromScale(1,1),
    }, parent)
end

local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ── MAIN FRAME ───────────────────────────────────────────────
local VP      = ScreenGui.AbsoluteSize  -- may be 0,0 before render; use camera
local Camera  = workspace.CurrentCamera
local function vp() return Camera.ViewportSize end

local MAIN_W  = math.floor(vp().X * 0.90)
local MAIN_H  = math.floor(vp().Y * 0.86)
local SIDE_W  = math.max(180, math.floor(MAIN_W * 0.195))
local TOP_H   = 54
local CONT_H  = MAIN_H - TOP_H

local Main = New("Frame",{
    Name="Main",
    Size=UDim2.fromOffset(MAIN_W, MAIN_H),
    Position=UDim2.fromScale(0.5, 0.5),
    AnchorPoint=Vector2.new(0.5, 0.5),
    BackgroundColor3=C.BG,
    BorderSizePixel=0,
}, ScreenGui)
Corner(Main, 12)
Stroke(Main, 1.5, C.BORDER)

-- drop shadow
New("Frame",{
    Size=UDim2.new(1,24,1,18),
    Position=UDim2.fromOffset(-12, 10),
    BackgroundColor3=C.BLACK,
    BackgroundTransparency=0.52,
    ZIndex=Main.ZIndex-1,
    BorderSizePixel=0,
}, ScreenGui)

-- ── DRAG ─────────────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=target.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - ds
            target.Position = UDim2.fromOffset(sp.X+d.X, sp.Y+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
end

-- ── TOP BAR ──────────────────────────────────────────────────
local Topbar = New("Frame",{
    Name="Topbar",
    Size=UDim2.new(1,0,0,TOP_H),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0,
    ZIndex=3,
}, Main)
Corner(Topbar, 12)
New("Frame",{  -- flatten bottom corners
    Size=UDim2.new(1,0,0.5,0),
    Position=UDim2.fromScale(0,0.5),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=3,
}, Topbar)
Stroke(Topbar, 1, C.BORDER)
MakeDraggable(Topbar, Main)

-- Logo
local LogoBox = New("Frame",{
    Size=UDim2.fromOffset(158, 42),
    Position=UDim2.fromOffset(10, 6),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=4,
}, Topbar)
Corner(LogoBox, 8); Stroke(LogoBox, 1, C.BORDER)

local LogoCirc = New("Frame",{
    Size=UDim2.fromOffset(32,32),
    Position=UDim2.fromOffset(5,5),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=5,
}, LogoBox)
Corner(LogoCirc, 16)
local LogoIco = Lbl(LogoCirc,"✦",17,C.ACCENT2,Enum.TextXAlignment.Center,FONT_BOLD)
LogoIco.ZIndex = 6

local LogoTitle = New("TextLabel",{
    Size=UDim2.fromOffset(112,20),
    Position=UDim2.fromOffset(42,3),
    BackgroundTransparency=1,
    Text="CINEX HUB", Font=FONT_BOLD,
    TextSize=12, TextColor3=C.TEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5,
}, LogoBox)
New("TextLabel",{
    Size=UDim2.fromOffset(112,16),
    Position=UDim2.fromOffset(42,22),
    BackgroundTransparency=1,
    Text="kuromi night edition", Font=FONT_REG,
    TextSize=9, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5,
}, LogoBox)

-- Search
local SearchW = math.floor(MAIN_W * 0.38)
local Search = New("Frame",{
    Size=UDim2.fromOffset(SearchW, 34),
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=4,
}, Topbar)
Corner(Search, 8); Stroke(Search, 1, C.BORDER)

Lbl(New("Frame",{
    Size=UDim2.fromOffset(28,34),
    Position=UDim2.fromOffset(4,0),
    BackgroundTransparency=1, ZIndex=5,
}, Search), "🔍", 13, C.SUBTEXT, Enum.TextXAlignment.Center)

local SearchBox = New("TextBox",{
    Size=UDim2.new(1,-86,1,0),
    Position=UDim2.fromOffset(30,0),
    BackgroundTransparency=1,
    PlaceholderText="Search settings, e.g. silent aim, FOV...",
    PlaceholderColor3=C.SUBTEXT,
    Text="", TextColor3=C.TEXT,
    Font=FONT_REG, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false, ZIndex=5,
}, Search)

New("TextLabel",{
    Size=UDim2.fromOffset(42,34),
    Position=UDim2.new(1,-76,0,0),
    BackgroundTransparency=1,
    Text="ctrl /", Font=FONT_REG,
    TextSize=10, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Right,
    ZIndex=5,
}, Search)

local SX = New("TextButton",{
    Size=UDim2.fromOffset(24,24),
    AnchorPoint=Vector2.new(0,0.5),
    Position=UDim2.new(1,-28,0.5,0),
    BackgroundColor3=C.PANELB,
    Text="✕", TextColor3=C.TEXT,
    Font=FONT_BOLD, TextSize=10,
    BorderSizePixel=0, ZIndex=5,
}, Search)
Corner(SX, 5)
SX.MouseButton1Click:Connect(function() SearchBox.Text="" end)

-- Keybind area
local KA = New("Frame",{
    Size=UDim2.fromOffset(130,42),
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-10,0.5,0),
    BackgroundTransparency=1,
    BorderSizePixel=0, ZIndex=4,
}, Topbar)

local KIcon = New("Frame",{
    Size=UDim2.fromOffset(32,32),
    BackgroundColor3=C.DIM,
    Position=UDim2.fromOffset(0,5),
    BorderSizePixel=0, ZIndex=5,
}, KA)
Corner(KIcon, 16)
Lbl(KIcon,"⌨",15,C.ACCENT,Enum.TextXAlignment.Center,FONT_BOLD).ZIndex=6

local KBtn = New("Frame",{
    Size=UDim2.fromOffset(78,28),
    Position=UDim2.fromOffset(36,7),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=5,
}, KA)
Corner(KBtn, 6); Stroke(KBtn, 1, C.BORDER)
Lbl(KBtn,"R SHIFT",11,C.TEXT,Enum.TextXAlignment.Center,FONT_SEMI).ZIndex=6

local KX = New("TextButton",{
    Size=UDim2.fromOffset(24,24),
    Position=UDim2.fromOffset(116,9),
    BackgroundColor3=C.PANELB,
    Text="✕", TextColor3=C.TEXT,
    Font=FONT_BOLD, TextSize=10,
    BorderSizePixel=0, ZIndex=5,
}, KA)
Corner(KX, 5)
KX.MouseButton1Click:Connect(function() Main.Visible=false end)

-- ── SIDEBAR ───────────────────────────────────────────────────
local Sidebar = New("Frame",{
    Name="Sidebar",
    Size=UDim2.fromOffset(SIDE_W, CONT_H),
    Position=UDim2.fromOffset(0, TOP_H),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=2,
}, Main)
New("Frame",{
    Size=UDim2.new(0,2,1,0),
    Position=UDim2.new(1,-2,0,0),
    BackgroundColor3=C.BORDER,
    BorderSizePixel=0, ZIndex=3,
}, Sidebar)
New("UICorner",{CornerRadius=UDim.new(0,12)}, Sidebar)
-- flatten right corners
New("Frame",{
    Size=UDim2.new(0.5,0,1,0),
    Position=UDim2.fromScale(0.5,0),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=2,
}, Sidebar)

local NavList = New("Frame",{
    Name="NavList",
    Size=UDim2.new(1,0,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    Position=UDim2.fromOffset(0,10),
    BackgroundTransparency=1,
    ZIndex=3,
}, Sidebar)
New("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,2),
}, NavList)

-- ── CONTENT AREA ─────────────────────────────────────────────
local Content = New("Frame",{
    Name="Content",
    Size=UDim2.new(1,-SIDE_W,0,CONT_H),
    Position=UDim2.fromOffset(SIDE_W, TOP_H),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=2,
}, Main)
-- flatten left corners
New("Frame",{
    Size=UDim2.new(0.12,0,1,0),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=2,
}, Content)
Corner(Content, 12)

-- Content header
local Header = New("Frame",{
    Name="Header",
    Size=UDim2.new(1,0,0,68),
    BackgroundTransparency=1,
    ZIndex=3,
}, Content)
Pad(Header,12,0,16,16)

local CatIcon = New("Frame",{
    Size=UDim2.fromOffset(36,36),
    Position=UDim2.fromOffset(16,16),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=4,
}, Content)
Corner(CatIcon, 18)
local CatIco = Lbl(CatIcon,"◈",18,C.ACCENT,Enum.TextXAlignment.Center,FONT_BOLD)
CatIco.ZIndex=5

local CatTitle = New("TextLabel",{
    Size=UDim2.fromOffset(300,28),
    Position=UDim2.fromOffset(62,12),
    BackgroundTransparency=1,
    Text="VISUALS", Font=FONT_BOLD,
    TextSize=20, TextColor3=C.TEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=4,
}, Content)
New("TextLabel",{
    Size=UDim2.fromOffset(420,16),
    Position=UDim2.fromOffset(62,38),
    BackgroundTransparency=1,
    Text="Everything in one place. Search, configure, and save your changes.",
    Font=FONT_REG, TextSize=11, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=4,
}, Content)

local FavBtn = New("TextButton",{
    Size=UDim2.fromOffset(160,30),
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-16,0,16),
    BackgroundColor3=C.PANELB,
    Text=" ★  Favorite this category",
    Font=FONT_SEMI, TextSize=12, TextColor3=C.ACCENT2,
    BorderSizePixel=0, ZIndex=4,
}, Content)
Corner(FavBtn, 8); Stroke(FavBtn, 1, C.BORDER)
FavBtn.MouseEnter:Connect(function() tw(FavBtn,0.15,{BackgroundColor3=C.PANELC}) end)
FavBtn.MouseLeave:Connect(function() tw(FavBtn,0.15,{BackgroundColor3=C.PANELB}) end)

-- separator
New("Frame",{
    Size=UDim2.new(1,-32,0,1),
    Position=UDim2.fromOffset(16,66),
    BackgroundColor3=C.BORDER,
    BorderSizePixel=0, ZIndex=3,
}, Content)

-- ── COMPONENT FACTORY ─────────────────────────────────────────

-- Star button
local function MakeStar(parent)
    local starred = false
    local btn = New("TextButton",{
        Size=UDim2.fromOffset(20,20),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-4,0.5,0),
        BackgroundTransparency=1,
        Text="☆", Font=FONT_BOLD,
        TextSize=14, TextColor3=C.STAR_INACT,
        BorderSizePixel=0, ZIndex=6,
    }, parent)
    btn.MouseButton1Click:Connect(function()
        starred = not starred
        btn.Text      = starred and "★" or "☆"
        btn.TextColor3 = starred and C.STAR_ACT or C.STAR_INACT
    end)
    return btn
end

-- Row container
local function MakeRow(parent, h)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,h or 44),
        BackgroundColor3=C.PANEL,
        BorderSizePixel=0, ZIndex=4,
    }, parent)
    Corner(row, 7); Stroke(row, 1, C.BORDER)
    return row
end

-- Toggle
local function MakeToggle(parent, labelText, default)
    local row = MakeRow(parent, 42)
    MakeStar(row)

    Lbl(New("Frame",{
        Size=UDim2.new(1,-64,1,0),
        Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=5,
    }, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)

    local state = default ~= nil and default or false

    local track = New("Frame",{
        Size=UDim2.fromOffset(42,22),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=state and C.TOG_ON or C.TOG_OFF,
        BorderSizePixel=0, ZIndex=5,
    }, row)
    Corner(track, 11)

    local knob = New("Frame",{
        Size=UDim2.fromOffset(18,18),
        Position=state and UDim2.fromOffset(22,2) or UDim2.fromOffset(2,2),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0, ZIndex=6,
    }, track)
    Corner(knob, 9)

    local btn = New("TextButton",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, Text="",
        ZIndex=7,
    }, track)

    btn.MouseButton1Click:Connect(function()
        state = not state
        tw(track,0.18,{BackgroundColor3=state and C.TOG_ON or C.TOG_OFF})
        tw(knob,0.18,{Position=state and UDim2.fromOffset(22,2) or UDim2.fromOffset(2,2)})
    end)

    return row, function() return state end
end

-- Slider
local function MakeSlider(parent, labelText, minV, maxV, defV)
    local row = MakeRow(parent, 52)
    MakeStar(row)

    Lbl(New("Frame",{
        Size=UDim2.new(1,-48,0,20),
        Position=UDim2.fromOffset(10,6),
        BackgroundTransparency=1, ZIndex=5,
    }, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)

    local valLbl = New("TextLabel",{
        Size=UDim2.fromOffset(32,20),
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-6,0,6),
        BackgroundTransparency=1,
        Text=tostring(defV), Font=FONT_BOLD,
        TextSize=12, TextColor3=C.ACCENT2,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=5,
    }, row)

    local track = New("Frame",{
        Size=UDim2.new(1,-20,0,6),
        Position=UDim2.fromOffset(10,32),
        BackgroundColor3=C.TOG_OFF,
        BorderSizePixel=0, ZIndex=5,
    }, row)
    Corner(track, 3)

    local pct = (defV - minV) / (maxV - minV)
    local fill = New("Frame",{
        Size=UDim2.fromScale(pct,1),
        BackgroundColor3=C.ACCENT,
        BorderSizePixel=0, ZIndex=6,
    }, track)
    Corner(fill, 3)

    local knob = New("Frame",{
        Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(pct,0,0.5,0),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0, ZIndex=7,
    }, track)
    Corner(knob, 7)
    Stroke(knob, 1.5, C.ACCENT)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel*(maxV-minV) + 0.5)
        rel = (val-minV)/(maxV-minV)
        fill.Size  = UDim2.fromScale(rel,1)
        knob.Position = UDim2.new(rel,0,0.5,0)
        valLbl.Text = tostring(val)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging then
            local x = i.UserInputType==Enum.UserInputType.Touch
                and i.Position.X or i.Position.X
            update(x)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            update(i.Position.X)
        end
    end)

    return row
end

-- TextButton/Pill (e.g. "UI", "None", "Color")
local function MakePill(parent, labelText, pillText)
    local row = MakeRow(parent, 42)
    MakeStar(row)

    Lbl(New("Frame",{
        Size=UDim2.new(1,-90,1,0),
        Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=5,
    }, row), labelText, 12, C.TEXT, Enum.TextXAlignment.Left, FONT_SEMI)

    local pill = New("TextButton",{
        Size=UDim2.fromOffset(68,26),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=C.PANELB,
        Text=pillText, Font=FONT_SEMI,
        TextSize=12, TextColor3=C.TEXT,
        BorderSizePixel=0, ZIndex=5,
    }, row)
    Corner(pill, 6); Stroke(pill, 1, C.BORDER)
    pill.MouseEnter:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PANELC}) end)
    pill.MouseLeave:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PANELB}) end)

    return row
end

-- Section header
local function MakeSectionHeader(parent, text)
    local h = New("Frame",{
        Size=UDim2.new(1,0,0,28),
        BackgroundColor3=C.PANELB,
        BorderSizePixel=0, ZIndex=4,
    }, parent)
    Corner(h, 6)
    local ico = New("Frame",{
        Size=UDim2.fromOffset(22,22),
        Position=UDim2.fromOffset(6,3),
        BackgroundColor3=C.DIM,
        BorderSizePixel=0, ZIndex=5,
    }, h)
    Corner(ico, 11)
    Lbl(ico,"◈",11,C.ACCENT,Enum.TextXAlignment.Center,FONT_BOLD).ZIndex=6

    local cap = New("TextButton",{
        Size=UDim2.new(1,-36,1,0),
        Position=UDim2.fromOffset(32,0),
        BackgroundTransparency=1,
        Text=text, Font=FONT_BOLD,
        TextSize=13, TextColor3=C.TEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0, ZIndex=5,
    }, h)

    local arrow = New("TextLabel",{
        Size=UDim2.fromOffset(20,28),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,0,0.5,0),
        BackgroundTransparency=1,
        Text="∧", Font=FONT_BOLD,
        TextSize=12, TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Center,
        ZIndex=5,
    }, h)
    Stroke(h, 1, C.BORDER)
    return h, arrow
end

-- Sub-section divider
local function MakeDivider(parent, text)
    local d = New("Frame",{
        Size=UDim2.new(1,0,0,22),
        BackgroundTransparency=1, ZIndex=4,
    }, parent)
    New("TextLabel",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Text="--- "..text.." ---",
        Font=FONT_SEMI, TextSize=10,
        TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,
    }, d)
    return d
end

-- ── TWO-COLUMN SCROLL AREA ────────────────────────────────────
local ColArea = New("Frame",{
    Name="ColArea",
    Size=UDim2.new(1,-16,1,-80),
    Position=UDim2.fromOffset(8,72),
    BackgroundTransparency=1,
    ZIndex=3,
}, Content)

local COL_GAP = 8
local COL_W   = math.floor((ColArea.AbsoluteSize.X > 0
    and ColArea.AbsoluteSize.X or (MAIN_W - SIDE_W - 32)) / 2 - COL_GAP)

-- Column 1
local Col1 = New("ScrollingFrame",{
    Name="Col1",
    Size=UDim2.new(0.5,-COL_GAP/2,1,0),
    BackgroundTransparency=1,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=3,
}, ColArea)
New("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,6),
}, Col1)

-- Column 2
local Col2 = New("ScrollingFrame",{
    Name="Col2",
    Size=UDim2.new(0.5,-COL_GAP/2,1,0),
    Position=UDim2.new(0.5,COL_GAP/2,0,0),
    BackgroundTransparency=1,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=3,
}, ColArea)
New("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,6),
}, Col2)

-- ── POPULATE COL 1: ESP / INVENTORY ──────────────────────────
local EspHeader = MakeSectionHeader(Col1, "ESP / INVENTORY")

MakeDivider(Col1, "PLAYER ESP")
MakePill(Col1, "esp font", "UI")
MakeSlider(Col1, "esp font size", 6, 30, 13)
MakeToggle(Col1, "infinite range", false)
MakeToggle(Col1, "enable esp", true)
MakePill(Col1, "ESP enable bind", "None")
MakeToggle(Col1, "box esp", true)
MakePill(Col1, "box color", "Color")

-- ── POPULATE COL 2: CROSSHAIR ─────────────────────────────────
MakePill(Col2, "crosshair font", "UI")
MakeToggle(Col2, "enable crosshair", true)
MakePill(Col2, "crosshair color", "Color")
MakeToggle(Col2, "crosshair on target", true)
MakeSlider(Col2, "speed", 1, 10, 3)
MakeSlider(Col2, "radius", 5, 60, 25)
MakeSlider(Col2, "thickness", 1, 6, 1.5)
MakeSlider(Col2, "length", 5, 50, 20)

-- ── SIDEBAR NAV ───────────────────────────────────────────────
local TABS = {
    {icon="⚔",  label="Combat"},
    {icon="◈",  label="Visuals"},
    {icon="⊞",  label="Misc"},
    {icon="⚙",  label="Config"},
    {icon="▷",  label="Quick start"},
    {icon="★",  label="Favorites"},
    {icon="⊡",  label="Creator Presets"},
    {icon="⌨",  label="Keybinds"},
}

local activeTab = "Visuals"
local tabBtns   = {}

local function setActiveTab(name)
    activeTab = name
    for _, t in pairs(tabBtns) do
        local isActive = t.label == name
        tw(t.bg, 0.15, {BackgroundColor3 = isActive and C.ACTIVE_BG or Color3.fromRGB(0,0,0)})
        t.bg.BackgroundTransparency = isActive and 0 or 1
        t.lbl.TextColor3 = isActive and C.TEXT or C.SUBTEXT
        t.bar.Visible    = isActive
    end
end

for i, tab in ipairs(TABS) do
    local isActive = tab.label == activeTab
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,38),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        LayoutOrder=i,
        ZIndex=4,
    }, NavList)

    local bar = New("Frame",{
        Size=UDim2.fromOffset(3, 22),
        Position=UDim2.fromOffset(0, 8),
        BackgroundColor3=C.ACCENT,
        BorderSizePixel=0,
        Visible=isActive, ZIndex=5,
    }, row)
    Corner(bar, 2)

    local bg = New("TextButton",{
        Size=UDim2.new(1,-4,0,34),
        Position=UDim2.fromOffset(4,2),
        BackgroundColor3=isActive and C.ACTIVE_BG or Color3.fromRGB(0,0,0),
        BackgroundTransparency=isActive and 0 or 1,
        Text="", BorderSizePixel=0, ZIndex=4,
    }, row)
    Corner(bg, 7)

    local icoBox = New("Frame",{
        Size=UDim2.fromOffset(24,24),
        Position=UDim2.fromOffset(8,5),
        BackgroundColor3=isActive and C.DIM or C.SIDEBAR,
        BorderSizePixel=0, ZIndex=5,
    }, bg)
    Corner(icoBox, 12)
    Lbl(icoBox, tab.icon, 12, isActive and C.ACCENT or C.SUBTEXT, Enum.TextXAlignment.Center, FONT_BOLD).ZIndex=6

    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-48,1,0),
        Position=UDim2.fromOffset(36,0),
        BackgroundTransparency=1,
        Text=tab.label, Font=FONT_SEMI,
        TextSize=12,
        TextColor3=isActive and C.TEXT or C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=5,
    }, bg)

    New("TextLabel",{
        Size=UDim2.fromOffset(12,24),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-6,0.5,0),
        BackgroundTransparency=1,
        Text=">", Font=FONT_BOLD,
        TextSize=11, TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=5,
    }, bg)

    tabBtns[i] = {bg=bg, bar=bar, lbl=lbl, label=tab.label, ico=icoBox}

    bg.MouseEnter:Connect(function()
        if tab.label ~= activeTab then
            tw(bg,0.12,{BackgroundColor3=C.PANELB})
            bg.BackgroundTransparency=0
        end
    end)
    bg.MouseLeave:Connect(function()
        if tab.label ~= activeTab then
            tw(bg,0.12,{BackgroundColor3=Color3.fromRGB(0,0,0)})
            bg.BackgroundTransparency=1
        end
    end)
    bg.MouseButton1Click:Connect(function()
        setActiveTab(tab.label)
        -- update content title
        CatTitle.Text = tab.label:upper()
    end)
end

-- ── SIDEBAR BOTTOM CARD ───────────────────────────────────────
local CardH = 120
local Card = New("Frame",{
    Name="KuroCard",
    Size=UDim2.new(1,-12,0,CardH),
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,6,1,-10),
    BackgroundColor3=C.CARD,
    BorderSizePixel=0, ZIndex=4,
}, Sidebar)
Corner(Card, 10); Stroke(Card, 1, C.BORDER)

-- gradient stripe at top of card
New("Frame",{
    Size=UDim2.new(1,0,0,3),
    BackgroundColor3=C.ACCENT,
    BorderSizePixel=0, ZIndex=5,
}, Card)
Corner(New("Frame",{
    Size=UDim2.new(1,0,0,3),
    BackgroundColor3=C.ACCENT,
    BorderSizePixel=0, ZIndex=4,
}, Card), 2)

-- kuromi art placeholder (purple circle with ♥)
local KuroArt = New("Frame",{
    Size=UDim2.fromOffset(60,60),
    Position=UDim2.fromOffset(8, 10),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=5,
}, Card)
Corner(KuroArt, 10); Stroke(KuroArt, 1, C.BORDER)

Lbl(KuroArt,"♥",26,C.ACCENT2,Enum.TextXAlignment.Center,FONT_BOLD).TextYAlignment=Enum.TextYAlignment.Center

-- "kuromi night edition" chip
New("TextLabel",{
    Size=UDim2.fromOffset(SIDE_W-24,12),
    Position=UDim2.fromOffset(6,4),
    BackgroundTransparency=1,
    Text="✦ kuromi night edition",
    Font=FONT_SEMI, TextSize=9, TextColor3=C.ACCENT2,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=6,
}, Card)

New("TextLabel",{
    Size=UDim2.fromOffset(SIDE_W-82,16),
    Position=UDim2.fromOffset(76, 14),
    BackgroundTransparency=1,
    Text="CINEX HUB / KUROMI...",
    Font=FONT_BOLD, TextSize=11, TextColor3=C.TEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=6,
}, Card)

New("TextLabel",{
    Size=UDim2.fromOffset(SIDE_W-82,14),
    Position=UDim2.fromOffset(76, 30),
    BackgroundTransparency=1,
    Text="KUROMI MOONLIGHT  ·  V2.6.20",
    Font=FONT_REG, TextSize=9, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=6,
}, Card)

local BegBtn = New("TextButton",{
    Size=UDim2.new(1,-16,0,26),
    Position=UDim2.fromOffset(8, 84),
    BackgroundColor3=C.PANELB,
    Text="Switch to Beginner",
    Font=FONT_SEMI, TextSize=12, TextColor3=C.TEXT,
    BorderSizePixel=0, ZIndex=5,
}, Card)
Corner(BegBtn, 7); Stroke(BegBtn, 1, C.BORDER)
BegBtn.MouseEnter:Connect(function() tw(BegBtn,0.13,{BackgroundColor3=C.PANELC}) end)
BegBtn.MouseLeave:Connect(function() tw(BegBtn,0.13,{BackgroundColor3=C.PANELB}) end)

-- footer note
New("TextLabel",{
    Size=UDim2.new(1,-16,0,14),
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,8,1,-4),
    BackgroundTransparency=1,
    Text="All settings are saved using their original config IDs.",
    Font=FONT_REG, TextSize=9, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=3,
}, Content)

-- ── KEYBIND TOGGLE (R SHIFT) ──────────────────────────────────
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ── READY ─────────────────────────────────────────────────────
print("[CinexHub] Kuromi Night Edition loaded — R SHIFT to toggle")
