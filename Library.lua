
-- UILib.lua
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UILib = {}

function UILib:Create(title)
	local gui = Instance.new("ScreenGui")
	gui.Name = "UILibGUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = game.CoreGui

	-- Janela principal
	local window = Instance.new("Frame", gui)
	window.Size = UDim2.new(0, 500, 0, 350)
	window.Position = UDim2.new(0.5, -250, 0.5, -175)
	window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	window.BorderSizePixel = 0
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	Instance.new("UICorner", window).CornerRadius = UDim.new(0, 6)
	window.Visible = true  -- menu já aberto

	-- Remove qualquer floating preto indesejado que possa existir (caso tenha)
	for _, child in pairs(gui:GetChildren()) do
		if child:IsA("Frame") and child ~= window then
			child:Destroy()
		end
	end

	-- Função arrastar adaptada para mouse e toque (mobile)
	local function makeDraggable(frame)
		local dragging = false
		local dragInput, dragStart, startPos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				-- Mantém a janela dentro da tela
				local newX = math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X)
				local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y)
				frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
			end
		end)
	end
	makeDraggable(window)

	-- Topbar
	local topbar = Instance.new("Frame", window)
	topbar.Size = UDim2.new(1, 0, 0, 30)
	topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 6)

	local titleLabel = Instance.new("TextLabel", topbar)
	titleLabel.Text = "  " .. title
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextSize = 14

	local closeBtn = Instance.new("TextButton", topbar)
	closeBtn.Text = "×"
	closeBtn.Size = UDim2.new(0, 30, 1, 0)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14

	local minimizeBtn = Instance.new("TextButton", topbar)
	minimizeBtn.Text = "–"
	minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
	minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 14

	-- Minimizar só oculta a janela, sem mostrar floatBtn
	minimizeBtn.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- Tabs e conteúdo
	local tabButtons = Instance.new("Frame", window)
	tabButtons.Size = UDim2.new(0, 120, 1, -30)
	tabButtons.Position = UDim2.new(0, 0, 0, 30)
	tabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Instance.new("UICorner", tabButtons).CornerRadius = UDim.new(0, 4)

	local tabLayout = Instance.new("UIListLayout", tabButtons)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 6)

	local content = Instance.new("Frame", window)
	content.Position = UDim2.new(0, 125, 0, 35)
	content.Size = UDim2.new(1, -135, 1, -45)
	content.BackgroundTransparency = 1

	local tabs = {}

	local ui = {}

	function ui:AddTab(tabName)
		local button = Instance.new("TextButton", tabButtons)
		button.Text = tabName
		button.Size = UDim2.new(1, -10, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Font = Enum.Font.Gotham
		button.TextSize = 14
		Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.ScrollBarThickness = 6
		page.Visible = false
		page.BackgroundTransparency = 1

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		page.ChildAdded:Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

		button.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do
				t.Visible = false
			end
			page.Visible = true
		end)

		tabs[tabName] = page
		if #content:GetChildren() == 1 then
			page.Visible = true
		end

		local elements = {}

		function elements:AddToggle(text, callback)
			local toggle = Instance.new("TextButton", page)
			toggle.Size = UDim2.new(1, -10, 0, 30)
			toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			toggle.TextColor3 = Color3.new(1, 1, 1)
			toggle.Font = Enum.Font.Gotham
			toggle.TextSize = 14
			toggle.Text = "[ OFF ] " .. text

			local state = false
			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.Text = (state and "[ ON  ] " or "[ OFF ] ") .. text
				if callback then callback(state) end
			end)
		end

		function elements:AddButton(text, callback)
			local btn = Instance.new("TextButton", page)
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(70, 90, 70)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.Text = text
			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
		end

		function elements:AddDropdown(text, options, callback)
			local drop = Instance.new("TextButton", page)
			drop.Size = UDim2.new(1, -10, 0, 30)
			drop.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			drop.TextColor3 = Color3.new(1, 1, 1)
			drop.Font = Enum.Font.Gotham
			drop.TextSize = 14
			drop.Text = text .. " ▼"

			local dropdownFrame = Instance.new("Frame", page)
			dropdownFrame.Size = UDim2.new(1, -10, 0, #options * 30)
			dropdownFrame.Position = UDim2.new(0, 5, 0, 30)
			dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			dropdownFrame.Visible = false
			Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 4)

			for i, option in ipairs(options) do
				local optionBtn = Instance.new("TextButton", dropdownFrame)
				optionBtn.Size = UDim2.new(1, 0, 0, 30)
				optionBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
				optionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				optionBtn.TextColor3 = Color3.new(1, 1, 1)
				optionBtn.Font = Enum.Font.Gotham
				optionBtn.TextSize = 14
				optionBtn.Text = option

				optionBtn.MouseButton1Click:Connect(function()
					drop.Text = option .. " ▼"
					dropdownFrame.Visible = false
					if callback then callback(option) end
				end)
			end

			drop.MouseButton1Click:Connect(function()
				dropdownFrame.Visible = not dropdownFrame.Visible
			end)
		end

		return elements
	end

	return ui
end

return UILib
