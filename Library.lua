-- Simple GUI Library for Roblox (Delta executor compatible)
local Library = {}
Library.__index = Library

function Library:Create(title)
    assert(type(title) == "string", "title must be a string")

    local self = setmetatable({}, Library)
    self.closed = false
    self.minimized = false
    self.tabs = {}
    self.currentTab = nil

    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleLibraryGui"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    self.gui = gui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.3, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    self.frame = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1,0,0,30)
    topBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    topBar.Parent = frame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0,8)
    topCorner.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(230,230,230)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = topBar

    local btnMinimize = Instance.new("TextButton")
    btnMinimize.Name = "Minimize"
    btnMinimize.Size = UDim2.new(0,30,1,0)
    btnMinimize.Position = UDim2.new(1, -60, 0, 0)
    btnMinimize.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btnMinimize.Text = "–"
    btnMinimize.Font = Enum.Font.GothamBold
    btnMinimize.TextSize = 20
    btnMinimize.TextColor3 = Color3.fromRGB(200,200,200)
    btnMinimize.Parent = topBar

    local btnMinCorner = Instance.new("UICorner")
    btnMinCorner.CornerRadius = UDim.new(0,4)
    btnMinCorner.Parent = btnMinimize

    local btnClose = Instance.new("TextButton")
    btnClose.Name = "Close"
    btnClose.Size = UDim2.new(0,30,1,0)
    btnClose.Position = UDim2.new(1, -30, 0, 0)
    btnClose.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btnClose.Text = "×"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 20
    btnClose.TextColor3 = Color3.fromRGB(255,100,100)
    btnClose.Parent = topBar

    local btnCloseCorner = Instance.new("UICorner")
    btnCloseCorner.CornerRadius = UDim.new(0,4)
    btnCloseCorner.Parent = btnClose

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.Size = UDim2.new(1, 0, 0, 30)
    tabsFrame.Position = UDim2.new(0,0,0,30)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = frame
    self.tabsFrame = tabsFrame

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.Parent = tabsFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Position = UDim2.new(0,0,0,60)
    contentFrame.Size = UDim2.new(1,0,1,-60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = frame
    self.contentFrame = contentFrame

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 60, 0, 30)
    floatBtn.Position = UDim2.new(0, 10, 0, 50)
    floatBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    floatBtn.TextColor3 = Color3.fromRGB(230,230,230)
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 18
    floatBtn.Text = title
    floatBtn.Visible = false
    floatBtn.Parent = gui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(0, 8)
    floatCorner.Parent = floatBtn

    btnMinimize.MouseButton1Click:Connect(function()
        if self.minimized then return end
        self.minimized = true
        frame.Visible = false
        floatBtn.Visible = true
    end)

    floatBtn.MouseButton1Click:Connect(function()
        if not self.minimized then return end
        self.minimized = false
        frame.Visible = true
        floatBtn.Visible = false
    end)

    btnClose.MouseButton1Click:Connect(function()
        self:Close()
    end)

    return self
end

function Library:Close()
    if self.closed then return end
    self.closed = true
    if self.gui then
        self.gui:Destroy()
    end
    self.tabs = nil
    self.elements = nil
end

function Library:CreateTab(name)
    assert(type(name) == "string", "Tab name must be string")
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton"
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tabButton.TextColor3 = Color3.fromRGB(230,230,230)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 16
    tabButton.Text = name
    tabButton.Parent = self.tabsFrame

    local tabContent = Instance.new("Frame")
    tabContent.Name = name .. "_Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = self.contentFrame

    tabButton.MouseButton1Click:Connect(function()
        self:SetTab(name)
    end)

    self.tabs[name] = {
        button = tabButton,
        content = tabContent,
        elements = {}
    }

    if not self.currentTab then
        self:SetTab(name)
    end

    return tabContent
end

function Library:SetTab(name)
    assert(self.tabs[name], "Tab doesn't exist: "..name)
    for tabName, tab in pairs(self.tabs) do
        local active = tabName == name
        tab.content.Visible = active
        tab.button.BackgroundColor3 = active and Color3.fromRGB(70,70,70) or Color3.fromRGB(50,50,50)
    end
    self.currentTab = name
end

function Library:AddToggle(tabName, label, default, callback)
    assert(self.tabs[tabName], "Tab doesn't exist: "..tabName)
    local tab = self.tabs[tabName]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #tab.elements + 1
    container.Parent = tab.content

    local labelLabel = Instance.new("TextLabel")
    labelLabel.Size = UDim2.new(1, -50, 1, 0)
    labelLabel.BackgroundTransparency = 1
    labelLabel.Text = label
    labelLabel.TextColor3 = Color3.fromRGB(230,230,230)
    labelLabel.TextXAlignment = Enum.TextXAlignment.Left
    labelLabel.Font = Enum.Font.Gotham
    labelLabel.TextSize = 16
    labelLabel.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -45, 0, 5)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 80)
    toggleBtn.Text = ""
    toggleBtn.Parent = container

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn

    local toggled = default

    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 80)
        if callback then callback(toggled) end
    end)

    table.insert(tab.elements, container)
    return container
