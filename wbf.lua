-- Wooden Box Auto Farmer
-- Using Fluent UI Library

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Конфигурация
local Config = {
    Enabled = false,
    FarmSpeed = 0.5,
    BasePosition = Vector3.new(0, 50, 0),
    AutoReturnToBase = true,
    BoxesCollected = 0,
    FullBright = false,
    NoFog = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false
}

local OriginalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

-- Загрузка Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Создание окна
local Window = Fluent:CreateWindow({
    Title = "Wooden Box Farmer",
    SubTitle = "by DinoChert",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создание вкладок
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "box" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" })
}

-- Вкладка Main
Tabs.Main:AddParagraph({
    Title = "Welcome!",
    Content = "Wooden Box Farmer - автоматический сбор боксов с телепортацией на базу."
})

Tabs.Main:AddButton({
    Title = "Quick Start",
    Description = "Установить базу и запустить фарм",
    Callback = function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Config.BasePosition = Character.HumanoidRootPart.Position
            Config.Enabled = true
            spawn(FarmLoop)
            Fluent:Notify({
                Title = "Quick Start",
                Content = "Автофарм запущен!",
                Duration = 3
            })
        end
    end
})

-- Вкладка Farm
local FarmToggle = Tabs.Farm:AddToggle("FarmToggle", {
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(Value)
        Config.Enabled = Value
        if Value then
            spawn(FarmLoop)
            Fluent:Notify({
                Title = "Auto Farm",
                Content = "Запущен",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Auto Farm",
                Content = "Остановлен",
                Duration = 2
            })
        end
    end
})

Tabs.Farm:AddToggle("AutoReturn", {
    Title = "Auto Return to Base",
    Default = true,
    Callback = function(Value)
        Config.AutoReturnToBase = Value
    end
})

Tabs.Farm:AddSlider("FarmSpeed", {
    Title = "Farm Speed",
    Description = "Задержка между сбором (секунды)",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Callback = function(Value)
        Config.FarmSpeed = Value
    end
})

-- Вкладка Teleport
Tabs.Teleport:AddButton({
    Title = "Set Base (Current Position)",
    Description = "Установить текущую позицию как базу",
    Callback = function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Config.BasePosition = Character.HumanoidRootPart.Position
            Fluent:Notify({
                Title = "Base",
                Content = "Установлена на текущей позиции",
                Duration = 3
            })
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Base",
    Description = "Телепортироваться на базу",
    Callback = function()
        TeleportTo(Config.BasePosition)
        Fluent:Notify({
            Title = "Teleport",
            Content = "Перемещение на базу",
            Duration = 2
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Nearest Box",
    Description = "Телепорт к ближайшему боксу",
    Callback = function()
        local boxes = FindWoodenBoxes()
        if #boxes > 0 then
            local closest = boxes[1]
            local minDist = math.huge
            
            for _, box in pairs(boxes) do
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (box.Position - Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = box
                    end
                end
            end
            
            TeleportTo(closest.Position + Vector3.new(0, 3, 0))
            Fluent:Notify({
                Title = "Teleport",
                Content = "К ближайшему боксу",
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Боксы не найдены",
                Duration = 3
            })
        end
    end
})

-- Вкладка Player
Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Скорость ходьбы",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Сила прыжка",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        Config.JumpPower = Value
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = Value
        end
    end
})

Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        Config.InfiniteJump = Value
    end
})

Tabs.Player:AddButton({
    Title = "Reset Player Settings",
    Description = "Сбросить настройки персонажа",
    Callback = function()
        Config.WalkSpeed = 16
        Config.JumpPower = 50
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = 16
            Character.Humanoid.JumpPower = 50
        end
        Fluent:Notify({
            Title = "Player",
            Content = "Настройки сброшены",
            Duration = 2
        })
    end
})

-- Вкладка Visuals
Tabs.Visuals:AddToggle("FullBright", {
    Title = "Full Bright",
    Default = false,
    Callback = function(Value)
        Config.FullBright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end
    end
})

