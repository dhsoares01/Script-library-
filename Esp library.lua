--[[
    📦 ESP v2 (Box 3D com contorno e visível através da parede)
    Recursos:
    - Line (tracer)
    - Box 3D
    - Name
    - Distance
]]--

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

LibraryESP.TextPosition = "Top"      -- "Top", "Center", "Bottom", "Below", "LeftSide", "RightSide"
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"

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

local function Draw3DBox(color)
    local lines = {}
    for i = 1, 12 do
        local outline = Drawing.new("Line")
        outline.Thickness = 3
        outline.Color = Color3.new(0,0,0)
        outline.Visible = false

        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = color
        line.Visible = false

        table.insert(lines, {Outline=outline, Line=line})
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
        Box = options.Box and Draw3DBox(options.Color or Color3.new(1,1,1)) or nil,
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
                for _, pair in ipairs(esp.Box) do
                    pair.Outline:Remove()
                    pair.Line:Remove()
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
        if pcall(function() object:GetPivot() end) then
            return object:GetPivot().Position
        else
            for _, part in ipairs(object:GetChildren()) do
                if part:IsA("BasePart") then return part.Position end
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
            for _, part in ipairs(object:GetChildren()) do
                if part:IsA("BasePart") then return part.Size end
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
            LibraryESP:RemoveESP(obj)
        else
            local objPos = getObjectPosition(obj)
            if not objPos then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(objPos)
            local basePos = Vector2.new(pos.X, pos.Y)
            local distance = (Camera.CFrame.Position - objPos).Magnitude

            if esp.NameText then
                esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                esp.NameText.Text = esp.Options.NameString or tostring(obj.Name)
                esp.NameText.Visible = onScreen
            end

            if esp.DistanceText then
                esp.DistanceText.Position = getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 14)
                esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                esp.DistanceText.Visible = onScreen
            end

            if esp.TracerLine then
                local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                if LibraryESP.LineFrom == "Top" then
                    from = Vector2.new(Camera.ViewportSize.X/2, 0)
                elseif LibraryESP.LineFrom == "Center" then
                    from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                elseif LibraryESP.LineFrom == "Below" then
                    from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/1.25)
                elseif LibraryESP.LineFrom == "Left" then
                    from = Vector2.new(0, Camera.ViewportSize.Y/2)
                elseif LibraryESP.LineFrom == "Right" then
                    from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y/2)
                end
                esp.TracerLine.From = from
                esp.TracerLine.To = basePos
                esp.TracerLine.Visible = onScreen
            end

            if esp.Box then
                local objCFrame = (obj.CFrame or (obj:IsA("Model") and obj:GetPivot())) or CFrame.new(objPos)
                local objSize = getObjectSize(obj) / 2

                -- 8 vértices do cubo
                local corners = {
                    Vector3.new( objSize.X,  objSize.Y,  objSize.Z),
                    Vector3.new(-objSize.X,  objSize.Y,  objSize.Z),
                    Vector3.new(-objSize.X, -objSize.Y,  objSize.Z),
                    Vector3.new( objSize.X, -objSize.Y,  objSize.Z),
                    Vector3.new( objSize.X,  objSize.Y, -objSize.Z),
                    Vector3.new(-objSize.X,  objSize.Y, -objSize.Z),
                    Vector3.new(-objSize.X, -objSize.Y, -objSize.Z),
                    Vector3.new( objSize.X, -objSize.Y, -objSize.Z),
                }

                -- projetar na tela
                local screenPoints = {}
                for _, corner in ipairs(corners) do
                    local worldPos = objCFrame:PointToWorldSpace(corner)
                    local vec = Camera:WorldToViewportPoint(worldPos)
                    table.insert(screenPoints, Vector2.new(vec.X, vec.Y))
                end

                local edges = {
                    {1,2},{2,3},{3,4},{4,1}, -- frente
                    {5,6},{6,7},{7,8},{8,5}, -- trás
                    {1,5},{2,6},{3,7},{4,8}  -- ligando frente e trás
                }

                for e, edge in ipairs(edges) do
                    local from = screenPoints[edge[1]]
                    local to = screenPoints[edge[2]]
                    local pair = esp.Box[e]
                    pair.Outline.From = from
                    pair.Outline.To = to
                    pair.Outline.Visible = true
                    pair.Line.From = from
                    pair.Line.To = to
                    pair.Line.Visible = true
                end
            end
        end
    end
end)

return LibraryESP
