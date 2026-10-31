-- ============================================================
--  CINEX HUB | KUROMI NIGHT EDITION  v2.6.20  [v3 - mobile fix]
--  PC  : Synapse X / Wave / Swift   → R SHIFT toggle
--  MOB : Delta / Codex / Fluxus     → botão ✦ flutuante
-- ============================================================
-- FIXES v3:
--   • Removidos todos os frames "flatten-corners" opacos que cobriam UI
--   • ZIndexBehavior = Global (sem herança de ZIndex pai)
--   • Sidebar/Content posicionados por offset puro, sem AbsoluteSize no load
--   • RunService.Heartbeat:Wait() antes de popular colunas no mobile
--   • Drag do slider usa Position.X do InputObject, não AbsolutePosition
-- ============================================================

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local PL  = game:GetService("Players")

local IS_MOB = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ── THEME ─────────────────────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(20,  14,  32),
    SIDE     = Color3.fromRGB(36,  26,  52),
    PANEL    = Color3.fromRGB(30,  21,  46),
    PNB      = Color3.fromRGB(50,  38,  72),
    PNC      = Color3.fromRGB(62,  48,  88),
    ACC      = Color3.fromRGB(172, 92, 252),
    ACC2     = Color3.fromRGB(208,142,255),
    DIM      = Color3.fromRGB(96,  52, 164),
    TOFF     = Color3.fromRGB(62,  48,  88),
    TON      = Color3.fromRGB(150, 70, 235),
    TXT      = Color3.fromRGB(236,230,248),
    SUB      = Color3.fromRGB(148,130,180),
    BOR      = Color3.fromRGB(80,  54, 122),
    ACT      = Color3.fromRGB(56,  40,  80),
    BLK      = Color3.fromRGB(8,    4,  16),
    CARD     = Color3.fromRGB(44,  30,  64),
    STON     = Color3.fromRGB(218,178,255),
    STOF     = Color3.fromRGB(72,  52, 102),
    SEP      = Color3.fromRGB(66,  48,  96),
    GRN      = Color3.fromRGB(76, 218,118),
}
local FB = Enum.Font.GothamBold
local FS = Enum.Font.GothamSemibold
local FR = Enum.Font.Gotham

-- ── GUI ROOT ──────────────────────────────────────────────────
local SG
if syn and syn.protect_gui then
    SG = Instance.new("ScreenGui"); syn.protect_gui(SG)
    SG.Parent = game:GetService("CoreGui")
elseif gethui then
    SG = Instance.new("ScreenGui"); SG.Parent = gethui()
