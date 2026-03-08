local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/refs/heads/main/serenelib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 250,
        Smoothness = 5,
        TargetPart = "Head",
        ShowFOV = true,
        AimKey = Enum.KeyCode.Q,
        SilentAim = false,
    },
    Hitbox = {
        Enabled = false,
        Size = 5,
        Transparency = 0.5,
        Visible = false,
    },
    Movement = {
        Speed = false,
        SpeedValue = 16,
        Fly = false,
        FlySpeed = 50,
        InfiniteJump = false,
        Noclip = false,
        AutoParkour = false,
    },
    Visuals = {
        ESP = false,
        ESPColor = Color3.fromRGB(65, 130, 255),
        BoxESP = false,
        NameESP = false,
        HealthBar = false,
        Tracers = false,
        TracerOrigin = "Bottom",
        Distance = false,
        MaxDistance = 1500,
        Chams = false,
        ChamsColor = Color3.fromRGB(65, 130, 255),
        ChamsFillTransparency = 0.6,
        ChamsOutlineTransparency = 0,
    },
}

local Window = SereneUI:CreateWindow({
    Title = "Serene Hub",
    Subtitle = "Universal",
    Size = UDim2.new(0, 600, 0, 430),
    AccentColor = Color3.fromRGB(65, 130, 255),
    ToggleKey = Enum.KeyCode.RightShift,
    BackgroundBlur = true,
    UIScale = 1,
    ConfigName = "SereneHub",
    Theme = {
        Background = Color3.fromRGB(12, 12, 20),
        Surface = Color3.fromRGB(16, 16, 26),
        SurfaceAlt = Color3.fromRGB(22, 22, 34),
        Card = Color3.fromRGB(26, 26, 40),
        CardHover = Color3.fromRGB(34, 34, 52),
        Border = Color3.fromRGB(40, 44, 70),
    },
})

local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
    local hum = GetHumanoid(player)
    return hum and hum.Health > 0
end

local function IsTeammate(player)
    if not Settings.Aimbot.TeamCheck then return false end
    if not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function GetClosestPlayerToCursor(fov, part)
    local closest = nil
    local shortestDist = fov

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not IsTeammate(player) then
            local char = GetCharacter(player)
            local targetPart = char and char:FindFirstChild(part)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = targetPart
                    end
                end
            end
        end
    end

    return closest
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(65, 130, 255)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
end)

local aiming = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Aimbot.AimKey then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.Aimbot.AimKey then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and aiming then
        local target = GetClosestPlayerToCursor(Settings.Aimbot.FOV, Settings.Aimbot.TargetPart)
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local diff = Vector2.new(targetPos.X, targetPos.Y) - mousePos
            local smooth = Settings.Aimbot.Smoothness
            mousemoverel(diff.X / smooth, diff.Y / smooth)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsAlive(player) and not IsTeammate(player) then
                local char = GetCharacter(player)
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                    root.Transparency = Settings.Hitbox.Visible and Settings.Hitbox.Transparency or 1
                    root.CanCollide = false
                    root.Material = Enum.Material.Neon
                    root.Color = Color3.fromRGB(65, 130, 255)
                end
            end
        end
    end
end)

local flyActive = false
local flyBody = nil

local function StartFly()
    local char = GetCharacter(LocalPlayer)
    local root = GetRootPart(LocalPlayer)
    if not char or not root then return end

    local hum = GetHumanoid(LocalPlayer)
    if hum then hum.PlatformStand = true end

    flyBody = Instance.new("BodyVelocity")
    flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBody.Velocity = Vector3.new(0, 0, 0)
    flyBody.Parent = root

    local gyro = Instance.new("BodyGyro")
    gyro.Name = "FlyGyro"
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 9000
    gyro.Parent = root

    flyActive = true
end

