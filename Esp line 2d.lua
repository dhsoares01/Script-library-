local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local ESPLines = {}
local connections = {}
local espEnabled = false

local function createLine(entity)
    if ESPLines[entity] then return end

    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(0, 255, 0)
    line.Transparency = 1
    ESPLines[entity] = line

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not espEnabled or not entity or not entity:IsDescendantOf(workspace) then
            line.Visible = false
            if conn then conn:Disconnect() end
            line:Remove()
            ESPLines[entity] = nil
            return
        end

        local root = entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChild("Torso") or entity:FindFirstChild("UpperTorso")
        if root then
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            local centerScreen = camera.ViewportSize / 2
            if onScreen then
                line.From = Vector2.new(centerScreen.X, centerScreen.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end)

    connections[entity] = conn
end

local function enableESP()
    espEnabled = true
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            createLine(plr.Character)
        end
    end
end

local function disableESP()
    espEnabled = false
    for _, line in pairs(ESPLines) do
        if line then line:Remove() end
    end
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    ESPLines = {}
    connections = {}
end

-- Toggle exemplo (substitua pelo seu menu se quiser)
print("Use enableESP() para ligar e disableESP() para desligar")

-- Ative com enableESP()
-- Desative com disableESP()
