# Lua Menu Library - Roblox UI Library

A customizable and feature-rich UI library for Roblox Lua scripts, designed to work with executors like Delta via loadstring.

## Features

- **Modern UI Design**: Clean, responsive interface with smooth animations
- **Multiple Themes**: Pre-built themes including Dark, White, Dark Forte, and White+Dark
- **Extensive Customization**: Tailor the look and feel of your UI directly from a dedicated configuration tab.
- **Enhanced Controls**: 
  - Toggles
  - Sliders (for integers and **new: for floating-point numbers**)
  - Dropdown menus (single select and multi-select)
  - Buttons
  - Labels
- **Advanced Configuration System**:
  - **Persistent Settings**: Save and load all UI configurations (theme, colors, control states) to a file or clipboard.
  - **Dynamic Customization**: Change colors (accent, text), fonts, corner radius, and opacity on the fly.
  - **Window Size Presets**: Easily adjust the main window size.
- **Immersive Loading Screen**: 
  - Animated loading screen with a minimum display time (5 seconds).
  - Centralized logo and a smooth rotating loader.
  - Ensures settings are loaded before the main menu appears.
- **Flexible Window Controls**:
  - Draggable window for easy positioning.
  - Resizable frame allowing custom window dimensions.
  - Minimize/maximize functionality for convenience.
- **Responsive Design**: Adapts gracefully to different screen sizes.

## Usage

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua](https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua)"))()

local window = Library:CreateWindow("My Awesome Script")

local mainTab = window:CreateTab("Main")
mainTab:AddLabel("Welcome to my script!")
mainTab:AddToggle("Enable Feature", function(state)
    print("Feature is now", state and "ON" or "OFF")
end)

-- New: Example of a slider for floating-point numbers (e.g., for multipliers, percentages)
mainTab:AddFloatSlider("Damage Multiplier", 0.5, 5.0, 1.0, 1, function(value)
    print("Damage Multiplier set to:", value)
end)

local configTab = window:CreateTab("Settings")
configTab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

Controls
Basic Controls
 * :AddLabel(text) - Adds a static text label.
 * :AddButton(text, callback) - Adds a clickable button that executes a function on click.
 * :AddToggle(text, callback) - Adds an on/off toggle switch that reports its state.
Advanced Controls
 * :AddDropdownButtonOnOff(title, items, callback) - Creates a dropdown menu where multiple items can be toggled on or off.
 * :AddSelectDropdown(title, items, callback) - Creates a dropdown menu for selecting a single item from a list.
 * :AddSlider(text, min, max, default, callback) - Implements a slider for selecting integer values within a specified range.
 * :AddFloatSlider(text, min, max, default, decimals, callback) - NEW: Implements a slider for selecting floating-point values. decimals (optional, default 2) controls the number of decimal places for display and value snapping.
Configuration Tab
The library includes a robust, built-in "Config" tab that allows users to fully customize the UI:
 * Theme Selection: Switch between "Dark", "White", "Dark Forte", and "White and Dark".
 * Color Customization: Adjust accent and text colors.
 * Font Selection: Choose from various Roblox fonts.
 * Corner Radius Adjustment: Modify the roundness of UI elements.
 * Opacity Control: Set the transparency level of the entire menu.
 * Window Size Presets: Apply predefined window sizes ("Small", "Medium", "Large") or use a custom size (via resizing).
 * Save/Load Configuration: Persist your custom settings.
 * Theme Reset: Revert to the default theme settings.
Themes
Pre-built themes included:
 * Dark - Default dark theme with blue accent.
 * White - Light theme with blue accent.
 * Dark Forte - High-contrast dark theme with a vibrant pink accent.
 * White and Dark - A modern blend of a light background with a dark sidebar.
Technical Details
 * Utilizes Roblox's TweenService for smooth and professional animations.
 * Features a flexible configuration system that supports writefile and readfile (for executors), with a fallback to setclipboard and getclipboard for portability.
 * The loading screen is designed to ensure a minimum 5-second display time, providing a premium user experience.
 * Implements a responsive design with dynamic resizing, adapting the UI layout as the window size changes.
 * Optimized for performance, ensuring a fluid experience even with complex UI structures.
Requirements
 * Roblox Lua environment.
 * Executor with loadstring support (e.g., Delta, Synapse X, Script-Ware).
 * HTTP access enabled for remote script loading.
Installation
To use the library, simply load it via loadstring:
```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua](https://raw.githubusercontent.com/dhsoares01/Script-library-/refs/heads/main/Library.lua)"))()
```
