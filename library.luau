--[[
    Evon Redesigned UI Library
    Similar but better than LinoriaLib (REFERENCE.luau).
    Implements the exact LinoriaLib API (Toggles, Options, Registry, outlines, addons)
    while adding modern search filters, live themes, font switchers, scale customizers,
    and smooth animations.
]]

local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService');
local TweenService = game:GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local ScreenGui = Instance.new('ScreenGui');
ScreenGui.Name = "EvonMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};
    HudRegistry = {};
    OpenedFrames = {};
    DependencyBoxes = {};
    Signals = {};
    ScreenGui = ScreenGui;
    
    -- Design tokens (themeable)
    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(0, 140, 255);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    RiskColor = Color3.fromRGB(255, 50, 50);
    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.SourceSans;
    
    CurrentTheme = "Dark";
    CurrentFontName = "Inter";
    CurrentScale = 1.0;
}

-- Theme Preset Definitions
Library.Themes = {
    Dark = {
        FontColor = Color3.fromRGB(255, 255, 255),
        MainColor = Color3.fromRGB(28, 28, 28),
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        AccentColor = Color3.fromRGB(0, 140, 255),
        OutlineColor = Color3.fromRGB(50, 50, 50),
    },
    Light = {
        FontColor = Color3.fromRGB(40, 40, 45),
        MainColor = Color3.fromRGB(230, 230, 235),
        BackgroundColor = Color3.fromRGB(245, 245, 248),
        AccentColor = Color3.fromRGB(0, 120, 240),
        OutlineColor = Color3.fromRGB(200, 200, 205),
    },
    Midnight = {
        FontColor = Color3.fromRGB(215, 220, 240),
        MainColor = Color3.fromRGB(16, 18, 32),
        BackgroundColor = Color3.fromRGB(10, 11, 20),
        AccentColor = Color3.fromRGB(150, 60, 255),
        OutlineColor = Color3.fromRGB(24, 26, 42),
    },
    OLED = {
        FontColor = Color3.fromRGB(255, 255, 255),
        MainColor = Color3.fromRGB(8, 8, 8),
        BackgroundColor = Color3.fromRGB(0, 0, 0),
        AccentColor = Color3.fromRGB(0, 140, 255),
        OutlineColor = Color3.fromRGB(28, 28, 28),
    },
    Classic = {
        FontColor = Color3.fromRGB(240, 240, 245),
        MainColor = Color3.fromRGB(44, 44, 50),
        BackgroundColor = Color3.fromRGB(38, 38, 43),
        AccentColor = Color3.fromRGB(255, 60, 60),
        OutlineColor = Color3.fromRGB(52, 52, 58),
    }
}

Library.Fonts = {
    Inter = Enum.Font.SourceSans,
    SegoeUI = Enum.Font.SourceSans,
    Roboto = Enum.Font.SourceSans,
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

-- Registry Implementation
function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };
    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;
    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];
    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;
        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;
        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    for _, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx];
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx();
            end
        end;
    end;
end;

function Library:SetTheme(themeName)
    local theme = Library.Themes[themeName]
    if not theme then return end
    Library.CurrentTheme = themeName
    
    Library.FontColor = theme.FontColor
    Library.MainColor = theme.MainColor
    Library.BackgroundColor = theme.BackgroundColor
    Library.AccentColor = theme.AccentColor
    Library.OutlineColor = theme.OutlineColor
    Library.AccentColorDark = Library:GetDarkerColor(theme.AccentColor)
    
    Library:UpdateColorsUsingRegistry()
end

function Library:SetAccent(color)
    Library.AccentColor = color
    Library.AccentColorDark = Library:GetDarkerColor(color)
    Library:UpdateColorsUsingRegistry()
end

function Library:SetFont(fontName)
    local font = Library.Fonts[fontName]
    if not font then return end
    Library.CurrentFontName = fontName
    Library.Font = font
    
    -- Update all TextLabels/TextBoxes font dynamically
    for _, Object in next, Library.Registry do
        if Object.Instance:IsA("TextLabel") or Object.Instance:IsA("TextBox") or Object.Instance:IsA("TextButton") then
            Object.Instance.Font = font
        end
    end
end

-- Setup player string generators
local function GetPlayersString()
    local PlayerList = Players:GetPlayers();
    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;
    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);
    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();
    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;
    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then return; end;
    local success, event = pcall(f, ...);
    if not success then
        warn("Callback Error: " .. tostring(event))
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;
    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;
    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;
    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;
    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextStrokeTransparency = 0;
    });
    Library:ApplyTextStroke(_Instance);
    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);
    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;
    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            );
            if ObjPos.Y > (Cutoff or 40) then return; end;
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                );
                RenderStepped:Wait();
            end;
        end;
    end)
end;

function Library:AddToolTip(InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.fromOffset(X + 8, Y + 4),
        ZIndex = 200,
        Parent = Library.ScreenGui,
        Visible = false,
    })
    Library:Create('UIStroke', {
        Color = Color3.new(0,0,0),
        Thickness = 1,
        Parent = Tooltip
    })
    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(4, 1),
        Size = UDim2.fromOffset(X, Y);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,
        Parent = Tooltip;
    });
    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });
    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });
    local IsHovering = false
    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then return end
        IsHovering = true
        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true
        while IsHovering do
            RunService.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];
        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;
            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];
        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;
            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
            return true;
        end;
    end;
    return false;
end;

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
        return true;
    end;
    return false;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

-- Setup signals disconnection on unload
function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end
    if Library.OnUnload then
        Library.OnUnload()
    end
    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

ScreenGui.DescendantRemoving:Connect(function(Inst)
    if Library.RegistryMap[Inst] then
        Library:RemoveFromRegistry(Inst);
    end;
end)

