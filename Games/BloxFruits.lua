-- ============================================================
--   Xtray Hub — Blox Fruits
--   Version  : 1.0.0
--   Author   : Xtray
--   GitHub   : https://github.com/ScXtray/all-In-One
-- ============================================================

-- ============================================================
-- [1] SERVICES & VARIABLES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VIM              = game:GetService("VirtualInputManager")
local CollectionService= game:GetService("CollectionService")
local Lighting         = game:GetService("Lighting")

local LP               = Players.LocalPlayer
local PlaceId          = game.PlaceId
local JobId            = game.JobId

-- ============================================================
-- [2] WORLD DETECTION
-- ============================================================
local World1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local World2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local World3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

if not (World1 or World2 or World3) then
    warn("[Xtray] Unsupported PlaceId: " .. PlaceId)
    return
end

-- ============================================================
-- [3] LOAD UI LIBRARY (redzlib)
-- ============================================================
local redzlib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Xtray-scripts/redzlib/main/source.lua"
))()

-- ============================================================
-- [4] WINDOW & TABS
-- ============================================================
local Window = redzlib:CreateWindow({
    Title   = "Xtray Hub",
    SubTitle = "Blox Fruits",
    TabWidth = 160,
    Size     = UDim2.fromOffset(580, 460),
    Acrylic  = true,
    Theme    = "Dark",
})

local Tabs = {
    AutoFarm    = Window:AddTab({ Title = "Auto Farm",     Icon = "swords" }),
    SeaEvent    = Window:AddTab({ Title = "Sea Events",    Icon = "anchor" }),
    Fishing     = Window:AddTab({ Title = "Fishing",       Icon = "fish" }),
    Fruits      = Window:AddTab({ Title = "Fruits",        Icon = "star" }),
    Teleport    = Window:AddTab({ Title = "Teleport",      Icon = "map-pin" }),
    Combat      = Window:AddTab({ Title = "Combat",        Icon = "crosshair" }),
    ESP         = Window:AddTab({ Title = "ESP",           Icon = "eye" }),
    FightStyle  = Window:AddTab({ Title = "Fight Style",   Icon = "zap" }),
    Misc        = Window:AddTab({ Title = "Misc",          Icon = "settings" }),
}

-- ============================================================
-- [5] GLOBAL STATE
-- ============================================================
_G.Mon          = ""
_G.MonFarm      = ""
_G.SelectWeapon = "None"
_G.AutoAttack   = true
_G.BringMonster = false
_G.WalkWater    = true
_G.AutoRaceV4   = false
_G.AutoRaceV3   = false
_G.CheckPoint   = false
_G.RemoveLava   = false
_G.AutoRejoin30m= false

local NeedAttacking = false
local PosMon        = CFrame.new(0, 0, 0)
local CurrentTween  = nil
local StartBring    = false
local DodgewithoutCool = false
local InfiniteGeppo    = false

-- ============================================================
-- [6] HELPER FUNCTIONS
-- ============================================================

-- Teleport (tween)
local function topos(cf)
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local HRP = char.HumanoidRootPart
    if CurrentTween then CurrentTween:Cancel() end
    CurrentTween = TweenService:Create(HRP, TweenInfo.new(0.13, Enum.EasingStyle.Linear), {CFrame = cf})
    CurrentTween:Play()
end

-- Teleport (instant)
local function TP1(cf)
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

-- Stop tween
local function StopTween(state)
    if not state and CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
end

-- Equip weapon
local function EquipWeapon(name)
    pcall(function()
        local tool = LP.Backpack:FindFirstChild(name) or LP.Character:FindFirstChild(name)
        if tool then
            LP.Character.Humanoid:EquipTool(tool)
        end
    end)
end

-- Auto haki
local function AutoHaki()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso", true)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Ken", true)
    end)
end

-- Server hop
local function Hop()
    pcall(function()
        local data = HttpService:JSONDecode(
            game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        local servers = {}
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LP)
        else
            TeleportService:Teleport(PlaceId, LP)
        end
    end)
end

-- Portal travel (Sea 3)
local function TryPortal(position)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", position)
    end)
end

-- ============================================================
-- [7] QUEST DATA
-- ============================================================

local QuestData = {}

if World1 then
    QuestData = {
        -- Level : { NPC_Name, QuestPos, FarmPos, MobName, MinLevel }
        {min=1,   max=14,   mob="Bandit",              quest=CFrame.new(-2567,7,2046),    farm=CFrame.new(-2547,7,1995)},
        {min=15,  max=29,   mob="Monkey",              quest=CFrame.new(-1612,37,149),    farm=CFrame.new(-1591,7,168)},
        {min=30,  max=59,   mob="Gorilla",             quest=CFrame.new(-1612,37,149),    farm=CFrame.new(-1529,40,257)},
        {min=60,  max=89,   mob="Pirate",              quest=CFrame.new(-1181,5,3804),    farm=CFrame.new(-1227,6,3898)},
        {min=90,  max=119,  mob="Monkey",              quest=CFrame.new(-1612,37,149),    farm=CFrame.new(-1591,7,168)},
        {min=120, max=149,  mob="Desert Bandit",       quest=CFrame.new(944,21,4373),     farm=CFrame.new(876,21,4316)},
        {min=150, max=174,  mob="Desert Officer",      quest=CFrame.new(944,21,4373),     farm=CFrame.new(1002,22,4440)},
        {min=175, max=199,  mob="Snow Bandit",         quest=CFrame.new(1347,105,-1320),  farm=CFrame.new(1226,104,-1428)},
        {min=200, max=249,  mob="Snowman",             quest=CFrame.new(1347,105,-1320),  farm=CFrame.new(1415,104,-1390)},
        {min=250, max=299,  mob="Marine",              quest=CFrame.new(-4914,51,4281),   farm=CFrame.new(-4920,50,4127)},
        {min=300, max=374,  mob="Marine Captain",      quest=CFrame.new(-4914,51,4281),   farm=CFrame.new(-4724,51,4282)},
        {min=375, max=449,  mob="Toga Warrior",        quest=CFrame.new(-11,29,2772),     farm=CFrame.new(77,33,2910)},
        {min=450, max=524,  mob="Gladiator",           quest=CFrame.new(-11,29,2772),     farm=CFrame.new(-157,31,2724)},
        {min=525, max=624,  mob="Prisoner",            quest=CFrame.new(4875,6,734),      farm=CFrame.new(4965,6,635)},
        {min=625, max=699,  mob="Dangerous Prisoner",  quest=CFrame.new(4875,6,734),      farm=CFrame.new(5078,6,801)},
        {min=700, max=774,  mob="Sky Bandit",          quest=CFrame.new(-483,332,595),    farm=CFrame.new(-550,320,700)},
        {min=775, max=849,  mob="Assassin",            quest=CFrame.new(-483,332,595),    farm=CFrame.new(-361,332,490)},
        {min=850, max=924,  mob="Sky Castel Guard",    quest=CFrame.new(2284,15,875),     farm=CFrame.new(2344,398,845)},
        {min=925, max=999,  mob="God's Guard",         quest=CFrame.new(2284,15,875),     farm=CFrame.new(2284,398,875)},
        {min=1000,max=1099, mob="Magma Ninja",         quest=CFrame.new(-5247,13,8505),   farm=CFrame.new(-5307,13,8617)},
        {min=1100,max=1199, mob="Dragon Crew Warrior", quest=CFrame.new(-5247,13,8505),   farm=CFrame.new(-5187,13,8394)},
        {min=1200,max=1274, mob="Dragon Crew Shooter", quest=CFrame.new(-5247,13,8505),   farm=CFrame.new(-5130,13,8489)},
        {min=1275,max=1399, mob="Snow Lurker",         quest=CFrame.new(-2448,73,-3211),  farm=CFrame.new(-2527,73,-3131)},
        {min=1400,max=1474, mob="Cosmic Sky Warrior",  quest=CFrame.new(-2448,73,-3211),  farm=CFrame.new(-2369,73,-3291)},
        {min=1475,max=1574, mob="Water Fighter",       quest=CFrame.new(-2850,7,5355),    farm=CFrame.new(-2730,7,5475)},
        {min=1575,max=1674, mob="Fishman Warrior",     quest=CFrame.new(-2850,7,5355),    farm=CFrame.new(-2970,7,5235)},
        {min=1675,max=1774, mob="Fishman Lord",        quest=CFrame.new(-2850,7,5355),    farm=CFrame.new(-2850,7,5235)},
        {min=1775,max=1874, mob="Forest Pirate",       quest=CFrame.new(5127,60,4105),    farm=CFrame.new(5247,60,3985)},
        {min=1875,max=2024, mob="Laboratory Pirate",   quest=CFrame.new(5127,60,4105),    farm=CFrame.new(5007,60,4225)},
    }
