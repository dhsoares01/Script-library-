-- DarkTabbedGUI.lua
-- Biblioteca GUI em Lua com Menu em Abas (Tabs), tema escuro, e suporte multiplataforma
-- Autor: ChatGPT
-- Uso: local GUI = loadstring([==[ <código aqui> ]==])(); GUI:Init(...)

local DarkTabbedGUI = {}
DarkTabbedGUI.__index = DarkTabbedGUI

-- Configurações de tema e dimensões
local theme = {
    bgColor = Color3.fromRGB(28, 28, 30),         -- fundo escuro geral
    tabBgColor = Color3.fromRGB(38, 38, 40),      -- fundo da coluna de abas
    tabSelectedColor = Color3.fromRGB(58, 58, 60),
    elementBgColor = Color3.fromRGB(48, 48, 50),
    elementHoverColor = Color3.fromRGB(78, 78, 80),
    borderColor = Color3.fromRGB(60, 60, 65),
    textColor = Color3.fromRGB(220, 220, 220),
    borderRadius = 8,
    font = Enum.Font.Gotham,
    headerHeight = 32,
    tabWidth = 140,
    scrollBarWidth = 6,
}

-- Função auxiliar para criar bordas sutis
local function createBorder(frame, radius, sides)
    -- sides: table com as bordas que devem aparecer ("Top", "Bottom", "Left", "Right")
    -- Implementação simples: adiciona frames finos nas bordas desejadas, arredondando apenas em regiões isoladas
    
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
        border.ZIndex = frame.ZIndex + 10
        border.Parent = frame
        if side == "Top" then
            border.Size = UDim2.new(1, 0, 0, borderThickness)
            border.Position = UDim2.new(0, 0, 0, 0)
            border.ClipsDescendants = false
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

-- Função auxiliar para criar um botão simples (usado para abas, minimizar, fechar, etc)
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
    lbl.Font = theme.font
    lbl.TextSize = fontSize or 16
    lbl.TextColor3 = theme.textColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.RichText = true
    if bold then
        lbl.Font = Enum.Font.GothamBold
    end
    lbl.Parent = parent
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
            callback(toggled)
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)

    updateToggle()
    return container, function(val) toggled = val; updateToggle() end
end

-- Criação de ButtonOnOff (botão que alterna estado)
local function createButtonOnOff(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

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
            callback(toggled)
        end
    end

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateButton()
    end)

    updateButton()
    return container, function(val) toggled = val; updateButton() end
end

