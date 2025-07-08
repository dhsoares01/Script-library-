local ESP = {
    Enabled = true,
    Objects = {},
    Settings = {
        Line = true,
        Box = true,
        Name = true,
        Distance = true,
        Color = Color3.fromRGB(255, 170, 0),
        FOVCorrection = true,
        MaxDistance = 2000 -- Em studs
    }
}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Função para calcular caixa mínima 2D do BasePart projetado na tela
local function GetBoundingBox(part)
    local corners = {}

    local cframe = part.CFrame
    local size = part.Size / 2

    -- 8 pontos do cubo
    local points = {
        cframe * Vector3.new( size.X,  size.Y,  size.Z),
        cframe * Vector3.new( size.X,  size.Y, -size.Z),
        cframe * Vector3.new( size.X, -size.Y,  size.Z),
        cframe * Vector3.new( size.X, -size.Y, -size.Z),
        cframe * Vector3.new(-size.X,  size.Y,  size.Z),
        cframe * Vector3.new(-size.X,  size.Y, -size.Z),
        cframe * Vector3.new(-size.X, -size.Y,  size.Z),
        cframe * Vector3.new(-size.X, -size.Y, -size.Z),
    }

    for _, point in ipairs(points) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(point)
        if onScreen then
            table.insert(corners, Vector2.new(screenPos.X, screenPos.Y))
        end
    end

    if #corners == 0 then
        return nil -- Nenhum ponto visível
    end

    -- Encontrar retângulo mínimo que engloba todos os pontos visíveis
    local minX = corners[1].X
    local maxX = corners[1].X
    local minY = corners[1].Y
    local maxY = corners[1].Y

    for i = 2, #corners do
        local v = corners[i]
        if v.X < minX then minX = v.X end
        if v.X > maxX then maxX = v.X end
        if v.Y < minY then minY = v.Y end
        if v.Y > maxY then maxY = v.Y end
    end

    local size = Vector2.new(maxX - minX, maxY - minY)
    local position = Vector2.new(minX, minY)

    return position, size
end

function ESP:Add(object, name)
    if not object:IsA("BasePart") then return end
    if self.Objects[object] then return end

    self.Objects[object] = {
        Name = name or object.Name,
        Part = object,
        Drawing = {
            Line = Drawing.new("Line"),
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text")
        }
    }

    local d = self.Objects[object].Drawing

    -- Linha
    d.Line.Thickness = 1.5
    d.Line.Transparency = 1
    d.Line.Color = self.Settings.Color
    d.Line.ZIndex = 2

    -- Caixa (Square)
    d.Box.Thickness = 2
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Color = self.Settings.Color
    d.Box.ZIndex = 2

    -- Nome
    d.Name.Size = 14
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.OutlineColor = Color3.new(0, 0, 0)
    d.Name.Transparency = 1
    d.Name.Color = self.Settings.Color
    d.Name.Font = Enum.Font.GothamSemibold
    d.Name.ZIndex = 3

    -- Distância
    d.Distance.Size = 12
    d.Distance.Center = true
    d.Distance.Outline = true
    d.Distance.OutlineColor = Color3.new(0, 0, 0)
    d.Distance.Transparency = 1
    d.Distance.Color = Color3.fromRGB(200, 200, 200)
    d.Distance.Font = Enum.Font.Gotham
    d.Distance.ZIndex = 3
end

function ESP:Remove(object)
    if self.Objects[object] then
        for _, v in pairs(self.Objects[object].Drawing) do
            v:Remove()
        end
        self.Objects[object] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, esp in pairs(ESP.Objects) do
            for _, draw in pairs(esp.Drawing) do
                draw.Visible = false
            end
        end
        return
    end

    for object, data in pairs(ESP.Objects) do
        if not object or not object:IsDescendantOf(workspace) then
            ESP:Remove(object)
            continue
        end

        local part = data.Part
        local name = data.Name
        local drawing = data.Drawing

        local screenPos, onScreen, depth = WorldToScreen(part.Position)

        if onScreen and depth < ESP.Settings.MaxDistance then
            local scale = ESP.Settings.FOVCorrection and (90 / Camera.FieldOfView) or 1

            local boxPos, boxSize = GetBoundingBox(part)

            if not boxPos or not boxSize then
                -- Se nenhum ponto visível, oculta tudo
                for _, v in pairs(drawing) do
                    v.Visible = false
                end
                continue
            end

            -- Aplicar escala proporcional ao FOV no tamanho da box
            boxSize = boxSize * scale

            -- Caixa (Box)
            drawing.Box.Position = boxPos
            drawing.Box.Size = boxSize
            drawing.Box.Visible = ESP.Settings.Box

            -- Linha (Line) do meio da base da tela até o meio da caixa (parte inferior)
            drawing.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawing.Line.To = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y)
            drawing.Line.Visible = ESP.Settings.Line

            -- Nome (Name) acima da caixa
            drawing.Name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 18)
            drawing.Name.Text = name
            drawing.Name.Visible = ESP.Settings.Name

            -- Distância (Distance) abaixo da caixa
            local distanceInMeters = depth * 0.28
            drawing.Distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 4)
            drawing.Distance.Text = string.format("%.1f m", distanceInMeters)
            drawing.Distance.Visible = ESP.Settings.Distance
        else
            for _, v in pairs(drawing) do
                v.Visible = false
            end
        end
    end
end)

function ESP:Clear()
    for obj in pairs(self.Objects) do
        self:Remove(obj)
    end
end

return ESP