local function StopFly()
    local char = GetCharacter(LocalPlayer)
    local root = GetRootPart(LocalPlayer)
    if root then
        local bv = root:FindFirstChildOfClass("BodyVelocity")
        local bg = root:FindFirstChild("FlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    local hum = GetHumanoid(LocalPlayer)
    if hum then hum.PlatformStand = false end
    flyBody = nil
    flyActive = false
end

RunService.RenderStepped:Connect(function()
    if flyActive and flyBody then
        local root = GetRootPart(LocalPlayer)
        if not root then StopFly(); return end

        local dir = Vector3.new(0, 0, 0)
        local camCF = Camera.CFrame
        local speed = Settings.Movement.FlySpeed

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit * speed
        end

        flyBody.Velocity = dir

        local gyro = root:FindFirstChild("FlyGyro")
        if gyro then
            gyro.CFrame = camCF
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump then
        local hum = GetHumanoid(LocalPlayer)
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Movement.Noclip then
        local char = GetCharacter(LocalPlayer)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.Speed then
        local hum = GetHumanoid(LocalPlayer)
        if hum then
            hum.WalkSpeed = Settings.Movement.SpeedValue
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AutoParkour then
        local hum = GetHumanoid(LocalPlayer)
        local root = GetRootPart(LocalPlayer)
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local rayOrigin = root.Position + Vector3.new(0, -1, 0)
            local rayDir = hum.MoveDirection * 4
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { GetCharacter(LocalPlayer) }

            local result = Workspace:Raycast(rayOrigin, rayDir, params)
            if result and result.Instance then
                local wallHeight = result.Instance.Position.Y + result.Instance.Size.Y / 2
                local playerY = root.Position.Y
                local diff = wallHeight - playerY

                if diff > 0 and diff < 12 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(0.1)
                    if root and root.Parent then
                        root.Velocity = Vector3.new(root.Velocity.X, math.clamp(diff * 12, 30, 80), root.Velocity.Z)
                    end
                end
            end
        end
    end
end)

local espObjects = {}

local function ClearESP()
    for _, data in pairs(espObjects) do
        for key, obj in pairs(data) do
            pcall(function()
                if typeof(obj) == "Instance" then
                    obj:Destroy()
                else
                    obj:Remove()
                end
            end)
        end
    end
    espObjects = {}
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end

    espObjects[player] = {}
    local data = espObjects[player]

    data.BoxOutline = Drawing.new("Square")
    data.BoxOutline.Thickness = 1
    data.BoxOutline.Filled = false
    data.BoxOutline.Color = Settings.Visuals.ESPColor
    data.BoxOutline.Visible = false
    data.BoxOutline.ZIndex = 5

    data.NameTag = Drawing.new("Text")
    data.NameTag.Size = 13
    data.NameTag.Center = true
    data.NameTag.Outline = true
    data.NameTag.Color = Color3.fromRGB(255, 255, 255)
    data.NameTag.Visible = false
    data.NameTag.ZIndex = 6

    data.DistTag = Drawing.new("Text")
    data.DistTag.Size = 11
    data.DistTag.Center = true
    data.DistTag.Outline = true
    data.DistTag.Color = Color3.fromRGB(200, 200, 200)
    data.DistTag.Visible = false
    data.DistTag.ZIndex = 6

    data.Tracer = Drawing.new("Line")
    data.Tracer.Thickness = 1
    data.Tracer.Color = Settings.Visuals.ESPColor
    data.Tracer.Visible = false
    data.Tracer.ZIndex = 4

    data.HealthBG = Drawing.new("Line")
    data.HealthBG.Thickness = 3
    data.HealthBG.Color = Color3.fromRGB(30, 30, 30)
    data.HealthBG.Visible = false
    data.HealthBG.ZIndex = 5

    data.HealthBar = Drawing.new("Line")
    data.HealthBar.Thickness = 2
    data.HealthBar.Color = Color3.fromRGB(80, 255, 80)
    data.HealthBar.Visible = false
    data.HealthBar.ZIndex = 6

    data.Highlight = Instance.new("Highlight")
    data.Highlight.Name = "SereneChams"
    data.Highlight.FillColor = Settings.Visuals.ChamsColor
    data.Highlight.OutlineColor = Settings.Visuals.ChamsColor
    data.Highlight.FillTransparency = Settings.Visuals.ChamsFillTransparency
    data.Highlight.OutlineTransparency = Settings.Visuals.ChamsOutlineTransparency
    data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function UpdateESP()
    for player, data in pairs(espObjects) do
        local char = GetCharacter(player)
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local localRoot = GetRootPart(LocalPlayer)

        local alive = IsAlive(player) and root and head and localRoot

        if not alive or (Settings.Aimbot.TeamCheck and IsTeammate(player)) then
            if data.BoxOutline then data.BoxOutline.Visible = false end
            if data.NameTag then data.NameTag.Visible = false end
            if data.DistTag then data.DistTag.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
            if data.HealthBG then data.HealthBG.Visible = false end
            if data.HealthBar then data.HealthBar.Visible = false end
            if data.Highlight then data.Highlight.Parent = nil end
            continue
        end

        local dist = (localRoot.Position - root.Position).Magnitude
        if dist > Settings.Visuals.MaxDistance then
            if data.BoxOutline then data.BoxOutline.Visible = false end
            if data.NameTag then data.NameTag.Visible = false end
            if data.DistTag then data.DistTag.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
            if data.HealthBG then data.HealthBG.Visible = false end
            if data.HealthBar then data.HealthBar.Visible = false end
            if data.Highlight then data.Highlight.Parent = nil end
            continue
        end

        local rootScreen, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

        if rootOnScreen then
            local boxH = math.abs(headScreen.Y - legScreen.Y)
            local boxW = boxH * 0.55

            if data.BoxOutline and Settings.Visuals.BoxESP then
                data.BoxOutline.Size = Vector2.new(boxW, boxH)
                data.BoxOutline.Position = Vector2.new(rootScreen.X - boxW / 2, headScreen.Y)
                data.BoxOutline.Color = Settings.Visuals.ESPColor
                data.BoxOutline.Visible = true
            elseif data.BoxOutline then
                data.BoxOutline.Visible = false
            end

            if data.NameTag and Settings.Visuals.NameESP then
                data.NameTag.Text = player.DisplayName
                data.NameTag.Position = Vector2.new(rootScreen.X, headScreen.Y - 16)
                data.NameTag.Visible = true
            elseif data.NameTag then
                data.NameTag.Visible = false
            end

            if data.DistTag and Settings.Visuals.Distance then
                data.DistTag.Text = math.floor(dist) .. "m"
                data.DistTag.Position = Vector2.new(rootScreen.X, legScreen.Y + 4)
                data.DistTag.Visible = true
            elseif data.DistTag then
                data.DistTag.Visible = false
            end

            if data.Tracer and Settings.Visuals.Tracers then
                local viewSize = Camera.ViewportSize
                local fromPos = Vector2.new(viewSize.X / 2, viewSize.Y)
                if Settings.Visuals.TracerOrigin == "Center" then
                    fromPos = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                elseif Settings.Visuals.TracerOrigin == "Mouse" then
                    fromPos = UserInputService:GetMouseLocation()
                end
                data.Tracer.From = fromPos
                data.Tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
                data.Tracer.Color = Settings.Visuals.ESPColor
                data.Tracer.Visible = true
            elseif data.Tracer then
                data.Tracer.Visible = false
            end

            if data.HealthBG and data.HealthBar and Settings.Visuals.HealthBar and hum then
                local barX = rootScreen.X - boxW / 2 - 6
                local barTop = headScreen.Y
                local barBot = legScreen.Y
                data.HealthBG.From = Vector2.new(barX, barTop)
                data.HealthBG.To = Vector2.new(barX, barBot)
                data.HealthBG.Visible = true

                local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barFillBot = barBot - (barBot - barTop) * healthPct
                data.HealthBar.From = Vector2.new(barX, barBot)
                data.HealthBar.To = Vector2.new(barX, barFillBot)
                data.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                data.HealthBar.Visible = true
            else
                if data.HealthBG then data.HealthBG.Visible = false end
                if data.HealthBar then data.HealthBar.Visible = false end
            end
        else
            if data.BoxOutline then data.BoxOutline.Visible = false end
            if data.NameTag then data.NameTag.Visible = false end
            if data.DistTag then data.DistTag.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
            if data.HealthBG then data.HealthBG.Visible = false end
            if data.HealthBar then data.HealthBar.Visible = false end
        end

        if data.Highlight and Settings.Visuals.Chams then
            data.Highlight.FillColor = Settings.Visuals.ChamsColor
            data.Highlight.OutlineColor = Settings.Visuals.ChamsColor
            data.Highlight.FillTransparency = Settings.Visuals.ChamsFillTransparency
            data.Highlight.OutlineTransparency = Settings.Visuals.ChamsOutlineTransparency
            data.Highlight.Parent = char
        elseif data.Highlight then
            data.Highlight.Parent = nil
        end
    end
end

local function RefreshAllESP()
    ClearESP()
    if Settings.Visuals.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            CreateESPForPlayer(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if Settings.Visuals.ESP then
        CreateESPForPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            pcall(function()
                if typeof(obj) == "Instance" then
                    obj:Destroy()
                else
                    obj:Remove()
                end
            end)
        end
        espObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Visuals.ESP then
        UpdateESP()
    end
end)

local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚔" })

CombatTab:CreateSection({ Name = "Aimbot" })

CombatTab:CreateToggle({
    Text = "Enable Aimbot",
    Default = false,
    Flag = "AimbotEnabled",
    Tooltip = "Locks aim to closest player in FOV",
    Callback = function(state)
        Settings.Aimbot.Enabled = state
    end,
})

CombatTab:CreateSlider({
    Text = "FOV Radius",
    Min = 50,
    Max = 800,
    Default = 250,
    Increment = 10,
    Suffix = "px",
    Flag = "AimbotFOV",
    Callback = function(val)
        Settings.Aimbot.FOV = val
    end,
})

CombatTab:CreateSlider({
    Text = "Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Increment = 1,
    Flag = "AimbotSmooth",
    Tooltip = "Lower = snappier, higher = smoother",
    Callback = function(val)
        Settings.Aimbot.Smoothness = val
    end,
})

CombatTab:CreateDropdown({
    Text = "Target Part",
    Items = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Flag = "AimbotPart",
    Callback = function(selected)
        Settings.Aimbot.TargetPart = selected
    end,
})

CombatTab:CreateKeybind({
    Text = "Aim Key",
    Default = Enum.KeyCode.Q,
    Flag = "AimKey",
    Callback = function(key)
        Settings.Aimbot.AimKey = key
    end,
})

CombatTab:CreateToggle({
    Text = "Show FOV Circle",
    Default = true,
    Flag = "ShowFOV",
    Callback = function(state)
        Settings.Aimbot.ShowFOV = state
    end,
})

CombatTab:CreateToggle({
    Text = "Team Check",
    Default = false,
    Flag = "TeamCheck",
    Tooltip = "Skip teammates when aiming",
    Callback = function(state)
        Settings.Aimbot.TeamCheck = state
    end,
})

CombatTab:CreateDivider()
CombatTab:CreateSection({ Name = "Hitbox Expander" })

CombatTab:CreateToggle({
    Text = "Hitbox Expander",
    Default = false,
    Flag = "HitboxEnabled",
    Callback = function(state)
        Settings.Hitbox.Enabled = state
        if not state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = GetCharacter(player)
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                    end
                end
            end
        end
    end,
})

CombatTab:CreateSlider({
    Text = "Hitbox Size",
    Min = 2,
    Max = 20,
    Default = 5,
    Increment = 1,
    Suffix = "",
    Flag = "HitboxSize",
    Callback = function(val)
        Settings.Hitbox.Size = val
    end,
})

CombatTab:CreateToggle({
    Text = "Show Hitboxes",
    Default = false,
    Flag = "HitboxVisible",
    Callback = function(state)
        Settings.Hitbox.Visible = state
    end,
})

local MoveTab = Window:CreateTab({ Name = "Movement", Icon = "🏃" })

MoveTab:CreateSection({ Name = "Speed" })

MoveTab:CreateToggle({
    Text = "Speed Hack",
    Default = false,
    Flag = "SpeedEnabled",
    Callback = function(state)
        Settings.Movement.Speed = state
        if not state then
            local hum = GetHumanoid(LocalPlayer)
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

MoveTab:CreateSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Increment = 1,
    Flag = "SpeedValue",
    Callback = function(val)
        Settings.Movement.SpeedValue = val
    end,
})

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Flight" })

MoveTab:CreateToggle({
    Text = "Fly",
    Default = false,
    Flag = "FlyEnabled",
    Tooltip = "WASD to move, Space/Shift for up/down",
    Callback = function(state)
        Settings.Movement.Fly = state
        if state then
            StartFly()
        else
            StopFly()
        end
    end,
})

MoveTab:CreateSlider({
    Text = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    Flag = "FlySpeed",
    Callback = function(val)
        Settings.Movement.FlySpeed = val
    end,
})

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Misc Movement" })

MoveTab:CreateToggle({
    Text = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
    Callback = function(state)
        Settings.Movement.InfiniteJump = state
    end,
})

MoveTab:CreateToggle({
    Text = "Noclip",
    Default = false,
    Flag = "Noclip",
    Tooltip = "Walk through walls and objects",
    Callback = function(state)
        Settings.Movement.Noclip = state
        if not state then
            local char = GetCharacter(LocalPlayer)
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

MoveTab:CreateToggle({
    Text = "Auto Parkour",
    Default = false,
    Flag = "AutoParkour",
    Tooltip = "Automatically jumps over walls while moving",
    Callback = function(state)
        Settings.Movement.AutoParkour = state
    end,
})

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁" })

VisualsTab:CreateSection({ Name = "ESP Master" })

VisualsTab:CreateToggle({
    Text = "Enable ESP",
    Default = false,
    Flag = "ESPEnabled",
    Tooltip = "Master toggle for all ESP features",
    Callback = function(state)
        Settings.Visuals.ESP = state
        if state then
            RefreshAllESP()
        else
            ClearESP()
        end
    end,
})

VisualsTab:CreateSlider({
    Text = "Max Distance",
    Min = 100,
    Max = 5000,
    Default = 1500,
    Increment = 100,
    Suffix = "m",
    Flag = "ESPDistance",
    Callback = function(val)
        Settings.Visuals.MaxDistance = val
    end,
})

VisualsTab:CreateColorPicker({
    Text = "ESP Color",
    Default = Color3.fromRGB(65, 130, 255),
    Flag = "ESPColor",
    Callback = function(color)
        Settings.Visuals.ESPColor = color
        FOVCircle.Color = color
    end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "ESP Elements" })

VisualsTab:CreateToggle({
    Text = "Box ESP",
    Default = false,
    Flag = "BoxESP",
    Callback = function(state)
        Settings.Visuals.BoxESP = state
    end,
})

VisualsTab:CreateToggle({
    Text = "Name ESP",
    Default = false,
    Flag = "NameESP",
    Callback = function(state)
        Settings.Visuals.NameESP = state
    end,
})

VisualsTab:CreateToggle({
    Text = "Health Bars",
    Default = false,
    Flag = "HealthBar",
    Callback = function(state)
        Settings.Visuals.HealthBar = state
    end,
})

VisualsTab:CreateToggle({
    Text = "Tracers",
    Default = false,
    Flag = "Tracers",
    Callback = function(state)
        Settings.Visuals.Tracers = state
    end,
})

VisualsTab:CreateDropdown({
    Text = "Tracer Origin",
    Items = { "Bottom", "Center", "Mouse" },
    Default = "Bottom",
    Flag = "TracerOrigin",
    Callback = function(selected)
        Settings.Visuals.TracerOrigin = selected
    end,
})

VisualsTab:CreateToggle({
    Text = "Show Distance",
    Default = false,
    Flag = "ShowDistance",
    Callback = function(state)
        Settings.Visuals.Distance = state
    end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "Chams" })

VisualsTab:CreateToggle({
    Text = "Enable Chams",
    Default = false,
    Flag = "ChamsEnabled",
    Tooltip = "Highlight players through walls",
    Callback = function(state)
        Settings.Visuals.Chams = state
    end,
})

VisualsTab:CreateColorPicker({
    Text = "Chams Color",
    Default = Color3.fromRGB(65, 130, 255),
    Flag = "ChamsColor",
    Callback = function(color)
        Settings.Visuals.ChamsColor = color
    end,
})

VisualsTab:CreateSlider({
    Text = "Fill Transparency",
    Min = 0,
    Max = 1,
    Default = 0.6,
    Increment = 0.05,
    Flag = "ChamsFill",
    Callback = function(val)
        Settings.Visuals.ChamsFillTransparency = val
    end,
})

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "🔧" })

SettingsTab:CreateSection({ Name = "Configuration" })

SettingsTab:CreateButton({
    Text = "Save Config",
    Tooltip = "Save all current settings",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({
            Title = "Config Saved",
            Message = "All settings saved successfully.",
            Type = "success",
            Icon = "✓",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateButton({
    Text = "Load Config",
    Tooltip = "Load saved settings",
    Callback = function()
        local ok = Window:LoadConfig("default")
        Window:Notify({
            Title = ok and "Config Loaded" or "No Config",
            Message = ok and "Settings restored." or "No saved config found.",
            Type = ok and "success" or "warning",
            Icon = ok and "✓" or "!",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Cleanup" })

SettingsTab:CreateButton({
    Text = "Reset All Settings",
    Tooltip = "Disable everything and reset to defaults",
    Callback = function()
        Settings.Aimbot.Enabled = false
        Settings.Hitbox.Enabled = false
        Settings.Movement.Speed = false
        Settings.Movement.InfiniteJump = false
        Settings.Movement.Noclip = false
        Settings.Movement.AutoParkour = false
        if flyActive then StopFly() end
        Settings.Movement.Fly = false
        Settings.Visuals.ESP = false
        ClearESP()
        FOVCircle.Visible = false

        local hum = GetHumanoid(LocalPlayer)
        if hum then
            hum.WalkSpeed = 16
        end

        Window:Notify({
            Title = "Reset",
            Message = "All features disabled.",
            Type = "info",
            Icon = "↺",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Info" })

SettingsTab:CreateParagraph({
    Title = "Serene Hub — Universal",
    Content = "Built with SereneUI v1.1\n"
        .. "Toggle UI: RightShift\n"
        .. "Aim Key: Q (rebindable)\n\n"
        .. "Universal — works across most games.\n"
        .. "Some features may behave differently\n"
        .. "depending on the game's anti-cheat.",
})

SettingsTab:CreateLabel({ Text = "Serene Hub v1.0 — SereneUI v1.1" })

Window:Notify({
    Title = "Serene Hub Loaded",
    Message = "Universal hub ready. Press RightShift to toggle.",
    Type = "success",
    Icon = "✓",
    Duration = 5,
})
