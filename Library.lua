--[[
  Biblioteca de Menu Customizável com Suporte a Configurações:
  - Permite definir cor, opacidade, salvar/carregar configurações locais (LocalPlayer).
  - Compatível com uso via loadstring (ex: executores Delta, etc).
  - Inclui controles para cor e opacidade do menu.
  - Exemplo de uso para integração com botões de "Salvar" e "Carregar" configs.
--]]

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Nome do arquivo de configuração
local CONFIG_FILENAME = "custom_menu_config.json"

-- Utilitários para leitura e escrita de arquivos
local function writeConfigFile(filename, content)
    local success, err = pcall(function()
        if typeof(writefile) == "function" then
            writefile(filename, content)
            return true
        elseif typeof(savefile) == "function" then
            savefile(filename, content)
            return true
        else
            error("Nenhuma função de escrita de arquivo (writefile/savefile) encontrada.")
        end
    end)
    if not success then
        warn("Erro ao escrever arquivo de configuração:", err)
    end
    return success
end

local function readConfigFile(filename)
    local content = nil
    local success, err = pcall(function()
        if typeof(readfile) == "function" then
            content = readfile(filename)
        elseif typeof(loadfile) == "function" then
            local res = loadfile(filename)
            if typeof(res) == "string" then content = res end
        else
            error("Nenhuma função de leitura de arquivo (readfile/loadfile) encontrada.")
        end
    end)
    if not success then
        warn("Erro ao ler arquivo de configuração:", err)
        return nil
    end
    return content
end

-- Paleta de cores: Tons modernos, contraste e acessibilidade
local palette = {
    Dark = Color3.fromRGB(27, 29, 35),
    MediumDark = Color3.fromRGB(36, 38, 49),
    Accent = Color3.fromRGB(0, 170, 255),
    Accent2 = Color3.fromRGB(0, 200, 130),
    Accent3 = Color3.fromRGB(255, 92, 92),
    Light = Color3.fromRGB(235, 235, 245),
    Text = Color3.fromRGB(235, 235, 245),
    Warning = Color3.fromRGB(255, 80, 80),
    Orange = Color3.fromRGB(255, 157, 77),
    Purple = Color3.fromRGB(112, 70, 255),
    Green = Color3.fromRGB(60, 210, 100),
    Yellow = Color3.fromRGB(255, 220, 50),
}

-- Tema usando a paleta acima
local theme = {
    Background = palette.Dark,
    TabBackground = palette.MediumDark,
    Accent = palette.Accent,
    Text = palette.Text,
    Stroke = palette.Accent,
    ScrollViewBackground = palette.MediumDark,
    ButtonBackground = palette.Dark,
    Warning = palette.Warning,
    CornerRadius = UDim.new(0, 8),
    SmallCornerRadius = UDim.new(0, 6),
    Padding = 8,
    TabButtonHeight = 34,
    ControlHeight = 32,
    ControlPadding = 6,
    Opacity = 0.96,
    Font = Enum.Font.Gotham,
    FontSize = 16,
    HeaderFontSize = 22,
}

local themeConfigKeys = {"Background", "TabBackground", "Accent", "Text", "Stroke", "ScrollViewBackground", "ButtonBackground", "Warning", "Opacity"}

-- Função para aplicar opacidade a todos os descendentes do frame principal
local function setMenuOpacity(mainFrame, opacityValue)
    local function applyTransparency(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("ScrollingFrame") then
            obj.BackgroundTransparency = 1 - opacityValue
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextTransparency = 1 - opacityValue
        end
        for _, child in ipairs(obj:GetChildren()) do
            applyTransparency(child)
        end
    end
    applyTransparency(mainFrame)
end

local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or theme.CornerRadius
    UICorner.Parent = parent
    return UICorner
end

local function createTextLabel(parent, text, textSize, textColor, font, alignment)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize or theme.FontSize
    label.TextColor3 = textColor or theme.Text
    label.Font = font or theme.Font
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function createTextButton(parent, text, callback, bgColor, textColor, font, textSize)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
    button.BackgroundColor3 = bgColor or theme.ButtonBackground
    button.Text = text
    button.TextColor3 = textColor or theme.Text
    button.Font = font or theme.Font
    button.TextSize = textSize or theme.FontSize
    button.AutoButtonColor = false
    button.Parent = parent

    createCorner(button, theme.SmallCornerRadius)

    local defaultBgColor = bgColor or theme.ButtonBackground
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = defaultBgColor }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

