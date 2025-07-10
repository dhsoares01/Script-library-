--[[
UI BIBLIOTECA - Floating Menu UI Library for Roblox Executors (Delta, Fluxus, etc.)
Author: dhsoares01
GitHub: [https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua]
License: MIT

Features:
- Draggable floating menu (mouse and touch support)
- Header with title, minimize/expand and close buttons
- Components: Toggle, Slider, ButtonOnOff, Label
- When minimized, menu collapses, button toggles between "-" and "+"
- When closed, disables all components except for those that must remain (e.g. slider reset to default)
- Mobile touch drag support

Usage:
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/youruser/yourrepo/main/UILibrary.lua"))()
local myMenu = ui:CreateMenu("Meu Menu")
local myToggle = myMenu:AddToggle("Ativar função", function(state) print("Toggle:", state) end)
local mySlider = myMenu:AddSlider("Volume", 0, 100, 50, function(value) print("Slider:", value) end)
local myButton = myMenu:AddButtonOnOff("Iniciar", function(on) print("Button:", on) end)
myMenu:AddLabel("Desenvolvido por dhsoares01")
]]

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local UILibrary = {}
UILibrary.__index = UILibrary

local COMPONENTS = {"Toggle", "Slider", "ButtonOnOff", "Label"}

-- Default theme (customize as needed)
local THEME = {
    Background = Color3.fromRGB(40, 40, 40),
    Header = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Button = Color3.fromRGB(60, 60, 60),
    ButtonOn = Color3.fromRGB(0, 220, 120),
    SliderBar = Color3.fromRGB(70, 70, 70),
    SliderFill = Color3.fromRGB(0, 170, 255)
}

-- Utility: Create UI element with properties
local function create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

--[[
    FloatingMenu Class
]]
local FloatingMenu = {}
FloatingMenu.__index = FloatingMenu

function FloatingMenu:Minimize()
    if self._closed then return end
    self._minimized = true
    self._body.Visible = false
    self._minBtn.Text = "+"
end

function FloatingMenu:Expand()
    if self._closed then return end
    self._minimized = false
    self._body.Visible = true
    self._minBtn.Text = "–"
end

function FloatingMenu:Close()
    self._closed = true
    self._main.Visible = false
    -- Disable all component callbacks
    for _,comp in pairs(self._components) do
        if comp.Type == "Toggle" then
            comp.Object.ToggleBtn.AutoButtonColor = false
            comp.Object.ToggleBtn.MouseButton1Click:Disconnect()
            comp.Object.ToggleBtn.Text = "OFF"
            comp.Object.ToggleBtn.BackgroundColor3 = THEME.Button
        elseif comp.Type == "ButtonOnOff" then
            comp.Object.Btn.AutoButtonColor = false
            comp.Object.Btn.MouseButton1Click:Disconnect()
            comp.Object.Btn.Text = "OFF"
            comp.Object.Btn.BackgroundColor3 = THEME.Button
        elseif comp.Type == "Slider" then
            -- Reset slider to default value and lock
            comp.Object.SliderBar.Bar.Size = UDim2.new(0,0,1,0)
            comp.Object.SliderBar.Fill.Size = UDim2.new(0,0,1,0)
            comp.Object.SliderBar.Bar.InputBegan:Disconnect()
            comp.Object.SliderBar.Bar.InputChanged:Disconnect()
            comp.Object.SliderBar.Bar.InputEnded:Disconnect()
            comp:Reset()
        end
    end
end

function FloatingMenu:_dragify(frame)
    local dragToggle, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
            update(input)
        end
    end)
end

function FloatingMenu:AddToggle(text, callback)
    local comp = {}
    local holder = create("Frame", {
        Name = "ToggleHolder",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,30),
        Parent = self._body
    })
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.SourceSans,
        TextColor3 = THEME.Text,
        TextSize = 16,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,5,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    local btn = create("TextButton", {
        Name = "ToggleBtn",
        BackgroundColor3 = THEME.Button,
        Text = "OFF",
        Font = Enum.Font.SourceSansBold,
        TextColor3 = THEME.Text,
        Size = UDim2.new(0,50,0,22),
        Position = UDim2.new(1,-58,0.5,-11),
        AnchorPoint = Vector2.new(0,0.5),
        Parent = holder
    })
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and THEME.ButtonOn or THEME.Button
        if callback then callback(state) end
    end)
    comp.Object = {Holder=holder, ToggleBtn=btn}
    comp.Type = "Toggle"
    table.insert(self._components, comp)
    return comp
end

