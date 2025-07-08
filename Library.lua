-- library.lua (corrigido)
local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local theme = {
    Background = Color3.fromRGB(28, 28, 30),
    Tab = Color3.fromRGB(38, 38, 40),
    Accent = Color3.fromRGB(0, 132, 255),
    Text = Color3.fromRGB(235, 235, 245),
    Shadow = Color3.fromRGB(0, 0, 0)
}

function Library:CreateWindow(name)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = name or "UILibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame:SetAttribute("Minimized", false)

    local corner = Instance.new("UICorner", MainFrame)
    corner.CornerRadius = UDim.new(0, 10)

    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Menu"
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = theme.Text

    local MinimizeBtn = Instance.new("TextButton", TitleBar)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -40, 0, 5)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextSize = 22
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextColor3 = theme.Text
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.AutoButtonColor = false

    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.BackgroundColor3 = theme.Tab

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Position = UDim2.new(0, 120, 0, 40)
    PageContainer.Size = UDim2.new(1, -120, 1, -40)
    PageContainer.BackgroundColor3 = theme.Background

    local UIList = Instance.new("UIListLayout", TabContainer)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)

    local pages = {}

    local function switchToPage(name)
        for pgName, pg in pairs(pages) do
            pg.Visible = (pgName == name)
        end
    end

    local window = {}

    function window:CreateTab(tabName)
        local Button = Instance.new("TextButton", TabContainer)
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = theme.Background
        Button.Text = tabName
        Button.TextColor3 = theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 15
        Button.BorderSizePixel = 0
        Button.AutoButtonColor = true

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Visible = false
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)

        pages[tabName] = Page

        Button.MouseButton1Click:Connect(function()
            switchToPage(tabName)
        end)

        -- Mostrar a primeira aba criada por padrão
        if not next(pages, tabName) then
            switchToPage(tabName)
        end

        local tab = {}

        function tab:AddLabel(text)
            local Label = Instance.new("TextLabel", Page)
            Label.Size = UDim2.new(1, -10, 0, 24)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        return tab
    end

    MinimizeBtn.MouseButton1Click:Connect(function()
        local minimized = not MainFrame:GetAttribute("Minimized")
        MainFrame:SetAttribute("Minimized", minimized)
        TweenService:Create(MainFrame, TweenInfo.new(0.25), {
            Size = minimized and UDim2.new(0, 520, 0, 40) or UDim2.new(0, 520, 0, 340)
        }):Play()
    end)

    return window
end

return Library
