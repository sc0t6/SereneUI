local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/refs/heads/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow("SereneUI")
local MainTab = Window:CreateTab("Main")
MainTab:Label("Serene UI has Loaded.")

MainTab:Button("Printing","blue",function()
    print("Test Button")
end)