-- Criação de Slider (0 a 100 por padrão)
local function createSlider(parent, text, default, minVal, maxVal, callback)
    minVal = minVal or 0
    maxVal = maxVal or 100
    default = default or minVal
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    local lbl = createLabel(text, container, UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = theme.font
    lbl.TextSize = 14

    local sliderBar = Instance.new("Frame")
    sliderBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    sliderBar.Size = UDim2.new(1, -20, 0, 12)
    sliderBar.Position = UDim2.new(0, 10, 0, 24)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container
    sliderBar.ZIndex = 100

    local fillBar = Instance.new("Frame")
    fillBar.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
    fillBar.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
    fillBar.Position = UDim2.new(0, 0, 0, 0)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar
    fillBar.ZIndex = 101

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 1, 0)
    sliderButton.Position = UDim2.new((default - minVal) / (maxVal - minVal), -8, 0, 0)
    sliderButton.BackgroundColor3 = theme.elementBgColor
    sliderButton.BorderSizePixel = 0
    sliderButton.AutoButtonColor = false
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    sliderButton.ZIndex = 102
    sliderButton.Modal = false

    local valueLbl = createLabel(tostring(default), container, UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0, 0))
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Font = theme.font
    valueLbl.TextSize = 14

    local dragging = false
    local sliderWidth = sliderBar.AbsoluteSize.X

    local function updateValue(x)
        local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
        local val = minVal + (relativeX / sliderBar.AbsoluteSize.X) * (maxVal - minVal)
        val = math.floor(val + 0.5) -- arredonda valor
        fillBar.Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0)
        sliderButton.Position = UDim2.new((val - minVal) / (maxVal - minVal), -8, 0, 0)
        valueLbl.Text = tostring(val)
        if callback then
            callback(val)
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    sliderBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)

    -- Suporte mobile arrastar slider pela barra também
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return container, function(val)
        val = math.clamp(val, minVal, maxVal)
        fillBar.Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0)
        sliderButton.Position = UDim2.new((val - minVal) / (maxVal - minVal), -8, 0, 0)
        valueLbl.Text = tostring(val)
        if callback then
            callback(val)
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

    local lbl = createLabel(text, container, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local selectedIndex = defaultIndex or 1
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

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0, 110, 0, 100)
    listFrame.Position = UDim2.new(1, -120, 0, 30)
    listFrame.BackgroundColor3 = theme.elementBgColor
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = container
    listFrame.ZIndex = 102
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 6
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = listFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 2)

    local function updateCanvasSize()
        local layoutSize = uiListLayout.AbsoluteContentSize
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layoutSize.Y)
    end

    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    local function closeDropdown()
        listFrame.Visible = false
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
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
            if callback then callback(option, i) end
        end)
    end

    return container, function(index)
        if options[index] then
            selectedIndex = index
            dropdownBtn.Text = options[index]
            if callback then callback(options[index], index) end
        end
    end
end

-- Dropdown ButtonOnOff (dropdown + on/off botão)
-- Continuando...

-- Dropdown ButtonOnOff (combina dropdown com botão ON/OFF)
local function createDropdownButtonOnOff(parent, text, options, defaultIndex, defaultToggle, callback)
    local container = Instance.new("Frame")
    container.BackgroundColor3 = theme.elementBgColor
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BorderSizePixel = 0
    container.Parent = parent
    container.ZIndex = 100

    -- Label
    local lbl = createLabel(text, container, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 8, 0, 0))
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = theme.font
    lbl.TextSize = 14

    -- Dropdown parte
    local selectedIndex = defaultIndex or 1
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0, 110, 0, 28)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0, 3)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.TextColor3 = theme.textColor
    dropdownBtn.Font = theme.font
    dropdownBtn.TextSize = 14
    dropdownBtn.Text = options[selectedIndex] or "Select"
    dropdownBtn.Parent = container
    dropdownBtn.ZIndex = 101

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0, 110, 0, 100)
    listFrame.Position = UDim2.new(0.5, 0, 0, 35)
    listFrame.BackgroundColor3 = theme.elementBgColor
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = container
    listFrame.ZIndex = 102
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 6
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = listFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 2)

    local function updateCanvasSize()
        local layoutSize = uiListLayout.AbsoluteContentSize
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layoutSize.Y)
    end
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

    local function closeDropdown()
        listFrame.Visible = false
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
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
            if callback then callback(selectedIndex, toggled) end
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

    local function updateToggle()
        if toggled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(56, 181, 73)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            toggleBtn.Text = "OFF"
        end
        if callback then callback(selectedIndex, toggled) end
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
    local dragging, dragInput, dragStart, startPos

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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
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
end

