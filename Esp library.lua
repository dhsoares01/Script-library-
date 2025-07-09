local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

LibraryESP.TextPosition = "Top"      -- "Top", "Center", "Bottom", "Below", "LeftSide", "RightSide"
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"
LibraryESP.BoxShape = "Square"       -- "Square", "Circle", "Octagon"

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
    local shape
    if LibraryESP.BoxShape == "Circle" then
        shape = Drawing.new("Circle")
        shape.Radius = 50
        shape.Thickness = 1
        shape.Filled = false
        shape.Color = color
        shape.Visible = false
    elseif LibraryESP.BoxShape == "Octagon" then
        shape = {}
        for i = 1,8 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = color
            line.Visible = false
            table.insert(shape, line)
        end
    else
        shape = Drawing.new("Square")
        shape.Thickness = 1
        shape.Filled = false
        shape.Color = color
        shape.Visible = false
    end
    return shape
end

local function CreateObjectHighlight(color, thickness)
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Thickness = thickness or 2
        line.Color = color
        line.Visible = false
        table.insert(lines, line)
    end
    return lines
end

function LibraryESP:CreateESP(object, options)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1,1,1)) or nil,
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1,1,1)) or nil,
        TracerLine = options.Tracer and DrawLine(options.Color or Color3.new(1,1,1)) or nil,
        Box = options.Box and DrawBox(options.Color or Color3.new(1,1,1)) or nil,
        Highlight = options.Highlight and CreateObjectHighlight(options.HighlightColor or Color3.new(1,0,0), options.HighlightThickness or 2) or nil,
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
            if esp.Box then
                if LibraryESP.BoxShape == "Octagon" then
                    for _, line in ipairs(esp.Box) do
                        line:Remove()
                    end
                else
                    esp.Box:Remove()
                end
            end
            if esp.Highlight then
                for _, line in ipairs(esp.Highlight) do
                    line:Remove()
                end
            end
            table.remove(ESPObjects, i)
        end
    end
end

local function getTextPosition(basePos, offsetType)
    local offset = Vector2.new(0, 0)
    if offsetType == "Top" then offset = Vector2.new(0, -16)
    elseif offsetType == "Center" then offset = Vector2.new(0, 0)
    elseif offsetType == "Bottom" then offset = Vector2.new(0, 16)
    elseif offsetType == "Below" then offset = Vector2.new(0, 26)
    elseif offsetType == "LeftSide" then offset = Vector2.new(-40, 0)
    elseif offsetType == "RightSide" then offset = Vector2.new(40, 0)
    end
    return basePos + offset
end

local function getObjectPosition(object)
    if typeof(object) ~= "Instance" then return nil end
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        local cf = select(1, object:GetBoundingBox())
        if cf then return cf.Position end
    end
    return nil
end

local function getObjectSize(object)
    if typeof(object) ~= "Instance" then return Vector3.new(1,1,1) end
    if object:IsA("BasePart") then
        return object.Size
    elseif object:IsA("Model") then
        local _, size = object:GetBoundingBox()
        if size then return size end
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
            if esp.Box then
                if LibraryESP.BoxShape == "Octagon" then
                    for _, line in ipairs(esp.Box) do
                        line:Remove()
                    end
                else
                    esp.Box:Remove()
                end
            end
            if esp.Highlight then
                for _, line in ipairs(esp.Highlight) do
                    line:Remove()
                end
            end
            table.remove(ESPObjects, i)
        else
            local objPos = getObjectPosition(obj)
            if not objPos then
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then
                    if LibraryESP.BoxShape == "Octagon" then
                        for _, line in ipairs(esp.Box) do
                            line.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                    end
                end
                if esp.Highlight then
                    for _, line in ipairs(esp.Highlight) do
                        line.Visible = false
                    end
                end
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(objPos)
            local basePos = Vector2.new(pos.X, pos.Y)
            local distance = (Camera.CFrame.Position - objPos).Magnitude

            if onScreen then
                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = esp.Options.NameString or tostring(obj.Name)
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

                    if LibraryESP.BoxShape == "Circle" then
                        esp.Box.Position = basePos
                        esp.Box.Radius = math.max(boxWidth, boxHeight) / 2
                        esp.Box.Visible = true
                    elseif LibraryESP.BoxShape == "Octagon" then
                        local radiusX = boxWidth / 2
                        local radiusY = boxHeight / 2
                        local center = basePos
                        for j = 1,8 do
                            local angle1 = math.rad((j - 1) * 45)
                            local angle2 = math.rad((j % 8) * 45)
                            local p1 = center + Vector2.new(math.cos(angle1) * radiusX, math.sin(angle1) * radiusY)
                            local p2 = center + Vector2.new(math.cos(angle2) * radiusX, math.sin(angle2) * radiusY)
                            local line = esp.Box[j]
                            line.From = p1
                            line.To = p2
                            line.Visible = true
                        end
                    else
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
                        esp.Box.Visible = true
                    end
                end

                if esp.Highlight then
                    local cf, size
                    if obj:IsA("Model") then
                        cf, size = obj:GetBoundingBox()
                    elseif obj:IsA("BasePart") then
                        cf = obj.CFrame
                        size = obj.Size
                    end

                    if cf and size then
                        local corners = {}
                        local halfSize = size / 2
                        for x = -1,1,2 do
                            for y = -1,1,2 do
                                for z = -1,1,2 do
                                    local corner = (cf * CFrame.new(halfSize.X * x, halfSize.Y * y, halfSize.Z * z)).Position
                                    table.insert(corners, corner)
                                end
                            end
                        end

                        local screenCorners = {}
                        for _, corner in ipairs(corners) do
                            local spos, visible = Camera:WorldToViewportPoint(corner)
                            table.insert(screenCorners, {Vector2.new(spos.X, spos.Y), visible})
                        end

                        local edges = {
                            {1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},
                            {5,6},{5,7},{6,8},{7,8}
                        }

                        for j, edge in ipairs(edges) do
                            local p1, on1 = unpack(screenCorners[edge[1]])
                            local p2, on2 = unpack(screenCorners[edge[2]])
                            if on1 and on2 then
                                esp.Highlight[j].From = p1
                                esp.Highlight[j].To = p2
                                esp.Highlight[j].Visible = true
                                esp.Highlight[j].Color = esp.Options.HighlightColor or Color3.new(1,0,0)
                            else
                                esp.Highlight[j].Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(esp.Highlight) do
                            line.Visible = false
                        end
                    end
                end

            else
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then
                    if LibraryESP.BoxShape == "Octagon" then
                        for _, line in ipairs(esp.Box) do
                            line.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                    end
                end
                if esp.Highlight then
                    for _, line in ipairs(esp.Highlight) do
                        line.Visible = false
                    end
                end
            end
        end
    end
end)

return LibraryESP
