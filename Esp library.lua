--// LibraryESP.lua

-- Referências importantes para câmera, jogadores, atualização por frame e jogador local
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tabela principal que conterá todas as funções da LibraryESP
local LibraryESP = {}

-- Tabela que armazenará todos os ESPs ativos criados
local ESPObjects = {}

--// Configurações globais para a posição do texto e origem da linha (tracer)
LibraryESP.TextPosition = "Top"    -- Opções: Top, Center, Bottom, Below, LeftSide, RightSide
LibraryESP.LineFrom = "Bottom"     -- Opções: Top, Center, Bottom, Below, Left, Right

--// Função para criar um texto com as configurações básicas do ESP
local function DrawText(size, color)
    local text = Drawing.new("Text") -- Cria um novo objeto de texto
    text.Size = size                 -- Define o tamanho do texto
    text.Center = true              -- Centraliza o texto na posição definida
    text.Outline = true             -- Habilita contorno para melhor leitura
    text.Font = 2                   -- Define a fonte do texto (2 = fonte padrão Roblox)
    text.Color = color              -- Cor do texto
    text.Visible = false            -- Inicialmente invisível, só aparece quando atualizado
    return text                    -- Retorna o objeto texto para uso
end

--// Função para criar uma linha (tracer) com configurações básicas
local function DrawLine(color)
    local line = Drawing.new("Line") -- Cria um novo objeto de linha
    line.Thickness = 1.5            -- Espessura da linha
    line.Color = color              -- Cor da linha
    line.Visible = false            -- Inicialmente invisível
    return line                    -- Retorna o objeto linha para uso
end

--// Função para criar uma caixa (box) com configurações básicas
local function DrawBox(color)
    local box = Drawing.new("Square") -- Cria um objeto de quadrado
    box.Thickness = 1               -- Espessura da borda da caixa
    box.Color = color               -- Cor da caixa
    box.Filled = false              -- Caixa não preenchida (só contorno)
    box.Visible = false             -- Inicialmente invisível
    return box                     -- Retorna o objeto caixa para uso
end

--// Função que cria um ESP para um objeto com as opções definidas
function LibraryESP:CreateESP(object, options)
    -- Cria uma tabela ESP que armazena o objeto, opções e os elementos visuais (texto, linha, caixa)
    local esp = {
        Object = object,
        Options = options,
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,           -- Texto do nome
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,   -- Texto da distância
        TracerLine = options.Tracer and DrawLine(options.Color or Color3.new(1, 1, 1)) or nil,           -- Linha do tracer
        Box = options.Box and DrawBox(options.Color or Color3.new(1, 1, 1)) or nil                        -- Caixa ao redor do objeto
    }

    -- Insere o ESP criado na lista de ESPs ativos
    table.insert(ESPObjects, esp)
    return esp -- Retorna o ESP criado para manipulação futura, se necessário
end

--// Função para remover ESPs de um objeto (ou todos se nil)
function LibraryESP:RemoveESP(object)
    -- Itera de trás para frente para remover ESPs com segurança durante a iteração
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.Object == object or object == nil then -- Se o objeto for o alvo ou nenhum especificado (remove tudo)
            -- Remove os elementos gráficos visuais do ESP
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            -- Remove o ESP da lista ativa
            table.remove(ESPObjects, i)
        end
    end
end

--// Função que calcula a posição do texto baseado no ponto base e no tipo de offset desejado
local function getTextPosition(basePos, offsetType)
    local offset = Vector2.new(0, 0) -- Inicializa offset neutro

    -- Define o offset com base na posição configurada
    if offsetType == "Top" then
        offset = Vector2.new(0, -16)
    elseif offsetType == "Center" then
        offset = Vector2.new(0, 0)
    elseif offsetType == "Bottom" then
        offset = Vector2.new(0, 16)
    elseif offsetType == "Below" then
        offset = Vector2.new(0, 26)
    elseif offsetType == "LeftSide" then
        offset = Vector2.new(-40, 0)
    elseif offsetType == "RightSide" then
        offset = Vector2.new(40, 0)
    end

    -- Retorna a posição base somada ao offset, para posicionar o texto corretamente
    return basePos + offset
end

--// Loop que atualiza o ESP a cada frame renderizado
RunService.RenderStepped:Connect(function()
    -- Percorre todos os ESPs criados
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        local obj = esp.Object

        -- Verifica se o objeto ainda é válido e está na workspace
        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then
            -- Remove ESPs de objetos inválidos para limpar a lista
            if esp.NameText then esp.NameText:Remove() end
            if esp.DistanceText then esp.DistanceText:Remove() end
            if esp.TracerLine then esp.TracerLine:Remove() end
            if esp.Box then esp.Box:Remove() end
            table.remove(ESPObjects, i)

        else
            -- Converte a posição 3D do objeto para coordenadas 2D da tela
            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            local basePos = Vector2.new(pos.X, pos.Y)

            -- Se o objeto está visível na tela
            if onScreen then
                -- Calcula a distância entre câmera e objeto para escalar elementos visuais
                local distance = (Camera.CFrame.Position - obj.Position).Magnitude

                -- Atualiza o texto do nome do objeto e sua posição
                if esp.NameText then
                    esp.NameText.Position = getTextPosition(basePos, LibraryESP.TextPosition)
                    esp.NameText.Text = tostring(obj.Name)
                    esp.NameText.Visible = true
                end

                -- Atualiza o texto da distância e sua posição um pouco abaixo do nome
                if esp.DistanceText then
                    esp.DistanceText.Position = getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 14)
                    esp.DistanceText.Text = string.format("[%dm]", math.floor(distance))
                    esp.DistanceText.Visible = true
                end

                -- Atualiza a posição da linha tracer baseado na configuração LineFrom
                if esp.TracerLine then
                    local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Padrão: inferior centro

                    -- Ajusta origem da linha conforme configuração
                    if LibraryESP.LineFrom == "Top" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    elseif LibraryESP.LineFrom == "Center" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Below" then
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.25)
                    elseif LibraryESP.LineFrom == "Left" then
                        from = Vector2.new(0, Camera.ViewportSize.Y / 2)
                    elseif LibraryESP.LineFrom == "Right" then
                        from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)
                    end

                    -- Define o início e fim da linha e torna visível
                    esp.TracerLine.From = from
                    esp.TracerLine.To = basePos
                    esp.TracerLine.Visible = true
                end

                -- Atualiza a caixa ao redor do objeto, escalando pelo tamanho/distância
                if esp.Box then
                    local size = 30 / (distance / 10) -- Ajusta tamanho com base na distância
                    esp.Box.Size = Vector2.new(size, size * 1.5) -- Caixa mais alta que larga
                    esp.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - size * 0.75) -- Centraliza caixa no objeto
                    esp.Box.Visible = true
                end

            else
                -- Se o objeto não está na tela, esconde todos os elementos visuais
                if esp.NameText then esp.NameText.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                if esp.TracerLine then esp.TracerLine.Visible = false end
                if esp.Box then esp.Box.Visible = false end
            end
        end
    end
end)

-- Retorna a tabela principal para uso externo
return LibraryESP
