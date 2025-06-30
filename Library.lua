local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Função para converter HSV para RGB (Color3 do Roblox)
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
    Main.Size = UDim2.new(0.9, 0, 0.8, 0) -- 90% largura, 80% altura da tela
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Main.BorderSizePixel = 0
    Main.Active = true
    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 16)

    -- Cabeçalho
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 48) -- Altura fixa, largura total
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.BorderSizePixel = 0
    local headerCorner = Instance.new("UICorner", Header)
    headerCorner.CornerRadius = UDim.new(0, 16)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Text = title or "Orion UI"
    TitleLabel.Size = UDim2.new(1, -64, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 48, 0, 48)
    CloseBtn.Position = UDim2.new(1, -48, 0, 0)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 28
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.AutoButtonColor = false
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Container do Color Picker
    local PickerContainer = Instance.new("Frame", Main)
    PickerContainer.Size = UDim2.new(0.9, 0, 0.8, -Header.Size.Y.Offset)
    PickerContainer.Position = UDim2.new(0.5, 0, 1, -PickerContainer.Size.Y.Offset - 16)
    PickerContainer.AnchorPoint = Vector2.new(0.5, 1)
    PickerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PickerContainer.BorderSizePixel = 0
    local cornerPicker = Instance.new("UICorner", PickerContainer)
    cornerPicker.CornerRadius = UDim.new(0, 14)

    -- Área de Saturação/Valor (quadrado)
    local SatValFrame = Instance.new("Frame", PickerContainer)
    SatValFrame.Size = UDim2.new(0.75, 0, 1, 0)
    SatValFrame.Position = UDim2.new(0, 12, 0, 0)
    SatValFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    SatValFrame.BorderSizePixel = 0
    local satValCorner = Instance.new("UICorner", SatValFrame)
    satValCorner.CornerRadius = UDim.new(0, 10)
    local SatValAspectRatio = Instance.new("UIAspectRatioConstraint", SatValFrame)
    SatValAspectRatio.AspectRatio = 1

    -- Gradiente horizontal de saturação (branco a cor)
    local satGradient = Instance.new("Frame", SatValFrame)
    satGradient.Size = UDim2.new(1, 0, 1, 0)
    satGradient.BackgroundColor3 = Color3.new(1, 1, 1)
    satGradient.BorderSizePixel = 0
    local saturationGradient = Instance.new("UIGradient", satGradient)
    saturationGradient.Rotation = 0

    -- Gradiente vertical de valor (transparente para preto)
    local valGradient = Instance.new("Frame", SatValFrame)
    valGradient.Size = UDim2.new(1, 0, 1, 0)
    valGradient.BackgroundColor3 = Color3.new(0, 0, 0)
    valGradient.BorderSizePixel = 0
    local valUIGradient = Instance.new("UIGradient", valGradient)
    valUIGradient.Rotation = 90

    -- Barra vertical para matiz (Hue)
    local HueFrame = Instance.new("Frame", PickerContainer)
    HueFrame.Size = UDim2.new(0.15, 0, 1, 0)
    HueFrame.Position = UDim2.new(1, -12, 0, 0)
    HueFrame.AnchorPoint = Vector2.new(1, 0)
    HueFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    HueFrame.BorderSizePixel = 0
    local hueCorner = Instance.new("UICorner", HueFrame)
    hueCorner.CornerRadius = UDim.new(0, 10)

    local hueGradient = Instance.new("UIGradient", HueFrame)
    hueGradient.Rotation = 270
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    }

    -- Indicador da saturação/valor (círculo)
    local SatValSelector = Instance.new("Frame", SatValFrame)
    SatValSelector.Size = UDim2.new(0, 32, 0, 32) -- maior para toque
    SatValSelector.BackgroundColor3 = Color3.new(1, 1, 1)
    SatValSelector.BorderColor3 = Color3.fromRGB(60, 60, 60)
    SatValSelector.BorderSizePixel = 2
    SatValSelector.AnchorPoint = Vector2.new(0.5, 0.5)
    SatValSelector.ZIndex = 5
    local selectorCorner = Instance.new("UICorner", SatValSelector)
    selectorCorner.CornerRadius = UDim.new(1, 0)

    -- Indicador da barra Hue (linha)
    local HueSelector = Instance.new("Frame", HueFrame)
    HueSelector.Size = UDim2.new(1, 0, 0, 10) -- linha mais espessa para toque
    HueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
    HueSelector.BorderColor3 = Color3.fromRGB(60, 60, 60)
    HueSelector.BorderSizePixel = 2
    HueSelector.AnchorPoint = Vector2.new(0.5, 0)
    HueSelector.Position = UDim2.new(0.5, 0, 0, 0)
    HueSelector.ZIndex = 5
    local hueSelectorCorner = Instance.new("UICorner", HueSelector)
    hueSelectorCorner.CornerRadius = UDim.new(0, 5)

    -- Estado interno HSV
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
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, HSVtoRGB(hue, 1, 1))
        }
    end

    -- Atualiza a cor do fundo principal para feedback visual
    local function applyColor()
        local c = HSVtoRGB(hue, sat, val)
        Main.BackgroundColor3 = c
    end

    updateSatValGradient()
    updateSatValSelector()
    updateHueSelector()
    applyColor()

    -- Flags de arrastar
    local draggingSatVal = false
    local draggingHue = false

    local function handleInputChanged(input, object, isSatVal)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relativePos = input.Position - object.AbsolutePosition
            if isSatVal then
                sat = math.clamp(relativePos.X / object.AbsoluteSize.X, 0, 1)
                val = 1 - math.clamp(relativePos.Y / object.AbsoluteSize.Y, 0, 1)
                updateSatValSelector()
            else
                hue = math.clamp(relativePos.Y / object.AbsoluteSize.Y, 0, 1)
                updateSatValGradient()
                updateHueSelector()
            end
            applyColor()
        end
    end

    SatValFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSatVal = true
            UserInputService.MouseIconEnabled = false
            handleInputChanged(input, SatValFrame, true)
        end
    end)

    SatValFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSatVal = false
            UserInputService.MouseIconEnabled = true
        end
    end)

    SatValFrame.InputChanged:Connect(function(input)
        if draggingSatVal then
            handleInputChanged(input, SatValFrame, true)
        end
    end)

    HueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            UserInputService.MouseIconEnabled = false
            handleInputChanged(input, HueFrame, false)
        end
    end)

    HueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
            UserInputService.MouseIconEnabled = true
        end
    end)

    HueFrame.InputChanged:Connect(function(input)
        if draggingHue then
            handleInputChanged(input, HueFrame, false)
        end
    end)

    -- Método público para obter a cor selecionada atual
    function Library:GetSelectedColor()
        return HSVtoRGB(hue, sat, val)
    end

    return Library
end

return Library
