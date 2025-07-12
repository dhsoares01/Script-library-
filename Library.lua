-- Biblioteca de UI aprimorada para Roblox 
-- - Expansão do menu mantém tamanho anterior
-- - Tela de loading exibida antes do menu, e só some após carregar configs
-- - Opacidade aplicada ao ScrollView do menu
-- - Salvamento e recuperação de todos controles (toggles, sliders, DropdownButtonOnOff, DropdownSelect, etc)
-- - Loading animado, centralizado, camada mais alta, tempo mínimo 5s, logo e círculo animado!

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local FONTS = {
    ["Gotham"] = Enum.Font.Gotham,
    ["GothamBold"] = Enum.Font.GothamBold,
    ["GothamSemibold"] = Enum.Font.GothamSemibold,
    ["Arial"] = Enum.Font.Arial,
    ["SourceSans"] = Enum.Font.SourceSans,
    ["Roboto"] = Enum.Font.Roboto,
    ["GothamMedium"] = Enum.Font.GothamMedium -- Adicionado para consistência
}

local THEMES = {
    ["Dark"] = {
        Background = Color3.fromRGB(30, 30, 30),
        TabBackground = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        LabelText = Color3.fromRGB(220, 220, 220),
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(20, 20, 20),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 10),
        SmallCornerRadius = UDim.new(0, 8),
        Padding = 10,
        TabButtonHeight = 38,
        ControlHeight = 36,
        ControlPadding = 8,
        Opacity = 1,
        Font = "Gotham"
    },

    ["White"] = {
        Background = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(20, 20, 20),
        LabelText = Color3.fromRGB(60, 60, 60),
        Stroke = Color3.fromRGB(200, 200, 200),
        ScrollViewBackground = Color3.fromRGB(250, 250, 250),
        ButtonBackground = Color3.fromRGB(220, 220, 220),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 10),
        SmallCornerRadius = UDim.new(0, 8),
        Padding = 10,
        TabButtonHeight = 38,
        ControlHeight = 36,
        ControlPadding = 8,
        Opacity = 1,
        Font = "Gotham"
    },

    ["Dark Forte"] = {
        Background = Color3.fromRGB(15, 15, 15),
        TabBackground = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(255, 0, 85),
        Text = Color3.fromRGB(255, 255, 255),
        LabelText = Color3.fromRGB(200, 200, 200),
        Stroke = Color3.fromRGB(50, 50, 50),
        ScrollViewBackground = Color3.fromRGB(10, 10, 10),
        ButtonBackground = Color3.fromRGB(40, 40, 40),
        Warning = Color3.fromRGB(255, 85, 0),
        CornerRadius = UDim.new(0, 10),
        SmallCornerRadius = UDim.new(0, 8),
        Padding = 10,
        TabButtonHeight = 38,
        ControlHeight = 36,
        ControlPadding = 8,
        Opacity = 1,
        Font = "GothamBold"
    },

    ["White and Dark"] = {
        Background = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(20, 20, 20),
        LabelText = Color3.fromRGB(60, 60, 60),
        Stroke = Color3.fromRGB(100, 100, 100),
        ScrollViewBackground = Color3.fromRGB(250, 250, 250),
        ButtonBackground = Color3.fromRGB(40, 40, 40),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 10),
        SmallCornerRadius = UDim.new(0, 8),
        Padding = 10,
        TabButtonHeight = 38,
        ControlHeight = 36,
        ControlPadding = 8,
        Opacity = 1,
        Font = "Gotham"
    }
}

local DEFAULT_THEME = table.clone(THEMES["Dark"])
local theme = table.clone(DEFAULT_THEME)

local function createCorner(parent, radius)
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = radius or theme.CornerRadius
    UICorner.Parent = parent
    return UICorner
end

local function createPadding(parent, allPadding)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, allPadding)
    UIPadding.PaddingRight = UDim.new(0, allPadding)
    UIPadding.PaddingTop = UDim.new(0, allPadding)
    UIPadding.PaddingBottom = UDim.new(0, allPadding)
    UIPadding.Parent = parent
    return UIPadding
end

