local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Função para converter HSV para RGB (Roblox usa Color3)
local function HSVtoRGB(h, s, v)
    if s == 0 then
        return Color3.new(v, v, v)
    end
    h = h * 6
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    if i == 0 then
        return Color3.new(v, t, p)
    elseif i == 1 then
        return Color3.new(q, v, p)
    elseif i == 2 then
        return Color3.new(p, v, t)
    elseif i == 3 then
        return Color3.new(p, q, v)
    elseif i == 4 then
        return Color3.new(t, p, v)
    else
        return Color3.new(v, p, q)
    end
end

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "OrionLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 380, 0, 460)
    Main.Position = UDim2.new(0.5, -190, 0.5, -230)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true
    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 12)

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0
    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = title or "Orion UI"
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Text = "×"
    CloseBtn.Size = UDim2.new(0, 42, 1, 0)
    CloseBtn.Position = UDim2.new(1, -42, 0, 0)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 24
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Container para o color picker
    local PickerContainer = Instance.new("Frame", Main)
    PickerContainer.Size = UDim2.new(0, 300, 0, 300)
    PickerContainer.Position = UDim2.new(0.5, -150, 0, 60)
    PickerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PickerContainer.BorderSizePixel = 0
    local cornerPicker = Instance.new("UICorner", PickerContainer)
    cornerPicker.CornerRadius = UDim.new(0, 10)

    -- Área quadrada Saturação x Valor (tonalidade fixa definida pelo matiz)
    local SatValFrame = Instance.new("Frame", PickerContainer)
    SatValFrame.Size = UDim2.new(0, 256, 0, 256)
    SatValFrame.Position = UDim2.new(0, 0, 0, 0)
    SatValFrame.BackgroundColor3 = Color3.new(1,1,1)
    SatValFrame.BorderSizePixel = 0
    local satValCorner = Instance.new("UICorner", SatValFrame)
    satValCorner.CornerRadius = UDim.new(0, 6)

    -- Sobreposição para o gradiente da saturação (horizontal)
    local satGradient = Instance.new("Frame", SatValFrame)
    satGradient.Size = UDim2.new(1, 0, 1, 0)
    satGradient.BackgroundColor3 = Color3.fromRGB(255,255,255)
    satGradient.BackgroundTransparency = 0
    satGradient.BorderSizePixel = 0

    -- Usar UIGradient para simular saturação horizontal do branco até a cor
    local saturationGradient = Instance.new("UIGradient", satGradient)
    saturationGradient.Rotation = 0
    saturationGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
    }

    -- Sobreposição para o gradiente do valor (brilho) vertical (de transparente para preto)
    local valGradient = Instance.new("Frame", SatValFrame)
    valGradient.Size = UDim2.new(1, 0, 1, 0)
    valGradient.BackgroundColor3 = Color3.new(0,0,0)
    valGradient.BackgroundTransparency = 0
    valGradient.BorderSizePixel = 0

    local valUIGradient = Instance.new("UIGradient", valGradient)
    valUIGradient.Rotation = 90
    valUIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0,1))
    }

    -- Barra vertical para matiz (Hue)
    local HueFrame = Instance.new("Frame", PickerContainer)
    HueFrame.Size = UDim2.new(0, 30, 0, 256)
    HueFrame.Position = UDim2.new(0, 270, 0, 0)
    HueFrame.BackgroundColor3 = Color3.new(1,1,1)
    HueFrame.BorderSizePixel = 0
    local hueCorner = Instance.new("UICorner", HueFrame)
    hueCorner.CornerRadius = UDim.new(0, 6)

    -- Criar um gradiente arco-íris para a barra Hue vertical
    local hueGradient = Instance.new("UIGradient", HueFrame)
    hueGradient.Rotation = 270
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),   -- Vermelho
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), -- Amarelo
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),   -- Verde
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), -- Ciano
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),   -- Azul
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), -- Magenta
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),   -- Vermelho novamente
    }

    -- Indicadores do seletor (pequenos círculos)
    local SatValSelector = Instance.new("Frame", SatValFrame)
    SatValSelector.Size = UDim2.new(0, 18, 0, 18)
    SatValSelector.BackgroundColor3 = Color3.new(1,1,1)
    SatValSelector.BorderColor3 = Color3.fromRGB(60,60,60)
    SatValSelector.BorderSizePixel = 2
    SatValSelector.AnchorPoint = Vector2.new(0.5, 0.5)
    SatValSelector.ZIndex = 5
    local selectorCorner = Instance.new("UICorner", SatValSelector)
    selectorCorner.CornerRadius = UDim.new(1, 0)

    local HueSelector = Instance.new("Frame", HueFrame)
    HueSelector.Size = UDim2.new(1, 0, 0, 4)
    HueSelector.BackgroundColor3 = Color3.new(1,1,1)
    HueSelector.BorderColor3 = Color3.fromRGB(60,60,60)
    HueSelector.BorderSizePixel = 2
    HueSelector.AnchorPoint = Vector2.new(0.5, 0)
    HueSelector.Position = UDim2.new(0.5, 0, 0, 0)
    HueSelector.ZIndex = 5
    local hueSelectorCorner = Instance.new("UICorner", HueSelector)
    hueSelectorCorner.CornerRadius = UDim.new(0, 2)

    -- Estado interno para HSV
    local hue = 0
    local sat = 1
    local val = 1

    local function updateSatValSelector()
        SatValSelector.Position = UDim2.new(sat, 0, 1 - val, 0)
    end
    local function updateHueSelector()
        HueSelector.Position = UDim2.new(0.5, 0, hue, 0)
    end

    local function updateSatValGradient()
        saturationGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, HSVtoRGB(hue,1,1))
        }
    end

    -- Atualiza cor da seleção inicial
    updateSatValGradient()
    updateSatValSelector()
    updateHueSelector()

    -- Função para atualizar cor selecionada e mostrar no Main background
    local function applyColor()
        local c = HSVtoRGB(hue, sat, val)
        Main.BackgroundColor3 = c
    end

    applyColor()

    -- Drag handlers
    local draggingSatVal = false
    SatValFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSatVal = true
            UserInputService.MouseIconEnabled = false
            local absPos = input.Position - SatValFrame.AbsolutePosition
            sat = math.clamp(absPos.X / SatValFrame.AbsoluteSize.X, 0, 1)
            val = 1 - math.clamp(absPos.Y / SatValFrame.AbsoluteSize.Y, 0, 1)
            updateSatValSelector()
            applyColor()
        end
    end)
    SatValFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSatVal = false
            UserInputService.MouseIconEnabled = true
        end
    end)
    SatValFrame.InputChanged:Connect(function(input)
        if draggingSatVal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = input.Position - SatValFrame.AbsolutePosition
            sat = math.clamp(absPos.X / SatValFrame.AbsoluteSize.X, 0, 1)
            val = 1 - math.clamp(absPos.Y / SatValFrame.AbsoluteSize.Y, 0, 1)
            updateSatValSelector()
            applyColor()
        end
    end)

    local draggingHue = false
    HueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            UserInputService.MouseIconEnabled = false
            local absPos = input.Position - HueFrame.AbsolutePosition
            hue = math.clamp(absPos.Y / HueFrame.AbsoluteSize.Y, 0, 1)
            updateSatValGradient()
            updateHueSelector()
            applyColor()
        end
    end)
    HueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
            UserInputService.MouseIconEnabled = true
        end
    end)
    HueFrame.InputChanged:Connect(function(input)
        if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = input.Position - HueFrame.AbsolutePosition
            hue = math.clamp(absPos.Y / HueFrame.AbsoluteSize.Y, 0, 1)
            updateSatValGradient()
            updateHueSelector()
            applyColor()
        end
    end)

    -- Retorna a cor atual selecionada em RGB
    function Library:GetSelectedColor()
        return HSVtoRGB(hue, sat, val)
    end

    return Library
end

return Library
