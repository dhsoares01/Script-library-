local Library = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ARGB para Color3 conversão
local function ARGBtoColor3(r, g, b)
	return Color3.fromRGB(r, g, b)
end

function Library:Create(title)
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "FloatingModUI"
	ScreenGui.ResetOnSpawn = false

	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Size = UDim2.new(0, 500, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.Draggable = true

	local Sidebar = Instance.new("Frame", MainFrame)
	Sidebar.Size = UDim2.new(0, 100, 1, 0)
	Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

	local Title = Instance.new("TextLabel", Sidebar)
	Title.Size = UDim2.new(1, 0, 0, 50)
	Title.Text = title or "Menu"
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18

	local TabsFolder = Instance.new("Folder", MainFrame)

	local function CreateTab(tabName)
		local TabButton = Instance.new("TextButton", Sidebar)
		TabButton.Size = UDim2.new(1, 0, 0, 30)
		TabButton.Text = tabName
		TabButton.BackgroundTransparency = 1
		TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		TabButton.Font = Enum.Font.Gotham
		TabButton.TextSize = 14

		local TabFrame = Instance.new("Frame", TabsFolder)
		TabFrame.Name = tabName
		TabFrame.Size = UDim2.new(1, -100, 1, 0)
		TabFrame.Position = UDim2.new(0, 100, 0, 0)
		TabFrame.BackgroundTransparency = 1
		TabFrame.Visible = false

		local Layout = Instance.new("UIListLayout", TabFrame)
		Layout.Padding = UDim.new(0, 8)

		TabButton.MouseButton1Click:Connect(function()
			for _, tab in pairs(TabsFolder:GetChildren()) do
				tab.Visible = false
			end
			TabFrame.Visible = true
		end)

		local Section = {}

		function Section:AddButton(text, callback)
			local Btn = Instance.new("TextButton", TabFrame)
			Btn.Size = UDim2.new(0, 350, 0, 30)
			Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			Btn.Text = text
			Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 14

			Btn.MouseButton1Click:Connect(function()
				pcall(callback)
			end)
		end

		function Section:AddToggle(text, callback)
			local Toggle = Instance.new("TextButton", TabFrame)
			Toggle.Size = UDim2.new(0, 350, 0, 30)
			Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			Toggle.Text = text .. ": OFF"
			Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 14

			local state = false
			Toggle.MouseButton1Click:Connect(function()
				state = not state
				Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
				pcall(callback, state)
			end)
		end

		function Section:AddSlider(text, min, max, default, callback)
			local Frame = Instance.new("Frame", TabFrame)
			Frame.Size = UDim2.new(0, 350, 0, 30)
			Frame.BackgroundTransparency = 1

			local Label = Instance.new("TextLabel", Frame)
			Label.Size = UDim2.new(0.5, 0, 1, 0)
			Label.Text = text .. ": " .. default
			Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.BackgroundTransparency = 1

			local Slider = Instance.new("TextButton", Frame)
			Slider.Position = UDim2.new(0.5, 0, 0, 0)
			Slider.Size = UDim2.new(0.5, 0, 1, 0)
			Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			Slider.Text = tostring(default)
			Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
			Slider.Font = Enum.Font.Gotham
			Slider.TextSize = 14

			local value = default
			Slider.MouseButton1Click:Connect(function()
				local input = tonumber(game:GetService("UserInputService"):GetStringForKeyCode(Enum.KeyCode.Return))
				if input then
					value = math.clamp(input, min, max)
					Label.Text = text .. ": " .. tostring(value)
					Slider.Text = tostring(value)
					pcall(callback, value)
				end
			end)
		end

		function Section:AddColorPicker(text, default, callback)
			local Picker = Instance.new("TextButton", TabFrame)
			Picker.Size = UDim2.new(0, 350, 0, 30)
			Picker.BackgroundColor3 = default or Color3.fromRGB(255, 0, 0)
			Picker.Text = text
			Picker.TextColor3 = Color3.fromRGB(255, 255, 255)
			Picker.Font = Enum.Font.Gotham
			Picker.TextSize = 14

			Picker.MouseButton1Click:Connect(function()
				local r = math.random(0, 255)
				local g = math.random(0, 255)
				local b = math.random(0, 255)
				local color = ARGBtoColor3(r, g, b)
				Picker.BackgroundColor3 = color
				pcall(callback, color)
			end)
		end

		return Section
	end

	return {
		CreateTab = CreateTab
	}
end

return Library
