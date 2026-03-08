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
        AutoClick = false,
        AutoClickSpeed = 10,
        Reach = false,
        ReachDistance = 15,
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
        BHop = false,
        BHopPower = 30,
        AutoStrafe = false,
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
        ServerInfoHUD = false,
        TimeOfDay = 14,
    },
    Misc = {
        AntiAFK = true,
        Gravity = 196.2,
        FPSCounter = false,
    },
}

local savedPositions = {}

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

local function GetCharacter(p) return p and p.Character end
local function GetHumanoid(p) local c = GetCharacter(p); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRootPart(p) local c = GetCharacter(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function IsAlive(p) local h = GetHumanoid(p); return h and h.Health > 0 end
local function IsTeammate(p)
    if not Settings.Aimbot.TeamCheck then return false end
    if not p.Team or not LocalPlayer.Team then return false end
    return p.Team == LocalPlayer.Team
end

local function GetClosestPlayerToCursor(fov, part)
    local closest, shortestDist = nil, fov
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p) and not IsTeammate(p) then
            local c = GetCharacter(p)
            local tp = c and c:FindFirstChild(part)
            if tp then
                local sp, on = Camera:WorldToViewportPoint(tp.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if d < shortestDist then shortestDist = d; closest = tp end
                end
            end
        end
    end
    return closest
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 64; FOVCircle.Radius = 250
FOVCircle.Filled = false; FOVCircle.Visible = false; FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7; FOVCircle.Color = Color3.fromRGB(65, 130, 255)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
end)

local aiming = false
UserInputService.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Settings.Aimbot.AimKey then aiming = true end end)
UserInputService.InputEnded:Connect(function(i) if i.KeyCode == Settings.Aimbot.AimKey then aiming = false end end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and aiming then
        local t = GetClosestPlayerToCursor(Settings.Aimbot.FOV, Settings.Aimbot.TargetPart)
        if t then
            local tp = Camera:WorldToViewportPoint(t.Position)
            local mp = UserInputService:GetMouseLocation()
            local d = Vector2.new(tp.X, tp.Y) - mp
            mousemoverel(d.X / Settings.Aimbot.Smoothness, d.Y / Settings.Aimbot.Smoothness)
        end
    end
end)

local lastTrigger = 0
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.TriggerBot and Settings.Aimbot.Enabled then
        local now = tick()
        if now - lastTrigger < Settings.Aimbot.TriggerDelay then return end
        local t = GetClosestPlayerToCursor(Settings.Aimbot.FOV, Settings.Aimbot.TargetPart)
        if t then
            local sp, on = Camera:WorldToViewportPoint(t.Position)
            if on and (Vector2.new(sp.X, sp.Y) - UserInputService:GetMouseLocation()).Magnitude < 15 then
                mouse1click(); lastTrigger = now
            end
        end
    end
end)

local lastAutoClick = 0
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.AutoClick then
        local now = tick()
        local interval = 1 / Settings.Aimbot.AutoClickSpeed
        if now - lastAutoClick >= interval then
            mouse1click()
            lastAutoClick = now
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Hitbox.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsAlive(p) and not IsTeammate(p) then
                local c = GetCharacter(p)
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    r.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                    r.Transparency = Settings.Hitbox.Visible and Settings.Hitbox.Transparency or 1
                    r.CanCollide = false; r.Material = Enum.Material.Neon; r.Color = Color3.fromRGB(65, 130, 255)
                end
            end
        end
    end
end)

local flyActive, flyBody = false, nil
local function StartFly()
    local c, r = GetCharacter(LocalPlayer), GetRootPart(LocalPlayer)
    if not c or not r then return end
    local h = GetHumanoid(LocalPlayer); if h then h.PlatformStand = true end
    flyBody = Instance.new("BodyVelocity"); flyBody.MaxForce = Vector3.new(math.huge,math.huge,math.huge); flyBody.Velocity = Vector3.zero; flyBody.Parent = r
    local g = Instance.new("BodyGyro"); g.Name = "FlyGyro"; g.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); g.P = 9000; g.Parent = r
    flyActive = true
end
local function StopFly()
    local r = GetRootPart(LocalPlayer)
    if r then local bv = r:FindFirstChildOfClass("BodyVelocity"); local bg = r:FindFirstChild("FlyGyro"); if bv then bv:Destroy() end; if bg then bg:Destroy() end end
    local h = GetHumanoid(LocalPlayer); if h then h.PlatformStand = false end; flyBody = nil; flyActive = false
end

