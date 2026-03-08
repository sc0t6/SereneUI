local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow({
    Title         = "Serene Hub",
    Subtitle      = "v1.1",
    Size          = UDim2.new(0, 580, 0, 420),
    AccentColor   = Color3.fromRGB(100, 130, 255),
    ToggleKey     = Enum.KeyCode.RightShift,
    BackgroundBlur= true,
    UIScale       = 1,
    ConfigName    = "SereneHub",
})


local MainTab = Window:CreateTab({ Name = "Main", Icon = "⚙" })

MainTab:CreateSection({ Name = "Features" })

MainTab:CreateToggle({
    Text     = "God Mode",
    Default  = false,
    Flag     = "GodMode",
    Callback = function(state)
        print("God Mode:", state)
    end,
})

MainTab:CreateSlider({
    Text      = "Walk Speed",
    Min       = 16,
    Max       = 200,
    Default   = 16,
    Increment = 1,
    Suffix    = "",
    Flag      = "WalkSpeed",
    Callback  = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

Window:Notify({
    Title    = "Welcome",
    Message  = "Serene Hub loaded. Press RightShift to toggle.",
    Type     = "success",
    Icon     = "✓",
    Duration = 5,
})
