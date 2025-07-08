--// LibraryESP.lua

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
local ESPObjects = {}

--// Configurações globais
LibraryESP.TextPosition = "Top" -- Top, Center, Bottom, Below, LeftSide, RightSide
LibraryESP.LineFrom = "Bottom" -- Top, Center, Bottom, Below, Left, Right

--// Funções de desenho
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

--// Função para pegar todos os cantos da bounding box 3D
local function GetBoundingCorners(cframe, size)
    local corners = {}
    for x = -0.5, 0.5, 1 do
        for y = -0.5, 0.5, 1 do
            for z = -0.5, 0.5, 1 do
                table.insert(corners, (cframe * CFrame.new(x * size.X, y * size.Y, z * size.Z)).Position)
            end
        end
    end
    return corners
end

--// Cria ESP
function LibraryESP:CreateESP(object, options)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,
        TracerLine = options.Tracer and DrawLine(options.Color or Color3.new(1, 1, 1)) or nil,
        Box = options.Box and DrawBox(options.Color or Color3.new(1, 1, 1)) or nil,
        Box3D = nil
    }

    if options.Box3D then
        local box3d = Instance.new("BoxHandleAdornment")
        box3d.Name = "ESPBox3D"
        box3d.Size = Vector3.new(1, 1, 1)
        box3d.Color3 = options.Color or Color3.new(1, 1, 1)
        box3d.Transparency = 0.7
        box3d.ZIndex = 0
        box3d.Adornee = object
        box3d.AlwaysOnTop = true
        box3d.Visible = true
        box3d.Parent = object
        esp.Box3D = box3d
    end

    table.insert(ESPObjects, esp)
    return esp
end

--// Remove ESP
function LibraryESP:RemoveESP(object)
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.Object == object or object == nil then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            if esp.Box3D then esp.Box3D:Destroy() end
            table.remove(ESPObjects, i)
        end
    end
end

--// Calcula posição de texto
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

--// Loop de atualização
RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            if esp.Box3D then esp.Box3D:Destroy() end
            table.remove(ESPObjects, i)
        else
            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            local basePos = Vector2.new(pos.X, pos.Y)

            if onScreen then
                local distance = (Camera.CFrame.Position - obj.Position).Magnitude

                -- Nome
                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = tostring(obj.Name)
                    esp.NameText.Visible = true
                end

                -- Distância
                if esp.DistanceText then
                    esp.DistanceText.Position = getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 14)
                    esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                    esp.DistanceText.Visible = true
                end

                -- Tracer
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

                -- Caixa 2D
                if esp.Box then
                    local cframe, size = obj:GetBoundingBox()
                    local corners = GetBoundingCorners(cframe, size)

                    local min, max = Vector2.new(math.huge, math.huge), Vector2.new(-math.huge, -math.huge)

                    for _, corner in ipairs(corners) do
                        local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
                        if onScreen then
                            local v2 = Vector2.new(screenPos.X, screenPos.Y)
                            min = Vector2.new(math.min(min.X, v2.X), math.min(min.Y, v2.Y))
                            max = Vector2.new(math.max(max.X, v2.X), math.max(max.Y, v2.Y))
                        end
                    end

                    local boxSize = max - min
                    esp.Box.Size = boxSize
                    esp.Box.Position = min
                    esp.Box.Visible = true
                end

                -- Caixa 3D já está ligada ao objeto, só atualiza visibilidade
                if esp.Box3D then
                    esp.Box3D.Visible = true
                end

            else
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then esp.Box.Visible = false end
                if esp.Box3D then esp.Box3D.Visible = false end
            end
        end
    end
end)

return LibraryESP
