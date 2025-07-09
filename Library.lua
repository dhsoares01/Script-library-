-- DarkTabbedGUI.lua
-- Biblioteca GUI em Lua com Menu em Abas (Tabs), tema escuro, e suporte multiplataforma
-- Autor: ChatGPT 
-- Uso: local GUI = require(caminho.para.DarkTabbedGUI).new("Meu Menu", game.Players.LocalPlayer.PlayerGui)

local DarkTabbedGUI = {}
DarkTabbedGUI.__index = DarkTabbedGUI

-- Configurações de tema e dimensões
local theme = {
    bgColor = Color3.fromRGB(28, 28, 30),         -- fundo escuro geral
    tabBgColor = Color3.fromRGB(38, 38, 40),      -- fundo da coluna de abas
    tabSelectedColor = Color3.fromRGB(58, 58, 60), -- Cor de aba selecionada
    elementBgColor = Color3.fromRGB(48, 48, 50),  -- Cor de fundo de elementos (toggle, slider, etc.)
    elementHoverColor = Color3.fromRGB(78, 78, 80), -- Cor de hover para elementos
    borderColor = Color3.fromRGB(60, 60, 65),     -- Cor da borda
    textColor = Color3.fromRGB(220, 220, 220),    -- Cor do texto
    borderRadius = 8,                             -- Raio de arredondamento
    font = Enum.Font.Gotham,                      -- Fonte padrão
    headerHeight = 32,                            -- Altura do cabeçalho
    tabWidth = 140,                               -- Largura da coluna de abas
    scrollBarWidth = 6,                           -- Largura da barra de rolagem
}

-- Função auxiliar para criar bordas sutis (revisada para ser mais funcional)
local function createBorder(frame, radius, sides)
    -- sides: table com as bordas que devem aparecer ("Top", "Bottom", "Left", "Right")
    -- Para arredondamento de cantos, prefira UICorner. Esta função é para bordas finas.
    
    local borders = {}
    local borderThickness = 1
    local color = theme.borderColor

    if not sides or #sides == 0 then
        sides = {"Top", "Bottom", "Left", "Right"}
    end

    for _, side in pairs(sides) do
        local border = Instance.new("Frame")
        border.BackgroundColor3 = color
        border.BorderSizePixel = 0
        border.Name = "Border"..side
        border.ZIndex = frame.ZIndex + 1 -- ZIndex corrigido para ser logo acima do frame
        border.Parent = frame
        if side == "Top" then
            border.Size = UDim2.new(1, 0, 0, borderThickness)
            border.Position = UDim2.new(0, 0, 0, 0)
        elseif side == "Bottom" then
            border.Size = UDim2.new(1, 0, 0, borderThickness)
            border.Position = UDim2.new(0, 0, 1, -borderThickness)
        elseif side == "Left" then
            border.Size = UDim2.new(0, borderThickness, 1, 0)
            border.Position = UDim2.new(0, 0, 0, 0)
        elseif side == "Right" then
            border.Size = UDim2.new(0, borderThickness, 1, 0)
            border.Position = UDim2.new(1, -borderThickness, 0, 0)
        end
        table.insert(borders, border)
    end
    return borders
end

-- Função auxiliar para criar um botão simples
local function createButton(text, parent, size, position, fontSize, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = theme.elementBgColor
    btn.Size = size or UDim2.new(0, 100, 0, 30)
    btn.Position = position or UDim2.new(0, 0, 0, 0)
    btn.Text = text or ""
    btn.Font = theme.font
    btn.TextSize = fontSize or 16
    btn.TextColor3 = theme.textColor
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    btn.ZIndex = 100

    -- Adiciona UICorner para arredondamento
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.borderRadius / 2) -- Botões menores, então um raio menor
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = theme.elementHoverColor
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = theme.elementBgColor
    end)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- Função auxiliar para criar Label simples
local function createLabel(text, parent, size, position, fontSize, bold)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = size or UDim2.new(1, 0, 0, 24)
    lbl.Position = position or UDim2.new(0, 0, 0, 0)
    lbl.Text = text or ""
    lbl.Font = bold and Enum.Font.GothamBold or theme.font -- Aplica GothamBold se bold for true
    lbl.TextSize = fontSize or 16
    lbl.TextColor3 = theme.textColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.RichText = true
    lbl.Parent = parent
    lbl.ZIndex = 100
    return lbl
end

