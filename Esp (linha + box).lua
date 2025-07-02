local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local ESP = {
    Enabled = true,
    ShowBox = true,
    ShowTracer = true,
    MaxDistance = 100,
    MaxESP = 15,
    BoxColor = Color3.fromRGB(0, 200, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
}

local storage = {}

local function create(class, props)
    local inst = Drawing.new(class)
    for prop, val in pairs(props) do
        inst[prop] = val
    end
    return inst
end

local function drawESP(obj, id)
    if storage[id] then return end

    local box = create("Square", {
        Thickness = 1.5,
        Color = ESP.BoxColor,
        Filled = false,
        Visible = false,
    })

    local line = create("Line", {
        Thickness = 1.5,
        Color = ESP.TracerColor,
        Visible = false,
    })

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not ESP.Enabled or not obj or not obj:IsDescendantOf(workspace) then
            box.Visible = false
            line.Visible = false
            return
        end

        local pos, onScreen = camera:WorldToViewportPoint(obj.Position)
        if not onScreen or (obj.Position - camera.CFrame.Position).Magnitude > ESP.MaxDistance then
            box.Visible = false
            line.Visible = false
            return
        end

        local size = obj.Size
        local top = camera:WorldToViewportPoint(obj.Position + Vector3.new(0, size.Y / 2, 0))
        local bottom = camera:WorldToViewportPoint(obj.Position - Vector3.new(0, size.Y / 2, 0))
        local height = (top - bottom).Y
        local width = height * (size.X / size.Y)

        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
        box.Color = ESP.BoxColor
        box.Visible = ESP.ShowBox

        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
        line.From = center
        line.To = Vector2.new(pos.X, pos.Y)
        line.Color = ESP.TracerColor
        line.Visible = ESP.ShowTracer
    end)

    storage[id] = {
        obj = obj,
        box = box,
        line = line,
        conn = conn,
    }
end

function ESP.UpdateAll(tipo, list, color)
    local seen = {}
    local count = 0
    for _, obj in ipairs(list) do
        if obj and obj:IsA("BasePart") and obj:IsDescendantOf(workspace) then
            local dist = (camera.CFrame.Position - obj.Position).Magnitude
            if dist <= ESP.MaxDistance then
                local id = tipo .. tostring(obj:GetDebugId())
                if not storage[id] and count < ESP.MaxESP then
                    ESP.BoxColor = color or ESP.BoxColor
                    ESP.TracerColor = color or ESP.TracerColor
                    drawESP(obj, id)
                    count += 1
                end
                seen[id] = true
            end
        end
    end

    for id, data in pairs(storage) do
        if not seen[id] then
            ESP.Remove(id)
        end
    end
end

function ESP.Remove(id)
    local data = storage[id]
    if data then
        if data.box then data.box:Remove() end
        if data.line then data.line:Remove() end
        if data.conn then data.conn:Disconnect() end
        storage[id] = nil
    end
end

function ESP.RemoveAll()
    for id in pairs(storage) do
        ESP.Remove(id)
    end
end

return ESP
