local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "FloatingLibrary_" .. tostring(math.random(1000, 9999))
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 400, 0, 300)
	Main.Position = UDim2.new(0.3, 0, 0.2, 0)
	Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true

	local Header = Instance.new("TextLabel", Main)
	Header.Size = UDim2.new(1, 0, 0, 30)
	Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Header.Text = title or "Floating UI"
	Header.TextColor3 = Color3.new(1, 1, 1)
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 16

	local TabHolder = Instance.new("Frame", Main)
	TabHolder.Position = UDim2.new(0, 0, 0, 30)
	TabHolder.Size = UDim2.new(0, 100, 1, -30)
	TabHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Position = UDim2.new(0, 100, 0, 30)
	PageHolder.Size = UDim2.new(1, -100, 1, -30)
	PageHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	PageHolder.ClipsDescendants = true

	local UIList = Instance.new("UIListLayout", TabHolder)
	UIList.Padding = UDim.new(0, 5)

	local Tabs = {}

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, 0, 0, 25)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Button.TextColor3 = Color3.new(1, 1, 1)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14

		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4
		local layout = Instance.new("UIListLayout", Page)
		layout.Padding = UDim.new(0, 5)

		Tabs[name] = Page

		Button.MouseButton1Click:Connect(function()
			for _, v in pairs(PageHolder:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			Page.Visible = true
		end)

		return {
			AddLabel = function(_, text)
				local lbl = Instance.new("TextLabel", Page)
				lbl.Size = UDim2.new(1, -10, 0, 25)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.TextColor3 = Color3.new(1, 1, 1)
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 14
			end,

			AddButton = function(_, text, callback)
				local btn = Instance.new("TextButton", Page)
				btn.Size = UDim2.new(1, -10, 0, 30)
				btn.Text = text
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 14
				btn.MouseButton1Click:Connect(callback)
			end
		}
	end

	return Library
end

return Library
