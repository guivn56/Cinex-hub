-- ============================================================
--  CINEX HUB | KUROMI NIGHT EDITION  v2.6.20
--  PC  : Synapse X / Wave / Swift  (R SHIFT toggle)
--  MOBILE: Delta / Codex / Fluxus  (botão flutuante sempre visível)
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")

-- ── DETECT MOBILE ────────────────────────────────────────────
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ── THEME ─────────────────────────────────────────────────────
local C = {
    BG         = Color3.fromRGB(22,  16,  34),
    SIDEBAR    = Color3.fromRGB(38,  28,  54),
    PANEL      = Color3.fromRGB(32,  23,  48),
    PANELB     = Color3.fromRGB(52,  40,  74),
    PANELC     = Color3.fromRGB(62,  48,  88),
    ACCENT     = Color3.fromRGB(175, 95, 255),
    ACCENT2    = Color3.fromRGB(210,145, 255),
    DIM        = Color3.fromRGB(100, 55, 168),
    TOG_OFF    = Color3.fromRGB(65,  50,  90),
    TOG_ON     = Color3.fromRGB(155, 75, 240),
    TEXT       = Color3.fromRGB(238,232,250),
    SUBTEXT    = Color3.fromRGB(150,133,182),
    BORDER     = Color3.fromRGB(82,  56, 124),
    ACTIVE_BG  = Color3.fromRGB(58,  42,  82),
    BLACK      = Color3.fromRGB(10,   6,  18),
    CARD       = Color3.fromRGB(45,  32,  66),
    STAR_ON    = Color3.fromRGB(220,180, 255),
    STAR_OFF   = Color3.fromRGB(75,  55, 105),
    SEP        = Color3.fromRGB(70,  50, 100),
    GREEN      = Color3.fromRGB(80, 220, 120),
}

local FB = Enum.Font.GothamBold
local FS = Enum.Font.GothamSemibold
local FR = Enum.Font.Gotham

-- ── GUI ROOT ──────────────────────────────────────────────────
local SG
local function tryParent(fn) local ok,r = pcall(fn); return ok and r or nil end

if syn and syn.protect_gui then
    SG = Instance.new("ScreenGui")
    syn.protect_gui(SG)
    SG.Parent = game:GetService("CoreGui")
elseif gethui then
    SG = Instance.new("ScreenGui")
    SG.Parent = gethui()
elseif tryParent(function() return game:GetService("CoreGui") end) then
    SG = Instance.new("ScreenGui")
    SG.Parent = game:GetService("CoreGui")
else
    SG = Instance.new("ScreenGui")
    SG.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

SG.Name             = "CinexHub"
SG.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
SG.ResetOnSpawn     = false
SG.IgnoreGuiInset   = true
SG.DisplayOrder     = 1000

-- ── HELPERS ───────────────────────────────────────────────────
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end

local function Corner(p,r)
    return New("UICorner",{CornerRadius=UDim.new(0,r or 8)},p)
end

local function Stroke(p,t,col)
    return New("UIStroke",{
        Thickness=t or 1, Color=col or C.BORDER,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    },p)
end

local function Pad(p,t,b,l,r)
    return New("UIPadding",{
        PaddingTop=UDim.new(0,t or 6), PaddingBottom=UDim.new(0,b or 6),
        PaddingLeft=UDim.new(0,l or 8), PaddingRight=UDim.new(0,r or 8),
    },p)
end

local function Tbl(p, txt, sz, col, xa, font, ya)
    local l = New("TextLabel",{
        BackgroundTransparency=1, Text=txt,
        Font=font or FR, TextSize=sz or 13,
        TextColor3=col or C.TEXT,
        TextXAlignment=xa or Enum.TextXAlignment.Left,
        TextYAlignment=ya or Enum.TextYAlignment.Center,
        TextWrapped=true, Size=UDim2.fromScale(1,1),
    },p)
    return l
end

local function tw(o,t,props)
    TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

-- ── VIEWPORT ──────────────────────────────────────────────────
local CAM   = workspace.CurrentCamera
local function VP() return CAM.ViewportSize end

-- ── SIZES ─────────────────────────────────────────────────────
local function calcSizes()
    local v    = VP()
    local W    = math.floor(v.X * 0.90)
    local H    = math.floor(v.Y * 0.86)
    local SIDE = math.max(160, math.floor(W * 0.20))
    local TOP  = 54
    return W, H, SIDE, TOP
end

