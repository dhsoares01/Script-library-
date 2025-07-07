-- RobloxESP.lua
-- Biblioteca ESP para Roblox
-- github.com/seu-usuario/RobloxESP

local ESP = {}
ESP.Objects = {}
ESP.Settings = {
    ShowLine = true,
    ShowBox = true,
    ShowDistance = true,
    ShowName = true,
    LineColor = Color3.new(1, 0, 0),
    BoxColor = Color3.new(0, 1, 0),
    TextColor = Color3.new(1, 1, 1)
}

local camera = workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer

-- Adiciona um objeto com ESP
function ESP:AddObject(model, name)
    if not model:IsA("Model") then return end
    if self.Objects[model] then return end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false
    box.Color = self.Settings.BoxColor

    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Visible = false
    line.Color = self.Settings.LineColor

    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Visible = false
    text.Color = self.Settings.TextColor

    self.Objects[model] = {
        Model = model,
        Box = box,
        Line = line,
        Text = text,
        Name = name or model.Name
    }
end

-- Remove ESP de um objeto
function ESP:RemoveObject(model)
    if self.Objects[model] then
        self.Objects[model].Box:Remove()
        self.Objects[model].Line:Remove()
        self.Objects[model].Text:Remove()
        self.Objects[model] = nil
    end
end

-- Atualiza todos os ESPs (deve ser chamado a cada frame)
function ESP:UpdateAll()
    local camPos = camera.CFrame.Position

    for model, data in pairs(self.Objects) do
        if not model:IsDescendantOf(game) then
            self:RemoveObject(model)
        else
            local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            if primary then
                local pos, onScreen = camera:WorldToViewportPoint(primary.Position)

                if onScreen then
                    -- Caixa
                    if self.Settings.ShowBox then
                        local size = model:GetExtentsSize()
                        local corners = {}
                        for _, offset in ipairs({
                            Vector3.new(1, 1, 1), Vector3.new(-1, 1, 1),
                            Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1),
                            Vector3.new(1, -1, 1), Vector3.new(-1, -1, 1),
                            Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1)
                        }) do
                            local worldPos = primary.CFrame:pointToWorldSpace(offset * size / 2)
                            table.insert(corners, camera:WorldToViewportPoint(worldPos))
                        end

                        local minX, minY, maxX, maxY = math.huge, math.huge, 0, 0
                        for _, corner in ipairs(corners) do
                            minX = math.min(minX, corner.X)
                            minY = math.min(minY, corner.Y)
                            maxX = math.max(maxX, corner.X)
                            maxY = math.max(maxY, corner.Y)
                        end

                        data.Box.Position = Vector2.new(minX, minY)
                        data.Box.Size = Vector2.new(maxX - minX, maxY - minY)
                        data.Box.Visible = true
                    else
                        data.Box.Visible = false
                    end

                    -- Linha
                    if self.Settings.ShowLine then
                        data.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        data.Line.To = Vector2.new(pos.X, pos.Y)
                        data.Line.Visible = true
                    else
                        data.Line.Visible = false
                    end

                    -- Texto
                    if self.Settings.ShowName or self.Settings.ShowDistance then
                        local textStr = ""
                        if self.Settings.ShowName then
                            textStr = data.Name
                        end
                        if self.Settings.ShowDistance then
                            local dist = math.floor((camPos - primary.Position).Magnitude)
                            textStr = textStr .. " [" .. dist .. "m]"
                        end

                        data.Text.Text = textStr
                        data.Text.Position = Vector2.new(pos.X, pos.Y - 15)
                        data.Text.Visible = true
                    else
                        data.Text.Visible = false
                    end
                else
                    data.Box.Visible = false
                    data.Line.Visible = false
                    data.Text.Visible = false
                end
            end
        end
    end
end

return ESP
