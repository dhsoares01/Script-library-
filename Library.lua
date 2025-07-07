-- ESP Library (Object-based) | Suporte: Box, Line, Name, Distance
-- Compatível com executores como Delta, Fluxus, Arceus X, Hydrogen
-- Atualizado: Auto-remover objetos nulos + toggle ESP.Enabled
-- Feito por ChatGPT | Licença livre para uso

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
    TeamCheck = false,
    Color = Color3.new(1, 1, 1)
}

-- Remover desenháveis de um objeto
local function removeESP(obj)
    pcall(function()
        if obj.Box then obj.Box:Remove() end
        if obj.Line then obj.Line:Remove() end
        if obj.NameLabel then obj.NameLabel:Remove() end
        if obj.DistanceLabel then obj.DistanceLabel:Remove() end
    end)
end

-- Função para criar um ESP em um objeto
function ESP:Add(object, name, color)
    local espObject = {
        Target = object,
        Name = name or object.Name,
        Color = color or ESP.Settings.Color,

        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        NameLabel = Drawing.new("Text"),
        DistanceLabel = Drawing.new("Text")
    }

    -- Configuração inicial
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

-- Atualização contínua dos ESPs
RunService.RenderStepped:Connect(function()
    for i = #ESP.Objects, 1, -1 do
        local obj = ESP.Objects[i]
        local target = obj.Target

        -- Se ESP estiver desligado ou target for inválido, limpar e remover
        if not ESP.Enabled or not target or not target:IsDescendantOf(game) or not target:FindFirstChild("HumanoidRootPart") then
            removeESP(obj)
            table.remove(ESP.Objects, i)
        else
            local root = target:FindFirstChild("HumanoidRootPart")
            local pos, visible = Camera:WorldToViewportPoint(root.Position)

            if visible then
                local size = math.clamp(2000 / (Camera.CFrame.Position - root.Position).Magnitude, 2, 300)
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
                    local distance = (Camera.CFrame.Position - root.Position).Magnitude
                    obj.DistanceLabel.Text = "[" .. math.floor(distance) .. "m]"
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