local MAIN_W, MAIN_H, SIDE_W, TOP_H = calcSizes()

-- ── MAIN FRAME ────────────────────────────────────────────────
local Main = New("Frame",{
    Name="Main",
    Size=UDim2.fromOffset(MAIN_W, MAIN_H),
    Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=C.BG,
    BorderSizePixel=0,
},SG)
Corner(Main,12); Stroke(Main,1.5,C.BORDER)

-- shadow
New("Frame",{
    Size=UDim2.new(1,20,1,16),
    Position=UDim2.fromOffset(-10,8),
    BackgroundColor3=C.BLACK,
    BackgroundTransparency=0.50,
    ZIndex=Main.ZIndex-1,
    BorderSizePixel=0,
},SG)

-- ── DRAG ──────────────────────────────────────────────────────
local function MakeDraggable(handle, target)
    local dragging, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds = i.Position
            sp = target.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = i.Position - ds
            target.Position = UDim2.fromOffset(sp.X+d.X, sp.Y+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ── MOBILE TOGGLE BUTTON (sempre visível) ────────────────────
local ToggleBtn = New("TextButton",{
    Name="CinexToggle",
    Size=UDim2.fromOffset(48,48),
    Position=UDim2.new(1,-58, 1,-68),
    BackgroundColor3=C.DIM,
    Text="✦", TextColor3=C.ACCENT2,
    Font=FB, TextSize=22,
    BorderSizePixel=0,
    ZIndex=2000,
},SG)
Corner(ToggleBtn,24)
Stroke(ToggleBtn,1.5,C.ACCENT)

-- drag the toggle button itself so user can reposition it
local function DragBtn(btn)
    local d,ds,sp = false,nil,nil
    local moved = false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            d=true; ds=i.Position; sp=btn.AbsolutePosition; moved=false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local delta = i.Position-ds
            if delta.Magnitude > 4 then
                moved=true
                btn.Position = UDim2.fromOffset(sp.X+delta.X, sp.Y+delta.Y)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            d=false
            if not moved then
                Main.Visible = not Main.Visible
            end
        end
    end)
end
DragBtn(ToggleBtn)

-- PC keybind (R SHIFT)
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ── TOP BAR ───────────────────────────────────────────────────
local Topbar = New("Frame",{
    Size=UDim2.new(1,0,0,TOP_H),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=4,
},Main)
Corner(Topbar,12)
New("Frame",{  -- flatten bottom
    Size=UDim2.new(1,0,0.5,0),
    Position=UDim2.fromScale(0,0.5),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=4,
},Topbar)
Stroke(Topbar,1,C.BORDER)
MakeDraggable(Topbar, Main)

-- Logo box
local LogoBox = New("Frame",{
    Size=UDim2.fromOffset(160,42),
    Position=UDim2.fromOffset(10,6),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=5,
},Topbar)
Corner(LogoBox,8); Stroke(LogoBox,1,C.BORDER)

local LogoCirc = New("Frame",{
    Size=UDim2.fromOffset(32,32),
    Position=UDim2.fromOffset(5,5),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=6,
},LogoBox)
Corner(LogoCirc,16)
Tbl(LogoCirc,"✦",17,C.ACCENT2,Enum.TextXAlignment.Center,FB).ZIndex=7

Tbl(New("Frame",{
    Size=UDim2.fromOffset(114,20),
    Position=UDim2.fromOffset(42,3),
    BackgroundTransparency=1, ZIndex=6,
},LogoBox),"CINEX HUB",12,C.TEXT,Enum.TextXAlignment.Left,FB)

Tbl(New("Frame",{
    Size=UDim2.fromOffset(114,16),
    Position=UDim2.fromOffset(42,22),
    BackgroundTransparency=1, ZIndex=6,
},LogoBox),"kuromi night edition",9,C.SUBTEXT,Enum.TextXAlignment.Left,FR)

-- Search bar
local SW = math.max(160, math.floor((MAIN_W-SIDE_W)*0.42))
local Search = New("Frame",{
    Size=UDim2.fromOffset(SW,34),
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=5,
},Topbar)
Corner(Search,8); Stroke(Search,1,C.BORDER)

Tbl(New("Frame",{
    Size=UDim2.fromOffset(28,34),
    Position=UDim2.fromOffset(4,0),
    BackgroundTransparency=1, ZIndex=6,
},Search),"🔍",13,C.SUBTEXT,Enum.TextXAlignment.Center,FR)