elseif World2 then
    QuestData = {
        {min=1500,max=1574, mob="Raider",              quest=CFrame.new(-380,77,256),     farm=CFrame.new(-460,77,176)},
        {min=1575,max=1649, mob="Mercenary",           quest=CFrame.new(-380,77,256),     farm=CFrame.new(-300,77,336)},
        {min=1650,max=1724, mob="Spy",                 quest=CFrame.new(3780,23,-3499),   farm=CFrame.new(3860,23,-3419)},
        {min=1725,max=1799, mob="Scientist",           quest=CFrame.new(424,211,-428),    farm=CFrame.new(344,211,-508)},
        {min=1800,max=1874, mob="Security",            quest=CFrame.new(424,211,-428),    farm=CFrame.new(504,211,-348)},
        {min=1875,max=1949, mob="Factory Staff",       quest=CFrame.new(424,211,-428),    farm=CFrame.new(424,211,-508)},
        {min=1950,max=2024, mob="Gladiator",           quest=CFrame.new(-1504,220,1369),  farm=CFrame.new(-1584,220,1289)},
        {min=2025,max=2099, mob="Saber Expert",        quest=CFrame.new(-1504,220,1369),  farm=CFrame.new(-1424,220,1449)},
        {min=2100,max=2174, mob="Zombie",              quest=CFrame.new(-3219,9,-3286),   farm=CFrame.new(-3139,9,-3206)},
        {min=2175,max=2249, mob="Vampire",             quest=CFrame.new(-3219,9,-3286),   farm=CFrame.new(-3299,9,-3366)},
        {min=2250,max=2324, mob="Snow Lurker",         quest=CFrame.new(753,408,-5275),   farm=CFrame.new(673,408,-5355)},
        {min=2325,max=2399, mob="Yeti",                quest=CFrame.new(753,408,-5275),   farm=CFrame.new(833,408,-5195)},
        {min=2400,max=2474, mob="Toxic Punk",          quest=CFrame.new(-6128,16,-5040),  farm=CFrame.new(-6048,16,-4960)},
        {min=2475,max=2549, mob="Laboratory Punk",     quest=CFrame.new(-6128,16,-5040),  farm=CFrame.new(-6208,16,-5120)},
        {min=2550,max=2624, mob="Deranged Punk",       quest=CFrame.new(-6128,16,-5040),  farm=CFrame.new(-6128,16,-5120)},
        {min=2625,max=2699, mob="Cursed Pirate",       quest=CFrame.new(-1024,83,-6762),  farm=CFrame.new(-944,83,-6682)},
        {min=2700,max=2774, mob="Elf",                 quest=CFrame.new(-3032,303,-12300),farm=CFrame.new(-2952,303,-12220)},
        {min=2775,max=2849, mob="Arctic Warrior",      quest=CFrame.new(-3032,303,-12300),farm=CFrame.new(-3112,303,-12380)},
        {min=2850,max=2974, mob="Pirate",              quest=CFrame.new(4816,8,2864),     farm=CFrame.new(4736,8,2784)},
        {min=2975,max=3099, mob="Galley Pirate",       quest=CFrame.new(4816,8,2864),     farm=CFrame.new(4896,8,2944)},
        {min=3100,max=3224, mob="Sky Pirate",          quest=CFrame.new(-288,49326,-35249),farm=CFrame.new(-368,49326,-35329)},
        {min=3225,max=3349, mob="Cloud Elemental",     quest=CFrame.new(-288,49326,-35249),farm=CFrame.new(-208,49326,-35169)},
    }
elseif World3 then
    QuestData = {
        {min=3500,max=3574, mob="Pirate Millionaire",  quest=CFrame.new(-227,21,5538),    farm=CFrame.new(-307,21,5458)},
        {min=3575,max=3649, mob="Pirate Captain",      quest=CFrame.new(-227,21,5538),    farm=CFrame.new(-147,21,5618)},
        {min=3650,max=3724, mob="Forest Pirate",       quest=CFrame.new(2681,1683,-7191), farm=CFrame.new(2601,1683,-7271)},
        {min=3725,max=3799, mob="Tree Spider",         quest=CFrame.new(2681,1683,-7191), farm=CFrame.new(2761,1683,-7111)},
        {min=3800,max=3874, mob="Island Pirate",       quest=CFrame.new(-226,21,5538),    farm=CFrame.new(-306,21,5458)},
        {min=3875,max=3949, mob="Roughhouse Pirate",   quest=CFrame.new(-13275,532,-7579),farm=CFrame.new(-13355,532,-7659)},
        {min=3950,max=4024, mob="Jade Emperor",        quest=CFrame.new(5291,1005,394),   farm=CFrame.new(5371,1005,314)},
        {min=4025,max=4099, mob="Hydra Dragon",        quest=CFrame.new(5291,1005,394),   farm=CFrame.new(5211,1005,474)},
        {min=4100,max=4174, mob="Pirate Officer",      quest=CFrame.new(-9515,164,5786),  farm=CFrame.new(-9435,164,5706)},
        {min=4175,max=4249, mob="Possessed Mummy",     quest=CFrame.new(-9515,164,5786),  farm=CFrame.new(-9595,164,5866)},
        {min=4250,max=4324, mob="Cocoa Warrior",       quest=CFrame.new(88,74,-12319),    farm=CFrame.new(8,74,-12399)},
        {min=4325,max=4399, mob="Sweet Thief",         quest=CFrame.new(-1885,19,-11667), farm=CFrame.new(-1965,19,-11747)},
        {min=4400,max=4474, mob="Candy Pirate",        quest=CFrame.new(-1014,149,-14556),farm=CFrame.new(-1094,149,-14636)},
        {min=4475,max=4549, mob="Ice Cream Chef",      quest=CFrame.new(-903,80,-10989),  farm=CFrame.new(-983,80,-11069)},
        {min=4550,max=4624, mob="Peanut Staff",        quest=CFrame.new(-2063,50,-10233), farm=CFrame.new(-2143,50,-10313)},
        {min=4625,max=4699, mob="Shark Pirate",        quest=CFrame.new(-16219,9,446),    farm=CFrame.new(-16299,9,366)},
        {min=4700,max=4799, mob="Dragon Warrior",      quest=CFrame.new(5743,1207,936),   farm=CFrame.new(5663,1207,1016)},
    }
end

-- ============================================================
-- [8] CHECKQUEST FUNCTION
-- ============================================================
local function CheckQuest()
    pcall(function()
        local char = LP.Character
        if not char or not char:FindFirstChild("Humanoid") then return end
        local level = LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Level") and LP.Data.Level.Value or 1

        for _, q in ipairs(QuestData) do
            if level >= q.min and level <= q.max then
                if _G.Mon ~= q.mob then
                    _G.Mon    = q.mob
                    _G.MonFarm= q.mob
                    PosMon    = q.farm
                    -- Accept quest
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", q.mob)
                end
                break
            end
        end
    end)
end

-- ============================================================
-- [9] ESP SYSTEMS
-- ============================================================

-- Chest ESP
local function UpdateChestESP()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "ChestESP" then obj:Destroy() end
        end
        if not _G.ChestESP then return end
        for _, chest in pairs(workspace:GetDescendants()) do
            if (chest.Name == "Chest" or chest.Name == "GoldChest") and chest:IsA("BasePart") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ChestESP"
                bg.Adornee = chest
                bg.Size = UDim2.new(0,120,0,30)
                bg.StudsOffset = Vector3.new(0,2,0)
                bg.AlwaysOnTop = true
                bg.MaxDistance = 999999
                bg.Parent = chest
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.TextScaled = true
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextColor3 = Color3.fromRGB(255,215,0)
                lbl.TextStrokeTransparency = 0
                lbl.Text = "Chest"
                lbl.Parent = bg
            end
        end
    end)
end

-- Berry ESP
local function UpdateBerriesESP()
    pcall(function()
        for _, berry in pairs(CollectionService:GetTagged("BerryBush")) do
            if not berry.Parent:FindFirstChild("BerryESP") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "BerryESP"
                bg.Adornee = berry
                bg.Size = UDim2.new(0,100,0,25)
                bg.StudsOffset = Vector3.new(0,2,0)
                bg.AlwaysOnTop = true
                bg.MaxDistance = 999999
                bg.Parent = berry.Parent
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.TextScaled = true
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextColor3 = Color3.fromRGB(255,80,80)
                lbl.TextStrokeTransparency = 0
                lbl.Text = "Berry"
                lbl.Parent = bg
            end
        end
    end)
end

-- Kitsune Island ESP
local function UpdateIslandKisuneESP()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "KitsuneESP" then obj:Destroy() end
        end
        if not KitsuneIslandEsp then return end
        for _, loc in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
            if loc.Name == "Kitsune Island" then
                local bg = Instance.new("BillboardGui")
                bg.Name = "KitsuneESP"
                bg.Adornee = loc
                bg.Size = UDim2.new(0,180,0,35)
                bg.StudsOffset = Vector3.new(0,5,0)
                bg.AlwaysOnTop = true
                bg.MaxDistance = 999999
                bg.Parent = loc
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.TextScaled = true
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextColor3 = Color3.fromRGB(255,165,0)
                lbl.TextStrokeTransparency = 0
                lbl.Text = "Kitsune Island"
                lbl.Parent = bg
            end
        end
    end)
end

-- Mirage Island ESP
local function UpdateIslandMirageESP()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "MirageESP" then obj:Destroy() end
        end
        if not MirageIslandESP then return end
        for _, loc in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
            if loc.Name == "Mirage Island" then
                local bg = Instance.new("BillboardGui")
                bg.Name = "MirageESP"
                bg.Adornee = loc
                bg.Size = UDim2.new(0,180,0,35)
                bg.StudsOffset = Vector3.new(0,5,0)
                bg.AlwaysOnTop = true
                bg.MaxDistance = 999999
                bg.Parent = loc
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.TextScaled = true
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextColor3 = Color3.fromRGB(80,200,255)
                lbl.TextStrokeTransparency = 0
                lbl.Text = "Mirage Island"
                lbl.Parent = bg
            end
        end
    end)
end

-- State variables for ESP toggles (declared before UI sections use them)
local KitsuneIslandEsp = false
local MirageIslandESP  = false
local Berry            = false

-- ============================================================
-- [10] TAB: AUTO FARM
-- ============================================================
local AF = Tabs.AutoFarm

AF:AddSection("Farm Settings")

AF:AddDropdown({
    Name    = "Select Weapon",
    Options = {"None","Pole (1st Form)","Pole (2nd Form)","Trident","Dark Blade","Saber","Soul Cane","Yama","Tushita","True Triple Katana","Gravity Cane","Koko","Serpent Bow","Acidum Rifle","Kabucha","Refined Flintlock","Refined Musket"},
    Default = "None",
    Callback = function(v)
        _G.SelectWeapon = v
    end
})

AF:AddSection("Auto Farm")

