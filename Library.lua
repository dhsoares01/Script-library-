--[[

FloatingUILibrary para Roblox - DESIGN MELHORADO
================================================

• Layout mais clean, moderno e responsivo.
• Efeitos visuais nos botões e tabs.
• Elementos com cantos arredondados, sombras e cores suaves.
• Hover/feedback visual nos controles.
• Scrollbar personalizada.
• Melhor contraste e separação de áreas.

--]]

local FloatingUILibrary = {}
FloatingUILibrary.__index = FloatingUILibrary

-- Utilidades
local function makeDraggable(frame, dragArea)
	local userInput = game:GetService("UserInputService")
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
	frame.Size = UDim2.new(1, 0, 0, 38)
	frame.BackgroundTransparency = 1

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local btn = Instance.new("TextButton")
	btn.Parent = frame
	btn.Size = UDim2.new(0, 36, 0, 36)
	btn.Position = UDim2.new(0, 0, 0, 1)
	btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
	btn.Text = value and "✓" or ""
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 22
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local btnShadow = Instance.new("ImageLabel", btn)
	btnShadow.BackgroundTransparency = 1
	btnShadow.Image = "rbxassetid://1316045217"
	btnShadow.Size = UDim2.new(1.3, 0, 1.3, 0)
	btnShadow.Position = UDim2.new(-0.15, 0, -0.15, 0)
	btnShadow.ImageColor3 = Color3.fromRGB(0,0,0)
	btnShadow.ImageTransparency = 0.9

	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.Size = UDim2.new(1, -44, 1, 0)
	lbl.Position = UDim2.new(0, 44, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text or "Toggle"
	lbl.TextColor3 = Color3.fromRGB(220,220,235)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 17
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Hover visual
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60,60,68)
		btnShadow.ImageTransparency = 0.8
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
		btnShadow.ImageTransparency = 0.9
	end)

	btn.MouseButton1Click:Connect(function()
		value = not value
		btn.Text = value and "✓" or ""
		btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
		if callback then callback(value) end
	end)

	function toggle:Reset()
		value = default
		btn.Text = value and "✓" or ""
		btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
		if callback then callback(value) end
	end

	function toggle:GetValue() return value end
	function toggle:SetValue(v)
		value = v
		btn.Text = value and "✓" or ""
		btn.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 50)
		if callback then callback(value) end
	end

	return frame, toggle
end

