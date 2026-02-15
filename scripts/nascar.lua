--[[
    NASCAR Racing Speed Script
    GUI: LinoriaLib
    Toggle Menu: End key (rebindable)
]]

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------
local function GetVehicleFromDescendant(Descendant)
    return
        Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car") or
        (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
        (Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
        Descendant:FindFirstAncestorWhichIsA("Model")
end

local function GetSeat()
    local Character = LocalPlayer.Character
    if not Character then return nil end
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return nil end
    local SeatPart = Humanoid.SeatPart
    if SeatPart and SeatPart:IsA("VehicleSeat") then
        return SeatPart
    end
    return nil
end

--------------------------------------------------------------
-- STATE
--------------------------------------------------------------
local defaultCharacterParent

--------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------
local Window = Library:CreateWindow({
    Title = 'NASCAR Speed Script',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Speed    = Window:AddTab('Speed'),
    Flight   = Window:AddTab('Flight'),
    Extras   = Window:AddTab('Extras'),
    Settings = Window:AddTab('Settings'),
}

--------------------------------------------------------------
-- SPEED TAB
--------------------------------------------------------------

-- == Acceleration ==
local AccelGroup = Tabs.Speed:AddLeftGroupbox('Acceleration')

AccelGroup:AddSlider('AccelMult', {
    Text = 'Velocity Multiplier',
    Default = 25,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = '/1000',
    Compact = false,
})

AccelGroup:AddLabel('Boost Key'):AddKeyPicker('AccelKey', {
    Default = 'W',
    Mode = 'Hold',
    Text = 'Acceleration Boost',
    SyncToggleState = false,
})

-- Acceleration loop
task.spawn(function()
    while true do
        task.wait()
        if Library.Unloaded then break end
        if Options.AccelKey:GetState() then
            local SeatPart = GetSeat()
            if SeatPart then
                local mult = Options.AccelMult.Value / 1000
                SeatPart.AssemblyLinearVelocity *= Vector3.new(1 + mult, 1, 1 + mult)
            end
        end
    end
end)

-- == Deceleration ==
local BrakeGroup = Tabs.Speed:AddLeftGroupbox('Deceleration')

BrakeGroup:AddSlider('BrakeMult', {
    Text = 'Brake Force',
    Default = 150,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Suffix = '/1000',
    Compact = false,
})

BrakeGroup:AddLabel('Brake Key'):AddKeyPicker('BrakeKey', {
    Default = 'S',
    Mode = 'Hold',
    Text = 'Quick Brake',
    SyncToggleState = false,
})

-- Brake loop
task.spawn(function()
    while true do
        task.wait()
        if Library.Unloaded then break end
        if Options.BrakeKey:GetState() then
            local SeatPart = GetSeat()
            if SeatPart then
                local mult = Options.BrakeMult.Value / 1000
                SeatPart.AssemblyLinearVelocity *= Vector3.new(1 - mult, 1, 1 - mult)
            end
        end
    end
end)

BrakeGroup:AddLabel('Instant Stop'):AddKeyPicker('StopKey', {
    Default = 'P',
    Mode = 'Toggle',
    Text = 'Instant Stop',
    SyncToggleState = false,
    NoUI = false,
})

Options.StopKey:OnClick(function()
    local SeatPart = GetSeat()
    if SeatPart then
        SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end)

-- == Nitro ==
local NitroGroup = Tabs.Speed:AddRightGroupbox('Nitro')

NitroGroup:AddSlider('NitroForce', {
    Text = 'Nitro Force',
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

NitroGroup:AddLabel('Nitro Key'):AddKeyPicker('NitroKey', {
    Default = 'F',
    Mode = 'Toggle',
    Text = 'Nitro Burst',
    SyncToggleState = false,
})

Options.NitroKey:OnClick(function()
    local SeatPart = GetSeat()
    if SeatPart then
        local lookDir = SeatPart.CFrame.LookVector
        SeatPart.AssemblyLinearVelocity = SeatPart.AssemblyLinearVelocity + lookDir * Options.NitroForce.Value
    end
end)

-- == MaxSpeed Override ==
local MaxSpeedGroup = Tabs.Speed:AddRightGroupbox('MaxSpeed Override')

MaxSpeedGroup:AddToggle('MaxSpeedEnabled', {
    Text = 'Override MaxSpeed',
    Default = false,
    Tooltip = 'Directly set the VehicleSeat MaxSpeed',
})

MaxSpeedGroup:AddSlider('MaxSpeedValue', {
    Text = 'Max Speed',
    Default = 200,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = false,
})

local function ApplyMaxSpeed()
    if Toggles.MaxSpeedEnabled.Value then
        local SeatPart = GetSeat()
        if SeatPart then
            SeatPart.MaxSpeed = Options.MaxSpeedValue.Value
        end
    end
end

Toggles.MaxSpeedEnabled:OnChanged(ApplyMaxSpeed)
Options.MaxSpeedValue:OnChanged(ApplyMaxSpeed)

-- == Torque Override ==
MaxSpeedGroup:AddDivider()

MaxSpeedGroup:AddToggle('TorqueEnabled', {
    Text = 'Override Torque',
    Default = false,
    Tooltip = 'Directly set the VehicleSeat Torque',
})

MaxSpeedGroup:AddSlider('TorqueValue', {
    Text = 'Torque',
    Default = 50,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

local function ApplyTorque()
    if Toggles.TorqueEnabled.Value then
        local SeatPart = GetSeat()
        if SeatPart then
            SeatPart.Torque = Options.TorqueValue.Value
        end
    end
end

Toggles.TorqueEnabled:OnChanged(ApplyTorque)
Options.TorqueValue:OnChanged(ApplyTorque)

--------------------------------------------------------------
-- FLIGHT TAB
--------------------------------------------------------------
local FlightGroup = Tabs.Flight:AddLeftGroupbox('Car Flight')

FlightGroup:AddToggle('FlightEnabled', {
    Text = 'Enable Flight',
    Default = false,
    Tooltip = 'Fly your car using WASD + Q/E for altitude',
})

FlightGroup:AddSlider('FlightSpeed', {
    Text = 'Flight Speed',
    Default = 100,
    Min = 0,
    Max = 800,
    Rounding = 0,
    Compact = false,
})

FlightGroup:AddLabel('Controls:')
FlightGroup:AddLabel('W/S = Forward/Back', true)
FlightGroup:AddLabel('A/D = Left/Right', true)
FlightGroup:AddLabel('E/Q = Up/Down', true)

RunService.Stepped:Connect(function()
    if Library.Unloaded then return end
    local Character = LocalPlayer.Character

    if Toggles.FlightEnabled.Value then
        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle:IsA("Model") then
                        Character.Parent = Vehicle
                        if not Vehicle.PrimaryPart then
                            if SeatPart.Parent == Vehicle then
                                Vehicle.PrimaryPart = SeatPart
                            else
                                Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
                            end
                        end

                        local speed = Options.FlightSpeed.Value / 100
                        local PrimaryCF = Vehicle:GetPrimaryPartCFrame()
                        local camLook = workspace.CurrentCamera.CFrame.LookVector
                        local moveOffset = CFrame.new(0, 0, 0)

                        if not UserInputService:GetFocusedTextBox() then
                            local x = (UserInputService:IsKeyDown(Enum.KeyCode.D) and speed) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -speed) or 0
                            local y = (UserInputService:IsKeyDown(Enum.KeyCode.E) and speed / 2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -speed / 2) or 0
                            local z = (UserInputService:IsKeyDown(Enum.KeyCode.S) and speed) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -speed) or 0
                            moveOffset = CFrame.new(x, y, z)
                        end

                        Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryCF.Position, PrimaryCF.Position + camLook) * moveOffset)
                        SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    else
        if Character then
            Character.Parent = defaultCharacterParent or Character.Parent
            defaultCharacterParent = Character.Parent
        end
    end
end)

--------------------------------------------------------------
-- EXTRAS TAB
--------------------------------------------------------------

-- == Anti-Flip ==
local StabilityGroup = Tabs.Extras:AddLeftGroupbox('Stability')

StabilityGroup:AddToggle('AntiFlip', {
    Text = 'Anti-Flip',
    Default = false,
    Tooltip = 'Prevents your car from flipping over at high speeds',
})

RunService.Heartbeat:Connect(function()
    if Library.Unloaded then return end
    if not Toggles.AntiFlip.Value then return end
    local SeatPart = GetSeat()
    if SeatPart then
        local up = SeatPart.CFrame.UpVector
        if up.Y < 0.7 then
            SeatPart.AssemblyAngularVelocity = Vector3.new(0, SeatPart.AssemblyAngularVelocity.Y, 0)
        end
    end
end)

-- == Springs ==
local SpringGroup = Tabs.Extras:AddLeftGroupbox('Debug')

SpringGroup:AddToggle('ShowSprings', {
    Text = 'Show Springs',
    Default = false,
    Tooltip = 'Visualize car spring constraints',
})

Toggles.ShowSprings:OnChanged(function()
    local SeatPart = GetSeat()
    if SeatPart then
        local Vehicle = GetVehicleFromDescendant(SeatPart)
        if Vehicle then
            for _, desc in pairs(Vehicle:GetDescendants()) do
                if desc:IsA("SpringConstraint") then
                    desc.Visible = Toggles.ShowSprings.Value
                end
            end
        end
    end
end)

-- == Info ==
local InfoGroup = Tabs.Extras:AddRightGroupbox('Live Stats')

local speedLabel = InfoGroup:AddLabel('Speed: 0')
local seatLabel = InfoGroup:AddLabel('Seat: None')

task.spawn(function()
    while true do
        task.wait(0.25)
        if Library.Unloaded then break end
        local SeatPart = GetSeat()
        if SeatPart then
            local speed = math.floor(SeatPart.AssemblyLinearVelocity.Magnitude)
            speedLabel:SetText('Speed: ' .. speed .. ' studs/s')
            seatLabel:SetText('MaxSpeed: ' .. SeatPart.MaxSpeed .. ' | Torque: ' .. SeatPart.Torque)
        else
            speedLabel:SetText('Speed: N/A')
            seatLabel:SetText('Seat: Not in a car')
        end
    end
end)

--------------------------------------------------------------
-- SETTINGS TAB
--------------------------------------------------------------
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload Script', function() Library:Unload() end)
MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu toggle keybind',
})

Library.ToggleKeybind = Options.MenuKeybind

-- Watermark with FPS
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('NASCAR Speed Script | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    print('[NASCAR Speed Script] Unloaded.')
    Library.Unloaded = true
end)

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('NASCARSpeedScript')
SaveManager:SetFolder('NASCARSpeedScript/config')

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

--------------------------------------------------------------
-- LOADED
--------------------------------------------------------------
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title    = "NASCAR Speed Script",
        Text     = "Loaded! Press End to toggle menu.",
        Duration = 5
    })
end)

print("[NASCAR Speed Script] Loaded. Press End to toggle menu.")
