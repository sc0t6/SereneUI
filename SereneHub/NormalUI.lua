local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow("Serene Hub")

local MainTab = Window:CreateTab("Main")

MainTab:Button("Print Hello", function()
print("Hello")
end)

MainTab:Toggle("Toggle Test", false, function(state)
print(state)
end)

Main:Slider("Slider Test",1,10,function(v)
print(v)
end)

SereneUI:Notify("SereneUI","Loaded Successfully!",5)
