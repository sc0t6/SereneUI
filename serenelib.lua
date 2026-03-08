local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/refs/heads/main/serenelib.lua"))()

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

MainTab:CreateDropdown({
    Text     = "Team",
    Items    = { "Red", "Blue", "Green", "Yellow" },
    Default  = "Red",
    Flag     = "Team",
    Callback = function(selected)
        print("Team:", selected)
    end,
})

MainTab:CreateDivider()

MainTab:CreateButton({
    Text     = "Print Hello",
    Tooltip  = "Prints a greeting to the console",
    Callback = function()
        print("Hello from SereneUI!")
    end,
})

MainTab:CreateKeybind({
    Text     = "Speed Toggle",
    Default  = Enum.KeyCode.F,
    Flag     = "SpeedKey",
    Callback = function(key)
        print("Speed key pressed:", key.Name)
    end,
})

MainTab:CreateTextBox({
    Text        = "Username",
    Placeholder = "Enter name...",
    Default     = "",
    Callback    = function(text, enter)
        if enter then print("Submitted:", text) end
    end,
})

local VisualsTab = Window:CreateTab({ Name = "Visuals", Icon = "🎨" })

VisualsTab:CreateSection({ Name = "Colors" })

VisualsTab:CreateColorPicker({
    Text     = "ESP Color",
    Default  = Color3.fromRGB(0, 255, 128),
    Flag     = "ESPColor",
    Callback = function(color)
        print("ESP Color:", color)
    end,
})

VisualsTab:CreateToggle({
    Text     = "Box ESP",
    Default  = true,
    Flag     = "BoxESP",
    Callback = function(state)
        print("Box ESP:", state)
    end,
})

VisualsTab:CreateSlider({
    Text      = "ESP Distance",
    Min       = 100,
    Max       = 2000,
    Default   = 500,
    Increment = 50,
    Suffix    = " studs",
    Flag      = "ESPDistance",
    Callback  = function(val)
        print("ESP dist:", val)
    end,
})

local loadingBar = VisualsTab:CreateProgressBar({
    Text    = "Loading Assets",
    Default = 0,
})

task.defer(function()
    for i = 1, 20 do
        task.wait(0.15)
        loadingBar:SetValue(i / 20)
    end
end)

VisualsTab:CreateParagraph({
    Title   = "About",
    Content = "SereneUI v1.1 — Close the UI and use the side "
            .. "button or press RightShift to reopen it.",
})

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "🔧" })

SettingsTab:CreateSection({ Name = "Configuration" })

SettingsTab:CreateTextBox({
    Text        = "Config Name",
    Placeholder = "my-config",
    Default     = "default",
    Callback    = function() end,
})

SettingsTab:CreateButton({
    Text     = "Save Config",
    Tooltip  = "Save current settings to file",
    Callback = function()
        Window:SaveConfig("default")
        Window:Notify({
            Title    = "Config Saved",
            Message  = "Your settings have been saved.",
            Type     = "success",
            Icon     = "✓",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateButton({
    Text     = "Load Config",
    Tooltip  = "Load settings from file",
    Callback = function()
        local ok = Window:LoadConfig("default")
        Window:Notify({
            Title    = ok and "Config Loaded" or "No Config Found",
            Message  = ok and "Settings restored." or "Save a config first.",
            Type     = ok and "success" or "warning",
            Icon     = ok and "✓" or "!",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateSection({ Name = "Info" })

SettingsTab:CreateLabel({ Text = "Made with SereneUI v1.1" })

Window:Notify({
    Title    = "Welcome",
    Message  = "Serene Hub loaded. Press RightShift to toggle.",
    Type     = "success",
    Icon     = "✓",
    Duration = 5,
})
