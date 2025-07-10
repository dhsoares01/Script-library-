--[[

FloatingUILibrary para Roblox
=============================

• Menu flutuante com cabeçalho, minimizar/expandir, fechar.
• Tabs à esquerda; ScrollView de funções à direita.
• Suporte a: Toggle, Slider, ButtonOnOff, Label.
• Arrastável (mouse e toque).
• Reset e destruição seguros.
• Otimizado para loadstring via Github.

--]]

local FloatingUILibrary = {}
FloatingUILibrary.__index = FloatingUILibrary

-- Utilidades
local function makeDraggable(frame, dragArea)
	local userInput = game:GetService("UserInputService")
	local runService = game:GetService("RunService")
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			dragInput = input
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragArea.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	userInput.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- Resettable interface
local Resettable = {}
function Resettable:Reset() end

-- UI Components
local function createToggle(default, text, callback)
	local toggle = setmetatable({}, {__index=Resettable})
	local value = default and true or false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 32)
	frame.BackgroundTransparency = 1

	local btn = Instance.new("TextButton")
	btn.Parent = frame
	btn.Size = UDim2.new(0, 32, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.Text = value and "✓" or ""
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 24
	btn.Position = UDim2.new(0,4, 0,0)

	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.Size = UDim2.new(1, -40, 1, 0)
	lbl.Position = UDim2.new(0, 40, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text or "Toggle"
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	btn.MouseButton1Click:Connect(function()
		value = not value
		btn.Text = value and "✓" or ""
		if callback then callback(value) end
	end)

	function toggle:Reset()
		value = default
		btn.Text = value and "✓" or ""
		if callback then callback(value) end
	end

	function toggle:GetValue() return value end
	function toggle:SetValue(v)
		value = v
		btn.Text = value and "✓" or ""
		if callback then callback(value) end
	end

	return frame, toggle
end

local function createSlider(minV, maxV, default, text, callback)
	local slider = setmetatable({}, {__index=Resettable})
	local value = default or minV

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,48)
	frame.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.Size = UDim2.new(1,0,0,20)
	lbl.Position = UDim2.new(0,0,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = (text or "Slider") .. " ["..tostring(value).."]"
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame")
	bar.Parent = frame
	bar.Size = UDim2.new(1,-20,0,8)
	bar.Position = UDim2.new(0,10,0,28)
	bar.BackgroundColor3 = Color3.fromRGB(55,55,55)
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true

	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.Size = UDim2.new((value-minV)/(maxV-minV),0,1,0)
	fill.BorderSizePixel = 0

	local knob = Instance.new("TextButton")
	knob.Parent = bar
	knob.Size = UDim2.new(0,16,1,8)
	knob.Position = UDim2.new((value-minV)/(maxV-minV),-8,-0.5,-4)
	knob.BackgroundColor3 = Color3.fromRGB(70,70,70)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.BorderSizePixel = 0
	knob.ZIndex = 2

	local dragging = false
	local function setValue(v)
		value = math.clamp(math.floor(v+0.5), minV, maxV)
		local pct = (value-minV)/(maxV-minV)
		fill.Size = UDim2.new(pct,0,1,0)
		knob.Position = UDim2.new(pct,-8,-0.5,-4)
		lbl.Text = (text or "Slider") .. " ["..tostring(value).."]"
		if callback then callback(value) end
	end

	local function inputPos(x)
		local relX = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
		setValue(minV + relX*(maxV-minV))
	end

	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			inputPos(input.Position.X)
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			inputPos(input.Position.X)
		end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if dragging then dragging = false end
	end)

	function slider:Reset()
		setValue(default or minV)
	end
	function slider:GetValue() return value end
	function slider:SetValue(v) setValue(v) end

	return frame, slider
end

local function createButtonOnOff(default, text, callback)
	local button = setmetatable({}, {__index=Resettable})
	local state = default and true or false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,32)
	frame.BackgroundTransparency = 1

	local btn = Instance.new("TextButton")
	btn.Parent = frame
	btn.Size = UDim2.new(1,0,1,0)
	btn.BackgroundColor3 = state and Color3.fromRGB(0,120,0) or Color3.fromRGB(60,60,60)
	btn.Text = text or "Button"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 16

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.BackgroundColor3 = state and Color3.fromRGB(0,120,0) or Color3.fromRGB(60,60,60)
		if callback then callback(state) end
	end)

	function button:Reset()
		state = default
		btn.BackgroundColor3 = state and Color3.fromRGB(0,120,0) or Color3.fromRGB(60,60,60)
		if callback then callback(state) end
	end
	function button:GetValue() return state end
	function button:SetValue(v)
		state = v
		btn.BackgroundColor3 = state and Color3.fromRGB(0,120,0) or Color3.fromRGB(60,60,60)
		if callback then callback(state) end
	end

	return frame, button