local SearchBox = New("TextBox",{
    Size=UDim2.new(1,-84,1,0),
    Position=UDim2.fromOffset(30,0),
    BackgroundTransparency=1,
    PlaceholderText="Search settings, e.g. silent aim, FOV...",
    PlaceholderColor3=C.SUBTEXT,
    Text="", TextColor3=C.TEXT,
    Font=FR, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false, ZIndex=6,
},Search)

Tbl(New("Frame",{
    Size=UDim2.fromOffset(38,34),
    Position=UDim2.new(1,-72,0,0),
    BackgroundTransparency=1, ZIndex=6,
},Search),"ctrl /",10,C.SUBTEXT,Enum.TextXAlignment.Right,FR)

local SX = New("TextButton",{
    Size=UDim2.fromOffset(24,24),
    AnchorPoint=Vector2.new(0,0.5),
    Position=UDim2.new(1,-28,0.5,0),
    BackgroundColor3=C.PANELB,
    Text="✕", TextColor3=C.TEXT,
    Font=FB, TextSize=10,
    BorderSizePixel=0, ZIndex=6,
},Search)
Corner(SX,5)
SX.MouseButton1Click:Connect(function() SearchBox.Text="" end)

-- Keybind area
local KA = New("Frame",{
    Size=UDim2.fromOffset(126,42),
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-10,0.5,0),
    BackgroundTransparency=1,
    BorderSizePixel=0, ZIndex=5,
},Topbar)

local KCirc = New("Frame",{
    Size=UDim2.fromOffset(32,32),
    Position=UDim2.fromOffset(0,5),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=6,
},KA)
Corner(KCirc,16)
Tbl(KCirc,"⌨",14,C.ACCENT,Enum.TextXAlignment.Center,FB).ZIndex=7

local KBox = New("Frame",{
    Size=UDim2.fromOffset(72,28),
    Position=UDim2.fromOffset(36,7),
    BackgroundColor3=C.PANEL,
    BorderSizePixel=0, ZIndex=6,
},KA)
Corner(KBox,6); Stroke(KBox,1,C.BORDER)
Tbl(KBox,"R SHIFT",11,C.TEXT,Enum.TextXAlignment.Center,FS).ZIndex=7

local CloseBtn = New("TextButton",{
    Size=UDim2.fromOffset(24,24),
    Position=UDim2.fromOffset(112,9),
    BackgroundColor3=C.PANELB,
    Text="✕", TextColor3=C.TEXT,
    Font=FB, TextSize=10,
    BorderSizePixel=0, ZIndex=6,
},KA)
Corner(CloseBtn,5)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

-- ── SIDEBAR ───────────────────────────────────────────────────
local Sidebar = New("Frame",{
    Name="Sidebar",
    Size=UDim2.fromOffset(SIDE_W, MAIN_H-TOP_H),
    Position=UDim2.fromOffset(0,TOP_H),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=3,
},Main)
Corner(Sidebar,12)
-- flatten right/top corners
New("Frame",{
    Size=UDim2.new(0.5,0,1,0),
    Position=UDim2.fromScale(0.5,0),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=3,
},Sidebar)
New("Frame",{
    Size=UDim2.new(1,0,0,12),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0, ZIndex=3,
},Sidebar)
-- right border line
New("Frame",{
    Size=UDim2.new(0,1,1,0),
    Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.SEP,
    BorderSizePixel=0, ZIndex=4,
},Sidebar)

-- Scrollable nav
local NavScroll = New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-128),
    Position=UDim2.fromOffset(0,8),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=2,
    ScrollBarImageColor3=C.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ZIndex=4,
},Sidebar)
New("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,2),
},NavScroll)

-- ── CONTENT AREA ──────────────────────────────────────────────
local CONT_W = MAIN_W - SIDE_W
local CONT_H = MAIN_H - TOP_H

local Content = New("Frame",{
    Name="Content",
    Size=UDim2.fromOffset(CONT_W, CONT_H),
    Position=UDim2.fromOffset(SIDE_W, TOP_H),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=3,
},Main)
Corner(Content,12)
-- flatten left/top
New("Frame",{
    Size=UDim2.new(0,14,1,0),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=3,
},Content)
New("Frame",{
    Size=UDim2.new(1,0,0,14),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=3,
},Content)

-- Category icon + title
local CatCirc = New("Frame",{
    Size=UDim2.fromOffset(36,36),
    Position=UDim2.fromOffset(14,14),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=5,
},Content)
Corner(CatCirc,18)
Tbl(CatCirc,"◈",18,C.ACCENT,Enum.TextXAlignment.Center,FB).ZIndex=6

