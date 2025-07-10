local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Temas prontos
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
        CornerRadius = UDim.new(0, 8),
        SmallCornerRadius = UDim.new(0, 6),
        Padding = 8,
        TabButtonHeight = 34,
        ControlHeight = 32,
        ControlPadding = 6,
        Opacity = 1
    },
    ["White"] = {
        Background = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(50, 50, 50),
        LabelText = Color3.fromRGB(30, 30, 30),
        Stroke = Color3.fromRGB(180, 180, 180),
        ScrollViewBackground = Color3.fromRGB(250, 250, 250),
        ButtonBackground = Color3.fromRGB(200, 200, 200),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 8),
        SmallCornerRadius = UDim.new(0, 6),
        Padding = 8,
        TabButtonHeight = 34,
        ControlHeight = 32,
        ControlPadding = 6,
        Opacity = 1
    },
    ["Dark Forte"] = {
        Background = Color3.fromRGB(18, 18, 18),
        TabBackground = Color3.fromRGB(24, 24, 24),
        Accent = Color3.fromRGB(0, 200, 255),
        Text = Color3.fromRGB(240, 240, 240),
        LabelText = Color3.fromRGB(180, 220, 255),
        Stroke = Color3.fromRGB(80, 80, 80),
        ScrollViewBackground = Color3.fromRGB(14, 14, 14),
        ButtonBackground = Color3.fromRGB(40, 40, 40),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 8),
        SmallCornerRadius = UDim.new(0, 6),
        Padding = 8,
        TabButtonHeight = 34,
        ControlHeight = 32,
        ControlPadding = 6,
        Opacity = 1
    },
    ["White and Dark"] = {
        Background = Color3.fromRGB(245, 245, 245),
        TabBackground = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(120, 0, 255),
        Text = Color3.fromRGB(30, 30, 30),
        LabelText = Color3.fromRGB(50, 50, 250),
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(240, 240, 240),
        ButtonBackground = Color3.fromRGB(180, 180, 180),
        Warning = Color3.fromRGB(255, 60, 60),
        CornerRadius = UDim.new(0, 8),
        SmallCornerRadius = UDim.new(0, 6),
        Padding = 8,
        TabButtonHeight = 34,
        ControlHeight = 32,
        ControlPadding = 6,
        Opacity = 1
    }
}

local DEFAULT_THEME = table.clone(THEMES["Dark"])
local theme = table.clone(DEFAULT_THEME)

-- Funções auxiliares
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
    label.TextColor3 = textColor or theme.LabelText or theme.Text
    label.Font = font or Enum.Font.Gotham
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
    button.Font = font or Enum.Font.GothamMedium
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

-- Configuração de salvar/carregar
local function getConfigPath(windowName)
    windowName = windowName or "CustomUILib"
    local configKey = "MenuConfig_"..windowName
    if writefile and readfile then
        return configKey..".json"
    end
    return nil
end

local function saveConfig(window, controls, windowName)
    local config = {
        Theme = {},
        Controls = {},
        Opacity = theme.Opacity,
        Size = window._mainFrame and {X=window._mainFrame.Size.X.Offset, Y=window._mainFrame.Size.Y.Offset} or {X=520, Y=340}
    }
    for k,v in pairs(theme) do
        if typeof(v) == "Color3" then
            config.Theme[k] = {v.R, v.G, v.B}
        else
            config.Theme[k] = v
        end
    end
    for key, ctrl in pairs(controls) do
        if ctrl.Get then
            config.Controls[key] = ctrl:Get()
        end
    end
    local json = HttpService:JSONEncode(config)
    local path = getConfigPath(windowName)
    if path then
        writefile(path, json)
    else
        setclipboard(json)
    end
end

local function loadConfig(window, controls, windowName, labelRefs)
    local config = nil
    local path = getConfigPath(windowName)
    if path and pcall(function() return readfile(path) end) then
        config = HttpService:JSONDecode(readfile(path))
    else
        local ok, clipboard = pcall(function() return getclipboard() end)
        if ok and clipboard then
            local decoded
            pcall(function() decoded = HttpService:JSONDecode(clipboard) end)
            if decoded and decoded.Theme then
                config = decoded
            end
        end
    end
    if not config then return end

    for k, v in pairs(config.Theme or {}) do
        if typeof(theme[k]) == "Color3" and typeof(v) == "table" then
            theme[k] = Color3.new(v[1], v[2], v[3])
        else
            theme[k] = v
        end
    end
    theme.Opacity = config.Opacity or theme.Opacity
    if window._mainFrame then
        window._mainFrame.BackgroundTransparency = 1-theme.Opacity
        if config.Size and config.Size.X and config.Size.Y then
            window._mainFrame.Size = UDim2.new(0, config.Size.X, 0, config.Size.Y)
        end
    end
    for key, value in pairs(config.Controls or {}) do
        if controls[key] and controls[key].Set then
            controls[key]:Set(value)
        end
    end
    if window.ApplyTheme then
        window:ApplyTheme(labelRefs)
    end
