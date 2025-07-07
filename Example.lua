local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local menu = Library:CreateMenu("Meu Menu")

menu:CreateToggle("Ativar Modo X", function(state)
	print("Toggle:", state)
end)

menu:CreateSlider("Volume", 0, 100, 50, function(val)
	print("Slider:", val)
end)

menu:CreateButton("Clique aqui", function()
	print("Botão pressionado!")
end)

menu:CreateMenuOptions("Escolha uma cor", {"Vermelho", "Verde", "Azul"}, function(opt)
	print("Cor escolhida:", opt)
end)

menu:CreateRichText("<b>Texto formatado:</b> <i>exemplo em itálico</i>")