local CatTitle = New("TextLabel",{
    Size=UDim2.fromOffset(CONT_W-220,28),
    Position=UDim2.fromOffset(58,12),
    BackgroundTransparency=1,
    Text="VISUALS", Font=FB,
    TextSize=20, TextColor3=C.TEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5,
},Content)

New("TextLabel",{
    Size=UDim2.fromOffset(CONT_W-220,16),
    Position=UDim2.fromOffset(58,38),
    BackgroundTransparency=1,
    Text="Everything in one place. Search, configure, and save your changes.",
    Font=FR, TextSize=11, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5,
},Content)

local FavBtn = New("TextButton",{
    Size=UDim2.fromOffset(170,30),
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-12,0,14),
    BackgroundColor3=C.PANELB,
    Text="  ★  Favorite this category",
    Font=FS, TextSize=12, TextColor3=C.ACCENT2,
    BorderSizePixel=0, ZIndex=5,
},Content)
Corner(FavBtn,8); Stroke(FavBtn,1,C.BORDER)
FavBtn.MouseEnter:Connect(function() tw(FavBtn,0.13,{BackgroundColor3=C.PANELC}) end)
FavBtn.MouseLeave:Connect(function() tw(FavBtn,0.13,{BackgroundColor3=C.PANELB}) end)

-- separator line under header
New("Frame",{
    Size=UDim2.new(1,-24,0,1),
    Position=UDim2.fromOffset(12,62),
    BackgroundColor3=C.SEP,
    BorderSizePixel=0, ZIndex=4,
},Content)

-- footer note
New("TextLabel",{
    Size=UDim2.new(1,-24,0,14),
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,12,1,-4),
    BackgroundTransparency=1,
    Text="All settings are saved using their original config IDs.",
    Font=FR, TextSize=9, TextColor3=C.SUBTEXT,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=4,
},Content)

-- ── COMPONENT FACTORY ─────────────────────────────────────────

local function StarBtn(parent)
    local on = false
    local b = New("TextButton",{
        Size=UDim2.fromOffset(20,20),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-4,0.5,0),
        BackgroundTransparency=1,
        Text="☆", Font=FB,
        TextSize=14, TextColor3=C.STAR_OFF,
        BorderSizePixel=0, ZIndex=7,
    },parent)
    b.MouseButton1Click:Connect(function()
        on=not on
        b.Text      = on and "★" or "☆"
        b.TextColor3 = on and C.STAR_ON or C.STAR_OFF
    end)
    return b
end

local function MakeRow(parent, h)
    local f = New("Frame",{
        Size=UDim2.new(1,-4,0,h or 42),
        BackgroundColor3=C.PANEL,
        BorderSizePixel=0, ZIndex=5,
    },parent)
    Corner(f,7); Stroke(f,1,C.BORDER)
    return f
end

-- Toggle
local function MakeToggle(parent, txt, default)
    local row = MakeRow(parent, 42)
    StarBtn(row)
    local state = (default == true)

    local lf = New("Frame",{
        Size=UDim2.new(1,-68,1,0),
        Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=6,
    },row)
    Tbl(lf, txt, 12, C.TEXT, Enum.TextXAlignment.Left, FS)

    local track = New("Frame",{
        Size=UDim2.fromOffset(44,22),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=state and C.TOG_ON or C.TOG_OFF,
        BorderSizePixel=0, ZIndex=6,
    },row)
    Corner(track,11)

    local knob = New("Frame",{
        Size=UDim2.fromOffset(18,18),
        Position=state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0, ZIndex=7,
    },track)
    Corner(knob,9)

    local hitbox = New("TextButton",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, Text="",
        ZIndex=8,
    },track)
    hitbox.MouseButton1Click:Connect(function()
        state=not state
        tw(track,0.18,{BackgroundColor3=state and C.TOG_ON or C.TOG_OFF})
        tw(knob,0.18,{Position=state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2)})
    end)
    return row, function() return state end
end

