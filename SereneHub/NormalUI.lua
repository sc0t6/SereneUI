local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/refs/heads/main/serenelib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local GuiInset = GuiService:GetGuiInset()

local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        FOV = 250,
        Smoothness = 5,
        TargetPart = "Head",
        ShowFOV = true,
        AimKey = Enum.KeyCode.Q,
        TriggerBot = false,
        TriggerDelay = 0.05,
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
        JumpPower = false,
        JumpPowerValue = 50,
        LongJump = false,
        LongJumpForce = 80,
        AntiVoid = false,
        SpinBot = false,
        SpinSpeed = 10,
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
        Fullbright = false,
        Crosshair = false,
        CrosshairSize = 12,
        CrosshairColor = Color3.fromRGB(65, 130, 255),
        CrosshairThickness = 1.5,
        AmbientColor = false,
        FogEnabled = false,
        FogEnd = 1000,
    },
    Misc = {
        AntiAFK = true,
        Gravity = 196.2,
        FPSCounter = false,
    },
}

local Window = SereneUI:CreateWindow({
    Title = "Serene Hub",
    Subtitle = "Universal",
    Size = UDim2.new(0, 620, 0, 440),
    AccentColor = Color3.fromRGB(65, 130, 255),
    ToggleKey = Enum.KeyCode.RightShift,
    BackgroundBlur = true,
    UIScale = 1,
    ConfigName = "SereneHub",
    Theme = {
        Background = Color3.fromRGB(10, 10, 18),
        Surface = Color3.fromRGB(14, 14, 24),
        SurfaceAlt = Color3.fromRGB(20, 20, 32),
        Card = Color3.fromRGB(24, 24, 38),
        CardHover = Color3.fromRGB(32, 32, 50),
        Border = Color3.fromRGB(38, 42, 68),
        Font = Enum.Font.GothamSemibold,
        FontBold = Enum.Font.GothamBold,
        FontLight = Enum.Font.GothamMedium,
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
FOVCircle.Visible = false
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
    if input.KeyCode == Settings.Aimbot.AimKey then aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.Aimbot.AimKey then aiming = false end
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

local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.TriggerBot and Settings.Aimbot.Enabled then
        local now = tick()
        if now - lastTrigger < Settings.Aimbot.TriggerDelay then return end
        local target = GetClosestPlayerToCursor(Settings.Aimbot.FOV, Settings.Aimbot.TargetPart)
        if target then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < 15 then
                    mouse1click()
                    lastTrigger = now
                end
            end
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
        if dir.Magnitude > 0 then dir = dir.Unit * speed end
        flyBody.Velocity = dir
        local gyro = root:FindFirstChild("FlyGyro")
        if gyro then gyro.CFrame = camCF end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump then
        local hum = GetHumanoid(LocalPlayer)
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    if Settings.Movement.LongJump then
        local hum = GetHumanoid(LocalPlayer)
        local root = GetRootPart(LocalPlayer)
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            task.defer(function()
                task.wait(0.05)
                if root and root.Parent then
                    root.Velocity = root.Velocity + hum.MoveDirection * Settings.Movement.LongJumpForce + Vector3.new(0, 20, 0)
                end
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Movement.Noclip then
        local char = GetCharacter(LocalPlayer)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.Speed then
        local hum = GetHumanoid(LocalPlayer)
        if hum then hum.WalkSpeed = Settings.Movement.SpeedValue end
    end
    if Settings.Movement.JumpPower then
        local hum = GetHumanoid(LocalPlayer)
        if hum then hum.JumpPower = Settings.Movement.JumpPowerValue end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AutoParkour then
        local hum = GetHumanoid(LocalPlayer)
        local root = GetRootPart(LocalPlayer)
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { GetCharacter(LocalPlayer) }
            local result = Workspace:Raycast(root.Position + Vector3.new(0, -1, 0), hum.MoveDirection * 4, params)
            if result and result.Instance then
                local diff = (result.Instance.Position.Y + result.Instance.Size.Y / 2) - root.Position.Y
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

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AntiVoid then
        local root = GetRootPart(LocalPlayer)
        if root and root.Position.Y < -50 then
            root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if Settings.Movement.SpinBot then
        local root = GetRootPart(LocalPlayer)
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.Movement.SpinSpeed * 60 * dt), 0)
        end
    end
end)

local crosshairLines = {}
for i = 1, 4 do
    local line = Drawing.new("Line")
    line.Thickness = Settings.Visuals.CrosshairThickness
    line.Color = Settings.Visuals.CrosshairColor
    line.Visible = false
    line.ZIndex = 998
    crosshairLines[i] = line
end

RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Crosshair then
        local center = UserInputService:GetMouseLocation()
        local sz = Settings.Visuals.CrosshairSize
        local gap = 4
        for i = 1, 4 do
            crosshairLines[i].Color = Settings.Visuals.CrosshairColor
            crosshairLines[i].Thickness = Settings.Visuals.CrosshairThickness
            crosshairLines[i].Visible = true
        end
        crosshairLines[1].From = Vector2.new(center.X - sz, center.Y)
        crosshairLines[1].To = Vector2.new(center.X - gap, center.Y)
        crosshairLines[2].From = Vector2.new(center.X + gap, center.Y)
        crosshairLines[2].To = Vector2.new(center.X + sz, center.Y)
        crosshairLines[3].From = Vector2.new(center.X, center.Y - sz)
        crosshairLines[3].To = Vector2.new(center.X, center.Y - gap)
        crosshairLines[4].From = Vector2.new(center.X, center.Y + gap)
        crosshairLines[4].To = Vector2.new(center.X, center.Y + sz)
    else
        for i = 1, 4 do crosshairLines[i].Visible = false end
    end
end)

local origLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function SetFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = origLighting.Brightness
        Lighting.ClockTime = origLighting.ClockTime
        Lighting.FogEnd = origLighting.FogEnd
        Lighting.GlobalShadows = origLighting.GlobalShadows
        Lighting.Ambient = origLighting.Ambient
        Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
    end
end

local fpsText = Drawing.new("Text")
fpsText.Size = 16
fpsText.Font = 2
fpsText.Outline = true
fpsText.Color = Color3.fromRGB(65, 130, 255)
fpsText.Position = Vector2.new(10, 10)
fpsText.Visible = false
fpsText.ZIndex = 1000

local fpsAccum = 0
local fpsFrames = 0
RunService.RenderStepped:Connect(function(dt)
    if Settings.Misc.FPSCounter then
        fpsAccum = fpsAccum + dt
        fpsFrames = fpsFrames + 1
        if fpsAccum >= 0.5 then
            local fps = math.floor(fpsFrames / fpsAccum)
            fpsText.Text = fps .. " FPS"
            fpsAccum = 0
            fpsFrames = 0
        end
        fpsText.Visible = true
    else
        fpsText.Visible = false
    end
end)

pcall(function()
    local vu = LocalPlayer:FindFirstChildOfClass("VirtualUser")
    if not vu then
        vu = Instance.new("VirtualUser")
        vu.Parent = LocalPlayer
    end
    LocalPlayer.Idled:Connect(function()
        if Settings.Misc.AntiAFK then
            local vu2 = LocalPlayer:FindFirstChildOfClass("VirtualUser")
            if vu2 then
                vu2:CaptureController()
                vu2:ClickButton2(Vector2.new())
            end
        end
    end)
end)

local espObjects = {}

