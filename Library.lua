local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
Background = Color3.fromRGB(30, 30, 30),
Tab = Color3.fromRGB(40, 40, 40),
Accent = Color3.fromRGB(0, 120, 255),
Text = Color3.fromRGB(255, 255, 255),
Stroke = Color3.fromRGB(60, 60, 60),
ScrollViewBackground = Color3.fromRGB(20, 20, 20), -- mais escuro para o background do ScrollView
}

function Library:CreateWindow(name)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = name or "CustomUILib"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Active = true

-- Suporte a arrastar com toque e mouse
local dragging = false
local dragStart, startPos

local function updateDrag(input)
local delta = input.Position - dragStart
MainFrame.Position = UDim2.new(
startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y
)
end

MainFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)

UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateDrag(input)
end
end)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = theme.Stroke
UIStroke.Thickness = 1

-- Título
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 40) -- espaço para botão minimizar
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = name or "Menu"
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão minimizar
local BtnMinimize = Instance.new("TextButton", MainFrame)
BtnMinimize.Size = UDim2.new(0, 30, 0, 30)
BtnMinimize.Position = UDim2.new(1, -40, 0, 5)
BtnMinimize.BackgroundColor3 = theme.Tab
BtnMinimize.Text = "–" -- traço de minimizar
BtnMinimize.TextColor3 = theme.Text
BtnMinimize.Font = Enum.Font.GothamBold
BtnMinimize.TextSize = 24
BtnMinimize.AutoButtonColor = false

local btnCorner = Instance.new("UICorner", BtnMinimize)
btnCorner.CornerRadius = UDim.new(0, 6)

BtnMinimize.MouseEnter:Connect(function()
TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
end)
BtnMinimize.MouseLeave:Connect(function()
TweenService:Create(BtnMinimize, TweenInfo.new(0.15), { BackgroundColor3 = theme.Tab }):Play()
end)

-- Contêiner de abas e página
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.Size = UDim2.new(0, 130, 1, -40)
TabContainer.BackgroundColor3 = theme.Tab

local TabCorner = Instance.new("UICorner", TabContainer)
TabCorner.CornerRadius = UDim.new(0, 6)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 130, 0, 40)
PageContainer.Size = UDim2.new(1, -130, 1, -40)
PageContainer.BackgroundColor3 = theme.Background
PageContainer.ClipsDescendants = true

local UIList = Instance.new("UIListLayout", TabContainer)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

local pages = {}

local minimized = false

BtnMinimize.MouseButton1Click:Connect(function()
minimized = not minimized
if minimized then
TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 130, 0, 40) }):Play()
PageContainer.Visible = false
TabContainer.Visible = false
BtnMinimize.Text = "+"
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -40, 0, 40)
else
TweenService:Create(MainFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 520, 0, 340) }):Play()
PageContainer.Visible = true
TabContainer.Visible = true
BtnMinimize.Text = "–"
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -40, 0, 40)
end
end)

local function switchToPage(name)
for pgName, pg in pairs(pages) do
if pgName == name then
pg.Visible = true
pg.BackgroundTransparency = 1
TweenService:Create(pg, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
else
pg.Visible = false
end
end
end

local window = {}

-- Redimensionar menu (borda direita-inferior)
do
local resizeFrame = Instance.new("Frame", MainFrame)
resizeFrame.Size = UDim2.new(0, 20, 0, 20)
resizeFrame.Position = UDim2.new(1, -20, 1, -20)
resizeFrame.BackgroundTransparency = 1
resizeFrame.ZIndex = 10
resizeFrame.Active = true

local mouseDown = false          
local lastPos = Vector2.new()          
  
resizeFrame.InputBegan:Connect(function(input)          
    if input.UserInputType == Enum.UserInputType.MouseButton1 then          
        mouseDown = true          
        lastPos = UserInputService:GetMouseLocation()          
    end          
end)          
  
UserInputService.InputChanged:Connect(function(input)          
    if mouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then          
        local delta = UserInputService:GetMouseLocation() - lastPos          
        lastPos = UserInputService:GetMouseLocation()          
  
        local newWidth = math.clamp(MainFrame.AbsoluteSize.X + delta.X, 350, 900)          
        local newHeight = math.clamp(MainFrame.AbsoluteSize.Y + delta.Y, 220, 600)          
  
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)          
        TabContainer.Size = UDim2.new(0, 130, 1, -40)          
        PageContainer.Size = UDim2.new(1, -130, 1, -40)          
  
        for _, pg in pairs(pages) do          
            pg.Size = UDim2.new(1, 0, 1, 0)          
        end          
    end          
end)          
  