Tabs.Visuals:AddToggle("NoFog", {
    Title = "No Fog",
    Default = false,
    Callback = function(Value)
        Config.NoFog = Value
        if Value then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = OriginalLighting.FogEnd
            Lighting.FogStart = OriginalLighting.FogStart
        end
    end
})

-- Вкладка Stats
local CollectedLabel = Tabs.Stats:AddParagraph({
    Title = "Boxes Collected",
    Content = "0"
})

local StatusLabel = Tabs.Stats:AddParagraph({
    Title = "Status",
    Content = "Waiting"
})

local BaseLabel = Tabs.Stats:AddParagraph({
    Title = "Base Position",
    Content = "Not set"
})

local BoxesLabel = Tabs.Stats:AddParagraph({
    Title = "Boxes in World",
    Content = "0"
})

Tabs.Stats:AddButton({
    Title = "Reset Statistics",
    Description = "Сбросить статистику",
    Callback = function()
        Config.BoxesCollected = 0
        Fluent:Notify({
            Title = "Stats",
            Content = "Сброшена",
            Duration = 2
        })
    end
})

-- Функции
function TeleportTo(position)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

function FindWoodenBoxes()
    local boxes = {}
    local items = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Items")
    
    if items then
        for _, item in pairs(items:GetChildren()) do
            if item.Name == "Wooden Box" and item:IsA("BasePart") then
                table.insert(boxes, item)
            end
        end
    end
    
    return boxes
end

function CollectBox(box)
    if not box or not box.Parent then return false end
    
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local boxPosition = box.Position
    TeleportTo(boxPosition + Vector3.new(0, 3, 0))
    
    wait(0.2)
    
    local prompt = box:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        Config.BoxesCollected = Config.BoxesCollected + 1
        return true
    end
    
    if box:FindFirstChild("TouchInterest") then
        firetouchinterest(character.HumanoidRootPart, box, 0)
        wait(0.1)
        firetouchinterest(character.HumanoidRootPart, box, 1)
        Config.BoxesCollected = Config.BoxesCollected + 1
        return true
    end
    
    return false
end

-- Основной цикл фарма
function FarmLoop()
    while Config.Enabled do
        local boxes = FindWoodenBoxes()
        
        if #boxes > 0 then
            for _, box in pairs(boxes) do
                if not Config.Enabled then break end
                
                CollectBox(box)
                wait(Config.FarmSpeed)
            end
            
            if Config.AutoReturnToBase and Config.Enabled then
                wait(0.5)
                TeleportTo(Config.BasePosition)
                wait(1)
            end
        else
            wait(2)
        end
        
        wait(1)
    end
end

-- Обновление статистики
spawn(function()
    while wait(1) do
        local boxes = FindWoodenBoxes()
        
        CollectedLabel:SetDesc(tostring(Config.BoxesCollected))
        StatusLabel:SetDesc(Config.Enabled and "Active" or "Stopped")
        BaseLabel:SetDesc(string.format("%.0f, %.0f, %.0f", 
            Config.BasePosition.X, Config.BasePosition.Y, Config.BasePosition.Z))
        BoxesLabel:SetDesc(tostring(#boxes))
    end
end)

-- Бесконечный прыжок
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Config.InfiniteJump and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Обновление персонажа при респавне
Player.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Config.Enabled = false
    FarmToggle:SetValue(false)
    
    wait(1)
    if Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Config.WalkSpeed
        Character.Humanoid.JumpPower = Config.JumpPower
    end
end)

-- Уведомление о загрузке
Fluent:Notify({
    Title = "Wooden Box Farmer",
    Content = "Успешно загружен!",
    Duration = 5
})

print("=================================")
print("  Wooden Box Farmer v2.0")
print("  Fluent UI Edition")
print("=================================")
print("✅ UI загружен")
print("📌 Установите базу перед началом")
print("=================================")