end

local function createLabel(text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,26)
	frame.BackgroundTransparency = 1
	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 16
	lbl.Text = text or "Label"
	return frame
end

-- Tab system
function FloatingUILibrary:New(title)
	local self = setmetatable({}, FloatingUILibrary)

	-- Container
	local sg = Instance.new("ScreenGui")
	sg.Name = "FloatingUILibrary"
	pcall(function() sg.Parent = gethui and gethui() or game:GetService("CoreGui") end)
	if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

	-- Menu Frame
	local main = Instance.new("Frame")
	main.Name = "MainMenu"
	main.Size = UDim2.new(0,420,0,320)
	main.Position = UDim2.new(0.5,-210,0.4,-160)
	main.BackgroundColor3 = Color3.fromRGB(28,28,32)
	main.BorderSizePixel = 0
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Parent = sg

	main.Active = true
	main.Draggable = false

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1,0,0,36)
	header.BackgroundColor3 = Color3.fromRGB(32,32,36)
	header.Parent = main

	local headerLbl = Instance.new("TextLabel")
	headerLbl.Parent = header
	headerLbl.Size = UDim2.new(1,-80,1,0)
	headerLbl.Position = UDim2.new(0,12,0,0)
	headerLbl.BackgroundTransparency = 1
	headerLbl.Text = title or "Floating UI"
	headerLbl.TextColor3 = Color3.new(1,1,1)
	headerLbl.Font = Enum.Font.GothamSemibold
	headerLbl.TextSize = 20
	headerLbl.TextXAlignment = Enum.TextXAlignment.Left

	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Parent = header
	minimizeBtn.Size = UDim2.new(0,36,1,0)
	minimizeBtn.Position = UDim2.new(1,-72,0,0)
	minimizeBtn.BackgroundTransparency = 1
	minimizeBtn.Text = "–"
	minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 30

	local closeBtn = Instance.new("TextButton")
	closeBtn.Parent = header
	closeBtn.Size = UDim2.new(0,36,1,0)
	closeBtn.Position = UDim2.new(1,-36,0,0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.fromRGB(220,80,80)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 30

	-- Left Tabs
	local tabsArea = Instance.new("Frame")
	tabsArea.Name = "Tabs"
	tabsArea.Size = UDim2.new(0,105,1,-36)
	tabsArea.Position = UDim2.new(0,0,0,36)
	tabsArea.BackgroundColor3 = Color3.fromRGB(25,25,28)
	tabsArea.Parent = main

	local tabsList = Instance.new("UIListLayout")
	tabsList.Parent = tabsArea
	tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabsList.SortOrder = Enum.SortOrder.LayoutOrder
	tabsList.Padding = UDim.new(0,6)

	-- Right ScrollView
	local contentArea = Instance.new("Frame")
	contentArea.Name = "Content"
	contentArea.Size = UDim2.new(1,-105,1,-36)
	contentArea.Position = UDim2.new(0,105,0,36)
	contentArea.BackgroundColor3 = Color3.fromRGB(32,32,36)
	contentArea.Parent = main
	contentArea.ClipsDescendants = true

	local scroll = Instance.new("ScrollingFrame")
	scroll.Parent = contentArea
	scroll.Size = UDim2.new(1,0,1,0)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.ScrollBarThickness = 4
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.Parent = scroll
	scrollLayout.Padding = UDim.new(0,6)

	-- Tabs logic
	self._tabs = {}
	self._tabBtns = {}
	self._tabContents = {}
	self._currentTab = nil
	self._resetList = {}

	function self:AddTab(tabName)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Parent = tabsArea
		tabBtn.Size = UDim2.new(1,-16,0,32)
		tabBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
		tabBtn.Text = tabName or "Tab"
		tabBtn.TextColor3 = Color3.new(1,1,1)
		tabBtn.Font = Enum.Font.GothamBold
		tabBtn.TextSize = 16
		tabBtn.AutoButtonColor = false

		local tabContent = Instance.new("Frame")
		tabContent.Size = UDim2.new(1,0,1,0)
		tabContent.BackgroundTransparency = 1
		tabContent.Name = "TabContent_"..tabName
		tabContent.Parent = scroll
		tabContent.Visible = false

		local tabContentLayout = Instance.new("UIListLayout")
		tabContentLayout.Parent = tabContent
		tabContentLayout.Padding = UDim.new(0,7)
		tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Show only this tab
		tabBtn.MouseButton1Click:Connect(function()
			for k,btn in pairs(self._tabBtns) do
				btn.BackgroundColor3 = Color3.fromRGB(40,40,44)
			end
			for k,content in pairs(self._tabContents) do
				content.Visible = false
			end
			tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			tabContent.Visible = true
			self._currentTab = tabName
		end)

		if not self._currentTab then
			tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			tabContent.Visible = true
			self._currentTab = tabName
		end

		self._tabs[tabName] = {btn=tabBtn, content=tabContent}
		self._tabBtns[tabName] = tabBtn
		self._tabContents[tabName] = tabContent

		return {
			AddToggle = function(_, ...)
				local ui, obj = createToggle(...)
				ui.Parent = tabContent
				table.insert(self._resetList, obj)
				return obj
			end,
			AddSlider = function(_, ...)
				local ui, obj = createSlider(...)
				ui.Parent = tabContent
				table.insert(self._resetList, obj)
				return obj
			end,
			AddButtonOnOff = function(_, ...)
				local ui, obj = createButtonOnOff(...)
				ui.Parent = tabContent
				table.insert(self._resetList, obj)
				return obj
			end,
			AddLabel = function(_, ...)
				local ui = createLabel(...)
				ui.Parent = tabContent
				return ui
			end,
		}
	end

	-- Minimize/Expand
	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			for _,v in ipairs(main:GetChildren()) do
				if v ~= header then v.Visible = false end
			end
			main.Size = UDim2.new(0,220,0,46)
			minimizeBtn.Text = "+"
		else
			for _,v in ipairs(main:GetChildren()) do
				v.Visible = true
			end
			main.Size = UDim2.new(0,420,0,320)
			minimizeBtn.Text = "–"
		end
	end)

	-- Close
	closeBtn.MouseButton1Click:Connect(function()
		for _,obj in ipairs(self._resetList) do
			if typeof(obj)=="table" and obj.Reset then
				obj:Reset()
			end
		end
		sg:Destroy()
		for k in pairs(self) do self[k]=nil end
	end)

	-- Draggable
	makeDraggable(main, header)

	return self
end

-- Exports
return FloatingUILibrary

--[[

USO EXEMPLO:

local UILib = loadstring(game:HttpGet("https://github.com/seuusuario/seurepo/raw/main/FloatingUILibrary.lua"))()
local menu = UILib:New("Meu Menu")

local tab1 = menu:AddTab("Funções")
tab1:AddLabel("Bem-vindo à Library!")
tab1:AddToggle(true, "Ativar algo", function(v) print("Toggle:",v) end)
tab1:AddSlider(0,100,50,"Volume", function(v) print("Slider:",v) end)
tab1:AddButtonOnOff(false, "Modo Turbo", function(v) print("Turbo:",v) end)

local tab2 = menu:AddTab("Config")
tab2:AddLabel("Configurações Avançadas")

]]