RunService.RenderStepped:Connect(function()
    if flyActive and flyBody then
        local r = GetRootPart(LocalPlayer); if not r then StopFly(); return end
        local dir, cf, spd = Vector3.zero, Camera.CFrame, Settings.Movement.FlySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
        if dir.Magnitude > 0 then dir = dir.Unit * spd end
        flyBody.Velocity = dir
        local g = r:FindFirstChild("FlyGyro"); if g then g.CFrame = cf end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.Movement.InfiniteJump then local h = GetHumanoid(LocalPlayer); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    if Settings.Movement.LongJump then
        local h, r = GetHumanoid(LocalPlayer), GetRootPart(LocalPlayer)
        if h and r and h.MoveDirection.Magnitude > 0 then
            task.defer(function() task.wait(0.05); if r and r.Parent then r.Velocity = r.Velocity + h.MoveDirection * Settings.Movement.LongJumpForce + Vector3.new(0, 20, 0) end end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Movement.Noclip then local c = GetCharacter(LocalPlayer); if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.Speed then local h = GetHumanoid(LocalPlayer); if h then h.WalkSpeed = Settings.Movement.SpeedValue end end
    if Settings.Movement.JumpPower then local h = GetHumanoid(LocalPlayer); if h then h.JumpPower = Settings.Movement.JumpPowerValue end end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AutoParkour then
        local h, r = GetHumanoid(LocalPlayer), GetRootPart(LocalPlayer)
        if h and r and h.MoveDirection.Magnitude > 0 then
            local p = RaycastParams.new(); p.FilterType = Enum.RaycastFilterType.Exclude; p.FilterDescendantsInstances = {GetCharacter(LocalPlayer)}
            local res = Workspace:Raycast(r.Position + Vector3.new(0,-1,0), h.MoveDirection * 4, p)
            if res and res.Instance then
                local d = (res.Instance.Position.Y + res.Instance.Size.Y/2) - r.Position.Y
                if d > 0 and d < 12 then h:ChangeState(Enum.HumanoidStateType.Jumping); task.wait(0.1); if r and r.Parent then r.Velocity = Vector3.new(r.Velocity.X, math.clamp(d*12,30,80), r.Velocity.Z) end end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AntiVoid then local r = GetRootPart(LocalPlayer); if r and r.Position.Y < -50 then r.CFrame = CFrame.new(r.Position.X, 100, r.Position.Z); r.Velocity = Vector3.zero end end
end)

RunService.RenderStepped:Connect(function(dt)
    if Settings.Movement.SpinBot then local r = GetRootPart(LocalPlayer); if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(Settings.Movement.SpinSpeed * 60 * dt), 0) end end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.BHop then
        local h = GetHumanoid(LocalPlayer)
        if h and h.MoveDirection.Magnitude > 0 and h:GetState() ~= Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
            local r = GetRootPart(LocalPlayer)
            if r then r.Velocity = r.Velocity + h.MoveDirection * Settings.Movement.BHopPower * 0.1 end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Movement.AutoStrafe then
        local h, r = GetHumanoid(LocalPlayer), GetRootPart(LocalPlayer)
        if h and r and h:GetState() == Enum.HumanoidStateType.Freefall then
            local look = Camera.CFrame.LookVector
            r.Velocity = Vector3.new(look.X * Settings.Movement.SpeedValue, r.Velocity.Y, look.Z * Settings.Movement.SpeedValue)
        end
    end
end)

local crosshairLines = {}
for i = 1, 4 do local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.fromRGB(65,130,255); l.Visible = false; l.ZIndex = 998; crosshairLines[i] = l end

RunService.RenderStepped:Connect(function()
    if Settings.Visuals.Crosshair then
        local c = UserInputService:GetMouseLocation(); local sz, gap = Settings.Visuals.CrosshairSize, 4
        for i = 1, 4 do crosshairLines[i].Color = Settings.Visuals.CrosshairColor; crosshairLines[i].Thickness = Settings.Visuals.CrosshairThickness; crosshairLines[i].Visible = true end
        crosshairLines[1].From = Vector2.new(c.X-sz, c.Y); crosshairLines[1].To = Vector2.new(c.X-gap, c.Y)
        crosshairLines[2].From = Vector2.new(c.X+gap, c.Y); crosshairLines[2].To = Vector2.new(c.X+sz, c.Y)
        crosshairLines[3].From = Vector2.new(c.X, c.Y-sz); crosshairLines[3].To = Vector2.new(c.X, c.Y-gap)
        crosshairLines[4].From = Vector2.new(c.X, c.Y+gap); crosshairLines[4].To = Vector2.new(c.X, c.Y+sz)
    else for i = 1, 4 do crosshairLines[i].Visible = false end end
end)

local origLighting = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient }

local function SetFullbright(on)
    if on then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178,178,178); Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
    else Lighting.Brightness = origLighting.Brightness; Lighting.ClockTime = origLighting.ClockTime; Lighting.FogEnd = origLighting.FogEnd; Lighting.GlobalShadows = origLighting.GlobalShadows; Lighting.Ambient = origLighting.Ambient; Lighting.OutdoorAmbient = origLighting.OutdoorAmbient end
end

local serverHUD = {}
for i = 1, 4 do
    local t = Drawing.new("Text"); t.Size = 13; t.Font = 2; t.Outline = true; t.Color = Color3.fromRGB(200,200,220); t.Visible = false; t.ZIndex = 1000
    t.Position = Vector2.new(10, 26 + (i-1) * 16); serverHUD[i] = t
end

local fpsText = Drawing.new("Text"); fpsText.Size = 16; fpsText.Font = 2; fpsText.Outline = true; fpsText.Color = Color3.fromRGB(65,130,255); fpsText.Position = Vector2.new(10, 10); fpsText.Visible = false; fpsText.ZIndex = 1000
local fpsA, fpsF = 0, 0
RunService.RenderStepped:Connect(function(dt)
    if Settings.Misc.FPSCounter then fpsA = fpsA + dt; fpsF = fpsF + 1; if fpsA >= 0.5 then fpsText.Text = math.floor(fpsF/fpsA) .. " FPS"; fpsA = 0; fpsF = 0 end; fpsText.Visible = true else fpsText.Visible = false end
    if Settings.Visuals.ServerInfoHUD then
        serverHUD[1].Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers; serverHUD[1].Visible = true
        serverHUD[2].Text = "Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"; serverHUD[2].Visible = true
        serverHUD[3].Text = "Server: " .. string.sub(game.JobId, 1, 8) .. "..."; serverHUD[3].Visible = true
        serverHUD[4].Text = "Place: " .. game.PlaceId; serverHUD[4].Visible = true
        local yOff = Settings.Misc.FPSCounter and 28 or 10
        for i = 1, 4 do serverHUD[i].Position = Vector2.new(10, yOff + (i-1)*16) end
    else for i = 1, 4 do serverHUD[i].Visible = false end end
end)

