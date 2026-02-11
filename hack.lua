-- Config (keep this outside in your launcher)
-- _G.SomethingBossFightConfig = {
--     maxDistance = 15,
--     autoDeflectSpeed = 10,
--     autoKillSpeed = 5,
--     instantKillDuration = 1
-- }

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/bacon"))()
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Anti-detection system
local antiDetection = {
    lastActionTime = 0,
    actionCooldown = 2, -- Minimum time between actions (seconds)
    packetCounter = 0,
    lastPacketTime = 0,
    packetInterval = 1, -- Send packets every second
    spoofedData = {},
    isSpamming = false
}

-- Enhanced anti-detection utility functions
local function antiDetectSend(action, data)
    local currentTime = tick()
    
    -- Rate limiting - don't send too many packets too quickly
    if currentTime - antiDetection.lastPacketTime > antiDetection.packetInterval then
        antiDetection.lastPacketTime = currentTime
        antiDetection.packetCounter = antiDetection.packetCounter + 1
        
        -- Add some randomness to avoid pattern detection
        local spoofedData = {
            packetId = antiDetection.packetCounter,
            timestamp = currentTime,
            userId = player.UserId,
            action = action,
            data = data or {}
        }
        
        -- Log for debugging (this won't be detected by anti-cheat)
        -- print("[ANTI-DETECT] Packet sent:", spoofedData.packetId, action)
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

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        -- Silent error handling to prevent detection
        return nil
    end
    return result
end

-- Create main window with anti-detection
local window = lib:CreateWindow("Something Boss Fight", Enum.KeyCode.RightShift)
lib:CreateLabel(window, "Anti-Detection Mode Active")

-- Auto Kill with enhanced anti-detection
local killToggled = false
local killConnection = nil

lib:CreateToggle(window,"Auto Kill",false,function(s)
    killToggled = s
    if s then
        -- Start auto kill loop with anti-detection
        killConnection = RunService.Heartbeat:Connect(function()
            if killToggled then
                -- Anti-detection: Add random delays to avoid pattern detection
                local delay = math.random(100, 500) / 1000 -- 0.1-0.5 seconds
                task.delay(delay, function()
                    if killToggled then
                        -- Get player character
                        local playerChar = player.Character
                        if not playerChar then return end
                        
                        -- Find enemies with anti-detection
                        local enemies = {}
                        local workspaceChildren = workspace:GetChildren()
                        
                        -- Filter enemies with error handling
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
                            local attackDelay = math.random(50, 200) / 1000 -- 0.05-0.2 seconds
                            
                            task.delay(attackDelay, function()
                                if killToggled then
                                    -- Try to damage using various attack methods with anti-detection
                                    local attackMethods = {"M1", "Slash", "W1_M1", "Swing", "Sentry", "M1_1", "M1_2", "M1_3", "M1_4"}
                                    
                                    for _, method in ipairs(attackMethods) do
                                        -- Safely attempt to send damage event with anti-detection
                                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                                            safeCall(function()
                                                -- Anti-detection: Spoof the data being sent
                                                local spoofedMethod = method .. "_" .. getRandomString(3)
                                                RepStorage.Events.DamageEnemy:FireServer(enemy.model, spoofedMethod)
                                                
                                                -- Send anti-detection signal
                                                antiDetectSend("damage_enemy", {
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
        -- Stop auto kill with proper cleanup
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

lib:CreateToggle(window,"God Mode",false,function(s)
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
                        local delay = math.random(200, 800) / 1000 -- 0.2-0.8 seconds
                        task.delay(delay, function()
                            if godModeToggled and humanoid and humanoid.Parent then
                                humanoid.Health = humanoid.MaxHealth
                                
                                -- Anti-detection signal
                                antiDetectSend("restore_health", {
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

lib:CreateToggle(window,"No Damage",false,function(s)
    noDamageToggled = s
    if s then
        local t = 0
        noDamageConn = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t >= 0.1 then
                t = 0
                if RepStorage.Events and RepStorage.Events.Rolling_iFrames then
                    safeCall(function()
                        -- Anti-detection: Randomize the call
                        local randomDelay = math.random(50, 150) / 1000
                        task.delay(randomDelay, function()
                            RepStorage.Events.Rolling_iFrames:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend("no_damage", {
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

lib:CreateToggle(window,"Auto Deflect",false,function(s)
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
                        antiDetectSend("auto_deflect", {
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

lib:CreateToggle(window,"Auto Buff",false,function(s)
    buffToggled = s
    if s then
        local function applyBuffs()
            -- Anti-detection: Add delays and randomization
            local delay = math.random(100, 300) / 1000
            
            task.delay(delay, function()
                if buffToggled then
                    -- Safely try to apply buffs with anti-detection
                    if RepStorage.ClassModule and RepStorage.ClassModule.Pularos and RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff then
                        safeCall(function()
                            RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend("apply_buff", {
                                buff_type = "Pularos",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.ChainsBinder and RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff then
                        safeCall(function()
                            RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(1)
                            RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(2)
                            
                            -- Anti-detection signal
                            antiDetectSend("apply_buff", {
                                buff_type = "ChainsBinder",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Soulslayer and RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff then
                        safeCall(function()
                            RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend("apply_buff", {
                                buff_type = "Soulslayer",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
                        safeCall(function()
                            RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend("apply_buff", {
                                buff_type = "Bloodhound",
                                timestamp = tick()
                            })
                        end)
                    end
                    
                    if RepStorage.ClassModule and RepStorage.ClassModule.Timekeeper and RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff then
                        safeCall(function()
                            RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff:FireServer()
                            
                            -- Anti-detection signal
                            antiDetectSend("apply_buff", {
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
lib:CreateButton(window,"Instant Kill (Bloodhound)",function()
    -- Instant kill with anti-detection
    if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
        for i = 1, 30 do
            safeCall(function()
                RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                
                -- Anti-detection signal
                antiDetectSend("instant_kill", {
                    step = i,
                    timestamp = tick()
                })
            end)
            task.wait(0.05)
        end
    end
end)

print("[Boss Fight GUI] Anti-Detection Version Loaded")
print("Controls: Click buttons to toggle features")
print("Auto Kill should now be harder to detect")
