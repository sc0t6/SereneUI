local SereneUI = {}
SereneUI.__index = SereneUI

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local DEFAULT_THEME = {
    Background        = Color3.fromRGB(18, 18, 24),
    Surface           = Color3.fromRGB(24, 24, 32),
    SurfaceAlt        = Color3.fromRGB(30, 30, 40),
    Card              = Color3.fromRGB(32, 32, 44),
    CardHover         = Color3.fromRGB(40, 40, 54),
    Border            = Color3.fromRGB(48, 48, 64),
    Accent            = Color3.fromRGB(100, 120, 255),
    AccentHover       = Color3.fromRGB(125, 142, 255),
    AccentDark        = Color3.fromRGB(70, 88, 200),
    TextPrimary       = Color3.fromRGB(235, 235, 245),
    TextSecondary     = Color3.fromRGB(160, 160, 180),
    TextMuted         = Color3.fromRGB(100, 100, 120),
    Success           = Color3.fromRGB(80, 200, 120),
    Warning           = Color3.fromRGB(255, 190, 60),
    Error             = Color3.fromRGB(255, 85, 85),
    Shadow            = Color3.fromRGB(0, 0, 0),
    Font              = Enum.Font.GothamMedium,
    FontBold          = Enum.Font.GothamBold,
    FontLight         = Enum.Font.Gotham,
    CornerRadius      = UDim.new(0, 8),
    CornerRadiusSmall = UDim.new(0, 6),
    CornerRadiusLarge = UDim.new(0, 12),
    AnimationSpeed    = 0.25,
    AnimationSpeedFast= 0.15,
    AnimationEasing   = Enum.EasingStyle.Quint,
}

local Util = {}

function Util.Tween(instance, props, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(
        duration or DEFAULT_THEME.AnimationSpeed,
        easingStyle or DEFAULT_THEME.AnimationEasing,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

function Util.TweenFast(instance, props)
    return Util.Tween(instance, props, DEFAULT_THEME.AnimationSpeedFast)
end

function Util.Create(className, properties, children)
    local obj = Instance.new(className)
    if properties then
        for k, v in pairs(properties) do
            if k ~= "Parent" then
                obj[k] = v
            end
        end
        if properties.Parent then
            obj.Parent = properties.Parent
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

function Util.Corner(parent, radius)
    return Util.Create("UICorner", {
        CornerRadius = radius or DEFAULT_THEME.CornerRadius,
        Parent = parent,
    })
end

function Util.Stroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or DEFAULT_THEME.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent,
    })
end

function Util.Shadow(parent, size, transparency)
    return Util.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, size or 24, 1, size or 24),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = DEFAULT_THEME.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent,
    })
end

function Util.Padding(parent, top, right, bottom, left)
    return Util.Create("UIPadding", {
        PaddingTop    = UDim.new(0, top or 8),
        PaddingRight  = UDim.new(0, right or top or 8),
        PaddingBottom = UDim.new(0, bottom or top or 8),
        PaddingLeft   = UDim.new(0, left or right or top or 8),
        Parent = parent,
    })
end

function Util.ListLayout(parent, padding, direction, hAlign, vAlign, sortOrder)
    return Util.Create("UIListLayout", {
        Padding             = UDim.new(0, padding or 6),
        FillDirection       = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center,
        VerticalAlignment   = vAlign or Enum.VerticalAlignment.Top,
        SortOrder           = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Util.Ripple(button, theme)
    local ripple = Util.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = button,
    })
    Util.Corner(ripple, UDim.new(1, 0))
    local sz = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Util.Tween(ripple, {
        Size = UDim2.new(0, sz, 0, sz),
        BackgroundTransparency = 1,
    }, 0.45, Enum.EasingStyle.Quad)
    task.delay(0.5, function() ripple:Destroy() end)
end

function Util.HoverBind(frame, hoverColor, defaultColor)
    frame.MouseEnter:Connect(function()
        Util.TweenFast(frame, { BackgroundColor3 = hoverColor })
    end)
    frame.MouseLeave:Connect(function()
        Util.TweenFast(frame, { BackgroundColor3 = defaultColor })
    end)
end

function Util.DeepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[Util.DeepCopy(k)] = Util.DeepCopy(v)
    end
    return copy
end

function Util.AddVisibility(api, frame)
    function api:SetVisible(vis)
        frame.Visible = vis
    end
    return api
end

local TooltipModule = {}

function TooltipModule.Init(screenGui, theme)
    local tooltip = Util.Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 100,
        Parent = screenGui,
    })
    Util.Corner(tooltip, theme.CornerRadiusSmall)
    Util.Stroke(tooltip, theme.Border, 1, 0.6)
    Util.Padding(tooltip, 6, 10, 6, 10)

    local label = Util.Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Font = theme.Font,
        TextSize = 12,
        TextColor3 = theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tooltip,
    })

    local showDelay = nil

    function TooltipModule.Show(text, posX, posY)
        if showDelay then task.cancel(showDelay) end
        showDelay = task.delay(0.4, function()
            label.Text = text
            tooltip.Position = UDim2.new(0, posX + 12, 0, posY + 12)
            tooltip.Visible = true
            tooltip.BackgroundTransparency = 1
            Util.TweenFast(tooltip, { BackgroundTransparency = 0 })
        end)
    end

    function TooltipModule.Hide()
        if showDelay then task.cancel(showDelay); showDelay = nil end
        tooltip.Visible = false
    end

    return TooltipModule
end

function TooltipModule.Bind(frame, text)
    frame.MouseEnter:Connect(function()
        local pos = frame.AbsolutePosition
        TooltipModule.Show(text, pos.X + frame.AbsoluteSize.X, pos.Y)
    end)
    frame.MouseLeave:Connect(function()
        TooltipModule.Hide()
    end)
end

local NotificationModule = {}