local function ClearESP()
    for _, data in pairs(espObjects) do
        for _, obj in pairs(data) do
            pcall(function()
                if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end
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
    data.NameTag.Font = 2
    data.NameTag.Center = true
    data.NameTag.Outline = true
    data.NameTag.Color = Color3.fromRGB(255, 255, 255)
    data.NameTag.Visible = false
    data.NameTag.ZIndex = 6

    data.DistTag = Drawing.new("Text")
    data.DistTag.Size = 11
    data.DistTag.Font = 2
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
    local viewSize = Camera.ViewportSize
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
            elseif data.BoxOutline then data.BoxOutline.Visible = false end

            if data.NameTag and Settings.Visuals.NameESP then
                data.NameTag.Text = player.DisplayName
                data.NameTag.Position = Vector2.new(rootScreen.X, headScreen.Y - 16)
                data.NameTag.Visible = true
            elseif data.NameTag then data.NameTag.Visible = false end

            if data.DistTag and Settings.Visuals.Distance then
                data.DistTag.Text = math.floor(dist) .. "m"
                data.DistTag.Position = Vector2.new(rootScreen.X, legScreen.Y + 4)
                data.DistTag.Visible = true
            elseif data.DistTag then data.DistTag.Visible = false end

            if data.Tracer and Settings.Visuals.Tracers then
                local fromPos
                if Settings.Visuals.TracerOrigin == "Center" then
                    fromPos = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                elseif Settings.Visuals.TracerOrigin == "Mouse" then
                    fromPos = UserInputService:GetMouseLocation()
                else
                    fromPos = Vector2.new(viewSize.X / 2, viewSize.Y - GuiInset.Y)
                end
                data.Tracer.From = fromPos
                data.Tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
                data.Tracer.Color = Settings.Visuals.ESPColor
                data.Tracer.Visible = true
            elseif data.Tracer then data.Tracer.Visible = false end

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
        elseif data.Highlight then data.Highlight.Parent = nil end
    end
end

local function RefreshAllESP()
    ClearESP()
    if Settings.Visuals.ESP then
        for _, player in ipairs(Players:GetPlayers()) do CreateESPForPlayer(player) end
    end
end

Players.PlayerAdded:Connect(function(player)
    if Settings.Visuals.ESP then CreateESPForPlayer(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            pcall(function()
                if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end
            end)
        end
        espObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Visuals.ESP then UpdateESP() end
end)

local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚔" })

CombatTab:CreateSection({ Name = "Aimbot" })

CombatTab:CreateToggle({
    Text = "Enable Aimbot",
    Default = false,
    Flag = "AimbotEnabled",
    Tooltip = "Locks aim to closest player in FOV",
    Callback = function(s) Settings.Aimbot.Enabled = s end,
})

CombatTab:CreateSlider({
    Text = "FOV Radius",
    Min = 50, Max = 800, Default = 250, Increment = 10,
    Suffix = "px", Flag = "AimbotFOV",
    Callback = function(v) Settings.Aimbot.FOV = v end,
})

CombatTab:CreateSlider({
    Text = "Smoothness",
    Min = 1, Max = 20, Default = 5, Increment = 1,
    Flag = "AimbotSmooth",
    Tooltip = "Lower = snappier, higher = smoother",
    Callback = function(v) Settings.Aimbot.Smoothness = v end,
})

CombatTab:CreateDropdown({
    Text = "Target Part",
    Items = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head", Flag = "AimbotPart",
    Callback = function(s) Settings.Aimbot.TargetPart = s end,
})

CombatTab:CreateKeybind({
    Text = "Aim Key",
    Default = Enum.KeyCode.Q, Flag = "AimKey",
    Callback = function(k) Settings.Aimbot.AimKey = k end,
})

CombatTab:CreateToggle({
    Text = "Show FOV Circle",
    Default = true, Flag = "ShowFOV",
    Callback = function(s) Settings.Aimbot.ShowFOV = s end,
})

CombatTab:CreateToggle({
    Text = "Team Check",
    Default = false, Flag = "TeamCheck",
    Tooltip = "Skip teammates when aiming",
    Callback = function(s) Settings.Aimbot.TeamCheck = s end,
})

CombatTab:CreateDivider()
CombatTab:CreateSection({ Name = "Trigger Bot" })

CombatTab:CreateToggle({
    Text = "Trigger Bot",
    Default = false, Flag = "TriggerBot",
    Tooltip = "Auto-clicks when crosshair is on a player",
    Callback = function(s) Settings.Aimbot.TriggerBot = s end,
})

CombatTab:CreateSlider({
    Text = "Trigger Delay",
    Min = 0, Max = 0.5, Default = 0.05, Increment = 0.01,
    Suffix = "s", Flag = "TriggerDelay",
    Callback = function(v) Settings.Aimbot.TriggerDelay = v end,
})

CombatTab:CreateDivider()
CombatTab:CreateSection({ Name = "Hitbox Expander" })

CombatTab:CreateToggle({
    Text = "Hitbox Expander",
    Default = false, Flag = "HitboxEnabled",
    Callback = function(s)
        Settings.Hitbox.Enabled = s
        if not s then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = GetCharacter(player)
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then root.Size = Vector3.new(2, 2, 1); root.Transparency = 1 end
                end
            end
        end
    end,
})

CombatTab:CreateSlider({
    Text = "Hitbox Size",
    Min = 2, Max = 20, Default = 5, Increment = 1,
    Flag = "HitboxSize",
    Callback = function(v) Settings.Hitbox.Size = v end,
})

CombatTab:CreateToggle({
    Text = "Show Hitboxes",
    Default = false, Flag = "HitboxVisible",
    Callback = function(s) Settings.Hitbox.Visible = s end,
})

local MoveTab = Window:CreateTab({ Name = "Movement", Icon = "🏃" })

MoveTab:CreateSection({ Name = "Speed" })

MoveTab:CreateToggle({
    Text = "Speed Hack",
    Default = false, Flag = "SpeedEnabled",
    Callback = function(s)
        Settings.Movement.Speed = s
        if not s then local hum = GetHumanoid(LocalPlayer); if hum then hum.WalkSpeed = 16 end end
    end,
})

MoveTab:CreateSlider({
    Text = "Walk Speed",
    Min = 16, Max = 250, Default = 16, Increment = 1,
    Flag = "SpeedValue",
    Callback = function(v) Settings.Movement.SpeedValue = v end,
})

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Jump" })

MoveTab:CreateToggle({
    Text = "Jump Power",
    Default = false, Flag = "JumpPowerEnabled",
    Callback = function(s)
        Settings.Movement.JumpPower = s
        if not s then local hum = GetHumanoid(LocalPlayer); if hum then hum.JumpPower = 50 end end
    end,
})

MoveTab:CreateSlider({
    Text = "Jump Height",
    Min = 50, Max = 300, Default = 50, Increment = 5,
    Flag = "JumpPowerValue",
    Callback = function(v) Settings.Movement.JumpPowerValue = v end,
})

MoveTab:CreateToggle({
    Text = "Infinite Jump",
    Default = false, Flag = "InfJump",
    Callback = function(s) Settings.Movement.InfiniteJump = s end,
})

MoveTab:CreateToggle({
    Text = "Long Jump",
    Default = false, Flag = "LongJump",
    Tooltip = "Launches you forward when jumping while moving",
    Callback = function(s) Settings.Movement.LongJump = s end,
})

MoveTab:CreateSlider({
    Text = "Long Jump Force",
    Min = 20, Max = 200, Default = 80, Increment = 5,
    Flag = "LongJumpForce",
    Callback = function(v) Settings.Movement.LongJumpForce = v end,
})

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Flight" })

MoveTab:CreateToggle({
    Text = "Fly",
    Default = false, Flag = "FlyEnabled",
    Tooltip = "WASD to move, Space/Shift for up/down",
    Callback = function(s)
        Settings.Movement.Fly = s
        if s then StartFly() else StopFly() end
    end,
})

MoveTab:CreateSlider({
    Text = "Fly Speed",
    Min = 10, Max = 200, Default = 50, Increment = 5,
    Flag = "FlySpeed",
    Callback = function(v) Settings.Movement.FlySpeed = v end,
})

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Misc Movement" })

MoveTab:CreateToggle({
    Text = "Noclip",
    Default = false, Flag = "Noclip",
    Tooltip = "Walk through walls and objects",
    Callback = function(s)
        Settings.Movement.Noclip = s
        if not s then
            local char = GetCharacter(LocalPlayer)
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                end
            end
        end
    end,
})

MoveTab:CreateToggle({
    Text = "Auto Parkour",
    Default = false, Flag = "AutoParkour",
    Tooltip = "Automatically vaults over walls while running",
    Callback = function(s) Settings.Movement.AutoParkour = s end,
})

MoveTab:CreateToggle({
    Text = "Anti Void",
    Default = false, Flag = "AntiVoid",
    Tooltip = "Teleports you back up if you fall below the map",
    Callback = function(s) Settings.Movement.AntiVoid = s end,
})

MoveTab:CreateToggle({
    Text = "Spin Bot",
    Default = false, Flag = "SpinBot",
    Tooltip = "Rapidly spins your character",
    Callback = function(s) Settings.Movement.SpinBot = s end,
})

MoveTab:CreateSlider({
    Text = "Spin Speed",
    Min = 1, Max = 50, Default = 10, Increment = 1,
    Flag = "SpinSpeed",
    Callback = function(v) Settings.Movement.SpinSpeed = v end,
})

MoveTab:CreateDivider()

MoveTab:CreateButton({
    Text = "Teleport to Closest Player",
    Tooltip = "Teleports behind the nearest player",
    Callback = function()
        local root = GetRootPart(LocalPlayer)
        if not root then return end
        local closestDist, closestRoot = math.huge, nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsAlive(player) then
                local pRoot = GetRootPart(player)
                if pRoot then
                    local d = (root.Position - pRoot.Position).Magnitude
                    if d < closestDist then closestDist = d; closestRoot = pRoot end
                end
            end
        end
        if closestRoot then
            root.CFrame = closestRoot.CFrame * CFrame.new(0, 0, 5)
            Window:Notify({ Title = "Teleported", Message = math.floor(closestDist) .. "m away", Type = "success", Duration = 2 })
        else
            Window:Notify({ Title = "No Target", Message = "No valid players found.", Type = "warning", Duration = 2 })
        end
    end,
})

MoveTab:CreateButton({
    Text = "Respawn Character",
    Tooltip = "Forces a respawn",
    Callback = function()
        local char = GetCharacter(LocalPlayer)
        if char then char:BreakJoints() end
    end,
})

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁" })

VisualsTab:CreateSection({ Name = "ESP" })

VisualsTab:CreateToggle({
    Text = "Enable ESP",
    Default = false, Flag = "ESPEnabled",
    Tooltip = "Master toggle for all ESP",
    Callback = function(s)
        Settings.Visuals.ESP = s
        if s then RefreshAllESP() else ClearESP() end
    end,
})

VisualsTab:CreateSlider({
    Text = "Max Distance",
    Min = 100, Max = 5000, Default = 1500, Increment = 100,
    Suffix = "m", Flag = "ESPDistance",
    Callback = function(v) Settings.Visuals.MaxDistance = v end,
})

VisualsTab:CreateColorPicker({
    Text = "ESP Color",
    Default = Color3.fromRGB(65, 130, 255), Flag = "ESPColor",
    Callback = function(c) Settings.Visuals.ESPColor = c; FOVCircle.Color = c end,
})

VisualsTab:CreateToggle({ Text = "Box ESP", Default = false, Flag = "BoxESP", Callback = function(s) Settings.Visuals.BoxESP = s end })
VisualsTab:CreateToggle({ Text = "Name ESP", Default = false, Flag = "NameESP", Callback = function(s) Settings.Visuals.NameESP = s end })
VisualsTab:CreateToggle({ Text = "Health Bars", Default = false, Flag = "HealthBar", Callback = function(s) Settings.Visuals.HealthBar = s end })
VisualsTab:CreateToggle({ Text = "Tracers", Default = false, Flag = "Tracers", Callback = function(s) Settings.Visuals.Tracers = s end })

VisualsTab:CreateDropdown({
    Text = "Tracer Origin",
    Items = { "Bottom", "Center", "Mouse" }, Default = "Bottom", Flag = "TracerOrigin",
    Callback = function(s) Settings.Visuals.TracerOrigin = s end,
})

VisualsTab:CreateToggle({ Text = "Show Distance", Default = false, Flag = "ShowDistance", Callback = function(s) Settings.Visuals.Distance = s end })

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "Chams" })

