-- ESPDesign.lua
local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local drawingLines = {}
local espBoxes = {}
local conexao = nil

-- Função para criar linha
local function criarLinha2D(obj, cor)
    local linha = Drawing.new("Line")
    linha.Color = cor or Color3.fromRGB(0, 255, 0)
    linha.Thickness = 2.5
    linha.Transparency = 0.95
    linha.Visible = true
    drawingLines[obj] = linha
end

-- Atualiza linha com fade por distância
local function atualizarLinha2D(obj, maxDist)
    local linha = drawingLines[obj]
    if not linha then return end

    local dist = (camera.CFrame.Position - obj.Position).Magnitude
    local pos, onScreen = camera:WorldToViewportPoint(obj.Position)

    if onScreen and dist <= (maxDist or 200) then
        linha.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        linha.To = Vector2.new(pos.X, pos.Y)
        linha.Transparency = math.clamp(1 - (dist / (maxDist or 200)), 0.1, 1)
        linha.Visible = true
    else
        linha.Visible = false
    end
end

-- Cria box
local function criarESPBox(obj, cor)
    if espBoxes[obj] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = obj
    box.Size = obj.Size
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Color3 = cor or Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.6
    box.Parent = obj
    espBoxes[obj] = box
end

-- Remove todas linhas e boxes
local function removerTudo()
    for obj, linha in pairs(drawingLines) do
        if linha then linha:Remove() end
    end
    drawingLines = {}

    for obj, box in pairs(espBoxes) do
        if box and box.Parent then
            box:Destroy()
        end
    end
    espBoxes = {}
end

-- Ativa ESP em lista de objetos
function ESP:Ativar(objList, cor)
    if conexao then conexao:Disconnect() end
    removerTudo()

    for _, obj in pairs(objList) do
        if obj and obj:IsA("BasePart") then
            criarLinha2D(obj, cor)
            criarESPBox(obj, cor)
        end
    end

    conexao = RunService.RenderStepped:Connect(function()
        for _, obj in pairs(objList) do
            if obj and obj:IsA("BasePart") then
                atualizarLinha2D(obj, 200)
            end
        end
    end)
end

-- Desativa ESP
function ESP:Desativar()
    if conexao then
        conexao:Disconnect()
        conexao = nil
    end
    removerTudo()
end

return ESP
