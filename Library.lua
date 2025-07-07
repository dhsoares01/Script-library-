local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local dragging, dragInput, dragStart, startPos

local function makeDraggable(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
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

-- Cria o menu base
function Library:CreateMenu(title)
	local gui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "CustomLibrary"

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 300, 0, 350)
	main.Position = UDim2.new(0.5, -150, 0.5, -175)
	main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = false

	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

	local titleLabel = Instance.new("TextLabel", header)
	titleLabel.Text = title
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = Color3.new(1,1,1)
	titleLabel.BackgroundTransparency = 1

	local close = Instance.new("TextButton", header)
	close.Text = "×"
	close.Size = UDim2.new(0, 30, 1, 0)
	close.Position = UDim2.new(1, -30, 0, 0)
	close.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	close.TextColor3 = Color3.new(1,1,1)

	local minimize = Instance.new("TextButton", header)
	minimize.Text = "–"
	minimize.Size = UDim2.new(0, 30, 1, 0)
	minimize.Position = UDim2.new(1, -60, 0, 0)
	minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	minimize.TextColor3 = Color3.new(1,1,1)

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, 0, 1, -30)
	content.Position = UDim2.new(0, 0, 0, 30)
	content.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", content)
	layout.Padding = UDim.new(0, 6)

	makeDraggable(header)

	local minimized = false

	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			content.Visible = false
			minimize.Text = "□"
			main.Size = UDim2.new(0, 300, 0, 30)
		else
			content.Visible = true
			minimize.Text = "–"
			main.Size = UDim2.new(0, 300, 0, 350)
		end
	end)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- API para adicionar elementos
	local api = {}

	function api:CreateToggle(text, callback)
		local toggle = Instance.new("TextButton", content)
		toggle.Size = UDim2.new(1, -10, 0, 30)
		toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		toggle.TextColor3 = Color3.new(1,1,1)
		toggle.Text = "[ ] " .. text

		local state = false
		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = (state and "[✓] " or "[ ] ") .. text
			if callback then callback(state) end
		end)
	end

	function api:CreateSlider(text, min, max, default, callback)
		local holder = Instance.new("Frame", content)
		holder.Size = UDim2.new(1, -10, 0, 40)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Text = text .. ": " .. default
		label.TextColor3 = Color3.new(1,1,1)
		label.BackgroundTransparency = 1

		local slider = Instance.new("TextButton", holder)
		slider.Size = UDim2.new(1, 0, 0, 20)
		slider.Position = UDim2.new(0, 0, 0, 20)
		slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		slider.Text = ""

		local value = default

		slider.MouseButton1Down:Connect(function()
			local conn
			conn = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
					value = math.floor(min + (max - min) * relX)
					label.Text = text .. ": " .. value
					if callback then callback(value) end
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					conn:Disconnect()
				end
			end)
		end)
	end

	function api:CreateButton(text, callback)
		local button = Instance.new("TextButton", content)
		button.Size = UDim2.new(1, -10, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.TextColor3 = Color3.new(1,1,1)
		button.Text = text

		button.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end

	function api:CreateMenuOptions(name, options, callback)
		local dropdown = Instance.new("TextButton", content)
		dropdown.Size = UDim2.new(1, -10, 0, 30)
		dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		dropdown.TextColor3 = Color3.new(1,1,1)
		dropdown.Text = name

		local menu = Instance.new("Frame", dropdown)
		menu.Size = UDim2.new(1, 0, 0, #options * 25)
		menu.Position = UDim2.new(0, 0, 1, 0)
		menu.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		menu.Visible = false
		menu.ClipsDescendants = true

		local list = Instance.new("UIListLayout", menu)

		for _, option in ipairs(options) do
			local optBtn = Instance.new("TextButton", menu)
			optBtn.Size = UDim2.new(1, 0, 0, 25)
			optBtn.Text = option
			optBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			optBtn.TextColor3 = Color3.new(1,1,1)

			optBtn.MouseButton1Click:Connect(function()
				callback(option)
				menu.Visible = false
			end)
		end

		dropdown.MouseButton1Click:Connect(function()
			menu.Visible = not menu.Visible
		end)
	end

	function api:CreateRichText(text)
		local rich = Instance.new("TextLabel", content)
		rich.Size = UDim2.new(1, -10, 0, 80)
		rich.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		rich.TextColor3 = Color3.new(1,1,1)
		rich.Text = text
		rich.TextWrapped = true
		rich.RichText = true
		rich.TextYAlignment = Enum.TextYAlignment.Top
	end

	return api
end

return Library