UserInputService.InputEnded:Connect(function(input)          
    if input.UserInputType == Enum.UserInputType.MouseButton1 then          
        mouseDown = false          
    end          
end)

end

function window:CreateTab(tabName, icon)
local Button = Instance.new("TextButton", TabContainer)
Button.Size = UDim2.new(1, -10, 0, 34)
Button.Position = UDim2.new(0, 5, 0, 0)
Button.BackgroundColor3 = theme.Background
Button.TextColor3 = theme.Text
Button.Font = Enum.Font.Gotham
Button.TextSize = 16
Button.AutoButtonColor = false
Button.TextXAlignment = Enum.TextXAlignment.Left

local btnCorner = Instance.new("UICorner", Button)          
btnCorner.CornerRadius = UDim.new(0, 6)          
  
if icon then          
    local iconLabel = Instance.new("TextLabel", Button)          
    iconLabel.Text = icon          
    iconLabel.Size = UDim2.new(0, 24, 1, 0)          
    iconLabel.Position = UDim2.new(0, 6, 0, 0)          
    iconLabel.BackgroundTransparency = 1          
    iconLabel.Font = Enum.Font.GothamBold          
    iconLabel.TextSize = 18          
    iconLabel.TextColor3 = theme.Accent          
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center          
    iconLabel.TextYAlignment = Enum.TextYAlignment.Center          
  
    Button.Text = "  " .. tabName          
else          
    Button.Text = tabName          
end          
  
Button.MouseEnter:Connect(function()          
    TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Accent }):Play()          
end)          
Button.MouseLeave:Connect(function()          
    TweenService:Create(Button, TweenInfo.new(0.2), { BackgroundColor3 = theme.Background }):Play()          
end)          
  
local Page = Instance.new("ScrollingFrame", PageContainer)          
Page.Visible = false          
Page.Size = UDim2.new(1, 0, 1, 0)          
Page.CanvasSize = UDim2.new(0, 0, 0, 0)          
Page.ScrollBarThickness = 4          
Page.BackgroundColor3 = theme.ScrollViewBackground -- background mais escuro          
Page.BorderSizePixel = 0          
  
-- Cantos arredondados para o ScrollView, inclusive canto inferior direito          
local pageCorner = Instance.new("UICorner", Page)          
pageCorner.CornerRadius = UDim.new(0, 8)          
  
local Layout = Instance.new("UIListLayout", Page)          
Layout.SortOrder = Enum.SortOrder.LayoutOrder          
Layout.Padding = UDim.new(0, 8)          
  
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()          
    Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)          
end)          
  
pages[tabName] = Page          
  
Button.MouseButton1Click:Connect(function()          
    switchToPage(tabName)          
end)          
  
