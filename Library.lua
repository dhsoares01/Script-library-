local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Cores personalizadas para um design parecido com a imagem
local ColorPalette = {
    Background = Color3.fromRGB(40, 40, 40),      -- Fundo geral da janela
    Header = Color3.fromRGB(50, 50, 50),          -- Fundo do cabeçalho
    TabHolder = Color3.fromRGB(35, 35, 35),       -- Fundo da área de abas (menu lateral)
    TabButton = Color3.fromRGB(35, 35, 35),       -- Cor normal do botão de aba
    TabButtonHover = Color3.fromRGB(45, 45, 45),  -- Cor do botão de aba ao passar o mouse
    TabButtonActive = Color3.fromRGB(40, 40, 40), -- Cor da aba ativa
    Content = Color3.fromRGB(40, 40, 40),         -- Fundo da área de conteúdo principal
    Text = Color3.fromRGB(230, 230, 230),         -- Cor geral do texto
    Accent = Color3.fromRGB(150, 90, 255),        -- Cor de destaque (para toques/seleção)
    Border = Color3.fromRGB(60, 60, 60),          -- Cor de bordas e divisores
    Button = Color3.fromRGB(60, 60, 60),          -- Cor do botão de ação
    ButtonHover = Color3.fromRGB(70, 70, 70),     -- Cor do botão de ação ao passar o mouse
    ToggleOff = Color3.fromRGB(80, 80, 80),       -- Cor do toggle desligado
    ToggleOn = Color3.fromRGB(120, 80, 180),      -- Cor do toggle ligado (roxo)
    Slider = Color3.fromRGB(60, 60, 60),          -- Cor da barra do slider
    SliderFill = Color3.fromRGB(120, 80, 180),    -- Cor do preenchimento do slider (roxo)
    UserProfileBackground = Color3.fromRGB(30, 30, 30), -- Fundo do perfil do usuário
    ProfileText = Color3.fromRGB(200, 200, 200)    -- Cor do texto do perfil
}

-- Icons from the image (replace with actual asset IDs if available)
local Icons = {
    Tab1 = "rbxassetid://13159047913", -- Placeholder: A simple square or circle
    Tab2 = "rbxassetid://13159048386", -- Placeholder: A star or diamond
    Premium = "rbxassetid://13159048897", -- Placeholder: A circle with a dot
    Fingerprint = "rbxassetid://13159049445", -- Placeholder: Fingerprint icon
    Avatar = "rbxassetid://13159049969" -- Placeholder: Default avatar icon
}

-- Function to load icons reliably (consider preloading or handling failures)
local function getIcon(assetId)
    local success, image = pcall(function()
        return "rbxassetid://" .. tostring(assetId)
    end)
    return success and image or "" -- Return empty string on failure
end

