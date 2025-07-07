-- ESP Library
local ESP = {}
ESP.Enabled = true
ESP.Objects = {}

-- Configurações padrão
ESP.Config = {
    LineColor = Color3.fromRGB(255, 255, 255),
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(255, 255, 0),
    MaxDistance = 1000,
    Font = Drawing.Fonts.UI,
    Thickness = 2,
    TextSize = 14,
}

-- Função para criar ESP para um objeto com posição
function ESP:AddObject(obj, config)
    config = config or {}
    local espData = {
        Object = obj,
        ShowLine = config.ShowLine or false,
        ShowBox = config.ShowBox or false,
        ShowName = config.ShowName or false,
        ShowDistance = config.ShowDistance or false,
        ColorLine = config.ColorLine or self.Config.LineColor,
        ColorBox = config.ColorBox or self.Config.BoxColor,
        ColorName = config.ColorName or self.Config.NameColor,
        ColorDistance = config.ColorDistance or self.Config.DistanceColor,
        Thickness = config.Thickness or self.Config.Thickness,
        TextSize = config.TextSize or self.Config.TextSize,
        Font = config.Font or self.Config.Font,
    }
    table.insert(self.Objects, espData)
end

-- Remove todos os ESPs
function ESP:Clear()
    for _, espData in pairs(self.Objects) do
        if espData.Line then espData.Line:Remove() end
        if espData.Box then espData.Box:Remove() end
        if espData.NameText then espData.NameText:Remove() end
        if espData.DistanceText then espData.DistanceText:Remove() end
    end
    self.Objects = {}
end

-- Atualiza a ESP (chame dentro de um RunService.RenderStepped)
function ESP:Update()
    if not self.Enabled then return end
    local camera = workspace.CurrentCamera
    local mouse = game.Players.LocalPlayer:GetMouse()
    
    for i, espData in pairs(self.Objects) do
        local obj = espData.Object
        if obj and obj.Parent then
            local pos3D = nil

            -- Tenta obter posição do objeto, espera que tenha CFrame ou Position
            if obj:IsA("BasePart") then
                pos3D = obj.Position
            elseif obj:IsA("Model") then
                if obj:FindFirstChild("HumanoidRootPart") then
                    pos3D = obj.HumanoidRootPart.Position
                else
                    pos3D = obj:GetModelCFrame().p
                end
            elseif obj:IsA("Instance") and obj.Position then
                pos3D = obj.Position
            end

            if pos3D then
                local screenPos, onScreen = camera:WorldToViewportPoint(pos3D)
                if onScreen and screenPos.Z > 0 then

                    -- Distância do player para o objeto
                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - pos3D).Magnitude

                    -- Line ESP
                    if espData.ShowLine then
                        if not espData.Line then
                            espData.Line = Drawing.new("Line")
                            espData.Line.Color = espData.ColorLine
                            espData.Line.Thickness = espData.Thickness
                            espData.Line.Transparency = 1
                        end
                        espData.Line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y) -- Bottom center (player)
                        espData.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                        espData.Line.Visible = true
                    elseif espData.Line then
                        espData.Line.Visible = false
                    end

                    -- Box ESP (retângulo)
                    if espData.ShowBox then
                        if not espData.Box then
                            espData.Box = Drawing.new("Square")
                            espData.Box.Color = espData.ColorBox
                            espData.Box.Thickness = espData.Thickness
                            espData.Box.Filled = false
                            espData.Box.Transparency = 1
                        end
                        local size = 40 + (1000 - math.min(distance, 1000)) / 50 -- Tamanho dinâmico por distância
                        espData.Box.Size = Vector2.new(size, size)
                        espData.Box.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
                        espData.Box.Visible = true
                    elseif espData.Box then
                        espData.Box.Visible = false
                    end

                    -- Name ESP
                    if espData.ShowName then
                        if not espData.NameText then
                            espData.NameText = Drawing.new("Text")
                            espData.NameText.Color = espData.ColorName
                            espData.NameText.Size = espData.TextSize
                            espData.NameText.Center = true
                            espData.NameText.Font = espData.Font
                            espData.NameText.Outline = true
                        end
                        espData.NameText.Text = tostring(obj.Name)
                        espData.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                        espData.NameText.Visible = true
                    elseif espData.NameText then
                        espData.NameText.Visible = false
                    end

                    -- Distance ESP
                    if espData.ShowDistance then
                        if not espData.DistanceText then
                            espData.DistanceText = Drawing.new("Text")
                            espData.DistanceText.Color = espData.ColorDistance
                            espData.DistanceText.Size = espData.TextSize
                            espData.DistanceText.Center = true
                            espData.DistanceText.Font = espData.Font
                            espData.DistanceText.Outline = true
                        end
                        espData.DistanceText.Text = string.format("%.0f m", distance)
                        espData.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 50)
                        espData.DistanceText.Visible = true
                    elseif espData.DistanceText then
                        espData.DistanceText.Visible = false
                    end
                else
                    -- Esconde os desenhos caso o objeto não esteja na tela
                    if espData.Line then espData.Line.Visible = false end
                    if espData.Box then espData.Box.Visible = false end
                    if espData.NameText then espData.NameText.Visible = false end
                    if espData.DistanceText then espData.DistanceText.Visible = false end
                end
            end
        else
            -- Remove ESP se o objeto foi destruído
            if espData.Line then espData.Line:Remove() end
            if espData.Box then espData.Box:Remove() end
            if espData.NameText then espData.NameText:Remove() end
            if espData.DistanceText then espData.DistanceText:Remove() end
            table.remove(self.Objects, i)
        end
    end
end

return ESP
