local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local ESPLibrary = {}
local maxESP = 12
local espDistanceMax = 100
local drawingLines = {}

function ESPLibrary.CreateESPBox(obj, color)
    if obj:FindFirstChild("ESPBoxGui") then return end

    local faces = {
        Enum.NormalId.Top,
        Enum.NormalId.Bottom,
        Enum.NormalId.Left,
        Enum.NormalId.Right,
        Enum.NormalId.Front,
        Enum.NormalId.Back,
    }

    for _, face in pairs(faces) do
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ESPBoxGui"
        surfaceGui.Adornee = obj
        surfaceGui.AlwaysOnTop = true
        surfaceGui.Face = face
        surfaceGui.LightInfluence = 0
        surfaceGui.ResetOnSpawn = false
        surfaceGui.Parent = obj

        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = color or Color3.new(0, 1, 0)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = color or Color3.new(0, 1, 0)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Parent = surfaceGui
    end
end

function ESPLibrary.CreateESPBeam(obj, tipo, color)
    if obj:FindFirstChild("ESP_Attach") then return end

    local root = Instance.new("Attachment", obj)
    root.Name = "ESP_Attach"

    -- Bolinha visível na frente da câmera
    local sphere = Instance.new("Part")
    sphere.Size = Vector3.new(0.4, 0.4, 0.4)
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.Neon
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Transparency = 0.3
    sphere.Color = color or Color3.fromRGB(0, 255, 0)
    sphere.Name = "ESP_Sphere"
    sphere.Parent = workspace

    local originAttach = Instance.new("Attachment", sphere)

    local beam = Instance.new("Beam")
    beam.Attachment0 = originAttach
    beam.Attachment1 = root
    beam.FaceCamera = true
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.Color = ColorSequence.new(color or Color3.fromRGB(0, 255, 0))
    beam.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.2)
    }
    beam.LightEmission = 1
    beam.Texture = "rbxassetid://127587558"
    beam.TextureLength = 5
    beam.TextureSpeed = 1
    beam.Parent = sphere

    local pulseTime = 0
    local updateConn = RunService.RenderStepped:Connect(function(dt)
        pulseTime += dt * 2
        local alpha = (math.sin(pulseTime) + 1) / 2 * 0.3 + 0.2
        beam.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, alpha),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, alpha)
        }

        local camCFrame = camera.CFrame
        local pos = camCFrame.Position + camCFrame.LookVector * 2 + Vector3.new(0, -1.5, 0)
        sphere.Position = pos
    end)

    drawingLines[tipo] = drawingLines[tipo] or {}
    drawingLines[tipo][obj] = {
        beam = beam,
        originPart = sphere,
        updateConn = updateConn,
        rootAttach = root
    }
end

function ESPLibrary.RemoveESP(tipo, obj)
    if drawingLines[tipo] and drawingLines[tipo][obj] then
        local esp = drawingLines[tipo][obj]
        if esp.beam then esp.beam:Destroy() end
        if esp.originPart then esp.originPart:Destroy() end
        if esp.updateConn then esp.updateConn:Disconnect() end
        if esp.rootAttach then esp.rootAttach:Destroy() end
        drawingLines[tipo][obj] = nil
    end

    for _, child in pairs(obj:GetChildren()) do
        if child.Name == "ESPBoxGui" or child.Name == "ESP_Attach" then
            child:Destroy()
        end
    end
end

function ESPLibrary.UpdateAll(tipo, objs, color)
    local cameraPos = camera.CFrame.Position
    local validObjs, objSet = {}, {}

    for _, obj in pairs(objs) do
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

    for i, info in pairs(validObjs) do
        local obj = info.obj
        if i <= maxESP then
            if not (drawingLines[tipo] and drawingLines[tipo][obj]) then
                ESPLibrary.CreateESPBeam(obj, tipo, color)
            end
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

function ESPLibrary.RemoveAll(tipo)
    if drawingLines[tipo] then
        for obj, _ in pairs(drawingLines[tipo]) do
            ESPLibrary.RemoveESP(tipo, obj)
        end
        drawingLines[tipo] = {}
    end
end

return ESPLibrary