end

function Library:CreateWindow(name)
    local controls = {}
    local labelRefs = {} -- Referência dos labels para troca de cor de texto dinâmica

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name or "CustomUILib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BackgroundTransparency = 1-theme.Opacity
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = theme.TabBackground
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

    local Title = createTextLabel(HeaderFrame, name or "Menu", 20, theme.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, theme.Padding, 0, 0)
    Title.TextYAlignment = Enum.TextYAlignment.Center

    local BtnMinimize = createTextButton(HeaderFrame, "–", nil, theme.TabBackground, theme.Text, Enum.Font.GothamBold, 24)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -theme.Padding - 30, 0, (HeaderFrame.Size.Y.Offset - 30) / 2)
    createCorner(BtnMinimize, theme.SmallCornerRadius)
    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Warning }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
    end)

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.BackgroundColor3 = theme.TabBackground
    TabContainer.ClipsDescendants = true
    local TabCorner = createCorner(TabContainer, theme.CornerRadius)
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, theme.Padding)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    createPadding(TabContainer, theme.Padding / 2)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = theme.ScrollViewBackground
    PageContainer.ClipsDescendants = true
    createCorner(PageContainer, theme.CornerRadius)

    local pages = {}
    local firstTabName = nil
    local activeTabButton = nil
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 150, 0, 40) }):Play()
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
            TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = theme.ButtonBackground }):Play()
        end
        activeTabButton = button
        TweenService:Create(activeTabButton, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
    end

    local window = {}
    window._mainFrame = MainFrame

    function window:ApplyTheme(labelRefs)
        MainFrame.BackgroundColor3 = theme.Background
        MainFrame.BackgroundTransparency = 1-theme.Opacity
        HeaderFrame.BackgroundColor3 = theme.TabBackground
        TabContainer.BackgroundColor3 = theme.TabBackground
        PageContainer.BackgroundColor3 = theme.ScrollViewBackground
        UIStroke.Color = theme.Stroke
        Title.TextColor3 = theme.Text
        BtnMinimize.TextColor3 = theme.Text

        -- aplica cor só nos labels do menu:
        for _, ref in ipairs(labelRefs) do
            if ref and ref:IsA("TextLabel") then
                ref.TextColor3 = theme.LabelText or theme.Text
            end
        end
    end

    do
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

        local Button = createTextButton(TabContainer, "  " .. tabName, nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 16)
        Button.Size = UDim2.new(1, -theme.Padding, 0, theme.TabButtonHeight)
        Button.TextXAlignment = Enum.TextXAlignment.Left

        if icon then
            local iconLabel = createTextLabel(Button, icon, 18, theme.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
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
        Page.ScrollBarThickness = 6
        Page.BackgroundColor3 = theme.ScrollViewBackground
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

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = createTextLabel(Page, text, 16, theme.LabelText or theme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 24)
            table.insert(labelRefs, Label)
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.Accent, Color3.new(1,1,1), Enum.Font.GothamMedium, 16)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = createTextButton(Page, text, nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 16)
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            ToggleBtn.TextScaled = false
            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.ButtonBackground }):Play()
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
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60,60,60) }):Play()
            end)
            ToggleBtn.MouseLeave:Connect(function()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.ButtonBackground }):Play()
            end)
            local id = "Toggle_"..text
            controls[id] = {
                Set = function(self, value) state = value; updateToggleVisual(); end,
                Get = function(self) return state end
            }
            return controls[id]
        end

        function tab:AddDropdownButtonOnOff(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
            container.BackgroundColor3 = theme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, theme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (theme.ControlHeight + theme.ControlPadding))
            dropdownFrame.BackgroundColor3 = theme.TabBackground
            dropdownFrame.Visible = false
            createCorner(dropdownFrame, theme.SmallCornerRadius)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, theme.ControlPadding)
            createPadding(dropdownFrame, theme.ControlPadding / 2)

            local states = {}
            local itemButtons = {}

            for _, name in ipairs(items) do
                states[name] = false
                local btn = createTextButton(dropdownFrame, name .. ": OFF", nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.ButtonBackground }):Play()
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
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or Color3.fromRGB(60,60,60) }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.ButtonBackground }):Play()
                end)
            end

            local expanded = false
            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                header.Text = (expanded and "▾ " or "▸ ") .. title
            end)

            local id = "DropdownOnOff_"..title
            controls[id] = {
                Set = function(_, item, value)
                    if states[item] ~= nil then
                        states[item] = value
                        if itemButtons[item] then
                            itemButtons[item].BackgroundColor3 = value and theme.Accent or theme.ButtonBackground
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
            return controls[id]
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
            container.BackgroundColor3 = theme.ButtonBackground
            container.BorderSizePixel = 0
            createCorner(container, theme.SmallCornerRadius)

            local header = createTextButton(container, "▸ " .. title, nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 16)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.BackgroundTransparency = 1

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * (theme.ControlHeight + theme.ControlPadding))
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
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end

            for _, name in ipairs(items) do
                local btn = createTextButton(dropdownFrame, name, nil, theme.ButtonBackground, theme.Text, Enum.Font.Gotham, 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then
                        callback(selectedItem)
                    end
                end)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.ButtonBackground }):Play()
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
                updateHeaderText()
            end)

            local id = "Dropdown_"..title
            controls[id] = {
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
            return controls[id]
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 40)
            SliderFrame.BackgroundTransparency = 1

            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), 14, theme.LabelText or theme.Text, Enum.Font.Gotham, Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            table.insert(labelRefs, Label)

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
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

            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)
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

            local id = "Slider_"..text
            controls[id] = {
                Set = function(self, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then
                        callback(value)
                    end
                end,
                Get = function(self)
                    local size = SliderFill.Size.X.Scale
                    return math.floor(min + (max - min) * size)
                end
            }
            return controls[id]
        end

        return tab
    end

    -- Aba de Configuração
    local configTab = window:CreateTab("Config")
    configTab:AddLabel("Customização do Menu:")

    -- Tema pronto
    configTab:AddSelectDropdown("Tema", {"Dark","White","Dark Forte","White and Dark"}, function(selected)
        local t = THEMES[selected] or THEMES["Dark"]
        for k,v in pairs(t) do
            theme[k] = v
        end
        window:ApplyTheme(labelRefs)
    end)

    -- Cor Accent
    configTab:AddDropdownButtonOnOff("Cor Accent", {"Azul","Roxo","Verde","Vermelho"}, function(states)
        if states["Azul"] then theme.Accent = Color3.fromRGB(0,120,255)
        elseif states["Roxo"] then theme.Accent = Color3.fromRGB(120,0,255)
        elseif states["Verde"] then theme.Accent = Color3.fromRGB(0,255,120)
        elseif states["Vermelho"] then theme.Accent = Color3.fromRGB(255,50,50) end
        window:ApplyTheme(labelRefs)
    end)

    -- Cor do texto dos labels
    configTab:AddDropdownButtonOnOff("Cor Text", {"Branco","Azul","Amarelo","Roxo"}, function(states)
        if states["Branco"] then theme.LabelText = Color3.fromRGB(255,255,255)
        elseif states["Azul"] then theme.LabelText = Color3.fromRGB(60,180,255)
        elseif states["Amarelo"] then theme.LabelText = Color3.fromRGB(240,220,60)
        elseif states["Roxo"] then theme.LabelText = Color3.fromRGB(180,60,255) end
        window:ApplyTheme(labelRefs)
    end)

    -- Opacidade
    configTab:AddSlider("Opacidade", 30, 100, math.floor((theme.Opacity or 1)*100), function(v)
        theme.Opacity = v/100
        MainFrame.BackgroundTransparency = 1-theme.Opacity
    end)

    configTab:AddButton("Salvar Config", function()
        saveConfig(window, controls, name)
    end)
    configTab:AddButton("Carregar Config", function()
        loadConfig(window, controls, name, labelRefs)
    end)
    configTab:AddButton("Resetar Tema", function()
        for k,v in pairs(DEFAULT_THEME) do
            theme[k] = v
        end
        window:ApplyTheme(labelRefs)
    end)

    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
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
