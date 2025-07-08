-- example.lua

-- Carrega a Library (assumindo que esteja no mesmo diretório ou no caminho correto)
local Library = require(game.ReplicatedStorage.Library) -- substitua pelo caminho correto do módulo

local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- Exemplo de como você usaria a biblioteca
local window = Library:CreateWindow("Meu Menu Incrível")

local mainTab = window:CreateTab("Principal", "⚙") -- Ícone de engrenagem
local combatTab = window:CreateTab("Combate", "⚔") -- Ícone de espadas
local playerTab = window:CreateTab("Jogador", "👤") -- Ícone de pessoa

mainTab:AddLabel("Bem-vindo ao menu aprimorado!")

mainTab:AddButton("Clique-me!", function()
    print("Botão Principal Clicado!")
end)

local myToggle = mainTab:AddToggle("Recurso Legal", function(state)
    print("Recurso Legal está agora: " .. (state and "ATIVADO" or "DESATIVADO"))
end)
myToggle:Set(true) -- Define o estado inicial

local mySlider = mainTab:AddSlider("Velocidade", 10, 100, 50, function(value)
    print("Velocidade definida para: " .. value)
end)

combatTab:AddLabel("Configurações de Combate:")

local abilitiesDropdown = combatTab:AddDropdownButtonOnOff("Habilidades", {"Dash", "Invisibilidade", "Curar", "Escudo"}, function(states)
    print("Estados das Habilidades:", states)
end)

combatTab:AddButton("Ativar Auto-Aim", function()
    print("Auto-Aim Ativado!")
end)

playerTab:AddLabel("Opções do Jogador:")
playerTab:AddToggle("Noclip", function(state)
    print("Noclip: " .. (state and "ON" or "OFF"))
end)
playerTab:AddSlider("Poder de Pulo", 50, 150, 100, function(value)
    print("Poder de Pulo: " .. value)
end)

-- Você pode chamar as funções Set/Get dos elementos de UI
-- myToggle:Set(false)
-- local currentSpeed = mySlider:Get()

-- Exemplo de uso para ESP, se você ainda precisar
-- (Nota: O código ESP original precisa ser refatorado para usar a nova estrutura da sua UI
-- se você quiser controlar as opções de ESP através deste menu.)

-- Configurações globais do ESP (estas ainda seriam definidas fora da UI se fossem globais)
-- LibraryESP.TextPosition = "Top" -- Se você tiver uma biblioteca ESP separada
-- LibraryESP.LineFrom = "Bottom"

-- Tabela para armazenar ESP criados para cada objeto
local espTable = {}

-- Função para criar ESP para todas as partes específicas no workspace
local function CreateESPForParts()
    -- Este é um exemplo de como você integraria seu sistema ESP.
    -- O 'LibraryESP' é um módulo separado.
    -- Certifique-se de que ele esteja disponível e funcional.
    
    -- Exemplo: Se você tiver um módulo `LibraryESP` no `ReplicatedStorage`
    local LibraryESP = game.ReplicatedStorage:FindFirstChild("LibraryESP") 
    if not LibraryESP then 
        warn("LibraryESP module not found!")
        return 
    end

    -- Remove todos os ESP anteriores (limpeza)
    for _, esp in pairs(espTable) do
        LibraryESP:RemoveESP(esp.Object)
    end
    espTable = {}

    -- Procura por todas as partes chamadas "Part" no workspace (exemplo)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Part" then
            -- Cria ESP para o objeto com opções desejadas
            local esp = LibraryESP:CreateESP(obj, {
                Name = true,
                Distance = true,
                Tracer = true,
                Box = true,
                Color = Color3.new(0, 1, 0) -- verde
            })
            table.insert(espTable, esp)
        end
    end
end

-- Você pode adicionar um botão no seu menu para ativar/desativar o ESP
combatTab:AddButton("Alternar ESP para 'Part'", function()
    -- Alternar a funcionalidade ESP aqui
    -- Por exemplo, você pode ter uma variável global para rastrear se o ESP está ativo
    -- e chamar CreateESPForParts ou remover ESPs existentes.
    print("Alternando ESP para 'Part'...")
    -- Exemplo simples:
    -- if not espEnabled then
    --     CreateESPForParts()
    --     espEnabled = true
    -- else
    --     for _, esp in pairs(espTable) do
    --         LibraryESP:RemoveESP(esp.Object)
    --     end
    --     espTable = {}
    --     espEnabled = false
    -- end
    CreateESPForParts() -- Apenas recria o ESP para demonstração
end)

