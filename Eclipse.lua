local library = {
    Renders = {},
    Connections = {},
    Folder = "Eclipse",
    Assets = "Assets",
    Configs = "Configs"
}
local utility = {}
local pages = {}
local sections = {}

do
    library.__index = library
    pages.__index = pages
    sections.__index = sections
end

local tws = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cre = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

local Theme = {
    Outer = Color3.fromRGB(15, 15, 18),
    Frame = Color3.fromRGB(22, 22, 26),
    FrameLight = Color3.fromRGB(28, 28, 34),
    Border = Color3.fromRGB(42, 42, 50),
    BorderLight = Color3.fromRGB(58, 58, 68),
    Accent = Color3.fromRGB(255, 120, 30),
    AccentDim = Color3.fromRGB(180, 84, 20),
    AccentBright = Color3.fromRGB(255, 158, 80),
    Text = Color3.fromRGB(236, 236, 242),
    TextMuted = Color3.fromRGB(156, 156, 166),
    TextDim = Color3.fromRGB(96, 96, 106),
    Item = Color3.fromRGB(30, 30, 36),
    ItemHover = Color3.fromRGB(42, 42, 50),
    TabDim = Color3.fromRGB(102, 102, 110),
    TabActive = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local function tween(instance, duration, style, direction, props)
    local t = tws:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(color1, color2)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function getViewport()
    return camera.ViewportSize
end

local function isTouch()
    return uis.TouchEnabled
end

local function clampWindow()
    local vp = getViewport()
    local w, h
    if isTouch() then
        w = math.clamp(vp.X * 0.78, 300, 380)
        h = math.clamp(vp.Y * 0.50, 280, 380)
    else
        w = math.clamp(vp.X * 0.60, 460, 720)
        h = math.clamp(vp.Y * 0.62, 380, 640)
    end
    return Vector2.new(w, h)
end

local function hsvToColor(h, s, v)
    return Color3.fromHSV(h, s, v)
end

local function colorToHex(c)
    local r = math.floor(c.R * 255 + 0.5)
    local g = math.floor(c.G * 255 + 0.5)
    local b = math.floor(c.B * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b), r, g, b
end

function utility:RenderObject(RenderType, RenderProperties, RenderHidden)
    local Render = Instance.new(RenderType)
    if RenderProperties and typeof(RenderProperties) == "table" then
        for Property, Value in pairs(RenderProperties) do
            if Property ~= "RenderTime" then
                Render[Property] = Value
            end
        end
    end
    library.Renders[#library.Renders + 1] = {Render, RenderProperties, RenderHidden, RenderProperties["RenderTime"] or nil}
    return Render
end

function utility:CreateConnection(ConnectionType, ConnectionCallback)
    local Connection = ConnectionType:Connect(ConnectionCallback)
    library.Connections[#library.Connections + 1] = Connection
    return Connection
end

function utility:MouseLocation()
    return uis:GetMouseLocation()
end

function utility:Serialise(Table)
    local Serialised = ""
    for Index, Value in pairs(Table) do
        Serialised = Serialised .. Value .. ", "
    end
    return Serialised:sub(0, #Serialised - 2)
end

function utility:Sort(Table1, Table2)
    local Table3 = {}
    for Index, Value in pairs(Table2) do
        if table.find(Table1, Index) then
            Table3[#Table3 + 1] = Value
        end
    end
    return Table3
end

function library:CreateWindow(Properties)
    Properties = Properties or {}
    local Window = {
        Pages = {},
        Accent = Properties.accent or Properties.Accent or Theme.Accent,
        Enabled = true,
        Minimized = false,
        Key = Enum.KeyCode.Z,
        Title = Properties.title or Properties.Title or "Eclipse"
    }

    do
        local touch = isTouch()
        local titleH = touch and 24 or 30
        local tabW = touch and 48 or 64
        local titleSize = touch and 10 or 12
        local initial = clampWindow()

        local ScreenGui = utility:RenderObject("ScreenGui", {
            DisplayOrder = 9999,
            Enabled = true,
            IgnoreGuiInset = true,
            Parent = cre,
            ResetOnSpawn = false,
            ZIndexBehavior = "Global"
        })

        local MainFrame = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, initial.X, 0, initial.Y),
            ClipsDescendants = true
        })
        corner(MainFrame, 6)

        local MainStroke = stroke(MainFrame, Theme.Border, 1, 0.2)

        local Shadow = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
            Position = MainFrame.Position,
            Size = UDim2.new(1, 16, 1, 16),
            ZIndex = 0,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Theme.Shadow,
            ImageTransparency = 0.34,
            ScaleType = "Slice",
            SliceCenter = Rect.new(10, 10, 118, 118)
        })

        local ShadowInner = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
            Position = MainFrame.Position,
            Size = UDim2.new(1, 8, 1, 8),
            ZIndex = 0,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Theme.Shadow,
            ImageTransparency = 0.5,
            ScaleType = "Slice",
            SliceCenter = Rect.new(10, 10, 118, 118)
        })

        local Glow = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
            Position = MainFrame.Position,
            Size = UDim2.new(1, 8, 1, 8),
            ZIndex = 0,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Theme.Accent,
            ImageTransparency = 0.95,
            ScaleType = "Slice",
            SliceCenter = Rect.new(10, 10, 118, 118)
        })

        local TitleBar = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = MainFrame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, titleH),
            ZIndex = 4,
            ClipsDescendants = true
        })
        corner(TitleBar, 6)

        local TitleBarGradient = gradient(TitleBar, Theme.FrameLight, Theme.Frame, 90)

        local TitleBarHighlight = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.94,
            BorderSizePixel = 0,
            Parent = TitleBar,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 5
        })

        local TitleBarLine = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = TitleBar,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 4
        })

        local TitleBarLineAccent = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Parent = TitleBar,
            Position = UDim2.new(0, 0, 1, -0.5),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 4
        })

        local TitleBarLogo = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(0, 12, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 5,
            Image = "rbxassetid://8547236654",
            ImageColor3 = Theme.Accent
        })

        local TitleBarLogoGlow = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(0, 20, 0.5, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 4,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Theme.Accent,
            ImageTransparency = 0.88,
            ScaleType = "Slice",
            SliceCenter = Rect.new(10, 10, 118, 118)
        })

        local TitleBarDivider = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent = TitleBar,
            Position = UDim2.new(0, 36, 0.5, -7),
            Size = UDim2.new(0, 1, 0, 14),
            ZIndex = 5
        })
        corner(TitleBarDivider, 1)

        local TitleBarText = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(0, 44, 0, 0),
            Size = UDim2.new(1, -112, 1, 0),
            ZIndex = 5,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>" .. string.upper(Window.Title) .. "</b> <font color='#6e6e76'>v1.0</font>",
            TextColor3 = Theme.Text,
            TextSize = titleSize,
            TextTruncate = "AtEnd",
            TextXAlignment = "Left",
            TextYAlignment = "Center"
        })

        local minTitleMaxW = (touch and 170 or 220) - 44 - 16 - 28 - 8
        local TitleBarTextMin = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(0, 44, 0, 0),
            Size = UDim2.new(0, math.max(40, minTitleMaxW), 1, 0),
            ZIndex = 5,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>" .. string.upper(Window.Title) .. "</b>",
            TextColor3 = Theme.Text,
            TextSize = titleSize,
            TextTruncate = "AtEnd",
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Visible = false
        })

        local MinimizeButton = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(1, -68, 0, 0),
            Size = UDim2.new(0, 28, 1, 0),
            ZIndex = 6,
            Text = "",
            AutoButtonColor = false
        })

        local MinimizeIcon = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = MinimizeButton,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            ZIndex = 6,
            Image = "rbxassetid://8548723563",
            ImageColor3 = Theme.TextMuted
        })

        local CloseButton = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = TitleBar,
            Position = UDim2.new(1, -34, 0, 0),
            Size = UDim2.new(0, 28, 1, 0),
            ZIndex = 6,
            Text = "",
            AutoButtonColor = false
        })

        local CloseIcon = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = CloseButton,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            ZIndex = 6,
            Image = "rbxassetid://8548757311",
            ImageColor3 = Theme.TextMuted
        })

        local searchH = touch and 22 or 26
        local SearchBar = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = MainFrame,
            Position = UDim2.new(0, 0, 0, titleH + 1),
            Size = UDim2.new(1, 0, 0, searchH),
            ZIndex = 4,
            ClipsDescendants = true
        })
        corner(SearchBar, 4)
        local SearchBarGradient = gradient(SearchBar, Theme.FrameLight, Theme.Frame, 90)
        local SearchBarStroke = stroke(SearchBar, Theme.Border, 1, 0.45)

        local SearchBarAccent = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SearchBar,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 5
        })
        corner(SearchBarAccent, 1)

        local SearchIconWrap = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SearchBar,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            ZIndex = 5
        })

        local SearchIconRing = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SearchIconWrap,
            Position = UDim2.new(0.4, 0, 0.4, 0),
            Size = UDim2.new(0, 8, 0, 8),
            ZIndex = 5
        })
        local SearchIconRingCorner = utility:RenderObject("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SearchIconRing
        })
        local SearchIconRingStroke = stroke(SearchIconRing, Theme.TextDim, 1.2, 0)

        local SearchIconHandle = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = Theme.TextDim,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = SearchIconWrap,
            Position = UDim2.new(0.7, 0, 0.7, 0),
            Size = UDim2.new(0, 5, 0, 1.4),
            ZIndex = 5,
            Rotation = 45
        })
        corner(SearchIconHandle, 1)

        local function setSearchIconColor(c)
            tween(SearchIconRingStroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Color = c })
            tween(SearchIconHandle, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundColor3 = c })
        end

        local SearchInput = utility:RenderObject("TextBox", {
            BackgroundTransparency = 1,
            Parent = SearchBar,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -58, 1, 0),
            ZIndex = 6,
            Font = Enum.Font.Code,
            PlaceholderText = "Search features...",
            PlaceholderColor3 = Theme.TextDim,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = touch and 10 or 11,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            ClearTextOnFocus = false,
            ClipsDescendants = true
        })

        local SearchClearBtn = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = SearchBar,
            Position = UDim2.new(1, -26, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            ZIndex = 6,
            Text = "",
            AutoButtonColor = false
        })

        local SearchClearIconWrap = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SearchClearBtn,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 6
        })

        local SearchClearLine1 = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.TextDim,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = SearchClearIconWrap,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 1.4),
            ZIndex = 6,
            Rotation = 45
        })
        corner(SearchClearLine1, 1)

        local SearchClearLine2 = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.TextDim,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = SearchClearIconWrap,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 1.4),
            ZIndex = 6,
            Rotation = -45
        })
        corner(SearchClearLine2, 1)

        local function setSearchClearVisible(visible)
            local targetTransparency = visible and 0 or 1
            tween(SearchClearLine1, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundTransparency = targetTransparency
            })
            tween(SearchClearLine2, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundTransparency = targetTransparency
            })
        end
        task.defer(function() setSearchClearVisible(false) end)

        local ContentContainer = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = MainFrame,
            Position = UDim2.new(0, 0, 0, titleH + searchH + 2),
            Size = UDim2.new(1, 0, 1, -(titleH + searchH + 2)),
            ZIndex = 2,
            ClipsDescendants = true
        })

        local ContainerStroke = stroke(ContentContainer, Theme.Border, 1, 0.4)
        corner(ContentContainer, 6)

        local ContainerGradient = gradient(ContentContainer, Theme.FrameLight, Theme.Frame, 90)

        local InnerFrame = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = ContentContainer,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 1, -8),
            ZIndex = 2,
            ClipsDescendants = true
        })
        corner(InnerFrame, 5)

        local TabsHolder = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = InnerFrame,
            Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(0, tabW, 1, -2),
            ZIndex = 3,
            ClipsDescendants = true
        })
        corner(TabsHolder, 5)

        local TabsHolderStroke = stroke(TabsHolder, Theme.Border, 1, 0.4)
        local TabsHolderGradient = gradient(TabsHolder, Theme.FrameLight, Theme.Frame, 90)

        local TabsDivider = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = InnerFrame,
            Position = UDim2.new(0, tabW, 0, 1),
            Size = UDim2.new(0, 1, 1, -2),
            ZIndex = 4
        })

        local TabsDividerAccent = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent = TabsDivider,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 18),
            ZIndex = 5
        })
        gradient(TabsDividerAccent, Theme.Accent, Color3.fromRGB(255, 255, 255), 90)

        local PagesHolder = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = InnerFrame,
            Position = UDim2.new(0, tabW + 1, 0, 1),
            Size = UDim2.new(1, -(tabW + 2), 1, -2),
            ZIndex = 3,
            ClipsDescendants = true
        })
        corner(PagesHolder, 5)

        local PagesHolderPattern = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = PagesHolder,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            Image = "rbxassetid://8547666218",
            ImageColor3 = Color3.fromRGB(28, 28, 32),
            ScaleType = "Tile",
            TileSize = UDim2.new(0, 10, 0, 10)
        })

        local PagesHolderGradient = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = PagesHolder,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Theme.Outer,
            ImageTransparency = 0.55
        })

        local TabsList = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 4),
            Parent = TabsHolder,
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Top"
        })

        local TabsPadding = utility:RenderObject("UIPadding", {
            Parent = TabsHolder,
            PaddingTop = UDim.new(0, 10)
        })

        local PagesFolder = utility:RenderObject("Folder", {
            Parent = PagesHolder
        })

        local MinimizedBar = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = MainFrame,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 7
        })

        local ResizeHandle, ResizeHandleIcon
        local resizing, resizeStart, resizeStartSize

        local sidePanelW = touch and 138 or 198
        local sidePanelGap = 4

        local function createSidePanel(side, titleText)
            local anchorX = side == "Left" and 1 or 0
            local Panel = utility:RenderObject("Frame", {
                AnchorPoint = Vector2.new(anchorX, 0.5),
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = ScreenGui,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, sidePanelW, 0, 0),
                ZIndex = 4,
                ClipsDescendants = true,
                Visible = false
            })
            corner(Panel, 6)
            stroke(Panel, Theme.Border, 1, 0.2)

            local PanelShadow = utility:RenderObject("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Parent = ScreenGui,
                Position = Panel.Position,
                Size = UDim2.new(0, sidePanelW + 10, 0, 10),
                ZIndex = 0,
                Image = "rbxassetid://1316045217",
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = 0.48,
                ScaleType = "Slice",
                SliceCenter = Rect.new(10, 10, 118, 118),
                Visible = false
            })

            local PanelShadowInner = utility:RenderObject("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Parent = ScreenGui,
                Position = Panel.Position,
                Size = UDim2.new(0, sidePanelW + 5, 0, 5),
                ZIndex = 0,
                Image = "rbxassetid://1316045217",
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = 0.62,
                ScaleType = "Slice",
                SliceCenter = Rect.new(10, 10, 118, 118),
                Visible = false
            })

            local PanelGlow = utility:RenderObject("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Parent = ScreenGui,
                Position = Panel.Position,
                Size = UDim2.new(0, sidePanelW + 8, 0, 8),
                ZIndex = 0,
                Image = "rbxassetid://1316045217",
                ImageColor3 = Theme.Accent,
                ImageTransparency = 0.95,
                ScaleType = "Slice",
                SliceCenter = Rect.new(10, 10, 118, 118),
                Visible = false
            })

            local PanelTitleBar = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Frame,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Panel,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, titleH),
                ZIndex = 5,
                ClipsDescendants = true
            })
            corner(PanelTitleBar, 6)
            gradient(PanelTitleBar, Theme.FrameLight, Theme.Frame, 90)

            utility:RenderObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.94,
                BorderSizePixel = 0,
                Parent = PanelTitleBar,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = 6
            })

            local PanelTitleLine = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Border,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = PanelTitleBar,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = 5
            })

            local PanelTitleAccent = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = PanelTitleBar,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 2, 1, 0),
                ZIndex = 6
            })
            corner(PanelTitleAccent, 1)

            utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = PanelTitleBar,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -42, 1, 0),
                ZIndex = 6,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b>" .. string.upper(titleText) .. "</b>",
                TextColor3 = Theme.Text,
                TextSize = titleSize,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local LockButton = utility:RenderObject("TextButton", {
                BackgroundColor3 = Theme.Frame,
                BackgroundTransparency = 0.6,
                Parent = PanelTitleBar,
                Position = UDim2.new(1, -60, 0.5, -9),
                Size = UDim2.new(0, 50, 0, 18),
                ZIndex = 6,
                Text = "未锁定",
                Font = Enum.Font.Code,
                TextColor3 = Theme.TextDim,
                TextSize = 10,
                AutoButtonColor = false
            })
            corner(LockButton, 4)
            stroke(LockButton, Theme.Border, 1, 0.4)

            local Content = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Frame,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Panel,
                Position = UDim2.new(0, 0, 0, titleH + 1),
                Size = UDim2.new(1, 0, 1, -(titleH + 1)),
                ZIndex = 4,
                ClipsDescendants = true
            })
            corner(Content, 6)
            stroke(Content, Theme.Border, 1, 0.4)
            gradient(Content, Theme.FrameLight, Theme.Frame, 90)

            utility:RenderObject("UIListLayout", {
                Parent = Content,
                Padding = UDim.new(0, 8),
                FillDirection = "Vertical",
                HorizontalAlignment = "Center",
                VerticalAlignment = "Center",
                SortOrder = "LayoutOrder"
            })
            utility:RenderObject("UIPadding", {
                Parent = Content,
                PaddingTop = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 14),
                PaddingLeft = UDim.new(0, 0),
                PaddingRight = UDim.new(0, 0)
            })

            local state = {
                Panel = Panel,
                Shadow = PanelShadow,
                ShadowInner = PanelShadowInner,
                Glow = PanelGlow,
                Content = Content,
                Locked = false,
                LockedPos = nil,
                LockedSize = nil
            }

            local function setLockVisual(locked)
                if locked then
                    LockButton.Text = "锁定"
                    tween(LockButton, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Color3.fromRGB(40, 24, 14),
                        TextColor3 = Theme.AccentBright
                    })
                else
                    LockButton.Text = "未锁定"
                    tween(LockButton, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Frame,
                        TextColor3 = Theme.TextDim
                    })
                end
            end
            task.defer(function() setLockVisual(false) end)

            local pdragging, pdragInput, pdragStart, pdragPos

            local function updatePanelDrag(input)
                local delta = input.Position - pdragStart
                local nx = pdragPos.X.Offset + delta.X
                local ny = pdragPos.Y.Offset + delta.Y
                Panel.Position = UDim2.new(0.5, nx, 0.5, ny)
                PanelShadow.Position = Panel.Position
                PanelGlow.Position = Panel.Position
                state.LockedPos = Panel.Position
            end

            utility:CreateConnection(LockButton.MouseButton1Click, function()
                state.Locked = not state.Locked
                if state.Locked then
                    state.LockedPos = Panel.Position
                    state.LockedSize = Panel.Size
                    setLockVisual(true)
                else
                    state.LockedPos = nil
                    state.LockedSize = nil
                    setLockVisual(false)
                end
            end)

            utility:CreateConnection(LockButton.MouseEnter, function()
                if not state.Locked then
                    tween(LockButton, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.ItemHover,
                        TextColor3 = Theme.Text
                    })
                end
            end)
            utility:CreateConnection(LockButton.MouseLeave, function()
                if not state.Locked then
                    tween(LockButton, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Frame,
                        TextColor3 = Theme.TextDim
                    })
                end
            end)

            utility:CreateConnection(PanelTitleBar.InputBegan, function(input)
                if not state.Locked then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    pdragging = true
                    pdragStart = input.Position
                    pdragPos = Panel.Position
                end
            end)
            utility:CreateConnection(PanelTitleBar.InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    pdragInput = input
                end
            end)
            utility:CreateConnection(uis.InputChanged, function(input)
                if input == pdragInput and pdragging then
                    updatePanelDrag(input)
                end
            end)
            utility:CreateConnection(uis.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    pdragging = false
                end
            end)

            return state
        end

        local function makeInfoRow(parent, labelText, order)
            local row = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                Parent = parent,
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 5,
                LayoutOrder = order or 0
            })
            local rowBg = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0.55,
                BorderSizePixel = 0,
                Parent = row,
                Position = UDim2.new(0, 8, 0, 1),
                Size = UDim2.new(1, -16, 1, -2),
                ZIndex = 5
            })
            corner(rowBg, 3)
            local dot = utility:RenderObject("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Parent = row,
                Position = UDim2.new(0, 14, 0.5, 0),
                Size = UDim2.new(0, 3, 0, 3),
                ZIndex = 6
            })
            corner(dot, 2)
            utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = row,
                Position = UDim2.new(0, 22, 0, 0),
                Size = UDim2.new(0.5, -22, 1, 0),
                ZIndex = 6,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<font color='#62626a'>" .. labelText .. "</font>",
                TextColor3 = Theme.TextDim,
                TextSize = 9,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })
            local val = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = row,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -18, 1, 0),
                ZIndex = 6,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<font color='#989aa2'>—</font>",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Right",
                TextYAlignment = "Center"
            })
            return val
        end

        local playerPanel = createSidePanel("Left", "Player")
        local serverPanel = createSidePanel("Right", "Server")

        local ppContent = playerPanel.Content
        local PlayerAvatar = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Theme.Item,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = ppContent,
            Size = UDim2.new(0, 56, 0, 56),
            ZIndex = 5,
            Image = "",
            LayoutOrder = 1
        })
        corner(PlayerAvatar, 28)
        stroke(PlayerAvatar, Theme.Accent, 1, 0.45)

        local PlayerName = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = ppContent,
            Size = UDim2.new(1, -20, 0, 16),
            ZIndex = 5,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>...</b>",
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextTruncate = "AtEnd",
            TextXAlignment = "Center",
            TextYAlignment = "Center",
            LayoutOrder = 2
        })

        local PlayerAccentLine = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0,
            Parent = ppContent,
            Size = UDim2.new(0, 28, 0, 1),
            ZIndex = 5,
            LayoutOrder = 3
        })
        corner(PlayerAccentLine, 1)

        local PlayerAccountVal = makeInfoRow(ppContent, "ACCOUNT", 4)
        local PlayerIdVal = makeInfoRow(ppContent, "USER ID", 5)

        local spContent = serverPanel.Content
        local ServerIconBg = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Item,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = spContent,
            Size = UDim2.new(0, 56, 0, 56),
            ZIndex = 5,
            LayoutOrder = 1
        })
        corner(ServerIconBg, 28)
        stroke(ServerIconBg, Theme.Accent, 1, 0.45)

        local ServerIconImage = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ServerIconBg,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -6, 1, -6),
            ZIndex = 6,
            Image = "rbxassetid://7743868380",
            ImageTransparency = 0
        })
        corner(ServerIconImage, 25)

        local ServerIconFallback = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ServerIconBg,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 24, 0, 24),
            ZIndex = 7,
            Image = "rbxassetid://8547310764",
            ImageColor3 = Theme.Accent,
            ImageTransparency = 0
        })

        local ServerName = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = spContent,
            Size = UDim2.new(1, -20, 0, 16),
            ZIndex = 5,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>...</b>",
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextTruncate = "AtEnd",
            TextXAlignment = "Center",
            TextYAlignment = "Center",
            LayoutOrder = 2
        })

        local ServerAccentLine = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0,
            Parent = spContent,
            Size = UDim2.new(0, 28, 0, 1),
            ZIndex = 5,
            LayoutOrder = 3
        })
        corner(ServerAccentLine, 1)

        local ServerUptimeVal = makeInfoRow(spContent, "UPTIME", 4)
        local ServerPlayersVal = makeInfoRow(spContent, "PLAYERS", 5)

        local Players = game:GetService("Players")
        local MarketplaceService = game:GetService("MarketplaceService")
        local RunService = game:GetService("RunService")
        local HttpService = game:GetService("HttpService")
        local lp = Players.LocalPlayer

        local function fmtDuration(sec)
            sec = math.max(0, math.floor(sec))
            local h = math.floor(sec / 3600)
            local m = math.floor((sec % 3600) / 60)
            local s = sec % 60
            if h > 0 then return string.format("%dh %02dm", h, m) end
            if m > 0 then return string.format("%dm %02ds", m, s) end
            return string.format("%ds", s)
        end

        local function getServerIcon()
            local universeId = game.GameId
            local rbxthumbFallback = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=150&h=150"
            local reqFn = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
            if not reqFn then return rbxthumbFallback end
            local success, result = pcall(function()
                local req = reqFn({
                    Url = "https://thumbnails.roblox.com/v1/games/icons?universeIds=" .. tostring(universeId) .. "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false",
                    Method = "GET",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Referer"] = "https://www.roblox.com/"
                    }
                })
                if req and req.StatusCode == 200 and req.Body then
                    local List = HttpService:JSONDecode(req.Body)
                    if List and List.data and List.data[1] and List.data[1].imageUrl then
                        return List.data[1].imageUrl
                    end
                end
                return rbxthumbFallback
            end)
            if not success then return rbxthumbFallback end
            return result or rbxthumbFallback
        end

        if lp then
            PlayerName.Text = "<b>" .. lp.DisplayName .. "</b>"
            PlayerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150"
            local ageDays = lp.AccountAge or 0
            local yrs = math.floor(ageDays / 365)
            local dRem = ageDays % 365
            local ageText = yrs > 0 and (yrs .. "y " .. dRem .. "d") or (ageDays .. "d")
            PlayerAccountVal.Text = "<font color='#989aa2'>" .. ageText .. "</font>"
            PlayerIdVal.Text = "<font color='#989aa2'>" .. tostring(lp.UserId) .. "</font>"
        end

        task.spawn(function()
            local ok, info = pcall(function()
                return MarketplaceService:GetProductInfo(game.PlaceId)
            end)
            if ok and info and info.Name then
                ServerName.Text = "<b>" .. info.Name .. "</b>"
            else
                ServerName.Text = "<b>SERVER</b>"
            end
        end)

        task.spawn(function()
            local universeId = game.GameId
            local httpIcon = getServerIcon()
            local httpUrl = httpIcon
            local isHttpUrl = httpUrl and (string.find(httpUrl, "^https?://") ~= nil)
            local rbxthumb = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=150&h=150"
            local staticFallback = "rbxassetid://7743868380"
            local function tryIcon(url)
                if not url then return false end
                ServerIconImage.Image = url
                task.wait(0.6)
                local ok, loaded = pcall(function() return ServerIconImage:IsLoaded() end)
                if ok and loaded then
                    tween(ServerIconFallback, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                        ImageTransparency = 1
                    })
                    return true
                end
                return false
            end
            if isHttpUrl then
                if not tryIcon(httpUrl) then
                    if not tryIcon(rbxthumb) then
                        ServerIconImage.Image = staticFallback
                    end
                end
            else
                if not tryIcon(rbxthumb) then
                    if not tryIcon(httpUrl) then
                        ServerIconImage.Image = staticFallback
                    end
                end
            end
        end)

        local sessionStart = os.time()
        local function refreshServerStats()
            ServerUptimeVal.Text = "<font color='#989aa2'>" .. fmtDuration(os.time() - sessionStart) .. "</font>"
            local cur = #Players:GetPlayers()
            local mx = Players.MaxPlayers or 0
            ServerPlayersVal.Text = "<font color='#989aa2'>" .. cur .. " / " .. mx .. "</font>"
        end
        refreshServerStats()

        utility:CreateConnection(Players.PlayerAdded, refreshServerStats)
        utility:CreateConnection(Players.PlayerRemoving, refreshServerStats)
        task.spawn(function()
            while true do
                task.wait(1)
                ServerUptimeVal.Text = "<font color='#989aa2'>" .. fmtDuration(os.time() - sessionStart) .. "</font>"
            end
        end)

        local function refreshSidePanels()
            local mfPos = MainFrame.Position
            local mfSize = MainFrame.Size
            local mfAnchor = MainFrame.AnchorPoint
            local cx, cy
            if mfAnchor.X == 0.5 and mfAnchor.Y == 0.5 then
                cx = mfPos.X.Offset
                cy = mfPos.Y.Offset
            else
                cx = mfPos.X.Offset + mfSize.X.Offset / 2
                cy = mfPos.Y.Offset + mfSize.Y.Offset / 2
            end
            local halfW = mfSize.X.Offset / 2
            local h = mfSize.Y.Offset
            local leftX = cx - halfW - sidePanelGap
            local rightX = cx + halfW + sidePanelGap
            local function applyPanel(p, x)
                if p.Locked and p.LockedPos and p.LockedSize then
                    p.Panel.Position = p.LockedPos
                    p.Panel.Size = p.LockedSize
                else
                    p.Panel.Position = UDim2.new(0.5, x, 0.5, cy)
                    p.Panel.Size = UDim2.new(0, sidePanelW, 0, h)
                end
                p.Shadow.Position = p.Panel.Position
                p.Shadow.Size = UDim2.new(0, p.Panel.Size.X.Offset + 10, 0, p.Panel.Size.Y.Offset + 10)
                p.ShadowInner.Position = p.Panel.Position
                p.ShadowInner.Size = UDim2.new(0, p.Panel.Size.X.Offset + 5, 0, p.Panel.Size.Y.Offset + 5)
                p.Glow.Position = p.Panel.Position
                p.Glow.Size = UDim2.new(0, p.Panel.Size.X.Offset + 8, 0, p.Panel.Size.Y.Offset + 8)
            end
            applyPanel(playerPanel, leftX)
            applyPanel(serverPanel, rightX)
        end

        local function setSidePanelsVisible(state)
            playerPanel.Panel.Visible = state
            playerPanel.Shadow.Visible = state
            playerPanel.ShadowInner.Visible = state
            playerPanel.Glow.Visible = state
            serverPanel.Panel.Visible = state
            serverPanel.Shadow.Visible = state
            serverPanel.ShadowInner.Visible = state
            serverPanel.Glow.Visible = state
        end

        local function fadeSidePanelsIn()
            setSidePanelsVisible(true)
            refreshSidePanels()
        end

        local function fadeSidePanelsOut()
            setSidePanelsVisible(false)
        end

        utility:CreateConnection(MainFrame:GetPropertyChangedSignal("Size"), refreshSidePanels)
        utility:CreateConnection(MainFrame:GetPropertyChangedSignal("Position"), refreshSidePanels)

        local function refreshShadowOnly()
            local mfPos = MainFrame.Position
            local mfSize = MainFrame.Size
            local mfAnchor = MainFrame.AnchorPoint
            local centerPos
            if mfAnchor.X == 0.5 and mfAnchor.Y == 0.5 then
                centerPos = mfPos
            else
                local w = mfSize.X.Offset
                local h = mfSize.Y.Offset
                centerPos = UDim2.new(mfPos.X.Scale, mfPos.X.Offset + w / 2, mfPos.Y.Scale, mfPos.Y.Offset + h / 2)
            end
            Shadow.Position = centerPos
            Shadow.Size = UDim2.new(0, mfSize.X.Offset + 16, 0, mfSize.Y.Offset + 16)
            ShadowInner.Position = centerPos
            ShadowInner.Size = UDim2.new(0, mfSize.X.Offset + 8, 0, mfSize.Y.Offset + 8)
            Glow.Position = centerPos
            Glow.Size = UDim2.new(0, mfSize.X.Offset + 8, 0, mfSize.Y.Offset + 8)
        end

        local function refreshShadow()
            refreshShadowOnly()
            refreshSidePanels()
        end

        ResizeHandle = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = MainFrame,
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 8,
            Text = "",
            AutoButtonColor = false
        })

        ResizeHandleIcon = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = ResizeHandle,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 8
        })

        local function makeGripLine(x, y, w, h)
            local line = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.TextDim,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = ResizeHandleIcon,
                Position = UDim2.new(0, x, 0, y),
                Size = UDim2.new(0, w, 0, h),
                ZIndex = 9
            })
            corner(line, 1)
            return line
        end
        local gripLines = {
            makeGripLine(2, 7, 2, 1),
            makeGripLine(5, 7, 2, 1),
            makeGripLine(8, 7, 2, 1),
            makeGripLine(5, 4, 2, 1),
            makeGripLine(8, 4, 2, 1),
            makeGripLine(8, 1, 2, 1)
        }

        local function makeEdgeHitbox(side)
            local size, pos
            if side == "Left" then
                size = UDim2.new(0, 4, 1, -(titleH + 12))
                pos = UDim2.new(0, 0, 0, titleH + 4)
            elseif side == "Right" then
                size = UDim2.new(0, 4, 1, -(titleH + 12))
                pos = UDim2.new(1, -4, 0, titleH + 4)
            elseif side == "Bottom" then
                size = UDim2.new(1, -8, 0, 4)
                pos = UDim2.new(0, 4, 1, -4)
            elseif side == "TopLeft" then
                size = UDim2.new(0, 8, 0, 8)
                pos = UDim2.new(0, 0, 0, 0)
            elseif side == "BottomLeft" then
                size = UDim2.new(0, 8, 0, 8)
                pos = UDim2.new(0, 0, 1, -8)
            elseif side == "BottomRight" then
                size = UDim2.new(0, 8, 0, 8)
                pos = UDim2.new(1, -8, 1, -8)
            elseif side == "TopRight" then
                size = UDim2.new(0, 8, 0, 8)
                pos = UDim2.new(1, -8, 0, 0)
            end
            local hitbox = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = MainFrame,
                Position = pos,
                Size = size,
                ZIndex = 7,
                Text = "",
                AutoButtonColor = false,
                Active = false
            })
            return hitbox
        end

        local EdgeLeft = makeEdgeHitbox("Left")
        local EdgeRight = makeEdgeHitbox("Right")
        local EdgeBottom = makeEdgeHitbox("Bottom")
        local EdgeTopLeft = makeEdgeHitbox("TopLeft")
        local EdgeBottomLeft = makeEdgeHitbox("BottomLeft")
        local EdgeTopRight = makeEdgeHitbox("TopRight")

        local edgeMoveActive = false
        local edgeMoveStartInput, edgeMoveStartPos

        local function beginEdgeMove(input)
            if Window.Minimized then return end
            edgeMoveActive = true
            edgeMoveStartInput = input.Position
            edgeMoveStartPos = MainFrame.Position
        end

        local function updateEdgeMove(input)
            if not edgeMoveActive then return end
            if cpLocked then return end
            local delta = input.Position - edgeMoveStartInput
            local nx = edgeMoveStartPos.X.Offset + delta.X
            local ny = edgeMoveStartPos.Y.Offset + delta.Y
            MainFrame.Position = UDim2.new(edgeMoveStartPos.X.Scale, nx, edgeMoveStartPos.Y.Scale, ny)
            if Window.Minimized and MainFrame.AnchorPoint == Vector2.new(0, 0) then
                local sz = MainFrame.Size
                preMinimizeCenter = UDim2.new(0.5, nx + sz.X.Offset / 2, 0.5, ny + sz.Y.Offset / 2)
            end
            refreshShadowOnly()
        end

        local function endEdgeMove()
            edgeMoveActive = false
        end

        for _, hb in ipairs({EdgeLeft, EdgeRight, EdgeBottom, EdgeTopLeft, EdgeBottomLeft, EdgeTopRight}) do
            utility:CreateConnection(hb.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    beginEdgeMove(input)
                end
            end)
        end

        utility:CreateConnection(uis.InputChanged, function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local vp = getViewport()
                local minW = touch and 300 or 460
                local minH = touch and 280 or 380
                local maxW = math.max(minW, vp.X - 20)
                local maxH = math.max(minH, vp.Y - 20)
                local newW = math.clamp(resizeStartSize.X + delta.X, minW, maxW)
                local newH = math.clamp(resizeStartSize.Y + delta.Y, minH, maxH)
                MainFrame.Size = UDim2.new(0, newW, 0, newH)
                Window._customSize = Vector2.new(newW, newH)
                refreshShadowOnly()
            elseif edgeMoveActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateEdgeMove(input)
            end
        end)

        utility:CreateConnection(uis.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if resizing then
                    resizing = false
                end
                if edgeMoveActive then
                    endEdgeMove()
                end
            end
        end)

        utility:CreateConnection(ResizeHandle.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if Window.Minimized then return end
                resizing = true
                resizeStart = input.Position
                resizeStartSize = Vector2.new(MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset)
            end
        end)

        utility:CreateConnection(ResizeHandle.MouseEnter, function()
            for _, line in ipairs(gripLines) do
                tween(line, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Accent
                })
            end
        end)

        utility:CreateConnection(ResizeHandle.MouseLeave, function()
            for _, line in ipairs(gripLines) do
                tween(line, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.TextDim
                })
            end
        end)

        local preMinimizeCenter = nil

        local function setMinimized(state)
            Window.Minimized = state
            local minW = touch and 170 or 220
            local targetH = state and titleH or (Window._customSize and Window._customSize.Y or clampWindow().Y)
            local targetW = state and minW or (Window._customSize and Window._customSize.X or clampWindow().X)

            if state then
                local curSize = MainFrame.Size
                local curPos = MainFrame.Position
                if not preMinimizeCenter then
                    preMinimizeCenter = curPos
                end
                local topLeftOffsetX = curPos.X.Offset - curSize.X.Offset / 2
                local topLeftOffsetY = curPos.Y.Offset - curSize.Y.Offset / 2
                local centerOffsetX = topLeftOffsetX + targetW / 2
                local centerOffsetY = topLeftOffsetY + targetH / 2
                MainFrame.AnchorPoint = Vector2.new(0, 0)
                MainFrame.Position = UDim2.new(0.5, topLeftOffsetX, 0.5, topLeftOffsetY)
                tween(MainFrame, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW, 0, targetH),
                    BackgroundTransparency = 0
                })
                tween(Shadow, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 16, 0, targetH + 16),
                    Position = UDim2.new(0.5, centerOffsetX, 0.5, centerOffsetY),
                    ImageTransparency = 0.45
                })
                tween(ShadowInner, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 8, 0, targetH + 8),
                    Position = UDim2.new(0.5, centerOffsetX, 0.5, centerOffsetY),
                    ImageTransparency = 0.6
                })
                tween(Glow, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 8, 0, targetH + 8),
                    Position = UDim2.new(0.5, centerOffsetX, 0.5, centerOffsetY),
                    ImageTransparency = 1
                })
            else
                local restorePos = preMinimizeCenter or UDim2.new(0.5, 0, 0.5, 0)
                MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                MainFrame.Position = restorePos
                tween(MainFrame, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW, 0, targetH),
                    BackgroundTransparency = 0
                })
                tween(Shadow, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 16, 0, targetH + 16),
                    Position = restorePos,
                    ImageTransparency = 0.34
                })
                tween(ShadowInner, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 8, 0, targetH + 8),
                    Position = restorePos,
                    ImageTransparency = 0.5
                })
                tween(Glow, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, targetW + 8, 0, targetH + 8),
                    Position = restorePos,
                    ImageTransparency = 0.95
                })
                preMinimizeCenter = nil
            end
            tween(MinimizedBar, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                BackgroundTransparency = state and 0 or 1
            })
            tween(MinimizeIcon, 0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = state and Theme.Accent or Theme.TextMuted
            })

            if state then
                tween(ContentContainer, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                    BackgroundTransparency = 1
                })
                tween(SearchBar, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                    BackgroundTransparency = 1
                })
                task.delay(0.18, function()
                    if Window.Minimized then
                        ContentContainer.Visible = false
                        SearchBar.Visible = false
                    end
                end)
                tween(TitleBarText, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextTransparency = 1
                })
                TitleBarTextMin.TextTransparency = 1
                TitleBarTextMin.Visible = true
                task.delay(0.12, function()
                    if Window.Minimized then
                        tween(TitleBarTextMin, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextTransparency = 0
                        })
                        TitleBarText.Visible = false
                    end
                end)
            else
                ContentContainer.Visible = true
                ContentContainer.BackgroundTransparency = 1
                SearchBar.Visible = true
                SearchBar.BackgroundTransparency = 1
                task.delay(0.06, function()
                    if not Window.Minimized then
                        tween(ContentContainer, 0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundTransparency = 0
                        })
                        tween(SearchBar, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundTransparency = 0
                        })
                    end
                end)
                tween(TitleBarTextMin, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextTransparency = 1
                })
                TitleBarText.TextTransparency = 1
                TitleBarText.Visible = true
                task.delay(0.12, function()
                    if not Window.Minimized then
                        tween(TitleBarText, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextTransparency = 0
                        })
                        TitleBarTextMin.Visible = false
                    end
                end)
            end
            if state then
                fadeSidePanelsOut()
            else
                fadeSidePanelsIn()
            end

            if ResizeHandle then
                ResizeHandle.Visible = not state
            end

            task.delay(0.4, refreshShadow)
        end

        local dragging, dragInput, dragStart, startPos
        local cpLocked = false

        local function updateDrag(input)
            if cpLocked then return end
            local delta = input.Position - dragStart
            local nx = startPos.X.Offset + delta.X
            local ny = startPos.Y.Offset + delta.Y
            MainFrame.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
            if Window.Minimized and MainFrame.AnchorPoint == Vector2.new(0, 0) then
                local sz = MainFrame.Size
                preMinimizeCenter = UDim2.new(0.5, nx + sz.X.Offset / 2, 0.5, ny + sz.Y.Offset / 2)
            end
            refreshShadowOnly()
        end

        utility:CreateConnection(TitleBar.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)

        utility:CreateConnection(TitleBar.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        utility:CreateConnection(uis.InputChanged, function(input)
            if input == dragInput and dragging then
                updateDrag(input)
            end
        end)

        utility:CreateConnection(uis.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        utility:CreateConnection(camera:GetPropertyChangedSignal("ViewportSize"), function()
            if not Window.Minimized then
                local sz = Window._customSize or clampWindow()
                local vp = getViewport()
                local minW = touch and 300 or 460
                local minH = touch and 280 or 380
                local maxW = math.max(minW, vp.X - 20)
                local maxH = math.max(minH, vp.Y - 20)
                sz = Vector2.new(math.clamp(sz.X, minW, maxW), math.clamp(sz.Y, minH, maxH))
                Window._customSize = sz
                tween(MainFrame, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, sz.X, 0, sz.Y)
                })
                task.delay(0.3, refreshShadow)
            end
        end)

        utility:CreateConnection(MinimizeButton.MouseButton1Click, function()
            setMinimized(not Window.Minimized)
        end)

        utility:CreateConnection(MinimizeButton.MouseEnter, function()
            tween(MinimizeIcon, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.Text,
                Size = UDim2.new(0, 14, 0, 14)
            })
        end)

        utility:CreateConnection(MinimizeButton.MouseLeave, function()
            tween(MinimizeIcon, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Window.Minimized and Theme.Accent or Theme.TextMuted,
                Size = UDim2.new(0, 12, 0, 12)
            })
        end)

        utility:CreateConnection(CloseButton.MouseButton1Click, function()
            Window:Unload()
        end)

        utility:CreateConnection(CloseButton.MouseEnter, function()
            tween(CloseIcon, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Color3.fromRGB(255, 90, 90),
                Size = UDim2.new(0, 14, 0, 14)
            })
        end)

        utility:CreateConnection(CloseButton.MouseLeave, function()
            tween(CloseIcon, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.TextMuted,
                Size = UDim2.new(0, 12, 0, 12)
            })
        end)

        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        Shadow.ImageTransparency = 1
        ShadowInner.ImageTransparency = 1
        Glow.ImageTransparency = 1
        TitleBar.Visible = false
        ContentContainer.Visible = false
        SearchBar.Visible = false

        local SplashFrame = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = MainFrame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 20,
            ClipsDescendants = true
        })

        local SplashLogo = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = SplashFrame,
            Position = UDim2.new(0.5, 0, 0.5, -22),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 21,
            Image = "rbxassetid://8547236654",
            ImageColor3 = Theme.Accent,
            ImageTransparency = 1
        })

        local SplashTitle = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = SplashFrame,
            Position = UDim2.new(0, 0, 0.5, 8),
            Size = UDim2.new(1, 0, 0, 14),
            ZIndex = 21,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>ECLIPSE</b>",
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            TextSize = 13,
            TextXAlignment = "Center",
            TextYAlignment = "Center"
        })

        local SplashVersion = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = SplashFrame,
            Position = UDim2.new(0, 0, 0.5, 24),
            Size = UDim2.new(1, 0, 0, 10),
            ZIndex = 21,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<font color='#6e6e76'>v1.0 // initializing</font>",
            TextColor3 = Theme.TextMuted,
            TextTransparency = 1,
            TextSize = 9,
            TextXAlignment = "Center",
            TextYAlignment = "Center"
        })

        local SplashBarBg = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SplashFrame,
            Position = UDim2.new(0.5, 0, 0.5, 48),
            Size = UDim2.new(0, 0, 0, 2),
            ZIndex = 21
        })
        corner(SplashBarBg, 1)
        stroke(SplashBarBg, Theme.Border, 1, 0.5)

        local SplashBarFill = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = SplashBarBg,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 22
        })
        corner(SplashBarFill, 1)
        gradient(SplashBarFill, Color3.fromRGB(255, 150, 60), Theme.Accent, 0)

        local SplashDots = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = SplashFrame,
            Position = UDim2.new(0, 0, 0.5, 60),
            Size = UDim2.new(1, 0, 0, 10),
            ZIndex = 21,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "",
            TextColor3 = Theme.TextDim,
            TextTransparency = 1,
            TextSize = 9,
            TextXAlignment = "Center",
            TextYAlignment = "Center"
        })

        task.wait(0.05)
        local sz = clampWindow()

        tween(MainFrame, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, sz.X, 0, sz.Y),
            BackgroundTransparency = 0
        })
        tween(Shadow, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, sz.X + 16, 0, sz.Y + 16),
            ImageTransparency = 0.34
        })
        tween(ShadowInner, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, sz.X + 8, 0, sz.Y + 8),
            ImageTransparency = 0.5
        })
        tween(Glow, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, sz.X + 8, 0, sz.Y + 8),
            ImageTransparency = 0.95
        })
        tween(SplashFrame, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundTransparency = 0
        })

        task.wait(0.18)
        tween(SplashLogo, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, 34, 0, 34),
            ImageTransparency = 0
        })
        tween(SplashTitle, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            TextTransparency = 0
        })
        tween(SplashVersion, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            TextTransparency = 0
        })
        tween(SplashBarBg, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, 160, 0, 2),
            BackgroundTransparency = 0
        })
        tween(SplashDots, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            TextTransparency = 0
        })

        task.wait(0.28)
        local progressMessages = {".", "..", "...", "ready"}
        local msgIdx = 1
        SplashDots.Text = progressMessages[1]
        tween(SplashBarFill, 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0
        })
        for i = 1, 3 do
            task.delay(0.18 * i, function()
                msgIdx = i + 1
                SplashDots.Text = progressMessages[msgIdx]
            end)
        end

        task.wait(0.85)
        tween(SplashLogo, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            ImageTransparency = 1,
            Size = UDim2.new(0, 26, 0, 26)
        })
        tween(SplashTitle, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            TextTransparency = 1
        })
        tween(SplashVersion, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            TextTransparency = 1
        })
        tween(SplashBarBg, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            BackgroundTransparency = 1
        })
        tween(SplashBarFill, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            BackgroundTransparency = 1
        })
        tween(SplashDots, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            TextTransparency = 1
        })
        task.wait(0.16)
        TitleBar.Visible = true
        ContentContainer.Visible = true
        SearchBar.Visible = true
        fadeSidePanelsIn()
        tween(SplashFrame, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
            BackgroundTransparency = 1
        })
        task.delay(0.24, function()
            SplashFrame.Visible = false
        end)

        function Window:SetPage(Page)
            for index, page in pairs(Window.Pages) do
                if page.Open and page ~= Page then
                    page:Set(false)
                end
            end
        end

        function Window:Fade(state)
            for index, render in pairs(library.Renders) do
                if not render[3] then
                    local cls = render[1].ClassName
                    local t = render[4] or 0.28
                    local prop = {}
                    if cls == "Frame" and (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                        prop.BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1
                    elseif cls == "ImageLabel" then
                        if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                            prop.BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1
                        end
                        if (render[2]["ImageTransparency"] or 0) ~= 1 then
                            prop.ImageTransparency = state and (render[2]["ImageTransparency"] or 0) or 1
                        end
                    elseif cls == "TextLabel" or cls == "TextButton" then
                        if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                            prop.BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1
                        end
                        if (render[2]["TextTransparency"] or 0) ~= 1 then
                            prop.TextTransparency = state and (render[2]["TextTransparency"] or 0) or 1
                        end
                    elseif cls == "TextBox" then
                        if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                            prop.BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1
                        end
                        if (render[2]["TextTransparency"] or 0) ~= 1 then
                            prop.TextTransparency = state and (render[2]["TextTransparency"] or 0) or 1
                        end
                    elseif cls == "ScrollingFrame" then
                        if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                            prop.BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1
                        end
                        if (render[2]["ScrollBarImageTransparency"] or 0) ~= 1 then
                            prop.ScrollBarImageTransparency = state and (render[2]["ScrollBarImageTransparency"] or 0) or 1
                        end
                    end
                    if next(prop) then
                        tws:Create(render[1], TweenInfo.new(t, Enum.EasingStyle.Quad, state and Enum.EasingDirection.Out or Enum.EasingDirection.In), prop):Play()
                    end
                end
            end
        end

        function Window:Unload()
            tween(MainFrame, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            })
            tween(Shadow, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                Size = UDim2.new(0, 0, 0, 0),
                ImageTransparency = 1
            })
            tween(ShadowInner, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                Size = UDim2.new(0, 0, 0, 0),
                ImageTransparency = 1
            })
            tween(Glow, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                Size = UDim2.new(0, 0, 0, 0),
                ImageTransparency = 1
            })
            task.wait(0.32)
            ScreenGui:Remove()
            for index, connection in pairs(library.Connections) do
                connection:Disconnect()
            end
            library = nil
            utility = nil
        end

        Window["TabsHolder"] = TabsHolder
        Window["PagesHolder"] = PagesFolder
        Window["MainFrame"] = MainFrame

        local performSearch

        utility:CreateConnection(uis.InputBegan, function(Input)
            if Input.KeyCode and Input.KeyCode == Window.Key then
                local focused = uis:GetFocusedTextBox()
                if focused == SearchInput then return end
                Window.Enabled = not Window.Enabled
                Window:Fade(Window.Enabled)
            elseif Input.KeyCode == Enum.KeyCode.Escape then
                if SearchInput and SearchInput.Text ~= "" then
                    SearchInput.Text = ""
                    if performSearch then performSearch("") end
                    SearchInput:ReleaseFocus(true)
                end
            end
        end)

        local lockWinW = 100
        local lockWinH = 28

        local LockWin = utility:RenderObject("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = ScreenGui,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, lockWinW, 0, lockWinH),
            ZIndex = 12,
            ClipsDescendants = true,
            Visible = false,
            Text = "",
            AutoButtonColor = false
        })
        corner(LockWin, 4)
        local LockWinStroke = stroke(LockWin, Theme.Border, 1, 0.2)

        local LockWinShadow = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
            Position = LockWin.Position,
            Size = UDim2.new(0, lockWinW + 10, 0, lockWinH + 10),
            ZIndex = 0,
            Image = "rbxassetid://1316045217",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = "Slice",
            SliceCenter = Rect.new(10, 10, 118, 118),
            Visible = false
        })

        local LockWinLabel = utility:RenderObject("TextLabel", {
            BackgroundTransparency = 1,
            Parent = LockWin,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 13,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<font color='#9696a0'>未锁定</font>",
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            TextXAlignment = "Center",
            TextYAlignment = "Center"
        })

        local function setLockDrag(locked)
            cpLocked = locked
            if locked then
                tween(LockWin, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Color3.fromRGB(40, 24, 14)
                })
                tween(LockWinStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Color = Theme.Accent,
                    Transparency = 0.1
                })
                tween(LockWinLabel, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.AccentBright
                })
                LockWinLabel.Text = "<b>已锁定</b>"
            else
                tween(LockWin, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Outer
                })
                tween(LockWinStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Color = Theme.Border,
                    Transparency = 0.2
                })
                tween(LockWinLabel, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextDim
                })
                LockWinLabel.Text = "<font color='#9696a0'>未锁定</font>"
            end
        end
        task.defer(function() setLockDrag(false) end)

        utility:CreateConnection(LockWin.MouseButton1Click, function()
            setLockDrag(not cpLocked)
        end)
        utility:CreateConnection(LockWin.MouseEnter, function()
            if not cpLocked then
                tween(LockWin, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Frame
                })
                tween(LockWinLabel, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
            end
        end)
        utility:CreateConnection(LockWin.MouseLeave, function()
            if not cpLocked then
                tween(LockWin, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Outer
                })
                tween(LockWinLabel, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextDim
                })
            end
        end)

        local lwDragging, lwDragInput, lwDragStart, lwDragPos
        utility:CreateConnection(LockWin.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                lwDragging = true
                lwDragStart = input.Position
                lwDragPos = LockWin.Position
            end
        end)
        utility:CreateConnection(LockWin.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                lwDragInput = input
            end
        end)
        utility:CreateConnection(uis.InputChanged, function(input)
            if input == lwDragInput and lwDragging then
                local delta = input.Position - lwDragStart
                local nx = lwDragPos.X.Offset + delta.X
                local ny = lwDragPos.Y.Offset + delta.Y
                local vp = getViewport()
                nx = math.clamp(nx, lockWinW / 2 + 2, vp.X - lockWinW / 2 - 2)
                ny = math.clamp(ny, lockWinH / 2 + 2, vp.Y - lockWinH / 2 - 2)
                LockWin.Position = UDim2.new(0, nx, 0, ny)
                LockWinShadow.Position = LockWin.Position
            end
        end)
        utility:CreateConnection(uis.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                lwDragging = false
            end
        end)

        local function refreshLockWinPos()
            if Window._lockWinPos then
                local vp = getViewport()
                local nx = math.clamp(Window._lockWinPos.X.Offset, lockWinW / 2 + 2, vp.X - lockWinW / 2 - 2)
                local ny = math.clamp(Window._lockWinPos.Y.Offset, lockWinH / 2 + 2, vp.Y - lockWinH / 2 - 2)
                LockWin.Position = UDim2.new(0, nx, 0, ny)
            else
                local vp = getViewport()
                LockWin.Position = UDim2.new(0, vp.X - lockWinW / 2 - 16, 0, lockWinH / 2 + 16)
            end
            LockWinShadow.Position = LockWin.Position
        end
        Window._refreshLockWinPos = refreshLockWinPos
        utility:CreateConnection(camera:GetPropertyChangedSignal("ViewportSize"), refreshLockWinPos)

        utility:CreateConnection(LockWin:GetPropertyChangedSignal("Position"), function()
            Window._lockWinPos = LockWin.Position
        end)

        local origFadeWithLock = Window.Fade
        function Window:Fade(state)
            origFadeWithLock(self, state)
            LockWin.Visible = state
            LockWinShadow.Visible = state
            if state then
                refreshLockWinPos()
            end
        end

        task.delay(0.1, function()
            refreshLockWinPos()
            LockWin.Visible = true
            LockWinShadow.Visible = true
        end)

        Window.Pages = Window.Pages or {}

        function performSearch(rawQuery)
            local query = (rawQuery or "")
            query = query:gsub("^%s+", ""):gsub("%s+$", "")
            local lower = string.lower(query)
            local hasQuery = (query ~= "")

            for _, page in ipairs(Window.Pages) do
                for _, section in ipairs(page.Sections or {}) do
                    local sectionHasMatch = false
                    for _, entry in ipairs(section.SearchEntries or {}) do
                        local name = string.lower(entry.name or "")
                        local match = (not hasQuery) or (string.find(name, lower, 1, true) ~= nil)
                        entry.holder.Visible = match
                        if match then
                            sectionHasMatch = true
                        end
                    end
                    if section.SectionHolder then
                        section.SectionHolder.Visible = (not hasQuery) or sectionHasMatch
                    end
                end
            end

            setSearchClearVisible(hasQuery)
        end

        utility:CreateConnection(SearchInput:GetPropertyChangedSignal("Text"), function()
            performSearch(SearchInput.Text)
        end)

        utility:CreateConnection(SearchClearBtn.MouseButton1Click, function()
            SearchInput.Text = ""
            performSearch("")
            SearchInput:CaptureFocus()
        end)
        utility:CreateConnection(SearchClearBtn.MouseEnter, function()
            if SearchInput.Text ~= "" then
                tween(SearchClearLine1, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Text
                })
                tween(SearchClearLine2, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Text
                })
            end
        end)
        utility:CreateConnection(SearchClearBtn.MouseLeave, function()
            tween(SearchClearLine1, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundColor3 = Theme.TextDim
            })
            tween(SearchClearLine2, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundColor3 = Theme.TextDim
            })
        end)

        utility:CreateConnection(SearchInput.Focused, function()
            tween(SearchBarStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Color = Theme.Accent,
                Transparency = 0.15
            })
            tween(SearchBarAccent, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundTransparency = 0
            })
            setSearchIconColor(Theme.AccentBright)
        end)
        utility:CreateConnection(SearchInput.FocusLost, function()
            tween(SearchBarStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Color = Theme.Border,
                Transparency = 0.45
            })
            tween(SearchBarAccent, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                BackgroundTransparency = 1
            })
            setSearchIconColor(Theme.TextDim)
        end)

        Window.PerformSearch = performSearch
    end

    return setmetatable(Window, library)
