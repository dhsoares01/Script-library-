-- ESP Library (Line + Box + Config via Loadstring)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP = {
    Settings = {
        Enabled = true,
        MaxDistance = 150,
        LineESP = {
            Enabled = true,
            Color = Color3.fromRGB(255, 0, 0)
        },
        BoxESP = {
            Enabled = true,
            Color = Color3.fromRGB(0, 255, 0)
        },
        TextESP = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255)
        }
    },
    Drawings = {}
}

function ESP:Clear()
    for _, d in pairs(self.Drawings) do
        for _, v in pairs(d) do
            if typeof(v) == "table" and v.Remove then
                v:Remove()
            end
        end
    end
    self.Drawings = {}
end

function ESP:UpdateConfig(config)
    for k, v in pairs(config) do
        if typeof(v) == "table" and typeof(self.Settings[k]) == "table" then
            for subK, subV in pairs(v) do
                self.Settings[k][subK] = subV
            end
        else
            self.Settings[k] = v
        end
    end
end

function ESP:Track()
    RunService:BindToRenderStep("ESP_Render", Enum.RenderPriority.Camera.Value + 1, function()
        if not self.Settings.Enabled then
            self:Clear()
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                if distance <= self.Settings.MaxDistance then
                    if not self.Drawings[player] then
                        self.Drawings[player] = {
                            Line = Drawing.new("Line"),
                            Box = Drawing.new("Square"),
                            Text = Drawing.new("Text")
                        }
                        self.Drawings[player].Text.Center = true
                        self.Drawings[player].Text.Outline = true
                        self.Drawings[player].Text.Size = 13
                        self.Drawings[player].Text.Font = 2
                    end

                    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local drawing = self.Drawings[player]

                    if onScreen then
                        if self.Settings.LineESP.Enabled then
                            drawing.Line.Visible = true
                            drawing.Line.Color = self.Settings.LineESP.Color
                            drawing.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            drawing.Line.To = Vector2.new(vector.X, vector.Y)
                            drawing.Line.Thickness = 1.5
                        else
                            drawing.Line.Visible = false
                        end

                        if self.Settings.BoxESP.Enabled then
                            drawing.Box.Visible = true
                            drawing.Box.Color = self.Settings.BoxESP.Color
                            drawing.Box.Thickness = 1.5
                            drawing.Box.Size = Vector2.new(50 / (distance / 10), 100 / (distance / 10))
                            drawing.Box.Position = Vector2.new(vector.X - drawing.Box.Size.X / 2, vector.Y - drawing.Box.Size.Y / 2)
                        else
                            drawing.Box.Visible = false
                        end

                        if self.Settings.TextESP.Enabled then
                            drawing.Text.Visible = true
                            drawing.Text.Color = self.Settings.TextESP.Color
                            drawing.Text.Text = string.format("%s (%.0f)", player.Name, distance)
                            drawing.Text.Position = Vector2.new(vector.X, vector.Y - 60)
                        else
                            drawing.Text.Visible = false
                        end
                    else
                        drawing.Line.Visible = false
                        drawing.Box.Visible = false
                        drawing.Text.Visible = false
                    end
                elseif self.Drawings[player] then
                    self.Drawings[player].Line.Visible = false
                    self.Drawings[player].Box.Visible = false
                    self.Drawings[player].Text.Visible = false
                end
            elseif self.Drawings[player] then
                self.Drawings[player].Line.Visible = false
                self.Drawings[player].Box.Visible = false
                self.Drawings[player].Text.Visible = false
            end
        end
    end)
end

ESP:Track()

return ESP
