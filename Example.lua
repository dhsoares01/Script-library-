-- Exemplo de uso da CustomUILib
-- Carrega a biblioteca via loadstring
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()

-- Cria a janela principal com título
local Window = Library:CreateWindow("Minha Interface")

-- Cria uma aba chamada "Configurações"
local Tab = Window:CreateTab("Configurações", "⚙️")

-- Adiciona um toggle para ligar/desligar um recurso
Tab:AddToggle("Ativar Recurso", function(state)
    print("Toggle está", state and "Ligado" or "Desligado")
    -- Aqui você pode colocar a lógica para ativar/desativar algo
end)

-- Adiciona um slider para ajuste de volume de 0 a 100, começando em 50
Tab:AddSlider("Volume", 0, 100, 50, function(value)
    print("Volume ajustado para:", value)
    -- Ajuste o volume ou qualquer valor aqui
end)

-- Adiciona um botão que executa uma ação ao ser clicado
Tab:AddButton("Clique aqui", function()
    print("Botão clicado!")
    -- Coloque aqui a ação do botão
end)

-- Adiciona uma label informativa
Tab:AddLabel("Este é um texto informativo")

-- Exemplo para criar uma segunda aba (opcional)
local Tab2 = Window:CreateTab("Visual", "👁️")

Tab2:AddToggle("Ativar Fullbright", function(state)
    print("Fullbright está", state and "Ativado" or "Desativado")
    -- Lógica para fullbright pode ser colocada aqui
end)

Tab2:AddSlider("FOV", 10, 100, 50, function(value)
    print("FOV ajustado para:", value)
    -- Ajustar campo de visão aqui
end)