else
    local ok = pcall(function()
        SG = Instance.new("ScreenGui")
        SG.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        SG = Instance.new("ScreenGui")
        SG.Parent = PL.LocalPlayer:WaitForChild("PlayerGui")
    end
end
SG.Name             = "CinexHub"
SG.ZIndexBehavior   = Enum.ZIndexBehavior.Global   -- ← CRÍTICO
SG.ResetOnSpawn     = false
SG.IgnoreGuiInset   = true
SG.DisplayOrder     = 1000

-- ── HELPERS ───────────────────────────────────────────────────
local function N(cls, p, par)
    local o = Instance.new(cls)
    for k,v in pairs(p or {}) do o[k]=v end
    if par then o.Parent=par end
    return o
end
local function Cor(p,r) return N("UICorner",{CornerRadius=UDim.new(0,r or 8)},p) end
local function Str(p,t,c) return N("UIStroke",{Thickness=t or 1,Color=c or C.BOR,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function tw(o,t,pr) TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),pr):Play() end

local function Lbl(par, txt, sz, col, xa, fnt, ya)
    return N("TextLabel",{
        BackgroundTransparency=1, Text=txt,
        Font=fnt or FR, TextSize=sz or 13,
        TextColor3=col or C.TXT,
        TextXAlignment=xa or Enum.TextXAlignment.Left,
        TextYAlignment=ya or Enum.TextYAlignment.Center,
        TextWrapped=true, Size=UDim2.fromScale(1,1),
        BorderSizePixel=0,
    },par)
end

-- ── VIEWPORT ──────────────────────────────────────────────────
local CAM = workspace.CurrentCamera
-- Wait for valid viewport on mobile
if CAM.ViewportSize == Vector2.new(0,0) then
    RS.Heartbeat:Wait()
end
local VP   = CAM.ViewportSize
local MW   = math.floor(VP.X * 0.90)
local MH   = math.floor(VP.Y * 0.86)
local SIDE = math.max(160, math.floor(MW * 0.205))
local TOPH = 54
local CNTW = MW - SIDE
local CNTH = MH - TOPH

-- ── SHADOW ────────────────────────────────────────────────────
N("Frame",{
    Size=UDim2.fromOffset(MW+18,MH+14),
    Position=UDim2.fromOffset(
        math.floor((VP.X-MW)*0.5)-9,
        math.floor((VP.Y-MH)*0.5)+8
    ),
    BackgroundColor3=C.BLK,
    BackgroundTransparency=0.48,
    BorderSizePixel=0,
    ZIndex=1,
},SG)

-- ── MAIN FRAME ────────────────────────────────────────────────
local Main = N("Frame",{
    Name="Main",
    Size=UDim2.fromOffset(MW,MH),
    Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=C.BG,
    BorderSizePixel=0,
    ZIndex=10,
},SG)
Cor(Main,12); Str(Main,1.5,C.BOR)

-- ── DRAG ──────────────────────────────────────────────────────
local function Draggable(handle, target)
    local drag,ds,sp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=target.AbsolutePosition
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            target.Position=UDim2.fromOffset(sp.X+d.X,sp.Y+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- ── FLOAT TOGGLE BUTTON (mobile always-visible) ───────────────
local FloatBtn = N("TextButton",{
    Name="CinexFloat",
    Size=UDim2.fromOffset(50,50),
    Position=UDim2.new(1,-62,1,-72),
    BackgroundColor3=C.DIM,
    Text="✦", TextColor3=C.ACC2,
    Font=FB, TextSize=22,
    BorderSizePixel=0,
    ZIndex=5000,
},SG)
Cor(FloatBtn,25); Str(FloatBtn,1.5,C.ACC)

do -- draggable + tap
    local d,ds,sp,moved=false,nil,nil,false
    FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            d=true; ds=i.Position; sp=FloatBtn.AbsolutePosition; moved=false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            local delta=i.Position-ds
            if delta.Magnitude>5 then
                moved=true
                FloatBtn.Position=UDim2.fromOffset(sp.X+delta.X,sp.Y+delta.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            d=false
            if not moved then Main.Visible=not Main.Visible end
        end
    end)
end

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        Main.Visible=not Main.Visible
    end
end)

-- ══════════════════════════════════════════
--  TOP BAR  (ZIndex 20-30)
-- ══════════════════════════════════════════
local Topbar = N("Frame",{
    Size=UDim2.fromOffset(MW,TOPH),
    BackgroundColor3=C.SIDE,
    BorderSizePixel=0, ZIndex=20,
},Main)
Cor(Topbar,12); Str(Topbar,1,C.BOR)
-- square off BOTTOM corners via clipping mask (no opaque frames)
Topbar.ClipsDescendants = false
Draggable(Topbar,Main)

-- extend bg to fill bottom half (kills bottom curve)
N("Frame",{
    Size=UDim2.new(1,0,0,math.ceil(TOPH/2)),
    Position=UDim2.fromOffset(0,math.floor(TOPH/2)),
    BackgroundColor3=C.SIDE,
    BorderSizePixel=0, ZIndex=19,
},Main)

-- Logo
local LogoBox = N("Frame",{
    Size=UDim2.fromOffset(162,42),
    Position=UDim2.fromOffset(10,6),
    BackgroundColor3=C.PANEL, BorderSizePixel=0, ZIndex=22,
},Topbar)
Cor(LogoBox,8); Str(LogoBox,1,C.BOR)

local LC = N("Frame",{
    Size=UDim2.fromOffset(32,32), Position=UDim2.fromOffset(5,5),
    BackgroundColor3=C.DIM, BorderSizePixel=0, ZIndex=23,
},LogoBox); Cor(LC,16)
local LI=Lbl(LC,"✦",17,C.ACC2,Enum.TextXAlignment.Center,FB)
LI.ZIndex=24

local LT=N("TextLabel",{
    Size=UDim2.fromOffset(116,20), Position=UDim2.fromOffset(42,3),
    BackgroundTransparency=1, Text="CINEX HUB", Font=FB,
    TextSize=12, TextColor3=C.TXT,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=23,
},LogoBox)
local LS=N("TextLabel",{
    Size=UDim2.fromOffset(116,16), Position=UDim2.fromOffset(42,22),
    BackgroundTransparency=1, Text="kuromi night edition", Font=FR,
    TextSize=9, TextColor3=C.SUB,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=23,
},LogoBox)

-- Search
local SBW=math.max(160,math.floor(CNTW*0.52))
local SBF=N("Frame",{
    Size=UDim2.fromOffset(SBW,34),
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    BackgroundColor3=C.PANEL, BorderSizePixel=0, ZIndex=22,
},Topbar); Cor(SBF,8); Str(SBF,1,C.BOR)

local SIcon=Lbl(N("Frame",{
    Size=UDim2.fromOffset(28,34),Position=UDim2.fromOffset(4,0),
    BackgroundTransparency=1,ZIndex=23,
},SBF),"🔍",13,C.SUB,Enum.TextXAlignment.Center,FR)
SIcon.ZIndex=23

local SearchBox=N("TextBox",{
    Size=UDim2.new(1,-84,1,0),Position=UDim2.fromOffset(30,0),
    BackgroundTransparency=1,
    PlaceholderText="Search settings, e.g. silent aim, FOV...",
    PlaceholderColor3=C.SUB, Text="", TextColor3=C.TXT,
    Font=FR, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false, ZIndex=24,
},SBF)

local SHint=N("TextLabel",{
    Size=UDim2.fromOffset(40,34),Position=UDim2.new(1,-70,0,0),
    BackgroundTransparency=1, Text="ctrl /", Font=FR,
    TextSize=10, TextColor3=C.SUB,
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=23,
},SBF)

local SCX=N("TextButton",{
    Size=UDim2.fromOffset(24,24),
    AnchorPoint=Vector2.new(0,0.5),
    Position=UDim2.new(1,-28,0.5,0),
    BackgroundColor3=C.PNB, Text="✕", TextColor3=C.TXT,
    Font=FB, TextSize=10, BorderSizePixel=0, ZIndex=24,
},SBF); Cor(SCX,5)
SCX.MouseButton1Click:Connect(function() SearchBox.Text="" end)

-- Keybind
local KA=N("Frame",{
    Size=UDim2.fromOffset(126,42),
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-10,0.5,0),
    BackgroundTransparency=1, BorderSizePixel=0, ZIndex=22,
},Topbar)

