local Library = {}

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

function Library:Create(title)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "FloatingModMenu"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 300, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = title or "Menu"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.Size = UDim2.new(1, 0, 1, -35)
    TabHolder.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout", TabHolder)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)

    local Menu = {}

    function Menu:CreateTab(tabName)
        local TabButton = Instance.new("TextButton", TabHolder)
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabButton.BorderSizePixel = 0
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 16
        TabButton.Text = tabName

        local actions = {}

        function actions:AddButton(text, callback)
            TabButton.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        return actions
    end

    return Menu
end

return Library
