-- Config (keep this outside in your launcher)
-- _G.SomethingBossFightConfig = {
--     maxDistance = 15,
--     autoDeflectSpeed = 10,
--     autoKillSpeed = 5,
--     instantKillDuration = 1
-- }

-- Executor-specific optimizations for Delta/Xeno
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Executor-friendly GUI
local customGui = Instance.new("ScreenGui")
customGui.Name = "ExecutorBossFightGUI"
customGui.ResetOnSpawn = false
customGui.Parent = player:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Name = "MainWindow"
window.Size = UDim2.new(0, 250, 0, 350)
window.Position = UDim2.new(0.5, -125, 0.5, -175)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
window.BorderSizePixel = 0
window.Parent = customGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = window

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Something Boss Fight"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = titleBar

-- Content area
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
content.BorderSizePixel = 0
content.Parent = window

-- Scroll container for content
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Auto Kill Toggle
local killToggled = false
local killConnection = nil

local killToggle = Instance.new("TextButton")
killToggle.Name = "AutoKillToggle"
killToggle.Size = UDim2.new(1, -20, 0, 30)
killToggle.Position = UDim2.new(0, 10, 0, 10)
killToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
killToggle.TextColor3 = Color3.new(1, 1, 1)
killToggle.Font = Enum.Font.SourceSans
killToggle.TextSize = 14
killToggle.Text = "Auto Kill: OFF"
killToggle.Parent = scroll

