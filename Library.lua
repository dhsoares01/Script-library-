local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "OrionLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 380, 0, 460) -- um pouco mais alto para mobile
    Main.Position = UDim2.new(0.5, -190, 0.5, -230)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 12) -- cantos mais arredondados

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 42) -- maior para toque fácil
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Text = title or "Orion UI"
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", Header)
    Close.Text = "×"
    Close.Size = UDim2.new(0, 42, 1, 0)
    Close.Position = UDim2.new(1, -42, 0, 0)
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
    Minimize.Size = UDim2.new(0, 42, 1, 0)
    Minimize.Position = UDim2.new(1, -84, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 24
    Minimize.BackgroundTransparency = 1

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 42)
    TabHolder.Size = UDim2.new(0, 130, 1, -42)
    TabHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabHolder.BorderSizePixel = 0

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 130, 0, 42)
    PageHolder.Size = UDim2.new(1, -130, 1, -42)
    PageHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, 380, 0, 42) or UDim2.new(0, 380, 0, 460)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = goalSize}):Play()

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

    -- Tab system
    function Library:CreateTab(name)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Size = UDim2.new(1, -12, 0, 40) -- botões maiores para toque fácil
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamSemibold
        Button.TextSize = 16
        Button.AutoButtonColor = false
        local corner = Instance.new("UICorner", Button)
        corner.CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 6
        Page.CanvasSize = UDim2.new(0, 0, 0, 700)
        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 10)

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        if #PageHolder:GetChildren() == 1 then Page.Visible = true end

        -- Funções para os controles do tab
        local function AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -24, 0, 26)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 15
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        local function AddSlider(labelText, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -24, 0, 48)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = labelText
            label.Size = UDim2.new(0.3, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderFrame = Instance.new("Frame", container)
            sliderFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
            sliderFrame.Size = UDim2.new(0.6, 0, 0.4, 0)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            sliderFrame.BorderSizePixel = 0
            local corner = Instance.new("UICorner", sliderFrame)
            corner.CornerRadius = UDim.new(0, 10)

            local sliderBar = Instance.new("Frame", sliderFrame)
            sliderBar.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            sliderBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderBar.BorderSizePixel = 0
            local corner2 = Instance.new("UICorner", sliderBar)
            corner2.CornerRadius = UDim.new(0, 10)
            sliderBar.Name = "Bar"

            local dragging = false
            local function inputUpdate(input)
                local pos = input.Position.X - sliderFrame.AbsolutePosition.X
                pos = math.clamp(pos, 0, sliderFrame.AbsoluteSize.X)
                sliderBar.Size = UDim2.new(pos / sliderFrame.AbsoluteSize.X, 0, 1, 0)
                local value = min + (pos / sliderFrame.AbsoluteSize.X) * (max - min)
                callback(value)
            end

            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    inputUpdate(input)
                end
            end)
            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            sliderFrame.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    inputUpdate(input)
                end
            end)
        end

        local function AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -24, 0, 40)
            btn.Text = text
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 16
            btn.AutoButtonColor = true
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(0, 10)
            btn.MouseButton1Click:Connect(callback)
        end

        return {
            AddLabel = AddLabel,
            AddSlider = AddSlider,
            AddButton = AddButton,
            Page = Page
        }
    end

    -- Paleta ARGB para configuração de cor do menu
    local config = {Red = 24, Green = 24, Blue = 24, Opacity = 1}
    local configTab = Library:CreateTab("Configurações")
    configTab.AddLabel("Escolha a cor do menu:")

    -- Paleta de cores simples para mobile: 8 cores + custom (slider alpha)
    local colorsPalette = {
        Color3.fromRGB(24, 24, 24),
        Color3.fromRGB(255, 85, 85),  -- vermelho
        Color3.fromRGB(100, 180, 255), -- azul
        Color3.fromRGB(85, 255, 127), -- verde
        Color3.fromRGB(255, 195, 0),  -- amarelo
        Color3.fromRGB(255, 128, 255), -- rosa
        Color3.fromRGB(255, 140, 0), -- laranja
        Color3.fromRGB(200, 200, 200) -- cinza claro
    }

    local paletteContainer = Instance.new("Frame", configTab.Page)
    paletteContainer.Size = UDim2.new(1, -24, 0, 60)
    paletteContainer.BackgroundTransparency = 1
    paletteContainer.LayoutOrder = 2

    local UIGrid = Instance.new("UIGridLayout", paletteContainer)
    UIGrid.CellSize = UDim2.new(0, 42, 0, 42)
    UIGrid.CellPadding = UDim2.new(0, 12, 0, 12)
    UIGrid.FillDirection = Enum.FillDirection.Horizontal
    UIGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left

    -- Guarda referência do botão selecionado pra mostrar borda
    local selectedButton = nil

    local function updateSelected(btn)
        if selectedButton then
            selectedButton.BorderSizePixel = 0
        end
        selectedButton = btn
        selectedButton.BorderColor3 = Color3.fromRGB(100, 180, 255)
        selectedButton.BorderSizePixel = 3
    end

    local function applyConfig()
        Main.BackgroundColor3 = Color3.fromRGB(config.Red, config.Green, config.Blue)
        Main.BackgroundTransparency = 1 - config.Opacity
    end

    -- Criar botões da paleta
    for i, col in ipairs(colorsPalette) do
        local colorBtn = Instance.new("TextButton", paletteContainer)
        colorBtn.Size = UDim2.new(0, 42, 0, 42)
        colorBtn.BackgroundColor3 = col
        colorBtn.AutoButtonColor = false
        local corner = Instance.new("UICorner", colorBtn)
        corner.CornerRadius = UDim.new(0, 8)
        colorBtn.LayoutOrder = i
        colorBtn.Text = ""

        colorBtn.MouseButton1Click:Connect(function()
            config.Red = math.floor(col.R * 255)
            config.Green = math.floor(col.G * 255)
            config.Blue = math.floor(col.B * 255)
            updateSelected(colorBtn)
            applyConfig()
        end)

        -- Se for a cor inicial, seleciona automático
        if col == Color3.fromRGB(config.Red, config.Green, config.Blue) then
            updateSelected(colorBtn)
        end
    end

    -- Slider para Opacidade separado (alpha)
    configTab.AddSlider("Opacidade", 0, 1, config.Opacity, function(v)
        config.Opacity = tonumber(string.format("%.2f", v))
        applyConfig()
    end)

    configTab.AddButton("Aplicar", applyConfig)
    configTab.AddLabel("⚠️ Configuração não salva")

    return Library
end

return Library
