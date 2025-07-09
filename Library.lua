-- ScriptLibrary GUI v1.0 (Dark Theme, Tabs, Mobile+PC)
-- Biblioteca GUI Lua pronta para uso via loadstring
-- Estrutura: menu com abas (esquerda) e conteúdo (direita)
-- Controles no cabeçalho: minimizar (toggle) e fechar (fecha menu)

local GUI = {}
GUI.__index = GUI

-- Configurações gerais do tema (dark)
local THEME = {
    bg = Color3.fromRGB(30,30,35),
    bgLight = Color3.fromRGB(40,40,45),
    bgLighter = Color3.fromRGB(50,50,55),
    accent = Color3.fromRGB(100, 150, 255),
    text = Color3.fromRGB(230,230,230),
    textDisabled = Color3.fromRGB(130,130,130),
    border = Color3.fromRGB(70,70,80),
    borderLight = Color3.fromRGB(100,100,110),
}

-- Função utilitária para arredondar cantos seletivos (usando UIStroke + UICorner)
local function createRoundedFrame(parent, size, position, bgColor, roundCorners)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = bgColor
    frame.Size = size
    frame.Position = position
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.Parent = frame

    -- roundCorners: table with keys: TopLeft, TopRight, BottomLeft, BottomRight (boolean)
    -- em Roblox nativo UICorner arredonda todos cantos iguais, então para cantos seletivos
    -- podemos criar máscaras ou contornar com bordas discretas e shapes. Aqui, 
    -- para simplificar, arredondamos todos ou nenhum (exigência visual)
    -- Então, arredondamos só se for área isolada (roundCorners == true)
    if roundCorners then
        corner.CornerRadius = UDim.new(0,8)
    else
        corner.CornerRadius = UDim.new(0,0)
    end

    return frame
end

-- Função para criar texto com configuração padrão
local function createLabel(parent, text, size, position, fontSize, bold, color, alignment)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Text = text or ""
    label.Size = size or UDim2.new(1,0,0,20)
    label.Position = position or UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or THEME.text
    label.TextScaled = false
    label.Font = bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    label.TextSize = fontSize or 16
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ClipsDescendants = true
    return label
end

-- Função para criar botão simples
local function createButton(parent, text, size, position)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Text = text or "Button"
    btn.Size = size or UDim2.new(0,100,0,30)
    btn.Position = position or UDim2.new(0,0,0,0)
    btn.BackgroundColor3 = THEME.bgLight
    btn.TextColor3 = THEME.text
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 16
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0,6)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = THEME.accent
        btn.TextColor3 = Color3.new(1,1,1)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = THEME.bgLight
        btn.TextColor3 = THEME.text
    end)
    return btn
end

-- Toggle simples (checkbox-like)
local function createToggle(parent, labelText, size, position)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0,140,0,30)
    frame.Position = position or UDim2.new(0,0,0,0)
    frame.BackgroundTransparency = 1

    local box = Instance.new("TextButton")
    box.Parent = frame
    box.Size = UDim2.new(0,24,0,24)
    box.Position = UDim2.new(0,0,0,3)
    box.BackgroundColor3 = THEME.bgLight
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.Text = ""
    box.Name = "ToggleBox"

    local corner = Instance.new("UICorner")
    corner.Parent = box
    corner.CornerRadius = UDim.new(0,5)

    local check = Instance.new("Frame")
    check.Parent = box
    check.Size = UDim2.new(0,16,0,16)
    check.Position = UDim2.new(0,4,0,4)
    check.BackgroundColor3 = THEME.accent
    check.Visible = false
    check.Name = "CheckMark"
    local checkCorner = Instance.new("UICorner")
    checkCorner.Parent = check
    checkCorner.CornerRadius = UDim.new(0,3)

    local label = createLabel(frame, labelText or "Toggle", UDim2.new(1,-30,1,0), UDim2.new(0,30,0,0), 16, false, THEME.text, Enum.TextXAlignment.Left)

    local toggled = false

    local function updateVisual()
        check.Visible = toggled
        if toggled then
            label.TextColor3 = THEME.accent
        else
            label.TextColor3 = THEME.text
        end
    end

    box.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateVisual()
    end)

    updateVisual()

    -- Interface API
    function frame:IsOn() return toggled end
    function frame:SetOn(state)
        toggled = state and true or false
        updateVisual()
    end

    return frame
