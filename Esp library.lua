--// ESP Library by Endereço
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
        MaxDistance = 2000
    }
}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

local Drawings = {}

--// Utils
local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

--// Add Object to ESP
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

    -- Styling
    local d = self.Objects[object].Drawing
    d.Line.Thickness = 1.5
    d.Line.Transparency = 1
    d.Line.Color = self.Settings.Color

    d.Box.Thickness = 1.5
    d.Box.Filled = false
    d.Box.Transparency = 1
    d.Box.Color = self.Settings.Color

    d.Name.Size = 13
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.Transparency = 1
    d.Name.Color = self.Settings.Color

    d.Distance.Size = 13
    d.Distance.Center = true
    d.Distance.Outline = true
    d.Distance.Transparency = 1
    d.Distance.Color = self.Settings.Color
end

--// Remove Object from ESP
function ESP:Remove(object)
    if self.Objects[object] then
        for _, v in pairs(self.Objects[object].Drawing) do
            v:Remove()
        end
        self.Objects[object] = nil
    end
end

--// Main ESP Loop
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
            local size = math.clamp((1 / depth) * 1000 * scale, 2, 60)
            local boxSize = Vector2.new(size, size * 1.5)
            local topLeft = screenPos - boxSize / 2

            -- Box
            drawing.Box.Position = topLeft
            drawing.Box.Size = boxSize
            drawing.Box.Visible = ESP.Settings.Box

            -- Line
            drawing.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawing.Line.To = screenPos
            drawing.Line.Visible = ESP.Settings.Line

            -- Name
            drawing.Name.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y / 2 - 14)
            drawing.Name.Text = name
            drawing.Name.Visible = ESP.Settings.Name

            -- Distance
            drawing.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y / 2 + 2)
            drawing.Distance.Text = string.format("%.0f studs", depth)
            drawing.Distance.Visible = ESP.Settings.Distance
        else
            for _, v in pairs(drawing) do
                v.Visible = false
            end
        end
    end
end)

--// Clear All ESPs
function ESP:Clear()
    for obj in pairs(self.Objects) do
        self:Remove(obj)
    end
end

return ESP
