local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "XSXStyleUI_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.85, 360, 480)
    local height = math.clamp(screenSize.Y * 0.75, 320, 420)

    Main.Size = UDim2.new(0, width, 0, height)
    Main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.Active = true
    local mainCorner = Instance.new("UICorner", Main)
    mainCorner.CornerRadius = UDim.new(0, 16)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Header.BackgroundTransparency = 0.05
    Header.BorderSizePixel = 0
    local headerCorner = Instance.new("UICorner", Header)
    headerCorner.CornerRadius = UDim.new(0, 16)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = title or "XSX Style UI"
    TitleLabel.Size = UDim2.new(1, -96, 1, 0)
    TitleLabel.Position = UDim2.new(0, 24, 0, 0)
    TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local Close = Instance.new("TextButton", Header)
    Close.Text = "×"
    Close.Size = UDim2.new(0, 48, 1, 0)
    Close.Position = UDim2.new(1, -48, 0, 0)
    Close.TextColor3 = Color3.fromRGB(230, 50, 50)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 28
    Close.BackgroundTransparency = 1
    Close.ZIndex = 10
    Close.AutoButtonColor = false
    Close.MouseEnter:Connect(function()
        Close.TextColor3 = Color3.fromRGB(255, 80, 80)
    end)
    Close.MouseLeave:Connect(function()
        Close.TextColor3 = Color3.fromRGB(230, 50, 50)
    end)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton", Header)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 48, 1, 0)
    Minimize.Position = UDim2.new(1, -96, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(180, 180, 180)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 28
    Minimize.BackgroundTransparency = 1
    Minimize.AutoButtonColor = false
    Minimize.MouseEnter:Connect(function()
        Minimize.TextColor3 = Color3.fromRGB(210, 210, 210)
    end)
    Minimize.MouseLeave:Connect(function()
        Minimize.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 48)
    TabHolder.Size = UDim2.new(0, 140, 1, -48)
    TabHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabHolder.BackgroundTransparency = 0.1
    TabHolder.BorderSizePixel = 0
    local tabCorner = Instance.new("UICorner", TabHolder)
    tabCorner.CornerRadius = UDim.new(0, 16)

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 140, 0, 48)
    PageHolder.Size = UDim2.new(1, -140, 1, -48)
    PageHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    PageHolder.BackgroundTransparency = 0.1
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0
    local pageCorner = Instance.new("UICorner", PageHolder)
    pageCorner.CornerRadius = UDim.new(0, 16)

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 12)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, width, 0, 48) or UDim2.new(0, width, 0, height)
        TweenService:Create(Main, TweenInfo.new(0.25), { Size = goalSize }):Play()
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
    end)

    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Notification style XSX
    function Library:Notify(text, duration)
        duration = duration or 3
        local alertFrame = Instance.new("Frame", CoreGui)
        alertFrame.Size = UDim2.new(0, 320, 0, 50)
        alertFrame.Position = UDim2.new(0.5, -160, 0, 20)
        alertFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        alertFrame.BackgroundTransparency = 0.1
        alertFrame.BorderSizePixel = 0
        alertFrame.AnchorPoint = Vector2.new(0.5, 0)
        alertFrame.ZIndex = 9999
        alertFrame.ClipsDescendants = true
        local alertCorner = Instance.new("UICorner", alertFrame)
        alertCorner.CornerRadius = UDim.new(0, 14)

        local label = Instance.new("TextLabel", alertFrame)
        label.Size = UDim2.new(1, -32, 1, 0)
        label.Position = UDim2.new(0, 16, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 20
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = 10000

        alertFrame.Position = UDim2.new(0.5, -160, 0, -70)
        alertFrame.BackgroundTransparency = 1
        label.TextTransparency = 1

        local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenIn = TweenService:Create(alertFrame, tweenInfo, {BackgroundTransparency = 0.1, Position = UDim2.new(0.5, -160, 0, 20)})
        local labelTweenIn = TweenService:Create(label, tweenInfo, {TextTransparency = 0})

        local tweenOut = TweenService:Create(alertFrame, tweenInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -160, 0, -70)})
        local labelTweenOut = TweenService:Create(label, tweenInfo, {TextTransparency = 1})

        tweenIn:Play()
        labelTweenIn:Play()
        tweenIn.Completed:Wait()

        task.wait(duration)

        tweenOut:Play()
        labelTweenOut:Play()
        tweenOut.Completed:Wait()
        alertFrame:Destroy()
    end

    function Library:ChangeTheme(color)
        Main.BackgroundColor3 = color or Color3.fromRGB(20, 20, 20)
        PageHolder.BackgroundColor3 = color:lerp(Color3.new(0, 0, 0), 0.25)
        TabHolder.BackgroundColor3 = color:lerp(Color3.new(0, 0, 0), 0.15)
        Header.BackgroundColor3 = color:lerp(Color3.new(0, 0, 0), 0.15)
    end

    function Library:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function Library:CreateTab(name)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Size = UDim2.new(1, -24, 0, 42)
        Button.Position = UDim2.new(0, 12, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Button.BackgroundTransparency = 0.05
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 18
        Button.AutoButtonColor = false
        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 14)

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            Button.TextColor3 = Color3.fromRGB(0, 170, 255)
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 8
        Page.CanvasSize = UDim2.new(0, 0, 0, 600)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always
        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 16)

        Tabs
