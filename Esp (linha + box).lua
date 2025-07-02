local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP3D = {}
ESP3D.__index = ESP3D

-- Cria Frame 2D para box da ESP (usando Drawing API para desempenho e estilo 2D)
local function create2DBox()
    local box = {}
    box.Outline = Drawing.new("Square")
    box.Outline.Visible = false
    box.Outline.Color = Color3.new(0,1,0)
    box.Outline.Thickness = 2
    box.Outline.Filled = false

    box.Fill = Drawing.new("Square")
    box.Fill.Visible = false
    box.Fill.Color = Color3.new(0,1,0)
    box.Fill.Transparency = 0.15
    box.Fill.Filled = true

    return box
end

-- Cria linha 2D do jogador até a base da tela
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(0,1,0)
    line.Thickness = 2
    return line
end

-- Projeta um ponto 3D para 2D na tela, retorna nil se estiver fora da tela ou atrás da câmera
local function worldToScreen(point)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(point)
    if not onScreen or screenPoint.Z < 0 then return nil end
    return Vector2.new(screenPoint.X, screenPoint.Y)
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
        Font = Enum.Font.SourceSansBold,
    }
    if settings then
        for k,v in pairs(settings) do
            self.Settings[k] = v
        end
    end

    self.espObjects = {}

    local TextService = game:GetService("TextService")

    local function createEspForObject(obj)
        local esp = {}

        esp.Box = create2DBox()
        esp.Line = createLine()

        -- Label de texto usando Drawing
        esp.Text = Drawing.new("Text")
        esp.Text.Visible = false
        esp.Text.Color = self.Settings.TextColor
        esp.Text.Size = 14
        esp.Text.Center = true
        esp.Text.Outline = true
        esp.Text.OutlineColor = Color3.new(0,0,0)
        esp.Text.Font = 3 -- Fonte padrão do Drawing

        esp.Object = obj
        return esp
    end

    for _, obj in pairs(self.Settings.Objects) do
        if obj and obj:IsA("BasePart") then
            self.espObjects[obj] = createEspForObject(obj)
        end
    end

    self._conn = RunService.RenderStepped:Connect(function()
        if not self.Settings.Enabled then
            for _, esp in pairs(self.espObjects) do
                esp.Box.Outline.Visible = false
                esp.Box.Fill.Visible = false
                esp.Line.Visible = false
                esp.Text.Visible = false
            end
            return
        end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local playerPos = rootPart.Position

        local screenHeight = Camera.ViewportSize.Y

        for obj, esp in pairs(self.espObjects) do
            if obj and obj.Parent then
                local objPos = obj.Position
                local dist = (playerPos - objPos).Magnitude

                if dist <= self.Settings.MaxDistance then
                    -- Pega os vértices do BasePart para calcular box 2D (aproximação)
                    local corners = {}
                    local size = obj.Size / 2

                    local cf = obj.CFrame
                    local points = {
                        cf * Vector3.new(-size.X, size.Y, -size.Z),
                        cf * Vector3.new(size.X, size.Y, -size.Z),
                        cf * Vector3.new(size.X, size.Y, size.Z),
                        cf * Vector3.new(-size.X, size.Y, size.Z),

                        cf * Vector3.new(-size.X, -size.Y, -size.Z),
                        cf * Vector3.new(size.X, -size.Y, -size.Z),
                        cf * Vector3.new(size.X, -size.Y, size.Z),
                        cf * Vector3.new(-size.X, -size.Y, size.Z),
                    }

                    local screenPoints = {}
                    for i, v in ipairs(points) do
                        local screenPos = worldToScreen(v)
                        if screenPos then
                            table.insert(screenPoints, screenPos)
                        end
                    end

                    if #screenPoints < 1 then
                        -- Objeto está fora da tela, oculta
                        esp.Box.Outline.Visible = false
                        esp.Box.Fill.Visible = false
                        esp.Line.Visible = false
                        esp.Text.Visible = false
                    else
                        -- Calcula box 2D que engloba todos pontos
                        local minX, minY = math.huge, math.huge
                        local maxX, maxY = -math.huge, -math.huge

                        for _, pt in pairs(screenPoints) do
                            if pt.X < minX then minX = pt.X end
                            if pt.Y < minY then minY = pt.Y end
                            if pt.X > maxX then maxX = pt.X end
                            if pt.Y > maxY then maxY = pt.Y end
                        end

                        local boxPos = Vector2.new(minX, minY)
                        local boxSize = Vector2.new(maxX - minX, maxY - minY)

                        -- Atualiza box
                        esp.Box.Outline.Visible = true
                        esp.Box.Fill.Visible = true
                        esp.Box.Outline.Position = boxPos
                        esp.Box.Outline.Size = boxSize
                        esp.Box.Outline.Color = self.Settings.BoxColor

                        esp.Box.Fill.Position = boxPos
                        esp.Box.Fill.Size = boxSize
                        esp.Box.Fill.Color = self.Settings.BoxColor
                        esp.Box.Fill.Transparency = 0.15

                        -- Atualiza linha da base do objeto até a base da tela (linha vertical abaixo do box)
                        -- Pega a posição 3D da base do objeto (pés)
                        local bottomPos3D = cf * Vector3.new(0, -size.Y, 0)
                        local bottomScreen = worldToScreen(bottomPos3D)

                        if bottomScreen then
                            esp.Line.Visible = true
                            esp.Line.Color = self.Settings.LineColor
                            esp.Line.From = bottomScreen
                            esp.Line.To = Vector2.new(bottomScreen.X, screenHeight) -- Vai até o rodapé da tela
                        else
                            esp.Line.Visible = false
                        end

                        -- Atualiza texto acima do box
                        esp.Text.Visible = true
                        esp.Text.Text = obj.Name .. " [" .. math.floor(dist) .. "m]"
                        esp.Text.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 16)
                        esp.Text.Color = self.Settings.TextColor
                    end
                else
                    -- Desativa ESP
                    esp.Box.Outline.Visible = false
                    esp.Box.Fill.Visible = false
                    esp.Line.Visible = false
                    esp.Text.Visible = false
                end
            else
                -- Objeto inválido, remove ESP
                esp.Box.Outline:Remove()
                esp.Box.Fill:Remove()
                esp.Line:Remove()
                esp.Text:Remove()
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
        esp.Box.Outline:Remove()
        esp.Box.Fill:Remove()
        esp.Line:Remove()
        esp.Text:Remove()
    end
    self.espObjects = {}
end

return ESP3D
