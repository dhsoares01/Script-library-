--[[
    Menu Library - Draggable, Collapsible, and Closable Menu UI
    Theme: Dark with subtle elegant borders.
    Components: Toggle, ButtonOnOff, Slider, Dropdown Button, Dropdown ButtonOnOff, Label.
    Touch-friendly and optimized for executors like Delta.
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/SEUUSUARIO/SUAREPO/main/menu_library.lua"))()
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local MenuLib = {}
MenuLib.__index = MenuLib

-- === CONFIG ===
local THEME = {
    MenuBg     = Color3.fromRGB(28, 28, 34),
    Border     = Color3.fromRGB(46, 46, 56),
    Accent     = Color3.fromRGB(49, 132, 255),
    Header     = Color3.fromRGB(36, 36, 46),
    TabBg      = Color3.fromRGB(22, 22, 28),
    TabSelected= Color3.fromRGB(38, 110, 255),
    TabText    = Color3.fromRGB(200, 200, 210),
    TabSelText = Color3.fromRGB(255, 255, 255),
    ContentBg  = Color3.fromRGB(18, 18, 22),
    LabelText  = Color3.fromRGB(210, 210, 220),
    ButtonOn   = Color3.fromRGB(39, 170, 100),
    ButtonOff  = Color3.fromRGB(53, 53, 60),
    SliderBar  = Color3.fromRGB(60, 60, 68),
    SliderFill = Color3.fromRGB(49, 132, 255),
    DropdownBg = Color3.fromRGB(30, 30, 38),
    Shadow     = Color3.fromRGB(0,0,0),
}

local function create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- === DRAG FUNCTIONALITY ===
local function make_draggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === MAIN CONSTRUCTOR ===
function MenuLib:Create(title)
    -- Destroy any existing menu
    if game.CoreGui:FindFirstChild("MenuLibraryMain") then
        game.CoreGui.MenuLibraryMain:Destroy()
    end

    local ScreenGui = create("ScreenGui", {
        Name = "MenuLibraryMain",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = game:GetService("CoreGui")
    })

    -- Shadow
    local Shadow = create("Frame", {
        BackgroundColor3 = THEME.Shadow,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 440, 0, 320),
        Position = UDim2.new(0.5, 10, 0.5, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })

    -- Main Frame
    local Main = create("Frame", {
        Name = "MenuFrame",
        BackgroundColor3 = THEME.MenuBg,
        BorderColor3 = THEME.Border,
        BorderSizePixel = 2,
        Size = UDim2.new(0, 420, 0, 300),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })

    make_draggable(Main)
    make_draggable(Shadow)

    -- Header
    local Header = create("Frame", {
        BackgroundColor3 = THEME.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,38),
        Parent = Main
    })
    make_draggable(Header)

    create("UICorner", {CornerRadius = UDim.new(0,9), Parent = Main})

    local Title = create("TextLabel", {
        Text = title or "Menu",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = THEME.LabelText,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0,0.5),
        Position = UDim2.new(0,16, 0.5, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Parent = Header
    })

    -- Minimize/Expand Button
    local MinBtn = create("TextButton", {
        Text = "–",
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        TextColor3 = THEME.LabelText,
        BackgroundColor3 = THEME.Header,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -40, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        Parent = Header
    })

    -- Close Button
    local CloseBtn = create("TextButton", {
        Text = "×",
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        TextColor3 = THEME.LabelText,
        BackgroundColor3 = THEME.Header,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        Parent = Header
    })

    -- Tab Area
    local TabArea = create("Frame", {
        BackgroundColor3 = THEME.TabBg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 110, 1, -38),
        Position = UDim2.new(0,0,0,38),
        Parent = Main
    })
    local TabLayout = create("UIListLayout", {Parent=TabArea, Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})

    -- Content Area (Right)
    local ContentArea = create("Frame", {
        BackgroundColor3 = THEME.ContentBg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -110, 1, -38),
        Position = UDim2.new(0,110,0,38),
        Parent = Main,
        ClipsDescendants = true
    })

    -- ScrollView
    local Scroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        Parent = ContentArea
    })
    local ScrollLayout = create("UIListLayout", {
        Parent = Scroll,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    -- Hide/Show Logic
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0,180,0,46)
            Shadow.Size = UDim2.new(0,200,0,66)
            ContentArea.Visible = false
            TabArea.Visible = false
            MinBtn.Text = "+"
        else
            Main.Size = UDim2.new(0,420,0,300)
            Shadow.Size = UDim2.new(0,440,0,320)
            ContentArea.Visible = true
            TabArea.Visible = true
            MinBtn.Text = "–"
        end
    end)

    -- Close Logic
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        for k,v in pairs(MenuLib) do
            if typeof(v)=="function" then MenuLib[k]=function() end end
        end
    end)

    -- === TABS ===
    local tabs = {}
    local currentTab = nil

    function MenuLib:Tab(name)
        local tab = create("TextButton", {
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = THEME.TabText,
            BackgroundColor3 = THEME.TabBg,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -12, 0, 32),
            Parent = TabArea,
            AutoButtonColor = false
        })

        local tabContent = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Scroll,
            Visible = false
        })

        local tabContentLayout = create("UIListLayout", {
            Parent = tabContent,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        tabs[name] = {Button = tab, Content = tabContent}

        tab.MouseButton1Click:Connect(function()
            for tabname, t in pairs(tabs) do
                t.Button.BackgroundColor3 = THEME.TabBg
                t.Button.TextColor3 = THEME.TabText
                t.Content.Visible = false
            end
            tab.BackgroundColor3 = THEME.TabSelected
            tab.TextColor3 = THEME.TabSelText
            tabContent.Visible = true
            currentTab = name
            Scroll.CanvasPosition = Vector2.new(0,0)
        end)

        -- First tab auto-select
        if not currentTab then
            tab.MouseButton1Click:Fire()
        end

        return setmetatable({
            AddToggle = function(_, label, default, callback)
                local frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 34),
                    Parent = tabContent
                })
                local tog = create("TextButton", {
                    Text = "",
                    BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff,
                    Size = UDim2.new(0,34,0,34),
                    Position = UDim2.new(0,0,0,0),
                    Parent = frame,
                    BorderSizePixel = 0,
                    AutoButtonColor = false
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=tog})
                local lbl = create("TextLabel", {
                    Text = label,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,40,0,0),
                    Size = UDim2.new(1, -44, 1, 0),
                    Parent = frame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                tog.MouseButton1Click:Connect(function()
                    default = not default
                    tog.BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff
                    if callback then callback(default) end
                end)
                make_draggable(frame)
            end,
            AddButtonOnOff = function(_, label, default, callback)
                local frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 34),
                    Parent = tabContent
                })
                local btn = create("TextButton", {
                    Text = default and "ON" or "OFF",
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff,
                    Size = UDim2.new(0,60,0,34),
                    Position = UDim2.new(0,0,0,0),
                    Parent = frame,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=btn})
                local lbl = create("TextLabel", {
                    Text = label,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,70,0,0),
                    Size = UDim2.new(1, -74, 1, 0),
                    Parent = frame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                btn.MouseButton1Click:Connect(function()
                    default = not default
                    btn.Text = default and "ON" or "OFF"
                    btn.BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff
                    if callback then callback(default) end
                end)
                make_draggable(frame)
            end,
            AddSlider = function(_, label, min, max, value, callback)
                local frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 48),
                    Parent = tabContent
                })
                local lbl = create("TextLabel", {
                    Text = label..": "..tostring(value),
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(1, 0, 0, 22),
                    Parent = frame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local bar = create("Frame", {
                    BackgroundColor3 = THEME.SliderBar,
                    Size = UDim2.new(1, -10, 0, 10),
                    Position = UDim2.new(0,0,0,28),
                    Parent = frame,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=bar})
                local fill = create("Frame", {
                    BackgroundColor3 = THEME.SliderFill,
                    Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
                    Position = UDim2.new(0,0,0,0),
                    Parent = bar,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=fill})

                local dragging = false
                local function update(x)
                    local rel = math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
                    local val = round(min + (max-min)*rel, 2)
                    fill.Size = UDim2.new(rel,0,1,0)
                    lbl.Text = label..": "..tostring(val)
                    if callback then callback(val) end
                end
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input.Position.X)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input.Position.X)
                    end
                end)
                make_draggable(frame)
            end,
            AddDropdown = function(_, label, items, selected, callback)
                local frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 40),
                    Parent = tabContent
                })
                local lbl = create("TextLabel", {
                    Text = label,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Parent = frame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local btn = create("TextButton", {
                    Text = items[selected] or "Select",
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundColor3 = THEME.DropdownBg,
                    Size = UDim2.new(0,70,0,32),
                    Position = UDim2.new(1, -74, 0, 4),
                    AnchorPoint = Vector2.new(1,0),
                    Parent = frame,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=btn})

                local open = false
                local dropdown = create("Frame", {
                    BackgroundColor3 = THEME.DropdownBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1,-74,1,0),
                    Size = UDim2.new(0,70,0,#items*28),
                    Visible = false,
                    Parent = frame
                })
                create("UICorner", {CornerRadius=UDim.new(0,6),Parent=dropdown})

                for i,v in ipairs(items) do
                    local opt = create("TextButton", {
                        Text = v,
                        Font = Enum.Font.Gotham,
                        TextSize = 15,
                        TextColor3 = THEME.LabelText,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1,0,0,28),
                        Position = UDim2.new(0,0,0,(i-1)*28),
                        Parent = dropdown,
                        BorderSizePixel = 0
                    })
                    opt.MouseButton1Click:Connect(function()
                        btn.Text = v
                        dropdown.Visible = false
                        open = false
                        if callback then callback(i, v) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    open = not open
                    dropdown.Visible = open
                end)
                make_draggable(frame)
            end,
            AddDropdownOnOff = function(_, label, items, default, callback)
                local frame = create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 44),
                    Parent = tabContent
                })
                local lbl = create("TextLabel", {
                    Text = label,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(1, -120, 1, 0),
                    Parent = frame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local btn = create("TextButton", {
                    Text = default and "ON" or "OFF",
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff,
                    Size = UDim2.new(0,44,0,32),
                    Position = UDim2.new(1, -116, 0, 6),
                    AnchorPoint = Vector2.new(1,0),
                    Parent = frame,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=btn})
                local ddBtn = create("TextButton", {
                    Text = items[1] or "Select",
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextColor3 = THEME.LabelText,
                    BackgroundColor3 = THEME.DropdownBg,
                    Size = UDim2.new(0,64,0,32),
                    Position = UDim2.new(1, -44, 0, 6),
                    AnchorPoint = Vector2.new(1,0),
                    Parent = frame,
                    BorderSizePixel = 0
                })
                create("UICorner", {CornerRadius=UDim.new(1,0),Parent=ddBtn})

                local open = false
                local dropdown = create("Frame", {
                    BackgroundColor3 = THEME.DropdownBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1,-44,1,0),
                    Size = UDim2.new(0,64,0,#items*28),
                    Visible = false,
                    Parent = frame
                })
                create("UICorner", {CornerRadius=UDim.new(0,6),Parent=dropdown})

                for i,v in ipairs(items) do
                    local opt = create("TextButton", {
                        Text = v,
                        Font = Enum.Font.Gotham,
                        TextSize = 15,
                        TextColor3 = THEME.LabelText,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1,0,0,28),
                        Position = UDim2.new(0,0,0,(i-1)*28),
                        Parent = dropdown,
                        BorderSizePixel = 0
                    })
                    opt.MouseButton1Click:Connect(function()
                        ddBtn.Text = v
                        dropdown.Visible = false
                        open = false
                        if callback then callback(btn.Text=="ON", v) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    default = not default
                    btn.Text = default and "ON" or "OFF"
                    btn.BackgroundColor3 = default and THEME.ButtonOn or THEME.ButtonOff
                    if callback then callback(default, ddBtn.Text) end
                end)
                ddBtn.MouseButton1Click:Connect(function()
                    open = not open
                    dropdown.Visible = open
                end)
                make_draggable(frame)
            end,
            AddLabel = function(_, text)
                local lbl = create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 15,
                    TextColor3 = THEME.LabelText,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 22),
                    Parent = tabContent,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                make_draggable(lbl)
            end
        }, {__index = MenuLib})
    end

    return MenuLib
end

return setmetatable(MenuLib, {
    __call = function(_, ...)
        return MenuLib:Create(...)
    end
})