-- Slider
local function MakeSlider(parent, txt, minV, maxV, defV)
    local row = MakeRow(parent, 54)
    StarBtn(row)

    local lf = New("Frame",{
        Size=UDim2.new(1,-52,0,20),
        Position=UDim2.fromOffset(10,8),
        BackgroundTransparency=1, ZIndex=6,
    },row)
    Tbl(lf, txt, 12, C.TEXT, Enum.TextXAlignment.Left, FS)

    local valTxt = New("TextLabel",{
        Size=UDim2.fromOffset(36,20),
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-6,0,8),
        BackgroundTransparency=1,
        Text=tostring(defV), Font=FB,
        TextSize=12, TextColor3=C.ACCENT2,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=6,
    },row)

    local track = New("Frame",{
        Size=UDim2.new(1,-22,0,6),
        Position=UDim2.fromOffset(10,36),
        BackgroundColor3=C.TOG_OFF,
        BorderSizePixel=0, ZIndex=6,
    },row)
    Corner(track,3)

    local pct0 = (defV-minV)/(maxV-minV)

    local fill = New("Frame",{
        Size=UDim2.fromScale(pct0,1),
        BackgroundColor3=C.ACCENT,
        BorderSizePixel=0, ZIndex=7,
    },track)
    Corner(fill,3)

    local knob = New("Frame",{
        Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(pct0,0,0.5,0),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0, ZIndex=8,
    },track)
    Corner(knob,7); Stroke(knob,1.5,C.ACCENT)

    local dragging = false
    local function upd(x)
        local abs = track.AbsolutePosition.X
        local sz  = track.AbsoluteSize.X
        local rel = math.clamp((x-abs)/sz,0,1)
        local val = math.floor(minV + rel*(maxV-minV) + 0.5)
        rel = (val-minV)/(maxV-minV)
        fill.Size         = UDim2.fromScale(rel,1)
        knob.Position     = UDim2.new(rel,0,0.5,0)
        valTxt.Text       = tostring(val)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
        end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            upd(i.Position.X)
            dragging=true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType==Enum.UserInputType.MouseMovement or
            i.UserInputType==Enum.UserInputType.Touch
        ) then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)

    return row
end

-- Pill / value button
local function MakePill(parent, txt, pillTxt)
    local row = MakeRow(parent, 42)
    StarBtn(row)

    local lf = New("Frame",{
        Size=UDim2.new(1,-94,1,0),
        Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=6,
    },row)
    Tbl(lf, txt, 12, C.TEXT, Enum.TextXAlignment.Left, FS)

    local pill = New("TextButton",{
        Size=UDim2.fromOffset(72,26),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=C.PANELB,
        Text=pillTxt, Font=FS,
        TextSize=12, TextColor3=C.TEXT,
        BorderSizePixel=0, ZIndex=6,
    },row)
    Corner(pill,6); Stroke(pill,1,C.BORDER)
    pill.MouseEnter:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PANELC}) end)
    pill.MouseLeave:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PANELB}) end)

    return row
end

-- Wide pill (full-width value display like "UI" font selector)
local function MakeWidePill(parent, txt, pillTxt)
    local row = MakeRow(parent, 68)
    StarBtn(row)

    local lf = New("Frame",{
        Size=UDim2.new(1,-28,0,20),
        Position=UDim2.fromOffset(10,8),
        BackgroundTransparency=1, ZIndex=6,
    },row)
    Tbl(lf, txt, 12, C.TEXT, Enum.TextXAlignment.Left, FS)

    local wide = New("TextButton",{
        Size=UDim2.new(1,-20,0,26),
        Position=UDim2.fromOffset(10,34),
        BackgroundColor3=C.PANELB,
        Text=pillTxt, Font=FS,
        TextSize=13, TextColor3=C.TEXT,
        BorderSizePixel=0, ZIndex=6,
    },row)
    Corner(wide,6); Stroke(wide,1,C.BORDER)
    wide.MouseEnter:Connect(function() tw(wide,0.12,{BackgroundColor3=C.PANELC}) end)
    wide.MouseLeave:Connect(function() tw(wide,0.12,{BackgroundColor3=C.PANELB}) end)

    return row
end

