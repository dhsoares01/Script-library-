--[[
    📦 ESP v5 (Design aprimorado: box 3D com contorno suave e efeitos sutis, texto adaptativo, traço mais dinâmico, Outline ESP)
    Recursos:
    - Line (tracer) com opções de estilo
    - Box 3D com outline suave e efeito de brilho sutil
    - Nome (com fundo opcional e contorno)
    - Distância (com fundo opcional, tamanho adaptativo e contorno)
    - Outline para todos os elementos de texto e linhas
]]

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

-- Configurações padrão (ajustáveis pelo usuário)
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"
LibraryESP.TracerStyle = "Solid"     -- "Solid", "Dashed" (note: dashed is a basic implementation)
LibraryESP.MaxDistance = 500         -- Distância máxima para renderizar ESP
LibraryESP.OutlineThickness = 1      -- Thickness of the outline for text and lines
LibraryESP.OutlineColor = Color3.fromRGB(20, 20, 20) -- Default outline color

-- 🌟 Utilitários de desenho (ajustados para suavidade e novos efeitos)
local function CreateText(size, color, outlineColor)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.OutlineColor = outlineColor or LibraryESP.OutlineColor
    text.Font = 2 -- 'SourceSansPro'
    text.Color = color
    text.Visible = false
    return text
end

local function CreateLine(color, thickness, transparency, outline)
    local line = Drawing.new("Line")
    line.Thickness = thickness or 2
    line.Color = color
    line.Transparency = transparency or 0.85
    line.Visible = false
    if outline then
        line.Outline = true
        line.OutlineColor = outline.Color or LibraryESP.OutlineColor
        line.OutlineThickness = outline.Thickness or LibraryESP.OutlineThickness
    end
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
        -- Main line for the box
        local line = Drawing.new("Line")
        line.Thickness = 1.8
        line.Color = color
        line.Transparency = 0.05
        line.Visible = false
        line.Outline = true
        line.OutlineColor = LibraryESP.OutlineColor
        line.OutlineThickness = LibraryESP.OutlineThickness + 1 -- Slightly thicker outline for the box

        -- Efeito de "glow" sutil (linha mais fina e transparente)
        local glowLine = Drawing.new("Line")
        glowLine.Thickness = 0.8
        glowLine.Color = color
        glowLine.Transparency = 0.5
        glowLine.Visible = false
        glowLine.Outline = false -- Glow line typically doesn't need an outline

        table.insert(boxElements, {Line = line, Glow = glowLine})
    end
    return boxElements
end

-- ✏️ Criar ESP
function LibraryESP:CreateESP(object, options)
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local outlineColor = options.OutlineColor or LibraryESP.OutlineColor

    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and CreateText(14, color, outlineColor) or nil,
        NameBackground = options.Name and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        DistanceText = options.Distance and CreateText(13, color, outlineColor) or nil,
        DistanceBackground = options.Distance and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        TracerLine = options.Tracer and CreateLine(color, 2, 0.2, {Color = outlineColor, Thickness = LibraryESP.OutlineThickness}) or nil,
        TracerGlow = options.Tracer and CreateLine(color, 1, 0.6, {Color = outlineColor, Thickness = LibraryESP.OutlineThickness * 0.5}) or nil,
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
                    pair.Line:Remove()
                    pair.Glow:Remove()
                end
            end
            table.remove(ESPObjects, i)
        end
    end
end

-- 🔧 Utilitários para obter posição e tamanho do objeto
local function getObjectPosition(object)
    if typeof(object) ~= "Instance" then return nil end
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        local primaryPart = object.PrimaryPart
        if primaryPart and primaryPart:IsA("BasePart") then
            return primaryPart.Position
        end
        -- Fallback for models without a primary part: try to find the center of its bounds
        local success, cframe = pcall(function() return object:GetBoundingBox() end)
        if success then return cframe.Position end

        -- Last resort: iterate children
        for _, part in ipairs(object:GetChildren()) do
            if part:IsA("BasePart") then return part.Position end
        end
    end
    return nil
end

