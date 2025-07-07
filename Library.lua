local UILib = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = "CustomUILib"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = game.CoreGui

local dragging, dragInput, dragStart, startPos

local function makeDraggable(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function createMainWindow(title)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.Size = UDim2.new(0, 400, 0, 300)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = false
	mainFrame.Parent = gui

	makeDraggable(mainFrame)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = title
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextSize = 14
	titleLabel.Parent = titleBar

	local minimize = Instance.new("TextButton")
	minimize.Text = "–"
	minimize.Size = UDim2.new(0, 30, 1, 0)
	minimize.Position = UDim2.new(1, -60, 0, 0)
	minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	minimize.Font = Enum.Font.GothamBold
	minimize.TextColor3 = Color3.new(1, 1, 1)
	minimize.TextSize = 14
	minimize.Parent = titleBar

	local close = Instance.new("TextButton")
	close.Text = "×"
	close.Size = UDim2.new(0, 30, 1, 0)
	close.Position = UDim2.new(1, -30, 0, 0)
	close.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
	close.Font = Enum.Font.GothamBold
	close.TextColor3 = Color3.new(1, 1, 1)
	close.TextSize = 14
	close.Parent = titleBar

	local container = Instance.new("Frame")
	container.Position = UDim2.new(0, 0, 0, 30)
	container.Size = UDim2.new(1, 0, 1, -30)
	container.BackgroundTransparency = 1
	container.Name = "Container"
	container.Parent = mainFrame

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 6)
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Parent = container

	-- Floating Button
	local floatBtn = Instance.new("TextButton")
	floatBtn.Visible = false
	floatBtn.Text = "Abrir Menu"
	floatBtn.Size = UDim2.new(0, 120, 0, 35)
	floatBtn.Position = UDim2.new(0.5, -60, 0.5, -17)
	floatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	floatBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	floatBtn.TextColor3 = Color3.new(1, 1, 1)
	floatBtn.Font = Enum.Font.Gotham
	floatBtn.TextSize = 14
	floatBtn.Parent = gui

	minimize.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		floatBtn.Visible = true
	end)

	floatBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = true
		floatBtn.Visible = false
	end)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
		UILib = nil
	end)

	return container
end

-- ELEMENTOS

function UILib:Create(title)
	local content = createMainWindow(title)

	function UILib:AddToggle(text, callback)
		local toggle = Instance.new("TextButton")
		toggle.Size = UDim2.new(1, -10, 0, 30)
		toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		toggle.TextColor3 = Color3.new(1, 1, 1)
		toggle.Font = Enum.Font.Gotham
		toggle.TextSize = 14
		toggle.Text = "[ OFF ] " .. text
		toggle.Parent = content

		local state = false
		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = (state and "[ ON  ] " or "[ OFF ] ") .. text
			if callback then callback(state) end
		end)
	end

	function UILib:AddSlider(text, min, max, callback)
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -10, 0, 50)
		holder.BackgroundTransparency = 1
		holder.Parent = content

		local label = Instance.new("TextLabel")
		label.Text = text .. ": " .. min
		label.Size = UDim2.new(1, 0, 0, 20)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.BackgroundTransparency = 1
		label.Parent = holder

		local slider = Instance.new("TextButton")
		slider.Size = UDim2.new(1, 0, 0, 20)
		slider.Position = UDim2.new(0, 0, 0, 25)
		slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		slider.Text = ""
		slider.Parent = holder

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = Color3.fromRGB(120, 120, 255)
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BorderSizePixel = 0
		fill.Parent = slider

		slider.MouseButton1Down:Connect(function()
			local conn
			conn = game:GetService("RunService").RenderStepped:Connect(function()
				local mouse = UserInputService:GetMouseLocation().X
				local absPos = slider.AbsolutePosition.X
				local absSize = slider.AbsoluteSize.X
				local percent = math.clamp((mouse - absPos) / absSize, 0, 1)
				fill.Size = UDim2.new(percent, 0, 1, 0)
				local value = math.floor(min + (max - min) * percent)
				label.Text = text .. ": " .. tostring(value)
				if callback then callback(value) end
			end)
			UserInputService.InputEnded:Wait()
			conn:Disconnect()
		end)
	end

	function UILib:AddDropdown(text, options, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.Text = text .. " ▼"
		btn.Parent = content

		local open = false

		btn.MouseButton1Click:Connect(function()
			open = not open
			if open then
				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, -10, 0, 25)
					optBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
					optBtn.TextColor3 = Color3.new(1, 1, 1)
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 13
					optBtn.Text = " - " .. opt
					optBtn.Parent = content

					optBtn.MouseButton1Click:Connect(function()
						btn.Text = text .. ": " .. opt
						if callback then callback(opt) end
						open = false
						optBtn:Destroy()
					end)
				end
			else
				for _, child in ipairs(content:GetChildren()) do
					if child:IsA("TextButton") and child.Text:match(" %- ") then
						child:Destroy()
					end
				end
			end
		end)
	end

	function UILib:AddButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(70, 90, 70)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.Text = text
		btn.Parent = content

		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end

	return UILib
end

return UILib
