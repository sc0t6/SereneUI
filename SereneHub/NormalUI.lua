local SereneUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sc0t6/SereneUI/main/serenelib.lua"))()

local Window = SereneUI:CreateWindow("SereneUI Demo")

local MainTab = Window:CreateTab("Main")
local Section = MainTab:CreateSection("Player")

Section:Button("Print Hello","blue",function()
	print("Hello!")
end)

Section:Toggle("Fly",function(state)
	print("Fly:",state)
end)

Section:Slider("Speed",0,100,function(value)
	print(value)
end)

Section:Textbox("Enter Name",function(text)
	print(text)
end)

Section:Dropdown("Select Fruit",{"Apple","Banana","Orange"},function(choice)
	print(choice)
end)

SereneUI:Notify("SereneUI","Loaded Successfully!",5)
