local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local NotifyLib = {}

function NotifyLib:Notify(titulo, mensagem, duracao)
    duracao = duracao or 4

    -- Container principal
    local holder = Instance.new("ScreenGui")
    holder.Name = "Notify_" .. tostring(math.random(10000, 99999))
    holder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    holder.IgnoreGuiInset = true
    holder.ResetOnSpawn = false
    holder.Parent = CoreGui

    -- Notificação
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 70)
    frame.Position = UDim2.new(1, 10, 1, -90)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = holder

    -- Sombra
    local shadow = Instance.new("UICorner")
    shadow.CornerRadius = UDim.new(0, 10)
    shadow.Parent = frame

    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titulo
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    -- Mensagem
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = mensagem
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame

    -- Entrada (slide in)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -10, 1, -90)
    }):Play()

    -- Remoção após tempo
    task.delay(duracao, function()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 310, 1, -90)
        }):Play()
        task.wait(0.4)
        holder:Destroy()
    end)
end

return NotifyLib