local tab = {}          

    function tab:AddDropdownToggle(text, options, default, callback)
    -- Container do dropdown
    local DropdownFrame = Instance.new("Frame", Page)
    DropdownFrame.Size = UDim2.new(1, -10, 0, 36)
    DropdownFrame.BackgroundColor3 = theme.Tab
    DropdownFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner", DropdownFrame)
    corner.CornerRadius = UDim.new(0, 6)

    -- Label do dropdown (texto + seleção atual)
    local Label = Instance.new("TextLabel", DropdownFrame)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextColor3 = theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left

    -- Ícone de seta (seta para baixo)
    local Arrow = Instance.new("TextLabel", DropdownFrame)
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Position = UDim2.new(1, -25, 0.5, -10)
    Arrow.BackgroundTransparency = 1
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 18
    Arrow.TextColor3 = theme.Accent
    Arrow.Text = "▼"

    -- Frame com as opções do dropdown (inicialmente invisível)
    local OptionsFrame = Instance.new("Frame", DropdownFrame)
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 2)
    OptionsFrame.BackgroundColor3 = theme.Tab
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Visible = false

    local optionsLayout = Instance.new("UIListLayout", OptionsFrame)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Padding = UDim.new(0, 2)

    local dropdownOpen = false
    local selected = default or options[1]

    local function updateLabel()
        Label.Text = text .. ": " .. tostring(selected)
    end
    updateLabel()

    -- Função para ajustar a altura das opções conforme o número de itens
    local function updateOptionsSize()
        local count = #options
        local optionHeight = 28
        OptionsFrame.Size = UDim2.new(1, 0, 0, count * (optionHeight + optionsLayout.Padding.Offset))
    end
    updateOptionsSize()

    -- Cria botão para cada opção
    for _, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton", OptionsFrame)
        optionBtn.Size = UDim2.new(1, -10, 0, 28)
        optionBtn.Position = UDim2.new(0, 5, 0, 0)
        optionBtn.BackgroundColor3 = theme.Background
        optionBtn.TextColor3 = theme.Text
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 14
        optionBtn.Text = option
        optionBtn.AutoButtonColor = false

        local optCorner = Instance.new("UICorner", optionBtn)
        optCorner.CornerRadius = UDim.new(0, 6)

        optionBtn.MouseEnter:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Accent }):Play()
        end)
        optionBtn.MouseLeave:Connect(function()
            TweenService:Create(optionBtn, TweenInfo.new(0.15), { BackgroundColor3 = theme.Background }):Play()
        end)

        optionBtn.MouseButton1Click:Connect(function()
            selected = option
            updateLabel()
            if callback then
                callback(selected)
            end
            dropdownOpen = false
            OptionsFrame.Visible = false
            -- Ajusta tamanho do DropdownFrame para a versão fechada
            DropdownFrame.Size = UDim2.new(1, -10, 0, 36)
            Arrow.Text = "▼"
        end)
    end

    -- Toggle para abrir/fechar dropdown
    DropdownFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dropdownOpen = not dropdownOpen
            OptionsFrame.Visible = dropdownOpen
            if dropdownOpen then
                DropdownFrame.Size = UDim2.new(1, -10, 0, 36 + OptionsFrame.Size.Y.Offset + 4)
                Arrow.Text = "▲"
            else
                DropdownFrame.Size = UDim2.new(1, -10, 0, 36)
                Arrow.Text = "▼"
            end
        end
    end)

    return {
        Set = function(self, value)
            if table.find(options, value) then
                selected = value
                updateLabel()
                if callback then
                    callback(selected)
                end
            end
        end,
        Get = function(self)
            return selected
        end
    }
end
  
function tab:AddLabel(text)          
    local Label = Instance.new("TextLabel", Page)          
    Label.Size = UDim2.new(1, -10, 0, 24)          
    Label.BackgroundTransparency = 1          
    Label.Text = text          
    Label.TextColor3 = theme.Text          
    Label.Font = Enum.Font.Gotham          
    Label.TextSize = 16          
end          
  
function tab:AddButton(text, callback)          
    local Btn = Instance.new("TextButton", Page)          
    Btn.Size = UDim2.new(1, -10, 0, 32)          
    Btn.BackgroundColor3 = theme.Accent          
    Btn.Text = text          
    Btn.TextColor3 = Color3.new(1,1,1)          
    Btn.Font = Enum.Font.GothamMedium          
    Btn.TextSize = 16          
  
    local corner = Instance.new("UICorner", Btn)          
    corner.CornerRadius = UDim.new(0, 6)          
  
    Btn.MouseButton1Click:Connect(callback)          
end          
  
