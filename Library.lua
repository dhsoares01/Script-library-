--[[
    GuiMenuLibrary.lua
    Biblioteca para criar menus GUI em executores como Delta via loadstring.
    Layout inspirado em: https://user-images.githubusercontent.com/83477843/183228970-14b0d112-e01b-44c2-b4b7-5d483d3145be.png
    Desenvolvido por: dhsoares01
--]]

local GuiMenuLibrary = {}
GuiMenuLibrary.__index = GuiMenuLibrary

-- Utilitário para criar instâncias rapidamente
local function create(class, props)
    local inst = Instance.new(class)
    for prop, val in pairs(props or {}) do
        inst[prop] = val
    end
    return inst
end

-- Função para arrastar frames
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, mousePos, framePos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Função principal para criar um menu
function GuiMenuLibrary:CreateMenu(options)
    -- Checa se já existe um menu
    if game.CoreGui:FindFirstChild("DGuiMenu") then
        game.CoreGui.DGuiMenu:Destroy()
    end

    -- Cria a tela principal
    local ScreenGui = create("ScreenGui", {
        Name = "DGuiMenu",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui")
    })

    -- Frame do menu
    local MainFrame = create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 410, 0, 280),
        Position = UDim2.new(0.5, -205, 0.5, -140),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })

    -- Arredondamento
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})

    -- Barra superior
    local TopBar = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TopBar})

    -- Título
    local Title = create("TextLabel", {
        Text = options.Title or "Menu",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextSize = 18,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    -- Botão fechar
    local CloseBtn = create("TextButton", {
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

    -- Drag
    makeDraggable(MainFrame, TopBar)

    -- Container lateral de abas
    local TabsFrame = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 110, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabsFrame})

    -- Layout das tabs
    local TabsList = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsFrame
    })
    TabsList.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Frame de conteúdo
    local ContentFrame = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 44),
        Size = UDim2.new(1, -130, 1, -54),
        Parent = MainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ContentFrame})

    -- Adiciona abas e páginas
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
        -- Botão lateral
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

        -- Página de conteúdo
        local page = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentFrame
        })

        -- Layout dos elementos
        local layout = create("UIListLayout", {
            Padding = UDim.new(0,8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })

        -- Adiciona elementos
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
    -- Mostra a primeira aba por padrão
    switchTab(1)
    return ScreenGui
end

return GuiMenuLibrary