-- Criação de um Toggle (switch)
local function createToggle(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- UICorner para arredondar o container do toggle
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    containerCorner.Parent = container

    local lbl = createLabel(text, container, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -48, 0, 5)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(56, 181, 73) or Color3.fromRGB(90, 90, 90)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Font = theme.font
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = theme.textColor
    toggleBtn.Parent = container
    toggleBtn.ZIndex = 101

    -- UICorner para o botão do toggle
    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(0, 10) -- Arredondamento maior para o estilo pill
    toggleBtnCorner.Parent = toggleBtn

    local toggled = default
    local function updateToggle()
        if toggled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            toggleBtn.Text = "OFF"
        end
        if callback then
            -- Adiciona um atraso para evitar chamadas duplicadas se o clique for rápido
            task.spawn(function() callback(toggled) end)
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    updateToggle() -- Garante que o estado inicial seja aplicado
    return container, function(val) toggled = val; updateToggle() end -- Retorna o container e a função de atualização
end

-- Criação de ButtonOnOff (botão que alterna estado) - Semelhante ao Toggle, mas com texto maior para o estado
local function createButtonOnOff(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- UICorner para arredondar o container
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    containerCorner.Parent = container

    local lbl = createLabel(text, container, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 24)
    btn.Position = UDim2.new(1, -70, 0, 3)
    btn.BackgroundColor3 = default and Color3.fromRGB(56, 181, 73) or Color3.fromRGB(90, 90, 90)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = default and "ON" or "OFF"
    btn.Font = theme.font
    btn.TextSize = 14
    btn.TextColor3 = theme.textColor
    btn.Parent = container
    btn.ZIndex = 101

    -- UICorner para o botão ON/OFF
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    btnCorner.Parent = btn

    local toggled = default
    local function updateButton()
        if toggled then
            btn.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            btn.Text = "OFF"
        end
        if callback then
            task.spawn(function() callback(toggled) end)
        end
    end

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateButton()
    end)

    updateButton() -- Garante que o estado inicial seja aplicado
    return container, function(val) toggled = val; updateButton() end
end

-- Criação de Slider (0 a 100 por padrão)
local function createSlider(parent, text, default, minVal, maxVal, callback)
    minVal = minVal or 0
    maxVal = maxVal or 100
    default = math.clamp(default or minVal, minVal, maxVal) -- Garante que o default esteja dentro dos limites

    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- UICorner para arredondar o container do slider
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    containerCorner.Parent = container

    local lbl = createLabel(text, container, UDim2.new(1, -50, 0, 20), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = theme.font
    lbl.TextSize = 14

    local sliderBar = Instance.new("Frame")
    sliderBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    sliderBar.Size = UDim2.new(1, -20, 0, 8) -- Diminuído a altura da barra
    sliderBar.Position = UDim2.new(0, 10, 0, 28) -- Ajustada a posição para baixo
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container
    sliderBar.ZIndex = 100

    -- UICorner para a barra do slider
    local sliderBarCorner = Instance.new("UICorner")
    sliderBarCorner.CornerRadius = UDim.new(0, 4) -- Arredondamento da barra
    sliderBarCorner.Parent = sliderBar

    local fillBar = Instance.new("Frame")
    fillBar.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
    fillBar.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
    fillBar.Position = UDim2.new(0, 0, 0, 0)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar
    fillBar.ZIndex = 101

    -- UICorner para a barra de preenchimento
    local fillBarCorner = Instance.new("UICorner")
    fillBarCorner.CornerRadius = UDim.new(0, 4)
    fillBarCorner.Parent = fillBar

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16) -- Botão de arrastar maior
    sliderButton.Position = UDim2.new((default - minVal) / (maxVal - minVal), -8, 0, -4) -- Posição ajustada
    sliderButton.BackgroundColor3 = theme.textColor -- Cor do botão de arrastar
    sliderButton.BorderSizePixel = 0
    sliderButton.AutoButtonColor = false
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    sliderButton.ZIndex = 102
    sliderButton.Modal = true -- Importante para capturar o input mesmo fora do frame do botão

    -- UICorner para o botão de arrastar
    local sliderBtnCorner = Instance.new("UICorner")
    sliderBtnCorner.CornerRadius = UDim.new(0, 8) -- Botão redondo
    sliderBtnCorner.Parent = sliderButton

    local valueLbl = createLabel(tostring(default), container, UDim2.new(0, 50, 0, 20), UDim2.new(1, -58, 0, 0))
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Font = theme.font
    valueLbl.TextSize = 14

    local dragging = false
    local UserInputService = game:GetService("UserInputService")

    local function updateValue(inputPos)
        local relativeX = math.clamp(inputPos.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
        local val = minVal + (relativeX / sliderBar.AbsoluteSize.X) * (maxVal - minVal)
        val = math.floor(val + 0.5) -- Arredonda para o inteiro mais próximo

        -- Atualiza visualmente o slider e o valor
        local normalizedVal = (val - minVal) / (maxVal - minVal)
        fillBar.Size = UDim2.new(normalizedVal, 0, 1, 0)
        sliderButton.Position = UDim2.new(normalizedVal, -8, 0, -4)
        valueLbl.Text = tostring(val)

        if callback then
            task.spawn(function() callback(val) end)
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
        end
    end)

    -- Permite arrastar pela barra também
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position)
        end
    end)

    return container, function(val) -- Retorna o container e a função para setar o valor
        val = math.clamp(val, minVal, maxVal)
        local normalizedVal = (val - minVal) / (maxVal - minVal)
        fillBar.Size = UDim2.new(normalizedVal, 0, 1, 0)
        sliderButton.Position = UDim2.new(normalizedVal, -8, 0, -4)
        valueLbl.Text = tostring(val)
        if callback then
            task.spawn(function() callback(val) end)
        end
    end
