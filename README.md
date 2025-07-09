
```
markdown
# 📚 Script GUI Menu Library

![Library Preview](https://via.placeholder.com/800x400/2d3748/ffffff?text=Script+GUI+Menu+Library+Preview)  
*(Adicione uma imagem real da sua biblioteca aqui)*

Uma biblioteca de interface gráfica (GUI) em Lua projetada para executores de scripts Roblox como Delta, Fluxus e outros. Crie menus interativos com facilidade e estilo profissional.

## ✨ Recursos Principais

### 🎨 Design Moderno
- Tema escuro com cantos arredondados
- Interface limpa e profissional
- Totalmente responsiva

### 🖱️ Interatividade Avançada
- ✅ Arrastar e mover janelas
- ↔️ Redimensionamento dinâmico
- 📌 Minimizar/Restaurar
- 🔄 Animações suaves

### 🧩 Componentes Ricos
| Componente            | Descrição                                      |
|-----------------------|-----------------------------------------------|
| **Label**             | Texto informativo                             |
| **Button**            | Botões clicáveis com ações personalizadas     |
| **Toggle**            | Interruptores ON/OFF                          |
| **DropdownButtonOnOff**| Menu expansível com múltiplas opções         |
| **SelectDropdown**    | Seleção única em lista expansível             |
| **Slider**           | Controle deslizante para valores numéricos    |

## 🚀 Começando

### 📥 Instalação
```
lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
```

### 🧑‍💻 Exemplo Básico
```
lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()

local MyMenu = Library:CreateWindow("Meu Menu Personalizado")
local MainTab = MyMenu:CreateTab("Principal", "⭐")

-- Adicionando componentes
MainTab:AddLabel("Configurações Gerais:")

MainTab:AddButton("Resetar Personagem", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
    print("Personagem resetado!")
end)

local toggle = MainTab:AddToggle("Voar", function(state)
    print("Modo voo:", state and "ATIVADO" or "DESATIVADO")
end)

MainTab:AddSlider("Velocidade", 10, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

## 📚 Documentação da API

### `Library`
| Método               | Parâmetros                          | Descrição                |
|----------------------|------------------------------------|--------------------------|
| `CreateWindow`       | `name` (string)                    | Cria nova janela GUI     |

### `Window`
| Método               | Parâmetros                          | Descrição                |
|----------------------|------------------------------------|--------------------------|
| `CreateTab`          | `name` (string), `icon` (optional) | Adiciona nova aba        |

### `Tab`
| Método                     | Parâmetros                                      | Retorno       |
|----------------------------|------------------------------------------------|---------------|
| `AddLabel`                | `text` (string)                                | -             |
| `AddButton`               | `text` (string), `callback` (function)         | -             |
| `AddToggle`               | `text` (string), `callback` (function)         | Toggle object |
| `AddDropdownButtonOnOff`  | `title` (string), `items` (table), `callback`  | Dropdown obj  |
| `AddSelectDropdown`       | `title` (string), `items` (table), `callback`  | Dropdown obj  |
| `AddSlider`               | `text`, `min`, `max`, `default`, `callback`    | Slider obj    |

## 🛠️ Estrutura Técnica
- **Arquitetura**: Single-file library
- **Dependências**: Roblox engine services
- **Performance**: Otimizada para carregamento rápido
- **Animations**: TweenService para transições suaves

## 🤝 Contribuição
Contribuições são bem-vindas! Siga estes passos:
1. Fork o repositório
2. Crie um branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para o branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença
Distribuído sob licença MIT. Veja `LICENSE` para mais informações.

---

<div align="center">
  <p>Feito com ❤️ por <a href="https://github.com/dhsoares01">dhsoares01</a></p>
  <img src="https://img.shields.io/github/stars/dhsoares01/Script-library-?style=social" alt="GitHub stars">
</div>
```