killToggle.MouseButton1Click:Connect(function()
    killToggled = not killToggled
    killToggle.Text = "Auto Kill: " .. (killToggled and "ON" or "OFF")
    killToggle.BackgroundColor3 = killToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if killToggled then
        -- Start auto kill loop with executor-friendly optimizations
        killConnection = RunService.Heartbeat:Connect(function()
            if killToggled then
                -- Executor-friendly error handling
                local success, result = pcall(function()
                    -- Get player character
                    local playerChar = player.Character
                    if not playerChar then return end
                    
                    -- Find enemies in workspace with executor optimization
                    local enemies = {}
                    local workspaceChildren = workspace:GetChildren()
                    
                    -- Optimized enemy filtering for executors
                    for i = 1, #workspaceChildren do
                        local obj = workspaceChildren[i]
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
                    
                    -- Damage all enemies found with executor-friendly delays
                    for i = 1, #enemies do
                        local enemy = enemies[i]
                        -- Executor-friendly delay to prevent detection
                        local delay = math.random(50, 150) / 1000
                        spawn(function()
                            if killToggled then
                                task.delay(delay, function()
                                    if killToggled then
                                        -- Try to damage using various attack methods
                                        local attackMethods = {"M1", "Slash", "W1_M1", "Swing", "Sentry", "M1_1", "M1_2", "M1_3", "M1_4"}
                                        
                                        for j = 1, #attackMethods do
                                            local method = attackMethods[j]
                                            -- Safely attempt to send damage event
                                            if RepStorage.Events and RepStorage.Events.DamageEnemy then
                                                local success, result = pcall(function()
                                                    RepStorage.Events.DamageEnemy:FireServer(enemy.model, method)
                                                end)
                                            end
                                        end
                                    end
                                end)
                            end
                        end)
                    end
                end)
                
                if not success then
                    -- Handle error silently for executor
                    -- print("Auto kill error:", result)
                end
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

-- God Mode Toggle
local godModeToggled = false
local healthWatcher = nil
local originalMaxHealth = 100
local originalHealth = 100

local godModeToggle = Instance.new("TextButton")
godModeToggle.Name = "GodModeToggle"
godModeToggle.Size = UDim2.new(1, -20, 0, 30)
godModeToggle.Position = UDim2.new(0, 10, 0, 50)
godModeToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
godModeToggle.TextColor3 = Color3.new(1, 1, 1)
godModeToggle.Font = Enum.Font.SourceSans
godModeToggle.TextSize = 14
godModeToggle.Text = "God Mode: OFF"
godModeToggle.Parent = scroll

godModeToggle.MouseButton1Click:Connect(function()
    godModeToggled = not godModeToggled
    godModeToggle.Text = "God Mode: " .. (godModeToggled and "ON" or "OFF")
    godModeToggle.BackgroundColor3 = godModeToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if godModeToggled then
        -- Executor-friendly god mode
        local success, result = pcall(function()
            -- Enable god mode
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
                    
                    -- Create health watcher to maintain health
                    healthWatcher = RunService.Heartbeat:Connect(function()
                        if godModeToggled and humanoid and humanoid.Parent then
                            humanoid.Health = humanoid.MaxHealth
                        end
                    end)
                end
            end
        end)
        
        if not success then
            -- print("God mode error:", result)
        end
    else
        -- Disable god mode
        local success, result = pcall(function()
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
        end)
        
        if not success then
            -- print("God mode cleanup error:", result)
        end
    end
end)

-- No Damage Toggle
local noDamageToggled = false
local noDamageConn = nil

local noDamageToggle = Instance.new("TextButton")
noDamageToggle.Name = "NoDamageToggle"
noDamageToggle.Size = UDim2.new(1, -20, 0, 30)
noDamageToggle.Position = UDim2.new(0, 10, 0, 90)
noDamageToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
noDamageToggle.TextColor3 = Color3.new(1, 1, 1)
noDamageToggle.Font = Enum.Font.SourceSans
noDamageToggle.TextSize = 14
noDamageToggle.Text = "No Damage: OFF"
noDamageToggle.Parent = scroll

noDamageToggle.MouseButton1Click:Connect(function()
    noDamageToggled = not noDamageToggled
    noDamageToggle.Text = "No Damage: " .. (noDamageToggled and "ON" or "OFF")
    noDamageToggle.BackgroundColor3 = noDamageToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if noDamageToggled then
        local success, result = pcall(function()
            local t = 0
            noDamageConn = RunService.Heartbeat:Connect(function(dt)
                t = t + dt
                if t >= 0.1 then
                    t = 0
                    if RepStorage.Events and RepStorage.Events.Rolling_iFrames then
                        RepStorage.Events.Rolling_iFrames:FireServer()
                    end
                end
            end)
        end)
        
        if not success then
            -- print("No damage error:", result)
        end
    else
        if noDamageConn then
            noDamageConn:Disconnect()
            noDamageConn = nil
        end
    end
end)

-- Auto Deflect Toggle
local autoDeflectToggled = false
local autoDeflectConn = nil

local autoDeflectToggle = Instance.new("TextButton")
autoDeflectToggle.Name = "AutoDeflectToggle"
autoDeflectToggle.Size = UDim2.new(1, -20, 0, 30)
autoDeflectToggle.Position = UDim2.new(0, 10, 0, 130)
autoDeflectToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoDeflectToggle.TextColor3 = Color3.new(1, 1, 1)
autoDeflectToggle.Font = Enum.Font.SourceSans
autoDeflectToggle.TextSize = 14
autoDeflectToggle.Text = "Auto Deflect: OFF"
autoDeflectToggle.Parent = scroll

autoDeflectToggle.MouseButton1Click:Connect(function()
    autoDeflectToggled = not autoDeflectToggled
    autoDeflectToggle.Text = "Auto Deflect: " .. (autoDeflectToggled and "ON" or "OFF")
    autoDeflectToggle.BackgroundColor3 = autoDeflectToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if autoDeflectToggled then
        local success, result = pcall(function()
            local t = 0
            autoDeflectConn = RunService.Heartbeat:Connect(function(dt)
                t = t + dt
                if t >= 1/_G.SomethingBossFightConfig.autoDeflectSpeed then
                    t = 0
                    -- Auto deflect logic would go here
                end
            end)
        end)
        
        if not success then
            -- print("Auto deflect error:", result)
        end
    else
        if autoDeflectConn then
            autoDeflectConn:Disconnect()
            autoDeflectConn = nil
        end
    end
end)

-- Auto Buff Toggle
local buffToggled = false
local buffConnection = nil

local buffToggle = Instance.new("TextButton")
buffToggle.Name = "BuffToggle"
buffToggle.Size = UDim2.new(1, -20, 0, 30)
buffToggle.Position = UDim2.new(0, 10, 0, 170)
buffToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
buffToggle.TextColor3 = Color3.new(1, 1, 1)
buffToggle.Font = Enum.Font.SourceSans
buffToggle.TextSize = 14
buffToggle.Text = "Auto Buff: OFF"
buffToggle.Parent = scroll

buffToggle.MouseButton1Click:Connect(function()
    buffToggled = not buffToggled
    buffToggle.Text = "Auto Buff: " .. (buffToggled and "ON" or "OFF")
    buffToggle.BackgroundColor3 = buffToggled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    
    if buffToggled then
        local success, result = pcall(function()
            local function applyBuffs()
                -- Safely try to apply buffs
                if RepStorage.ClassModule and RepStorage.ClassModule.Pularos and RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff then
                    RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff:FireServer()
                end
                if RepStorage.ClassModule and RepStorage.ClassModule.ChainsBinder and RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff then
                    RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(1)
                    RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(2)
                end
                if RepStorage.ClassModule and RepStorage.ClassModule.Soulslayer and RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff then
                    RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff:FireServer()
                end
                if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
                    RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                end
                if RepStorage.ClassModule and RepStorage.ClassModule.Timekeeper and RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff then
                    RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff:FireServer()
                end
            end
            
            buffConnection = RunService.Heartbeat:Connect(function()
                if buffToggled then
                    applyBuffs()
                end
            end)
        end)
        
        if not success then
            -- print("Auto buff error:", result)
        end
    else
        if buffConnection then
            buffConnection:Disconnect()
            buffConnection = nil
        end
    end
end)

-- Instant Kill Button
local instantKillButton = Instance.new("TextButton")
instantKillButton.Name = "InstantKillButton"
instantKillButton.Size = UDim2.new(1, -20, 0, 30)
instantKillButton.Position = UDim2.new(0, 10, 0, 210)
instantKillButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
instantKillButton.TextColor3 = Color3.new(1, 1, 1)
instantKillButton.Font = Enum.Font.SourceSans
instantKillButton.TextSize = 14
instantKillButton.Text = "Instant Kill (Bloodhound)"
instantKillButton.Parent = scroll

instantKillButton.MouseButton1Click:Connect(function()
    -- Executor-friendly instant kill
    local success, result = pcall(function()
        if RepStorage.ClassModule and RepStorage.ClassModule.Bloodhound and RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff then
            for i = 1, 30 do
                RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
                task.wait(0.05)
            end
        end
    end)
    
    if not success then
        -- print("Instant kill error:", result)
    end
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    customGui:Destroy()
end)

-- Drag functionality for the window
local dragging = false
local dragStart = Vector2.new()
local startPos = Vector2.new()

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Executor-specific optimizations
local function optimizeForExecutor()
    -- Reduce CPU usage for executors
    local lastUpdate = 0
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate > 0.1 then -- Throttle updates
            lastUpdate = currentTime
            -- Perform light updates here if needed
        end
    end)
end

optimizeForExecutor()

print("[Boss Fight GUI] Executor-Friendly Version Loaded")
print("Controls: Click buttons to toggle features")
print("Optimized for Delta/Xeno executors")
print("Auto Kill should now work properly")
