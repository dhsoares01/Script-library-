local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "FloatingLibrary_" .. tostring(math.random(1000, 9999))
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 400, 0, 320)
	Main.Position = UDim2.new(0.3, 0, 0.2, 0)
	Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true

	local UICorner = Instance.new("UICorner", Main)
	UICorner.CornerRadius = UDim.new(0, 10)

	local Shadow = Instance.new("ImageLabel", Main)
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 30, 1, 30)
	Shadow.Image = "rbxassetid://1316045217"
	Shadow.ImageTransparency = 0.7
	Shadow.BackgroundTransparency = 1
	Shadow.ZIndex = 0

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 35)
	Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Header.BorderSizePixel = 0

	local HeaderCorner = Instance.new("UICorner", Header)
	HeaderCorner.CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel", Header)
	Title.Text = title or "Floating UI"
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamSemibold
	Title.TextSize = 17
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Header)
	Close.Text = "×"
	Close.Size = UDim2.new(0, 30, 1, 0)
	Close.Position = UDim2.new(1, -30, 0, 0)
	Close.TextColor3 = Color3.new(1, 0.3, 0.3)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.BackgroundTransparency = 1
	Close.ZIndex = 2
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Text = "–"
	Minimize.Size = UDim2.new(0, 30, 1, 0)
	Minimize.Position = UDim2.new(1, -60, 0, 0)
	Minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
	Minimize.Font = Enum.Font.GothamBold
	Minimize.TextSize = 20
	Minimize.BackgroundTransparency = 1

	local TabHolder = Instance.new("Frame", Main)
	TabHolder.Position = UDim2.new(0, 0, 0, 35)
	TabHolder.Size = UDim2.new(0, 110, 1, -35)
	TabHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

	local TabCorner = Instance.new("UICorner", TabHolder)
	TabCorner.CornerRadius = UDim.new(0, 8)

	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Position = UDim2.new(0, 110, 0, 35)
	PageHolder.Size = UDim2.new(1, -110, 1, -35)
	PageHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	PageHolder.ClipsDescendants = true

	local PageCorner = Instance.new("UICorner", PageHolder)
	PageCorner.CornerRadius = UDim.new(0, 8)

	local UIList = Instance.new("UIListLayout", TabHolder)
	UIList.Padding = UDim.new(0, 5)

	local Tabs = {}

	local minimized = false
	Minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		local goal = minimized and UDim2.new(0, 400, 0, 35) or UDim2.new(0, 400, 0, 320)
		TweenService:Create(Main, TweenInfo.new(0.3), {Size = goal}):Play()
	end)

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, 0, 0, 28)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Button.TextColor3 = Color3.new(1, 1, 1)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14

		local BtnCorner = Instance.new("UICorner", Button)
		BtnCorner.CornerRadius = UDim.new(0, 6)

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

				local btnCorner = Instance.new("UICorner", btn)
				btnCorner.CornerRadius = UDim.new(0, 6)

				btn.MouseButton1Click:Connect(callback)
			end
		}
	end

	return Library
end

return Library
