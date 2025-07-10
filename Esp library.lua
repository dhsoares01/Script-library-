--[[
    📦 ESP v2 (Orientado a Objeto, Design Aprimorado)
    Recursos:
    - Line (tracer do jogador local até o alvo)
    - Box (caixa 2D ou 3D ao redor do alvo, formas aprimoradas e centralizadas)
    - Name (exibe o nome do alvo com melhor fonte e alinhamento)
    - Distance (exibe a distância do alvo em studs, tooltip elegante)
    - Suporte fácil para personalização global (cor, fonte, espessura, transparência)
    - Ocultação automática para objetos fora da tela ou obstruídos
    - Limpeza automática de recursos (anti-leak)
]]--

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LibraryESP = {}
local ESPObjects = {}

-- Configurações Globais
LibraryESP.TextPosition = "Top"      -- "Top", "Center", "Bottom", "Below", "LeftSide", "RightSide"
LibraryESP.LineFrom = "Bottom"       -- "Top", "Center", "Bottom", "Below", "Left", "Right"
LibraryESP.BoxShape = "Square"       -- "Square", "Circle", "Octagon"
LibraryESP.GlobalColor = Color3.fromRGB(18, 194, 233)
LibraryESP.GlobalThickness = 2
LibraryESP.GlobalTransparency = 0.9
LibraryESP.GlobalFont = 2            -- 1 = UI, 2 = System, 3 = Plex, 4 = Monospace

local function ApplyDrawingDefaults(draw)
    draw.Color = LibraryESP.GlobalColor
    draw.Transparency = LibraryESP.GlobalTransparency
    if draw.Thickness then draw.Thickness = LibraryESP.GlobalThickness end
    if draw.Font then draw.Font = LibraryESP.GlobalFont end
    return draw
end

local function DrawText(size, color)
    local text = Drawing.new("Text")
    text.Size = size
    text.Center = true
    text.Outline = true
    text.Color = color or LibraryESP.GlobalColor
    text.Font = LibraryESP.GlobalFont
    text.Transparency = LibraryESP.GlobalTransparency
    text.Visible = false
    return text
end

local function DrawLine(color)
    local line = Drawing.new("Line")
    line.Thickness = LibraryESP.GlobalThickness
    line.Color = color or LibraryESP.GlobalColor
    line.Transparency = LibraryESP.GlobalTransparency
    line.Visible = false
    return line
end

local function DrawBox(color)
    local shape
    if LibraryESP.BoxShape == "Circle" then
        shape = Drawing.new("Circle")
        shape.Radius = 50
        shape.Thickness = LibraryESP.GlobalThickness
        shape.Filled = false
        shape.Color = color or LibraryESP.GlobalColor
        shape.Transparency = LibraryESP.GlobalTransparency
        shape.Visible = false
    elseif LibraryESP.BoxShape == "Octagon" then
        shape = {}
        for i = 1,8 do
            local line = Drawing.new("Line")
            line.Thickness = LibraryESP.GlobalThickness
            line.Color = color or LibraryESP.GlobalColor
            line.Transparency = LibraryESP.GlobalTransparency
            line.Visible = false
            table.insert(shape, line)
        end
    else -- Square
        shape = Drawing.new("Square")
        shape.Thickness = LibraryESP.GlobalThickness
        shape.Filled = false
        shape.Color = color or LibraryESP.GlobalColor
        shape.Transparency = LibraryESP.GlobalTransparency
        shape.Visible = false
    end
    return shape
end

function LibraryESP:CreateESP(object, options)
    options = options or {}
    local color = options.Color or LibraryESP.GlobalColor
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and DrawText(options.TextSize or 14, color) or nil,
        DistanceText = options.Distance and DrawText(options.TextSize or 13, color) or nil,
        TracerLine = options.Tracer and DrawLine(color) or nil,
        Box = options.Box and DrawBox(color) or nil,
        _removed = false
    }
    table.insert(ESPObjects, esp)
    return esp
