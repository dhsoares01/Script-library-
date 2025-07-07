local ESP = {}

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

ESP.Enabled = false
ESP.Color = Color3.fromRGB(0, 255, 0)
ESP.Objects = {} -- Tabela de objetos para ESP

-- Tabela para armazenar os objetos Drawing criados para cada objeto
local espDrawings = {}

-- Cria os desenhos para um objeto
local function createDrawings()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = ESP.Color
    line.Visible = false
    
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Color = ESP.Color
    box.Filled = false
    box.Visible = false
    
    return {
        Line = line,
        Box = box
    }
end

-- Função para atualizar a posição dos desenhos para um objeto
local function updateDrawings(obj, drawings)
    if not obj or not obj.Parent then
        -- Se o objeto sumiu da workspace, esconder desenhos
        drawings.Line.Visible = false
        drawings.Box.Visible = false
        return
    end
    
    local objPos = obj.Position or (obj:IsA("BasePart") and obj.Position) or nil
    if not objPos then
        drawings.Line.Visible = false
        drawings.Box.Visible = false
        return
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(objPos)
    
    if onScreen then
        local screenX, screenY = screenPos.X, screenPos.Y
        
        -- Linha do centro da tela até o objeto
        local centerX, centerY = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
        drawings.Line.From = Vector2.new(centerX, centerY)
        drawings.Line.To = Vector2.new(screenX, screenY)
        drawings.Line.Color = ESP.Color
        drawings.Line.Visible = true
        
        -- Caixa ao redor do objeto (simples, fixa um tamanho)
        local boxSize = 30
        drawings.Box.Size = Vector2.new(boxSize, boxSize)
        drawings.Box.Position = Vector2.new(screenX - boxSize/2, screenY - boxSize/2)
        drawings.Box.Color = ESP.Color
        drawings.Box.Visible = true
    else
        drawings.Line.Visible = false
        drawings.Box.Visible = false
    end
end

-- Atualiza todas as ESPs
local function onRenderStep()
    if not ESP.Enabled then
        -- Esconder tudo quando desabilitado
        for obj, drawings in pairs(espDrawings) do
            drawings.Line.Visible = false
            drawings.Box.Visible = false
        end
        return
    end
    
    for obj, drawings in pairs(espDrawings) do
        updateDrawings(obj, drawings)
    end
end

function ESP:SetColor(color)
    self.Color = color
    -- Atualiza a cor dos desenhos
    for _, drawings in pairs(espDrawings) do
        drawings.Line.Color = color
        drawings.Box.Color = color
    end
end

function ESP:AddObject(obj)
    if not obj or espDrawings[obj] then return end
    local drawings = createDrawings()
    espDrawings[obj] = drawings
    table.insert(self.Objects, obj)
end

function ESP:RemoveObject(obj)
    if not obj then return end
    if espDrawings[obj] then
        espDrawings[obj].Line:Remove()
        espDrawings[obj].Box:Remove()
        espDrawings[obj] = nil
    end
    for i, o in ipairs(self.Objects) do
        if o == obj then
            table.remove(self.Objects, i)
            break
        end
    end
end

function ESP:Clear()
    for obj, drawings in pairs(espDrawings) do
        drawings.Line:Remove()
        drawings.Box:Remove()
    end
    espDrawings = {}
    self.Objects = {}
end

function ESP:SetEnabled(state)
    self.Enabled = state
    if not state then
        -- Quando desligar, esconder tudo
        for obj, drawings in pairs(espDrawings) do
            drawings.Line.Visible = false
            drawings.Box.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(onRenderStep)

return ESP
