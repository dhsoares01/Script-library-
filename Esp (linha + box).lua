local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local ESPLibrary = {}
local maxESP = 12
local espDistanceMax = 100
local drawingLines = {}

-- Cores padrão
local DEFAULT_COLOR = Color3.fromRGB(0, 200, 255)
local BORDER_COLOR = Color3.fromRGB(255, 255, 255)

-- ESP 3D Box com SurfaceGui
function ESPLibrary.CreateESPBox(obj, color)
    if obj:FindFirstChild("ESPBoxGui") then return end

    local faces = {
        Enum.NormalId.Top, Enum.NormalId.Bottom,
        Enum.NormalId.Left, Enum.NormalId.Right,
        Enum.NormalId.Front, Enum.NormalId.Back,
    }

    for _, face in ipairs(faces) do
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ESPBoxGui"
        surfaceGui.Adornee = obj
        surfaceGui.Face = face
        surfaceGui.AlwaysOnTop = true
        surfaceGui.LightInfluence = 0
        surfaceGui.ResetOnSpawn = false
        surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        surfaceGui.Parent = obj

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = color or DEFAULT_COLOR
        frame.BorderColor3 = BORDER_COLOR
        frame.BorderSizePixel = 1
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.Parent = surfaceGui

        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(0, 3)
        uicorner.Parent = frame
    end
end

-- ESP linha com Beam 3D
function ESPLibrary.CreateESPBeam(obj, tipo, color)
    if obj:FindFirstChild("ESP_Attach") then return end

    local root = Instance.new("Attachment", obj)
    root.Name = "ESP_Attach"

    local sphere = Instance.new("Part")
    sphere.Size = Vector3.new(0.35, 0.35, 0.35)
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.Neon
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Transparency = 0.35
    sphere.Color = color or DEFAULT_COLOR
    sphere.Name = "ESP_Sphere"
    sphere.Parent = workspace

    local originAttach = Instance.new("Attachment", sphere)

    local beam = Instance.new("Beam")
    beam.Attachment0 = originAttach
    beam.Attachment1 = root
    beam.FaceCamera = true
    beam.Width0 = 0.08
    beam.Width1 = 0.08
    beam.Color = ColorSequence.new(color or DEFAULT_COLOR)
    beam.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    }
    beam.LightEmission = 1
    beam.Texture = "rbxassetid://127587558"
    beam.TextureLength = 2.5
    beam.TextureSpeed = 0.6
    beam.Parent = sphere

    local pulseTime = 0
    local updateConn = RunService.RenderStepped:Connect(function(dt)
        pulseTime += dt * 1.5
        local alpha = (math.sin(pulseTime) + 1) / 2 * 0.2 + 0.3
        beam.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, alpha),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, alpha)
        }

        local cam = camera.CFrame
        sphere.Position = cam.Position + cam.LookVector * 2 + Vector3.new(0, -1.5, 0)
    end)

    drawingLines[tipo] = drawingLines[tipo] or {}
    drawingLines[tipo][obj] = {
        beam = beam,
        originPart = sphere,
        updateConn = updateConn,
        rootAttach = root
    }
end

-- ESP 2D (linha + box)
function ESPLibrary.CreateESP2D(obj, tipo, color)
    if not obj:IsA("BasePart") then return end
    drawingLines[tipo] = drawingLines[tipo] or {}

    if drawingLines[tipo][obj] then return end

    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = color or DEFAULT_COLOR
    line.Visible = true

    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Color = color or DEFAULT_COLOR
    box.Filled = false
    box.Visible = true

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not obj or not obj:IsDescendantOf(workspace) then
            line:Remove()
            box:Remove()
            conn:Disconnect()
            return
        end

        local rootPos, onScreen = camera:WorldToViewportPoint(obj.Position)
        if not onScreen then
            line.Visible = false
            box.Visible = false
            return
        end

        local size = obj.Size
        local screenSize = (camera:WorldToViewportPoint(obj.Position + Vector3.new(0, size.Y / 2, 0)) - camera:WorldToViewportPoint(obj.Position - Vector3.new(0, size.Y / 2, 0))).Y
        local width = screenSize * (size.X / size.Y)

        box.Size = Vector2.new(width, screenSize)
        box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - screenSize / 2)
        box.Visible = true

        local viewCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        line.From = viewCenter
        line.To = Vector2.new(rootPos.X, rootPos.Y)
        line.Visible = true
    end)

    drawingLines[tipo][obj] = {
        box = box,
        line = line,
        updateConn = conn
    }
end

-- Remove todos os tipos de ESP
function ESPLibrary.RemoveESP(tipo, obj)
    if drawingLines[tipo] and drawingLines[tipo][obj] then
        local esp = drawingLines[tipo][obj]
        if esp.beam then esp.beam:Destroy() end
        if esp.originPart then esp.originPart:Destroy() end
        if esp.box and typeof(esp.box.Remove) == "function" then esp.box:Remove() end
        if esp.line and typeof(esp.line.Remove) == "function" then esp.line:Remove() end
        if esp.updateConn then esp.updateConn:Disconnect() end
        if esp.rootAttach then esp.rootAttach:Destroy() end
        drawingLines[tipo][obj] = nil
    end

    for _, child in ipairs(obj:GetChildren()) do
        if child.Name == "ESPBoxGui" or child.Name == "ESP_Attach" then
            child:Destroy()
        end
    end
end

-- Atualiza tudo por tipo
function ESPLibrary.UpdateAll(tipo, objs, color)
    local cameraPos = camera.CFrame.Position
    local validObjs, objSet = {}, {}

    for _, obj in ipairs(objs) do
        if obj and obj:IsDescendantOf(workspace) and obj:IsA("BasePart") then
            local dist = (obj.Position - cameraPos).Magnitude
            if dist <= espDistanceMax then
                table.insert(validObjs, {obj = obj, dist = dist})
                objSet[obj] = true
            else
                ESPLibrary.RemoveESP(tipo, obj)
            end
        else
            ESPLibrary.RemoveESP(tipo, obj)
        end
    end

    table.sort(validObjs, function(a, b) return a.dist < b.dist end)

    for i, info in ipairs(validObjs) do
        local obj = info.obj
        if i <= maxESP then
            ESPLibrary.CreateESP2D(obj, tipo, color)
            ESPLibrary.CreateESPBox(obj, color)
        else
            ESPLibrary.RemoveESP(tipo, obj)
        end
    end

    if drawingLines[tipo] then
        for obj in pairs(drawingLines[tipo]) do
            if not objSet[obj] then
                ESPLibrary.RemoveESP(tipo, obj)
            end
        end
    end
end

-- Limpa todos
function ESPLibrary.RemoveAll(tipo)
    if drawingLines[tipo] then
        for obj in pairs(drawingLines[tipo]) do
            ESPLibrary.RemoveESP(tipo, obj)
        end
        drawingLines[tipo] = {}
    end
end

return ESPLibrary