_G.AutoFarm = false
AF:AddToggle({
    Name    = "Auto Farm",
    Default = false,
    Callback = function(v)
        _G.AutoFarm = v
        StartBring = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoFarm then
                CheckQuest()
                local char = LP.Character
                if not char or not char:FindFirstChild("Humanoid") then return end
                if char.Humanoid.Health <= 0 then return end

                EquipWeapon(_G.SelectWeapon)
                AutoHaki()

                local target = nil
                local minDist = math.huge
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == _G.Mon and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        local dist = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target  = mob
                        end
                    end
                end

                if target then
                    repeat
                        task.wait()
                        if target.Humanoid.Health > 0 then
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            target.HumanoidRootPart.CanCollide = false
                            target.HumanoidRootPart.Size = Vector3.new(60,60,60)
                            target.HumanoidRootPart.CFrame = PosMon
                            if target.Humanoid:FindFirstChild("Animator") then
                                target.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(LP, "SimulationRadius", math.huge)
                            topos(PosMon * CFrame.new(0,5,0))
                        end
                    until not _G.AutoFarm or not target.Parent or target.Humanoid.Health <= 0
                else
                    topos(PosMon * CFrame.new(0,5,0))
                end
            end
        end)
    end
end)

AF:AddSection("Nearest Enemy Farm")

_G.NearestFarm = false
AF:AddToggle({
    Name    = "Auto Farm Nearest",
    Default = false,
    Callback = function(v)
        _G.NearestFarm = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.NearestFarm then
                local char = LP.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                if char.Humanoid.Health <= 0 then return end

                EquipWeapon(_G.SelectWeapon)
                AutoHaki()

                local target, minDist = nil, math.huge
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        local dist = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target  = mob
                        end
                    end
                end

                if target then
                    repeat
                        task.wait()
                        AutoHaki()
                        EquipWeapon(_G.SelectWeapon)
                        target.HumanoidRootPart.CanCollide = false
                        topos(target.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
                    until not _G.NearestFarm or not target.Parent or target.Humanoid.Health <= 0
                end
            end
        end)
    end
end)

AF:AddSection("Boss Farm")

local BossData = {}
if World1 then
    BossData = {
        "Gorilla King","Bobby","Yeti","Mob Enforcer","Swan","Saber Expert",
        "Vice Admiral","Warden","Chief Warden","Magma Admiral","Lord of Destruction",
        "Smoke Admiral","Fishman Lord","Wysper","Thunder God","Floating Skeleton",
        "Dark Master","Golden Boss","rip_indra (Sea 1)"
    }
elseif World2 then
    BossData = {
        "Darkbeard","Order","Fajita","Don Swan","Diamond","Jeremy","Smoke Admiral",
        "Tide Keeper","Cursed Captain","rip_indra (Sea 2)","Cake Prince","Sea Beast"
    }
elseif World3 then
    BossData = {
        "Longma","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate",
        "rip_indra (Sea 3)","Cake Queen","Sea Beast","Leviathan","Demonic Soul","Dough King",
        "Tiki Outpost Boss","Soul Reaper"
    }
end

_G.SelectBoss    = BossData[1] or "None"
_G.AutoBossFarm  = false

AF:AddDropdown({
    Name    = "Select Boss",
    Options = BossData,
    Default = _G.SelectBoss,
    Callback = function(v)
        _G.SelectBoss = v
    end
})

AF:AddToggle({
    Name    = "Auto Farm Boss",
    Default = false,
    Callback = function(v)
        _G.AutoBossFarm = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoBossFarm then
                local char = LP.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                EquipWeapon(_G.SelectWeapon)
                AutoHaki()
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == _G.SelectBoss and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            mob.HumanoidRootPart.CanCollide = false
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
                        until not _G.AutoBossFarm or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end
        end)
    end
end)

AF:AddSection("Material Farm")

local MaterialList = {
    "Leather","Scrap Metal","Minerals","Magma Ore","Dragon Scale",
    "Angel Wings","Mystic Droplet","Vampire Fang","Gunpowder",
    "Conjured Cocoa","Mini Tusk","Mythological Pirate"
}

_G.SelectMaterial  = MaterialList[1]
_G.AutoMaterialFarm= false

AF:AddDropdown({
    Name    = "Select Material",
    Options = MaterialList,
    Default = _G.SelectMaterial,
    Callback = function(v)
        _G.SelectMaterial = v
    end
})

AF:AddToggle({
    Name    = "Auto Farm Material",
    Default = false,
    Callback = function(v)
        _G.AutoMaterialFarm = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoMaterialFarm then
                local char = LP.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                EquipWeapon(_G.SelectWeapon)
                AutoHaki()
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        local drops = mob:GetChildren()
                        for _, d in pairs(drops) do
                            if d.Name == _G.SelectMaterial then
                                repeat
                                    task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.SelectWeapon)
                                    mob.HumanoidRootPart.CanCollide = false
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
                                until not _G.AutoMaterialFarm or not mob.Parent or mob.Humanoid.Health <= 0
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end)

AF:AddSection("Auto Skills")

_G.AutoSkillZ = false
_G.AutoSkillX = false
_G.AutoSkillC = false

AF:AddToggle({Name="Auto Skill Z", Default=false, Callback=function(v) _G.AutoSkillZ=v end})
AF:AddToggle({Name="Auto Skill X", Default=false, Callback=function(v) _G.AutoSkillX=v end})
AF:AddToggle({Name="Auto Skill C", Default=false, Callback=function(v) _G.AutoSkillC=v end})

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.AutoSkillZ then VIM:SendKeyEvent(true,"Z",false,game) task.wait(0.05) VIM:SendKeyEvent(false,"Z",false,game) end
            if _G.AutoSkillX then VIM:SendKeyEvent(true,"X",false,game) task.wait(0.05) VIM:SendKeyEvent(false,"X",false,game) end
            if _G.AutoSkillC then VIM:SendKeyEvent(true,"C",false,game) task.wait(0.05) VIM:SendKeyEvent(false,"C",false,game) end
        end)
    end
end)

AF:AddSection("Auto Haki")

_G.AutoHakiToggle = false
AF:AddToggle({
    Name    = "Auto Equip Haki",
    Default = false,
    Callback = function(v)
        _G.AutoHakiToggle = v
    end
})

spawn(function()
    while task.wait(1) do
        if _G.AutoHakiToggle then
            AutoHaki()
        end
    end
end)

-- ============================================================
-- [11] TAB: SEA EVENTS
-- ============================================================
local SE = Tabs.SeaEvent

SE:AddSection("Boat Events")

_G.AutoBoat = false
SE:AddToggle({
    Name    = "Auto Farm Boat (Tween)",
    Default = false,
    Callback = function(v)
        _G.AutoBoat = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.AutoBoat then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Boat" or obj.Name == "BoatEnemy" then
                        if obj:FindFirstChild("HumanoidRootPart") then
                            topos(obj.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
                        end
                    end
                end
            end
        end)
    end
end)

SE:AddSection("Shark Events")

_G.AutoShark = false
SE:AddToggle({
    Name    = "Auto Farm Shark",
    Default = false,
    Callback = function(v)
        _G.AutoShark = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.AutoShark then
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == "Shark" and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        EquipWeapon(_G.SelectWeapon)
                        AutoHaki()
                        topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
                    end
                end
            end
        end)
    end
end)

SE:AddSection("Terror Shark")

_G.AutoTerrorShark = false
SE:AddToggle({
    Name    = "Auto Farm Terror Shark",
    Default = false,
    Callback = function(v)
        _G.AutoTerrorShark = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.AutoTerrorShark then
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == "Sea Beast" and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        EquipWeapon(_G.SelectWeapon)
                        AutoHaki()
                        mob.HumanoidRootPart.CanCollide = false
                        topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,8,0))
                    end
                end
            end
        end)
    end
end)

SE:AddSection("Bounty Expert")

_G.AutoBountyExpert = false
SE:AddToggle({
    Name    = "Auto Tween to Bounty Expert",
    Default = false,
    Callback = function(v)
        _G.AutoBountyExpert = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.AutoBountyExpert then
                for _, npc in pairs(workspace.NPCs:GetChildren()) do
                    if npc.Name == "Bounty Expert" and npc:FindFirstChild("HumanoidRootPart") then
                        topos(npc.HumanoidRootPart.CFrame * CFrame.new(0,3,3))
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- [12] TAB: FISHING
-- ============================================================
local FT = Tabs.Fishing

FT:AddSection("Auto Fishing")

_G.AutoFish  = false
_G.AutoSell  = false

FT:AddToggle({
    Name    = "Auto Fishing",
    Default = false,
    Callback = function(v)
        _G.AutoFish = v
    end
})

FT:AddToggle({
    Name    = "Auto Sell Fish",
    Default = false,
    Callback = function(v)
        _G.AutoSell = v
    end
})

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.AutoFish then
                local rod = LP.Backpack:FindFirstChild("Fishing Rod") or LP.Character:FindFirstChild("Fishing Rod")
                if rod then
                    LP.Character.Humanoid:EquipTool(rod)
                    VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                end
            end
        end)
    end
end)

spawn(function()
    while task.wait(2) do
        pcall(function()
            if _G.AutoSell then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SellFish")
            end
        end)
    end
end)

-- ============================================================
-- [13] TAB: FRUITS
-- ============================================================
local FR = Tabs.Fruits

FR:AddSection("Fruit Actions")

