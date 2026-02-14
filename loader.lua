local HttpService = game:GetService("HttpService")
local BASE_URL = "https://raw.githubusercontent.com/uniondeliver/tcheks-hub/main/"

local gamesJson = game:HttpGet(BASE_URL .. "games.json")
local data = HttpService:JSONDecode(gamesJson)

local currentPlaceId = game.PlaceId

for _, entry in ipairs(data.games) do
    if entry.placeId == currentPlaceId then
        local scriptCode = game:HttpGet(BASE_URL .. entry.script)
        loadstring(scriptCode)()
        return
    end
end
