-- ESP.lua
-- Biblioteca simples de ESP para Roblox
-- Permite criar ESP com linha, caixa, nome, distância e cor customizável
-- Alvo via objeto BasePart (ex: HumanoidRootPart)

local ESP = {}
ESP.__index = ESP

-- Serviços usados
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

-- Configurações padrão
ESP.Settings = {
    Enabled = true,
    ShowLine = true,
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ESPColor = Color3.fromRGB(0, 255, 0),
}

-- Tabela para armazenar dados ESP por BasePart alvo
ESP.Objects = {}

-- Função para criar um objeto Drawing.Line
local function CreateLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = ESP.Settings.ESPColor
    line.Thickness = 1.5
    return line
end

-- Função para criar um objeto Drawing.Square (caixa)
local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Settings.ESPColor
    box.Thickness = 2
    box.Filled = false
    return box
end

-- Função para criar um objeto Drawing.Text
local function CreateText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = ESP.Settings.ESPColor
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Font = 2
    return text
end

-- Cria os objetos ESP para um alvo BasePart
local function CreateESPObjects(target)
    local data = {
        Line = CreateLine(),
        Box = CreateBox(),
        Name = CreateText(),
        Distance = CreateText(),
        Target = target
    }
    ESP.Objects[target] = data
end

-- Remove os objetos ESP de um alvo BasePart
local function RemoveESPObjects(target)
    local data = ESP.Objects[target]
    if data then
        data.Line:Remove()
        data.Box:Remove()
        data.Name:Remove()
        data.Distance:Remove()
        ESP.Objects[target] = nil
    end
end

-- Atualiza a posição e visibilidade dos objetos ESP para um alvo BasePart
local function UpdateESPFor(target)
    local data = ESP.Objects[target]
    if not data then return end
    local cam = Camera
    local pos3D = target.Position

    local screenPos, onScreen = cam:WorldToViewportPoint(pos3D)
    if not onScreen then
        data.Line.Visible = false
        data.Box.Visible = false
        data.Name.Visible = false
        data.Distance.Visible = false
        return
    end

    local color = ESP.Settings.ESPColor
    data.Line.Color = color
    data.Box.Color = color
    data.Name.Color = color
    data.Distance.Color = color

    if ESP.Settings.ShowLine then
        data.Line.Visible = true
        data.Line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
    else
        data.Line.Visible = false
    end

    if ESP.Settings.ShowBox then
        data.Box.Visible = true
        local boxSize = Vector2.new(50, 50)
        data.Box.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
        data.Box.Size = boxSize
    else
        data.Box.Visible = false
    end

    if ESP.Settings.ShowName then
        data.Name.Visible = true
        data.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
        local plr = Players:GetPlayerFromCharacter(target.Parent)
        data.Name.Text = plr and plr.Name or target.Name or "Object"
    else
        data.Name.Visible = false
    end

    if ESP.Settings.ShowDistance then
        data.Distance.Visible = true
        local dist = (cam.CFrame.Position - pos3D).Magnitude
        data.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
        data.Distance.Text = string.format("%.1f studs", dist)
    else
        data.Distance.Visible = false
    end
end

-- Atualiza todos ESPs
function ESP:Update()
    if not self.Settings.Enabled then
        for _, data in pairs(self.Objects) do
            data.Line.Visible = false
            data.Box.Visible = false
            data.Name.Visible = false
            data.Distance.Visible = false
        end
        return
    end

    for target, _ in pairs(self.Objects) do
        if target and target.Parent then
            UpdateESPFor(target)
        else
            RemoveESPObjects(target)
        end
    end
end

-- Adiciona um alvo BasePart para ESP
function ESP:Add(target)
    if not target or not target:IsA("BasePart") then
        warn("ESP: alvo deve ser BasePart válido")
        return
    end
    if not self.Objects[target] then
        CreateESPObjects(target)
    end
end

-- Remove um alvo BasePart da ESP
function ESP:Remove(target)
    RemoveESPObjects(target)
end

-- Remove todos alvos ESP
function ESP:Clear()
    for target, _ in pairs(self.Objects) do
        RemoveESPObjects(target)
    end
end

-- Configurações
function ESP:SetEnabled(value)
    self.Settings.Enabled = value
    if not value then
        self:Clear()
    end
end
function ESP:SetShowLine(value) self.Settings.ShowLine = value end
function ESP:SetShowBox(value) self.Settings.ShowBox = value end
function ESP:SetShowName(value) self.Settings.ShowName = value end
function ESP:SetShowDistance(value) self.Settings.ShowDistance = value end
function ESP:SetColor(color3) self.Settings.ESPColor = color3 end

-- Loop de atualização ligado
RunService.RenderStepped:Connect(function()
    ESP:Update()
end)

return ESP
