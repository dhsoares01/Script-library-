```markdown
# 📚 Script GUI Menu Library for Roblox

![Library Preview](https://i.imgur.com/YOUR_PREVIEW_IMAGE.png) *Replace with actual preview image*

A lightweight, feature-rich GUI library for Roblox script executors (Delta, Fluxus, Synapse, etc.) that simplifies creating interactive menus with a modern dark theme.

## 🌟 Features

### 🖥️ Window Management
- **Draggable** - Move the window anywhere on screen
- **Resizable** - Adjust size from the bottom-right corner
- **Minimize/Restore** - Save screen space when needed
- **Tab System** - Organize options into categorized tabs

### 🎨 UI Elements
| Element            | Description                                  |
|--------------------|----------------------------------------------|
| **Label**          | Display informational text                  |
| **Button**         | Execute functions with a click              |
| **Toggle**         | ON/OFF switches with visual feedback        |
| **DropdownButton** | Multi-select options (great for ESP menus)  |
| **SelectDropdown** | Single-select from multiple options         |
| **Slider**         | Adjust numeric values within a range        |

## ⚡ Quick Start

### Installation
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/main/Library.lua"))()
```

### Basic Example
```lua
local MyMenu = Library:CreateWindow("Cheat Menu")
local MainTab = MyMenu:CreateTab("Main", "⭐")

-- Add UI elements
MainTab:AddLabel("Player Modifications")

MainTab:AddButton("Reset Character", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
end)

local SpeedToggle = MainTab:AddToggle("Speed Hack", function(state)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
end)

MainTab:AddSlider("Jump Power", 10, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)
```

## 📖 Complete API Reference

### Window Creation
```lua
Library:CreateWindow(title: string?) -> Window
```
- `title`: Window title (default: "CustomUILib")

### Window Methods
```lua
Window:CreateTab(name: string, icon: string?) -> Tab
```
- `name`: Tab display name
- `icon`: Optional emoji/character icon

### Tab Methods
| Method                          | Description                                  |
|---------------------------------|----------------------------------------------|
| `AddLabel(text)`               | Adds informational text                     |
| `AddButton(text, callback)`    | Creates clickable button                    |
| `AddToggle(text, callback)`    | Creates ON/OFF toggle                       |
| `AddDropdownButtonOnOff(title, items, callback)` | Multi-select dropdown             |
| `AddSelectDropdown(title, items, callback)` | Single-select dropdown            |
| `AddSlider(text, min, max, default, callback)` | Value range selector           |

## 🛠️ Development Notes
- Built with **UDim2** for responsive positioning
- Uses **TweenService** for smooth animations
- Implements **UserInputService** for drag/resize functionality
- Single-file design for easy integration

## 🤝 Contributing
We welcome contributions! Please:
1. Open an Issue for bug reports/feature requests
2. Submit Pull Requests with clear descriptions
3. Maintain consistent code style

## 📜 License
MIT License - See [LICENSE](https://github.com/dhsoares01/Script-library-/blob/main/LICENSE) for details
```

### Key Improvements:
1. **Better Visual Hierarchy** - Clear sections with emoji icons
2. **Responsive Tables** - For comparing features/methods
3. **Code Highlighting** - Proper markdown code blocks
4. **Concise Language** - More direct explanations
5. **API Reference Table** - Easier to scan than paragraphs
6. **Placeholder for Preview Image** - Important for GUI libraries
7. **Consistent Formatting** - Uniform heading styles

Would you like me to:
1. Add a more detailed comparison table of UI elements?
2. Include troubleshooting section?
3. Add a version compatibility chart?
4. Include more complete code examples for each element type?
