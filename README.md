📦 README.md (CustomUILib)

# 🌙 CustomUILib — Roblox Menu Library

> A modern, lightweight UI library for creating beautiful, customizable menus in Lua scripts.  
> Compatible with executors like **Delta**, **Hydrogen**, **Fluxus**, and more.

![version](https://img.shields.io/badge/Version-1.0-blue)
![license](https://img.shields.io/badge/License-MIT-green)
![roblox](https://img.shields.io/badge/Roblox-Executor%20Compatible-red)

---

## ✨ Features

- Dark theme with customizable colors
- Tabs with optional icons
- Minimize/expand the entire menu
- Smooth drag, scroll & resize support
- Tween animations for a modern feel
- Widgets ready to use:
  - Labels
  - Buttons
  - Toggles
  - Sliders
  - Dropdown buttons ON/OFF

---

## ⚙️ How to use

Load the library via `loadstring`:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()


---

🚀 Quick example

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow("My Script Menu")

local Tab = Window:CreateTab("Main", "⭐")

Tab:AddLabel("Welcome to my script!")

Tab:AddButton("Click me", function()
    print("Button clicked!")
end)

local toggle = Tab:AddToggle("Enable something", function(state)
    print("Toggle:", state)
end)

Tab:AddSlider("Volume", 0, 100, 50, function(value)
    print("Slider:", value)
end)

local dropdown = Tab:AddDropdownButtonOnOff("Features", {"Aimbot", "ESP", "AutoFarm"}, function(states)
    print(states) -- table of selected features
end)

-- Example of manual control:
-- toggle:Set(true)
-- print(toggle:Get())
-- dropdown:Set("Aimbot", true)
-- local currentStates = dropdown:GetAll()


---

🎨 Custom theme

Edit the colors at the start of your script:

local theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Tab = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Stroke = Color3.fromRGB(60, 60, 60),
    ScrollViewBackground = Color3.fromRGB(20, 20, 20),
}


---

📌 Requirements & notes

Executor must support loadstring & HttpGet

Tested on Delta, Hydrogen, Fluxus

Fully script-rendered UI (no external assets)

Only needs CoreGui permissions



---

🤝 Contributing

Feel free to open a pull request to add new widgets, fix bugs, or improve performance! 🚀


---

📄 License

Released under the MIT License — free to use, modify and share.


---

<p align="center">
  <img src="https://raw.githubusercontent.com/dhsoares01/Script-library-/main/banner.svg" alt="CustomUILib banner" />
</p>
```
---
