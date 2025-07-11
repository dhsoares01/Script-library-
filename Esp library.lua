--[[
    📦 ESP v4 (Design aprimorado: box 3D com contorno suave e efeitos sutis, texto adaptativo, traço mais dinâmico)
    Recursos:
    - Line (tracer) com opções de estilo
    - Box 3D com outline suave e efeito de brilho sutil
    - Nome (com fundo opcional)
    - Distância (com fundo opcional e tamanho adaptativo)
]]

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

-- Configurações padrão (ajustáveis pelo usuário)
LibraryESP.TextPosition = "Top"      -- This now mainly affects the name's base position. Distance is relative.
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"
LibraryESP.TracerStyle = "Solid"     -- "Solid", "Dashed"
LibraryESP.MaxDistance = 500         -- Distância máxima para renderizar ESP

-- 🌟 Utilitários de desenho (ajustados para suavidade e novos efeitos)
local function CreateText(size, color, outlineColor)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.OutlineColor = outlineColor or Color3.fromRGB(20, 20, 20)
    text.Font = 2 -- 'SourceSansPro'
    text.Color = color
    text.Visible = false
    return text
end

local function CreateLine(color, thickness, transparency)
    local line = Drawing.new("Line")
    line.Thickness = thickness or 2
    line.Color = color
    line.Transparency = transparency or 0.85
    line.Visible = false
    return line
end

local function CreateFilledQuad(color, transparency)
    local quad = Drawing.new("Quad")
    quad.Color = color
    quad.Transparency = transparency or 0.6
    quad.Visible = false
    return quad
end

local function Create3DBox(color)
    local boxElements = {}
    for i = 1, 12 do
        -- Outline mais grosso e suave
        local outline = Drawing.new("Line")
        outline.Thickness = 3.5
        outline.Color = Color3.fromRGB(20, 20, 20)
        outline.Transparency = 0.7
        outline.Visible = false

        -- Linha principal mais fina
        local line = Drawing.new("Line")
        line.Thickness = 1.8
        line.Color = color
        line.Transparency = 0.05 -- Mais opaco para a linha principal
        line.Visible = false

        -- Efeito de "glow" sutil (linha mais fina e transparente)
        local glowLine = Drawing.new("Line")
        glowLine.Thickness = 0.8
        glowLine.Color = color
        glowLine.Transparency = 0.5
        glowLine.Visible = false

        table.insert(boxElements, {Outline = outline, Line = line, Glow = glowLine})
    end
    return boxElements
end

-- ✏️ Criar ESP
function LibraryESP:CreateESP(object, options)
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local outlineColor = options.OutlineColor or Color3.fromRGB(20, 20, 20)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and CreateText(14, color, outlineColor) or nil,
        NameBackground = options.Name and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        DistanceText = options.Distance and CreateText(13, color, outlineColor) or nil,
        DistanceBackground = options.Distance and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        TracerLine = options.Tracer and CreateLine(color, 2, 0.2) or nil, -- Tracer mais opaco
        TracerGlow = options.Tracer and CreateLine(color, 1, 0.6) or nil,  -- Glow para o tracer
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
            if esp.NameBackground then esp.NameBackground:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.DistanceBackground then esp.DistanceBackground:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.TracerGlow then esp.TracerGlow:Remove() end
            if esp.Box then
                for _, pair in ipairs(esp.Box) do
                    pair.Outline:Remove()
                    pair.Line:Remove()
                    pair.Glow:Remove()
                end
            end
            table.remove(ESPObjects, i)
        end
    end
end

