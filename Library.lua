--[[
    GuiMenuLibrary.lua
    Biblioteca para criar menus GUI em executores como Delta via loadstring.
    Design aprimorado, Slider, DropdownButtonOnOff, DropdownButton.
    Bugs corrigidos: sombra branca e arrasto touch.
    Desenvolvido por: dhsoares01
--]]

local GuiMenuLibrary = {}
GuiMenuLibrary.__index = GuiMenuLibrary

local UserInputService = game:GetService("UserInputService")

local function create(class, props)
    local inst = Instance.new(class)
    for prop, val in pairs(props or {}) do
        inst[prop] = val
    end
    return inst
end

-- Arrasto só no fundo do menu, não nas abas/conteúdo/topbar/botões, suportando mouse e toque (dedo)
local function setupSmartDrag(MainFrame, disallowAreas)
    local dragging = false
    local dragStart, startPos
    local dragTouchId = nil

    local function isInDisallowArea(pos)
        for _, area in ipairs(disallowAreas) do
            if area and area.Visible ~= false then
                local absPos = area.AbsolutePosition
                local absSize = area.AbsoluteSize
                if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                    return true
                end
            end
        end
        return false
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not isInDisallowArea(input.Position) then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                local conn; conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if conn then conn:Disconnect() end
                    end
                end)
            end
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if not isInDisallowArea(input.Position) and not dragging then
                dragging = true
                dragTouchId = input.TouchId
                dragStart = input.Position
                startPos = MainFrame.Position
                local conn; conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        dragTouchId = nil
                        if conn then conn:Disconnect() end
                    end
                end)
            end
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.TouchMoved:Connect(function(input)
        if dragging and dragTouchId and input.TouchId == dragTouchId then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function GuiMenuLibrary:CreateMenu(options)
    if game.CoreGui:FindFirstChild("DGuiMenu") then
        game.CoreGui.DGuiMenu:Destroy()
    end

    local ScreenGui = create("ScreenGui", {
        Name = "DGuiMenu",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    -- Sombra suave (correção: Shadow atrás do MainFrame)
    local MainSize = UDim2.new(0, 410, 0, 280)
    local MainAnchor = Vector2.new(0.5, 0.5)
    local MainPos = UDim2.new(0.5, 0, 0.5, 0)

    local Shadow = create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        BackgroundTransparency = 1,
        ImageTransparency = 0.35,
        Size = UDim2.new(0, 430, 0, 300),
        Position = MainPos,
        AnchorPoint = MainAnchor,
        ZIndex = 0,
        Parent = ScreenGui
    })

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(22, 23, 36),
        BorderSizePixel = 0,
        Size = MainSize,
        Position = MainPos,
        AnchorPoint = MainAnchor,
        Parent = ScreenGui,
        ZIndex = 1,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    create("UIStroke", {Color = Color3.fromRGB(40,90,255), Thickness = 2, Parent = MainFrame})

    local TopBar = create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Color3.fromRGB(30, 32, 50),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TopBar})

    local Title = create("TextLabel", {
        Text = options.Title or "Menu",
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextSize = 19,
        Size = UDim2.new(1, -72, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local CloseBtn = create("TextButton", {
        Name = "CloseBtn",
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 24,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -36, 0, 0),
        Parent = TopBar
    })
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinBtn = create("TextButton", {
        Name = "MinBtn",
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 24,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -72, 0, 0),
        Parent = TopBar
    })

    local TabsFrame = create("Frame", {
        Name = "TabsFrame",
        BackgroundColor3 = Color3.fromRGB(29, 30, 45),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 110, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabsFrame})

    local TabsList = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsFrame
    })
    TabsList.VerticalAlignment = Enum.VerticalAlignment.Top

    local ContentFrame = create("Frame", {
        Name = "ContentFrame",
        BackgroundColor3 = Color3.fromRGB(25, 26, 40),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 46),
        Size = UDim2.new(1, -130, 1, -56),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentFrame})

    -- Scroll
    local Scroll = create("ScrollingFrame", {
        Name = "Scroll",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(40,90,255),
        Parent = ContentFrame,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        TopImage = "rbxassetid://7445543660",
        BottomImage = "rbxassetid://7445543660",
    })

    local tabButtons = {}
    local pages = {}
    local function switchTab(tabIndex)
        for i, page in ipairs(pages) do
            page.Visible = (i == tabIndex)
            tabButtons[i].BackgroundColor3 = i == tabIndex and Color3.fromRGB(40, 80, 255) or Color3.fromRGB(45, 45, 55)
            tabButtons[i].TextColor3 = i == tabIndex and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,200)
        end
    end

    for i, tab in ipairs(options.Tabs or { {Name = "Aba 1", Elements = {}} }) do
        local btn = create("TextButton", {
            Text = tab.Name,
            Font = Enum.Font.GothamMedium,
            TextSize = 15,
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            TextColor3 = Color3.fromRGB(170,170,200),
            Size = UDim2.new(1, -20, 0, 36),
            Parent = TabsFrame,
            AutoButtonColor = false
        })
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
        btn.MouseButton1Click:Connect(function() switchTab(i) end)
        tabButtons[i] = btn

        local page = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = Scroll
        })

        local layout = create("UIListLayout", {
            Padding = UDim.new(0,12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })

        for _, el in ipairs(tab.Elements or {}) do
            if el.Type == "Button" then
                local btn = create("TextButton", {
                    Text = el.Text or "Botão",
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    BackgroundColor3 = Color3.fromRGB(40, 90, 255),
                    TextColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(1, -10, 0, 36),
                    Parent = page,
                    AutoButtonColor = true
                })
                create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
                create("UIStroke", {Color = Color3.fromRGB(40,90,255), Thickness = 1, Transparency = 0.7, Parent = btn})
                if el.Callback then
                    btn.MouseButton1Click:Connect(el.Callback)
                end

            elseif el.Type == "Label" then
                local lbl = create("TextLabel", {
                    Text = el.Text or "Texto",
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(210,210,230),
                    Size = UDim2.new(1, -6, 0, 24),
                    Parent = page,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

            elseif el.Type == "Toggle" then
                local togFrame = create("Frame", {
                    Size = UDim2.new(1, -10, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = page
                })
                local togBtn = create("TextButton", {
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 90),
                    Size = UDim2.new(0, 36, 0, 36),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = togFrame,
                    AutoButtonColor = true
                })
                create("UICorner", {CornerRadius = UDim.new(1,0), Parent = togBtn})

                local on = el.State or false
                local function update()
                    togBtn.BackgroundColor3 = on and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(50, 50, 90)
                end
                togBtn.MouseButton1Click:Connect(function()
                    on = not on
                    update()
                    if el.Callback then el.Callback(on) end
                end)
                update()

                create("TextLabel", {
                    Text = el.Text or "Toggle",
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(210,210,230),
                    Size = UDim2.new(1, -44, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    Parent = togFrame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

            elseif el.Type == "Slider" then
                local sliderFrame = create("Frame", {
                    Size = UDim2.new(1, -10, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = page
                })
                local title = create("TextLabel", {
                    Text = (el.Text or "Slider").." ["..tostring(el.Value or el.Min or 0).."]",
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(210,210,230),
                    Size = UDim2.new(1, 0, 0, 14),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                local bar = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(43, 56, 108),
                    Size = UDim2.new(1, -10, 0, 8),
                    Position = UDim2.new(0, 5, 0, 20),
                    Parent = sliderFrame
                })
                create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})

                local fill = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(40, 90, 255),
                    Size = UDim2.new(0,0,1,0),
                    Position = UDim2.new(0,0,0,0),
                    Parent = bar,
                    ZIndex = 2
                })
                create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

                local knob = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(0,12,0,20),
                    Position = UDim2.new(0,0,0.5,-6),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Parent = bar,
                    ZIndex = 3
                })
                create("UICorner", {CornerRadius = UDim.new(1,0), Parent = knob})
                create("UIStroke", {Color = Color3.fromRGB(40,90,255), Thickness = 2, Parent = knob})

                local min, max, value = el.Min or 0, el.Max or 100, el.Value or 0
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    local percent = (value-min)/(max-min)
                    fill.Size = UDim2.new(percent,0,1,0)
                    knob.Position = UDim2.new(percent,0,0.5,-6)
                    title.Text = (el.Text or "Slider").." ["..tostring(math.floor(value*100)/100).."]"
                    if el.Callback then el.Callback(value) end
                end
                updateSlider(value)
                -- Mouse/touch drag
                local dragging = false
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local function setValueFromInput(pos)
                            local rel = (pos.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                            updateSlider(min+(max-min)*math.clamp(rel,0,1))
                        end
                        setValueFromInput(input.Position)
                        local conn1, conn2
                        conn1 = UserInputService.InputChanged:Connect(function(inp)
                            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                                setValueFromInput(inp.Position)
                            end
                        end)
                        conn2 = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                                if conn1 then conn1:Disconnect() end
                                if conn2 then conn2:Disconnect() end
                            end
                        end)
                    end
                end)

            elseif el.Type == "DropdownButtonOnOff" then
                local open = false
                local dropFrame = create("Frame", {
                    Size = UDim2.new(1, -10, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = page
                })

                local mainBtn = create("TextButton", {
                    Text = el.Text or "Dropdown",
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    BackgroundColor3 = Color3.fromRGB(40, 90, 255),
                    TextColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0,0,0,0),
                    Parent = dropFrame,
                    AutoButtonColor = true
                })
                create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainBtn})

                local optsFrame = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(30, 32, 50),
                    Size = UDim2.new(1, 0, 0, #el.Options*38),
                    Position = UDim2.new(0,0,1,0),
                    Visible = false,
                    Parent = dropFrame,
                    ZIndex = 10
                })
                create("UICorner", {CornerRadius = UDim.new(0,8), Parent = optsFrame})
                create("UIStroke", {Color = Color3.fromRGB(40,90,255), Transparency=0.7, Thickness=1, Parent = optsFrame})

                for i, opt in ipairs(el.Options or {}) do
                    local optFrame = create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 38),
                        Position = UDim2.new(0,0,0,(i-1)*38),
                        Parent = optsFrame,
                        ZIndex = 11
                    })
                    local btn = create("TextButton", {
                        Text = opt,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(210,210,230),
                        Size = UDim2.new(1, -40, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        Parent = optFrame,
                        ZIndex = 12
                    })
                    local onoffBtn = create("TextButton", {
                        Text = "OFF",
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        BackgroundColor3 = Color3.fromRGB(70, 70, 90),
                        TextColor3 = Color3.fromRGB(255,80,80),
                        Size = UDim2.new(0,34,0,26),
                        Position = UDim2.new(1, -36, 0.5, -13),
                        AnchorPoint = Vector2.new(0,0),
                        Parent = optFrame,
                        ZIndex = 12,
                        AutoButtonColor = true,
                    })
                    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = onoffBtn})
                    local isOn = false
                    onoffBtn.MouseButton1Click:Connect(function()
                        isOn = not isOn
                        onoffBtn.Text = isOn and "ON" or "OFF"
                        onoffBtn.BackgroundColor3 = isOn and Color3.fromRGB(40,180,90) or Color3.fromRGB(70,70,90)
                        onoffBtn.TextColor3 = isOn and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,80,80)
                        if el.Callback then el.Callback(opt, isOn) end
                    end)
                end

                mainBtn.MouseButton1Click:Connect(function()
                    open = not open
                    optsFrame.Visible = open
                end)

            elseif el.Type == "DropdownButton" then
                local open = false
                local dropFrame = create("Frame", {
                    Size = UDim2.new(1, -10, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = page
                })

                local mainBtn = create("TextButton", {
                    Text = el.Text or "Dropdown",
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    BackgroundColor3 = Color3.fromRGB(40, 90, 255),
                    TextColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0,0,0,0),
                    Parent = dropFrame,
                    AutoButtonColor = true
                })
                create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainBtn})

                local optsFrame = create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(30, 32, 50),
                    Size = UDim2.new(1, 0, 0, #el.Options*38),
                    Position = UDim2.new(0,0,1,0),
                    Visible = false,
                    Parent = dropFrame,
                    ZIndex = 10
                })
                create("UICorner", {CornerRadius = UDim.new(0,8), Parent = optsFrame})
                create("UIStroke", {Color = Color3.fromRGB(40,90,255), Transparency=0.7, Thickness=1, Parent = optsFrame})

                for i, opt in ipairs(el.Options or {}) do
                    local optFrame = create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 38),
                        Position = UDim2.new(0,0,0,(i-1)*38),
                        Parent = optsFrame,
                        ZIndex = 11
                    })
                    local btn = create("TextButton", {
                        Text = opt,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(210,210,230),
                        Size = UDim2.new(1, -40, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        Parent = optFrame,
                        ZIndex = 12
                    })
                    local goBtn = create("TextButton", {
                        Text = ">",
                        Font = Enum.Font.GothamBold,
                        TextSize = 16,
                        BackgroundColor3 = Color3.fromRGB(40, 90, 255),
                        TextColor3 = Color3.fromRGB(255,255,255),
                        Size = UDim2.new(0,34,0,26),
                        Position = UDim2.new(1, -36, 0.5, -13),
                        AnchorPoint = Vector2.new(0,0),
                        Parent = optFrame,
                        ZIndex = 12,
                        AutoButtonColor = true,
                    })
                    create("UICorner", {CornerRadius = UDim.new(1,0), Parent = goBtn})
                    goBtn.MouseButton1Click:Connect(function()
                        if el.Callback then el.Callback(opt) end
                    end)
                end

                mainBtn.MouseButton1Click:Connect(function()
                    open = not open
                    optsFrame.Visible = open
                end)
            end
        end
        pages[i] = page
    end
    switchTab(1)

    -- Áreas que NÃO permitem drag
    local disallowAreas = {TopBar, TabsFrame, ContentFrame, CloseBtn, MinBtn}
    setupSmartDrag(MainFrame, disallowAreas)

    -- Função de recolher/expandir menu
    local expanded = true
    local originalSize = MainFrame.Size
    local collapsedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, TopBar.Size.Y.Offset or 36)
    local originalTabsVisible = true
    local originalContentVisible = true

    MinBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if not expanded then
            -- Recolher: esconder abas e conteúdo, diminuir tamanho
            originalTabsVisible = TabsFrame.Visible
            originalContentVisible = ContentFrame.Visible
            TabsFrame.Visible = false
            ContentFrame.Visible = false
            MainFrame.Size = collapsedSize
            MinBtn.Text = "+"
        else
            -- Expandir: mostrar abas e conteúdo, restaurar tamanho
            TabsFrame.Visible = originalTabsVisible
            ContentFrame.Visible = originalContentVisible
            MainFrame.Size = originalSize
            MinBtn.Text = "—"
        end
    end)

    return ScreenGui
end

return GuiMenuLibrary