end

-- ButtonOnOff (toggle button)
local function createButtonOnOff(parent, labelText, size, position)
    local btn = createButton(parent, labelText or "OnOff", size, position)
    local on = false
    local function update()
        if on then
            btn.BackgroundColor3 = THEME.accent
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Text = (labelText or "OnOff") .. ": ON"
        else
            btn.BackgroundColor3 = THEME.bgLight
            btn.TextColor3 = THEME.text
            btn.Text = (labelText or "OnOff") .. ": OFF"
        end
    end
    btn.MouseButton1Click:Connect(function()
        on = not on
        update()
    end)
    update()

    -- API
    function btn:IsOn() return on end
    function btn:SetOn(state)
        on = state and true or false
        update()
    end
    return btn
end

-- Slider (horizontal)
local function createSlider(parent, labelText, size, position, minValue, maxValue)
    minValue = minValue or 0
    maxValue = maxValue or 100
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0,180,0,40)
    frame.Position = position or UDim2.new(0,0,0,0)
    frame.BackgroundTransparency = 1

    local label = createLabel(frame, labelText or "Slider", UDim2.new(1,0,0,14), UDim2.new(0,0,0,0), 14, false, THEME.text, Enum.TextXAlignment.Left)

    local barBg = Instance.new("Frame")
    barBg.Parent = frame
    barBg.Size = UDim2.new(1,0,0,14)
    barBg.Position = UDim2.new(0,0,0,20)
    barBg.BackgroundColor3 = THEME.bgLight
    barBg.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.Parent = barBg
    corner.CornerRadius = UDim.new(0,7)

    local barFill = Instance.new("Frame")
    barFill.Parent = barBg
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.Position = UDim2.new(0,0,0,0)
    barFill.BackgroundColor3 = THEME.accent
    barFill.BorderSizePixel = 0
    local cornerFill = Instance.new("UICorner")
    cornerFill.Parent = barFill
    cornerFill.CornerRadius = UDim.new(0,7)

    local valueLabel = createLabel(frame, tostring(minValue), UDim2.new(0,40,0,14), UDim2.new(1,-45,0,0), 14, false, THEME.text, Enum.TextXAlignment.Right)

    local dragging = false
    local value = minValue

    local function updateValueFromPos(x)
        local relative = math.clamp(x - barBg.AbsolutePosition.X, 0, barBg.AbsoluteSize.X)
        local percent = relative / barBg.AbsoluteSize.X
        value = minValue + (maxValue - minValue) * percent
        valueLabel.Text = string.format("%.1f", value)
        barFill.Size = UDim2.new(percent, 0, 1, 0)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValueFromPos(input.Position.X)
        end
    end)
    barBg.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValueFromPos(input.Position.X)
        end
    end)
    barBg.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    -- API
    function frame:GetValue() return value end
    function frame:SetValue(newValue)
        value = math.clamp(newValue, minValue, maxValue)
        local percent = (value - minValue) / (maxValue - minValue)
        valueLabel.Text = string.format("%.1f", value)
        barFill.Size = UDim2.new(percent, 0, 1, 0)
    end

    return frame
end

