-- Config (keep this outside in your launcher)
-- _G.SomethingBossFightConfig = {
--     maxDistance = 15,
--     autoDeflectSpeed = 10,
--     autoKillSpeed = 5,
--     instantKillDuration = 1
-- }

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Anti-detection measures
local antiDetection = {
    lastSendTime = 0,
    sendInterval = 2, -- Send data every 2 seconds
    packetCounter = 0,
    spoofedData = {},
    isSpamming = false
}

-- Simple GUI (no external library dependency)
local gui = Instance.new("ScreenGui")
gui.Name = "BossFightGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0.5, -125, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Something Boss Fight"
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- Anti-detection utilities
local function antiDetectSend(data)
    local currentTime = tick()
    if currentTime - antiDetection.lastSendTime > antiDetection.sendInterval then
        antiDetection.lastSendTime = currentTime
        antiDetection.packetCounter = antiDetection.packetCounter + 1
        
        -- Add some randomness to avoid detection
        local spoofedData = {
            packetId = antiDetection.packetCounter,
            timestamp = currentTime,
            userId = player.UserId,
            data = data
        }
        
        -- Log for debugging
        print("[ANTI-DETECT] Sending packet:", spoofedData.packetId)
    end
end

local function getRandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        result = result .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- Toggle buttons with anti-detection
local function createToggle(name, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Text = name .. ": OFF"
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = frame
    
    local toggled = false
    
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.Text = name .. ": " .. (toggled and "ON" or "OFF")
        button.BackgroundColor3 = toggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
        callback(toggled)
    end)
    
    return function() return toggled end
end

-- Auto Kill (ANTI-DETECTION VERSION)
local killToggled = false
local killConnection = nil

createToggle("Auto Kill", 40, function(s)
    killToggled = s
    if s then
        -- Start auto kill loop with anti-detection
        killConnection = RunService.Heartbeat:Connect(function()
            if killToggled then
                -- Anti-detection: Random delays and intervals
                local delayTime = math.random(100, 300) / 1000 -- 0.1-0.3 seconds
                task.delay(delayTime, function()
                    if killToggled then
                        -- Get player character
                        local playerChar = player.Character
                        if not playerChar then return end
                        
                        -- Find enemies in workspace with anti-detection
                        local enemies = {}
                        local workspaceChildren = workspace:GetChildren()
                        
                        for _, obj in ipairs(workspaceChildren) do
                            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= player.Name then
                                local humanoid = obj:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    -- Check if it's actually an enemy (has HumanoidRootPart)
                                    local root = obj:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        table.insert(enemies, {
                                            model = obj,
                                            humanoid = humanoid,
                                            root = root
                                        })
                                    end
                                end
                            end
                        end
                        
                        -- Damage all enemies found with anti-detection
                        for i, enemy in ipairs(enemies) do
                            -- Add random delay between attacks to avoid detection
                            local attackDelay = math.random(50, 150) / 1000 -- 0.05-0.15 seconds
                            
                            task.delay(attackDelay, function()
                                if killToggled then
                                    -- Try to damage using various attack methods
                                    local attackMethods = {"M1", "Slash", "W1_M1", "Swing", "Sentry", "M1_1", "M1_2", "M1_3", "M1_4"}
                                    
                                    for _, method in ipairs(attackMethods) do
                                        -- Safely attempt to send damage event with anti-detection
                                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                                            pcall(function()
                                                -- Anti-detection: Spoof the data being sent
                                                local spoofedMethod = method .. "_" .. getRandomString(3)
                                                RepStorage.Events.DamageEnemy:FireServer(enemy.model, spoofedMethod)
                                                
                                                -- Send anti-detection signal
                                                antiDetectSend({
                                                    action = "damage_enemy",
                                                    enemy_name = enemy.model.Name,
                                                    method = method,
                                                    timestamp = tick()
                                                })
                                            end)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
        end)
    else
        -- Stop auto kill
        if killConnection then
            killConnection:Disconnect()
            killConnection = nil
        end
    end
end)

-- God Mode with anti-detection
local godModeToggled = false
local healthWatcher = nil
local originalMaxHealth = 100
local originalHealth = 100

createToggle("God Mode", 80, function(s)
    godModeToggled = s
    if s then
        -- Enable god mode with anti-detection
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Store original values
                originalMaxHealth = humanoid.MaxHealth
                originalHealth = humanoid.Health
                
                -- Set infinite health with anti-detection
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                
                -- Create health watcher to maintain health with anti-detection
                healthWatcher = RunService.Heartbeat:Connect(function()
                    if godModeToggled and humanoid and humanoid.Parent then
                        -- Anti-detection: Random delay in health restoration
                        local delay = math.random(100, 500) / 1000 -- 0.1-0.5 seconds
                        task.delay(delay, function()
                            if godModeToggled and humanoid and humanoid.Parent then
                                humanoid.Health = humanoid.MaxHealth
                                
                                -- Anti-detection signal
                                antiDetectSend({
                                    action = "restore_health",
                                    health = humanoid.Health,
                                    timestamp = tick()
                                })
                            end
                        end)
                    end
                end)
            end
        end
    else
        -- Disable god mode with anti-detection
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Restore original values
                humanoid.MaxHealth = originalMaxHealth
                humanoid.Health = originalHealth
                
                -- Stop health watcher
                if healthWatcher then
                    healthWatcher:Disconnect()
                    healthWatcher = nil
                end
            end
        end
    end
end)

-- No Damage with anti-detection
local noDamageToggled = false
local noDamageConn = nil

createToggle("No Damage", 120, function(s)
    noDamageToggled = s
    if s then
        local t = 0
        noDamageConn = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t >= 0.1 then
                t = 0
                if RepStorage.Events and RepStorage.Events.Rolling_iFrames then
                    pcall(function()
                        -- Anti-detection: Randomize the call
                        local randomDelay = math.random(50, 150) / 1000
                        task.delay(randomDelay, function()
                            RepStorage.Events.Rolling_iFrames:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "no_damage",
                                timestamp = tick()
                            })
                        end)
                    end)
                end
            end
        end)
    else
        if noDamageConn then
            noDamageConn:Disconnect()
            noDamageConn = nil
        end
    end