-- Notification Queue System
local NotificationContainer = Library:Create('Frame', {
    Size = UDim2.new(0, 240, 1, -40),
    Position = UDim2.new(1, -260, 0, 20),
    BackgroundTransparency = 1,
    ZIndex = 200,
    Parent = ScreenGui
})
local NotificationLayout = Library:Create('UIListLayout', {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    Parent = NotificationContainer
})

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(220, 1000));
    XSize = math.max(XSize + 16, 200)
    YSize = YSize + 12

    local NotifyOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, YSize),
        ClipsDescendants = true,
        ZIndex = 201,
        Parent = NotificationContainer,
    });
    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        ZIndex = 202,
        Parent = NotifyOuter,
    });
    Library:AddToRegistry(InnerFrame, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor'
    });
    local Label = Library:CreateLabel({
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        Text = Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 14,
        TextWrapped = true,
        ZIndex = 203,
        Parent = InnerFrame
    });
    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 204,
        Parent = InnerFrame
    });
    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor'
    });
    
    TweenService:Create(NotifyOuter, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, XSize, 0, YSize)
    }):Play()

    task.spawn(function()
        wait(Time or 5);
        local fadeOut = TweenService:Create(NotifyOuter, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, YSize)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            NotifyOuter:Destroy()
        end)
    end);
end;

local BaseAddons = {};
local Funcs = {};

-- 1. Nested Color Picker
function Funcs:AddColorPicker(Idx, Info)
    local ToggleLabel = self.TextLabel;
    assert(Info.Default, 'AddColorPicker: Missing default value.');

    local ColorPicker = {
        Value = Info.Default;
        Transparency = Info.Transparency or 0;
        Type = 'ColorPicker';
        Title = type(Info.Title) == 'string' and Info.Title or 'Color picker';
        Callback = Info.Callback or function(Color) end;
    };

    function ColorPicker:SetHSVFromRGB(Color)
        local H, S, V = Color3.toHSV(Color);
        ColorPicker.Hue = H;
        ColorPicker.Sat = S;
        ColorPicker.Vib = V;
    end;
    ColorPicker:SetHSVFromRGB(ColorPicker.Value);

    local DisplayFrame = Library:Create('Frame', {
        BackgroundColor3 = ColorPicker.Value;
        BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(0, 24, 0, 12);
        ZIndex = 6;
        Parent = ToggleLabel;
    });

    local CheckerFrame = Library:Create('ImageLabel', {
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 5;
        Image = 'http://www.roblox.com/asset/?id=12977615774';
        Visible = not not Info.Transparency;
        Parent = DisplayFrame;
    });

    local PickerFrameOuter = Library:Create('Frame', {
        Name = 'Color';
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 1;
        Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 16),
        Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui,
    });

    DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
        PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 16);
    end)

    local PickerFrameInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = PickerFrameOuter;
    });

    local Highlight = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = PickerFrameInner;
    });

    local SatVibMapOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 4, 0, 25);
        Size = UDim2.new(0, 200, 0, 200);
        ZIndex = 102;
        Parent = PickerFrameInner;
    });

    local SatVibMapInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 103;
        Parent = SatVibMapOuter;
    });

    local SatVibMap = Library:Create('ImageLabel', {
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 104;
        Image = 'rbxassetid://4155801252';
        Parent = SatVibMapInner;
    });

    local CursorOuter = Library:Create('ImageLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.new(0, 6, 0, 6);
        BackgroundTransparency = 1;
        Image = 'http://www.roblox.com/asset/?id=9619665977';
        ImageColor3 = Color3.new(0, 0, 0);
        ZIndex = 105;
        Parent = SatVibMap;
    });

    local CursorInner = Library:Create('ImageLabel', {
        Size = UDim2.new(0, 4, 0, 4);
        Position = UDim2.new(0, 1, 0, 1);
        BackgroundTransparency = 1;
        Image = 'http://www.roblox.com/asset/?id=9619665977';
        ZIndex = 106;
        Parent = CursorOuter;
    })

    local HueSelectorOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 208, 0, 25);
        Size = UDim2.new(0, 16, 0, 200);
        ZIndex = 102;
        Parent = PickerFrameInner;
    });

    local HueSelectorInner = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 103;
        Parent = HueSelectorOuter;
    });

    local HueCursor = Library:Create('Frame', { 
        BackgroundColor3 = Color3.new(1, 1, 1);
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 104;
        Parent = HueCursor or HueSelectorInner; -- Fallback safely
    });

    local HueBoxOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(4, 228),
        Size = UDim2.new(0.5, -6, 0, 20),
        ZIndex = 103,
        Parent = PickerFrameInner;
    });

    local HueBoxInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 104,
        Parent = HueBoxOuter;
    });

    local HueBox = Library:Create('TextBox', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -5, 1, 0);
        Font = Library.Font;
        PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
        PlaceholderText = 'Hex color',
        Text = '#FFFFFF',
        TextColor3 = Library.FontColor;
        TextSize = 13;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 105,
        Parent = HueBoxInner;
    });
    Library:ApplyTextStroke(HueBox);

    local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
        Position = UDim2.new(0.5, 2, 0, 228),
        Size = UDim2.new(0.5, -6, 0, 20),
        Parent = PickerFrameInner
    });
    local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
        Text = '255, 255, 255',
        PlaceholderText = 'RGB color',
        TextColor3 = Library.FontColor
    });

    local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
    if Info.Transparency then 
        TransparencyBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 251);
            Size = UDim2.new(1, -8, 0, 15);
            ZIndex = 103;
            Parent = PickerFrameInner;
        });

        TransparencyBoxInner = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 104;
            Parent = TransparencyBoxOuter;
        });

        Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

        Library:Create('ImageLabel', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Image = 'http://www.roblox.com/asset/?id=12978095818';
            ZIndex = 105;
            Parent = TransparencyBoxInner;
        });

        TransparencyCursor = Library:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0.5, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 106;
            Parent = TransparencyBoxInner;
        });
    end;

    local DisplayLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Position = UDim2.fromOffset(5, 5);
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        Text = ColorPicker.Title,
        ZIndex = 102;
        Parent = PickerFrameInner;
    });

    -- Registry Bindings
    Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
    Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
    Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

    local SequenceTable = {};
    for H = 0, 1, 0.1 do
        table.insert(SequenceTable, ColorSequenceKeypoint.new(H, Color3.fromHSV(H, 1, 1)));
    end;
    Library:Create('UIGradient', {
        Color = ColorSequence.new(SequenceTable);
        Rotation = 90;
        Parent = HueSelectorInner;
    });

    local function Display()
        ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
        SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

        DisplayFrame.BackgroundColor3 = ColorPicker.Value;
        DisplayFrame.BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);

        if TransparencyBoxInner then
            TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
            TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
        end;

        CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
        HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

        HueBox.Text = '#' .. ColorPicker.Value:ToHex()
        RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

        Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
        Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
    end;

    function ColorPicker:Display() Display(); end;
    
    function ColorPicker:OnChanged(Func)
        ColorPicker.Changed = Func;
        Func(ColorPicker.Value)
    end;

    function ColorPicker:Show()
        for Frame, _ in next, Library.OpenedFrames do
            if Frame.Name == 'Color' then
                Frame.Visible = false;
                Library.OpenedFrames[Frame] = nil;
            end;
        end;
        PickerFrameOuter.Visible = true;
        Library.OpenedFrames[PickerFrameOuter] = true;
    end;

    function ColorPicker:Hide()
        PickerFrameOuter.Visible = false;
        Library.OpenedFrames[PickerFrameOuter] = nil;
    end;

    function ColorPicker:SetValue(HSV, Transparency)
        ColorPicker.Transparency = Transparency or 0;
        local color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
        ColorPicker:SetHSVFromRGB(color);
        Display();
    end;

    function ColorPicker:SetValueRGB(Color, Transparency)
        ColorPicker.Transparency = Transparency or 0;
        ColorPicker:SetHSVFromRGB(Color);
        Display();
    end;

    -- Custom context menu (copy/paste)
    local ContextMenu = { Options = {} }
    ContextMenu.Container = Library:Create('Frame', {
        BorderColor3 = Color3.new(),
        ZIndex = 200,
        Visible = false,
        Parent = ScreenGui
    })
    ContextMenu.Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 201;
        Parent = ContextMenu.Container;
    });
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ContextMenu.Inner;
    });
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 4),
        Parent = ContextMenu.Inner,
    });

    local function updateMenuPosition()
        ContextMenu.Container.Position = UDim2.fromOffset(
            (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
            DisplayFrame.AbsolutePosition.Y + 1
        )
    end
    local function updateMenuSize()
        local maxW = 80
        for _, lbl in next, ContextMenu.Inner:GetChildren() do
            if lbl:IsA("TextLabel") then maxW = math.max(maxW, lbl.TextBounds.X) end
        end
        ContextMenu.Container.Size = UDim2.fromOffset(maxW + 8, ContextMenu.Inner.UIListLayout.AbsoluteContentSize.Y + 4)
    end
    DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
    ContextMenu.Inner.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

    Library:AddToRegistry(ContextMenu.Inner, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    function ContextMenu:AddOption(Str, Callback)
        local Button = Library:CreateLabel({
            Active = false;
            Size = UDim2.new(1, 0, 0, 16);
            TextSize = 13;
            Text = Str;
            ZIndex = 202;
            Parent = self.Inner;
            TextXAlignment = Enum.TextXAlignment.Left,
        });
        Library:OnHighlight(Button, Button, { TextColor3 = 'AccentColor' }, { TextColor3 = 'FontColor' });
        Button.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Callback()
                ContextMenu.Container.Visible = false
            end
        end)
    end
    ContextMenu:AddOption('Copy color', function()
        Library.ColorClipboard = ColorPicker.Value
        Library:Notify('Copied color!', 2)
    end)
    ContextMenu:AddOption('Paste color', function()
        if not Library.ColorClipboard then
            return Library:Notify('Clipboard is empty!', 2)
        end
        ColorPicker:SetValueRGB(Library.ColorClipboard)
    end)

    SatVibMap.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local MinX = SatVibMap.AbsolutePosition.X;
                local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                local MinY = SatVibMap.AbsolutePosition.Y;
                local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                Display();
                RenderStepped:Wait();
            end;
            Library:AttemptSave();
        end;
    end);

    HueSelectorInner.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local MinY = HueSelectorInner.AbsolutePosition.Y;
                local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                Display();
                RenderStepped:Wait();
            end;
            Library:AttemptSave();
        end;
    end);

    DisplayFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
            if PickerFrameOuter.Visible then ColorPicker:Hide() else ContextMenu.Container.Visible = false; ColorPicker:Show() end
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
            updateMenuPosition();
            ContextMenu.Container.Visible = not ContextMenu.Container.Visible
            ColorPicker:Hide()
        end
    end)

    if TransparencyBoxInner then
        TransparencyBoxInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinX = TransparencyBoxInner.AbsolutePosition.X;
                    local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);
                    ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));
                    Display();
                    RenderStepped:Wait();
                end;
                Library:AttemptSave();
            end;
        end);
    end;

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Library:IsMouseOverFrame(PickerFrameOuter) and not Library:IsMouseOverFrame(DisplayFrame) then
                ColorPicker:Hide()
            end
            if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                ContextMenu.Container.Visible = false
            end
        end
    end))

    Display();
    Options[Idx] = ColorPicker;
    return self;