pcall(function()
    local vu = LocalPlayer:FindFirstChildOfClass("VirtualUser")
    if not vu then vu = Instance.new("VirtualUser"); vu.Parent = LocalPlayer end
    LocalPlayer.Idled:Connect(function() if Settings.Misc.AntiAFK then local v = LocalPlayer:FindFirstChildOfClass("VirtualUser"); if v then v:CaptureController(); v:ClickButton2(Vector2.new()) end end end)
end)

local espObjects = {}
local function ClearESP()
    for _, data in pairs(espObjects) do for _, obj in pairs(data) do pcall(function() if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end end) end end
    espObjects = {}
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer or espObjects[player] then return end
    espObjects[player] = {}; local d = espObjects[player]
    d.BoxOutline = Drawing.new("Square"); d.BoxOutline.Thickness = 1; d.BoxOutline.Filled = false; d.BoxOutline.Color = Settings.Visuals.ESPColor; d.BoxOutline.Visible = false; d.BoxOutline.ZIndex = 5
    d.NameTag = Drawing.new("Text"); d.NameTag.Size = 13; d.NameTag.Font = 2; d.NameTag.Center = true; d.NameTag.Outline = true; d.NameTag.Color = Color3.fromRGB(255,255,255); d.NameTag.Visible = false; d.NameTag.ZIndex = 6
    d.DistTag = Drawing.new("Text"); d.DistTag.Size = 11; d.DistTag.Font = 2; d.DistTag.Center = true; d.DistTag.Outline = true; d.DistTag.Color = Color3.fromRGB(200,200,200); d.DistTag.Visible = false; d.DistTag.ZIndex = 6
    d.Tracer = Drawing.new("Line"); d.Tracer.Thickness = 1; d.Tracer.Color = Settings.Visuals.ESPColor; d.Tracer.Visible = false; d.Tracer.ZIndex = 4
    d.HealthBG = Drawing.new("Line"); d.HealthBG.Thickness = 3; d.HealthBG.Color = Color3.fromRGB(30,30,30); d.HealthBG.Visible = false; d.HealthBG.ZIndex = 5
    d.HealthBar = Drawing.new("Line"); d.HealthBar.Thickness = 2; d.HealthBar.Color = Color3.fromRGB(80,255,80); d.HealthBar.Visible = false; d.HealthBar.ZIndex = 6
    d.Highlight = Instance.new("Highlight"); d.Highlight.Name = "SereneChams"; d.Highlight.FillColor = Settings.Visuals.ChamsColor; d.Highlight.OutlineColor = Settings.Visuals.ChamsColor
    d.Highlight.FillTransparency = Settings.Visuals.ChamsFillTransparency; d.Highlight.OutlineTransparency = Settings.Visuals.ChamsOutlineTransparency; d.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function UpdateESP()
    local vs = Camera.ViewportSize
    for player, data in pairs(espObjects) do
        local char = GetCharacter(player); local root = char and char:FindFirstChild("HumanoidRootPart"); local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid"); local lr = GetRootPart(LocalPlayer)
        local alive = IsAlive(player) and root and head and lr
        local function hideAll() if data.BoxOutline then data.BoxOutline.Visible = false end; if data.NameTag then data.NameTag.Visible = false end; if data.DistTag then data.DistTag.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end; if data.HealthBG then data.HealthBG.Visible = false end; if data.HealthBar then data.HealthBar.Visible = false end; if data.Highlight then data.Highlight.Parent = nil end end
        if not alive or (Settings.Aimbot.TeamCheck and IsTeammate(player)) then hideAll(); continue end
        local dist = (lr.Position - root.Position).Magnitude
        if dist > Settings.Visuals.MaxDistance then hideAll(); continue end
        local rs, ron = Camera:WorldToViewportPoint(root.Position)
        local hs = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local ls = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        if ron then
            local bH = math.abs(hs.Y - ls.Y); local bW = bH * 0.55
            if data.BoxOutline and Settings.Visuals.BoxESP then data.BoxOutline.Size = Vector2.new(bW,bH); data.BoxOutline.Position = Vector2.new(rs.X-bW/2, hs.Y); data.BoxOutline.Color = Settings.Visuals.ESPColor; data.BoxOutline.Visible = true elseif data.BoxOutline then data.BoxOutline.Visible = false end
            if data.NameTag and Settings.Visuals.NameESP then data.NameTag.Text = player.DisplayName; data.NameTag.Position = Vector2.new(rs.X, hs.Y-16); data.NameTag.Visible = true elseif data.NameTag then data.NameTag.Visible = false end
            if data.DistTag and Settings.Visuals.Distance then data.DistTag.Text = math.floor(dist).."m"; data.DistTag.Position = Vector2.new(rs.X, ls.Y+4); data.DistTag.Visible = true elseif data.DistTag then data.DistTag.Visible = false end
            if data.Tracer and Settings.Visuals.Tracers then
                local fp; if Settings.Visuals.TracerOrigin == "Center" then fp = Vector2.new(vs.X/2, vs.Y/2) elseif Settings.Visuals.TracerOrigin == "Mouse" then fp = UserInputService:GetMouseLocation() else fp = Vector2.new(vs.X/2, vs.Y - GuiInset.Y) end
                data.Tracer.From = fp; data.Tracer.To = Vector2.new(rs.X, rs.Y); data.Tracer.Color = Settings.Visuals.ESPColor; data.Tracer.Visible = true
            elseif data.Tracer then data.Tracer.Visible = false end
            if data.HealthBG and data.HealthBar and Settings.Visuals.HealthBar and hum then
                local bX = rs.X-bW/2-6; data.HealthBG.From = Vector2.new(bX, hs.Y); data.HealthBG.To = Vector2.new(bX, ls.Y); data.HealthBG.Visible = true
                local hp = math.clamp(hum.Health/hum.MaxHealth,0,1); local fb = ls.Y-(ls.Y-hs.Y)*hp
                data.HealthBar.From = Vector2.new(bX, ls.Y); data.HealthBar.To = Vector2.new(bX, fb); data.HealthBar.Color = Color3.fromRGB(255*(1-hp), 255*hp, 0); data.HealthBar.Visible = true
            else if data.HealthBG then data.HealthBG.Visible = false end; if data.HealthBar then data.HealthBar.Visible = false end end
        else hideAll() end
        if data.Highlight and Settings.Visuals.Chams then data.Highlight.FillColor = Settings.Visuals.ChamsColor; data.Highlight.OutlineColor = Settings.Visuals.ChamsColor; data.Highlight.FillTransparency = Settings.Visuals.ChamsFillTransparency; data.Highlight.OutlineTransparency = Settings.Visuals.ChamsOutlineTransparency; data.Highlight.Parent = char
        elseif data.Highlight then data.Highlight.Parent = nil end
    end
