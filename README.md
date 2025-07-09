# 🏗️ Roblox GUI Library

**A lightweight and customizable GUI library for Roblox scripting**, designed to work with popular executors like Delta, Synapse, and others via `loadstring`.

## 📥 Installation
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
```

## ✨ Features
- **Modern UI Components**: Tabs, buttons, sliders, toggles, and more
- **Customizable Design**: Change colors, sizes, and layouts
- **Notification System**: Built-in alert system
- **ESP Integration**: Compatible with ESP modules
- **Lightweight**: Optimized for performance

## 🛠️ Basic Usage

### 1. Creating a Window
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
local Window = Library:CreateWindow("My Script")
```

### 2. Adding Tabs
```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
```

### 3. Adding Controls

#### Buttons
```lua
MainTab:AddButton("Teleport to Spawn", function()
    -- Your code here
end)
```

#### Sliders
```lua
MainTab:AddSlider("WalkSpeed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

#### Toggles
```lua
MainTab:AddToggle("God Mode", false, function(state)
    _G.GodMode = state
end)
```

#### Dropdowns
```lua
MainTab:AddDropdown("ESP Options", {"Box", "Name", "Distance"}, function(selections)
    _G.ESPBox = selections["Box"]
end)
```

## 🎨 Customization
```lua
-- Example of changing colors
Library:SetTheme({
    Primary = Color3.fromRGB(25, 25, 25),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 170, 255)
})
```

## 📌 Example Script
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()

local Window = Library:CreateWindow("Player Utilities")
local PlayerTab = Window:CreateTab("Player")

PlayerTab:AddSlider("Jump Power", 50, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

PlayerTab:AddToggle("Noclip", false, function(state)
    _G.Noclip = state
    -- Noclip implementation would go here
end)

PlayerTab:AddButton("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
```

## 📜 Documentation
| Method | Description |
|--------|-------------|
| `CreateWindow(title)` | Creates main window |
| `CreateTab(name, [icon])` | Adds a new tab |
| `AddButton(text, callback)` | Creates a clickable button |
| `AddSlider(text, min, max, default, callback)` | Creates adjustable slider |
| `AddToggle(text, default, callback)` | Creates on/off toggle |
| `AddDropdown(text, options, callback)` | Creates multi-select dropdown |

## ⚠️ Disclaimer
This library is intended for educational purposes only. Use at your own risk.

## 🌟 Credits
Developed by [@dhsoares01](https://github.com/dhsoares01)

---

> 💡 **Tip**: Combine with other libraries from the [Script Library](https://github.com/dhsoares01/Script-library-) for enhanced functionality!
