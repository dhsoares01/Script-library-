local ESP3D = {}
ESP3D.__index = ESP3D

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cria um box 3D em volta do objeto
local function createBoxPart(size, color, transparency)
    local part = Instance.new("BoxHandleAdornment")
    part.Adornee = nil -- será setado depois
    part.AlwaysOnTop = true
    part.ZIndex = 2
    part.Size = size
    part.Transparency = transparency or 0.5
    part.Color3 = color
    part.Visible = true
    return part
end

-- Cria uma linha entre dois pontos
local function createLine()
    local line = Instance.new("Beam")
    local attachment0 = Instance.new("Attachment")
    local attachment1 = Instance.new("Attachment")
    attachment0.Name = "Attachment0"
    attachment1.Name = "Attachment1"

    local part0 = Instance.new("Part")
    part0.Transparency = 1
    part0.Anchored = true
    part0.CanCollide = false
    part0.Size = Vector3.new(0.2,0.2,0.2)
    part0.Name = "ESPLinePart0"
    attachment0.Parent = part0

    local part1 = Instance.new("Part")
    part1.Transparency = 1
    part1.Anchored = true
    part1.CanCollide = false
    part1.Size = Vector3.new(0.2,0.2,0.2)
    part1.Name = "ESPLinePart1"
    attachment1.Parent = part1

    line.Attachment0 = attachment0
    line.Attachment1 = attachment1
    line.Parent = part0

    line.Width0 = 0.05
    line.Width1 = 0.05
    line.Color = ColorSequence.new(Color3.new(1,1,1)) -- branco padrão

    return {
        beam = line,
        part0 = part0,
        part1 = part1,
        attachment0 = attachment0,
        attachment1 = attachment1
    }
end

-- Cria um BillboardGui para nome e distância
local function createBillboard(nameText, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = nil
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = nameText or "Object"
    textLabel.TextColor3 = color or Color3.new(1,1,1)
    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    return billboard, textLabel
end


function ESP3D.new(objects, options)
    local self = setmetatable({}, ESP3D)
    self.Objects = objects or {}
    self.Enabled = options and options.Enabled or true
    self.Color = (options and options.Color) or Color3.fromRGB(255,0,0)
    self.MaxDistance = (options and options.MaxDistance) or 300

    -- tabela pra guardar as partes da ESP por objeto
    self.ESPData = {}

    -- Criar ESP para cada objeto
    for _, obj in pairs(self.Objects) do
        if obj and obj:IsA("BasePart") then
            local box = createBoxPart(obj.Size, self.Color, 0.4)
            box.Adornee = obj
            box.Parent = Camera

            local line = createLine()
            line.beam.Color = ColorSequence.new(self.Color)

            local billboard, textLabel = createBillboard(obj.Name, self.Color)
            billboard.Adornee = obj
            billboard.Parent = Camera

            self.ESPData[obj] = {
                box = box,
                line = line,
                billboard = billboard,
                textLabel = textLabel
            }
        end
    end

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then
            -- esconder todos
            for obj,data in pairs(self.ESPData) do
                if data.box then data.box.Visible = false end
                if data.line then
                    data.line.beam.Parent.Transparency = 1
                    data.line.part0.Transparency = 1
                    data.line.part1.Transparency = 1
                end
                if data.billboard then data.billboard.Enabled = false end
            end
            return
        end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        for obj,data in pairs(self.ESPData) do
            if obj and obj.Parent then
                local dist = (rootPart.Position - obj.Position).Magnitude
                if dist <= self.MaxDistance then
                    -- Mostrar box
                    if data.box then
                        data.box.Visible = true
                        data.box.Color3 = self.Color
                    end

                    -- Atualizar linha
                    if data.line then
                        local pos0 = rootPart.Position
                        local pos1 = obj.Position
                        data.line.part0.CFrame = CFrame.new(pos0)
                        data.line.part1.CFrame = CFrame.new(pos1)

                        data.line.part0.Transparency = 1
                        data.line.part1.Transparency = 1

                        data.line.beam.Transparency = NumberSequence.new(0)
                        data.line.beam.Color = ColorSequence.new(self.Color)
                    end

                    -- Atualizar Billboard
                    if data.billboard and data.textLabel then
                        data.billboard.Enabled = true
                        data.billboard.Adornee = obj
                        data.textLabel.Text = obj.Name .. "\n" .. string.format("%.1fm", dist)
                        data.textLabel.TextColor3 = self.Color
                    end
                else
                    if data.box then data.box.Visible = false end
                    if data.line then
                        data.line.beam.Transparency = NumberSequence.new(1)
                    end
                    if data.billboard then data.billboard.Enabled = false end
                end
            else
                -- Objeto removido ou inválido, esconder ESP
                if data.box then data.box.Visible = false end
                if data.line then data.line.beam.Transparency = NumberSequence.new(1) end
                if data.billboard then data.billboard.Enabled = false end
            end
        end
    end)

    return self
end

function ESP3D:SetEnabled(state)
    self.Enabled = state
end

function ESP3D:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
    end
    for obj,data in pairs(self.ESPData) do
        if data.box then data.box:Destroy() end
        if data.line then
            data.line.beam:Destroy()
            data.line.part0:Destroy()
            data.line.part1:Destroy()
        end
        if data.billboard then data.billboard:Destroy() end
    end
    self.ESPData = {}
end

-- Exporta a library para loadstring
return ESP3D
