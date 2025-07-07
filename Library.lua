local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true
ESP.Settings = {
    Box = true,
    Line = true,
    Name = true,
    Distance = true,
    Color = Color3.new(1, 1, 1)
}

function ESP:Add(object, name, color)
    -- Evita adicionar objetos nulos
    if not object then return end

    local espObject = {
        Target = object,
        Name = name or (object.Name or "Unknown"),
        Color = color or ESP.Settings.Color,

        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        NameLabel = Drawing.new("Text"),
        DistanceLabel = Drawing.new("Text")
    }

    espObject.Box.Thickness = 1
    espObject.Box.Transparency = 1
    espObject.Box.Color = espObject.Color
    espObject.Box.Filled = false

    espObject.Line.Thickness = 1
    espObject.Line.Transparency = 1
    espObject.Line.Color = espObject.Color

    espObject.NameLabel.Size = 14
    espObject.NameLabel.Center = true
    espObject.NameLabel.Outline = true
    espObject.NameLabel.Color = espObject.Color

    espObject.DistanceLabel.Size = 13
    espObject.DistanceLabel.Center = true
    espObject.DistanceLabel.Outline = true
    espObject.DistanceLabel.Color = espObject.Color

    table.insert(ESP.Objects, espObject)
end

function ESP:Remove(espObject)
    espObject.Box:Remove()
    espObject.Line:Remove()
    espObject.NameLabel:Remove()
    espObject.DistanceLabel:Remove()
end

-- Limpa todos os ESPs da tela e da lista
function ESP:Clear()
    for i = #ESP.Objects, 1, -1 do
        ESP:Remove(ESP.Objects[i])
        table.remove(ESP.Objects, i)
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        -- Quando desativado, oculta e remove os desenhos
        for i = #ESP.Objects, 1, -1 do
            local obj = ESP.Objects[i]
            ESP:Remove(obj)
            table.remove(ESP.Objects, i)
        end
        return
    end

    for i = #ESP.Objects, 1, -1 do
        local obj = ESP.Objects[i]
        local target = obj.Target

        -- Remove se o alvo não existir ou foi destruído
        if not target or not target:IsDescendantOf(game) then
            ESP:Remove(obj)
            table.remove(ESP.Objects, i)
        else
            local pos, visible = Camera:WorldToViewportPoint(target.Position)

            if visible then
                local dist = (Camera.CFrame.Position - target.Position).Magnitude
                local size = math.clamp(2000 / dist, 2, 300)
                local boxSize = Vector2.new(size, size * 1.5)

                -- Box ESP
                if ESP.Settings.Box then
                    obj.Box.Size = boxSize
                    obj.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    obj.Box.Visible = true
                else
                    obj.Box.Visible = false
                end

                -- Line ESP
                if ESP.Settings.Line then
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Visible = true
                else
                    obj.Line.Visible = false
                end

                -- Name ESP
                if ESP.Settings.Name then
                    obj.NameLabel.Text = obj.Name
                    obj.NameLabel.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
                    obj.NameLabel.Visible = true
                else
                    obj.NameLabel.Visible = false
                end

                -- Distance ESP
                if ESP.Settings.Distance then
                    obj.DistanceLabel.Text = "[" .. math.floor(dist) .. "m]"
                    obj.DistanceLabel.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
                    obj.DistanceLabel.Visible = true
                else
                    obj.DistanceLabel.Visible = false
                end
            else
                obj.Box.Visible = false
                obj.Line.Visible = false
                obj.NameLabel.Visible = false
                obj.DistanceLabel.Visible = false
            end
        end
    end
end)

return ESP
