repeat wait() until game:IsLoaded()
local plr = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local rs = game:GetService("RunService")
local ts = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local toggle = {
    AutoFarm = false,
    AutoBoss = false,
    AutoFly = false,
    AutoUpgradeSkills = false,
    AutoFarmResources = false,
    AutoRevive = false,
    AutoTrackQuestProgress = false,
    AutoReportCheat = false,
    AutoRaid = false,
    KillAura = false,
}

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false

local function createToggleButton(text, posY, toggleKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 300, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "[TẮT] " .. text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = gui
    btn.Active = true
    btn.Draggable = true

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        toggle[toggleKey] = state
        btn.Text = (state and "[BẬT] " or "[TẮT] ") .. text
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

-- Tạo các nút chức năng
local names = {
    {"Tự động Farm", "AutoFarm"},
    {"Tự động Boss", "AutoBoss"},
    {"Tự động Fly", "AutoFly"},
    {"Tăng kỹ năng + Trang bị", "AutoUpgradeSkills"},
    {"Nhặt vật phẩm", "AutoFarmResources"},
    {"Tự động Hồi sinh", "AutoRevive"},
    {"Theo dõi nhiệm vụ", "AutoTrackQuestProgress"},
    {"Báo cáo gian lận", "AutoReportCheat"},
    {"Tự động Raid", "AutoRaid"},
    {"Kill Aura", "KillAura"},
}
for i, pair in ipairs(names) do
    createToggleButton(pair[1], 40 + i * 40, pair[2])
end

-- Phím tắt K
local visible = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        visible = not visible
        for _, v in pairs(gui:GetChildren()) do
            if v:IsA("TextButton") then v.Visible = visible end
        end
    end
end)

-- Vòng lặp chính
rs.RenderStepped:Connect(function()
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- AutoFarm
    if toggle.AutoFarm then
        local closest, dist = nil, math.huge
        for _, mob in pairs(workspace:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                local d = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = mob
                end
            end
        end
        if closest then
            char:MoveTo(closest.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        end
    end

    -- AutoBoss
    if toggle.AutoBoss then
        for _, boss in pairs(workspace:GetChildren()) do
            if boss.Name:lower():find("boss") and boss:FindFirstChild("HumanoidRootPart") then
                char:MoveTo(boss.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
                break
            end
        end
    end

    -- AutoFly
    if toggle.AutoFly then
        if not char:FindFirstChild("Flying") then
            vim:SendKeyEvent(true, "T", false, game)
            wait(0.2)
            vim:SendKeyEvent(false, "T", false, game)
        end
    end

    -- AutoUpgradeSkills
    if toggle.AutoUpgradeSkills then
        local remote = game.ReplicatedStorage:FindFirstChild("UpgradeSkill")
        if remote then
            remote:FireServer("All")
        end
    end

    -- AutoFarmResources
    if toggle.AutoFarmResources then
        for _, item in pairs(workspace:GetChildren()) do
            if item:IsA("Part") and item:FindFirstChild("TouchInterest") then
                firetouchinterest(char.HumanoidRootPart, item, 0)
                wait(0.1)
                firetouchinterest(char.HumanoidRootPart, item, 1)
            end
        end
    end

    -- AutoRevive
    if toggle.AutoRevive then
        if char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
            ts:Teleport(game.PlaceId, plr)
        end
    end

    -- AutoTrackQuestProgress
    if toggle.AutoTrackQuestProgress then
        local quest = plr:FindFirstChild("Quest")
        if quest then
            print("Nhiệm vụ hiện tại: " .. quest.Value)
        end
    end

    -- AutoReportCheat
    if toggle.AutoReportCheat then
        for _, other in pairs(game.Players:GetPlayers()) do
            if other ~= plr and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                local speed = other.Character.HumanoidRootPart.Velocity.Magnitude
                if speed > 150 then
                    warn("Phát hiện nghi ngờ hack: " .. other.Name)
                end
            end
        end
    end

    -- AutoRaid
    if toggle.AutoRaid then
        local portal = workspace:FindFirstChild("RaidPortal")
        if portal and portal:FindFirstChild("TouchInterest") then
            firetouchinterest(char.HumanoidRootPart, portal, 0)
            wait(0.2)
            firetouchinterest(char.HumanoidRootPart, portal, 1)
        end
    end

    -- KillAura
    if toggle.KillAura then
        for _, enemy in pairs(workspace:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                local dist = (enemy.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < 15 then
                    enemy.Humanoid:TakeDamage(10)
                end
            end
        end
    end
end)
