-- NotificationLibrary.lua (com imagem)
local NotificationLibrary = {}

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local NOTIFY_DURATION = 5
local NOTIFY_SPACING = 8
local NOTIFY_WIDTH = 320
local NOTIFY_HEIGHT = 80

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.AnchorPoint = Vector2.new(1, 1)
NotifyContainer.Position = UDim2.new(1, -10, 1, -10)
NotifyContainer.Size = UDim2.new(0, NOTIFY_WIDTH, 1, 0)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = ScreenGui

local notifications = {}

function NotificationLibrary:Notify(title, description, duration, imageId)
	duration = duration or NOTIFY_DURATION

	local NotifyFrame = Instance.new("Frame")
	NotifyFrame.Size = UDim2.new(0, NOTIFY_WIDTH, 0, NOTIFY_HEIGHT)
	NotifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	NotifyFrame.BorderSizePixel = 0
	NotifyFrame.BackgroundTransparency = 0.1
	NotifyFrame.ClipsDescendants = true
	NotifyFrame.AnchorPoint = Vector2.new(1, 1)
	NotifyFrame.Position = UDim2.new(1, 0, 1, 0)
	NotifyFrame.Parent = NotifyContainer
	NotifyFrame.ZIndex = 5

	local UICorner = Instance.new("UICorner", NotifyFrame)
	UICorner.CornerRadius = UDim.new(0, 8)

	local UIStroke = Instance.new("UIStroke", NotifyFrame)
	UIStroke.Color = Color3.fromRGB(70, 70, 70)
	UIStroke.Thickness = 1

	local Padding = Instance.new("UIPadding", NotifyFrame)
	Padding.PaddingTop = UDim.new(0, 8)
	Padding.PaddingBottom = UDim.new(0, 8)
	Padding.PaddingLeft = UDim.new(0, 10)
	Padding.PaddingRight = UDim.new(0, 10)

	-- Ícone (se fornecido)
	if imageId then
		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.Image = imageId
		Icon.Size = UDim2.new(0, 32, 0, 32)
		Icon.Position = UDim2.new(0, 0, 0, 0)
		Icon.BackgroundTransparency = 1
		Icon.ScaleType = Enum.ScaleType.Fit
		Icon.Parent = NotifyFrame

		local UIPadding = Instance.new("UIPadding", NotifyFrame)
		UIPadding.PaddingLeft = UDim.new(0, 40)
	end

	local TitleLabel = Instance.new("TextLabel", NotifyFrame)
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Position = UDim2.new(0, 40, 0, 2)
	TitleLabel.Size = UDim2.new(1, -40, 0, 18)

	local DescriptionLabel = Instance.new("TextLabel", NotifyFrame)
	DescriptionLabel.Text = description
	DescriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	DescriptionLabel.TextSize = 14
	DescriptionLabel.Font = Enum.Font.Gotham
	DescriptionLabel.BackgroundTransparency = 1
	DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	DescriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
	DescriptionLabel.TextWrapped = true
	DescriptionLabel.Position = UDim2.new(0, 40, 0, 24)
	DescriptionLabel.Size = UDim2.new(1, -40, 1, -26)

	table.insert(notifications, 1, NotifyFrame)
	for i, notif in ipairs(notifications) do
		local targetY = -((NOTIFY_HEIGHT + NOTIFY_SPACING) * (i - 1))
		TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, 0, 1, targetY)
		}):Play()
	end

	task.delay(duration, function()
		if NotifyFrame and NotifyFrame.Parent then
			local index = table.find(notifications, NotifyFrame)
			if index then table.remove(notifications, index) end

			TweenService:Create(NotifyFrame, TweenInfo.new(0.3), {
				BackgroundTransparency = 1
			}):Play()

			NotifyFrame:Destroy()

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