end

-- Criação Dropdown simples (clicar para abrir lista, selecionar valor)
local function createDropdown(parent, text, options, defaultIndex, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- UICorner para o container do dropdown
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    containerCorner.Parent = container

    local lbl = createLabel(text, container, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local selectedIndex = defaultIndex or 1
    if not options[selectedIndex] then selectedIndex = 1 end -- Garante um índice válido

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0, 110, 0, 28)
    dropdownBtn.Position = UDim2.new(1, -120, 0, 1)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.TextColor3 = theme.textColor
    dropdownBtn.Font = theme.font
    dropdownBtn.TextSize = 14
    dropdownBtn.Text = options[selectedIndex] or "Select"
    dropdownBtn.Parent = container
    dropdownBtn.ZIndex = 101

    -- UICorner para o botão do dropdown
    local dropdownBtnCorner = Instance.new("UICorner")
    dropdownBtnCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    dropdownBtnCorner.Parent = dropdownBtn

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0, 110, 0, 100) -- Altura padrão da lista
    listFrame.Position = UDim2.new(1, -120, 0, 30)
    listFrame.BackgroundColor3 = theme.elementBgColor
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = container
    listFrame.ZIndex = 102
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = theme.scrollBarWidth
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- UICorner para o frame da lista do dropdown
    local listFrameCorner = Instance.new("UICorner")
    listFrameCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    listFrameCorner.Parent = listFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = listFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 2)

    local function updateCanvasSize()
        -- Adiciona um pequeno padding extra para evitar que a barra de rolagem corte o último item
        local layoutSize = uiListLayout.AbsoluteContentSize
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layoutSize.Y + 4)
    end

    -- Conecta ao evento para atualizar o CanvasSize dinamicamente
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    local function closeDropdown()
        listFrame.Visible = false
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            updateCanvasSize() -- Atualiza o CanvasSize ao abrir
        end
    end)

    -- Fecha o dropdown se o usuário clicar fora dele
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input)
        if listFrame.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not input.Target:IsDescendantOf(listFrame) and input.Target ~= dropdownBtn then
                closeDropdown()
            end
        end
    end)

    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.BackgroundColor3 = theme.elementBgColor
        optionBtn.BorderSizePixel = 0
        optionBtn.Size = UDim2.new(1, 0, 0, 24)
        optionBtn.Text = option
        optionBtn.Font = theme.font
        optionBtn.TextSize = 14
        optionBtn.TextColor3 = theme.textColor
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = listFrame
        optionBtn.ZIndex = 103

        -- UICorner para os botões de opção
        local optionBtnCorner = Instance.new("UICorner")
        optionBtnCorner.CornerRadius = UDim.new(0, 4)
        optionBtnCorner.Parent = optionBtn

        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = theme.elementHoverColor
        end)
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = theme.elementBgColor
        end)

        optionBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            dropdownBtn.Text = option
            closeDropdown()
            if callback then task.spawn(function() callback(option, i) end) end
        end)
    end

    return container, function(index) -- Retorna o container e uma função para setar o valor programaticamente
        if options[index] then
            selectedIndex = index
            dropdownBtn.Text = options[index]
            if callback then task.spawn(function() callback(options[index], index) end) end
        end
    end
