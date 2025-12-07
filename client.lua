local currentWeather, targetWeather
local transitionStart = 0
local transitionDuration = Config.Presets.transition_duration or 5.0
local isTransitioning = false

local function applyWeather(w)
    if not w then return end

    SetWeatherTypeNowPersist(w.weather)
    SetRainLevel(w.rain or 0.0)
    SetWindSpeed(w.wind or 0.0)
    SetWindDirection((w.wind or 0.0) * 360.0)

    if w.fog and w.fog > 0.0 then
        SetFogDensity(w.fog)
    end

    if w.tint then
        SetTimecycleModifier('default')
        local brightness = (w.tint.r + w.tint.g + w.tint.b) / 765.0
        if brightness < 1.0 then
            SetTimecycleModifierStrength(1.0 - brightness)
        end
    end
end

local function interpolateWeather(from, to, t)
    if not from or not to then return to end
    t = math.max(0.0, math.min(1.0, t))
    local lerp = Util.lerp

    return {
        weather = to.weather,
        cloudiness = lerp(from.cloudiness, to.cloudiness, t),
        rain = lerp(from.rain, to.rain, t),
        wind = lerp(from.wind, to.wind, t),
        fog = lerp(from.fog, to.fog, t),
        tint = {
            r = math.floor(lerp(from.tint.r, to.tint.r, t)),
            g = math.floor(lerp(from.tint.g, to.tint.g, t)),
            b = math.floor(lerp(from.tint.b, to.tint.b, t))
        },
        gameplay = to.gameplay
    }
end

local function decompressSnapshot(data)
    if not data or not data.w then return nil end

    return {
        weather = data.w,
        cloudiness = data.c or 0.0,
        rain = data.r or 0.0,
        wind = data.wi or 0.0,
        fog = data.f or 0.0,
        tint = data.t or { r = 255, g = 255, b = 255 },
        gameplay = data.g or {
            traction_mult = 1.0,
            visibility_mult = 1.0,
            economy_mult = 1.0
        }
    }
end

local function applyDelta(base, delta)
    if not base then return nil end
    local out = Util.deepCopy(base)

    out.weather = delta.w or out.weather
    out.cloudiness = delta.c or out.cloudiness
    out.rain = delta.r or out.rain
    out.wind = delta.wi or out.wind
    out.fog = delta.f or out.fog
    out.tint = delta.t or out.tint
    out.gameplay = delta.g or out.gameplay

    return out
end

RegisterNetEvent('reactive_weather:snapshot', function(data)
    local w = decompressSnapshot(data)
    if not w then return end

    if not currentWeather then
        currentWeather, targetWeather = w, w
        applyWeather(w)
        return
    end

    targetWeather = w
    transitionStart = GetGameTimer()
    isTransitioning = true
end)

RegisterNetEvent('reactive_weather:delta', function(delta)
    if not currentWeather then
        return TriggerServerEvent('reactive_weather:request_snapshot')
    end

    local base = targetWeather or currentWeather
    local newTarget = applyDelta(base, delta)
    if newTarget then
        targetWeather = newTarget
        if not isTransitioning then
            transitionStart = GetGameTimer()
            isTransitioning = true
        end
    end
end)

AddEventHandler('onClientResourceStart', function(res)
    if res == GetCurrentResourceName() then
        Wait(1500)
        TriggerServerEvent('reactive_weather:request_snapshot')
    end
end)

CreateThread(function()
    while true do
        if isTransitioning and currentWeather and targetWeather then
            local now = GetGameTimer()
            local progress = math.min(1.0, (now - transitionStart) / (transitionDuration * 1000.0))
            applyWeather(interpolateWeather(currentWeather, targetWeather, progress))

            if progress >= 1.0 then
                currentWeather = targetWeather
                isTransitioning = false
            end
        elseif currentWeather then
            applyWeather(currentWeather)
        end
        Wait(100)
    end
end)

CreateThread(function()
    while true do
        if currentWeather and currentWeather.gameplay then
            local g = currentWeather.gameplay

            if Config.Gameplay.enable_traction_modifier then
                SetVehicleGravityMultiplier(g.traction_mult or 1.0)
            end
            if Config.Gameplay.enable_visibility_modifier then
                SetTimecycleModifierStrength(1.0 - (g.visibility_mult or 1.0))
            end
        end
        Wait(1000)
    end
end)

exports('GetCurrentWeather', function() return currentWeather end)
exports('IsTransitioning', function() return isTransitioning end)
