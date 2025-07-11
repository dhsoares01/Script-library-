--[[
    Customizable UI Library for Roblox with Config Tab
    Features:
    - Multiple themes (Dark, Dark Extra, Dark Opacity, White)
    - Menu opacity adjustment
    - Font style selection
    - Config tab with "Menu Save" layout (dropdown, save/load/reset/clear buttons)
    - Load/Save system for menu state (settings and functions)
    - Designed for use via loadstring, e.g. on Delta Executor
    - All customization within a "Config" tab
    - No dependencies outside Roblox APIs

    Usage:
        Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/USUARIO/REPO/main/Library.lua"))()
        local win = Library:CreateWindow("Meu Menu")
        local configTab = win:CreateTab("Config", "⚙️")
        -- etc...
]]

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

--= THEME DEFINITIONS =--
local themes = {
    ["Dark"] = {
        Background = Color3.fromRGB(30, 30, 30),
        TabBackground = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(60, 60, 60),
        ScrollViewBackground = Color3.fromRGB(20, 20, 20),
        ButtonBackground = Color3.fromRGB(50, 50, 50),
        Warning = Color3.fromRGB(255, 60, 60),
    },
    ["Dark Extra"] = {
        Background = Color3.fromRGB(16,16,18),
        TabBackground = Color3.fromRGB(20,22,28),
        Accent = Color3.fromRGB(120, 0, 255),
        Text = Color3.fromRGB(225, 225, 255),
        Stroke = Color3.fromRGB(35, 17, 44),
        ScrollViewBackground = Color3.fromRGB(12, 12, 18),
        ButtonBackground = Color3.fromRGB(38, 38, 52),
        Warning = Color3.fromRGB(220, 40, 180),
    },
    ["Dark Opacity"] = {
        Background = Color3.fromRGB(30,30,30),
        TabBackground = Color3.fromRGB(40,40,40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255,255,255),
        Stroke = Color3.fromRGB(60,60,60),
        ScrollViewBackground = Color3.fromRGB(20,20,20),
        ButtonBackground = Color3.fromRGB(50,50,50),
        Warning = Color3.fromRGB(255,60,60),
        Opacity = 0.7, -- Custom for this theme
    },
    ["White"] = {
        Background = Color3.fromRGB(240, 240, 240),
        TabBackground = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(30, 30, 30),
        Stroke = Color3.fromRGB(200, 200, 200),
        ScrollViewBackground = Color3.fromRGB(245, 245, 245),
        ButtonBackground = Color3.fromRGB(220, 220, 220),
        Warning = Color3.fromRGB(255, 60, 60),
    }
}

local default_theme = "Dark"
local theme = table.clone(themes[default_theme])
theme.CornerRadius = UDim.new(0, 8)
theme.SmallCornerRadius = UDim.new(0, 6)
theme.Padding = 8
theme.TabButtonHeight = 34
theme.ControlHeight = 32
theme.ControlPadding = 6
theme.Opacity = 1

local fonts = {
    ["Gotham"] = Enum.Font.Gotham,
    ["GothamBold"] = Enum.Font.GothamBold,
    ["GothamMedium"] = Enum.Font.GothamMedium,
    ["SourceSans"] = Enum.Font.SourceSans,
    ["Arial"] = Enum.Font.Arial,
    ["Code"] = Enum.Font.Code,
    ["FredokaOne"] = Enum.Font.FredokaOne,
    ["Ubuntu"] = Enum.Font.Ubuntu,
    ["Roboto"] = Enum.Font.Roboto,
    ["SciFi"] = Enum.Font.SciFi,
}

local default_font = "Gotham"

--= UTILITIES =--
local function applyThemeToFrame(frame, th)
    frame.BackgroundColor3 = th.Background
    if frame:IsA("Frame") then
        frame.BackgroundTransparency = 1 - (th.Opacity or 1)
    end
end

local function setGlobalTheme(thname, mainframes)
    local th = themes[thname]
    if th then
        -- Copy theme values into global theme table
        for k, v in pairs(th) do
            theme[k] = v
        end
        theme.Opacity = th.Opacity or 1
        -- Refresh all active frames
        for _, mf in ipairs(mainframes) do
            mf.BackgroundColor3 = theme.Background
            mf.BackgroundTransparency = 1 - theme.Opacity
        end
    end