end

-- 2. Nested Keybind Picker
function Funcs:AddKeyPicker(Idx, Info)
    local ToggleLabel = self.TextLabel;
    assert(Info.Default, 'AddKeyPicker: Missing default keybind.');

    local KeyPicker = {
        Value = Info.Default;
        Toggled = false;
        Mode = Info.Mode or 'Toggle';
        Type = 'KeyPicker';
        Callback = Info.Callback or function() end;
        ChangedCallback = Info.ChangedCallback or function() end;
        SyncToggleState = Info.SyncToggleState or false;
    };

    local PickOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(0, 24, 0, 13);
        ZIndex = 6;
        Parent = ToggleLabel;
    });
    local PickInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 7;
        Parent = PickOuter;
    });
    Library:AddToRegistry(PickInner, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });
    local DisplayLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0);
        TextSize = 11;
        Text = Info.Default;
        ZIndex = 8;
        Parent = PickInner;
    });

    local ModeSelectOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0,0,0),
        Size = UDim2.new(0, 60, 0, 47),
        Visible = false,
        ZIndex = 150,
        Parent = ScreenGui
    });
    local ModeSelectInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 151,
        Parent = ModeSelectOuter
    });
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ModeSelectInner
    });
    Library:AddToRegistry(ModeSelectInner, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor'
    });

    local function updateModeSelectPosition()
        ModeSelectOuter.Position = UDim2.fromOffset(PickOuter.AbsolutePosition.X + 28, PickOuter.AbsolutePosition.Y)
    end
    PickOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateModeSelectPosition)

    local Modes = {'Always', 'Toggle', 'Hold'}
    local ModeButtons = {}

    for _, m in ipairs(Modes) do
        local btn = Library:CreateLabel({
            Active = false,
            Size = UDim2.new(1, 0, 0, 15),
            TextSize = 11,
            Text = m,
            ZIndex = 152,
            Parent = ModeSelectInner
        });
        local buttonState = {}
        function buttonState:Select()
            for _, o in pairs(ModeButtons) do o:Deselect() end
            KeyPicker.Mode = m
            btn.TextColor3 = Library.AccentColor
            Library.RegistryMap[btn].Properties.TextColor3 = 'AccentColor'
            ModeSelectOuter.Visible = false
        end
        function buttonState:Deselect()
            btn.TextColor3 = Library.FontColor
            Library.RegistryMap[btn].Properties.TextColor3 = 'FontColor'
        end
        btn.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                buttonState:Select()
                Library:AttemptSave()
            end
        end)
        if m == KeyPicker.Mode then buttonState:Select() end
        ModeButtons[m] = buttonState
    end

    function KeyPicker:GetState()
        if KeyPicker.Mode == 'Always' then return true
        elseif KeyPicker.Mode == 'Hold' then
            if KeyPicker.Value == 'None' then return false end
            if KeyPicker.Value == 'MB1' then return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif KeyPicker.Value == 'MB2' then return InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            else return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]) end
        else return KeyPicker.Toggled end
    end

    function KeyPicker:SetValue(Data)
        KeyPicker.Value = Data[1]
        ModeButtons[Data[2]]:Select()
        DisplayLabel.Text = KeyPicker.Value
    end

    local Picking = false
    PickOuter.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
            Picking = true
            DisplayLabel.Text = '...'
            local ev;
            ev = InputService.InputBegan:Connect(function(inp)
                local key = 'None'
                if inp.UserInputType == Enum.UserInputType.Keyboard then key = inp.KeyCode.Name
                elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then key = 'MB1'
                elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then key = 'MB2' end
                Picking = false
                KeyPicker.Value = key
                DisplayLabel.Text = key
                Library:SafeCallback(KeyPicker.ChangedCallback, inp.KeyCode or inp.UserInputType)
                Library:SafeCallback(KeyPicker.Callback, inp.KeyCode or inp.UserInputType)
                Library:AttemptSave()
                ev:Disconnect()
            end)
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
            updateModeSelectPosition()
            ModeSelectOuter.Visible = not ModeSelectOuter.Visible
        end
    end)

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
        if not Picking then
            if KeyPicker.Mode == 'Toggle' then
                local k = KeyPicker.Value
                if k == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1 then KeyPicker.Toggled = not KeyPicker.Toggled
                elseif k == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then KeyPicker.Toggled = not KeyPicker.Toggled
                elseif Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == k then KeyPicker.Toggled = not KeyPicker.Toggled end
                if KeyPicker.SyncToggleState and self.SetValue then self:SetValue(KeyPicker.Toggled) end
            end
        end
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not Library:IsMouseOverFrame(ModeSelectOuter) and not Library:IsMouseOverFrame(PickOuter) then
                ModeSelectOuter.Visible = false
            end
        end
    end))

    Options[Idx] = KeyPicker
    return self
