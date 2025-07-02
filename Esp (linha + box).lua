local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)

    self.Settings = {
        Enabled = true,
        MaxDistance = 150,
        ReferenceObjects = {},

        LineESP = { Enabled = true, Color = Color3.fromRGB(255, 0, 0) },
        BoxESP = { Enabled = true, Color = Color3.fromRGB(0, 255, 0) },
        TextESP = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) }
    }

    self.Drawings = {}
    self._renderConnection = nil
    self.MaxBoxLines = 12

    return self
end

function ESP:UpdateConfig(config)
    local function merge(t1, t2)
        for k,v in pairs(t2) do
            if type(v) == "table" and type(t1[k]) == "table" then
                merge(t1[k], v)
            else
                t1[k] = v
            end
        end
    end
    merge(self.Settings, config)
end

function ESP:Clear()
    for obj, draws in pairs(self.Drawings) do
        for _, d in pairs(draws) do
            if d and d.Remove then
                d:Remove()
            end
        end
    end
    self.Drawings = {}
end

function ESP:Stop()
    if self._renderConnection then
        self._renderConnection:Disconnect()
        self._renderConnection = nil
    end
    self:Clear()
end

function ESP:Start()
    if self._renderConnection then return end

    self._renderConnection = RunService:BindToRenderStep("ESP_Render", Enum.RenderPriority.Camera.Value + 1, function()
        if not self.Settings.Enabled then
            self:Clear()
            return
        end

        for _, obj in pairs(self.Settings.ReferenceObjects) do
            if obj and obj.Parent then
                local pos = obj.Position or (obj:IsA("BasePart") and obj.Position)
                if pos then
                    local dist = (Camera.CFrame.Position - pos).Magnitude
                    local onScreenVector, onScreen = Camera:WorldToViewportPoint(pos)

                    if not self.Drawings[obj] then
                        local lines = {}
                        for i = 1, self.MaxBoxLines do
                            local line = Drawing.new("Line")
                            line.Visible = false
                            line.Color = self.Settings.BoxESP.Color
                            line.Thickness = 1.5
                            table.insert(lines, line)
                        end

                        local lineToCenter = Drawing.new("Line")
                        lineToCenter.Visible = false
                        lineToCenter.Color = self.Settings.LineESP.Color
                        lineToCenter.Thickness = 1.5

                        local text = Drawing.new("Text")
                        text.Center = true
                        text.Outline = true
                        text.Size = 13
                        text.Font = 2
                        text.Visible = false

                        self.Drawings[obj] = {
                            Lines = lines,
                            LineToCenter = lineToCenter,
                            Text = text
                        }
                    end

                    local draws = self.Drawings[obj]

                    if dist <= self.Settings.MaxDistance and onScreen then
                        -- Verifica FOV horizontal
                        local cameraDirection = Camera.CFrame.LookVector
                        local directionToObj = (pos - Camera.CFrame.Position).Unit
                        local dot = cameraDirection:Dot(directionToObj)
                        local angle = math.deg(math.acos(dot))

                        if angle > (Camera.FieldOfView / 2) then
                            for _, line in ipairs(draws.Lines) do
                                line.Visible = false
                            end
                            draws.LineToCenter.Visible = false
                            draws.Text.Visible = false
                            continue
                        end

                        -- Linha até o centro
                        if self.Settings.LineESP.Enabled then
                            draws.LineToCenter.Visible = true
                            draws.LineToCenter.Color = self.Settings.LineESP.Color
                            draws.LineToCenter.Thickness = 1.5
                            draws.LineToCenter.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            draws.LineToCenter.To = Vector2.new(onScreenVector.X, onScreenVector.Y)
                        else
                            draws.LineToCenter.Visible = false
                        end

                        -- Caixa 3D
                        if self.Settings.BoxESP.Enabled then
                            local cf, size = obj:GetBoundingBox()
                            local corners = {}
                            for x = -0.5, 0.5, 1 do
                                for y = -0.5, 0.5, 1 do
                                    for z = -0.5, 0.5, 1 do
                                        table.insert(corners, (cf * CFrame.new(x * size.X, y * size.Y, z * size.Z)).Position)
                                    end
                                end
                            end

                            local screenCorners = {}
                            local visibleCount = 0
                            for i, corner in ipairs(corners) do
                                local screenPos, isVisible = Camera:WorldToViewportPoint(corner)
                                screenCorners[i] = {pos = Vector2.new(screenPos.X, screenPos.Y), onScreen = isVisible}
                                if isVisible then visibleCount = visibleCount + 1 end
                            end

                            if visibleCount > 0 then
                                local function setLine(i, startIndex, endIndex)
                                    local startCorner = screenCorners[startIndex]
                                    local endCorner = screenCorners[endIndex]
                                    local line = draws.Lines[i]
                                    if startCorner.onScreen and endCorner.onScreen then
                                        line.Visible = true
                                        line.From = startCorner.pos
                                        line.To = endCorner.pos
                                        line.Color = self.Settings.BoxESP.Color
                                        line.Thickness = 1.5
                                    else
                                        line.Visible = false
                                    end
                                end

                                -- Liga os 12 arestas da caixa 3D
                                setLine(1, 1, 2)
                                setLine(2, 2, 4)
                                setLine(3, 4, 3)
                                setLine(4, 3, 1)

                                setLine(5, 5, 6)
                                setLine(6, 6, 8)
                                setLine(7, 8, 7)
                                setLine(8, 7, 5)

                                setLine(9, 1, 5)
                                setLine(10, 2, 6)
                                setLine(11, 3, 7)
                                setLine(12, 4, 8)
                            else
                                for _, line in ipairs(draws.Lines) do
                                    line.Visible = false
                                end
                            end
                        else
                            for _, line in ipairs(draws.Lines) do
                                line.Visible = false
                            end
                        end

                        -- Texto
                        if self.Settings.TextESP.Enabled then
                            draws.Text.Visible = true
                            draws.Text.Color = self.Settings.TextESP.Color
                            draws.Text.Text = string.format("%s\n%.0f studs", obj.Name or "Obj", dist)
                            draws.Text.Position = Vector2.new(onScreenVector.X, onScreenVector.Y - 60)
                        else
                            draws.Text.Visible = false
                        end
                    else
                        for _, line in ipairs(draws.Lines) do
                            line.Visible = false
                        end
                        draws.LineToCenter.Visible = false
                        draws.Text.Visible = false
                    end
                else
                    if self.Drawings[obj] then
                        for _, d in pairs(self.Drawings[obj]) do
                            if d and d.Remove then
                                d:Remove()
                            end
                        end
                        self.Drawings[obj] = nil
                    end
                end
            end
        end
    end)
end

return ESP
