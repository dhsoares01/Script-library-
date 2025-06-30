local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "OrionStyleLibrary_" .. tostring(math.random(1000, 9999))
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 420, 0, 340)
	Main.Position = UDim2.new(0.3, 0, 0.2, 0)
	Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

	local Icon = Instance.new("ImageLabel", Header)
	Icon.Size = UDim2.new(0, 24, 0, 24)
	Icon.Position = UDim2.new(0, 10, 0.5, -12)
	Icon.BackgroundTransparency = 1
	Icon.Image = "rbxassetid://6034291996" -- Ícone da Orion

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Text = title or "Orion UI"
	TitleLabel.Size = UDim2.new(1, -60, 1, 0)
	TitleLabel.Position = UDim2.new(0, 40, 0, 0)
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Header)
	Close.Text = "×"
	Close.Size = UDim2.new(0, 30, 1, 0)
	Close.Position = UDim2.new(1, -30, 0, 0)
	Close.TextColor3 = Color3.fromRGB(255, 70, 70)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.BackgroundTransparency = 1
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Text = "–"
	Minimize.Size = UDim2.new(0, 30, 1, 0)
	Minimize.Position = UDim2.new(1, -60, 0, 0)
	Minimize.TextColor3 = Color3.fromRGB(180, 180, 180)
	Minimize.Font = Enum.Font.GothamBold
	Minimize.TextSize = 20
	Minimize.BackgroundTransparency = 1

	local TabHolder = Instance.new("Frame", Main)
	TabHolder.Position = UDim2.new(0, 0, 0, 40)
	TabHolder.Size = UDim2.new(0, 110, 1, -40)
	TabHolder.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 8)

	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Position = UDim2.new(0, 110, 0, 40)
	PageHolder.Size = UDim2.new(1, -110, 1, -40)
	PageHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	PageHolder.ClipsDescendants = true
	Instance.new("UICorner", PageHolder).CornerRadius = UDim.new(0, 8)

	local UIList = Instance.new("UIListLayout", TabHolder)
	UIList.Padding = UDim.new(0, 6)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder

	local Tabs = {}
	local currentTab = nil
	local minimized = false

	Minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		local targetSize = minimized and UDim2.new(0, 420, 0, 40) or UDim2.new(0, 420, 0, 340)
		TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play()
		TabHolder.Visible = not minimized
		PageHolder.Visible = not minimized
	end)

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, -10, 0, 30)
		Button.Position = UDim2.new(0, 5, 0, 0)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Button.TextColor3 = Color3.new(1, 1, 1)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Button.AutoButtonColor = false
		Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4
		Page.CanvasSize = UDim2.new(0, 0, 0, 500)
		local layout = Instance.new("UIListLayout", Page)
		layout.Padding = UDim.new(0, 6)

		Tabs[name] = Page

		Button.MouseButton1Click:Connect(function()
			for _, child in pairs(PageHolder:GetChildren()) do
				if child:IsA("ScrollingFrame") then
					child.Visible = false
				end
			end
			for _, btn in pairs(TabHolder:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end
			end
			Button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			Page.Visible = true
			currentTab = name
		end)

		if not currentTab then
			Button:MouseButton1Click()
		end

		return {
			AddLabel = function(_, text)
				local lbl = Instance.new("TextLabel", Page)
				lbl.Size = UDim2.new(1, -10, 0, 25)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.TextColor3 = Color3.new(1, 1, 1)
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 14
				lbl.TextXAlignment = Enum.TextXAlignment.Left
			end,

			AddButton = function(_, text, callback)
				local btn = Instance.new("TextButton", Page)
				btn.Size = UDim2.new(1, -10, 0, 30)
				btn.Text = text
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 14
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
				btn.MouseButton1Click:Connect(callback)
			end
		}
	end

	return Library
end

return Library
