-- ============================================
-- ELBESTADT HUB - STANDALONE VERSION
-- ============================================
-- Script tout-en-un pour The Forge
-- Tous les modules sont intégrés dans ce fichier

-- ============================================
-- UTILS MODULE
-- ============================================

local Utils = {}

function Utils.GetCharacter()
    local player = game.Players.LocalPlayer
    return workspace.Living:FindFirstChild(player.Name)
end

function Utils.UnloadUI()
    if getgenv().Library then
        if getgenv().Library.Unload then
            getgenv().Library:Unload()
        end
        getgenv().Library = nil
        getgenv().Options = nil
        getgenv().Toggles = nil
    end

    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Linoria") or gui.Name:find("mspaint")) then
            gui:Destroy()
        end
    end
end

getgenv().Utils = Utils

pcall(Utils.UnloadUI)

-- ============================================
-- CHARGEMENT LINORIA
-- ============================================

local linoriaRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(linoriaRepo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(linoriaRepo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(linoriaRepo .. "addons/SaveManager.lua"))()

getgenv().Library = Library

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

-- ============================================
-- CRÉATION FENÊTRE
-- ============================================

local Window = Library:CreateWindow({
    Title = "Elbestadt Hub",
    Footer = "version: 1.0.0",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Home = Window:AddTab("Home", "house"),
    Main = Window:AddTab("Main", "menu"),
    Player = Window:AddTab("Player","user"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Purchases = Window:AddTab("Purchases", "dollar-sign"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ============================================
-- PLAYER MODULE
-- ============================================

local HumanModCons = {}
local normalWalkSpeed = 16
local normalJumpPower = 50

local PlayerTab = Tabs.Player
local MovementsGroup = PlayerTab:AddLeftGroupbox("Movements")

-- WalkSpeed
MovementsGroup:AddToggle("WalkspeedToggle", {
    Text = "Enable WalkSpeed",
    Default = false,
    Tooltip = "Active ou désactive la modification de vitesse",
    Callback = function(Value)
        if Value then
            local character = Utils.GetCharacter()
            if not character then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            local function ApplyWalkSpeed()
                if humanoid then
                    humanoid.WalkSpeed = Options.WalkspeedSlider.Value
                end
            end

            ApplyWalkSpeed()

            if HumanModCons.wsLoop then
                HumanModCons.wsLoop:Disconnect()
            end

            HumanModCons.wsLoop = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(ApplyWalkSpeed)

            if HumanModCons.wsCA then
                HumanModCons.wsCA:Disconnect()
            end

            HumanModCons.wsCA = workspace.Living.ChildAdded:Connect(function(child)
                local player = game.Players.LocalPlayer
                if child.Name == player.Name then
                    task.wait(0.5)
                    humanoid = child:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        ApplyWalkSpeed()
                        if HumanModCons.wsLoop then
                            HumanModCons.wsLoop:Disconnect()
                        end
                        HumanModCons.wsLoop = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(ApplyWalkSpeed)
                    end
                end
            end)
        else
            if HumanModCons.wsLoop then
                HumanModCons.wsLoop:Disconnect()
                HumanModCons.wsLoop = nil
            end
            if HumanModCons.wsCA then
                HumanModCons.wsCA:Disconnect()
                HumanModCons.wsCA = nil
            end

            local character = Utils.GetCharacter()
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = normalWalkSpeed
                end
            end
        end
    end
})

MovementsGroup:AddSlider("WalkspeedSlider", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        if Toggles.WalkspeedToggle.Value then
            local character = Utils.GetCharacter()
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = Value
                end
            end
        end
    end
})

-- JumpPower
MovementsGroup:AddToggle("JumppowerToggle", {
    Text = "Enable JumpPower",
    Default = false,
    Tooltip = "Active ou désactive la modification de saut",
    Callback = function(Value)
        if Value then
            local character = Utils.GetCharacter()
            if not character then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            local function ApplyJumpPower()
                if humanoid then
                    humanoid.JumpPower = Options.JumppowerSlider.Value
                end
            end

            ApplyJumpPower()

            if HumanModCons.jpLoop then
                HumanModCons.jpLoop:Disconnect()
            end

            HumanModCons.jpLoop = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(ApplyJumpPower)

            if HumanModCons.jpCA then
                HumanModCons.jpCA:Disconnect()
            end

            HumanModCons.jpCA = workspace.Living.ChildAdded:Connect(function(child)
                local player = game.Players.LocalPlayer
                if child.Name == player.Name then
                    task.wait(0.5)
                    humanoid = child:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        ApplyJumpPower()
                        if HumanModCons.jpLoop then
                            HumanModCons.jpLoop:Disconnect()
                        end
                        HumanModCons.jpLoop = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(ApplyJumpPower)
                    end
                end
            end)
        else
            if HumanModCons.jpLoop then
                HumanModCons.jpLoop:Disconnect()
                HumanModCons.jpLoop = nil
            end
            if HumanModCons.jpCA then
                HumanModCons.jpCA:Disconnect()
                HumanModCons.jpCA = nil
            end

            local character = Utils.GetCharacter()
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = normalJumpPower
                end
            end
        end
    end
})

MovementsGroup:AddSlider("JumppowerSlider", {
    Text = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        if Toggles.JumppowerToggle.Value then
            local character = Utils.GetCharacter()
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = Value
                end
            end
        end
    end
})

-- ============================================
-- FORGE MODULE
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainTab = Tabs.Main
local ForgeGroup = MainTab:AddLeftGroupbox("Forge")


ForgeGroup:AddToggle("AutoForgeToggle", {
    Text = "Enable Auto Forge",
    Default = false,
    Tooltip = "Active ou désactive la forge automatique",
    
})



local function AutoForge()
    local RunService = game:GetService("RunService")

    local currentPhase = nil
    local isForging = false

    -- fonction pour detecter la phase actuelle
    local function getPhase()
        local playerGUI = Players.LocalPlayer.PlayerGui
        if not playerGUI then return nil end

        local forgeUI = Players.LocalPlayer.PlayerGui.Forge
        if not forgeUI then return nil end

        if forgeUI:FindFirstChild("MeltMiniGame") and forgeUI.MeltMiniGame.Visible then
            return "Melt"
        elseif forgeUI:FindFirstChild("PourMiniGame") and forgeUI.PourMiniGame:Visible then
            return "Pour"
        elseif forgeUI:FindFirstChild("HammerMiniGame") and forgeUI.HammerMiniGame.Visible then
            return "Hammer"
        end
        
        return nil
    end


    -- fonction pour passer à la prochaine phase
    task.spawn(function()
        while true do
            task.wait(0.1)
    
            if Toggles.AutoForgeToggle.Value then
                local phase = getPhase()
                
                -- Si on détecte une nouvelle phase
                if phase and phase ~= currentPhase then
                    currentPhase = phase
                    print("[Forge] Nouvelle phase détectée:", phase)
                    
                    -- Skip vers la prochaine phase
                    if phase == "Melt" then
                        
                        
                    elseif phase == "Pour" then
                        
                        
                    elseif phase == "Hammer" then
                        
                        
                    end
                end
                
                -- Reset si plus dans la forge
                if not phase then
                    currentPhase = nil
                end
            end
        end
    end)
end

AutoForge()
            













-- ============================================
-- ESP MODULE
-- ============================================


-- ============================================
-- PURCHASES MODULE
-- ============================================


-- ============================================
-- UI SETTINGS
-- ============================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("ElbestadtHub")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    print("[Elbestadt Hub] UI déchargée")
end)

Library.ToggleKeybind = Options.MenuKeybind or Enum.KeyCode.RightShift

Library:Notify("Elbestadt Hub chargé avec succès!", 5)
Library:Notify("Appuie sur RightShift pour toggle l'UI", 5)
