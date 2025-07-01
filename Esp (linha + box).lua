-- ESP.lua
local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local maxDist = 200

-- Guarda os objetos de ESP com suas cores
local espObjects = {} -- [obj] = cor

-- Guarda linhas e boxes
local drawingLines = {}
local espBoxes = {}

local conexao = nil

local function criarLinha2D(obj, cor)
    local linha = Drawing.new("Line")
    linha.Color = cor or Color3.fromRGB(0, 255, 0)
    linha.Thickness = 2.5
    linha.Transparency = 0.95
    linha.Visible = true
    drawingLines[obj] = linha
end

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

local function removerObjeto(obj)
    if drawingLines[obj] then
        drawingLines[obj]:Remove()
        drawingLines[obj] = nil
    end
    if espBoxes[obj] and espBoxes[obj].Parent then
        espBoxes[obj]:Destroy()
        espBoxes[obj] = nil
    end
    espObjects[obj] = nil
end

local function atualizarLinha2D(obj)
    local linha = drawingLines[obj]
    if not linha or not obj or not obj.Parent then
        removerObjeto(obj)
        return
    end

    local dist = (camera.CFrame.Position - obj.Position).Magnitude
    local pos, onScreen = camera:WorldToViewportPoint(obj.Position)

    if onScreen and dist <= maxDist then
        linha.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        linha.To = Vector2.new(pos.X, pos.Y)
        linha.Transparency = math.clamp(1 - (dist / maxDist), 0.1, 1)
        linha.Visible = true
    else
        linha.Visible = false
    end
end

function ESP:AtualizarLista(novaLista, cor)
    local novaSet = {}

    -- Adicionar e manter existentes
    for _, obj in pairs(novaLista) do
        if obj and obj:IsA("BasePart") then
            novaSet[obj] = true
            if not espObjects[obj] then
                espObjects[obj] = cor
                criarLinha2D(obj, cor)
                criarESPBox(obj, cor)
            end
        end
    end

    -- Remover objetos que sumiram
    for obj, _ in pairs(espObjects) do
        if not novaSet[obj] then
            removerObjeto(obj)
        end
    end
end

function ESP:Desativar()
    if conexao then
        conexao:Disconnect()
        conexao = nil
    end
    for obj, _ in pairs(espObjects) do
        removerObjeto(obj)
    end
    espObjects = {}
end

function ESP:Ativar()
    if conexao then return end
    conexao = RunService.RenderStepped:Connect(function()
        for obj, _ in pairs(espObjects) do
            atualizarLinha2D(obj)
        end
    end)
end

return ESP
