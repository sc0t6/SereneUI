local SereneUI = {}
SereneUI.__index = SereneUI

-- Create ScreenGui
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SereneUI"
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,350,0,400)
Main.Position = UDim2.new(0.5,-175,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Parent = ScreenGui

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.Parent = Main

-- Color presets
local Colors = {
	blue = Color3.fromRGB(0,170,255),
	red = Color3.fromRGB(255,85,85),
	green = Color3.fromRGB(85,255,127),
	gray = Color3.fromRGB(60,60,60)
}

function SereneUI:Label(text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,-10,0,30)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.new(1,1,1)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 14
	Label.Parent = Main
end

function SereneUI:Button(text,color,callback)
	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,-10,0,35)
	Button.BackgroundColor3 = Colors[color] or Colors.gray
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 14
	Button.Text = text
	Button.Parent = Main

	Button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
end

function SereneUI:Toggle(text,callback)

	local Toggle = Instance.new("TextButton")
	Toggle.Size = UDim2.new(1,-10,0,35)
	Toggle.BackgroundColor3 = Colors.gray
	Toggle.Text = text.." : OFF"
	Toggle.TextColor3 = Color3.new(1,1,1)
	Toggle.Parent = Main

	local state = false

	Toggle.MouseButton1Click:Connect(function()
		state = not state
		Toggle.Text = text.." : "..(state and "ON" or "OFF")

		if callback then
			callback(state)
		end
	end)

end

function SereneUI:Textbox(placeholder,callback)

	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(1,-10,0,35)
	Box.BackgroundColor3 = Colors.gray
	Box.Text = ""
	Box.PlaceholderText = placeholder
	Box.TextColor3 = Color3.new(1,1,1)
	Box.Parent = Main

	Box.FocusLost:Connect(function()
		if callback then
			callback(Box.Text)
		end
	end)

end

function SereneUI:Slider(text,min,max,callback)

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1,-10,0,40)
	Frame.BackgroundColor3 = Colors.gray
	Frame.Parent = Main

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1,0,1,0)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.new(1,1,1)
	Label.Text = text.." : "..min
	Label.Parent = Frame

	local value = min

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			local pos = input.Position.X
			local size = Frame.AbsoluteSize.X
			local start = Frame.AbsolutePosition.X

			value = math.floor(((pos-start)/size)*(max-min)+min)

			Label.Text = text.." : "..value

			if callback then
				callback(value)
			end

		end
	end)

end

function SereneUI:ColorPicker(callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1,-10,0,35)
	Button.BackgroundColor3 = Color3.fromRGB(0,255,255)
	Button.Text = "Pick Color"
	Button.TextColor3 = Color3.new(0,0,0)
	Button.Parent = Main

	Button.MouseButton1Click:Connect(function()

		local color = Color3.fromRGB(
			math.random(0,255),
			math.random(0,255),
			math.random(0,255)
		)

		Button.BackgroundColor3 = color

		if callback then
			callback(color)
		end

	end)

end

return setmetatable({},SereneUI)
