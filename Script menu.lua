local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()
local ui = lib:Create("Menu Personalizado")

local tab = ui:CreateTab("Principal")

-- Label
tab:AddLabel("Lobray DH SOARES")

-- Botão
tab:AddButton("Clique aqui", function()
    print("Botão foi clicado!")
end)

-- Toggle
tab:AddToggle("Click (on/off)", false, function(state)
    print("Modo escuro:", state and "ativado" or "desativado")
end)

-- Slider
tab:AddSlider("Slider ", 0, 100, 50, function(value)
    print("Volume:", value)
end)
