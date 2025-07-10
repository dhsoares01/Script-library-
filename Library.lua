--[[

UI_Library.lua
UI Library para Roblox: Menu Flutuante Interativo

Como usar:
UILib local = loadstring(jogo:HttpGet("https://raw.githubusercontent.com/seuusuario/seurepo/main/UI_Library.lua"))()
UILib:Init({
    Título = "Meu Menu",
    DefaultPos = UDim2.new(0.3,0,0.3,0),
    TamanhoPadrão = UDim2.new(0, 350, 0, 350),
})

local toggle = UILib:AddToggle("Ativar Função", false, function(state)
    print("Alternar:", estado)
fim)

controle deslizante local = UILib:AddSlider("Volume", 0, 100, 50, função(val)
    print("Controle deslizante:", val)
fim)

local onoff = UILib:AddButtonOnOff("Modo Turbo", falso, função(estado)
    print("Turbo:", estado)
fim)

UILib:AddLabel("Informações úteis para o usuário.")

]]

UIS local = jogo:GetService("UserInputService")
TS local = jogo:GetService("TweenService")
local runService = game:GetService("RunService")

função local create(class, props)
    inst local = Instância.novo(classe)
    para k,v em pares(props ou {}) faça
        inst[k]=v
    fim
    retornar inst
fim

IU local = {}
UI.__index = IU