end

local function RefreshAllESP() ClearESP(); if Settings.Visuals.ESP then for _, p in ipairs(Players:GetPlayers()) do CreateESPForPlayer(p) end end end
Players.PlayerAdded:Connect(function(p) if Settings.Visuals.ESP then CreateESPForPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p) if espObjects[p] then for _, o in pairs(espObjects[p]) do pcall(function() if typeof(o)=="Instance" then o:Destroy() else o:Remove() end end) end; espObjects[p]=nil end end)
RunService.RenderStepped:Connect(function() if Settings.Visuals.ESP then UpdateESP() end end)

local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚔" })
CombatTab:CreateSection({ Name = "Aimbot" })
CombatTab:CreateToggle({ Text = "Enable Aimbot", Default = false, Flag = "AimbotEnabled", Tooltip = "Locks aim to closest player in FOV", Callback = function(s) Settings.Aimbot.Enabled = s end })
CombatTab:CreateSlider({ Text = "FOV Radius", Min = 50, Max = 800, Default = 250, Increment = 10, Suffix = "px", Flag = "AimbotFOV", Callback = function(v) Settings.Aimbot.FOV = v end })
CombatTab:CreateSlider({ Text = "Smoothness", Min = 1, Max = 20, Default = 5, Increment = 1, Flag = "AimbotSmooth", Tooltip = "Lower = snappier", Callback = function(v) Settings.Aimbot.Smoothness = v end })
CombatTab:CreateDropdown({ Text = "Target Part", Items = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, Default = "Head", Flag = "AimbotPart", Callback = function(s) Settings.Aimbot.TargetPart = s end })
CombatTab:CreateKeybind({ Text = "Aim Key", Default = Enum.KeyCode.Q, Flag = "AimKey", Callback = function(k) Settings.Aimbot.AimKey = k end })
CombatTab:CreateToggle({ Text = "Show FOV Circle", Default = true, Flag = "ShowFOV", Callback = function(s) Settings.Aimbot.ShowFOV = s end })
CombatTab:CreateToggle({ Text = "Team Check", Default = false, Flag = "TeamCheck", Tooltip = "Skip teammates", Callback = function(s) Settings.Aimbot.TeamCheck = s end })

CombatTab:CreateDivider()
CombatTab:CreateSection({ Name = "Automation" })
CombatTab:CreateToggle({ Text = "Trigger Bot", Default = false, Flag = "TriggerBot", Tooltip = "Auto-fires when crosshair is near target", Callback = function(s) Settings.Aimbot.TriggerBot = s end })
CombatTab:CreateSlider({ Text = "Trigger Delay", Min = 0, Max = 0.5, Default = 0.05, Increment = 0.01, Suffix = "s", Flag = "TriggerDelay", Callback = function(v) Settings.Aimbot.TriggerDelay = v end })
CombatTab:CreateToggle({ Text = "Auto Clicker", Default = false, Flag = "AutoClick", Tooltip = "Rapidly clicks mouse", Callback = function(s) Settings.Aimbot.AutoClick = s end })
CombatTab:CreateSlider({ Text = "Click Speed", Min = 1, Max = 50, Default = 10, Increment = 1, Suffix = " CPS", Flag = "AutoClickSpeed", Callback = function(v) Settings.Aimbot.AutoClickSpeed = v end })

CombatTab:CreateDivider()
CombatTab:CreateSection({ Name = "Hitbox Expander" })
CombatTab:CreateToggle({ Text = "Hitbox Expander", Default = false, Flag = "HitboxEnabled", Callback = function(s)
    Settings.Hitbox.Enabled = s
    if not s then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then local c = GetCharacter(p); local r = c and c:FindFirstChild("HumanoidRootPart"); if r then r.Size = Vector3.new(2,2,1); r.Transparency = 1 end end end end
end })
CombatTab:CreateSlider({ Text = "Hitbox Size", Min = 2, Max = 20, Default = 5, Increment = 1, Flag = "HitboxSize", Callback = function(v) Settings.Hitbox.Size = v end })
CombatTab:CreateToggle({ Text = "Show Hitboxes", Default = false, Flag = "HitboxVisible", Callback = function(s) Settings.Hitbox.Visible = s end })
CombatTab:CreateSlider({ Text = "Hitbox Opacity", Min = 0, Max = 1, Default = 0.5, Increment = 0.05, Flag = "HitboxTransparency", Callback = function(v) Settings.Hitbox.Transparency = v end })

