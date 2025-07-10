--[[ 
    Roblox UI Library 
    - Floating Menu with header, minimize/expand, and close functionality
    - Components: Toggle, Slider, ButtonOnOff, Label
    - Mobile touch support (dragging/moving)
    - Designed for easy usage via loadstring, customizable, and compatible with popular Roblox executors
    - To use: 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/<your-username>/<repo-name>/main/UILibrary.lua"))()
    Author: dhsoares01
]]

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local Library = {}
Library.__index = Library

-- Utilities
local function MakeDraggable(frame, dragBar)
    local dragging, dragInput, mousePos, framePos
    local TouchConnection

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            if input.UserInputType == Enum.UserInputType.Touch then
                TouchConnection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if TouchConnection then TouchConnection:Disconnect() end
                    end
                end)
            end
        end
    end)

    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if TouchConnection then TouchConnection:Disconnect() end
        end
    end)
end

-- Main UI Library
function Library:Create(title)
    -- ScreenGui + Main Frame
    local gui = Instance.new("ScreenGui")
    gui.Name = "UILib"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    local main = Instance.new("Frame")
    main.Name = "MainMenu"
    main.Size = UDim2.new(0, 360, 0, 340)
    main.Position = UDim2.new(0.5, -180, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(28,28,40)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = false
    main.Parent = gui

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Color3.fromRGB(38,38,60)
    header.BorderSizePixel = 0
    header.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -110, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "UI Library"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(220,220,255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -90, 0, 0)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(50,50,73)
    minimizeBtn.Text = "–"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextColor3 = Color3.fromRGB(200,200,220)
    minimizeBtn.TextSize = 22
    minimizeBtn.Parent = header

    local expandBtn = minimizeBtn:Clone()
    expandBtn.Text = "+"
    expandBtn.Name = "ExpandBtn"
    expandBtn.Visible = false
    expandBtn.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 1, 0)
    closeBtn.Position = UDim2.new(1, -45, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60,25,33)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(240, 110, 120)
    closeBtn.TextSize = 22
    closeBtn.Parent = header

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Position = UDim2.new(0, 0, 0, 36)
    container.Size = UDim2.new(1, 0, 1, -36)
    container.BackgroundTransparency = 1
    container.Parent = main

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = container

    -- Dragging support
    MakeDraggable(main, header)

    -- Minimize / Expand logic
    local origSize = main.Size
    local collapsedSize = UDim2.new(origSize.X.Scale, origSize.X.Offset, 0, 36)

    minimizeBtn.MouseButton1Click:Connect(function()
        TS:Create(main, TweenInfo.new(0.18), {Size = collapsedSize}):Play()
        container.Visible = false
        minimizeBtn.Visible = false
        expandBtn.Visible = true
    end)
    expandBtn.MouseButton1Click:Connect(function()
        TS:Create(main, TweenInfo.new(0.18), {Size = origSize}):Play()
        container.Visible = true
        minimizeBtn.Visible = true
        expandBtn.Visible = false
    end)

    -- Close logic
    closeBtn.MouseButton1Click:Connect(function()
        for _, comp in pairs(container:GetChildren()) do
            if comp:IsA("Frame") and comp:FindFirstChild("_UILibType") then
                if comp._UILibType.Value == "Slider" then
                    -- Reset slider to default
                    pcall(function()
                        local slider = comp:FindFirstChild("SliderBar")
                        local default = comp:FindFirstChild("_Default") and comp._Default.Value or 0
                        local val = comp:FindFirstChild("_Value")
                        if slider and val then
                            local sliderSize = slider.AbsoluteSize.X
                            local percent = (default - comp._Min.Value) / (comp._Max.Value - comp._Min.Value)
                            slider.Position = UDim2.new(percent, -8, 0.5, -8)
                            val.Value = default
                        end
                    end)
                else
                    comp.Visible = false
                end
            end
        end
    end)

    local ui = setmetatable({
        Container = container,
        Gui = gui,
        Main = main,
    }, Library)
    return ui
end

-- COMPONENTS

