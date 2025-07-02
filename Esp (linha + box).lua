local ObjectESP = {}
ObjectESP.__index = ObjectESP

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ObjectESP.new(configPerObject)
	local self = setmetatable({}, ObjectESP)

	self.Objects = configPerObject or {}
	self.Drawings = {}
	self.GuiFolder = Instance.new("Folder", game.CoreGui)
	self.GuiFolder.Name = "ESP3D_Guis"

	RunService.RenderStepped:Connect(function()
		for obj, cfg in pairs(self.Objects) do
			if obj and obj:IsA("BasePart") then
				local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
				local distance = (Camera.CFrame.Position - obj.Position).Magnitude

				-- CRIA DRAWINGS SE NECESSÁRIO
				self:CreateDrawings(obj, cfg)

				-- LINE 2D
				if cfg.Line2D then
					local line = self.Drawings[obj].Line2D
					line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
					line.To = Vector2.new(pos.X, pos.Y)
					line.Visible = onScreen
				end

				-- BOX 2D
				if cfg.Box2D then
					local size = obj.Size * 1.5
					local corner = Camera:WorldToViewportPoint(obj.Position + Vector3.new(size.X, size.Y, 0))
					local topLeft = Vector2.new(pos.X - (corner.X - pos.X), pos.Y - (corner.Y - pos.Y))
					local bottomRight = Vector2.new(pos.X + (corner.X - pos.X), pos.Y + (corner.Y - pos.Y))

					local box = self.Drawings[obj].Box2D
					box.Position = topLeft
					box.Size = bottomRight - topLeft
					box.Visible = onScreen
				end

				-- NAME 2D
				if cfg.Name2D then
					local text = self.Drawings[obj].Name2D
					text.Position = Vector2.new(pos.X, pos.Y - 20)
					text.Text = obj.Name
					text.Visible = onScreen
				end

				-- DISTANCE 2D
				if cfg.Distance2D then
					local text = self.Drawings[obj].Distance2D
					text.Position = Vector2.new(pos.X, pos.Y + 15)
					text.Text = string.format("%.1fm", distance)
					text.Visible = onScreen
				end

				-- LINE 3D
				if cfg.Line3D then
					local a = self.Drawings[obj].Line3D
					a.Adornee = obj
					a.Visible = true
				end

				-- BOX 3D
				if cfg.Box3D then
					local b = self.Drawings[obj].Box3D
					b.Adornee = obj
					b.Size = obj.Size
					b.Visible = true
				end

				-- NAME 3D
				if cfg.Name3D then
					local txt = self.Drawings[obj].Name3D
					txt.Adornee = obj
					txt.TextLabel.Text = obj.Name
					txt.Enabled = true
				end

				-- DISTANCE 3D
				if cfg.Distance3D then
					local txt = self.Drawings[obj].Distance3D
					txt.Adornee = obj
					txt.TextLabel.Text = string.format("%.1fm", distance)
					txt.Enabled = true
				end
			end
		end
	end)

	return self
end

function ObjectESP:CreateDrawings(obj, cfg)
	if self.Drawings[obj] then return end
	self.Drawings[obj] = {}

	-- 2D
	if cfg.Line2D then
		local line = Drawing.new("Line")
		line.Thickness = 1
		line.Color = cfg.Color or Color3.new(1, 1, 1)
		line.Visible = false
		self.Drawings[obj].Line2D = line
	end
	if cfg.Box2D then
		local box = Drawing.new("Square")
		box.Color = cfg.Color or Color3.new(1, 1, 1)
		box.Thickness = 1
		box.Filled = false
		box.Visible = false
		self.Drawings[obj].Box2D = box
	end
	if cfg.Name2D then
		local text = Drawing.new("Text")
		text.Size = 14
		text.Center = true
		text.Outline = true
		text.Color = cfg.Color or Color3.new(1, 1, 1)
		text.Visible = false
		self.Drawings[obj].Name2D = text
	end
	if cfg.Distance2D then
		local text = Drawing.new("Text")
		text.Size = 13
		text.Center = true
		text.Outline = true
		text.Color = cfg.Color or Color3.new(1, 1, 1)
		text.Visible = false
		self.Drawings[obj].Distance2D = text
	end

	-- 3D
	if cfg.Line3D then
		local adorn = Instance.new("Beam", obj)
		adorn.Attachment0 = Instance.new("Attachment", obj)
		adorn.Attachment1 = Instance.new("Attachment", Camera)
		adorn.Width0 = 0.1
		adorn.Width1 = 0.1
		adorn.Color = ColorSequence.new(cfg.Color or Color3.new(1,1,1))
		adorn.FaceCamera = true
		adorn.Enabled = true
		self.Drawings[obj].Line3D = adorn
	end

	if cfg.Box3D then
		local box = Instance.new("BoxHandleAdornment")
		box.Size = obj.Size
		box.Adornee = obj
		box.AlwaysOnTop = true
		box.ZIndex = 0
		box.Color3 = cfg.Color or Color3.new(1,1,1)
		box.Transparency = 0.2
		box.Parent = self.GuiFolder
		self.Drawings[obj].Box3D = box
	end

	if cfg.Name3D then
		local gui = Instance.new("BillboardGui", self.GuiFolder)
		gui.Size = UDim2.new(0, 100, 0, 20)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		local text = Instance.new("TextLabel", gui)
		text.Size = UDim2.new(1, 0, 1, 0)
		text.TextScaled = true
		text.BackgroundTransparency = 1
		text.TextColor3 = cfg.Color or Color3.new(1, 1, 1)
		gui.TextLabel = text
		self.Drawings[obj].Name3D = gui
	end

	if cfg.Distance3D then
		local gui = Instance.new("BillboardGui", self.GuiFolder)
		gui.Size = UDim2.new(0, 100, 0, 20)
		gui.StudsOffset = Vector3.new(0, 2, 0)
		gui.AlwaysOnTop = true
		local text = Instance.new("TextLabel", gui)
		text.Size = UDim2.new(1, 0, 1, 0)
		text.TextScaled = true
		text.BackgroundTransparency = 1
		text.TextColor3 = cfg.Color or Color3.new(1, 1, 1)
		gui.TextLabel = text
		self.Drawings[obj].Distance3D = gui
	end
end

return ObjectESP
