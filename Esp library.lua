--// LibraryESP.lua    

local Camera = workspace.CurrentCamera    
local Players = game:GetService("Players")    
local RunService = game:GetService("RunService")    
local LocalPlayer = Players.LocalPlayer    

local LibraryESP = {}    
local ESPObjects = {}    

--// Configurações globais    
LibraryESP.TextPosition = "Top" -- Top, Center, Bottom, Below, LeftSide, RightSide    
LibraryESP.LineFrom = "Bottom" -- Top, Center, Bottom, Below, Left, Right    

--// Funções de desenho    

-- Texto com sombra    
local function DrawText(size, color)    
    local text = Drawing.new("Text")    
    text.Size = size    
    text.Center = true    
    text.Outline = false    
    text.Font = 2    
    text.Color = color    
    text.Visible = false    

    local shadow = Drawing.new("Text")    
    shadow.Size = size    
    shadow.Center = true    
    shadow.Outline = false    
    shadow.Font = 2    
    shadow.Color = Color3.new(0,0,0)    
    shadow.Transparency = 0.4    
    shadow.Visible = false    

    function text:SetPosition(pos)    
        text.Position = pos    
        shadow.Position = pos + Vector2.new(1, 1)    
    end    
    function text:SetText(txt)    
        text.Text = txt    
        shadow.Text = txt    
    end    
    function text:SetVisible(v)    
        text.Visible = v    
        shadow.Visible = v    
    end    
    function text:Remove()    
        text:Remove()    
        shadow:Remove()    
    end    

    return text    
end    

-- Caixa com borda dupla e cantos arredondados simulados    
local function DrawFancyBox(color)    
    local box = {}    

    box.bg = Drawing.new("Square")    
    box.bg.Color = Color3.new(color.R, color.G, color.B)    
    box.bg.Transparency = 0.15    
    box.bg.Thickness = 6    
    box.bg.Filled = false    
    box.bg.Visible = false    

    box.fg = Drawing.new("Square")    
    box.fg.Color = color    
    box.fg.Thickness = 1.5    
    box.fg.Filled = false    
    box.fg.Visible = false    

    box.corners = {}    
    local cornerSize = 6    
    local thickness = 1.5    

    local function createCorner()    
        return {    
            Drawing.new("Line"), -- horizontal    
            Drawing.new("Line")  -- vertical    
        }    
    end    

    for i=1,4 do    
        local h, v = createCorner()    
        h.Thickness = thickness    
        v.Thickness = thickness    
        h.Color = color    
        v.Color = color    
        h.Visible = false    
        v.Visible = false    
        table.insert(box.corners, {h, v})    
    end    

    function box:SetPosition(pos)    
        box.bg.Position = pos    
        box.fg.Position = pos    

        local x, y = pos.X, pos.Y    
        local w, h = box:GetSize()    

        -- Superior esquerdo    
        box.corners[1][1].From = Vector2.new(x, y)    
        box.corners[1][1].To = Vector2.new(x + cornerSize, y)    
        box.corners[1][2].From = Vector2.new(x, y)    
        box.corners[1][2].To = Vector2.new(x, y + cornerSize)    

        -- Superior direito    
        box.corners[2][1].From = Vector2.new(x + w - cornerSize, y)    
        box.corners[2][1].To = Vector2.new(x + w, y)    
        box.corners[2][2].From = Vector2.new(x + w, y)    
        box.corners[2][2].To = Vector2.new(x + w, y + cornerSize)    

        -- Inferior esquerdo    
        box.corners[3][1].From = Vector2.new(x, y + h)    
        box.corners[3][1].To = Vector2.new(x + cornerSize, y + h)    
        box.corners[3][2].From = Vector2.new(x, y + h - cornerSize)    
        box.corners[3][2].To = Vector2.new(x, y + h)    

        -- Inferior direito    
        box.corners[4][1].From = Vector2.new(x + w - cornerSize, y + h)    
        box.corners[4][1].To = Vector2.new(x + w, y + h)    
        box.corners[4][2].From = Vector2.new(x + w, y + h - cornerSize)    
        box.corners[4][2].To = Vector2.new(x + w, y + h)    
    end    

    function box:SetSize(size)    
        box.bg.Size = size    
        box.fg.Size = size    
    end    

    function box:GetSize()    
        return box.bg.Size    
    end    

    function box:SetVisible(v)    
        box.bg.Visible = v    
        box.fg.Visible = v    
        for _,corner in pairs(box.corners) do    
            corner[1].Visible = v    
            corner[2].Visible = v    
        end    
    end    

    function box:Remove()    
        box.bg:Remove()    
        box.fg:Remove()    
        for _,corner in pairs(box.corners) do    
            corner[1]:Remove()    
            corner[2]:Remove()    
        end    
    end    

    return box    
end    

