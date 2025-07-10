local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local DataStoreService = game:GetService("DataStoreService") -- For saving/loading configurations

-- 1. Refatoração do Tema: Mais opções e clareza
local themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        TabBackground = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(20, 20, 20),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        Warning = Color3.fromRGB(255, 60, 60),
    },
    ExtraDark = {
        Background = Color3.fromRGB(20, 20, 20),
        TabBackground = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(50, 50, 50),
        ScrollViewBackground = Color3.fromRGB(15, 15, 15),
        ButtonBackground = Color3.fromRGB(40, 40, 40),
        Warning = Color3.fromRGB(255, 50, 50),
    },
    White = {
        Background = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(30, 30, 30),
        Stroke = Color3.fromRGB(200, 200, 200),
        ScrollViewBackground = Color3.fromRGB(230, 230, 230),
        ButtonBackground = Color3.fromRGB(220, 220, 220),
        Warning = Color3.fromRGB(255, 60, 60),
    },
    DarkandWhite = {
        Background = Color3.fromRGB(30, 30, 30),
        TabBackground = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255), -- Text on dark background
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(230, 230, 230), -- White content area
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        Warning = Color3.fromRGB(255, 60, 60),
        -- Special text color for white areas if needed, handled by apply theme
        TextOnWhite = Color3.fromRGB(30, 30, 30),
    },
    PurpleandBlue = {
        Background = Color3.fromRGB(50, 30, 80),
        TabBackground = Color3.fromRGB(70, 40, 100),
        Accent = Color3.fromRGB(60, 140, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(90, 60, 130),
        ScrollViewBackground = Color3.fromRGB(40, 20, 70),
        ButtonBackground = Color3.fromRGB(80, 50, 110),
        Warning = Color3.fromRGB(255, 80, 80),
    },
}

local currentThemeName = "Dark"
local currentTheme = themes[currentThemeName]

-- Shared theme properties (not changed by theme preset)
local sharedThemeProps = {
    CornerRadius = UDim.new(0, 8),                  -- Raio de canto padrão para elementos maiores
    SmallCornerRadius = UDim.new(0, 6),             -- Raio de canto para elementos menores (botões)
    Padding = 8,                                    -- Preenchimento padrão para layouts
    TabButtonHeight = 34,                           -- Altura padrão para botões de aba
    ControlHeight = 32,                             -- Altura padrão para controles (botões, toggles)
    ControlPadding = 6,                             -- Espaçamento interno para controles
}

-- Merge shared properties into currentTheme
for k, v in pairs(sharedThemeProps) do
    currentTheme[k] = v
end

-- Collection of all UI elements that need theme updates
local uiElementsToUpdate = {}
local mainLabels = {} -- To store references to main labels for color changes
local allTextLabels = {} -- To store all text labels for font changes

-- Helper to apply corner radius
local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or currentTheme.CornerRadius
    UICorner.Parent = parent
    return UICorner
end

-- Helper to apply padding
local function createPadding(parent, allPadding)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, allPadding)
    UIPadding.PaddingRight = UDim.new(0, allPadding)
    UIPadding.PaddingTop = UDim.new(0, allPadding)
    UIPadding.PaddingBottom = UDim.new(0, allPadding)
    UIPadding.Parent = parent
    return UIPadding
end

-- Helper for creating TextLabels
local function createTextLabel(parent, text, textSize, textColor, font, alignment, isMainLabel)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize or 16
    label.TextColor3 = textColor or currentTheme.Text
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    table.insert(allTextLabels, label) -- Add to font update list
    if isMainLabel then
        table.insert(mainLabels, label) -- Add to main label list for color changes
    end
    return label
end

