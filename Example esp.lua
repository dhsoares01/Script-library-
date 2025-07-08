-- example.lua

-- Carrega a LibraryESP (assumindo que esteja no mesmo diretório ou no caminho correto)
local LibraryESP = require(path.to.LibraryESP) -- substitua pelo caminho correto do módulo

local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- Configurações globais do ESP
LibraryESP.TextPosition = "Top"
LibraryESP.LineFrom = "Bottom"

-- Tabela para armazenar ESP criados para cada objeto
local espTable = {}

-- Função para criar ESP para todas as partes específicas no workspace
local function CreateESPForParts()
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

-- Cria ESP inicialmente
CreateESPForParts()

-- Atualiza ESP quando uma nova parte for adicionada (exemplo simples)
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("BasePart") and desc.Name == "Part" then
        local esp = LibraryESP:CreateESP(desc, {
            Name = true,
            Distance = true,
            Tracer = true,
            Box = true,
            Color = Color3.new(0, 1, 0)
        })
        table.insert(espTable, esp)
    end
end)

-- Exemplo para remover ESP se a parte for removida
workspace.DescendantRemoving:Connect(function(desc)
    if desc:IsA("BasePart") and desc.Name == "Part" then
        LibraryESP:RemoveESP(desc)
        for i = #espTable, 1, -1 do
            if espTable[i].Object == desc then
                table.remove(espTable, i)
            end
        end
    end
end)
