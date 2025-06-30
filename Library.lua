local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cores personalizadas para um design moderno e legível
local ColorPalette = {
    Background = Color3.fromRGB(20, 20, 25),
    Header = Color3.fromRGB(30, 30, 40),
    Tab = Color3.fromRGB(35, 35, 50),
    Content = Color3.fromRGB(25, 25, 35),
    Button = Color3.fromRGB(50, 40, 80),
    ButtonHover = Color3.fromRGB(70, 50, 110),
    ToggleOff = Color3.fromRGB(90, 90, 110),
    ToggleOn = Color3.fromRGB(140, 80, 220),
    Slider = Color3.fromRGB(70, 70, 90),
    SliderFill = Color3.fromRGB(120, 90, 240),
    Text = Color3.fromRGB(230, 230, 240),
    Accent = Color3.fromRGB(160, 110, 255),
    Border = Color3.fromRGB(70, 70, 90)
}

-- Função auxiliar para verificar entrada do ponteiro (mouse ou toque)
local function isPointerInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch
end

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FloatingLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui -- Define o pai aqui para evitar reflow desnecessário

    -- Main Container - Ajustado para ser mais flexível em mobile
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0.9, 0, 0.7, 0) -- Tamanho responsivo (90% da largura, 70% da altura da tela)
    Main.Position = UDim2.new(0.05, 0, 0.15, 0) -- Posição centralizada
    Main.BackgroundColor3 = ColorPalette.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true -- Draggable é útil, mas em mobile pode ser mais sensível.

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10) -- Bordas um pouco maiores para toque
    UICorner.Parent = Main

    -- Efeito de sombra suave (pode ser pesado para dispositivos muito fracos, mas geralmente ok)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(20, 10, 40)
    Shadow.ImageTransparency = 0.7
    Shadow.BackgroundTransparency = 1
    Shadow.ZIndex = -1
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = Main

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45) -- Altura maior para toque
    Header.BackgroundColor3 = ColorPalette.Header
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    -- Gradiente do header
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Rotation = 90
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 40, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 80))
    })
    HeaderGradient.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Text = title or "Floating UI"
    TitleLabel.Size = UDim2.new(1, -90, 1, 0) -- Espaço para botões de controle
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.TextColor3 = ColorPalette.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextSize = 18 -- Texto maior para melhor visibilidade
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Botões de controle
    local Close = Instance.new("TextButton")
    Close.Name = "CloseButton"
    Close.Text = "×"
    Close.Size = UDim2.new(0, 40, 1, 0) -- Área de toque maior
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.TextColor3 = Color3.fromRGB(255, 80, 80)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 24
    Close.BackgroundTransparency = 1
    Close.ZIndex = 2
    Close.Parent = Header

    -- Efeitos de hover e clique para feedback visual
    Close.MouseEnter:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
    end)
    Close.MouseLeave:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Minimize = Instance.new("TextButton")
    Minimize.Name = "MinimizeButton"
    Minimize.Text = "–"
    Minimize.Size = UDim2.new(0, 40, 1, 0) -- Área de toque maior
    Minimize.Position = UDim2.new(1, -80, 0, 0)
    Minimize.TextColor3 = ColorPalette.Text
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 24
    Minimize.BackgroundTransparency = 1
    Minimize.Parent = Header

    Minimize.MouseEnter:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.2), {TextColor3 = ColorPalette.Accent}):Play()
    end)
    Minimize.MouseLeave:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.2), {TextColor3 = ColorPalette.Text}):Play()
    end)

    -- Área de abas
    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Position = UDim2.new(0, 0, 0, 45)
    TabHolder.Size = UDim2.new(0.3, 0, 1, -45) -- Abas ocupam 30% da largura
    TabHolder.BackgroundColor3 = ColorPalette.Tab
    TabHolder.BorderSizePixel = 0
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 10)
    TabHolder.Parent = Main

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8) -- Mais espaçamento
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabHolder

    -- Área de conteúdo
    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Position = UDim2.new(0.3, 0, 0, 45) -- Começa após as abas
    PageHolder.Size = UDim2.new(0.7, 0, 1, -45) -- Ocupa o restante da largura
    PageHolder.BackgroundColor3 = ColorPalette.Content
    PageHolder.ClipsDescendants = true
    Instance.new("UICorner", PageHolder).CornerRadius = UDim.new(0, 10)
    PageHolder.Parent = Main

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 45) or UDim2.new(0.9, 0, 0.7, 0)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play()

        -- Esconde/mostra elementos com base no estado minimizado
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
        TitleLabel.TextXAlignment = minimized and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    end)

    function Library:CreateTab(name)
        local Button = Instance.new("TextButton")
        Button.Name = name .. "TabButton"
        Button.Size = UDim2.new(0.9, 0, 0, 40) -- Altura maior para toque
        Button.Text = name
        Button.BackgroundColor3 = ColorPalette.Button
        Button.TextColor3 = ColorPalette.Text
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 16 -- Texto maior
        Button.AutoButtonColor = false
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
        Button.Parent = TabHolder

        -- Efeito hover e clique
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = ColorPalette.ButtonHover}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = ColorPalette.Button}):Play()
        end)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 6 -- Barra de rolagem mais grossa para toque
        Page.ScrollBarImageColor3 = ColorPalette.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado dinamicamente pelo UIListLayout
        Page.Parent = PageHolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10) -- Mais espaçamento entre elementos
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.FillDirection = Enum.FillDirection.Vertical
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.Parent = Page

        -- Adiciona um UIPadding para um respiro nas bordas
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.Parent = Page

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true

            -- Efeito de seleção
            for _, btn in pairs(TabHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = btn == Button and ColorPalette.Accent or ColorPalette.Button
                    }):Play()
                end
            end
            
            -- Ajusta o CanvasSize da página selecionada
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)
        end)

        return {
            AddLabel = function(_, text)
                local container = Instance.new("Frame")
                container.Name = "LabelContainer"
                container.Size = UDim2.new(1, 0, 0, 30) -- Altura levemente maior
                container.BackgroundTransparency = 1
                container.Parent = Page

                local lbl = Instance.new("TextLabel")
                lbl.Name = "Label"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = ColorPalette.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 15 -- Texto maior
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped = true -- Essencial para textos longos em mobile
                lbl.Parent = container

                local divider = Instance.new("Frame")
                divider.Name = "Divider"
                divider.Position = UDim2.new(0, 0, 1, -1)
                divider.Size = UDim2.new(1, 0, 0, 1)
                divider.BackgroundColor3 = ColorPalette.Border
                divider.BorderSizePixel = 0
                divider.Parent = container
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return lbl
            end,

            AddButton = function(_, text, callback)
                local btn = Instance.new("TextButton")
                btn.Name = "Button_" .. text:gsub(" ", "")
                btn.Size = UDim2.new(1, 0, 0, 40) -- Altura maior para toque
                btn.Text = text
                btn.BackgroundColor3 = ColorPalette.Button
                btn.TextColor3 = ColorPalette.Text
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 16 -- Texto maior
                btn.AutoButtonColor = false
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
                btn.Parent = Page

                -- Efeitos hover e clique
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.ButtonHover,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.Button,
                        TextColor3 = ColorPalette.Text
                    }):Play()
                end)
                btn.MouseButton1Down:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = ColorPalette.Accent,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                btn.MouseButton1Up:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.ButtonHover,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                btn.MouseButton1Click:Connect(callback)
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return btn
            end,

            AddToggle = function(_, text, default, callback)
                local container = Instance.new("Frame")
                container.Name = "ToggleContainer"
                container.Size = UDim2.new(1, 0, 0, 40) -- Altura maior para toque
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Text = text
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = container

                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "ToggleFrame"
                toggleFrame.Size = UDim2.new(0.25, 0, 0.7, 0)
                toggleFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
                toggleFrame.BackgroundColor3 = ColorPalette.ToggleOff
                toggleFrame.BorderSizePixel = 0
                Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0.5, 0)
                toggleFrame.Parent = container

                local toggleDot = Instance.new("Frame")
                toggleDot.Name = "ToggleDot"
                toggleDot.Size = UDim2.new(0.4, 0, 0.8, 0)
                toggleDot.Position = UDim2.new(default and 0.55 or 0.05, 0, 0.1, 0)
                toggleDot.BackgroundColor3 = ColorPalette.Text
                toggleDot.BorderSizePixel = 0
                Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(0.5, 0)
                toggleDot.Parent = toggleFrame

                local state = default

                local function updateToggle()
                    if state then
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOn
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.55, 0, 0.1, 0)
                        }):Play()
                    else
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOff
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.05, 0, 0.1, 0)
                        }):Play()
                    end
                end

                updateToggle()

                local function toggleState()
                    state = not state
                    updateToggle()
                    if callback then callback(state) end
                end

                toggleFrame.MouseButton1Click:Connect(toggleState)
                label.MouseButton1Click:Connect(toggleState)
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, value)
                        state = value
                        updateToggle()
                    end,
                    Get = function()
                        return state
                    end
                }
            end,

            AddSlider = function(_, text, min, max, default, callback)
                local container = Instance.new("Frame")
                container.Name = "SliderContainer"
                container.Size = UDim2.new(1, 0, 0, 70) -- Altura maior
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 0.4, 0)
                label.Text = text .. ": " .. tostring(default)
                label.BackgroundTransparency = 1
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local slider = Instance.new("Frame")
                slider.Name = "Slider"
                slider.Position = UDim2.new(0, 0, 0.4, 5)
                slider.Size = UDim2.new(1, 0, 0.3, 0)
                slider.BackgroundColor3 = ColorPalette.Slider
                slider.BorderSizePixel = 0
                Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)
                slider.Parent = container

                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.BackgroundColor3 = ColorPalette.SliderFill
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                fill.BorderSizePixel = 0
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
                fill.Parent = slider

                -- Indicador de valor (o knob já serve essa função)
                local valueIndicator = Instance.new("Frame")
                valueIndicator.Name = "ValueIndicator"
                valueIndicator.Size = UDim2.new(0, 8, 0, 20) -- Knob maior
                valueIndicator.Position = UDim2.new(fill.Size.X.Scale, -4, 0.5, -10) -- Posiciona no fim do fill
                valueIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
                valueIndicator.BackgroundColor3 = ColorPalette.Text
                valueIndicator.BorderSizePixel = 0
                Instance.new("UICorner", valueIndicator).CornerRadius = UDim.new(0.5, 0) -- Círculo
                valueIndicator.Parent = slider
                
                local currentSliderValue = default
                local dragging = false

                local function updateSlider(input)
                    local rel = input.Position.X - slider.AbsolutePosition.X
                    local pct = math.clamp(rel / slider.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pct + 0.5)
                    
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valueIndicator.Position = UDim2.new(pct, -4, 0.5, -10)
                    label.Text = text .. ": " .. value
                    
                    if value ~= currentSliderValue then
                        currentSliderValue = value
                        if callback then callback(currentSliderValue) end
                    end
                end

                slider.InputBegan:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = true
                        updateSlider(input)
                        TweenService:Create(valueIndicator, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 24)}):Play() -- Aumenta o knob ao arrastar
                    end
                end)

                slider.InputEnded:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = false
                        TweenService:Create(valueIndicator, TweenInfo.new(0.1), {Size = UDim2.new(0, 8, 0, 20)}):Play() -- Retorna o tamanho normal
                    end
                end)

                slider.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        updateSlider(input)
                    end
                end)
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, value)
                        local pct = math.clamp((value - min) / (max - min), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        valueIndicator.Position = UDim2.new(pct, -4, 0.5, -10)
                        label.Text = text .. ": " .. value
                        currentSliderValue = value
                    end,
                    Get = function()
                        return currentSliderValue
                    end
                }
            end,

            AddSeekBar = function(_, text, min, max, default, callback)
                local container = Instance.new("Frame")
                container.Name = "SeekBarContainer"
                container.Size = UDim2.new(1, 0, 0, 80) -- Altura maior
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 0, 25)
                label.Text = text .. ": " .. tostring(default)
                label.BackgroundTransparency = 1
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local bar = Instance.new("Frame")
                bar.Name = "Bar"
                bar.Position = UDim2.new(0, 0, 0, 30)
                bar.Size = UDim2.new(1, 0, 0, 10) -- Barra mais grossa
                bar.BackgroundColor3 = ColorPalette.Slider
                bar.BorderSizePixel = 0
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 5)
                bar.Parent = container

                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.BackgroundColor3 = ColorPalette.SliderFill
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                fill.BorderSizePixel = 0
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
                fill.Parent = bar

                -- Bolinha de controle
                local knob = Instance.new("Frame")
                knob.Name = "Knob"
                knob.Size = UDim2.new(0, 16, 0, 16) -- Knob maior
                knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8) -- Ajusta posição para o centro
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.BackgroundColor3 = ColorPalette.Text
                knob.BorderSizePixel = 0
                Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                knob.Parent = bar

                local knobShadow = Instance.new("ImageLabel")
                knobShadow.Name = "KnobShadow"
                knobShadow.Size = UDim2.new(1, 6, 1, 6)
                knobShadow.Position = UDim2.new(0.5, -3, 0.5, -3)
                knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                knobShadow.Image = "rbxassetid://1316045217"
                knobShadow.ImageColor3 = Color3.new(0, 0, 0)
                knobShadow.ImageTransparency = 0.8
                knobShadow.BackgroundTransparency = 1
                knobShadow.ZIndex = -1
                knobShadow.ScaleType = Enum.ScaleType.Slice
                knobShadow.SliceCenter = Rect.new(10, 10, 118, 118)
                knobShadow.Parent = knob

                local currentSeekBarValue = default
                local dragging = false

                local function updateSeekBar(input)
                    local rel = input.Position.X - bar.AbsolutePosition.X
                    local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pct + 0.5)
                    
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    label.Text = text .. ": " .. value
                    
                    if value ~= currentSeekBarValue then
                        currentSeekBarValue = value
                        if callback then callback(currentSeekBarValue) end
                    end
                end

                bar.InputBegan:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = true
                        updateSeekBar(input)
                        TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play() -- Aumenta o knob ao arrastar
                    end
                end)

                bar.InputEnded:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = false
                        TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play() -- Retorna o tamanho normal
                    end
                end)

                bar.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        updateSeekBar(input)
                    end
                end)
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, value)
                        local pct = math.clamp((value - min) / (max - min), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, 0, 0.5, 0)
                        label.Text = text .. ": " .. value
                        currentSeekBarValue = value
                    end,
                    Get = function()
                        return currentSeekBarValue
                    end
                }
            end,

            AddDropdown = function(_, text, options, default, callback)
                local container = Instance.new("Frame")
                container.Name = "DropdownContainer"
                container.Size = UDim2.new(1, 0, 0, 40) -- Altura maior
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Text = text
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = container

                local dropdown = Instance.new("TextButton")
                dropdown.Name = "DropdownButton"
                dropdown.Size = UDim2.new(0.3, 0, 1, 0)
                dropdown.Position = UDim2.new(0.7, 0, 0, 0)
                dropdown.Text = options[default] or "Select"
                dropdown.TextColor3 = ColorPalette.Text
                dropdown.Font = Enum.Font.Gotham
                dropdown.TextSize = 14
                dropdown.BackgroundColor3 = ColorPalette.Button
                dropdown.AutoButtonColor = false
                Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
                dropdown.Parent = container
                
                -- Adiciona uma seta para indicar que é um dropdown
                local Arrow = Instance.new("ImageLabel")
                Arrow.Size = UDim2.new(0, 16, 0, 16)
                Arrow.Position = UDim2.new(1, -20, 0.5, -8)
                Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
                Arrow.Image = "rbxassetid://6034177579" -- Exemplo de asset para seta para baixo
                Arrow.ImageColor3 = ColorPalette.Text
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = dropdown

                local dropdownList = Instance.new("ScrollingFrame")
                dropdownList.Name = "DropdownList"
                dropdownList.Size = UDim2.new(0.3, 0, 0, math.min(#options * 30, 150)) -- Altura dinâmica, mas limitada para não ser muito grande
                dropdownList.Position = UDim2.new(0.7, 0, 1, 5)
                dropdownList.BackgroundColor3 = ColorPalette.Content
                dropdownList.BorderSizePixel = 0
                dropdownList.Visible = false
                dropdownList.ScrollBarThickness = 6
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 30) -- Ajusta o CanvasSize para todas as opções
                Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 6)
                dropdownList.ZIndex = 3 -- Garante que o dropdown fique acima de outros elementos
                dropdownList.Parent = container

                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, 3)
                layout.FillDirection = Enum.FillDirection.Vertical
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                layout.Parent = dropdownList
                
                -- Adiciona um UIPadding para as opções
                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.PaddingTop = UDim.new(0, 5)
                OptionPadding.PaddingBottom = UDim.new(0, 5)
                OptionPadding.PaddingLeft = UDim.new(0, 5)
                OptionPadding.PaddingRight = UDim.new(0, 5)
                OptionPadding.Parent = dropdownList

                for i, option in ipairs(options) do -- Usar ipairs para iteração ordenada
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Name = "Option_" .. option:gsub(" ", "")
                    optionBtn.Size = UDim2.new(1, 0, 0, 30) -- Altura maior para toque
                    optionBtn.Text = option
                    optionBtn.TextColor3 = ColorPalette.Text
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.TextSize = 14
                    optionBtn.BackgroundColor3 = ColorPalette.Button
                    optionBtn.AutoButtonColor = false
                    Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 4)
                    optionBtn.Parent = dropdownList

                    optionBtn.MouseEnter:Connect(function()
                        TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = ColorPalette.ButtonHover
                        }):Play()
                    end)
                    optionBtn.MouseLeave:Connect(function()
                        TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = ColorPalette.Button
                        }):Play()
                    end)
                    optionBtn.MouseButton1Click:Connect(function()
                        dropdown.Text = option
                        dropdownList.Visible = false
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play() -- Gira a seta para cima
                        if callback then callback(i, option) end
                    end)
                end

                dropdown.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    if dropdownList.Visible then
                         TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play() -- Gira a seta para baixo
                    else
                         TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play() -- Gira a seta para cima
                    end
                end)
                
                -- Ajusta o CanvasSize da página
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, index)
                        if options[index] then
                            dropdown.Text = options[index]
                            if callback then callback(index, options[index]) end
                        end
                    end,
                    Get = function()
                        return table.find(options, dropdown.Text)
                    end
                }
            end
        }
    end

    return Library
end

return Library