VisualsTab:CreateToggle({
    Text = "Enable Chams",
    Default = false, Flag = "ChamsEnabled",
    Tooltip = "Highlight players through walls",
    Callback = function(s) Settings.Visuals.Chams = s end,
})

VisualsTab:CreateColorPicker({
    Text = "Chams Color",
    Default = Color3.fromRGB(65, 130, 255), Flag = "ChamsColor",
    Callback = function(c) Settings.Visuals.ChamsColor = c end,
})

VisualsTab:CreateSlider({
    Text = "Fill Transparency",
    Min = 0, Max = 1, Default = 0.6, Increment = 0.05, Flag = "ChamsFill",
    Callback = function(v) Settings.Visuals.ChamsFillTransparency = v end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "World" })

VisualsTab:CreateToggle({
    Text = "Fullbright",
    Default = false, Flag = "Fullbright",
    Tooltip = "Removes all darkness, fog, and shadows",
    Callback = function(s) Settings.Visuals.Fullbright = s; SetFullbright(s) end,
})

VisualsTab:CreateColorPicker({
    Text = "Ambient Color",
    Default = Lighting.Ambient, Flag = "AmbientColor",
    Tooltip = "Change the world ambient lighting color",
    Callback = function(c)
        Lighting.Ambient = c
        Lighting.OutdoorAmbient = c
    end,
})