local function getObjectExtents(object)
    if typeof(object) ~= "Instance" then return CFrame.identity, Vector3.new(1,1,1) end
    if object:IsA("BasePart") then
        return object.CFrame, object.Size
    elseif object:IsA("Model") then
        local success, cframe, size = pcall(function() return object:GetBoundingBox() end)
        if success then return cframe, size end
        -- Fallback for models without a bounding box
        local primaryPart = object.PrimaryPart
        if primaryPart and primaryPart:IsA("BasePart") then
            return primaryPart.CFrame, primaryPart.Size
        end
    end
    return CFrame.identity, Vector3.new(1,1,1) -- Default for unknown types
end

-- Helper for dashed lines (basic implementation)
local function getDashedPoints(from, to, dashLength, spaceLength)
    local segments = {}
    local totalLength = (to - from).Magnitude
    local direction = (to - from).Unit
    local currentPos = from
    local currentLength = 0

    while currentLength < totalLength do
        local segmentEnd = currentPos + direction * dashLength
        if (segmentEnd - from).Magnitude > totalLength then
            segmentEnd = to -- Ensure last segment ends exactly at 'to'
        end
        table.insert(segments, currentPos)
        table.insert(segments, segmentEnd)
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

        local objCFrame, objSize = getObjectExtents(obj)
        local objPos = objCFrame.Position
        if not objPos then continue end

        local screenPoint, isVisible = Camera:WorldToScreenPoint(objPos)
        local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
        local distance = (Camera.CFrame.Position - objPos).Magnitude

        local renderESP = isVisible and distance <= LibraryESP.MaxDistance

        -- Dynamic text size based on distance
        local baseTextSize = 14
        local adaptiveTextSize = math.max(8, math.min(20, baseTextSize * (1 - distance / LibraryESP.MaxDistance * 0.7))) -- Cap max size

        -- Calculate screen points for the 3D box based on object's bounding box
        local boxCorners = {
            objCFrame * Vector3.new( objSize.X/2,  objSize.Y/2,  objSize.Z/2),
            objCFrame * Vector3.new(-objSize.X/2,  objSize.Y/2,  objSize.Z/2),
            objCFrame * Vector3.new(-objSize.X/2, -objSize.Y/2,  objSize.Z/2),
            objCFrame * Vector3.new( objSize.X/2, -objSize.Y/2,  objSize.Z/2),
            objCFrame * Vector3.new( objSize.X/2,  objSize.Y/2, -objSize.Z/2),
            objCFrame * Vector3.new(-objSize.X/2,  objSize.Y/2, -objSize.Z/2),
            objCFrame * Vector3.new(-objSize.X/2, -objSize.Y/2, -objSize.Z/2),
            objCFrame * Vector3.new( objSize.X/2, -objSize.Y/2, -objSize.Z/2),
        }

        local screenCorners = {}
        local allCornersOnScreen = true
        for _, cornerWorldPos in ipairs(boxCorners) do
            local vec, vis = Camera:WorldToScreenPoint(cornerWorldPos)
            table.insert(screenCorners, Vector2.new(vec.X, vec.Y))
            if not vis then allCornersOnScreen = false end
        end

        -- Calculate screen position for the base of the object (for text alignment)
        local objectBasePoint = objCFrame * Vector3.new(0, -objSize.Y/2, 0)
        local baseScreenPoint, baseOnScreen = Camera:WorldToScreenPoint(objectBasePoint)
        local baseScreenPos = Vector2.new(baseScreenPoint.X, baseScreenPoint.Y)

        local nameOffset = Vector2.new(0, -10) -- Offset for the name above the object
        local distanceOffset = Vector2.new(0, 10) -- Offset for the distance below the object

        -- Adjust offsets based on object height in screen space
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        for _, sc in ipairs(screenCorners) do
            minX = math.min(minX, sc.X)
            minY = math.min(minY, sc.Y)
            maxX = math.max(maxX, sc.X)
            maxY = math.max(maxY, sc.Y)
        end
        local boxScreenHeight = maxY - minY
        local boxScreenWidth = maxX - minX

        -- Adjust text offsets dynamically based on box size
        if boxScreenHeight > 0 then
            nameOffset = Vector2.new(0, - (boxScreenHeight / 2 + 5)) -- 5 pixels buffer above box
            distanceOffset = Vector2.new(0, (boxScreenHeight / 2 + 5)) -- 5 pixels buffer below box
        end


        if esp.NameText then
            esp.NameText.Text = esp.Options.NameTextString or obj.Name
            esp.NameText.Size = adaptiveTextSize
            esp.NameText.Position = baseScreenPos + nameOffset
            esp.NameText.Visible = renderESP
            if esp.NameBackground then
                local textBounds = esp.NameText.TextBounds
                esp.NameBackground.PointA = esp.NameText.Position - Vector2.new(textBounds.X / 2, textBounds.Y / 2)
                esp.NameBackground.PointB = esp.NameText.Position + Vector2.new(textBounds.X / 2, -textBounds.Y / 2)
                esp.NameBackground.PointC = esp.NameText.Position + Vector2.new(textBounds.X / 2, textBounds.Y / 2)
                esp.NameBackground.PointD = esp.NameText.Position + Vector2.new(-textBounds.X / 2, textBounds.Y / 2)
                esp.NameBackground.Visible = renderESP
            end
        end

        if esp.DistanceText then
            esp.DistanceText.Size = adaptiveTextSize * 0.8
            esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
            esp.DistanceText.Position = baseScreenPos + distanceOffset
            esp.DistanceText.Visible = renderESP
            if esp.DistanceBackground then
                local textBounds = esp.DistanceText.TextBounds
                esp.DistanceBackground.PointA = esp.DistanceText.Position - Vector2.new(textBounds.X / 2, textBounds.Y / 2)
                esp.DistanceBackground.PointB = esp.DistanceText.Position + Vector2.new(textBounds.X / 2, -textBounds.Y / 2)
                esp.DistanceBackground.PointC = esp.DistanceText.Position + Vector2.new(textBounds.X / 2, textBounds.Y / 2)
                esp.DistanceBackground.PointD = esp.DistanceText.Position + Vector2.new(-textBounds.X / 2, textBounds.Y / 2)
                esp.DistanceBackground.Visible = renderESP
            end
        end

        if esp.TracerLine and esp.TracerGlow then
            local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            if LibraryESP.LineFrom == "Top" then
                from = Vector2.new(Camera.ViewportSize.X/2, 0)
            elseif LibraryESP.LineFrom == "Center" then
                from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Below" then
                from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y * 0.8)
            elseif LibraryESP.LineFrom == "Left" then
                from = Vector2.new(0, Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Right" then
                from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y/2)
            end

            -- Target point for tracer is the base of the object
            local tracerTargetScreenPoint, tracerTargetOnScreen = Camera:WorldToScreenPoint(objectBasePoint)
            local tracerTargetPos = Vector2.new(tracerTargetScreenPoint.X, tracerTargetScreenPoint.Y)


            if LibraryESP.TracerStyle == "Solid" then
                esp.TracerLine.From = from
                esp.TracerLine.To = tracerTargetPos
                esp.TracerLine.Visible = renderESP and tracerTargetOnScreen
                esp.TracerGlow.From = from
                esp.TracerGlow.To = tracerTargetPos
                esp.TracerGlow.Visible = renderESP and tracerTargetOnScreen
            elseif LibraryESP.TracerStyle == "Dashed" then
                -- For dashed lines, we'd ideally draw multiple small lines.
                -- For simplicity and performance with Drawing objects,
                -- this is a basic "simulation" by setting visibility based on current frame or a counter.
                -- A proper dashed line would require dynamically creating/updating many Drawing.Line objects.
                esp.TracerLine.From = from
                esp.TracerLine.To = tracerTargetPos
                esp.TracerLine.Visible = renderESP and tracerTargetOnScreen -- Always visible, actual dashing needs more logic
                esp.TracerGlow.From = from
                esp.TracerGlow.To = tracerTargetPos
                esp.TracerGlow.Visible = renderESP and tracerTargetOnScreen
            end
        end

        if esp.Box then
            local edges = { {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8} }
            for idx, edge in ipairs(edges) do
                local pair = esp.Box[idx]
                if renderESP and allCornersOnScreen then
                    pair.Line.From, pair.Line.To = screenCorners[edge[1]], screenCorners[edge[2]]
                    pair.Glow.From, pair.Glow.To = screenCorners[edge[1]], screenCorners[edge[2]]
                    pair.Line.Visible, pair.Glow.Visible = true, true
                else
                    pair.Line.Visible, pair.Glow.Visible = false, false
                end
            end
        end
    end
end)

return LibraryESP

