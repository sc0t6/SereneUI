local SereneUI = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Colors = {
    Background = Color3.fromRGB(22,22,22),
    Section = Color3.fromRGB(30,30,30),
    Element = Color3.fromRGB(40,40,40),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(235,235,235)
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SereneUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-------------------------------------------------
-- Notification System
-------------------------------------------------

function SereneUI:Notify(cfg)

    local Title = cfg.Title or "Notification"
    local Text = cfg.Text or ""
    local Duration = cfg.Duration or 3

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(260,70)
    Frame.Position = UDim2.new(1,-280,1,-90)
    Frame.BackgroundColor3 = Colors.Section
    Frame.Parent = ScreenGui

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-20,0,24)
    TitleLabel.Position = UDim2.fromOffset(10,6)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1,-20,0,20)
    Desc.Position = UDim2.fromOffset(10,30)
    Desc.Text = Text
    Desc.TextColor3 = Color3.fromRGB(200,200,200)
    Desc.BackgroundTransparency = 1
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 14
    Desc.Parent = Frame

    Frame.Position = Frame.Position + UDim2.fromOffset(300,0)

    TweenService:Create(Frame,TweenInfo.new(.35),{
        Position = UDim2.new(1,-280,1,-90)
    }):Play()

    task.delay(Duration,function()

        TweenService:Create(Frame,TweenInfo.new(.35),{
            Position = Frame.Position + UDim2.fromOffset(300,0)
        }):Play()

        task.wait(.35)
        Frame:Destroy()

    end)

end

-------------------------------------------------
-- Window Creation
-------------------------------------------------

function SereneUI:CreateWindow(cfg)

    local Window = {}

    local Size = cfg.Size or UDim2.fromOffset(500,400)
    local Title = cfg.Title or "SereneUI"

    local Main = Instance.new("Frame")
    Main.Size = Size
    Main.Position = UDim2.new(.5,-Size.X.Offset/2,.5,-Size.Y.Offset/2)
    Main.BackgroundColor3 = Colors.Background
    Main.Parent = ScreenGui

    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,36)
    Top.BackgroundColor3 = Colors.Section
    Top.Parent = Main
    Instance.new("UICorner",Top).CornerRadius = UDim.new(0,10)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1,0,1,0)
    TitleLabel.Parent = Top

    -------------------------------------------------
    -- Dragging
    -------------------------------------------------

    local dragging,dragStart,startPos

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

    -------------------------------------------------
    -- Tab System
    -------------------------------------------------

    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(0,120,1,-36)
    Tabs.Position = UDim2.new(0,0,0,36)
    Tabs.BackgroundColor3 = Colors.Section
    Tabs.Parent = Main

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1,-120,1,-36)
    Pages.Position = UDim2.new(0,120,0,36)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    local TabLayout = Instance.new("UIListLayout",Tabs)

    -------------------------------------------------
    -- Create Tab
    -------------------------------------------------

    function Window:CreateTab(name)

        local Tab = {}

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1,0,0,32)
        Button.Text = name
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.TextColor3 = Colors.Text
        Button.BackgroundColor3 = Colors.Element
        Button.Parent = Tabs

        local Page = Instance.new("Frame")
        Page.Size = UDim2.new(1,0,1,0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = Pages

        local Layout = Instance.new("UIListLayout",Page)
        Layout.Padding = UDim.new(0,8)

        Button.MouseButton1Click:Connect(function()

            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end

            Page.Visible = true

        end)

        -------------------------------------------------
        -- Section
        -------------------------------------------------

        function Tab:CreateSection(title)

            local Section = {}

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1,-12,0,160)
            Frame.BackgroundColor3 = Colors.Section
            Frame.Parent = Page
            Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

            local Label = Instance.new("TextLabel")
            Label.Text = title
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextColor3 = Colors.Text
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1,-10,0,22)
            Label.Position = UDim2.fromOffset(8,4)
            Label.Parent = Frame

            local Layout = Instance.new("UIListLayout",Frame)
            Layout.Padding = UDim.new(0,6)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder

            -------------------------------------------------
            -- Button
            -------------------------------------------------

            function Section:Button(cfg)

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,-16,0,30)
                Btn.Position = UDim2.fromOffset(8,0)
                Btn.BackgroundColor3 = Colors.Element
                Btn.Text = cfg.Name
                Btn.TextColor3 = Colors.Text
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Btn.Parent = Frame
                Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,6)

                Btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        cfg.Callback()
                    end
                end)

            end

            -------------------------------------------------

            return Section

        end

        return Tab

    end

    return Window

end

return SereneUI
