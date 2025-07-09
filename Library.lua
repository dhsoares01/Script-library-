-- ScriptLibrary.lua
local ScriptLibrary = {}

-- Configuração geral
local theme = {
    background = Color3.fromRGB(25, 25, 25),
    header = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(50, 50, 50),
    text = Color3.fromRGB(240, 240, 240),
    border = Color3.fromRGB(70, 70, 70),
    highlight = Color3.fromRGB(100, 100, 100)
}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptLibrary"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Variáveis internas
local minimized = false

-- Função para arrastar
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Cabeçalho elegante
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 450, 0, 300)
frame.Position = UDim2.new(0.5, -225, 0.5, -150)
frame.BackgroundColor3 = theme.background
frame.BorderSizePixel = 1
frame.BorderColor3 = theme.border
frame.Parent = screenGui

MakeDraggable(frame)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = theme.header
header.BorderSizePixel = 0
header.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "ScriptLibrary"
title.TextColor3 = theme.text
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Position = UDim2.new(0.5, -50, 0, 0)
title.Size = UDim2.new(0, 100, 1, 0)
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "–"
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
minimizeBtn.BackgroundColor3 = theme.accent
minimizeBtn.BorderSizePixel = 0
minimizeBtn.TextColor3 = theme.text
minimizeBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = theme.accent
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = theme.text
closeBtn.Parent = header

local tabsContainer = Instance.new("Frame")
tabsContainer.Position = UDim2.new(0, 0, 0, 30)
tabsContainer.Size = UDim2.new(1, 0, 0, 30)
tabsContainer.BackgroundColor3 = theme.accent
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = frame

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.Size = UDim2.new(1, 0, 1, -60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

-- Botão de minimizar
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        contentFrame.Visible = false
        tabsContainer.Visible = false
        minimizeBtn.Text = "□"
        frame.Size = UDim2.new(0, 450, 0, 30)
    else
        contentFrame.Visible = true
        tabsContainer.Visible = true
        minimizeBtn.Text = "–"
        frame.Size = UDim2.new(0, 450, 0, 300)
    end
end)

-- Botão de fechar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Função para criar abas
function ScriptLibrary:AddTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Text = tabName
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.BackgroundColor3 = theme.accent
    tabBtn.BorderSizePixel = 0
    tabBtn.TextColor3 = theme.text
    tabBtn.Parent = tabsContainer

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = contentFrame

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 4)
    uiList.Parent = tabContent

    tabBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = false
            end
        end
        tabContent.Visible = true
    end)

    local tabAPI = {}

    function tabAPI:CreateLabel(text)
        local label = Instance.new("TextLabel")
        label.Text = text
        label.TextColor3 = theme.text
        label.BackgroundColor3 = theme.background
        label.BorderColor3 = theme.border
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Parent = tabContent
        return label
    end

    function tabAPI:CreateToggle(text, callback)
        local toggle = Instance.new("TextButton")
        toggle.Text = text.." [OFF]"
        toggle.TextColor3 = theme.text
        toggle.BackgroundColor3 = theme.background
        toggle.BorderColor3 = theme.border
        toggle.Size = UDim2.new(1, -10, 0, 25)
        toggle.Parent = tabContent

        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = text..(state and " [ON]" or " [OFF]")
            if callback then callback(state) end
        end)
        return toggle
    end

    function tabAPI:CreateButtonOnOff(text, callback)
        return tabAPI:CreateToggle(text, callback)
    end

    function tabAPI:CreateSlider(text, min, max, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -10, 0, 25)
        holder.BackgroundColor3 = theme.background
        holder.BorderColor3 = theme.border
        holder.Parent = tabContent

        local label = Instance.new("TextLabel")
        label.Text = text..": "..min
        label.TextColor3 = theme.text
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Parent = holder

        local value = min
        holder.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                local con
                con = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or 
                       inp.UserInputType == Enum.UserInputType.Touch then
                        local rel = inp.Position.X - holder.AbsolutePosition.X
                        local percent = math.clamp(rel / holder.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * percent)
                        label.Text = text..": "..value
                        if callback then callback(value) end
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        con:Disconnect()
                    end
                end)
            end
        end)
        return holder
    end

    function tabAPI:CreateDropdown(text, items, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text.." ▼"
        btn.TextColor3 = theme.text
        btn.BackgroundColor3 = theme.background
        btn.BorderColor3 = theme.border
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Parent = tabContent

        local open = false
        local list = {}

        btn.MouseButton1Click:Connect(function()
            open = not open
            btn.Text = text..(open and " ▲" or " ▼")
            for _, i in ipairs(list) do i.Visible = open end
        end)

        for _, item in ipairs(items) do
            local opt = Instance.new("TextButton")
            opt.Text = item
            opt.TextColor3 = theme.text
            opt.BackgroundColor3 = theme.background
            opt.BorderColor3 = theme.border
            opt.Size = UDim2.new(1, -20, 0, 25)
            opt.Visible = false
            opt.Parent = tabContent
            table.insert(list, opt)

            opt.MouseButton1Click:Connect(function()
                if callback then callback(item) end
                open = false
                btn.Text = text.." ▼"
                for _, i in ipairs(list) do i.Visible = false end
            end)
        end
        return btn
    end

    function tabAPI:CreateDropdownButtonOnOff(text, items, callback)
        return tabAPI:CreateDropdown(text, items, callback)
    end

    return tabAPI
end

return ScriptLibrary
