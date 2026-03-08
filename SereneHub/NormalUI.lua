local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow({
    Title = "SereneUI V2",
    Size = UDim2.fromOffset(520,420)
})

local Main = Window:CreateTab("Main")
local Player = Main:CreateSection("Player")

Player:Button({
    Name = "Print Hello",
    Color = "blue",
    Callback = function()
        print("Hello!")
    end
})

Player:Toggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        print(v)
    end
})

Player:Slider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Callback = function(v)
        print(v)
    end
})

Player:Dropdown({
    Name = "Fruit",
    Options = {"Apple","Banana","Orange"},
    Callback = function(v)
        print(v)
    end
})

SereneUI:Notify({
    Title = "SereneUI",
    Text = "Loaded successfully",
    Duration = 4
})
