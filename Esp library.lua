--// ESP Library by Endereço (Com toggles individuais e box corrigido, linha melhorada)
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
    d.Line.Thickness = 2
    d.Line.Transparency = 1
    d.Line.Color = ESP.Settings.Color
    d.Line.ZIndex = 2

    -- Caixa (Square)
    d.Box.Thickness = 2
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Color = ESP.Settings.Color
    d.Box.ZIndex = 2

    -- Nome
    d.Name.Size = 14
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.OutlineColor = Color3.new(0, 0, 0)
    d.Name.Transparency = 1
    d.Name.Color = ESP.Settings.Color
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
        if self.Objects[object].Drawing.Circle then
            self.Objects[object].Drawing.Circle:Remove()
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
            if esp.Drawing.Circle then
                esp.Drawing.Circle.Visible = false
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
            local size = math.clamp((1 / depth) * 1000 * scale, 3, 70)
            local boxSize = Vector2.new(size * 1.1, size * 1.5)
            local topLeft = screenPos - boxSize / 2

            -- Caixa (Box)
            drawing.Box.Position = topLeft
            drawing.Box.Size = boxSize
            drawing.Box.Visible = ESP.Settings.Box

            -- Linha (Line) melhorada
            if ESP.Settings.Line then
                local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- centro inferior da tela
                local endPos = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2)

                drawing.Line.From = startPos
                drawing.Line.To = endPos
                drawing.Line.Color = ESP.Settings.Color
                drawing.Line.Thickness = 2
                drawing.Line.Transparency = 1
                drawing.Line.ZIndex = 2
                drawing.Line.Visible = true

                -- Círculo no fim da linha
                if not drawing.Circle then
                    drawing.Circle = Drawing.new("Circle")
                    drawing.Circle.Color = ESP.Settings.Color
                    drawing.Circle.Thickness = 2
                    drawing.Circle.NumSides = 18
                    drawing.Circle.Filled = false
                    drawing.Circle.Transparency = 1
                    drawing.Circle.ZIndex = 3
                end
                drawing.Circle.Position = endPos
                drawing.Circle.Radius = 5
                drawing.Circle.Visible = true
            else
                drawing.Line.Visible = false
                if drawing.Circle then drawing.Circle.Visible = false end
            end

            -- Nome (Name)
            drawing.Name.Position = Vector2.new(screenPos.X, topLeft.Y - 20)
            drawing.Name.Text = name
            drawing.Name.Visible = ESP.Settings.Name

            -- Distância (Distance)
            local distanceInMeters = depth * 0.28
            drawing.Distance.Position = Vector2.new(screenPos.X, topLeft.Y + boxSize.Y + 8)
            drawing.Distance.Text = string.format("%.1f m", distanceInMeters)
            drawing.Distance.Visible = ESP.Settings.Distance
        else
            for _, v in pairs(drawing) do
                v.Visible = false
            end
            if drawing.Circle then
                drawing.Circle.Visible = false
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
