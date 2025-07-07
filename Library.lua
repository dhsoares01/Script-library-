--[[ 
ESP Library por Referência de Caminho (Path)
Suporte: Linha, Caixa, Nome, Distância
Autor: DH Soares
--]]

--// Serviços
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

--// Objeto principal
local ESP = {
	Enabled = true,
	Color = Color3.fromRGB(0, 255, 0),
	ShowLine = true,
	ShowBox = true,
	ShowDistance = true,
	ShowName = true,
	Tracked = {} -- { Path = string, Object = Instance }
}

--// Utilitários de desenho
local function DrawText(text, pos, color)
	local obj = Drawing.new("Text")
	obj.Text = text
	obj.Position = pos
	obj.Color = color
	obj.Size = 13
	obj.Outline = true
	obj.Center = true
	obj.Visible = true
	return obj
end

local function DrawLine(from, to, color)
	local obj = Drawing.new("Line")
	obj.From = from
	obj.To = to
	obj.Color = color
	obj.Thickness = 1
	obj.Visible = true
	return obj
end

local function DrawBox(center, size, color)
	local box = {}
	local half = size / 2
	local topLeft = center - half
	local topRight = Vector2.new(topLeft.X + size.X, topLeft.Y)
	local bottomLeft = Vector2.new(topLeft.X, topLeft.Y + size.Y)
	local bottomRight = topLeft + size

	box[1] = DrawLine(topLeft, topRight, color)
	box[2] = DrawLine(topRight, bottomRight, color)
	box[3] = DrawLine(bottomRight, bottomLeft, color)
	box[4] = DrawLine(bottomLeft, topLeft, color)

	return box
end

--// Função para resolver string path -> Instance
local function ResolvePath(path)
	local current = game
	for segment in string.gmatch(path, "[^%.]+") do
		current = current:FindFirstChild(segment)
		if not current then return nil end
	end
	return current
end

--// Adiciona objeto por path
function ESP:AddPath(path)
	local obj = ResolvePath(path)
	if obj and obj:IsA("BasePart") then
		table.insert(self.Tracked, {
			Path = path,
			Object = obj
		})
	end
end

--// Remove objeto por path
function ESP:RemovePath(path)
	for i, data in ipairs(self.Tracked) do
		if data.Path == path then
			table.remove(self.Tracked, i)
			break
		end
	end
end

--// Loop de desenho
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for _, entry in ipairs(ESP.Tracked) do
		local obj = entry.Object
		if obj and obj:IsA("BasePart") and obj:IsDescendantOf(workspace) then
			local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
			if onScreen then
				local screenPos = Vector2.new(pos.X, pos.Y)
				local dist = (Camera.CFrame.Position - obj.Position).Magnitude
				local color = ESP.Color

				-- ESP elementos
				local lineObj, boxObj, textObj, distObj

				if ESP.ShowLine then
					lineObj = DrawLine(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y), screenPos, color)
				end

				if ESP.ShowBox then
					local size2D = Vector2.new(60 / pos.Z, 100 / pos.Z)
					boxObj = DrawBox(screenPos, size2D, color)
				end

				if ESP.ShowName then
					textObj = DrawText(obj.Name, screenPos + Vector2.new(0, -30), color)
				end

				if ESP.ShowDistance then
					distObj = DrawText(string.format("%.1f studs", dist), screenPos + Vector2.new(0, -15), color)
				end

				-- Remove os desenhos no próximo frame
				RunService.RenderStepped:Once(function()
					if lineObj then lineObj:Remove() end
					if textObj then textObj:Remove() end
					if distObj then distObj:Remove() end
					if boxObj then
						for _, l in ipairs(boxObj) do
							l:Remove()
						end
					end
				end)
			end
		end
	end
end)

--// Exemplo de uso:
ESP:AddPath("workspace.Part") -- substitua por qualquer endereço válido
ESP:AddPath("workspace.Model.Lamp")

--// Configurações (opcional)
ESP.Color = Color3.fromRGB(255, 255, 0)
ESP.ShowLine = true
ESP.ShowBox = true
ESP.ShowDistance = true
ESP.ShowName = true

--// Para desativar tudo:
-- ESP.Enabled = false
