# Roblox UI Menu Library

Uma biblioteca moderna, flexível e fácil de usar para criar menus customizados em jogos Roblox. Inclui temas, animações, tela de loading, salvamento de configurações, opacidade global, e diversos controles para criar menus profissionais e agradáveis visualmente.

---

## 🚀 Principais Recursos

- **Tela de Loading Customizada:** Com animação e tempo mínimo de exibição, sempre centralizada e na camada mais alta.
- **Temas Prontos:** Dark, White, Dark Forte, White and Dark. Fácil de expandir.
- **Opacidade Total:** Controle de opacidade aplicado em todo o menu, incluindo abas, header e ScrollViews.
- **Salvamento e Carregamento de Configurações:** Todos os controles (toggles, sliders, dropdowns) são salvos e restaurados, incluindo tema, fonte, tamanho do menu e outras preferências.
- **Aba de Configuração Rica:** Troca de tema, cor accent, cor do texto, fonte, raio dos cantos, tamanho do menu, opacidade e mais.
- **Layout Moderno:** Cantos arredondados, padding, botões animados, menu redimensionável e minimizável.
- **Extensível:** Fácil adicionar novas abas, botões e controles customizados.
- **100% Roblox Lua:** Não depende de módulos externos além dos padrões do Roblox.

---

## 📦 Instalação

1. Adicione o arquivo `Library.lua` ao seu projeto Roblox (pode ser como ModuleScript).
2. Importe a Library no seu script principal:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
```

---

## 📝 Exemplo de Uso

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()

local Window = Library:CreateWindow("Meu Menu Customizado")

local Tab1 = Window:CreateTab("Principal", "🏠")
Tab1:AddLabel("Bem-vindo ao menu!")
Tab1:AddToggle("Ativar Modo X", function(state) print("Modo X:", state) end)
Tab1:AddSlider("Volume", 0, 100, 50, function(val) print("Volume:", val) end)

local TabConfig = Window:CreateTab("Config", "⚙️")
-- A aba Config já vem pronta, mas você pode adicionar mais controles se quiser!
```

---

## 🧩 Controles Disponíveis

- **AddLabel(text):** Adiciona um label de texto.
- **AddButton(text, callback):** Botão com callback.
- **AddToggle(text, callback):** Toggle ON/OFF.
- **AddDropdownButtonOnOff(title, items, callback):** Dropdown com múltiplas opções ON/OFF.
- **AddSelectDropdown(title, items, callback):** Dropdown de seleção única.
- **AddSlider(text, min, max, default, callback):** Slider ajustável.

---

## 💾 Salvamento/Carregamento

- O menu salva automaticamente todos os controles se você clicar em "Salvar Config" na aba Config.
- As configurações são restauradas automaticamente no próximo uso (por arquivo ou clipboard, se não houver permissão de escrita).

---

## 🎨 Customização Visual

- **Temas**: Troque rapidamente entre temas na aba Config.
- **Cores**: Defina cor accent e cor do texto dos labels.
- **Fonte**: Troque entre várias fontes Roblox.
- **Opacidade**: Ajuste a transparência do menu inteiro.
- **Tamanho**: Redimensione livremente, ou use presets rápidos.

---

## 🛠️ Dicas de Expansão

- Use `Window:CreateTab("Nova Aba", "🔧")` para adicionar novas abas.
- Adicione mais temas ao objeto `THEMES`.
- Modifique a função `ApplyTheme` para customizações avançadas.
- O menu pode ser minimizado, arrastado e redimensionado pelo usuário.

---

## 📋 Licença

Uso livre para qualquer projeto Roblox. Sinta-se à vontade para modificar e compartilhar!

---

## ✨ Créditos

Criado por [DH SOARES](https://github.com/HOLD2292), inspirado em UIs modernas de jogos.