function Library:AddLabel(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Label"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(230,230,255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local t = Instance.new("StringValue")
    t.Name = "_UILibType"
    t.Value = "Label"
    t.Parent = frame

    frame.Parent = self.Container
    return frame
end

function Library:AddToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 2

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleBtn.Position = UDim2.new(0, 0, 0.5, -15)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50,130,90)
    toggleBtn.Text = default and "✓" or ""
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220,220,255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local state = Instance.new("BoolValue")
    state.Name = "_Value"
    state.Value = default or false
    state.Parent = frame

    local t = Instance.new("StringValue")
    t.Name = "_UILibType"
    t.Value = "Toggle"
    t.Parent = frame

    toggleBtn.MouseButton1Click:Connect(function()
        state.Value = not state.Value
        toggleBtn.Text = state.Value and "✓" or ""
        if callback then callback(state.Value) end
    end)

    frame.Parent = self.Container
    return frame
end

function Library:AddButtonOnOff(text, initial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 36)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 3

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 0, 30)
    button.Position = UDim2.new(0, 0, 0.5, -15)
    button.BackgroundColor3 = initial and Color3.fromRGB(60,180,100) or Color3.fromRGB(180,60,60)
    button.Text = initial and "ON" or "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(255,255,255)
    button.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 80, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Button"
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220,220,255)
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local state = Instance.new("BoolValue")
    state.Name = "_Value"
    state.Value = initial or false
    state.Parent = frame

    local t = Instance.new("StringValue")
    t.Name = "_UILibType"
    t.Value = "ButtonOnOff"
    t.Parent = frame

    button.MouseButton1Click:Connect(function()
        state.Value = not state.Value
        button.Text = state.Value and "ON" or "OFF"
        button.BackgroundColor3 = state.Value and Color3.fromRGB(60,180,100) or Color3.fromRGB(180,60,60)
        if callback then callback(state.Value) end
    end)

    frame.Parent = self.Container
    return frame
end

function Library:AddSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 4

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "Slider") .. ": " .. tostring(default or min)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(220,220,255)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Name = "SliderBar"
    sliderBar.Size = UDim2.new(1, -10, 0, 10)
    sliderBar.Position = UDim2.new(0, 5, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(80,80,120)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = frame

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
    sliderKnob.AnchorPoint = Vector2.new(0, 0.5)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(130,160,230)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBar

    local value = Instance.new("NumberValue")
    value.Name = "_Value"
    value.Value = default or min
    value.Parent = frame

    local minV = Instance.new("NumberValue")
    minV.Name = "_Min"
    minV.Value = min or 0
    minV.Parent = frame

    local maxV = Instance.new("NumberValue")
    maxV.Name = "_Max"
    maxV.Value = max or 100
    maxV.Parent = frame

    local defaultV = Instance.new("NumberValue")
    defaultV.Name = "_Default"
    defaultV.Value = default or min
    defaultV.Parent = frame

    local t = Instance.new("StringValue")
    t.Name = "_UILibType"
    t.Value = "Slider"
    t.Parent = frame

    -- Set knob position
    local function setKnob(val)
        val = math.clamp(val, minV.Value, maxV.Value)
        local percent = (val - minV.Value) / (maxV.Value - minV.Value)
        local px = percent * (sliderBar.AbsoluteSize.X - sliderKnob.AbsoluteSize.X)
        sliderKnob.Position = UDim2.new(0, px, 0.5, -8)
        value.Value = val
        label.Text = (text or "Slider") .. ": " .. tostring(math.floor(val*100)/100)
        if callback then callback(val) end
    end

    local dragging = false

    local function updateInput(x)
        local rel = x - sliderBar.AbsolutePosition.X
        local percent = math.clamp(rel / sliderBar.AbsoluteSize.X, 0, 1)
        local v = minV.Value + (maxV.Value - minV.Value) * percent
        setKnob(v)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateInput(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input.Position.X)
        end
    end)

    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateInput(input.Position.X)
        end
    end)

    -- Default position
    frame.Parent = self.Container
    frame.Parent:WaitForChild(frame.Name or frame)
    setKnob(default or min)

    return frame
end

return Library