local FruitList = {
    {"Rocket Fruit",    "Rocket-Rocket"},
    {"Spin Fruit",      "Spin-Spin"},
    {"Blade Fruit",     "Blade-Blade"},
    {"Spring Fruit",    "Spring-Spring"},
    {"Bomb Fruit",      "Bomb-Bomb"},
    {"Smoke Fruit",     "Smoke-Smoke"},
    {"Spike Fruit",     "Spike-Spike"},
    {"Flame Fruit",     "Flame-Flame"},
    {"Eagle Fruit",     "Eagle-Eagle"},
    {"Ice Fruit",       "Ice-Ice"},
    {"Sand Fruit",      "Sand-Sand"},
    {"Dark Fruit",      "Dark-Dark"},
    {"Diamond Fruit",   "Diamond-Diamond"},
    {"Light Fruit",     "Light-Light"},
    {"Rubber Fruit",    "Rubber-Rubber"},
    {"Creation Fruit",  "Creation-Creation"},
    {"Ghost Fruit",     "Ghost-Ghost"},
    {"Magma Fruit",     "Magma-Magma"},
    {"Quake Fruit",     "Quake-Quake"},
    {"Buddha Fruit",    "Buddha-Buddha"},
    {"Love Fruit",      "Love-Love"},
    {"Spider Fruit",    "Spider-Spider"},
    {"Sound Fruit",     "Sound-Sound"},
    {"Phoenix Fruit",   "Phoenix-Phoenix"},
    {"Portal Fruit",    "Portal-Portal"},
    {"Lightning Fruit", "Lightning-Lightning"},
    {"Pain Fruit",      "Pain-Pain"},
    {"Blizzard Fruit",  "Blizzard-Blizzard"},
    {"Gravity Fruit",   "Gravity-Gravity"},
    {"Mammoth Fruit",   "Mammoth-Mammoth"},
    {"T-Rex Fruit",     "T-Rex-T-Rex"},
    {"Dough Fruit",     "Dough-Dough"},
    {"Shadow Fruit",    "Shadow-Shadow"},
    {"Venom Fruit",     "Venom-Venom"},
    {"Gas Fruit",       "Gas-Gas"},
    {"Control Fruit",   "Control-Control"},
    {"Spirit Fruit",    "Spirit-Spirit"},
    {"Leopard Fruit",   "Leopard-Leopard"},
    {"Yeti Fruit",      "Yeti-Yeti"},
    {"Kitsune Fruit",   "Kitsune-Kitsune"},
    {"Dragon Fruit",    "Dragon-Dragon"},
}

FR:AddToggle({
    Name    = "Auto Random Fruits",
    Default = false,
    Callback = function(v)
        _G.RandomAuto = v
    end
})

spawn(function()
    while task.wait() do
        if _G.RandomAuto then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin","Buy")
            end)
        end
    end
end)

FR:AddToggle({
    Name    = "Auto Store Fruits",
    Default = false,
    Callback = function(v)
        getgenv().AutoStoreFruit = v
    end
})

spawn(function()
    while task.wait(0.2) do
        if getgenv().AutoStoreFruit then
            pcall(function()
                local char   = LP.Character or LP.CharacterAdded:Wait()
                local pack   = LP:WaitForChild("Backpack")
                for _, fruit in ipairs(FruitList) do
                    local name = fruit[1]
                    local id   = fruit[2]
                    local tool = pack:FindFirstChild(name) or char:FindFirstChild(name)
                    if tool then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", id, tool)
                        break
                    end
                end
            end)
        end
    end
end)

FR:AddToggle({
    Name    = "Teleport To Fruit Spawn",
    Default = false,
    Callback = function(v)
        _G.TweenFruit = v
    end
})

spawn(function()
    while task.wait(0.1) do
        if _G.TweenFruit then
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name,"Fruit") and obj:FindFirstChild("Handle") then
                    TP1(obj.Handle.CFrame)
                end
            end
        end
    end
end)

FR:AddToggle({
    Name    = "Auto Grab Fruits",
    Default = false,
    Callback = function(v)
        _G.Grabfruit = v
    end
})

spawn(function()
    while task.wait(0.1) do
        if _G.Grabfruit then
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name,"Fruit") and obj:FindFirstChild("Handle") then
                    local char = LP.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj.Handle.CFrame
                    end
                end
            end
        end
    end
end)

FR:AddSection("Check Stock Fruits")

local function FormatNumber(n)
    local s = tostring(n)
    repeat
        local _, c = s:gsub("^(-?%d+)(%d%d%d)","%%1,%%2")
        s = s:gsub("^(-?%d+)(%d%d%d)","%1,%2")
    until c == 0
    return s
end

local function GetFruitStock()
    local txt = "Advance Fruit Stock\n"
    local ok, res = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits",true) end)
    if ok and res then
        local any = false
        for _, f in pairs(res) do
            if f.OnSale then any = true; txt = txt .. f.Name .. " - $" .. FormatNumber(f.Price) .. "\n" end
        end
        if not any then txt = txt .. "- No fruits in stock.\n" end
    else
        txt = txt .. "- Failed to load.\n"
    end
    txt = txt .. "\nNormal Fruit Stock\n"
    ok, res = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits") end)
    if ok and res then
        local any = false
        for _, f in pairs(res) do
            if f.OnSale then any = true; txt = txt .. f.Name .. " - $" .. FormatNumber(f.Price) .. "\n" end
        end
        if not any then txt = txt .. "- No fruits in stock.\n" end
    else
        txt = txt .. "- Failed to load.\n"
    end
    return txt
end

local StockParagraph = FR:AddParagraph({Title="Stock", Content="Loading..."})
task.spawn(function() while task.wait(60) do pcall(function() StockParagraph:Set(GetFruitStock()) end) end end)
pcall(function() StockParagraph:Set(GetFruitStock()) end)

-- Raid section (Sea 2 / Sea 3 only)
if not World1 then
    FR:AddSection("Raid Fruits")

    _G.SelectChip = "Flame"
    _G.AutoBuyChip= false
    _G.StartRaid  = false
    _G.Dungeon    = false

    FR:AddDropdown({
        Name    = "Select Chip",
        Options = {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Spider","Phoenix","Lightning","Dough"},
        Default = "Flame",
        Callback = function(v) _G.SelectChip = v end
    })

    FR:AddToggle({Name="Auto Buy Chip", Default=false, Callback=function(v) _G.AutoBuyChip=v end})

    task.spawn(function()
        while task.wait(1) do
            if _G.AutoBuyChip and _G.SelectChip then
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc","Select",_G.SelectChip)
                end)
            end
        end
    end)

    FR:AddToggle({Name="Auto Start Raid", Default=false, Callback=function(v) _G.StartRaid=v end})

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if not _G.StartRaid then return end
                local gui = LP.PlayerGui:FindFirstChild("Main")
                if not gui then return end
                if gui.Timer.Visible then return end
                if workspace._WorldOrigin.Locations:FindFirstChild("Island 1") then return end
                if not (LP.Backpack:FindFirstChild("Special Microchip") or LP.Character:FindFirstChild("Special Microchip")) then return end
                if World2 then
                    topos(CFrame.new(-6438.73,250.64,-4501.5))
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
                    fireclickdetector(workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                elseif World3 then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5075.5,314.51,-3150.02))
                    topos(CFrame.new(-5017.4,314.84,-2823.01))
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
                    fireclickdetector(workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                end
            end)
        end
    end)

    FR:AddToggle({Name="Auto Farm Raid Next Island", Default=false, Callback=function(v) _G.Dungeon=v end})

    local function GetIsland(num)
        local closest, dist = nil, math.huge
        for _, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
            if v.Name == "Island "..num then
                local mag = (v.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then dist = mag; closest = v end
            end
        end
        return closest
    end

    local function GetNextIsland()
        for _, i in ipairs({5,4,3,2,1}) do
            local isl = GetIsland(i)
            if isl and (isl.Position - LP.Character.HumanoidRootPart.Position).Magnitude <= 4500 then return isl end
        end
    end

    task.spawn(function()
        while task.wait() do
            if _G.Dungeon then
                pcall(function()
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0
                        and (mob.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude <= 1000 then
                            repeat
                                task.wait(0.1)
                                if mob.Humanoid.Health > 0 then
                                    EquipWeapon(_G.SelectWeapon)
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                end
                            until mob.Humanoid.Health <= 0 or not _G.Dungeon
                        end
                    end
                    local isl = GetNextIsland()
                    if isl then topos(isl.CFrame * CFrame.new(0,60,0)) end
                end)
            end
        end
    end)
end

-- Raid Law (Sea 2 only)
if World2 then
    FR:AddSection("Raid Law (Sea 2)")

    FR:AddButton({
        Title    = "Auto Buy Chip Law",
        Callback = function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","Microchip","2")
        end
    })

    FR:AddButton({
        Title    = "Auto Start Raid Law",
        Callback = function()
            fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
        end
    })

    FR:AddToggle({Name="Auto Farm Law Raid", Default=false, Callback=function(v) _G.AutoLawRaid=v end})

    spawn(function()
        while task.wait() do
            if _G.AutoLawRaid then
                pcall(function()
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name == "Order" and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.CanCollide = false
                                mob.Humanoid.WalkSpeed = 0
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                sethiddenproperty(LP,"SimulationRadius",math.huge)
                            until not _G.AutoLawRaid or not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                end)
            end
        end
    end)
end

-- Special islands (Sea 3)
if World3 then
    FR:AddSection("Kitsune Island")

    FR:AddToggle({
        Name    = "Auto Tween Kitsune Island",
        Default = false,
        Callback = function(v)
            _G.AutoKitsune = v
            StopTween(v)
        end
    })

    spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if _G.AutoKitsune then
                    for _, loc in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
                        if loc.Name == "Kitsune Island" then topos(loc.CFrame * CFrame.new(0,50,0)) end
                    end
                end
            end)
        end
    end)

    FR:AddToggle({
        Title   = "ESP Kitsune Island",
        Value   = false,
        Callback = function(v)
            KitsuneIslandEsp = v
            if v then task.spawn(function() while KitsuneIslandEsp do UpdateIslandKisuneESP() task.wait(1) end end)
            else UpdateIslandKisuneESP() end
        end
    })

    FR:AddSection("Mirage Island")

    local MiragePara = FR:AddParagraph({Title="Mirage Island Status", Content="Checking..."})
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if not workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") then
                    MiragePara:Set("Mirage Island: Not Spawned")
                else
                    MiragePara:Set("Mirage Island: SPAWNED!")
                end
            end)
        end
    end)

    FR:AddToggle({
        Name    = "Tween Mirage Island",
        Default = false,
        Callback = function(v)
            _G.AutoMysticIsland = v
            StopTween(v)
        end
    })

    spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if _G.AutoMysticIsland then
                    for _, loc in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
                        if loc.Name == "Mirage Island" then
                            topos(loc.CFrame * CFrame.new(0,333,0))
                        end
                    end
                end
            end)
        end
    end)

    FR:AddToggle({
        Title   = "ESP Mirage Island",
        Value   = false,
        Callback = function(v)
            MirageIslandESP = v
            if v then task.spawn(function() while MirageIslandESP do UpdateIslandMirageESP() task.wait(1) end end)
            else UpdateIslandMirageESP() end
        end
    })

    FR:AddSection("Azure Ember")

    FR:AddToggle({
        Name    = "Auto Azure Ember",
        Default = false,
        Callback = function(v)
            _G.AutoAzuerEmber = v
            StopTween(v)
        end
    })

    spawn(function()
        while task.wait() do
            pcall(function()
                if _G.AutoAzuerEmber then
                    if workspace:FindFirstChild("AttachedAzureEmber") then
                        TP1(workspace.EmberTemplate.Part.CFrame)
                    end
                end
            end)
        end
    end)

    FR:AddSection("Look Moon + V3")

    FR:AddToggle({
        Name    = "Look Moon + Auto V3",
        Default = false,
        Callback = function(v)
            _G.AutoDooHee = v
            StopTween(v)
        end
    })

    spawn(function()
        while task.wait() do
            pcall(function()
                if _G.AutoDooHee then
                    local moonDir = Lighting:GetMoonDirection()
                    local camPos  = workspace.CurrentCamera.CFrame.p
                    workspace.CurrentCamera.CFrame = CFrame.lookAt(camPos, camPos + moonDir * 100)
                    task.wait(2)
                    VIM:SendKeyEvent(true,"T",false,game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false,"T",false,game)
                end
            end)
        end
    end)
