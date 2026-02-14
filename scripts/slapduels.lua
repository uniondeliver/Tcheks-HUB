local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local character, hrp, humanoid

---Refresh character references on spawn.
local function refreshCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end

if player.Character then
    refreshCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
    refreshCharacter(char)
end)

---Check if the local player is alive.
local function isAlive()
    return character and hrp and hrp.Parent
        and humanoid and humanoid.Health > 0
end

local Window = Library:CreateWindow({
    Title = 'Slap Duels | Tcheks HUB',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Teleport = Window:AddTab('Teleport'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

---Disable anti-cheat on load.
task.spawn(function()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    local knit = packages and packages:FindFirstChild("Knit")
    local services = knit and knit:FindFirstChild("Services")
    local antiCheat = services and services:FindFirstChild("AntiCheatService")
    if antiCheat then
        antiCheat:Destroy()
        Library:Notify("destrroyed ac", 3)
    end
end)

local HitboxGroup = Tabs.Main:AddLeftGroupbox('Hitbox Extender')

local hitboxEnabled = false
local hitboxSize = 10
local hitboxTransparency = 0.5
local visualCache = {}
local hitboxConnections = {}

---Create a selection box visual on a target HRP.
local function createVisual(targetHrp)
    if visualCache[targetHrp] then return end
    local box = Instance.new("SelectionBox")
    box.Name = "HitboxVisual"
    box.Adornee = targetHrp
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = hitboxTransparency
    box.SurfaceTransparency = math.max(0, hitboxTransparency - 0.1)
    box.LineThickness = hitboxTransparency >= 1 and 0 or 0.07
    box.Visible = hitboxTransparency < 1
    box.Parent = targetHrp
    visualCache[targetHrp] = box
end

---Remove a selection box visual from a target HRP.
local function removeVisual(targetHrp)
    local box = visualCache[targetHrp]
    if box then
        box:Destroy()
        visualCache[targetHrp] = nil
    end
end

---Apply expanded hitbox to an enemy character.
local function applyHitbox(char)
    if not char or char == player.Character then return end
    local targetHrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not targetHrp or not hum or hum.Health <= 0 then return end

    targetHrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    targetHrp.CanCollide = false
    targetHrp.Transparency = 1
    createVisual(targetHrp)
end

---Remove expanded hitbox from a character.
local function removeHitbox(char)
    if not char then return end
    local targetHrp = char:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end

    targetHrp.Size = Vector3.new(2, 2, 1)
    targetHrp.CanCollide = true
    targetHrp.Transparency = 0
    removeVisual(targetHrp)
end

---Cleanup all hitboxes for every player.
local function cleanupAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            removeHitbox(plr.Character)
        end
    end
end

---Hook a player for hitbox tracking.
local function hookPlayer(plr)
    if plr == player then return end
    if hitboxConnections[plr] then return end

    local conns = {}

    conns.charAdded = plr.CharacterAdded:Connect(function(char)
        if not hitboxEnabled then return end
        local targetHrp = char:WaitForChild("HumanoidRootPart", 5)
        if not targetHrp then return end
        if hitboxEnabled then
            applyHitbox(char)
        end
    end)

    if plr.Character and hitboxEnabled then
        applyHitbox(plr.Character)
    end

    hitboxConnections[plr] = conns
end

---Unhook a player and remove their hitbox.
local function unhookPlayer(plr)
    local conns = hitboxConnections[plr]
    if conns then
        for _, conn in pairs(conns) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        hitboxConnections[plr] = nil
    end
    if plr.Character then
        removeHitbox(plr.Character)
    end
end

---Enable hitbox system for all players.
local function enableHitboxSystem()
    for _, plr in ipairs(Players:GetPlayers()) do
        hookPlayer(plr)
    end
end

---Disable hitbox system and cleanup.
local function disableHitboxSystem()
    for plr, _ in pairs(hitboxConnections) do
        unhookPlayer(plr)
    end
    cleanupAllHitboxes()
end

Players.PlayerAdded:Connect(function(plr)
    if hitboxEnabled then
        hookPlayer(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    unhookPlayer(plr)
end)

player.CharacterAdded:Connect(function()
    if hitboxEnabled then
        task.wait(0.5)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                applyHitbox(plr.Character)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not hitboxEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local targetHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and targetHrp.Size.X ~= hitboxSize then
                targetHrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                targetHrp.CanCollide = false
                targetHrp.Transparency = 1
            end
        end
    end
end)

HitboxGroup:AddToggle('HitboxEnabled', {
    Text = 'Enable Hitbox Extender',
    Default = false,
    Tooltip = 'Expand enemy hitboxes for easier hits',
    Callback = function(Value)
        hitboxEnabled = Value
        if Value then
            enableHitboxSystem()
        else
            disableHitboxSystem()
        end
    end
})

HitboxGroup:AddSlider('HitboxSize', {
    Text = 'Hitbox Size',
    Default = 10,
    Min = 5,
    Max = 20,
    Rounding = 0,
    Suffix = ' studs',
    Compact = false,
    Callback = function(Value)
        hitboxSize = Value
    end
})

HitboxGroup:AddSlider('HitboxTransparency', {
    Text = 'Visual Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        hitboxTransparency = Value
        for _, box in pairs(visualCache) do
            if box and box.Parent then
                box.Transparency = Value
                box.SurfaceTransparency = math.max(0, Value - 0.1)
                box.LineThickness = Value >= 1 and 0 or 0.07
                box.Visible = Value < 1
            end
        end
    end
})

HitboxGroup:AddDivider()
HitboxGroup:AddLabel('Red boxes show extended hitboxes', true)

local TeleportGroup = Tabs.Teleport:AddLeftGroupbox('Teleport to Goal')

---Get start and end goal parts.
local function getParts()
    return workspace:FindFirstChild("StartPart", true),
           workspace:FindFirstChild("EndPart", true)
end

---Blink teleport to a part and fire touch interest.
local function blinkToPart(part)
    if not part or not isAlive() then return false end

    local old = hrp.CFrame
    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.35)

    if typeof(firetouchinterest) == "function" then
        local touch = part:FindFirstChildOfClass("TouchInterest")
        if touch then
            pcall(firetouchinterest, hrp, part, 0)
            pcall(firetouchinterest, hrp, part, 1)
        end
    end

    hrp.CFrame = old
    return true
end

TeleportGroup:AddButton({
    Text = 'Teleport to Nearest Goal',
    Func = function()
        if not isAlive() then
            Library:Notify("Character not found! Wait for respawn.", 3)
            return
        end

        local s, e = getParts()
        if not s or not e then
            Library:Notify("Please enter a game first!\nThis will not work in lobby.", 3)
            return
        end

        local distToStart = (s.Position - hrp.Position).Magnitude
        local distToEnd = (e.Position - hrp.Position).Magnitude

        if distToStart < distToEnd then
            if blinkToPart(e) then
                Library:Notify("Teleported to End Goal!", 2)
            end
        else
            if blinkToPart(s) then
                Library:Notify("Teleported to Start Goal!", 2)
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to the closest goal'
})

TeleportGroup:AddDivider()
TeleportGroup:AddLabel('Works only in-game, not in lobby', true)


local DashGroup = Tabs.Teleport:AddRightGroupbox('Dash Forward')

local teleportStuds = 10
local lastUse = 0
local COOLDOWN = 0.10

---Dash forward by a given number of studs.
local function dashForward(studs)
    if not isAlive() then return end

    humanoid.WalkSpeed = 0
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    local look = hrp.CFrame.LookVector
    local pos = hrp.Position + (look * studs) + Vector3.new(0, 2, 0)
    hrp.CFrame = CFrame.new(pos, pos + look)

    RunService.Heartbeat:Wait()
    humanoid.WalkSpeed = 16
end

DashGroup:AddSlider('DashDistance', {
    Text = 'Dash Distance',
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = ' studs',
    Compact = false,
    Callback = function(Value)
        teleportStuds = Value
    end
})

DashGroup:AddLabel('Keybind:'):AddKeyPicker('DashKeybind', {
    Default = 'R',
    SyncToggleState = false,
    Mode = 'Hold',
    Text = 'Dash Forward',
    NoUI = false,
    Callback = function(Value)
        if not Value then return end
        if not isAlive() then return end

        if tick() - lastUse < COOLDOWN then
            return
        end

        lastUse = tick()

        if typeof(_G.thru) == "function" then
            pcall(_G.thru, teleportStuds)
        else
            dashForward(teleportStuds)
        end
    end
})

DashGroup:AddDivider()
DashGroup:AddLabel('Press keybind to dash in look direction', true)


local MiscGroup = Tabs.Main:AddRightGroupbox('Miscellaneous')

MiscGroup:AddToggle('ShowWatermark', {
    Text = 'Show Watermark',
    Default = true,
    Tooltip = 'Toggle the watermark bar',
    Callback = function(Value)
        Library:SetWatermarkVisibility(Value)
    end
})

MiscGroup:AddToggle('ShowFPS', {
    Text = 'Show FPS in Watermark',
    Default = true,
    Tooltip = 'Display FPS and ping in watermark',
})

MiscGroup:AddToggle('ShowKeybindList', {
    Text = 'Show Keybind List',
    Default = true,
    Tooltip = 'Toggle the keybind list on screen',
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

MiscGroup:AddDivider()

MiscGroup:AddButton({
    Text = 'Rejoin Server',
    Func = function()
        TeleportService:Teleport(game.PlaceId, player)
    end,
    DoubleClick = true,
    Tooltip = 'Double click to rejoin current server'
})


Library:SetWatermarkVisibility(true)

local FrameCounter = 0
local FPS = 60
local lastWatermarkUpdate = 0

---Update watermark with FPS and ping every second.
local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1

    local now = tick()
    if (now - lastWatermarkUpdate) >= 1 then
        FPS = FrameCounter
        FrameCounter = 0
        lastWatermarkUpdate = now

        if Toggles.ShowFPS and Toggles.ShowFPS.Value then
            Library:SetWatermark(string.format(
                'Tcheks HUB | %d fps | %d ms',
                FPS,
                math.floor(Stats.Network.ServerStatsItem['Data Ping']:GetValue())
            ))
        else
            Library:SetWatermark('Tcheks HUB')
        end
    end
end)

Library.KeybindFrame.Visible = true


---Cleanup on unload.
Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    disableHitboxSystem()
    Library.Unloaded = true
end)


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('SlapDuels')
SaveManager:SetFolder('SlapDuels/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

Library:Notify("Slap Duels loaded successfully!\nMade by nilly", 5)
