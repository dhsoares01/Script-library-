local DarkTabsLib = {}

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local gui = Instance.new("ScreenGui")
gui.Name = "ScriptLibrary"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = game:GetService("CoreGui") end)

-- Janela
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 350)
frame.Position = UDim2.new(0.5, -250, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderColor3 = Color3.fromRGB(50,50,50)
frame.BorderSizePixel = 1
frame.Parent = gui

-- Drag (mobile e PC)
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
rs.RenderStepped:Connect(function()
	if dragging and dragInput then
		local delta = dragInput.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Cabeçalho
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(20,20,20)
header.BorderSizePixel = 0
header.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "DarkTabs Library"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(220,220,220)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,0,0,0)
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(200,200,200)
closeBtn.Size = UDim2.new(0,30,1,0)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local minBtn = Instance.new("TextButton")
minBtn.Text = "–"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(200,200,200)
minBtn.Size = UDim2.new(0,30,1,0)
minBtn.Position = UDim2.new(1,-60,0,0)
minBtn.BackgroundTransparency = 1
minBtn.Parent = header

local contentVisible = true
minBtn.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	for _,v in pairs(frame:GetChildren()) do
		if v~=header then v.Visible=contentVisible end
	end
end)

-- Tabs
local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(0,100,1,-30)
tabs.Position = UDim2.new(0,0,0,30)
tabs.BackgroundColor3=Color3.fromRGB(30,30,30)
tabs.BorderSizePixel=0
tabs.Parent=frame

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,-100,1,-30)
pages.Position=UDim2.new(0,100,0,30)
pages.BackgroundTransparency=1
pages.Parent=frame

local UIPageLayout = Instance.new("UIPageLayout")
UIPageLayout.SortOrder=Enum.SortOrder.LayoutOrder
UIPageLayout.Parent=pages

