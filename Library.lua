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

    -- Responsivo para mobile
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.9, 300, 450)
    local height = math.clamp(screenSize.Y * 0.75, 300, 380)

    Main.Size = UDim2.new(0, width, 0, height)
    Main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = title or "Orion UI"
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

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
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 12)

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 120, 0, 40)
    PageHolder.Size = UDim2.new(1, -120, 1, -40)
    PageHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0
    Instance.new("UICorner", PageHolder).CornerRadius = UDim.new(0, 12)

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, width, 0, 40) or UDim2.new(0, width, 0, height)
        TweenService:Create(Main, TweenInfo.new(0.3), { Size = goalSize }):Play()
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
    end)

    -- Drag
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

    -- Funções extras da lib

    function Library:Notify(text, duration)
        duration = duration or 3
        local alertFrame = Instance.new("Frame", CoreGui)
        alertFrame.Size = UDim2.new(0, 300, 0, 50)
        alertFrame.Position = UDim2.new(0.5, -150, 0, 20)
        alertFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        alertFrame.BackgroundTransparency = 0.3
        alertFrame.BorderSizePixel = 0
        alertFrame.AnchorPoint = Vector2.new(0.5, 0)
        alertFrame.ZIndex = 9999
        alertFrame.ClipsDescendants = true
        Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel", alertFrame)
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = 10000

        alertFrame.Position = UDim2.new(0.5, -150, 0, -60)
        alertFrame.BackgroundTransparency = 1
        label.TextTransparency = 1

        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenIn = TweenService:Create(alertFrame, tweenInfo, {BackgroundTransparency = 0.3, Position = UDim2.new(0.5, -150, 0, 20)})
        local labelTweenIn = TweenService:Create(label, tweenInfo, {TextTransparency = 0})

        local tweenOut = TweenService:Create(alertFrame, tweenInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0, -60)})
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
        Main.BackgroundColor3 = color or Color3.fromRGB(24, 24, 24)
        PageHolder.BackgroundColor3 = color:lerp(Color3.new(1, 1, 1), 0.1)
        TabHolder.BackgroundColor3 = color:lerp(Color3.new(0, 0, 0), 0.2)
    end

    function Library:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

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
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 8
        Page.CanvasSize = UDim2.new(0, 0, 0, 600)
        Page.VerticalScrollBarInset = Enum.ScrollBarInset.Always

        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 12)

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        if #PageHolder:GetChildren() == 1 then
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
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        return tabObj
    end

    -- Notificação automática ao abrir
    task.defer(function()
        Library:Notify("Bem-vindo ao painel, aproveite!", 4)
    end)

    -- Cria aba Configurações
    local config = Library:CreateTab("Configurações")

    config:AddLabel("🎨 Escolha o tema do menu:")
    config:AddButton("Tema Roxo Premium", function()
        Library:ChangeTheme(Color3.fromRGB(120, 0, 255))
        Library:Notify("Tema Roxo aplicado!", 3)
    end)
    config:AddButton("Tema Azul Moderno", function()
        Library:ChangeTheme(Color3.fromRGB(0, 170, 255))
        Library:Notify("Tema Azul aplicado!", 3)
    end)
    config:AddButton("Tema Vermelho Intenso", function()
        Library:ChangeTheme(Color3.fromRGB(255, 50, 50))
        Library:Notify("Tema Vermelho aplicado!", 3)
    end)
    config:AddButton("Tema Escuro Clássico", function()
        Library:ChangeTheme(Color3.fromRGB(24, 24, 24))
        Library:Notify("Tema Escuro aplicado!", 3)
    end)

    config:AddLabel("📝 Personalize o título do menu:")
    config:AddButton("Título: Painel Pro", function()
        Library:SetTitle("Painel Pro")
        Library:Notify("Título alterado para 'Painel Pro'!", 3)
    end)
    config:AddButton("Título: Central de Controle", function()
        Library:SetTitle("Central de Controle")
        Library:Notify("Título alterado para 'Central de Controle'!", 3)
    end)

    config:AddLabel("🔄 Outras opções:")
    config:AddButton("Redefinir Interface", function()
        Library:Notify("Reiniciando interface...", 2)
        task.wait(0.5)
        ScreenGui:Destroy()
        -- Você pode recriar a interface chamando Library:Create() novamente, se quiser
    end)

    return Library
end

return Library