function tab:AddToggle(text, callback)          
    local ToggleBtn = Instance.new("TextButton", Page)          
    ToggleBtn.Size = UDim2.new(1, -10, 0, 32)          
    ToggleBtn.BackgroundColor3 = theme.Tab          
    ToggleBtn.TextColor3 = theme.Text          
    ToggleBtn.Font = Enum.Font.Gotham          
    ToggleBtn.TextSize = 16          
  
    local corner = Instance.new("UICorner", ToggleBtn)          
    corner.CornerRadius = UDim.new(0, 6)          
  
    local state = false          
    local function update()          
        ToggleBtn.Text = text .. ": " .. (state and "ON" or "OFF")          
        ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.Tab          
    end          
    update()          
  
    ToggleBtn.MouseButton1Click:Connect(function()          
        state = not state          
        update()          
        if callback then          
            callback(state)          
        end          
    end)          
  
    return {          
        Set = function(self, value)          
            state = value          
            update()          
        end,          
        Get = function(self)          
            return state          
        end,          
    }          
end          
  
function tab:AddSlider(text, min, max, default, callback)          
    local SliderFrame = Instance.new("Frame", Page)          
    SliderFrame.Size = UDim2.new(1, -10, 0, 40)          
    SliderFrame.BackgroundTransparency = 1          
  
    local Label = Instance.new("TextLabel", SliderFrame)          
    Label.Size = UDim2.new(1, 0, 0, 16)          
    Label.Position = UDim2.new(0, 0, 0, 0)          
    Label.BackgroundTransparency = 1          
    Label.Font = Enum.Font.Gotham          
    Label.TextSize = 14          
    Label.TextColor3 = theme.Text          
    Label.Text = text .. ": " .. tostring(default)          
    Label.TextXAlignment = Enum.TextXAlignment.Left          
  
    local SliderBar = Instance.new("Frame", SliderFrame)          
    SliderBar.Size = UDim2.new(1, 0, 0, 12)          
    SliderBar.Position = UDim2.new(0, 0, 0, 24)          
    SliderBar.BackgroundColor3 = theme.Tab          
    SliderBar.BorderSizePixel = 0          
  
    local SliderCorner = Instance.new("UICorner", SliderBar)          
    SliderCorner.CornerRadius = UDim.new(0, 6)          
  
    local SliderFill = Instance.new("Frame", SliderBar)          
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)          
    SliderFill.BackgroundColor3 = theme.Accent          
    SliderFill.BorderSizePixel = 0          
  
    local FillCorner = Instance.new("UICorner", SliderFill)          
    FillCorner.CornerRadius = UDim.new(0, 6)          
  
    local dragging = false          
  
    local function updateValue(input)          
        local relativeX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)          
        local percent = relativeX / SliderBar.AbsoluteSize.X          
        local value = math.floor(min + (max - min) * percent)          
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)          
        Label.Text = text .. ": " .. tostring(value)          
        if callback then          
            callback(value)          
        end          
        return value          
    end          
  
    SliderBar.InputBegan:Connect(function(input)          
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then          
            dragging = true          
            updateValue(input)          
        end          
    end)          
  
    SliderBar.InputChanged:Connect(function(input)          
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then          
            updateValue(input)          
        end          
    end)          
  
    UserInputService.InputEnded:Connect(function(input)          
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then          
            dragging = false          
        end          
    end)          
  
    return {          
        Set = function(self, value)          
            local percent = math.clamp((value - min) / (max - min), 0, 1)          
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)          
            Label.Text = text .. ": " .. tostring(value)          
            if callback then          
                callback(value)          
            end          
        end,          
        Get = function(self)          
            local size = SliderFill.Size.X.Scale          
            return math.floor(min + (max - min) * size)          
        end,          
    }          
end          
  
return tab

end

-- Inicializa na primeira aba se existir
coroutine.wrap(function()
wait(0.1)
for tabName, _ in pairs(pages) do
switchToPage(tabName)
break
end
end)()

return window

end

return Library

