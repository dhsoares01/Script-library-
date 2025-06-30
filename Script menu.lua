local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()
local ui = lib:Create("Menu Personalizado")

local tab = ui:CreateTab("Principal")
tab:AddLabel("Bem-vindo, Lucas!")
tab:AddButton("Clique aqui", function()
    print("Botão foi clicado!")
end)
