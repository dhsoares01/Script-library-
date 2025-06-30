local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
	
	-- Borda sutil com sombra leve (blur)
	local Shadow = Instance.new("ImageLabel", Main)
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 20, 1, 20)
	Shadow.Image = "rbxassetid://4613698066" -- sombra mais suave, tipo blur
	Shadow.ImageColor3 = Color3.new(0,0,0)
	Shadow.ImageTransparency = 0.75
	Shadow.BackgroundTransparency = 1
	Shadow.ZIndex = 0

	-- Borda arredondada
	local UICornerMain = Instance.new("UICorner", Main)
	UICornerMain.CornerRadius = UDim.new(0, 12)

	-- Header (sem brilho, só cor sólida)
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 38)
	Header.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	Header.BorderSizePixel = 0
	local HeaderCorner = Instance.new("UICorner", Header)
	HeaderCorner.CornerRadius = UDim.new(0, 12)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Text = title or "Floating UI"
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Header)
	Close.Text = "×"
	Close.Size = UDim2.new(0, 38, 1, 0)
	Close.Position = UDim2.new(1, -40, 0, 0)
	Close.TextColor3 = Color3.fromRGB(255, 75, 75)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 24
	Close.BackgroundTransparency = 1
	Close.ZIndex = 2
	Close.AutoButtonColor = false
	Close.MouseEnter:Connect(function() Close.TextColor3 = Color3.fromRGB(255, 120, 120) end)
	Close.MouseLeave:Connect(function() Close.TextColor3 = Color3.fromRGB(255, 75, 75) end)
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Text = "—"
	Minimize.Size = UDim2.new(0, 38, 1, 0)
	Minimize.Position = UDim2.new(1, -80, 0, 0)
	Minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
	Minimize.Font = Enum.Font.GothamBold
	Minimize.TextSize = 24
	Minimize.BackgroundTransparency = 1
	Minimize.ZIndex = 2
	Minimize.AutoButtonColor = false
	Minimize.MouseEnter:Connect(function() Minimize.TextColor3 = Color3.fromRGB(230, 230, 230) end)
	Minimize.MouseLeave:Connect(function() Minimize.TextColor3 = Color3.fromRGB(200, 200, 200) end)

	local TabHolder = Instance.new("Frame", Main)
	TabHolder.Position = UDim2.new(0, 0, 0, 38)
	TabHolder.Size = UDim2.new(0, 110, 1, -38)
	TabHolder.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	local TabHolderCorner = Instance.new("UICorner", TabHolder)
	TabHolderCorner.CornerRadius = UDim.new(0, 10)

	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Position = UDim2.new(0, 110, 0, 38)
	PageHolder.Size = UDim2.new(1, -110, 1, -38)
	PageHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	PageHolder.ClipsDescendants = true
	local PageHolderCorner = Instance.new("UICorner", PageHolder)
	PageHolderCorner.CornerRadius = UDim.new(0, 10)

	local UIList = Instance.new("UIListLayout", TabHolder)
	UIList.Padding = UDim.new(0, 8)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder

	local Tabs = {}
	local minimized = false

	Minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		local size = minimized and UDim2.new(0, 400, 0, 38) or UDim2.new(0, 400, 0, 320)
		TweenService:Create(Main, TweenInfo.new(0.3), {Size = size}):Play()
		TabHolder.Visible = not minimized
		PageHolder.Visible = not minimized
	end)

	local function isPointerInput(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1 or
			   input.UserInputType == Enum.UserInputType.Touch
	end

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, 0, 0, 32)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Button.TextColor3 = Color3.new(1, 1, 1)
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 15
		Button.AutoButtonColor = false
		local btnCorner = Instance.new("UICorner", Button)
		btnCorner.CornerRadius = UDim.new(0, 8)

		-- efeito hover simples
		Button.MouseEnter:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		end)
		Button.MouseLeave:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end)

		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 5
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		local layout = Instance.new("UIListLayout", Page)
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		Tabs[name] = Page

		Button.MouseButton1Click:Connect(function()
			for _, v in pairs(PageHolder:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			Page.Visible = true
		end)

		-- Ativa o primeiro tab automaticamente
		if #TabHolder:GetChildren() == 0 then
			Button:CaptureFocus()
			Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			Page.Visible = true
		end

		return {
			AddLabel = function(_, text)
				local lbl = Instance.new("TextLabel", Page)
				lbl.Size = UDim2.new(1, -20, 0, 25)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.TextColor3 = Color3.new(1, 1, 1)
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 14
				lbl.TextXAlignment = Enum.TextXAlignment.Left
			end,

			AddButton = function(_, text, callback)
				local btn = Instance.new("TextButton", Page)
				btn.Size = UDim2.new(1, -20, 0, 32)
				btn.Text = text
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 15
				btn.AutoButtonColor = false
				local btnCorner = Instance.new("UICorner", btn)
				btnCorner.CornerRadius = UDim.new(0, 8)
				btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) end)
				btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
				btn.MouseButton1Click:Connect(callback)
			end,

			AddToggle = function(_, text, default, callback)
				local toggle = Instance.new("TextButton", Page)
				toggle.Size = UDim2.new(1, -20, 0, 32)
				toggle.Text = (default and "[✔] " or "[ ] ") .. text
				toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				toggle.TextColor3 = Color3.new(1, 1, 1)
				toggle.Font = Enum.Font.Gotham
				toggle.TextSize = 15
				toggle.AutoButtonColor = false
				local toggleCorner = Instance.new("UICorner", toggle)
				toggleCorner.CornerRadius = UDim.new(0, 8)
				local state = default
				local function updateText()
					toggle.Text = (state and "[✔] " or "[ ] ") .. text
				end
				updateText()
				toggle.MouseEnter:Connect(function() toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80) end)
				toggle.MouseLeave:Connect(function() toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
				toggle.MouseButton1Click:Connect(function()
					state = not state
					updateText()
					if callback then callback(state) end
				end)
			end,

			AddSlider = function(_, text, min, max, default, callback)
				local container = Instance.new("Frame", Page)
				container.Size = UDim2.new(1, -20, 0, 40)
				container.BackgroundTransparency = 1

				local label = Instance.new("TextLabel", container)
				label.Size = UDim2.new(1, 0, 0.5, 0)
				label.Text = text .. ": " .. tostring(default)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.new(1, 1, 1)
				label.Font = Enum.Font.Gotham
				label.TextSize = 14

				local slider = Instance.new("Frame", container)
				slider.Position = UDim2.new(0, 0, 0.5, 5)
				slider.Size = UDim2.new(1, 0, 0, 18)
				slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				local sliderCorner = Instance.new("UICorner", slider)
				sliderCorner.CornerRadius = UDim.new(0, 10)

				local fill = Instance.new("Frame", slider)
				fill.Name = "Fill"
				fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BorderSizePixel = 0
				local fillCorner = Instance.new("UICorner", fill)
				fillCorner.CornerRadius = UDim.new(0, 10)

				local dragging = false

				local function updateInput(input)
					local rel = input.Position.X - slider.AbsolutePosition.X
					local pct = math.clamp(rel / slider.AbsoluteSize.X, 0, 1)
					local value = math.floor(min + (max - min) * pct)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					label.Text = text .. ": " .. value
					if callback then callback(value) end
				end

				slider.InputBegan:Connect(function(input)
					if isPointerInput(input) then
						dragging = true
						updateInput(input)
					end
				end)

				slider.InputEnded:Connect(function(input)
					if isPointerInput(input) then
						dragging = false
					end
				end)

				slider.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
						updateInput(input)
					end
				end)
			end,

			AddSeekBar = function(_, text, min, max, default, callback)
				local container = Instance.new("Frame", Page)
				container.Size = UDim2.new(1, -20, 0, 50)
				container.BackgroundTransparency = 1

				local label = Instance.new("TextLabel", container)
				label.Size = UDim2.new(1, 0, 0, 20)
				label.Text = text .. ": " .. tostring(default)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.new(1, 1, 1)
				label.Font = Enum.Font.Gotham
				label.TextSize = 14
				label.TextXAlignment = Enum.TextXAlignment.Left

				local bar = Instance.new("Frame", container)
				bar.Position = UDim2.new(0, 0, 0, 25)
				bar.Size = UDim2.new(1, 0, 0, 15)
				bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				local barCorner = Instance.new("UICorner", bar)
				barCorner.CornerRadius = UDim.new(0, 8)

				local fill = Instance.new("Frame", bar)
				fill.Name = "Fill"
				fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BorderSizePixel = 0
				local fillCorner = Instance.new("UICorner", fill)
				fillCorner.CornerRadius = UDim.new(0, 8)

				local dragging = false

				local function updateInput(input)
					local rel = input.Position.X - bar.AbsolutePosition.X
					local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)
					local value = math.floor(min + (max - min) * pct)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					label.Text = text .. ": " .. value
					if callback then callback(value) end
				end

				bar.InputBegan:Connect(function(input)
					if isPointerInput(input) then
						dragging = true
						updateInput(input)
					end
				end)

				bar.InputEnded:Connect(function(input)
					if isPointerInput(input) then
						dragging = false
					end
				end)

				bar.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
						updateInput(input)
					end
				end)
			end,
		}
	end

	return Library
end

return Library