local MoveTab = Window:CreateTab({ Name = "Movement", Icon = "🏃" })
MoveTab:CreateSection({ Name = "Speed" })
MoveTab:CreateToggle({ Text = "Speed Hack", Default = false, Flag = "SpeedEnabled", Callback = function(s) Settings.Movement.Speed = s; if not s then local h = GetHumanoid(LocalPlayer); if h then h.WalkSpeed = 16 end end end })
MoveTab:CreateSlider({ Text = "Walk Speed", Min = 16, Max = 250, Default = 16, Increment = 1, Flag = "SpeedValue", Callback = function(v) Settings.Movement.SpeedValue = v end })

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Jump" })
MoveTab:CreateToggle({ Text = "Jump Power", Default = false, Flag = "JumpPowerEnabled", Callback = function(s) Settings.Movement.JumpPower = s; if not s then local h = GetHumanoid(LocalPlayer); if h then h.JumpPower = 50 end end end })
MoveTab:CreateSlider({ Text = "Jump Height", Min = 50, Max = 300, Default = 50, Increment = 5, Flag = "JumpPowerValue", Callback = function(v) Settings.Movement.JumpPowerValue = v end })
MoveTab:CreateToggle({ Text = "Infinite Jump", Default = false, Flag = "InfJump", Callback = function(s) Settings.Movement.InfiniteJump = s end })
MoveTab:CreateToggle({ Text = "Long Jump", Default = false, Flag = "LongJump", Tooltip = "Launches forward when jumping", Callback = function(s) Settings.Movement.LongJump = s end })
MoveTab:CreateSlider({ Text = "Long Jump Force", Min = 20, Max = 200, Default = 80, Increment = 5, Flag = "LongJumpForce", Callback = function(v) Settings.Movement.LongJumpForce = v end })
MoveTab:CreateToggle({ Text = "Bunny Hop", Default = false, Flag = "BHop", Tooltip = "Auto-jumps while moving for momentum", Callback = function(s) Settings.Movement.BHop = s end })
MoveTab:CreateSlider({ Text = "BHop Power", Min = 5, Max = 100, Default = 30, Increment = 5, Flag = "BHopPower", Callback = function(v) Settings.Movement.BHopPower = v end })

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Flight" })
MoveTab:CreateToggle({ Text = "Fly", Default = false, Flag = "FlyEnabled", Tooltip = "WASD + Space/Shift", Callback = function(s) Settings.Movement.Fly = s; if s then StartFly() else StopFly() end end })
MoveTab:CreateSlider({ Text = "Fly Speed", Min = 10, Max = 200, Default = 50, Increment = 5, Flag = "FlySpeed", Callback = function(v) Settings.Movement.FlySpeed = v end })

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Misc" })
MoveTab:CreateToggle({ Text = "Noclip", Default = false, Flag = "Noclip", Tooltip = "Walk through everything", Callback = function(s) Settings.Movement.Noclip = s; if not s then local c = GetCharacter(LocalPlayer); if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end end end })
MoveTab:CreateToggle({ Text = "Auto Parkour", Default = false, Flag = "AutoParkour", Tooltip = "Vaults over walls automatically", Callback = function(s) Settings.Movement.AutoParkour = s end })
MoveTab:CreateToggle({ Text = "Anti Void", Default = false, Flag = "AntiVoid", Tooltip = "Saves you from falling off the map", Callback = function(s) Settings.Movement.AntiVoid = s end })
MoveTab:CreateToggle({ Text = "Auto Strafe", Default = false, Flag = "AutoStrafe", Tooltip = "Air strafes toward camera direction", Callback = function(s) Settings.Movement.AutoStrafe = s end })
MoveTab:CreateToggle({ Text = "Spin Bot", Default = false, Flag = "SpinBot", Callback = function(s) Settings.Movement.SpinBot = s end })
MoveTab:CreateSlider({ Text = "Spin Speed", Min = 1, Max = 50, Default = 10, Increment = 1, Flag = "SpinSpeed", Callback = function(v) Settings.Movement.SpinSpeed = v end })

