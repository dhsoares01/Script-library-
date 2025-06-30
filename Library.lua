local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cores personalizadas
local ColorPalette = {
    Background = Color3.fromRGB(15, 15, 20),
    Header = Color3.fromRGB(25, 25, 35),
    Tab = Color3.fromRGB(30, 30, 45),
    Content = Color3.fromRGB(20, 20, 30),
    Button = Color3.fromRGB(45, 35, 70),
    ButtonHover = Color3.fromRGB(60, 45, 90),
    ToggleOff = Color3.fromRGB(80, 80, 100),
    ToggleOn = Color3.fromRGB(120, 70, 200),
    Slider = Color3.fromRGB(60, 60, 80),
    SliderFill = Color3.fromRGB(100, 80, 220),
    Text = Color3.fromRGB(240, 240, 250),
    Accent = Color3.fromRGB(140, 100, 255),
    Border = Color3.fromRGB(60, 60, 80)
}

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "FloatingLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Container
    local Main = Instance.new("Frame", ScreenGui)  
    Main.Size = UDim2.new(0, 400, 0, 350)  
    Main.Position = UDim2.new(0.3, 0, 0.2, 0)  
    Main.BackgroundColor3 = ColorPalette.Background
    Main.BorderSizePixel = 0  
    Main.Active = true  
    Main.Draggable = true  

    local UICorner = Instance.new("UICorner", Main)  
    UICorner.CornerRadius = UDim.new(0, 8)  

    -- Efeito de sombra suave
    local Shadow = Instance.new("ImageLabel", Main)  
    Shadow.Name = "Shadow"  
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)  
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)  
    Shadow.Size = UDim2.new(1, 40, 1, 40)  
    Shadow.Image = "rbxassetid://1316045217"  
    Shadow.ImageColor3 = Color3.fromRGB(20, 10, 40)
    Shadow.ImageTransparency = 0.8  
    Shadow.BackgroundTransparency = 1  
    Shadow.ZIndex = -1  
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

    -- Header
    local Header = Instance.new("Frame", Main)  
    Header.Size = UDim2.new(1, 0, 0, 35)  
    Header.BackgroundColor3 = ColorPalette.Header
    Header.BorderSizePixel = 0  
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    
    -- Gradiente do header
    local HeaderGradient = Instance.new("UIGradient", Header)
    HeaderGradient.Rotation = 90
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 40, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 80))
    })

    local TitleLabel = Instance.new("TextLabel", Header)  
    TitleLabel.Text = title or "Floating UI"  
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)  
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)  
    TitleLabel.TextColor3 = ColorPalette.Text
    TitleLabel.BackgroundTransparency = 1  
    TitleLabel.Font = Enum.Font.GothamSemibold  
    TitleLabel.TextSize = 16  
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left  

    -- Botões de controle
    local Close = Instance.new("TextButton", Header)  
    Close.Text = "×"  
    Close.Size = UDim2.new(0, 30, 1, 0)  
    Close.Position = UDim2.new(1, -30, 0, 0)  
    Close.TextColor3 = Color3.fromRGB(255, 80, 80)  
    Close.Font = Enum.Font.GothamBold  
    Close.TextSize = 22  
    Close.BackgroundTransparency = 1  
    Close.ZIndex = 2  
    
    Close.MouseEnter:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
    end)
    
    Close.MouseLeave:Connect(function()
        TweenService:Create(Close, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    
    Close.MouseButton1Click:Connect(function()  
        ScreenGui:Destroy()  
    end)  

    local Minimize = Instance.new("TextButton", Header)  
    Minimize.Text = "–"  
    Minimize.Size = UDim2.new(0, 30, 1, 0)  
    Minimize.Position = UDim2.new(1, -60, 0, 0)  
    Minimize.TextColor3 = ColorPalette.Text
    Minimize.Font = Enum.Font.GothamBold  
    Minimize.TextSize = 22  
    Minimize.BackgroundTransparency = 1  

    Minimize.MouseEnter:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.2), {TextColor3 = ColorPalette.Accent}):Play()
    end)
    
    Minimize.MouseLeave:Connect(function()
        TweenService:Create(Minimize, TweenInfo.new(0.2), {TextColor3 = ColorPalette.Text}):Play()
    end)

    -- Área de abas
    local TabHolder = Instance.new("Frame", Main)  
    TabHolder.Position = UDim2.new(0, 0, 0, 35)  
    TabHolder.Size = UDim2.new(0, 110, 1, -35)  
    TabHolder.BackgroundColor3 = ColorPalette.Tab
    TabHolder.BorderSizePixel = 0
    Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 8)  

    -- Área de conteúdo
    local PageHolder = Instance.new("Frame", Main)  
    PageHolder.Position = UDim2.new(0, 110, 0, 35)  
    PageHolder.Size = UDim2.new(1, -110, 1, -35)  
    PageHolder.BackgroundColor3 = ColorPalette.Content
    PageHolder.ClipsDescendants = true  
    Instance.new("UICorner", PageHolder).CornerRadius = UDim.new(0, 8)  

    local UIList = Instance.new("UIListLayout", TabHolder)  
    UIList.Padding = UDim.new(0, 5)  
    UIList.SortOrder = Enum.SortOrder.LayoutOrder  

    local Tabs = {}  
    local minimized = false  

    Minimize.MouseButton1Click:Connect(function()  
        minimized = not minimized  
        local meta = minimized and UDim2.new(0, 400, 0, 35) or UDim2.new(0, 400, 0, 350)  
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = meta}):Play()  
        TabHolder.Visible = not minimized  
        PageHolder.Visible = not minimized  
    end)  

    local function isPointerInput(input)  
        return input.UserInputType == Enum.UserInputType.MouseButton1 or  
               input.UserInputType == Enum.UserInputType.Touch  
    end  

    function Library:CreateTab(name)  
        local Button = Instance.new("TextButton", TabHolder)  
        Button.Size = UDim2.new(0.9, 0, 0, 30)  
        Button.Position = UDim2.new(0.05, 0, 0, 0)
        Button.Text = name  
        Button.BackgroundColor3 = ColorPalette.Button
        Button.TextColor3 = ColorPalette.Text
        Button.Font = Enum.Font.GothamMedium  
        Button.TextSize = 14  
        Button.AutoButtonColor = false
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)  
        
        -- Efeito hover
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = ColorPalette.ButtonHover}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = ColorPalette.Button}):Play()
        end)

        local Page = Instance.new("ScrollingFrame", PageHolder)  
        Page.Size = UDim2.new(1, 0, 1, 0)  
        Page.Visible = false  
        Page.BackgroundTransparency = 1  
        Page.ScrollBarThickness = 4  
        Page.ScrollBarImageColor3 = ColorPalette.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 500)  
        local layout = Instance.new("UIListLayout", Page)  
        layout.Padding = UDim.new(0, 8)  

        Tabs[name] = Page  

        Button.MouseButton1Click:Connect(function()  
            for _, v in pairs(PageHolder:GetChildren()) do  
                if v:IsA("ScrollingFrame") then  
                    v.Visible = false  
                end  
            end  
            Page.Visible = true  
            
            -- Efeito de seleção
            for _, btn in pairs(TabHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = btn == Button and ColorPalette.Accent or ColorPalette.Button
                    }):Play()
                end
            end
        end)  

        return {  
            AddLabel = function(_, text)
                local container = Instance.new("Frame", Page)
                container.Size = UDim2.new(1, -15, 0, 25)
                container.BackgroundTransparency = 1
                
                local lbl = Instance.new("TextLabel", container)  
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1  
                lbl.Text = text  
                lbl.TextColor3 = ColorPalette.Text
                lbl.Font = Enum.Font.Gotham  
                lbl.TextSize = 14  
                lbl.TextXAlignment = Enum.TextXAlignment.Left  
                
                local divider = Instance.new("Frame", container)
                divider.Position = UDim2.new(0, 0, 1, -1)
                divider.Size = UDim2.new(1, 0, 0, 1)
                divider.BackgroundColor3 = ColorPalette.Border
                divider.BorderSizePixel = 0
                
                return lbl
            end,  

            AddButton = function(_, text, callback)  
                local btn = Instance.new("TextButton", Page)  
                btn.Size = UDim2.new(1, -15, 0, 32)  
                btn.Text = text  
                btn.BackgroundColor3 = ColorPalette.Button
                btn.TextColor3 = ColorPalette.Text
                btn.Font = Enum.Font.GothamMedium  
                btn.TextSize = 14  
                btn.AutoButtonColor = false
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)  
                
                -- Efeitos hover e clique
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.ButtonHover,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.Button,
                        TextColor3 = ColorPalette.Text
                    }):Play()
                end)
                
                btn.MouseButton1Down:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = ColorPalette.Accent,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                
                btn.MouseButton1Up:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ColorPalette.ButtonHover,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end)
                
                btn.MouseButton1Click:Connect(callback)  
                
                return btn
            end,  

            AddToggle = function(_, text, default, callback)  
                local container = Instance.new("Frame", Page)
                container.Size = UDim2.new(1, -15, 0, 30)
                container.BackgroundTransparency = 1
                
                local label = Instance.new("TextLabel", container)
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Text = text
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleFrame = Instance.new("Frame", container)
                toggleFrame.Size = UDim2.new(0.25, 0, 0.7, 0)
                toggleFrame.Position = UDim2.new(0.75, 0, 0.15, 0)
                toggleFrame.BackgroundColor3 = ColorPalette.ToggleOff
                toggleFrame.BorderSizePixel = 0
                Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0.5, 0)
                
                local toggleDot = Instance.new("Frame", toggleFrame)
                toggleDot.Size = UDim2.new(0.4, 0, 0.8, 0)
                toggleDot.Position = UDim2.new(default and 0.55 or 0.05, 0, 0.1, 0)
                toggleDot.BackgroundColor3 = ColorPalette.Text
                toggleDot.BorderSizePixel = 0
                Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(0.5, 0)
                
                local state = default
                
                local function updateToggle()
                    if state then
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOn
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.55, 0, 0.1, 0)
                        }):Play()
                    else
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOff
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.05, 0, 0.1, 0)
                        }):Play()
                    end
                end
                
                updateToggle()
                
                local function toggleState()
                    state = not state
                    updateToggle()
                    if callback then callback(state) end
                end
                
                toggleFrame.MouseButton1Click:Connect(toggleState)
                label.MouseButton1Click:Connect(toggleState)
                
                return {
                    Set = function(_, value)
                        state = value
                        updateToggle()
                    end,
                    Get = function()
                        return state
                    end
                }
            end,  

            AddSlider = function(_, text, min, max, default, callback)  
                local container = Instance.new("Frame", Page)  
                container.Size = UDim2.new(1, -15, 0, 60)  
                container.BackgroundTransparency = 1  

                local label = Instance.new("TextLabel", container)  
                label.Size = UDim2.new(1, 0, 0.4, 0)  
                label.Text = text .. ": " .. tostring(default)  
                label.BackgroundTransparency = 1  
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham  
                label.TextSize = 14  
                label.TextXAlignment = Enum.TextXAlignment.Left  

                local slider = Instance.new("Frame", container)  
                slider.Position = UDim2.new(0, 0, 0.4, 5)  
                slider.Size = UDim2.new(1, 0, 0.3, 0)  
                slider.BackgroundColor3 = ColorPalette.Slider
                slider.BorderSizePixel = 0
                Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)  

                local fill = Instance.new("Frame", slider)  
                fill.Name = "Fill"  
                fill.BackgroundColor3 = ColorPalette.SliderFill
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)  
                fill.BorderSizePixel = 0  
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)  
                
                -- Indicador de valor
                local valueIndicator = Instance.new("Frame", fill)
                valueIndicator.Size = UDim2.new(0, 6, 0, 16)
                valueIndicator.Position = UDim2.new(1, -3, 0.5, -8)
                valueIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
                valueIndicator.BackgroundColor3 = ColorPalette.Text
                valueIndicator.BorderSizePixel = 0
                Instance.new("UICorner", valueIndicator).CornerRadius = UDim.new(0, 3)

                local dragging = false  

                local function updateInput(input)  
                    local rel = input.Position.X - slider.AbsolutePosition.X  
                    local pct = math.clamp(rel / slider.AbsoluteSize.X, 0, 1)  
                    local value = math.floor(min + (max - min) * pct + 0.5)  
                    fill.Size = UDim2.new(pct, 0, 1, 0)  
                    label.Text = text .. ": " .. value  
                    if callback then callback(value) end  
                end  

                slider.InputBegan:Connect(function(input)  
                    if isPointerInput(input) then  
                        dragging = true  
                        updateInput(input)  
                    end  
                end)  

                slider.InputEnded:Connect(function(input)  
                    if isPointerInput(input) then  
                        dragging = false  
                    end  
                end)  

                slider.InputChanged:Connect(function(input)  
                    if dragging and input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then  
                        updateInput(input)  
                    end  
                end)  
                
                return {
                    Set = function(_, value)
                        local pct = math.clamp((value - min) / (max - min), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        label.Text = text .. ": " .. value
                    end
                }
            end,  

            AddSeekBar = function(_, text, min, max, default, callback)  
                local container = Instance.new("Frame", Page)  
                container.Size = UDim2.new(1, -15, 0, 70)  
                container.BackgroundTransparency = 1  

                local label = Instance.new("TextLabel", container)  
                label.Size = UDim2.new(1, 0, 0, 20)  
                label.Text = text .. ": " .. tostring(default)  
                label.BackgroundTransparency = 1  
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham  
                label.TextSize = 14  
                label.TextXAlignment = Enum.TextXAlignment.Left  

                local bar = Instance.new("Frame", container)  
                bar.Position = UDim2.new(0, 0, 0, 25)  
                bar.Size = UDim2.new(1, 0, 0, 8)  
                bar.BackgroundColor3 = ColorPalette.Slider
                bar.BorderSizePixel = 0
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)  

                local fill = Instance.new("Frame", bar)  
                fill.Name = "Fill"  
                fill.BackgroundColor3 = ColorPalette.SliderFill
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)  
                fill.BorderSizePixel = 0  
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)  
                
                -- Bolinha de controle
                local knob = Instance.new("Frame", bar)
                knob.Size = UDim2.new(0, 12, 0, 12)
                knob.Position = UDim2.new((default - min) / (max - min), -2, 0, -2)
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.BackgroundColor3 = ColorPalette.Text
                knob.BorderSizePixel = 0
                Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                
                local knobShadow = Instance.new("ImageLabel", knob)
                knobShadow.Size = UDim2.new(1, 6, 1, 6)
                knobShadow.Position = UDim2.new(0.5, -3, 0.5, -3)
                knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                knobShadow.Image = "rbxassetid://1316045217"
                knobShadow.ImageColor3 = Color3.new(0, 0, 0)
                knobShadow.ImageTransparency = 0.8
                knobShadow.BackgroundTransparency = 1
                knobShadow.ZIndex = -1
                knobShadow.ScaleType = Enum.ScaleType.Slice
                knobShadow.SliceCenter = Rect.new(10, 10, 118, 118)

                local dragging = false  

                local function updateInput(input)  
                    local rel = input.Position.X - bar.AbsolutePosition.X  
                    local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)  
                    local value = math.floor(min + (max - min) * pct + 0.5)  
                    fill.Size = UDim2.new(pct, 0, 1, 0)  
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    label.Text = text .. ": " .. value  
                    if callback then callback(value) end  
                end  

                bar.InputBegan:Connect(function(input)  
                    if isPointerInput(input) then  
                        dragging = true  
                        updateInput(input)  
                        TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play()
                    end  
                end)  

                bar.InputEnded:Connect(function(input)  
                    if isPointerInput(input) then  
                        dragging = false  
                        TweenService:Create(knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
                    end  
                end)  

                bar.InputChanged:Connect(function(input)  
                    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then  
                        updateInput(input)  
                    end  
                end)  
                
                return {
                    Set = function(_, value)
                        local pct = math.clamp((value - min) / (max - min), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, 0, 0.5, 0)
                        label.Text = text .. ": " .. value
                    end
                }
            end,
            
            AddDropdown = function(_, text, options, default, callback)
                local container = Instance.new("Frame", Page)
                container.Size = UDim2.new(1, -15, 0, 30)
                container.BackgroundTransparency = 1
                
                local label = Instance.new("TextLabel", container)
                label.Size = UDim2.new(0.7, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Text = text
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdown = Instance.new("TextButton", container)
                dropdown.Size = UDim2.new(0.3, 0, 1, 0)
                dropdown.Position = UDim2.new(0.7, 0, 0, 0)
                dropdown.Text = options[default] or "Select"
                dropdown.TextColor3 = ColorPalette.Text
                dropdown.Font = Enum.Font.Gotham
                dropdown.TextSize = 14
                dropdown.BackgroundColor3 = ColorPalette.Button
                dropdown.AutoButtonColor = false
                Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 4)
                
                local dropdownList = Instance.new("ScrollingFrame", container)
                dropdownList.Size = UDim2.new(0.3, 0, 0, 100)
                dropdownList.Position = UDim2.new(0.7, 0, 1, 5)
                dropdownList.BackgroundColor3 = ColorPalette.Content
                dropdownList.BorderSizePixel = 0
                dropdownList.Visible = false
                dropdownList.ScrollBarThickness = 4
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 4)
                
                local layout = Instance.new("UIListLayout", dropdownList)
                layout.Padding = UDim.new(0, 2)
                
                for i, option in pairs(options) do
                    local optionBtn = Instance.new("TextButton", dropdownList)
                    optionBtn.Size = UDim2.new(1, -10, 0, 25)
                    optionBtn.Position = UDim2.new(0, 5, 0, (i-1)*25)
                    optionBtn.Text = option
                    optionBtn.TextColor3 = ColorPalette.Text
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.TextSize = 13
                    optionBtn.BackgroundColor3 = ColorPalette.Button
                    optionBtn.AutoButtonColor = false
                    Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 3)
                    
                    optionBtn.MouseEnter:Connect(function()
                        TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = ColorPalette.ButtonHover
                        }):Play()
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                            BackgroundColor3 = ColorPalette.Button
                        }):Play()
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        dropdown.Text = option
                        dropdownList.Visible = false
                        if callback then callback(i, option) end
                    end)
                end
                
                dropdown.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                end)
                
                return {
                    Set = function(_, index)
                        if options[index] then
                            dropdown.Text = options[index]
                            if callback then callback(index, options[index]) end
                        end
                    end,
                    Get = function()
                        return table.find(options, dropdown.Text)
                    end
                }
            end
        }  
    end  

    return Library
end

return Library