-- Criação do menu principal com abas
function DarkTabbedGUI.new(title, parent)
    parent = parent or game:GetService("CoreGui") -- Pode ser alterado conforme uso
    local self = setmetatable({}, DarkTabbedGUI)

    -- Container principal
    local container = Instance.new("Frame")
    container.Name = "DarkTabbedGUI"
    container.Size = UDim2.new(0, 480, 0, 320)
    container.Position = UDim2.new(0.5, -240, 0.5, -160)
    container.BackgroundColor3 = theme.bgColor
    container.BorderSizePixel = 0
    container.Parent = parent
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

    -- Botões no canto direito (Minimizar, Fechar)
    local btnMinimize = createButton("–", header, UDim2.new(0, 40, 1, 0), UDim2.new(1, -80, 0, 0), 20)
    local btnClose = createButton("×", header, UDim2.new(0, 40, 1, 0), UDim2.new(1, -40, 0, 0), 20)

    -- Container de abas (lado esquerdo)
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.BackgroundColor3 = theme.tabBgColor
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Size = UDim2.new(0, theme.tabWidth, 1, -theme.headerHeight)
    tabsFrame.Position = UDim2.new(0, 0, 0, theme.headerHeight)
    tabsFrame.Parent = container
    tabsFrame.ZIndex = 1001

    local tabsCorner = Instance.new("UICorner")
    tabsCorner.CornerRadius = UDim.new(0, 0) -- canto reto pois conecta com área direita
    tabsCorner.Parent = tabsFrame

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
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, theme.borderRadius)
    contentCorner.Parent = contentFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0,8)

    -- Tabela para armazenar abas e conteúdos
    self.tabs = {}
    self.currentTab = nil

    -- Função para criar uma nova aba
    function self:AddTab(tabName)
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
        tabContent.Size = UDim2.new(1, 0, 0, 0) -- tamanho dinâmico conforme conteúdo
        tabContent.Parent = contentFrame
        tabContent.Visible = false

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
                -- Reset visual aba anterior
                self.tabs[self.currentTab].button.BackgroundColor3 = theme.tabBgColor
                self.tabs[self.currentTab].content.Visible = false
            end
            self.currentTab = tabName
            tabButton.BackgroundColor3 = theme.elementHoverColor
            tabContent.Visible = true
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
        end
        self.tabs = {}
        self.currentTab = nil
    end

    -- Função para fechar o menu (remove da parent)
    function self:Close()
        self:Clear()
        container:Destroy()
    end

    -- Controle do botão minimizar/maximizar
    local minimized = false
    btnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tabsFrame.Visible = false
            contentFrame.Visible = false
            container.Size = UDim2.new(0, 150, 0, theme.headerHeight)
            btnMinimize.Text = "□"
        else
            tabsFrame.Visible = true
            contentFrame.Visible = true
            container.Size = UDim2.new(0, 480, 0, 320)
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
        local toggle = createToggle(tab.content, labelText, default, callback)
        toggle.LayoutOrder = #tab.content:GetChildren() + 1
        return toggle
    end

    function self:AddButtonOnOff(tabName, labelText, default, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local button = createButtonOnOff(tab.content, labelText, default, callback)
        button.LayoutOrder = #tab.content:GetChildren() + 1
        return button
    end

    function self:AddSlider(tabName, labelText, min, max, default, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local slider = createSlider(tab.content, labelText, min, max, default, callback)
        slider.LayoutOrder = #tab.content:GetChildren() + 1
        return slider
    end

    function self:AddDropdown(tabName, labelText, options, defaultIndex, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local dropdown = createDropdown(tab.content, labelText, options, defaultIndex, callback)
        dropdown.LayoutOrder = #tab.content:GetChildren() + 1
        return dropdown
    end

    function self:AddDropdownButtonOnOff(tabName, labelText, options, defaultIndex, defaultToggle, callback)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local combo = createDropdownButtonOnOff(tab.content, labelText, options, defaultIndex, defaultToggle, callback)
        combo.LayoutOrder = #tab.content:GetChildren() + 1
        return combo
    end

    function self:AddLabel(tabName, text)
        local tab = self.tabs[tabName]
        if not tab then error("Tab '"..tabName.."' não existe") end
        local lbl = createLabel(text, tab.content, UDim2.new(1, 0, 0, 24), UDim2.new(0, 8, 0, 4))
        lbl.LayoutOrder = #tab.content:GetChildren() + 1
        return lbl
    end

    return self
end

return DarkTabbedGUI