-- Dropdown (basic)
local function createDropdown(parent, labelText, size, position, options)
    options = options or {"Option 1", "Option 2", "Option 3"}
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size or UDim2.new(0,150,0,30)
    frame.Position = position or UDim2.new(0,0,0,0)
    frame.BackgroundTransparency = 1

    local label = createLabel(frame, labelText or "Dropdown", UDim2.new(1,0,0,16), UDim2.new(0,0,0,0), 14, false, THEME.text, Enum.TextXAlignment.Left)

    local dropdownBtn = createButton(frame, options[1], UDim2.new(1,0,0,18), UDim2.new(0,0,0,14))
    dropdownBtn.AutoButtonColor = true

    local listFrame = Instance.new("Frame")
    listFrame.Parent = frame
    listFrame.Size = UDim2.new(1,0,0,#options * 20)
    listFrame.Position = UDim2.new(0,0,1,2)
    listFrame.BackgroundColor3 = THEME.bgLight
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    local listCorner = Instance.new("UICorner")
    listCorner.Parent = listFrame
    listCorner.CornerRadius = UDim.new(0,6)

    local selectedIndex = 1

    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = listFrame
        optBtn.Text = option
        optBtn.Size = UDim2.new(1,0,0,20)
        optBtn.Position = UDim2.new(0,0,0,(i-1)*20)
        optBtn.BackgroundColor3 = THEME.bgLight
        optBtn.BorderSizePixel = 0
        optBtn.TextColor3 = THEME.text
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 14
        optBtn.AutoButtonColor = true
        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = THEME.accent end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = THEME.bgLight end)
        optBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            dropdownBtn.Text = option
            listFrame.Visible = false
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)

    -- API
    function frame:GetValue()
        return options[selectedIndex], selectedIndex
    end
    function frame:SetValue(index)
        if options[index] then
            selectedIndex = index
            dropdownBtn.Text = options[index]
        end
    end

    return frame
end

-- Dropdown ButtonOnOff (dropdown + toggle)
local function createDropdownButtonOnOff(parent, labelText, size, position, options)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = size or UDim2.new(0,200,0,60)
    container.Position = position or UDim2.new(0,0,0,0)
    container.BackgroundTransparency = 1

    local dropdown = createDropdown(container, labelText, UDim2.new(1,0,0,30), UDim2.new(0,0,0,0), options)
    local btnOnOff = createButtonOnOff(container, labelText, UDim2.new(1,0,0,25), UDim2.new(0,0,0,32))

    -- API
    function container:GetValue()
        return dropdown:GetValue(), btnOnOff:IsOn()
    end
    function container:SetValue(index, onoff)
        dropdown:SetValue(index)
        btnOnOff:SetOn(onoff)
    end

    return container
end

-- Label simples
local function createLabelSimple(parent, text, size, position)
    return createLabel(parent, text, size, position, 16, false, THEME.text, Enum.TextXAlignment.Left)
end

-- ====== Menu Principal ======
function GUI.new(titleText)
    local self = setmetatable({}, GUI)

    -- Cria ScreenGui no PlayerGui
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptLibraryGUI"
    screenGui.Parent = playerGui
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.screenGui = screenGui

    -- Container principal (frame arredondado)
    local container = createRoundedFrame(screenGui, UDim2.new(0, 440, 0, 320), UDim2.new(0.5, 0, 0.5, 0), THEME.bg, true)