end

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
    label.TextColor3 = textColor or theme.Text
    label.Font = font or fonts[default_font]
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
    button.Font = font or fonts[default_font]
    button.TextSize = textSize or 16
    button.AutoButtonColor = false
    button.BackgroundTransparency = 1 - theme.Opacity
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

--= CORE WINDOW CREATION =--
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
    MainFrame.BackgroundTransparency = 1 - (theme.Opacity or 1)
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

    -- Header
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    HeaderFrame.BackgroundColor3 = theme.TabBackground
    HeaderFrame.BackgroundTransparency = 1 - theme.Opacity
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.Active = true

    createCorner(HeaderFrame, theme.CornerRadius)

    -- Drag logic
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
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

    -- Title & minimize
    local Title = createTextLabel(HeaderFrame, name or "Menu", 20, theme.Text, fonts.GothamBold, Enum.TextXAlignment.Left)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, theme.Padding, 0, 0)
    Title.TextYAlignment = Enum.TextYAlignment.Center

    local BtnMinimize = createTextButton(HeaderFrame, "–", nil, theme.TabBackground, theme.Text, fonts.GothamBold, 24)
    BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
    BtnMinimize.Position = UDim2.new(1, -theme.Padding - 30, 0, 5)
    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Warning }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.TabBackground }):Play()
    end)

    -- Tab/sidebar
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.BackgroundColor3 = theme.TabBackground
    TabContainer.BackgroundTransparency = 1 - theme.Opacity
    TabContainer.ClipsDescendants = true
    createCorner(TabContainer, theme.CornerRadius)
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, theme.Padding)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    createPadding(TabContainer, theme.Padding / 2)

    -- Pages
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.Size = UDim2.new(1, -130, 1, -40)
    PageContainer.BackgroundColor3 = theme.ScrollViewBackground
    PageContainer.BackgroundTransparency = 1 - theme.Opacity
    PageContainer.ClipsDescendants = true
    createCorner(PageContainer, theme.CornerRadius)

    -- Minimize logic
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

    -- Resizable
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true

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

    -- TABS & PAGES
    local pages, firstTabName, activeTabButton = {}, nil, nil
    local mainframes = {MainFrame, HeaderFrame, TabContainer, PageContainer}

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

    function window:CreateTab(tabName, icon)
        if not firstTabName then firstTabName = tabName end
        local Button = createTextButton(TabContainer, "  " .. tabName, nil, theme.ButtonBackground, theme.Text, fonts[default_font], 16)
        Button.Size = UDim2.new(1, -theme.Padding, 0, theme.TabButtonHeight)
        Button.TextXAlignment = Enum.TextXAlignment.Left
        if icon then
            local iconLabel = createTextLabel(Button, icon, 18, theme.Accent, fonts.GothamBold, Enum.TextXAlignment.Center)
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
        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName, Button)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = createTextLabel(Page, text, 16, theme.Text, fonts[default_font], Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 24)
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = createTextButton(Page, text, callback, theme.Accent, Color3.new(1,1,1), fonts.GothamMedium, 16)
            return Btn
        end

        function tab:AddSelectDropdown(title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
            container.BackgroundColor3 = theme.ButtonBackground
            createCorner(container, theme.SmallCornerRadius)
            local header = createTextButton(container, "▸ " .. title, nil, theme.ButtonBackground, theme.Text, fonts[default_font], 16)
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
                local btn = createTextButton(dropdownFrame, name, nil, theme.ButtonBackground, theme.Text, fonts[default_font], 14)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then callback(selectedItem) end
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
            return {
                Set = function(_, item)
                    if table.find(items, item) then
                        selectedItem = item
                        updateHeaderText()
                        if callback then callback(selectedItem) end
                    end
                end,
                Get = function() return selectedItem end
            }
        end

        function tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 40)
            SliderFrame.BackgroundTransparency = 1
            local Label = createTextLabel(SliderFrame, text .. ": " .. tostring(default), 14, theme.Text, fonts[default_font], Enum.TextXAlignment.Left)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
            SliderBar.BackgroundColor3 = theme.ButtonBackground
            createCorner(SliderBar, theme.SmallCornerRadius)
            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            createCorner(SliderFill, theme.SmallCornerRadius)
            local draggingSlider = false
            local function updateSliderValue(input)
                local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
                local percent = relativeX / SliderBar.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percent)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                Label.Text = text .. ": " .. tostring(value)
                if callback then callback(value) end
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
                    if callback then callback(value) end
                end,
                Get = function(self)
                    local size = SliderFill.Size.X.Scale
                    return math.floor(min + (max - min) * size)
                end,
                _instance = SliderFrame
            }
        end

        return tab
    end

    -- AUTOSELECT FIRST TAB
    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName then
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and string.find(btn.Text, firstTabName) then
                    switchToPage(firstTabName, btn)
                    break
                end
            end
        end
    end)()

    --= CONFIG TAB (personalização completa) =--
    function window:CreateConfigTab(tabName)
        tabName = tabName or "Config"
        local tab = self:CreateTab(tabName, "⚙️")

        tab:AddLabel("Personalização do Menu:")

        -- Theme selector
        local themeSelector = tab:AddSelectDropdown("Tema", {"Dark", "Dark Extra", "Dark Opacity", "White"}, function(selected)
            setGlobalTheme(selected, mainframes)
            -- Opacity (slider) update if "Dark Opacity"
            if selected == "Dark Opacity" then
                opacitySlider:Set(theme.Opacity * 100)
            else
                opacitySlider:Set((theme.Opacity or 1) * 100)
            end
        end)
        themeSelector:Set(default_theme)

        -- Opacity slider
        local opacitySlider = tab:AddSlider("Opacidade do Menu (%)", 30, 100, (theme.Opacity or 1) * 100, function(val)
            local v = math.clamp(val / 100, 0.3, 1)
            theme.Opacity = v
            for _, f in ipairs(mainframes) do
                if f:IsA("Frame") then
                    f.BackgroundTransparency = 1 - v
                end
            end
        end)
        opacitySlider:Set(theme.Opacity * 100)

        -- Font selector
        local fontNames = {}
        for k in pairs(fonts) do table.insert(fontNames, k) end
        table.sort(fontNames)
        local fontSelector = tab:AddSelectDropdown("Fonte", fontNames, function(selected)
            default_font = selected
            for _, f in ipairs(mainframes) do
                for _, child in ipairs(f:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.Font = fonts[selected]
                    end
                end
            end
        end)
        fontSelector:Set(default_font)

        -- Separator
        tab:AddLabel("Menu Save:")

        -- Load/save system
        local loads = {}
        local currentLoad = nil
        local loadsDropdown
        local function refreshLoadsDropdown()
            local names = {}
            for name in pairs(loads) do table.insert(names, name) end
            loadsDropdown:Set(nil)
            loadsDropdown.Items = names
        end

        -- Dropdown
        loadsDropdown = tab:AddSelectDropdown("Loads Salvos", {}, function(selected)
            currentLoad = selected
        end)

        -- Save Load
        tab:AddButton("Salvar Load", function()
            local name = "Load_" .. tostring(#loads + 1)
            local config = {
                Theme = themeSelector:Get(),
                Opacity = opacitySlider:Get(),
                Font = fontSelector:Get(),
            }
            loads[name] = config
            refreshLoadsDropdown()
            loadsDropdown:Set(name)
        end)

        -- Carregar Load
        tab:AddButton("Carregar Load", function()
            if currentLoad and loads[currentLoad] then
                local conf = loads[currentLoad]
                themeSelector:Set(conf.Theme)
                opacitySlider:Set(conf.Opacity)
                fontSelector:Set(conf.Font)
            end
        end)

        -- Resetar Load
        tab:AddButton("Resetar Load", function()
            themeSelector:Set(default_theme)
            opacitySlider:Set(100)
            fontSelector:Set("Gotham")
        end)

        -- Limpar Lista
        tab:AddButton("Limpar Lista de Loads", function()
            loads = {}
            refreshLoadsDropdown()
        end)

        -- Store loads in window for programmatic access if needed
        window._loads = loads
        window._loadDropdown = loadsDropdown

        return tab
    end

    return window
end

return Library