-- Corrigido: controles de cor e dropdown melhores
local function createCustomizationTab(windowInstance, mainFrame, applyThemeCallback)
    local tab = windowInstance:CreateTab("Configurações", "⚙️")

    tab:AddLabel("Cor de Fundo do Menu")
    tab:AddSelectDropdown("Cor de Fundo", {
        "Dark", "Accent2", "Accent3", "Orange", "Purple", "Green"
    }, function(opt)
        local colors = {
            ["Dark"] = palette.Dark,
            ["Accent2"] = palette.Accent2,
            ["Accent3"] = palette.Accent3,
            ["Orange"] = palette.Orange,
            ["Purple"] = palette.Purple,
            ["Green"] = palette.Green,
        }
        theme.Background = colors[opt] or palette.Dark
        if applyThemeCallback then applyThemeCallback() end
    end)

    tab:AddLabel("Cor de Destaque (Accent)")
    tab:AddSelectDropdown("Cor de Destaque", {
        "Padrão", "Accent2", "Accent3", "Orange", "Purple", "Green", "Yellow"
    }, function(opt)
        local colors = {
            ["Padrão"] = palette.Accent,
            ["Accent2"] = palette.Accent2,
            ["Accent3"] = palette.Accent3,
            ["Orange"] = palette.Orange,
            ["Purple"] = palette.Purple,
            ["Green"] = palette.Green,
            ["Yellow"] = palette.Yellow,
        }
        theme.Accent = colors[opt] or palette.Accent
        if applyThemeCallback then applyThemeCallback() end
    end)

    tab:AddLabel("Opacidade Global do Menu")
    tab:AddSlider("Opacidade", 30, 100, math.floor(theme.Opacity * 100), function(val)
        theme.Opacity = val / 100
        setMenuOpacity(mainFrame, theme.Opacity)
    end)

    tab:AddButton("Salvar Configuração", function()
        local config = {}
        for _, k in ipairs(themeConfigKeys) do
            local v = theme[k]
            if typeof(v) == "Color3" then
                config[k] = {v.R, v.G, v.B}
            else
                config[k] = v
            end
        end
        local success = writeConfigFile(CONFIG_FILENAME, HttpService:JSONEncode(config))
        if success then
            print("Configuração salva com sucesso em:", CONFIG_FILENAME)
        else
            warn("Falha ao salvar configuração.")
        end
    end)

    tab:AddButton("Carregar Configuração", function()
        local data = readConfigFile(CONFIG_FILENAME)
        if data then
            local ok, config = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and typeof(config) == "table" then
                for _, k in ipairs(themeConfigKeys) do
                    if config[k] ~= nil then
                        if typeof(theme[k]) == "Color3" and typeof(config[k]) == "table" and #config[k] == 3 then
                            theme[k] = Color3.new(unpack(config[k]))
                        elseif k == "Opacity" then
                            theme[k] = tonumber(config[k]) or theme[k]
                        end
                    end
                end
                if applyThemeCallback then applyThemeCallback() end
                setMenuOpacity(mainFrame, theme.Opacity)
                print("Configuração carregada com sucesso.")
            else
                warn("Erro ao decodificar JSON da configuração ou formato inválido.")
            end
        else
            warn("Nenhuma configuração encontrada para carregar ou erro na leitura.")
        end
    end)
