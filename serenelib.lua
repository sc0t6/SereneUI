local SereneUI = {}
SereneUI.__index = SereneUI

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Accent = Color3.fromRGB(120,170,255)

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SereneUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Background blur
local Blur = Instance.new("BlurEffect")
Blur.Size = 8
Blur.Parent = game.Lighting

-- Notifications
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0,320,1,0)
NotifHolder.Position = UDim2.new(1,-330,0,20)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0,10)
List.Parent = NotifHolder

function SereneUI:Notify(title,text,time)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1,0,0,70)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
Frame.Parent = NotifHolder

Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,10)

local Stroke = Instance.new("UIStroke",Frame)
Stroke.Color = Accent
Stroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Text = title
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,10,0,6)
Title.Size = UDim2.new(1,-20,0,22)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Text = Instance.new("TextLabel")
Text.Text = text
Text.Font = Enum.Font.Gotham
Text.TextSize = 14
Text.TextColor3 = Color3.fromRGB(200,200,200)
Text.BackgroundTransparency = 1
Text.Position = UDim2.new(0,10,0,30)
Text.Size = UDim2.new(1,-20,0,20)
Text.TextXAlignment = Enum.TextXAlignment.Left
Text.Parent = Frame

Frame.Position = UDim2.new(1,0,0,0)

TweenService:Create(Frame,TweenInfo.new(.35),{
Position = UDim2.new(0,0,0,0)
}):Play()

task.delay(time or 4,function()

TweenService:Create(Frame,TweenInfo.new(.3),{
Position = UDim2.new(1,0,0,0)
}):Play()

task.wait(.3)
Frame:Destroy()

end)

end

-- Window
function SereneUI:CreateWindow(name)

local Window = {}

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,560,0,380)
Main.Position = UDim2.new(.5,-280,.5,-190)
Main.BackgroundColor3 = Color3.fromRGB(24,24,30)
Main.Parent = ScreenGui

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,14)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Color = Color3.fromRGB(60,60,80)

-- Gradient
local Gradient = Instance.new("UIGradient",Main)
Gradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromRGB(28,28,36)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,24))
}

-- Title bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,40)
Top.BackgroundTransparency = 1
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Text = name
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,15,0,0)
Title.Size = UDim2.new(1,0,1,0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

-- Draggable
local dragging = false
local dragStart
local startPos

Top.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 then

dragging = true
dragStart = input.Position
startPos = Main.Position

end

end)

Top.InputEnded:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end

end)

UIS.InputChanged:Connect(function(input)

if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

local delta = input.Position - dragStart

Main.Position =
UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,
startPos.Y.Scale,startPos.Y.Offset + delta.Y)

end

end)

-- Tabs area
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0,150,1,-40)
Tabs.Position = UDim2.new(0,0,0,40)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local TabLayout = Instance.new("UIListLayout",Tabs)
TabLayout.Padding = UDim.new(0,6)

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1,-150,1,-40)
Pages.Position = UDim2.new(0,150,0,40)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

function Window:CreateTab(name)

local Tab = {}

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1,-10,0,36)
Button.Position = UDim2.new(0,5,0,0)
Button.Text = name
Button.BackgroundColor3 = Color3.fromRGB(40,40,50)
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.Gotham
Button.TextSize = 14
Button.Parent = Tabs

Instance.new("UICorner",Button).CornerRadius = UDim.new(0,8)

local Page = Instance.new("ScrollingFrame")
Page.Visible = false
Page.Size = UDim2.new(1,0,1,0)
Page.BackgroundTransparency = 1
Page.Parent = Pages
Page.CanvasSize = UDim2.new(0,0,5,0)

local Layout = Instance.new("UIListLayout",Page)
Layout.Padding = UDim.new(0,8)

Button.MouseButton1Click:Connect(function()

for _,v in pairs(Pages:GetChildren()) do
if v:IsA("ScrollingFrame") then
v.Visible = false
end
end

Page.Visible = true

end)

-- Better Button
function Tab:Button(text,callback)

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1,-20,0,38)
Btn.Position = UDim2.new(0,10,0,0)
Btn.Text = text
Btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
Btn.TextColor3 = Color3.new(1,1,1)
Btn.Font = Enum.Font.Gotham
Btn.TextSize = 14
Btn.Parent = Page

Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,10)

Btn.MouseEnter:Connect(function()

TweenService:Create(Btn,TweenInfo.new(.2),{
BackgroundColor3 = Accent
}):Play()

end)

Btn.MouseLeave:Connect(function()

TweenService:Create(Btn,TweenInfo.new(.2),{
BackgroundColor3 = Color3.fromRGB(35,35,45)
}):Play()

end)

Btn.MouseButton1Click:Connect(function()

if callback then
callback()
end

end)

end

return Tab

end

return Window

end

return SereneUI