end

-- ============================================================
-- [14] TAB: TELEPORT
-- ============================================================
local TP = Tabs.Teleport

TP:AddSection("Teleport Island")

local IslandList = {}
if World1 then
    IslandList = {
        "WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert",
        "Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2",
        "Sky Island 3","Prison","Magma Village","Under Water Island","Fountain City",
        "Shank Room","Mob Island"
    }
elseif World2 then
    IslandList = {
        "The Cafe","Dark Area","Factory","Colossuim","Zombie Island",
        "Two Snow Mountain","Punk Hazard","Cursed Ship","Ice Castle",
        "Forgotten Island","Ussop Island","Mini Sky Island",
        "Flamingo Mansion","Flamingo Room","Green Zone"
    }
elseif World3 then
    IslandList = {
        "Mansion","Port Town","Great Tree","Castle On The Sea","MiniSky",
        "Hydra Island","Floating Turtle","Haunted Castle","Ice Cream Island",
        "Peanut Island","Cake Island","Cocoa Island","Candy Island",
        "Tiki Outpost","Dragon Dojo"
    }
end

local IslandCFrames = {
    -- Sea 1
    ["WindMill"]            = CFrame.new(979.799,16.516,1429.047),
    ["Marine"]              = CFrame.new(-2566.43,6.856,2045.256),
    ["Middle Town"]         = CFrame.new(-690.331,15.094,1582.238),
    ["Jungle"]              = CFrame.new(-1612.796,36.852,149.128),
    ["Pirate Village"]      = CFrame.new(-1181.309,4.751,3803.546),
    ["Desert"]              = CFrame.new(944.158,20.92,4373.3),
    ["Snow Island"]         = CFrame.new(1347.807,104.668,-1319.737),
    ["MarineFord"]          = CFrame.new(-4914.821,50.964,4281.028),
    ["Magma Village"]       = CFrame.new(-5247.716,12.884,8504.969),
    ["Fountain City"]       = CFrame.new(5127.128,59.501,4105.446),
    ["Sky Island 1"]        = CFrame.new(-483.734,332.038,595.327),
    ["Sky Island 2"]        = CFrame.new(2284.414,15.152,875.725),
    ["Sky Island 3"]        = CFrame.new(-2448.53,73.016,-3210.631),
    ["Prison"]              = CFrame.new(4875.33,5.652,734.85),
    ["Colosseum"]           = CFrame.new(-11.311,29.277,2771.522),
    ["Under Water Island"]  = CFrame.new(-2850.201,7.392,5354.993),
    ["Shank Room"]          = CFrame.new(-1442.166,29.879,-28.355),
    ["Mob Island"]          = CFrame.new(-2850.201,7.392,5354.993),
    -- Sea 2
    ["The Cafe"]            = CFrame.new(-380.479,77.22,255.826),
    ["Dark Area"]           = CFrame.new(3780.03,22.652,-3498.586),
    ["Factory"]             = CFrame.new(424.127,211.162,-427.54),
    ["Colossuim"]           = CFrame.new(-1503.622,219.796,1369.31),
    ["Zombie Island"]       = CFrame.new(-3219,9,-3286),
    ["Two Snow Mountain"]   = CFrame.new(753.143,408.236,-5274.615),
    ["Punk Hazard"]         = CFrame.new(-6127.654,15.952,-5040.286),
    ["Cursed Ship"]         = CFrame.new(-1024,83,-6762),
    ["Ice Castle"]          = CFrame.new(-3032,303,-12300),
    ["Forgotten Island"]    = CFrame.new(-3032,303,-12300),
    ["Ussop Island"]        = CFrame.new(4816.862,8.46,2863.82),
    ["Mini Sky Island"]     = CFrame.new(-288.741,49326.316,-35248.594),
    ["Flamingo Mansion"]    = CFrame.new(-11.311,29.277,2771.522),
    ["Flamingo Room"]       = CFrame.new(-11.311,29.277,2771.522),
    ["Green Zone"]          = CFrame.new(-11.311,29.277,2771.522),
    -- Sea 3
    ["Mansion"]             = CFrame.new(-12471.17,374.94,-7551.678),
    ["Port Town"]           = CFrame.new(-226.751,20.603,5538.34),
    ["Great Tree"]          = CFrame.new(2681.274,1682.809,-7190.985),
    ["Castle On The Sea"]   = CFrame.new(-5017.4,314.84,-2823.01),
    ["MiniSky"]             = CFrame.new(-288.741,49326.316,-35248.594),
    ["Hydra Island"]        = CFrame.new(5291.249,1005.443,393.762),
    ["Floating Turtle"]     = CFrame.new(-13274.528,531.821,-7579.223),
    ["Haunted Castle"]      = CFrame.new(-9515.372,164.006,5786.061),
    ["Ice Cream Island"]    = CFrame.new(-902.568,79.932,-10988.848),
    ["Peanut Island"]       = CFrame.new(-2062.748,50.474,-10232.568),
    ["Cake Island"]         = CFrame.new(-1884.775,19.328,-11666.897),
    ["Cocoa Island"]        = CFrame.new(87.943,73.555,-12319.465),
    ["Candy Island"]        = CFrame.new(-1014.424,149.111,-14555.963),
    ["Tiki Outpost"]        = CFrame.new(-16218.683,9.086,445.618),
    ["Dragon Dojo"]         = CFrame.new(5743.319,1206.91,936.011),
}

_G.SelectIsland    = IslandList[1] or "None"
_G.TeleportIsland  = false

TP:AddDropdown({
    Name    = "Select Island",
    Options = IslandList,
    Default = _G.SelectIsland,
    Callback = function(v) _G.SelectIsland = v end
})

TP:AddToggle({
    Name    = "Auto Tween To Island",
    Default = false,
    Callback = function(v)
        _G.TeleportIsland = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.TeleportIsland and _G.SelectIsland and IslandCFrames[_G.SelectIsland] then
                local cf = IslandCFrames[_G.SelectIsland]
                if World3 then TryPortal(cf.Position) end
                topos(cf)
            end
        end)
    end
end)

TP:AddButton({
    Title   = "Teleport Now",
    Callback = function()
        pcall(function()
            if _G.SelectIsland and IslandCFrames[_G.SelectIsland] then
                local cf = IslandCFrames[_G.SelectIsland]
                if World3 then TryPortal(cf.Position) end
                TP1(cf)
            end
        end)
    end
})

-- ============================================================
-- [15] TAB: COMBAT (Aimbot)
-- ============================================================
local CB = Tabs.Combat

CB:AddSection("Aimbot Gun")

local AimbotEnabled = false
local AimPlayers    = false
local AimMobs       = false
local IgnoreMobs    = true
local v1_aimbot = nil

pcall(function()
    v1_aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/PlockScripts/Aimbot-skill-config/refs/heads/main/Aimbot.lua"))()
end)

local function UpdateAimbot()
    if not v1_aimbot then return end
    if not AimbotEnabled then
        v1_aimbot:SetPlayerSilentAim(false)
        v1_aimbot:SetNPCSilentAim(false)
        return
    end
    if AimPlayers then
        v1_aimbot:SetPlayerSilentAim(true)
        v1_aimbot:SetNPCSilentAim(false)
        return
    end
    if AimMobs then
        v1_aimbot:SetNPCSilentAim(not IgnoreMobs)
        v1_aimbot:SetPlayerSilentAim(false)
        return
    end
    v1_aimbot:SetPlayerSilentAim(false)
    v1_aimbot:SetNPCSilentAim(false)
end

CB:AddToggle({
    Name    = "Enable Aimbot",
    Default = false,
    Callback = function(v)
        AimbotEnabled = v
        if v1_aimbot then
            if not v then v1_aimbot:Pause()
            else v1_aimbot:Restore() end
        end
        UpdateAimbot()
    end
})

CB:AddToggle({
    Name    = "Aimbot on Players",
    Default = false,
    Callback = function(v)
        AimPlayers = v
        if v then AimMobs = false end
        UpdateAimbot()
    end
})

