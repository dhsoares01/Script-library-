Script Library - UI + ESP para Roblox

Biblioteca Lua para criação rápida e personalizável de interfaces gráficas modernas (GUI) em Roblox, com sistema integrado de ESP 2D para destacar objetos no mundo do jogo.


---

Visão Geral

Este projeto é composto por duas bibliotecas principais:

Library.lua — Sistema modular para construção de menus, janelas e controles interativos.

LibraryESP.lua — Sistema 2D de ESP (Extra Sensory Perception), que desenha textos, caixas e linhas para evidenciar objetos no mundo.


O objetivo é facilitar a criação de scripts de exploração, cheats ou ferramentas de visualização para jogos Roblox, mantendo código limpo e modular.


---

Features

Library.lua (UI)

Criação de janelas customizadas com título, ícones e abas

Controles variados: Toggles, Sliders, Dropdowns, Buttons

Eventos para interação intuitiva

Design moderno, dark mode com cantos arredondados

Arrastar e redimensionar janelas

Scroll automático para listas longas

Posicionamento responsivo dos controles


LibraryESP.lua (ESP)

Desenho dinâmico baseado em Drawing API do Roblox

Elementos visuais: Caixa (box), Linha (tracer), Texto (nome e distância)

Configurações customizáveis por ESP (cores, visibilidade)

Atualização em tempo real com cálculo de posição e escala baseados na câmera

Suporte a BasePart e Model como alvo

Prevenção de vazamento de memória com remoção automática ao objeto sumir



---

Instalação

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Esp%20library.lua"))()


---

API Básica

Library.lua

Library:CreateWindow(title: string) -> Window Cria uma janela principal.

Window:CreateTab(name: string, icon: string) -> Tab Cria uma aba dentro da janela.

Tab:AddToggle(label: string, default: bool, callback: function) Adiciona um botão toggle com callback.

Tab:AddSlider(label: string, default: number, min: number, max: number, callback: function) Adiciona um slider para valores numéricos.

Tab:AddDropdown(label: string, options: table, callback: function) Adiciona uma dropdown.

Tab:AddButton(label: string, callback: function) Adiciona um botão simples.



---

LibraryESP.lua

ESP:CreateESP(object: Instance, options: table) -> ESPObject

Cria um ESP para o objeto especificado. As opções são:

Opção	Tipo	Descrição

Name	boolean	Exibe o nome do objeto
Distance	boolean	Exibe a distância da câmera
Tracer	boolean	Desenha uma linha da tela até o objeto
Box	boolean	Desenha uma caixa em volta do objeto
Color	Color3	Cor dos elementos do ESP


ESP:RemoveESP(object: Instance)

Remove o ESP associado ao objeto.

LibraryESP.TextPosition
Define a posição do texto relativo ao objeto ("Top", "Center", "Bottom", "Below", "LeftSide", "RightSide").

LibraryESP.LineFrom
Define a origem da linha tracer ("Top", "Center", "Bottom", "Below", "Left", "Right").



---

Exemplos Avançados

Atualizar ESP dinamicamente em um loop

local ESPStore = {}
local ESPSettings = {Tracer=true, Box=true, Distance=true, Name=true, Color=Color3.new(0,1,0)}

game:GetService("RunService").RenderStepped:Connect(function()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and not ESPStore[obj] then
            ESPStore[obj] = ESP:CreateESP(obj, ESPSettings)
        end
    end

    -- Limpar objetos removidos
    for obj, esp in pairs(ESPStore) do
        if not obj or not obj:IsDescendantOf(workspace) then
            ESP:RemoveESP(obj)
            ESPStore[obj] = nil
        end
    end
end)


---

Integrando com a UI

local Window = Library:CreateWindow("Meu Menu")
local Tab = Window:CreateTab("Visual", "")

local ESPStore = {}
local ESPSettings = {Tracer=false, Box=false, Distance=false, Name=false, Color=Color3.new(1,0,0)}

Tab:AddToggle("Ativar ESP", false, function(enabled)
    if enabled then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") then
                ESPStore[obj] = ESP:CreateESP(obj, ESPSettings)
            end
        end
    else
        for obj, _ in pairs(ESPStore) do
            ESP:RemoveESP(obj)
            ESPStore[obj] = nil
        end
    end
end)

Tab:AddToggle("Mostrar Nome", false, function(value)
    ESPSettings.Name = value
    for obj, esp in pairs(ESPStore) do
        esp.NameText.Visible = value
    end
end)

Tab:AddSlider("Tamanho da Caixa", 13, 5, 30, function(value)
    for obj, esp in pairs(ESPStore) do
        if esp.Box then
            esp.Box.Thickness = value / 5
        end
    end
end)


---

Dicas e Cuidados

Sempre remova ESPs de objetos que foram destruídos para evitar vazamento de memória.

Use RenderStepped para atualizar dinamicamente o ESP com base na câmera e posições.

Ajuste a escala e posições do texto para melhor legibilidade conforme o FOV do jogo.

Utilize cores contrastantes para destacar objetos importantes.

Evite criar ESPs para centenas de objetos simultaneamente para não impactar performance.

Teste em diferentes resoluções e modos de tela.



---

Possíveis Usos

Scripts para jogos como DOORS, Jailbreak, Arsenal, etc.

Ferramentas de exploração e debugging para mapas complexos.

Modificações visuais para melhorar percepção espacial.

Ferramentas para speedrunning e assistências visuais.



---

FAQ

Q: Posso usar essas bibliotecas para qualquer jogo Roblox?
A: Sim, desde que os objetos tenham BasePart ou Model com partes acessíveis.

Q: Como faço para mudar a cor do ESP?
A: Passe a propriedade Color nas opções ao criar o ESP (ex: Color3.fromRGB(255,0,0)).

Q: O ESP funciona em dispositivos móveis?
A: O Drawing API tem limitações em algumas plataformas. Teste para confirmar.

Q: É seguro usar em jogos online?
A: Depende das regras do jogo e dos termos da Roblox. Use com responsabilidade.


---

Changelog

v1.0 — Lançamento inicial com UI básica e ESP 2D funcional.

v1.1 — Melhorias na performance, suporte a múltiplos tipos de textos e linhas.

v1.2 — Adicionado suporte a posições customizadas de texto e linha.

v1.3 — Corrigidos bugs de remoção e atualização dinâmica.



---

Contato

Criador: dhsoares01

Repositório e issues: https://github.com/dhsoares01/Script-library-

Feedbacks e sugestões são muito bem-vindos!



---
