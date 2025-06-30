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
    Main.Size = UDim2.new(0, 450, 0, 340)
    Main.Position = UDim2.new(0.5, -225, 0.5, -170)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 8)

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Text = title or "Orion UI"
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton", Header)
    Close.Text = "×"
    Close.Size = UDim2.new(0, 36, 1, 0)
    Close.Position = UDim2.new(1, -36, 0, 0)
    Close.TextColor3 = Color3.fromRGB(255, 85, 85)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 20
    Close.BackgroundTransparency = 1
    Close.ZIndex = 2
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton", Header)
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 36, 1, 0)
    Minimize.Position = UDim2.new(1, -72, 0, 0)
    Minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 20
    Minimize.BackgroundTransparency = 1

    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Position = UDim2.new(0, 0, 0, 36)
    TabHolder.Size = UDim2.new(0, 120, 1, -36)
    TabHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabHolder.BorderSizePixel = 0

    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 120, 0, 36)
    PageHolder.Size = UDim2.new(1, -120, 1, -36)
    PageHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    PageHolder.ClipsDescendants = true
    PageHolder.BorderSizePixel = 0

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local goalSize = minimized and UDim2.new(0, 450, 0, 36) or UDim2.new(0, 450, 0, 340)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = goalSize}):Play()

        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
    end)

    -- Dragging support for mobile and mouse
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

    -- Criação da tab com funções para adicionar elementos
    function Library:CreateTab(name)
        local Button = Instance.new("TextButton", TabHolder)
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Position = UDim2.new(0, 5, 0, 0)
        Button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.AutoButtonColor = false

        local BtnCorner = Instance.new("UICorner", Button)
        BtnCorner.CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 5
        Page.CanvasSize = UDim2.new(0, 0, 0, 600)

        local layout = Instance.new("UIListLayout", Page)
        layout.Padding = UDim.new(0, 8)

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        -- Ativar a primeira aba criada automaticamente
        if #PageHolder:GetChildren() == 1 then
            Page.Visible = true
        end

        -- Função para adicionar Label
        local function AddLabel(text)
            local lbl = Instance.new("TextLabel", Page)
            lbl.Size = UDim2.new(1, -12, 0, 24)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- Função para adicionar Button simples
        local function AddButton(text, callback)
            local btn = Instance.new("TextButton", Page)
            btn.Size = UDim2.new(1, -12, 0, 30)
            btn.Text = text
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.AutoButtonColor = true

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(callback)
        end

        -- Função para criar Slider estilizado
        local function AddSlider(labelText, min, max, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -12, 0, 40)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = labelText
            label.Size = UDim2.new(0.3, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local sliderFrame = Instance.new("Frame", container)
            sliderFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
            sliderFrame.Size = UDim2.new(0.6, 0, 0.4, 0)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderFrame.BorderSizePixel = 0

            local sliderCorner = Instance.new("UICorner", sliderFrame)
            sliderCorner.CornerRadius = UDim.new(0, 8)

            local sliderBar = Instance.new("Frame", sliderFrame)
            sliderBar.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            sliderBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderBar.BorderSizePixel = 0

            local sliderBarCorner = Instance.new("UICorner", sliderBar)
            sliderBarCorner.CornerRadius = UDim.new(0, 8)

            -- Lógica do slider para interatividade
            local dragging = false
            local sliderWidth = sliderFrame.AbsoluteSize.X

            sliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local pos = input.Position.X - sliderFrame.AbsolutePosition.X
                    pos = math.clamp(pos, 0, sliderWidth)
                    sliderBar.Size = UDim2.new(pos / sliderWidth, 0, 1, 0)
                    local value = min + (pos / sliderWidth) * (max - min)
                    callback(value)
                end
            end)

            sliderFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            sliderFrame.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position.X - sliderFrame.AbsolutePosition.X
                    pos = math.clamp(pos, 0, sliderWidth)
                    sliderBar.Size = UDim2.new(pos / sliderWidth, 0, 1, 0)
                    local value = min + (pos / sliderWidth) * (max - min)
                    callback(value)
                end
            end)
        end

        -- Função para criar Toggle estilizado
        local function AddToggle(labelText, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -12, 0, 30)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = labelText
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local toggleButton = Instance.new("TextButton", container)
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0.15, 0)
            toggleButton.BackgroundColor3 = default and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 70)
            toggleButton.Text = ""
            toggleButton.AutoButtonColor = true

            local toggleCorner = Instance.new("UICorner", toggleButton)
            toggleCorner.CornerRadius = UDim.new(0, 10)

            toggleButton.MouseButton1Click:Connect(function()
                default = not default
                toggleButton.BackgroundColor3 = default and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 70)
                callback(default)
            end)
        end

        -- Função para criar Button OnOff estilizado
        local function AddButtonOnOff(labelText, default, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -12, 0, 30)
            container.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", container)
            label.Text = labelText
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", container)
            btn.Size = UDim2.new(0, 60, 0, 25)
            btn.Position = UDim2.new(1, -70, 0.1, 0)
            btn.BackgroundColor3 = default and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 70)
            btn.Text = default and "ON" or "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.AutoButtonColor = true

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                default = not default
                btn.BackgroundColor3 = default and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 70)
                btn.Text = default and "ON" or "OFF"
                callback(default)
            end)
        end

        -- Expor as funções para uso externo
        return {
            AddLabel = AddLabel,
            AddButton = AddButton,
            AddSlider = AddSlider,
            AddToggle = AddToggle,
            AddButtonOnOff = AddButtonOnOff,
            Page = Page -- expor a página se precisar adicionar elementos diretamente
        }
    end

    return Library
end

return Library
