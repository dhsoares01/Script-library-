-- NotificationLibrary.lua
-- Library de notificações 
local NotificationLibrary = {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configurações padrão
local Config = {
    Duration = 5,         -- tempo visível (segundos)
    FadeTime = 0.4,       -- duração da animação de entrada/saída
    Width = 300,          -- largura do frame
    Height = 80,          -- altura do frame
    StartPosition = UDim2.new(1, 310, 0, 50),  -- posição inicial (fora da tela à direita)
    EndPosition = UDim2.new(1, -10, 0, 50),    -- posição final (visível)
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    TitleColor = Color3.fromRGB(255, 255, 255),
    SubtitleColor = Color3.fromRGB(180, 180, 180),
    FontTitle = Enum.Font.GothamBold,
    FontSubtitle = Enum.Font.Gotham,
    TextSizeTitle = 20,
    TextSizeSubtitle = 14,
}

-- Função principal para criar e mostrar notificação
function NotificationLibrary:Notify(titleText, subtitleText)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NerdV5Notification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, Config.Width, 0, Config.Height)
    frame.Position = Config.StartPosition
    frame.BackgroundColor3 = Config.BackgroundColor
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Name = "NotificationFrame"
    frame.Parent = screenGui
    frame.ClipsDescendants = true
    frame.ZIndex = 10
    frame.Rotation = 0

    -- Sombra (opcional para estilo mais clean)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.Image = "rbxassetid://1316045217" -- sombra circular (pode trocar)
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.75
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = titleText or "Título"
    title.TextColor3 = Config.TitleColor
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.TextStrokeTransparency = 0
    title.Font = Config.FontTitle
    title.TextSize = Config.TextSizeTitle
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 30)
    subtitle.Position = UDim2.new(0, 10, 0, 42)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = subtitleText or "Subtítulo"
    subtitle.TextColor3 = Config.SubtitleColor
    subtitle.TextStrokeColor3 = Color3.new(0, 0, 0)
    subtitle.TextStrokeTransparency = 0.3
    subtitle.Font = Config.FontSubtitle
    subtitle.TextSize = Config.TextSizeSubtitle
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = frame

    -- Tween para entrada
    local tweenIn = TweenService:Create(frame, TweenInfo.new(Config.FadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = Config.EndPosition})
    tweenIn:Play()

    -- Depois de Duration segundos, faz saída e destrói
    delay(Config.Duration, function()
        local tweenOut = TweenService:Create(frame, TweenInfo.new(Config.FadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = Config.StartPosition})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        screenGui:Destroy()
    end)
end

return NotificationLibrary
