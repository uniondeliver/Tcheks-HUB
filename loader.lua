local HttpService = game:GetService("HttpService")
local BASE_URL = "https://raw.githubusercontent.com/uniondeliver/Tcheks-HUB/main/"

local function fetch(url)
    return game:HttpGet(url .. "?t=" .. tostring(tick()))
end

local gamesJson = fetch(BASE_URL .. "games.json")
local data = HttpService:JSONDecode(gamesJson)

local currentPlaceId = game.PlaceId

for _, entry in ipairs(data.games) do
    if entry.placeId == currentPlaceId then
        local scriptCode = fetch(BASE_URL .. entry.script)
        loadstring(scriptCode)()
        return
    end
end