CB:AddToggle({
    Name    = "Aimbot on Mobs",
    Default = false,
    Callback = function(v)
        AimMobs = v
        if v then AimPlayers = false end
        UpdateAimbot()
    end
})

CB:AddToggle({
    Name    = "Ignore Mobs",
    Default = true,
    Callback = function(v)
        IgnoreMobs = v
        UpdateAimbot()
    end
})

-- ============================================================
-- [16] TAB: ESP
-- ============================================================
local ES = Tabs.ESP

ES:AddSection("Player ESP")

local ESP_SAVE       = "xtray_esp_players.txt"
local ESP_SIZE_SAVE  = "xtray_esp_size.txt"
local ESPPlayer      = isfile(ESP_SAVE) and readfile(ESP_SAVE)=="true" or false
local ESPSize        = tonumber(isfile(ESP_SIZE_SAVE) and readfile(ESP_SIZE_SAVE)) or 24
local ESPConnections = {}

local function RemovePlayerESP(player)
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then local e = hrp:FindFirstChild("XtrayESP"); if e then e:Destroy() end end
    end
    if ESPConnections[player] then ESPConnections[player]:Disconnect(); ESPConnections[player]=nil end
end

local function CreatePlayerESP(player)
    if player == LP then return end
    if not ESPPlayer then return end
    if not player.Character then return end
    local char = player.Character
    local hrp  = char:WaitForChild("HumanoidRootPart",3)
    local hum  = char:WaitForChild("Humanoid",3)
    if not hrp or not hum then return end
    RemovePlayerESP(player)
    local bg = Instance.new("BillboardGui")
    bg.Name       = "XtrayESP"
    bg.Adornee    = hrp
    bg.Size       = UDim2.new(0,220,0,44)
    bg.StudsOffset= Vector3.new(0,3,0)
    bg.AlwaysOnTop= true
    bg.MaxDistance= 999999
    bg.LightInfluence = 0
    bg.Parent     = hrp
    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size       = UDim2.new(1,0,0.5,0)
    nameLbl.RichText   = true
    nameLbl.TextColor3 = Color3.fromRGB(210,210,210)
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextSize   = ESPSize
    nameLbl.Font       = Enum.Font.SourceSans
    nameLbl.Parent     = bg
    local hpLbl = Instance.new("TextLabel")
    hpLbl.BackgroundTransparency = 1
    hpLbl.Size        = UDim2.new(1,0,0.5,0)
    hpLbl.Position    = UDim2.new(0,0,0.5,0)
    hpLbl.TextColor3  = Color3.fromRGB(0,255,0)
    hpLbl.TextStrokeTransparency = 0
    hpLbl.TextSize    = ESPSize
    hpLbl.Font        = Enum.Font.SourceSans
    hpLbl.Parent      = bg
    ESPConnections[player] = RunService.RenderStepped:Connect(function()
        if not ESPPlayer then RemovePlayerESP(player); return end
        if not player.Character or hum.Health <= 0 then RemovePlayerESP(player); return end
        local myChar = LP.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
        nameLbl.Text = "<font color='rgb(235,235,235)'>"..player.Name.."</font> ["..dist.."m]"
        hpLbl.Text   = "["..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth).."]"
    end)
end

local function SetupPlayerESP(player)
    if player == LP then return end
    player.CharacterAdded:Connect(function()
        if ESPPlayer then task.wait(0.2); CreatePlayerESP(player) end
    end)
    if player.Character then task.wait(0.2); CreatePlayerESP(player) end
end

for _, p in ipairs(Players:GetPlayers()) do SetupPlayerESP(p) end
Players.PlayerAdded:Connect(SetupPlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)

ES:AddSlider({
    Title   = "ESP Text Size",
    Min     = 10,
    Max     = 40,
    Default = ESPSize,
    Callback = function(v)
        ESPSize = v
        writefile(ESP_SIZE_SAVE, tostring(v))
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local esp = p.Character.HumanoidRootPart:FindFirstChild("XtrayESP")
                if esp then
                    for _, obj in pairs(esp:GetChildren()) do
                        if obj:IsA("TextLabel") then obj.TextSize = v end
                    end
                end
            end
        end
    end
})

ES:AddToggle({
    Title   = "ESP Players",
    Default = ESPPlayer,
    Callback = function(v)
        ESPPlayer = v
        writefile(ESP_SAVE, tostring(v))
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                if v then CreatePlayerESP(p)
                else RemovePlayerESP(p) end
            end
        end
    end
})

ES:AddSection("Object ESP")

ES:AddToggle({
    Title   = "ESP Chest",
    Value   = false,
    Callback = function(v)
        _G.ChestESP = v
        if not v then UpdateChestESP()
        else task.spawn(function() while _G.ChestESP do UpdateChestESP() task.wait(1) end end) end
    end
})

local FRUIT_ESP_SAVE = "xtray_esp_fruits.txt"
local DevilFruitESP = isfile(FRUIT_ESP_SAVE) and readfile(FRUIT_ESP_SAVE)=="true" or false

local function StartFruitESP()
    task.spawn(function()
        while DevilFruitESP do
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(1); continue end
            local rootPos = char.HumanoidRootPart.Position
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and string.find(obj.Name,"Fruit") and obj.Parent ~= char then
                    local base = obj:FindFirstChild("Handle") or obj.PrimaryPart
                    if base then
                        if not base:FindFirstChild("XtrayFruitESP") then
                            local bg = Instance.new("BillboardGui")
                            bg.Name="XtrayFruitESP"; bg.Adornee=base
                            bg.Size=UDim2.new(0,140,0,35); bg.StudsOffset=Vector3.new(0,1.5,0)
                            bg.AlwaysOnTop=true; bg.Parent=base
                            local lbl=Instance.new("TextLabel")
                            lbl.Name="Label"; lbl.Size=UDim2.new(1,0,1,0)
                            lbl.BackgroundTransparency=1; lbl.TextScaled=true
                            lbl.Font=Enum.Font.SourceSansBold
                            lbl.TextColor3=Color3.fromRGB(120,0,0)
                            lbl.TextStrokeTransparency=0; lbl.Parent=bg
                        end
                        local dist = math.floor((rootPos - base.Position).Magnitude)
                        base.XtrayFruitESP.Label.Text = "Fruit | < "..dist.." >"
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

local function StopFruitESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "XtrayFruitESP" then obj:Destroy() end
    end
end

ES:AddToggle({
    Title   = "ESP Fruits",
    Value   = DevilFruitESP,
    Callback = function(v)
        DevilFruitESP = v
        writefile(FRUIT_ESP_SAVE, tostring(v))
        if v then StartFruitESP() else StopFruitESP() end
    end
})

if DevilFruitESP then StartFruitESP() end

ES:AddToggle({
    Title   = "ESP Berry",
    Value   = false,
    Callback = function(v)
        Berry = v
        if not v then
            for _, b in pairs(CollectionService:GetTagged("BerryBush")) do
                if b.Parent:FindFirstChild("BerryESP") then b.Parent.BerryESP:Destroy() end
            end
        else
            UpdateBerriesESP()
        end
    end
})

ES:AddSection("Visual")

ES:AddButton({
    Title   = "Meteor Rain",
    Callback = function()
        pcall(function()
            local char = LP.Character
            if char and char.PrimaryPart then
                require(ReplicatedStorage.Effect.Container.UzothSpec)({Position = char.PrimaryPart.Position})
            end
        end)
    end
})

ES:AddButton({
    Title   = "Remove Portal Dash Cooldown",
    Callback = function()
        pcall(function()
            local portal = LP.Backpack:FindFirstChild("Portal-Portal") or (LP.Character and LP.Character:FindFirstChild("Portal-Portal"))
            if portal then
                local conns = getconnections(portal.Activated)
                for _, conn in ipairs(conns) do
                    local func = conn.Function
                    if func and #debug.getupvalues(func) == 9 then
                        task.spawn(function()
                            while portal and portal:IsDescendantOf(game) do
                                debug.setupvalue(func, 2, 0)
                                task.wait(0.1)
                            end
                        end)
                    end
                end
            end
        end)
    end
})

-- ============================================================
-- [17] TAB: FIGHT STYLE
-- ============================================================
local FS = Tabs.FightStyle

FS:AddSection("Buy Fighting Style")

local SEA = World1 and 1 or World2 and 2 or World3 and 3

local STYLE_NPCS = {
    BlackLeg      = {[1]={Vector3.new(-988,13,3996)},    [2]={Vector3.new(-4750.61,35.08,-4846.33)},  [3]={Vector3.new(-5043.64,371.35,-3183.40)}},
    Electro       = {[1]={Vector3.new(-5382.27,14.15,-2150.34)}, [2]={Vector3.new(-4863.81,35.08,-4767.54)}, [3]={Vector3.new(-4993.20,314.56,-3198.06)}},
    FishmanKarate = {[1]={Vector3.new(61584.35,18.85,988.89)},  [2]={Vector3.new(-4960.04,35.08,-4662.67)}, [3]={Vector3.new(-5017.39,371.35,-3187.53)}},
    Superhuman    = {[2]={Vector3.new(1378.05,247.43,-5189.37)}, [3]={Vector3.new(-4997.53,371.35,-3197.46)}},
    DeathStep     = {[2]={Vector3.new(6360.04,296.67,-6763.93)}, [3]={Vector3.new(-4997.64,314.56,-3220.37)}},
    SharkmanKarate= {[2]={Vector3.new(-2602.40,239.22,-10314.75)},[3]={Vector3.new(-4970.48,314.56,-3225.04)}},
    ElectricClaw  = {[3]={Vector3.new(-10369.83,331.69,-10126.49)}},
    DragonTalon   = {[3]={Vector3.new(5662.03,1211.32,858.60)}},
    GodHuman      = {[3]={Vector3.new(-13775.56,334.66,-9877.67)}},
    SanguineArt   = {[3]={Vector3.new(-16514.86,23.18,-190.84)}},
}

_G.BuyFly    = false
local BV_LV  = nil
local BV_AO  = nil
local BV_Tgt = nil

local function HRP_FS()
    return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
end

local function EnsureStyleFly()
    local hrp = HRP_FS(); if not hrp then return end
    if not BV_LV or BV_LV.Parent ~= hrp then
        if BV_LV then BV_LV:Destroy() end
        BV_LV = Instance.new("LinearVelocity")
        BV_LV.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment",hrp)
        BV_LV.MaxForce = math.huge
        BV_LV.VectorVelocity = Vector3.zero
        BV_LV.Parent = hrp
    end
    if not BV_AO or BV_AO.Parent ~= hrp then
        if BV_AO then BV_AO:Destroy() end
        BV_AO = Instance.new("AlignOrientation")
        BV_AO.Attachment0 = hrp:FindFirstChildOfClass("Attachment")
        BV_AO.MaxTorque = math.huge
        BV_AO.Responsiveness = 200
        BV_AO.Parent = hrp
    end
end

local function StopStyleFly()
    RunService:UnbindFromRenderStep("XtrayBuyFly")
    if BV_LV then BV_LV:Destroy(); BV_LV=nil end
    if BV_AO then BV_AO:Destroy(); BV_AO=nil end
    BV_Tgt = nil
end

local function FlyToStyle(pos)
    BV_Tgt = pos
    RunService:BindToRenderStep("XtrayBuyFly", Enum.RenderPriority.Character.Value+1, function()
        if not _G.BuyFly then StopStyleFly(); return end
        local hrp = HRP_FS(); if not hrp then return end
        EnsureStyleFly()
        for _, v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
        local delta = BV_Tgt - hrp.Position
        local dist  = delta.Magnitude
        if dist <= 3 then
            BV_LV.VectorVelocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(BV_Tgt)
            return
        end
        local dir = delta.Unit
        BV_LV.VectorVelocity = dir * math.clamp(dist*6, 120, 330)
        BV_AO.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir)
    end)