-- Linha tracer com efeito gradiente (duas linhas)    
local function DrawFancyLine(color)    
    local line1 = Drawing.new("Line")    
    line1.Thickness = 3    
    line1.Color = Color3.new(color.R, color.G, color.B)    
    line1.Transparency = 0.2    
    line1.Visible = false    

    local line2 = Drawing.new("Line")    
    line2.Thickness = 1.5    
    line2.Color = color    
    line2.Visible = false    

    return {    
        SetFromTo = function(self, from, to)    
            line1.From = from    
            line1.To = to    
            line2.From = from    
            line2.To = to    
        end,    
        SetVisible = function(self, v)    
            line1.Visible = v    
            line2.Visible = v    
        end,    
        Remove = function(self)    
            line1:Remove()    
            line2:Remove()    
        end    
    }    
end    

-- Cria ESP com novo design    
function LibraryESP:CreateESP(object, options)    
    local esp = {    
        Object = object,    
        Options = options,    
        NameText = options.Name and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,    
        DistanceText = options.Distance and DrawText(13, options.Color or Color3.new(1, 1, 1)) or nil,    
        TracerLine = options.Tracer and DrawFancyLine(options.Color or Color3.new(1, 1, 1)) or nil,    
        Box = options.Box and DrawFancyBox(options.Color or Color3.new(1, 1, 1)) or nil    
    }    

    table.insert(ESPObjects, esp)          
    return esp    
end    

-- Remove ESP    
function LibraryESP:RemoveESP(object)    
    for i = #ESPObjects, 1, -1 do    
        local esp = ESPObjects[i]    
        if esp.Object == object or object == nil then    
            if esp.NameText then esp.NameText:Remove() end    
            if esp.DistanceText then esp.DistanceText:Remove() end    
            if esp.TracerLine then esp.TracerLine:Remove() end    
            if esp.Box then esp.Box:Remove() end    
            table.remove(ESPObjects, i)    
        end    
    end    
end    

-- Calcula posição de texto    
local function getTextPosition(basePos, offsetType)    
    local offset = Vector2.new(0, 0)    

    if offsetType == "Top" then          
        offset = Vector2.new(0, -16)          
    elseif offsetType == "Center" then          
        offset = Vector2.new(0, 0)          
    elseif offsetType == "Bottom" then          
        offset = Vector2.new(0, 16)          
    elseif offsetType == "Below" then          
        offset = Vector2.new(0, 26)          
    elseif offsetType == "LeftSide" then          
        offset = Vector2.new(-40, 0)          
    elseif offsetType == "RightSide" then          
        offset = Vector2.new(40, 0)          
    end          

    return basePos + offset    
end    

-- Loop de atualização    
RunService.RenderStepped:Connect(function()    
    for i = #ESPObjects, 1, -1 do    
        local esp = ESPObjects[i]    
        local obj = esp.Object    

        if not obj or typeof(obj) ~= "Instance" or not obj:IsDescendantOf(workspace) then          
            if esp.NameText then esp.NameText:Remove() end          
            if esp.DistanceText then esp.DistanceText:Remove() end          
            if esp.TracerLine then esp.TracerLine:Remove() end          
            if esp.Box then esp.Box:Remove() end          
            table.remove(ESPObjects, i)          
        else          
            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)          
            local basePos = Vector2.new(pos.X, pos.Y)          

            if onScreen then          
                local distance = (Camera.CFrame.Position - obj.Position).Magnitude          

                -- Nome          
                if esp.NameText then          
                    esp.NameText:SetPosition(getTextPosition(basePos, LibraryESP.TextPosition))          
                    esp.NameText:SetText(tostring(obj.Name))          
                    esp.NameText:SetVisible(true)          
                end          

                -- Distância          
                if esp.DistanceText then          
                    esp.DistanceText:SetPosition(getTextPosition(basePos, LibraryESP.TextPosition) + Vector2.new(0, 14))          
                    esp.DistanceText:SetText(string.format("[%dm]", math.floor(distance)))          
                    esp.DistanceText:SetVisible(true)          
                end          

                -- Tracer          
                if esp.TracerLine then          
                    local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)          
                    if LibraryESP.LineFrom == "Top" then          
                        from = Vector2.new(Camera.ViewportSize.X / 2, 0)          
                    elseif LibraryESP.LineFrom == "Center" then          
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)          
                    elseif LibraryESP.LineFrom == "Below" then          
                        from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1.25)          
                    elseif LibraryESP.LineFrom == "Left" then          
                        from = Vector2.new(0, Camera.ViewportSize.Y / 2)          
                    elseif LibraryESP.LineFrom == "Right" then          
                        from = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y / 2)          
                    end          

                    esp.TracerLine:SetFromTo(from, basePos)          
                    esp.TracerLine:SetVisible(true)          
                end          

                -- Caixa          
                if esp.Box then          
                    local size = 30 / (distance / 10)          
                    local boxSize = Vector2.new(size, size * 1.5)          
                    esp.Box:SetSize(boxSize)          
                    esp.Box:SetPosition(Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2))          
                    esp.Box:SetVisible(true)          
                end          
            else          
                if esp.NameText then esp.NameText:SetVisible(false) end          
                if esp.DistanceText then esp.DistanceText:SetVisible(false) end          
                if esp.TracerLine then esp.TracerLine:SetVisible(false) end          
                if esp.Box then esp.Box:SetVisible(false) end          
            end          
        end          
    end    
end)    

return LibraryESP
