--[[
  Design e layout aprimorados para biblioteca de GUI Roblox.
  - Inspiração: Fluent, Neumorphism, linhas mais suaves e responsividade.
  - Cores mais suaves, sombras, hover, animações mais modernas.
  - Separação visual clara entre abas, contornos, efeitos de luz.
  - Foco em acessibilidade e ajuste visual para diferentes resoluções.
--]]

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(26, 27, 30),
    Tab = Color3.fromRGB(34, 36, 40),
    Accent = Color3.fromRGB(0, 162, 255),
    Accent2 = Color3.fromRGB(0, 210, 255),
    Text = Color3.fromRGB(230, 235, 245),
    Stroke = Color3.fromRGB(50, 50, 60),
    Shadow = Color3.fromRGB(10, 10, 15),
    ScrollViewBackground = Color3.fromRGB(20, 22, 25),
    Hover = Color3.fromRGB(22, 160, 255),
}

local function createShadow(parent, radius, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, radius * 2, 1, radius * 2)
    shadow.Position = UDim2.new(0, -radius, 0, -radius)
    shadow.ImageColor3 = theme.Shadow
    shadow.ImageTransparency = transparency or 0.75
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
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
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 10
    MainFrame.Parent = ScreenGui

    createShadow(MainFrame, 24, 0.80)

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 16)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 2

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -56, 0, 46)
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamSemibold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão minimizar
    local BtnMinimize = Instance.new("TextButton", MainFrame)
    BtnMinimize.Size = UDim2.new(0, 34, 0, 34)
    BtnMinimize.Position = UDim2.new(1, -44, 0, 6)
    BtnMinimize.BackgroundColor3 = theme.Tab
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 24
    BtnMinimize.AutoButtonColor = false
    BtnMinimize.ZIndex = 12

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", BtnMinimize)
    btnStroke.Color = theme.Stroke
    btnStroke.Thickness = 1

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Hover }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
    end)

    -- Contêiner de abas e página
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 46)
    TabContainer.Size = UDim2.new(0, 136, 1, -46)
    TabContainer.BackgroundColor3 = theme.Tab

    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 14)
    local TabStroke = Instance.new("UIStroke", TabContainer)
    TabStroke.Color = theme.Stroke
    TabStroke.Thickness = 1

    createShadow(TabContainer, 10, 0.88)

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 136, 0, 46)
    PageContainer.Size = UDim2.new(1, -136, 1, -46)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true
    local PageCorner = Instance.new("UICorner", PageContainer)
    PageCorner.CornerRadius = UDim.new(0, 12)
    local PageStroke = Instance.new("UIStroke", PageContainer)
    PageStroke.Color = theme.Stroke
    PageStroke.Thickness = 1

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)

    local pages = {}
    local firstTabName = nil
    local minimized = false

    -- Drag
    local dragging = false
    local dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local y = UserInputService:GetMouseLocation().Y - MainFrame.AbsolutePosition.Y
            if y < 46 then -- só permitir drag na barra de título
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

    -- Redimensionar menu (borda direita-inferior)
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 15
        resizeFrame.Active = true
        local corner = Instance.new("UICorner", resizeFrame)
        corner.CornerRadius = UDim.new(0, 8)

        local mouseDown = false
        local initialMousePos
        local initialFrameSize
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
                local newHeight = math.clamp(initialFrameSize.Y.Offset + delta.Y, 220, 650)
                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = false
            end
        end)
    end

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 136, 0, 46) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
            Title.Position = UDim2.new(0, 18, 0, 0)
            Title.Size = UDim2.new(1, -56, 0, 46)
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
            Title.Position = UDim2.new(0, 18, 0, 0)
            Title.Size = UDim2.new(1, -56, 0, 46)
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end
    end

    local window = {}

    function window:CreateTab(tabName, icon)
        if not firstTabName then firstTabName = tabName end

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -12, 0, 38)
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = theme.Background
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ZIndex = 11

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 10)
        local btnStroke = Instance.new("UIStroke", Button)
        btnStroke.Color = theme.Stroke
        btnStroke.Thickness = 1

        if icon then
            local iconLabel = Instance.new("TextLabel", Button)
            iconLabel.Text = icon
            iconLabel.Size = UDim2.new(0, 24, 1, 0)
            iconLabel.Position = UDim2.new(0, 8, 0, 0)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextSize = 18
            iconLabel.TextColor3 = theme.Accent2
            iconLabel.TextXAlignment = Enum.TextXAlignment.Center
            iconLabel.TextYAlignment = Enum.TextYAlignment.Center
            Button.Text = "      " .. tabName
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()
            TweenService:Create(Button, TweenInfo.new(0.2), { TextColor3 = Color3.new(1, 1, 1) }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background }):Play()
            TweenService:Create(Button, TweenInfo.new(0.2), { TextColor3 = theme.Text }):Play()
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 5
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0
        Page.ZIndex = 12

        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 12)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 14)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -8, 0, 26)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            return Label
        end

        function tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -8, 0, 34)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16
            Btn.AutoButtonColor = false

            local corner = Instance.new("UICorner", Btn)
            corner.CornerRadius = UDim.new(0, 8)
            local btnStroke = Instance.new("UIStroke", Btn)
            btnStroke.Color = theme.Accent2
            btnStroke.Thickness = 1

            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent2 }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
            end)
            Btn.MouseButton1Click:Connect(callback)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, -8, 0, 34)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.Gotham
            ToggleBtn.TextSize = 16
            ToggleBtn.AutoButtonColor = false

            local corner = Instance.new("UICorner", ToggleBtn)
            corner.CornerRadius = UDim.new(0, 8)
            local btnStroke = Instance.new("UIStroke", ToggleBtn)
            btnStroke.Color = theme.Stroke
            btnStroke.Thickness = 1

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = state and theme.Accent or theme.Tab }):Play()
                TweenService:Create(ToggleBtn, TweenInfo.new(0.15), { TextColor3 = state and Color3.new(1,1,1) or theme.Text }):Play()
            end
            updateToggleVisual()

            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggleVisual()
                if callback then
                    callback(state)
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

        -- Mantém os métodos AddDropdownButtonOnOff, AddSelectDropdown e AddSlider
        -- (mude apenas os valores visuais para seguir o novo tema)

        tab.AddDropdownButtonOnOff = function(self, title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -8, 0, 38)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0
            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, 8)
            local btnStroke = Instance.new("UIStroke", container)
            btnStroke.Color = theme.Stroke
            btnStroke.Thickness = 1

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, -8, 0, #items * 32 + 4)
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false
            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, 8)
            local btnStroke2 = Instance.new("UIStroke", dropdownFrame)
            btnStroke2.Color = theme.Stroke
            btnStroke2.Thickness = 1

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)

            local states, itemButtons = {}, {}
            for _, name in ipairs(items) do
                states[name] = false
                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -8, 0, 28)
                btn.Position = UDim2.new(0, 4, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.AutoButtonColor = false
                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 6)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Hover }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = (states[name] and theme.Accent or theme.Tab) }):Play()
                end)
                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
                end
                updateBtnVisual()
                itemButtons[name] = btn
                btn.MouseButton1Click:Connect(function()
                    states[name] = not states[name]
                    updateBtnVisual()
                    if callback then callback(states) end
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
                            itemButtons[item].BackgroundColor3 = value and theme.Accent or theme.Tab
                            itemButtons[item].Text = item .. ": " .. (value and "ON" or "OFF")
                        end
                        if callback then callback(states) end
                    end
                end,
                GetAll = function() return states end
            }
        end

        tab.AddSelectDropdown = function(self, title, items, callback)
            local container = Instance.new("Frame", Page)
            container.Size = UDim2.new(1, -8, 0, 38)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0
            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, 8)
            local btnStroke = Instance.new("UIStroke", container)
            btnStroke.Color = theme.Stroke
            btnStroke.Thickness = 1

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, -8, 0, #items * 32 + 4)
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false
            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, 8)
            local btnStroke2 = Instance.new("UIStroke", dropdownFrame)
            btnStroke2.Color = theme.Stroke
            btnStroke2.Thickness = 1

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)

            local selectedItem, expanded = nil, false
            local function updateHeaderText()
                if selectedItem then
                    header.Text = (expanded and "▾ " or "▸ ") .. title .. ": " .. selectedItem
                else
                    header.Text = (expanded and "▾ " or "▸ ") .. title
                end
            end

            for _, name in ipairs(items) do
                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -8, 0, 28)
                btn.Position = UDim2.new(0, 4, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = name
                btn.AutoButtonColor = false
                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 6)
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Hover }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    selectedItem = name
                    expanded = false
                    dropdownFrame.Visible = false
                    updateHeaderText()
                    if callback then callback(selectedItem) end
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

        tab.AddSlider = function(self, text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, -8, 0, 44)
            SliderFrame.BackgroundTransparency = 1

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = theme.Text
            Label.Text = text .. ": " .. tostring(default)
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBar = Instance.new("Frame", SliderFrame)
            SliderBar.Size = UDim2.new(1, 0, 0, 14)
            SliderBar.Position = UDim2.new(0, 0, 0, 26)
            SliderBar.BackgroundColor3 = theme.Tab
            SliderBar.BorderSizePixel = 0
            local SliderCorner = Instance.new("UICorner", SliderBar)
            SliderCorner.CornerRadius = UDim.new(0, 7)

            local SliderFill = Instance.new("Frame", SliderBar)
            local initialPercent = math.clamp((default - min) / (max - min), 0, 1)
            SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.Accent
            SliderFill.BorderSizePixel = 0
            local FillCorner = Instance.new("UICorner", SliderFill)
            FillCorner.CornerRadius = UDim.new(0, 7)

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
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    updateSliderValue(input)
                    input.Handled = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSliderValue(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            return {
                Set = function(_, value)
                    local percent = math.clamp((value - min) / (max - min), 0, 1)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(value)
                    if callback then callback(value) end
                end,
                Get = function()
                    local size = SliderFill.Size.X.Scale
                    return math.floor(min + (max - min) * size)
                end,
                _instance = SliderFrame
            }
        end

        return tab
    end

    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            switchToPage(firstTabName)
        end
    end)()

    return window
end

return Library
