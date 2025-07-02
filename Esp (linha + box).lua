local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)

    self.Settings = {
        Enabled = true,
        MaxDistance = 150,
        FOVEnabled = true,
        FOVAngle = 90, -- em graus

        ReferenceObjects = {},

        LineESP = { Enabled = true, Color = Color3.fromRGB(255, 0, 0) },
        BoxESP = { Enabled = true, Color = Color3.fromRGB(0, 255, 0) },
        TextESP = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) }
    }

    self.Drawings = {}
    self._renderConnection = nil

    return self
end

function ESP:UpdateConfig(config)
    local function merge(t1, t2)
        for k, v in pairs(t2) do
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
                    local camPos = Camera.CFrame.Position
                    local dist = (camPos - pos).Magnitude

                    -- Verifica FOV
                    local direction = (pos - camPos).Unit
                    local camLook = Camera.CFrame.LookVector
                    local angle = math.deg(math.acos(camLook:Dot(direction)))

                    if self.Settings.FOVEnabled and angle > self.Settings.FOVAngle / 2 then
                        -- Fora do FOV
                        if self.Drawings[obj] then
                            for _, d in pairs(self.Drawings[obj]) do
                                d.Visible = false
                            end
                        end
                        continue
                    end

                    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)

                    if not self.Drawings[obj] then
                        self.Drawings[obj] = {
                            Line = Drawing.new("Line"),
                            Box = Drawing.new("Square"),
                            Text = Drawing.new("Text")
                        }
                        local txt = self.Drawings[obj].Text
                        txt.Center = true
                        txt.Outline = true
                        txt.Size = 13
                        txt.Font = 2
                    end

                    local draws = self.Drawings[obj]

                    if dist <= self.Settings.MaxDistance and onScreen then
                        if self.Settings.LineESP.Enabled then
                            draws.Line.Visible = true
                            draws.Line.Color = self.Settings.LineESP.Color
                            draws.Line.Thickness = 1.5
                            draws.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            draws.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                        else
                            draws.Line.Visible = false
                        end

                        if self.Settings.BoxESP.Enabled then
                            draws.Box.Visible = true
                            draws.Box.Color = self.Settings.BoxESP.Color
                            draws.Box.Thickness = 1.5
                            local sizeX = 50 / (dist / 10)
                            local sizeY = 100 / (dist / 10)
                            draws.Box.Size = Vector2.new(sizeX, sizeY)
                            draws.Box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)
                        else
                            draws.Box.Visible = false
                        end

                        if self.Settings.TextESP.Enabled then
                            draws.Text.Visible = true
                            draws.Text.Color = self.Settings.TextESP.Color
                            draws.Text.Text = string.format("%s\n%.0f studs", obj.Name or "Obj", dist)
                            draws.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 60)
                        else
                            draws.Text.Visible = false
                        end
                    else
                        draws.Line.Visible = false
                        draws.Box.Visible = false
                        draws.Text.Visible = false
                    end
                end
            else
                if self.Drawings[obj] then
                    for _, d in pairs(self.Drawings[obj]) do
                        if d and d.Remove then d:Remove() end
                    end
                    self.Drawings[obj] = nil
                end
            end
        end
    end)
end

return ESP