function DarkTabsLib:CreateTab(name)
	local tabBtn=Instance.new("TextButton")
	tabBtn.Text=name
	tabBtn.Font=Enum.Font.Gotham
	tabBtn.TextSize=14
	tabBtn.TextColor3=Color3.fromRGB(220,220,220)
	tabBtn.BackgroundColor3=Color3.fromRGB(45,45,45)
	tabBtn.Size=UDim2.new(1,0,0,30)
	tabBtn.BorderSizePixel=0
	tabBtn.Parent=tabs

	local page=Instance.new("Frame")
	page.Name=name
	page.Size=UDim2.new(1,0,1,0)
	page.BackgroundTransparency=1
	page.Parent=pages

	local list=Instance.new("UIListLayout")
	list.Padding=UDim.new(0,4)
	list.Parent=page

	tabBtn.MouseButton1Click:Connect(function() UIPageLayout:JumpTo(page) end)

	local elements={}

	function elements:Toggle(text,callback)
		local btn=Instance.new("TextButton")
		btn.Text=text
		btn.Font=Enum.Font.Gotham
		btn.TextSize=14
		btn.TextColor3=Color3.fromRGB(220,220,220)
		btn.BackgroundColor3=Color3.fromRGB(50,50,50)
		btn.Size=UDim2.new(1,-10,0,25)
		btn.BorderSizePixel=1
		btn.BorderColor3=Color3.fromRGB(70,70,70)
		btn.Parent=page
		local on=false
		btn.MouseButton1Click:Connect(function()
			on=not on
			btn.BackgroundColor3=on and Color3.fromRGB(70,100,70) or Color3.fromRGB(50,50,50)
			pcall(callback,on)
		end)
	end

	function elements:ButtonOnOff(text,callback)
		local btn=Instance.new("TextButton")
		btn.Text=text
		btn.Font=Enum.Font.Gotham
		btn.TextSize=14
		btn.TextColor3=Color3.fromRGB(220,220,220)
		btn.BackgroundColor3=Color3.fromRGB(50,50,50)
		btn.Size=UDim2.new(1,-10,0,25)
		btn.BorderSizePixel=1
		btn.BorderColor3=Color3.fromRGB(70,70,70)
		btn.Parent=page
		local on=false
		btn.MouseButton1Click:Connect(function()
			on=not on
			btn.Text=text..(on and" [ON]" or" [OFF]")
			pcall(callback,on)
		end)
	end

	function elements:Slider(text,min,max,callback)
		local holder=Instance.new("Frame")
		holder.Size=UDim2.new(1,-10,0,40)
		holder.BackgroundTransparency=1
		holder.Parent=page

		local label=Instance.new("TextLabel")
		label.Text=text
		label.Font=Enum.Font.Gotham
		label.TextSize=14
		label.TextColor3=Color3.fromRGB(220,220,220)
		label.BackgroundTransparency=1
		label.Size=UDim2.new(1,0,0,20)
		label.Parent=holder

		local slider=Instance.new("Frame")
		slider.Size=UDim2.new(1,0,0,10)
		slider.Position=UDim2.new(0,0,0,25)
		slider.BackgroundColor3=Color3.fromRGB(50,50,50)
		slider.BorderSizePixel=1
		slider.BorderColor3=Color3.fromRGB(70,70,70)
		slider.Parent=holder

		local fill=Instance.new("Frame")
		fill.Size=UDim2.new(0,0,1,0)
		fill.BackgroundColor3=Color3.fromRGB(100,100,100)
		fill.BorderSizePixel=0
		fill.Parent=slider

		local dragging=false
		local function setValue(pos)
			local scale=math.clamp((pos-slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
			fill.Size=UDim2.new(scale,0,1,0)
			local value=math.floor(min+(max-min)*scale)
			pcall(callback,value)
		end
		slider.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				dragging=true;setValue(input.Position.X)
			end
		end)
		slider.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
		end)
		slider.InputChanged:Connect(function(input)
			if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
				setValue(input.Position.X)
			end
		end)
	end

	function elements:Dropdown(text,options,callback)
		local btn=Instance.new("TextButton")
		btn.Text=text
		btn.Font=Enum.Font.Gotham
		btn.TextSize=14
		btn.TextColor3=Color3.fromRGB(220,220,220)
		btn.BackgroundColor3=Color3.fromRGB(50,50,50)
		btn.Size=UDim2.new(1,-10,0,25)
		btn.Parent=page
		local open=false
		local items={}
		btn.MouseButton1Click:Connect(function()
			open=not open
			for _,v in ipairs(items) do v.Visible=open end
		end)
		for _,opt in ipairs(options) do
			local optBtn=Instance.new("TextButton")
			optBtn.Text=opt
			optBtn.Font=Enum.Font.Gotham
			optBtn.TextSize=14
			optBtn.TextColor3=Color3.fromRGB(220,220,220)
			optBtn.BackgroundColor3=Color3.fromRGB(40,40,40)
			optBtn.Size=UDim2.new(1,-20,0,20)
			optBtn.Visible=false
			optBtn.Parent=page
			table.insert(items,optBtn)
			optBtn.MouseButton1Click:Connect(function()
				pcall(callback,opt)
				open=false
				for _,v in ipairs(items)do v.Visible=false end
			end)
		end
	end

	function elements:DropdownButtonOnOff(text,options,callback)
		local btn=Instance.new("TextButton")
		btn.Text=text
		btn.Font=Enum.Font.Gotham
		btn.TextSize=14
		btn.TextColor3=Color3.fromRGB(220,220,220)
		btn.BackgroundColor3=Color3.fromRGB(50,50,50)
		btn.Size=UDim2.new(1,-10,0,25)
		btn.Parent=page
		local open=false
		local items={}
		btn.MouseButton1Click:Connect(function()
			open=not open
			for _,v in ipairs(items) do v.Visible=open end
		end)
		for _,opt in ipairs(options) do
			local optBtn=Instance.new("TextButton")
			optBtn.Text=opt
			optBtn.Font=Enum.Font.Gotham
			optBtn.TextSize=14
			optBtn.TextColor3=Color3.fromRGB(220,220,220)
			optBtn.BackgroundColor3=Color3.fromRGB(40,40,40)
			optBtn.Size=UDim2.new(1,-20,0,20)
			optBtn.Visible=false
			optBtn.Parent=page
			table.insert(items,optBtn)
			local on=false
			optBtn.MouseButton1Click:Connect(function()
				on=not on
				optBtn.Text=opt..(on and" [ON]"or" [OFF]")
				pcall(callback,opt,on)
			end)
		end
	end

	function elements:Label(text)
		local lbl=Instance.new("TextLabel")
		lbl.Text=text
		lbl.Font=Enum.Font.Gotham
		lbl.TextSize=14
		lbl.TextColor3=Color3.fromRGB(200,200,200)
		lbl.BackgroundTransparency=1
		lbl.Size=UDim2.new(1,-10,0,20)
		lbl.Parent=page
	end

	return elements
end

return DarkTabsLib
