--// LibraryESP.lua

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

LibraryESP.TextPosition = "Top"    -- "Top", "Center", "Bottom", "Below", "LeftSide", "RightSide"
LibraryESP.LineFrom = "Bottom"     -- "Top", "Center", "Bottom", "Below", "Left", "Right"

local function DrawText(size, color)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = color
    text.Visible = false
    return text
end

local function DrawLine(color)
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = color
    line.Visible = false
    return line
end

local function DrawBox(color)
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
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1,1,1)) or nil,
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1,1,1)) or nil,
        TracerLine = options.Tracer and DrawLine(options.Color or Color3.new(1,1,1)) or nil,
        Box = options.Box and DrawBox(options.Color or Color3.new(1,1,1)) or nil,
    }
    table.insert(ESPObjects, esp)
    return esp
end

function LibraryESP:RemoveESP(object)
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.Object == object or object == nil then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            table.remove(ESPObjects, i)
        end
    end
end

local function getTextPosition(basePos, offsetType)
    local offset = Vector2.new(0, 0)
    if offsetType == "Top" then
        offset = Vector2.new(0, -16)
    elseif offsetType == "Center" then
        offset = Vector2.new(0, 0)
    elseif offsetType == "Bottom" then
        offset = Vector2.new(0, 16)
    elseif offsetType == "Below" then
        offset = Vector2.new(0, 26)
    elseif offsetType == "LeftSide" then
        offset = Vector2.new(-40, 0)
    elseif offsetType == "RightSide" then
        offset = Vector2.new(40, 0)
    end
    return basePos + offset
end

local function getObjectPosition(object)
    if typeof(object) ~= "Instance" then return nil end
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        if pcall(function() object:GetModelCFrame() end) then
            return object:GetModelCFrame().p
        else
            for _, part in pairs(object:GetChildren()) do
                if part:IsA("BasePart") then
                    return part.Position
                end
            end
        end
    end
    return nil
end

local function getObjectSize(object)
    if typeof(object) ~= "Instance" then return Vector3.new(1,1,1) end
    if object:IsA("BasePart") then
        return object.Size
    elseif object:IsA("Model") then
        if pcall(function() object:GetExtentsSize() end) then
            return object:GetExtentsSize()
        else
            for _, part in pairs(object:GetChildren()) do
                if part:IsA("BasePart") then
                    return part.Size
                end
            end
        end
    end
    return Vector3.new(1,1,1)
end

RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            table.remove(ESPObjects, i)

        else
            local objPos = getObjectPosition(obj)
            if not objPos then
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then esp.Box.Visible = false end
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(objPos)
            local basePos = Vector2.new(pos.X, pos.Y)

            if onScreen then
                local distance = (Camera.CFrame.Position - objPos).Magnitude

                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = tostring(obj.Name)
                    esp.NameText.Visible = true
                end

                if esp.DistanceText then
                    esp.DistanceText.Position = getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 14)
                    esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                    esp.DistanceText.Visible = true
                end

                if esp.TracerLine then
                    local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    if LibraryESP.LineFrom == "Top" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    elseif LibraryESP.LineFrom == "Center" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Below" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.25)
                    elseif LibraryESP.LineFrom == "Left" then
                        from = Vector2.new(0, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Right" then
                        from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
                    end

                    esp.TracerLine.From = from
                    esp.TracerLine.To = basePos
                    esp.TracerLine.Visible = true
                end

                if esp.Box then
                    local size3D = getObjectSize(obj)
                    local sizeX = math.clamp(size3D.X, 1, 10)
                    local sizeY = math.clamp(size3D.Y, 1, 10)
                    local scale = 300 / (distance + 0.1)

                    local boxWidth = sizeX * scale
                    local boxHeight = sizeY * scale

                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
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
