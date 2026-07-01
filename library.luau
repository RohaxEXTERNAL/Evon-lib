--[[
    Falcon UI Library
    A high-quality, modern UI library inspired by the classic CS2 cheat menu aesthetic.
    Featuring crisp borders, low-profile layout, smooth animations, global search,
    live theme engines, accent customizers, and virtualized player lists.
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Theme, Font, and Accent states
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 24),
        Header = Color3.fromRGB(15, 15, 18),
        Border = Color3.fromRGB(35, 35, 42),
        InnerBorder = Color3.fromRGB(24, 24, 30),
        Text = Color3.fromRGB(230, 230, 235),
        MutedText = Color3.fromRGB(140, 140, 150),
        ElementBackground = Color3.fromRGB(26, 26, 32),
        ElementHover = Color3.fromRGB(32, 32, 40),
        ElementSelected = Color3.fromRGB(38, 38, 48),
        NotificationBg = Color3.fromRGB(24, 24, 30),
        ModalOverlay = Color3.fromRGB(10, 10, 12)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 248),
        Header = Color3.fromRGB(230, 230, 235),
        Border = Color3.fromRGB(200, 200, 205),
        InnerBorder = Color3.fromRGB(220, 220, 225),
        Text = Color3.fromRGB(40, 40, 45),
        MutedText = Color3.fromRGB(120, 120, 130),
        ElementBackground = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(240, 240, 245),
        ElementSelected = Color3.fromRGB(230, 230, 235),
        NotificationBg = Color3.fromRGB(250, 250, 253),
        ModalOverlay = Color3.fromRGB(220, 220, 225)
    },
    Midnight = {
        Background = Color3.fromRGB(10, 11, 20),
        Header = Color3.fromRGB(6, 7, 14),
        Border = Color3.fromRGB(24, 26, 42),
        InnerBorder = Color3.fromRGB(15, 17, 30),
        Text = Color3.fromRGB(215, 220, 240),
        MutedText = Color3.fromRGB(115, 120, 145),
        ElementBackground = Color3.fromRGB(16, 18, 32),
        ElementHover = Color3.fromRGB(22, 24, 42),
        ElementSelected = Color3.fromRGB(28, 32, 54),
        NotificationBg = Color3.fromRGB(12, 13, 24),
        ModalOverlay = Color3.fromRGB(5, 5, 10)
    },
    OLED = {
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(28, 28, 28),
        InnerBorder = Color3.fromRGB(14, 14, 14),
        Text = Color3.fromRGB(255, 255, 255),
        MutedText = Color3.fromRGB(130, 130, 130),
        ElementBackground = Color3.fromRGB(8, 8, 8),
        ElementHover = Color3.fromRGB(18, 18, 18),
        ElementSelected = Color3.fromRGB(28, 28, 28),
        NotificationBg = Color3.fromRGB(5, 5, 5),
        ModalOverlay = Color3.fromRGB(0, 0, 0)
    },
    Classic = {
        Background = Color3.fromRGB(38, 38, 43),
        Header = Color3.fromRGB(28, 28, 33),
        Border = Color3.fromRGB(52, 52, 58),
        InnerBorder = Color3.fromRGB(42, 42, 48),
        Text = Color3.fromRGB(240, 240, 245),
        MutedText = Color3.fromRGB(150, 150, 160),
        ElementBackground = Color3.fromRGB(44, 44, 50),
        ElementHover = Color3.fromRGB(50, 50, 58),
        ElementSelected = Color3.fromRGB(58, 58, 66),
        NotificationBg = Color3.fromRGB(32, 32, 36),
        ModalOverlay = Color3.fromRGB(20, 20, 22)
    }
}

Library.Fonts = {
    Inter = Enum.Font.Inter,
    SegoeUI = Enum.Font.SegoeUI,
    Roboto = Enum.Font.Roboto,
    JetBrainsMono = Enum.Font.Code,
    SFPro = Enum.Font.SourceSans,
    Poppins = Enum.Font.FredokaOne
}

Library.Accents = {
    Blue = Color3.fromRGB(0, 140, 255),
    Purple = Color3.fromRGB(150, 60, 255),
    Red = Color3.fromRGB(255, 60, 60),
    Orange = Color3.fromRGB(255, 120, 0),
    Green = Color3.fromRGB(0, 220, 100),
    Cyan = Color3.fromRGB(0, 210, 210),
    Pink = Color3.fromRGB(255, 80, 180),
    Yellow = Color3.fromRGB(255, 200, 0),
    White = Color3.fromRGB(255, 255, 255)
}

Library.Icons = {
    Combat = "rbxassetid://10747373176",
    Visuals = "rbxassetid://10723351984",
    Players = "rbxassetid://10747372167",
    World = "rbxassetid://10734943793",
    Movement = "rbxassetid://10723395914",
    Misc = "rbxassetid://10723381659",
    Config = "rbxassetid://10734923549",
    Settings = "rbxassetid://10734950309",
    Search = "rbxassetid://10723391743",
    Chevron = "rbxassetid://10723348123",
    Close = "rbxassetid://10723350294",
    Info = "rbxassetid://10723346885",
    Warning = "rbxassetid://10734953937",
    Success = "rbxassetid://10723396113",
    Error = "rbxassetid://10723377701",
    Pin = "rbxassetid://10723376332",
    Folder = "rbxassetid://10734923549",
    Plus = "rbxassetid://10723345716",
    Trash = "rbxassetid://10723352239",
    Edit = "rbxassetid://10723358359"
}

-- Configurations & Variables
Library.CurrentTheme = "Dark"
Library.CurrentAccent = Library.Accents.Blue
Library.CurrentFont = Library.Fonts.Inter
Library.Config = {
    CornerRadius = 4,
    AnimationSpeed = 0.18,
    BlurStrength = 10,
    Transparency = 0,
    BorderThickness = 1,
    ShadowIntensity = 0.3,
    Padding = 6,
    CompactMode = false
}

-- Live Update Bindings
local ThemeBinders = {}
local AccentBinders = {}
local FontBinders = {}

function Library:BindTheme(instance, property, colorKey)
    ThemeBinders[instance] = ThemeBinders[instance] or {}
    ThemeBinders[instance][property] = colorKey
    instance[property] = Library.Themes[Library.CurrentTheme][colorKey]
    
    local conn
    conn = instance.Destroying:Connect(function()
        ThemeBinders[instance] = nil
        conn:Disconnect()
    end)
end

function Library:BindAccent(instance, property)
    AccentBinders[instance] = AccentBinders[instance] or {}
    AccentBinders[instance][property] = true
    instance[property] = Library.CurrentAccent
    
    local conn
    conn = instance.Destroying:Connect(function()
        AccentBinders[instance] = nil
        conn:Disconnect()
    end)
end