end

-- Dropdown ButtonOnOff (combina dropdown com botão ON/OFF)
local function createDropdownButtonOnOff(parent, text, options, defaultIndex, defaultToggle, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 35) -- Altura um pouco maior
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- UICorner para o container
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    containerCorner.Parent = container

    -- Label
    local lbl = createLabel(text, container, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = theme.font
    lbl.TextSize = 14

    -- Dropdown parte
    local selectedIndex = defaultIndex or 1
    if not options[selectedIndex] then selectedIndex = 1 end -- Garante um índice válido

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0, 110, 0, 28)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0, 3) -- Posição ajustada
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.TextColor3 = theme.textColor
    dropdownBtn.Font = theme.font
    dropdownBtn.TextSize = 14
    dropdownBtn.Text = options[selectedIndex] or "Select"
    dropdownBtn.Parent = container
    dropdownBtn.ZIndex = 101

    -- UICorner para o botão do dropdown
    local dropdownBtnCorner = Instance.new("UICorner")
    dropdownBtnCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    dropdownBtnCorner.Parent = dropdownBtn

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0, 110, 0, 100)
    listFrame.Position = UDim2.new(0.5, 0, 0, 35) -- Posição ajustada
    listFrame.BackgroundColor3 = theme.elementBgColor
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = container
    listFrame.ZIndex = 102
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = theme.scrollBarWidth
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- UICorner para o frame da lista
    local listFrameCorner = Instance.new("UICorner")
    listFrameCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    listFrameCorner.Parent = listFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = listFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 2)

    local function updateCanvasSize()
        local layoutSize = uiListLayout.AbsoluteContentSize
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layoutSize.Y + 4) -- Adiciona padding extra
    end
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    local function closeDropdown()
        listFrame.Visible = false
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            updateCanvasSize()
        end
    end)

    -- Fecha o dropdown se o usuário clicar fora dele
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input)
        if listFrame.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not input.Target:IsDescendantOf(listFrame) and input.Target ~= dropdownBtn and not input.Target:IsDescendantOf(toggleBtn) then
                closeDropdown()
            end
        end
    end)

    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.BackgroundColor3 = theme.elementBgColor
        optionBtn.BorderSizePixel = 0
        optionBtn.Size = UDim2.new(1, 0, 0, 24)
        optionBtn.Text = option
        optionBtn.Font = theme.font
        optionBtn.TextSize = 14
        optionBtn.TextColor3 = theme.textColor
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = listFrame
        optionBtn.ZIndex = 103

        -- UICorner para os botões de opção
        local optionBtnCorner = Instance.new("UICorner")
        optionBtnCorner.CornerRadius = UDim.new(0, 4)
        optionBtnCorner.Parent = optionBtn

        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundColor3 = theme.elementHoverColor
        end)
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundColor3 = theme.elementBgColor
        end)

        optionBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            dropdownBtn.Text = option
            closeDropdown()
            if callback then task.spawn(function() callback(selectedIndex, toggled) end) end
        end)
    end

    -- Botão ON/OFF
    local toggled = defaultToggle or false
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 28)
    toggleBtn.Position = UDim2.new(1, -70, 0, 3)
    toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(56, 181, 73) or Color3.fromRGB(90, 90, 90)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = toggled and "ON" or "OFF"
    toggleBtn.Font = theme.font
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = theme.textColor
    toggleBtn.Parent = container
    toggleBtn.ZIndex = 101

    -- UICorner para o botão ON/OFF
    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(0, theme.borderRadius / 2)
    toggleBtnCorner.Parent = toggleBtn

    local function updateToggle()
        if toggled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            toggleBtn.Text = "OFF"
        end
        if callback then task.spawn(function() callback(selectedIndex, toggled) end) end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    updateToggle()

    return container, function(index, val)
        if index and options[index] then
            selectedIndex = index
            dropdownBtn.Text = options[index]
        end
        if val ~= nil then
            toggled = val
        end
        updateToggle()
    end
end

-- Função para tornar um frame arrastável (suporta mouse e toque)
local function makeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
        end
    end)
end

