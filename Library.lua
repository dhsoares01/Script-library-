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

-- Função para arrastar frames (mouse e toque)
local function makeDraggable(frame, dragAreas)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput, dragStart, startPos
    local function inputInDragArea(input)
        for _, area in ipairs(dragAreas) do
            if area and area.Visible ~= false then
                local absPos = area.AbsolutePosition
                local absSize = area.AbsoluteSize
                if input.Position.X >= absPos.X and input.Position.X <= absPos.X + absSize.X
                and input.Position.Y >= absPos.Y and input.Position.Y <= absPos.Y + absSize.Y then
                    return true
                end
            end
        end
        return false
    end

    local function canDrag(input)
        -- Não permitir drag se for botão de fechar ou minimizar
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            return inputInDragArea(input)
        end
        return false
    end

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    local function begin(input)
        if not canDrag(input) then return end
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if connection then connection:Disconnect() end
            end
        end)
    end

    -- Mouse e toque
    frame.InputBegan:Connect(function(input)
        if canDrag(input) then
            begin(input)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    -- Suporte multi-toque: drag pelo dedo
    UserInputService.TouchMoved:Connect(function(input)
        if dragging then update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            update(input)
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

    -- Frame do menu (centralizado na tela)
    local MainFrame = create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 410, 0, 280),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })

    -- Arredondamento
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})

    -- Barra superior
    local TopBar = create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 0),
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
        Size = UDim2.new(1, -64, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    -- Botão fechar
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

    -- Botão minimizar (opcional, não implementado função, só reserva visual)
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
    -- MinBtn.MouseButton1Click:Connect(function() --[[minimizar se desejar]] end)

    -- Container lateral de abas
    local TabsFrame = create("Frame", {
        Name = "TabsFrame",
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
        Name = "ContentFrame",
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

    -- Áreas válidas para drag: MainFrame - exceto TopBar, TabsFrame, ContentFrame, CloseBtn, MinBtn
    -- Vamos criar uma "DragArea" invisível que cobre só o fundo do MainFrame exceto as zonas de conteúdo/topbar/tabs
    -- Prático: basta considerar MainFrame inteiro, mas ignorar eventos se forem dentro de TopBar, TabsFrame, ContentFrame, CloseBtn, MinBtn

    -- Áreas que NÃO permitem drag:
    local noDragAreas = {TopBar, TabsFrame, ContentFrame, CloseBtn, MinBtn}

    -- Áreas que PODEM iniciar drag: MainFrame, mas ignorando as acima
    -- Adaptar makeDraggable para só permitir drag se não estiver nessas áreas
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local insideNoDrag = false
            for _, area in ipairs(noDragAreas) do
                if area and area.Visible ~= false then
                    local absPos = area.AbsolutePosition
                    local absSize = area.AbsoluteSize
                    if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                    and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                        insideNoDrag = true
                        break
                    end
                end
            end
            if not insideNoDrag then
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
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
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

    return ScreenGui
end

return GuiMenuLibrary
