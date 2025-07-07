-- ESP Library for Roblox
-- GitHub: https://github.com/yourusername/roblox-esp-library

local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

-- Configuration defaults
local defaultConfig = {
    lineColor = Color3.fromRGB(255, 0, 0),
    boxColor = Color3.fromRGB(255, 0, 0),
    textColor = Color3.fromRGB(255, 255, 255),
    textSize = 14,
    lineThickness = 1,
    boxThickness = 1,
    showDistance = true,
    showName = true,
    maxDistance = 1000,
    enabled = true
}

-- Helper function to create a Drawing object
local function createDrawing(type, props)
    local drawing = Drawing.new(type)
    for prop, value in pairs(props) do
        drawing[prop] = value
    end
    return drawing
end

-- Constructor
function ESPLibrary.new(object, config)
    local self = setmetatable({}, ESPLibrary)
    
    self.object = object
    self.config = config or defaultConfig
    self.connections = {}
    
    -- Initialize ESP components
    self.line = createDrawing("Line", {
        Thickness = self.config.lineThickness,
        Color = self.config.lineColor,
        Visible = false
    })
    
    self.box = createDrawing("Quad", {
        Thickness = self.config.boxThickness,
        Color = self.config.boxColor,
        Filled = false,
        Visible = false
    })
    
    self.distanceText = createDrawing("Text", {
        Size = self.config.textSize,
        Color = self.config.textColor,
        Outline = true,
        Center = true,
        Visible = false
    })
    
    self.nameText = createDrawing("Text", {
        Size = self.config.textSize,
        Color = self.config.textColor,
        Outline = true,
        Center = true,
        Visible = false
    })
    
    -- Set up connections
    self:setupConnections()
    
    return self
end

-- Update ESP visuals
function ESPLibrary:update()
    if not self.config.enabled or not self.object or not self.object.Parent then
        self:hide()
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Get object position (handle both BasePart and Model)
    local position
    if self.object:IsA("BasePart") then
        position = self.object.Position
    elseif self.object:IsA("Model") then
        local primaryPart = self.object.PrimaryPart or self.object:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            position = primaryPart.Position
        else
            self:hide()
            return
        end
    else
        self:hide()
        return
    end
    
    -- Calculate distance
    local distance = (camera.CFrame.Position - position).Magnitude
    if distance > self.config.maxDistance then
        self:hide()
        return
    end
    
    -- Get 2D screen position
    local screenPosition, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen then
        self:hide()
        return
    end
    
    -- Update line (from bottom center of screen to object)
    if self.config.showLine then
        self.line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
        self.line.To = Vector2.new(screenPosition.X, screenPosition.Y)
        self.line.Visible = true
    else
        self.line.Visible = false
    end
    
    -- Update box (around object)
    if self.config.showBox then
        local size = self.object:IsA("BasePart") and self.object.Size or self.object:GetExtentsSize()
        local corners = {
            camera:WorldToViewportPoint(position + Vector3.new(size.X/2, size.Y/2, size.Z/2)),
            camera:WorldToViewportPoint(position + Vector3.new(-size.X/2, size.Y/2, size.Z/2)),
            camera:WorldToViewportPoint(position + Vector3.new(-size.X/2, -size.Y/2, size.Z/2)),
            camera:WorldToViewportPoint(position + Vector3.new(size.X/2, -size.Y/2, size.Z/2))
        }
        
        if #corners == 4 then
            self.box.PointA = Vector2.new(corners[1].X, corners[1].Y)
            self.box.PointB = Vector2.new(corners[2].X, corners[2].Y)
            self.box.PointC = Vector2.new(corners[3].X, corners[3].Y)
            self.box.PointD = Vector2.new(corners[4].X, corners[4].Y)
            self.box.Visible = true
        else
            self.box.Visible = false
        end
    else
        self.box.Visible = false
    end
    
    -- Update distance text
    if self.config.showDistance then
        self.distanceText.Text = string.format("%.1f studs", distance)
        self.distanceText.Position = Vector2.new(screenPosition.X, screenPosition.Y + 20)
        self.distanceText.Visible = true
    else
        self.distanceText.Visible = false
    end
    
    -- Update name text
    if self.config.showName then
        self.nameText.Text = self.object.Name
        self.nameText.Position = Vector2.new(screenPosition.X, screenPosition.Y - 20)
        self.nameText.Visible = true
    else
        self.nameText.Visible = false
    end
end

-- Set up event connections
function ESPLibrary:setupConnections()
    -- Clean up old connections
    for _, connection in pairs(self.connections) do
        connection:Disconnect()
    end
    self.connections = {}
    
    -- Update ESP on render step
    table.insert(self.connections, game:GetService("RunService").RenderStepped:Connect(function()
        self:update()
    end))
    
    -- Clean up if object is removed
    table.insert(self.connections, self.object.AncestryChanged:Connect(function(_, parent)
        if not parent then
            self:destroy()
        end
    end))
end

-- Hide all ESP elements
function ESPLibrary:hide()
    self.line.Visible = false
    self.box.Visible = false
    self.distanceText.Visible = false
    self.nameText.Visible = false
end

-- Destroy the ESP object
function ESPLibrary:destroy()
    self:hide()
    
    -- Disconnect all events
    for _, connection in pairs(self.connections) do
        connection:Disconnect()
    end
    
    -- Remove drawing objects
    self.line:Remove()
    self.box:Remove()
    self.distanceText:Remove()
    self.nameText:Remove()
    
    setmetatable(self, nil)
end

-- Example usage:
--[[
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create ESP for all players except yourself
for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
        local esp = ESPLibrary.new(otherPlayer.Character, {
            showLine = true,
            showBox = true,
            showDistance = true,
            showName = true,
            lineColor = Color3.fromRGB(0, 255, 0),
            boxColor = Color3.fromRGB(0, 255, 0),
            maxDistance = 500
        })
    end
end
]]

return ESPLibrary
