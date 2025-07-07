local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Configurações padrão
ESP.Config = {
    LineEnabled = true,
    BoxEnabled = true,
    NameEnabled = true,
    DistanceEnabled = true,
    LineColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(0, 255, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
}

-- Função para criar objetos Drawing
local function createDrawing(type)
    local d = Drawing.new(type)
    d.Visible = false
    return d
end

-- Cria ESP para um objeto (obj pode ser qualquer Instância com posição e boundingbox)
function ESP.newForObject(obj, displayName)
    local self = setmetatable({}, ESP)
    self.Object = obj
    self.NameText = displayName or obj.Name

    self.Line = createDrawing("Line")
    self.Box = createDrawing("Square")
    self.Name = createDrawing("Text")
    self.Distance = createDrawing("Text")

    return self
end

-- Atualiza posição do ESP para o objeto
function ESP:update()
    if not self.Object or not self.Object.Parent then
        self:hideAll()
        return
    end

    local success, minVec, maxVec = pcall(function()
        return self.Object:GetBoundingBox()
    end)
    if not success then
        self:hideAll()
        return
    end

    local center = (minVec + maxVec) / 2

    local screenPos, visible = Camera:WorldToViewportPoint(center)
    if not visible then
        self:hideAll()
        return
    end

    local dist = (Camera.CFrame.Position - center).Magnitude
    if dist > ESP.Config.MaxDistance then
        self:hideAll()
        return
    end

    -- Linha: da base da tela até o objeto
    if ESP.Config.LineEnabled then
        self.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        self.Line.To = Vector2.new(screenPos.X, screenPos.Y)
        self.Line.Color = ESP.Config.LineColor
        self.Line.Visible = true
    else
        self.Line.Visible = false
    end

    -- Caixa em volta
    if ESP.Config.BoxEnabled then
        local corners = {
            Vector3.new(minVec.X, maxVec.Y, minVec.Z),
            Vector3.new(maxVec.X, maxVec.Y, minVec.Z),
            Vector3.new(maxVec.X, maxVec.Y, maxVec.Z),
            Vector3.new(minVec.X, maxVec.Y, maxVec.Z),
            Vector3.new(minVec.X, minVec.Y, minVec.Z),
            Vector3.new(maxVec.X, minVec.Y, minVec.Z),
            Vector3.new(maxVec.X, minVec.Y, maxVec.Z),
            Vector3.new(minVec.X, minVec.Y, maxVec.Z),
        }

        local screenPoints = {}
        for i, corner in pairs(corners) do
            local sp, vis = Camera:WorldToViewportPoint(corner)
            screenPoints[i] = Vector2.new(sp.X, sp.Y)
        end

        local minX = math.huge
        local maxX = -math.huge
        local minY = math.huge
        local maxY = -math.huge
        for _, point in pairs(screenPoints) do
            minX = math.min(minX, point.X)
            maxX = math.max(maxX, point.X)
            minY = math.min(minY, point.Y)
            maxY = math.max(maxY, point.Y)
        end

        self.Box.Position = Vector2.new(minX, minY)
        self.Box.Size = Vector2.new(maxX - minX, maxY - minY)
        self.Box.Color = ESP.Config.BoxColor
        self.Box.Thickness = 2
        self.Box.Visible = true
    else
        self.Box.Visible = false
    end

    -- Nome
    if ESP.Config.NameEnabled then
        self.Name.Text = self.NameText
        self.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
        self.Name.Center = true
        self.Name.Color = ESP.Config.TextColor
        self.Name.Visible = true
        self.Name.Outline = true
    else
        self.Name.Visible = false
    end

    -- Distância
    if ESP.Config.DistanceEnabled then
        self.Distance.Text = string.format("%.0f m", dist)
        self.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 15)
        self.Distance.Center = true
        self.Distance.Color = ESP.Config.TextColor
        self.Distance.Visible = true
        self.Distance.Outline = true
    else
        self.Distance.Visible = false
    end
end

function ESP:hideAll()
    self.Line.Visible = false
    self.Box.Visible = false
    self.Name.Visible = false
    self.Distance.Visible = false
end

function ESP:remove()
    self.Line:Remove()
    self.Box:Remove()
    self.Name:Remove()
    self.Distance:Remove()
end

-- Gerenciador de múltiplos ESPs
local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager.new()
    local self = setmetatable({}, ESPManager)
    self.ESPObjects = {}

    RunService.RenderStepped:Connect(function()
        for obj, esp in pairs(self.ESPObjects) do
            if not obj or not obj.Parent then
                esp:remove()
                self.ESPObjects[obj] = nil
            else
                esp:update()
            end
        end
    end)

    return self
end

function ESPManager:addObject(obj, displayName)
    if not self.ESPObjects[obj] then
        self.ESPObjects[obj] = ESP.newForObject(obj, displayName)
    end
end

function ESPManager:removeObject(obj)
    if self.ESPObjects[obj] then
        self.ESPObjects[obj]:remove()
        self.ESPObjects[obj] = nil
    end
end

function ESPManager:clear()
    for _, esp in pairs(self.ESPObjects) do
        esp:remove()
    end
    self.ESPObjects = {}
end

return ESPManager