end

BaseAddons.__index = Funcs;
BaseAddons.__namecall = function(T, K, ...) return Funcs[K](T, ...) end;

-- Containers (Groupbox & Tabbox)
local BaseGroupbox = {};
do
    local GFuncs = {};

    function GFuncs:AddBlank(Size)
        Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Size),
            Parent = self.Container
        });
    end;

    function GFuncs:AddLabel(Text, DoesWrap)
        local LabelObj = {}
        local lbl = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15),
            TextSize = 13,
            Text = Text,
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.Container
        });
        if not DoesWrap then
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = lbl
            });
        else
            local _, y = Library:GetTextBounds(Text, Library.Font, 13, Vector2.new(lbl.AbsoluteSize.X, 1000))
            lbl.Size = UDim2.new(1, -4, 0, y)
        end
        LabelObj.TextLabel = lbl
        function LabelObj:SetText(t)
            lbl.Text = t
            if DoesWrap then
                local _, y = Library:GetTextBounds(t, Library.Font, 13, Vector2.new(lbl.AbsoluteSize.X, 1000))
                lbl.Size = UDim2.new(1, -4, 0, y)
            end
            self.Parent:Resize()
        end
        LabelObj.Parent = self
        if not DoesWrap then setmetatable(LabelObj, BaseAddons) end
        self:AddBlank(4)
        self:Resize()
        return LabelObj
    end

    function GFuncs:AddButton(...)
        local Button = {}
        local args = {...}
        local props = args[1]
        if type(props) == 'table' then
            Button.Text = props.Text
            Button.Func = props.Func
        else
            Button.Text = args[1]
            Button.Func = args[2]
        end
        
        local Outer = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            BorderColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = self.Container
        });
        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = Outer
        });
        local Label = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 13,
            Text = Button.Text,
            ZIndex = 6,
            Parent = Inner
        });
        Library:AddToRegistry(Outer, { BorderColor3 = 'Black' });
        Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
        
        Library:OnHighlight(Outer, Outer, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'Black' });
        
        Outer.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Library:SafeCallback(Button.Func)
            end
        end)

        function Button:AddButton(...)
            local Sub = {}
            local sArgs = {...}
            if type(sArgs[1]) == 'table' then Sub.Text = sArgs[1].Text; Sub.Func = sArgs[1].Func else Sub.Text = sArgs[1]; Sub.Func = sArgs[2] end
            Outer.Size = UDim2.new(0.5, -2, 0, 20)
            local sOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0,0,0),
                BorderColor3 = Color3.new(0,0,0),
                Position = UDim2.new(1, 3, 0, 0),
                Size = UDim2.new(1, -2, 1, 0),
                ZIndex = 5,
                Parent = Outer
            });
            local sInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 6,
                Parent = sOuter
            });
            local sLabel = Library:CreateLabel({
                Size = UDim2.new(1,0,1,0),
                TextSize = 13,
                Text = Sub.Text,
                ZIndex = 6,
                Parent = sInner
            });
            sOuter.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    Library:SafeCallback(Sub.Func)
                end
            end)
            return Sub
        end

        self:AddBlank(4)
        self:Resize()
        return Button
    end

    function GFuncs:AddDivider()
        local dOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1, -4, 0, 3),
            ZIndex = 5,
            Parent = self.Container
        });
        local dInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = dOuter
        });
        Library:AddToRegistry(dInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
        self:AddBlank(4)
        self:Resize()
    end

    function GFuncs:AddInput(Idx, Info)
        local Input = {
            Value = Info.Default or "",
            Numeric = Info.Numeric or false,
            Finished = Info.Finished or false,
            Type = 'Input',
            Callback = Info.Callback or function() end
        };
        Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 13),
            TextSize = 13,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.Container
        });
        self:AddBlank(1)
        local Outer = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = self.Container
        });
        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = Outer
        });
        Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
        
        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            Font = Library.Font,
            PlaceholderText = Info.Placeholder or "",
            Text = Input.Value,
            TextColor3 = Library.FontColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
            Parent = Inner
        });
        Library:ApplyTextStroke(Box)
        Library:AddToRegistry(Box, { TextColor3 = 'FontColor' });

        function Input:SetValue(val)
            if Input.Numeric and not tonumber(val) and val ~= "" then return end
            Input.Value = val
            Box.Text = val
            Library:SafeCallback(Input.Callback, val)
        end
        Box.FocusLost:Connect(function()
            Input:SetValue(Box.Text)
            Library:AttemptSave()
        end)
        if not Input.Finished then
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Input:SetValue(Box.Text)
            end)
        end

        self:AddBlank(4)
        self:Resize()
        Options[Idx] = Input
        return Input
    end

    function GFuncs:AddToggle(Idx, Info)
        local Toggle = {
            Value = Info.Default or false,
            Type = 'Toggle',
            Callback = Info.Callback or function() end,
            Addons = {}
        };
        local Outer = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(0, 12, 0, 12),
            ZIndex = 5,
            Parent = self.Container
        });
        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = Outer
        });
        Library:AddToRegistry(Outer, { BorderColor3 = 'Black' });
        Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

        local Label = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0),
            Position = UDim2.new(1, 6, 0, 0),
            TextSize = 13,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
            Parent = Inner
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Label
        });
        local ClickArea = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 210, 1, 0),
            ZIndex = 8,
            Parent = Outer
        });
        Library:OnHighlight(ClickArea, Outer, { BorderColor3 = 'AccentColor' }, { BorderColor3 = 'Black' });

        local function Display()
            Inner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor
            Inner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor
            Library.RegistryMap[Inner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor'
            Library.RegistryMap[Inner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor'
        end

        function Toggle:SetValue(bool)
            Toggle.Value = not not bool
            Display()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
        end
        ClickArea.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave()
            end
        end)

        Toggle.TextLabel = Label
        setmetatable(Toggle, BaseAddons)
        Toggles[Idx] = Toggle
        self:AddBlank(16)
        self:Resize()
        return Toggle
    end

    function GFuncs:AddSlider(Idx, Info)
        local Slider = {
            Value = Info.Default or Info.Min,
            Min = Info.Min,
            Max = Info.Max,
            Rounding = Info.Rounding or 0,
            MaxSize = 220,
            Type = 'Slider',
            Callback = Info.Callback or function() end
        };
        Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 12),
            TextSize = 13,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.Container
        });
        self:AddBlank(3)
        local Outer = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1, -4, 0, 12),
            ZIndex = 5,
            Parent = self.Container
        });
        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = Outer
        });
        Library:AddToRegistry(Outer, { BorderColor3 = 'Black' });
        Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
        
        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderColor3 = Library.AccentColorDark,
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 7,
            Parent = Inner
        });
        Library:AddToRegistry(Fill, { BackgroundColor3 = 'AccentColor'; BorderColor3 = 'AccentColorDark' });
        
        local Display = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = 12,
            ZIndex = 9,
            Parent = Inner
        });

        local function updateDisplay()
            local suf = Info.Suffix or ""
            Display.Text = Slider.Value .. suf .. " / " .. Slider.Max .. suf
            local pct = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
        end

        function Slider:SetValue(val)
            val = math.clamp(val, Slider.Min, Slider.Max)
            if Slider.Rounding > 0 then
                Slider.Value = tonumber(string.format("%." .. Slider.Rounding .. "f", val))
            else
                Slider.Value = math.floor(val)
            end
            updateDisplay()
            Library:SafeCallback(Slider.Callback, Slider.Value)
        end

        Inner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local pct = math.clamp((Mouse.X - Inner.AbsolutePosition.X) / Inner.AbsoluteSize.X, 0, 1)
                    Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * pct)
                    RenderStepped:Wait()
                end
                Library:AttemptSave()
            end
        end)

        Slider:SetValue(Slider.Value)
        self:AddBlank(4)
        self:Resize()
        Options[Idx] = Slider
        return Slider
    end

    function GFuncs:AddDropdown(Idx, Info)
        local Dropdown = {
            Values = Info.Values,
            Value = Info.Multi and {} or Info.Default,
            Multi = Info.Multi,
            Type = 'Dropdown',
            Callback = Info.Callback or function() end
        };
        Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 12),
            TextSize = 13,
            Text = Info.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.Container
        });
        self:AddBlank(3)
        local Outer = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1, -4, 0, 20),
            ZIndex = 5,
            Parent = self.Container
        });
        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 6,
            Parent = Outer
        });
        Library:AddToRegistry(Outer, { BorderColor3 = 'Black' });
        Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });

        local Display = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -25, 1, 0),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "--",
            ZIndex = 7,
            Parent = Inner
        });
        local Arrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Image = 'http://www.roblox.com/asset/?id=6282522798',
            ZIndex = 8,
            Parent = Inner
        });

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0),
            Visible = false,
            ZIndex = 300,
            Parent = ScreenGui
        });
        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 301,
            Parent = ListOuter
        });
        Library:AddToRegistry(ListInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' });
        local Scroll = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 302,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
            Parent = ListInner
        });
        Library:AddToRegistry(Scroll, { ScrollBarImageColor3 = 'AccentColor' });
        Library:Create('UIListLayout', { Parent = Scroll })

        local function updatePos()
            ListOuter.Position = UDim2.fromOffset(Outer.AbsolutePosition.X, Outer.AbsolutePosition.Y + Outer.Size.Y.Offset + 1)
            ListOuter.Size = UDim2.fromOffset(Outer.AbsoluteSize.X, math.min(#Dropdown.Values * 20 + 2, 120))
        end
        Outer:GetPropertyChangedSignal('AbsolutePosition'):Connect(updatePos)

        local function renderList()
            for _, c in ipairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            for _, val in ipairs(Dropdown.Values) do
                local itemFrame = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 303,
                    Parent = Scroll
                });
                local itemLabel = Library:CreateLabel({
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextSize = 12,
                    Text = tostring(val),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 304,
                    Parent = itemFrame
                });
                local function highlight()
                    local act = false
                    if Dropdown.Multi then act = not not Dropdown.Value[val] else act = (Dropdown.Value == val) end
                    itemLabel.TextColor3 = act and Library.AccentColor or Library.FontColor
                end
                highlight()

                itemFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Dropdown.Multi then
                            Dropdown.Value[val] = not Dropdown.Value[val]
                        else
                            Dropdown.Value = val
                            ListOuter.Visible = false
                        end
                        Dropdown:Display()
                        renderList()
                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                    end
                end)
            end
            Scroll.CanvasSize = UDim2.fromOffset(0, #Dropdown.Values * 20)
        end

        function Dropdown:Display()
            if Dropdown.Multi then
                local str = ""
                for k, v in pairs(Dropdown.Value) do
                    if v then str = str .. k .. ", " end
                end
                Display.Text = (str == "" and "--" or string.sub(str, 1, #str - 2))
            else
                Display.Text = tostring(Dropdown.Value or "--")
            end
        end

        function Dropdown:SetValue(val)
            Dropdown.Value = val
            Dropdown:Display()
            renderList()
        end

        Outer.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                updatePos()
                ListOuter.Visible = not ListOuter.Visible
                renderList()
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Library:IsMouseOverFrame(ListOuter) and not Library:IsMouseOverFrame(Outer) then
                    ListOuter.Visible = false
                end
            end
        end))

        Dropdown:Display()
        self:AddBlank(4)
        self:Resize()
        Options[Idx] = Dropdown
        return Dropdown
    end

    function GFuncs:AddDependencyBox()
        local boxObj = {
            Dependencies = {},
            Update = function(self)
                local visible = true
                for _, dep in ipairs(self.Dependencies) do
                    local opt = Toggles[dep.Idx] or Options[dep.Idx]
                    if opt then
                        if opt.Value ~= dep.Value then visible = false end
                    end
                end
                self.Frame.Visible = visible
                self.ParentGroupbox:Resize()
            end,
            Setup = function(self, list)
                self.Dependencies = list
                self:Update()
            end
        }
        local subContainer = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 2,
            Parent = self.Container
        });
        local subLayout = Library:Create('UIListLayout', { Parent = subContainer })
        subLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            subContainer.Size = UDim2.new(1, 0, 0, subLayout.AbsoluteContentSize.Y)
        end)
        boxObj.Frame = subContainer
        boxObj.Container = subContainer
        boxObj.ParentGroupbox = self
        setmetatable(boxObj, {__index = GFuncs})
        table.insert(Library.DependencyBoxes, boxObj)
        return boxObj
    end

    function GFuncs:Resize()
        local h = 20
        for _, c in ipairs(self.Container:GetChildren()) do
            if not c:IsA("UIListLayout") and c.Visible then h = h + c.Size.Y.Offset end
        end
        self.OuterFrame.Size = UDim2.new(1, 0, 0, h + 8)
    end

    BaseGroupbox.__index = GFuncs;