function NotificationModule.Init(screenGui, theme)
    local container = Util.Create("Frame", {
        Name = "NotificationContainer",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 320, 1, -40),
        ZIndex = 90,
        Parent = screenGui,
    })
    Util.ListLayout(container, 8, Enum.FillDirection.Vertical,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

    NotificationModule._container = container
    NotificationModule._theme = theme
end

function NotificationModule.Send(options)
    local theme = NotificationModule._theme
    local title    = options.Title or "Notification"
    local message  = options.Message or ""
    local duration = options.Duration or 4
    local icon     = options.Icon or ""
    local nType    = options.Type or "info"

    local accentColor = theme.Accent
    if nType == "success" then accentColor = theme.Success
    elseif nType == "warning" then accentColor = theme.Warning
    elseif nType == "error" then accentColor = theme.Error end

    local card = Util.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        LayoutOrder = -math.floor(tick() * 100),
        Parent = NotificationModule._container,
    })
    Util.Corner(card, theme.CornerRadius)
    Util.Stroke(card, theme.Border, 1, 0.7)
    Util.Shadow(card, 16, 0.6)

    Util.Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })

    local content = Util.Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -18, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })
    Util.Padding(content, 10, 10, 10, 10)
    Util.ListLayout(content, 3)

    local titleRow = Util.Create("Frame", {
        Name = "TitleRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = content,
    })

    if icon ~= "" then
        Util.Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 0, 18),
            Font = theme.Font,
            Text = icon,
            TextSize = 14,
            TextColor3 = accentColor,
            Parent = titleRow,
        })
    end

    Util.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, icon ~= "" and 22 or 0, 0, 0),
        Size = UDim2.new(1, icon ~= "" and -22 or 0, 1, 0),
        Font = theme.FontBold,
        Text = title,
        TextSize = 13,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = titleRow,
    })

    if message ~= "" then
        Util.Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = theme.FontLight,
            Text = message,
            TextSize = 12,
            TextColor3 = theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = content,
        })
    end

    local progressBar = Util.Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 0, 2),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })

    card.BackgroundTransparency = 1
    card.Position = UDim2.new(1, 40, 0, 0)
    Util.Tween(card, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0),
    }, 0.35, Enum.EasingStyle.Back)

    for _, child in ipairs(card:GetDescendants()) do
        if child:IsA("TextLabel") then
            local orig = child.TextTransparency
            child.TextTransparency = 1
            task.delay(0.15, function()
                Util.Tween(child, { TextTransparency = orig }, 0.2)
            end)
        end
    end

    Util.Tween(progressBar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        Util.Tween(card, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 40, 0, 0),
            Size = UDim2.new(1, 0, 0, 0),
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        card:Destroy()
    end

    local dismissBtn = Util.Create("TextButton", {
        Name = "DismissHit",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5,
        Parent = card,
    })
    dismissBtn.MouseButton1Click:Connect(function()
        dismiss()
    end)

    task.delay(duration, function()
        dismiss()
    end)
end

local ConfigModule = {}

function ConfigModule.Init(libraryName)
    ConfigModule._name = libraryName or "SereneUI"
    ConfigModule._data = {}
    ConfigModule._flags = {}
end

function ConfigModule.SetFlag(flag, value)
    ConfigModule._flags[flag] = value
end

function ConfigModule.GetFlag(flag)
    return ConfigModule._flags[flag]
end

function ConfigModule.Save(fileName)
    local path = ConfigModule._name .. "/" .. (fileName or "default") .. ".json"
    local data = {}
    for flag, value in pairs(ConfigModule._flags) do
        if typeof(value) == "Color3" then
            data[flag] = { _type = "Color3", R = value.R, G = value.G, B = value.B }
        elseif typeof(value) == "EnumItem" then
            data[flag] = { _type = "Enum", Value = tostring(value) }
        else
            data[flag] = value
        end
    end
    local json = HttpService:JSONEncode(data)
    if writefile then
        if not isfolder(ConfigModule._name) then makefolder(ConfigModule._name) end
        writefile(path, json)
    end
end

function ConfigModule.Load(fileName)
    local path = ConfigModule._name .. "/" .. (fileName or "default") .. ".json"
    if readfile and isfile and isfile(path) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and data then
            for flag, value in pairs(data) do
                if type(value) == "table" and value._type == "Color3" then
                    ConfigModule._flags[flag] = Color3.new(value.R, value.G, value.B)
                else
                    ConfigModule._flags[flag] = value
                end
            end
            return true
        end
    end
    return false
end

local BlurModule = {}

function BlurModule.Init(enabled)
    BlurModule._enabled = enabled
    BlurModule._blur = nil
end

function BlurModule.Show()
    if not BlurModule._enabled then return end
    if not BlurModule._blur then
        BlurModule._blur = Util.Create("BlurEffect", {
            Name = "SereneUIBlur",
            Size = 0,
            Parent = Lighting,
        })
    end
    Util.Tween(BlurModule._blur, { Size = 12 }, 0.3)
end

function BlurModule.Hide()
    if BlurModule._blur then
        Util.Tween(BlurModule._blur, { Size = 0 }, 0.3)
    end
end

function BlurModule.Destroy()
    if BlurModule._blur then
        BlurModule._blur:Destroy()
        BlurModule._blur = nil
    end
end

function SereneUI:CreateWindow(options)
    options = options or {}
    local title       = options.Title or "SereneUI"
    local subtitle    = options.Subtitle or "v1.0"
    local size        = options.Size or UDim2.new(0, 560, 0, 400)
    local theme       = Util.DeepCopy(DEFAULT_THEME)
    local toggleKey   = options.ToggleKey or Enum.KeyCode.RightShift
    local blurEnabled = options.BackgroundBlur ~= false
    local scaleFactor = options.UIScale or 1
    local configName  = options.ConfigName or title

    if options.Theme then
        for k, v in pairs(options.Theme) do
            theme[k] = v
        end
    end
    if options.AccentColor then
        theme.Accent = options.AccentColor
        local r, g, b = options.AccentColor.R, options.AccentColor.G, options.AccentColor.B
        theme.AccentHover = Color3.new(
            math.clamp(r + 0.1, 0, 1),
            math.clamp(g + 0.1, 0, 1),
            math.clamp(b + 0.1, 0, 1)
        )
        theme.AccentDark = Color3.new(
            math.clamp(r - 0.12, 0, 1),
            math.clamp(g - 0.12, 0, 1),
            math.clamp(b - 0.12, 0, 1)
        )
    end

    ConfigModule.Init(configName)
    BlurModule.Init(blurEnabled)

    local screenGui = Util.Create("ScreenGui", {
        Name = "SereneUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 100,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end

    if scaleFactor ~= 1 then
        Util.Create("UIScale", { Scale = scaleFactor, Parent = screenGui })
    end

    TooltipModule.Init(screenGui, theme)
    NotificationModule.Init(screenGui, theme)

    local mainFrame = Util.Create("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        BackgroundColor3 = theme.Background,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Util.Corner(mainFrame, theme.CornerRadiusLarge)
    Util.Stroke(mainFrame, theme.Border, 1, 0.6)
    Util.Shadow(mainFrame, 40, 0.45)

    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    task.defer(function()
        Util.Tween(mainFrame, {
            Size = size,
            BackgroundTransparency = 0,
        }, 0.45, Enum.EasingStyle.Back)
        BlurModule.Show()
    end)

    local titleBar = Util.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(1, 0, 0, 42),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    Util.Create("UICorner", {
        CornerRadius = theme.CornerRadiusLarge,
        Parent = titleBar,
    })
    Util.Create("Frame", {
        Name = "BottomFill",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    Util.Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = theme.Accent,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.7,
        Parent = titleBar,
    })

    local logoCircle = Util.Create("Frame", {
        Name = "LogoCircle",
        BackgroundColor3 = theme.Accent,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0, 12, 0.5, -13),
        Parent = titleBar,
    })
    Util.Corner(logoCircle, UDim.new(1, 0))
    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = theme.FontBold,
        Text = string.sub(title, 1, 1),
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = logoCircle,
    })

    local titleContainer = Util.Create("Frame", {
        Name = "TitleContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 46, 0, 0),
        Size = UDim2.new(0.6, -46, 1, 0),
        Parent = titleBar,
    })
    Util.ListLayout(titleContainer, 0, Enum.FillDirection.Horizontal,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    local titleLabel = Util.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        Font = theme.FontBold,
        Text = title,
        TextSize = 15,
        TextColor3 = theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleContainer,
    })

    local subtitleLabel = Util.Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        Font = theme.FontLight,
        Text = "  " .. subtitle,
        TextSize = 13,
        TextColor3 = theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleContainer,
    })

    local closeBtn = Util.Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = theme.Error,
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextSize = 13,
        TextColor3 = theme.Error,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    Util.Corner(closeBtn, UDim.new(1, 0))
    Util.HoverBind(closeBtn, Color3.fromRGB(255, 60, 60), theme.Error)
    closeBtn.MouseEnter:Connect(function()
        Util.TweenFast(closeBtn, { BackgroundTransparency = 0.4 })
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.TweenFast(closeBtn, { BackgroundTransparency = 0.85 })
    end)

    local minBtn = Util.Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = theme.TextMuted,
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -70, 0.5, -14),
        Font = theme.FontBold,
        Text = "—",
        TextSize = 14,
        TextColor3 = theme.TextMuted,
        AutoButtonColor = false,
        Parent = titleBar,
    })
    Util.Corner(minBtn, UDim.new(1, 0))
    minBtn.MouseEnter:Connect(function()
        Util.TweenFast(minBtn, { BackgroundTransparency = 0.5 })
    end)
    minBtn.MouseLeave:Connect(function()
        Util.TweenFast(minBtn, { BackgroundTransparency = 0.85 })
    end)

    local reopenBtn = Util.Create("TextButton", {
        Name = "ReopenBtn",
        BackgroundColor3 = theme.Surface,
        Size = UDim2.new(0, 36, 0, 100),
        Position = UDim2.new(0, -50, 0.5, -50),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = theme.FontBold,
        Text = "›",
        TextSize = 22,
        TextColor3 = theme.Accent,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 80,
        Parent = screenGui,
    })
    Util.Corner(reopenBtn, theme.CornerRadius)
    Util.Stroke(reopenBtn, theme.Border, 1, 0.6)
    Util.Shadow(reopenBtn, 12, 0.6)

    reopenBtn.MouseEnter:Connect(function()
        Util.TweenFast(reopenBtn, {
            BackgroundColor3 = theme.Card,
            Size = UDim2.new(0, 40, 0, 108),
        })
    end)
    reopenBtn.MouseLeave:Connect(function()
        Util.TweenFast(reopenBtn, {
            BackgroundColor3 = theme.Surface,
            Size = UDim2.new(0, 36, 0, 100),
        })
    end)

    local dragging, dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Util.TweenFast(mainFrame, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            })
        end
    end)

    local sidebar = Util.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Surface,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 150, 1, -42),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame,
    })

    Util.Create("Frame", {
        Name = "Divider",
        BackgroundColor3 = theme.Border,
        BackgroundTransparency = 0.5,
        Position = UDim2.new(1, -1, 0, 8),
        Size = UDim2.new(0, 1, 1, -16),
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local tabButtonContainer = Util.Create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, -4, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.TextMuted,
        ScrollBarImageTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Util.ListLayout(tabButtonContainer, 3, nil, Enum.HorizontalAlignment.Center)
    Util.Padding(tabButtonContainer, 4, 8, 4, 8)

    local contentArea = Util.Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 42),
        Size = UDim2.new(1, -150, 1, -42),
        ClipsDescendants = true,
        Parent = mainFrame,
    })

    local Window = {
        _screenGui      = screenGui,
        _mainFrame      = mainFrame,
        _contentArea    = contentArea,
        _tabBtnContainer= tabButtonContainer,
        _theme          = theme,
        _tabs           = {},
        _activeTab      = nil,
        _visible        = true,
        _toggleKey      = toggleKey,
    }

    local function toggleUI()
        Window._visible = not Window._visible
        if Window._visible then
            Util.Tween(reopenBtn, { Position = UDim2.new(0, -50, 0.5, -50) }, 0.2)
            task.delay(0.15, function() reopenBtn.Visible = false end)
            mainFrame.Visible = true
            Util.Tween(mainFrame, {
                Size = size,
                BackgroundTransparency = 0,
            }, 0.35, Enum.EasingStyle.Back)
            BlurModule.Show()
        else
            Util.Tween(mainFrame, {
                Size = UDim2.new(0, size.X.Offset, 0, 0),
                BackgroundTransparency = 1,
            }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            BlurModule.Hide()
            task.delay(0.3, function()
                if not Window._visible then
                    mainFrame.Visible = false
                end
            end)
            reopenBtn.Visible = true
            reopenBtn.Position = UDim2.new(0, -50, 0.5, -50)
            task.delay(0.35, function()
                if not Window._visible then
                    Util.Tween(reopenBtn, {
                        Position = UDim2.new(0, 8, 0.5, -50),
                    }, 0.3, Enum.EasingStyle.Back)
                end
            end)
        end
    end

    reopenBtn.MouseButton1Click:Connect(function()
        if not Window._visible then
            toggleUI()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            toggleUI()
        end
    end)

    local confirmOverlay = Util.Create("Frame", {
        Name = "ConfirmOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 50,
        Parent = mainFrame,
    })

    local confirmBox = Util.Create("Frame", {
        Name = "ConfirmBox",
        BackgroundColor3 = theme.Surface,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 300, 0, 140),
        ZIndex = 51,
        Parent = confirmOverlay,
    })
    Util.Corner(confirmBox, theme.CornerRadiusLarge)
    Util.Stroke(confirmBox, theme.Border, 1, 0.5)
    Util.Shadow(confirmBox, 24, 0.5)

    Util.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 20),
        Font = theme.FontBold,
        Text = "Are you sure?",
        TextSize = 15,
        TextColor3 = theme.TextPrimary,
        ZIndex = 52,
        Parent = confirmBox,
    })

    Util.Create("TextLabel", {
        Name = "Desc",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 0, 16),
        Font = theme.FontLight,
        Text = "This will destroy the menu entirely.",
        TextSize = 12,
        TextColor3 = theme.TextSecondary,
        ZIndex = 52,
        Parent = confirmBox,
    })

    local confirmYes = Util.Create("TextButton", {
        Name = "Yes",
        BackgroundColor3 = theme.Error,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(0.5, -125, 1, -50),
        Font = theme.FontBold,
        Text = "Destroy",
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        ZIndex = 52,
        Parent = confirmBox,
    })
    Util.Corner(confirmYes, theme.CornerRadiusSmall)

    local confirmNo = Util.Create("TextButton", {
        Name = "No",
        BackgroundColor3 = theme.Card,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(0.5, 5, 1, -50),
        Font = theme.FontBold,
        Text = "Cancel",
        TextSize = 13,
        TextColor3 = theme.TextPrimary,
        AutoButtonColor = false,
        ZIndex = 52,
        Parent = confirmBox,
    })
    Util.Corner(confirmNo, theme.CornerRadiusSmall)

    confirmYes.MouseEnter:Connect(function()
        Util.TweenFast(confirmYes, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) })
    end)
    confirmYes.MouseLeave:Connect(function()
        Util.TweenFast(confirmYes, { BackgroundColor3 = theme.Error })
    end)
    confirmNo.MouseEnter:Connect(function()
        Util.TweenFast(confirmNo, { BackgroundColor3 = theme.CardHover })
    end)
    confirmNo.MouseLeave:Connect(function()
        Util.TweenFast(confirmNo, { BackgroundColor3 = theme.Card })
    end)

    local function showConfirm()
        confirmOverlay.Visible = true
        confirmBox.Size = UDim2.new(0, 280, 0, 120)
        confirmBox.BackgroundTransparency = 1
        confirmOverlay.BackgroundTransparency = 1
        Util.Tween(confirmOverlay, { BackgroundTransparency = 0.4 }, 0.2)
        Util.Tween(confirmBox, {
            Size = UDim2.new(0, 300, 0, 140),
            BackgroundTransparency = 0,
        }, 0.25, Enum.EasingStyle.Back)
    end

    local function hideConfirm()
        Util.Tween(confirmBox, {
            Size = UDim2.new(0, 280, 0, 120),
            BackgroundTransparency = 1,
        }, 0.2)
        Util.Tween(confirmOverlay, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.25, function()
            confirmOverlay.Visible = false
        end)
    end

    confirmYes.MouseButton1Click:Connect(function()
        hideConfirm()
        task.delay(0.25, function()
            BlurModule.Destroy()
            screenGui:Destroy()
        end)
    end)

    confirmNo.MouseButton1Click:Connect(hideConfirm)

    closeBtn.MouseButton1Click:Connect(showConfirm)
    minBtn.MouseButton1Click:Connect(toggleUI)

    function Window:SetTitle(t)
        titleLabel.Text = t
        logoCircle:FindFirstChildWhichIsA("TextLabel").Text = string.sub(t, 1, 1)
    end

    function Window:SetSubtitle(s)
        subtitleLabel.Text = "  " .. s
    end

    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or ""

        local tabBtn = Util.Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = theme.SurfaceAlt,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false,
            Font = theme.Font,
            Text = "",
            LayoutOrder = #self._tabs + 1,
            Parent = tabButtonContainer,
        })
        Util.Corner(tabBtn, theme.CornerRadiusSmall)

        if tabIcon ~= "" then
            Util.Create("TextLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 20, 1, 0),
                Font = theme.Font,
                Text = tabIcon,
                TextSize = 14,
                TextColor3 = theme.TextMuted,
                Parent = tabBtn,
            })
        end

        local tabLabel = Util.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, tabIcon ~= "" and 32 or 12, 0, 0),
            Size = UDim2.new(1, tabIcon ~= "" and -36 or -16, 1, 0),
            Font = theme.Font,
            Text = tabName,
            TextSize = 13,
            TextColor3 = theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = tabBtn,
        })

        local indicator = Util.Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
            Parent = tabBtn,
        })
        Util.Corner(indicator, UDim.new(0, 2))

        local tabContent = Util.Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.TextMuted,
            ScrollBarImageTransparency = 0.5,
            BorderSizePixel = 0,
            Visible = false,
            Parent = contentArea,
        })
        Util.ListLayout(tabContent, 6)
        Util.Padding(tabContent, 12, 14, 12, 14)

        local tabObj = {
            _btn       = tabBtn,
            _label     = tabLabel,
            _indicator = indicator,
            _content   = tabContent,
            _theme     = theme,
            _name      = tabName,
            _elements  = {},
            _window    = self,
        }

        local function activateTab()
            if self._activeTab then
                local prev = self._activeTab
                prev._content.Visible = false
                Util.TweenFast(prev._btn, { BackgroundTransparency = 1 })
                Util.TweenFast(prev._label, { TextColor3 = theme.TextSecondary })
                Util.Tween(prev._indicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.2)
                local prevIcon = prev._btn:FindFirstChild("Icon")
                if prevIcon then Util.TweenFast(prevIcon, { TextColor3 = theme.TextMuted }) end
            end

            self._activeTab = tabObj
            tabContent.Visible = true
            Util.TweenFast(tabBtn, { BackgroundTransparency = 0.7 })
            Util.TweenFast(tabLabel, { TextColor3 = theme.TextPrimary })
            Util.Tween(indicator, { Size = UDim2.new(0, 3, 0, 18) }, 0.2)
            local iconLbl = tabBtn:FindFirstChild("Icon")
            if iconLbl then Util.TweenFast(iconLbl, { TextColor3 = theme.Accent }) end

            tabContent.CanvasPosition = Vector2.new(0, 0)
            for _, el in ipairs(tabContent:GetChildren()) do
                if el:IsA("Frame") then
                    local origTrans = (el.Name == "Section_" or el.BackgroundTransparency == 1)
                        and 1 or 0
                    if origTrans == 0 then
                        el.BackgroundTransparency = 1
                        Util.Tween(el, { BackgroundTransparency = 0 }, 0.3)
                    end
                end
            end
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        tabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= tabObj then
                Util.TweenFast(tabBtn, { BackgroundTransparency = 0.8 })
                Util.TweenFast(tabLabel, { TextColor3 = theme.TextPrimary })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= tabObj then
                Util.TweenFast(tabBtn, { BackgroundTransparency = 1 })
                Util.TweenFast(tabLabel, { TextColor3 = theme.TextSecondary })
            end
        end)

        table.insert(self._tabs, tabObj)

        if #self._tabs == 1 then
            task.defer(activateTab)
        end

        local function makeElementRow(name, height)
            local row = Util.Create("Frame", {
                Name = name,
                BackgroundColor3 = theme.Card,
                Size = UDim2.new(1, 0, 0, height or 38),
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            Util.Corner(row, theme.CornerRadiusSmall)
            Util.Stroke(row, theme.Border, 1, 0.8)
            table.insert(tabObj._elements, row)
            return row
        end

        function tabObj:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"

            local section = Util.Create("Frame", {
                Name = "Section_" .. sectionName,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            table.insert(tabObj._elements, section)

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 16),
                Position = UDim2.new(0, 4, 0, 4),
                Font = theme.FontBold,
                Text = string.upper(sectionName),
                TextSize = 10,
                TextColor3 = theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section,
            })

            Util.Create("Frame", {
                BackgroundColor3 = theme.Border,
                BackgroundTransparency = 0.6,
                Size = UDim2.new(1, -8, 0, 1),
                Position = UDim2.new(0, 4, 1, -1),
                BorderSizePixel = 0,
                Parent = section,
            })
        end

        function tabObj:CreateDivider()
            local div = Util.Create("Frame", {
                Name = "Divider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            Util.Create("Frame", {
                BackgroundColor3 = theme.Border,
                BackgroundTransparency = 0.6,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -16, 0, 1),
                BorderSizePixel = 0,
                Parent = div,
            })
            table.insert(tabObj._elements, div)
        end

        function tabObj:CreateLabel(labelOptions)
            labelOptions = labelOptions or {}
            local text = labelOptions.Text or "Label"

            local row = makeElementRow("Label", 32)
            local lbl = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local labelAPI = {}
            function labelAPI:SetText(newText) lbl.Text = newText end
            return Util.AddVisibility(labelAPI, row)
        end

        function tabObj:CreateParagraph(pOptions)
            pOptions = pOptions or {}
            local pTitle   = pOptions.Title or "Info"
            local pContent = pOptions.Content or ""

            local row = Util.Create("Frame", {
                Name = "Paragraph",
                BackgroundColor3 = theme.Card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            Util.Corner(row, theme.CornerRadiusSmall)
            Util.Stroke(row, theme.Border, 1, 0.8)
            table.insert(tabObj._elements, row)

            local inner = Util.Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = row,
            })
            Util.ListLayout(inner, 4)
            Util.Padding(inner, 10, 12, 10, 12)

            local tLbl = Util.Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Font = theme.FontBold,
                Text = pTitle,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inner,
            })

            local cLbl = Util.Create("TextLabel", {
                Name = "Content",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = theme.FontLight,
                Text = pContent,
                TextSize = 12,
                TextColor3 = theme.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = inner,
            })

            local pAPI = {}
            function pAPI:SetTitle(t) tLbl.Text = t end
            function pAPI:SetContent(c) cLbl.Text = c end
            return Util.AddVisibility(pAPI, row)
        end

        function tabObj:CreateButton(btnOptions)
            btnOptions = btnOptions or {}
            local text     = btnOptions.Text or "Button"
            local callback = btnOptions.Callback or function() end
            local tip      = btnOptions.Tooltip

            local row = makeElementRow("Button", 36)
            Util.HoverBind(row, theme.CardHover, theme.Card)

            local btn = Util.Create("TextButton", {
                Name = "Btn",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = theme.Font,
                Text = "",
                AutoButtonColor = false,
                Parent = row,
            })

            local btnLabel = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -56, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(1, -32, 0, 0),
                Font = theme.FontBold,
                Text = "→",
                TextSize = 14,
                TextColor3 = theme.Accent,
                Parent = btn,
            })

            btn.MouseButton1Click:Connect(function()
                Util.Ripple(row, theme)
                Util.TweenFast(row, { BackgroundColor3 = theme.AccentDark })
                task.delay(0.15, function()
                    Util.TweenFast(row, { BackgroundColor3 = theme.Card })
                end)
                callback()
            end)

            if tip then TooltipModule.Bind(row, tip) end

            local btnAPI = {}
            function btnAPI:SetText(t) btnLabel.Text = t end
            return Util.AddVisibility(btnAPI, row)
        end

        function tabObj:CreateToggle(tglOptions)
            tglOptions = tglOptions or {}
            local text     = tglOptions.Text or "Toggle"
            local default  = tglOptions.Default or false
            local callback = tglOptions.Callback or function() end
            local flag     = tglOptions.Flag
            local tip      = tglOptions.Tooltip

            local row = makeElementRow("Toggle", 36)
            Util.HoverBind(row, theme.CardHover, theme.Card)

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local track = Util.Create("Frame", {
                Name = "Track",
                BackgroundColor3 = theme.SurfaceAlt,
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                Parent = row,
            })
            Util.Corner(track, UDim.new(1, 0))
            Util.Stroke(track, theme.Border, 1, 0.7)

            local knob = Util.Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = theme.TextMuted,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 3, 0.5, -7),
                Parent = track,
            })
            Util.Corner(knob, UDim.new(1, 0))

            local state = default

            local function updateVisual(animate)
                if state then
                    if animate then
                        Util.TweenFast(track, { BackgroundColor3 = theme.Accent })
                        Util.TweenFast(knob, {
                            Position = UDim2.new(1, -17, 0.5, -7),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        })
                    else
                        track.BackgroundColor3 = theme.Accent
                        knob.Position = UDim2.new(1, -17, 0.5, -7)
                        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    end
                else
                    if animate then
                        Util.TweenFast(track, { BackgroundColor3 = theme.SurfaceAlt })
                        Util.TweenFast(knob, {
                            Position = UDim2.new(0, 3, 0.5, -7),
                            BackgroundColor3 = theme.TextMuted,
                        })
                    else
                        track.BackgroundColor3 = theme.SurfaceAlt
                        knob.Position = UDim2.new(0, 3, 0.5, -7)
                        knob.BackgroundColor3 = theme.TextMuted
                    end
                end
            end

            updateVisual(false)

            local clickBtn = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = row,
            })

            clickBtn.MouseButton1Click:Connect(function()
                state = not state
                updateVisual(true)
                if flag then ConfigModule.SetFlag(flag, state) end
                callback(state)
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, state) end

            local tglAPI = {}
            function tglAPI:SetValue(val)
                state = val
                updateVisual(true)
                if flag then ConfigModule.SetFlag(flag, state) end
                callback(state)
            end
            function tglAPI:GetValue() return state end
            return Util.AddVisibility(tglAPI, row)
        end

        function tabObj:CreateSlider(sliderOptions)
            sliderOptions = sliderOptions or {}
            local text      = sliderOptions.Text or "Slider"
            local min       = sliderOptions.Min or 0
            local max       = sliderOptions.Max or 100
            local default   = sliderOptions.Default or min
            local increment = sliderOptions.Increment or 1
            local callback  = sliderOptions.Callback or function() end
            local flag      = sliderOptions.Flag
            local suffix    = sliderOptions.Suffix or ""
            local tip       = sliderOptions.Tooltip

            local row = makeElementRow("Slider", 54)
            row.ClipsDescendants = true

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 12, 0, 6),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local valueLabel = Util.Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 58, 0, 20),
                Position = UDim2.new(1, -62, 0, 6),
                Font = theme.FontBold,
                Text = tostring(default) .. suffix,
                TextSize = 12,
                TextColor3 = theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            local sliderTrack = Util.Create("Frame", {
                Name = "SliderTrack",
                BackgroundColor3 = theme.SurfaceAlt,
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 34),
                Parent = row,
            })
            Util.Corner(sliderTrack, UDim.new(1, 0))

            local fill = Util.Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(0, 0, 1, 0),
                BorderSizePixel = 0,
                Parent = sliderTrack,
            })
            Util.Corner(fill, UDim.new(1, 0))

            local sliderKnob = Util.Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 0, 0.5, 0),
                ZIndex = 2,
                Parent = sliderTrack,
            })
            Util.Corner(sliderKnob, UDim.new(1, 0))
            Util.Shadow(sliderKnob, 8, 0.6)

            local currentValue = default

            local function setValue(val, animate)
                val = math.clamp(val, min, max)
                val = math.floor((val - min) / increment + 0.5) * increment + min
                val = math.clamp(val, min, max)
                currentValue = val
                local pct = if (max - min) ~= 0 then (val - min) / (max - min) else 0

                if animate then
                    Util.TweenFast(fill, { Size = UDim2.new(pct, 0, 1, 0) })
                    Util.TweenFast(sliderKnob, { Position = UDim2.new(pct, 0, 0.5, 0) })
                else
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
                end

                valueLabel.Text = tostring(val) .. suffix
                if flag then ConfigModule.SetFlag(flag, val) end
                callback(val)
            end

            setValue(default, false)

            local sliding = false

            local function inputUpdate(input)
                local trackPos   = sliderTrack.AbsolutePosition.X
                local trackWidth = sliderTrack.AbsoluteSize.X
                if trackWidth == 0 then return end
                local relative = math.clamp((input.Position.X - trackPos) / trackWidth, 0, 1)
                local val = min + (max - min) * relative
                setValue(val, false)
            end

            local slideBtn = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 24),
                Text = "",
                Parent = row,
            })

            slideBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    inputUpdate(input)
                end
            end)

            slideBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    inputUpdate(input)
                end
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, currentValue) end

            local sliderAPI = {}
            function sliderAPI:SetValue(val) setValue(val, true) end
            function sliderAPI:GetValue() return currentValue end
            return Util.AddVisibility(sliderAPI, row)
        end

        function tabObj:CreateDropdown(ddOptions)
            ddOptions = ddOptions or {}
            local text     = ddOptions.Text or "Dropdown"
            local items    = ddOptions.Items or {}
            local default  = ddOptions.Default
            local multi    = ddOptions.MultiSelect or false
            local callback = ddOptions.Callback or function() end
            local flag     = ddOptions.Flag
            local tip      = ddOptions.Tooltip

            local expanded = false
            local selected = multi and {} or default
            if multi and default then
                for _, v in ipairs(default) do selected[v] = true end
            end

            local row = Util.Create("Frame", {
                Name = "Dropdown",
                BackgroundColor3 = theme.Card,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true,
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            Util.Corner(row, theme.CornerRadiusSmall)
            Util.Stroke(row, theme.Border, 1, 0.8)
            table.insert(tabObj._elements, row)

            local header = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                AutoButtonColor = false,
                Parent = row,
            })

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            local selectedLabel = Util.Create("TextLabel", {
                Name = "Selected",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, -30, 1, 0),
                Position = UDim2.new(0.55, 0, 0, 0),
                Font = theme.FontLight,
                Text = multi and "None" or (default or "Select"),
                TextSize = 12,
                TextColor3 = theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = header,
            })

            local chevron = Util.Create("TextLabel", {
                Name = "Chevron",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                Font = theme.Font,
                Text = "▾",
                TextSize = 14,
                TextColor3 = theme.TextMuted,
                Parent = header,
            })

            local itemsContainer = Util.Create("Frame", {
                Name = "Items",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = row,
            })
            Util.ListLayout(itemsContainer, 2, nil, Enum.HorizontalAlignment.Center)
            Util.Padding(itemsContainer, 4, 6, 6, 6)

            local function getDisplayText()
                if multi then
                    local sel = {}
                    for k, v in pairs(selected) do
                        if v then table.insert(sel, k) end
                    end
                    return #sel > 0 and table.concat(sel, ", ") or "None"
                else
                    return selected or "Select"
                end
            end

            local function refreshItems()
                for _, child in ipairs(itemsContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                for i, item in ipairs(items) do
                    local isSelected = multi and selected[item] or (selected == item)
                    local itemBtn = Util.Create("TextButton", {
                        Name = item,
                        BackgroundColor3 = isSelected and theme.AccentDark or theme.SurfaceAlt,
                        BackgroundTransparency = isSelected and 0.6 or 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = theme.Font,
                        Text = item,
                        TextSize = 12,
                        TextColor3 = isSelected and theme.Accent or theme.TextSecondary,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        Parent = itemsContainer,
                    })
                    Util.Corner(itemBtn, theme.CornerRadiusSmall)

                    itemBtn.MouseEnter:Connect(function()
                        Util.TweenFast(itemBtn, {
                            BackgroundColor3 = theme.CardHover,
                            TextColor3 = theme.TextPrimary,
                        })
                    end)
                    itemBtn.MouseLeave:Connect(function()
                        local sel = multi and selected[item] or (selected == item)
                        Util.TweenFast(itemBtn, {
                            BackgroundColor3 = sel and theme.AccentDark or theme.SurfaceAlt,
                            TextColor3 = sel and theme.Accent or theme.TextSecondary,
                        })
                    end)

                    itemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[item] = not selected[item]
                        else
                            selected = item
                        end
                        selectedLabel.Text = getDisplayText()
                        if flag then ConfigModule.SetFlag(flag, selected) end
                        callback(multi and selected or selected)
                        refreshItems()
                        if not multi then
                            expanded = false
                            Util.Tween(row, { Size = UDim2.new(1, 0, 0, 38) }, 0.2)
                            Util.Tween(chevron, { Rotation = 0 }, 0.2)
                        end
                    end)
                end
            end

            refreshItems()

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    local itemCount = #items
                    local targetH = 38 + 8 + itemCount * 30 + 6
                    Util.Tween(row, { Size = UDim2.new(1, 0, 0, targetH) }, 0.25,
                        Enum.EasingStyle.Back)
                    Util.Tween(chevron, { Rotation = 180 }, 0.2)
                else
                    Util.Tween(row, { Size = UDim2.new(1, 0, 0, 38) }, 0.2)
                    Util.Tween(chevron, { Rotation = 0 }, 0.2)
                end
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, selected) end

            local ddAPI = {}
            function ddAPI:SetItems(newItems) items = newItems; refreshItems() end
            function ddAPI:SetValue(val)
                selected = val
                selectedLabel.Text = getDisplayText()
                refreshItems()
                if flag then ConfigModule.SetFlag(flag, selected) end
                callback(selected)
            end
            function ddAPI:GetValue() return selected end
            return Util.AddVisibility(ddAPI, row)
        end

        function tabObj:CreateKeybind(kbOptions)
            kbOptions = kbOptions or {}
            local text     = kbOptions.Text or "Keybind"
            local default  = kbOptions.Default or Enum.KeyCode.Unknown
            local callback = kbOptions.Callback or function() end
            local flag     = kbOptions.Flag
            local tip      = kbOptions.Tooltip

            local currentKey = default
            local listening  = false

            local row = makeElementRow("Keybind", 36)
            Util.HoverBind(row, theme.CardHover, theme.Card)

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local keyBtn = Util.Create("TextButton", {
                Name = "KeyBtn",
                BackgroundColor3 = theme.SurfaceAlt,
                Size = UDim2.new(0, 60, 0, 24),
                Position = UDim2.new(1, -70, 0.5, -12),
                Font = theme.Font,
                Text = default.Name or "None",
                TextSize = 11,
                TextColor3 = theme.Accent,
                AutoButtonColor = false,
                Parent = row,
            })
            Util.Corner(keyBtn, theme.CornerRadiusSmall)
            Util.Stroke(keyBtn, theme.Border, 1, 0.7)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                Util.TweenFast(keyBtn, { BackgroundColor3 = theme.AccentDark })
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if not listening then
                    if input.KeyCode == currentKey and not processed then
                        callback(currentKey)
                    end
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = input.KeyCode.Name
                    listening = false
                    Util.TweenFast(keyBtn, { BackgroundColor3 = theme.SurfaceAlt })
                    if flag then ConfigModule.SetFlag(flag, currentKey.Name) end
                end
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, currentKey.Name) end

            local kbAPI = {}
            function kbAPI:SetKey(key)
                currentKey = key
                keyBtn.Text = key.Name
                if flag then ConfigModule.SetFlag(flag, key.Name) end
            end
            function kbAPI:GetKey() return currentKey end
            return Util.AddVisibility(kbAPI, row)
        end

        function tabObj:CreateTextBox(tbOptions)
            tbOptions = tbOptions or {}
            local text         = tbOptions.Text or "Input"
            local placeholder  = tbOptions.Placeholder or "Type here..."
            local default      = tbOptions.Default or ""
            local callback     = tbOptions.Callback or function() end
            local flag         = tbOptions.Flag
            local clearOnFocus = tbOptions.ClearOnFocus
            if clearOnFocus == nil then clearOnFocus = false end
            local tip = tbOptions.Tooltip

            local row = makeElementRow("TextBox", 36)

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.45, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local inputFrame = Util.Create("Frame", {
                BackgroundColor3 = theme.SurfaceAlt,
                Size = UDim2.new(0.52, -12, 0, 26),
                Position = UDim2.new(0.48, 0, 0.5, -13),
                Parent = row,
            })
            Util.Corner(inputFrame, theme.CornerRadiusSmall)
            Util.Stroke(inputFrame, theme.Border, 1, 0.7)

            local textBox = Util.Create("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                Font = theme.FontLight,
                PlaceholderText = placeholder,
                PlaceholderColor3 = theme.TextMuted,
                Text = default,
                TextSize = 12,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = clearOnFocus,
                Parent = inputFrame,
            })

            textBox.Focused:Connect(function()
                Util.TweenFast(inputFrame, { BackgroundColor3 = theme.Card })
                local stroke = inputFrame:FindFirstChildWhichIsA("UIStroke")
                if stroke then Util.TweenFast(stroke, { Color = theme.Accent, Transparency = 0.3 }) end
            end)

            textBox.FocusLost:Connect(function(enterPressed)
                Util.TweenFast(inputFrame, { BackgroundColor3 = theme.SurfaceAlt })
                local stroke = inputFrame:FindFirstChildWhichIsA("UIStroke")
                if stroke then Util.TweenFast(stroke, { Color = theme.Border, Transparency = 0.7 }) end
                if flag then ConfigModule.SetFlag(flag, textBox.Text) end
                callback(textBox.Text, enterPressed)
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, default) end

            local tbAPI = {}
            function tbAPI:SetValue(val) textBox.Text = val; if flag then ConfigModule.SetFlag(flag, val) end end
            function tbAPI:GetValue() return textBox.Text end
            return Util.AddVisibility(tbAPI, row)
        end

        function tabObj:CreateProgressBar(pbOptions)
            pbOptions = pbOptions or {}
            local text    = pbOptions.Text or "Progress"
            local default = pbOptions.Default or 0
            local tip     = pbOptions.Tooltip

            local row = makeElementRow("ProgressBar", 48)

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.new(0, 12, 0, 4),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local pctLabel = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 48, 0, 18),
                Position = UDim2.new(1, -56, 0, 4),
                Font = theme.FontBold,
                Text = tostring(math.floor(default * 100)) .. "%",
                TextSize = 12,
                TextColor3 = theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            local barBg = Util.Create("Frame", {
                BackgroundColor3 = theme.SurfaceAlt,
                Size = UDim2.new(1, -24, 0, 8),
                Position = UDim2.new(0, 12, 0, 28),
                Parent = row,
            })
            Util.Corner(barBg, UDim.new(1, 0))

            local barFill = Util.Create("Frame", {
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(math.clamp(default, 0, 1), 0, 1, 0),
                BorderSizePixel = 0,
                Parent = barBg,
            })
            Util.Corner(barFill, UDim.new(1, 0))

            if tip then TooltipModule.Bind(row, tip) end

            local pbAPI = {}
            function pbAPI:SetValue(pct)
                pct = math.clamp(pct, 0, 1)
                pctLabel.Text = tostring(math.floor(pct * 100)) .. "%"
                Util.TweenFast(barFill, { Size = UDim2.new(pct, 0, 1, 0) })
            end
            function pbAPI:SetText(t)
                row:FindFirstChild("TextLabel")
                for _, c in ipairs(row:GetChildren()) do
                    if c:IsA("TextLabel") and c ~= pctLabel then
                        c.Text = t
                        break
                    end
                end
            end
            return Util.AddVisibility(pbAPI, row)
        end

        function tabObj:CreateColorPicker(cpOptions)
            cpOptions = cpOptions or {}
            local text     = cpOptions.Text or "Color"
            local default  = cpOptions.Default or Color3.fromRGB(255, 255, 255)
            local callback = cpOptions.Callback or function() end
            local flag     = cpOptions.Flag
            local tip      = cpOptions.Tooltip

            local expanded = false
            local currentColor = default
            local h, s, v = default:ToHSV()

            local row = Util.Create("Frame", {
                Name = "ColorPicker",
                BackgroundColor3 = theme.Card,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = true,
                LayoutOrder = #tabObj._elements + 1,
                Parent = tabContent,
            })
            Util.Corner(row, theme.CornerRadiusSmall)
            Util.Stroke(row, theme.Border, 1, 0.8)
            table.insert(tabObj._elements, row)

            local cpHeader = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                AutoButtonColor = false,
                Parent = row,
            })

            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = theme.Font,
                Text = text,
                TextSize = 13,
                TextColor3 = theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cpHeader,
            })

            local preview = Util.Create("Frame", {
                Name = "Preview",
                BackgroundColor3 = currentColor,
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(1, -36, 0.5, -11),
                Parent = cpHeader,
            })
            Util.Corner(preview, UDim.new(1, 0))
            Util.Stroke(preview, theme.Border, 1, 0.5)

            local pickerBody = Util.Create("Frame", {
                Name = "PickerBody",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 90),
                Parent = row,
            })
            Util.Padding(pickerBody, 6, 12, 8, 12)

            local hueTrack = Util.Create("Frame", {
                Name = "HueTrack",
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 12, 0, 44),
                Parent = row,
            })
            Util.Corner(hueTrack, UDim.new(1, 0))
            Util.Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                }),
                Parent = hueTrack,
            })

            local hueKnob = Util.Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(h, 0, 0.5, 0),
                ZIndex = 3,
                Parent = hueTrack,
            })
            Util.Corner(hueKnob, UDim.new(1, 0))

            local satTrack = Util.Create("Frame", {
                Name = "SatTrack",
                BackgroundColor3 = Color3.fromHSV(h, 1, v),
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 12, 0, 66),
                Parent = row,
            })
            Util.Corner(satTrack, UDim.new(1, 0))
            Util.Create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromHSV(h, 1, 1)),
                Parent = satTrack,
            })

            local satKnob = Util.Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(s, 0, 0.5, 0),
                ZIndex = 3,
                Parent = satTrack,
            })
            Util.Corner(satKnob, UDim.new(1, 0))

            local valTrack = Util.Create("Frame", {
                Name = "ValTrack",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 12, 0, 88),
                Parent = row,
            })
            Util.Corner(valTrack, UDim.new(1, 0))
            Util.Create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, s, 1)),
                Parent = valTrack,
            })

            local valKnob = Util.Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(v, 0, 0.5, 0),
                ZIndex = 3,
                Parent = valTrack,
            })
            Util.Corner(valKnob, UDim.new(1, 0))

            local function updateColor()
                currentColor = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = currentColor
                if flag then ConfigModule.SetFlag(flag, currentColor) end
                callback(currentColor)
            end

            local slidingHue, slidingSat, slidingVal = false, false, false

            local function makeSliderInteraction(track, knobInst, setter)
                local isSliding = false
                local hitArea = Util.Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 8, 1, 8),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, -4, 0.5, 0),
                    Text = "",
                    ZIndex = 4,
                    Parent = track,
                })

                hitArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        isSliding = true
                        local rel = math.clamp(
                            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                            0, 1
                        )
                        knobInst.Position = UDim2.new(rel, 0, 0.5, 0)
                        setter(rel)
                        updateColor()
                    end
                end)

                hitArea.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        isSliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp(
                            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                            0, 1
                        )
                        knobInst.Position = UDim2.new(rel, 0, 0.5, 0)
                        setter(rel)
                        updateColor()
                    end
                end)
            end

            makeSliderInteraction(hueTrack, hueKnob, function(val) h = val end)
            makeSliderInteraction(satTrack, satKnob, function(val) s = val end)
            makeSliderInteraction(valTrack, valKnob, function(val) v = val end)

            cpHeader.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    Util.Tween(row, { Size = UDim2.new(1, 0, 0, 114) }, 0.25,
                        Enum.EasingStyle.Back)
                else
                    Util.Tween(row, { Size = UDim2.new(1, 0, 0, 38) }, 0.2)
                end
            end)

            if tip then TooltipModule.Bind(row, tip) end
            if flag then ConfigModule.SetFlag(flag, currentColor) end

            local cpAPI = {}
            function cpAPI:SetValue(color)
                currentColor = color
                h, s, v = color:ToHSV()
                hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
                satKnob.Position = UDim2.new(s, 0, 0.5, 0)
                valKnob.Position = UDim2.new(v, 0, 0.5, 0)
                preview.BackgroundColor3 = color
                if flag then ConfigModule.SetFlag(flag, color) end
                callback(color)
            end
            function cpAPI:GetValue() return currentColor end
            return Util.AddVisibility(cpAPI, row)
        end

        return tabObj
    end

    function Window:Notify(options)
        NotificationModule.Send(options)
    end

    function Window:SaveConfig(name)  ConfigModule.Save(name) end
    function Window:LoadConfig(name)  return ConfigModule.Load(name) end
    function Window:GetFlag(flag)     return ConfigModule.GetFlag(flag) end

    function Window:Destroy()
        BlurModule.Destroy()
        screenGui:Destroy()
    end

    return Window
end

return SereneUI