container.AnchorPoint = Vector2.new(0.5, 0.5)
    self.container = container

    -- Cabeçalho (height fixo, bg escuro)
    local header = Instance.new("Frame")
    header.Parent = container
    header.Size = UDim2.new(1,0,0,28)
    header.Position = UDim2.new(0,0,0,0)
    header.BackgroundColor3 = THEME.bgLighter
    header.BorderSizePixel = 1

    -- Arrastar: mouse + toque
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    container.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = container.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                     input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                     input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

    -- Bordas arredondadas apenas no topo
    local headerCorner = Instance.new("UICorner")
    headerCorner.Parent = header
    headerCorner.CornerRadius = UDim.new(0,8)

    -- Título centralizado
    local title = createLabel(header, titleText or "ScriptLibrary GUI", UDim2.new(1, -80, 1, 0), UDim2.new(0, 0, 0, 0), 18, true, THEME.text, Enum.TextXAlignment.Center)
    title.Position = UDim2.new(0, 0, 0, 0)

    -- Botões no canto direito do header
    local btnMinimize = createButton(header, "–", UDim2.new(0, 24, 1, 0), UDim2.new(1, -56, 0, 0))
    local btnClose = createButton(header, "×", UDim2.new(0, 24, 1, 0), UDim2.new(1, -28, 0, 0))

    btnMinimize.TextScaled = true
    btnClose.TextScaled = true

    -- Container principal horizontal (tabs esquerda + conteúdo direita)
    local contentHolder = Instance.new("Frame")
    contentHolder.Parent = container
    contentHolder.Position = UDim2.new(0, 0, 0, 28)
    contentHolder.Size = UDim2.new(1, 0, 1, -28)
    contentHolder.BackgroundTransparency = 1

    -- Coluna abas (esquerda)
    local tabsFrame = createRoundedFrame(contentHolder, UDim2.new(0, 120, 1, 0), UDim2.new(0,0,0,0), THEME.bgLight, false)
    tabsFrame.ClipsDescendants = true
    self.tabsFrame = tabsFrame

    -- ScrollView para abas (vertical)
    local tabsScroll = Instance.new("ScrollingFrame")
    tabsScroll.Parent = tabsFrame
    tabsScroll.Size = UDim2.new(1, 0, 1, 0)
    tabsScroll.Position = UDim2.new(0, 0, 0, 0)
    tabsScroll.BackgroundTransparency = 1
    tabsScroll.BorderSizePixel = 0
    tabsScroll.ScrollBarThickness = 6
    tabsScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    tabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabsUIList = Instance.new("UIListLayout")
    tabsUIList.Parent = tabsScroll
    tabsUIList.SortOrder = Enum.SortOrder.LayoutOrder
    tabsUIList.Padding = UDim.new(0, 4)

    self.tabsScroll = tabsScroll

    -- Área do conteúdo à direita
    local contentFrame = createRoundedFrame(contentHolder, UDim2.new(1, -120, 1, 0), UDim2.new(0, 120, 0, 0), THEME.bgLight, true)
    contentFrame.ClipsDescendants = true
    self.contentFrame = contentFrame

    -- ScrollView para conteúdo (vertical)
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Parent = contentFrame
    contentScroll.Size = UDim2.new(1, -12, 1, -12)
    contentScroll.Position = UDim2.new(0, 6, 0, 6)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 8
    contentScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local contentUIList = Instance.new("UIListLayout")
    contentUIList.Parent = contentScroll
    contentUIList.SortOrder = Enum.SortOrder.LayoutOrder
    contentUIList.Padding = UDim.new(0, 8)

    self.contentScroll = contentScroll
    self.contentUIList = contentUIList

    -- Estado das abas
    self.tabs = {}
    self.selectedTab = nil

    -- Função para trocar aba ativa
    function self:SelectTab(tabName)
        if self.selectedTab == tabName then return end
        self.selectedTab = tabName

        -- Atualiza visual das abas
        for name, tabData in pairs(self.tabs) do
            if name == tabName then
                tabData.button.BackgroundColor3 = THEME.accent
                tabData.button.TextColor3 = Color3.new(1,1,1)
                tabData.content.Visible = true
            else
                tabData.button.BackgroundColor3 = THEME.bgLight
                tabData.button.TextColor3 = THEME.text
                tabData.content.Visible = false
            end
        end
    end

    -- Função para adicionar aba
    function self:AddTab(tabName)
        if self.tabs[tabName] then
            warn("Tab "..tabName.." já existe.")
            return self.tabs[tabName].content
        end

        -- Botão da aba
        local tabBtn = createButton(self.tabsScroll, tabName, UDim2.new(1, 0, 0, 30))
        tabBtn.BackgroundColor3 = THEME.bgLight
        tabBtn.TextColor3 = THEME.text
        tabBtn.Font = Enum.Font.SourceSansSemibold
        tabBtn.TextSize = 15
        tabBtn.AutoButtonColor = false

        tabBtn.MouseEnter:Connect(function()
            if self.selectedTab ~= tabName then
                tabBtn.BackgroundColor3 = THEME.borderLight
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if self.selectedTab ~= tabName then
                tabBtn.BackgroundColor3 = THEME.bgLight
            end
        end)

        tabBtn.MouseButton1Click:Connect(function()
            self:SelectTab(tabName)
        end)

        -- Conteúdo da aba
        local content = Instance.new("Frame")
        content.Name = tabName.."_Content"
        content.Parent = self.contentScroll
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 0, 0) -- Height adaptado pelo UIListLayout
        content.Visible = false

        -- Layout do conteúdo (vertical)
        local uiList = Instance.new("UIListLayout")
        uiList.Parent = content
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Padding = UDim.new(0, 8)

        self.tabs[tabName] = {
            button = tabBtn,
            content = content,
            uiList = uiList,
        }

        -- Atualiza canvas size da tabsScroll para evitar cortes
        self.tabsScroll.CanvasSize = UDim2.new(0, 0, 0, tabsUIList.AbsoluteContentSize.Y)

        -- Se for a primeira aba, seleciona
        if not self.selectedTab then
            self:SelectTab(tabName)
        end

        return content
    end

    -- Função para fechar GUI
    function self:Close()
        self.screenGui:Destroy()
        self.screenGui = nil
        self.container = nil
        self.tabs = nil
        self.selectedTab = nil
    end

    -- Botão minimizar - recolhe/expande conteúdo
