local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP3D = {}
ESP3D.__index = ESP3D

-- Cria linha 3D entre dois pontos (Part fino e transparente)
local function createLinePart()
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.Material = Enum.Material.Neon
    part.Shape = Enum.PartType.Block
    part.Size = Vector3.new(0.1, 0.1, 1) -- comprimento vai ser escalado dinamicamente
    part.CastShadow = false
    part.Name = "ESPLINE"
    return part
end

-- Cria BillboardGui para texto flutuante
local function createBillboard(textColor)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 2, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = textColor or Color3.new(1,1,1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = ""
    textLabel.Parent = billboard

    billboard.Name = "ESPBillboard"
    billboard.Parent = nil -- será setado depois
    billboard.TextLabel = textLabel

    return billboard
end

function ESP3D.new(settings)
    local self = setmetatable({}, ESP3D)

    self.Settings = {
        Enabled = true,
        Objects = {}, -- lista de BaseParts
        MaxDistance = 250,
        LineColor = Color3.fromRGB(0,255,0),
        BoxColor = Color3.fromRGB(0,255,0),
        TextColor = Color3.fromRGB(255,255,255),
    }
    if settings then
        for k,v in pairs(settings) do
            self.Settings[k] = v
        end
    end

    self.espObjects = {}

    local function createEspForObject(obj)
        -- SelectionBox para box 3D
        local box = Instance.new("SelectionBox")
        box.Adornee = obj
        box.LineThickness = 0.01
        box.Color3 = self.Settings.BoxColor
        box.Parent = obj

        -- Linha 3D entre jogador e objeto
        local line = createLinePart()
        line.Color = self.Settings.LineColor
        line.Parent = workspace

        -- BillboardGui para texto
        local billboard = createBillboard(self.Settings.TextColor)
        billboard.Parent = obj

        return {
            Object = obj,
            Box = box,
            Line = line,
            Billboard = billboard,
        }
    end

    -- Inicializa ESP para cada objeto
    for _, obj in pairs(self.Settings.Objects) do
        if obj and obj:IsA("BasePart") then
            self.espObjects[obj] = createEspForObject(obj)
        end
    end

    -- Atualiza tudo a cada frame
    self._conn = RunService.RenderStepped:Connect(function()
        if not self.Settings.Enabled then
            for _, esp in pairs(self.espObjects) do
                esp.Box.Visible = false
                esp.Line.Transparency = 1
                esp.Billboard.Enabled = false
            end
            return
        end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local playerPos = rootPart.Position

        for obj, esp in pairs(self.espObjects) do
            if obj and obj.Parent then
                local objPos = obj.Position
                local dist = (playerPos - objPos).Magnitude

                if dist <= self.Settings.MaxDistance then
                    -- Ativa ESP
                    esp.Box.Visible = true
                    esp.Box.Color3 = self.Settings.BoxColor

                    -- Atualiza linha 3D
                    local direction = (objPos - playerPos)
                    local midPoint = playerPos + direction/2
                    esp.Line.Size = Vector3.new(0.05, 0.05, direction.Magnitude)
                    esp.Line.CFrame = CFrame.new(midPoint, objPos) * CFrame.new(0,0,-direction.Magnitude/2)
                    esp.Line.Transparency = 0 -- visível
                    esp.Line.Color = self.Settings.LineColor

                    -- Atualiza texto
                    esp.Billboard.Enabled = true
                    esp.Billboard.TextLabel.Text = tostring(obj.Name) .. " [" .. math.floor(dist) .. "m]"
                    esp.Billboard.TextLabel.TextColor3 = self.Settings.TextColor
                else
                    -- Desativa ESP
                    esp.Box.Visible = false
                    esp.Line.Transparency = 1
                    esp.Billboard.Enabled = false
                end
            else
                -- Objeto inválido, remove ESP
                esp.Box:Destroy()
                esp.Line:Destroy()
                esp.Billboard:Destroy()
                self.espObjects[obj] = nil
            end
        end
    end)

    return self
end

function ESP3D:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    for _, esp in pairs(self.espObjects) do
        if esp.Box then esp.Box:Destroy() end
        if esp.Line then esp.Line:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
    end
    self.espObjects = {}
end

return ESP3D
