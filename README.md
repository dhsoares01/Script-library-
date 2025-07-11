# Lua Menu Library - Roblox UI Library

A customizable and feature-rich UI library for Roblox Lua scripts, designed to work with executors like Delta via loadstring.

## Features

- **Modern UI Design**: Clean, responsive interface with smooth animations
- **Multiple Themes**: Pre-built themes including Dark, White, Dark Forte, and White+Dark
- **Customizable Controls**: 
  - Toggles
  - Sliders
  - Dropdown menus (single select and multi-select)
  - Buttons
  - Labels
- **Configuration System**:
  - Save/load UI configurations
  - Customize colors, fonts, corner radius, and opacity
  - Persistent settings between sessions
- **Loading Screen**: 
  - Animated loading screen with minimum display time
  - Centered logo and rotating loader
- **Window Controls**:
  - Draggable window
  - Resizable frame
  - Minimize/maximize functionality
- **Responsive Design**: Adapts to different screen sizes

## Usage

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()

local window = Library:CreateWindow("My Awesome Script")

local mainTab = window:CreateTab("Main")
mainTab:AddLabel("Welcome to my script!")
mainTab:AddToggle("Enable Feature", function(state)
    print("Feature is now", state and "ON" or "OFF")
end)

local configTab = window:CreateTab("Settings")
configTab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

## Controls

### Basic Controls
- `:AddLabel(text)` - Adds a text label
- `:AddButton(text, callback)` - Adds a clickable button
- `:AddToggle(text, callback)` - Adds an on/off toggle switch

### Advanced Controls
- `:AddDropdownButtonOnOff(title, items, callback)` - Multi-select dropdown
- `:AddSelectDropdown(title, items, callback)` - Single-select dropdown
- `:AddSlider(text, min, max, default, callback)` - Value slider with range

### Configuration
The library includes a built-in configuration tab with:
- Theme selection
- Color customization
- Font selection
- Corner radius adjustment
- Opacity control
- Window size presets
- Save/Load configuration buttons
- Theme reset

## Themes

Pre-built themes included:
1. **Dark** - Default dark theme with blue accent
2. **White** - Light theme with blue accent
3. **Dark Forte** - High-contrast dark theme with pink accent
4. **White and Dark** - Light background with dark sidebar

## Technical Details

- Uses Roblox TweenService for smooth animations
- Supports clipboard configuration transfer
- Loading screen ensures minimum 5s display time
- Responsive design with dynamic resizing
- Optimized for performance

## Requirements

- Roblox Lua environment
- Executor with loadstring support (Delta, Synapse, etc.)
- HTTP access for remote loading

## Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua"))()
```
