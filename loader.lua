local HttpService = game:GetService("HttpService")
local BASE_URL = "https://raw.githubusercontent.com/YOURUSERNAME/tcheks-hub/main/"

-- Fetch games list
local gamesJson = game:HttpGet(BASE_URL .. "games.json")
local data = HttpService:JSONDecode(gamesJson)

-- Get current place ID
local currentPlaceId = game.PlaceId

-- Find matching script
for _, entry in ipairs(data.games) do
    if entry.placeId == currentPlaceId then
        print("[tcheks hub] Loading script for: " .. entry.name)
        local scriptCode = game:HttpGet(BASE_URL .. entry.script)
        loadstring(scriptCode)()
        return
    end
end

print("[tcheks hub] No script found for this game (PlaceId: " .. tostring(currentPlaceId) .. ")")