end

function Library:AddSlider(tabName, label, min, max, default, callback)
    assert(self.tabs[tabName], "Tab doesn't exist: "..tabName)
    local tab = self.tabs[tabName]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #tab.elements + 1
    container.Parent = tab.content

    local labelLabel = Instance.new("TextLabel")
    labelLabel.Size = UDim2.new(1, -10, 0, 20)
    labelLabel.BackgroundTransparency = 1
    labelLabel.Text = label
    labelLabel.TextColor3 = Color3.fromRGB(230,230,230)
    labelLabel.TextXAlignment = Enum.TextXAlignment.Left
    labelLabel.Font = Enum.Font.Gotham
    labelLabel.TextSize = 16
    labelLabel.Parent = container

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 20)
    sliderFrame.Position = UDim2.new(0, 5, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
    sliderFrame.Parent = container

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderFrame

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    fillBar.Parent = sliderFrame

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fillBar

    local dragging = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = sliderFrame.AbsolutePosition.X
            local sliderWidth = sliderFrame.AbsoluteSize.X
            local relativePos = math.clamp(mouseX - sliderX, 0, sliderWidth)
            local value = min + (relativePos / sliderWidth) * (max - min)
            fillBar.Size = UDim2.new(relativePos / sliderWidth, 0, 1, 0)
            if callback then callback(value) end
        end
    end)

    table.insert(tab.elements, container)
    return container
end

function Library:AddDropdown(tabName, label, options, defaultIndex, callback)
    assert(self.tabs[tabName], "Tab doesn't exist: "..tabName)
    local tab = self.tabs[tabName]
    assert(type(options) == "table" and #options > 0, "Options must be a non-empty table")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #tab.elements + 1
    container.Parent = tab.content

    local labelLabel = Instance.new("TextLabel")
    labelLabel.Size = UDim2.new(1, -10, 0, 20)
    labelLabel.BackgroundTransparency = 1
    labelLabel.Text = label
    labelLabel.TextColor3 = Color3.fromRGB(230,230,230)
    labelLabel.TextXAlignment = Enum.TextXAlignment.Left
    labelLabel.Font = Enum.Font.Gotham
    labelLabel.TextSize = 16
    labelLabel.Parent = container

    local dropButton = Instance.new("TextButton")
    dropButton.Size = UDim2.new(1, -10, 0, 20)
    dropButton.Position = UDim2.new(0, 5, 0, 20)
    dropButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
    dropButton.TextColor3 = Color3.fromRGB(230,230,230)
    dropButton.Font = Enum.Font.Gotham
    dropButton.TextSize = 16
    dropButton.Text = options[defaultIndex or 1]
    dropButton.Parent = container

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 5)
    dropCorner.Parent = dropButton

    local listOpen = false
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -10, 0, #options * 25)
    listFrame.Position = UDim2.new(0, 5, 0, 40)
    listFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
    listFrame.Visible = false
    listFrame.Parent = container

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = listFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = listFrame

    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 25)
        optionBtn.BackgroundTransparency = 1
        optionBtn.Text = option
        optionBtn.TextColor3 = Color3.fromRGB(230,230,230)
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 16
        optionBtn.Parent = listFrame

        optionBtn.MouseEnter:Connect(function()
            optionBtn.BackgroundTransparency = 0.5
            optionBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
        end)
        optionBtn.MouseLeave:Connect(function()
            optionBtn.BackgroundTransparency = 1
        end)

        optionBtn.MouseButton1Click:Connect(function()
            dropButton.Text = option
            if callback then callback(option, i) end
            listFrame.Visible = false
            listOpen = false
        end)
    end

    dropButton.MouseButton1Click:Connect(function()
        listOpen = not listOpen
        listFrame.Visible = listOpen
    end)

    table.insert(tab.elements, container)
    return container
end

function Library:AddButton(tabName, label, callback)
    assert(self.tabs[tabName], "Tab doesn't exist: "..tabName)
    local tab = self.tabs[tabName]

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(50,50,50)
    button.TextColor3 = Color3.fromRGB(230,230,230)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = label
    button.LayoutOrder = #tab.elements + 1
    button.Parent = tab.content

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    table.insert(tab.elements, button)
    return button
end

return Library
