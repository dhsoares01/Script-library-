--[[
    DarkMenuLib
    Biblioteca de menu customizável para Lua
    Compatível com executores como Delta (Roblox/LuaU)
    Carregue via loadstring, ex:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/DarkMenuLib.lua"))()

    Uso:
        local menu = DarkMenuLib:Create{
            Title = "Meu Menu",
            Tabs = {
                { Name = "Config", Icon = "⚙️" },
                { Name = "Visual", Icon = "🎨" }
            }
        }

        menu:AddToggle("Config", "Ativar função", false, function(on) print("Toggle", on) end)
        menu:AddButtonOnOff("Config", "Iniciar", function(on) print("ButtonOnOff", on) end)
        menu:AddSlider("Visual", "Transparência", 0, 1, 0.5, function(val) print("Slider", val) end)
        menu:AddDropdown("Config", "Opções", {"A", "B", "C"}, function(opt) print("Dropdown", opt) end)
        menu:AddDropdownOnOff("Visual", "Cores", {"Vermelho", "Verde"}, function(opt, on) print("DropdownOnOff", opt, on) end)
        menu:AddLabel("Config", "Créditos: dhsoares01")
]]

if _G.__DarkMenuLib then return _G.__DarkMenuLib end

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local DarkMenuLib = {}
DarkMenuLib.__index = DarkMenuLib

local Theme = {
    Main = Color3.fromRGB(34, 34, 40),
    Accent = Color3.fromRGB(55, 90, 145),
    Border = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(230, 230, 230),
    Secondary = Color3.fromRGB(52, 52, 60),
    Button = Color3.fromRGB(38, 38, 46)
}

local function Make(instance, props)
    local obj = Instance.new(instance)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

