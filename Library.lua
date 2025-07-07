local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local dragging, dragInput, dragStart, startPos

local function makeDraggable(frame)
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
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Library:CreateMenu(titleText)
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local ScreenGui = Instance.new("ScreenGui", playerGui)
	ScreenGui.Name = "LibraryGUI"
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 320, 0, 40)
	Main.Position = UDim2.new(0.5, -160, 0.5, -120)
	Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Main.BorderSizePixel = 0
	Main.Active = true

	local corner = Instance.new("UICorner", Main)
	corner.CornerRadius = UDim.new(0, 8)

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.Text = titleText or "Painel"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Size = UDim2.new(0, 20, 0, 20)
	Minimize.Position = UDim2.new(1, -50, 0.5, -10)
	Minimize.Text = "–"
	Minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	Minimize.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", Minimize).CornerRadius = UDim.new(1, 0)

	local Close = Instance.new("TextButton", Header)
	Close.Size = UDim2.new(0, 20, 0, 20)
	Close.Position = UDim2.new(1, -25, 0.5, -10)
	Close.Text = "×"
	Close.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	Close.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", Close).CornerRadius = UDim.new(1, 0)

	local Body = Instance.new("Frame", Main)
	Body.Name = "Body"
	Body.Position = UDim2.new(0, 0, 0, 40)
	Body.Size = UDim2.new(1, 0, 0, 210)
	Body.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

	local padding = Instance.new("UIPadding", Body)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)

	local layout = Instance.new("UIListLayout", Body)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Toggle
	local Toggle = Instance.new("TextButton", Body)
	Toggle.Size = UDim2.new(1, 0, 0, 30)
	Toggle.Text = "🔘 Toggle: OFF"
	Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Toggle.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

	local toggleState = false
	Toggle.MouseButton1Click:Connect(function()
		toggleState = not toggleState
		Toggle.Text = toggleState and "✅ Toggle: ON" or "🔘 Toggle: OFF"
	end)

	-- Slider
	local Slider = Instance.new("Frame", Body)
	Slider.Size = UDim2.new(1, 0, 0, 30)
	Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Instance.new("UICorner", Slider).CornerRadius = UDim.new(0, 6)

	local Bar = Instance.new("Frame", Slider)
	Bar.Size = UDim2.new(0.9, 0, 0.35, 0)
	Bar.Position = UDim2.new(0.05, 0, 0.325, 0)
	Bar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Knob = Instance.new("Frame", Bar)
	Knob.Size = UDim2.new(0, 14, 1.5, 0)
	Knob.Position = UDim2.new(0, -7, 0, -2)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false

	local function updateKnob(input)
		local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
		Knob.Position = UDim2.new(pos, -7, 0, -2)
	end

	Knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			updateKnob(input)
		end
	end)

	-- Botão + submenu
	local MenuButton = Instance.new("TextButton", Body)
	MenuButton.Size = UDim2.new(1, 0, 0, 30)
	MenuButton.Text = "📂 Mostrar Opções"
	MenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	MenuButton.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", MenuButton).CornerRadius = UDim.new(0, 6)

	local SubMenu = Instance.new("Frame", Body)
	SubMenu.Size = UDim2.new(1, 0, 0, 90)
	SubMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	SubMenu.Visible = false
	Instance.new("UICorner", SubMenu).CornerRadius = UDim.new(0, 6)

	local subLayout = Instance.new("UIListLayout", SubMenu)
	subLayout.SortOrder = Enum.SortOrder.LayoutOrder
	subLayout.Padding = UDim.new(0, 4)

	local items = { "Item 1", "Item 2", "Item 3" }
	for _, v in ipairs(items) do
		local option = Instance.new("TextButton", SubMenu)
		option.Size = UDim2.new(1, 0, 0, 25)
		option.Text = "🔹 " .. v
		option.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		option.TextColor3 = Color3.new(1, 1, 1)
		Instance.new("UICorner", option).CornerRadius = UDim.new(0, 6)
	end

	MenuButton.MouseButton1Click:Connect(function()
		SubMenu.Visible = not SubMenu.Visible
	end)

	-- Minimizar e Fechar
	local isMinimized = false
	Minimize.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		Body.Visible = not isMinimized
		Main.Size = isMinimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 250)
		Minimize.Text = isMinimized and "☐" or "–"
	end)

	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	makeDraggable(Main)
end

return Library