end

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    createCorner(MainFrame, theme.CornerRadius)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1

    local Title = createTextLabel(MainFrame, name or "Menu", theme.HeaderFontSize, theme.Text, theme.Font, Enum.TextXAlignment.Left)
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.ZIndex = 2

    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -40, 0, 5)
    BtnMinimize.BackgroundColor3 = theme.TabBackground
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false
    BtnMinimize.ZIndex = 2
    createCorner(BtnMinimize, UDim.new(0, 6))

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
    end)

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.BackgroundColor3 = theme.TabBackground
    createCorner(TabContainer, UDim.new(0, 6))

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.FillDirection = Enum.FillDirection.Vertical
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pages = {}
    local tabButtons = {}
    local firstTabName = nil
    local currentActiveTabButton = nil
    local minimized = false
    local dragConnections = {}

    local function connectDragEvents()
        dragConnections.InputBegan = MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.Position.Y <= (MainFrame.AbsolutePosition.Y + 40) then
                    local dragStart = UserInputService:GetMouseLocation()
                    local startPos = MainFrame.Position
                    local dragInputChangedConn
                    dragInputChangedConn = UserInputService.InputChanged:Connect(function(changedInput)
                        if (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                            local delta = UserInputService:GetMouseLocation() - dragStart
                            MainFrame.Position = UDim2.new(
                                startPos.X.Scale, startPos.X.Offset + delta.X,
                                startPos.Y.Scale, startPos.Y.Offset + delta.Y
                            )
                        end
                    end)
                    local dragInputEndedConn
                    dragInputEndedConn = UserInputService.InputEnded:Connect(function(endedInput)
                        if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                            dragInputChangedConn:Disconnect()
                            dragInputEndedConn:Disconnect()
                        end
                    end)
                    input.Handled = true
                end
            end
        end)
    end

    local function disconnectDragEvents()
        if dragConnections.InputBegan then
            dragConnections.InputBegan:Disconnect()
            dragConnections.InputBegan = nil
        end
    end

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.TextXAlignment = Enum.TextXAlignment.Center
            disconnectDragEvents()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.TextXAlignment = Enum.TextXAlignment.Left
            connectDragEvents()
            setMenuOpacity(MainFrame, theme.Opacity)
        end
    end)

    local function switchToPage(name, button)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
            if pgName == name then
                setMenuOpacity(pg, theme.Opacity)
            end
        end

        -- Atualiza o visual dos botões de abas
        for tabName, btn in pairs(tabButtons) do
            if btn == button then
                TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
            else
                TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabBackground }):Play()
            end
        end
        currentActiveTabButton = button
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
        resizeFrame.Draggable = false

        local mouseDownResize = false
        local initialMousePos = Vector2.new()
        local initialFrameSize = UDim2.new()

        resizeFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = true
                initialMousePos = UserInputService:GetMouseLocation()
                initialFrameSize = MainFrame.Size
                input.Handled = true
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if mouseDownResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = UserInputService:GetMouseLocation() - initialMousePos
                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 900)
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 600)
                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseDownResize = false
            end
        end)
    end

    function window:CreateTab(tabName, icon)
        if firstTabName == nil then
            firstTabName = tabName
        end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -12, 0, theme.TabButtonHeight)
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = theme.TabBackground
        Button.TextColor3 = theme.Text
        Button.Font = theme.Font
        Button.TextSize = theme.FontSize
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        createCorner(Button, UDim.new(0, 6))

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 6, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 18
            iconLabel.TextColor3 = theme.Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center

            Button.Text = "  " .. tabName
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            if currentActiveTabButton ~= Button then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent * 0.8 }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if currentActiveTabButton ~= Button then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.TabBackground }):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 8
        Page.ScrollBarImageColor3 = theme.Accent
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0

        createCorner(Page, theme.CornerRadius)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, theme.Padding)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.FillDirection = Enum.FillDirection.Vertical

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + theme.Padding * 2)
        end)

        pages[tabName] = Page
        tabButtons[tabName] = Button

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text, horizontalAlignment)
            local Label = createTextLabel(Page, text, theme.FontSize, theme.Text, theme.Font, horizontalAlignment or Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, -theme.Padding * 2, 0, 24)
            Label.Position = UDim2.new(0, theme.Padding, 0, 0)
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.ButtonBackground, theme.Text)
            Btn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            Btn.Position = UDim2.new(0, theme.Padding, 0, 0)
            return Btn
        end

        function tab:AddToggle(text, initialValue, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            ToggleBtn.Position = UDim2.new(0, theme.Padding, 0, 0)
            ToggleBtn.BackgroundColor3 = theme.TabBackground
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = theme.Font
            ToggleBtn.TextSize = theme.FontSize
            ToggleBtn.AutoButtonColor = false

            createCorner(ToggleBtn, theme.SmallCornerRadius)

            local state = initialValue or false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.TabBackground }):Play()
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
                end
            end)

            ToggleBtn.MouseEnter:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent * 0.8 }):Play()
                end
            end)
            ToggleBtn.MouseLeave:Connect(function()
                if not state then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
                end
            end)

            return {
                Set = function(_, value)
                    state = value
                    updateToggleVisual()
                end,
                Get = function()
                    return state
                end,
                _instance = ToggleBtn
            }
        end

        -- Corrigido: Dropdown de seleção singular
        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -theme.Padding * 2, 0, theme.ControlHeight)
            container.Position = UDim2.new(0, theme.Padding, 0, 0)
            container.BackgroundColor3 = theme.TabBackground
            container.BorderSizePixel = 0
            container.ClipsDescendants = true
            createCorner(container, theme.SmallCornerRadius)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = theme.FontSize
            header.Font = theme.Font
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.TextYAlignment = Enum.TextYAlignment.Center
            header.AutoButtonColor = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 0)
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 3
            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding / 2)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.FillDirection = Enum.FillDirection.Vertical

            local selectedItem = nil
            local expanded = false

            local function updateHeaderText()
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end

            for _, name in ipairs(items) do
                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -theme.ControlPadding, 0, theme.ControlHeight)
                btn.Position = UDim2.new(0, theme.ControlPadding / 2, 0, 0)
                btn.BackgroundColor3 = theme.TabBackground
                btn.TextColor3 = theme.Text
                btn.Font = theme.Font
                btn.TextSize = theme.FontSize - 2
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = name
                btn.AutoButtonColor = false
                createCorner(btn, UDim.new(0, 4))
                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    dropdownFrame.Parent = nil
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
                end)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                updateHeaderText()
                if expanded then
                    dropdownFrame.Parent = Page
                    dropdownFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
                else
                    dropdownFrame.Parent = nil
                end
                dropdownFrame.Visible = expanded
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Fire()
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
            SliderFrame.Size = UDim2.new(1, -theme.Padding * 2, 0, 40)
            SliderFrame.Position = UDim2.new(0, theme.Padding, 0, 0)
            SliderFrame.BackgroundTransparency = 1

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), theme.FontSize - 2, theme.Text, theme.Font, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
            SliderBar.BackgroundColor3 = theme.TabBackground
            SliderBar.BorderSizePixel = 0

            createCorner(SliderBar, UDim.new(0, 6))

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0

            createCorner(SliderFill, UDim.new(0, 6))

            local draggingSlider = false
            local currentValue = default

            local function updateSliderValue(inputPos)
                local relativeX = math.clamp(inputPos.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
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
                    updateSliderValue(input.Position)
                    input.Handled = true
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderValue(input.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            return {
                Set = function(_, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    currentValue = value
                    if callback then
                        callback(value)
                    end
                end,
                Get = function()
                    return currentValue
                end,
                _instance = SliderFrame
            }
        end

        return tab
    end

    local function applyTheme()
        MainFrame.BackgroundColor3 = theme.Background
        TabContainer.BackgroundColor3 = theme.TabBackground
        PageContainer.BackgroundColor3 = theme.Background
        Title.TextColor3 = theme.Text
        BtnMinimize.BackgroundColor3 = theme.TabBackground
        BtnMinimize.TextColor3 = theme.Text
        UIStroke.Color = theme.Stroke
        setMenuOpacity(MainFrame, theme.Opacity)
        for tabName, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (btn == currentActiveTabButton) and theme.Accent or theme.TabBackground
            btn.TextColor3 = theme.Text
        end
    end

    local initialConfigData = readConfigFile(CONFIG_FILENAME)
    if initialConfigData then
        local ok, initialConfig = pcall(function() return HttpService:JSONDecode(initialConfigData) end)
        if ok and typeof(initialConfig) == "table" then
            for _, k in ipairs(themeConfigKeys) do
                if initialConfig[k] ~= nil then
                    if typeof(theme[k]) == "Color3" and typeof(initialConfig[k]) == "table" and #initialConfig[k] == 3 then
                        theme[k] = Color3.new(unpack(initialConfig[k]))
                    elseif k == "Opacity" then
                        theme[k] = tonumber(initialConfig[k]) or theme[k]
                    end
                end
            end
            applyTheme()
        else
            warn("Erro ao carregar ou decodificar configuração inicial.")
        end
    end
    setMenuOpacity(MainFrame, theme.Opacity)

    task.wait(0.1)
    if firstTabName ~= nil then
        local firstTabButton = tabButtons[firstTabName]
        switchToPage(firstTabName, firstTabButton)
    end

    connectDragEvents()

    createCustomizationTab(window, MainFrame, applyTheme)

    return window
end

return Library
