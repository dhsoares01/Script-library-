local ESP = {}
ESP.__index = ESP

-- Cria a library ESP via endereço de objetos
-- config: tabela opcional, com booleanos para ativar cada feature (true/false)
function ESP.new(config)
    local self = setmetatable({}, ESP)

    config = config or {}

    self.Enabled = true
    self.LineESP = config.line == nil and true or config.line
    self.Box3DESP = config.box3d == nil and true or config.box3d
    self.Box2DESP = config.box2d == nil and true or config.box2d
    self.NameESP = config.name == nil and true or config.name
    self.DistanceESP = config.distance == nil and true or config.distance
    self.ObjectESP = config.object == nil and true or config.object

    self.TrackedObjects = {} -- objetos para espionar

    local Players = game:GetService("Players")
    self.LocalPlayer = Players.LocalPlayer
    self.Camera = workspace.CurrentCamera
    self.RunService = game:GetService("RunService")

    -- Guarda os drawings para cada objeto
    self.ESPData = {}

    -- Função para adicionar objeto para espionar
    function self:AddObject(obj)
        if obj and not table.find(self.TrackedObjects, obj) then
            table.insert(self.TrackedObjects, obj)
        end
    end

    -- Função para remover objeto da lista e limpar drawings
    function self:RemoveObject(obj)
        for i, v in ipairs(self.TrackedObjects) do
            if v == obj then
                table.remove(self.TrackedObjects, i)
                break
            end
        end
        if self.ESPData[obj] then
            for _, v in pairs(self.ESPData[obj]) do
                v:Remove()
            end
            self.ESPData[obj] = nil
        end
    end

    -- Função para limpar lista e remover drawings
    function self:ClearObjects()
        for obj, data in pairs(self.ESPData) do
            for _, drawing in pairs(data) do
                drawing:Remove()
            end
        end
        self.ESPData = {}
        self.TrackedObjects = {}
    end

    -- Funções de criação de Drawing objects
    local function createLine()
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        line.ZIndex = 2
        return line
    end

    local function createBox()
        local box = Drawing.new("Square")
        box.Color = Color3.new(1, 1, 1)
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        box.ZIndex = 2
        return box
    end

    local function createText()
        local text = Drawing.new("Text")
        text.Color = Color3.new(1, 1, 1)
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Transparency = 1
        text.ZIndex = 3
        text.Font = 2 -- Arial
        return text
    end

    -- Atualiza a ESP a cada frame
    self.Connection = self.RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end

        local cam = self.Camera
        local lp = self.LocalPlayer
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = lp.Character.HumanoidRootPart.Position

        -- Filtra objetos válidos e remove inválidos imediatamente
        local validObjects = {}
        for _, obj in ipairs(self.TrackedObjects) do
            if obj and obj.Parent then
                table.insert(validObjects, obj)
            else
                if self.ESPData[obj] then
                    for _, v in pairs(self.ESPData[obj]) do
                        v:Remove()
                    end
                    self.ESPData[obj] = nil
                end
            end
        end
        self.TrackedObjects = validObjects

        -- Atualiza ESP dos objetos válidos
        for _, obj in ipairs(self.TrackedObjects) do
            local rootPosObj = nil
            if obj:IsA("BasePart") then
                rootPosObj = obj.Position
            elseif obj:IsA("Model") then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    rootPosObj = hrp.Position
                else
                    local suc, cframe, size = pcall(function() return obj:GetBoundingBox() end)
                    if suc and cframe then
                        rootPosObj = cframe.Position
                    end
                end
            else
                local suc, cframe, size = pcall(function() return obj:GetBoundingBox() end)
                if suc and cframe then
                    rootPosObj = cframe.Position
                end
            end

            if not rootPosObj then
                if self.ESPData[obj] then
                    for _, v in pairs(self.ESPData[obj]) do
                        v.Visible = false
                    end
                end
                -- 'continue' não existe no Lua, então pulamos com 'goto'
                goto continue_loop
            end

            local dist = (rootPos - rootPosObj).Magnitude

            local success, screenPos3D = pcall(function()
                return cam:WorldToViewportPoint(rootPosObj)
            end)

            if not success or screenPos3D.Z < 0 then
                if self.ESPData[obj] then
                    for _, v in pairs(self.ESPData[obj]) do
                        v.Visible = false
                    end
                end
                goto continue_loop
            end

            local screenPos = Vector2.new(screenPos3D.X, screenPos3D.Y)

            -- Cria drawings se não existir para o objeto
            if not self.ESPData[obj] then
                self.ESPData[obj] = {}

                if self.LineESP then
                    self.ESPData[obj].line = createLine()
                end

                if self.Box2DESP then
                    self.ESPData[obj].box2d = createBox()
                end

                if self.Box3DESP then
                    self.ESPData[obj].box3d = {}
                    for _=1,12 do
                        table.insert(self.ESPData[obj].box3d, createLine())
                    end
                end

                if self.ObjectESP then
                    self.ESPData[obj].objectBox = createBox()
                    self.ESPData[obj].objectBox.Filled = false
                end

                if self.NameESP then
                    self.ESPData[obj].name = createText()
                end

                if self.DistanceESP then
                    self.ESPData[obj].distance = createText()
                end
            end

            local data = self.ESPData[obj]

            -- Line ESP
            if self.LineESP and data.line then
                data.line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                data.line.To = screenPos
                data.line.Visible = true
            elseif data.line then
                data.line.Visible = false
            end

            -- Box 2D ESP
            if self.Box2DESP and data.box2d then
                local size = Vector2.new(50, 70) -- exemplo fixo, ajuste conforme precisar
                data.box2d.Size = size
                data.box2d.Position = screenPos - (size / 2)
                data.box2d.Visible = true
            elseif data.box2d then
                data.box2d.Visible = false
            end

            -- Box 3D ESP
            if self.Box3DESP and data.box3d then
                local success2, cframe, size = pcall(function() return obj:GetBoundingBox() end)
                if not success2 or not cframe then
                    for _, line in pairs(data.box3d) do
                        line.Visible = false
                    end
                else
                    local extents = size / 2
                    local points = {
                        cframe * Vector3.new(-extents.X, -extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, -extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, -extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, -extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, extents.Y, extents.Z),
                    }

                    for i, v in ipairs(points) do
                        local onscreen2, pos2 = pcall(function()
                            return cam:WorldToViewportPoint(v)
                        end)
                        if onscreen2 and pos2.Z > 0 then
                            points[i] = Vector2.new(pos2.X, pos2.Y)
                        else
                            points[i] = nil
                        end
                    end

                    local linesIdx = {
                        {1,2},{2,3},{3,4},{4,1},
                        {5,6},{6,7},{7,8},{8,5},
                        {1,5},{2,6},{3,7},{4,8}
                    }

                    for i, line in ipairs(data.box3d) do
                        local idx = linesIdx[i]
                        local p1 = points[idx[1]]
                        local p2 = points[idx[2]]
                        if p1 and p2 then
                            line.From = p1
                            line.To = p2
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                end
            elseif data.box3d then
                for _, line in pairs(data.box3d) do
                    line.Visible = false
                end
            end

            -- Object ESP (caixa 2D que cobre o objeto todo)
            if self.ObjectESP and data.objectBox then
                local success3, cframe, size = pcall(function() return obj:GetBoundingBox() end)
                if success3 and cframe then
                    local extents = size / 2
                    local corners3d = {
                        cframe * Vector3.new(-extents.X, -extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, -extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, -extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, -extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, extents.Y, -extents.Z),
                        cframe * Vector3.new(extents.X, extents.Y, extents.Z),
                        cframe * Vector3.new(-extents.X, extents.Y, extents.Z),
                    }

                    local minX, maxX = math.huge, -math.huge
                    local minY, maxY = math.huge, -math.huge

                    for _, corner in ipairs(corners3d) do
                        local onscreen4, pos4 = pcall(function()
                            return cam:WorldToViewportPoint(corner)
                        end)
                        if onscreen4 and pos4.Z > 0 then
                            local sp = Vector2.new(pos4.X, pos4.Y)
                            if sp.X < minX then minX = sp.X end
                            if sp.X > maxX then maxX = sp.X end
                            if sp.Y < minY then minY = sp.Y end
                            if sp.Y > maxY then maxY = sp.Y end
                        end
                    end

                    if minX ~= math.huge and minY ~= math.huge and maxX ~= -math.huge and maxY ~= -math.huge then
                        data.objectBox.Position = Vector2.new(minX, minY)
                        data.objectBox.Size = Vector2.new(maxX - minX, maxY - minY)
                        data.objectBox.Visible = true
                    else
                        data.objectBox.Visible = false
                    end
                else
                    data.objectBox.Visible = false
                end
            elseif data.objectBox then
                data.objectBox.Visible = false
            end

            -- Nome ESP
            if self.NameESP and data.name then
                data.name.Text = tostring(obj.Name)
                data.name.Position = screenPos + Vector2.new(0, -40)
                data.name.Visible = true
            elseif data.name then
                data.name.Visible = false
            end

            -- Distância ESP
            if self.DistanceESP and data.distance then
                data.distance.Text = string.format("[%.1f]", dist)
                data.distance.Position = screenPos + Vector2.new(0, -25)
                data.distance.Visible = true
            elseif data.distance then
                data.distance.Visible = false
            end

            ::continue_loop::
        end
    end)

    return self
end

-- Função para desligar a ESP e limpar todos drawings
function ESP:Destroy()
    self.Enabled = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    for obj, data in pairs(self.ESPData) do
        for _, drawing in pairs(data) do
            drawing:Remove()
        end
    end
    self.ESPData = {}
    self.TrackedObjects = {}
end

return ESP
