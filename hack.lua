-- [KILL AURA SCRIPT] for Delta/Xeno Executors
-- Attacks ANYTHING with health (including NPCs, players, etc.)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RepStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KillAuraGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Size = UDim2.new(0, 250, 0, 250)
window.Position = UDim2.new(0.5, -125, 0.5, -125)
window.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
window.BorderSizePixel = 0
window.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Kill Aura & Fly"
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = window

-- Kill Aura Toggle
local killAuraEnabled = false
local killAuraConnection = nil

local killAuraBtn = Instance.new("TextButton")
killAuraBtn.Size = UDim2.new(1, -20, 0, 30)
killAuraBtn.Position = UDim2.new(0, 10, 0, 40)
killAuraBtn.Text = "Kill Aura: OFF"
killAuraBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
killAuraBtn.TextColor3 = Color3.new(1, 1, 1)
killAuraBtn.Font = Enum.Font.SourceSans
killAuraBtn.TextSize = 14
killAuraBtn.Parent = window

killAuraBtn.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    killAuraBtn.Text = "Kill Aura: " .. (killAuraEnabled and "ON" or "OFF")
    killAuraBtn.BackgroundColor3 = killAuraEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if killAuraEnabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if killAuraEnabled then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local playerPos = char.HumanoidRootPart.Position
                local targets = {}
                
                -- Find ALL objects with health in workspace
                for _, obj in ipairs(workspace:GetChildren()) do
                    -- Check if object has health (any kind of health system)
                    if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("BasePart") then
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
                end
                
                -- Sort by distance (closest first)
                table.sort(targets, function(a, b) return a.distance < b.distance end)
                
                -- Attack closest target
                if #targets > 0 then
                    local target = targets[1]
                    -- Use built-in weapon attack
                    local weapon = char:FindFirstChild("Tool") or char:FindFirstChild("RightHand") or char:FindFirstChild("LeftHand")
                    
                    if weapon then
                        -- Try to damage with weapon
                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                            RepStorage.Events.DamageEnemy:FireServer(target.object, "M1")
                        end
                    else
                        -- Default attack
                        if RepStorage.Events and RepStorage.Events.DamageEnemy then
                            RepStorage.Events.DamageEnemy:FireServer(target.object, "M1")
                        end
                    end
                end
            end
        end)
    else
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

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -20, 0, 30)
flyBtn.Position = UDim2.new(0, 10, 0, 80)
flyBtn.Text = "Fly: OFF"
flyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.SourceSans
flyBtn.TextSize = 14
flyBtn.Parent = window

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if flyEnabled then
        -- Enable fly mode
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = true
                root.CanCollide = false
            end
        end
        
        -- Start fly loop
        flyConnection = RunService.Heartbeat:Connect(function()
            if flyEnabled and player.Character then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Apply fly movement
                    local moveDirection = flyInput.Unit * 50
                    flyVelocity = moveDirection
                    
                    -- Update position
                    root.CFrame = root.CFrame + flyVelocity * (1/60)
                    
                    -- Apply damping
                    flyVelocity = flyVelocity * 0.85
                end
            end
        end)
        
        -- Input handling
        UserInputService.InputBegan:Connect(function(input)
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
        
        UserInputService.InputEnded:Connect(function(input)
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
    else
        -- Disable fly mode
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
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

local godModeBtn = Instance.new("TextButton")
godModeBtn.Size = UDim2.new(1, -20, 0, 30)
godModeBtn.Position = UDim2.new(0, 10, 0, 120)
godModeBtn.Text = "God Mode: OFF"
godModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
godModeBtn.TextColor3 = Color3.new(1, 1, 1)
godModeBtn.Font = Enum.Font.SourceSans
godModeBtn.TextSize = 14
godModeBtn.Parent = window

godModeBtn.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    godModeBtn.Text = "God Mode: " .. (godModeEnabled and "ON" or "OFF")
    godModeBtn.BackgroundColor3 = godModeEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if godModeEnabled then
        -- Enable god mode
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end
    else
        -- Disable god mode
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0, 160)
closeBtn.Text = "Close GUI"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14
closeBtn.Parent = window

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("[Kill Aura] Attack ANYTHING with health")
print("Controls: Kill Aura, Fly, God Mode toggles")
print("Fly Controls: WASD + Space/Shift")