end

function library:CreatePage(Properties)
    Properties = Properties or {}
    local Page = {
        Image = (Properties.image or Properties.Image or Properties.icon or Properties.Icon),
        Size = (Properties.size or Properties.Size or UDim2.new(0, 50, 0, 50)),
        Open = false,
        Window = self
    }

    do
        local touch = isTouch()
        local tabH = touch and 44 or 56
        local iconSize = touch and 18 or 24
        local Page_Tab = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Item,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page.Window["TabsHolder"],
            Size = UDim2.new(1, 0, 0, tabH),
            ZIndex = 4,
            ClipsDescendants = true
        })

        local Page_Tab_Indicator = utility:RenderObject("Frame", {
            BackgroundColor3 = Page.Window.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 2, 1, 0),
            ZIndex = 5,
            RenderTime = 0.22
        })
        corner(Page_Tab_Indicator, 1)

        local Page_Tab_Background = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Item,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 4,
            RenderTime = 0.22
        })
        corner(Page_Tab_Background, 4)

        local Page_Tab_Divider = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Position = UDim2.new(0.5, -16, 1, -1),
            Size = UDim2.new(0, 32, 0, 1),
            ZIndex = 4
        })
        corner(Page_Tab_Divider, 1)

        local Page_Tab_Image = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = Page_Tab,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, iconSize, 0, iconSize),
            ZIndex = 5,
            Image = Page.Image,
            ImageColor3 = Theme.TabDim,
            RenderTime = 0.22
        })

        local Page_Tab_Button = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = Page_Tab,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 6,
            AutoButtonColor = false
        })

        local Page_Page = utility:RenderObject("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page.Window["PagesHolder"],
            Position = UDim2.new(0, 16, 0, 16),
            Size = UDim2.new(1, -32, 1, -32),
            Visible = false,
            ZIndex = 4,
            ClipsDescendants = true
        })

        local Page_Page_Left = utility:RenderObject("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page_Page,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -8, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.BorderLight,
            ScrollBarImageTransparency = 0.4,
            VerticalScrollBarInset = "ScrollBar",
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = "Y",
            ScrollingDirection = "Y"
        })

        local Page_Page_Right = utility:RenderObject("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Page_Page,
            Position = UDim2.new(0.5, 8, 0, 0),
            Size = UDim2.new(0.5, -8, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.BorderLight,
            ScrollBarImageTransparency = 0.4,
            VerticalScrollBarInset = "ScrollBar",
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = "Y",
            ScrollingDirection = "Y"
        })

        local Page_Left_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 14),
            Parent = Page_Page_Left,
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Top"
        })

        local Page_Right_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 14),
            Parent = Page_Page_Right,
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Top"
        })

        Page["Page"] = Page_Page
        Page["Left"] = Page_Page_Left
        Page["Right"] = Page_Page_Right

        function Page:Set(state)
            Page.Open = state
            if state then
                Page_Page.Visible = true
                Page_Page.Position = UDim2.new(0, 16, 0, 16)
                tween(Page_Tab_Indicator, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 0
                })
                tween(Page_Tab_Background, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 0.6
                })
                tween(Page_Tab_Image, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    ImageColor3 = Theme.TabActive
                })
                Page.Window:SetPage(Page)
            else
                Page_Page.Visible = false
                tween(Page_Tab_Indicator, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 1
                })
                tween(Page_Tab_Background, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 1
                })
                tween(Page_Tab_Image, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    ImageColor3 = Theme.TabDim
                })
            end
        end

        utility:CreateConnection(Page_Tab_Button.MouseButton1Click, function()
            if not Page.Open then
                Page:Set(true)
            end
        end)

        utility:CreateConnection(Page_Tab_Button.MouseEnter, function()
            if not Page.Open then
                tween(Page_Tab_Image, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    ImageColor3 = Color3.fromRGB(180, 180, 188)
                })
                tween(Page_Tab_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 0.8
                })
            end
        end)

        utility:CreateConnection(Page_Tab_Button.MouseLeave, function()
            if not Page.Open then
                tween(Page_Tab_Image, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    ImageColor3 = Theme.TabDim
                })
                tween(Page_Tab_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 1
                })
            end
        end)
    end

    if #Page.Window.Pages == 0 then Page:Set(true) end
    Page.Window.Pages[#Page.Window.Pages + 1] = Page
    return setmetatable(Page, pages)
end

function pages:CreateSection(Properties)
    Properties = Properties or {}
    local Section = {
        Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Section"),
        Size = (Properties.size or Properties.Size or 150),
        Side = (Properties.side or Properties.Side or "Left"),
        Content = {},
        SearchEntries = {},
        Window = self.Window,
        Page = self
    }

    do
        local Section_Holder = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Frame,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = Section.Page[Section.Side],
            Size = UDim2.new(1, 0, 0, Section.Size),
            ZIndex = 3,
            RenderTime = 0.28,
            ClipsDescendants = true
        })
        corner(Section_Holder, 4)
        stroke(Section_Holder, Theme.Border, 1, 0.4)

        local Section_Holder_Extra = utility:RenderObject("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 2
        })

        local Section_Holder_Frame = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Outer,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 3,
            ClipsDescendants = true
        })
        corner(Section_Holder_Frame, 3)

        local Section_Holder_TitleInline = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 14, 0, -1),
            Size = UDim2.new(0, 0, 0, 2),
            ZIndex = 5
        })
        corner(Section_Holder_TitleInline, 1)

        local Section_Holder_Title = utility:RenderObject("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Parent = Section_Holder,
            Position = UDim2.new(0, 18, 0, 0),
            Size = UDim2.new(1, -26, 0, 15),
            ZIndex = 5,
            Font = Enum.Font.Code,
            RichText = true,
            Text = "<b>" .. string.upper(Section.Name) .. "</b>",
            TextColor3 = Theme.Text,
            TextSize = 11,
            TextXAlignment = "Left"
        })

        local Holder_Extra_Gradient1 = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(0, 1, 0, 1),
            Rotation = 180,
            Size = UDim2.new(1, -2, 0, 18),
            Visible = false,
            ZIndex = 4,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Theme.Outer,
            Active = false
        })

        local Holder_Extra_Gradient2 = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, -2, 0, 18),
            Visible = false,
            ZIndex = 4,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Theme.Outer,
            Active = false
        })

        local Holder_Extra_ArrowUp = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, -21, 0, 0),
            Size = UDim2.new(0, 15, 0, 14),
            Text = "",
            Visible = false,
            ZIndex = 4,
            AutoButtonColor = false
        })

        local Holder_Extra_ArrowDown = utility:RenderObject("TextButton", {
            BackgroundTransparency = 1,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, -21, 1, -14),
            Size = UDim2.new(0, 15, 0, 14),
            Text = "",
            Visible = false,
            ZIndex = 4,
            AutoButtonColor = false
        })

        local Extra_ArrowUp_Image = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = Holder_Extra_ArrowUp,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            ZIndex = 4,
            Image = "rbxassetid://8548757311",
            ImageColor3 = Theme.TextMuted
        })

        local Extra_ArrowDown_Image = utility:RenderObject("ImageLabel", {
            BackgroundTransparency = 1,
            Parent = Holder_Extra_ArrowDown,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            ZIndex = 4,
            Image = "rbxassetid://8548723563",
            ImageColor3 = Theme.TextMuted
        })

        local Holder_Extra_Bar = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 4, 1, 0),
            Visible = false,
            ZIndex = 4,
            Active = false
        })

        local Holder_Extra_BarFill = utility:RenderObject("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Parent = Holder_Extra_Bar,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 5
        })
        corner(Holder_Extra_BarFill, 1)

        local Holder_Frame_ContentHolder = utility:RenderObject("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = Section_Holder_Frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 4,
            AutomaticCanvasSize = "Y",
            BottomImage = "rbxassetid://7783554086",
            CanvasSize = UDim2.new(0, 0, 0, 0),
            MidImage = "rbxassetid://7783554086",
            ScrollBarImageColor3 = Theme.BorderLight,
            ScrollBarImageTransparency = 0.4,
            ScrollBarThickness = 6,
            TopImage = "rbxassetid://7783554086",
            VerticalScrollBarInset = "ScrollBar"
        })

        local Frame_ContentHolder_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = Holder_Frame_ContentHolder,
            FillDirection = "Vertical",
            HorizontalAlignment = "Center",
            VerticalAlignment = "Top"
        })

        local Frame_ContentHolder_Padding = utility:RenderObject("UIPadding", {
            Parent = Holder_Frame_ContentHolder,
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 8)
        })

        Section_Holder_TitleInline.Size = UDim2.new(0, Section_Holder_Title.TextBounds.X + 8, 0, 2)

        Section["Holder"] = Holder_Frame_ContentHolder
        Section["Extra"] = Section_Holder_Extra
        Section["OverlayParent"] = Section_Holder_Frame
        Section["SectionHolder"] = Section_Holder

        function Section:CloseContent()
            if Section.Content.Open then
                Section.Content:Close()
                Section.Content = {}
            end
        end

        utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
            local canScroll = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
            Holder_Extra_Gradient1.Visible = canScroll
            Holder_Extra_Gradient2.Visible = canScroll
            Holder_Extra_Bar.Visible = canScroll
            if canScroll then
                local progress = Holder_Frame_ContentHolder.AbsoluteWindowSize.Y / Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y
                local pos = Holder_Frame_ContentHolder.CanvasPosition.Y / (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y)
                Holder_Extra_BarFill.Size = UDim2.new(1, 0, math.clamp(progress, 0, 1), 0)
                Holder_Extra_BarFill.Position = UDim2.new(0, 0, math.clamp(pos, 0, 1) * (1 - progress), 0)
                Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 5)
                Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 5 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            end
        end)

        utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("CanvasPosition"), function()
            if Section.Content.Open then
                Section.Content:Close()
                Section.Content = {}
            end
            local canScroll = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
            if canScroll then
                local progress = Holder_Frame_ContentHolder.AbsoluteWindowSize.Y / Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y
                local pos = Holder_Frame_ContentHolder.CanvasPosition.Y / math.max(1, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y)
                tween(Holder_Extra_BarFill, 0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
                    Size = UDim2.new(1, 0, math.clamp(progress, 0, 1), 0),
                    Position = UDim2.new(0, 0, math.clamp(pos, 0, 1) * (1 - progress), 0)
                })
                Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 1)
                Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 1 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            end
        end)

        utility:CreateConnection(Holder_Extra_ArrowUp.MouseButton1Click, function()
            tween(Holder_Frame_ContentHolder, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y - 28, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            })
        end)

        utility:CreateConnection(Holder_Extra_ArrowDown.MouseButton1Click, function()
            tween(Holder_Frame_ContentHolder, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y + 28, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            })
        end)

        utility:CreateConnection(Holder_Extra_ArrowUp.MouseEnter, function()
            tween(Extra_ArrowUp_Image, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.Text
            })
        end)
        utility:CreateConnection(Holder_Extra_ArrowUp.MouseLeave, function()
            tween(Extra_ArrowUp_Image, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.TextMuted
            })
        end)
        utility:CreateConnection(Holder_Extra_ArrowDown.MouseEnter, function()
            tween(Extra_ArrowDown_Image, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.Text
            })
        end)
        utility:CreateConnection(Holder_Extra_ArrowDown.MouseLeave, function()
            tween(Extra_ArrowDown_Image, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                ImageColor3 = Theme.TextMuted
            })
        end)

        Section_Holder.BackgroundTransparency = 1
        Section_Holder.Position = UDim2.new(0, 14, 0, 0)
        task.wait(0.04)
        tween(Section_Holder, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 0, 0, 0)
        })
    end

    self.Sections = self.Sections or {}
    table.insert(self.Sections, Section)

    return setmetatable(Section, sections)