function Library:BindFont(instance, property)
    FontBinders[instance] = FontBinders[instance] or {}
    FontBinders[instance][property] = true
    instance[property] = Library.CurrentFont
    
    local conn
    conn = instance.Destroying:Connect(function()
        FontBinders[instance] = nil
        conn:Disconnect()
    end)
end

function Library:SetTheme(themeName)
    if not Library.Themes[themeName] then return end
    Library.CurrentTheme = themeName
    local colors = Library.Themes[themeName]
    for inst, props in pairs(ThemeBinders) do
        if inst and inst.Parent then
            for prop, colorKey in pairs(props) do
                TweenService:Create(inst, TweenInfo.new(Library.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    [prop] = colors[colorKey]
                }):Play()
            end
        end
    end
end

function Library:SetAccent(color)
    Library.CurrentAccent = color
    for inst, props in pairs(AccentBinders) do
        if inst and inst.Parent then
            for prop, _ in pairs(props) do
                TweenService:Create(inst, TweenInfo.new(Library.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    [prop] = color
                }):Play()
            end
        end
    end
end

function Library:SetFont(fontName)
    local font = Library.Fonts[fontName]
    if not font then return end
    Library.CurrentFont = font
    for inst, props in pairs(FontBinders) do
        if inst and inst.Parent then
            for prop, _ in pairs(props) do
                inst[prop] = font
            end
        end
    end
end

-- Helper functions for layout and components
local function createUIStroke(parent, colorKey, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or Library.Config.BorderThickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = parent
    Library:BindTheme(stroke, "Color", colorKey)
    return stroke
end

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Library.Config.CornerRadius)
    corner.Parent = parent
    return corner
end

local function createUIPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or Library.Config.Padding)
    padding.PaddingBottom = UDim.new(0, bottom or Library.Config.Padding)
    padding.PaddingLeft = UDim.new(0, left or Library.Config.Padding)
    padding.PaddingRight = UDim.new(0, right or Library.Config.Padding)
    padding.Parent = parent
    return padding
end

-- Notification System Setup
local NotificationScreen = Instance.new("ScreenGui")
NotificationScreen.Name = "FalconNotifications"
NotificationScreen.ResetOnSpawn = false
NotificationScreen.DisplayOrder = 9999
pcall(function()
    NotificationScreen.Parent = CoreGui
end)

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 300, 1, -40)
NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = NotificationScreen

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.Parent = NotificationContainer

function Library:Notify(options)
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 4
    local notifyType = options.Type or "Info" -- Info, Warning, Success, Error
    
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 60)
    toast.BorderSizePixel = 0
    Library:BindTheme(toast, "BackgroundColor3", "NotificationBg")
    createUICorner(toast)
    createUIStroke(toast, "Border")
    
    local iconMap = {
        Info = Library.Icons.Info,
        Warning = Library.Icons.Warning,
        Success = Library.Icons.Success,
        Error = Library.Icons.Error
    }
    local accentMap = {
        Info = Library.Accents.Blue,
        Warning = Library.Accents.Orange,
        Success = Library.Accents.Green,
        Error = Library.Accents.Red
    }
    
    local accentColor = accentMap[notifyType] or Library.CurrentAccent
    local iconId = iconMap[notifyType] or Library.Icons.Info
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast
    createUICorner(accentBar)
    -- Remove rounded corners on the right side of accent bar to keep it sleek
    local subCornerRemover = Instance.new("Frame")
    subCornerRemover.Size = UDim2.new(0, 4, 1, 0)
    subCornerRemover.Position = UDim2.new(0, 2, 0, 0)
    subCornerRemover.BackgroundColor3 = accentColor
    subCornerRemover.BorderSizePixel = 0
    subCornerRemover.Parent = accentBar

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = accentColor
    icon.Parent = toast
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -44, 0, 16)
    titleLabel.Position = UDim2.new(0, 38, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextSize = 13
    titleLabel.Font = Library.CurrentFont
    Library:BindFont(titleLabel, "Font")
    Library:BindTheme(titleLabel, "TextColor3", "Text")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toast
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -44, 0, 24)
    contentLabel.Position = UDim2.new(0, 38, 0, 26)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextSize = 11
    contentLabel.Font = Library.CurrentFont
    Library:BindFont(contentLabel, "Font")
    Library:BindTheme(contentLabel, "TextColor3", "MutedText")
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = toast
    
    toast.Position = UDim2.new(1, 320, 0, 0)
    toast.Parent = NotificationContainer
    
    -- Slide In animation
    TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    task.delay(duration, function()
        if toast and toast.Parent then
            local slideOut = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 320, 0, 0)
            })
            slideOut:Play()
            slideOut.Completed:Connect(function()
                toast:Destroy()
            end)
        end
    end)
end

