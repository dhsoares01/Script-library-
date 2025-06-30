local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "UI_" .. tostring(math.random(1000, 9999))
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 400, 0, 320)
	Main.Position = UDim2.new(0.3, 0, 0.2, 0)
	Main.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true

	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 36)
	Header.BackgroundColor3 = Color3.fromRGB(38, 38, 40)
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel", Header)
	Title.Text = title or "Menu"
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamSemibold
	Title.TextSize = 17
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Header)
	Close.Text = "×"
	Close.Size = UDim2.new(0, 36, 1, 0)
	Close.Position = UDim2.new(1, -36, 0, 0)
	Close.TextColor3 = Color3.fromRGB(255, 80, 80)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.BackgroundTransparency = 1
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local TabHolder = Instance.new("Frame", Main)
	TabHolder.Position = UDim2.new(0, 0, 0, 36)
	TabHolder.Size = UDim2.new(0, 110, 1, -36)
	TabHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
	Instance.new("UICorner", TabHolder).CornerRadius = UDim.new(0, 8)
	Instance.new("UIListLayout", TabHolder).Padding = UDim.new(0, 5)

	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Position = UDim2.new(0, 110, 0, 36)
	PageHolder.Size = UDim2.new(1, -110, 1, -36)
	PageHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
	PageHolder.ClipsDescendants = true
	Instance.new("UICorner", PageHolder).CornerRadius = UDim.new(0, 8)

	local Tabs = {}

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, 0, 0, 28)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		Button.TextColor3 = Color3.new(1, 1, 1)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4
		Page.CanvasSize = UDim2.new(0, 0, 0, 500)
		local layout = Instance.new("UIListLayout", Page)
		layout.Padding = UDim.new(0, 5)

		Tabs[name] = Page

		Button.MouseButton1Click:Connect(function()
			for _, child in pairs(PageHolder:GetChildren()) do
				if child:IsA("ScrollingFrame") then
					child.Visible = false
				end
			end
			Page.Visible = true
		end)

		return {
			AddLabel = function(_, text)
				local lbl = Instance.new("TextLabel", Page)
				lbl.Size = UDim2.new(1, -10, 0, 24)
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
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
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
