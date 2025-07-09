-- ScriptLibrary.lua
local ScriptLibrary = {}

-- Tema dark refinado
local theme = {
    background = Color3.fromRGB(28, 28, 28),
    header = Color3.fromRGB(35, 35, 35),
    accent = Color3.fromRGB(50, 50, 50),
    text = Color3.fromRGB(230, 230, 230),
    border = Color3.fromRGB(60, 60, 60),
    highlight = Color3.fromRGB(90, 90, 90)
}

local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "ScriptLibrary"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local minimized = false

-- Função para permitir arrastar (mobile e PC)
local function MakeDraggable(frame)
    local dragging, dragStart, startPos

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

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 🖼 Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 480, 0, 320)
frame.Position = UDim2.new(0.5, -240, 0.5, -160)
frame.BackgroundColor3 = theme.background
frame.BorderColor3 = theme.border
frame.BorderSizePixel = 1
frame.Parent = gui
MakeDraggable(frame)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = theme.header
header.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "ScriptLibrary"
title.TextColor3 = theme.text
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 0)
title.Size = UDim2.new(0, 120, 1, 0)
title.Parent = header

-- Botões
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "–"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
minimizeBtn.BackgroundColor3 = theme.accent
minimizeBtn.BorderSizePixel = 0
minimizeBtn.TextColor3 = theme.text
minimizeBtn.Parent = header

local closeBtn = minimizeBtn:Clone()
closeBtn.Text = "×"
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Parent = header

-- Tabs Container
local tabs = Instance.new("Frame")
tabs.Position = UDim2.new(0, 0, 0, 32)
tabs.Size = UDim2.new(1, 0, 0, 28)
tabs.BackgroundColor3 = theme.accent
tabs.Parent = frame

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 0, 0, 60)
content.Size = UDim2.new(1, 0, 1, -60)
content.BackgroundTransparency = 1
content.Parent = frame

-- Layout mais flat e minimalista
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame

-- Minimizar
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        content.Visible = false
        tabs.Visible = false
        minimizeBtn.Text = "□"
        frame.Size = UDim2.new(0, 480, 0, 32)
    else
        content.Visible = true
        tabs.Visible = true
        minimizeBtn.Text = "–"
        frame.Size = UDim2.new(0, 480, 0, 320)
    end
end)

-- Fechar
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Função para criar tabs
function ScriptLibrary:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 14
    tabBtn.TextColor3 = theme.text
    tabBtn.BackgroundColor3 = theme.accent
    tabBtn.BorderSizePixel = 0
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.Parent = tabs

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = content

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = tabContent
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabBtn.MouseButton1Click:Connect(function()
        for _, c in pairs(content:GetChildren()) do
            if c:IsA("Frame") then c.Visible = false end
        end
        tabContent.Visible = true
    end)

    -- API da aba
    local api = {}

    function api:CreateLabel(txt)
        local lbl = Instance.new("TextLabel")
        lbl.Text = txt
        lbl.TextColor3 = theme.text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.BackgroundColor3 = theme.background
        lbl.BorderColor3 = theme.border
        lbl.Size = UDim2.new(1, -12, 0, 24)
        lbl.Parent = tabContent
        return lbl
    end

    function api:CreateToggle(txt, cb)
        local btn = Instance.new("TextButton")
        btn.Text = txt.." [OFF]"
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = theme.text
        btn.BackgroundColor3 = theme.background
        btn.BorderColor3 = theme.border
        btn.Size = UDim2.new(1, -12, 0, 24)
        btn.Parent = tabContent

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = txt..(state and " [ON]" or " [OFF]")
            if cb then cb(state) end
        end)
        return btn
    end

    function api:CreateButtonOnOff(txt, cb)
        return api:CreateToggle(txt, cb)
    end

    function api:CreateSlider(txt, min, max, cb)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -12, 0, 24)
        frame.BackgroundColor3 = theme.background
        frame.BorderColor3 = theme.border
        frame.Parent = tabContent

        local lbl = Instance.new("TextLabel")
        lbl.Text = txt..": "..min
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextColor3 = theme.text
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Parent = frame

        local value = min
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                local con
                con = UIS.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or
                       inp.UserInputType == Enum.UserInputType.Touch then
                        local rel = inp.Position.X - frame.AbsolutePosition.X
                        local pct = math.clamp(rel / frame.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * pct)
                        lbl.Text = txt..": "..value
                        if cb then cb(value) end
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        con:Disconnect()
                    end
                end)
            end
        end)
        return frame
    end

    function api:CreateDropdown(txt, items, cb)
        local mainBtn = Instance.new("TextButton")
        mainBtn.Text = txt.." ▼"
        mainBtn.Font = Enum.Font.Gotham
        mainBtn.TextSize = 14
        mainBtn.TextColor3 = theme.text
        mainBtn.BackgroundColor3 = theme.background
        mainBtn.BorderColor3 = theme.border
        mainBtn.Size = UDim2.new(1, -12, 0, 24)
        mainBtn.Parent = tabContent

        local open = false
        local opts = {}

        mainBtn.MouseButton1Click:Connect(function()
            open = not open
            mainBtn.Text = txt..(open and " ▲" or " ▼")
            for _, o in ipairs(opts) do o.Visible = open end
        end)

        for _, item in ipairs(items) do
            local opt = Instance.new("TextButton")
            opt.Text = item
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 14
            opt.TextColor3 = theme.text
            opt.BackgroundColor3 = theme.background
            opt.BorderColor3 = theme.border
            opt.Size = UDim2.new(1, -24, 0, 22)
            opt.Visible = false
            opt.Parent = tabContent
            table.insert(opts, opt)

            opt.MouseButton1Click:Connect(function()
                if cb then cb(item) end
                open = false
                mainBtn.Text = txt.." ▼"
                for _, o in ipairs(opts) do o.Visible = false end
            end)
        end
        return mainBtn
    end

    function api:CreateDropdownButtonOnOff(txt, items, cb)
        return api:CreateDropdown(txt, items, cb)
    end

    return api
end

return ScriptLibrary
