# 🌦️ Reactive Weather (Client Showcase)

This repository contains the client-side logic of **Reactive Weather** — a smooth and dynamic weather controller built for FiveM.  
This version is a **showcase-only** release, focused on the client logic and interpolation system.

---

## ✨ Features

- Smooth weather transitions (fully interpolated)
- Handles rain, fog, wind, tint, cloudiness, etc.
- Supports snapshot + delta updates
- Optional gameplay modifiers (traction, visibility…)
- Lightweight and clean logic
- Includes simple exports for external scripts

---

## 📁 Included File

- **client.lua** — full dynamic weather logic  
  *(No server-side code in this showcase.)*

---

## 🛠️ Exports

```lua
exports['reactive_weather']:GetCurrentWeather()
exports['reactive_weather']:IsTransitioning()