local KC=N("Frame",{
    Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(0,5),
    BackgroundColor3=C.DIM, BorderSizePixel=0, ZIndex=23,
},KA); Cor(KC,16)
Lbl(KC,"⌨",14,C.ACC,Enum.TextXAlignment.Center,FB).ZIndex=24

local KB=N("Frame",{
    Size=UDim2.fromOffset(72,28),Position=UDim2.fromOffset(36,7),
    BackgroundColor3=C.PANEL, BorderSizePixel=0, ZIndex=23,
},KA); Cor(KB,6); Str(KB,1,C.BOR)
Lbl(KB,"R SHIFT",11,C.TXT,Enum.TextXAlignment.Center,FS).ZIndex=24

local ClsBtn=N("TextButton",{
    Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(112,9),
    BackgroundColor3=C.PNB, Text="✕", TextColor3=C.TXT,
    Font=FB, TextSize=10, BorderSizePixel=0, ZIndex=23,
},KA); Cor(ClsBtn,5)
ClsBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

-- ══════════════════════════════════════════
--  SIDEBAR  (ZIndex 15-18)
-- ══════════════════════════════════════════
local Sidebar=N("Frame",{
    Name="Sidebar",
    Size=UDim2.fromOffset(SIDE,CNTH),
    Position=UDim2.fromOffset(0,TOPH),
    BackgroundColor3=C.SIDE,
    BorderSizePixel=0, ZIndex=15,
},Main)
Cor(Sidebar,12); Str(Sidebar,1,C.BOR)
-- kill top-right and top-left curvature by layering a rect on top of top portion
N("Frame",{
    Size=UDim2.fromOffset(SIDE,14),
    BackgroundColor3=C.SIDE,
    BorderSizePixel=0, ZIndex=16,
},Sidebar)
-- right-side separator
N("Frame",{
    Size=UDim2.fromOffset(1,CNTH),
    Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.SEP,
    BorderSizePixel=0, ZIndex=17,
},Sidebar)

local NavScroll=N("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-122),
    Position=UDim2.fromOffset(0,6),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=2,
    ScrollBarImageColor3=C.ACC,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ZIndex=18,
},Sidebar)
N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},NavScroll)

