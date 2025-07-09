---

🎮 Script GUI Menu Library

> Biblioteca para criação rápida e moderna de menus no Roblox, ideal para executores como Delta, Fluxus e outros.




---

📦 Instalação

Adicione esta linha ao início do seu script Roblox:

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()


---

✨ Funcionalidades Principais

🎨 Design Moderno: Tema escuro elegante com cantos arredondados.

🖱 Interatividade Completa:

Arrastar a janela

Redimensionar dinamicamente

Minimizar/restaurar


🧩 Sistema de Abas: Organização intuitiva.

🛠 Controles Disponíveis:

Label – Exibe texto

Button – Executa funções

Toggle – Liga/desliga recursos

DropdownButtonOnOff – Menu para múltiplas opções ON/OFF

SelectDropdown – Seleção única

Slider – Ajusta valores numéricos


⚡ Leve e compatível: Ideal para loadstring em vários executores.



---

🚀 Exemplo de Uso Rápido

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

-- Cria a janela principal
local MyMenu = Library:CreateWindow("Meu Script Cheats")

-- Aba principal
local MainOptions = MyMenu:CreateTab("Geral", "⭐")

-- Label
MainOptions:AddLabel("Opções Rápidas:")

-- Botão
MainOptions:AddButton("Resetar Personagem", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
    warn("Personagem resetado!")
end)

-- Toggle
local noClipToggle = MainOptions:AddToggle("NoClip", function(state)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
    print("NoClip: " .. (state and "ATIVADO" or "DESATIVADO"))
end)

-- Slider
MainOptions:AddSlider("Jump Power", 10, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    print("Jump Power definido para: " .. value)
end)

print("Menu carregado com sucesso!")


---

🧰 API Completa

📦 Library:CreateWindow(name: string)

Cria uma nova janela GUI.

name: Título (opcional). Padrão: "CustomUILib".

Retorna: window (objeto)



---

🗂 Métodos do window

➕ window:CreateTab(tabName: string, icon: string?)

Cria uma aba.

tabName: Nome da aba

icon: (opcional) Emoji ou caractere

Retorna: tab (objeto)



---

🛠 Métodos do tab

🏷 tab:AddLabel(text: string)

Adiciona um label.

🔘 tab:AddButton(text: string, callback: function)

Botão clicável.

✅ tab:AddToggle(text: string, callback: function(state: boolean))

Toggle ON/OFF.

Retorna:

Set(value: boolean)

Get()



📥 tab:AddDropdownButtonOnOff(title: string, items: table, callback: function(states: table))

Dropdown com múltiplas opções ON/OFF.

Retorna:

Set(item: string, value: boolean)

GetAll()



☑ tab:AddSelectDropdown(title: string, items: table, callback: function(selectedItem: string))

Dropdown seleção única.

Retorna:

Set(item: string)

Get()



🎚 tab:AddSlider(text: string, min, max, default, callback)

Slider numérico.

Retorna:

Set(value: number)

Get()




---

⚙️ Desenvolvimento

Código inteiro em um único arquivo .lua.

Layout automático usando UIListLayout.

Transições com TweenService.

Drag & resize usando UserInputService.



---

🤝 Contribuição

Abra uma Issue para bugs ou sugestões.

Faça um Pull Request seguindo o estilo do código.



---

📄 Licença

Distribuído sob a Licença MIT.


---
