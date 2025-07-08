--// LibraryESP.lua

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

function DrawText(size, color)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = color
    text.Visible = false
    return text
end

function DrawLine(color)
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = color
    line.Visible = false
    return line
end

function DrawBox(color)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = color
    box.Filled = false
    box.Visible = false
    return box
end

function LibraryESP:CreateESP(object, options)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,
        TracerLine = options.Tracer and DrawLine(options.Color or Color3.new(1, 1, 1)) or nil,
        Box = options.Box and DrawBox(options.Color or Color3.new(1, 1, 1)) or nil
    }

    table.insert(ESPObjects, esp)
    return esp
end

function LibraryESP:RemoveESP(object)
    for i, esp in ipairs(ESPObjects) do
        if esp.Object == object then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            table.remove(ESPObjects, i)
            break
        end
    end
end

RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        -- Remove ESP se objeto for inválido ou não estiver mais no workspace
        if not obj or not obj:IsDescendantOf(workspace) then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            table.remove(ESPObjects, i)
        else
            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            if onScreen then
                local distance = (Camera.CFrame.Position - obj.Position).Magnitude

                if esp.NameText then
                    esp.NameText.Position = Vector2.new(pos.X, pos.Y - 16)
                    esp.NameText.Text = tostring(obj.Name)
                    esp.NameText.Visible = true
                end

                if esp.DistanceText then
                    esp.DistanceText.Position = Vector2.new(pos.X, pos.Y + 16)
                    esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                    esp.DistanceText.Visible = true
                end

                if esp.TracerLine then
                    esp.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.TracerLine.To = Vector2.new(pos.X, pos.Y)
                    esp.TracerLine.Visible = true
                end

                if esp.Box then
                    local size = 30 / (distance / 10)
                    esp.Box.Size = Vector2.new(size, size * 1.5)
                    esp.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - size * 0.75)
                    esp.Box.Visible = true
                end
            else
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then esp.Box.Visible = false end
            end
        end
    end
end)

return LibraryESP
