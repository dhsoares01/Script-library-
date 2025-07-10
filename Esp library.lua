--[[ 
    📦 ESP v3 (Design aprimorado: box 3D com contorno suave, texto centralizado, traço mais clean)
    Recursos:
    - Line (tracer)
    - Box 3D com outline suave
    - Nome
    - Distância
]]

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

LibraryESP.TextPosition = "Top"      -- "Top", "Center", "Bottom", "Below", "LeftSide", "RightSide"
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"

-- 🌟 Utilitários de desenho (ajustados para suavidade)
local function CreateText(size, color)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(20, 20, 20)
    text.Font = 2
    text.Color = color
    text.Visible = false
    return text
end

local function CreateLine(color, thickness)
    local line = Drawing.new("Line")
    line.Thickness = thickness or 2
    line.Color = color
    line.Transparency = 0.85
    line.Visible = false
    return line
end

local function Create3DBox(color)
    local lines = {}
    for i = 1, 12 do
        local outline = Drawing.new("Line")
        outline.Thickness = 3
        outline.Color = Color3.fromRGB(20, 20, 20)
        outline.Transparency = 0.8
        outline.Visible = false

        local line = Drawing.new("Line")
        line.Thickness = 1.8
        line.Color = color
        line.Transparency = 0.9
        line.Visible = false

        table.insert(lines, {Outline=outline, Line=line})
    end
    return lines
end

-- ✏️ Criar ESP
function LibraryESP:CreateESP(object, options)
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and CreateText(14, color) or nil,
        DistanceText = options.Distance and CreateText(13, color) or nil,
        TracerLine = options.Tracer and CreateLine(color) or nil,
        Box = options.Box and Create3DBox(color) or nil,
    }
    table.insert(ESPObjects, esp)
    return esp
end

-- 🧹 Remover ESP
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

-- 🔧 Utilitários
local function getTextPosition(basePos, offsetType)
    local offsets = {
        Top = Vector2.new(0, -18),
        Center = Vector2.new(0, 0),
        Bottom = Vector2.new(0, 18),
        Below = Vector2.new(0, 28),
        LeftSide = Vector2.new(-40, 0),
        RightSide = Vector2.new(40, 0),
    }
    return basePos + (offsets[offsetType] or Vector2.zero)
end

local function getObjectPosition(object)
    if typeof(object) ~= "Instance" then return nil end
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        local success, pivot = pcall(function() return object:GetPivot() end)
        if success then return pivot.Position end
        for _, part in ipairs(object:GetChildren()) do
            if part:IsA("BasePart") then return part.Position end
        end
    end
    return nil
end

local function getObjectSize(object)
    if typeof(object) ~= "Instance" then return Vector3.new(1,1,1) end
    if object:IsA("BasePart") then
        return object.Size
    elseif object:IsA("Model") then
        local success, size = pcall(function() return object:GetExtentsSize() end)
        if success then return size end
        for _, part in ipairs(object:GetChildren()) do
            if part:IsA("BasePart") then return part.Size end
        end
    end
    return Vector3.new(1,1,1)
end

-- 🏃‍♂️ Loop principal
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
            local screenPos = Vector2.new(pos.X, pos.Y)
            local distance = (Camera.CFrame.Position - objPos).Magnitude

            if esp.NameText then
                esp.NameText.Position = getTextPosition(screenPos, LibraryESP.TextPosition)
                esp.NameText.Text = esp.Options.NameString or obj.Name
                esp.NameText.Visible = onScreen
            end

            if esp.DistanceText then
                esp.DistanceText.Position = getTextPosition(screenPos, LibraryESP.TextPosition) + Vector2.new(0, 14)
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
                    from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/1.2)
                elseif LibraryESP.LineFrom == "Left" then
                    from = Vector2.new(0, Camera.ViewportSize.Y/2)
                elseif LibraryESP.LineFrom == "Right" then
                    from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y/2)
                end
                esp.TracerLine.From = from
                esp.TracerLine.To = screenPos
                esp.TracerLine.Visible = onScreen
            end

            if esp.Box then
                local cf = (obj.CFrame or (obj:IsA("Model") and obj:GetPivot())) or CFrame.new(objPos)
                local size = getObjectSize(obj) / 2
                local corners = {
                    Vector3.new( size.X, size.Y, size.Z), Vector3.new(-size.X, size.Y, size.Z),
                    Vector3.new(-size.X, -size.Y, size.Z), Vector3.new( size.X, -size.Y, size.Z),
                    Vector3.new( size.X, size.Y, -size.Z), Vector3.new(-size.X, size.Y, -size.Z),
                    Vector3.new(-size.X, -size.Y, -size.Z), Vector3.new( size.X, -size.Y, -size.Z),
                }
                local screenPoints, allVisible = {}, true
                for _, corner in ipairs(corners) do
                    local wp = cf:PointToWorldSpace(corner)
                    local vec, vis = Camera:WorldToViewportPoint(wp)
                    table.insert(screenPoints, Vector2.new(vec.X, vec.Y))
                    if not vis then allVisible = false end
                end
                local edges = { {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8} }
                for idx, edge in ipairs(edges) do
                    local pair = esp.Box[idx]
                    if allVisible then
                        pair.Outline.From, pair.Outline.To = screenPoints[edge[1]], screenPoints[edge[2]]
                        pair.Line.From, pair.Line.To = screenPoints[edge[1]], screenPoints[edge[2]]
                        pair.Outline.Visible, pair.Line.Visible = true, true
                    else
                        pair.Outline.Visible, pair.Line.Visible = false, false
                    end
                end
            end
        end
    end
end)

return LibraryESP