-- Função auxiliar para verificar entrada do ponteiro (mouse ou toque)
local function isPointerInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch
end

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OrionLibrary_" .. tostring(math.random(1000, 9999))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 350) -- Tamanho fixo para replicar a imagem
    Main.Position = UDim2.new(0.5, -275, 0.5, -175) -- Posição centralizada
    Main.BackgroundColor3 = ColorPalette.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.ClipsDescendants = true -- Para que o canto superior do Header seja arredondado com o Main

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8) -- Bordas arredondadas como na imagem
    UICorner.Parent = Main

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35) -- Altura menor
    Header.BackgroundColor3 = ColorPalette.Header
    Header.BorderSizePixel = 0
    Header.Parent = Main
    
    local HeaderTitleLabel = Instance.new("TextLabel")
    HeaderTitleLabel.Name = "TitleLabel"
    HeaderTitleLabel.Text = title or "Orion Library"
    HeaderTitleLabel.Size = UDim2.new(1, -70, 1, 0)
    HeaderTitleLabel.Position = UDim2.new(0, 10, 0, 0)
    HeaderTitleLabel.TextColor3 = ColorPalette.Text
    HeaderTitleLabel.BackgroundTransparency = 1
    HeaderTitleLabel.Font = Enum.Font.GothamBold -- Mais negrito como na imagem
    HeaderTitleLabel.TextSize = 16
    HeaderTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitleLabel.Parent = Header

    -- Botões de controle (X e -)
    local Close = Instance.new("TextButton")
    Close.Name = "CloseButton"
    Close.Text = "—" -- Usando traço em vez de X para minimizado na imagem
    Close.Size = UDim2.new(0, 25, 1, 0)
    Close.Position = UDim2.new(1, -25, 0, 0)
    Close.TextColor3 = ColorPalette.Text
    Close.Font = Enum.Font.SourceSansPro -- Fonte para o símbolo
    Close.TextSize = 20
    Close.BackgroundTransparency = 1
    Close.ZIndex = 2
    Close.Parent = Header

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local Minimize = Instance.new("TextButton")
    Minimize.Name = "MinimizeButton"
    Minimize.Text = "−" -- Símbolo de minimização
    Minimize.Size = UDim2.new(0, 25, 1, 0)
    Minimize.Position = UDim2.new(1, -50, 0, 0)
    Minimize.TextColor3 = ColorPalette.Text
    Minimize.Font = Enum.Font.SourceSansPro
    Minimize.TextSize = 20
    Minimize.BackgroundTransparency = 1
    Minimize.Parent = Header

    -- Área de abas (Painel esquerdo)
    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Position = UDim2.new(0, 0, 0, 35) -- Começa abaixo do header
    TabHolder.Size = UDim2.new(0, 160, 1, -35) -- Largura fixa para abas
    TabHolder.BackgroundColor3 = ColorPalette.TabHolder
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = Main

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.FillDirection = Enum.FillDirection.Vertical
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabHolder
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 5)
    TabPadding.Parent = TabHolder

    -- Área de conteúdo (Painel direito)
    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Position = UDim2.new(0, 160, 0, 35) -- Começa após as abas
    PageHolder.Size = UDim2.new(1, -160, 1, -35)
    PageHolder.BackgroundColor3 = ColorPalette.Content
    PageHolder.ClipsDescendants = true
    PageHolder.Parent = Main

    local Tabs = {}
    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 550, 0, 35) or UDim2.new(0, 550, 0, 350)
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play()

        -- Esconde/mostra elementos com base no estado minimizado
        TabHolder.Visible = not minimized
        PageHolder.Visible = not minimized
        HeaderTitleLabel.TextXAlignment = minimized and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    end)
    
    -- User profile section at the bottom of the TabHolder
    local UserProfileFrame = Instance.new("Frame")
    UserProfileFrame.Name = "UserProfileFrame"
    UserProfileFrame.Size = UDim2.new(1, 0, 0, 50)
    UserProfileFrame.Position = UDim2.new(0, 0, 1, -50) -- Posiciona no final do TabHolder
    UserProfileFrame.BackgroundColor3 = ColorPalette.UserProfileBackground
    UserProfileFrame.BorderSizePixel = 0
    UserProfileFrame.Parent = TabHolder

    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Name = "Avatar"
    UserAvatar.Size = UDim2.new(0, 32, 0, 32)
    UserAvatar.Position = UDim2.new(0, 10, 0.5, -16)
    UserAvatar.AnchorPoint = Vector2.new(0, 0.5)
    UserAvatar.Image = getIcon(Icons.Avatar) -- Default avatar image
    UserAvatar.BackgroundTransparency = 1
    Instance.new("UICorner", UserAvatar).CornerRadius = UDim.new(0.5, 0)
    UserAvatar.Parent = UserProfileFrame

    local UserNameLabel = Instance.new("TextLabel")
    UserNameLabel.Name = "UserName"
    UserNameLabel.Size = UDim2.new(0, 0, 1, 0) -- Adjust width based on content
    UserNameLabel.AutoSize = Enum.AutomaticSize.X
    UserNameLabel.Position = UDim2.new(0, 48, 0, 0)
    UserNameLabel.Text = "shlex"
    UserNameLabel.TextColor3 = ColorPalette.ProfileText
    UserNameLabel.BackgroundTransparency = 1
    UserNameLabel.Font = Enum.Font.GothamMedium
    UserNameLabel.TextSize = 14
    UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserNameLabel.TextYAlignment = Enum.TextYAlignment.Center
    UserNameLabel.Parent = UserProfileFrame
    
    local UserStatusLabel = Instance.new("TextLabel")
    UserStatusLabel.Name = "UserStatus"
    UserStatusLabel.Size = UDim2.new(0, 0, 1, 0) -- Adjust width based on content
    UserStatusLabel.AutoSize = Enum.AutomaticSize.X
    UserStatusLabel.Position = UDim2.new(0, 48 + UserNameLabel.AbsoluteSize.X + 5, 0, 0) -- Position next to username
    UserStatusLabel.Text = "Premium"
    UserStatusLabel.TextColor3 = ColorPalette.Accent
    UserStatusLabel.BackgroundTransparency = 1
    UserStatusLabel.Font = Enum.Font.GothamMedium
    UserStatusLabel.TextSize = 14
    UserStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserStatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    UserStatusLabel.Parent = UserProfileFrame
    
    -- Ensure UserNameLabel and UserStatusLabel are properly aligned vertically
    local UserLayout = Instance.new("UIListLayout")
    UserLayout.Padding = UDim.new(0, 5)
    UserLayout.FillDirection = Enum.FillDirection.Horizontal
    UserLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UserLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UserLayout.Parent = UserProfileFrame
    
    -- Remove AutomaticSize for UserNameLabel and UserStatusLabel if it causes issues with UIListLayout
    UserNameLabel.AutoSize = Enum.AutomaticSize.None
    UserNameLabel.Size = UDim2.new(0, 60, 1, 0) -- Fixed size for better layout with list layout
    UserStatusLabel.AutoSize = Enum.AutomaticSize.None
    UserStatusLabel.Size = UDim2.new(0, 60, 1, 0)

    -- Adjusted UIListLayout to place them side by side
    UserLayout.FillDirection = Enum.FillDirection.Horizontal
    UserLayout.Padding = UDim.new(0, 5)
    UserLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UserLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    -- Positioning of text labels in relation to the avatar
    UserNameLabel.Position = UDim2.new(0, 48, 0, 0)
    UserStatusLabel.Position = UDim2.new(0, 48 + UserNameLabel.AbsoluteSize.X + 5, 0, 0) -- Needs to be recalculated dynamically or fixed


    function Library:CreateTab(name, iconAssetId)
        local TabContainer = Instance.new("Frame")
        TabContainer.Name = name .. "TabContainer"
        TabContainer.Size = UDim2.new(1, -20, 0, 35) -- Slightly smaller to leave padding
        TabContainer.BackgroundTransparency = 1
        TabContainer.Parent = TabHolder
        
        local Button = Instance.new("TextButton")
        Button.Name = name .. "TabButton"
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Text = "" -- Text will be handled by a separate label for icon
        Button.BackgroundColor3 = ColorPalette.TabButton
        Button.AutoButtonColor = false
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
        Button.Parent = TabContainer

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        TabIcon.Image = getIcon(iconAssetId)
        TabIcon.ImageColor3 = ColorPalette.Text
        TabIcon.BackgroundTransparency = 1
        TabIcon.Parent = Button

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Text = name
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.TextColor3 = ColorPalette.Text
        TabLabel.BackgroundTransparency = 1
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 15
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = Button

        -- Efeito hover e clique
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = ColorPalette.TabButtonHover}):Play()
        end)
        Button.MouseLeave:Connect(function()
            -- Only revert if not active
            if Button.BackgroundColor3 ~= ColorPalette.TabButtonActive then
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = ColorPalette.TabButton}):Play()
            end
        end)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = ColorPalette.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = PageHolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.FillDirection = Enum.FillDirection.Vertical
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left -- Align to left for content
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.Parent = Page

        Tabs[name] = Page

        Button.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true

            -- Efeito de seleção: Aba ativa
            for _, btnContainer in pairs(TabHolder:GetChildren()) do
                if btnContainer:IsA("Frame") and btnContainer.Name:find("TabContainer") then
                    local tabButton = btnContainer:FindFirstChildWhichIsA("TextButton")
                    if tabButton then
                         local targetColor = tabButton == Button and ColorPalette.TabButtonActive or ColorPalette.TabButton
                        TweenService:Create(tabButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = targetColor
                        }):Play()
                    end
                end
            end
            
            -- Ajusta o CanvasSize da página selecionada
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)
        end)
        
        -- Select the first tab created by default
        if #Tabs == 1 then
            Button.MouseButton1Click:Connect(function()
                -- Temporarily remove and re-add to force click effect
                local currentLayoutOrder = TabContainer.LayoutOrder
                TabContainer.LayoutOrder = 0
                wait() -- Give a tiny moment for layout to update if needed
                TabContainer.LayoutOrder = currentLayoutOrder
            end)
            Button.MouseButton1Click:Fire() -- Simulate click to select the first tab
        end


        return {
            AddLabel = function(_, text, isParagraph)
                local container = Instance.new("Frame")
                container.Name = "TextContainer"
                container.Size = UDim2.new(1, 0, 0, 0) -- Auto size Y
                container.BackgroundTransparency = 1
                container.Parent = Page

                local lbl = Instance.new("TextLabel")
                lbl.Name = "Label"
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = ColorPalette.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = isParagraph and 13 or 16 -- Menor para parágrafo, maior para label
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped = true
                lbl.RichText = false
                lbl.Parent = container

                -- Adjust height of container based on text content
                lbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    container.Size = UDim2.new(1, 0, 0, lbl.TextBounds.Y + (isParagraph and 0 or 5)) -- Add some padding
                    Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)
                end)
                
                -- Force initial TextBounds calculation
                task.defer(function()
                    container.Size = UDim2.new(1, 0, 0, lbl.TextBounds.Y + (isParagraph and 0 or 5))
                    Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)
                end)

                if not isParagraph then
                    local divider = Instance.new("Frame")
                    divider.Name = "Divider"
                    divider.Size = UDim2.new(1, 0, 0, 1)
                    divider.BackgroundColor3 = ColorPalette.Border
                    divider.BorderSizePixel = 0
                    divider.Position = UDim2.new(0,0,1,0) -- Position at bottom of container
                    divider.Parent = container
                    
                    container.Size = UDim2.new(1,0,0,30) -- Fixed height for labels with dividers
                end

                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return lbl
            end,

            AddParagraph = function(_, text)
                return self.AddLabel(_, text, true) -- Reusing AddLabel with paragraph styling
            end,

            AddButton = function(_, text, callback)
                local container = Instance.new("Frame")
                container.Name = "ButtonContainer"
                container.Size = UDim2.new(1, 0, 0, 40)
                container.BackgroundTransparency = 1
                container.Parent = Page

                local btn = Instance.new("TextButton")
                btn.Name = "Button_" .. text:gsub(" ", "")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = text
                btn.BackgroundColor3 = ColorPalette.Button
                btn.TextColor3 = ColorPalette.Text
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 15
                btn.AutoButtonColor = false
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.Parent = container

                -- Fingerprint Icon
                local FingerprintIcon = Instance.new("ImageLabel")
                FingerprintIcon.Name = "FingerprintIcon"
                FingerprintIcon.Size = UDim2.new(0, 20, 0, 20)
                FingerprintIcon.Position = UDim2.new(1, -30, 0.5, -10)
                FingerprintIcon.Image = getIcon(Icons.Fingerprint)
                FingerprintIcon.ImageColor3 = ColorPalette.Text
                FingerprintIcon.BackgroundTransparency = 1
                FingerprintIcon.Parent = btn

                -- Efeitos hover e clique
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = ColorPalette.ButtonHover
                    }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = ColorPalette.Button
                    }):Play()
                end)
                btn.MouseButton1Down:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.05), {
                        BackgroundColor3 = ColorPalette.Accent
                    }):Play()
                end)
                btn.MouseButton1Up:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = ColorPalette.ButtonHover
                    }):Play()
                end)
                btn.MouseButton1Click:Connect(callback)
                
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return btn
            end,

            AddToggle = function(_, text, default, callback)
                local container = Instance.new("Frame")
                container.Name = "ToggleContainer"
                container.Size = UDim2.new(1, 0, 0, 40)
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(0.8, -10, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                label.Text = text
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextWrapped = true
                label.Parent = container

                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "ToggleFrame"
                toggleFrame.Size = UDim2.new(0, 40, 0, 20) -- Tamanho fixo para o toggle
                toggleFrame.Position = UDim2.new(1, -50, 0.5, -10) -- Posiciona mais à direita
                toggleFrame.BackgroundColor3 = default and ColorPalette.ToggleOn or ColorPalette.ToggleOff
                toggleFrame.BorderSizePixel = 0
                Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0.5, 0) -- Canto arredondado como pílula
                toggleFrame.Parent = container

                local toggleDot = Instance.new("Frame")
                toggleDot.Name = "ToggleDot"
                toggleDot.Size = UDim2.new(0, 16, 0, 16) -- Tamanho fixo para o dot
                toggleDot.Position = UDim2.new(default and 0.65 or 0.1, 0, 0.5, -8) -- Posição inicial do dot
                toggleDot.AnchorPoint = Vector2.new(0.5, 0.5)
                toggleDot.BackgroundColor3 = ColorPalette.Text
                toggleDot.BorderSizePixel = 0
                Instance.new("UICorner", toggleDot).CornerRadius = UDim.new(0.5, 0) -- Círculo
                toggleDot.Parent = toggleFrame

                local state = default

                local function updateToggle()
                    if state then
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOn
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.75, 0, 0.5, -8) -- Move para a direita
                        }):Play()
                    else
                        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                            BackgroundColor3 = ColorPalette.ToggleOff
                        }):Play()
                        TweenService:Create(toggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.25, 0, 0.5, -8) -- Move para a esquerda
                        }):Play()
                    end
                end

                updateToggle()

                local function toggleState()
                    state = not state
                    updateToggle()
                    if callback then callback(state) end
                end

                toggleFrame.MouseButton1Click:Connect(toggleState)
                label.MouseButton1Click:Connect(toggleState)
                
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, value)
                        state = value
                        updateToggle()
                    end,
                    Get = function()
                        return state
                    end
                }
            end,

            AddSlider = function(_, text, min, max, default, callback)
                local container = Instance.new("Frame")
                container.Name = "SliderContainer"
                container.Size = UDim2.new(1, 0, 0, 70)
                container.BackgroundTransparency = 1
                container.Parent = Page

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 0.4, 0)
                label.Text = text .. ": " .. tostring(default)
                label.BackgroundTransparency = 1
                label.TextColor3 = ColorPalette.Text
                label.Font = Enum.Font.Gotham
                label.TextSize = 15
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = container

                local slider = Instance.new("Frame")
                slider.Name = "Slider"
                slider.Position = UDim2.new(0, 0, 0.4, 5)
                slider.Size = UDim2.new(1, 0, 0, 10) -- Altura da barra do slider
                slider.BackgroundColor3 = ColorPalette.Slider
                slider.BorderSizePixel = 0
                Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 5)
                slider.Parent = container

                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.BackgroundColor3 = ColorPalette.SliderFill
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                fill.BorderSizePixel = 0
                Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
                fill.Parent = slider

                local valueIndicator = Instance.new("Frame")
                valueIndicator.Name = "ValueIndicator"
                valueIndicator.Size = UDim2.new(0, 16, 0, 16) -- Knob maior
                valueIndicator.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8) -- Posiciona no fim do fill
                valueIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
                valueIndicator.BackgroundColor3 = ColorPalette.Text
                valueIndicator.BorderSizePixel = 0
                Instance.new("UICorner", valueIndicator).CornerRadius = UDim.new(0.5, 0) -- Círculo
                valueIndicator.Parent = slider
                
                local currentSliderValue = default
                local dragging = false

                local function updateSlider(input)
                    local rel = input.Position.X - slider.AbsolutePosition.X
                    local pct = math.clamp(rel / slider.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pct + 0.5)
                    
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    valueIndicator.Position = UDim2.new(pct, -8, 0.5, -8)
                    label.Text = text .. ": " .. value
                    
                    if value ~= currentSliderValue then
                        currentSliderValue = value
                        if callback then callback(currentSliderValue) end
                    end
                end

                slider.InputBegan:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = true
                        updateSlider(input)
                        TweenService:Create(valueIndicator, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play()
                    end
                end)

                slider.InputEnded:Connect(function(input)
                    if isPointerInput(input) then
                        dragging = false
                        TweenService:Create(valueIndicator, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play()
                    end
                end)

                slider.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        updateSlider(input)
                    end
                end)
                
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + PagePadding.PaddingTop.Offset + PagePadding.PaddingBottom.Offset)

                return {
                    Set = function(_, value)
                        local pct = math.clamp((value - min) / (max - min), 0, 1)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        valueIndicator.Position = UDim2.new(pct, -8, 0.5, -8)
                        label.Text = text .. ": " .. value
                        currentSliderValue = value
                    end,
                    Get = function()
                        return currentSliderValue
                    end
                }
            end,
            -- Removed AddSeekBar and AddDropdown as they are not present in the image
        }
    end

    return Library
end

return Library
