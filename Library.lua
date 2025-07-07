local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Função utilitária
local function create(class, props)
	local inst = Instance.new(class)
	for i, v in pairs(props) do
		inst[i] = v
	end
	return inst
end

-- Função de arrastar otimizada para toque e mouse
local function makeDraggable(frame)
	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
								   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

-- Cria a janela principal
function Library:CreateWindow(title)
	local screenGui = create("ScreenGui", {
		Name = "CustomLibrary",
		ResetOnSpawn = false,
		Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	})

	local main = create("Frame", {
		Size = UDim2.new(0, 300, 0, 400),
		Position = UDim2.new(0.5, -150, 0.5, -200), -- Centralizado
		AnchorPoint = Vector2.new(0.5, 0.5), -- Centralização precisa
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui
	})
	main.BackgroundTransparency = 0.1
	main.AutomaticSize = Enum.AutomaticSize.Y
	main.Name = "MainUI"
	main.Active = true
	main.Draggable = false

	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BorderSizePixel = 0,
		Parent = main
	})

	local titleLabel = create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = title or "Menu",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Parent = header
	})

	local minimizeBtn = create("TextButton", {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -60, 0, 0),
		Text = "–",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.Gotham,
		TextSize = 16,
		BackgroundTransparency = 1,
		Parent = header
	})

	local closeBtn = create("TextButton", {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		Text = "×",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.Gotham,
		TextSize = 16,
		BackgroundTransparency = 1,
		Parent = header
	})

	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = 1,
		Name = "ContentContainer",
		Parent = main
	})

	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = container
	})

	local function toggleMenu()
		container.Visible = not container.Visible
		minimizeBtn.Text = container.Visible and "–" or "□"
	end

	minimizeBtn.MouseButton1Click:Connect(toggleMenu)
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	-- Torna o menu arrastável com touch/mouse
	makeDraggable(header)

	-- APIs públicas
	local api = {}

	function api:CreateToggle(text, callback)
		local toggle = create("TextButton", {
			Size = UDim2.new(1, -10, 0, 30),
			Text = "[ ] " .. text,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = container
		})

		local state = false
		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = (state and "[✔] " or "[ ] ") .. text
			if callback then callback(state) end
		end)
	end

	function api:CreateSlider(text, min, max, callback)
		local frame = create("Frame", {
			Size = UDim2.new(1, -10, 0, 50),
			BackgroundTransparency = 1,
			Parent = container
		})

		local label = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Text = text,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 14,
			BackgroundTransparency = 1,
			Parent = frame
		})

		local slider = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			Text = "",
			Parent = frame
		})

		local fill = create("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(120, 120, 255),
			BorderSizePixel = 0,
			Parent = slider
		})

		local dragging = false
		local function update(input)
			local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(pos, 0, 1, 0)
			local value = math.floor(min + (max - min) * pos)
			if callback then callback(value) end
		end

		slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	function api:CreateButton(text, callback)
		local btn = create("TextButton", {
			Size = UDim2.new(1, -10, 0, 30),
			Text = text,
			BackgroundColor3 = Color3.fromRGB(80, 80, 80),
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			Parent = container
		})
		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end

	function api:CreateDropdown(text, options, callback)
		local open = false
		local button = create("TextButton", {
			Size = UDim2.new(1, -10, 0, 30),
			Text = "▸ " .. text,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = container
		})

		local optionHolder = create("Frame", {
			Size = UDim2.new(1, -20, 0, #options * 25),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = container
		})
		create("UIListLayout", {Parent = optionHolder})

		for _, opt in pairs(options) do
			local optBtn = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 25),
				Text = opt,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = Color3.new(1,1,1),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Parent = optionHolder
			})

			optBtn.MouseButton1Click:Connect(function()
				if callback then callback(opt) end
				optionHolder.Visible = false
				button.Text = "▸ " .. text
				open = false
			end)
		end

		button.MouseButton1Click:Connect(function()
			open = not open
			optionHolder.Visible = open
			button.Text = (open and "▾ " or "▸ ") .. text
		end)
	end

	function api:CreateRichText(text)
		local label = create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 60),
			Text = text,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			RichText = true,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 1,
			Parent = container
		})
	end

	return api
end

return Library