MoveTab:CreateDivider()
MoveTab:CreateSection({ Name = "Teleport" })
MoveTab:CreateButton({ Text = "TP to Closest Player", Tooltip = "Teleports behind nearest player", Callback = function()
    local r = GetRootPart(LocalPlayer); if not r then return end
    local cd, cr = math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and IsAlive(p) then local pr = GetRootPart(p); if pr then local d = (r.Position-pr.Position).Magnitude; if d < cd then cd = d; cr = pr end end end end
    if cr then r.CFrame = cr.CFrame * CFrame.new(0,0,5); Window:Notify({Title="Teleported", Message=math.floor(cd).."m", Type="success", Duration=2}) end
end })
MoveTab:CreateButton({ Text = "Save Position", Tooltip = "Saves current location", Callback = function()
    local r = GetRootPart(LocalPlayer)
    if r then savedPositions[#savedPositions+1] = r.CFrame; Window:Notify({Title="Saved", Message="Position #"..#savedPositions.." saved", Type="success", Duration=2}) end
end })
MoveTab:CreateButton({ Text = "Load Position", Tooltip = "Teleports to last saved position", Callback = function()
    local r = GetRootPart(LocalPlayer)
    if r and #savedPositions > 0 then r.CFrame = savedPositions[#savedPositions]; Window:Notify({Title="Loaded", Message="Teleported to position #"..#savedPositions, Type="success", Duration=2})
    else Window:Notify({Title="Error", Message="No saved positions", Type="warning", Duration=2}) end
end })
MoveTab:CreateButton({ Text = "Respawn", Callback = function() local c = GetCharacter(LocalPlayer); if c then c:BreakJoints() end end })

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "👁" })
VisualsTab:CreateSection({ Name = "ESP" })
VisualsTab:CreateToggle({ Text = "Enable ESP", Default = false, Flag = "ESPEnabled", Tooltip = "Master ESP toggle", Callback = function(s) Settings.Visuals.ESP = s; if s then RefreshAllESP() else ClearESP() end end })
VisualsTab:CreateSlider({ Text = "Max Distance", Min = 100, Max = 5000, Default = 1500, Increment = 100, Suffix = "m", Flag = "ESPDistance", Callback = function(v) Settings.Visuals.MaxDistance = v end })
VisualsTab:CreateColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(65,130,255), Flag = "ESPColor", Callback = function(c) Settings.Visuals.ESPColor = c; FOVCircle.Color = c end })
VisualsTab:CreateToggle({ Text = "Box ESP", Default = false, Flag = "BoxESP", Callback = function(s) Settings.Visuals.BoxESP = s end })
VisualsTab:CreateToggle({ Text = "Name ESP", Default = false, Flag = "NameESP", Callback = function(s) Settings.Visuals.NameESP = s end })
VisualsTab:CreateToggle({ Text = "Health Bars", Default = false, Flag = "HealthBar", Callback = function(s) Settings.Visuals.HealthBar = s end })
VisualsTab:CreateToggle({ Text = "Tracers", Default = false, Flag = "Tracers", Callback = function(s) Settings.Visuals.Tracers = s end })
VisualsTab:CreateDropdown({ Text = "Tracer Origin", Items = {"Bottom","Center","Mouse"}, Default = "Bottom", Flag = "TracerOrigin", Callback = function(s) Settings.Visuals.TracerOrigin = s end })
VisualsTab:CreateToggle({ Text = "Show Distance", Default = false, Flag = "ShowDistance", Callback = function(s) Settings.Visuals.Distance = s end })

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "Chams" })
VisualsTab:CreateToggle({ Text = "Enable Chams", Default = false, Flag = "ChamsEnabled", Tooltip = "Highlight through walls", Callback = function(s) Settings.Visuals.Chams = s end })
VisualsTab:CreateColorPicker({ Text = "Chams Color", Default = Color3.fromRGB(65,130,255), Flag = "ChamsColor", Callback = function(c) Settings.Visuals.ChamsColor = c end })
VisualsTab:CreateSlider({ Text = "Fill Transparency", Min = 0, Max = 1, Default = 0.6, Increment = 0.05, Flag = "ChamsFill", Callback = function(v) Settings.Visuals.ChamsFillTransparency = v end })

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "World" })
VisualsTab:CreateToggle({ Text = "Fullbright", Default = false, Flag = "Fullbright", Tooltip = "Removes darkness and fog", Callback = function(s) Settings.Visuals.Fullbright = s; SetFullbright(s) end })
VisualsTab:CreateSlider({ Text = "Time of Day", Min = 0, Max = 24, Default = 14, Increment = 0.5, Flag = "TimeOfDay", Tooltip = "Change world time", Callback = function(v) Settings.Visuals.TimeOfDay = v; Lighting.ClockTime = v end })
VisualsTab:CreateColorPicker({ Text = "Ambient Color", Default = Lighting.Ambient, Flag = "AmbientColor", Callback = function(c) Lighting.Ambient = c; Lighting.OutdoorAmbient = c end })
VisualsTab:CreateSlider({ Text = "Fog Distance", Min = 0, Max = 10000, Default = math.clamp(Lighting.FogEnd, 0, 10000), Increment = 100, Flag = "FogEnd", Tooltip = "0 = thick fog", Callback = function(v) Lighting.FogEnd = v end })
VisualsTab:CreateToggle({ Text = "Server Info HUD", Default = false, Flag = "ServerHUD", Tooltip = "Shows player count, ping, server ID", Callback = function(s) Settings.Visuals.ServerInfoHUD = s end })

VisualsTab:CreateDivider()
VisualsTab:CreateSection({ Name = "Crosshair" })
VisualsTab:CreateToggle({ Text = "Custom Crosshair", Default = false, Flag = "CrosshairEnabled", Callback = function(s) Settings.Visuals.Crosshair = s end })
VisualsTab:CreateSlider({ Text = "Size", Min = 4, Max = 30, Default = 12, Increment = 1, Suffix = "px", Flag = "CrosshairSize", Callback = function(v) Settings.Visuals.CrosshairSize = v end })
VisualsTab:CreateColorPicker({ Text = "Crosshair Color", Default = Color3.fromRGB(65,130,255), Flag = "CrosshairColor", Callback = function(c) Settings.Visuals.CrosshairColor = c end })

local ScriptsTab = Window:CreateTab({ Name = "Scripts", Icon = "📜" })

ScriptsTab:CreateSection({ Name = "Admin & Utility" })