-- ══════════════════════════════════════════
--  CONTENT AREA  (ZIndex 15-18)
-- ══════════════════════════════════════════
local Content=N("Frame",{
    Name="Content",
    Size=UDim2.fromOffset(CNTW,CNTH),
    Position=UDim2.fromOffset(SIDE,TOPH),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=15,
},Main)
Cor(Content,12); Str(Content,1,C.BOR)
-- kill top-left corner curve
N("Frame",{
    Size=UDim2.fromOffset(14,CNTH),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=16,
},Content)
N("Frame",{
    Size=UDim2.fromOffset(CNTW,14),
    BackgroundColor3=C.BG,
    BorderSizePixel=0, ZIndex=16,
},Content)

-- Cat header
local CatCirc=N("Frame",{
    Size=UDim2.fromOffset(36,36),Position=UDim2.fromOffset(16,14),
    BackgroundColor3=C.DIM, BorderSizePixel=0, ZIndex=18,
},Content); Cor(CatCirc,18)
Lbl(CatCirc,"◈",18,C.ACC,Enum.TextXAlignment.Center,FB).ZIndex=19

local CatTitle=N("TextLabel",{
    Size=UDim2.fromOffset(CNTW-200,28),Position=UDim2.fromOffset(60,12),
    BackgroundTransparency=1, Text="VISUALS", Font=FB,
    TextSize=20, TextColor3=C.TXT,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18,
},Content)

N("TextLabel",{
    Size=UDim2.fromOffset(CNTW-200,16),Position=UDim2.fromOffset(60,38),
    BackgroundTransparency=1,
    Text="Everything in one place. Search, configure, and save your changes.",
    Font=FR, TextSize=11, TextColor3=C.SUB,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18,
},Content)

local FavBtn=N("TextButton",{
    Size=UDim2.fromOffset(172,30),
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-14,0,14),
    BackgroundColor3=C.PNB,
    Text="  ★  Favorite this category",
    Font=FS, TextSize=12, TextColor3=C.ACC2,
    BorderSizePixel=0, ZIndex=18,
},Content); Cor(FavBtn,8); Str(FavBtn,1,C.BOR)
FavBtn.MouseEnter:Connect(function() tw(FavBtn,0.13,{BackgroundColor3=C.PNC}) end)
FavBtn.MouseLeave:Connect(function() tw(FavBtn,0.13,{BackgroundColor3=C.PNB}) end)

N("Frame",{
    Size=UDim2.new(1,-28,0,1),Position=UDim2.fromOffset(14,62),
    BackgroundColor3=C.SEP, BorderSizePixel=0, ZIndex=17,
},Content)

N("TextLabel",{
    Size=UDim2.new(1,-24,0,14),
    AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,14,1,-4),
    BackgroundTransparency=1,
    Text="All settings are saved using their original config IDs.",
    Font=FR, TextSize=9, TextColor3=C.SUB,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=17,
},Content)

-- ══════════════════════════════════════════
--  COMPONENTS  (ZIndex 30+)
-- ══════════════════════════════════════════
local BASE_Z = 30

local function StarBtn(par)
    local on=false
    local b=N("TextButton",{
        Size=UDim2.fromOffset(20,20),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-4,0.5,0),
        BackgroundTransparency=1, Text="☆", Font=FB,
        TextSize=14, TextColor3=C.STOF,
        BorderSizePixel=0, ZIndex=BASE_Z+5,
    },par)
    b.MouseButton1Click:Connect(function()
        on=not on
        b.Text=on and "★" or "☆"
        b.TextColor3=on and C.STON or C.STOF
    end)
    return b
end

local function MakeRow(par,h)
    local f=N("Frame",{
        Size=UDim2.new(1,-4,0,h or 42),
        BackgroundColor3=C.PANEL,
        BorderSizePixel=0, ZIndex=BASE_Z,
    },par)
    Cor(f,7); Str(f,1,C.BOR)
    return f
end

