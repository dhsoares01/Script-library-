--[[
  📦 ESP v4.1 (Aprimorado)
  - Box 3D com efeito de brilho, outline adaptativo e fade
  - Texto adaptativo: tamanho e contraste inteligente, fundo ajustado
  - Tracer com suporte real a linhas tracejadas
  - Limpeza e atualização eficientes para performance
  - API fácil de customizar pelo usuário
]]

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

-- Configurações padrão (mutáveis em tempo real pelo usuário)
LibraryESP.TextPosition = "Top"
LibraryESP.LineFrom = "Bottom"
LibraryESP.TracerStyle = "Solid" -- "Solid", "Dashed"
LibraryESP.MaxDistance = 500

-- ⬇️️ Utilitários de desenho
local function CreateText(size, color, outlineColor)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.OutlineColor = outlineColor or Color3.fromRGB(20,20,20)
    text.Font = 2
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
        local outline = Drawing.new("Line")
        outline.Thickness = 3.2
        outline.Color = Color3.fromRGB(20,20,20)
        outline.Transparency = 0.75
        outline.Visible = false

        local line = Drawing.new("Line")
        line.Thickness = 1.6
        line.Color = color
        line.Transparency = 0.12
        line.Visible = false

        local glowLine = Drawing.new("Line")
        glowLine.Thickness = 0.8
        glowLine.Color = color
        glowLine.Transparency = 0.5
        glowLine.Visible = false

        table.insert(boxElements, {Outline=outline, Line=line, Glow=glowLine})
    end
    return boxElements
end

-- ⬇️ Utilitário para linhas tracejadas reais
local function RenderDashedLine(lineList, from, to, color, thickness, alpha, dash, gap, visible)
    local dir = (to-from)
    local len = dir.Magnitude
    dir = dir.Unit
    local pos = from
    local drawn = 0
    local idx = 1
    while drawn < len do
        local segEnd = (drawn+dash > len) and to or (pos + dir*dash)
        local seg = lineList[idx] or CreateLine(color, thickness, alpha)
        seg.From, seg.To = pos, segEnd
        seg.Color = color
        seg.Thickness = thickness
        seg.Transparency = alpha
        seg.Visible = visible
        lineList[idx] = seg
        pos = segEnd + dir*gap
        drawn = drawn + dash + gap
        idx = idx+1
    end
    -- Oculta segmentos não usados
    for i=idx,#lineList do
        if lineList[i] then lineList[i].Visible = false end
    end
end

-- ⬇️ Utilitários de posição/size
local function getObjectPosition(object)
    if typeof(object) ~= "Instance" then return nil end
    if object:IsA("BasePart") then
        return object.Position
    elseif object:IsA("Model") then
        local ok, pivot = pcall(function() return object:GetPivot() end)
        if ok then return pivot.Position end
        if object.PrimaryPart then return object.PrimaryPart.Position end
        for _, part in ipairs(object:GetChildren()) do
            if part:IsA("BasePart") then return part.Position end
        end
    end
    return nil
end

local function getObjectSize(object)
    if typeof(object) ~= "Instance" then return Vector3.one end
    if object:IsA("BasePart") then return object.Size end
    if object:IsA("Model") then
        local ok, size = pcall(function() return object:GetExtentsSize() end)
        if ok then return size end
        if object.PrimaryPart then return object.PrimaryPart.Size end
    end
    return Vector3.new(2,4,2)
end

-- ⬇️ Criação e remoção de ESP
function LibraryESP:CreateESP(object, options)
    local color = options.Color or Color3.fromRGB(255,255,255)
    local outlineColor = options.OutlineColor or Color3.fromRGB(20,20,20)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and CreateText(14, color, outlineColor) or nil,
        NameBackground = options.Name and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        DistanceText = options.Distance and CreateText(13, color, outlineColor) or nil,
        DistanceBackground = options.Distance and options.TextBackground and CreateFilledQuad(Color3.fromRGB(0,0,0), 0.5) or nil,
        TracerLine = options.Tracer and CreateLine(color, 2, 0.25) or nil,
        TracerGlow = options.Tracer and CreateLine(color, 1, 0.3) or nil,
        TracerDashList = {}, -- Lista de linhas para dash
        Box = options.Box and Create3DBox(color) or nil,
    }
    table.insert(ESPObjects, esp)
    return esp
end

function LibraryESP:RemoveESP(object)
    for i = #ESPObjects,1,-1 do
        local esp = ESPObjects[i]
        if esp.Object == object or object == nil then
            if esp.NameText then esp.NameText:Remove() end
            if esp.NameBackground then esp.NameBackground:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.DistanceBackground then esp.DistanceBackground:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.TracerGlow then esp.TracerGlow:Remove() end
            if esp.TracerDashList then for _,l in ipairs(esp.TracerDashList) do l:Remove() end end
            if esp.Box then for _,pair in ipairs(esp.Box) do pair.Outline:Remove() pair.Line:Remove() pair.Glow:Remove() end end
            table.remove(ESPObjects, i)
        end
    end
end