função local dragify(frame)
    arrasto local, dragInput, dragStart, startPos
    atualização de função local (entrada)
        delta local = entrada.Posição - arrastarIniciar
        frame.Posição = UDim2.new(
            startPos.X.Escala, startPos.X.Deslocamento + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    fim

    frame.InputBegan:Connect(função(entrada)
        se (input.UserInputType == Enum.UserInputType.MouseButton1) ou
           (input.UserInputType == Enum.UserInputType.Touch) então
            arrastando = verdadeiro
            arrastarIniciar = entrada.Posição
            startPos = frame.Posição
            entrada.Alterado:Conectar(função()
                se input.UserInputState == Enum.UserInputState.End então
                    arrastando = falso
                fim
            fim)
        fim
    fim)
    frame.InputChanged:Connect(função(entrada)
        se (input.UserInputType == Enum.UserInputType.MouseMovement) ou
           (input.UserInputType == Enum.UserInputType.Touch) então
            dragInput = entrada
        fim
    fim)
    UIS.InputChanged:Connect(função(entrada)
        se entrada == arrastarEntrada e arrastando então
            atualização(entrada)
        fim
    fim)
fim

função UI:Init(opts)
    opts = opta ou {}
    -- Remove outras instâncias
    se game.CoreGui:FindFirstChild("UI_Library_Main") então
        jogo.CoreGui.UI_Library_Main:Destroy()
    fim

    -- GUI principal
    ScreenGui local = criar("ScreenGui", {
        Nome = "UI_Library_Main",
        ResetOnSpawn = falso,
        Pai = syn e syn.protect_gui e syn.protect_gui(game.CoreGui) ou game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Irmão,
    })

    local Principal = criar("Quadro", {
        Nome = "MainFrame",
        Pai = ScreenGui,
        BackgroundColor3 = Cor3.fromRGB(35,35,40),
        BorderSizePixel = 0,
        Posição = opts.DefaultPos ou UDim2.new(0.3,0,0.3,0),
        Tamanho = opts.DefaultSize ou UDim2.new(0,350,0,350),
        Ativo = verdadeiro,
        Arrastável = falso,
    })

    arrastar(Principal)

    local UICorner = create("UICorner", {CornerRadius = UDim.new(0,8), Pai = Principal})

    -- Cabeçalho
    Cabeçalho local = create("Quadro", {
        Pai = Principal,
        BackgroundColor3 = Cor3.fromRGB(47,47,60),
        BorderSizePixel = 0,
        Tamanho = UDim2.new(1,0,0,36),
    })
    create("UICorner", {CornerRadius=UDim.new(0,8), Pai=Cabeçalho})

    Título local = create("TextLabel", {
        Pai = Cabeçalho,
        Transparência de fundo = 1,
        Posição = UDim2.new(0,12,0,0),
        Tamanho = UDim2.new(1,-120,1,0),
        Texto = opts.Title ou "Biblioteca de IU",
        TextColor3 = Color3.fromRGB(240.240.240),
        Tamanho do texto = 20,
        Fonte = Enum.Font.GothamBold,
        AlinhamentoTextoXAlinhamento = Enum.AlinhamentoTextoXAlinhamento.Esquerda,
    })

    -- Botões de cabeçalho
    estados locais = {minimizado=falso}
    função local makeButton(txt, pos, retorno de chamada)
        local b = criar("TextButton", {
            Pai = Cabeçalho,
            Tamanho = UDim2.new(0,28,0,28),
            Posição = pos,
            BackgroundColor3 = Cor3.fromRGB(60,60,75),
            Texto = txt,
            Fonte = Enum.Font.GothamBold,
            Tamanho do texto = 19,
            TextColor3 = Cor3.novo(1,1,1),
            BorderSizePixel = 0,
            AutoButtonColor = verdadeiro,
        })
        criar("UICorner", {CornerRadius=UDim.new(0,5), Pai=b})
        b.MouseButton1Click:Conectar(retorno de chamada)
        retornar b
    fim

    MinBtn local = makeButton("–", UDim2.new(1,-88,0.5,-14), função()
        se não estados, minimizados então
            estados.minimizado = verdadeiro
            Conteúdo.Visível = falso
            MinBtn.Text = "+"
        outro
            estados.minimizado = falso
            Conteúdo.Visível = verdadeiro
            MinBtn.Text = "–"
        fim
    fim)

    CloseBtn local = makeButton("Ã—", UDim2.new(1,-48,0.5,-14), função()
        para _,comp em ipairs(self._components) faça
            se comp._reset então
                comp._reset()
            fim
        fim
        ScreenGui:Destruir()
        setmetatable(self,nulo)
    fim)

    -- Área de componentes
    Conteúdo local = create("Quadro",{
        Pai = Principal,
        Transparência de fundo = 1,
        Posição = UDim2.new(0,0,0,40),
        Tamanho = UDim2.new(1,0,1,-44),
    })
    UIList local = criar("UIListLayout",{
        Pai = Conteúdo,
        Ordem de classificação = Enum.Ordem de classificação.Ordem de layout,
        Preenchimento = UDim.new(0,8),
    })

    self.ScreenGui = GuiaDeTela
    self.Main = Principal
    self.Content = Conteúdo
    self.Header = Cabeçalho
    self._components = {}
    self._defaultSize = Tamanho principal
    self._defaultPos = Posição Principal
fim

função UI:AddToggle(txt, padrão, retorno de chamada)
    composição local = {}
    comp._value = padrão ou falso
    comp._reset = função()
        comp._value = falso
        toggleBtn.BackgroundColor3 = Cor3.fromRGB(70,70,80)
        retorno de chamada(falso)
    fim

    quadro local = create("Quadro",{
        Pai = self.Content,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1, -20, 0, 38),
    })

    rótulo local = create("TextLabel",{
        Pai = quadro,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,-50,1,0),
        Texto = txt ou "Alternar",
        TextColor3 = Color3.fromRGB(230.230.230),
        Fonte = Enum.Font.Gotham,
        Tamanho do texto = 17,
        AlinhamentoTextoXAlinhamento = Enum.AlinhamentoTextoXAlinhamento.Esquerda,
    })

    local toggleBtn = criar("TextButton",{
        Pai = quadro,
        Tamanho = UDim2.new(0,38,0.5,0),
        Posição = UDim2.new(1,-44,0.25,0),
        BackgroundColor3 = comp._value e Color3.fromRGB(80,190,80) ou Color3.fromRGB(70,70,80),
        Texto = comp._value e "ON" ou "OFF",
        TextColor3 = Cor3.novo(1,1,1),
        Fonte = Enum.Font.GothamBold,
        Tamanho do texto = 16,
        BorderSizePixel = 0,
        AutoButtonColor = verdadeiro,
    })
    criar("UICorner",{CornerRadius=UDim.new(0,7),Parent=toggleBtn})

    toggleBtn.MouseButton1Click:Conectar(função()
        comp._value = não comp._value
        toggleBtn.Text = comp._value e "ON" ou "OFF"
        toggleBtn.BackgroundColor3 = comp._value e Color3.fromRGB(80,190,80) ou Color3.fromRGB(70,70,80)
        se retorno de chamada então retorno de chamada(comp._value) fim
    fim)

    tabela.inserir(self._components, comp)
    retorno comp
fim