-- Section header (collapsible)
local function MakeSectionHeader(parent, txt)
    local open = true
    local hdr = New("Frame",{
        Size=UDim2.new(1,-4,0,30),
        BackgroundColor3=C.PANELB,
        BorderSizePixel=0, ZIndex=5,
    },parent)
    Corner(hdr,8); Stroke(hdr,1,C.BORDER)

    local ic = New("Frame",{
        Size=UDim2.fromOffset(22,22),
        Position=UDim2.fromOffset(6,4),
        BackgroundColor3=C.DIM,
        BorderSizePixel=0, ZIndex=6,
    },hdr)
    Corner(ic,11)
    Tbl(ic,"◈",11,C.ACCENT,Enum.TextXAlignment.Center,FB).ZIndex=7

    local cap = New("TextButton",{
        Size=UDim2.new(1,-38,1,0),
        Position=UDim2.fromOffset(32,0),
        BackgroundTransparency=1,
        Text=txt, Font=FB,
        TextSize=13, TextColor3=C.TEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0, ZIndex=6,
    },hdr)

    local arr = New("TextLabel",{
        Size=UDim2.fromOffset(20,30),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-4,0.5,0),
        BackgroundTransparency=1,
        Text="∧", Font=FB,
        TextSize=12, TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Center,
        ZIndex=6,
    },hdr)

    return hdr, arr, cap, function() return open end,
        function(body)
            cap.MouseButton1Click:Connect(function()
                open=not open
                arr.Text = open and "∧" or "∨"
                body.Visible = open
            end)
        end
end

-- Divider label
local function MakeDivider(parent, txt)
    local f = New("Frame",{
        Size=UDim2.new(1,-4,0,22),
        BackgroundTransparency=1, ZIndex=5,
    },parent)
    local l = New("TextLabel",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Text="--- "..txt.." ---",
        Font=FS, TextSize=10,
        TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6,
    },f)
    return f
end

-- Status indicator row (for keybind / bind section)
local function MakeStatusRow(parent, txt, status)
    local row = MakeRow(parent, 30)
    local lf = New("Frame",{
        Size=UDim2.new(1,-12,1,0),
        Position=UDim2.fromOffset(8,0),
        BackgroundTransparency=1, ZIndex=6,
    },row)
    Tbl(lf, txt, 11, C.SUBTEXT, Enum.TextXAlignment.Left, FS)
    if status then
        Tbl(New("Frame",{
            Size=UDim2.fromOffset(80,30),
            AnchorPoint=Vector2.new(1,0.5),
            Position=UDim2.new(1,0,0.5,0),
            BackgroundTransparency=1, ZIndex=6,
        },row), status, 10, C.GREEN, Enum.TextXAlignment.Right, FS)
    end
    return row
end

-- ── TWO-COLUMN SCROLL AREA ────────────────────────────────────
local ColArea = New("Frame",{
    Size=UDim2.new(1,-16,1,-76),
    Position=UDim2.fromOffset(8,66),
    BackgroundTransparency=1,
    ZIndex=4,
},Content)

local GAP = 6

local Col1 = New("ScrollingFrame",{
    Size=UDim2.new(0.5,-GAP/2,1,-18),
    BackgroundTransparency=1,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=4,
},ColArea)
New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},Col1)
New("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},Col1)

local Col2 = New("ScrollingFrame",{
    Size=UDim2.new(0.5,-GAP/2,1,-18),
    Position=UDim2.new(0.5,GAP/2,0,0),
    BackgroundTransparency=1,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=4,
},ColArea)
New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},Col2)
New("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},Col2)

-- ── POPULATE COL 1 — ESP / INVENTORY ─────────────────────────
local espHdr, espArr, espCap, espOpen, espBind = MakeSectionHeader(Col1, "ESP / INVENTORY")

-- body container (for collapse)
local EspBody = New("Frame",{
    Size=UDim2.new(1,-4,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,
    ZIndex=4,
},Col1)
New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},EspBody)

espBind(EspBody)

MakeDivider(EspBody, "PLAYER ESP")
MakeWidePill(EspBody, "esp font", "UI")
MakeSlider(EspBody, "esp font size", 6, 30, 13)
MakeToggle(EspBody, "infinite range", false)
MakeToggle(EspBody, "enable esp", true)
MakePill(EspBody, "ESP enable bind", "None")
MakeToggle(EspBody, "box esp", true)
MakePill(EspBody, "box color", "Color")

MakeDivider(EspBody, "SKELETON ESP")
MakeToggle(EspBody, "enable skeleton", false)
MakePill(EspBody, "skeleton color", "Color")
MakeSlider(EspBody, "skeleton thickness", 1, 5, 1)

MakeDivider(EspBody, "HEAD ESP")
MakeToggle(EspBody, "head circle", false)
MakeSlider(EspBody, "head radius", 4, 20, 8)

MakeDivider(EspBody, "HEALTH BAR")
MakeToggle(EspBody, "enable healthbar", false)
MakePill(EspBody, "bar side", "Left")
MakeSlider(EspBody, "bar thickness", 1, 5, 2)

