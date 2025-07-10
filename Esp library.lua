--[[
    📦 ESP v2 (Orientado a Objeto + sistema de objetos ESP)
    Recursos:
    - Line (tracer do jogador local até o alvo)
    - Box (caixa 2D ou 3D ao redor do alvo)
    - Name (exibe o nome do alvo)
    - Distance (exibe a distância do alvo em studs)
    - Sistema de objetos ESP para controle individual (enable/disable/update)
]]--

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LibraryESP = {}
LibraryESP.__index = LibraryESP
LibraryESP.TextPosition = "Top"
LibraryESP.LineFrom = "Bottom"
LibraryESP.BoxShape = "Square"

local ESPObjects = {}

--=== Utilidades de desenho ===--
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

local function DrawBox(color, shape)
    shape = shape or LibraryESP.BoxShape
    local box
    if shape == "Circle" then
        box = Drawing.new("Circle")
        box.Radius = 50
        box.Thickness = 1
        box.Filled = false
        box.Color = color
        box.Visible = false
    elseif shape == "Octagon" then
        box = {}
        for i = 1,8 do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = color
            line.Visible = false
            table.insert(box, line)
        end
    else
        box = Drawing.new("Square")
        box.Thickness = 1
        box.Filled = false
        box.Color = color
        box.Visible = false
    end
    return box
end

--=== Utilidades de cálculo ===--
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

--=== ESP Object Class ===--
local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(object, options)
    options = options or {}
    local self = setmetatable({}, ESPObject)
    self.Object = object
    self.Options = options
    self.Enabled = true
    self.Color = options.Color or Color3.new(1,1,1)
    self.NameString = options.NameString or (object and object.Name or "NoName")

    -- Drawing objects
    self.NameText = options.Name and DrawText(13, self.Color) or nil
    self.DistanceText = options.Distance and DrawText(13, self.Color) or nil
    self.TracerLine = options.Tracer and DrawLine(self.Color) or nil
    self.Box = options.Box and DrawBox(self.Color, options.BoxShape or LibraryESP.BoxShape) or nil

    return self
end

function ESPObject:Update(options)
    options = options or {}
    for k, v in pairs(options) do
        self.Options[k] = v
    end
    if options.Color then
        self.Color = options.Color
        if self.NameText then self.NameText.Color = options.Color end
        if self.DistanceText then self.DistanceText.Color = options.Color end
        if self.TracerLine then self.TracerLine.Color = options.Color end
        if self.Box then
            if type(self.Box) == "table" then
                for _, l in ipairs(self.Box) do l.Color = options.Color end
            else
                self.Box.Color = options.Color
            end
        end
    end
    if options.NameString then
        self.NameString = options.NameString
    end
end

function ESPObject:SetEnabled(enabled)
    self.Enabled = enabled
    if self.NameText then self.NameText.Visible = false end
    if self.DistanceText then self.DistanceText.Visible = false end
    if self.TracerLine then self.TracerLine.Visible = false end
    if self.Box then
        if type(self.Box) == "table" then
            for _, l in ipairs(self.Box) do l.Visible = false end
        else
            self.Box.Visible = false
        end
    end
end

function ESPObject:Remove()
    if self.NameText then self.NameText:Remove() end
    if self.DistanceText then self.DistanceText:Remove() end
    if self.TracerLine then self.TracerLine:Remove() end
    if self.Box then
        if type(self.Box) == "table" then
            for _, l in ipairs(self.Box) do l:Remove() end
        else
            self.Box:Remove()
        end
    end
    self.Enabled = false
end

--=== Métodos da LibraryESP ===--

function LibraryESP:AddESP(object, options)
    local esp = ESPObject.new(object, options)
    table.insert(ESPObjects, esp)
    return esp
end

function LibraryESP:RemoveESP(objectOrESP)
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp == objectOrESP or esp.Object == objectOrESP then
            esp:Remove()
            table.remove(ESPObjects, i)
        end
    end
end

function LibraryESP:RemoveAll()
    for i = #ESPObjects, 1, -1 do
        ESPObjects[i]:Remove()
        table.remove(ESPObjects, i)
    end
end

function LibraryESP:GetAll()
    return ESPObjects
end

--=== Loop de renderização ===--
RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if not esp.Enabled then
            if esp.NameText then esp.NameText.Visible = false end
            if esp.DistanceText then esp.DistanceText.Visible = false end
            if esp.TracerLine then esp.TracerLine.Visible = false end
            if esp.Box then
                if type(esp.Box) == "table" then
                    for _, l in ipairs(esp.Box) do l.Visible = false end
                else
                    esp.Box.Visible = false
                end
            end
            continue
        end

        local obj = esp.Object
        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            esp:Remove()
            table.remove(ESPObjects, i)
        else
            local objPos = getObjectPosition(obj)
            if not objPos then
                esp:SetEnabled(false)
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(objPos)
            local basePos = Vector2.new(pos.X, pos.Y)
            local distance = (Camera.CFrame.Position - objPos).Magnitude

            if onScreen then
                -- Name
                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = esp.NameString
                    esp.NameText.Visible = true
                end
                -- Distance
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
                -- Box
                if esp.Box then
                    local size3D = getObjectSize(obj)
                    local sizeX = math.clamp(size3D.X, 1, 10)
                    local sizeY = math.clamp(size3D.Y, 1, 10)
                    local scale = 300 / (distance + 0.1)
                    local boxWidth = sizeX * scale
                    local boxHeight = sizeY * scale

                    if type(esp.Box) == "userdata" and esp.Box.ClassName == "Circle" then
                        esp.Box.Position = basePos
                        esp.Box.Radius = math.max(boxWidth, boxHeight) / 2
                        esp.Box.Visible = true
                    elseif type(esp.Box) == "table" then -- Octagon
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
                    else -- Square
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Position = Vector2.new(pos.X - boxWidth / 2, pos.Y - boxHeight / 2)
                        esp.Box.Visible = true
                    end
                end
            else
                esp:SetEnabled(false)
            end
        end
    end
end)

LibraryESP.ESPObject = ESPObject
return LibraryESP