VisualsTab:CreateSlider({
    Text = "Fog Distance",
    Min = 0, Max = 10000, Default = math.clamp(Lighting.FogEnd, 0, 10000), Increment = 100,
    Suffix = "", Flag = "FogEnd",
    Tooltip = "0 = thick fog, 10000 = no fog",
    Callback = function(v) Lighting.FogEnd = v end,
})

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "Crosshair" })

VisualsTab:CreateToggle({
    Text = "Custom Crosshair",
    Default = false, Flag = "CrosshairEnabled",
    Callback = function(s) Settings.Visuals.Crosshair = s end,
})

VisualsTab:CreateSlider({
    Text = "Crosshair Size",
    Min = 4, Max = 30, Default = 12, Increment = 1,
    Suffix = "px", Flag = "CrosshairSize",
    Callback = function(v) Settings.Visuals.CrosshairSize = v end,
})

VisualsTab:CreateColorPicker({
    Text = "Crosshair Color",
    Default = Color3.fromRGB(65, 130, 255), Flag = "CrosshairColor",
    Callback = function(c) Settings.Visuals.CrosshairColor = c end,
})

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "🔧" })

SettingsTab:CreateSection({ Name = "UI" })

SettingsTab:CreateToggle({
    Text = "Background Blur",
    Default = true, Flag = "BackgroundBlur",
    Tooltip = "Toggle blur effect behind the menu",
    Callback = function(s)
        local blur = Lighting:FindFirstChild("SereneUIBlur")
        if blur then blur.Enabled = s end
    end,
})