local function createTextLabel(parent, text, textSize, textColor, font, alignment)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize or 16
    label.TextColor3 = textColor or theme.LabelText
    label.Font = font or FONTS[theme.Font] or Enum.Font.Gotham
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
    button.Font = font or FONTS[theme.Font] or Enum.Font.GothamMedium
    button.TextSize = textSize or 16
    button.AutoButtonColor = false
    button.Parent = parent

    createCorner(button, theme.SmallCornerRadius)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = bgColor or theme.ButtonBackground }):Play()
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    return button
end

local function setMenuOpacity(window, opacity)
    if window._mainFrame then
        local transparency = 1 - opacity
        window._mainFrame.BackgroundTransparency = transparency
        window._header.BackgroundTransparency = transparency
        window._tabs.BackgroundTransparency = transparency
        window._page.BackgroundTransparency = transparency
        for _, v in pairs(window._scrollViews or {}) do
            v.BackgroundTransparency = transparency
        end
    end
end

local function getConfigPath(windowName)
    windowName = windowName or "CustomUILib"
    local configKey = "MenuConfig_" .. windowName
    -- Verifica se writefile/readfile estão disponíveis (ex: em ambientes de exploit)
    if _G.writefile and _G.readfile then
        return configKey .. ".json"
    end
    return nil
end

local function saveConfig(window, controls, windowName)
    local config = {
        Theme = {},
        Controls = {},
        Opacity = theme.Opacity,
        Font = theme.Font,
        Size = window._mainFrame and {X = window._mainFrame.Size.X.Offset, Y = window._mainFrame.Size.Y.Offset} or {X = 540, Y = 360}
    }
    -- Salva as propriedades do tema, convertendo Color3 para tabela
    for k, v in pairs(theme) do
        if typeof(v) == "Color3" then
            config.Theme[k] = {v.R, v.G, v.B}
        elseif typeof(v) == "UDim" then
            config.Theme[k] = {v.Scale, v.Offset}
        else
            config.Theme[k] = v
        end
    end
    -- Salva os estados dos controles
    for key, ctrl in pairs(controls) do
        if ctrl.Get then
            config.Controls[key] = ctrl:Get()
        elseif ctrl.GetAll then
            config.Controls[key] = ctrl:GetAll()
        elseif ctrl.GetSelected then
            config.Controls[key] = ctrl:GetSelected()
        end
    end
    local json = HttpService:JSONEncode(config)
    local path = getConfigPath(windowName)
    if path then
        pcall(function() _G.writefile(path, json) end)
    else
        -- Fallback para clipboard se writefile não estiver disponível
        pcall(function() setclipboard(json) end)
    end
end

local function loadConfig(window, controls, windowName, labelRefs)
    local config = nil
    local path = getConfigPath(windowName)
    if path then
        local success, content = pcall(function() return _G.readfile(path) end)
        if success and content then
            pcall(function() config = HttpService:JSONDecode(content) end)
        end
    end

    -- Tenta carregar do clipboard se não houver arquivo ou se a leitura falhar
    if not config then
        local ok, clipboard = pcall(function() return getclipboard() end)
        if ok and clipboard then
            local decoded
            pcall(function() decoded = HttpService:JSONDecode(clipboard) end)
            if decoded and decoded.Theme then -- Verifica se é uma config válida
                config = decoded
            end
        end
    end

    if not config then return end

    -- Aplica o tema carregado
    for k, v in pairs(config.Theme or {}) do
        if typeof(DEFAULT_THEME[k]) == "Color3" and typeof(v) == "table" then
            theme[k] = Color3.new(v[1], v[2], v[3])
        elseif typeof(DEFAULT_THEME[k]) == "UDim" and typeof(v) == "table" then
            theme[k] = UDim.new(v[1], v[2])
        else
            theme[k] = v
        end
    end
    theme.Opacity = config.Opacity or theme.Opacity
    theme.Font = config.Font or theme.Font

    -- Ajusta o tamanho do frame principal
    if window._mainFrame then
        if config.Size and config.Size.X and config.Size.Y then
            window._mainFrame.Size = UDim2.new(0, config.Size.X, 0, config.Size.Y)
        end
    end

    -- Aplica os estados dos controles
    for key, value in pairs(config.Controls or {}) do
        if controls[key] then
            if controls[key].Set then
                controls[key]:Set(value)
            elseif controls[key].SetAll then
                controls[key]:SetAll(value)
            elseif controls[key].SetSelected then
                controls[key]:SetSelected(value)
            end
        end
    end

    -- Reaplicar o tema a todos os elementos visuais
    if window.ApplyTheme then
        window:ApplyTheme(labelRefs)
    end
    setMenuOpacity(window, theme.Opacity)
