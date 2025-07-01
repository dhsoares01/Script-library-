local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
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
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "OrionLibraryUI"
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame", ScreenGui)
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 480, 0, 300)
	Main.Position = UDim2.new(0.5, -240, 0.5, -150)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.AnchorPoint = Vector2.new(0.5, 0.5)

	local UICorner = Instance.new("UICorner", Main)
	UICorner.CornerRadius = UDim.new(0, 8)

	local Title = Instance.new("TextLabel", Main)
	Title.Text = title or "Orion Library"
	Title.Size = UDim2.new(1, -40, 0, 30)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.TextColor3 = Theme.Text
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local TabButtons = Instance.new("Frame", Main)
	TabButtons.Size = UDim2.new(0, 100, 1, -30)
	TabButtons.Position = UDim2.new(0, 0, 0, 30)
	TabButtons.BackgroundColor3 = Theme.Panel

	local UICorner2 = Instance.new("UICorner", TabButtons)
	UICorner2.CornerRadius = UDim.new(0, 8)

	local Tabs = Instance.new("Frame", Main)
	Tabs.Size = UDim2.new(1, -110, 1, -40)
	Tabs.Position = UDim2.new(0, 110, 0, 40)
	Tabs.BackgroundTransparency = 1

	local TabsContainer = {}

	function Library:CreateTab(tabName)
		local Button = Instance.new("TextButton", TabButtons)
		Button.Size = UDim2.new(1, 0, 0, 30)
		Button.BackgroundTransparency = 1
		Button.Text = "  " .. tabName
		Button.TextColor3 = Theme.Text
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Button.TextXAlignment = Enum.TextXAlignment.Left

		local TabContent = Instance.new("Frame", Tabs)
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.Visible = false
		TabContent.BackgroundColor3 = Theme.Panel
		TabContent.BorderColor3 = Theme.Border
		TabContent.BorderSizePixel = 1

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
			Label.Size = UDim2.new(1, -10, 0, 20)
			Label.BackgroundTransparency = 1
			Label.Text = text
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
		end

		function TabFunctions:AddParagraph(title, content)
			local Frame = Instance.new("Frame", TabContent)
			Frame.Size = UDim2.new(1, -10, 0, 100)
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
			Content.TextScaled = false
			Content.ClipsDescendants = true
		end

		function TabFunctions:AddButton(text, callback)
			local Button = Instance.new("TextButton", TabContent)
			Button.Size = UDim2.new(1, -10, 0, 30)
			Button.BackgroundColor3 = Theme.Background
			Button.BorderColor3 = Theme.Border
			Button.Text = text
			Button.TextColor3 = Theme.Text
			Button.Font = Enum.Font.Gotham
			Button.TextSize = 14

			Button.MouseButton1Click:Connect(function()
				if callback then
					pcall(callback)
				end
			end)
		end

		function TabFunctions:AddToggle(text, callback)
			local Toggle = Instance.new("TextButton", TabContent)
			Toggle.Size = UDim2.new(1, -10, 0, 30)
			Toggle.BackgroundColor3 = Theme.Background
			Toggle.BorderColor3 = Theme.Border
			Toggle.Text = text .. ": Off"
			Toggle.TextColor3 = Theme.Text
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 14

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
