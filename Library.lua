--[[
    GuiMenuLibrary.lua
    Biblioteca para criar menus GUI em executores como Delta via loadstring.
    Layout inspirado em: https://user-images.githubusercontent.com/83477843/183228970-14b0d112-e01b-44c2-b4b7-5d483d3145be.png
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
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not isInDisallowArea(input.Position) then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                if input.UserInputType == Enum.UserInputType.Touch then
                    dragTouchId = input.TouchId
                end
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if input.UserInputType == Enum.UserInputType.Touch and dragTouchId and input.TouchId ~= dragTouchId then
                return
            end
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

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 410, 0, 280),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})

    local TopBar = create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TopBar})

    local Title = create("TextLabel", {
        Text = options.Title or "Menu",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextSize = 18,
        Size = UDim2.new(1, -64, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local CloseBtn = create("TextButton", {
        Name = "CloseBtn",
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 22,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 34, 1, 0),
        Position = UDim2.new(1, -34, 0, 0),
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
        TextSize = 22,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 34, 1, 0),
        Position = UDim2.new(1, -68, 0, 0),
        Parent = TopBar
    })

    local TabsFrame = create("Frame", {
        Name = "TabsFrame",
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 110, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabsFrame})

    local TabsList = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsFrame
    })
    TabsList.VerticalAlignment = Enum.VerticalAlignment.Top

    local ContentFrame = create("Frame", {
        Name = "ContentFrame",
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 44),
        Size = UDim2.new(1, -130, 1, -54),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ContentFrame})

    local tabButtons = {}
    local pages = {}
    local function switchTab(tabIndex)
        for i, page in ipairs(pages) do
            page.Visible = (i == tabIndex)
            tabButtons[i].BackgroundColor3 = i == tabIndex and Color3.fromRGB(40, 80, 255) or Color3.fromRGB(45, 45, 45)
            tabButtons[i].TextColor3 = i == tabIndex and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
        end
    end

    for i, tab in ipairs(options.Tabs or { {Name = "Aba 1", Elements = {}} }) do
        local btn = create("TextButton", {
            Text = tab.Name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            TextColor3 = Color3.fromRGB(200,200,200),
            Size = UDim2.new(1, -16, 0, 34),
            Parent = TabsFrame,
            AutoButtonColor = false
        })
        btn.MouseButton1Click:Connect(function() switchTab(i) end)
        tabButtons[i] = btn

        local page = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentFrame
        })

        local layout = create("UIListLayout", {
            Padding = UDim.new(0,8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })

        for _, el in ipairs(tab.Elements or {}) do
            if el.Type == "Button" then
                local btn = create("TextButton", {
                    Text = el.Text or "Botão",
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    BackgroundColor3 = Color3.fromRGB(35, 80, 220),
                    TextColor3 = Color3.fromRGB(255,255,255),
                    Size = UDim2.new(1, -10, 0, 34),
                    Parent = page,
                    AutoButtonColor = true
                })
                create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
                if el.Callback then
                    btn.MouseButton1Click:Connect(el.Callback)
                end
            elseif el.Type == "Label" then
                create("TextLabel", {
                    Text = el.Text or "Texto",
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(220,220,220),
                    Size = UDim2.new(1, -10, 0, 24),
                    Parent = page,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            elseif el.Type == "Toggle" then
                local togFrame = create("Frame", {
                    Size = UDim2.new(1, -10, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = page
                })
                local togBtn = create("TextButton", {
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = togFrame
                })
                create("UICorner", {CornerRadius = UDim.new(1,0), Parent = togBtn})

                local on = el.State or false
                local function update()
                    togBtn.BackgroundColor3 = on and Color3.fromRGB(40, 180, 90) or Color3.fromRGB(50, 50, 50)
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
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(200,200,200),
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 40, 0, 0),
                    Parent = togFrame,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
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
    local collapsedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, TopBar.Size.Y.Offset or 34)
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
