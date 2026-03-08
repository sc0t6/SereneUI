local SereneUI = {}
SereneUI.__index = SereneUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SereneUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Notification Container
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0,300,1,0)
NotifHolder.Position = UDim2.new(1,-310,0,10)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local Layout = Instance.new("UIListLayout", NotifHolder)
Layout.Padding = UDim.new(0,6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Notification Function
function SereneUI:Notify(title,text,time)

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1,0,0,60)
    Notif.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Notif.Parent = NotifHolder

    local Corner = Instance.new("UICorner",Notif)
    Corner.CornerRadius = UDim.new(0,8)

    local Title = Instance.new("TextLabel")
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.new(1,1,1)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,-10,0,20)
    Title.Position = UDim2.new(0,5,0,5)
    Title.Parent = Notif

    local Text = Instance.new("TextLabel")
    Text.Text = text
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 13
    Text.TextColor3 = Color3.fromRGB(200,200,200)
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1,-10,0,20)
    Text.Position = UDim2.new(0,5,0,30)
    Text.Parent = Notif

    task.delay(time or 3,function()
        Notif:Destroy()
    end)

end

-- Create Window
function SereneUI:CreateWindow(name)

    local Window = {}

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,500,0,350)
    Main.Position = UDim2.new(0.5,-250,0.5,-175)
    Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Main.Parent = ScreenGui

    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(1,0,0,30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Main

    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(0,120,1,-30)
    Tabs.Position = UDim2.new(0,0,0,30)
    Tabs.BackgroundTransparency = 1
    Tabs.Parent = Main

    local TabLayout = Instance.new("UIListLayout",Tabs)

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1,-120,1,-30)
    Pages.Position = UDim2.new(0,120,0,30)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    function Window:CreateTab(tabName)

        local Tab = {}

        local Button = Instance.new("TextButton")
        Button.Text = tabName
        Button.Size = UDim2.new(1,0,0,35)
        Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
        Button.TextColor3 = Color3.new(1,1,1)
        Button.Parent = Tabs
        Instance.new("UICorner",Button)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Pages
        Page.CanvasSize = UDim2.new(0,0,5,0)

        local Layout = Instance.new("UIListLayout",Page)
        Layout.Padding = UDim.new(0,6)

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        -- Button
        function Tab:Button(name,callback)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,-10,0,35)
            Btn.Position = UDim2.new(0,5,0,0)
            Btn.Text = name
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Parent = Page

            Instance.new("UICorner",Btn)

            Btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

        end

        -- Toggle
        function Tab:Toggle(name,default,callback)

            local State = default

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,-10,0,35)
            Btn.Text = name.." : "..tostring(State)
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Parent = Page
            Instance.new("UICorner",Btn)

            Btn.MouseButton1Click:Connect(function()

                State = not State
                Btn.Text = name.." : "..tostring(State)

                if callback then
                    callback(State)
                end

            end)

        end

        -- Slider
        function Tab:Slider(name,min,max,callback)

            local Value = min

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,-10,0,35)
            Btn.Text = name.." : "..Value
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Parent = Page
            Instance.new("UICorner",Btn)

            Btn.MouseButton1Click:Connect(function()

                Value = math.clamp(Value+1,min,max)
                Btn.Text = name.." : "..Value

                if callback then
                    callback(Value)
                end

            end)

        end

        return Tab
    end

    return Window
end

return SereneUI