função UI:AddSlider(txt, min, max, padrão, retorno de chamada)
    min, max = min ou 0, max ou 100
    valor local = padrão ou mínimo
    composição local = {}
    comp._reset = função()
        valor = min
        valueBar.Size = UDim2.new(0,0,1,0)
        valueLabel.Text = tostring(min)
        se retorno de chamada então retorno de chamada(min) fim
    fim

    quadro local = create("Quadro",{
        Pai = self.Content,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,-20,0,52),
    })
    rótulo local = create("TextLabel",{
        Pai = quadro,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,0,0.3,0),
        Posição = UDim2.new(0,0,0,0),
        Texto = txt ou "Slider",
        TextColor3 = Color3.fromRGB(230.230.230),
        Fonte = Enum.Font.Gotham,
        Tamanho do texto = 16,
        AlinhamentoTextoXAlinhamento = Enum.AlinhamentoTextoXAlinhamento.Esquerda,
    })
    local sliderBar = create("Quadro",{
        Pai = quadro,
        BackgroundColor3 = Cor3.fromRGB(60,60,75),
        Posição = UDim2.new(0,0,0.5,0),
        Tamanho = UDim2.new(1,-50,0,10),
        BorderSizePixel = 0,
    })
    criar("UICorner",{CornerRadius=UDim.new(0,4),Parent=sliderBar})
    valor localBarra = criar("Quadro",{
        Pai = sliderBar,
        BackgroundColor3 = Cor3.fromRGB(70,180,250),
        Tamanho = UDim2.new((valor-min)/(máx-min),0,1,0),
        BorderSizePixel=0,
    })
    criar("UICorner",{CornerRadius=UDim.new(0,4),Parent=valueBar})

    valor localLabel = create("TextLabel",{
        Pai = quadro,
        Transparência de fundo = 1,
        Posição = UDim2.new(1,-38,0.5,-6),
        Tamanho = UDim2.new(0,36,0,20),
        Texto = tostring(valor),
        TextColor3 = Color3.fromRGB(220.220.220),
        Fonte = Enum.Font.GothamBold,
        Tamanho do texto = 15,
        AlinhamentoTextoXAlinhamento = Enum.TextoXAlinhamento.Direita,
    })

    arrasto local = falso
    função local setSlider(pos)
        rel local = math.clamp((pos.X - sliderBar.AbsolutePosition.X)/sliderBar.AbsoluteSize.X, 0, 1)
        valor = math.floor((min + (max-min)*rel)+0,5)
        valueBar.Size = UDim2.new(rel,0,1,0)
        valueLabel.Text = tostring(valor)
        se retorno de chamada então retorno de chamada(valor) fim
    fim

    sliderBar.InputBegan:Connect(função(entrada)
        se input.UserInputType == Enum.UserInputType.MouseButton1 ou input.UserInputType == Enum.UserInputType.Touch então
            arrastando = verdadeiro
            setSlider(entrada.Posição)
        fim
    fim)
    UIS.InputChanged:Connect(função(entrada)
        se arrastar e (input.UserInputType == Enum.UserInputType.MouseMovement ou input.UserInputType == Enum.UserInputType.Touch) então
            setSlider(entrada.Posição)
        fim
    fim)
    UIS.InputEnded:Connect(função(entrada)
        se input.UserInputType == Enum.UserInputType.MouseButton1 ou input.UserInputType == Enum.UserInputType.Touch então
            arrastando = falso
        fim
    fim)

    tabela.inserir(self._components, comp)
    retorno comp
fim

função UI:AddButtonOnOff(txt, padrão, retorno de chamada)
    composição local = {}
    comp._value = padrão ou falso
    comp._reset = função()
        comp._value = falso
        btn.BackgroundColor3 = Cor3.fromRGB(70,70,80)
        btn.Text = txt.." [DESLIGADO]"
        se retorno de chamada então retorno de chamada(falso) fim
    fim

    quadro local = create("Quadro",{
        Pai = self.Content,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,-20,0,40),
    })
    botão local = create("TextButton",{
        Pai = quadro,
        Tamanho = UDim2.new(1,0,1,0),
        BackgroundColor3 = comp._value e Color3.fromRGB(60,180,100) ou Color3.fromRGB(70,70,80),
        Texto = txt .. (comp._value e " [ON]" ou " [OFF]"),
        TextColor3 = Cor3.novo(1,1,1),
        Fonte = Enum.Font.GothamBold,
        Tamanho do texto = 16,
        BorderSizePixel = 0,
        AutoButtonColor = verdadeiro,
    })
    criar("UICorner",{CornerRadius=UDim.new(0,7),Parent=btn})

    btn.MouseButton1Click:Conectar(função()
        comp._value = não comp._value
        btn.Text = txt .. (comp._value e " [ON]" ou " [OFF]")
        btn.BackgroundColor3 = comp._value e Color3.fromRGB(60,180,100) ou Color3.fromRGB(70,70,80)
        se retorno de chamada então retorno de chamada(comp._value) fim
    fim)

    tabela.inserir(self._components, comp)
    retorno comp
fim

função UI:AddLabel(txt)
    quadro local = create("Quadro",{
        Pai = self.Content,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,-20,0,26),
    })
    rótulo local = create("TextLabel",{
        Pai = quadro,
        Transparência de fundo = 1,
        Tamanho = UDim2.new(1,0,1,0),
        Texto = txt ou "Rótulo",
        TextColor3 = Color3.fromRGB(200.200.200),
        Fonte = Enum.Font.Gotham,
        Tamanho do texto = 15,
        AlinhamentoTextoXAlinhamento = Enum.AlinhamentoTextoXAlinhamento.Esquerda,
    })
fim

-- API
UI_API local = setmetatable({}, UI)
função UI_API:Init(opt)
    UI.Init(self, opt)
    retornar a si mesmo
fim

função UI_API:AddToggle(...)
    retornar UI.AddToggle(self, ...)
fim

função UI_API:AddSlider(...)
    retornar UI.AddSlider(self, ...)
fim

função UI_API:AddButtonOnOff(...)
    retornar UI.AddButtonOnOff(self, ...)
fim

função UI_API:AddLabel(...)
    retornar UI.AddLabel(self, ...)
fim

retornar UI_API
