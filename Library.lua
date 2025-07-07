-- ESP Library para objetos por endereço
-- Suporta Line e Box

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true
ESP.LineColor = Color3.fromRGB(255, 0, 0)
ESP.BoxColor = Color3.fromRGB(0, 255, 0)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Cria um novo objeto ESP
function ESP:AddObject(obj)
    if not obj or not obj:IsA("BasePart") then
        warn("ESP: Objeto inválido ou não é BasePart")
        return
    end
    if self.Objects[obj] then
        return -- já existe
    end

    local espData = {}

    -- Criar Drawing objects
    espData.Line = Drawing.new("Line")
    espData.Line.Color = self.LineColor
    espData.Line.Thickness = 1
    espData.Line.Transparency = 1
    espData.Line.Visible = true

    espData.BoxLines = {}
    for i=1,4 do
        local line = Drawing.new("Line")
        line.Color = self.BoxColor
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = true
        table.insert(espData.BoxLines, line)
    end

    self.Objects[obj] = espData
end

-- Remove ESP de um objeto
function ESP:RemoveObject(obj)
    local espData = self.Objects[obj]
    if espData then
        espData.Line.Visible = false
        espData.Line:Remove()
        for _, line in pairs(espData.BoxLines) do
            line.Visible = false
            line:Remove()
        end
        self.Objects[obj] = nil
    end
end

-- Atualiza a posição da box 2D do objeto
function ESP:GetBoundingBox2D(obj)
    local corners = {}

    -- Pega os 8 pontos da bounding box do objeto no mundo
    local cframe = obj.CFrame
    local size = obj.Size / 2

    local points = {
        cframe * Vector3.new(-size.X, -size.Y, -size.Z),
        cframe * Vector3.new(-size.X, -size.Y, size.Z),
        cframe * Vector3.new(-size.X, size.Y, -size.Z),
        cframe * Vector3.new(-size.X, size.Y, size.Z),
        cframe * Vector3.new(size.X, -size.Y, -size.Z),
        cframe * Vector3.new(size.X, -size.Y, size.Z),
        cframe * Vector3.new(size.X, size.Y, -size.Z),
        cframe * Vector3.new(size.X, size.Y, size.Z),
    }

    for _, point in pairs(points) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(point)
        if onScreen then
            table.insert(corners, Vector2.new(screenPos.X, screenPos.Y))
        end
    end

    if #corners == 0 then
        return nil
    end

    -- Calcula min e max para formar a box 2D
    local minX = corners[1].X
    local maxX = corners[1].X
    local minY = corners[1].Y
    local maxY = corners[1].Y

    for i=2,#corners do
        local v = corners[i]
        if v.X < minX then minX = v.X end
        if v.X > maxX then maxX = v.X end
        if v.Y < minY then minY = v.Y end
        if v.Y > maxY then maxY = v.Y end
    end

    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

-- Atualiza a ESP toda frame
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end

    for obj, espData in pairs(ESP.Objects) do
        if not obj or not obj.Parent then
            -- Objeto removido
            ESP:RemoveObject(obj)
        else
            local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            if onScreen then
                -- Atualiza linha (do centro da tela até o objeto)
                local centerScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                espData.Line.From = centerScreen
                espData.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                espData.Line.Visible = true

                -- Atualiza box
                local min, max = ESP:GetBoundingBox2D(obj)
                if min and max then
                    -- 4 linhas da box
                    local lines = espData.BoxLines

                    lines[1].From = Vector2.new(min.X, min.Y)
                    lines[1].To = Vector2.new(max.X, min.Y)

                    lines[2].From = Vector2.new(max.X, min.Y)
                    lines[2].To = Vector2.new(max.X, max.Y)

                    lines[3].From = Vector2.new(max.X, max.Y)
                    lines[3].To = Vector2.new(min.X, max.Y)

                    lines[4].From = Vector2.new(min.X, max.Y)
                    lines[4].To = Vector2.new(min.X, min.Y)

                    for i=1,4 do
                        lines[i].Visible = true
                    end
                else
                    for i=1,4 do
                        espData.BoxLines[i].Visible = false
                    end
                end

            else
                -- Fora da tela
                espData.Line.Visible = false
                for i=1,4 do
                    espData.BoxLines[i].Visible = false
                end
            end
        end
    end
end)

return ESP
