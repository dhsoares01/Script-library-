-- ESP Library (Object-based) | Suporte: Box, Line, Name, Distance
-- Compatível com executores como Delta, Fluxus, Arceus X, Hydrogen
-- Feito por ChatGPT | Licença livre para uso

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true -- novo: toggle principal
ESP.Settings = {
    Box = true,
    Line = true,
    Name = true,
    Distance = true,
    TeamCheck = false,
    Color = Color3.new(1, 1, 1)
}

-- Remover um ESP manualmente
function ESP:RemoveESP(index)
    local obj = self.Objects[index]
    if obj then
        for _, drawing in pairs({obj.Box, obj.Line, obj.NameLabel, obj.DistanceLabel}) do
            if drawing and drawing.Remove then drawing:Remove() end
        end
        table.remove(self.Objects, index)
    end
end

-- Criar ESP em um objeto
function ESP:Add(object, name, color)
    if not object or typeof(object) ~= "Instance" then return end

    local espObject = {
        Target = object,
        Name = name or object.Name,
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

    table.insert(self.Objects, espObject)
end

-- Alternar ESP
function ESP:Enable()
    self.Enabled = true
end

function ESP:Disable()
    self.Enabled = false
    for _, obj in ipairs(self.Objects) do
        for _, drawing in pairs({obj.Box, obj.Line, obj.NameLabel, obj.DistanceLabel}) do
            drawing.Visible = false
        end
    end
end

-- Atualização contínua
RunService.RenderStepped:Connect(function()
    for i = #ESP.Objects, 1, -1 do
        local obj = ESP.Objects[i]
        local target = obj.Target

        -- Remove ESP se alvo foi destruído
        if not target or not target:IsDescendantOf(game) then
            ESP:RemoveESP(i)
        elseif ESP.Enabled and target:FindFirstChild("HumanoidRootPart") then
            local root = target:FindFirstChild("HumanoidRootPart")
            local pos, visible = Camera:WorldToViewportPoint(root.Position)

            if visible then
                local distance = (Camera.CFrame.Position - root.Position).Magnitude
                local size = math.clamp(2000 / distance, 2, 300)
                local boxSize = Vector2.new(size, size * 1.5)

                -- Box ESP
                obj.Box.Size = boxSize
                obj.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                obj.Box.Visible = ESP.Settings.Box

                -- Line ESP
                obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Line.To = Vector2.new(pos.X, pos.Y)
                obj.Line.Visible = ESP.Settings.Line

                -- Name ESP
                obj.NameLabel.Text = obj.Name
                obj.NameLabel.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
                obj.NameLabel.Visible = ESP.Settings.Name

                -- Distance ESP
                obj.DistanceLabel.Text = "[" .. math.floor(distance) .. "m]"
                obj.DistanceLabel.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
                obj.DistanceLabel.Visible = ESP.Settings.Distance
            else
                obj.Box.Visible = false
                obj.Line.Visible = false
                obj.NameLabel.Visible = false
                obj.DistanceLabel.Visible = false
            end
        else
            -- Caso ESP esteja desativado
            obj.Box.Visible = false
            obj.Line.Visible = false
            obj.NameLabel.Visible = false
            obj.DistanceLabel.Visible = false
        end
    end
end)

return ESP