end

local function BuyStyle(style, remote)
    task.spawn(function()
        local pos = STYLE_NPCS[style] and STYLE_NPCS[style][SEA]
        if not pos then return end
        _G.BuyFly = true
        FlyToStyle(pos[1])
        repeat task.wait() until (HRP_FS() and (HRP_FS().Position - pos[1]).Magnitude <= 4) or not _G.BuyFly
        if _G.BuyFly then
            ReplicatedStorage.Remotes.CommF_:InvokeServer(remote)
        end
        _G.BuyFly = false
        StopStyleFly()
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(0.4)
    if _G.BuyFly and BV_Tgt then FlyToStyle(BV_Tgt) end
end)

local StyleButtons = {
    {label="Buy Black Leg",       style="BlackLeg",       remote="BuyBlackLeg"},
    {label="Buy Electro",         style="Electro",        remote="BuyElectro"},
    {label="Buy Fishman Karate",  style="FishmanKarate",  remote="BuyFishmanKarate"},
    {label="Buy Superhuman",      style="Superhuman",     remote="BuySuperhuman"},
    {label="Buy Death Step",      style="DeathStep",      remote="BuyDeathStep"},
    {label="Buy Sharkman Karate", style="SharkmanKarate", remote="BuySharkmanKarate"},
    {label="Buy Electric Claw",   style="ElectricClaw",   remote="BuyElectricClaw"},
    {label="Buy Dragon Talon",    style="DragonTalon",    remote="BuyDragonTalon"},
    {label="Buy God Human",       style="GodHuman",       remote="BuyGodHuman"},
    {label="Buy Sanguine Art",    style="SanguineArt",    remote="BuySanguineArt"},
}

for _, btn in ipairs(StyleButtons) do
    if STYLE_NPCS[btn.style] and STYLE_NPCS[btn.style][SEA] then
        FS:AddButton({
            Title    = btn.label,
            Callback = function()
                BuyStyle(btn.style, btn.remote)
            end
        })
    end
end

FS:AddSection("Shop Items")