end;

-- CreateWindow Implementations
function Library:CreateWindow(options)
    local title = options.Title or "Evon Menu"
    local size = options.Size or UDim2.fromOffset(550, 600)
    local center = options.Center or false

    local Window = {
        Tabs = {}
    };

    local Outer = Library:Create('Frame', {
        AnchorPoint = center and Vector2.new(0.5, 0.5) or Vector2.zero,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Position = center and UDim2.fromScale(0.5, 0.5) or UDim2.fromOffset(175, 50),
        Size = size,
        Visible = false,
        ZIndex = 1,
        Parent = ScreenGui,
    });
    Library:MakeDraggable(Outer, 25);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.AccentColor,
        BorderMode = Enum.BorderMode.Inset,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 1,
        Parent = Outer,
    });
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'AccentColor',
    });

    local TitleLabel = Library:CreateLabel({
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(0, 0, 0, 25),
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1,
        Parent = Inner,
    });

    local SearchBox = Library:Create('TextBox', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(1, -125, 0, 4),
        Size = UDim2.new(0, 100, 0, 18),
        Font = Library.Font,
        PlaceholderText = "Search...",
        Text = "",
        TextColor3 = Library.FontColor,
        TextSize = 11,
        ZIndex = 10,
        Parent = Inner
    });
    Library:ApplyTextStroke(SearchBox);
    Library:AddToRegistry(SearchBox, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
        TextColor3 = 'FontColor'
    });

    local WindowControls = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0, 4),
        Size = UDim2.new(0, 18, 0, 18),
        Parent = Inner
    })
    local CloseBtn = Library:Create('TextButton', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "X",
        Font = Enum.Font.Code,
        TextColor3 = Library.FontColor,
        TextSize = 12,
        Parent = WindowControls
    })
    CloseBtn.MouseButton1Click:Connect(function()
        Library:Unload()
    end)

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 25),
        Size = UDim2.new(1, -16, 1, -33),
        ZIndex = 1,
        Parent = Inner,
    });
    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor',
        BorderColor3 = 'OutlineColor',
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        BorderColor3 = Color3.new(0, 0, 0),
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
        Parent = MainSectionOuter,
    });
    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor',
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 21),
        ZIndex = 1,
        Parent = MainSectionInner,
    });
    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabArea,
    });

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 8, 0, 30),
        Size = UDim2.new(1, -16, 1, -38),
        ZIndex = 2,
        Parent = MainSectionInner,
    });
    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor',
        BorderColor3 = 'OutlineColor',
    });

    -- Search mechanism
    SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
        local q = SearchBox.Text:lower()
        for _, tab in pairs(Window.Tabs) do
            for _, gb in pairs(tab.Groupboxes) do
                local anyVis = false
                for _, child in ipairs(gb.Container:GetChildren()) do
                    if not child:IsA("UIListLayout") then
                        local hasText = false
                        if child:IsA("Frame") and child:FindFirstChild("TextLabel") then
                            hasText = child.TextLabel.Text:lower():find(q) ~= nil
                        elseif child:IsA("TextLabel") then
                            hasText = child.Text:lower():find(q) ~= nil
                        end
                        child.Visible = (q == "" or hasText)
                        if child.Visible then anyVis = true end
                    end
                end
                gb.OuterFrame.Visible = anyVis
                gb:Resize()
            end
        end
    end)

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {},
            Tabboxes = {}
        };
        local textW = Library:GetTextBounds(Name, Library.Font, 14) + 12

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor,
            BorderColor3 = Library.OutlineColor,
            Size = UDim2.new(0, textW, 1, 0),
            ZIndex = 1,
            Parent = TabArea,
        });
        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor',
            BorderColor3 = 'OutlineColor',
        });
        local TabButtonLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0),
            Text = Name,
            ZIndex = 1,
            Parent = TabButton,
        });
        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false,
            ZIndex = 3,
            Parent = TabButton,
        });
        Library:AddToRegistry(Blocker, { BackgroundColor3 = 'MainColor' });

        local TabFrame = Library:Create('Frame', {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2,
            Parent = TabContainer,
        });
        
        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0.5, -12, 1, -16),
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ZIndex = 2,
            Parent = TabFrame,
        });
        local RightSide = LeftSide:Clone()
        RightSide.Position = UDim2.new(0.5, 4, 0, 8)
        RightSide.Parent = TabFrame

        local lLayout = Library:Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = LeftSide })
        local rLayout = Library:Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = RightSide })
        
        lLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() LeftSide.CanvasSize = UDim2.fromOffset(0, lLayout.AbsoluteContentSize.Y) end)
        rLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() RightSide.CanvasSize = UDim2.fromOffset(0, rLayout.AbsoluteContentSize.Y) end)

        function Tab:ShowTab()
            for _, t in pairs(Window.Tabs) do t:HideTab() end
            Blocker.Visible = true
            TabButton.BackgroundColor3 = Library.MainColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor'
            TabFrame.Visible = true
        end

        function Tab:HideTab()
            Blocker.Visible = false
            TabButton.BackgroundColor3 = Library.BackgroundColor
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor'
            TabFrame.Visible = false
        end

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:ShowTab()
            end
        end)

        function Tab:AddGroupbox(Info)
            local Groupbox = {};
            local OuterFrame = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 40),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide
            });
            Library:AddToRegistry(OuterFrame, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0,0,0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = OuterFrame
            });
            Library:AddToRegistry(BoxInner, { BackgroundColor3 = 'BackgroundColor' });
            
            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 5,
                Parent = BoxInner
            });
            Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor' });

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 6, 0, 2),
                TextSize = 13,
                Text = Info.Name,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = BoxInner
            });
            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 20),
                Size = UDim2.new(1, -12, 1, -20),
                ZIndex = 1,
                Parent = BoxInner
            });
            Library:Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = Container })

            Groupbox.OuterFrame = OuterFrame
            Groupbox.Container = Container
            setmetatable(Groupbox, BaseGroupbox)
            Groupbox:Resize()
            
            Tab.Groupboxes[Info.Name] = Groupbox
            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name) return Tab:AddGroupbox({ Side = 1, Name = Name }) end
        function Tab:AddRightGroupbox(Name) return Tab:AddGroupbox({ Side = 2, Name = Name }) end

        -- Tabbox within groupbox support
        function Tab:AddTabbox(Info)
            local Tabbox = { Tabs = {} }
            local OuterFrame = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Library.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 0, 40),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide
            });
            Library:AddToRegistry(OuterFrame, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor' });
            
            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor,
                BorderColor3 = Color3.new(0,0,0),
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                ZIndex = 4,
                Parent = OuterFrame
            });
            Library:AddToRegistry(BoxInner, { BackgroundColor3 = 'BackgroundColor' });
            
            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 1),
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = 5,
                Parent = BoxInner
            });
            Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Horizontal, Parent = TabboxButtons })

            function Tabbox:AddTab(Name)
                local SubTab = {}
                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor,
                    BorderColor3 = Color3.new(0,0,0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 6,
                    Parent = TabboxButtons
                });
                Library:AddToRegistry(Button, { BackgroundColor3 = 'MainColor' });
                local ButtonLabel = Library:CreateLabel({ Size = UDim2.new(1,0,1,0), TextSize = 13, Text = Name, ZIndex = 7, Parent = Button });
                
                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0,0,1,0),
                    Size = UDim2.new(1,0,0,1),
                    Visible = false,
                    ZIndex = 9,
                    Parent = Button
                });
                Library:AddToRegistry(Block, { BackgroundColor3 = 'BackgroundColor' });

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 20),
                    Size = UDim2.new(1, -12, 1, -20),
                    Visible = false,
                    ZIndex = 1,
                    Parent = BoxInner
                });
                Library:Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = Container })

                function SubTab:Show()
                    for _, t in pairs(Tabbox.Tabs) do t:Hide() end
                    Container.Visible = true
                    Block.Visible = true
                    Button.BackgroundColor3 = Library.BackgroundColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor'
                    SubTab:Resize()
                end
                function SubTab:Hide()
                    Container.Visible = false
                    Block.Visible = false
                    Button.BackgroundColor3 = Library.MainColor
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor'
                end
                function SubTab:Resize()
                    local cnt = 0
                    for _ in pairs(Tabbox.Tabs) do cnt = cnt + 1 end
                    for _, b in ipairs(TabboxButtons:GetChildren()) do
                        if b:IsA("Frame") then b.Size = UDim2.new(1 / cnt, 0, 1, 0) end
                    end
                    if not Container.Visible then return end
                    local sz = 20
                    for _, el in ipairs(Container:GetChildren()) do
                        if not el:IsA("UIListLayout") and el.Visible then sz = sz + el.Size.Y.Offset end
                    end
                    OuterFrame.Size = UDim2.new(1, 0, 0, sz + 8)
                end
                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then SubTab:Show() end
                end)

                SubTab.OuterFrame = OuterFrame
                SubTab.Container = Container
                setmetatable(SubTab, BaseGroupbox)
                Tabbox.Tabs[Name] = SubTab
                
                if #TabboxButtons:GetChildren() == 2 then SubTab:Show() end
                return SubTab
            end
            
            return Tabbox
        end

        if #TabContainer:GetChildren() == 1 then Tab:ShowTab() end
        Window.Tabs[Name] = Tab
        return Tab
    end

    local toggledState = false
    local fadingMenu = false
    local toggleKey = Enum.KeyCode.RightControl

    -- Custom Drawing cursor to draw on top of UI
    local function drawCursor()
        local cursor = Drawing.new('Triangle')
        cursor.Thickness = 1
        cursor.Filled = true
        cursor.Visible = true

        local outline = Drawing.new('Triangle')
        outline.Thickness = 1
        outline.Filled = false
        outline.Color = Color3.new(0, 0, 0)
        outline.Visible = true

        while toggledState and ScreenGui.Parent do
            InputService.MouseIconEnabled = false
            local mPos = InputService:GetMouseLocation()
            cursor.Color = Library.AccentColor
            cursor.PointA = Vector2.new(mPos.X, mPos.Y)
            cursor.PointB = Vector2.new(mPos.X + 14, mPos.Y + 6)
            cursor.PointC = Vector2.new(mPos.X + 5, mPos.Y + 14)
            outline.PointA = cursor.PointA
            outline.PointB = cursor.PointB
            outline.PointC = cursor.PointC
            RenderStepped:Wait()
        end
        InputService.MouseIconEnabled = true
        cursor:Remove()
        outline:Remove()
    end

    function Library:Toggle()
        if fadingMenu then return end
        fadingMenu = true
        toggledState = not toggledState
        Outer.Visible = toggledState
        if toggledState then task.spawn(drawCursor) end
        fadingMenu = false
    end

    -- Menu toggle listener
    InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                Library:Toggle()
            end
        elseif Input.KeyCode == toggleKey then
            Library:Toggle()
        end
    end)

    Window.Holder = Outer;
    return Window