local function Dragify(frame, dragArea)
    local dragging, dragInput, startPos, startInput
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPos = frame.Position

            local function EndDrag()
                dragging = false
            end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then EndDrag() end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function DarkMenuLib:Create(opts)
    opts = opts or {}
    local self = setmetatable({}, DarkMenuLib)
    self.Tabs = opts.Tabs or { { Name = "Main", Icon = "" } }
    self._ContentFrames = {}
    self._Callbacks = {}
    self._Active = true

    -- Main GUI
    local Main = Make("ScreenGui", { Name = "DarkMenuLib_"..tostring(math.random(10000,99999)), ResetOnSpawn=false })
    Main.Parent = game:GetService("CoreGui")

    local Border = Make("Frame", {
        Name = "Border",
        Size = UDim2.new(0, 415, 0, 315),
        Position = UDim2.new(0.5, -210, 0.5, -150),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5,0.5),
        Active = true,
        Draggable = false,
        Parent = Main
    })
    local Shadow = Make("UICorner", { CornerRadius = UDim.new(0,9), Parent = Border })
    Dragify(Border, Border)

    local Container = Make("Frame", {
        Name = "Container",
        Size = UDim2.new(1,-8,1,-8),
        Position = UDim2.new(0,4,0,4),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = Border
    })
    Make("UICorner", { CornerRadius = UDim.new(0,8), Parent = Container })

    -- Header
    local Header = Make("Frame", {
        Name = "Header",
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Container
    })
    Make("UICorner", { CornerRadius = UDim.new(0,8), Parent = Header })

    local Title = Make("TextLabel", {
        Name = "Title",
        Text = opts.Title or "DarkMenu",
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,16,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    local BtnMin = Make("TextButton", {
        Name = "MinBtn",
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        Size = UDim2.new(0,32,1,0),
        Position = UDim2.new(1,-64,0,0),
        BackgroundColor3 = Theme.Button,
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = Header
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = BtnMin })

    local BtnClose = Make("TextButton", {
        Name = "CloseBtn",
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        Size = UDim2.new(0,32,1,0),
        Position = UDim2.new(1,-32,0,0),
        BackgroundColor3 = Color3.fromRGB(150,40,40),
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = Header
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = BtnClose })

    -- Tabs (Left)
    local Tabs = Make("Frame", {
        Name = "Tabs",
        Size = UDim2.new(0, 94, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Container
    })
    Make("UICorner", { CornerRadius = UDim.new(0,7), Parent = Tabs })

    local TabList = Make("UIListLayout", {
        SortingOrder = Enum.SortingOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        Parent = Tabs
    })

    -- Main Content (Right)
    local Content = Make("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -102, 1, -46),
        Position = UDim2.new(0, 98, 0, 42),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Parent = Container
    })

    local ContentBorder = Make("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 0.7,
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = Content
    })
    Make("UICorner", { CornerRadius = UDim.new(0,8), Parent = ContentBorder })

    -- ScrollView
    local Scroll = Make("ScrollingFrame", {
        Name = "Scroll",
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0,8,0,8),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        Parent = Content
    })
    Make("UICorner", { CornerRadius = UDim.new(0,7), Parent = Scroll })

    local UIList = Make("UIListLayout", {
        Parent = Scroll,
        Padding = UDim.new(0,7),
        SortOrder = Enum.SortingOrder.LayoutOrder
    })

    -- Tabs
    self._TabButtons = {}
    for i,tab in ipairs(self.Tabs) do
        local btn = Make("TextButton", {
            Name = "TabBtn_"..tab.Name,
            Text = (tab.Icon and tab.Icon.." " or "")..tab.Name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 16,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1,-10,0,32),
            Position = UDim2.new(0,5,0,0),
            AutoButtonColor = true,
            BorderSizePixel = 0,
            Parent = Tabs
        })
        Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = btn })
        Dragify(Border, btn)
        self._TabButtons[tab.Name] = btn
        -- Each tab gets a Scroll frame as main content
        local tabFrame = Make("Frame", {
            Name = "Tab_"..tab.Name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Visible = (i==1),
            Parent = Scroll
        })
        local tabList = Make("UIListLayout", {
            Parent = tabFrame,
            Padding = UDim.new(0,6),
            SortOrder = Enum.SortingOrder.LayoutOrder
        })
        self._ContentFrames[tab.Name] = tabFrame

        btn.MouseButton1Click:Connect(function()
            -- Switch tabs
            for n,fr in pairs(self._ContentFrames) do
                fr.Visible = (n==tab.Name)
            end
            for n,tabbtn in pairs(self._TabButtons) do
                tabbtn.BackgroundColor3 = Theme.Secondary
            end
            btn.BackgroundColor3 = Theme.Main
        end)
        if i==1 then
            tabFrame.Visible = true
            btn.BackgroundColor3 = Theme.Main
        end
    end

    -- Minimize/Expand
    local minimized = false
    BtnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Border, TweenInfo.new(0.16), { Size = UDim2.new(0,110,0,45) }):Play()
            Container.Visible = false
            BtnMin.Text = "+"
        else
            TweenService:Create(Border, TweenInfo.new(0.18), { Size = UDim2.new(0,415,0,315) }):Play()
            Container.Visible = true
            BtnMin.Text = "–"
        end
    end)

    -- Close
    BtnClose.MouseButton1Click:Connect(function()
        self._Active = false
        Main:Destroy()
        for _,f in pairs(self._Callbacks) do
            if typeof(f)=="function" then
                pcall(f,false)
            end
        end
        _G.__DarkMenuLib = nil
    end)

    -- Dragging by header too
    Dragify(Border, Header)

    self._MainGui = Main
    self._Border = Border
    self._Container = Container
    self._Scroll = Scroll
    self._UIList = UIList
    self._CurrentTab = self.Tabs[1].Name

    -- Helper
    function self:_GetTabFrame(tab)
        return self._ContentFrames[tab or self._CurrentTab]
    end

    -- Add drag to all elements
    function self:AddDraggable(frame, dragArea)
        Dragify(Border, dragArea or frame)
    end

    return self
end

-- Components
function DarkMenuLib:AddToggle(tab, text, default, callback)
    local frame = Make("Frame", {
        Size = UDim2.new(1,-6,0,36),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self:_GetTabFrame(tab)
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = frame })

    local label = Make("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-40,1,0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    local btn = Make("TextButton", {
        Size = UDim2.new(0,34,0,20),
        Position = UDim2.new(1,-45,0.5,-10),
        BackgroundColor3 = default and Theme.Accent or Theme.Button,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = frame
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = btn })

    local circle = Make("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(default and 1 or 0, default and -18 or 2, 0.5, -8),
        AnchorPoint = Vector2.new(0,0),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Parent = btn
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = circle })

    local on = default and true or false
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(btn, TweenInfo.new(0.13), { BackgroundColor3 = on and Theme.Accent or Theme.Button }):Play()
        TweenService:Create(circle, TweenInfo.new(0.13), { Position = UDim2.new(on and 1 or 0, on and -18 or 2, 0.5, -8) }):Play()
        if callback then callback(on) end
    end)
    self._Callbacks[text] = callback
    return frame
end

function DarkMenuLib:AddButtonOnOff(tab, text, callback)
    local frame = Make("Frame", {
        Size = UDim2.new(1,-6,0,36),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self:_GetTabFrame(tab)
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = frame })

    local btn = Make("TextButton", {
        Text = text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Button,
        Size = UDim2.new(1,-12,1,-10),
        Position = UDim2.new(0,6,0,5),
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = frame
    })
    Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = btn })

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.BackgroundColor3 = on and Theme.Accent or Theme.Button
        if callback then callback(on) end
    end)
    self._Callbacks[text] = callback
    return frame
