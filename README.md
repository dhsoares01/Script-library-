# CustomUILib

**CustomUILib** é uma biblioteca leve e elegante para criação de interfaces gráficas (GUI) personalizadas em Roblox, focada em simplicidade, usabilidade e design moderno. Ideal para desenvolvedores que querem adicionar menus interativos, com suporte a abas, botões, toggles, sliders, redimensionamento e muito mais.

---

## 🎨 Tema e Design

- Tema escuro com cores suaves e contrastantes.
- Cantos arredondados em todos os elementos para uma aparência moderna.
- Animações suaves para transições e interações.
- Suporte nativo a arrastar a janela via mouse ou toque.
- Janela redimensionável pelo canto inferior direito.
- Botão de minimizar/restaurar no título para otimizar espaço.

---

## 🚀 Recursos Principais

| Funcionalidade           | Descrição                                                  |
|-------------------------|------------------------------------------------------------|
| Janela Principal         | Criar uma janela centralizada com título personalizável.   |
| Abas                     | Permite múltiplas abas para organizar opções ou ferramentas. |
| Botões                  | Botões clicáveis com callback.                              |
| Toggles                 | Botões de ligar/desligar com estado visual e callback.     |
| Sliders                 | Controle deslizante com valor numérico, mínimo e máximo.   |
| Redimensionamento       | Permite redimensionar a janela pelo canto inferior direito.|
| Minimize/Restore        | Botão para minimizar e restaurar a janela.                 |

---

## 📦 Como usar

### Instalação

Basta carregar a biblioteca diretamente via `loadstring`:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()

Criar a janela principal

local Window = Library:CreateWindow("Minha Interface")

Criar uma aba

local Tab = Window:CreateTab("Configurações", "") -- Segundo parâmetro é opcional para ícone (string)

Adicionar componentes à aba

Toggle


Tab:AddToggle("Ativar recurso", function(state)
    print("Toggle está", state and "Ligado" or "Desligado")
end)

Slider


Tab:AddSlider("Volume", 0, 100, 50, function(value)
    print("Volume ajustado para:", value)
end)

Botão


Tab:AddButton("Clique aqui", function()
    print("Botão clicado")
end)

Label


Tab:AddLabel("Esta é uma label informativa")


---

⚙️ API detalhada

Library:CreateWindow(title)

Cria a janela principal.

title (string): Título da janela.
Retorna um objeto janela com métodos para criar abas.



---

window:CreateTab(name, icon)

Cria uma aba dentro da janela.

name (string): Nome da aba.

icon (string): Ícone opcional (texto, como um emoji ou caractere).


Retorna um objeto aba com métodos para adicionar componentes.


---

tab:AddToggle(text, callback)

Adiciona um toggle button.

text (string): Texto exibido.

callback (function): Função chamada com o estado (boolean) ao clicar.



---

tab:AddSlider(text, min, max, default, callback)

Adiciona um slider.

text (string): Texto exibido.

min (number): Valor mínimo.

max (number): Valor máximo.

default (number): Valor inicial.

callback (function): Função chamada com valor atualizado (number).



---

tab:AddButton(text, callback)

Adiciona um botão simples.

text (string): Texto exibido.

callback (function): Função chamada ao clicar.



---

tab:AddLabel(text)

Adiciona uma label estática para texto informativo.

text (string): Texto da label.



---

💡 Dicas

Use abas para organizar funcionalidades diferentes.

Combine toggles e sliders para opções configuráveis.

Ajuste o tamanho da janela com o canto inferior direito para melhor usabilidade.

Minimize a janela quando não precisar interagir para liberar espaço na tela.



---

❓ FAQ

P: A janela pode ser fechada?
R: Atualmente, a biblioteca oferece minimizar, mas não fechar. Você pode modificar o código para adicionar essa funcionalidade.

P: Posso personalizar as cores?
R: Sim! O tema está definido no arquivo fonte na tabela theme para fácil ajuste.

P: A biblioteca funciona em dispositivos móveis?
R: Sim! Suporta toque para arrastar e interagir com controles.


---

Licença

MIT License © dhsoares01


---

Contato

Criado por dhsoares01
GitHub: https://github.com/dhsoares01
