-- NotificationLibrary.lua
local NotificationLibrary = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configuração
local NOTIFY_DURATION = 5
local NOTIFY_SPACING = 8
local NOTIFY_WIDTH = 300
local NOTIFY_HEIGHT = 80

-- Tela principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Container para notificações
local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.AnchorPoint = Vector2.new(1, 1)
NotifyContainer.Position = UDim2.new(1, -10, 1, -10)
NotifyContainer.Size = UDim2.new(0, NOTIFY_WIDTH, 1, 0)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = ScreenGui

-- Lista de notificações ativas
local notifications = {}

function NotificationLibrary:Notify(title, description, duration)
	duration = duration or NOTIFY_DURATION

	-- Criar base
	local NotifyFrame = Instance.new("Frame")
	NotifyFrame.Size = UDim2.new(0, NOTIFY_WIDTH, 0, NOTIFY_HEIGHT)
	NotifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	NotifyFrame.BorderSizePixel = 0
	NotifyFrame.BackgroundTransparency = 0.1
	NotifyFrame.ClipsDescendants = true
	NotifyFrame.AnchorPoint = Vector2.new(1, 1)
	NotifyFrame.Position = UDim2.new(1, 0, 1, 0)
	NotifyFrame.Parent = NotifyContainer
	NotifyFrame.AutomaticSize = Enum.AutomaticSize.Y
	NotifyFrame.ZIndex = 5
	NotifyFrame.Name = "Notification"

	-- Arredondamento
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = NotifyFrame

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(70, 70, 70)
	UIStroke.Thickness = 1
	UIStroke.Parent = NotifyFrame

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 8)
	Padding.PaddingBottom = UDim.new(0, 8)
	Padding.PaddingLeft = UDim.new(0, 10)
	Padding.PaddingRight = UDim.new(0, 10)
	Padding.Parent = NotifyFrame

	-- Título
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Size = UDim2.new(1, 0, 0, 18)
	TitleLabel.Parent = NotifyFrame

	-- Descrição
	local DescriptionLabel = Instance.new("TextLabel")
	DescriptionLabel.Text = description
	DescriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	DescriptionLabel.TextSize = 14
	DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	DescriptionLabel.BackgroundTransparency = 1
	DescriptionLabel.Font = Enum.Font.Gotham
	DescriptionLabel.Position = UDim2.new(0, 0, 0, 22)
	DescriptionLabel.Size = UDim2.new(1, 0, 0, 40)
	DescriptionLabel.TextWrapped = true
	DescriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
	DescriptionLabel.Parent = NotifyFrame

	-- Organizar notificações existentes
	table.insert(notifications, 1, NotifyFrame)
	for i, notif in ipairs(notifications) do
		local targetY = -((NOTIFY_HEIGHT + NOTIFY_SPACING) * (i - 1))
		TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, 0, 1, targetY)
		}):Play()
	end

	-- Remover após tempo
	task.delay(duration, function()
		if NotifyFrame and NotifyFrame.Parent then
			local index = table.find(notifications, NotifyFrame)
			if index then
				table.remove(notifications, index)
			end

			-- Fade out
			local tween = TweenService:Create(NotifyFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
			tween:Play()
			tween.Completed:Wait()

			NotifyFrame:Destroy()

			-- Reorganizar
			for i, notif in ipairs(notifications) do
				local targetY = -((NOTIFY_HEIGHT + NOTIFY_SPACING) * (i - 1))
				TweenService:Create(notif, TweenInfo.new(0.25), {
					Position = UDim2.new(1, 0, 1, targetY)
				}):Play()
			end
		end
	end)
end

return NotificationLibrary