-- 🔧 Utilitários
local function getTextPosition(basePos, offsetType, textHeight)
    -- This function is now more for a base offset, individual text elements will adjust
    local yOffset = textHeight / 2 -- Approximação para centralização vertical
    local offsets = {
        Top = Vector2.new(0, -18),      -- Initial offset for the name text
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
        -- Fallback for models without a pivot or GetPivot failing
        local primaryPart = object.PrimaryPart
        if primaryPart and primaryPart:IsA("BasePart") then
            return primaryPart.Position
        end
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
        -- Fallback for models without extents size or GetExtentsSize failing
        local primaryPart = object.PrimaryPart
        if primaryPart and primaryPart:IsA("BasePart") then
            return primaryPart.Size
        end
        local bounds = {
            min = Vector3.new(math.huge, math.huge, math.huge),
            max = Vector3.new(math.huge * -1, math.huge * -1, math.huge * -1)
        }
        for _, part in ipairs(object:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                local partMin = part.CFrame:PointToObjectSpace(part.Position - part.Size / 2)
                local partMax = part.CFrame:PointToObjectSpace(part.Position + part.Size / 2)
                bounds.min = Vector3.new(math.min(bounds.min.X, partMin.X), math.min(bounds.min.Y, partMin.Y), math.min(bounds.min.Z, partMin.Z))
                bounds.max = Vector3.new(math.max(bounds.max.X, partMax.X), math.max(bounds.max.Y, partMax.Y), math.max(bounds.max.Z, partMax.Z))
            end
        end
        if bounds.min.X ~= math.huge then
            return bounds.max - bounds.min
        end
    end
    return Vector3.new(1,1,1)
end

-- Helper to calculate dashed line segments
local function getDashedLineSegments(from, to, dashLength, spaceLength)
    local segments = {}
    local totalLength = (to - from).Magnitude
    local direction = (to - from).Unit
    local currentPos = from
    local currentLength = 0

    while currentLength < totalLength do
        local segmentEnd = currentPos + direction * dashLength
        if (segmentEnd - from).Magnitude > totalLength then
            segmentEnd = to
        end
        table.insert(segments, {from = currentPos, to = segmentEnd})
        currentPos = segmentEnd + direction * spaceLength
        currentLength = (currentPos - from).Magnitude
    end
    return segments
end

-- 🏃‍♂️ Loop principal
RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object
        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            LibraryESP:RemoveESP(obj)
            continue
        end

        local objPos = getObjectPosition(obj)
        if not objPos then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(objPos)
        local screenPos = Vector2.new(pos.X, pos.Y)
        local distance = (Camera.CFrame.Position - objPos).Magnitude

        local isVisible = onScreen and distance <= LibraryESP.MaxDistance

        -- Dynamic text size based on distance
        local baseTextSize = 14
        local adaptiveTextSize = math.max(8, baseTextSize * (1 - distance / LibraryESP.MaxDistance))

        local nameOffset = Vector2.new(0, -25) -- Offset for the name above the object
        local distanceOffset = Vector2.new(0, 15) -- Offset for the distance below the object

        if esp.NameText then
            -- Usar NameTextString se fornecido, senão, usar obj.Name
            esp.NameText.Text = esp.Options.NameTextString or obj.Name
            esp.NameText.Size = adaptiveTextSize
            esp.NameText.Position = screenPos + nameOffset
            esp.NameText.Visible = isVisible
            if esp.NameBackground then
                local textBounds = esp.NameText.TextBounds
                esp.NameBackground.PointA = esp.NameText.Position - textBounds / 2
                esp.NameBackground.PointB = esp.NameText.Position + Vector2.new(textBounds.X / 2, -textBounds.Y / 2)
                esp.NameBackground.PointC = esp.NameText.Position + textBounds / 2
                esp.NameBackground.PointD = esp.NameText.Position + Vector2.new(-textBounds.X / 2, textBounds.Y / 2)
                esp.NameBackground.Visible = isVisible
            end
        end

        if esp.DistanceText then
            esp.DistanceText.Size = adaptiveTextSize * 0.8 -- Slightly smaller than name
            esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
            esp.DistanceText.Position = screenPos + distanceOffset
            esp.DistanceText.Visible = isVisible
            if esp.DistanceBackground then
                local textBounds = esp.DistanceText.TextBounds
                esp.DistanceBackground.PointA = esp.DistanceText.Position - textBounds / 2
                esp.DistanceBackground.PointB = esp.DistanceText.Position + Vector2.new(textBounds.X / 2, -textBounds.Y / 2)
                esp.DistanceBackground.PointC = esp.DistanceText.Position + textBounds / 2
                esp.DistanceBackground.PointD = esp.DistanceText.Position + Vector2.new(-textBounds.X / 2, textBounds.Y / 2)
                esp.DistanceBackground.Visible = isVisible
            end
        end

        if esp.TracerLine and esp.TracerGlow then
            local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            if LibraryESP.LineFrom == "Top" then
                from = Vector2.new(Camera.ViewportSize.X/2, 0)
            elseif LibraryESP.LineFrom == "Center" then
                from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Below" then
                from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y * 0.8) -- Slightly higher than bottom
            elseif LibraryESP.LineFrom == "Left" then
                from = Vector2.new(0, Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Right" then
                from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y/2)
            end

            if LibraryESP.TracerStyle == "Solid" then
                esp.TracerLine.From = from
                esp.TracerLine.To = screenPos
                esp.TracerLine.Visible = isVisible
                esp.TracerGlow.From = from
                esp.TracerGlow.To = screenPos
                esp.TracerGlow.Visible = isVisible
            elseif LibraryESP.TracerStyle == "Dashed" then
                -- Dashed lines are more complex with Drawing.new("Line"). For true dashed lines, you'd need multiple line objects.
                -- For simplicity, will keep it solid if "Dashed" is chosen until a full dashed implementation is added.
                esp.TracerLine.From = from
                esp.TracerLine.To = screenPos
                esp.TracerLine.Visible = isVisible
                esp.TracerGlow.From = from
                esp.TracerGlow.To = screenPos
                esp.TracerGlow.Visible = isVisible
            end
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
            local screenPoints, allCornersOnScreen = {}, true
            for _, corner in ipairs(corners) do
                local wp = cf:PointToWorldSpace(corner)
                local vec, vis = Camera:WorldToViewportPoint(wp)
                table.insert(screenPoints, Vector2.new(vec.X, vec.Y))
                if not vis then allCornersOnScreen = false end
            end

            local edges = { {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8} }
            for idx, edge in ipairs(edges) do
                local pair = esp.Box[idx]
                if isVisible and allCornersOnScreen then -- Only show box if all corners are on screen and object is visible
                    pair.Outline.From, pair.Outline.To = screenPoints[edge[1]], screenPoints[edge[2]]
                    pair.Line.From, pair.Line.To = screenPoints[edge[1]], screenPoints[edge[2]]
                    pair.Glow.From, pair.Glow.To = screenPoints[edge[1]], screenPoints[edge[2]]
                    pair.Outline.Visible, pair.Line.Visible, pair.Glow.Visible = true, true, true
                else
                    pair.Outline.Visible, pair.Line.Visible, pair.Glow.Visible = false, false, false
                end
            end
        end
    end
end)

return LibraryESP