-- Helper for creating TextButtons
local function createTextButton(parent, text, callback, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
    button.BackgroundColor3 = bgColor or currentTheme.ButtonBackground
    button.Text = text
    button.TextColor3 = textColor or currentTheme.Text
    button.Font = font or Enum.Font.GothamMedium
    button.TextSize = textSize or 16
    button.AutoButtonColor = false
    button.Parent = parent

    createCorner(button, currentTheme.SmallCornerRadius)

    -- Efeitos de hover padrão
    local defaultBg = bgColor or currentTheme.ButtonBackground
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = defaultBg }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- Function to apply the current theme to all registered UI elements
local function applyTheme(themeColors)
    currentTheme = {}
    for k, v in pairs(themeColors) do
        currentTheme[k] = v
    end
    for k, v in pairs(sharedThemeProps) do
        currentTheme[k] = v
    end

    for _, element in ipairs(uiElementsToUpdate) do
        if element.Name == "MainFrame" then
            element.BackgroundColor3 = currentTheme.Background
            element.UIStroke.Color = currentTheme.Stroke
        elseif element.Name == "HeaderFrame" then
            element.BackgroundColor3 = currentTheme.TabBackground
        elseif element.Name == "TitleLabel" then
            element.TextColor3 = currentTheme.Text
        elseif element.Name == "MinimizeButton" then
            element.BackgroundColor3 = currentTheme.TabBackground
            element.TextColor3 = currentTheme.Text
            -- Update hover colors explicitly for minimize button
            element.MouseEnter:Connect(function()
                TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Warning }):Play()
            end)
            element.MouseLeave:Connect(function()
                TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.TabBackground }):Play()
            end)
        elseif element.Name == "TabContainer" then
            element.BackgroundColor3 = currentTheme.TabBackground
        elseif element.Name == "PageContainer" then
            element.BackgroundColor3 = currentTheme.ScrollViewBackground
        elseif element.Name == "TabButton" then
            element.BackgroundColor3 = currentTheme.ButtonBackground
            element.TextColor3 = currentTheme.Text
            -- Re-apply hover logic for tab buttons
            local defaultBg = currentTheme.ButtonBackground
            local accent = currentTheme.Accent
            element.MouseEnter:Connect(function()
                if element ~= element._activeTabButton then
                    TweenService:Create(element, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }):Play()
                end
            end)
            element.MouseLeave:Connect(function()
                if element ~= element._activeTabButton then
                    TweenService:Create(element, TweenInfo.new(0.2), { BackgroundColor3 = defaultBg }):Play()
                end
            end)
            -- If it's the active button, set its color
            if element == element._activeTabButton then
                element.BackgroundColor3 = currentTheme.Accent
            end
            if element.IconLabel then
                element.IconLabel.TextColor3 = currentTheme.Accent
            end
        elseif element.Name == "PageFrame" then
            element.BackgroundColor3 = currentTheme.ScrollViewBackground
        elseif element.Name == "Label" then
            element.TextColor3 = currentTheme.Text
            if element.Parent.Name == "SliderFrame" then -- For slider labels
                element.TextColor3 = currentTheme.Text
            end
        elseif element.Name == "Button" or element.Name == "Toggle" or element.Name == "DropdownContainer" then
            -- For generic buttons, toggles, dropdown headers created by add functions
            if element.BackgroundColor3 ~= currentTheme.Accent then -- Don't change accent-colored toggles/buttons
                element.BackgroundColor3 = currentTheme.ButtonBackground
            end
            element.TextColor3 = currentTheme.Text
            local defaultBg = currentTheme.ButtonBackground
            local accent = currentTheme.Accent
            element.MouseEnter:Connect(function()
                if element.Name == "Toggle" and element.IsOn then
                    TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = accent }):Play()
                else
                    TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = accent }):Play()
                end
            end)
            element.MouseLeave:Connect(function()
                if element.Name == "Toggle" and element.IsOn then
                    TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = accent }):Play()
                else
                    TweenService:Create(element, TweenInfo.new(0.15), { BackgroundColor3 = defaultBg }):Play()
                end
            end)
        elseif element.Name == "DropdownFrame" then
            element.BackgroundColor3 = currentTheme.TabBackground
        elseif element.Name == "SliderFill" then
            element.BackgroundColor3 = currentTheme.Accent
        elseif element.Name == "SliderBar" then
            element.BackgroundColor3 = currentTheme.ButtonBackground
        end
    end

    -- Special handling for DarkandWhite theme for text on white backgrounds
    if themeColors == themes.DarkandWhite then
        for _, element in ipairs(uiElementsToUpdate) do
            if element.Name == "PageFrame" then
                for _, child in ipairs(element:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child.TextColor3 = currentTheme.TextOnWhite
                    elseif child:IsA("Frame") and (child.Name == "DropdownContainer" or child.Name == "SliderFrame") then
                        for _, grandChild in ipairs(child:GetChildren()) do
                            if grandChild:IsA("TextLabel") then
                                grandChild.TextColor3 = currentTheme.TextOnWhite
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Function to update main label colors
local function updateMainLabelColors(color)
    for _, label in ipairs(mainLabels) do
        label.TextColor3 = color
    end
end

-- Function to update font for all text labels
local function updateFont(fontEnum)
    for _, label in ipairs(allTextLabels) do
        label.Font = fontEnum
    end
end

-- Function to update the opacity of the main menu frame
local function updateMenuOpacity(opacity)
    local mainFrame = uiElementsToUpdate.MainFrame
    if mainFrame then
        local targetTransparency = 1 - opacity
        TweenService:Create(mainFrame, TweenInfo.new(0.2), { BackgroundTransparency = targetTransparency }):Play()

        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.2), { BackgroundTransparency = targetTransparency, TextTransparency = targetTransparency }):Play()
                for _, grandChild in ipairs(child:GetChildren()) do
                    if grandChild:IsA("Frame") or grandChild:IsA("TextButton") or grandChild:IsA("TextLabel") then
                         TweenService:Create(grandChild, TweenInfo.new(0.2), { BackgroundTransparency = targetTransparency, TextTransparency = targetTransparency }):Play()
                         for _, greatGrandChild in ipairs(grandChild:GetChildren()) do
                            if greatGrandChild:IsA("Frame") or greatGrandChild:IsA("TextButton") or greatGrandChild:IsA("TextLabel") then
                                 TweenService:Create(greatGrandChild, TweenInfo.new(0.2), { BackgroundTransparency = targetTransparency, TextTransparency = targetTransparency }):Play()
                            end
                         end
                    end
                end
            end
        end
    end