end

do
    function sections:CreateToggle(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 7),
                Size = UDim2.new(0, 16, 0, 8),
                ZIndex = 3
            })
            corner(Content_Holder_Outline, 2)
            stroke(Content_Holder_Outline, Theme.Border, 1, 0.4)

            local Holder_Outline_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(60, 60, 68),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Holder_Outline_Frame, 1)

            local Fill_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Holder_Outline_Frame,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 4
            })
            corner(Fill_Frame, 1)

            local Fill_Gradient = gradient(Fill_Frame, Color3.fromRGB(255, 255, 255), Content.Window.Accent, 90)

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -44, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            function Content:Set(state)
                Content.State = state
                local tw = 0.26
                if state then
                    tween(Fill_Frame, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 1, 0)
                    })
                    tween(Content_Holder_Title, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextColor3 = Theme.Text
                    })
                    tween(Content_Holder_Outline, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Color3.fromRGB(40, 30, 20)
                    })
                else
                    tween(Fill_Frame, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 1, 0)
                    })
                    tween(Content_Holder_Title, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextColor3 = Theme.TextMuted
                    })
                    tween(Content_Holder_Outline, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Outer
                    })
                end
                Content.Callback(Content:Get())
            end

            function Content:Get()
                return Content.State
            end

            utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function()
                Content:Set(not Content:Get())
            end)

            utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
                if not Content.State then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Color3.fromRGB(82, 82, 92)
                    })
                end
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Content.State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 198)
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
                if not Content.State then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 68)
                    })
                end
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Content.State and Theme.Text or Theme.TextMuted
                })
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateSlider(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or nil),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
            Min = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
            Max = (Properties.max or Properties.Max or Properties.maxmimum or Properties.Maximum or 100),
            Ending = (Properties.ending or Properties.Ending or Properties.suffix or Properties.Suffix or ""),
            Decimals = (1 / (Properties.decimals or Properties.Decimals or Properties.tick or Properties.Tick or 1)),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Holding = false,
            Hovering = false,
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local rowH = Content.Name and 38 or 22
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, rowH),
                ZIndex = 3
            })

            if Content.Name then
                utility:RenderObject("TextLabel", {
                    BackgroundTransparency = 1,
                    Parent = Content_Holder,
                    Position = UDim2.new(0, 44, 0, 4),
                    Size = UDim2.new(1, -94, 0, 11),
                    ZIndex = 3,
                    Font = Enum.Font.Code,
                    RichText = true,
                    Text = Content.Name,
                    TextColor3 = Theme.TextMuted,
                    TextSize = 10,
                    TextTruncate = "AtEnd",
                    TextXAlignment = "Left",
                    TextYAlignment = "Center"
                })

                local Content_Holder_Value = utility:RenderObject("TextLabel", {
                    BackgroundTransparency = 1,
                    Parent = Content_Holder,
                    Position = UDim2.new(1, -54, 0, 4),
                    Size = UDim2.new(0, 54, 0, 11),
                    ZIndex = 3,
                    Font = Enum.Font.Code,
                    RichText = true,
                    Text = "",
                    TextColor3 = Content.Window.Accent,
                    TextSize = 10,
                    TextXAlignment = "Right",
                    TextYAlignment = "Center"
                })
                Content["ValueLabel"] = Content_Holder_Value
            end

            local trackY = Content.Name and 19 or 9
            local Slider_Track = utility:RenderObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(26, 26, 32),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 40, 0, trackY),
                Size = UDim2.new(1, -100, 0, 4),
                ZIndex = 3
            })
            corner(Slider_Track, 2)

            local Slider_Fill = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Slider_Track,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 4
            })
            corner(Slider_Fill, 2)
            gradient(Slider_Fill, Theme.AccentBright, Content.Window.Accent, 0)

            local Slider_Pip = utility:RenderObject("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Slider_Track,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 2, 0, 10),
                ZIndex = 5
            })
            corner(Slider_Pip, 1)

            local Slider_Hitbox = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 36, 0, trackY - 6),
                Size = UDim2.new(1, -96, 0, 16),
                Text = "",
                ZIndex = 8,
                AutoButtonColor = false
            })

            local function updateTrackVisual()
                local c = (Content.Holding or Content.Hovering) and Color3.fromRGB(34, 34, 42) or Color3.fromRGB(26, 26, 32)
                tween(Slider_Track, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = c
                })
                local pipTrans = Content.Holding and 0 or (Content.Hovering and 0.3 or 0.6)
                tween(Slider_Pip, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = pipTrans
                })
            end

            function Content:Set(state, instant)
                Content.State = math.clamp(math.round(state * Content.Decimals) / Content.Decimals, Content.Min, Content.Max)
                local fill = (1 - ((Content.Max - Content.State) / (Content.Max - Content.Min)))
                local dur = instant and 0 or 0.14
                local style = instant and Enum.EasingStyle.Linear or Enum.EasingStyle.Quint
                local dir = instant and Enum.EasingDirection.InOut or Enum.EasingDirection.Out
                tween(Slider_Fill, dur, style, dir, {
                    Size = UDim2.new(fill, 0, 1, 0)
                })
                tween(Slider_Pip, dur, style, dir, {
                    Position = UDim2.new(fill, 0, 0.5, 0)
                })
                if Content.ValueLabel then
                    Content.ValueLabel.Text = "<b>" .. Content.State .. Content.Ending .. "</b>"
                end
                Content.Callback(Content:Get())
            end

            function Content:Refresh()
                local Mouse = utility:MouseLocation()
                local rel = math.clamp(Mouse.X - Slider_Track.AbsolutePosition.X, 0, Slider_Track.AbsoluteSize.X)
                local pct = rel / Slider_Track.AbsoluteSize.X
                local val = Content.Min + (Content.Max - Content.Min) * pct
                Content:Set(val, true)
            end

            function Content:Get()
                return Content.State
            end

            utility:CreateConnection(Slider_Hitbox.MouseButton1Down, function()
                Content:Refresh()
                Content.Holding = true
                updateTrackVisual()
            end)

            utility:CreateConnection(Slider_Hitbox.MouseEnter, function()
                Content.Hovering = true
                updateTrackVisual()
            end)

            utility:CreateConnection(Slider_Hitbox.MouseLeave, function()
                Content.Hovering = false
                if not Content.Holding then
                    updateTrackVisual()
                end
            end)

            utility:CreateConnection(uis.InputChanged, function(Input)
                if Content.Holding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Content:Refresh()
                end
            end)

            utility:CreateConnection(uis.InputEnded, function(Input)
                if Content.Holding and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    Content.Holding = false
                    updateTrackVisual()
                end
            end)

            Content:Set(Content.State, true)
        end

        return Content
    end

    function sections:CreateDropdown(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or 1),
            Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Content = {
                Open = false
            },
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 3
            })

            local Content_Holder_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 40, 0, 16),
                Size = UDim2.new(1, -98, 0, 20),
                ZIndex = 3
            })
            corner(Content_Holder_Outline, 3)
            stroke(Content_Holder_Outline, Theme.Border, 1, 0.4)

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 5),
                Size = UDim2.new(1, -44, 0, 11),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            local Holder_Outline_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Holder_Outline_Frame, 2)

            local Outline_Frame_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Holder_Outline_Frame,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -22, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 10,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
                BackgroundTransparency = 1,
                Parent = Holder_Outline_Frame,
                Position = UDim2.new(1, -14, 0.5, -3),
                Size = UDim2.new(0, 7, 0, 6),
                ZIndex = 4,
                Image = "rbxassetid://8532000591",
                ImageColor3 = Theme.TextMuted
            })

            function Content:Set(state)
                Content.State = state
                Outline_Frame_Title.Text = "<b>" .. tostring(Content.Options[Content:Get()]) .. "</b>"
                Content.Callback(Content:Get())
                if Content.Content.Open then
                    Content.Content:Refresh(Content:Get())
                end
            end

            function Content:Get()
                return Content.State
            end

            function Content:Open()
                Content.Section:CloseContent()
                local Open = {}
                local Connections = {}
                local InputCheck

                local overlayParent = Content.Section.OverlayParent
                local relX = Content_Holder_Outline.AbsolutePosition.X - overlayParent.AbsolutePosition.X
                local relY = Content_Holder_Outline.AbsolutePosition.Y - overlayParent.AbsolutePosition.Y + Content_Holder_Outline.AbsoluteSize.Y + 2

                local Content_Open_Holder = utility:RenderObject("Frame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = overlayParent,
                    Position = UDim2.new(0, relX, 0, relY),
                    Size = UDim2.new(0, Content_Holder_Outline.AbsoluteSize.X, 0, 0),
                    ZIndex = 20,
                    ClipsDescendants = true
                })

                local Open_Holder_Outline = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Outer,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Content_Open_Holder,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 6
                })
                corner(Open_Holder_Outline, 3)
                stroke(Open_Holder_Outline, Theme.Border, 1, 0.4)

                local Open_Holder_Outline_Frame = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Frame,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Open_Holder_Outline,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    ZIndex = 6
                })
                corner(Open_Holder_Outline_Frame, 2)

                local totalH = (20 * #Content.Options) + 2
                tween(Content_Open_Holder, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(1, -98, 0, totalH)
                })
                tween(Outline_Frame_Arrow, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Rotation = 180,
                    ImageColor3 = Theme.Accent
                })
                tween(Holder_Outline_Frame, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.ItemHover
                })

                for Index, Option in pairs(Content.Options) do
                    local Outline_Frame_Option = utility:RenderObject("Frame", {
                        BackgroundColor3 = Theme.Item,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Parent = Open_Holder_Outline_Frame,
                        Position = UDim2.new(0, 0, 0, 20 * (Index - 1)),
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 6
                    })
                    corner(Outline_Frame_Option, 2)

                    local Frame_Option_Title = utility:RenderObject("TextLabel", {
                        BackgroundTransparency = 1,
                        Parent = Outline_Frame_Option,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -14, 1, 0),
                        ZIndex = 6,
                        Font = Enum.Font.Code,
                        RichText = true,
                        Text = tostring(Option),
                        TextColor3 = Index == Content.State and Content.Window.Accent or Theme.TextMuted,
                        TextSize = 10,
                        TextTruncate = "AtEnd",
                        TextXAlignment = "Left",
                        TextYAlignment = "Center"
                    })

                    local Frame_Option_Button = utility:RenderObject("TextButton", {
                        BackgroundTransparency = 1,
                        Parent = Outline_Frame_Option,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 7,
                        AutoButtonColor = false
                    })

                    local Clicked = utility:CreateConnection(Frame_Option_Button.MouseButton1Click, function()
                        Content:Set(Index)
                    end)

                    local Entered = utility:CreateConnection(Frame_Option_Button.MouseEnter, function()
                        tween(Outline_Frame_Option, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundColor3 = Theme.ItemHover
                        })
                        tween(Frame_Option_Title, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = Index == Content.State and Content.Window.Accent or Theme.Text
                        })
                    end)

                    local Left = utility:CreateConnection(Frame_Option_Button.MouseLeave, function()
                        tween(Outline_Frame_Option, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundColor3 = Theme.Item
                        })
                        tween(Frame_Option_Title, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = Index == Content.State and Content.Window.Accent or Theme.TextMuted
                        })
                    end)

                    Connections[#Connections + 1] = Clicked
                    Connections[#Connections + 1] = Entered
                    Connections[#Connections + 1] = Left
                    Open[#Open + 1] = {Index, Frame_Option_Title, Outline_Frame_Option, Frame_Option_Button}
                end

                function Content.Content:Close()
                    Content.Content.Open = false
                    tween(Content_Open_Holder, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                        Size = UDim2.new(0, Content_Open_Holder.AbsoluteSize.X, 0, 0)
                    })
                    tween(Outline_Frame_Arrow, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        Rotation = 0,
                        ImageColor3 = Theme.TextMuted
                    })
                    tween(Holder_Outline_Frame, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Item
                    })
                    task.delay(0.2, function()
                        for Index, Value in pairs(Open) do
                            Value[2]:Remove()
                            Value[3]:Remove()
                            Value[4]:Remove()
                        end
                        Content_Open_Holder:Remove()
                        Open_Holder_Outline:Remove()
                        Open_Holder_Outline_Frame:Remove()
                        Open = nil
                    end)
                    for Index, Value in pairs(Connections) do
                        Value:Disconnect()
                    end
                    if InputCheck then InputCheck:Disconnect() end
                    function Content.Content:Refresh() end
                    Connections = nil
                    InputCheck = nil
                end

                function Content.Content:Refresh(state)
                    for Index, Value in pairs(Open) do
                        tween(Value[2], 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = Value[1] == Content.State and Content.Window.Accent or Theme.TextMuted
                        })
                    end
                end

                Content.Content.Open = true
                Content.Section.Content = Content.Content

                task.wait()
                InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
                    if Content.Content.Open and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Mouse = utility:MouseLocation()
                        if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 4) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 4)) then
                            Content.Section:CloseContent()
                        end
                    end
                end)
            end

            utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function()
                if Content.Content.Open then
                    Content.Section:CloseContent()
                else
                    Content:Open()
                end
            end)

            utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
                if not Content.Content.Open then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.ItemHover
                    })
                end
                tween(Outline_Frame_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
                if not Content.Content.Open then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Item
                    })
                end
                tween(Outline_Frame_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateMultibox(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or {1}),
            Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
            Minimum = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
            Maximum = (Properties.max or Properties.Max or Properties.maximum or Properties.Maximum or 1000),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Content = {
                Open = false
            },
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 3
            })

            local Content_Holder_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 40, 0, 16),
                Size = UDim2.new(1, -98, 0, 20),
                ZIndex = 3
            })
            corner(Content_Holder_Outline, 3)
            stroke(Content_Holder_Outline, Theme.Border, 1, 0.4)

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 5),
                Size = UDim2.new(1, -44, 0, 11),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            local Holder_Outline_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Holder_Outline_Frame, 2)

            local Outline_Frame_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Holder_Outline_Frame,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -22, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 10,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
                BackgroundTransparency = 1,
                Parent = Holder_Outline_Frame,
                Position = UDim2.new(1, -14, 0.5, -3),
                Size = UDim2.new(0, 7, 0, 6),
                ZIndex = 4,
                Image = "rbxassetid://8532000591",
                ImageColor3 = Theme.TextMuted
            })

            function Content:Set(state)
                table.sort(state)
                Content.State = state
                local Serialised = utility:Serialise(utility:Sort(Content:Get(), Content.Options))
                Serialised = Serialised == "" and "-" or Serialised
                Outline_Frame_Title.Text = "<b>" .. Serialised .. "</b>"
                Content.Callback(Content:Get())
                if Content.Content.Open then
                    Content.Content:Refresh(Content:Get())
                end
            end

            function Content:Get()
                return Content.State
            end

            function Content:Open()
                Content.Section:CloseContent()
                local Open = {}
                local Connections = {}
                local InputCheck

                local Content_Open_Holder = utility:RenderObject("Frame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Content.Section.Extra,
                    Position = UDim2.new(0, Content_Holder_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X, 0, Content_Holder_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 22),
                    Size = UDim2.new(1, -98, 0, 0),
                    ZIndex = 6,
                    ClipsDescendants = true
                })

                local Open_Holder_Outline = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Outer,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Content_Open_Holder,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 6
                })
                corner(Open_Holder_Outline, 3)
                stroke(Open_Holder_Outline, Theme.Border, 1, 0.4)

                local Open_Holder_Outline_Frame = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Frame,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Open_Holder_Outline,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    ZIndex = 6
                })
                corner(Open_Holder_Outline_Frame, 2)

                local totalH = (20 * #Content.Options) + 2
                tween(Content_Open_Holder, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(1, -98, 0, totalH)
                })
                tween(Outline_Frame_Arrow, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    Rotation = 180,
                    ImageColor3 = Theme.Accent
                })
                tween(Holder_Outline_Frame, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.ItemHover
                })

                for Index, Option in pairs(Content.Options) do
                    local Outline_Frame_Option = utility:RenderObject("Frame", {
                        BackgroundColor3 = Theme.Item,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        Parent = Open_Holder_Outline_Frame,
                        Position = UDim2.new(0, 0, 0, 20 * (Index - 1)),
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 6
                    })
                    corner(Outline_Frame_Option, 2)

                    local Frame_Option_Title = utility:RenderObject("TextLabel", {
                        BackgroundTransparency = 1,
                        Parent = Outline_Frame_Option,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -14, 1, 0),
                        ZIndex = 6,
                        Font = Enum.Font.Code,
                        RichText = true,
                        Text = tostring(Option),
                        TextColor3 = table.find(Content.State, Index) and Content.Window.Accent or Theme.TextMuted,
                        TextSize = 10,
                        TextTruncate = "AtEnd",
                        TextXAlignment = "Left",
                        TextYAlignment = "Center"
                    })

                    local Frame_Option_Button = utility:RenderObject("TextButton", {
                        BackgroundTransparency = 1,
                        Parent = Outline_Frame_Option,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 7,
                        AutoButtonColor = false
                    })

                    local Clicked = utility:CreateConnection(Frame_Option_Button.MouseButton1Click, function()
                        local NewTable = Content:Get()
                        if table.find(NewTable, Index) then
                            if (#NewTable - 1) >= Content.Minimum then
                                table.remove(NewTable, table.find(NewTable, Index))
                            end
                        else
                            if (#NewTable + 1) <= Content.Maximum then
                                table.insert(NewTable, Index)
                            end
                        end
                        Content:Set(NewTable)
                    end)

                    local Entered = utility:CreateConnection(Frame_Option_Button.MouseEnter, function()
                        tween(Outline_Frame_Option, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundColor3 = Theme.ItemHover
                        })
                        tween(Frame_Option_Title, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = table.find(Content.State, Index) and Content.Window.Accent or Theme.Text
                        })
                    end)

                    local Left = utility:CreateConnection(Frame_Option_Button.MouseLeave, function()
                        tween(Outline_Frame_Option, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            BackgroundColor3 = Theme.Item
                        })
                        tween(Frame_Option_Title, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = table.find(Content.State, Index) and Content.Window.Accent or Theme.TextMuted
                        })
                    end)

                    Connections[#Connections + 1] = Clicked
                    Connections[#Connections + 1] = Entered
                    Connections[#Connections + 1] = Left
                    Open[#Open + 1] = {Index, Frame_Option_Title, Outline_Frame_Option, Frame_Option_Button}
                end

                function Content.Content:Close()
                    Content.Content.Open = false
                    tween(Content_Open_Holder, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                        Size = UDim2.new(1, -98, 0, 0)
                    })
                    tween(Outline_Frame_Arrow, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        Rotation = 0,
                        ImageColor3 = Theme.TextMuted
                    })
                    tween(Holder_Outline_Frame, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Item
                    })
                    task.delay(0.2, function()
                        for Index, Value in pairs(Open) do
                            Value[2]:Remove()
                            Value[3]:Remove()
                            Value[4]:Remove()
                        end
                        Content_Open_Holder:Remove()
                        Open_Holder_Outline:Remove()
                        Open_Holder_Outline_Frame:Remove()
                        Open = nil
                    end)
                    for Index, Value in pairs(Connections) do
                        Value:Disconnect()
                    end
                    if InputCheck then InputCheck:Disconnect() end
                    function Content.Content:Refresh() end
                    Connections = nil
                    InputCheck = nil
                end

                function Content.Content:Refresh(state)
                    for Index, Value in pairs(Open) do
                        tween(Value[2], 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = table.find(Content.State, Value[1]) and Content.Window.Accent or Theme.TextMuted
                        })
                    end
                end

                Content.Content.Open = true
                Content.Section.Content = Content.Content

                task.wait()
                InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
                    if Content.Content.Open and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Mouse = utility:MouseLocation()
                        if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 4) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 4)) then
                            Content.Section:CloseContent()
                        end
                    end
                end)
            end

            utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function()
                if Content.Content.Open then
                    Content.Section:CloseContent()
                else
                    Content:Open()
                end
            end)

            utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
                if not Content.Content.Open then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.ItemHover
                    })
                end
                tween(Outline_Frame_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
                if not Content.Content.Open then
                    tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Theme.Item
                    })
                end
                tween(Outline_Frame_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateKeybind(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil),
            Mode = (Properties.mode or Properties.Mode or "Hold"),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Active = false,
            Holding = false,
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        local Keys = {
            KeyCodes = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "One", "Two", "Three", "Four", "Five", "Six", "Seveen", "Eight", "Nine", "0", "Insert", "Tab", "Home", "End", "LeftAlt", "LeftControl", "LeftShift", "RightAlt", "RightControl", "RightShift", "CapsLock"},
            Inputs = {"MouseButton1", "MouseButton2", "MouseButton3"},
            Shortened = {["MouseButton1"] = "M1", ["MouseButton2"] = "M2", ["MouseButton3"] = "M3", ["Insert"] = "INS", ["LeftAlt"] = "LA", ["LeftControl"] = "LC", ["LeftShift"] = "LS", ["RightAlt"] = "RA", ["RightControl"] = "RC", ["RightShift"] = "RS", ["CapsLock"] = "CL"}
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -90, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            local Value_Background = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(1, -54, 0.5, -8),
                Size = UDim2.new(0, 46, 0, 16),
                ZIndex = 4
            })
            corner(Value_Background, 3)
            stroke(Value_Background, Theme.Border, 1, 0.4)
            gradient(Value_Background, Theme.ItemHover, Theme.Item, 90)

            local Content_Holder_Value = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Value_Background,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Center",
                TextYAlignment = "Center"
            })

            function Content:Set(state)
                Content.State = state or {}
                Content.Active = false
                Content_Holder_Value.Text = "[" .. (#Content:Get() > 0 and Content:Shorten(Content:Get()[2]) or "-") .. "]"
                Content.Callback(Content:Get())
            end

            function Content:Get()
                return Content.State
            end

            function Content:Shorten(Str)
                for Index, Value in pairs(Keys.Shortened) do
                    Str = string.gsub(Str, Index, Value)
                end
                return Str
            end

            function Content:Change(Key)
                if Key.EnumType then
                    if Key.EnumType == Enum.KeyCode or Key.EnumType == Enum.UserInputType then
                        if table.find(Keys.KeyCodes, Key.Name) or table.find(Keys.Inputs, Key.Name) then
                            Content:Set({Key.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType", Key.Name})
                            return true
                        end
                    end
                end
            end

            utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function()
                Content.Holding = true
                Content_Holder_Value.Text = "[...]"
                tween(Content_Holder_Value, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Color3.fromRGB(255, 90, 90)
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseButton2Click, function()
                Content:Set()
            end)

            utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
                tween(Value_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.ItemHover
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
                tween(Value_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Item
                })
            end)

            utility:CreateConnection(uis.InputBegan, function(Input)
                if Content.Holding then
                    local Success = Content:Change(Input.KeyCode.Name ~= "Unknown" and Input.KeyCode or Input.UserInputType)
                    if Success then
                        Content.Holding = false
                        tween(Content_Holder_Value, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
                            TextColor3 = Theme.Accent
                        })
                        task.delay(0.4, function()
                            if not Content.Holding then
                                tween(Content_Holder_Value, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                                    TextColor3 = Theme.TextMuted
                                })
                            end
                        end)
                    end
                end
                if Content:Get()[1] and Content:Get()[2] then
                    if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                        if Content.Mode == "Hold" then
                            Content.Active = true
                            tween(Value_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                                BackgroundColor3 = Content.Window.Accent
                            })
                        elseif Content.Mode == "Toggle" then
                            Content.Active = not Content.Active
                            tween(Value_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                                BackgroundColor3 = Content.Active and Content.Window.Accent or Theme.Item
                            })
                        end
                    end
                end
            end)

            utility:CreateConnection(uis.InputEnded, function(Input)
                if Content:Get()[1] and Content:Get()[2] then
                    if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                        if Content.Mode == "Hold" then
                            Content.Active = false
                            tween(Value_Background, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                                BackgroundColor3 = Theme.Item
                            })
                        end
                    end
                end
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateColorpicker(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 255, 255)),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Content = {
                Open = false
            },
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(1, -42, 0, 7),
                Size = UDim2.new(0, 22, 0, 8),
                ZIndex = 3
            })
            corner(Content_Holder_Outline, 2)
            stroke(Content_Holder_Outline, Theme.Border, 1, 0.4)

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -44, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            local Holder_Outline_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.State,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Holder_Outline_Frame, 1)

            function Content:Set(state)
                Content.State = state
                tween(Holder_Outline_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Content.State
                })
                Content.Callback(Content:Get())
            end

            function Content:Get()
                return Content.State
            end

            function Content:Open()
                Content.Section:CloseContent()
                local Connections = {}
                local InputCheck

                local initialH, initialS, initialV = Color3.toHSV(Content.State)
                local H = initialH
                local S = initialS
                local V = initialV
                local svDragging = false
                local hueDragging = false

                local Content_Open_Holder = utility:RenderObject("Frame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Content.Section.Extra,
                    Position = UDim2.new(0, Content_Holder_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X, 0, Content_Holder_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 12),
                    Size = UDim2.new(0, 196, 0, 0),
                    ZIndex = 6,
                    ClipsDescendants = true
                })

                local Open_Holder_Outline = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Outer,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Content_Open_Holder,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 6
                })
                corner(Open_Holder_Outline, 4)
                stroke(Open_Holder_Outline, Theme.Border, 1, 0.4)

                local Open_Outline_Frame = utility:RenderObject("Frame", {
                    BackgroundColor3 = Theme.Frame,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Open_Holder_Outline,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    ZIndex = 6
                })
                corner(Open_Outline_Frame, 3)
                gradient(Open_Outline_Frame, Theme.FrameLight, Theme.Frame, 90)

                local Picker_Layout = utility:RenderObject("Frame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Open_Outline_Frame,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -12, 1, -12),
                    ZIndex = 6
                })

                local SV_Square = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    BorderSizePixel = 0,
                    Parent = Picker_Layout,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -22, 0, 150),
                    ZIndex = 6
                })
                corner(SV_Square, 3)

                local SV_White = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = SV_Square,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 6
                })
                corner(SV_White, 3)
                local SV_White_Gradient = Instance.new("UIGradient")
                SV_White_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                SV_White_Gradient.Transparency = NumberSequence.new(0, 1)
                SV_White_Gradient.Rotation = 0
                SV_White_Gradient.Parent = SV_White

                local SV_Black = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = SV_Square,
                    Position = UDim2.new(0,0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 7
                })
                corner(SV_Black, 3)
                local SV_Black_Gradient = Instance.new("UIGradient")
                SV_Black_Gradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
                SV_Black_Gradient.Transparency = NumberSequence.new(1, 0)
                SV_Black_Gradient.Rotation = 90
                SV_Black_Gradient.Parent = SV_Black

                local SV_Indicator = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = SV_Square,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(S, 0, 1 - V, 0),
                    Size = UDim2.new(0, 6, 0, 6),
                    ZIndex = 9
                })
                corner(SV_Indicator, 3)
                stroke(SV_Indicator, Color3.fromRGB(0, 0, 0), 1, 0)

                local SV_Button = utility:RenderObject("TextButton", {
                    BackgroundTransparency = 1,
                    Parent = SV_Square,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 10,
                    AutoButtonColor = false
                })

                local Hue_Bar = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Picker_Layout,
                    Position = UDim2.new(1, -16, 0, 0),
                    Size = UDim2.new(0, 14, 0, 150),
                    ZIndex = 6
                })
                corner(Hue_Bar, 3)
                local Hue_Bar_Gradient = Instance.new("UIGradient")
                Hue_Bar_Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                Hue_Bar_Gradient.Rotation = 90
                Hue_Bar_Gradient.Parent = Hue_Bar

                local Hue_Indicator = utility:RenderObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Hue_Bar,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, H, 0),
                    Size = UDim2.new(1, 2, 0, 4),
                    ZIndex = 8
                })
                corner(Hue_Indicator, 1)
                stroke(Hue_Indicator, Color3.fromRGB(0, 0, 0), 1, 0)

                local Hue_Button = utility:RenderObject("TextButton", {
                    BackgroundTransparency = 1,
                    Parent = Hue_Bar,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 10,
                    AutoButtonColor = false
                })

                local Preview_Swatch = utility:RenderObject("Frame", {
                    BackgroundColor3 = Content.State,
                    BorderSizePixel = 0,
                    Parent = Picker_Layout,
                    Position = UDim2.new(0, 0, 0, 156),
                    Size = UDim2.new(0, 32, 0, 22),
                    ZIndex = 6
                })
                corner(Preview_Swatch, 3)
                stroke(Preview_Swatch, Theme.Border, 1, 0.4)
                gradient(Preview_Swatch, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200), 90)

                local Hex_Label = utility:RenderObject("TextLabel", {
                    BackgroundTransparency = 1,
                    Parent = Picker_Layout,
                    Position = UDim2.new(0, 40, 0, 156),
                    Size = UDim2.new(1, -40, 0, 22),
                    ZIndex = 6,
                    Font = Enum.Font.Code,
                    RichText = true,
                    Text = "",
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    TextXAlignment = "Left",
                    TextYAlignment = "Center"
                })

                local function updateVisuals()
                    SV_Square.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    SV_Indicator.Position = UDim2.new(S, 0, 1 - V, 0)
                    Hue_Indicator.Position = UDim2.new(0.5, 0, H, 0)
                    Preview_Swatch.BackgroundColor3 = Color3.fromHSV(H, S, V)
                    local color = Color3.fromHSV(H, S, V)
                    local hex, r, g, b = colorToHex(color)
                    Hex_Label.Text = "<b>" .. hex .. "</b>  <font color='#7e7e86'>RGB " .. r .. ", " .. g .. ", " .. b .. "</font>"
                end

                local function applyColor()
                    Content.State = Color3.fromHSV(H, S, V)
                    tween(Holder_Outline_Frame, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundColor3 = Content.State
                    })
                    Content.Callback(Content:Get())
                end

                local function updateSV(input)
                    local relX = math.clamp(input.Position.X - SV_Square.AbsolutePosition.X, 0, SV_Square.AbsoluteSize.X)
                    local relY = math.clamp(input.Position.Y - SV_Square.AbsolutePosition.Y, 0, SV_Square.AbsoluteSize.Y)
                    S = relX / SV_Square.AbsoluteSize.X
                    V = 1 - (relY / SV_Square.AbsoluteSize.Y)
                    updateVisuals()
                    applyColor()
                end

                local function updateHue(input)
                    local relY = math.clamp(input.Position.Y - Hue_Bar.AbsolutePosition.Y, 0, Hue_Bar.AbsoluteSize.Y)
                    H = relY / Hue_Bar.AbsoluteSize.Y
                    updateVisuals()
                    applyColor()
                end

                Connections[#Connections + 1] = utility:CreateConnection(SV_Button.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = true
                        updateSV(input)
                    end
                end)

                Connections[#Connections + 1] = utility:CreateConnection(Hue_Button.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = true
                        updateHue(input)
                    end
                end)

                Connections[#Connections + 1] = utility:CreateConnection(uis.InputChanged, function(input)
                    if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSV(input)
                    elseif hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateHue(input)
                    end
                end)

                Connections[#Connections + 1] = utility:CreateConnection(uis.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                        hueDragging = false
                    end
                end)

                updateVisuals()

                tween(Content_Open_Holder, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(0, 196, 0, 192)
                })

                function Content.Content:Close()
                    Content.Content.Open = false
                    svDragging = false
                    hueDragging = false
                    tween(Content_Open_Holder, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                        Size = UDim2.new(0, 196, 0, 0)
                    })
                    task.delay(0.22, function()
                        Content_Open_Holder:Remove()
                    end)
                    for Index, Value in pairs(Connections) do
                        Value:Disconnect()
                    end
                    if InputCheck then InputCheck:Disconnect() end
                    function Content.Content:Refresh() end
                    Connections = nil
                    InputCheck = nil
                end

                function Content.Content:Refresh(state)
                    local ch, cs, cv = Color3.toHSV(Content.State)
                    H, S, V = ch, cs, cv
                    updateVisuals()
                end

                Content.Content.Open = true
                Content.Section.Content = Content.Content

                task.wait()
                InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
                    if Content.Content.Open and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                        local Mouse = utility:MouseLocation()
                        if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 4) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 4)) then
                            if not (Mouse.X > Content_Holder.AbsolutePosition.X and Mouse.Y > (Content_Holder.AbsolutePosition.Y) and Mouse.X < (Content_Holder.AbsolutePosition.X + Content_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Holder.AbsolutePosition.Y + Content_Holder.AbsoluteSize.Y)) then
                                if Content.Content.Open then
                                    Content.Section:CloseContent()
                                end
                            end
                        end
                    end
                end)
            end

            utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function()
                if Content.Content.Open then
                    Content.Section:CloseContent()
                else
                    Content:Open()
                end
            end)

            utility:CreateConnection(Content_Holder_Button.MouseEnter, function()
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            utility:CreateConnection(Content_Holder_Button.MouseLeave, function()
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateButton(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Button"),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 3
            })

            local Button_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 4),
                Size = UDim2.new(1, -40, 0, 16),
                ZIndex = 3
            })
            corner(Button_Outline, 3)
            stroke(Button_Outline, Theme.Border, 1, 0.4)

            local Button_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Button_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Button_Frame, 2)
            gradient(Button_Frame, Theme.ItemHover, Theme.Item, 90)

            local Button_Accent = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Button_Frame,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 4
            })
            corner(Button_Accent, 2)
            gradient(Button_Accent, Color3.fromRGB(255, 150, 60), Content.Window.Accent, 90)

            local Button_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Button_Frame,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b>" .. Content.Name .. "</b>",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Center",
                TextYAlignment = "Center"
            })

            local Button_Click = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 4),
                Size = UDim2.new(1, -40, 0, 16),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            function Content:Set(name)
                if name then
                    Content.Name = name
                    Button_Title.Text = "<b>" .. Content.Name .. "</b>"
                end
            end

            utility:CreateConnection(Button_Click.MouseButton1Click, function()
                Content.Callback()
                tween(Button_Accent, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 0.7
                })
                task.delay(0.18, function()
                    tween(Button_Accent, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundTransparency = 1
                    })
                end)
            end)

            utility:CreateConnection(Button_Click.MouseEnter, function()
                tween(Button_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.ItemHover
                })
                tween(Button_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)

            utility:CreateConnection(Button_Click.MouseLeave, function()
                tween(Button_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Item
                })
                tween(Button_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
            end)
        end

        return Content
    end

    function sections:CreateLabel(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Label"),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = 3
            })

            local Label_AccentBar = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0.5, -1),
                Size = UDim2.new(0, 2, 0, 2),
                ZIndex = 4
            })
            corner(Label_AccentBar, 1)

            local Label_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 28, 0, 0),
                Size = UDim2.new(1, -36, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b>" .. Content.Name .. "</b>",
                TextColor3 = Theme.Text,
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            function Content:Set(name)
                Content.Name = name or Content.Name
                Label_Title.Text = "<b>" .. Content.Name .. "</b>"
            end
        end

        return Content
    end

    function sections:CreateInput(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Input"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or ""),
            Placeholder = (Properties.placeholder or Properties.Placeholder or Properties.ph or Properties.Ph or ""),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -120, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Input_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(1, -104, 0, 4),
                Size = UDim2.new(0, 84, 0, 14),
                ZIndex = 3
            })
            corner(Input_Outline, 3)
            stroke(Input_Outline, Theme.Border, 1, 0.4)

            local Input_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Input_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Input_Frame, 2)

            local Input_Box = utility:RenderObject("TextBox", {
                BackgroundTransparency = 1,
                Parent = Input_Frame,
                Position = UDim2.new(0, 4, 0, 0),
                Size = UDim2.new(1, -8, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                PlaceholderText = Content.Placeholder,
                Text = Content.State,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDim,
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                ClearTextOnFocus = false
            })

            function Content:Set(state)
                Content.State = state or ""
                Input_Box.Text = Content.State
                Content.Callback(Content:Get())
            end

            function Content:Get()
                return Content.State
            end

            utility:CreateConnection(Input_Box.FocusLost, function(enterPressed)
                Content.State = Input_Box.Text
                Content.Callback(Content:Get())
                tween(Input_Outline, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Outer
                })
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
            end)

            utility:CreateConnection(Input_Box.Focused, function()
                tween(Input_Outline, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Color3.fromRGB(40, 30, 20)
                })
                tween(Content_Holder_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)
        end

        return Content
    end

    function sections:CreateDivider(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or ""),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 16),
                ZIndex = 3
            })

            local Divider_Line = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Border,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0.5, -1),
                Size = UDim2.new(1, -40, 0, 1),
                ZIndex = 3
            })

            local Divider_Title
            if Content.Name ~= "" then
                local Divider_Pad = utility:RenderObject("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Theme.Outer,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Parent = Content_Holder,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 10),
                    ZIndex = 4
                })

                Divider_Title = utility:RenderObject("TextLabel", {
                    BackgroundTransparency = 1,
                    Parent = Divider_Pad,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5,
                    Font = Enum.Font.Code,
                    RichText = true,
                    Text = "<font color='#9696a0'>" .. string.upper(Content.Name) .. "</font>",
                    TextColor3 = Theme.TextDim,
                    TextSize = 9,
                    TextXAlignment = "Center",
                    TextYAlignment = "Center"
                })
                local padW = Divider_Title.TextBounds.X + 14
                Divider_Pad.Size = UDim2.new(0, padW, 0, 12)
                Divider_Line.Size = UDim2.new(1, -40, 0, 1)
            end
        end

        return Content
    end

    function sections:CreateProgressBar(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Progress"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or 0),
            Max = (Properties.max or Properties.Max or 100),
            Display = (Properties.display or Properties.Display or "percent"),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -100, 0, 11),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Content_Holder_Value = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 50, 0, 11),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "0%",
                TextColor3 = Theme.Text,
                TextSize = 10,
                TextXAlignment = "Right",
                TextYAlignment = "Center"
            })

            local Bar_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 40, 0, 14),
                Size = UDim2.new(1, -80, 0, 6),
                ZIndex = 3
            })
            corner(Bar_Outline, 3)
            stroke(Bar_Outline, Theme.Border, 1, 0.4)

            local Bar_Track = utility:RenderObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(48, 48, 56),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Bar_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Bar_Track, 2)

            local Bar_Fill = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Bar_Track,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 4
            })
            corner(Bar_Fill, 2)
            gradient(Bar_Fill, Color3.fromRGB(255, 180, 80), Content.Window.Accent, 0)

            function Content:Set(state)
                Content.State = math.clamp(state, 0, Content.Max)
                local pct = Content.State / Content.Max
                tween(Bar_Fill, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                    Size = UDim2.new(pct, 0, 1, 0)
                })
                if Content.Display == "value" then
                    Content_Holder_Value.Text = "<b>" .. tostring(Content.State) .. "/" .. tostring(Content.Max) .. "</b>"
                else
                    Content_Holder_Value.Text = "<b>" .. math.floor(pct * 100) .. "%</b>"
                end
            end

            function Content:Get()
                return Content.State
            end

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateSwitch(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Switch"),
            State = (Properties.state or Properties.State or Properties.def or Properties.Def or false),
            Options = (Properties.options or Properties.Options or {"Off", "On"}),
            Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local Content_Holder_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Switch_Track = utility:RenderObject("Frame", {
                BackgroundColor3 = Color3.fromRGB(48, 48, 56),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(1, -56, 0, 5),
                Size = UDim2.new(0, 36, 0, 12),
                ZIndex = 3
            })
            corner(Switch_Track, 6)
            stroke(Switch_Track, Theme.Border, 1, 0.4)

            local Switch_Fill = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Switch_Track,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 4
            })
            corner(Switch_Fill, 6)
            gradient(Switch_Fill, Color3.fromRGB(255, 180, 80), Content.Window.Accent, 0)

            local Switch_Knob = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Text,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Switch_Track,
                Position = UDim2.new(0, 1, 0.5, -5),
                Size = UDim2.new(0, 10, 0, 10),
                ZIndex = 5
            })
            corner(Switch_Knob, 5)

            local Switch_Button = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            function Content:Set(state)
                Content.State = state
                local tw = 0.24
                if state then
                    tween(Switch_Fill, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                        BackgroundTransparency = 0
                    })
                    tween(Switch_Knob, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                        Position = UDim2.new(1, -11, 0.5, -5)
                    })
                    tween(Content_Holder_Title, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextColor3 = Theme.Text
                    })
                else
                    tween(Switch_Fill, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
                        BackgroundTransparency = 1
                    })
                    tween(Switch_Knob, tw, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
                        Position = UDim2.new(0, 1, 0.5, -5)
                    })
                    tween(Content_Holder_Title, tw, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextColor3 = Theme.TextMuted
                    })
                end
                Content.Callback(Content:Get())
            end

            function Content:Get()
                return Content.State
            end

            utility:CreateConnection(Switch_Button.MouseButton1Click, function()
                Content:Set(not Content:Get())
            end)

            utility:CreateConnection(Switch_Button.MouseEnter, function()
                tween(Switch_Track, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Color3.fromRGB(58, 58, 68)
                })
            end)

            utility:CreateConnection(Switch_Button.MouseLeave, function()
                tween(Switch_Track, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Color3.fromRGB(48, 48, 56)
                })
            end)

            Content:Set(Content.State)
        end

        return Content
    end

    function sections:CreateKeyValue(Properties)
        Properties = Properties or {}
        local Content = {
            Key = (Properties.key or Properties.Key or Properties.name or Properties.Name or "Key"),
            Value = (Properties.value or Properties.Value or "—"),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 3
            })

            local KV_Bg = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0.55,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 2),
                Size = UDim2.new(1, -40, 1, -4),
                ZIndex = 3
            })
            corner(KV_Bg, 3)

            local KV_Dot = utility:RenderObject("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 26, 0.5, 0),
                Size = UDim2.new(0, 3, 0, 3),
                ZIndex = 5
            })
            corner(KV_Dot, 2)

            local KV_Key = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 34, 0, 0),
                Size = UDim2.new(0.5, -34, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<font color='#62626a'>" .. string.upper(Content.Key) .. "</font>",
                TextColor3 = Theme.TextDim,
                TextSize = 9,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local KV_Value = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -30, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<font color='#989aa2'>" .. tostring(Content.Value) .. "</font>",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextTruncate = "AtEnd",
                TextXAlignment = "Right",
                TextYAlignment = "Center"
            })

            function Content:Set(value)
                Content.Value = value
                KV_Value.Text = "<font color='#989aa2'>" .. tostring(value) .. "</font>"
            end

            function Content:SetKey(key)
                Content.Key = key
                KV_Key.Text = "<font color='#62626a'>" .. string.upper(key) .. "</font>"
            end
        end

        return Content
    end

    function sections:CreateSegmented(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or "Segmented"),
            State = (Properties.state or Properties.State or 1),
            Options = (Properties.options or Properties.Options or {"A", "B"}),
            Callback = (Properties.callback or Properties.Callback or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 3
            })

            local Seg_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 44, 0, 5),
                Size = UDim2.new(1, -44, 0, 11),
                ZIndex = 3,
                Font = Enum.Font.Code,
                RichText = true,
                Text = Content.Name,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Seg_Bg = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 40, 0, 18),
                Size = UDim2.new(1, -60, 0, 16),
                ZIndex = 3
            })
            corner(Seg_Bg, 3)
            stroke(Seg_Bg, Theme.Border, 1, 0.4)

            local Seg_Inner = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Seg_Bg,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Seg_Inner, 2)

            local optionCount = #Content.Options
            local segButtons = {}
            local segHighlights = {}

            for Index, Option in pairs(Content.Options) do
                local segBtn = utility:RenderObject("TextButton", {
                    BackgroundTransparency = 1,
                    Parent = Seg_Inner,
                    Position = UDim2.new((Index - 1) / optionCount, 0, 0, 0),
                    Size = UDim2.new(1 / optionCount, 0, 1, 0),
                    ZIndex = 5,
                    Font = Enum.Font.Code,
                    RichText = true,
                    Text = tostring(Option),
                    TextColor3 = Index == Content.State and Theme.Text or Theme.TextMuted,
                    TextSize = 10,
                    TextTruncate = "AtEnd",
                    AutoButtonColor = false
                })

                local segHighlight = utility:RenderObject("Frame", {
                    BackgroundColor3 = Content.Window.Accent,
                    BackgroundTransparency = Index == Content.State and 0.7 or 1,
                    BorderSizePixel = 0,
                    Parent = Seg_Inner,
                    Position = UDim2.new((Index - 1) / optionCount, 1, 0, 1),
                    Size = UDim2.new(1 / optionCount, -2, 1, -2),
                    ZIndex = 4
                })
                corner(segHighlight, 2)
                gradient(segHighlight, Content.Window.Accent, Theme.AccentDim, 90)

                segButtons[Index] = segBtn
                segHighlights[Index] = segHighlight

                utility:CreateConnection(segBtn.MouseButton1Click, function()
                    Content:Set(Index)
                end)
                utility:CreateConnection(segBtn.MouseEnter, function()
                    if Index ~= Content.State then
                        tween(segBtn, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = Theme.Text
                        })
                    end
                end)
                utility:CreateConnection(segBtn.MouseLeave, function()
                    if Index ~= Content.State then
                        tween(segBtn, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                            TextColor3 = Theme.TextMuted
                        })
                    end
                end)
            end

            function Content:Set(state)
                Content.State = state
                for Index, btn in pairs(segButtons) do
                    local active = Index == state
                    tween(btn, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextColor3 = active and Theme.Text or Theme.TextMuted
                    })
                    tween(segHighlights[Index], 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundTransparency = active and 0.7 or 1
                    })
                end
                Content.Callback(state)
            end

            function Content:Get()
                return Content.State
            end
        end

        return Content
    end

    function sections:CreateIconButton(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or "Button"),
            Icon = (Properties.icon or Properties.Icon or "rbxassetid://8547236654"),
            Callback = (Properties.callback or Properties.Callback or function() end),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 3
            })

            local Btn_Outline = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Outer,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 4),
                Size = UDim2.new(1, -40, 0, 16),
                ZIndex = 3
            })
            corner(Btn_Outline, 3)
            stroke(Btn_Outline, Theme.Border, 1, 0.4)

            local Btn_Frame = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Btn_Outline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 3
            })
            corner(Btn_Frame, 2)
            gradient(Btn_Frame, Theme.ItemHover, Theme.Item, 90)

            local Btn_IconBg = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0.85,
                BorderSizePixel = 0,
                Parent = Btn_Frame,
                Position = UDim2.new(0, 2, 0.5, -7),
                Size = UDim2.new(0, 14, 0, 14),
                ZIndex = 4
            })
            corner(Btn_IconBg, 3)

            local Btn_Icon = utility:RenderObject("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Parent = Btn_IconBg,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 9, 0, 9),
                ZIndex = 5,
                Image = Content.Icon,
                ImageColor3 = Content.Window.Accent
            })

            local Btn_Title = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Btn_Frame,
                Position = UDim2.new(0, 20, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b>" .. Content.Name .. "</b>",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Btn_Click = utility:RenderObject("TextButton", {
                BackgroundTransparency = 1,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 4),
                Size = UDim2.new(1, -40, 0, 16),
                Text = "",
                ZIndex = 6,
                AutoButtonColor = false
            })

            function Content:Set(name)
                if name then
                    Content.Name = name
                    Btn_Title.Text = "<b>" .. name .. "</b>"
                end
            end

            utility:CreateConnection(Btn_Click.MouseButton1Click, function()
                Content.Callback()
                tween(Btn_IconBg, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 0.4
                })
                task.delay(0.18, function()
                    tween(Btn_IconBg, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        BackgroundTransparency = 0.85
                    })
                end)
            end)

            utility:CreateConnection(Btn_Click.MouseEnter, function()
                tween(Btn_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.ItemHover
                })
                tween(Btn_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.Text
                })
            end)
            utility:CreateConnection(Btn_Click.MouseLeave, function()
                tween(Btn_Frame, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    BackgroundColor3 = Theme.Item
                })
                tween(Btn_Title, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                    TextColor3 = Theme.TextMuted
                })
            end)
        end

        return Content
    end

    function sections:CreateStat(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or "Stat"),
            Value = (Properties.value or Properties.Value or 0),
            Suffix = (Properties.suffix or Properties.Suffix or ""),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 40),
                ZIndex = 3
            })

            local Stat_Bg = utility:RenderObject("Frame", {
                BackgroundColor3 = Theme.Item,
                BackgroundTransparency = 0.55,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0, 4),
                Size = UDim2.new(1, -40, 1, -8),
                ZIndex = 3
            })
            corner(Stat_Bg, 3)
            stroke(Stat_Bg, Theme.Border, 1, 0.5)

            local Stat_Accent = utility:RenderObject("Frame", {
                BackgroundColor3 = Content.Window.Accent,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = Stat_Bg,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 2, 1, 0),
                ZIndex = 4
            })
            corner(Stat_Accent, 1)

            local Stat_Label = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Stat_Bg,
                Position = UDim2.new(0, 10, 0, 4),
                Size = UDim2.new(1, -14, 0, 10),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<font color='#62626a'>" .. string.upper(Content.Name) .. "</font>",
                TextColor3 = Theme.TextDim,
                TextSize = 9,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            local Stat_Value = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Stat_Bg,
                Position = UDim2.new(0, 10, 0, 16),
                Size = UDim2.new(1, -14, 0, 16),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b><font color='#e8e8ee'>" .. tostring(Content.Value) .. "</font><font color='#787882'>" .. Content.Suffix .. "</font></b>",
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextTruncate = "AtEnd",
                TextXAlignment = "Left",
                TextYAlignment = "Center"
            })

            function Content:Set(value)
                Content.Value = value
                Stat_Value.Text = "<b><font color='#e8e8ee'>" .. tostring(value) .. "</font><font color='#787882'>" .. Content.Suffix .. "</font></b>"
            end
        end

        return Content
    end

    function sections:CreateBadge(Properties)
        Properties = Properties or {}
        local Content = {
            Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "Badge"),
            Color = (Properties.color or Properties.Color or Properties.tint or Properties.Tint or Theme.Accent),
            Window = self.Window,
            Page = self.Page,
            Section = self
        }

        do
            local Content_Holder = utility:RenderObject("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = Content.Section.Holder,
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = 3
            })

            local Badge_Bg = utility:RenderObject("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Content.Color,
                BackgroundTransparency = 0.85,
                BorderSizePixel = 0,
                Parent = Content_Holder,
                Position = UDim2.new(0, 20, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 14),
                ZIndex = 4
            })
            corner(Badge_Bg, 3)

            local Badge_Text = utility:RenderObject("TextLabel", {
                BackgroundTransparency = 1,
                Parent = Badge_Bg,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                ZIndex = 5,
                Font = Enum.Font.Code,
                RichText = true,
                Text = "<b>" .. string.upper(Content.Name) .. "</b>",
                TextColor3 = Content.Color,
                TextSize = 9,
                TextXAlignment = "Center",
                TextYAlignment = "Center"
            })

            task.defer(function()
                Badge_Bg.Size = UDim2.new(0, Badge_Text.TextBounds.X + 16, 0, 14)
            end)
            Badge_Bg.Size = UDim2.new(0, 60, 0, 14)
        end

        return Content
    end