-- ── POPULATE COL 2 — CROSSHAIR ────────────────────────────────
local crossHdr, crossArr, crossCap, crossOpen, crossBind = MakeSectionHeader(Col2, "CROSSHAIR")
local CrossBody = New("Frame",{
    Size=UDim2.new(1,-4,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,
    ZIndex=4,
},Col2)
New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},CrossBody)
crossBind(CrossBody)

MakeWidePill(CrossBody, "crosshair font", "UI")
MakeToggle(CrossBody, "enable crosshair", true)
MakePill(CrossBody, "crosshair color", "Color")
MakeToggle(CrossBody, "crosshair on target", true)
MakeSlider(CrossBody, "speed", 1, 10, 3)
MakeSlider(CrossBody, "radius", 5, 60, 25)
MakeSlider(CrossBody, "thickness", 1, 6, 2)
MakeSlider(CrossBody, "length", 5, 50, 20)

MakeDivider(CrossBody, "DOT")
MakeToggle(CrossBody, "enable dot", false)
MakeSlider(CrossBody, "dot size", 1, 8, 2)
MakePill(CrossBody, "dot color", "Color")

MakeDivider(CrossBody, "OUTLINE")
MakeToggle(CrossBody, "enable outline", false)
MakeSlider(CrossBody, "outline thickness", 1, 4, 1)

-- ── SIDEBAR TABS ──────────────────────────────────────────────
local TABS = {
    {ico="⚔",  name="Combat"},
    {ico="◈",  name="Visuals"},
    {ico="⊞",  name="Misc"},
    {ico="⚙",  name="Config"},
    {ico="▷",  name="Quick start"},
    {ico="★",  name="Favorites"},
    {ico="⊡",  name="Creator Presets"},
    {ico="⌨",  name="Keybinds"},
}

local activeTab = "Visuals"
local tabData   = {}

local function setTab(name)
    activeTab = name
    CatTitle.Text = name:upper()
    for _, t in pairs(tabData) do
        local a = (t.name == name)
        tw(t.bg, 0.14, {BackgroundColor3 = a and C.ACTIVE_BG or C.SIDEBAR})
        t.bg.BackgroundTransparency = 0
        t.lbl.TextColor3 = a and C.TEXT or C.SUBTEXT
        t.bar.Visible    = a
        t.icoBox.BackgroundColor3 = a and C.DIM or C.PANELB
        t.icoLbl.TextColor3 = a and C.ACCENT or C.SUBTEXT
    end
end

for i, tab in ipairs(TABS) do
    local isAct = (tab.name == activeTab)
    local row = New("Frame",{
        Size=UDim2.new(1,0,0,38),
        BackgroundTransparency=1,
        LayoutOrder=i, ZIndex=5,
    },NavScroll)

    local bar = New("Frame",{
        Size=UDim2.fromOffset(3,22),
        Position=UDim2.fromOffset(0,8),
        BackgroundColor3=C.ACCENT,
        BorderSizePixel=0,
        Visible=isAct, ZIndex=6,
    },row)
    Corner(bar,2)

    local bg = New("TextButton",{
        Size=UDim2.new(1,-4,0,34),
        Position=UDim2.fromOffset(4,2),
        BackgroundColor3=isAct and C.ACTIVE_BG or C.SIDEBAR,
        BackgroundTransparency=0,
        Text="", BorderSizePixel=0, ZIndex=5,
    },row)
    Corner(bg,7)

    local icoBox = New("Frame",{
        Size=UDim2.fromOffset(24,24),
        Position=UDim2.fromOffset(8,5),
        BackgroundColor3=isAct and C.DIM or C.PANELB,
        BorderSizePixel=0, ZIndex=6,
    },bg)
    Corner(icoBox,12)

    local icoLbl = Tbl(icoBox, tab.ico, 12,
        isAct and C.ACCENT or C.SUBTEXT, Enum.TextXAlignment.Center, FB)
    icoLbl.ZIndex=7

    local lbl = New("TextLabel",{
        Size=UDim2.new(1,-46,1,0),
        Position=UDim2.fromOffset(36,0),
        BackgroundTransparency=1,
        Text=tab.name, Font=FS,
        TextSize=12, TextColor3=isAct and C.TEXT or C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6,
    },bg)

    New("TextLabel",{
        Size=UDim2.fromOffset(12,34),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-6,0.5,0),
        BackgroundTransparency=1,
        Text=">", Font=FB,
        TextSize=11, TextColor3=C.SUBTEXT,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=6,
    },bg)

    tabData[i] = {name=tab.name, bg=bg, bar=bar, lbl=lbl, icoBox=icoBox, icoLbl=icoLbl}

    bg.MouseEnter:Connect(function()
        if tab.name ~= activeTab then
            tw(bg,0.10,{BackgroundColor3=C.PANELB})
        end
    end)
    bg.MouseLeave:Connect(function()
        if tab.name ~= activeTab then
            tw(bg,0.10,{BackgroundColor3=C.SIDEBAR})
        end
    end)
    bg.MouseButton1Click:Connect(function() setTab(tab.name) end)
