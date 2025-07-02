local ObjectESP = {}
ObjectESP.__index = ObjectESP

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ObjectESP.new(objects, config)
	local self = setmetatable({}, ObjectESP)

	self.Objects = objects
	self.Config = {
		Line2D = config.Line2D or false,
		Line3D = config.Line3D or false,
		Box2D = config.Box2D or false,
		Box3D = config.Box3D or false,
		Name2D = config.Name2D or false,
		Name3D = config.Name3D or false,
		Distance2D = config.Distance2D or false,
		Distance3D = config.Distance3D or false,
		Color = config.Color or Color3.new(1, 1, 1)
	}

	self.Connections = {}
	self:Start()
	return self
end

function ObjectESP:Start()
	self.Connections.Render = RunService.RenderStepped:Connect(function()
		self:RenderAll()
	end)
end

function ObjectESP:RenderAll()
	for _, object in pairs(self.Objects) do
		if object and object:IsA("BasePart") then
			local pos, onScreen = Camera:WorldToViewportPoint(object.Position)

			-- 2D Line
			if self.Config.Line2D and onScreen then
				self:DrawLine2D(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), Vector2.new(pos.X, pos.Y), self.Config.Color)
			end

			-- 3D Line
			if self.Config.Line3D then
				self:DrawLine3D(Camera.CFrame.Position, object.Position, self.Config.Color)
			end

			-- 2D Box
			if self.Config.Box2D and onScreen then
				self:DrawBox2D(pos, 50, 50, self.Config.Color)
			end

			-- 3D Box
			if self.Config.Box3D then
				self:DrawBox3D(object, self.Config.Color)
			end

			-- 2D Name
			if self.Config.Name2D and onScreen then
				self:DrawText2D(object.Name, Vector2.new(pos.X, pos.Y - 20), self.Config.Color)
			end

			-- 3D Name
			if self.Config.Name3D then
				self:DrawBillboard(object, object.Name, self.Config.Color)
			end

			-- 2D Distance
			if self.Config.Distance2D and onScreen then
				local dist = (Camera.CFrame.Position - object.Position).Magnitude
				self:DrawText2D(string.format("%.1f", dist), Vector2.new(pos.X, pos.Y + 10), self.Config.Color)
			end

			-- 3D Distance
			if self.Config.Distance3D then
				local dist = (Camera.CFrame.Position - object.Position).Magnitude
				self:DrawBillboard(object, string.format("%.1f", dist), self.Config.Color)
			end
		end
	end
end

function ObjectESP:DrawLine2D(from, to, color)
	local line = Drawing.new("Line")
	line.From = from
	line.To = to
	line.Color = color
	line.Thickness = 1.5
	line.Transparency = 1
	line.Visible = true
	game:GetService("Debris"):AddItem(line, 0.03)
end

function ObjectESP:DrawLine3D(from, to, color)
	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Color = color
	part.Size = Vector3.new(0.05, 0.05, (from - to).Magnitude)
	part.CFrame = CFrame.new(from, to) * CFrame.new(0, 0, -part.Size.Z / 2)
	game:GetService("Debris"):AddItem(part, 0.03)
end

function ObjectESP:DrawBox2D(center, width, height, color)
	local box = Drawing.new("Square")
	box.Position = center - Vector2.new(width/2, height/2)
	box.Size = Vector2.new(width, height)
	box.Color = color
	box.Thickness = 1.5
	box.Transparency = 1
	box.Visible = true
	game:GetService("Debris"):AddItem(box, 0.03)
end

function ObjectESP:DrawBox3D(part, color)
	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Size = part.Size
	box.Transparency = 0.5
	box.Color3 = color
	box.Parent = part
	game:GetService("Debris"):AddItem(box, 0.03)
end

function ObjectESP:DrawText2D(text, pos, color)
	local txt = Drawing.new("Text")
	txt.Text = text
	txt.Position = pos
	txt.Color = color
	txt.Size = 13
	txt.Center = true
	txt.Outline = true
	txt.Transparency = 1
	txt.Visible = true
	game:GetService("Debris"):AddItem(txt, 0.03)
end

function ObjectESP:DrawBillboard(part, text, color)
	local bill = Instance.new("BillboardGui", part)
	bill.Size = UDim2.new(0, 100, 0, 20)
	bill.Adornee = part
	bill.AlwaysOnTop = true

	local label = Instance.new("TextLabel", bill)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextScaled = true
	label.Text = text
	label.Font = Enum.Font.ArialBold
	game:GetService("Debris"):AddItem(bill, 0.03)
end

function ObjectESP:Destroy()
	if self.Connections.Render then
		self.Connections.Render:Disconnect()
	end
end

return ObjectESP