function FloatingMenu:AddButtonOnOff(text, callback)
    local comp = {}
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,30),
        Parent = self._body
    })
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.SourceSans,
        TextColor3 = THEME.Text,
        TextSize = 16,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,5,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    local btn = create("TextButton", {
        Name = "Btn",
        BackgroundColor3 = THEME.Button,
        Text = "OFF",
        Font = Enum.Font.SourceSansBold,
        TextColor3 = THEME.Text,
        Size = UDim2.new(0,50,0,22),
        Position = UDim2.new(1,-58,0.5,-11),
        AnchorPoint = Vector2.new(0,0.5),
        Parent = holder
    })
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and THEME.ButtonOn or THEME.Button
        if callback then callback(on) end
    end)
    comp.Object = {Holder=holder, Btn=btn}
    comp.Type = "ButtonOnOff"
    table.insert(self._components, comp)
    return comp
end

function FloatingMenu:AddSlider(text, min, max, default, callback)
    local comp = {}
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,38),
        Parent = self._body
    })
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = ("%s: %d"):format(text, default),
        Font = Enum.Font.SourceSans,
        TextColor3 = THEME.Text,
        TextSize = 16,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,5,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    local sliderBar = create("Frame", {
        Name = "SliderBar",
        BackgroundColor3 = THEME.SliderBar,
        BorderSizePixel = 0,
        Size = UDim2.new(0.7,0,0,8),
        Position = UDim2.new(0,5,1,-16),
        Parent = holder
    })
    local fill = create("Frame", {
        Name = "Fill",
        BackgroundColor3 = THEME.SliderFill,
        BorderSizePixel = 0,
        Size = UDim2.new((default-min)/(max-min),0,1,0),
        Parent = sliderBar
    })
    local dragging = false
    local function setSlider(x)
        local rel = math.clamp((x-sliderBar.AbsolutePosition.X)/sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max-min)*rel + 0.5)
        fill.Size = UDim2.new(rel,0,1,0)
        label.Text = ("%s: %d"):format(text, value)
        if callback then callback(value) end
    end
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setSlider(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            setSlider(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging then dragging = false end
    end)
    function comp:Reset()
        fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
        label.Text = ("%s: %d"):format(text, default)
        if callback then callback(default) end
    end
    comp.Object = {Holder=holder, SliderBar={Bar=sliderBar, Fill=fill}, Label=label}
    comp.Type = "Slider"
    table.insert(self._components, comp)
    return comp
end

function FloatingMenu:AddLabel(text)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,24),
        Parent = self._body
    })
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.SourceSansItalic,
        TextColor3 = THEME.Text,
        TextSize = 14,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    return label
end

function UILibrary:CreateMenu(title)
    local selfMenu = setmetatable({}, FloatingMenu)
    selfMenu._components = {}
    selfMenu._closed = false
    selfMenu._minimized = false

    -- Main container
    local main = create("Frame", {
        Name = "FloatingMenu",
        AnchorPoint = Vector2.new(0,0),
        Position = UDim2.new(0.25,0,0.2,0),
        Size = UDim2.new(0,320,0,48),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Parent = game:GetService("CoreGui")
    })
    selfMenu._main = main

    -- Header
    local header = create("Frame", {
        Name = "Header",
        BackgroundColor3 = THEME.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,36),
        Parent = main
    })

    local titleLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title or "Biblioteca UI",
        Font = Enum.Font.SourceSansBold,
        TextColor3 = THEME.Text,
        TextSize = 18,
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })

    -- Minimize button
    local minBtn = create("TextButton", {
        Text = "–",
        Font = Enum.Font.SourceSansBold,
        TextSize = 22,
        TextColor3 = THEME.Text,
        BackgroundColor3 = Color3.fromRGB(50,50,50),
        Size = UDim2.new(0,32,0,28),
        Position = UDim2.new(1,-72,0.5,-14),
        AnchorPoint = Vector2.new(0,0.5),
        Parent = header
    })
    selfMenu._minBtn = minBtn

    -- Close button
    local closeBtn = create("TextButton", {
        Text = "×",
        Font = Enum.Font.SourceSansBold,
        TextSize = 22,
        TextColor3 = THEME.Text,
        BackgroundColor3 = Color3.fromRGB(90,30,30),
        Size = UDim2.new(0,32,0,28),
        Position = UDim2.new(1,-36,0.5,-14),
        AnchorPoint = Vector2.new(0,0.5),
        Parent = header
    })

    -- Body
    local body = create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,-36),
        Position = UDim2.new(0,0,0,36),
        Parent = main
    })
    selfMenu._body = body

    -- ListLayout for elements
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body
    })

    -- Drag support (mouse and touch)
    selfMenu:_dragify(header)

    -- Minimize/Expand logic
    minBtn.MouseButton1Click:Connect(function()
        if selfMenu._minimized then
            selfMenu:Expand()
        else
            selfMenu:Minimize()
        end
    end)

    -- Close logic
    closeBtn.MouseButton1Click:Connect(function()
        selfMenu:Close()
    end)

    return selfMenu
end

return setmetatable(UILibrary, {
    __call = function(cls, ...)
        return cls
    end
})
