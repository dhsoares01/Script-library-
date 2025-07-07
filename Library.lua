local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

function Library:CreateWindow(title)
	local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 300, 0, 40)
	Main.Position = UDim2.new(0.5, -150, 0.3, 0)
	Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Main.BorderSizePixel = 0
	Main.Name = "MainWindow"

	local Header = Instance.new("TextButton", Main)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.Text = title or "Menu"
	Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Header.TextColor3 = Color3.fromRGB(255, 255, 255)
	Header.Font = Enum.Font.SourceSansBold
	Header.TextSize = 20
	Header.AutoButtonColor = false

	local TabsHolder = Instance.new("Frame", Main)
	TabsHolder.Position = UDim2.new(0, 0, 0, 40)
	TabsHolder.Size = UDim2.new(1, 0, 0, 30)
	TabsHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	TabsHolder.BorderSizePixel = 0

	local Body = Instance.new("Frame", Main)
	Body.Position = UDim2.new(0, 0, 0, 70)
	Body.Size = UDim2.new(1, 0, 0, 200)
	Body.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Body.BorderSizePixel = 0

	local UIList = Instance.new("UIListLayout", Body)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 6)

	local open = true

	Header.MouseButton1Click:Connect(function()
		open = not open
		local targetSize = open and UDim2.new(0, 300, 0, 270) or UDim2.new(0, 300, 0, 40)
		TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play()
	end)

	local function createTab(name)
		local tabBtn = Instance.new("TextButton", TabsHolder)
		tabBtn.Size = UDim2.new(0, 100, 1, 0)
		tabBtn.Text = name
		tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabBtn.Font = Enum.Font.SourceSans
		tabBtn.TextSize = 16
		tabBtn.BorderSizePixel = 0
		tabBtn.AutoButtonColor = true

		local tabContent = Instance.new("Frame")
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.Visible = false
		tabContent.Parent = Body

		Instance.new("UIListLayout", tabContent).Padding = UDim.new(0, 6)

		tabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(Body:GetChildren()) do
				if v:IsA("Frame") then v.Visible = false end
			end
			tabContent.Visible = true
		end)

		if #Body:GetChildren() == 1 then
			tabContent.Visible = true
		end

		return tabContent
	end

	local function createToggle(text, callback)
		local toggle = Instance.new("TextButton")
		toggle.Size = UDim2.new(1, -10, 0, 30)
		toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggle.Font = Enum.Font.SourceSans
		toggle.TextSize = 18
		toggle.Text = text .. ": OFF"
		toggle.BorderSizePixel = 0
		local state = false

		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = text .. ": " .. (state and "ON" or "OFF")
			if callback then callback(state) end
		end)

		return toggle
	end

	local function createSlider(text, min, max, callback)
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -10, 0, 50)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Text = text .. ": " .. min
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSans
		label.TextSize = 16

		local slider = Instance.new("Frame", holder)
		slider.Position = UDim2.new(0, 0, 0, 25)
		slider.Size = UDim2.new(1, 0, 0, 10)
		slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

		local fill = Instance.new("Frame", slider)
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

		local dragging = false

		local function update(input)
			local sizeScale = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(sizeScale, 0, 1, 0)
			local value = math.floor(min + (max - min) * sizeScale)
			label.Text = text .. ": " .. value
			if callback then callback(value) end
		end

		slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				update(input)
			end
		end)

		slider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
				update(input)
			end
		end)

		return holder
	end

	local function createDropdown(text, options, callback)
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, -10, 0, 40)
		holder.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

		local dropdown = Instance.new("TextButton", holder)
		dropdown.Size = UDim2.new(1, 0, 1, 0)
		dropdown.Text = text .. ": [Selecionar]"
		dropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
		dropdown.Font = Enum.Font.SourceSans
		dropdown.TextSize = 16
		dropdown.BorderSizePixel = 0

		local open = false
		local listFrame

		dropdown.MouseButton1Click:Connect(function()
			if open then
				if listFrame then listFrame:Destroy() end
				open = false
			else
				open = true
				listFrame = Instance.new("Frame", holder)
				listFrame.Position = UDim2.new(0, 0, 1, 0)
				listFrame.Size = UDim2.new(1, 0, 0, #options * 30)
				listFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				listFrame.BorderSizePixel = 0

				for _, opt in ipairs(options) do
					local btn = Instance.new("TextButton", listFrame)
					btn.Size = UDim2.new(1, 0, 0, 30)
					btn.Text = opt
					btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					btn.TextColor3 = Color3.fromRGB(255, 255, 255)
					btn.Font = Enum.Font.SourceSans
					btn.TextSize = 16
					btn.AutoButtonColor = true
					btn.BorderSizePixel = 0

					btn.MouseButton1Click:Connect(function()
						dropdown.Text = text .. ": " .. opt
						if callback then callback(opt) end
						listFrame:Destroy()
						open = false
					end)
				end
			end
		end)

		return holder
	end

	return {
		CreateTab = function(_, name)
			local tabFrame = createTab(name)

			return {
				CreateToggle = function(_, text, callback)
					local t = createToggle(text, callback)
					t.Parent = tabFrame
				end,
				CreateSlider = function(_, text, min, max, callback)
					local s = createSlider(text, min, max, callback)
					s.Parent = tabFrame
				end,
				CreateDropdown = function(_, text, list, callback)
					local d = createDropdown(text, list, callback)
					d.Parent = tabFrame
				end
			}
		end
	}
end

return Library