FS:AddButton({Title="Buy Swordsman Hat ($150,000)",   Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem","Swordsman Hat") end) end})
FS:AddButton({Title="Buy Tomoe Ring ($500,000)",      Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem","Tomoe Ring") end) end})

FS:AddSection("Race & Stats")

FS:AddButton({Title="Buy Ghoul",       Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm","Change",4) end) end})
FS:AddButton({Title="Buy Cyborg",      Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CyborgTrainer","Buy") end) end})
FS:AddButton({Title="Reset Stats (2,500F)", Callback=function()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","Refund","1")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","Refund","2")
    end)
end})
FS:AddButton({Title="Random Race (3,000F)", Callback=function()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","Reroll","1")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","Reroll","2")
    end)
end})

-- ============================================================
-- [18] TAB: MISC (Settings)
-- ============================================================
local MS = Tabs.Misc

MS:AddSection("Fast Attack")

_G.AutoAttack = true
MS:AddToggle({
    Name    = "Fast Attack",
    Default = true,
    Callback = function(v)
        _G.AutoAttack = v
    end
})

local fa_v1  = next
local fa_v2  = {ReplicatedStorage.Util, ReplicatedStorage.Common, ReplicatedStorage.Remotes, ReplicatedStorage.Assets}
local fa_v3  = nil
local fa_u4  = nil
local fa_u5  = nil

pcall(function()
    while true do
        local v6
        fa_v3, v6 = fa_v1(fa_v2, fa_v3)
        if fa_v3 == nil then break end
        for _, child in pairs(v6:GetChildren()) do
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                fa_u5 = child:GetAttribute("Id")
                fa_u4 = child
            end
        end
        v6.ChildAdded:Connect(function(p)
            if p:IsA("RemoteEvent") and p:GetAttribute("Id") then
                fa_u5 = p:GetAttribute("Id")
                fa_u4 = p
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.0001) do
        pcall(function()
            if not _G.AutoAttack then return end
            local char = LP.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hits  = {}
            for _, container in ipairs({workspace.Enemies, workspace.Characters}) do
                for _, mob in ipairs(container:GetChildren()) do
                    local mhrp = mob:FindFirstChild("HumanoidRootPart")
                    local mhum = mob:FindFirstChild("Humanoid")
                    if mob ~= char and mhrp and mhum and mhum.Health > 0
                    and (mhrp.Position - hrp.Position).Magnitude <= 60 then
                        for _, part in ipairs(mob:GetChildren()) do
                            if part:IsA("BasePart") and (mhrp.Position - hrp.Position).Magnitude <= 60 then
                                table.insert(hits, {mob, part})
                            end
                        end
                    end
                end
            end
            local tool = char:FindFirstChildOfClass("Tool")
            if #hits > 0 and tool and (tool:GetAttribute("WeaponType")=="Melee" or tool:GetAttribute("WeaponType")=="Sword") then
                pcall(function()
                    require(ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit", true)
                    ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
                    local head = hits[1][1]:FindFirstChild("Head")
                    if head then
                        ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(head, hits, {}, tostring(LP.UserId):sub(2,4)..tostring(coroutine.running()):sub(11,15))
                        if fa_u4 and fa_u5 then
                            cloneref(fa_u4):FireServer(string.gsub("RE/RegisterHit",".",function(c)
                                return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow()/10 % 10)+1))
                            end), bit32.bxor(fa_u5+909090, ReplicatedStorage.Modules.Net.seed:InvokeServer()*2), head, hits)
                        end
                    end
                end)
            end
        end)
    end
end)

MS:AddSection("Bring Mob")

MS:AddToggle({
    Name    = "Bring Mob",
    Default = false,
    Callback = function(v)
        _G.BringMonster = v
        StartBring = v
        StopTween(v)
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            CheckQuest()
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if _G.BringMonster and (StartBring and mob.Name == _G.MonFarm or mob.Name == _G.Mon)
                and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart")
                and mob.Humanoid.Health > 0
                and (mob.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude <= 320 then
                    if mob.Name == "Factory Staff" then
                        if (mob.HumanoidRootPart.Position - PosMon.Position).Magnitude <= 250 then
                            mob.Head.CanCollide = false
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(60,60,60)
                            mob.HumanoidRootPart.CFrame = PosMon
                            if mob.Humanoid:FindFirstChild("Animator") then mob.Humanoid.Animator:Destroy() end
                            sethiddenproperty(LP,"SimulationRadius",math.huge)
                        end
                    elseif (mob.HumanoidRootPart.Position - PosMon.Position).Magnitude <= 320 then
                        mob.HumanoidRootPart.Size = Vector3.new(60,60,60)
                        mob.HumanoidRootPart.CFrame = PosMon
                        mob.HumanoidRootPart.CanCollide = false
                        mob.Head.CanCollide = false
                        if mob.Humanoid:FindFirstChild("Animator") then mob.Humanoid.Animator:Destroy() end
                        sethiddenproperty(LP,"SimulationRadius",math.huge)
                    end
                end
            end
        end)
    end
end)

MS:AddSection("Server")

MS:AddButton({
    Title   = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(PlaceId, LP)
    end
})

MS:AddButton({
    Title   = "Server Hop",
    Callback = function() Hop() end
})

MS:AddToggle({
    Name        = "Anti-Reset (Hop every 30 min)",
    Description = "Auto server hop every 30 minutes",
    Default     = false,
    Callback    = function(v)
        _G.AutoRejoin30m = v
        if v then
            task.spawn(function()
                while _G.AutoRejoin30m do
                    task.wait(1800)
                    if not _G.AutoRejoin30m then break end
                    Hop()
                end
            end)
        end
    end
})

MS:AddSection("Join Server")

MS:AddTextBox({
    Name            = "Job ID",
    PlaceholderText = "Paste Job ID here...",
    Callback        = function(v)
        if v ~= "" then
            TeleportService:TeleportToPlaceInstance(PlaceId, v)
        end
    end
})

MS:AddButton({
    Title   = "Join From Clipboard",
    Callback = function()
        pcall(function()
            local id = tostring(getclipboard())
            if id and id ~= "" then
                TeleportService:TeleportToPlaceInstance(PlaceId, id, LP)
            end
        end)
    end
})

MS:AddSection("Team")

MS:AddButton({Title="Join Pirates",  Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam","Pirates") end) end})
MS:AddButton({Title="Join Marines",  Callback=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam","Marines") end) end})

MS:AddSection("Race")

MS:AddToggle({
    Title   = "Auto Active Race V3",
    Value   = false,
    Callback = function(v)
        _G.AutoRaceV3 = v
    end
})

spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoRaceV3 then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end
        end)
    end
end)

local RACE_V4_SAVE = "xtray_racev4.txt"
_G.AutoRaceV4 = isfile(RACE_V4_SAVE) and readfile(RACE_V4_SAVE)=="true" or false

MS:AddToggle({
    Title   = "Auto Active Race V4",
    Value   = _G.AutoRaceV4,
    Callback = function(v)
        _G.AutoRaceV4 = v
        writefile(RACE_V4_SAVE, tostring(v))
    end
})

spawn(function()
    while task.wait(0.5) do
        if _G.AutoRaceV4 then
            pcall(function()
                local char = LP.Character; if not char then return end
                local energy      = char:FindFirstChild("RaceEnergy")
                local transformed = char:FindFirstChild("RaceTransformed")
                if energy and transformed and energy.Value >= 1 and not transformed.Value then
                    VIM:SendKeyEvent(true,Enum.KeyCode.Y,false,game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false,Enum.KeyCode.Y,false,game)
                    task.wait(5)
                end
            end)
        end
    end
end)

MS:AddSection("Local Player")

local SPEED_SAVE  = "xtray_walkspeed.txt"
local JUMP_SAVE   = "xtray_jump.txt"
local MOV_SAVE    = "xtray_movement.txt"

local MovEnabled  = isfile(MOV_SAVE)   and readfile(MOV_SAVE)=="true"  or false
local WalkSpeedV  = tonumber(isfile(SPEED_SAVE) and readfile(SPEED_SAVE)) or 58
local JumpV       = tonumber(isfile(JUMP_SAVE)  and readfile(JUMP_SAVE))  or 58

local function ApplyMovement(char)
    local hum = char:WaitForChild("Humanoid",5); if not hum then return end
    if MovEnabled then hum.WalkSpeed=WalkSpeedV; hum.JumpPower=JumpV end
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if MovEnabled then hum.WalkSpeed=WalkSpeedV end end)
    hum:GetPropertyChangedSignal("JumpPower"):Connect(function() if MovEnabled then hum.JumpPower=JumpV end end)
end

LP.CharacterAdded:Connect(function(c) task.wait(0.2); ApplyMovement(c) end)
if LP.Character then ApplyMovement(LP.Character) end

MS:AddToggle({
    Title   = "Enable WalkSpeed & Jump",
    Default = MovEnabled,
    Callback = function(v)
        MovEnabled = v
        writefile(MOV_SAVE, tostring(v))
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then
            if v then hum.WalkSpeed=WalkSpeedV; hum.JumpPower=JumpV
            else hum.WalkSpeed=16; hum.JumpPower=50 end
        end
    end
})

MS:AddSlider({
    Title   = "Walk Speed",
    Min     = 16,
    Max     = 300,
    Default = WalkSpeedV,
    Callback = function(v)
        WalkSpeedV = v
        writefile(SPEED_SAVE, tostring(v))
        if MovEnabled then
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed=v end
        end
    end
})

MS:AddSlider({
    Title   = "Jump Power",
    Min     = 50,
    Max     = 500,
    Default = JumpV,
    Callback = function(v)
        JumpV = v
        writefile(JUMP_SAVE, tostring(v))
        if MovEnabled then
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if hum then hum.JumpPower=v end
        end
    end
})

MS:AddSection("Visual")

local FB_SAVE = "xtray_fullbright.txt"
local FullBrightEnabled = isfile(FB_SAVE) and readfile(FB_SAVE)=="true" or false

local OrigLighting = {
    Ambient          = Lighting.Ambient,
    ColorShift_Bottom= Lighting.ColorShift_Bottom,
    ColorShift_Top   = Lighting.ColorShift_Top,
    Brightness       = Lighting.Brightness,
    GlobalShadows    = Lighting.GlobalShadows,
}

local function ApplyFullBright(state)
    if state then
        Lighting.Ambient           = Color3.new(1,1,1)
        Lighting.ColorShift_Bottom = Color3.new(1,1,1)
        Lighting.ColorShift_Top    = Color3.new(1,1,1)
        Lighting.Brightness        = 3
        Lighting.GlobalShadows     = false
    else
        Lighting.Ambient           = OrigLighting.Ambient
        Lighting.ColorShift_Bottom = OrigLighting.ColorShift_Bottom
        Lighting.ColorShift_Top    = OrigLighting.ColorShift_Top
        Lighting.Brightness        = OrigLighting.Brightness
        Lighting.GlobalShadows     = OrigLighting.GlobalShadows
    end
end

ApplyFullBright(FullBrightEnabled)

MS:AddToggle({
    Title   = "Full Bright",
    Value   = FullBrightEnabled,
    Callback = function(v)
        FullBrightEnabled = v
        writefile(FB_SAVE, tostring(v))
        ApplyFullBright(v)
    end
})

MS:AddButton({
    Title   = "Remove Sky Fog",
    Callback = function()
        if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
        if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
        if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
    end
})

MS:AddButton({
    Title   = "FPS Boost",
    Callback = function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic; v.Reflectance=0
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false
            elseif v:IsA("Lighting") then v.GlobalShadows=false; v.FogEnd=1e10; v.Brightness=0 end
        end
        pcall(function() setfpscap(60) end)
    end
})

MS:AddButton({
    Title   = "White Screen Toggle",
    Callback = function()
        _G.WhiteScreen = not _G.WhiteScreen
        RunService:Set3dRenderingEnabled(not _G.WhiteScreen)
    end
})

MS:AddSection("Others")

MS:AddToggle({
    Name    = "Delete Lava",
    Default = false,
    Callback = function(v)
        _G.RemoveLava = v
    end
})

spawn(function()
    while task.wait(1) do
        if _G.RemoveLava then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.lower(obj.Name):find("lava") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end)

MS:AddToggle({
    Name    = "Dodge No CD",
    Default = false,
    Callback = function(v) DodgewithoutCool = v end
})

spawn(function()
    while task.wait() do
        if DodgewithoutCool then
            pcall(function()
                for _, fn in next, getgc() do
                    if typeof(fn)=="function" and getfenv(fn).script==LP.Character:WaitForChild("Dodge") then
                        for i, val in next, getupvalues(fn) do
                            if tostring(val)=="0.4" then setupvalue(fn,i,0) end
                        end
                    end
                end
            end)
        end
    end
end)

MS:AddToggle({
    Title   = "Infinite Geppo",
    Value   = false,
    Callback = function(v) InfiniteGeppo = v end
})

spawn(function()
    while task.wait(1) do
        if InfiniteGeppo then
            pcall(function()
                for _, fn in next, getgc() do
                    if getfenv(fn).script==LP.Character:WaitForChild("Geppo") then
                        for i, val in next, getupvalues(fn) do
                            if tostring(val)=="0" then
                                repeat task.wait(0.1); setupvalue(fn,i,0)
                                until not InfiniteGeppo or LP.Character.Humanoid.Health<=0
                            end
                        end
                    end
                end
            end)
        end
    end
end)

MS:AddToggle({
    Title   = "Walk on Water",
    Default = true,
    Callback = function(v) _G.WalkWater=v end
})

_G.WalkWater = true

spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.WalkWater then
                workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000,80,1000)
            else
                workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000,112,1000)
            end
        end)
    end
end)

MS:AddSection("Redeem Codes")

local Codes = {
    "NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
    "FIGHT4FRUIT","NOEXPLOITER","NOOB2ADMIN","CODESLIDE","ADMINHACKED","ADMINDARES",
    "fruitconcepts","krazydares","TRIPLEABUSE","SEATROLLING","24NOADMIN","REWARDFUN",
    "Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999",
    "Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2",
    "SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock",
    "Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews",
    "TheGreatAce","SECRET_ADMIN","SUB2GAMERROBOT_RESET1","SUB2OFFICIALNOOBIE",
    "AXIORE","BIGNEWS","BLUXXY","CHANDLER","ENYU_IS_PRO","FUDD10","FUDD10_V2",
    "KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","SUB2CAPTAINMAUI",
    "SUB2DAIGROCK","SUB2FER999","SUB2NOOBMASTER123","SUB2UNCLEKIZARU","TANTAIGAMING","THEGREATACE"
}

MS:AddButton({
    Title   = "Redeem All Codes",
    Callback = function()
        task.spawn(function()
            for _, code in ipairs(Codes) do
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(code)
                end)
                task.wait(0.1)
            end
        end)
    end
})

MS:AddSection("Menu")

MS:AddButton({
    Title   = "Open Title Menu",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("getTitles")
            LP.PlayerGui.Main.Titles.Visible = true
        end)
    end
})

-- ============================================================
-- [19] ADMIN DETECTION (auto hop if game admin found)
-- ============================================================
local GameAdmins = {
    red_game43=true, rip_indra=true, Axiore=true, Polkster=true,
    wenlocktoad=true, Daigrock=true, toilamvidamme=true,
    oofficialnoobie=true, Uzoth=true, Azarth=true, arlthmetic=true,
    Death_King=true, Lunoven=true, TheGreateAced=true, rip_fud=true,
    drip_mama=true, layandikit12=true, Hingoi=true,
}

task.spawn(function()
    while task.wait(1) do
        for _, player in pairs(Players:GetPlayers()) do
            if GameAdmins[player.Name] then
                Hop()
                break
            end
        end
    end
end)

-- ============================================================
-- [20] RETURN
-- ============================================================
return redzlib
