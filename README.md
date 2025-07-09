# 🎛️ Script GUI Menu Library

---

## 📖 Sobre a Biblioteca

Biblioteca de interface gráfica (GUI) em **Lua**, projetada para executores de scripts Roblox como **Delta**, **Fluxus** e outros. Facilita a criação de menus interativos, modernos e responsivos, para que você foque na lógica do seu script enquanto a biblioteca gerencia a interface.

---

## ✨ Funcionalidades Principais

- **Design Sofisticado:** Tema escuro com cantos arredondados para uma experiência profissional e agradável.
- **Interatividade Completa:**
  - **Arrastar:** Mova a janela pela tela facilmente.
  - **Redimensionar:** Ajuste o tamanho da janela pelo canto inferior direito.
  - **Minimizar/Restaurar:** Controle a visibilidade da janela com um clique.
- **Organização Lógica:** Sistema de abas para categorizar opções.
- **Controles Abrangentes:**
  - `Label`: Texto informativo.
  - `Button`: Executa funções customizadas.
  - `Toggle`: Ativa/desativa recursos (ON/OFF).
  - `DropdownButtonOnOff`: Menu expansível com múltiplas opções independentes.
  - `SelectDropdown`: Seleção única em lista expansível.
  - `Slider`: Ajusta valores numéricos com feedback instantâneo.
- **Compatibilidade Ampla:** Leve e eficiente, ideal para carregamento via `loadstring`.

---

## 🚀 Instalação e Uso Rápido

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()


---

🛠️ Exemplo Rápido

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local MyMenu = Library:CreateWindow("Meu Script Cheats")
local MainOptions = MyMenu:CreateTab("Geral", "⭐")

MainOptions:AddLabel("Opções Rápidas:")

MainOptions:AddButton("Resetar Personagem", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
    warn("Personagem resetado!")
end)

local noClipToggle = MainOptions:AddToggle("NoClip", function(state)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
    print("NoClip está: " .. (state and "ATIVADO" or "DESATIVADO"))
end)

MainOptions:AddSlider("Jump Power", 10, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    print("Jump Power definido para: " .. value)
end)

print("Menu carregado com sucesso!")


---

📚 API (Interface de Programação de Aplicações)

Library

Método	Parâmetros	Descrição	Retorno

CreateWindow(name)	name: string	Cria e retorna uma janela GUI	objeto window


Window (objeto retornado)

Método	Parâmetros	Descrição	Retorno

CreateTab(tabName, icon?)	tabName: string, icon?: string	Cria uma aba dentro da janela	objeto tab


Tab (objeto retornado)

Método	Parâmetros	Descrição	Retorno

AddLabel(text)	text: string	Adiciona texto informativo	—
AddButton(text, callback)	text: string, callback: function	Adiciona botão clicável	—
AddToggle(text, callback)	text: string, callback: function(state: boolean)	Botão ON/OFF. Retorna objeto com .Set(), .Get()	objeto toggle
AddDropdownButtonOnOff(title, items, callback)	title: string, items: table, callback: function(states: table)	Menu expansível multi-toggle. Retorna objeto com .Set(), .GetAll()	objeto dropdown multi-toggle
AddSelectDropdown(title, items, callback)	title: string, items: table, callback: function(selectedItem: string)	Menu expansível single-select. Retorna objeto com .Set(), .Get()	objeto dropdown single-select
AddSlider(text, min, max, default, callback)	text: string, min: number, max: number, default: number, callback: function(value: number)	Slider numérico. Retorna objeto com .Set(), .Get()	objeto slider



---

🛠️ Desenvolvimento

Código contido em um único arquivo .lua.

Layouts e tamanhos gerenciados via UDim2 e UIListLayout.

Usa TweenService para animações suaves.

Usa UserInputService para funcionalidades de arrastar e redimensionar.



---

🤝 Contribuição

Contribuições são bem-vindas!

Abra uma Issue para bugs ou sugestões.

Crie um Pull Request com melhorias, seguindo o estilo do código.



---

📄 Licença

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo LICENSE no repositório para detalhes.


---