end


function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = currentTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true -- Essencial para arrastar
    MainFrame.Draggable = false -- Desativa o Draggable nativo do Roblox para implementar o personalizado
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    uiElementsToUpdate.MainFrame = MainFrame

    -- 2. Lógica de arrastar o MainFrame melhorada (movido para o cabeçalho)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    -- Frame para a barra superior (onde o título e botão de minimizar ficam)
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = currentTheme.TabBackground
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Active = true -- Para arrastar pela barra superior
    uiElementsToUpdate.HeaderFrame = HeaderFrame

    createCorner(HeaderFrame, currentTheme.CornerRadius) -- Aplicar canto ao header também (top-left, top-right)

    HeaderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = MainFrame.Position
            input.Handled = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    createCorner(MainFrame, currentTheme.CornerRadius)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = currentTheme.Stroke
    UIStroke.Thickness = 1
    uiElementsToUpdate.MainFrame.UIStroke = UIStroke -- Store reference for theme updates

    -- Título dentro do HeaderFrame
    local Title = createTextLabel(HeaderFrame, name or "Menu", 20, currentTheme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left, true)
    Title.Name = "TitleLabel"
    Title.Size = UDim2.new(1, -50, 1, 0) -- Menor para botão minimizar
    Title.Position = UDim2.new(0, currentTheme.Padding, 0, 0) -- Adiciona padding
    Title.TextYAlignment = Enum.TextYAlignment.Center
    uiElementsToUpdate.TitleLabel = Title

    -- Botão minimizar
    local BtnMinimize = createTextButton(HeaderFrame, "–", nil, currentTheme.TabBackground, currentTheme.Text, Enum.Font.GothamBold, 24)
    BtnMinimize.Name = "MinimizeButton"
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -currentTheme.Padding - 30, 0, (HeaderFrame.Size.Y.Offset - 30) / 2) -- Centraliza verticalmente
    createCorner(BtnMinimize, currentTheme.SmallCornerRadius) -- Usa small corner radius
    uiElementsToUpdate.MinimizeButton = BtnMinimize

    -- Ajustar hover do botão minimizar para ser mais discreto ou usar Warning color
    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Warning }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.TabBackground }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Name = "TabContainer"
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40) -- Tab container agora começa abaixo do header
    TabContainer.BackgroundColor3 = currentTheme.TabBackground
    TabContainer.ClipsDescendants = true -- Para que o canto arredondado funcione no fundo
    uiElementsToUpdate.TabContainer = TabContainer

    local TabCorner = createCorner(TabContainer, currentTheme.CornerRadius) -- Arredondar canto inferior esquerdo
    -- UIListLayout para as abas
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, currentTheme.Padding) -- Padding consistente
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    createPadding(TabContainer, currentTheme.Padding / 2) -- Adiciona padding interno ao TabContainer

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Name = "PageContainer"
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = currentTheme.ScrollViewBackground -- Fundo da área de conteúdo
    PageContainer.ClipsDescendants = true
    uiElementsToUpdate.PageContainer = PageContainer

    createCorner(PageContainer, currentTheme.CornerRadius) -- Arredondar canto inferior direito


    local pages = {}
    local firstTabName = nil
    local activeTabButton = nil -- Para controlar o estado visual da aba ativa

    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play() -- Aumentei um pouco a largura minimizada
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
        end
    end)

    local function switchToPage(name, button)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end

        if activeTabButton then
            TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
            activeTabButton._activeTabButton = nil -- Clear reference
        end
        activeTabButton = button
        activeTabButton._activeTabButton = activeTabButton -- Self reference for theme update
        TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
    end

    local window = {}

    -- Redimensionar menu (borda direita-inferior)
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true
        resizeFrame.Name = "ResizeHandle" -- Nome para facilitar a depuração

        local mouseDown = false
        local initialMousePos = Vector2.new()
        local initialFrameSize = UDim2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDown = true
                initialMousePos = UserInputService:GetMouseLocation()
                initialFrameSize = MainFrame.Size
                input.Handled = true
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDown and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = UserInputService:GetMouseLocation() - initialMousePos

                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 900)
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 600)

                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDown = false
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        if firstTabName == nil then
            firstTabName = tabName
        end

        local Button = createTextButton(TabContainer, "  " .. tabName, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
        Button.Name = "TabButton"
        Button.Size = UDim2.new(1, -currentTheme.Padding, 0, currentTheme.TabButtonHeight)
        Button.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(uiElementsToUpdate, Button) -- Add to theme update list

        if icon then
            local iconLabel = createTextLabel(Button, icon, 18, currentTheme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center, false)
            iconLabel.Name = "IconLabel"
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, currentTheme.ControlPadding, 0, 0) -- Ícone mais para a esquerda
            Button.IconLabel = iconLabel -- Store reference for theme updates
        end

        -- Ajustar hover dos botões de aba para serem um pouco diferentes ou ter um indicador
        Button.MouseEnter:Connect(function()
            if Button ~= activeTabButton then -- Só faz hover se não for o botão ativo
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if Button ~= activeTabButton then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = "PageFrame"
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 6 -- Scrollbar um pouco mais espessa
        Page.BackgroundColor3 = currentTheme.ScrollViewBackground
        Page.BorderSizePixel = 0
        Page.Active = true -- Para permitir rolagem em si
        table.insert(uiElementsToUpdate, Page) -- Add to theme update list

        createCorner(Page, currentTheme.CornerRadius) -- Cantos arredondados

        local PageListLayout = Instance.new("UIListLayout", Page)
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, currentTheme.Padding) -- Padding consistente
        PageListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Centraliza os controles na página

        createPadding(Page, currentTheme.Padding) -- Padding interno para a página

        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + currentTheme.Padding * 2) -- Adiciona padding no final
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text, isMain)
            local Label = createTextLabel(Page, text, 16, currentTheme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, isMain)
            Label.Name = "Label"
            Label.Size = UDim2.new(1, 0, 0, 24) -- Ajusta tamanho
            table.insert(uiElementsToUpdate, Label) -- Add to theme update list
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, currentTheme.Accent, Color3.new(1,1,1), Enum.Font.GothamMedium, 16)
            Btn.Name = "Button"
            table.insert(uiElementsToUpdate, Btn) -- Add to theme update list
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = createTextButton(Page, text, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            ToggleBtn.Name = "Toggle"
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            ToggleBtn.TextScaled = false -- Desativar TextScaled para controlar o tamanho do texto
            table.insert(uiElementsToUpdate, ToggleBtn) -- Add to theme update list

            local state = false
            ToggleBtn.IsOn = state -- Store state for theme update
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
                ToggleBtn.IsOn = state
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
                end
            })

            -- Ajustar hover do toggle
            ToggleBtn.MouseEnter:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or Color3.fromRGB(60,60,60) }):Play()
            end)
            ToggleBtn.MouseLeave:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
            end)

            return {
                Set = function(self, value)
                    state = value
                    updateToggleVisual()
                end,
                Get = function(self)
                    return state
                end,
                _instance = ToggleBtn
            }
        end

        function tab:AddDropdownButtonOnOff(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Name = "DropdownContainer"
            container.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
            container.BackgroundColor3 = currentTheme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, container)

            local header = createTextButton(container, "▸ " .. title, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            header.Name = "DropdownHeader"
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1 -- Não queremos hover color no header, o container muda

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (currentTheme.ControlHeight + currentTheme.ControlPadding))
            dropdownFrame.BackgroundColor3 = currentTheme.TabBackground -- Fundo do dropdown
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, dropdownFrame)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, currentTheme.ControlPadding)
            createPadding(dropdownFrame, currentTheme.ControlPadding / 2) -- Padding interno para os itens do dropdown

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false

                local btn = createTextButton(dropdownFrame, name .. ": OFF", nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 14)
                btn.Name = "DropdownItemButton"
                btn.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(uiElementsToUpdate, btn)

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
                end
                updateBtnVisual()
                itemButtons[name] = btn

                btn.MouseButton1Click:Connect(function()
                    states[name] = not states[name]
                    updateBtnVisual()
                    if callback then
                        callback(states)
                    end
                end)

                 -- Ajustar hover para itens do dropdown
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or Color3.fromRGB(60,60,60) }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and currentTheme.Accent or currentTheme.ButtonBackground }):Play()
                end)
            end

            local expanded = false

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title
            end)

            return {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            -- Atualiza visualmente o botão específico
                            itemButtons[item].BackgroundColor3 = value and currentTheme.Accent or currentTheme.ButtonBackground
                            itemButtons[item].Text = item .. ": " .. (value and "ON" or "OFF")
                        end
                        if callback then
                            callback(states)
                        end
                    end
                end,
                GetAll = function()
                    return states
                end
            }
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Name = "DropdownContainer"
            container.Size = UDim2.new(1, 0, 0, currentTheme.ControlHeight)
            container.BackgroundColor3 = currentTheme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, container)

            local header = createTextButton(container, "▸ " .. title, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 16)
            header.Name = "DropdownHeader"
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1
            header._defaultBg = currentTheme.ButtonBackground -- Store for hover

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Name = "DropdownFrame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (currentTheme.ControlHeight + currentTheme.ControlPadding))
            dropdownFrame.BackgroundColor3 = currentTheme.TabBackground
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, dropdownFrame)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, currentTheme.ControlPadding)
            createPadding(dropdownFrame, currentTheme.ControlPadding / 2)

            local selectedItem = nil
            local expanded = false

            local function updateHeaderText()
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end
            updateHeaderText() -- Initial text set

            for _, name in ipairs(items) do
                local btn = createTextButton(dropdownFrame, name, nil, currentTheme.ButtonBackground, currentTheme.Text, Enum.Font.Gotham, 14)
                btn.Name = "DropdownItemButton"
                btn.TextXAlignment = Enum.TextXAlignment.Left
                table.insert(uiElementsToUpdate, btn)

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                end)

                 -- Ajustar hover para itens do dropdown
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = currentTheme.ButtonBackground }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                updateHeaderText()
            end)

            return {
                Set = function(_, item)
                    if table.find(items, item) then
                        selectedItem = item
                        updateHeaderText()
                        if callback then
                            callback(selectedItem)
                        end
                    end
                end,
                Get = function()
                    return selectedItem
                end
            }
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Name = "SliderFrame"
            SliderFrame.Size = UDim2.new(1, 0, 0, 40)
            SliderFrame.BackgroundTransparency = 1
            table.insert(uiElementsToUpdate, SliderFrame)

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), 14, currentTheme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left, false)
            Label.Name = "Label"
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            table.insert(uiElementsToUpdate, Label)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Name = "SliderBar"
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
            SliderBar.BackgroundColor3 = currentTheme.ButtonBackground
            SliderBar.BorderSizePixel = 0
            createCorner(SliderBar, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, SliderBar)

            local SliderFill = Instance.new("Frame", SliderBar)
            SliderFill.Name = "SliderFill"
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = currentTheme.Accent
            SliderFill.BorderSizePixel = 0
            createCorner(SliderFill, currentTheme.SmallCornerRadius)
            table.insert(uiElementsToUpdate, SliderFill)

            local draggingSlider = false
            local currentValue = default

            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
                currentValue = value
                if callback then
                    callback(value)
                end
                return value
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSliderValue(input)
                    input.Handled = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderValue(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            return {
                Set = function(self, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    currentValue = value
                    if callback then
                        callback(value)
                    end
                end,
                Get = function(self)
                    return currentValue
                end,
                _instance = SliderFrame
            }
        end

        return tab

    end

    -- Initial setup of theme
    applyTheme(themes[currentThemeName])

    -- --- Settings Tab ---
    local settingsTab = window:CreateTab("Settings", "⚙") -- Cog icon for settings

    local availableThemes = {}
    for themeName, _ in pairs(themes) do
        table.insert(availableThemes, themeName)
    end
    local themeDropdown = settingsTab:AddSelectDropdown("Theme", availableThemes, function(selectedTheme)
        currentThemeName = selectedTheme
        applyTheme(themes[selectedTheme])
    end)
    themeDropdown:Set(currentThemeName) -- Set initial selection

    settingsTab:AddLabel("--- Main Label Color ---", true) -- Added separator label
    local labelColorR = settingsTab:AddSlider("Red", 0, 255, 255, function(value)
        local currentColor = mainLabels[1] and mainLabels[1].TextColor3 or Color3.fromRGB(255,255,255)
        updateMainLabelColors(Color3.fromRGB(value, currentColor.G * 255, currentColor.B * 255))
    end)
    local labelColorG = settingsTab:AddSlider("Green", 0, 255, 255, function(value)
        local currentColor = mainLabels[1] and mainLabels[1].TextColor3 or Color3.fromRGB(255,255,255)
        updateMainLabelColors(Color3.fromRGB(currentColor.R * 255, value, currentColor.B * 255))
    end)
    local labelColorB = settingsTab:AddSlider("Blue", 0, 255, 255, function(value)
        local currentColor = mainLabels[1] and mainLabels[1].TextColor3 or Color3.fromRGB(255,255,255)
        updateMainLabelColors(Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, value))
    end)

    settingsTab:AddLabel("--- Font Style ---", true)
    local availableFonts = {}
    for i, font in ipairs(Enum.Font:GetEnumItems()) do
        table.insert(availableFonts, font.Name)
    end
    local fontDropdown = settingsTab:AddSelectDropdown("Font Style", availableFonts, function(selectedFontName)
        updateFont(Enum.Font[selectedFontName])
    end)
    fontDropdown:Set("Gotham") -- Set initial default font

    settingsTab:AddLabel("--- Menu Opacity ---", true)
    local opacitySlider = settingsTab:AddSlider("Opacity", 0, 100, 100, function(value)
        updateMenuOpacity(value / 100) -- Convert to 0-1 scale
    end)

    settingsTab:AddLabel("--- Configurations ---", true)

    local configurationsDataStore = DataStoreService:GetDataStore("MenuConfigurations")
    local savedConfigs = {}
    local configDropdown = nil
    local selectedConfigName = nil

    local function loadSavedConfigurations()
        local success, data = pcall(function()
            return configurationsDataStore:GetAsync("UserConfigs")
        end)

        if success and data then
            savedConfigs = data
        else
            savedConfigs = {}
        end

        local configNames = {"None"} -- Add a default "None" option
        for name, _ in pairs(savedConfigs) do
            table.insert(configNames, name)
        end
        -- Re-create dropdown if it already exists to update items
        if configDropdown then
            configDropdown._instance.Parent:Destroy() -- Destroy the old container
        end
        configDropdown = settingsTab:AddSelectDropdown("Load Configuration", configNames, function(name)
            selectedConfigName = name
            if name ~= "None" then
                local config = savedConfigs[name]
                if config then
                    -- Apply saved settings
                    themeDropdown:Set(config.Theme)
                    labelColorR:Set(config.LabelColor.R * 255)
                    labelColorG:Set(config.LabelColor.G * 255)
                    labelColorB:Set(config.LabelColor.B * 255)
                    fontDropdown:Set(config.Font)
                    opacitySlider:Set(config.Opacity * 100)
                end
            end
        end)
        configDropdown:Set("None")
    end

    local function saveCurrentConfiguration(name)
        local currentConfig = {
            Theme = currentThemeName,
            LabelColor = mainLabels[1] and mainLabels[1].TextColor3 or Color3.fromRGB(255,255,255),
            Font = allTextLabels[1] and allTextLabels[1].Font.Name or Enum.Font.Gotham.Name,
            Opacity = 1 - MainFrame.BackgroundTransparency,
            -- Add other settings you want to save
        }
        savedConfigs[name] = currentConfig

        local success, err = pcall(function()
            configurationsDataStore:SetAsync("UserConfigs", savedConfigs)
        end)

        if success then
            warn("Configuration '" .. name .. "' saved successfully!")
            loadSavedConfigurations() -- Reload dropdown to show new config
        else
            warn("Failed to save configuration: " .. err)
        end
    end

    local saveButton = settingsTab:AddButton("Save Current Settings", function()
        local name = game:GetService("UserInputService"):GetClipboard()
        if not name or name == "" then
            name = "MyConfig_" .. os.time()
        end
        saveCurrentConfiguration(name)
    end)

    local loadButton = settingsTab:AddButton("Load Selected Configuration", function()
        if selectedConfigName and selectedConfigName ~= "None" then
            local config = savedConfigs[selectedConfigName]
            if config then
                themeDropdown:Set(config.Theme)
                labelColorR:Set(config.LabelColor.R * 255)
                labelColorG:Set(config.LabelColor.G * 255)
                labelColorB:Set(config.LabelColor.B * 255)
                fontDropdown:Set(config.Font)
                opacitySlider:Set(config.Opacity * 100)
            end
        else
            warn("No configuration selected to load.")
        end
    end)


    -- Load configurations when the menu is created
    loadSavedConfigurations()


    -- Inicializa na primeira aba se existir
    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            -- Encontra o botão da primeira aba para ativá-lo visualmente
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and string.find(btn.Text, firstTabName) then
                    switchToPage(firstTabName, btn)
                    break
                end
            end
        end
    end)()

    return window
end

return Library
