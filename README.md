
# 📚 Script GUI Menu Library

![Prévia da Biblioteca](https://via.placeholder.com/1000x500/2d3748/ffffff?text=Adicione+aqui+uma+imagem+atraente+da+sua+GUI!)

---

Uma **poderosa e moderna biblioteca GUI em Lua**, desenvolvida especificamente para executores de scripts Roblox como Delta, Fluxus e outros. Com ela, você pode criar menus interativos com facilidade, profissionalismo e um design impecável.

---

## ✨ Recursos Em Destaque

Nossa biblioteca foi pensada para oferecer a melhor experiência, tanto para desenvolvedores quanto para usuários finais.

### 🎨 Design Intuitivo e Moderno
- **Tema Escuro Sofisticado:** Confortável para os olhos e com um visual profissional.
- **Cantos Arredondados e Interface Limpa:** Detalhes que fazem a diferença na estética.
- **Totalmente Responsiva:** Adapta-se perfeitamente a diferentes resoluções e tamanhos de tela.

### 🖱️ Interatividade Avançada
- **Arrastar e Mover:** Liberdade total para posicionar as janelas onde desejar.
- **Redimensionamento Dinâmico:** Ajuste o tamanho das janelas em tempo real.
- **Minimizar/Restaurar:** Organize seu espaço de trabalho facilmente.
- **Animações Suaves:** Transições fluidas que enriquecem a experiência do usuário.

### 🧩 Componentes Ricos e Versáteis
Construa interfaces complexas com uma variedade de componentes pré-fabricados:

| Componente           | Descrição                                                              | Exemplo de Uso                                           |
|----------------------|------------------------------------------------------------------------|----------------------------------------------------------|
| **Label** | Exibe texto informativo simples.                                       | `MainTab:AddLabel("Informações do Jogo")`              |
| **Button** | Botões clicáveis que executam ações personalizadas.                    | `MainTab:AddButton("Comprar Item")`                      |
| **Toggle** | Interruptor ON/OFF para alternar estados.                              | `MainTab:AddToggle("Modo Deus")`                         |
| **DropdownButtonOnOff**| Menu expansível com múltiplas opções de ligar/desligar.              | `MainTab:AddDropdownButtonOnOff("Habilidades", {...})`  |
| **SelectDropdown** | Lista expansível para seleção única de itens.                          | `MainTab:AddSelectDropdown("Classes", {...})`           |
| **Slider** | Controle deslizante para ajustar valores numéricos dentro de um intervalo. | `MainTab:AddSlider("Volume", 0, 100, 50)`               |

---

## 🚀 Como Começar (Instalação e Uso)

### 📥 Instalação Rápida

Para começar a usar a `Script GUI Menu Library`, basta carregar o script diretamente no seu executor:

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua](https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua)"))()

🧑‍💻 Exemplo de Uso Básico
Veja como é simples criar e personalizar seu primeiro menu interativo:
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua](https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua)"))()

-- Criação da Janela Principal
local MyMenu = Library:CreateWindow("Meu Menu Personalizado")

-- Criação de uma Aba na Janela
local MainTab = MyMenu:CreateTab("Principal", "⭐") -- O segundo argumento é opcional e adiciona um ícone à aba

-- Adicionando Componentes à Aba:

-- Adiciona um rótulo informativo
MainTab:AddLabel("Configurações Gerais:")

-- Adiciona um botão que reseta o personagem ao ser clicado
MainTab:AddButton("Resetar Personagem", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
    print("Personagem resetado!")
end)

-- Adiciona um interruptor (toggle) para o modo voo
local toggleVoo = MainTab:AddToggle("Voar", function(state)
    print("Modo voo:", state and "ATIVADO" or "DESATIVADO")
    -- Lógica para ativar/desativar o voo
end)

-- Adiciona um slider para controlar a velocidade do personagem
MainTab:AddSlider("Velocidade", 10, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    print("Velocidade definida para:", value)
end)

📚 Documentação da API (Referência Rápida)
Explore as principais funções e métodos disponíveis na biblioteca para construir suas interfaces.
Library - O Objeto Principal
| Método | Parâmetros | Descrição |
|---|---|---|
| CreateWindow | name (string) | Cria uma nova janela GUI. Retorna um objeto Window. |
Window - Manipulando Janelas
| Método | Parâmetros | Descrição |
|---|---|---|
| CreateTab | name (string), icon (string, opcional) | Adiciona uma nova aba à janela. Retorna um objeto Tab. |
Tab - Adicionando Componentes às Abas
| Método | Parâmetros | Retorno |
|---|---|---|
| AddLabel | text (string) | nil |
| AddButton | text (string), callback (function) | nil |
| AddToggle | text (string), callback (function state -> boolean) | Toggle object |
| AddDropdownButtonOnOff | title (string), items (table), callback (function item_name, state -> boolean) | Dropdown object |
| AddSelectDropdown | title (string), items (table), callback (function selected_item_name -> string) | Dropdown object |
| AddSlider | text (string), min (number), max (number), default (number), callback (function value -> number) | Slider object |
🛠️ Detalhes Técnicos
 * Arquitetura: Biblioteca de arquivo único para fácil integração.
 * Dependências: Utiliza apenas serviços nativos do Roblox (sem dependências externas complexas).
 * Performance: Otimizada para carregamento rápido e fluidez.
 * Animações: Impulsionada por TweenService para transições suaves e responsivas.
🤝 Contribuição
Sua ajuda é muito bem-vinda para tornar esta biblioteca ainda melhor! Se você tem ideias, encontrou um bug ou quer adicionar novos recursos, siga estes passos:
 * Fork este repositório.
 * Crie um novo branch para sua funcionalidade ou correção:
   git checkout -b feature/minha-nova-funcionalidade
   (ou fix/correcao-de-bug)
 * Faça suas alterações e commit-as:
   git commit -m 'feat: Adiciona nova funcionalidade X'
   (use prefixos como feat:, fix:, docs:, etc.)
 * Faça o push do seu branch para o seu fork:
   git push origin feature/minha-nova-funcionalidade
 * Abra um Pull Request para este repositório, descrevendo suas mudanças.
📄 Licença
Este projeto é distribuído sob a licença MIT. Para mais detalhes, consulte o arquivo LICENSE.
<div align="center">
<p>Feito com ❤️ por <a href="https://github.com/dhsoares01">dhsoares01</a></p>
<img src="https://img.shields.io/github/stars/dhsoares01/Script-library-?style=social" alt="GitHub stars">
</div>