-- Toggle
local function Toggle(par,txt,def)
    local row=MakeRow(par,42)
    StarBtn(row)
    local state=(def==true)

    local lf=N("Frame",{
        Size=UDim2.new(1,-70,1,0),Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=BASE_Z+1,
    },row)
    Lbl(lf,txt,12,C.TXT,Enum.TextXAlignment.Left,FS).ZIndex=BASE_Z+2

    local track=N("Frame",{
        Size=UDim2.fromOffset(44,22),
        AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=state and C.TON or C.TOFF,
        BorderSizePixel=0, ZIndex=BASE_Z+2,
    },row); Cor(track,11)

    local knob=N("Frame",{
        Size=UDim2.fromOffset(18,18),
        Position=state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0, ZIndex=BASE_Z+3,
    },track); Cor(knob,9)

    local hit=N("TextButton",{
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text="", ZIndex=BASE_Z+4,
    },track)
    hit.MouseButton1Click:Connect(function()
        state=not state
        tw(track,0.18,{BackgroundColor3=state and C.TON or C.TOFF})
        tw(knob,0.18,{Position=state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2)})
    end)
    return row, function() return state end
end

-- Slider
local function Slider(par,txt,mn,mx,def)
    local row=MakeRow(par,54)
    StarBtn(row)

    local lf=N("Frame",{
        Size=UDim2.new(1,-52,0,20),Position=UDim2.fromOffset(10,8),
        BackgroundTransparency=1, ZIndex=BASE_Z+1,
    },row)
    Lbl(lf,txt,12,C.TXT,Enum.TextXAlignment.Left,FS).ZIndex=BASE_Z+2

    local vl=N("TextLabel",{
        Size=UDim2.fromOffset(36,20),
        AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,8),
        BackgroundTransparency=1, Text=tostring(def),
        Font=FB, TextSize=12, TextColor3=C.ACC2,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=BASE_Z+2,
    },row)

    local tr=N("Frame",{
        Size=UDim2.new(1,-22,0,6),Position=UDim2.fromOffset(10,36),
        BackgroundColor3=C.TOFF, BorderSizePixel=0, ZIndex=BASE_Z+2,
    },row); Cor(tr,3)

    local p0=(def-mn)/(mx-mn)
    local fl=N("Frame",{
        Size=UDim2.fromScale(p0,1),
        BackgroundColor3=C.ACC, BorderSizePixel=0, ZIndex=BASE_Z+3,
    },tr); Cor(fl,3)

    local kn=N("Frame",{
        Size=UDim2.fromOffset(14,14),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(p0,0,0.5,0),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0, ZIndex=BASE_Z+4,
    },tr); Cor(kn,7); Str(kn,1.5,C.ACC)

    local drag=false
    local function upd(x)
        local abs=tr.AbsolutePosition.X
        local sz=tr.AbsoluteSize.X
        if sz==0 then return end
        local r=math.clamp((x-abs)/sz,0,1)
        local v=math.floor(mn+r*(mx-mn)+0.5)
        r=(v-mn)/(mx-mn)
        fl.Size=UDim2.fromScale(r,1)
        kn.Position=UDim2.new(r,0,0.5,0)
        vl.Text=tostring(v)
    end

    kn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    tr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            upd(i.Position.X); drag=true
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    return row
end

-- Pill (label + value button inline)
local function Pill(par,txt,ptxt)
    local row=MakeRow(par,42)
    StarBtn(row)

    local lf=N("Frame",{
        Size=UDim2.new(1,-96,1,0),Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, ZIndex=BASE_Z+1,
    },row)
    Lbl(lf,txt,12,C.TXT,Enum.TextXAlignment.Left,FS).ZIndex=BASE_Z+2

    local pill=N("TextButton",{
        Size=UDim2.fromOffset(72,26),
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-28,0.5,0),
        BackgroundColor3=C.PNB, Text=ptxt, Font=FS,
        TextSize=12, TextColor3=C.TXT,
        BorderSizePixel=0, ZIndex=BASE_Z+2,
    },row); Cor(pill,6); Str(pill,1,C.BOR)
    pill.MouseEnter:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PNC}) end)
    pill.MouseLeave:Connect(function() tw(pill,0.12,{BackgroundColor3=C.PNB}) end)
    return row
end

-- Wide Pill (label on top, wide button below — like "esp font → UI")
local function WidePill(par,txt,ptxt)
    local row=MakeRow(par,68)
    StarBtn(row)

    local lf=N("Frame",{
        Size=UDim2.new(1,-28,0,20),Position=UDim2.fromOffset(10,8),
        BackgroundTransparency=1, ZIndex=BASE_Z+1,
    },row)
    Lbl(lf,txt,12,C.TXT,Enum.TextXAlignment.Left,FS).ZIndex=BASE_Z+2

    local w=N("TextButton",{
        Size=UDim2.new(1,-20,0,26),Position=UDim2.fromOffset(10,34),
        BackgroundColor3=C.PNB, Text=ptxt, Font=FS,
        TextSize=13, TextColor3=C.TXT,
        BorderSizePixel=0, ZIndex=BASE_Z+2,
    },row); Cor(w,6); Str(w,1,C.BOR)
    w.MouseEnter:Connect(function() tw(w,0.12,{BackgroundColor3=C.PNC}) end)
    w.MouseLeave:Connect(function() tw(w,0.12,{BackgroundColor3=C.PNB}) end)
    return row
