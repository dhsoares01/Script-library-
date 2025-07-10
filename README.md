# Custom Executor GUI Menu Library

Uma biblioteca Lua para criar menus de executores customizados no Roblox, com suporte a múltiplas abas, drag & drop, resize, sliders, toggles, dropdowns e muito mais. Inspirada no visual e experiência de executores como Delta, Via e outros, ideal para ser usada via `loadstring` em scripts de execução.

## Recursos

- Interface moderna e escura (dark theme)
- Sistema de abas com fácil navegação
- Drag & drop e redimensionamento do menu
- Minimizar/restaurar a janela
- Abas com ícones (opcional)
- Suporte a Label, Botão, Toggle, Dropdown de seleção, Dropdown multi-toggle, Slider
- Fácil integração com scripts de execução (Delta, Via, etc)
- Design responsivo e intuitivo

## Instalação

Recomenda-se utilizar via `loadstring` diretamente do seu repositório/raw:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()
```

> **Nota:** Substitua a URL pelo link raw do seu script.

## Exemplo de Uso

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local win = Library:CreateWindow("Meu Executor Custom")

local mainTab = win:CreateTab("Principal", "⭐")
mainTab:AddLabel("Bem-vindo ao Executor!")

mainTab:AddButton("Clique Aqui", function()
    print("Botão pressionado!")
end)

local myToggle = mainTab:AddToggle("Ativar Função", function(state)
    print("Toggle está:", state and "Ligado" or "Desligado")
end)

mainTab:AddSlider("Volume", 0, 100, 50, function(value)
    print("Volume ajustado para:", value)
end)

mainTab:AddSelectDropdown("Escolha uma opção", {"A", "B", "C"}, function(selected)
    print("Você selecionou:", selected)
end)

mainTab:AddDropdownButtonOnOff("Módulos", {"ESP", "Aimbot", "AutoFarm"}, function(states)
    print("Estados dos módulos:", states)
end)
```

## API

### `Library:CreateWindow(title)`

Cria uma nova janela de menu.

- `title` _(string)_: Nome do menu.

**Retorna:** Um objeto `window` com métodos para criar abas.

---

### `window:CreateTab(tabName, icon)`

Cria uma nova aba.

- `tabName` _(string)_: Nome da aba.
- `icon` _(string|nil)_: (Opcional) Ícone em Unicode/Emoji.

**Retorna:** Um objeto `tab`.

---

#### Métodos do `tab`:

##### `tab:AddLabel(text)`
Adiciona um label de texto.

##### `tab:AddButton(text, callback)`
Adiciona um botão.

##### `tab:AddToggle(text, callback)`
Adiciona um botão de liga/desliga.
- `callback(state)` recebe um boolean.

##### `tab:AddDropdownButtonOnOff(title, items, callback)`
Adiciona um dropdown múltiplo, cada item é toggle ON/OFF.
- `callback(states)` recebe uma tabela `{[item] = true/false}`.

##### `tab:AddSelectDropdown(title, items, callback)`
Adiciona um dropdown para seleção única.
- `callback(selected)` recebe o item escolhido.

##### `tab:AddSlider(text, min, max, default, callback)`
Adiciona um slider.
- `callback(value)` recebe o valor atual.

---

## Personalização Visual

O tema pode ser alterado editando a tabela `theme` no início do arquivo. Cores e estilos são facilmente customizáveis.

## Dicas

- O menu pode ser arrastado e redimensionado pelo usuário.
- O botão de minimizar esconde o conteúdo, deixando apenas o título visível.
- Todos os elementos são criados dinamicamente, permitindo adicionar/remover abas e conteúdos conforme necessário.

## Compatibilidade

- **Roblox LuaU** (compatível com exploits/executores como Delta, Via, Synapse, etc)
- Não requer dependências externas.

## Licença

MIT License

---

**Autor:** [dhsoares01]

**Contribua ou reporte bugs via issues/pull requests!**
