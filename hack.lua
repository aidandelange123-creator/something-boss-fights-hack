-- Config (keep this outside in your launcher)
-- _G.SomethingBossFightConfig = {
--     maxDistance = 15,
--     autoDeflectSpeed = 10,
--     autoKillSpeed = 5,
--     instantKillDuration = 1
-- }

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/bacon  "))()
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local greetings = {
    "Hello :3", "Welcome back!", "Good luck!", "Stay strong.", "Don't get hit!", "Wipe 'em out!",
    "You're awesome!", "Keep grinding!", "Have fun!", "Make them fear you!", "Speedrun time!", "Focus up!",
    "One-shot everything!", "Watch out!", "Your blade is ready!", "Time to deflect like pro!",
    "Buff up and go!", "Remember to heal!", "This is your moment!", "No mercy today!",
}

math.randomseed(tick())
local greeting = greetings[math.random(1, #greetings)]

-- Rayfield-style UI
local window = lib:CreateWindow("Something Boss Fight", {
    Icon = "rbxassetid://11450335525",
    Theme = "Dark"
})

lib:CreateLabel(window, greeting)

local function generateFakeIP()
    local function randomOctet()
        return tostring(math.random(0, 255))
    end
    return table.concat({randomOctet(), randomOctet(), randomOctet(), randomOctet()}, ".")
end

local countries = {
    "Vietnam", "United States", "Canada", "United Kingdom", "Australia", "Germany",
    "France", "Japan", "South Korea", "Brazil", "India", "Mexico",
    "Russia", "Italy", "Spain", "Netherlands", "Sweden", "Norway",
    "Denmark", "Finland", "Poland", "Switzerland", "Belgium", "Portugal",
    "Turkey", "Argentina", "Colombia", "Chile", "Peru", "New Zealand"
}

local function getPlayerCountry()
    local player = Players.LocalPlayer
    local success, country = pcall(function()
        return player:GetAccountCountry()
    end)
    if success and country then
        local codeMap = {
            VN = "Vietnam", US = "United States", CA = "Canada", GB = "United Kingdom", AU = "Australia",
            DE = "Germany", FR = "France", JP = "Japan", KR = "South Korea", BR = "Brazil",
            IN = "India", MX = "Mexico", RU = "Russia", IT = "Italy", ES = "Spain",
            NL = "Netherlands", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
            PL = "Poland", CH = "Switzerland", BE = "Belgium", PT = "Portugal", TR = "Turkey",
            AR = "Argentina", CO = "Colombia", CL = "Chile", PE = "Peru", NZ = "New Zealand"
        }
        return codeMap[country] or country
    end
    return countries[math.random(1, #countries)]
end

local easterEggActive = math.random(1, 50) == 1
if easterEggActive then
    StarterGui:SetCore("SendNotification", {
        Title = "???",
        Text = "What this?",
        Duration = 9,
        Button1 = "..."
    })

    lib:CreateLabel(window, "...")
    lib:CreateLabel(window, "Soemthing...feel off")

    lib:CreateButton(window, "???", function()
        local country = getPlayerCountry()
        local fakeIP = generateFakeIP()

        StarterGui:SetCore("SendNotification", {
            Title = "You shouldn't done that.",
            Text = "IP: "..fakeIP.." | Country: "..country,
            Duration = 5
        })

        task.wait(5)
        Players.LocalPlayer:Kick("? is coming\nIP: "..fakeIP.." | Country: "..country)
    end)
end

local function getNearestPrompt()
    local c = Players.LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local r = c.HumanoidRootPart
    local closestPrompt = nil
    local closestDist = _G.SomethingBossFightConfig.maxDistance
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and v.Parent:IsA("BasePart") then
            local dist = (r.Position - v.Parent.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPrompt = v
            end
        end
    end
    return closestPrompt
end

-- No Damage
local noDamageToggled = false
local noDamageConn
lib:CreateToggle(window,"No Damage",false,function(s)
    noDamageToggled = s
    if s then
        local t = 0
        noDamageConn = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t >= 0.1 then
                t = 0
                RepStorage.Events.Rolling_iFrames:FireServer()
            end
        end)
    else
        if noDamageConn then noDamageConn:Disconnect() noDamageConn = nil end
    end
end)

-- Auto Deflect
local autoDeflectToggled = false
local autoDeflectConn
lib:CreateToggle(window,"Auto Deflect",false,function(s)
    autoDeflectToggled = s
    if s then
        local t = 0
        autoDeflectConn = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t >= 1/_G.SomethingBossFightConfig.autoDeflectSpeed then
                t = 0
                local p = getNearestPrompt()
                if p then fireproximityprompt(p) end
            end
        end)
    else
        if autoDeflectConn then autoDeflectConn:Disconnect() autoDeflectConn = nil end
    end
end)

-- Auto Buff
local buffToggled = false
lib:CreateToggle(window,"Auto Buff",false,function(s)
    buffToggled = s
    local statusEffects = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("StatusEffects")
    statusEffects.Visible = not s

    while buffToggled do
        RepStorage.ClassModule.Pularos.RemoteEvents.ApplyBuff:FireServer()
        RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(1)
        RepStorage.ClassModule.ChainsBinder.RemoteEvents.ApplyBuff:FireServer(2)
        RepStorage.ClassModule.Soulslayer.RemoteEvents.ApplyBuff:FireServer()
        RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
        RepStorage.ClassModule.Timekeeper.RemoteEvents.ApplyBuff:FireServer()
        task.wait(0.5)
    end
end)

-- Auto Kill (FIXED)
local killToggled = false
local killConnection = nil

lib:CreateToggle(window,"Auto Kill",false,function(s)
    killToggled = s
    
    if s then
        -- Start auto kill loop
        killConnection = RunService.Heartbeat:Connect(function()
            if killToggled then
                local playerChar = Players.LocalPlayer.Character
                if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                    local enemies = {}
                    
                    -- Find all enemies in workspace
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= Players.LocalPlayer.Name then
                            local humanoid = obj:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local root = obj:FindFirstChild("HumanoidRootPart")
                                if root then
                                    table.insert(enemies, {model = obj, humanoid = humanoid, root = root})
                                end
                            end
                        end
                    end
                    
                    -- Damage all enemies
                    for _, enemy in ipairs(enemies) do
                        -- Try to damage using various attack methods
                        local attackMethods = {"M1", "Slash", "W1_M1", "Swing", "Sentry", "M1_1", "M1_2", "M1_3", "M1_4"}
                        for _, attackMethod in ipairs(attackMethods) do
                            if RepStorage.Events.DamageEnemy then
                                RepStorage.Events.DamageEnemy:FireServer(enemy.model, attackMethod)
                            end
                        end
                    end
                end
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

lib:CreateLabel(window,"Miscellaneous")

-- Instant Kill Button
lib:CreateButton(window,"Instant kill (Bloodhound)",function()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local statusEffects = playerGui:WaitForChild("MainGui"):WaitForChild("StatusEffects")
    statusEffects.Visible = false
    for i = 1, 30 do
        RepStorage.ClassModule.Bloodhound.RemoteEvents.ApplyBuff:FireServer()
        task.wait(0.05)
    end
    task.wait(_G.SomethingBossFightConfig.instantKillDuration)
    statusEffects.Visible = true
end)

-- God Mode
local godModeToggled = false
local healthWatcher = nil
local originalMaxHealth = 100
local originalHealth = 100

lib:CreateToggle(window,"God Mode",false,function(s)
    godModeToggled = s
    
    if s then
        -- Enable god mode
        local char = Players.LocalPlayer.Character
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
    else
        -- Disable god mode
        local char = Players.LocalPlayer.Character
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