-- ⬇️ Loop principal
RunService.RenderStepped:Connect(function()
    for i = #ESPObjects,1,-1 do
        local esp = ESPObjects[i]
        local obj = esp.Object
        if not obj or typeof(obj)~="Instance" or not obj:IsDescendantOf(workspace) then
            LibraryESP:RemoveESP(obj)
            continue
        end

        local objPos = getObjectPosition(obj)
        if not objPos then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(objPos)
        local screenPos = Vector2.new(pos.X, pos.Y)
        local distance = (Camera.CFrame.Position - objPos).Magnitude
        local isVisible = onScreen and distance <= LibraryESP.MaxDistance

        -- Texto adaptativo
        local baseTextSize = 14
        local adaptiveTextSize = math.max(8, baseTextSize * (1 - distance/LibraryESP.MaxDistance * 0.7))
        local textColor = esp.Options.Color or Color3.fromRGB(255,255,255)

        local nameOffset = Vector2.new(0,-25)
        local distanceOffset = Vector2.new(0,16)

        if esp.NameText then
            esp.NameText.Text = esp.Options.NameTextString or obj.Name
            esp.NameText.Size = adaptiveTextSize
            esp.NameText.Color = textColor
            esp.NameText.Position = screenPos + nameOffset
            esp.NameText.Visible = isVisible
            if esp.NameBackground then
                local tb = esp.NameText.TextBounds
                local pos = esp.NameText.Position
                esp.NameBackground.PointA = pos - tb/2
                esp.NameBackground.PointB = pos + Vector2.new(tb.X/2,-tb.Y/2)
                esp.NameBackground.PointC = pos + tb/2
                esp.NameBackground.PointD = pos + Vector2.new(-tb.X/2,tb.Y/2)
                esp.NameBackground.Visible = isVisible
            end
        end

        if esp.DistanceText then
            esp.DistanceText.Size = adaptiveTextSize*0.8
            esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
            esp.DistanceText.Color = textColor
            esp.DistanceText.Position = screenPos + distanceOffset
            esp.DistanceText.Visible = isVisible
            if esp.DistanceBackground then
                local tb = esp.DistanceText.TextBounds
                local pos = esp.DistanceText.Position
                esp.DistanceBackground.PointA = pos - tb/2
                esp.DistanceBackground.PointB = pos + Vector2.new(tb.X/2,-tb.Y/2)
                esp.DistanceBackground.PointC = pos + tb/2
                esp.DistanceBackground.PointD = pos + Vector2.new(-tb.X/2,tb.Y/2)
                esp.DistanceBackground.Visible = isVisible
            end
        end

        if esp.TracerLine and esp.TracerGlow then
            local from = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            if LibraryESP.LineFrom == "Top" then from = Vector2.new(Camera.ViewportSize.X/2,0)
            elseif LibraryESP.LineFrom == "Center" then from = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Below" then from = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y*0.8)
            elseif LibraryESP.LineFrom == "Left" then from = Vector2.new(0,Camera.ViewportSize.Y/2)
            elseif LibraryESP.LineFrom == "Right" then from = Vector2.new(Camera.ViewportSize.X,Camera.ViewportSize.Y/2) end

            if LibraryESP.TracerStyle == "Solid" then
                esp.TracerLine.From = from
                esp.TracerLine.To = screenPos
                esp.TracerLine.Visible = isVisible
                esp.TracerGlow.From = from
                esp.TracerGlow.To = screenPos
                esp.TracerGlow.Visible = isVisible
                -- Oculta dashes se houver
                if esp.TracerDashList then for _,l in ipairs(esp.TracerDashList) do l.Visible=false end end
            elseif LibraryESP.TracerStyle == "Dashed" then
                -- Esconde linhas sólidas
                esp.TracerLine.Visible = false
                esp.TracerGlow.Visible = false
                RenderDashedLine(esp.TracerDashList, from, screenPos, textColor, 2, 0.6, 10, 7, isVisible)
            end
        end

        -- Box 3D
        if esp.Box then
            local cf = (obj.CFrame or (obj:IsA("Model") and obj:GetPivot())) or CFrame.new(objPos)
            local size = getObjectSize(obj)/2
            local corners = {
                Vector3.new( size.X, size.Y, size.Z), Vector3.new(-size.X, size.Y, size.Z),
                Vector3.new(-size.X,-size.Y, size.Z), Vector3.new( size.X,-size.Y, size.Z),
                Vector3.new( size.X, size.Y,-size.Z), Vector3.new(-size.X, size.Y,-size.Z),
                Vector3.new(-size.X,-size.Y,-size.Z), Vector3.new( size.X,-size.Y,-size.Z),
            }
            local screenPts, allOnScreen = {}, true
            for _,c in ipairs(corners) do
                local wp = cf:PointToWorldSpace(c)
                local vec, vis = Camera:WorldToViewportPoint(wp)
                table.insert(screenPts, Vector2.new(vec.X,vec.Y))
                if not vis then allOnScreen = false end
            end
            local edges = { {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8} }
            local fade = math.clamp(1 - (distance/LibraryESP.MaxDistance), 0.25, 1)
            for idx, edge in ipairs(edges) do
                local pair = esp.Box[idx]
                if isVisible and allOnScreen then
                    pair.Outline.From, pair.Outline.To = screenPts[edge[1]], screenPts[edge[2]]
                    pair.Outline.Transparency = 0.7*fade
                    pair.Outline.Visible = true
                    pair.Line.From, pair.Line.To = screenPts[edge[1]], screenPts[edge[2]]
                    pair.Line.Transparency = 0.13*fade
                    pair.Line.Visible = true
                    pair.Glow.From, pair.Glow.To = screenPts[edge[1]], screenPts[edge[2]]
                    pair.Glow.Transparency = 0.5*fade
                    pair.Glow.Visible = true
                else
                    pair.Outline.Visible, pair.Line.Visible, pair.Glow.Visible = false, false, false
                end
            end
        end
    end
end)

return LibraryESP