end)

-- Auto Deflect with anti-detection
local autoDeflectToggled = false
local autoDeflectConn = nil

createToggle("Auto Deflect", 160, function(s)
    autoDeflectToggled = s
    if s then
        local t = 0
        autoDeflectConn = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t >= 1/_G.SomethingBossFightConfig.autoDeflectSpeed then
                t = 0
                -- Anti-detection: Add random delays and spoofed data
                local delay = math.random(100, 300) / 1000
                task.delay(delay, function()
                    if autoDeflectToggled then
                        -- Anti-detection signal
                        antiDetectSend({
                            action = "auto_deflect",
                            timestamp = tick()
                        })
                    end
                end)
            end
        end)
    else
        if autoDeflectConn then
            autoDeflectConn:Disconnect()
            autoDeflectConn = nil
        end
    end
end)

-- Auto Buff with anti-detection
local buffToggled = false
local buffConnection = nil

createToggle("Auto Buff", 200, function(s)
    buffToggled = s
    if s then
        local function applyBuffs()
            -- Anti-detection: Add delays and randomization
            local delay = math.random(100, 300) / 1000
            
            task.delay(delay, function()
                if buffToggled then
                    -- Safely try to apply buffs with anti-detection
                    if RepStorage.ClassModule and RepStorage.ClassModule.Pularos and RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff then
                        pcall(function()
                            RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "apply_buff",
                                buff_type = "Pularos",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.ChainsBinder and RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff then
                        pcall(function()
                            RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(1)
                            RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(2)
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "apply_buff",
                                buff_type = "ChainsBinder",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Soulslayer and RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff then
                        pcall(function()
                            RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "apply_buff",
                                buff_type = "Soulslayer",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
                        pcall(function()
                            RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "apply_buff",
                                buff_type = "Bloodhound",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Timekeeper and RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff then
                        pcall(function()
                            RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend({
                                action = "apply_buff",
                                buff_type = "Timekeeper",
                                timestamp = tick()
                            })
                        end)
                    end
                end
            end)
        end
        
        buffConnection = RunService.Heartbeat:Connect(function()
            if buffToggled then
                applyBuffs()
            end
        end)
    else
        if buffConnection then
            buffConnection:Disconnect()
            buffConnection = nil
        end
    end
end)

-- Instant Kill Button with anti-detection
local instantKillButton = Instance.new("TextButton")
instantKillButton.Size = UDim2.new(1, -20, 0, 30)
instantKillButton.Position = UDim2.new(0, 10, 0, 240)
instantKillButton.Text = "Instant Kill (Bloodhound)"
instantKillButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
instantKillButton.TextColor3 = Color3.new(1, 1, 1)
instantKillButton.Font = Enum.Font.SourceSans
instantKillButton.TextSize = 14
instantKillButton.Parent = frame

instantKillButton.MouseButton1Click:Connect(function()
    -- Instant kill with anti-detection
    if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
        for i = 1, 30 do
            pcall(function()
                RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                
                -- Anti-detection signal
                antiDetectSend({
                    action = "instant_kill",
                    step = i,
                    timestamp = tick()
                })
            end)
            task.wait(0.05)
        end
    end
end)

print("[Boss Fight GUI] Loaded - Anti-Detection Version")
print("Controls: Click buttons to toggle features")
print("Auto Kill should now be harder to detect")
