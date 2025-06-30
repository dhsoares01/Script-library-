local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "OrionLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)

    -- Tornar responsivo para mobile, usar uma porcentagem da tela
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.9, 300, 450)
    local height = math.clamp(screenSize.Y * 0.75, 300, 380)

    Main.Size = UDim2.new(0, width, 0, height)
    Main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 12)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = title or "Orion UI"
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", Header)
    Close.Text = "×"
    Close.Size = UDim2.new(0, 40, 1, 0)
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.TextColor3 = Color3.fromRGB(255, 85, 85)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 24
    Close.BackgroundTransparency = 1
    Close.ZIndex = 2
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton", Header)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 40, 1, 0)
    Minimize.Position = UDim2.new(1, -80, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 24
    Minimize.BackgroundTransparency = 1

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.Size = UDim2.new(0, 120, 1, -40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabHolder.BorderSizePixel = 0

    local TabHolderCorner = Instance.new("UICorner", TabHolder)
    TabHolderCorner.CornerRadius = UDim.new(0, 12)

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 120, 0, 40)
    PageHolder.Size = UDim2.new(1, -120, 1, -40)
    PageHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0

    local PageHolderCorner = Instance.new("UICorner", PageHolder)
    PageHolderCorner.CornerRadius = UDim.new(0, 12)

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, width, 0, 40) or UDim2.new(0, width, 0, height)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = goalSize}):Play()
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
    end)

    -- Drag support (mouse + touch)
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

    -- Criar tabs
    function Library:CreateTab(name)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Size = UDim2.new(1, -16, 0, 36)
        Button.Position = UDim2.new(0, 8, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false

        local BtnCorner = Instance.new("UICorner", Button)
        BtnCorner.CornerRadius = UDim.new(0, 10)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 8
        Page.CanvasSize = UDim2.new(0, 0, 0, 600)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always

        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 12)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        -- Ativa primeira aba criada automaticamente
        if #PageHolder:GetChildren() == 0 then
            Button:CaptureFocus()
            Page.Visible = true
        end

        local tabObj = {}

        function tabObj:AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -20, 0, 26)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            return lbl
        end

        function tabObj:AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -20, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.Text = text
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 16
            btn.AutoButtonColor = true

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 10)

            btn.MouseButton1Click:Connect(callback)

            -- Efeito hover mobile e desktop
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end)

            return btn
        end

        function tabObj:AddToggle(text, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -20, 0, 36)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggle = Instance.new("TextButton", container)
            toggle.Size = UDim2.new(0, 40, 0, 20)
            toggle.Position = UDim2.new(1, -40, 0.5, -10)
            toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
            toggle.AutoButtonColor = false
            toggle.Text = ""
            toggle.ClipsDescendants = true

            local toggleCorner = Instance.new("UICorner", toggle)
            toggleCorner.CornerRadius = UDim.new(0, 10)

            local circle = Instance.new("Frame", toggle)
            circle.Size = UDim2.new(0, 16, 0, 16)
            circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local circleCorner = Instance.new("UICorner", circle)
            circleCorner.CornerRadius = UDim.new(1, 0)

            local toggled = default

            toggle.MouseButton1Click:Connect(function()
                toggled = not toggled
                toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
                circle:TweenPosition(toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                if callback then
                    callback(toggled)
                end
            end)

            return container
        end

        function tabObj:AddSlider(text, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -20, 0, 50)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(230, 230, 230)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBar = Instance.new("Frame", container)
            sliderBar.Size = UDim2.new(1, 0, 0, 16)
            sliderBar.Position = UDim2.new(0, 0, 0, 30)
            sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBar.ClipsDescendants = true

            local sliderCorner = Instance.new("UICorner", sliderBar)
            sliderCorner.CornerRadius = UDim.new(0, 10)

            local sliderFill = Instance.new("Frame", sliderBar)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

            local fillCorner = Instance.new("UICorner", sliderFill)
            fillCorner.CornerRadius = UDim.new(0, 10)

            local dragging = false

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local mouseX = input.Position.X
                    local barPos = sliderBar.AbsolutePosition.X
                    local barSize = sliderBar.AbsoluteSize.X
                    local relativeX = math.clamp(mouseX - barPos, 0, barSize)
                    local percent = relativeX / barSize
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    local value = math.floor(min + (max - min) * percent)
                    label.Text = text .. ": " .. tostring(value)
                    if callback then callback(value) end
                end
            end)

            sliderBar.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mouseX = input.Position.X
                    local barPos = sliderBar.AbsolutePosition.X
                    local barSize = sliderBar.AbsoluteSize.X
                    local relativeX = math.clamp(mouseX - barPos, 0, barSize)
                    local percent = relativeX / barSize
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    local value = math.floor(min + (max - min) * percent)
                    label.Text = text .. ": " .. tostring(value)
                    if callback then callback(value) end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return container
        end

        return tabObj
    end

    return Library
end

return Library