-- Botões no canto direito do header
local btnExpand = createButton(header, "□", UDim2.new(0, 24, 1, 0), UDim2.new(1, -84, 0, 0))
btnExpand.TextScaled = true
btnExpand.Visible = false

local btnMinimize = createButton(header, "–", UDim2.new(0, 24, 1, 0), UDim2.new(1, -56, 0, 0))
local btnClose = createButton(header, "×", UDim2.new(0, 24, 1, 0), UDim2.new(1, -28, 0, 0))
btnMinimize.TextScaled = true
btnClose.TextScaled = true

local expanded = true

btnMinimize.MouseButton1Click:Connect(function()
    if expanded then
        contentHolder.Visible = false
        container.Size = UDim2.new(0, 120, 0, 320)
        btnMinimize.Visible = false
        btnExpand.Visible = true
        expanded = false
    end
end)

btnExpand.MouseButton1Click:Connect(function()
    if not expanded then
        contentHolder.Visible = true
        container.Size = UDim2.new(0, 440, 0, 320)
        btnExpand.Visible = false
        btnMinimize.Visible = true
        expanded = true
    end
end)

    -- Botão fechar - destroi GUI e limpa referências
    btnClose.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Suporte para drag móvel e PC para mover a janela
    local dragging = false
    local dragInput, mousePos, framePos

    local function updateDrag(input)
        local delta = input.Position - mousePos
        container.Position = UDim2.new(
            0,
            math.clamp(framePos.X + delta.X, 10, workspace.CurrentCamera.ViewportSize.X - container.AbsoluteSize.X - 10),
            0,
            math.clamp(framePos.Y + delta.Y, 10, workspace.CurrentCamera.ViewportSize.Y - container.AbsoluteSize.Y - 10)
        )
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            updateDrag(input)
        end
    end)

    return self
end

-- Acesso público para criar novos componentes
GUI.CreateToggle = createToggle
GUI.CreateButtonOnOff = createButtonOnOff
GUI.CreateSlider = createSlider
GUI.CreateDropdown = createDropdown
GUI.CreateDropdownButtonOnOff = createDropdownButtonOnOff
GUI.CreateLabel = createLabelSimple

return GUI