end

-- Section header (collapsible)
local function SecHeader(par,txt)
    local open=true
    local hdr=N("Frame",{
        Size=UDim2.new(1,-4,0,30),
        BackgroundColor3=C.PNB, BorderSizePixel=0, ZIndex=BASE_Z,
    },par); Cor(hdr,8); Str(hdr,1,C.BOR)

    local ic=N("Frame",{
        Size=UDim2.fromOffset(22,22),Position=UDim2.fromOffset(6,4),
        BackgroundColor3=C.DIM, BorderSizePixel=0, ZIndex=BASE_Z+1,
    },hdr); Cor(ic,11)
    Lbl(ic,"◈",11,C.ACC,Enum.TextXAlignment.Center,FB).ZIndex=BASE_Z+2

    local cap=N("TextButton",{
        Size=UDim2.new(1,-38,1,0),Position=UDim2.fromOffset(32,0),
        BackgroundTransparency=1, Text=txt, Font=FB,
        TextSize=13, TextColor3=C.TXT,
        TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0, ZIndex=BASE_Z+2,
    },hdr)

    local arr=N("TextLabel",{
        Size=UDim2.fromOffset(20,30),
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-4,0.5,0),
        BackgroundTransparency=1, Text="∧", Font=FB,
        TextSize=12, TextColor3=C.SUB,
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=BASE_Z+2,
    },hdr)

    return hdr, function(body)
        cap.MouseButton1Click:Connect(function()
            open=not open
            arr.Text=open and "∧" or "∨"
            body.Visible=open
        end)
    end
end

-- Divider label
local function Div(par,txt)
    local f=N("Frame",{
        Size=UDim2.new(1,-4,0,22),
        BackgroundTransparency=1, ZIndex=BASE_Z,
    },par)
    Lbl(f,"--- "..txt.." ---",10,C.SUB,Enum.TextXAlignment.Left,FS).ZIndex=BASE_Z+1
    return f
end

-- ══════════════════════════════════════════
--  TWO COLUMN SCROLL AREA
-- ══════════════════════════════════════════
local ColArea=N("Frame",{
    Size=UDim2.fromOffset(CNTW-16, CNTH-74),
    Position=UDim2.fromOffset(8,68),
    BackgroundTransparency=1, ZIndex=17,
},Content)

local GAP=6
local COL=math.floor((CNTW-16)/2 - GAP/2)

local Col1=N("ScrollingFrame",{
    Size=UDim2.fromOffset(COL,CNTH-80),
    BackgroundTransparency=1,
    ScrollBarThickness=3, ScrollBarImageColor3=C.ACC,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=18,
},ColArea)
N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},Col1)
N("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},Col1)

local Col2=N("ScrollingFrame",{
    Size=UDim2.fromOffset(COL,CNTH-80),
    Position=UDim2.fromOffset(COL+GAP,0),
    BackgroundTransparency=1,
    ScrollBarThickness=3, ScrollBarImageColor3=C.ACC,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    BorderSizePixel=0, ZIndex=18,
},ColArea)
N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},Col2)
N("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},Col2)

-- ══════════════════════════════════════════
--  POPULATE COL 1 — ESP / INVENTORY
-- ══════════════════════════════════════════
local eh,ebind = SecHeader(Col1,"ESP / INVENTORY")
local EspBody=N("Frame",{
    Size=UDim2.new(1,-4,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1, ZIndex=BASE_Z,
},Col1)
N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},EspBody)
ebind(EspBody)

