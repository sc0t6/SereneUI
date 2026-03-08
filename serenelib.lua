local SereneUI = {}

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIS = game:GetService("UserInputService")

local Colors = {
	blue = Color3.fromRGB(0,170,255),
	red = Color3.fromRGB(255,80,80),
	green = Color3.fromRGB(80,255,120),
	gray = Color3.fromRGB(50,50,50)
}

-- SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SereneUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- NOTIFICATION HOLDER
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0,300,1,0)
NotifHolder.Position = UDim2.new(1,-310,0,10)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0,5)
NotifLayout.Parent = NotifHolder

function SereneUI:Notify(title,text,time)

	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(1,0,0,60)
	Notif.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Notif.Parent = NotifHolder

	local Title = Instance.new("TextLabel")
	Title.Text = title
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Color3.new(1,1,1)
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1,-10,0,20)
	Title.Position = UDim2.new(0,5,0,5)
	Title.Parent = Notif

	local Desc = Instance.new("TextLabel")
	Desc.Text = text
	Desc.Font = Enum.Font.Gotham
	Desc.TextSize = 14
	Desc.TextColor3 = Color3.fromRGB(200,200,200)
	Desc.BackgroundTransparency = 1
	Desc.Size = UDim2.new(1,-10,0,20)
	Desc.Position = UDim2.new(0,5,0,30)
	Desc.Parent = Notif

	task.delay(time or 5,function()
		Notif:Destroy()
	end)

end

function SereneUI:CreateWindow(title)

	local Window = {}

	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0,500,0,400)
	Main.Position = UDim2.new(0.5,-250,0.5,-200)
	Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Main.Parent = ScreenGui

	local Top = Instance.new("TextLabel")
	Top.Size = UDim2.new(1,0,0,30)
	Top.BackgroundColor3 = Color3.fromRGB(20,20,20)
	Top.Text = title
	Top.Font = Enum.Font.GothamBold
	Top.TextColor3 = Color3.new(1,1,1)
	Top.Parent = Main

	-- DRAGGING

	local dragging
	local dragStart
	local startPos

	Top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)

		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

			local delta = input.Position - dragStart

			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

		end

	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local TabHolder = Instance.new("Frame")
	TabHolder.Size = UDim2.new(0,120,1,-30)
	TabHolder.Position = UDim2.new(0,0,0,30)
	TabHolder.BackgroundColor3 = Color3.fromRGB(20,20,20)
	TabHolder.Parent = Main

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1,-120,1,-30)
	Content.Position = UDim2.new(0,120,0,30)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Parent = TabHolder

	function Window:CreateTab(name)

		local Tab = {}
		local TabButton = Instance.new("TextButton")

		TabButton.Size = UDim2.new(1,0,0,30)
		TabButton.Text = name
		TabButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
		TabButton.TextColor3 = Color3.new(1,1,1)
		TabButton.Parent = TabHolder

		local Page = Instance.new("Frame")
		Page.Size = UDim2.new(1,0,1,0)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.Parent = Content

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0,5)
		Layout.Parent = Page

		TabButton.MouseButton1Click:Connect(function()

			for _,v in pairs(Content:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end

			Page.Visible = true

		end)

		function Tab:CreateSection(title)

			local Section = {}

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1,-10,0,200)
			Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
			Frame.Parent = Page

			local Title = Instance.new("TextLabel")
			Title.Text = title
			Title.Font = Enum.Font.GothamBold
			Title.TextColor3 = Color3.new(1,1,1)
			Title.BackgroundTransparency = 1
			Title.Size = UDim2.new(1,0,0,20)
			Title.Parent = Frame

			local Layout = Instance.new("UIListLayout")
			Layout.Padding = UDim.new(0,4)
			Layout.Parent = Frame

			function Section:Button(text,color,callback)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1,-10,0,30)
				Btn.BackgroundColor3 = Colors[color] or Colors.gray
				Btn.Text = text
				Btn.TextColor3 = Color3.new(1,1,1)
				Btn.Parent = Frame

				Btn.MouseButton1Click:Connect(function()
					if callback then callback() end
				end)

			end

			function Section:Toggle(text,callback)

				local state = false

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1,-10,0,30)
				Btn.BackgroundColor3 = Colors.gray
				Btn.Text = text.." : OFF"
				Btn.TextColor3 = Color3.new(1,1,1)
				Btn.Parent = Frame

				Btn.MouseButton1Click:Connect(function()

					state = not state
					Btn.Text = text.." : "..(state and "ON" or "OFF")

					if callback then
						callback(state)
					end

				end)

			end

			function Section:Textbox(name,callback)

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1,-10,0,30)
				Box.PlaceholderText = name
				Box.Text = ""
				Box.BackgroundColor3 = Colors.gray
				Box.TextColor3 = Color3.new(1,1,1)
				Box.Parent = Frame

				Box.FocusLost:Connect(function()
					if callback then callback(Box.Text) end
				end)

			end

			function Section:Slider(text,min,max,callback)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1,-10,0,30)
				Btn.BackgroundColor3 = Colors.gray
				Btn.Text = text.." : "..min
				Btn.TextColor3 = Color3.new(1,1,1)
				Btn.Parent = Frame

				local value = min

				Btn.MouseButton1Click:Connect(function()

					value += 1

					if value > max then
						value = min
					end

					Btn.Text = text.." : "..value

					if callback then callback(value) end

				end)

			end

			function Section:Dropdown(text,options,callback)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1,-10,0,30)
				Btn.BackgroundColor3 = Colors.gray
				Btn.Text = text
				Btn.TextColor3 = Color3.new(1,1,1)
				Btn.Parent = Frame

				Btn.MouseButton1Click:Connect(function()

					local choice = options[math.random(1,#options)]
					Btn.Text = text.." : "..choice

					if callback then callback(choice) end

				end)

			end

			return Section

		end

		return Tab

	end

	return Window

end

return SereneUI
