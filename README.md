<div align="center">

# 🎨 Temmies Instance Animator
### The Ultimate General-Purpose Animation Suite for Roblox

<img src="assets/main-menu.png" width="45%" /> <img src="assets/ui-screenshot.png" width="45%" />

### 🚀 Stop Rigging. Start Animating.

**T.I.A.** breaks the chains of traditional Roblox animation. No Motor6Ds, no rigging, no limitations.
If it exists in the Explorer, **you can animate it.**

[![Roblox](https://img.shields.io/badge/Platform-Roblox-red.svg)](https://www.roblox.com)

[⬇️ Download Latest Release](https://github.com/T3mm1epurple/TemmiesInstanceAnimator/releases)

</div>

---

## ✨ Why T.I.A?

Most animation plugins force you to use character rigs. **Temmies Instance Animator** is designed for everything else. Whether you are making complex UI transitions, moving platforms, flickering lights, or custom visual effects, T.I.A handles it with a familiar, timeline-based workflow.

### 🔑 Key Features

| Feature | Description |
| :--- | :--- |
| **Universal Support** | Animate Parts, UIs, Decals, Lights, Textures—anything with a property. |
| **Multi-Instance** | Animate multiple objects in a single timeline with perfect synchronization. |
| **Precision Timing** | Give every single property its own Easing Style, Direction, and Duration. |
| **Property Locking** | Lock specific properties to prevent accidental edits while animating. |
| **Looping & Sync** | Create infinitely looping animations or perfectly sync multiple objects. |
| **Relative Tweening** | Use **Addition Mode** to add to values (e.g., `Size + 5`) rather than setting them absolutely. |

---

## 🎥 Showcase

### Complex UI Animations
Perfect for hover effects, loading screens, and menu transitions without writing complex tween scripts manually.

<div align="center">
  <video src="assets/hover-button.mp4" controls width="48%"></video>
  <video src="assets/loading-bar.mp4" controls width="48%"></video>
</div>

### Physical Environment & Movement
Bring your map to life with moving platforms, machinery, and dynamic lighting.

<div align="center">
  <video src="assets/cog-wheel.mp4" controls width="48%"></video>
  <video src="assets/simple-move.mp4" controls width="48%"></video>
</div>

---

## 🛠️ Powerful Tools Under the Hood

### ➕ Addition Mode (Relative Tweening)
Most tweens set a value to a specific number (e.g., `Size = 10`). **Addition Mode** treats your keyframes as *offsets*.
* **Example:** Define a keyframe as `+5 Size`.
* **Result:** The object grows by 5 studs, regardless of its original size.

### 🔒 Property Disabling & Locking
* **Disable:** Right-click a property to ignore it completely (keep timelines clean).
* **Lock:** Prevent specific properties from being edited accidentally.

### 📝 Live Editing
Need to tweak an animation? Just select the object or the saved **ModuleScript**, and T.I.A will load the timeline right back up.

---

## 📥 Installation

### Method 1: Local Plugin (Recommended)
1. Go to the [**Releases Page**](https://github.com/T3mm1epurple/TemmiesInstanceAnimator/releases).
2. Download the latest `.rbxmx` file.
3. Drag and drop the file into your Roblox Studio **Plugins Folder**.

---

## 💻 API & Usage

Playing animations in-game is incredibly optimized. The plugin compiles your animation into a lightweight `ModuleScript`.

### 1. Setup
1. **Export:** Your animation saves as a ModuleScript inside your object.
2. **Insert API:** Click "Insert Module" in the plugin ui to get the `T.I.A` engine (Will be placed in `ReplicatedStorage`).

### 2. Scripting
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TIA = require(ReplicatedStorage:WaitForChild("T.I.A"))

-- Locate your generated animation module
local MyAnimModule = script.Parent.TemmieTweens.MyAnimation

-- Load the animation track
local track = TIA:Load(MyAnimModule)

-- Play the animation
track.Play()
```