SettingsTab:CreateToggle({
    Text = "FPS Counter",
    Default = false, Flag = "FPSCounter",
    Tooltip = "Shows FPS in the top-left corner",
    Callback = function(s) Settings.Misc.FPSCounter = s end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "World" })

SettingsTab:CreateSlider({
    Text = "Gravity",
    Min = 0, Max = 500, Default = 196, Increment = 1,
    Flag = "Gravity", Tooltip = "Default is 196.2",
    Callback = function(v) Settings.Misc.Gravity = v; Workspace.Gravity = v end,
})

SettingsTab:CreateToggle({
    Text = "Anti AFK",
    Default = true, Flag = "AntiAFK",
    Tooltip = "Prevents idle kick",
    Callback = function(s) Settings.Misc.AntiAFK = s end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Config" })

SettingsTab:CreateButton({
    Text = "Save Config",
    Tooltip = "Save all settings to file",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({ Title = "Saved", Message = "Config saved.", Type = "success", Icon = "✓", Duration = 2 })
    end,
})

SettingsTab:CreateButton({
    Text = "Load Config",
    Tooltip = "Load saved settings",
    Callback = function()
        local ok = Window:LoadConfig("default")
        Window:Notify({
            Title = ok and "Loaded" or "Not Found",
            Message = ok and "Settings restored." or "No config found.",
            Type = ok and "success" or "warning",
            Icon = ok and "✓" or "!",
            Duration = 2,
        })
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Server" })

SettingsTab:CreateButton({
    Text = "Rejoin Server",
    Tooltip = "Reconnects to the same server",
    Callback = function()
        Window:Notify({ Title = "Rejoining...", Type = "info", Duration = 1 })
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

SettingsTab:CreateButton({
    Text = "Server Hop",
    Tooltip = "Joins a different server",
    Callback = function()
        Window:Notify({ Title = "Hopping...", Type = "info", Duration = 1 })
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:CreateButton({
    Text = "Copy Server ID",
    Tooltip = "Copies the current server JobId",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Window:Notify({ Title = "Copied", Message = "Server ID copied to clipboard.", Type = "success", Duration = 2 })
        else
            Window:Notify({ Title = "Error", Message = "Clipboard not supported.", Type = "error", Duration = 2 })
        end
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Player Info" })

SettingsTab:CreateParagraph({
    Title = "Your Info",
    Content = "Username: " .. LocalPlayer.Name
        .. "\nDisplay: " .. LocalPlayer.DisplayName
        .. "\nUserID: " .. tostring(LocalPlayer.UserId)
        .. "\nPlace: " .. tostring(game.PlaceId),
})

SettingsTab:CreateButton({
    Text = "Copy User ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(LocalPlayer.UserId))
            Window:Notify({ Title = "Copied", Message = "User ID copied.", Type = "success", Duration = 2 })
        end
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Reset" })

SettingsTab:CreateButton({
    Text = "Reset All Settings",
    Tooltip = "Disable everything and restore defaults",
    Callback = function()
        Settings.Aimbot.Enabled = false
        Settings.Aimbot.TriggerBot = false
        Settings.Hitbox.Enabled = false
        Settings.Movement.Speed = false
        Settings.Movement.JumpPower = false
        Settings.Movement.InfiniteJump = false
        Settings.Movement.LongJump = false
        Settings.Movement.Noclip = false
        Settings.Movement.AutoParkour = false
        Settings.Movement.AntiVoid = false
        Settings.Movement.SpinBot = false
        if flyActive then StopFly() end
        Settings.Movement.Fly = false
        Settings.Visuals.ESP = false
        Settings.Visuals.Crosshair = false
        Settings.Visuals.Fullbright = false
        ClearESP()
        SetFullbright(false)
        FOVCircle.Visible = false
        fpsText.Visible = false
        for i = 1, 4 do crosshairLines[i].Visible = false end
        Workspace.Gravity = 196.2
        Lighting.FogEnd = origLighting.FogEnd
        Lighting.Ambient = origLighting.Ambient
        Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
        local hum = GetHumanoid(LocalPlayer)
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        Window:Notify({ Title = "Reset", Message = "All features off, defaults restored.", Type = "info", Icon = "↺", Duration = 3 })
    end,
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "About" })

SettingsTab:CreateParagraph({
    Title = "Serene Hub — Universal",
    Content = "Built with SereneUI v1.1\nToggle: RightShift  |  Aim: Q\n\nUniversal hub for most games.\nSome features may vary by game.",
})

SettingsTab:CreateLabel({ Text = "Serene Hub v1.1 — SereneUI v1.1" })

Window:Notify({
    Title = "Serene Hub",
    Message = "Loaded successfully. Press RightShift to toggle.",
    Type = "success",
    Icon = "✓",
    Duration = 5,
})