Div(EspBody,"PLAYER ESP")
WidePill(EspBody,"esp font","UI")
Slider(EspBody,"esp font size",6,30,13)
Toggle(EspBody,"infinite range",false)
Toggle(EspBody,"enable esp",true)
Pill(EspBody,"ESP enable bind","None")
Toggle(EspBody,"box esp",true)
Pill(EspBody,"box color","Color")
Div(EspBody,"SKELETON ESP")
Toggle(EspBody,"enable skeleton",false)
Pill(EspBody,"skeleton color","Color")
Slider(EspBody,"skeleton thickness",1,5,1)
Div(EspBody,"HEAD ESP")
Toggle(EspBody,"head circle",false)
Slider(EspBody,"head radius",4,20,8)
Div(EspBody,"HEALTH BAR")
Toggle(EspBody,"enable healthbar",false)
Pill(EspBody,"bar side","Left")
Slider(EspBody,"bar thickness",1,5,2)

-- ══════════════════════════════════════════
--  POPULATE COL 2 — CROSSHAIR
-- ══════════════════════════════════════════
local ch2,cbind2 = SecHeader(Col2,"CROSSHAIR")
local CrossBody=N("Frame",{
    Size=UDim2.new(1,-4,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1, ZIndex=BASE_Z,
},Col2)
N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},CrossBody)
cbind2(CrossBody)

WidePill(CrossBody,"crosshair font","UI")
Toggle(CrossBody,"enable crosshair",true)
Pill(CrossBody,"crosshair color","Color")
Toggle(CrossBody,"crosshair on target",true)
Slider(CrossBody,"speed",1,10,3)
Slider(CrossBody,"radius",5,60,25)
Slider(CrossBody,"thickness",1,6,2)
Slider(CrossBody,"length",5,50,20)
Div(CrossBody,"DOT")
Toggle(CrossBody,"enable dot",false)
Slider(CrossBody,"dot size",1,8,2)
Pill(CrossBody,"dot color","Color")
Div(CrossBody,"OUTLINE")
Toggle(CrossBody,"enable outline",false)
Slider(CrossBody,"outline thickness",1,4,1)

-- ══════════════════════════════════════════
--  SIDEBAR TABS
-- ══════════════════════════════════════════
local TABS={
    {ic="⚔",nm="Combat"},
    {ic="◈",nm="Visuals"},
    {ic="⊞",nm="Misc"},
    {ic="⚙",nm="Config"},
    {ic="▷",nm="Quick start"},
    {ic="★",nm="Favorites"},
    {ic="⊡",nm="Creator Presets"},
    {ic="⌨",nm="Keybinds"},
}
local activeTab="Visuals"
local tabRef={}

local function setTab(nm)
    activeTab=nm
    CatTitle.Text=nm:upper()
    for _,t in pairs(tabRef) do
        local a=(t.nm==nm)
        tw(t.bg,0.14,{BackgroundColor3=a and C.ACT or C.SIDE})
        t.lbl.TextColor3=a and C.TXT or C.SUB
        t.bar.Visible=a
        t.ib.BackgroundColor3=a and C.DIM or C.PNB
        t.il.TextColor3=a and C.ACC or C.SUB
    end
end

for i,tab in ipairs(TABS) do
    local isA=(tab.nm==activeTab)
    local row=N("Frame",{
        Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,
        LayoutOrder=i, ZIndex=18,
    },NavScroll)

    local bar=N("Frame",{
        Size=UDim2.fromOffset(3,22),Position=UDim2.fromOffset(0,8),
        BackgroundColor3=C.ACC, BorderSizePixel=0,
        Visible=isA, ZIndex=20,
    },row); Cor(bar,2)

    local bg=N("TextButton",{
        Size=UDim2.new(1,-4,0,34),Position=UDim2.fromOffset(4,2),
        BackgroundColor3=isA and C.ACT or C.SIDE,
        BackgroundTransparency=0, Text="",
        BorderSizePixel=0, ZIndex=19,
    },row); Cor(bg,7)

    local ib=N("Frame",{
        Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(8,5),
        BackgroundColor3=isA and C.DIM or C.PNB,
        BorderSizePixel=0, ZIndex=20,
    },bg); Cor(ib,12)

    local il=Lbl(ib,tab.ic,12,isA and C.ACC or C.SUB,Enum.TextXAlignment.Center,FB)
    il.ZIndex=21

    local lbl=N("TextLabel",{
        Size=UDim2.new(1,-46,1,0),Position=UDim2.fromOffset(36,0),
        BackgroundTransparency=1, Text=tab.nm, Font=FS,
        TextSize=12, TextColor3=isA and C.TXT or C.SUB,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=20,
    },bg)

    N("TextLabel",{
        Size=UDim2.fromOffset(12,34),
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),
        BackgroundTransparency=1, Text=">", Font=FB,
        TextSize=11, TextColor3=C.SUB,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=20,
    },bg)

    tabRef[i]={nm=tab.nm,bg=bg,bar=bar,lbl=lbl,ib=ib,il=il}

    bg.MouseEnter:Connect(function()
        if tab.nm~=activeTab then tw(bg,0.10,{BackgroundColor3=C.PNB}) end
    end)
    bg.MouseLeave:Connect(function()
        if tab.nm~=activeTab then tw(bg,0.10,{BackgroundColor3=C.SIDE}) end
    end)
    bg.MouseButton1Click:Connect(function() setTab(tab.nm) end)
