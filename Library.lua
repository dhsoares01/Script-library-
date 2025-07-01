local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Paleta de Cores
local Theme = {
	Background = Color3.fromRGB(25, 25, 25),
	Panel = Color3.fromRGB(35, 35, 35),
	Text = Color3.fromRGB(235, 235, 235),
	Accent = Color3.fromRGB(100, 100, 255),
	Border = Color3.fromRGB(60, 60, 60),
}

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "OrionLibraryUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = CoreGui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0.9, 0, 0.8, 0) -- Ocupa boa parte da tela
	Main.Position = UDim2.new(0.05, 0, 0.1, 0)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.AnchorPoint = Vector2.new(0, 0)
	Main.Parent = ScreenGui

	local UICorner = Instance.new("UICorner", Main)
	UICorner.CornerRadius = UDim.new(0, 8)

	local Title = Instance.new("TextLabel", Main)
	Title.Text = title or "Orion Library"
	Title.Size = UDim2.new(1, -20, 0, 40)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.TextColor3 = Theme.Text
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- Drag funcional no mobile
	local dragging, dragInput, dragStart, startPos
	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Main.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local TabButtons = Instance.new("ScrollingFrame", Main)
	TabButtons.Size = UDim2.new(0, 120, 1, -50)
	TabButtons.Position = UDim2.new(0, 0, 0, 40)
	TabButtons.BackgroundColor3 = Theme.Panel
	TabButtons.ScrollBarThickness = 4
	TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local UICorner2 = Instance.new("UICorner", TabButtons)
	UICorner2.CornerRadius = UDim.new(0, 8)

	local ButtonsLayout = Instance.new("UIListLayout", TabButtons)
	ButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ButtonsLayout.Padding = UDim.new(0, 6)

	local Tabs = Instance.new("Frame", Main)
	Tabs.Size = UDim2.new(1, -140, 1, -60)
	Tabs.Position = UDim2.new(0, 130, 0, 50)
	Tabs.BackgroundTransparency = 1

	local TabsContainer = {}

	function Library:CreateTab(tabName)
		local Button = Instance.new("TextButton", TabButtons)
		Button.Size = UDim2.new(1, -10, 0, 40)
		Button.BackgroundTransparency = 1
		Button.Text = "  " .. tabName
		Button.TextColor3 = Theme.Text
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 16
		Button.TextXAlignment = Enum.TextXAlignment.Left

		local TabContent = Instance.new("ScrollingFrame", Tabs)
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.Visible = false
		TabContent.BackgroundColor3 = Theme.Panel
		TabContent.BorderColor3 = Theme.Border
		TabContent.BorderSizePixel = 1
		TabContent.ScrollBarThickness = 4
		TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local Layout = Instance.new("UIListLayout", TabContent)
		Layout.Padding = UDim.new(0, 6)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder

		Button.MouseButton1Click:Connect(function()
			for _, tab in pairs(TabsContainer) do
				tab.Visible = false
			end
			TabContent.Visible = true
		end)

		table.insert(TabsContainer, TabContent)

		local TabFunctions = {}

		function TabFunctions:AddLabel(text)
			local Label = Instance.new("TextLabel", TabContent)
			Label.Size = UDim2.new(1, -10, 0, 25)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 16
			Label.TextXAlignment = Enum.TextXAlignment.Left
		end

		function TabFunctions:AddParagraph(title, content)
			local Frame = Instance.new("Frame", TabContent)
			Frame.Size = UDim2.new(1, -10, 0, 120)
			Frame.BackgroundColor3 = Theme.Background
			Frame.BorderColor3 = Theme.Border
			Frame.BorderSizePixel = 1

			local ParagraphTitle = Instance.new("TextLabel", Frame)
			ParagraphTitle.Text = title
			ParagraphTitle.Size = UDim2.new(1, -10, 0, 20)
			ParagraphTitle.Position = UDim2.new(0, 5, 0, 5)
			ParagraphTitle.TextColor3 = Theme.Text
			ParagraphTitle.BackgroundTransparency = 1
			ParagraphTitle.Font = Enum.Font.GothamBold
			ParagraphTitle.TextSize = 14
			ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left

			local Content = Instance.new("TextLabel", Frame)
			Content.Text = content
			Content.Size = UDim2.new(1, -10, 1, -30)
			Content.Position = UDim2.new(0, 5, 0, 25)
			Content.TextColor3 = Theme.Text
			Content.BackgroundTransparency = 1
			Content.Font = Enum.Font.Gotham
			Content.TextSize = 12
			Content.TextXAlignment = Enum.TextXAlignment.Left
			Content.TextYAlignment = Enum.TextYAlignment.Top
			Content.TextWrapped = true
			Content.ClipsDescendants = true
		end

		function TabFunctions:AddButton(text, callback)
			local Button = Instance.new("TextButton", TabContent)
			Button.Size = UDim2.new(1, -10, 0, 35)
			Button.BackgroundColor3 = Theme.Background
			Button.BorderColor3 = Theme.Border
			Button.Text = text
			Button.TextColor3 = Theme.Text
			Button.Font = Enum.Font.Gotham
			Button.TextSize = 16

			Button.MouseButton1Click:Connect(function()
				if callback then
					pcall(callback)
				end
			end)
		end

		function TabFunctions:AddToggle(text, callback)
			local Toggle = Instance.new("TextButton", TabContent)
			Toggle.Size = UDim2.new(1, -10, 0, 35)
			Toggle.BackgroundColor3 = Theme.Background
			Toggle.BorderColor3 = Theme.Border
			Toggle.Text = text .. ": Off"
			Toggle.TextColor3 = Theme.Text
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 16

			local state = false

			Toggle.MouseButton1Click:Connect(function()
				state = not state
				Toggle.Text = text .. ": " .. (state and "On" or "Off")
				if callback then
					pcall(callback, state)
				end
			end)
		end

		return TabFunctions
	end

	return Library
end

return Library
