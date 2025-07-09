--[[
    📦 ESP v1 (Orientado a Objeto)
    Recursos:
    - Line (tracer do jogador local até o alvo)
    - Box (caixa 2D ao redor do alvo)
    - Name (exibe o nome do alvo)
    - Distance (exibe a distância do alvo em studs)
]]--

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(28, 30, 34),
    Tab = Color3.fromRGB(40, 43, 50),
    Accent = Color3.fromRGB(0, 140, 255),
    Text = Color3.fromRGB(235, 235, 245),
    Stroke = Color3.fromRGB(50, 56, 65),
    ScrollViewBackground = Color3.fromRGB(24, 26, 29),
    Shadow = Color3.fromRGB(0,0,0),
    BtnHighlight = Color3.fromRGB(15, 110, 210),
    BtnMinor = Color3.fromRGB(60, 65, 74),
}

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

    -- Shadow effect
    do
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = UDim2.new(0.5, 2, 0.5, 3)
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageTransparency = 0.76
        shadow.BackgroundTransparency = 1
        shadow.ZIndex = 0
        shadow.Parent = MainFrame
    end

    -- Drag logic
    local dragging = false
    local dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Position.Y < MainFrame.AbsolutePosition.Y + 40 then -- só permite drag no topo
                dragging = true
                dragStart = UserInputService:GetMouseLocation()
                startPos = MainFrame.Position
                input.Handled = true
            end
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

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = theme.Stroke
    UIStroke.Thickness = 1.1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- TitleBar
    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local BtnMinimize = Instance.new("TextButton", TitleBar)
    BtnMinimize.Size = UDim2.new(0, 34, 0, 34)
    BtnMinimize.Position = UDim2.new(1, -44, 0, 5)
    BtnMinimize.BackgroundColor3 = theme.BtnMinor
    BtnMinimize.Text = "–"
    BtnMinimize.TextColor3 = theme.Text
    BtnMinimize.Font = Enum.Font.GothamBold
    BtnMinimize.TextSize = 21
    BtnMinimize.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner", BtnMinimize)
    btnCorner.CornerRadius = UDim.new(1, 0)

    BtnMinimize.MouseEnter:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.14), { BackgroundColor3 = theme.BtnHighlight }):Play()
    end)
    BtnMinimize.MouseLeave:Connect(function()
        TweenService:Create(BtnMinimize, TweenInfo.new(0.14), { BackgroundColor3 = theme.BtnMinor }):Play()
    end)

    -- TabContainer
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 44)
    TabContainer.Size = UDim2.new(0, 130, 1, -44)
    TabContainer.BackgroundColor3 = theme.Tab

    local TabCorner = Instance.new("UICorner", TabContainer)
    TabCorner.CornerRadius = UDim.new(0, 9)

    local TabGlow = Instance.new("ImageLabel", TabContainer)
    TabGlow.Image = "rbxassetid://1316045217"
    TabGlow.ImageTransparency = 0.88
    TabGlow.Size = UDim2.new(1, 12, 1, 12)
    TabGlow.Position = UDim2.new(0, -6, 0, -6)
    TabGlow.BackgroundTransparency = 1
    TabGlow.ZIndex = 0

    -- PageContainer
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 130, 0, 44)
    PageContainer.Size = UDim2.new(1, -130, 1, -44)
    PageContainer.BackgroundColor3 = theme.Background
    PageContainer.ClipsDescendants = true

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 7)

    local pages = {}
    local firstTabName = nil
    local minimized = false

    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.28), { Size = UDim2.new(0, 130, 0, 44) }):Play()
            PageContainer.Visible = false
            TabContainer.Visible = false
            BtnMinimize.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.28), { Size = UDim2.new(0, 520, 0, 340) }):Play()
            PageContainer.Visible = true
            TabContainer.Visible = true
            BtnMinimize.Text = "–"
        end
    end)

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            if pgName == name then
                pg.Visible = true
            else
                pg.Visible = false
            end
        end
    end

    local window = {}

    -- Resizable
    do
        local resizeFrame = Instance.new("Frame", MainFrame)
        resizeFrame.Size = UDim2.new(0, 20, 0, 20)
        resizeFrame.Position = UDim2.new(1, -20, 1, -20)
        resizeFrame.BackgroundTransparency = 1
        resizeFrame.ZIndex = 10
        resizeFrame.Active = true

        local grip = Instance.new("ImageLabel", resizeFrame)
        grip.Image = "rbxassetid://3926307971"
        grip.ImageRectOffset = Vector2.new(964, 284)
        grip.ImageRectSize = Vector2.new(36, 36)
        grip.Size = UDim2.new(0, 20, 0, 20)
        grip.BackgroundTransparency = 1
        grip.ImageColor3 = theme.Stroke
        grip.ZIndex = 11

        local mouseDown = false
        local initialMousePos, initialFrameSize

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

        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, -12, 0, 34)
        Button.Position = UDim2.new(0, 6, 0, 0)
        Button.BackgroundColor3 = theme.Background
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 16
        Button.AutoButtonColor = false
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ZIndex = 1

        local btnCorner = Instance.new("UICorner", Button)
        btnCorner.CornerRadius = UDim.new(0, 7)

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

            Button.Text = "   " .. tabName
        else
            Button.Text = tabName
        end

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.16), { BackgroundColor3 = theme.BtnHighlight, TextColor3 = Color3.new(1,1,1) }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.16), { BackgroundColor3 = theme.Background, TextColor3 = theme.Text }):Play()
        end)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 5
        Page.BackgroundColor3 = theme.ScrollViewBackground
        Page.BorderSizePixel = 0
        Page.Padding = UDim.new(0, 10)

        local pageCorner = Instance.new("UICorner", Page)
        pageCorner.CornerRadius = UDim.new(0, 9)

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 14)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.19), { BackgroundColor3 = (btn == Button) and theme.Accent or theme.Background, TextColor3 = (btn == Button) and Color3.new(1,1,1) or theme.Text }):Play()
                end
            end
        end)

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, 0, 0, 26)
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
            Btn.Size = UDim2.new(1, 0, 0, 34)
            Btn.BackgroundColor3 = theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 16

            local corner = Instance.new("UICorner", Btn)
            corner.CornerRadius = UDim.new(0, 7)

            Btn.MouseButton1Click:Connect(callback)
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.13), { BackgroundColor3 = theme.BtnHighlight }):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.13), { BackgroundColor3 = theme.Accent }):Play()
            end)
            return Btn
        end

        function tab:AddToggle(text, callback)
            local ToggleBtn = Instance.new("TextButton", Page)
            ToggleBtn.Size = UDim2.new(1, 0, 0, 34)
            ToggleBtn.BackgroundColor3 = theme.Tab
            ToggleBtn.TextColor3 = theme.Text
            ToggleBtn.Font = Enum.Font.GothamMedium
            ToggleBtn.TextSize = 16

            local corner = Instance.new("UICorner", ToggleBtn)
            corner.CornerRadius = UDim.new(0, 7)

            local state = false
            local function updateToggleVisual()
                ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")
                TweenService:Create(ToggleBtn, TweenInfo.new(0.12), { BackgroundColor3 = state and theme.Accent or theme.Tab, TextColor3 = state and Color3.new(1,1,1) or theme.Text }):Play()
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
            container.Size = UDim2.new(1, 0, 0, 36)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0

            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, 7)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * 32 + 4)
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false

            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, 7)

            local listLayout = Instance.new("UIListLayout", dropdownFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 4)

            local states, itemButtons = {}, {}
            for _, name in ipairs(items) do
                states[name] = false
                local btn = Instance.new("TextButton", dropdownFrame)
                btn.Size = UDim2.new(1, -6, 0, 28)
                btn.Position = UDim2.new(0, 3, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 7)

                local function updateBtnVisual()
                    btn.Text = name .. ": " .. (states[name] and "ON" or "OFF")
                    TweenService:Create(btn, TweenInfo.new(0.11), { BackgroundColor3 = states[name] and theme.Accent or theme.Tab }):Play()
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
            container.Size = UDim2.new(1, 0, 0, 36)
            container.BackgroundColor3 = theme.Tab
            container.BorderSizePixel = 0

            local corner = Instance.new("UICorner", container)
            corner.CornerRadius = UDim.new(0, 7)

            local header = Instance.new("TextButton", container)
            header.Size = UDim2.new(1, 0, 1, 0)
            header.BackgroundTransparency = 1
            header.Text = "▸ " .. title
            header.TextColor3 = theme.Text
            header.TextSize = 16
            header.Font = Enum.Font.Gotham
            header.TextXAlignment = Enum.TextXAlignment.Left

            local dropdownFrame = Instance.new("Frame", Page)
            dropdownFrame.Size = UDim2.new(1, 0, 0, #items * 32 + 4)
            dropdownFrame.BackgroundColor3 = theme.Tab
            dropdownFrame.Visible = false

            local dropCorner = Instance.new("UICorner", dropdownFrame)
            dropCorner.CornerRadius = UDim.new(0, 7)

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
                btn.Size = UDim2.new(1, -6, 0, 28)
                btn.Position = UDim2.new(0, 3, 0, 0)
                btn.BackgroundColor3 = theme.Tab
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 14
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Text = name

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 7)

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
                    TweenService:Create(btn, TweenInfo.new(0.11), { BackgroundColor3 = theme.Accent }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.11), { BackgroundColor3 = theme.Tab }):Play()
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
            SliderFrame.Size = UDim2.new(1, 0, 0, 40)
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
            SliderBar.Size = UDim2.new(1, 0, 0, 12)
            SliderBar.Position = UDim2.new(0, 0, 0, 24)
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
                    if callback then
                        callback(value)
                    end
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

    coroutine.wrap(function()
        task.wait(0.1)
        if firstTabName ~= nil then
            switchToPage(firstTabName)
            -- destaca a primeira aba
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent, TextColor3 = Color3.new(1,1,1) }):Play()
                    break
                end
            end
        end
    end)()

    return window
end

return Library