local function createSlider(minV, maxV, default, text, callback)
	local slider = setmetatable({}, {__index=Resettable})
	local value = default or minV

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,56)
	frame.BackgroundTransparency = 1
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Parent = frame
	lbl.Size = UDim2.new(1,0,0,22)
	lbl.Position = UDim2.new(0,0,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = (text or "Slider") .. " ["..tostring(value).."]"
	lbl.TextColor3 = Color3.fromRGB(220,220,235)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame")
	bar.Parent = frame
	bar.Size = UDim2.new(1,-20,0,10)
	bar.Position = UDim2.new(0,10,0,30)
	bar.BackgroundColor3 = Color3.fromRGB(55,60,70)
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.Size = UDim2.new((value-minV)/(maxV-minV),0,1,0)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("TextButton")
	knob.Parent = bar
	knob.Size = UDim2.new(0,18,1,10)
	knob.Position = UDim2.new((value-minV)/(maxV-minV),-9,-0.5,-5)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.Text = ""
	knob.AutoButtonColor = true
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
	local knobShadow = Instance.new("ImageLabel", knob)
	knobShadow.BackgroundTransparency = 1
	knobShadow.Image = "rbxassetid://1316045217"
	knobShadow.Size = UDim2.new(1.25,0,1.25,0)
	knobShadow.Position = UDim2.new(-0.125,0,-0.125,0)
	knobShadow.ImageColor3 = Color3.fromRGB(0,0,0)
	knobShadow.ImageTransparency = 0.88

	local dragging = false
	local function setValue(v)
		value = math.clamp(math.floor(v+0.5), minV, maxV)
		local pct = (value-minV)/(maxV-minV)
		fill.Size = UDim2.new(pct,0,1,0)
		knob.Position = UDim2.new(pct,-9,-0.5,-5)
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

	-- Hover
	knob.MouseEnter:Connect(function()
		knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		knobShadow.ImageTransparency = 0.8
	end)
	knob.MouseLeave:Connect(function()
		knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
		knobShadow.ImageTransparency = 0.88
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
	frame.Size = UDim2.new(1,0,0,36)
	frame.BackgroundTransparency = 1
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

	local btn = Instance.new("TextButton")
	btn.Parent = frame
	btn.Size = UDim2.new(1,0,1,0)
	btn.BackgroundColor3 = state and Color3.fromRGB(0,170,80) or Color3.fromRGB(48,48,56)
	btn.Text = text or "Button"
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 16
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local btnShadow = Instance.new("ImageLabel", btn)
	btnShadow.BackgroundTransparency = 1
	btnShadow.Image = "rbxassetid://1316045217"
	btnShadow.Size = UDim2.new(1.3, 0, 1.3, 0)
	btnShadow.Position = UDim2.new(-0.15, 0, -0.15, 0)
	btnShadow.ImageColor3 = Color3.fromRGB(0,0,0)
	btnShadow.ImageTransparency = 0.9

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60,60,70)
		btnShadow.ImageTransparency = 0.8
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = state and Color3.fromRGB(0,170,80) or Color3.fromRGB(48,48,56)
		btnShadow.ImageTransparency = 0.9
	end)

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.BackgroundColor3 = state and Color3.fromRGB(0,170,80) or Color3.fromRGB(48,48,56)
		if callback then callback(state) end
	end)

	function button:Reset()
		state = default
		btn.BackgroundColor3 = state and Color3.fromRGB(0,170,80) or Color3.fromRGB(48,48,56)
		if callback then callback(state) end
	end
	function button:GetValue() return state end
	function button:SetValue(v)
		state = v
		btn.BackgroundColor3 = state and Color3.fromRGB(0,170,80) or Color3.fromRGB(48,48,56)
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
	lbl.TextColor3 = Color3.fromRGB(180,180,200)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
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
	sg.IgnoreGuiInset = true
	pcall(function() sg.Parent = gethui and gethui() or game:GetService("CoreGui") end)
	if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

	-- Menu Frame
	local main = Instance.new("Frame")
	main.Name = "MainMenu"
	main.Size = UDim2.new(0,440,0,350)
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Position = UDim2.new(0.5,0,0.5,0)
	main.BackgroundColor3 = Color3.fromRGB(22,24,30)
	main.BorderSizePixel = 0
	main.Parent = sg
	Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)
	local shadow = Instance.new("ImageLabel", main)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.Size = UDim2.new(1.2,0,1.2,0)
	shadow.Position = UDim2.new(-0.1,0,-0.1,0)
	shadow.ImageColor3 = Color3.fromRGB(0,0,0)
	shadow.ImageTransparency = 0.85
	shadow.ZIndex = 0

	main.Active = true
	main.Draggable = false

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1,0,0,44)
	header.BackgroundColor3 = Color3.fromRGB(30,34,45)
	header.Parent = main
	header.ZIndex = 2
	Instance.new("UICorner", header).CornerRadius = UDim.new(0,16)

	local headerLbl = Instance.new("TextLabel")
	headerLbl.Parent = header
	headerLbl.Size = UDim2.new(1,-100,1,0)
	headerLbl.Position = UDim2.new(0,18,0,0)
	headerLbl.BackgroundTransparency = 1
	headerLbl.Text = title or "Floating UI"
	headerLbl.TextColor3 = Color3.fromRGB(220,220,255)
	headerLbl.Font = Enum.Font.GothamBold
	headerLbl.TextSize = 22
	headerLbl.TextXAlignment = Enum.TextXAlignment.Left

	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Parent = header
	minimizeBtn.Size = UDim2.new(0,40,1,0)
	minimizeBtn.Position = UDim2.new(1,-82,0,0)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(36,40,54)
	minimizeBtn.Text = "–"
	minimizeBtn.TextColor3 = Color3.fromRGB(180,180,220)
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 34
	minimizeBtn.AutoButtonColor = false
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1,0)
	local minShad = Instance.new("ImageLabel", minimizeBtn)
	minShad.BackgroundTransparency = 1
	minShad.Image = "rbxassetid://1316045217"
	minShad.Size = UDim2.new(1.2,0,1.2,0)
	minShad.Position = UDim2.new(-0.1,0,-0.1,0)
	minShad.ImageColor3 = Color3.fromRGB(0,0,0)
	minShad.ImageTransparency = 0.85

	minimizeBtn.MouseEnter:Connect(function()
		minimizeBtn.BackgroundColor3 = Color3.fromRGB(40,80,140)
		minShad.ImageTransparency = 0.8
	end)
	minimizeBtn.MouseLeave:Connect(function()
		minimizeBtn.BackgroundColor3 = Color3.fromRGB(36,40,54)
		minShad.ImageTransparency = 0.85
	end)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Parent = header
	closeBtn.Size = UDim2.new(0,40,1,0)
	closeBtn.Position = UDim2.new(1,-42,0,0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(54,36,36)
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 32
	closeBtn.AutoButtonColor = false
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
	local closeShad = Instance.new("ImageLabel", closeBtn)
	closeShad.BackgroundTransparency = 1
	closeShad.Image = "rbxassetid://1316045217"
	closeShad.Size = UDim2.new(1.2,0,1.2,0)
	closeShad.Position = UDim2.new(-0.1,0,-0.1,0)
	closeShad.ImageColor3 = Color3.fromRGB(0,0,0)
	closeShad.ImageTransparency = 0.85

	closeBtn.MouseEnter:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(120,50,50)
		closeShad.ImageTransparency = 0.75
	end)
	closeBtn.MouseLeave:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(54,36,36)
		closeShad.ImageTransparency = 0.85
	end)

	-- Left Tabs
	local tabsArea = Instance.new("Frame")
	tabsArea.Name = "Tabs"
	tabsArea.Size = UDim2.new(0,120,1,-44)
	tabsArea.Position = UDim2.new(0,0,0,44)
	tabsArea.BackgroundColor3 = Color3.fromRGB(26,28,38)
	tabsArea.Parent = main
	Instance.new("UICorner", tabsArea).CornerRadius = UDim.new(0,12)

	local tabsList = Instance.new("UIListLayout")
	tabsList.Parent = tabsArea
	tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabsList.SortOrder = Enum.SortOrder.LayoutOrder
	tabsList.Padding = UDim.new(0,8)

	-- Right ScrollView
	local contentArea = Instance.new("Frame")
	contentArea.Name = "Content"
	contentArea.Size = UDim2.new(1,-120,1,-44)
	contentArea.Position = UDim2.new(0,120,0,44)
	contentArea.BackgroundColor3 = Color3.fromRGB(35,38,54)
	contentArea.Parent = main
	contentArea.ClipsDescendants = true
	Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0,10)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Parent = contentArea
	scroll.Size = UDim2.new(1,0,1,0)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.ScrollBarThickness = 7
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.BorderSizePixel = 0

	-- Custom scrollbar color
	scroll.ScrollBarImageColor3 = Color3.fromRGB(0,170,255)
	scroll.ScrollBarImageTransparency = 0.3

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.Parent = scroll
	scrollLayout.Padding = UDim.new(0,9)

	-- Tabs logic
	self._tabs = {}
	self._tabBtns = {}
	self._tabContents = {}
	self._currentTab = nil
	self._resetList = {}

	function self:AddTab(tabName)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Parent = tabsArea
		tabBtn.Size = UDim2.new(1,-24,0,38)
		tabBtn.BackgroundColor3 = Color3.fromRGB(44,46,56)
		tabBtn.Text = tabName or "Tab"
		tabBtn.TextColor3 = Color3.fromRGB(200,220,250)
		tabBtn.Font = Enum.Font.GothamBold
		tabBtn.TextSize = 17
		tabBtn.AutoButtonColor = false
		Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(1,0)
		local btnShadow = Instance.new("ImageLabel", tabBtn)
		btnShadow.BackgroundTransparency = 1
		btnShadow.Image = "rbxassetid://1316045217"
		btnShadow.Size = UDim2.new(1.2,0,1.2,0)
		btnShadow.Position = UDim2.new(-0.1,0,-0.1,0)
		btnShadow.ImageColor3 = Color3.fromRGB(0,0,0)
		btnShadow.ImageTransparency = 0.9

		tabBtn.MouseEnter:Connect(function()
			if self._currentTab ~= tabName then
				tabBtn.BackgroundColor3 = Color3.fromRGB(60,80,120)
				btnShadow.ImageTransparency = 0.85
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if self._currentTab ~= tabName then
				tabBtn.BackgroundColor3 = Color3.fromRGB(44,46,56)
				btnShadow.ImageTransparency = 0.9
			end
		end)

		local tabContent = Instance.new("Frame")
		tabContent.Size = UDim2.new(1,0,1,0)
		tabContent.BackgroundTransparency = 1
		tabContent.Name = "TabContent_"..tabName
		tabContent.Parent = scroll
		tabContent.Visible = false

		local tabContentLayout = Instance.new("UIListLayout")
		tabContentLayout.Parent = tabContent
		tabContentLayout.Padding = UDim.new(0,12)
		tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Show only this tab
		tabBtn.MouseButton1Click:Connect(function()
			for k,btn in pairs(self._tabBtns) do
				btn.BackgroundColor3 = Color3.fromRGB(44,46,56)
				btn:FindFirstChildOfClass("ImageLabel").ImageTransparency = 0.9
			end
			for k,content in pairs(self._tabContents) do
				content.Visible = false
			end
			tabBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
			btnShadow.ImageTransparency = 0.7
			tabContent.Visible = true
			self._currentTab = tabName
		end)

		if not self._currentTab then
			tabBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
			btnShadow.ImageTransparency = 0.7
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
			main.Size = UDim2.new(0,210,0,56)
			minimizeBtn.Text = "+"
		else
			for _,v in ipairs(main:GetChildren()) do
				v.Visible = true
			end
			main.Size = UDim2.new(0,440,0,350)
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