-- Criação do menu principal com abas
function DarkTabbedGUI.new(title, parent)
    parent = parent or game:GetService("CoreGui") -- Permite definir o pai do GUI

    -- Cria uma ScreenGui para garantir que a GUI apareça corretamente
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkTabbedScreenGui"
    screenGui.Parent = parent
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Garante que a GUI esteja acima de outras UIs

    local self = setmetatable({}, DarkTabbedGUI)

    -- Container principal
    local container = Instance.new("Frame")
    container.Name = "DarkTabbedGUI"
    container.Size = UDim2.new(0, 480, 0, 320)
    container.Position = UDim2.new(0.5, -240, 0.5, -160) -- Centralizado
    container.BackgroundColor3 = theme.bgColor
    container.BorderSizePixel = 0
    container.Parent = screenGui -- O container principal agora é filho da ScreenGui
    container.ZIndex = 1000
    container.ClipsDescendants = true
    self.Container = container

    -- Arredondar somente os cantos do container
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.borderRadius)
    corner.Parent = container

    -- Cabeçalho
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = theme.tabBgColor
    header.Size = UDim2.new(1, 0, 0, theme.headerHeight)
    header.Parent = container
    header.ZIndex = 1001 -- Deve estar acima dos outros elementos para ser clicável

    -- Apenas os cantos superiores do cabeçalho devem ser arredondados
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, theme.borderRadius)
    headerCorner.Parent = header

    -- Título centralizado
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Menu"
    titleLabel.Font = theme.font
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = theme.textColor
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = header
    titleLabel.ZIndex = 1002

    -- Botões no canto direito (Minimizar, Fechar)
    local btnMinimize = createButton("–", header, UDim2.new(0, 40, 1, 0), UDim2.new(1, -80, 0, 0), 20)
    local btnClose = createButton("×", header, UDim2.new(0, 40, 1, 0), UDim2.new(1, -40, 0, 0), 20)
    
    btnMinimize.ZIndex = 1002
    btnClose.ZIndex = 1002

    -- Container de abas (lado esquerdo)
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.BackgroundColor3 = theme.tabBgColor
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Size = UDim2.new(0, theme.tabWidth, 1, -theme.headerHeight)
    tabsFrame.Position = UDim2.new(0, 0, 0, theme.headerHeight)
    tabsFrame.Parent = container
    tabsFrame.ZIndex = 1001

    -- UIListLayout para organizar as abas verticalmente
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = tabsFrame
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 4) -- Espaçamento entre as abas

    -- Container de conteúdo (lado direito)
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.BackgroundColor3 = theme.elementBgColor
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, theme.tabWidth, 0, theme.headerHeight)
    contentFrame.Size = UDim2.new(1, -theme.tabWidth, 1, -theme.headerHeight)
    contentFrame.Parent = container
    contentFrame.ZIndex = 1001
    contentFrame.ScrollBarThickness = theme.scrollBarWidth
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Importante para o scroll

    -- UICorner para o frame de conteúdo (apenas borda superior direita e inferior direita)
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, theme.borderRadius)
    contentCorner.Parent = contentFrame

    -- Adiciona cantos arredondados específicos ao contentFrame para que não se sobreponha à aba
    local contentUICorner = Instance.new("UICorner")
    contentUICorner.CornerRadius = UDim.new(0, theme.borderRadius)
    contentUICorner.Parent = contentFrame

    -- UIListLayout para organizar os elementos dentro do contentFrame
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8) -- Espaçamento entre os elementos

    -- Tabela para armazenar abas e conteúdos
    self.tabs = {}
    self.currentTab = nil

    -- Função para criar uma nova aba
    function self:AddTab(tabName)
        if self.tabs[tabName] then
            warn("Tab '" .. tabName .. "' already exists. Returning existing tab content.")
            return self.tabs[tabName].content
        end

        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. tabName
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundColor3 = theme.tabBgColor
        tabButton.BorderSizePixel = 0
        tabButton.Font = theme.font
        tabButton.TextSize = 15
        tabButton.TextColor3 = theme.textColor
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabsFrame
        tabButton.ZIndex = 1002

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = tabButton

        -- Conteúdo da aba (Frame filho do contentFrame)
        local tabContent = Instance.new("Frame")
        tabContent.Name = "Content_" .. tabName
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 0, 0) -- Tamanho inicial 0, será ajustado pelo AutomaticCanvasSize
        tabContent.Parent = contentFrame
        tabContent.Visible = false
        tabContent.ClipsDescendants = true -- Garante que os elementos filhos não ultrapassem os limites

        -- Layout para itens da aba
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = tabContent
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Padding = UDim.new(0, 8)

        -- Armazena referência
        self.tabs[tabName] = {
            button = tabButton,
            content = tabContent,
            layout = tabLayout
        }

        -- Função para selecionar esta aba
        local function selectTab()
            if self.currentTab then
                -- Reset visual da aba anterior
                self.tabs[self.currentTab].button.BackgroundColor3 = theme.tabBgColor
                self.tabs[self.currentTab].content.Visible = false
            end
            self.currentTab = tabName
            tabButton.BackgroundColor3 = theme.tabSelectedColor -- Usa a cor de aba selecionada
            tabContent.Visible = true
            -- Força a atualização do CanvasSize ao mudar de aba
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 8)
        end

        tabButton.MouseEnter:Connect(function()
            if self.currentTab ~= tabName then
                tabButton.BackgroundColor3 = theme.elementHoverColor
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if self.currentTab ~= tabName then
                tabButton.BackgroundColor3 = theme.tabBgColor
            end
        end)

        tabButton.MouseButton1Click:Connect(selectTab)

        -- Seleciona a primeira aba criada automaticamente
        if not self.currentTab then
            selectTab()
        end

        -- Retorna frame do conteúdo para adicionar elementos
        return tabContent
    end

    -- Função para limpar todo conteúdo (útil para fechar)
    function self:Clear()
        for _, tab in pairs(self.tabs) do
            tab.content:ClearAllChildren()
            tab.content:Destroy() -- Destrói os frames de conteúdo das abas
            tab.button:Destroy() -- Destrói os botões das abas
        end
        self.tabs = {}
        self.currentTab = nil
    end

    -- Função para fechar o menu (remove da parent)
    function self:Close()
        self:Clear()
        container:Destroy() -- Destrói o container principal
        screenGui:Destroy() -- Destrói a ScreenGui completa
    end

    -- Controle do botão minimizar/maximizar
    local minimized = false
    local originalSize = container.Size
    local originalPosition = container.Position

    btnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tabsFrame.Visible = false
            contentFrame.Visible = false
            container.Size = UDim2.new(0, theme.tabWidth, 0, theme.headerHeight) -- Tamanho apenas do cabeçalho
            container.Position = UDim2.new(1, -container.AbsoluteSize.X - 10, 0, 10) -- Move para o canto superior direito
            btnMinimize.Text = "□"
        else
            tabsFrame.Visible = true
            contentFrame.Visible = true
            container.Size = originalSize
            container.Position = originalPosition
            btnMinimize.Text = "–"
        end
    end)

    -- Botão fechar: fecha e limpa
    btnClose.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Tornar o menu arrastável
    makeDraggable(header)

    -- Funções para adicionar os elementos obrigatórios em abas
    function self:AddToggle(tabName, labelText, default, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local container, setter = createToggle(tab.content, labelText, default, callback)
        container.LayoutOrder = #tab.content:GetChildren() + 1
        return container, setter
    end

    function self:AddButtonOnOff(tabName, labelText, default, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local container, setter = createButtonOnOff(tab.content, labelText, default, callback)
        container.LayoutOrder = #tab.content:GetChildren() + 1
        return container, setter
    end

    function self:AddSlider(tabName, labelText, min, max, default, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local container, setter = createSlider(tab.content, labelText, default, min, max, callback) -- Ordem dos argumentos corrigida
        container.LayoutOrder = #tab.content:GetChildren() + 1
        return container, setter
    end

    function self:AddDropdown(tabName, labelText, options, defaultIndex, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local container, setter = createDropdown(tab.content, labelText, options, defaultIndex, callback)
        container.LayoutOrder = #tab.content:GetChildren() + 1
        return container, setter
    end

    function self:AddDropdownButtonOnOff(tabName, labelText, options, defaultIndex, defaultToggle, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local container, setter = createDropdownButtonOnOff(tab.content, labelText, options, defaultIndex, defaultToggle, callback)
        container.LayoutOrder = #tab.content:GetChildren() + 1
        return container, setter
    end

    function self:AddLabel(tabName, text, bold) -- Adicionado parâmetro 'bold'
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local lbl = createLabel(text, tab.content, UDim2.new(1, 0, 0, 24), UDim2.new(0, 8, 0, 4), nil, bold)
        lbl.LayoutOrder = #tab.content:GetChildren() + 1
        return lbl
    end

    return self
end

return DarkTabbedGUI