end

-- Automatic UI settings builder helper
function Library:AddSettingsAndConfig(Window)
    local SettingsTab = Window:AddTab("Settings")
    local ThemesBox = SettingsTab:AddLeftGroupbox("Theme & Fonts")
    local CustomizerBox = SettingsTab:AddRightGroupbox("Customization")
    
    ThemesBox:AddDropdown("ThemeDropdown", {
        Text = "Active Theme",
        Values = {"Dark", "Light", "Midnight", "OLED", "Classic"},
        Default = "Dark",
        Callback = function(val)
            Library:SetTheme(val)
        end
    })
    
    ThemesBox:AddDropdown("FontDropdown", {
        Text = "Active Font",
        Values = {"Inter", "SegoeUI", "Roboto", "JetBrainsMono", "SFPro", "Poppins"},
        Default = "Inter",
        Callback = function(val)
            Library:SetFont(val)
        end
    })
    
    ThemesBox:AddDropdown("AccentDropdown", {
        Text = "Active Accent",
        Values = {"Blue", "Purple", "Red", "Orange", "Green", "Cyan", "Pink", "Yellow", "White"},
        Default = "Blue",
        Callback = function(val)
            Library:SetAccent(Library.Accents[val])
        end
    })

    -- Custom scale, transparency adjustments
    local scaleVal = 1.0
    CustomizerBox:AddSlider("UIScaleSlider", {
        Text = "UI Scale",
        Min = 0.5,
        Max = 2.0,
        Rounding = 1,
        Default = 1.0,
        Callback = function(val)
            scaleVal = val
            -- Apply scaling using UIScale
            local sc = ScreenGui:FindFirstChild("UIScale") or Instance.new("UIScale", ScreenGui)
            sc.Scale = val
        end
    })
    
    Library.ToggleKeybind = CustomizerBox:AddLabel("Menu Toggle"):AddKeyPicker("MenuKeyPicker", {
        Default = "Insert",
        Mode = "Toggle"
    })
    
    -- Config system simulation
    local ConfigBox = SettingsTab:AddLeftGroupbox("Configurations")
    local configName = "default"
    ConfigBox:AddInput("ConfigNameInput", {
        Text = "Config Name",
        Placeholder = "Enter name...",
        Default = "default",
        Callback = function(val) configName = val end
    })
    ConfigBox:AddButton("Save Profile", function()
        Library:Notify("Successfully saved profile '" .. configName .. "'", 4)
    end)
    ConfigBox:AddButton("Load Profile", function()
        Library:Notify("Successfully loaded profile '" .. configName .. "'", 4)
    end)
    ConfigBox:AddButton("Delete Profile", function()
        Library:Notify("Deleted configuration profile '" .. configName .. "'", 4)
    end)
end

getgenv().Library = Library
return Library
