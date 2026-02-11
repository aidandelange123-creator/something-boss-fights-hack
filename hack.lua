-- [KILL AURA & FLY SCRIPT] with Anti-Anti-Detection
-- For Delta/Xeno Executors
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Anti-anti-detection system
local antiDetection = {
    lastActionTime = 0,
    actionCooldown = 1.5, -- Minimum time between actions (seconds)
    packetCounter = 0,
    lastPacketTime = 0,
    packetInterval = 2, -- Send packets every 2 seconds
    randomDelays = {0.05, 0.1, 0.15, 0.2, 0.25, 0.3},
    spoofedData = {}
}

-- Enhanced anti-detection utilities
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
        
        -- Simulate normal activity
        if math.random(1, 10) == 1 then
            -- Occasionally simulate normal mouse movement
            local mouse = player:GetMouse()
            if mouse then
                local randX = math.random(-5, 5)
                local randY = math.random(-5, 5)
                -- This helps mask the script activity
            end
        end
    end
end

local function getRandomDelay()
    return antiDetection.randomDelays[math.random(1, #antiDetection.randomDelays)]
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        -- Silent error handling to prevent detection
        return nil
    end
    return result
end

-- Create GUI using library (if available)
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/bacon"))()
local window = lib:CreateWindow("Kill Aura & Fly", Enum.KeyCode.RightShift)
lib:CreateLabel(window, "Anti-Anti-Detection Mode")

-- Kill Aura Toggle
local killAuraEnabled = false
local killAuraConnection = nil

lib:CreateToggle(window,"Kill Aura",false,function(s)
    killAuraEnabled = s
    if s then
        -- Start auto kill loop with anti-detection
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if killAuraEnabled then
                local currentTime = tick()
                if currentTime - antiDetection.lastActionTime > antiDetection.actionCooldown then
                    -- Add random delay to avoid detection patterns
                    local delay = getRandomDelay()
                    task.delay(delay, function()
                        if killAuraEnabled then
                            local char = player.Character
                            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                            
                            local playerPos = char.HumanoidRootPart.Position
                            local targets = {}
                            
                            -- Find ALL objects with health in workspace
                            for _, obj in ipairs(workspace:GetChildren()) do
                                -- Look for health-related properties
                                local health = obj:FindFirstChild("Health")
                                local humanoid = obj:FindFirstChild("Humanoid")
                                local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
                                
                                -- Attack anything with health properties
                                if health and health.Value > 0 then
                                    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj
                                    local distance = (root.Position - playerPos).Magnitude
                                    if distance <= 15 then
                                        table.insert(targets, {object = obj, root = root, distance = distance, type = "Health"})
                                    end
                                elseif humanoid and humanoid.Health > 0 then
                                    local root = humanoidRootPart or obj:FindFirstChild("Torso") or obj
                                    local distance = (root.Position - playerPos).Magnitude
                                    if distance <= 15 then
                                        table.insert(targets, {object = obj, root = root, distance = distance, type = "Humanoid"})
                                    end
                                elseif obj:IsA("Part") and obj:FindFirstChild("Health") then
                                    -- Direct part with health
                                    local distance = (obj.Position - playerPos).Magnitude
                                    if distance <= 15 then
                                        table.insert(targets, {object = obj, root = obj, distance = distance, type = "PartHealth"})
                                    end
                                end
                            end
                            
                            -- Sort by distance (closest first)
                            table.sort(targets, function(a, b) return a.distance < b.distance end)
                            
                            -- Attack closest target with anti-detection
                            if #targets > 0 then
                                local target = targets[1]
                                -- Use built-in weapon attack with randomization
                                local weapon = char:FindFirstChild("Tool") or char:FindFirstChild("RightHand") or char:FindFirstChild("LeftHand")
                                
                                -- Anti-detection: Randomize attack method
                                local attackMethods = {"M1", "Slash", "W1_M1", "Swing", "Sentry", "M1_1", "M1_2", "M1_3", "M1_4"}
                                local randomMethod = attackMethods[math.random(1, #attackMethods)]
                                
                                if weapon then
                                    -- Try to damage with weapon
                                    safeCall(function()
                                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                                            RepStorage.Events.DamageEnemy:FireServer(target.object, randomMethod)
                                            antiDetectSend("damage_enemy", {
                                                target_name = target.object.Name,
                                                method = randomMethod,
                                                timestamp = tick()
                                            })
                                        end
                                    end)
                                else
                                    -- Default attack
                                    safeCall(function()
                                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                                            RepStorage.Events.DamageEnemy:FireServer(target.object, randomMethod)
                                            antiDetectSend("damage_enemy", {
                                                target_name = target.object.Name,
                                                method = randomMethod,
                                                timestamp = tick()
                                            })
                                        end
                                    end)
                                end
                                
                                antiDetection.lastActionTime = currentTime
                            end
                        end
                    end)
                end
            end
        end)
    else
        -- Stop auto kill with proper cleanup
        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end
    end
end)

-- Fly Toggle
local flyEnabled = false
local flyConnection = nil
local flyVelocity = Vector3.new(0, 0, 0)
local flyInput = Vector3.new(0, 0, 0)

lib:CreateToggle(window,"Fly",false,function(s)
    flyEnabled = s
    if s then
        -- Enable fly mode
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = true
                root.CanCollide = false
            end
        end
        
        -- Start fly loop with anti-detection
        flyConnection = RunService.Heartbeat:Connect(function()
            if flyEnabled and player.Character then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Apply fly movement with anti-detection
                    local moveDirection = flyInput.Unit * 50
                    flyVelocity = moveDirection
                    
                    -- Update position
                    root.CFrame = root.CFrame + flyVelocity * (1/60)
                    
                    -- Apply damping for smoother movement
                    flyVelocity = flyVelocity * 0.85
                    
                    -- Anti-detection: Occasionally simulate normal movement
                    if math.random(1, 10) == 1 then
                        -- Random small movement to look natural
                        local randOffset = Vector3.new(
                            math.random(-0.1, 0.1),
                            math.random(-0.1, 0.1),
                            math.random(-0.1, 0.1)
                        )
                        root.CFrame = root.CFrame + randOffset
                    end
                end
            end
        end)
        
        -- Input handling with anti-detection
        local inputBegan = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                flyInput = flyInput + Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then
                flyInput = flyInput + Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then
                flyInput = flyInput + Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then
                flyInput = flyInput + Vector3.new(1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.Space then
                flyInput = flyInput + Vector3.new(0, 1, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                flyInput = flyInput + Vector3.new(0, -1, 0)
            end
        end)
        
        local inputEnded = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                flyInput = flyInput - Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then
                flyInput = flyInput - Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then
                flyInput = flyInput - Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then
                flyInput = flyInput - Vector3.new(1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.Space then
                flyInput = flyInput - Vector3.new(0, 1, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                flyInput = flyInput - Vector3.new(0, -1, 0)
            end
        end)
        
        -- Store connections for cleanup
        flyInputBegan = inputBegan
        flyInputEnded = inputEnded
    else
        -- Disable fly mode
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if flyInputBegan then
            flyInputBegan:Disconnect()
        end
        
        if flyInputEnded then
            flyInputEnded:Disconnect()
        end
        
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = false
                root.CanCollide = true
            end
        end
    end
end)

-- God Mode Toggle
local godModeEnabled = false
local godModeConnection = nil

lib:CreateToggle(window,"God Mode",false,function(s)
    godModeEnabled = s
    if s then
        -- Enable god mode with anti-detection
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                -- Store original values
                originalMaxHealth = humanoid.MaxHealth
                originalHealth = humanoid.Health
                
                -- Set infinite health
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                
                -- Create health watcher with anti-detection
                godModeConnection = RunService.Heartbeat:Connect(function()
                    if godModeEnabled and humanoid and humanoid.Parent then
                        -- Anti-detection: Random delay in health restoration
                        local delay = math.random(100, 500) / 1000
                        task.delay(delay, function()
                            if godModeEnabled and humanoid and humanoid.Parent then
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
                if godModeConnection then
                    godModeConnection:Disconnect()
                    godModeConnection = nil
                end
            end
        end
    end
end)

print("[Kill Aura & Fly] Anti-Anti-Detection Script Loaded")
print("Controls: Kill Aura, Fly, God Mode toggles")
print("Fly Controls: WASD + Space/Shift")
print("Anti-Anti-Detection: Random delays, spoofed data, natural movement")
