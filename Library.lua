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
    local width = math.clamp(screenSize.X * 0.9, 350, 460)
    local height = math.clamp(screenSize.Y * 0.75, 350, 420)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, width, 0, height)
    Main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    Main.BackgroundColor3 = Color3.fromRGB(27, 27, 35)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 16)

    --- Header ---
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(38, 38, 47)
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = title or "Orion UI"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.TextColor3 = Color3.fromRGB(225, 225, 230)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", Header)
    Close.Text = "✕"
    Close.Size = UDim2.new(0, 50, 1, 0)
    Close.Position = UDim2.new(1, -50, 0, 0)
    Close.TextColor3 = Color3.fromRGB(255, 95, 95)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 28
    Close.BackgroundTransparency = 1
    Close.AutoButtonColor = false
    Close.ZIndex = 2

    Close.MouseEnter:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
    end)
    Close.MouseLeave:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 95, 95)}):Play()
    end)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton", Header)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 50, 1, 0)
    Minimize.Position = UDim2.new(1, -100, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(180, 180, 190)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 28
    Minimize.BackgroundTransparency = 1
    Minimize.AutoButtonColor = false

    Minimize.MouseEnter:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(210, 210, 220)}):Play()
    end)
    Minimize.MouseLeave:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
    end)

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 45)
    TabHolder.Size = UDim2.new(0, 140, 1, -45)
    TabHolder.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
    TabHolder.BorderSizePixel = 0

    local TabHolderCorner = Instance.new("UICorner", TabHolder)
    TabHolderCorner.CornerRadius = UDim.new(0, 16)

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 140, 0, 45)
    PageHolder.Size = UDim2.new(1, -140, 1, -45)
    PageHolder.BackgroundColor3 = Color3.fromRGB(38, 38, 47)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0

    local PageHolderCorner = Instance.new("UICorner", PageHolder)
    PageHolderCorner.CornerRadius = UDim.new(0, 16)

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 10)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, width, 0, 45) or UDim2.new(0, width, 0, height)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = goalSize}):Play()
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
    end)

    --- Drag support (mouse + touch) ---
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

            -- Instead of input.Changed, use UserInputService.InputEnded for robustness
            -- and connect to a single input ended event for the current drag.
            -- Disconnect the event after it fires to prevent memory leaks if dragging stops.
            local inputEndedConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded == input then
                    dragging = false
                    inputEndedConnection:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                update(input)
            end
        end
    end)

    --- Create tabs ---
    function Library:CreateTab(name)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -20, 0, 40)
        Button.Position = UDim2.new(0, 10, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(49, 49, 60)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(225, 225, 230)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 17
        Button.AutoButtonColor = false
        Button.Parent = TabHolder -- Set parent here

        local BtnCorner = Instance.new("UICorner", Button)
        BtnCorner.CornerRadius = UDim.new(0, 12)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 8
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        Page.BorderSizePixel = 0
        Page.Parent = PageHolder -- Set parent here

        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 14)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true

            -- Destaque do botão ativo
            for _, btn in pairs(TabHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(49, 49, 60)}):Play()
                end
            end
            TweenService:Create(Button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
        end)

        if #PageHolder:GetChildren() == 0 then
            -- Button:CaptureFocus() -- CaptureFocus is not a common or necessary practice here for initial selection
            Page.Visible = true
            Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end

        local tabObj = {}

        function tabObj:AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -20, 0, 26)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 15
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            return lbl
        end

        function tabObj:AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -20, 0, 44)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(245, 245, 245)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 17
            btn.AutoButtonColor = true

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 14)

            btn.MouseButton1Click:Connect(callback)

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
            end)

            return btn
        end

        function tabObj:AddToggle(text, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -20, 0, 38)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = text
            label.Font = Enum.Font.Gotham
            label.TextSize = 15
            label.TextColor3 = Color3.fromRGB(240, 240, 245)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -55, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggle = Instance.new("TextButton", container)
            toggle.Size = UDim2.new(0, 48, 0, 24)
            toggle.Position = UDim2.new(1, -48, 0.5, -12)
            toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
            toggle.AutoButtonColor = false
            toggle.Text = ""
            toggle.ClipsDescendants = true

            local toggleCorner = Instance.new("UICorner", toggle)
            toggleCorner.CornerRadius = UDim.new(0, 14)

            local circle = Instance.new("Frame", toggle)
            circle.Size = UDim2.new(0, 20, 0, 20)
            circle.Position = default and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)

            local circleCorner = Instance.new("UICorner", circle)
            circleCorner.CornerRadius = UDim.new(1, 0)

            local toggled = default

            toggle.MouseButton1Click:Connect(function()
                toggled = not toggled
                TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)}):Play()
                circle:TweenPosition(toggled and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                if callback then
                    callback(toggled)
                end
            end)

            -- Function to manually set the toggle state, useful for loading configurations
            function container:SetToggleState(state)
                toggled = state
                toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
                circle.Position = toggled and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
            end

            return container, function() return toggled end
        end

        function tabObj:AddSlider(text, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -20, 0, 52)
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
            sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            sliderBar.ClipsDescendants = true
            sliderBar.ZIndex = 6

            local sliderCorner = Instance.new("UICorner", sliderBar)
            sliderCorner.CornerRadius = UDim.new(0, 14)

            local sliderFill = Instance.new("Frame", sliderBar)
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            sliderFill.ZIndex = 7

            local fillCorner = Instance.new("UICorner", sliderFill)
            fillCorner.CornerRadius = UDim.new(0, 14)

            local dragging = false
            local currentValue = default

            local function updateSlider(inputX)
                local barPos = sliderBar.AbsolutePosition.X
                local barSize = sliderBar.AbsoluteSize.X
                local relativeX = math.clamp(inputX - barPos, 0, barSize)
                local percent = relativeX / barSize
                currentValue = math.floor(min + (max - min) * percent)
                sliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. tostring(currentValue)
                if callback then callback(currentValue) end
            end

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            -- Function to manually set the slider value, useful for loading configurations
            function container:SetSliderValue(value)
                currentValue = math.clamp(value, min, max)
                sliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. tostring(currentValue)
            end

            return container, function() return currentValue end
        end

        return tabObj
    end

    --- Create config tab with save and load ---
    local configTab = Library:CreateTab("Configuração")

    -- Define configData outside the function to persist it across calls/reloads
    local configData = getgenv().MyConfig or {}
    local uiElements = {} -- To store references to UI elements for updating

    local function saveConfig()
        getgenv().MyConfig = configData
        print("Configurações salvas!")
    end

    local function loadConfig()
        configData = getgenv().MyConfig or {}
        print("Configurações carregadas!")

        -- Update UI elements based on loaded config
        if uiElements.featureToggle and configData.featureEnabled ~= nil then
            uiElements.featureToggle:SetToggleState(configData.featureEnabled)
        end
        if uiElements.volumeSlider and configData.volume ~= nil then
            uiElements.volumeSlider:SetSliderValue(configData.volume)
        end
    end

    configTab:AddLabel("Configurações do Usuário")

    -- Example toggle with save/load
    local toggleContainer, getToggleState = configTab:AddToggle("Ativar recurso", configData.featureEnabled or false, function(state)
        configData.featureEnabled = state
    end)
    uiElements.featureToggle = toggleContainer -- Store reference

    -- Example slider with save/load
    local sliderContainer, getSliderValue = configTab:AddSlider("Volume", 0, 100, configData.volume or 50, function(value)
        configData.volume = value
    end)
    uiElements.volumeSlider = sliderContainer -- Store reference

    local saveButton = configTab:AddButton("Salvar Configurações", function()
        saveConfig()
    end)

    local loadButton = configTab:AddButton("Carregar Configurações", function()
        loadConfig()
    end)

    -- Initial load of config when the UI is created
    loadConfig()

    return Library
end

return Library
