-- Xtray Script Hub
-- Version: 1.0.0
-- Author: Xtray
-- GitHub: https://github.com/ScXtray/all-In-One

local ScriptVersion = "1.0.0"
local ScriptName    = "Xtray Hub"

-- Supported Games
local Games = {
    [2753915549]     = "BloxFruits", -- Sea 1 (old)
    [85211729168715] = "BloxFruits", -- Sea 1 (new)
    [4442272183]     = "BloxFruits", -- Sea 2 (old)
    [79091703265657] = "BloxFruits", -- Sea 2 (new)
    [7449423635]     = "BloxFruits", -- Sea 3 (old)
    [100117331123089]= "BloxFruits", -- Sea 3 (new)
}

local PlaceId = game.PlaceId
local GameName = Games[PlaceId]

if not GameName then
    warn("[Xtray] Game not supported: " .. PlaceId)
    return
end

-- Load game script
local success, err = pcall(function()
    local url = "https://raw.githubusercontent.com/ScXtray/all-In-One/main/Games/" .. GameName .. ".lua"
    loadstring(game:HttpGet(url))()
end)

if not success then
    warn("[Xtray] Failed to load: " .. tostring(err))
end