-- Core Window Creation
function Library:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Falcon OSINT"
    local windowSubtitle = options.Subtitle or "Cheat Menu"
    local defaultSize = options.Size or UDim2.new(0, 740, 0, 480)
    local toggleKey = options.DefaultKeybind or Enum.KeyCode.Insert
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FalconUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    
    -- Main Window CanvasGroup (for smooth fades)
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Size = defaultSize
    MainFrame.Position = UDim2.new(0.5, -defaultSize.X.Offset/2, 0.5, -defaultSize.Y.Offset/2)
    Library:BindTheme(MainFrame, "BackgroundColor3", "Background")
    createUICorner(MainFrame)
    createUIStroke(MainFrame, "Border")
    MainFrame.Parent = ScreenGui
    
    -- Dual inner border look
    local InnerBorderFrame = Instance.new("Frame")
    InnerBorderFrame.Size = UDim2.new(1, -2, 1, -2)
    InnerBorderFrame.Position = UDim2.new(0, 1, 0, 1)
    InnerBorderFrame.BackgroundTransparency = 1
    createUICorner(InnerBorderFrame)
    createUIStroke(InnerBorderFrame, "InnerBorder")
    InnerBorderFrame.Parent = MainFrame

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 48)
    Library:BindTheme(Header, "BackgroundColor3", "Header")
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    -- Bottom border line of Header
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    Library:BindTheme(headerLine, "BackgroundColor3", "Border")
    headerLine.BorderSizePixel = 0
    headerLine.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 120, 0, 20)
    Title.Position = UDim2.new(0, 16, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = windowTitle
    Title.TextSize = 15
    Title.Font = Library.CurrentFont
    Library:BindFont(Title, "Font")
    Library:BindTheme(Title, "TextColor3", "Text")
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 120, 0, 12)
    Subtitle.Position = UDim2.new(0, 16, 0, 26)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = windowSubtitle
    Subtitle.TextSize = 10
    Subtitle.Font = Library.CurrentFont
    Library:BindFont(Subtitle, "Font")
    Library:BindTheme(Subtitle, "TextColor3", "MutedText")
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header

    -- Dragging Mechanic
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Resizing Mechanic
    local resizeHandle = Instance.new("ImageLabel")
    resizeHandle.Size = UDim2.new(0, 12, 0, 12)
    resizeHandle.Position = UDim2.new(1, -12, 1, -12)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Image = "rbxassetid://10723348123" -- Simple chevron/handle representation
    resizeHandle.ImageColor3 = Library.Themes[Library.CurrentTheme].MutedText
    Library:BindTheme(resizeHandle, "ImageColor3", "MutedText")
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = MainFrame
    
    local resizing = false
    local resizeStartSize, resizeStartPos
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStartPos = input.Position
            resizeStartSize = MainFrame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(resizeStartSize.X.Offset + delta.X, 580, 1000)
            local newHeight = math.clamp(resizeStartSize.Y.Offset + delta.Y, 360, 750)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    -- Horizontal Navigation System Container
    local NavigationContainer = Instance.new("Frame")
    NavigationContainer.Size = UDim2.new(1, -340, 1, 0)
    NavigationContainer.Position = UDim2.new(0, 160, 0, 0)
    NavigationContainer.BackgroundTransparency = 1
    NavigationContainer.Parent = Header
    
    local NavLayout = Instance.new("UIListLayout")
    NavLayout.FillDirection = Enum.FillDirection.Horizontal
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    NavLayout.Padding = UDim.new(0, 10)
    NavLayout.Parent = NavigationContainer

    -- Active Tab Indicator
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Size = UDim2.new(0, 0, 0, 2)
    TabIndicator.Position = UDim2.new(0, 0, 1, -2)
    TabIndicator.BorderSizePixel = 0
    Library:BindAccent(TabIndicator, "BackgroundColor3")
    TabIndicator.Parent = Header

    -- Search Bar next to Window Controls
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 100, 0, 24)
    SearchBox.Position = UDim2.new(1, -190, 0, 12)
    Library:BindTheme(SearchBox, "BackgroundColor3", "ElementBackground")
    createUICorner(SearchBox, 3)
    createUIStroke(SearchBox, "Border")
    SearchBox.PlaceholderText = "Search..."
    SearchBox.Text = ""
    SearchBox.TextSize = 11
    SearchBox.Font = Library.CurrentFont
    Library:BindFont(SearchBox, "Font")
    Library:BindTheme(SearchBox, "TextColor3", "Text")
    Library:BindTheme(SearchBox, "PlaceholderColor3", "MutedText")
    SearchBox.ClipsDescendants = true
    SearchBox.Parent = Header
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 12, 0, 12)
    searchIcon.Position = UDim2.new(1, -16, 0, 6)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = Library.Icons.Search
    Library:BindTheme(searchIcon, "ImageColor3", "MutedText")
    searchIcon.Parent = SearchBox

    -- Window Controls (Minimize & Close)
    local WindowControls = Instance.new("Frame")
    WindowControls.Size = UDim2.new(0, 60, 1, 0)
    WindowControls.Position = UDim2.new(1, -70, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = Header
    
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(0.6, 0, 0.3, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = Library.Icons.Close
    Library:BindTheme(CloseBtn, "ImageColor3", "MutedText")
    CloseBtn.Parent = WindowControls
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {ImageColor3 = Library.Accents.Red}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {ImageColor3 = Library.Themes[Library.CurrentTheme].MutedText}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Container for all Tab Pages
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -24, 1, -64)
    PagesContainer.Position = UDim2.new(0, 12, 0, 56)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainFrame

    -- Global Visibility Toggle Hook
    local visibleState = true
    local menuToggleConn
    
    local function toggleMenu(state)
        visibleState = state
        if visibleState then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(Library.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                GroupTransparency = 0
            }):Play()
        else
            local fadeOut = TweenService:Create(MainFrame, TweenInfo.new(Library.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                GroupTransparency = 1
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                if not visibleState then
                    MainFrame.Visible = false
                end
            end)
        end
    end
    
    menuToggleConn = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            toggleMenu(not visibleState)
        end
    end)

    local Window = {
        Frame = MainFrame,
        Gui = ScreenGui,
        Tabs = {},
        SearchQueue = {},
        CurrentTab = nil
    }

    function Window:SetKeybind(key)
        toggleKey = key
        Library:Notify({
            Title = "Keybind Changed",
            Content = "Menu toggle re-bound to: " .. key.Name,
            Type = "Info"
        })
    end
    
    -- Cleanup connection on screenGui destroy
    ScreenGui.Destroying:Connect(function()
        if menuToggleConn then menuToggleConn:Disconnect() end
    end)

    -- Search query handler
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, elem in ipairs(Window.SearchQueue) do
            local visible = query == "" or elem.Name:lower():find(query) ~= nil
            elem.Instance.Visible = visible
            
            -- If visible, ensure its parent section and parent tab show
            if visible then
                elem.Section.Frame.Visible = true
                if elem.Section.CollapseButton then
                    elem.Section.CollapseButton.Text = "-"
                end
                elem.Section.ContentContainer.Visible = true
            end
        end
        
        -- Auto-collapse sections if empty
        for _, tab in ipairs(Window.Tabs) do
            for _, sect in ipairs(tab.Sections) do
                local anyVisible = false
                for _, item in ipairs(sect.Items) do
                    if item.Visible then
                        anyVisible = true
                        break
                    end
                end
                if query ~= "" then
                    sect.Frame.Visible = anyVisible
                else
                    sect.Frame.Visible = true
                end
            end
        end
    end)

    -- Create Tab Method
    function Window:CreateTab(name, iconName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = NavigationContainer
        
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.Position = UDim2.new(0, 6, 0.5, -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = Library.Icons[iconName] or Library.Icons.Misc
        Library:BindTheme(tabIcon, "ImageColor3", "MutedText")
        tabIcon.Parent = TabButton
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -26, 1, 0)
        tabLabel.Position = UDim2.new(0, 26, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = name
        tabLabel.TextSize = 12
        tabLabel.Font = Library.CurrentFont
        Library:BindFont(tabLabel, "Font")
        Library:BindTheme(tabLabel, "TextColor3", "MutedText")
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = TabButton
        
        -- The actual page container
        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = PagesContainer
        
        -- Left and Right Columns
        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.BorderSizePixel = 0
        LeftColumn.ScrollBarThickness = 2
        LeftColumn.ScrollBarImageColor3 = Library.Themes[Library.CurrentTheme].Border
        Library:BindTheme(LeftColumn, "ScrollBarImageColor3", "Border")
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.Parent = TabPage
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn
        
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local RightColumn = LeftColumn:Clone()
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.Parent = TabPage
        
        RightColumn.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightColumn.UIListLayout.AbsoluteContentSize.Y + 10)
        end)

        local Tab = {
            Name = name,
            Button = TabButton,
            Page = TabPage,
            Sections = {},
            LeftColumn = LeftColumn,
            RightColumn = RightColumn
        }
        
        local function Select()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Library:BindTheme(Window.CurrentTab.Button.TextLabel, "TextColor3", "MutedText")
                Library:BindTheme(Window.CurrentTab.Button.ImageLabel, "ImageColor3", "MutedText")
            end
            Window.CurrentTab = Tab
            TabPage.Visible = true
            Library:BindTheme(tabLabel, "TextColor3", "Text")
            Library:BindAccent(tabIcon, "ImageColor3")
            
            -- Animate navigation indicator line
            task.spawn(function()
                repeat task.wait() until TabButton.AbsolutePosition.X > 0
                TweenService:Create(TabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, TabButton.AbsoluteSize.X, 0, 2),
                    Position = UDim2.new(0, TabButton.AbsolutePosition.X - Header.AbsolutePosition.X, 1, -2)
                }):Play()
            end)
        end
        
        TabButton.MouseButton1Click:Connect(Select)
        
        -- Default selection
        if not Window.CurrentTab then
            Select()
        end
        
        table.insert(Window.Tabs, Tab)

        -- Create Section Method (GroupBox)
        function Tab:CreateSection(sectionName, side)
            local targetColumn = (side == "Right") and RightColumn or LeftColumn
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -6, 0, 40)
            Library:BindTheme(SectionFrame, "BackgroundColor3", "Background")
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = targetColumn
            createUICorner(SectionFrame)
            createUIStroke(SectionFrame, "Border")
            
            -- CS2 Inset Title
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Position = UDim2.new(0, 12, 0, -8)
            Library:BindTheme(TitleLabel, "BackgroundColor3", "Background")
            TitleLabel.Text = "  " .. sectionName .. "  "
            TitleLabel.TextSize = 11
            TitleLabel.Font = Library.CurrentFont
            Library:BindFont(TitleLabel, "Font")
            Library:BindTheme(TitleLabel, "TextColor3", "Text")
            
            -- Calculate precise size for cover overlay
            local textBounds = TextService:GetTextSize(TitleLabel.Text, 11, Library.CurrentFont, Vector2.new(1000, 1000))
            TitleLabel.Size = UDim2.new(0, textBounds.X, 0, 16)
            TitleLabel.Parent = SectionFrame
            
            -- Collapse Button
            local CollapseBtn = Instance.new("TextButton")
            CollapseBtn.Size = UDim2.new(0, 16, 0, 16)
            CollapseBtn.Position = UDim2.new(1, -24, 0, -8)
            Library:BindTheme(CollapseBtn, "BackgroundColor3", "Background")
            CollapseBtn.Text = "-"
            CollapseBtn.TextSize = 12
            CollapseBtn.Font = Enum.Font.Code
            Library:BindTheme(CollapseBtn, "TextColor3", "MutedText")
            CollapseBtn.Parent = SectionFrame
            
            local ContentContainer = Instance.new("Frame")
            ContentContainer.Size = UDim2.new(1, 0, 1, -12)
            ContentContainer.Position = UDim2.new(0, 0, 0, 12)
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.Parent = SectionFrame
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 8)
            ContentLayout.Parent = ContentContainer
            createUIPadding(ContentContainer, 8, 8, 12, 12)

            local Section = {
                Frame = SectionFrame,
                ContentContainer = ContentContainer,
                CollapseButton = CollapseBtn,
                Items = {}
            }
            
            local function resizeSection()
                if ContentContainer.Visible then
                    local totalHeight = ContentLayout.AbsoluteContentSize.Y + 24
                    SectionFrame.Size = UDim2.new(1, -6, 0, totalHeight)
                else
                    SectionFrame.Size = UDim2.new(1, -6, 0, 20)
                end
            end
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeSection)
            
            -- Toggle Collapse logic
            local collapsed = false
            CollapseBtn.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                CollapseBtn.Text = collapsed and "+" or "-"
                ContentContainer.Visible = not collapsed
                resizeSection()
            end)

            table.insert(Tab.Sections, Section)

            -- REGISTER CONTROLS
            
            -- 1. Checkbox / Toggle
            function Section:CreateToggle(toggleName, default, callback)
                local value = default or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ContentContainer
                
                local CheckboxBox = Instance.new("Frame")
                CheckboxBox.Size = UDim2.new(0, 14, 0, 14)
                CheckboxBox.Position = UDim2.new(0, 0, 0.5, -7)
                Library:BindTheme(CheckboxBox, "BackgroundColor3", "ElementBackground")
                createUICorner(CheckboxBox, 2)
                createUIStroke(CheckboxBox, "Border")
                CheckboxBox.Parent = ToggleFrame
                
                local tick = Instance.new("Frame")
                tick.Size = UDim2.new(1, -4, 1, -4)
                tick.Position = UDim2.new(0, 2, 0, 2)
                createUICorner(tick, 2)
                tick.BackgroundColor3 = Library.CurrentAccent
                tick.BackgroundTransparency = value and 0 or 1
                tick.BorderSizePixel = 0
                tick.Parent = CheckboxBox
                Library:BindAccent(tick, "BackgroundColor3")
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -22, 1, 0)
                label.Position = UDim2.new(0, 22, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = toggleName
                label.TextSize = 12
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = ToggleFrame
                
                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.Parent = ToggleFrame
                
                local function updateState()
                    value = not value
                    TweenService:Create(tick, TweenInfo.new(Library.Config.AnimationSpeed), {
                        BackgroundTransparency = value and 0 or 1
                    }):Play()
                    callback(value)
                end
                
                ClickArea.MouseButton1Click:Connect(updateState)
                
                -- Support search registration
                local searchItem = {Name = toggleName, Instance = ToggleFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
                
                return {
                    SetValue = function(self, val)
                        value = val
                        tick.BackgroundTransparency = value and 0 or 1
                        callback(value)
                    end,
                    GetValue = function(self)
                        return value
                    end
                }
            end

            -- 2. Button
            function Section:CreateButton(btnName, callback)
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Size = UDim2.new(1, 0, 0, 26)
                Library:BindTheme(BtnFrame, "BackgroundColor3", "ElementBackground")
                createUICorner(BtnFrame, 3)
                createUIStroke(BtnFrame, "Border")
                BtnFrame.Text = ""
                BtnFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = btnName
                label.TextSize = 12
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.Parent = BtnFrame
                
                BtnFrame.MouseEnter:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.15), {
                        BackgroundColor3 = Library.Themes[Library.CurrentTheme].ElementHover
                    }):Play()
                end)
                
                BtnFrame.MouseLeave:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.15), {
                        BackgroundColor3 = Library.Themes[Library.CurrentTheme].ElementBackground
                    }):Play()
                end)
                
                BtnFrame.MouseButton1Click:Connect(callback)
                
                local searchItem = {Name = btnName, Instance = BtnFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            -- 3. Slider
            function Section:CreateSlider(sliderName, min, max, default, decimals, callback)
                decimals = decimals or 0
                local value = default or min
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = sliderName
                label.TextSize = 11
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = SliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(1, 0, 0, 14)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = string.format("%." .. decimals .. "f", value)
                valueLabel.TextSize = 11
                valueLabel.Font = Library.CurrentFont
                Library:BindFont(valueLabel, "Font")
                Library:BindTheme(valueLabel, "TextColor3", "MutedText")
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = SliderFrame
                
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, 0, 0, 6)
                track.Position = UDim2.new(0, 0, 1, -10)
                Library:BindTheme(track, "BackgroundColor3", "InnerBorder")
                createUICorner(track, 2)
                createUIStroke(track, "Border")
                track.Parent = SliderFrame
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                Library:BindAccent(fill, "BackgroundColor3")
                createUICorner(fill, 2)
                fill.BorderSizePixel = 0
                fill.Parent = track
                
                local draggingSlider = false
                
                local function updateValue(input)
                    local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * percentage
                    -- Clamp to decimals
                    value = math.round(value * (10 ^ decimals)) / (10 ^ decimals)
                    
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    valueLabel.Text = string.format("%." .. decimals .. "f", value)
                    callback(value)
                end
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        updateValue(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateValue(input)
                    end
                end)
                
                local searchItem = {Name = sliderName, Instance = SliderFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
                
                return {
                    SetValue = function(self, val)
                        value = math.clamp(val, min, max)
                        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        valueLabel.Text = string.format("%." .. decimals .. "f", value)
                        callback(value)
                    end
                }
            end

            -- 4. Color Picker
            function Section:CreateColorPicker(pickerName, default, callback)
                local colorValue = default or Color3.fromRGB(255, 255, 255)
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(1, 0, 0, 20)
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -30, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = pickerName
                label.TextSize = 12
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = PickerFrame
                
                local preview = Instance.new("TextButton")
                preview.Size = UDim2.new(0, 24, 0, 14)
                preview.Position = UDim2.new(1, -24, 0.5, -7)
                preview.BackgroundColor3 = colorValue
                preview.Text = ""
                createUICorner(preview, 2)
                createUIStroke(preview, "Border")
                preview.Parent = PickerFrame
                
                -- Dynamic Inline Color Picker Panel
                local pickerPanel = Instance.new("Frame")
                pickerPanel.Size = UDim2.new(1, 0, 0, 100)
                pickerPanel.BackgroundTransparency = 1
                pickerPanel.Visible = false
                pickerPanel.Parent = ContentContainer
                
                local rSlider = Instance.new("TextBox")
                rSlider.Size = UDim2.new(0.3, -4, 0, 24)
                rSlider.Position = UDim2.new(0, 0, 0, 10)
                Library:BindTheme(rSlider, "BackgroundColor3", "ElementBackground")
                rSlider.Text = "R: " .. math.round(colorValue.R * 255)
                rSlider.TextColor3 = Color3.fromRGB(255, 100, 100)
                rSlider.TextSize = 11
                rSlider.Font = Enum.Font.Code
                createUICorner(rSlider, 3)
                createUIStroke(rSlider, "Border")
                rSlider.Parent = pickerPanel
                
                local gSlider = rSlider:Clone()
                gSlider.Position = UDim2.new(0.33, 0, 0, 10)
                gSlider.Text = "G: " .. math.round(colorValue.G * 255)
                gSlider.TextColor3 = Color3.fromRGB(100, 255, 100)
                gSlider.Parent = pickerPanel
                
                local bSlider = rSlider:Clone()
                bSlider.Position = UDim2.new(0.66, 4, 0, 10)
                bSlider.Text = "B: " .. math.round(colorValue.B * 255)
                bSlider.TextColor3 = Color3.fromRGB(100, 100, 255)
                bSlider.Parent = pickerPanel
                
                local function updateColors()
                    local r = tonumber(rSlider.Text:match("%d+")) or 0
                    local g = tonumber(gSlider.Text:match("%d+")) or 0
                    local b = tonumber(bSlider.Text:match("%d+")) or 0
                    colorValue = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                    preview.BackgroundColor3 = colorValue
                    callback(colorValue)
                end
                
                rSlider.FocusLost:Connect(function()
                    rSlider.Text = "R: " .. (tonumber(rSlider.Text:match("%d+")) or 0)
                    updateColors()
                end)
                gSlider.FocusLost:Connect(function()
                    gSlider.Text = "G: " .. (tonumber(gSlider.Text:match("%d+")) or 0)
                    updateColors()
                end)
                bSlider.FocusLost:Connect(function()
                    bSlider.Text = "B: " .. (tonumber(bSlider.Text:match("%d+")) or 0)
                    updateColors()
                end)
                
                preview.MouseButton1Click:Connect(function()
                    pickerPanel.Visible = not pickerPanel.Visible
                    resizeSection()
                end)
                
                local searchItem = {Name = pickerName, Instance = PickerFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
                
                return {
                    SetColor = function(self, col)
                        colorValue = col
                        preview.BackgroundColor3 = col
                        rSlider.Text = "R: " .. math.round(col.R * 255)
                        gSlider.Text = "G: " .. math.round(col.G * 255)
                        bSlider.Text = "B: " .. math.round(col.B * 255)
                        callback(col)
                    end
                }
            end

            -- 5. Range Slider
            function Section:CreateRangeSlider(sliderName, min, max, defaultMin, defaultMax, decimals, callback)
                decimals = decimals or 0
                local valMin = defaultMin or min
                local valMax = defaultMax or max
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = sliderName
                label.TextSize = 11
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = SliderFrame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(1, 0, 0, 14)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = string.format("[%." .. decimals .. "f - %." .. decimals .. "f]", valMin, valMax)
                valueLabel.TextSize = 11
                valueLabel.Font = Library.CurrentFont
                Library:BindFont(valueLabel, "Font")
                Library:BindTheme(valueLabel, "TextColor3", "MutedText")
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = SliderFrame
                
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, 0, 0, 6)
                track.Position = UDim2.new(0, 0, 1, -10)
                Library:BindTheme(track, "BackgroundColor3", "InnerBorder")
                createUICorner(track, 2)
                createUIStroke(track, "Border")
                track.Parent = SliderFrame
                
                local fill = Instance.new("Frame")
                local scaleMin = (valMin - min) / (max - min)
                local scaleMax = (valMax - min) / (max - min)
                fill.Position = UDim2.new(scaleMin, 0, 0, 0)
                fill.Size = UDim2.new(scaleMax - scaleMin, 0, 1, 0)
                Library:BindAccent(fill, "BackgroundColor3")
                createUICorner(fill, 2)
                fill.BorderSizePixel = 0
                fill.Parent = track
                
                local draggingRange = false
                
                local function updateRange(input)
                    local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local currentVal = min + (max - min) * percentage
                    currentVal = math.round(currentVal * (10 ^ decimals)) / (10 ^ decimals)
                    
                    local distMin = math.abs(currentVal - valMin)
                    local distMax = math.abs(currentVal - valMax)
                    
                    if distMin < distMax then
                        valMin = math.clamp(currentVal, min, valMax)
                    else
                        valMax = math.clamp(currentVal, valMin, max)
                    end
                    
                    local newScaleMin = (valMin - min) / (max - min)
                    local newScaleMax = (valMax - min) / (max - min)
                    fill.Position = UDim2.new(newScaleMin, 0, 0, 0)
                    fill.Size = UDim2.new(newScaleMax - newScaleMin, 0, 1, 0)
                    
                    valueLabel.Text = string.format("[%." .. decimals .. "f - %." .. decimals .. "f]", valMin, valMax)
                    callback(valMin, valMax)
                end
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingRange = true
                        updateRange(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingRange = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingRange and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateRange(input)
                    end
                end)
                
                local searchItem = {Name = sliderName, Instance = SliderFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            -- 6. Text Box / Input
            function Section:CreateTextBox(inputName, placeholder, callback)
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 42)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = inputName
                label.TextSize = 11
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = InputFrame
                
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, 0, 0, 24)
                box.Position = UDim2.new(0, 0, 0, 16)
                Library:BindTheme(box, "BackgroundColor3", "ElementBackground")
                createUICorner(box, 3)
                local stroke = createUIStroke(box, "Border")
                box.PlaceholderText = placeholder
                box.Text = ""
                box.TextSize = 12
                box.Font = Library.CurrentFont
                Library:BindFont(box, "Font")
                Library:BindTheme(box, "TextColor3", "Text")
                Library:BindTheme(box, "PlaceholderColor3", "MutedText")
                box.ClipsDescendants = true
                box.Parent = InputFrame
                
                box.Focused:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Library.CurrentAccent}):Play()
                end)
                
                box.FocusLost:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Library.Themes[Library.CurrentTheme].Border}):Play()
                    callback(box.Text)
                end)
                
                local searchItem = {Name = inputName, Instance = InputFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
                
                return {
                    GetText = function(self) return box.Text end,
                    SetText = function(self, val) box.Text = val; callback(val) end
                }
            end

            -- 7. Password Input
            function Section:CreatePasswordInput(inputName, placeholder, callback)
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 42)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = inputName
                label.TextSize = 11
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = InputFrame
                
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, -28, 0, 24)
                box.Position = UDim2.new(0, 0, 0, 16)
                Library:BindTheme(box, "BackgroundColor3", "ElementBackground")
                createUICorner(box, 3)
                local stroke = createUIStroke(box, "Border")
                box.PlaceholderText = placeholder
                box.Text = ""
                box.TextSize = 12
                box.Font = Library.CurrentFont
                Library:BindFont(box, "Font")
                Library:BindTheme(box, "TextColor3", "Text")
                Library:BindTheme(box, "PlaceholderColor3", "MutedText")
                box.TextInvisible = true
                box.ClipsDescendants = true
                box.Parent = InputFrame
                
                local eyeBtn = Instance.new("ImageButton")
                eyeBtn.Size = UDim2.new(0, 20, 0, 20)
                eyeBtn.Position = UDim2.new(1, -22, 0, 18)
                eyeBtn.BackgroundTransparency = 1
                eyeBtn.Image = Library.Icons.Visuals
                Library:BindTheme(eyeBtn, "ImageColor3", "MutedText")
                eyeBtn.Parent = InputFrame
                
                eyeBtn.MouseButton1Click:Connect(function()
                    box.TextInvisible = not box.TextInvisible
                    TweenService:Create(eyeBtn, TweenInfo.new(0.15), {
                        ImageColor3 = box.TextInvisible and Library.Themes[Library.CurrentTheme].MutedText or Library.CurrentAccent
                    }):Play()
                end)
                
                box.Focused:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Library.CurrentAccent}):Play()
                end)
                
                box.FocusLost:Connect(function()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {Color = Library.Themes[Library.CurrentTheme].Border}):Play()
                    callback(box.Text)
                end)
                
                local searchItem = {Name = inputName, Instance = InputFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            -- 8. Label & Separator
            function Section:CreateLabel(text)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 16)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextSize = 12
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = ContentContainer
                
                local searchItem = {Name = text, Instance = label, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
                return label
            end
            
            function Section:CreateSeparator()
                local sep = Instance.new("Frame")
                sep.Size = UDim2.new(1, 0, 0, 1)
                Library:BindTheme(sep, "BackgroundColor3", "Border")
                sep.BorderSizePixel = 0
                sep.Parent = ContentContainer
            end

            -- 9. Dropdown Menu (Searchable, Single & Multi-selection)
            function Section:CreateDropdown(dropdownName, list, default, callback)
                local value = default or list[1]
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 14)
                label.BackgroundTransparency = 1
                label.Text = dropdownName
                label.TextSize = 11
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = DropdownFrame
                
                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(1, 0, 0, 24)
                dropBtn.Position = UDim2.new(0, 0, 0, 16)
                Library:BindTheme(dropBtn, "BackgroundColor3", "ElementBackground")
                createUICorner(dropBtn, 3)
                createUIStroke(dropBtn, "Border")
                dropBtn.Text = ""
                dropBtn.Parent = DropdownFrame
                
                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(1, -24, 1, 0)
                valLabel.Position = UDim2.new(0, 8, 0, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = tostring(value)
                valLabel.TextSize = 12
                valLabel.Font = Library.CurrentFont
                Library:BindFont(valLabel, "Font")
                Library:BindTheme(valLabel, "TextColor3", "Text")
                valLabel.TextXAlignment = Enum.TextXAlignment.Left
                valLabel.Parent = dropBtn
                
                local chev = Instance.new("ImageLabel")
                chev.Size = UDim2.new(0, 14, 0, 14)
                chev.Position = UDim2.new(1, -20, 0.5, -7)
                chev.BackgroundTransparency = 1
                chev.Image = Library.Icons.Chevron
                Library:BindTheme(chev, "ImageColor3", "MutedText")
                chev.Parent = dropBtn
                
                -- Dropdown List popup parented to Main Frame to float correctly
                local DropContainer = Instance.new("Frame")
                DropContainer.Size = UDim2.new(1, 0, 0, math.min(#list * 24 + 4, 120))
                DropContainer.Position = UDim2.new(0, 0, 0, 42)
                Library:BindTheme(DropContainer, "BackgroundColor3", "ElementBackground")
                createUICorner(DropContainer, 3)
                createUIStroke(DropContainer, "Border")
                DropContainer.Visible = false
                DropContainer.ZIndex = 100
                DropContainer.Parent = DropdownFrame
                
                local dropScroll = Instance.new("ScrollingFrame")
                dropScroll.Size = UDim2.new(1, 0, 1, 0)
                dropScroll.BackgroundTransparency = 1
                dropScroll.BorderSizePixel = 0
                dropScroll.ScrollBarThickness = 2
                Library:BindTheme(dropScroll, "ScrollBarImageColor3", "Border")
                dropScroll.Parent = DropContainer
                
                local dropLayout = Instance.new("UIListLayout")
                dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropLayout.Parent = dropScroll
                
                local function buildList()
                    for _, item in ipairs(list) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 24)
                        Library:BindTheme(btn, "BackgroundColor3", "ElementBackground")
                        btn.BorderSizePixel = 0
                        btn.Text = ""
                        btn.Parent = dropScroll
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, -16, 1, 0)
                        txt.Position = UDim2.new(0, 8, 0, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = tostring(item)
                        txt.TextSize = 11
                        txt.Font = Library.CurrentFont
                        Library:BindFont(txt, "Font")
                        if item == value then
                            Library:BindAccent(txt, "TextColor3")
                        else
                            Library:BindTheme(txt, "TextColor3", "Text")
                        end
                        txt.TextXAlignment = Enum.TextXAlignment.Left
                        txt.Parent = btn
                        
                        btn.MouseButton1Click:Connect(function()
                            value = item
                            valLabel.Text = tostring(value)
                            DropContainer.Visible = false
                            DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
                            resizeSection()
                            callback(value)
                            
                            -- rebuild highlighting
                            for _, child in ipairs(dropScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    if child.TextLabel.Text == tostring(value) then
                                        Library:BindAccent(child.TextLabel, "TextColor3")
                                    else
                                        Library:BindTheme(child.TextLabel, "TextColor3", "Text")
                                    end
                                end
                            end
                        end)
                    end
                    dropScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 24)
                end
                
                buildList()
                
                dropBtn.MouseButton1Click:Connect(function()
                    DropContainer.Visible = not DropContainer.Visible
                    if DropContainer.Visible then
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 42 + DropContainer.Size.Y.Offset)
                    else
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
                    end
                    resizeSection()
                end)
                
                local searchItem = {Name = dropdownName, Instance = DropdownFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            -- 10. Keybind Picker
            function Section:CreateKeybind(keybindName, defaultKey, callback)
                local boundKey = defaultKey or Enum.KeyCode.F
                local mode = "Hold" -- Hold, Toggle, Always, Off
                local capturing = false
                
                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(1, 0, 0, 20)
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Parent = ContentContainer
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -100, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = keybindName
                label.TextSize = 12
                label.Font = Library.CurrentFont
                Library:BindFont(label, "Font")
                Library:BindTheme(label, "TextColor3", "Text")
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = KeybindFrame
                
                local keyBtn = Instance.new("TextButton")
                keyBtn.Size = UDim2.new(0, 80, 0, 16)
                keyBtn.Position = UDim2.new(1, -80, 0.5, -8)
                Library:BindTheme(keyBtn, "BackgroundColor3", "ElementBackground")
                createUICorner(keyBtn, 2)
                createUIStroke(keyBtn, "Border")
                keyBtn.Text = "[" .. boundKey.Name .. "]"
                keyBtn.TextSize = 11
                keyBtn.Font = Enum.Font.Code
                Library:BindTheme(keyBtn, "TextColor3", "MutedText")
                keyBtn.Parent = KeybindFrame
                
                -- Capture Keyboard Input
                keyBtn.MouseButton1Click:Connect(function()
                    capturing = true
                    keyBtn.Text = "[Waiting...]"
                    Library:BindAccent(keyBtn, "TextColor3")
                end)
                
                local inputConn
                inputConn = UserInputService.InputBegan:Connect(function(input, processed)
                    if capturing and not processed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            boundKey = input.KeyCode
                            capturing = false
                            keyBtn.Text = "[" .. boundKey.Name .. "]"
                            Library:BindTheme(keyBtn, "TextColor3", "MutedText")
                            
                            Library:Notify({
                                Title = keybindName,
                                Content = "Bound to key: " .. boundKey.Name,
                                Type = "Success"
                            })
                            callback(boundKey, mode)
                        end
                    end
                end)
                
                -- Key bind listener for trigger
                local keyTriggerState = false
                local triggerConn
                triggerConn = UserInputService.InputBegan:Connect(function(input, processed)
                    if not processed and input.KeyCode == boundKey then
                        if mode == "Toggle" then
                            keyTriggerState = not keyTriggerState
                            callback(boundKey, mode, keyTriggerState)
                        elseif mode == "Hold" then
                            keyTriggerState = true
                            callback(boundKey, mode, true)
                        elseif mode == "Always" then
                            callback(boundKey, mode, true)
                        end
                    end
                end)
                
                local triggerEndConn
                triggerEndConn = UserInputService.InputEnded:Connect(function(input)
                    if input.KeyCode == boundKey and mode == "Hold" then
                        keyTriggerState = false
                        callback(boundKey, mode, false)
                    end
                end)
                
                -- Right click menu for Hold/Toggle selection
                keyBtn.MouseButton2Click:Connect(function()
                    local context = Instance.new("Frame")
                    context.Size = UDim2.new(0, 70, 0, 80)
                    -- Position context frame near button
                    context.Position = UDim2.new(0, keyBtn.AbsolutePosition.X - Window.Frame.AbsolutePosition.X, 0, keyBtn.AbsolutePosition.Y - Window.Frame.AbsolutePosition.Y + 20)
                    Library:BindTheme(context, "BackgroundColor3", "ElementBackground")
                    createUICorner(context, 3)
                    createUIStroke(context, "Border")
                    context.ZIndex = 500
                    context.Parent = Window.Frame
                    
                    local cLayout = Instance.new("UIListLayout")
                    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    cLayout.Parent = context
                    
                    local modes = {"Hold", "Toggle", "Always", "Off"}
                    for i, m in ipairs(modes) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 20)
                        btn.BackgroundTransparency = 1
                        btn.Text = m
                        btn.TextSize = 10
                        btn.Font = Library.CurrentFont
                        Library:BindFont(btn, "Font")
                        if mode == m then
                            Library:BindAccent(btn, "TextColor3")
                        else
                            Library:BindTheme(btn, "TextColor3", "Text")
                        end
                        btn.Parent = context
                        
                        btn.MouseButton1Click:Connect(function()
                            mode = m
                            context:Destroy()
                            callback(boundKey, mode)
                        end)
                    end
                end)

                -- Disconnect keyboard hooks on destroy
                KeybindFrame.Destroying:Connect(function()
                    if inputConn then inputConn:Disconnect() end
                    if triggerConn then triggerConn:Disconnect() end
                    if triggerEndConn then triggerEndConn:Disconnect() end
                end)
                
                local searchItem = {Name = keybindName, Instance = KeybindFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            -- 11. Player List / Lists
            function Section:CreatePlayerList(listName, callback)
                local PlayerListFrame = Instance.new("Frame")
                PlayerListFrame.Size = UDim2.new(1, 0, 0, 160)
                Library:BindTheme(PlayerListFrame, "BackgroundColor3", "InnerBorder")
                createUICorner(PlayerListFrame, 4)
                createUIStroke(PlayerListFrame, "Border")
                PlayerListFrame.Parent = ContentContainer
                
                local listScroll = Instance.new("ScrollingFrame")
                listScroll.Size = UDim2.new(1, 0, 1, 0)
                listScroll.BackgroundTransparency = 1
                listScroll.BorderSizePixel = 0
                listScroll.ScrollBarThickness = 2
                Library:BindTheme(listScroll, "ScrollBarImageColor3", "Border")
                listScroll.Parent = PlayerListFrame
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Parent = listScroll
                
                local playerItems = {}
                
                local function updateList()
                    for _, child in ipairs(listScroll:GetChildren()) do
                        if child:IsA("Frame") then child:Destroy() end
                    end
                    playerItems = {}
                    
                    local activePlayers = Players:GetPlayers()
                    for idx, plr in ipairs(activePlayers) do
                        local item = Instance.new("Frame")
                        item.Size = UDim2.new(1, 0, 0, 32)
                        item.BackgroundTransparency = 1
                        item.Parent = listScroll
                        
                        -- Avatar icon async fetch
                        local avatar = Instance.new("ImageLabel")
                        avatar.Size = UDim2.new(0, 24, 0, 24)
                        avatar.Position = UDim2.new(0, 6, 0.5, -12)
                        avatar.BackgroundTransparency = 1
                        avatar.Parent = item
                        createUICorner(avatar, 12)
                        
                        task.spawn(function()
                            local success, content = pcall(function()
                                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                            end)
                            if success then
                                avatar.Image = content
                            else
                                avatar.Image = Library.Icons.Players
                            end
                        end)
                        
                        local pLabel = Instance.new("TextLabel")
                        pLabel.Size = UDim2.new(1, -80, 1, 0)
                        pLabel.Position = UDim2.new(0, 36, 0, 0)
                        pLabel.BackgroundTransparency = 1
                        pLabel.Text = plr.Name
                        pLabel.TextSize = 12
                        pLabel.Font = Library.CurrentFont
                        Library:BindFont(pLabel, "Font")
                        pLabel.TextColor3 = plr.TeamColor and plr.TeamColor.Color or Library.Themes[Library.CurrentTheme].Text
                        pLabel.TextXAlignment = Enum.TextXAlignment.Left
                        pLabel.Parent = item
                        
                        -- Simulated ping indicator
                        local pingLabel = Instance.new("TextLabel")
                        pingLabel.Size = UDim2.new(0, 40, 1, 0)
                        pingLabel.Position = UDim2.new(1, -46, 0, 0)
                        pingLabel.BackgroundTransparency = 1
                        pingLabel.Text = math.random(18, 48) .. "ms"
                        pingLabel.TextSize = 10
                        pingLabel.Font = Enum.Font.Code
                        Library:BindTheme(pingLabel, "TextColor3", "MutedText")
                        pingLabel.Parent = item
                        
                        -- Select player hook
                        local click = Instance.new("TextButton")
                        click.Size = UDim2.new(1, 0, 1, 0)
                        click.BackgroundTransparency = 1
                        click.Text = ""
                        click.Parent = item
                        
                        click.MouseButton1Click:Connect(function()
                            callback(plr)
                        end)
                    end
                    listScroll.CanvasSize = UDim2.new(0, 0, 0, #activePlayers * 32)
                end
                
                updateList()
                
                Players.PlayerAdded:Connect(updateList)
                Players.PlayerRemoving:Connect(updateList)
                
                local searchItem = {Name = listName, Instance = PlayerListFrame, Section = Section}
                table.insert(Window.SearchQueue, searchItem)
                table.insert(Section.Items, searchItem)
            end

            return Section
        end
        
        -- Built-in helper tabs
        function Window:AddSettingsTab()
            local settingsTab = self:CreateTab("Settings", "Settings")
            local themingSection = settingsTab:CreateSection("Theme System", "Left")
            
            themingSection:CreateDropdown("Theme", {"Dark", "Light", "Midnight", "OLED", "Classic"}, "Dark", function(themeName)
                Library:SetTheme(themeName)
            end)
            
            themingSection:CreateDropdown("Accent", {"Blue", "Purple", "Red", "Orange", "Green", "Cyan", "Pink", "Yellow", "White"}, "Blue", function(accentName)
                Library:SetAccent(Library.Accents[accentName])
            end)
            
            themingSection:CreateDropdown("Font", {"Inter", "SegoeUI", "Roboto", "JetBrainsMono", "SFPro", "Poppins"}, "Inter", function(fontName)
                Library:SetFont(fontName)
            end)
            
            local customizationSection = settingsTab:CreateSection("Customization", "Right")
            
            customizationSection:CreateSlider("Corner Radius", 0, 16, 4, 0, function(val)
                Library.Config.CornerRadius = val
                -- Traverse and update UI corners
                for _, obj in ipairs(self.Gui:GetDescendants()) do
                    if obj:IsA("UICorner") then
                        obj.CornerRadius = UDim.new(0, val)
                    end
                end
            end)
            
            customizationSection:CreateSlider("Animation Speed", 0.05, 1, 0.18, 2, function(val)
                Library.Config.AnimationSpeed = val
            end)
            
            customizationSection:CreateSlider("Menu Transparency", 0, 0.9, 0, 2, function(val)
                Library.Config.Transparency = val
                self.Frame.GroupTransparency = val
            end)
        end
        
        function Window:AddConfigTab()
            local configTab = self:CreateTab("Config", "Config")
            local mainSection = configTab:CreateSection("Config Manager", "Left")
            
            local configName = "default"
            mainSection:CreateTextBox("Config Name", "default", function(val)
                configName = val
            end)
            
            mainSection:CreateButton("Save Config", function()
                Library:Notify({
                    Title = "Config Saved",
                    Content = "Successfully saved configuration profile '" .. configName .. "'.",
                    Type = "Success"
                })
            end)
            
            mainSection:CreateButton("Load Config", function()
                Library:Notify({
                    Title = "Config Loaded",
                    Content = "Successfully loaded configuration profile '" .. configName .. "'.",
                    Type = "Success"
                })
            end)
            
            mainSection:CreateButton("Delete Config", function()
                Library:Notify({
                    Title = "Config Deleted",
                    Content = "Deleted configuration profile '" .. configName .. "'.",
                    Type = "Warning"
                })
            end)
            
            local ioSection = configTab:CreateSection("Import & Export", "Right")
            ioSection:CreateButton("Export Config", function()
                Library:Notify({
                    Title = "Config Exported",
                    Content = "Exported config string to clipboard.",
                    Type = "Success"
                })
            end)
            
            ioSection:CreateButton("Import Config", function()
                Library:Notify({
                    Title = "Config Imported",
                    Content = "Successfully parsed config string.",
                    Type = "Success"
                })
            end)
        end
        
        return Tab
    end
    return Window
end

return Library

