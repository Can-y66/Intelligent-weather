# Reactive Weather (Client Showcase)

This repository contains the client-side implementation of a dynamic, interpolated weather system for FiveM.  
The goal of this repo is to present clean, readable code and serve as a reference for future development.

## Overview

The client handles:
- Smooth, time-based transitions between weather states  
- Interpolation of rain, fog, wind, cloudiness and tint values  
- Snapshot and delta updates sent from the server  
- Optional gameplay modifiers (traction, visibility, etc.)  
- Minimal performance impact

Only the client logic is included here. Server-side examples and configuration files are intentionally omitted to keep this repository focused on code structure and readability.

## File Structure

- `client.lua` — Complete weather handling, interpolation logic and event processing.

## Exports

```lua
exports['reactive_weather']:GetCurrentWeather()
exports['reactive_weather']:IsTransitioning()
```

These functions allow other client resources to access the current weather state or check whether a transition is active.

Purpose

This repository exists to showcase:

A clean approach to client-side weather interpolation

Modular and maintainable architecture

A reference implementation for developers building custom weather systems or dynamic environmental effects

License

You are free to use, modify, or extend this code. Attribution is appreciated but not required.