ScriptsTab:CreateButton({ Text = "Infinite Yield", Tooltip = "Powerful admin command script", Callback = function()
    Window:Notify({Title="Loading", Message="Infinite Yield...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
end })

ScriptsTab:CreateButton({ Text = "Hydroxide", Tooltip = "Remote spy and runtime inspector", Callback = function()
    Window:Notify({Title="Loading", Message="Hydroxide...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua"))() end)
end })

ScriptsTab:CreateButton({ Text = "Simple Spy", Tooltip = "Lightweight remote spy", Callback = function()
    Window:Notify({Title="Loading", Message="Simple Spy...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() end)
end })

ScriptsTab:CreateButton({ Text = "DEX Explorer", Tooltip = "Roblox game explorer", Callback = function()
    Window:Notify({Title="Loading", Message="DEX Explorer...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
end })

ScriptsTab:CreateButton({ Text = "Dark DEX", Tooltip = "Dark themed explorer", Callback = function()
    Window:Notify({Title="Loading", Message="Dark DEX...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDex.lua"))() end)
end })

ScriptsTab:CreateDivider()
ScriptsTab:CreateSection({ Name = "Testing" })

ScriptsTab:CreateButton({ Text = "UNC Environment Test", Tooltip = "Tests executor environment compatibility", Callback = function()
    Window:Notify({Title="Loading", Message="UNC Test...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/nicemike40/UNCCheckEnv/main/test.lua"))() end)
end })

ScriptsTab:CreateButton({ Text = "Myriad Test", Tooltip = "Alternative executor environment test", Callback = function()
    Window:Notify({Title="Loading", Message="Myriad...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/myriad-test/main/source.lua"))() end)
end })

ScriptsTab:CreateDivider()
ScriptsTab:CreateSection({ Name = "Fun & Misc" })

ScriptsTab:CreateButton({ Text = "Flashback (Replay)", Tooltip = "Record and replay your character movements", Callback = function()
    Window:Notify({Title="Loading", Message="Flashback...", Type="info", Duration=2})
    task.defer(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/IcyMonstrosity/Flashback/main/Source.lua"))() end)
end })

ScriptsTab:CreateButton({ Text = "Chat Spy", Tooltip = "See whispers and team chat from all players", Callback = function()
    Window:Notify({Title="Loading", Message="Chat Spy...", Type="info", Duration=2})
    task.defer(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                p.Chatted:Connect(function(msg) print("[ChatSpy] " .. p.Name .. ": " .. msg) end)
            end
        end
        Players.PlayerAdded:Connect(function(p)
            p.Chatted:Connect(function(msg) print("[ChatSpy] " .. p.Name .. ": " .. msg) end)
        end)
        Window:Notify({Title="Chat Spy", Message="Active — check console (F9)", Type="success", Duration=3})
    end)
end })

ScriptsTab:CreateButton({ Text = "Ambient Sound Remover", Tooltip = "Removes all ambient sounds in the game", Callback = function()
    local count = 0
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Sound") and v.Playing then v:Stop(); v.Volume = 0; count = count + 1 end
    end
    for _, v in ipairs(game:GetService("SoundService"):GetDescendants()) do
        if v:IsA("Sound") and v.Playing then v:Stop(); v.Volume = 0; count = count + 1 end
    end
    Window:Notify({Title="Sounds Removed", Message="Stopped " .. count .. " sounds", Type="success", Duration=3})
end })

ScriptsTab:CreateButton({ Text = "Remove Fog & Atmosphere", Tooltip = "Strips all atmosphere effects from Lighting", Callback = function()
    local count = 0
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
            if v.Name ~= "SereneUIBlur" then v:Destroy(); count = count + 1 end
        end
    end
    Lighting.FogEnd = 100000
    Window:Notify({Title="Effects Removed", Message="Removed " .. count .. " effects", Type="success", Duration=3})
end })

ScriptsTab:CreateButton({ Text = "Print Workspace Children", Tooltip = "Lists top-level objects to console", Callback = function()
    print("=== Workspace Children ===")
    for _, v in ipairs(Workspace:GetChildren()) do print(" - " .. v.ClassName .. ": " .. v.Name) end
    Window:Notify({Title="Printed", Message="Check console (F9)", Type="info", Duration=2})
end })

ScriptsTab:CreateButton({ Text = "Rejoin with Script", Tooltip = "Rejoins and re-executes Serene Hub", Callback = function()
    Window:Notify({Title="Rejoining...", Type="info", Duration=1})
    task.wait(0.5)
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/refs/heads/main/serenelib.lua"))()')
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end })

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "🔧" })

SettingsTab:CreateSection({ Name = "UI" })
SettingsTab:CreateToggle({ Text = "Background Blur", Default = true, Flag = "BackgroundBlur", Tooltip = "Toggle blur behind menu", Callback = function(s) local b = Lighting:FindFirstChild("SereneUIBlur"); if b then b.Enabled = s end end })
SettingsTab:CreateToggle({ Text = "FPS Counter", Default = false, Flag = "FPSCounter", Tooltip = "Top-left FPS display", Callback = function(s) Settings.Misc.FPSCounter = s end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "World" })
SettingsTab:CreateSlider({ Text = "Gravity", Min = 0, Max = 500, Default = 196, Increment = 1, Flag = "Gravity", Tooltip = "Default: 196", Callback = function(v) Workspace.Gravity = v end })
SettingsTab:CreateToggle({ Text = "Anti AFK", Default = true, Flag = "AntiAFK", Tooltip = "Prevents idle kick", Callback = function(s) Settings.Misc.AntiAFK = s end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Config" })
SettingsTab:CreateButton({ Text = "Save Config", Callback = function() Window:SaveConfig("default"); Window:Notify({Title="Saved", Message="Config saved.", Type="success", Icon="✓", Duration=2}) end })
SettingsTab:CreateButton({ Text = "Load Config", Callback = function() local ok = Window:LoadConfig("default"); Window:Notify({Title = ok and "Loaded" or "Not Found", Message = ok and "Restored." or "No config.", Type = ok and "success" or "warning", Duration=2}) end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Server" })
SettingsTab:CreateButton({ Text = "Rejoin Server", Callback = function() Window:Notify({Title="Rejoining...", Type="info", Duration=1}); task.wait(0.5); TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
SettingsTab:CreateButton({ Text = "Server Hop", Callback = function() Window:Notify({Title="Hopping...", Type="info", Duration=1}); task.wait(0.5); TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
SettingsTab:CreateButton({ Text = "Copy Server ID", Callback = function() if setclipboard then setclipboard(game.JobId); Window:Notify({Title="Copied", Message="Server ID copied.", Type="success", Duration=2}) end end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Player" })
SettingsTab:CreateParagraph({ Title = "Your Info", Content = "User: " .. LocalPlayer.Name .. "\nDisplay: " .. LocalPlayer.DisplayName .. "\nID: " .. LocalPlayer.UserId .. "\nPlace: " .. game.PlaceId })
SettingsTab:CreateButton({ Text = "Copy User ID", Callback = function() if setclipboard then setclipboard(tostring(LocalPlayer.UserId)); Window:Notify({Title="Copied", Type="success", Duration=1}) end end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Player List" })

local playerListDropdown
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end

local selectedPlayer = nil
playerListDropdown = SettingsTab:CreateDropdown({ Text = "Select Player", Items = getPlayerNames(), Flag = "SelectedPlayer", Callback = function(s) selectedPlayer = s end })

SettingsTab:CreateButton({ Text = "TP to Selected Player", Callback = function()
    if not selectedPlayer then Window:Notify({Title="Error", Message="Select a player first.", Type="warning", Duration=2}); return end
    local target = Players:FindFirstChild(selectedPlayer)
    if target then
        local r, tr = GetRootPart(LocalPlayer), GetRootPart(target)
        if r and tr then r.CFrame = tr.CFrame * CFrame.new(0,0,5); Window:Notify({Title="Teleported", Message="To " .. selectedPlayer, Type="success", Duration=2}) end
    end
end })

SettingsTab:CreateButton({ Text = "Spectate Selected", Callback = function()
    if not selectedPlayer then return end
    local target = Players:FindFirstChild(selectedPlayer)
    if target and GetCharacter(target) then Camera.CameraSubject = GetHumanoid(target); Window:Notify({Title="Spectating", Message=selectedPlayer, Type="info", Duration=2}) end
end })

SettingsTab:CreateButton({ Text = "Stop Spectating", Callback = function()
    Camera.CameraSubject = GetHumanoid(LocalPlayer)
    Window:Notify({Title="Stopped", Message="Viewing yourself.", Type="info", Duration=1})
end })

Players.PlayerAdded:Connect(function() task.wait(1); pcall(function() playerListDropdown:SetItems(getPlayerNames()) end) end)
Players.PlayerRemoving:Connect(function() task.wait(1); pcall(function() playerListDropdown:SetItems(getPlayerNames()) end) end)

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "Reset" })
SettingsTab:CreateButton({ Text = "Reset All Settings", Tooltip = "Disable everything", Callback = function()
    Settings.Aimbot.Enabled = false; Settings.Aimbot.TriggerBot = false; Settings.Aimbot.AutoClick = false
    Settings.Hitbox.Enabled = false; Settings.Movement.Speed = false; Settings.Movement.JumpPower = false
    Settings.Movement.InfiniteJump = false; Settings.Movement.LongJump = false; Settings.Movement.Noclip = false
    Settings.Movement.AutoParkour = false; Settings.Movement.AntiVoid = false; Settings.Movement.SpinBot = false
    Settings.Movement.BHop = false; Settings.Movement.AutoStrafe = false
    if flyActive then StopFly() end; Settings.Movement.Fly = false
    Settings.Visuals.ESP = false; Settings.Visuals.Crosshair = false; Settings.Visuals.Fullbright = false
    Settings.Visuals.ServerInfoHUD = false
    ClearESP(); SetFullbright(false); FOVCircle.Visible = false; fpsText.Visible = false
    for i = 1, 4 do crosshairLines[i].Visible = false end; for i = 1, 4 do serverHUD[i].Visible = false end
    Workspace.Gravity = 196.2; Lighting.FogEnd = origLighting.FogEnd; Lighting.ClockTime = origLighting.ClockTime
    Lighting.Ambient = origLighting.Ambient; Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
    local h = GetHumanoid(LocalPlayer); if h then h.WalkSpeed = 16; h.JumpPower = 50 end
    Camera.CameraSubject = GetHumanoid(LocalPlayer)
    Window:Notify({Title="Reset", Message="All defaults restored.", Type="info", Icon="↺", Duration=3})
end })

SettingsTab:CreateDivider()
SettingsTab:CreateSection({ Name = "About" })
SettingsTab:CreateParagraph({ Title = "Serene Hub — Universal", Content = "Built with SereneUI v1.1\nToggle: RightShift  |  Aim: Q\nUniversal hub for most games." })
SettingsTab:CreateLabel({ Text = "Serene Hub v1.2 — SereneUI v1.1" })

Window:Notify({ Title = "Serene Hub", Message = "Loaded successfully. Press RightShift to toggle.", Type = "success", Icon = "✓", Duration = 5 })
