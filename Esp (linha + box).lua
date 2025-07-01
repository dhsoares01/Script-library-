local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local ESPLibrary = {}
local maxESP = 12
local espDistanceMax = 100
local drawingLines = {}

-- Cria a caixa ESP em um objeto BasePart
function ESPLibrary.CreateESPBox(obj, cor)
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
        frame.BackgroundColor3 = cor or Color3.new(0, 1, 0)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = cor or Color3.new(0, 1, 0)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Parent = surfaceGui
    end
end

-- Cria a linha Beam que conecta o objeto à câmera
function ESPLibrary.CreateESPBeam(obj, tipo, cor)
    if obj:FindFirstChild("ESP_Attach") then return end

    local root = Instance.new("Attachment", obj)
    root.Name = "ESP_Attach"

    local originPart = Instance.new("Part")
    originPart.Size = Vector3.new(0.2, 0.2, 0.2)
    originPart.Transparency = 1
    originPart.Anchored = true
    originPart.CanCollide = false
    originPart.Name = "ESP_Origin"
    originPart.Parent = workspace

    local originAttach = Instance.new("Attachment", originPart)

    local beam = Instance.new("Beam")
    beam.Attachment0 = originAttach
    beam.Attachment1 = root
    beam.FaceCamera = true
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.Color = ColorSequence.new(cor or Color3.fromRGB(0, 255, 0))
    beam.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.2)
    }
    beam.LightEmission = 0.7
    beam.Texture = "rbxassetid://127587558"
    beam.TextureLength = 5
    beam.TextureSpeed = 1
    beam.Parent = originPart

    local pulseTime = 0
    local updateConn = RunService.RenderStepped:Connect(function(dt)
        pulseTime = pulseTime + dt * 2
        local alpha = (math.sin(pulseTime) + 1) / 2 * 0.3 + 0.2
        beam.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, alpha),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, alpha)
        }

        local camCFrame = camera.CFrame
        local pos = camCFrame.Position + camCFrame.LookVector * 2 + Vector3.new(0, -1.5, 0)
        originPart.Position = pos
    end)

    drawingLines[tipo] = drawingLines[tipo] or {}
    drawingLines[tipo][obj] = {
        beam = beam,
        originPart = originPart,
        updateConn = updateConn,
        rootAttach = root
    }
end

-- Remove a ESP do objeto
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

-- Atualiza todas ESPs de um tipo para um conjunto de objetos
function ESPLibrary.UpdateAll(tipo, objs, cor)
    local cameraPos = camera.CFrame.Position
    local objsValidos, objSet = {}, {}

    for _, obj in pairs(objs) do
        if obj and obj:IsDescendantOf(workspace) and obj:IsA("BasePart") then
            local dist = (obj.Position - cameraPos).Magnitude
            if dist <= espDistanceMax then
                table.insert(objsValidos, {obj = obj, dist = dist})
                objSet[obj] = true
            else
                ESPLibrary.RemoveESP(tipo, obj)
            end
        else
            ESPLibrary.RemoveESP(tipo, obj)
        end
    end

    table.sort(objsValidos, function(a, b) return a.dist < b.dist end)

    for i, info in pairs(objsValidos) do
        local obj = info.obj
        if i <= maxESP then
            if not (drawingLines[tipo] and drawingLines[tipo][obj]) then
                ESPLibrary.CreateESPBeam(obj, tipo, cor)
            end
            ESPLibrary.CreateESPBox(obj, cor)
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

return ESPLibrary