end

function DarkMenuLib:AddSlider(tab, text, min, max, default, callback)
    min, max, default = tonumber(min), tonumber(max), tonumber(default)
    local frame = Make("Frame", {
        Size = UDim2.new(1,-6,0,48),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self:_GetTabFrame(tab)
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = frame })

    local label = Make("TextLabel", {
        Text = ("%s [%0.2f]"):format(text, default),
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    local sliderBar = Make("Frame", {
        Size = UDim2.new(1,-32,0,8),
        Position = UDim2.new(0,16,0,30),
        BackgroundColor3 = Theme.Button,
        BorderSizePixel = 0,
        Parent = frame
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = sliderBar })
    local fill = Make("Frame", {
        Size = UDim2.new((default-min)/(max-min),0,1,0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = sliderBar
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })

    local knob = Make("Frame", {
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new((default-min)/(max-min),-8,0.5,-8),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Parent = sliderBar
    })
    Make("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })

    local dragging = false
    local function setVal(percent)
        percent = math.clamp(percent,0,1)
        local val = min + (max-min)*percent
        fill.Size = UDim2.new(percent,0,1,0)
        knob.Position = UDim2.new(percent,-8,0.5,-8)
        label.Text = ("%s [%0.2f]"):format(text, val)
        if callback then callback(val) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local px = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            setVal(px)
        end
    end)
    setVal((default-min)/(max-min))
    self._Callbacks[text] = callback
    return frame
end

function DarkMenuLib:AddDropdown(tab, text, choices, callback)
    local frame = Make("Frame", {
        Size = UDim2.new(1,-6,0,38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self:_GetTabFrame(tab)
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = frame })

    local btn = Make("TextButton", {
        Text = text.." ▼",
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Button,
        Size = UDim2.new(1,-12,1,-8),
        Position = UDim2.new(0,6,0,4),
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = frame,
        ClipsDescendants = true
    })
    Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = btn })

    local dropFrame = Make("Frame", {
        BackgroundColor3 = Theme.Button,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,#choices*28),
        Position = UDim2.new(0,0,1,0),
        Visible = false,
        Parent = btn
    })
    Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = dropFrame })

    for i, v in ipairs(choices) do
        local opt = Make("TextButton", {
            Text = tostring(v),
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Button,
            Size = UDim2.new(1,0,0,28),
            Position = UDim2.new(0,0,0,(i-1)*28),
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Parent = dropFrame
        })
        opt.MouseButton1Click:Connect(function()
            btn.Text = ("%s: %s ▼"):format(text, v)
            dropFrame.Visible = false
            if callback then callback(v) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
    self._Callbacks[text] = callback
    return frame
end

function DarkMenuLib:AddDropdownOnOff(tab, text, choices, callback)
    local frame = Make("Frame", {
        Size = UDim2.new(1,-6,0,38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self:_GetTabFrame(tab)
    })
    Make("UICorner", { CornerRadius = UDim.new(0,6), Parent = frame })

    local btn = Make("TextButton", {
        Text = text.." ▼",
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Button,
        Size = UDim2.new(1,-12,1,-8),
        Position = UDim2.new(0,6,0,4),
        BorderSizePixel = 0,
        AutoButtonColor = true,
        Parent = frame,
        ClipsDescendants = true
    })
    Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = btn })

    local dropFrame = Make("Frame", {
        BackgroundColor3 = Theme.Button,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,#choices*28),
        Position = UDim2.new(0,0,1,0),
        Visible = false,
        Parent = btn
    })
    Make("UICorner", { CornerRadius = UDim.new(0,5), Parent = dropFrame })

    for i, v in ipairs(choices) do
        local opt = Make("TextButton", {
            Text = tostring(v).." [OFF]",
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Button,
            Size = UDim2.new(1,0,0,28),
            Position = UDim2.new(0,0,0,(i-1)*28),
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Parent = dropFrame
        })
        local on = false
        opt.MouseButton1Click:Connect(function()
            on = not on
            opt.Text = tostring(v)..(on and " [ON]" or " [OFF]")
            opt.BackgroundColor3 = on and Theme.Accent or Theme.Button
            if callback then callback(v, on) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
    self._Callbacks[text] = callback
    return frame
end

function DarkMenuLib:AddLabel(tab, text)
    local label = Make("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-10,0,22),
        Position = UDim2.new(0,5,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self:_GetTabFrame(tab)
    })
    return label
end

_G.__DarkMenuLib = DarkMenuLib
return DarkMenuLib