end

function Library:CreateWindow(name)
    local controls = {}
    local labelRefs = {} -- Referências para todos os TextLabels criados, para aplicar o tema dinamicamente
    local scrollViews = {}

    -- Tela de Loading
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "UILoadingScreen"
    loadingGui.Parent = CoreGui
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    loadingGui.DisplayOrder = 2^31 - 1 -- Garante que esteja no topo

    local loadingFrame = Instance.new("Frame", loadingGui)
    loadingFrame.Size = UDim2.new(0, 400, 0, 180)
    loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    loadingFrame.BackgroundTransparency = 0
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Visible = true
    createCorner(loadingFrame, UDim.new(0, 18))

    -- Logo
    local logo = Instance.new("ImageLabel", loadingFrame)
    logo.Image = "https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/file_00000000d87c622f85a325b6fb76c039.png" -- Seu asset de logo
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 68, 0, 68)
    logo.Position = UDim2.new(0.5, -34, 0, 22) -- Centralizado acima dos textos
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ZIndex = 99

    -- Círculo animado (loader)
    local circle = Instance.new("Frame", loadingFrame)
    circle.Size = UDim2.new(0, 64, 0, 64)
    circle.Position = UDim2.new(0.5, -32, 0, 20) -- Alinhado com a logo
    circle.BackgroundTransparency = 1
    circle.ZIndex = 5

    local circleUI = Instance.new("UIStroke", circle)
    circleUI.Thickness = 5
    circleUI.Color = Color3.fromRGB(0, 120, 255)
    circleUI.Transparency = 0
    circleUI.LineJoinMode = Enum.LineJoinMode.Round
    circleUI.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local arc = Instance.new("ImageLabel", circle)
    arc.BackgroundTransparency = 1
    arc.Image = "rbxassetid://13762349403" -- Asset de arco circular
    arc.ImageColor3 = Color3.fromRGB(0, 120, 255)
    arc.Size = UDim2.new(1, 0, 1, 0)
    arc.AnchorPoint = Vector2.new(0.5, 0.5)
    arc.Position = UDim2.new(0.5, 0, 0.5, 0)
    arc.ZIndex = 6

    -- Animação de rotação do arco
    local animRunning = true
    local rotationTween = TweenService:Create(arc, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), { Rotation = 360 })
    rotationTween:Play()

    -- Textos (logo + loader label)
    local logoText = createTextLabel(loadingFrame, "Script Library", 19, Color3.fromRGB(0, 170, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    logoText.Position = UDim2.new(0, 0, 0, 96)
    logoText.Size = UDim2.new(1, 0, 0, 30)
    logoText.TextTransparency = 0
    logoText.BackgroundTransparency = 1

    local loadingLabel = createTextLabel(loadingFrame, "Carregando Menu...", 16, Color3.fromRGB(220, 220, 220), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    loadingLabel.Size = UDim2.new(1, 0, 0, 28)
    loadingLabel.Position = UDim2.new(0, 0, 1, -36)
    loadingLabel.TextYAlignment = Enum.TextYAlignment.Top
    loadingLabel.TextTransparency = 0.05

    -- Animação de pontinhos no texto de carregamento
    local animDots = true
    coroutine.wrap(function()
        local i = 0
        while animDots do
            local dots = string.rep(".", (i % 4))
            loadingLabel.Text = "Carregando Menu" .. dots
            i = i + 1
            task.wait(0.4)
        end
    end)()

    -- Menu principal (inicia invisível)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    ScreenGui.Enabled = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 540, 0, 360)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BackgroundTransparency = 1 - theme.Opacity
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local prevExpandedSize = MainFrame.Size -- Para manter o tamanho ao minimizar/restaurar

    -- Dragging logic for MainFrame
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 44)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = theme.TabBackground
    HeaderFrame.BackgroundTransparency = 1 - theme.Opacity
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Active = true

    createCorner(HeaderFrame, theme.CornerRadius)

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

    createCorner(MainFrame, theme.CornerRadius)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1

    local Title = createTextLabel(HeaderFrame, name or "Menu", 22, theme.Text, FONTS[theme.Font] or Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, theme.Padding, 0, 0)
    Title.TextYAlignment = Enum.TextYAlignment.Center

    local BtnMinimize = createTextButton(HeaderFrame, "–", nil, theme.TabBackground, theme.Text, FONTS[theme.Font] or Enum.Font.GothamBold, 26)
    BtnMinimize.Size = UDim2.new(0, 34, 0, 34)
    BtnMinimize.Position = UDim2.new(1, -theme.Padding - 34, 0, (HeaderFrame.Size.Y.Offset - 34) / 2)
    createCorner(BtnMinimize, theme.SmallCornerRadius)
    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Warning }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
    end)

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 44)
    TabContainer.Size = UDim2.new(0, 144, 1, -44)
    TabContainer.BackgroundColor3 = theme.TabBackground
    TabContainer.BackgroundTransparency = 1 - theme.Opacity
    TabContainer.ClipsDescendants = true
    local TabCorner = createCorner(TabContainer, theme.CornerRadius)
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, theme.Padding)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    createPadding(TabContainer, theme.Padding / 2)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 144, 0, 44)
    PageContainer.Size = UDim2.new(1, -144, 1, -44)
    PageContainer.BackgroundColor3 = theme.ScrollViewBackground
    PageContainer.BackgroundTransparency = 1 - theme.Opacity
    PageContainer.ClipsDescendants = true
    createCorner(PageContainer, theme.CornerRadius)

    local pages = {}
    local firstTabName = nil
    local activeTabButton = nil
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            prevExpandedSize = MainFrame.Size
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 44) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = prevExpandedSize }):Play()
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
            TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = theme.ButtonBackground }):Play()
        end
        activeTabButton = button
        TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end

    local window = {}
    window._mainFrame = MainFrame
    window._header = HeaderFrame
    window._tabs = TabContainer
    window._page = PageContainer
    window._scrollViews = scrollViews

    function window:ApplyTheme(labelRefsToUpdate)
        MainFrame.BackgroundColor3 = theme.Background
        MainFrame.BackgroundTransparency = 1 - theme.Opacity
        HeaderFrame.BackgroundColor3 = theme.TabBackground
        HeaderFrame.BackgroundTransparency = 1 - theme.Opacity
        TabContainer.BackgroundColor3 = theme.TabBackground
        TabContainer.BackgroundTransparency = 1 - theme.Opacity
        PageContainer.BackgroundColor3 = theme.ScrollViewBackground
        PageContainer.BackgroundTransparency = 1 - theme.Opacity
        UIStroke.Color = theme.Stroke
        Title.TextColor3 = theme.Text
        Title.Font = FONTS[theme.Font] or Title.Font
        BtnMinimize.TextColor3 = theme.Text
        BtnMinimize.Font = FONTS[theme.Font] or BtnMinimize.Font

        -- Atualiza todos os TextLabels registrados
        for _, ref in ipairs(labelRefsToUpdate) do
            if ref and ref:IsA("TextLabel") then
                ref.TextColor3 = theme.LabelText or theme.Text
                ref.Font = FONTS[theme.Font] or ref.Font
            end
        end

        -- Atualiza ScrollViews
        for _, sv in pairs(scrollViews) do
            sv.BackgroundTransparency = 1 - theme.Opacity
        end

        -- Atualiza botões (Tabs, Toggles, Dropdowns)
        for _, ctrl in pairs(controls) do
            if ctrl.updateVisual then
                ctrl:updateVisual()
            end
        end

        -- Reaplicar corner radius
        createCorner(MainFrame, theme.CornerRadius)
        createCorner(HeaderFrame, theme.CornerRadius)
        createCorner(TabContainer, theme.CornerRadius)
        createCorner(PageContainer, theme.CornerRadius)
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                createCorner(btn, theme.SmallCornerRadius)
            end
        end
        for _, sv in pairs(scrollViews) do
            createCorner(sv, theme.CornerRadius)
        end
    end

    do -- Redimensionamento do menu
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true
        resizeFrame.Name = "ResizeHandle"

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
                -- Limita o tamanho mínimo e máximo do menu
                local newWidth = math.clamp(initialFrameSize.X.Offset + delta.X, 350, 1000)
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 700)
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

        local Button = createTextButton(TabContainer, "  " .. tabName, nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 18)
        Button.Size = UDim2.new(1, -theme.Padding, 0, theme.TabButtonHeight)
        Button.TextXAlignment = Enum.TextXAlignment.Left

        if icon then
            local iconLabel = createTextLabel(Button, icon, 20, theme.Accent, FONTS[theme.Font], Enum.TextXAlignment.Center)
            iconLabel.Size = UDim2.new(0, 28, 1, 0)
            iconLabel.Position = UDim2.new(0, theme.ControlPadding, 0, 0)
        end

        Button.MouseEnter:Connect(function()
            if Button ~= activeTabButton then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 60, 60) }):Play()
            end
        end)
        Button.MouseLeave:Connect(function()
            if Button ~= activeTabButton then
                TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.ButtonBackground }):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 7
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BackgroundTransparency = 1 - theme.Opacity
        Page.BorderSizePixel = 0
        Page.Active = true

        createCorner(Page, theme.CornerRadius)
        local PageListLayout = Instance.new("UIListLayout", Page)
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, theme.Padding)
        PageListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        createPadding(Page, theme.Padding)
        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + theme.Padding * 2)
        end)

        pages[tabName] = Page
        table.insert(scrollViews, Page)

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = createTextLabel(Page, text, 16, theme.LabelText or theme.Text, FONTS[theme.Font], Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 26)
            table.insert(labelRefs, Label)
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.Accent, Color3.new(1, 1, 1), FONTS[theme.Font], 16)
            -- Adiciona uma função de atualização visual para o tema
            Btn.updateVisual = function()
                Btn.BackgroundColor3 = theme.Accent
                Btn.TextColor3 = Color3.new(1, 1, 1)
                Btn.Font = FONTS[theme.Font]
                createCorner(Btn, theme.SmallCornerRadius) -- Recria o canto para atualizar o radius
            end
            local id = "Button_" .. text
            controls[id] = Btn -- Armazena a referência para a atualização do tema
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = createTextButton(Page, text, nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 16)
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            ToggleBtn.TextScaled = false
            local state = false

            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.ButtonBackground }):Play()
                ToggleBtn.TextColor3 = theme.Text
                ToggleBtn.Font = FONTS[theme.Font]
                createCorner(ToggleBtn, theme.SmallCornerRadius)
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
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60, 60, 60) }):Play()
            end)
            ToggleBtn.MouseLeave:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.ButtonBackground }):Play()
            end)

            local id = "Toggle_" .. text
            controls[id] = {
                Set = function(self, value) state = value; updateToggleVisual(); end,
                Get = function(self) return state end,
                updateVisual = updateToggleVisual -- Adiciona para atualização do tema
            }
            return controls[id]
        end

        function tab:AddDropdownButtonOnOff(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
            container.BackgroundColor3 = theme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, theme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1

            local dropdownFrame = Instance.new("Frame", Page)
            -- A altura inicial é 0, será ajustada dinamicamente
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding)
            createPadding(dropdownFrame, theme.ControlPadding / 2)

            local states = {}
            local itemButtons = {}

            local function updateItemButtonVisual(btn, name)
                btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.ButtonBackground }):Play()
                btn.TextColor3 = theme.Text
                btn.Font = FONTS[theme.Font]
                createCorner(btn, theme.SmallCornerRadius)
            end

            for _, name in ipairs(items) do
                states[name] = false
                local btn = createTextButton(dropdownFrame, name .. ": OFF", nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                itemButtons[name] = btn
                updateItemButtonVisual(btn, name) -- Inicializa visual

                btn.MouseButton1Click:Connect(function()
                    states[name] = not states[name]
                    updateItemButtonVisual(btn, name)
                    if callback then
                        callback(states)
                    end
                end)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or Color3.fromRGB(60, 60, 60) }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.ButtonBackground }):Play()
                end)
            end

            -- Ajusta a altura do dropdownFrame dinamicamente
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                dropdownFrame.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
            end)

            local expanded = false
            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title
                -- Ajusta a altura do container principal se o dropdown estiver visível
                container.Size = UDim2.new(1, 0, 0, theme.ControlHeight + (expanded and dropdownFrame.Size.Y.Offset or 0))
            end)

            local id = "DropdownOnOff_" .. title
            controls[id] = {
                SetAll = function(_, tbl)
                    for k, v in pairs(tbl or {}) do
                        if states[k] ~= nil then
                            states[k] = v
                            if itemButtons[k] then
                                updateItemButtonVisual(itemButtons[k], k)
                            end
                        end
                    end
                    if callback then callback(states) end
                end,
                GetAll = function()
                    return states
                end,
                updateVisual = function() -- Atualiza visual de todos os sub-botões do dropdown
                    header.BackgroundColor3 = theme.ButtonBackground
                    header.TextColor3 = theme.Text
                    header.Font = FONTS[theme.Font]
                    createCorner(container, theme.SmallCornerRadius)
                    createCorner(dropdownFrame, theme.SmallCornerRadius)
                    dropdownFrame.BackgroundColor3 = theme.TabBackground
                    for name, btn in pairs(itemButtons) do
                        updateItemButtonVisual(btn, name)
                    end
                end
            }
            return controls[id]
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
            container.BackgroundColor3 = theme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, theme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0) -- Altura dinâmica
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding)
            createPadding(dropdownFrame, theme.ControlPadding / 2)

            local selectedItem = nil
            local expanded = false

            local function updateHeaderText()
                header.TextColor3 = theme.Text
                header.Font = FONTS[theme.Font]
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end
            updateHeaderText() -- Inicializa o texto do header

            for _, name in ipairs(items) do
                local btn = createTextButton(dropdownFrame, name, nil, theme.ButtonBackground, theme.Text, FONTS[theme.Font], 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                local function updateItemBtnVisual()
                    btn.BackgroundColor3 = theme.ButtonBackground
                    btn.TextColor3 = theme.Text
                    btn.Font = FONTS[theme.Font]
                    createCorner(btn, theme.SmallCornerRadius)
                end
                updateItemBtnVisual() -- Inicializa visual

                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                    -- Recolhe o container após a seleção
                    container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
                end)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.ButtonBackground }):Play()
                end)
            end

            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                dropdownFrame.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + theme.ControlPadding)
            end)

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                updateHeaderText()
                -- Expande/recolhe o container principal
                container.Size = UDim2.new(1, 0, 0, theme.ControlHeight + (expanded and dropdownFrame.Size.Y.Offset or 0))
            end)

            local id = "Dropdown_" .. title
            controls[id] = {
                SetSelected = function(_, item)
                    if table.find(items, item) then
                        selectedItem = item
                        updateHeaderText()
                        if callback then
                            callback(selectedItem)
                        end
                    end
                end,
                GetSelected = function()
                    return selectedItem
                end,
                updateVisual = function() -- Atualiza visual
                    updateHeaderText()
                    header.BackgroundColor3 = theme.ButtonBackground
                    createCorner(container, theme.SmallCornerRadius)
                    createCorner(dropdownFrame, theme.SmallCornerRadius)
                    dropdownFrame.BackgroundColor3 = theme.TabBackground
                    for _, btn in pairs(dropdownFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = theme.ButtonBackground
                            btn.TextColor3 = theme.Text
                            btn.Font = FONTS[theme.Font]
                            createCorner(btn, theme.SmallCornerRadius)
                        end
                    end
                end
            }
            return controls[id]
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundTransparency = 1

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), 15, theme.LabelText or theme.Text, FONTS[theme.Font], Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            table.insert(labelRefs, Label)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 14)
            SliderBar.Position = UDim2.new(0, 0, 0, 26)
            SliderBar.BackgroundColor3 = theme.ButtonBackground
            SliderBar.BorderSizePixel = 0
            createCorner(SliderBar, theme.SmallCornerRadius)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0
            createCorner(SliderFill, theme.SmallCornerRadius)

            local draggingSlider = false
            local value = default

            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                value = math.floor(min + (max - min) * percent)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
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

            local id = "Slider_" .. text
            controls[id] = {
                Set = function(self, newValue)
                    value = newValue
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then
                        callback(value)
                    end
                    createCorner(SliderFill, theme.SmallCornerRadius) -- Atualiza o canto
                end,
                Get = function(self)
                    return value
                end,
                updateVisual = function() -- Atualiza visual do slider
                    SliderBar.BackgroundColor3 = theme.ButtonBackground
                    SliderFill.BackgroundColor3 = theme.Accent
                    Label.TextColor3 = theme.LabelText
                    Label.Font = FONTS[theme.Font]
                    createCorner(SliderBar, theme.SmallCornerRadius)
                    createCorner(SliderFill, theme.SmallCornerRadius)
                end
            }
            return controls[id]
        end

        function tab:AddFloatSlider(text, min, max, default, decimals, callback)
            decimals = decimals or 2 -- Padrão para 2 casas decimais

            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundTransparency = 1

            local Label = createTextLabel(SliderFrame, text .. ": " .. string.format("%." .. decimals .. "f", default), 15, theme.LabelText or theme.Text, FONTS[theme.Font], Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            table.insert(labelRefs, Label)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 14)
            SliderBar.Position = UDim2.new(0, 0, 0, 26)
            SliderBar.BackgroundColor3 = theme.ButtonBackground
            SliderBar.BorderSizePixel = 0
            createCorner(SliderBar, theme.SmallCornerRadius)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0
            createCorner(SliderFill, theme.SmallCornerRadius)

            local draggingSlider = false
            local value = default

            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local rawValue = min + (max - min) * percent
                value = tonumber(string.format("%." .. decimals .. "f", rawValue)) -- Arredonda para o número de decimais
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
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

            local id = "FloatSlider_" .. text
            controls[id] = {
                Set = function(self, newValue)
                    value = tonumber(string.format("%." .. decimals .. "f", newValue))
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then
                        callback(value)
                    end
                    createCorner(SliderFill, theme.SmallCornerRadius) -- Atualiza o canto
                end,
                Get = function(self)
                    return value
                end,
                updateVisual = function() -- Atualiza visual do slider
                    SliderBar.BackgroundColor3 = theme.ButtonBackground
                    SliderFill.BackgroundColor3 = theme.Accent
                    Label.TextColor3 = theme.LabelText
                    Label.Font = FONTS[theme.Font]
                    createCorner(SliderBar, theme.SmallCornerRadius)
                    createCorner(SliderFill, theme.SmallCornerRadius)
                end
            }
            return controls[id]
        end


        return tab
    end

    -- Aba de Configuração (ajustada para usar a nova função ApplyTheme corretamente)
    local configTab = window:CreateTab("Config", "")
    configTab:AddLabel("Customização do Menu:")

    configTab:AddSelectDropdown("Tema", {"Dark", "White", "Dark Forte", "White and Dark"}, function(selected)
        local t = THEMES[selected] or THEMES["Dark"]
        for k, v in pairs(t) do
            theme[k] = v
        end
        window:ApplyTheme(labelRefs)
    end)
    -- As opções de cores aqui devem setar diretamente as propriedades do tema para que ApplyTheme funcione
    configTab:AddSelectDropdown("Cor Accent", {"Padrão", "Azul", "Roxo", "Verde", "Vermelho", "Amarelo"}, function(selected)
        if selected == "Padrão" then theme.Accent = DEFAULT_THEME.Accent
        elseif selected == "Azul" then theme.Accent = Color3.fromRGB(0, 120, 255)
        elseif selected == "Roxo" then theme.Accent = Color3.fromRGB(120, 0, 255)
        elseif selected == "Verde" then theme.Accent = Color3.fromRGB(0, 255, 120)
        elseif selected == "Vermelho" then theme.Accent = Color3.fromRGB(255, 50, 50)
        elseif selected == "Amarelo" then theme.Accent = Color3.fromRGB(250, 220, 40) end
        window:ApplyTheme(labelRefs)
    end)
    configTab:AddSelectDropdown("Cor Texto", {"Padrão", "Branco", "Azul", "Amarelo", "Roxo", "Preto"}, function(selected)
        if selected == "Padrão" then theme.LabelText = DEFAULT_THEME.LabelText
        elseif selected == "Branco" then theme.LabelText = Color3.fromRGB(255, 255, 255)
        elseif selected == "Azul" then theme.LabelText = Color3.fromRGB(60, 180, 255)
        elseif selected == "Amarelo" then theme.LabelText = Color3.fromRGB(240, 220, 60)
        elseif selected == "Roxo" then theme.LabelText = Color3.fromRGB(180, 60, 255)
        elseif selected == "Preto" then theme.LabelText = Color3.fromRGB(0, 0, 0) end
        theme.Text = theme.LabelText -- Geralmente Text e LabelText são a mesma cor para o texto
        window:ApplyTheme(labelRefs)
    end)
    configTab:AddSelectDropdown("Fonte", {"Gotham", "GothamBold", "GothamSemibold", "Arial", "SourceSans", "Roboto"}, function(selected)
        theme.Font = selected
        window:ApplyTheme(labelRefs)
    end)
    configTab:AddSlider("Radius", 0, 18, theme.CornerRadius.Offset, function(v)
        theme.CornerRadius = UDim.new(0, v)
        theme.SmallCornerRadius = UDim.new(0, math.max(0, v - 2))
        window:ApplyTheme(labelRefs)
    end)
    configTab:AddSlider("Opacidade", 30, 100, math.floor((theme.Opacity or 1) * 100), function(v)
        theme.Opacity = v / 100
        setMenuOpacity(window, theme.Opacity)
    end)
    configTab:AddSelectDropdown("Tamanho Menu", {"Pequeno", "Médio", "Grande", "Personalizado"}, function(selected)
        if selected == "Pequeno" then
            MainFrame.Size = UDim2.new(0, 360, 0, 220)
        elseif selected == "Médio" then
            MainFrame.Size = UDim2.new(0, 540, 0, 360)
        elseif selected == "Grande" then
            MainFrame.Size = UDim2.new(0, 700, 0, 520)
        end
    end)
    configTab:AddButton("Salvar Config", function()
        saveConfig(window, controls, name)
    end)
    configTab:AddButton("Carregar Config", function()
        loadConfig(window, controls, name, labelRefs)
    end)
    configTab:AddButton("Resetar Tema", function()
        for k, v in pairs(DEFAULT_THEME) do
            theme[k] = v
        end
        window:ApplyTheme(labelRefs)
    end)

    -- Inicialização de loading e carregamento de config
    coroutine.wrap(function()
        local loadingStart = tick()
        task.wait(0.1) -- Pequena espera para garantir que a UI de loading seja renderizada

        loadConfig(window, controls, name, labelRefs) -- Carrega a configuração antes de esconder a tela de loading

        -- Garante que a tela de loading fique visível por pelo menos 5 segundos
        local elapsed = tick() - loadingStart
        if elapsed < 5 then
            task.wait(5 - elapsed)
        end

        animDots = false -- Para a animação de pontinhos
        if rotationTween and rotationTween.PlaybackState == Enum.PlaybackState.Playing then
             rotationTween:Stop()
        end
        
        loadingGui.Enabled = false
        loadingGui:Destroy() -- Destrói a tela de loading após o uso

        ScreenGui.Enabled = true -- Habilita o menu principal
        if firstTabName ~= nil then
            -- Ativa a primeira aba por padrão
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
