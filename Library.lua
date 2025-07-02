local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "OrionLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.9, 380, 480)  -- largura um pouco maior
    local height = math.clamp(screenSize.Y * 0.75, 380, 460) -- altura um pouco maior

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, width, 0, height)
    Main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 32)  -- tom mais escuro, menos saturado
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true

    -- Sombra leve para o painel
    local Shadow = Instance.new("ImageLabel", Main)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://12130856075" -- sombra circular sutil
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.85
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 20)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 46)  -- tom suave
    Header.BorderSizePixel = 0
    Header.ZIndex = 2

    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 20)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = title or "Orion UI"
    Title.Size = UDim2.new(1, -110, 1, 0)
    Title.Position = UDim2.new(0, 25, 0, 0)
    Title.TextColor3 = Color3.fromRGB(230, 230, 235)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextStrokeTransparency = 0.75  -- texto com leve sombra para melhor leitura

    local Close = Instance.new("TextButton", Header)
    Close.Text = "✕"
    Close.Size = UDim2.new(0, 48, 1, 0)
    Close.Position = UDim2.new(1, -52, 0, 0)
    Close.TextColor3 = Color3.fromRGB(255, 85, 85)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 26
    Close.BackgroundTransparency = 1
    Close.AutoButtonColor = false
    Close.ZIndex = 3
    Close.Cursor = "PointingHand"

    Close.MouseEnter:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
    end)
    Close.MouseLeave:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 85, 85)}):Play()
    end)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton", Header)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 48, 1, 0)
    Minimize.Position = UDim2.new(1, -100, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(180, 180, 190)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 28
    Minimize.BackgroundTransparency = 1
    Minimize.AutoButtonColor = false
    Minimize.Cursor = "PointingHand"
    Minimize.ZIndex = 3

    Minimize.MouseEnter:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(210, 210, 220)}):Play()
    end)
    Minimize.MouseLeave:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
    end)

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 48)
    TabHolder.Size = UDim2.new(0, 150, 1, -48)
    TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    TabHolder.BorderSizePixel = 0

    local TabHolderCorner = Instance.new("UICorner", TabHolder)
    TabHolderCorner.CornerRadius = UDim.new(0, 20)

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 150, 0, 48)
    PageHolder.Size = UDim2.new(1, -150, 1, -48)
    PageHolder.BackgroundColor3 = Color3.fromRGB(38, 38, 47)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0

    local PageHolderCorner = Instance.new("UICorner", PageHolder)
    PageHolderCorner.CornerRadius = UDim.new(0, 20)

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 14)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, width, 0, 48) or UDim2.new(0, width, 0, height)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = goalSize}):Play()
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
        Button.Size = UDim2.new(1, -28, 0, 44)
        Button.Position = UDim2.new(0, 14, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(220, 220, 230)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 17
        Button.AutoButtonColor = false
        Button.Cursor = "PointingHand"

        local BtnCorner = Instance.new("UICorner", Button)
        BtnCorner.CornerRadius = UDim.new(0, 16)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 9
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        Page.BorderSizePixel = 0
        Page.ZIndex = 3

        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 16)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true

            -- Destaque do botão ativo com cor azul vibrante e sombra leve
            for _, btn in pairs(TabHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}):Play()
                    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
                    btn.TextStrokeTransparency = 1
                end
            end
            TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            Button.TextColor3 = Color3.fromRGB(240, 240, 245)
            Button.TextStrokeTransparency = 0.8
        end)

        if #PageHolder:GetChildren() == 0 then
            Button:CaptureFocus()
            Page.Visible = true
            Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Button.TextColor3 = Color3.fromRGB(240, 240, 245)
            Button.TextStrokeTransparency = 0.8
        end

        local tabObj = {}

        function tabObj:AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -30, 0, 26)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(195, 195, 210)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            return lbl
        end

        function tabObj:AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -30, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(245, 245, 245)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 17
            btn.AutoButtonColor = true
            btn.Cursor = "PointingHand"

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 18)

            btn.MouseButton1Click:Connect(callback)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
            end)

            return btn
        end

        function tabObj:AddToggle(text, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -30, 0, 38)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextColor3 = Color3.fromRGB(240, 240, 245)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggle = Instance.new("TextButton", container)
            toggle.Size = UDim2.new(0, 48, 0, 26)
            toggle.Position = UDim2.new(1, -50, 0.5, -13)
            toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
            toggle.AutoButtonColor = false
            toggle.Text = ""
            toggle.ClipsDescendants = true
            toggle.Cursor = "PointingHand"

            local toggleCorner = Instance.new("UICorner", toggle)
            toggleCorner.CornerRadius = UDim.new(0, 16)

            local circle = Instance.new("Frame", toggle)
            circle.Size = UDim2.new(0, 22, 0, 22)
            circle.Position = default and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
            circle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)

            local circleCorner = Instance.new("UICorner", circle)
            circleCorner.CornerRadius = UDim.new(1, 0)

            local toggled = default

            toggle.MouseButton1Click:Connect(function()
                toggled = not toggled
                toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
                circle:TweenPosition(toggled and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
                if callback then
                    callback(toggled)
                end
            end)

            return container
        end

        function tabObj:AddSlider(text, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -30, 0, 52)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = text .. ": " .. tostring(default)
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextColor3 = Color3.fromRGB(240, 240, 245)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 22)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBar = Instance.new("Frame", container)
            sliderBar.Size = UDim2.new(1, 0, 0, 18)
            sliderBar.Position = UDim2.new(0, 0, 0, 30)
            sliderBar.BackgroundColor3 = Color3.fromRGB(42, 42, 58)
            sliderBar.ClipsDescendants = true
            sliderBar.ZIndex = 6
            sliderBar.Cursor = "PointingHand"

            local sliderCorner = Instance.new("UICorner", sliderBar)
            sliderCorner.CornerRadius = UDim.new(0, 18)

            local sliderFill = Instance.new("Frame", sliderBar)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            sliderFill.ZIndex = 7

            local fillCorner = Instance.new("UICorner", sliderFill)
            fillCorner.CornerRadius = UDim.new(0, 18)

            local dragging = false

            local function updateSlider(inputX)
                local barPos = sliderBar.AbsolutePosition.X
                local barSize = sliderBar.AbsoluteSize.X
                local relativeX = math.clamp(inputX - barPos, 0, barSize)
                local percent = relativeX / barSize
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(min + (max - min) * percent)
                label.Text = text .. ": " .. tostring(value)
                if callback then callback(value) end
            end

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position.X)
                end
            end)

            sliderBar.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
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
