local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local dragging, dragInput, dragStart, startPos

-- 📌 Função de arrastar
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

-- 🎨 Criar Menu
function Library:CreateMenu(titleText)
	local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer.PlayerGui)
	ScreenGui.Name = "CustomLibraryGUI"

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 300, 0, 40)
	Main.Position = UDim2.new(0.5, -150, 0.5, -100)
	Main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.Name = "MainMenu"

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Header.BorderSizePixel = 0

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.Text = titleText or "Menu"
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Font = Enum.Font.Gotham
	Title.TextSize = 16

	local Minimize = Instance.new("TextButton", Header)
	Minimize.Size = UDim2.new(0, 20, 0, 20)
	Minimize.Position = UDim2.new(1, -50, 0.5, -10)
	Minimize.Text = "–"
	Minimize.TextColor3 = Color3.new(1, 1, 1)
	Minimize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

	local Close = Instance.new("TextButton", Header)
	Close.Size = UDim2.new(0, 20, 0, 20)
	Close.Position = UDim2.new(1, -25, 0.5, -10)
	Close.Text = "×"
	Close.TextColor3 = Color3.new(1, 1, 1)
	Close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

	local Body = Instance.new("Frame", Main)
	Body.Name = "Body"
	Body.Position = UDim2.new(0, 0, 0, 40)
	Body.Size = UDim2.new(1, 0, 0, 160)
	Body.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

	local layout = Instance.new("UIListLayout", Body)
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Toggle
	local Toggle = Instance.new("TextButton", Body)
	Toggle.Size = UDim2.new(1, -10, 0, 30)
	Toggle.Position = UDim2.new(0, 5, 0, 5)
	Toggle.Text = "Toggle: OFF"
	Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	local toggleState = false
	Toggle.MouseButton1Click:Connect(function()
		toggleState = not toggleState
		Toggle.Text = "Toggle: " .. (toggleState and "ON" or "OFF")
	end)

	-- Slider
	local SliderFrame = Instance.new("Frame", Body)
	SliderFrame.Size = UDim2.new(1, -10, 0, 30)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

	local SliderBar = Instance.new("Frame", SliderFrame)
	SliderBar.Size = UDim2.new(1, 0, 0.5, 0)
	SliderBar.Position = UDim2.new(0, 0, 0.25, 0)
	SliderBar.BackgroundColor3 = Color3.fromRGB(90, 90, 90)

	local SliderKnob = Instance.new("Frame", SliderBar)
	SliderKnob.Size = UDim2.new(0, 10, 1, 0)
	SliderKnob.Position = UDim2.new(0, 0, 0, 0)
	SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SliderKnob.BorderSizePixel = 0

	local draggingSlider = false
	SliderKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			local bar = SliderBar
			local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			SliderKnob.Position = UDim2.new(pos, -5, 0, 0)
		end
	end)

	-- Botão com submenu
	local MenuButton = Instance.new("TextButton", Body)
	MenuButton.Size = UDim2.new(1, -10, 0, 30)
	MenuButton.Text = "Mostrar Opções"
	MenuButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

	local SubMenu = Instance.new("Frame", Body)
	SubMenu.Size = UDim2.new(1, -10, 0, 90)
	SubMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	SubMenu.Visible = false

	local options = { "Item 1", "Item 2", "Item 3" }
	for _, item in ipairs(options) do
		local btn = Instance.new("TextButton", SubMenu)
		btn.Size = UDim2.new(1, 0, 0, 25)
		btn.Text = item
		btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	end

	MenuButton.MouseButton1Click:Connect(function()
		SubMenu.Visible = not SubMenu.Visible
	end)

	-- Minimizar
	local isMinimized = false
	Minimize.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		Body.Visible = not isMinimized
		Minimize.Text = isMinimized and "☐" or "–"
		Main.Size = isMinimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 200)
	end)

	-- Fechar
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	makeDraggable(Main)
end

return Library
