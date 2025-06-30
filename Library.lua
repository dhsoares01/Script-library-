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
	Main.BackgroundColor3 = Color3.fromRGB(20, 18, 35) -- fundo preto com azul escuro
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

	local Shadow = Instance.new("ImageLabel", Main)
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 40, 1, 40)
	Shadow.Image = "rbxassetid://1316045217"
	Shadow.ImageTransparency = 0.75
	Shadow.BackgroundTransparency = 1
	Shadow.ZIndex = 0

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 38)
	Header.BackgroundColor3 = Color3.fromRGB(55, 28, 80) -- roxo escuro
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Text = title or "Floating UI"
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.TextColor3 = Color3.fromRGB(225, 215, 255) -- lilás claro
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamSemibold
	TitleLabel.TextSize = 20
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Header)
	Close.Text = "×"
	Close.Size = UDim2.new(0, 36, 1, 0)
	Close.Position = UDim2.new(1, -40, 0, 0)
	Close.TextColor3 = Color3.fromRGB(255, 100, 120)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 28
	Close.BackgroundTransparency = 1
	Close.ZIndex = 2
	Close.AutoButtonColor = false
	Close.MouseEnter:Connect(function()
		Close.TextColor3 = Color3.fromRGB(255, 180, 180)
	end)
	Close.MouseLeave:Connect(function()
		Close.TextColor3 = Color3.fromRGB(255, 100, 120)
	end)
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Text = "–"
	Minimize.Size = UDim2.new(0, 36, 1, 0)
	Minimize.Position = UDim2.new(1, -80, 0, 0)
	Minimize.TextColor3 = Color3.fromRGB(170, 170, 255)
	Minimize.Font = Enum.Font.GothamBold
	Minimize.TextSize = 28
	Minimize.BackgroundTransparency = 1
	Minimize.ZIndex = 2
	Minimize.AutoButtonColor = false
	Minimize.MouseEnter:Connect(function()
		Minimize.TextColor3 = Color3.fromRGB(210, 210, 255)
	end)
	Minimize.MouseLeave:Connect(function()
		Minimize.TextColor3 = Color3.fromRGB(170, 170, 255)
	end)

	-- (Restante do código principal e abas igual ao seu original...)

	local function isPointerInput(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1 or
			   input.UserInputType == Enum.UserInputType.Touch
	end

	function Library:CreateTab(name)
		local Button = Instance.new("TextButton", TabHolder)
		Button.Size = UDim2.new(1, 0, 0, 28)
		Button.Text = name
		Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		Button.TextColor3 = Color3.fromRGB(200, 200, 230)
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
		layout.Padding = UDim.new(0, 7)

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
				lbl.TextColor3 = Color3.fromRGB(210, 210, 240)
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 14
				lbl.TextXAlignment = Enum.TextXAlignment.Left
			end,

			AddButton = function(_, text, callback)
				local btn = Instance.new("TextButton", Page)
				btn.Size = UDim2.new(1, -10, 0, 32)
				btn.Text = text
				btn.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
				btn.TextColor3 = Color3.fromRGB(220, 220, 250)
				btn.Font = Enum.Font.GothamSemibold
				btn.TextSize = 15
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
				btn.AutoButtonColor = false
				btn.MouseEnter:Connect(function()
					TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(120, 90, 190)}):Play()
				end)
				btn.MouseLeave:Connect(function()
					TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 50, 120)}):Play()
				end)
				btn.MouseButton1Click:Connect(callback)
			end,

			AddToggle = function(_, text, default, callback)
				local toggleFrame = Instance.new("Frame", Page)
				toggleFrame.Size = UDim2.new(1, -10, 0, 36)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 40, 70) -- fundo roxo escuro misturado
				toggleFrame.BorderColor3 = Color3.fromRGB(120, 120, 120) -- borda cinza suave
				toggleFrame.BorderSizePixel = 1
				Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)

				local label = Instance.new("TextLabel", toggleFrame)
				label.Text = text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 16
				label.TextColor3 = Color3.fromRGB(220, 220, 255)
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, -50, 1, 0)
				label.Position = UDim2.new(0, 12, 0, 0)
				label.TextXAlignment = Enum.TextXAlignment.Left

				local button = Instance.new("TextButton", toggleFrame)
				button.Size = UDim2.new(0, 36, 0, 24)
				button.Position = UDim2.new(1, -44, 0.5, -12)
				button.BackgroundColor3 = default and Color3.fromRGB(130, 90, 230) or Color3.fromRGB(60, 60, 60)
				button.BorderColor3 = Color3.fromRGB(90, 80, 140)
				button.BorderSizePixel = 1
				button.AutoButtonColor = false
				button.Text = ""
				Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

				local circle = Instance.new("Frame", button)
				circle.Size = UDim2.new(0, 18, 0, 18)
				circle.Position = default and UDim2.new(1, -18, 0.5, -9) or UDim2.new(0, 0, 0.5, -9)
				circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				circle.BorderSizePixel = 0
				Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

				local state = default
				local function update()
					if state then
						button.BackgroundColor3 = Color3.fromRGB(130, 90, 230)
						circle:TweenPosition(UDim2.new(1, -18, 0.5, -9), "Out", "Quad", 0.25, true)
					else
						button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
						circle:TweenPosition(UDim2.new(0, 0, 0.5, -9), "Out", "Quad", 0.25, true)
					end
				end
				update()

				button.MouseButton1Click:Connect(function()
					state = not state
					update()
					if callback then
						callback(state)
					end
				end)
			end,

			AddSlider = function(_, text, min, max, default, callback)
				local container = Instance.new("Frame", Page)
				container.Size = UDim2.new(1, -10, 0, 50)
				container.BackgroundColor3 = Color3.fromRGB(45, 30, 80) -- roxo escuro suave
				container.BorderColor3 = Color3.fromRGB(110, 110, 110)
				container.BorderSizePixel = 1
				Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

				local label = Instance.new("TextLabel", container)
				label.Size = UDim2.new(1, -20, 0, 20)
				label.Position = UDim2.new(0, 10, 0, 6)
				label.Text = text .. ": " .. tostring(default)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(220, 220, 255)
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 16
				label.TextXAlignment = Enum.TextXAlignment.Left

				local slider = Instance.new("Frame", container)
				slider.Position = UDim2.new(0, 10, 0, 30)
				slider.Size = UDim2.new(1, -20, 0, 12)
				slider.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
				slider.BorderColor3 = Color3.fromRGB(130, 100, 220)
				slider.BorderSizePixel = 1
				Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 8)

				local fill = Instance.new("Frame", slider)
				fill.Name = "Fill"
				fill.BackgroundColor3 = Color3.fromRGB(180, 140, 255)
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BorderSizePixel = 0
				Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

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
				container.Size = UDim2.new(1, -10, 0, 55)
				container.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
				container.BorderColor3 = Color3.fromRGB(120, 120, 120)
				container.BorderSizePixel = 1
				Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

				local label = Instance.new("TextLabel", container)
				label.Size = UDim2.new(1, -20, 0, 22)
				label.Position = UDim2.new(0, 10, 0, 6)
				label.Text = text .. ": " .. tostring(default)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(230, 230, 255)
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 16
				label.TextXAlignment = Enum.TextXAlignment.Left

				local bar = Instance.new("Frame", container)
				bar.Position = UDim2.new(0, 10, 0, 30)
				bar.Size = UDim2.new(1, -20, 0, 18)
				bar.BackgroundColor3 = Color3.fromRGB(60, 50, 110)
				bar.BorderColor3 = Color3.fromRGB(160, 140, 220)
				bar.BorderSizePixel = 1
				Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

				local fill = Instance.new("Frame", bar)
				fill.Name = "Fill"
				fill.BackgroundColor3 = Color3.fromRGB(140, 110, 240)
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BorderSizePixel = 0
				Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)

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
