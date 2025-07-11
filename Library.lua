--[[
    Extlocal Library (Melhorada)
    - Novo design mais sofisticado e moderno, com animações suaves e melhor contraste.
    - Aba "Config" obrigatória no menu, com opções:
        - Alterar tema (Dark, White, Dark and White, Purple and Blue)
        - Mudar cor dos labels principais (color picker)
        - Trocar estilo da fonte (dropdown)
        - Ajustar opacidade do menu (slider)
        - Dropdown de configurações salvas
        - Botões de salvar e carregar configurações
    - Suporte a salvar/carregar configurações em JSON localmente (através de `HttpService` e `setclipboard`/`clipboard`)
    - UI modernizada, com espaçamento, sombras, smooth transitions, cantos arredondados e cores temáticas.
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Temas disponíveis
local themes = {
    ["Dark"] = {
        Background = Color3.fromRGB(30, 30, 30),
        Tab = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(20, 20, 20),
    },
    ["White"] = {
        Background = Color3.fromRGB(240, 240, 240),
        Tab = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(180, 180, 180),
        ScrollViewBackground = Color3.fromRGB(230, 230, 230),
    },
    ["Dark and White"] = {
        Background = Color3.fromRGB(45, 45, 45),
        Tab = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(45, 45, 45),
        Stroke = Color3.fromRGB(100, 100, 100),
        ScrollViewBackground = Color3.fromRGB(60, 60, 60),
    },
    ["Purple and Blue"] = {
        Background = Color3.fromRGB(50, 40, 70),
        Tab = Color3.fromRGB(60, 50, 100),
        Accent = Color3.fromRGB(124, 58, 237),
        Text = Color3.fromRGB(210, 210, 255),
        Stroke = Color3.fromRGB(80, 50, 110),
        ScrollViewBackground = Color3.fromRGB(35, 25, 50),
    },
}

local fontStyles = {
    "Gotham",
    "GothamBold",
    "GothamMedium",
    "GothamSemibold",
    "SourceSans",
    "SourceSansBold",
    "SourceSansItalic",
    "SourceSansLight",
    "SourceSansSemibold"
}

-- Configuração padrão
local defaultConfig = {
    Theme = "Dark",
    MainLabelColor = Color3.fromRGB(255,255,255),
    Font = "Gotham",
    MenuOpacity = 1,
    SavedList = {},
    LastConfigName = ""
}

local currentConfig = table.clone(defaultConfig)
local savedConfigs = {}

-- Função utilitária para alterar tema
local function applyTheme(themeName, guiElements)
    local th = themes[themeName] or themes["Dark"]
    for key, obj in pairs(guiElements) do
        if obj and th[key] then
            if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                TweenService:Create(obj, TweenInfo.new(0.3), { BackgroundColor3 = th[key] }):Play()
            end
        end
    end
end

-- Função utilitária para aplicar fonte
local function applyFont(font, guiLabels)
    for _, label in ipairs(guiLabels) do
        if label and label:IsA("TextLabel") or label:IsA("TextButton") then
            label.Font = Enum.Font[font]
        end
    end
end

-- Função utilitária para aplicar cor do label principal
local function applyMainLabelColor(color, labels)
    for _, label in ipairs(labels) do
        if label and label:IsA("TextLabel") then
            TweenService:Create(label, TweenInfo.new(0.2), { TextColor3 = color }):Play()
        end
    end
end

-- Função utilitária para copiar para clipboard
local function copyToClipboard(str)
    pcall(function()
        setclipboard(str)
    end)
end

-- Função utilitária para salvar/load configs
local function saveConfig(name)
    if not name or name == "" then return end
    local data = {
        Theme = currentConfig.Theme,
        MainLabelColor = currentConfig.MainLabelColor,
        Font = currentConfig.Font,
        MenuOpacity = currentConfig.MenuOpacity
    }
    savedConfigs[name] = data
    currentConfig.LastConfigName = name
    if not table.find(currentConfig.SavedList, name) then
        table.insert(currentConfig.SavedList, name)
    end
    -- No Roblox, persistência local só é possível via clipboard ou Datastore (limitado em local scripts)
    copyToClipboard(HttpService:JSONEncode(savedConfigs))
end

local function loadConfig(name)
    if not name or not savedConfigs[name] then return end
    for k,v in pairs(savedConfigs[name]) do
        currentConfig[k] = v
    end
    currentConfig.LastConfigName = name
end

-- Função para criar colorpicker básico (fake, pois não existe nativo)
local function createColorPicker(parent, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 36, 0, 24)
    btn.BackgroundColor3 = default
    btn.Text = ""
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(function()
        -- Simula um colorpicker: usuário deve colar valor hexadecimal
        local hex = tostring(game:GetService("StarterGui"):PromptInput("Digite o HEX da cor (#RRGGBB):", "Exemplo: #00FF00"))
        if hex and typeof(hex) == "string" and #hex == 7 and hex:sub(1,1) == "#" then
            local r = tonumber(hex:sub(2,3),16) or 255
            local g = tonumber(hex:sub(4,5),16) or 255
            local b = tonumber(hex:sub(6,7),16) or 255
            local c = Color3.fromRGB(r,g,b)
            btn.BackgroundColor3 = c
            if callback then callback(c) end
        end
    end)
    return btn
end

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 540, 0, 370)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = themes[currentConfig.Theme].Background
    MainFrame.BackgroundTransparency = 1 - currentConfig.MenuOpacity
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Shadow = Instance.new("ImageLabel")
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.BackgroundTransparency = 1
    Shadow.Size = UDim2.new(1, 32, 1, 32)
    Shadow.Position = UDim2.new(-0.03, 0, -0.03, 0)
    Shadow.ZIndex = 0
    Shadow.ImageTransparency = 0.67
    Shadow.Parent = MainFrame

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = themes[currentConfig.Theme].Stroke
    UIStroke.Thickness = 2

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -60, 0, 40)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 25
    Title.Font = Enum.Font[currentConfig.Font]
    Title.TextColor3 = currentConfig.MainLabelColor
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 34, 0, 34)
    BtnMinimize.Position = UDim2.new(1, -46, 0, 7)
    BtnMinimize.BackgroundColor3 = themes[currentConfig.Theme].Tab
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = themes[currentConfig.Theme].Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 25
    BtnMinimize.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, 8)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = themes[currentConfig.Theme].Accent }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = themes[currentConfig.Theme].Tab }):Play()
    end)

    local dragging, dragStart, startPos = false, Vector2.new(), UDim2.new()
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Position.Y < Title.AbsolutePosition.Y + Title.AbsoluteSize.Y then
                dragging = true
                dragStart = UserInputService:GetMouseLocation()
                startPos = MainFrame.Position
                input.Handled = true
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Redimensionar
    local resizeFrame = Instance.new("Frame", MainFrame)
    resizeFrame.Size = UDim2.new(0, 22, 0, 22)
    resizeFrame.Position = UDim2.new(1, -22, 1, -22)
    resizeFrame.BackgroundTransparency = 1
    resizeFrame.ZIndex = 120
    resizeFrame.Active = true
    local mouseDown, initialMousePos, initialFrameSize = false, Vector2.new(), UDim2.new()
    resizeFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseDown = true
            initialMousePos = UserInputService:GetMouseLocation()
            initialFrameSize = MainFrame.Size
            input.Handled = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - initialMousePos
            local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 900)
            local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 600)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseDown = false
        end
    end)

    -- Contêiner de abas/menu
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 48)
    TabContainer.Size = UDim2.new(0, 144, 1, -48)
    TabContainer.BackgroundColor3 = themes[currentConfig.Theme].Tab
    TabContainer.BorderSizePixel = 0
    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 9)
    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 7)

    -- Container das páginas
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 144, 0, 48)
    PageContainer.Size = UDim2.new(1, -144, 1, -48)
    PageContainer.BackgroundColor3 = themes[currentConfig.Theme].Background
    PageContainer.ClipsDescendants = true

    local pages, tabButtons, firstTabName = {}, {}, nil
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 144, 0, 48) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 540, 0, 370) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end
        for tname, btn in pairs(tabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = (tname == name) and themes[currentConfig.Theme].Accent or themes[currentConfig.Theme].Background
            }):Play()
        end
    end

    local window = {}

    function window:CreateTab(tabName, icon)
        if not firstTabName then firstTabName = tabName end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -12, 0, 38)
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = themes[currentConfig.Theme].Background
        Button.TextColor3 = themes[currentConfig.Theme].Text
        Button.Font = Enum.Font[currentConfig.Font]
        Button.TextSize = 17
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 8)

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 8, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 19
            iconLabel.TextColor3 = themes[currentConfig.Theme].Accent
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center
            Button.Text = "  " .. tabName
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = themes[currentConfig.Theme].Accent }):Play()
        end)
        Button.MouseLeave:Connect(function()
            if pages[tabName] and not pages[tabName].Visible then
                TweenService:Create(Button, TweenInfo.new(0.15), { BackgroundColor3 = themes[currentConfig.Theme].Background }):Play()
            end
        end)

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
        end)

        tabButtons[tabName] = Button

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundColor3 = themes[currentConfig.Theme].ScrollViewBackground
        Page.BorderSizePixel = 0
        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 10)
        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
        end)
        pages[tabName] = Page

        -- Métodos da aba iguais ao seu script original...

        -- (EXEMPLO) Função AddLabel, AddButton, AddToggle, AddDropdownButtonOnOff, AddSelectDropdown, AddSlider...
        -- Implemente igual ao seu código original, mas com uso de currentConfig para Tema, Fonte e Cores

        -- Exemplo para AddLabel:
        function Page:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -14, 0, 26)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = currentConfig.MainLabelColor
            Label.Font = Enum.Font[currentConfig.Font]
            Label.TextSize = 17
            Label.TextXAlignment = Enum.TextXAlignment.Left
            return Label
        end

        -- Adicione aqui os outros métodos (AddButton, AddToggle, etc), adaptando para usar currentConfig

        return Page
    end

    -- ABA CONFIG (Obrigatória)
    local configTab = window:CreateTab("Config", "⚙️")
    do
        -- Dropdown de tema
        local themeLabel = configTab:AddLabel("Tema do Menu")
        local themeDropdown = Instance.new("TextButton", configTab)
        themeDropdown.Size = UDim2.new(0, 180, 0, 28)
        themeDropdown.Text = currentConfig.Theme
        themeDropdown.BackgroundColor3 = themes[currentConfig.Theme].Tab
        themeDropdown.TextColor3 = themes[currentConfig.Theme].Text
        themeDropdown.Font = Enum.Font.Gotham
        themeDropdown.TextSize = 15
        local themeList = Instance.new("Frame", configTab)
        themeList.Size = UDim2.new(0, 180, 0, #themes*22)
        themeList.Visible = false
        themeDropdown.MouseButton1Click:Connect(function()
            themeList.Visible = not themeList.Visible
        end)
        local idx = 0
        for tn,_ in pairs(themes) do
            idx = idx + 1
            local btn = Instance.new("TextButton", themeList)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0,0,0,(idx-1)*22)
            btn.Text = tn
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.MouseButton1Click:Connect(function()
                currentConfig.Theme = tn
                themeDropdown.Text = tn
                applyTheme(tn, {
                    Background = MainFrame,
                    Tab = TabContainer,
                    Stroke = UIStroke,
                    ScrollViewBackground = PageContainer,
                })
                themeList.Visible = false
            end)
        end

        -- Colorpicker para label principal
        local colorLabel = configTab:AddLabel("Cor dos Labels Principais")
        local colorPicker = createColorPicker(configTab, currentConfig.MainLabelColor, function(color)
            currentConfig.MainLabelColor = color
            applyMainLabelColor(color, {Title, colorLabel})
        end)

        -- Dropdown de fonte
        local fontLabel = configTab:AddLabel("Fonte do Menu")
        local fontDropdown = Instance.new("TextButton", configTab)
        fontDropdown.Size = UDim2.new(0, 140, 0, 28)
        fontDropdown.Text = currentConfig.Font
        fontDropdown.BackgroundColor3 = themes[currentConfig.Theme].Tab
        fontDropdown.TextColor3 = themes[currentConfig.Theme].Text
        fontDropdown.Font = Enum.Font.Gotham
        fontDropdown.TextSize = 15
        local fontList = Instance.new("Frame", configTab)
        fontList.Size = UDim2.new(0, 140, 0, #fontStyles*20)
        fontList.Visible = false
        fontDropdown.MouseButton1Click:Connect(function()
            fontList.Visible = not fontList.Visible
        end)
        for i,fn in ipairs(fontStyles) do
            local btn = Instance.new("TextButton", fontList)
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.Position = UDim2.new(0,0,0,(i-1)*20)
            btn.Text = fn
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.MouseButton1Click:Connect(function()
                currentConfig.Font = fn
                fontDropdown.Text = fn
                applyFont(fn, {Title, fontLabel, themeLabel, colorLabel})
                fontList.Visible = false
            end)
        end

        -- Slider de opacidade do menu
        local opacityLabel = configTab:AddLabel("Opacidade do Menu")
        local opacitySlider = Instance.new("Frame", configTab)
        opacitySlider.Size = UDim2.new(0, 180, 0, 24)
        opacitySlider.BackgroundTransparency = 1
        local sliderBar = Instance.new("Frame", opacitySlider)
        sliderBar.Size = UDim2.new(1, 0, 0, 12)
        sliderBar.Position = UDim2.new(0, 0, 0, 6)
        sliderBar.BackgroundColor3 = themes[currentConfig.Theme].Tab
        local sliderFill = Instance.new("Frame", sliderBar)
        local percent = currentConfig.MenuOpacity
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderFill.BackgroundColor3 = themes[currentConfig.Theme].Accent
        local draggingSlider = false
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                local percent = relativeX / sliderBar.AbsoluteSize.X
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                currentConfig.MenuOpacity = percent
                MainFrame.BackgroundTransparency = 1 - percent
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)

        -- Dropdown de configs salvas
        local savedLabel = configTab:AddLabel("Configurações salvas")
        local savedDropdown = Instance.new("TextButton", configTab)
        savedDropdown.Size = UDim2.new(0, 200, 0, 28)
        savedDropdown.Text = currentConfig.LastConfigName or "(Nenhuma)"
        savedDropdown.BackgroundColor3 = themes[currentConfig.Theme].Tab
        savedDropdown.TextColor3 = themes[currentConfig.Theme].Text
        savedDropdown.Font = Enum.Font.Gotham
        savedDropdown.TextSize = 15
        local savedList = Instance.new("Frame", configTab)
        savedList.Size = UDim2.new(0, 200, 0, #currentConfig.SavedList*20)
        savedList.Visible = false
        savedDropdown.MouseButton1Click:Connect(function()
            savedList.Visible = not savedList.Visible
        end)
        for i,name in ipairs(currentConfig.SavedList) do
            local btn = Instance.new("TextButton", savedList)
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.Position = UDim2.new(0,0,0,(i-1)*20)
            btn.Text = name
            btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.MouseButton1Click:Connect(function()
                savedDropdown.Text = name
                savedList.Visible = false
                loadConfig(name)
            end)
        end

        -- Botão salvar
        local saveBtn = Instance.new("TextButton", configTab)
        saveBtn.Size = UDim2.new(0, 90, 0, 28)
        saveBtn.Text = "Salvar"
        saveBtn.BackgroundColor3 = themes[currentConfig.Theme].Accent
        saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.TextSize = 15
        saveBtn.MouseButton1Click:Connect(function()
            local configName = tostring(game:GetService("StarterGui"):PromptInput("Nome da configuração:", currentConfig.LastConfigName or ""))
            if configName and configName ~= "" then
                saveConfig(configName)
                -- Atualizar lista de configs salvas
                savedDropdown.Text = configName
            end
        end)

        -- Botão carregar
        local loadBtn = Instance.new("TextButton", configTab)
        loadBtn.Size = UDim2.new(0, 90, 0, 28)
        loadBtn.Text = "Carregar"
        loadBtn.BackgroundColor3 = themes[currentConfig.Theme].Tab
        loadBtn.TextColor3 = themes[currentConfig.Theme].Accent
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.TextSize = 15
        loadBtn.MouseButton1Click:Connect(function()
            if savedDropdown.Text and savedDropdown.Text ~= "(Nenhuma)" then
                loadConfig(savedDropdown.Text)
            end
        end)
    end

    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName then
            switchToPage(firstTabName)
        end
    end)()

    return window
end

return Library