end

function LibraryESP:RemoveESP(object)
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.Object == object or object == nil then
            local function safeRemove(draw)
                if draw and draw.Remove then pcall(function() draw:Remove() end) end
            end
            safeRemove(esp.NameText)
            safeRemove(esp.DistanceText)
            safeRemove(esp.TracerLine)
            if esp.Box then
                if LibraryESP.BoxShape == "Octagon" then
                    for _, line in ipairs(esp.Box) do safeRemove(line) end
                else
                    safeRemove(esp.Box)
                end
            end
            table.remove(ESPObjects, i)
        end
    end
end

local textOffsets = {
    Top      = Vector2.new(0, -18),
    Center   = Vector2.new(0, 0),
    Bottom   = Vector2.new(0, 18),
    Below    = Vector2.new(0, 28),
    LeftSide = Vector2.new(-44, 0),
    RightSide= Vector2.new(44, 0)
}
local function getTextPosition(basePos, offsetType)
    return basePos + (textOffsets[offsetType] or Vector2.new(0, 0))
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

-- Função para ocultar ESP se objeto estiver obstruído
local function isObstructed(objPos)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin, (objPos - origin).Unit * (objPos - origin).Magnitude)
    local part = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character, Camera})
    return (part ~= nil)
end

RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            LibraryESP:RemoveESP(obj)
        else
            local objPos = getObjectPosition(obj)
            if not objPos then
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then
                    if LibraryESP.BoxShape == "Octagon" then
                        for _, line in ipairs(esp.Box) do line.Visible = false end
                    else
                        esp.Box.Visible = false
                    end
                end
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(objPos)
            local basePos = Vector2.new(pos.X, pos.Y)
            local isBlocked = not onScreen or isObstructed(objPos)

            if not isBlocked then
                local distance = (Camera.CFrame.Position - objPos).Magnitude

                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = esp.Options.NameString or tostring(obj.Name)
                    esp.NameText.Color = esp.Options.Color or LibraryESP.GlobalColor
                    esp.NameText.Visible = true
                end

                if esp.DistanceText then
                    esp.DistanceText.Position = getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 16)
                    esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                    esp.DistanceText.Color = esp.Options.Color or LibraryESP.GlobalColor
                    esp.DistanceText.Visible = true
                end

                if esp.TracerLine then
                    local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    if LibraryESP.LineFrom == "Top" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    elseif LibraryESP.LineFrom == "Center" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Below" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.2)
                    elseif LibraryESP.LineFrom == "Left" then
                        from = Vector2.new(0, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Right" then
                        from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
                    end
                    esp.TracerLine.From = from
                    esp.TracerLine.To = basePos
                    esp.TracerLine.Color = esp.Options.Color or LibraryESP.GlobalColor
                    esp.TracerLine.Visible = true
                end

                if esp.Box then
                    local size3D = getObjectSize(obj)
                    local sizeX = math.clamp(size3D.X, 1, 10)
                    local sizeY = math.clamp(size3D.Y, 1, 10)
                    local scale = 320 / (distance + 1)

                    local boxWidth = sizeX * scale
                    local boxHeight = sizeY * scale

                    if LibraryESP.BoxShape == "Circle" then
                        esp.Box.Position = basePos
                        esp.Box.Radius = math.max(boxWidth, boxHeight) / 2
                        esp.Box.Color = esp.Options.Color or LibraryESP.GlobalColor
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
                            line.Color = esp.Options.Color or LibraryESP.GlobalColor
                            line.Visible = true
                        end

                    else -- Square
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
                        esp.Box.Color = esp.Options.Color or LibraryESP.GlobalColor
                        esp.Box.Visible = true
                    end
                end

            else
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then
                    if LibraryESP.BoxShape == "Octagon" then
                        for _, line in ipairs(esp.Box) do line.Visible = false end
                    else
                        esp.Box.Visible = false
                    end
                end
            end
        end
    end
end)

return LibraryESP