end

-- ══════════════════════════════════════════
--  SIDEBAR BOTTOM CARD
-- ══════════════════════════════════════════
local Card=N("Frame",{
    Size=UDim2.new(1,-12,0,116),
    AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,6,1,-6),
    BackgroundColor3=C.CARD, BorderSizePixel=0, ZIndex=18,
},Sidebar); Cor(Card,10); Str(Card,1,C.BOR)

N("Frame",{
    Size=UDim2.new(1,0,0,2),
    BackgroundColor3=C.ACC, BorderSizePixel=0, ZIndex=19,
},Card)
Lbl(N("Frame",{
    Size=UDim2.new(1,-8,0,14),Position=UDim2.fromOffset(4,4),
    BackgroundTransparency=1, ZIndex=19,
},Card),"✦ kuromi night edition",9,C.ACC2,Enum.TextXAlignment.Left,FS).ZIndex=20

local Art=N("Frame",{
    Size=UDim2.fromOffset(54,54),Position=UDim2.fromOffset(5,20),
    BackgroundColor3=C.DIM, BorderSizePixel=0, ZIndex=19,
},Card); Cor(Art,10); Str(Art,1,C.BOR)
local AL=Lbl(Art,"♥",26,C.ACC2,Enum.TextXAlignment.Center,FB)
AL.TextYAlignment=Enum.TextYAlignment.Center; AL.ZIndex=20

Lbl(N("Frame",{
    Size=UDim2.fromOffset(SIDE-74,18),Position=UDim2.fromOffset(64,20),
    BackgroundTransparency=1, ZIndex=19,
},Card),"CINEX HUB / KUROMI...",11,C.TXT,Enum.TextXAlignment.Left,FB).ZIndex=20

Lbl(N("Frame",{
    Size=UDim2.fromOffset(SIDE-74,14),Position=UDim2.fromOffset(64,38),
    BackgroundTransparency=1, ZIndex=19,
},Card),"KUROMI MOONLIGHT  ·  V2.6.20",9,C.SUB,Enum.TextXAlignment.Left,FR).ZIndex=20

local BegBtn=N("TextButton",{
    Size=UDim2.new(1,-12,0,26),Position=UDim2.fromOffset(6,82),
    BackgroundColor3=C.PNB, Text="Switch to Beginner",
    Font=FS, TextSize=12, TextColor3=C.TXT,
    BorderSizePixel=0, ZIndex=19,
},Card); Cor(BegBtn,7); Str(BegBtn,1,C.BOR)
BegBtn.MouseEnter:Connect(function() tw(BegBtn,0.12,{BackgroundColor3=C.PNC}) end)
BegBtn.MouseLeave:Connect(function() tw(BegBtn,0.12,{BackgroundColor3=C.PNB}) end)

-- ══════════════════════════════════════════
--  LIVE SEARCH FILTER
-- ══════════════════════════════════════════
RS.Heartbeat:Wait() -- ensure AbsoluteSize settled before indexing
local allRows={}
local function indexBody(body)
    for _,ch in ipairs(body:GetChildren()) do
        if ch:IsA("Frame") then
            local tl=ch:FindFirstChildWhichIsA("TextLabel")
            if tl then
                table.insert(allRows,{f=ch, t=tl.Text:lower()})
            end
        end
    end
end
indexBody(EspBody); indexBody(CrossBody)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=SearchBox.Text:lower()
    if q=="" then
        for _,r in pairs(allRows) do r.f.Visible=true end
        return
    end
    for _,r in pairs(allRows) do
        r.f.Visible=(r.t:find(q,1,true)~=nil)
    end
end)

-- ══════════════════════════════════════════
print("[CinexHub] v3 loaded — float btn sempre visível")
print(IS_MOB and "  mobile: toca ✦ pra abrir/fechar" or "  PC: R SHIFT toggle")
