local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

function Library:CreateWindow(title)
	local dragging, dragStart, startPos

	local gui = Instance.new("ScreenGui", game.CoreGui)
	gui.ResetOnSpawn = false
	gui.Name = "CustomLibrary"

	local Main = Instance.new("Frame", gui)
	Main.Size = UDim2.new(0, 320, 0, 50)
	Main.Position = UDim2.new(0.5, -160, 0.3, 0)
	Main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Main.BorderColor3 = Color3.fromRGB(60, 60, 60)
	Main.BorderSizePixel = 1
	Main.ClipsDescendants = true
	Main.Name = "MainWindow"
	Main.AnchorPoint = Vector2.new(0, 0)
	Main.ZIndex = 1
	Main.Active = true
	Main.Draggable = false
	Main.AutomaticSize = Enum.AutomaticSize.Y
	Main.BackgroundTransparency = 0
	Main.Parent = gui
	Main:SetAttribute("Open", true)
	Main.BackgroundTransparency = 0
	Main.BorderMode = Enum.BorderMode.Inset
	Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Main.BorderSizePixel = 1
	Main.BackgroundTransparency = 0
	Main.ClipsDescendants = true
	Main.ZIndex = 5
	Main.Name = "LibraryMain"
	Main.AnchorPoint = Vector2.new(0, 0)
	Main.AutomaticSize = Enum.AutomaticSize.Y
	Main.Active = true

	local UICorner = Instance.new("UICorner", Main)
	UICorner.CornerRadius = UDim.new(0, 8)

	local Header = Instance.new("TextButton", Main)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Header.Text = title or "Menu"
	Header.Font = Enum.Font.GothamBold
	Header.TextColor3 = Color3.fromRGB(255, 255, 255)
	Header.TextSize = 18
	Header.AutoButtonColor = false
	Header.Name = "Header"

	local HeaderCorner = Instance.new("UICorner", Header)
	HeaderCorner.CornerRadius = UDim.new(0, 8)

	local Content = Instance.new("Frame", Main)
	Content.Position = UDim2.new(0, 0, 0, 50)
	Content.Size = UDim2.new(1, 0, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Name = "Content"

	local TabsHolder = Instance.new("Frame", Content)
	TabsHolder.Size = UDim2.new(1, 0, 0, 35)
	TabsHolder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	TabsHolder.BorderSizePixel = 0

	local TabLayout = Instance.new("UIListLayout", TabsHolder)
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Pages = Instance.new("Frame", Content)
	Pages.Size = UDim2.new(1, 0, 1, -35)
	Pages.Position = UDim2.new(0, 0, 0, 35)
	Pages.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Pages.BorderSizePixel = 0

	local PageLayout = Instance.new("UIPageLayout", Pages)
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageLayout.EasingDirection = Enum.EasingDirection.In
	PageLayout.EasingStyle = Enum.EasingStyle.Quad
	PageLayout.Padding = UDim.new(0, 0)
	PageLayout.TweenTime = 0.3
	PageLayout.ScrollWheelInputEnabled = false
	PageLayout.TouchInputEnabled = false

	local open = true

	Header.MouseButton1Click:Connect(function()
		open = not open
		local newSize = open and 400 or 0
		TweenService:Create(Content, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, newSize)}):Play()
	end)

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	function Library:CreateTab(name)
		local TabButton = Instance.new("TextButton", TabsHolder)
		TabButton.Size = UDim2.new(0, 100, 1, 0)
		TabButton.Text = name
		TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.Font = Enum.Font.Gotham
		TabButton.TextSize = 14
		TabButton.BorderSizePixel = 0
		TabButton.AutoButtonColor = true

		local Page = Instance.new("Frame", Pages)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Name = name

		local List = Instance.new("UIListLayout", Page)
		List.SortOrder = Enum.SortOrder.LayoutOrder
		List.Padding = UDim.new(0, 6)

		TabButton.MouseButton1Click:Connect(function()
			PageLayout:JumpTo(Page)
		end)

		local API = {}

		function API:CreateToggle(text, callback)
			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.new(1, -10, 0, 30)
			Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 14
			Toggle.Text = text .. ": OFF"
			Toggle.BorderSizePixel = 0
			local state = false

			Toggle.MouseButton1Click:Connect(function()
				state = not state
				Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
				if callback then callback(state) end
			end)

			Toggle.Parent = Page
		end

		function API:CreateSlider(text, min, max, callback)
			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, -10, 0, 50)
			Holder.BackgroundTransparency = 1

			local Label = Instance.new("TextLabel", Holder)
			Label.Size = UDim2.new(1, 0, 0, 20)
			Label.Text = text .. ": " .. min
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.BackgroundTransparency = 1
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14

			local Bar = Instance.new("Frame", Holder)
			Bar.Position = UDim2.new(0, 0, 0, 30)
			Bar.Size = UDim2.new(1, 0, 0, 8)
			Bar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

			local Fill = Instance.new("Frame", Bar)
			Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			Fill.Size = UDim2.new(0, 0, 1, 0)

			local dragging = false

			local function update(input)
				local scale = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Fill.Size = UDim2.new(scale, 0, 1, 0)
				local val = math.floor(min + (max - min) * scale)
				Label.Text = text .. ": " .. val
				if callback then callback(val) end
			end

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input)
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

			Holder.Parent = Page
		end

		function API:CreateDropdown(text, options, callback)
			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1, -10, 0, 35)
			Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Holder.BorderSizePixel = 0

			local Dropdown = Instance.new("TextButton", Holder)
			Dropdown.Size = UDim2.new(1, 0, 1, 0)
			Dropdown.Text = text .. ": [Selecionar]"
			Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
			Dropdown.Font = Enum.Font.Gotham
			Dropdown.TextSize = 14
			Dropdown.BorderSizePixel = 0

			local Opened = false
			local ListFrame

			Dropdown.MouseButton1Click:Connect(function()
				if Opened then
					if ListFrame then ListFrame:Destroy() end
					Opened = false
				else
					Opened = true
					ListFrame = Instance.new("Frame", Holder)
					ListFrame.Position = UDim2.new(0, 0, 1, 0)
					ListFrame.Size = UDim2.new(1, 0, 0, #options * 25)
					ListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					ListFrame.BorderSizePixel = 0

					for _, option in ipairs(options) do
						local Btn = Instance.new("TextButton", ListFrame)
						Btn.Size = UDim2.new(1, 0, 0, 25)
						Btn.Text = option
						Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
						Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
						Btn.Font = Enum.Font.Gotham
						Btn.TextSize = 14
						Btn.BorderSizePixel = 0

						Btn.MouseButton1Click:Connect(function()
							Dropdown.Text = text .. ": " .. option
							if callback then callback(option) end
							ListFrame:Destroy()
							Opened = false
						end)
					end
				end
			end)

			Holder.Parent = Page
		end

		return API
	end

	return Library
end

return Library
