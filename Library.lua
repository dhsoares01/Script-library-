--[[
📦 ScriptLibrary v1.0
GUI em Lua com Tema Escuro, Menu em Abas, Suporte Mobile/Desktop
Elementos: Toggle, ButtonOnOff, Slider, Dropdown, Dropdown+ButtonOnOff, Label
Carregamento via: loadstring(game:HttpGet("URL"))()

Desenvolvido para executores como Delta, Synapse, etc.
Documentação embutida abaixo.
--]]

local ScriptLibrary = {}

--// Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--// Tema e estilos
local theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Header = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(70, 130, 180),
    Text = Color3.fromRGB(220, 220, 220),
    Border = Color3.fromRGB(50, 50, 50),
    ButtonOn = Color3.fromRGB(70, 130, 180),
    ButtonOff = Color3.fromRGB(80, 80, 80),
}

--// Variáveis internas
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptLibrary"
gui.Parent = game.CoreGui

--// Função utilitária: Criar cantos arredondados quando isolado
local function addCornerRadius(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

--// Função utilitária: Bordas
local function addBorder(obj)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = theme.Border
    stroke.Parent = obj
end

--// Cabeçalho
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = theme.Background
frame.BorderSizePixel = 0
addBorder(frame)
frame.Parent = gui

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = theme.Header
addBorder(header)
header.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "ScriptLibrary"
title.TextColor3 = theme.Text
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Parent = header

-- Botões minimizar e fechar
local minimize = Instance.new("TextButton")
minimize.Text = "–"
minimize.TextColor3 = theme.Text
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 16
minimize.Size = UDim2.new(0, 30, 1, 0)
minimize.Position = UDim2.new(1, -60, 0, 0)
minimize.BackgroundColor3 = theme.Header
addBorder(minimize)
minimize.Parent = header

local close = Instance.new("TextButton")
close.Text = "×"
close.TextColor3 = theme.Text
close.Font = Enum.Font.SourceSansBold
close.TextSize = 16
close.Size = UDim2.new(0, 30, 1, 0)
close.Position = UDim2.new(1, -30, 0, 0)
close.BackgroundColor3 = theme.Header
addBorder(close)
close.Parent = header

-- Conteúdo das abas
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 1, -30)
tabsFrame.Position = UDim2.new(0, 0, 0, 30)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

-- Lista de abas
local tabs = {}

function ScriptLibrary:CreateTab(name)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = name
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 6
    tab.CanvasSize = UDim2.new(0,0,0,0)
    tab.Parent = tabsFrame
    tabs[name] = tab
    return tab
end

-- Minimizar
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tabsFrame.Visible = false
        minimize.Text = "□"
        frame.Size = UDim2.new(0, 400, 0, 30)
    else
        tabsFrame.Visible = true
        minimize.Text = "–"
        frame.Size = UDim2.new(0, 400, 0, 300)
    end
end)

-- Fechar
close.MouseButton1Click:Connect(function()
    gui:Destroy()
    ScriptLibrary = nil
end)

-- Drag mobile/desktop
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

----------------------------------------------------------------
-- ELEMENTOS
----------------------------------------------------------------

-- Toggle
function ScriptLibrary:CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.TextColor3 = theme.Text
    btn.BackgroundColor3 = theme.ButtonOff
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    addBorder(btn)
    btn.Parent = parent

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and theme.ButtonOn or theme.ButtonOff
        if callback then callback(state) end
    end)
end

-- ButtonOnOff (sem manter estado)
function ScriptLibrary:CreateButtonOnOff(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.TextColor3 = theme.Text
    btn.BackgroundColor3 = theme.ButtonOff
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    addBorder(btn)
    btn.Parent = parent

    btn.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- Slider
function ScriptLibrary:CreateSlider(parent, text, min, max, callback)
    local label = Instance.new("TextLabel")
    label.Text = text..": "..tostring(min)
    label.TextColor3 = theme.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Parent = parent

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 8)
    slider.Position = UDim2.new(0, 5, 0, 25)
    slider.BackgroundColor3 = theme.ButtonOff
    addBorder(slider)
    slider.Parent = parent

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = theme.ButtonOn
    fill.Parent = slider

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local ratio = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            local value = math.floor(min + (max - min) * ratio)
            label.Text = text..": "..tostring(value)
            if callback then callback(value) end
        end
    end)
end

-- Dropdown simples
function ScriptLibrary:CreateDropdown(parent, text, options, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text.." ▼"
    btn.TextColor3 = theme.Text
    btn.BackgroundColor3 = theme.ButtonOff
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    addBorder(btn)
    btn.Parent = parent

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, -10, 0, #options*25)
    list.Position = UDim2.new(0, 5, 0, 30)
    list.BackgroundColor3 = theme.Background
    addBorder(list)
    list.Visible = false
    list.Parent = parent

    for _,opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Text = opt
        optBtn.TextColor3 = theme.Text
        optBtn.BackgroundColor3 = theme.ButtonOff
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 14
        addBorder(optBtn)
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = text.." ▼ "..opt
            list.Visible = false
            if callback then callback(opt) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)
end

-- Dropdown com botão extra
function ScriptLibrary:CreateDropdownWithButton(parent, text, options, buttonText, buttonCallback)
    self:CreateDropdown(parent, text, options, nil)
    self:CreateButtonOnOff(parent, buttonText, buttonCallback)
end

-- Label
function ScriptLibrary:CreateLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.TextColor3 = theme.Text
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.Parent = parent
end

return ScriptLibrary
