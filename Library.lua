-- ESP com suporte a jogadores e objetos
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local ESP_SETTINGS = {
    Enabled = true,
    ShowBox = true,
    ShowName = true,
    ShowTracer = true,
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    BoxOutlineColor = Color3.new(0, 0, 0),
    TracerPosition = "Bottom"
}

local cache = {}
local objectCache = {}
local ObjectESPList = {} -- insira aqui os objetos que deseja rastrear

-- Utilitário para criar desenho
local function create(class, props)
    local drawing = Drawing.new(class)
    for prop, val in pairs(props) do
        drawing[prop] = val
    end
    return drawing
end

-- Criar ESP para jogador
local function createPlayerEsp(player)
    local esp = {
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1
        })
    }
    cache[player] = esp
end

-- Criar ESP para objeto
local function createObjectEsp(obj)
    local esp = {
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13,
            Text = obj.Name
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 1
        })
    }
    objectCache[obj] = esp
end

-- Atualizar ESP
local function updateEsp()
    -- ESP de jogadores
    for player, esp in pairs(cache) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if ESP_SETTINGS.Enabled and root then
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local size = Vector2.new(60, 100)
                local boxPos = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                -- Box
                esp.box.Position = boxPos
                esp.box.Size = size
                esp.box.Visible = ESP_SETTINGS.ShowBox

                -- Name
                esp.name.Position = Vector2.new(pos.X, boxPos.Y - 16)
                esp.name.Text = player.Name
                esp.name.Visible = ESP_SETTINGS.ShowName

                -- Tracer
                if ESP_SETTINGS.ShowTracer then
                    local tracerY = ESP_SETTINGS.TracerPosition == "Top" and 0
                        or ESP_SETTINGS.TracerPosition == "Middle" and camera.ViewportSize.Y / 2
                        or camera.ViewportSize.Y
                    esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.tracer.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.tracer.Visible = false
        end
    end

    -- ESP de objetos
    for _, obj in ipairs(ObjectESPList) do
        if obj and obj:IsA("BasePart") then
            local esp = objectCache[obj]
            if not esp then
                createObjectEsp(obj)
                esp = objectCache[obj]
            end

            local pos, onScreen = camera:WorldToViewportPoint(obj.Position)
            if ESP_SETTINGS.Enabled and onScreen then
                local size = Vector2.new(50, 50)
                local boxPos = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                -- Box
                esp.box.Position = boxPos
                esp.box.Size = size
                esp.box.Visible = ESP_SETTINGS.ShowBox

                -- Name
                esp.name.Position = Vector2.new(pos.X, pos.Y - 20)
                esp.name.Text = obj.Name
                esp.name.Visible = ESP_SETTINGS.ShowName

                -- Tracer
                if ESP_SETTINGS.ShowTracer then
                    local tracerY = ESP_SETTINGS.TracerPosition == "Top" and 0
                        or ESP_SETTINGS.TracerPosition == "Middle" and camera.ViewportSize.Y / 2
                        or camera.ViewportSize.Y
                    esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.tracer.Visible = false
            end
        end
    end
end

-- Inicializar ESP para jogadores existentes
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createPlayerEsp(player)
    end
end

-- Detectar novos jogadores
Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createPlayerEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if cache[player] then
        for _, d in pairs(cache[player]) do
            d:Remove()
        end
        cache[player] = nil
    end
end)

-- Atualizar em tempo real
RunService.RenderStepped:Connect(updateEsp)

-- 🔧 Exemplo de uso (adicione seus objetos aqui)
table.insert(ObjectESPList, workspace:WaitForChild("Part"))
-- table.insert(ObjectESPList, workspace.CaixaSegredo)

return ESP_SETTINGS