end

local function wrapCreateForSearch(origFn)
    return function(self, props)
        local sectionHolder = self.Holder
        local before = {}
        if sectionHolder then
            for _, child in ipairs(sectionHolder:GetChildren()) do
                before[child] = true
            end
        end

        local content = origFn(self, props)

        if content and content.Name ~= nil and sectionHolder and self.SearchEntries then
            for _, child in ipairs(sectionHolder:GetChildren()) do
                if not before[child] and child:IsA("Frame") then
                    table.insert(self.SearchEntries, {
                        name = content.Name,
                        holder = child,
                        content = content
                    })
                    break
                end
            end
        end

        return content
    end
end

for _, fname in ipairs({
    "CreateToggle", "CreateSlider", "CreateDropdown", "CreateMultibox",
    "CreateKeybind", "CreateColorpicker", "CreateButton", "CreateLabel",
    "CreateInput", "CreateDivider", "CreateProgressBar",    "CreateKeyValue", "CreateSegmented", "CreateIconButton", "CreateStat",
    "CreateBadge"
}) do
    local original = sections[fname]
    if type(original) == "function" then
        sections[fname] = wrapCreateForSearch(original)
    end
end

-- Shorthand aliases for simplified control creation
sections.Button = sections.CreateButton
sections.Toggle = sections.CreateToggle
sections.Slider = sections.CreateSlider
sections.Dropdown = sections.CreateDropdown
sections.Keybind = sections.CreateKeybind
sections.Colorpicker = sections.CreateColorpicker
sections.Multibox = sections.CreateMultibox
sections.Label = sections.CreateLabel
sections.Input = sections.CreateInput
sections.Divider = sections.CreateDivider
sections.ProgressBar = sections.CreateProgressBar
sections.Switch = sections.CreateSwitch
sections.Badge = sections.CreateBadge
sections.TextBox = sections.CreateInput
sections.Header = sections.CreateLabel
sections.KeyValue = sections.CreateKeyValue
sections.Segmented = sections.CreateSegmented
sections.IconButton = sections.CreateIconButton
sections.Stat = sections.CreateStat

pages.Section = pages.CreateSection

return library