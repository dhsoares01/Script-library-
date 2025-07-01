-- Carrega a Library da pasta
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local UI = Library:Create("Orion Library")

local Tab1 = UI:CreateTab("Tab 1")
Tab1:AddLabel("Label")
Tab1:AddParagraph("Paragraph", [[
Suspendisse ut sapien at diam tincidunt sagittis et sit amet felis.
Quisque vulputate ullamcorper enim sit amet venenatis. Donec vestibulum orci enim...
]])
Tab1:AddButton("Button", function()
	print("Botão clicado!")
end)
Tab1:AddToggle("Toggle", function(state)
	print("Toggle:", state)
end)
