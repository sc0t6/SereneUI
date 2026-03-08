local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow({
    Title = "SereneUI V2",
    Size = UDim2.fromOffset(520,420)
})

local Main = Window:CreateTab("Main")
local Player = Main:CreateSection("Player")

Player:Button({
    Name = "Print Button Test",
    Color = "blue",
    Callback = function()
        print("Hello!")
    end
})

Player:Toggle({
    Name = "Toggle Test",
    Default = false,
    Callback = function(v)
        v = print("ive still not done it")
    end
})

Player:Slider({
    Name = "Slider test",
    Min = 0,
    Max = 100,
    Default = 16,
    Callback = function(v)
        v = print("ive still not done it")
    end
})

Player:Dropdown({
    Name = "DropDown Test",
    Options = {"Test 1","Test 2","Test 3"},
    Callback = function(v)
        v = print("ive still not done it")
    end
})

SereneUI:Notify({
    Title = "SereneUI",
    Text = "Loaded successfully",
    Duration = 4
})
