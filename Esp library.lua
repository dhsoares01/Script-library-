local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
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

local function CalculatePath(startPos, endPos)
    local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
    path:ComputeAsync(startPos, endPos)
    if path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints()
    end
    return nil
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

local function CreatePathParts(num, color)
    local parts = {}
    for i = 1, num do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.2,0.2,0.2)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0
        part.Color = color or Color3.new(0,1,0)
        part.Parent = workspace
        table.insert(parts, part)
    end
    return parts
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
        PathLines = options.Path and CreatePathParts(0, options.PathColor or Color3.new(0,1,0)) or nil,
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
            if esp.PathLines then
                for _, part in ipairs(esp.PathLines) do
                    part:Destroy()
                end
            end
            table.remove(ESPObjects, i)
        end
    end
end

RunService.RenderStepped:Connect(function()
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            LibraryESP:RemoveESP(obj)
        else
            local objPos = getObjectPosition(obj)
            local pos, onScreen = objPos and Camera:WorldToViewportPoint(objPos) or {}, false
            if objPos then pos, onScreen = Camera:WorldToViewportPoint(objPos) end
            local distance = (Camera.CFrame.Position - objPos).Magnitude

            -- (Aqui fica igual para NameText, DistanceText, TracerLine, Box, Highlight)

            -- ✅ NOVO: PathLines em 3D
            if esp.PathLines then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and objPos then
                    local waypoints = CalculatePath(hrp.Position, objPos)
                    local needed = waypoints and (#waypoints - 1) or 0

                    -- Ajusta quantidade de parts
                    while #esp.PathLines < needed do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(0.2,0.2,0.2)
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 0
                        part.Color = esp.Options.PathColor or Color3.new(0,1,0)
                        part.Parent = workspace
                        table.insert(esp.PathLines, part)
                    end
                    while #esp.PathLines > needed do
                        local part = table.remove(esp.PathLines)
                        part:Destroy()
                    end

                    if waypoints then
                        for idx = 1, #waypoints - 1 do
                            local wp1 = waypoints[idx].Position
                            local wp2 = waypoints[idx+1].Position
                            local part = esp.PathLines[idx]

                            local distance = (wp1 - wp2).Magnitude
                            part.Size = Vector3.new(0.2, 0.2, distance)
                            part.CFrame = CFrame.new(wp1, wp2) * CFrame.new(0,0,-distance/2)
                            part.Color = esp.Options.PathColor or Color3.new(0,1,0)
                            part.Transparency = 0
                        end
                    else
                        for _, part in ipairs(esp.PathLines) do
                            part.Transparency = 1
                        end
                    end
                else
                    for _, part in ipairs(esp.PathLines) do
                        part.Transparency = 1
                    end
                end
            end
        end
    end
end)

return LibraryESP