end

-- ── SIDEBAR BOTTOM CARD ───────────────────────────────────────
local Card = New("Frame",{
    Name="KuroCard",
    Size=UDim2.new(1,-12,0,118),
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,6,1,-6),
    BackgroundColor3=C.CARD,
    BorderSizePixel=0, ZIndex=5,
},Sidebar)
Corner(Card,10); Stroke(Card,1,C.BORDER)

-- accent top stripe
New("Frame",{
    Size=UDim2.new(1,0,0,2),
    BackgroundColor3=C.ACCENT,
    BorderSizePixel=0, ZIndex=6,
},Card)

-- kuromi tag top
Tbl(New("Frame",{
    Size=UDim2.new(1,-8,0,14),
    Position=UDim2.fromOffset(4,5),
    BackgroundTransparency=1, ZIndex=6,
},Card),"✦ kuromi night edition",9,C.ACCENT2,Enum.TextXAlignment.Left,FS)

-- art placeholder
local Art = New("Frame",{
    Size=UDim2.fromOffset(54,54),
    Position=UDim2.fromOffset(6,20),
    BackgroundColor3=C.DIM,
    BorderSizePixel=0, ZIndex=6,
},Card)
Corner(Art,10); Stroke(Art,1,C.BORDER)
Tbl(Art,"♥",24,C.ACCENT2,Enum.TextXAlignment.Center,FB).TextYAlignment=Enum.TextYAlignment.Center

-- info
Tbl(New("Frame",{
    Size=UDim2.fromOffset(SIDE_W-78,18),
    Position=UDim2.fromOffset(64,20),
    BackgroundTransparency=1, ZIndex=6,
},Card),"CINEX HUB / KUROMI...",11,C.TEXT,Enum.TextXAlignment.Left,FB)

Tbl(New("Frame",{
    Size=UDim2.fromOffset(SIDE_W-78,14),
    Position=UDim2.fromOffset(64,38),
    BackgroundTransparency=1, ZIndex=6,
},Card),"KUROMI MOONLIGHT · V2.6.20",9,C.SUBTEXT,Enum.TextXAlignment.Left,FR)

local BegBtn = New("TextButton",{
    Size=UDim2.new(1,-12,0,26),
    Position=UDim2.fromOffset(6,82),
    BackgroundColor3=C.PANELB,
    Text="Switch to Beginner",
    Font=FS, TextSize=12, TextColor3=C.TEXT,
    BorderSizePixel=0, ZIndex=6,
},Card)
Corner(BegBtn,7); Stroke(BegBtn,1,C.BORDER)
BegBtn.MouseEnter:Connect(function() tw(BegBtn,0.12,{BackgroundColor3=C.PANELC}) end)
BegBtn.MouseLeave:Connect(function() tw(BegBtn,0.12,{BackgroundColor3=C.PANELB}) end)

-- ── SEARCH FILTER (live) ──────────────────────────────────────
local allRows = {}
for _, col in ipairs({EspBody, CrossBody}) do
    for _, ch in ipairs(col:GetChildren()) do
        if ch:IsA("Frame") and ch:FindFirstChildWhichIsA("TextLabel") then
            local tl = ch:FindFirstChildWhichIsA("TextLabel")
            if tl then
                table.insert(allRows, {frame=ch, text=tl.Text:lower()})
            end
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower()
    if q=="" then
        for _,r in pairs(allRows) do r.frame.Visible=true end
        return
    end
    for _,r in pairs(allRows) do
        r.frame.Visible = r.text:find(q,1,true)~=nil
    end
end)

-- ── READY ─────────────────────────────────────────────────────
print("[CinexHub] Kuromi Night Edition v2.6.20 — pronto")
print(IS_MOBILE and "[CinexHub] Mobile: use o botão ✦ flutuante" or "[CinexHub] PC: R SHIFT para toggle")
