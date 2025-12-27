-- Wooden Box Auto Farmer
-- Using Rayfield UI Library (like universal scripts)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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
    Notifications = true,
    FullBright = false,
    NoFog = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false
}

local Lighting = game:GetService("Lighting")
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

-- Загрузка Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание окна
local Window = Rayfield:CreateWindow({
    Name = "🪵 Wooden Box Farmer",
    LoadingTitle = "Wooden Box Farmer",
    LoadingSubtitle = "by Script Developer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WoodenBoxFarmer",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- Вкладка "Главная"
local HomeTab = Window:CreateTab("🏠 Главная", 4483362458)

local HomeSection = HomeTab:CreateSection("Добро пожаловать!")

HomeTab:CreateParagraph({
    Title = "📌 Инструкция",
    Content = "1. Перейди в 'Телепорт' и установи базу\n2. Настрой параметры во вкладке 'Фарм'\n3. Включи автофарм и наслаждайся!"
})

HomeTab:CreateButton({
    Name = "🚀 Быстрый старт",
    Callback = function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Config.BasePosition = Character.HumanoidRootPart.Position
            Config.Enabled = true
            spawn(FarmLoop)
            Rayfield:Notify({
                Title = "Быстрый старт",
                Content = "Автофарм запущен!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Вкладка "Фарм"
local FarmTab = Window:CreateTab("⚙️ Фарм", 4483362458)

local FarmSection = FarmTab:CreateSection("Настройки автофарма")

local FarmToggle = FarmTab:CreateToggle({
    Name = "🟢 Включить автофарм",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(Value)
        Config.Enabled = Value
        if Value then
            spawn(FarmLoop)
            Rayfield:Notify({
                Title = "Автофарм",
                Content = "Запущен",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Автофарм",
                Content = "Остановлен",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

local AutoReturnToggle = FarmTab:CreateToggle({
    Name = "🏠 Авто возврат на базу",
    CurrentValue = true,
    Flag = "AutoReturnToggle",
    Callback = function(Value)
        Config.AutoReturnToBase = Value
    end
})

local NotificationsToggle = FarmTab:CreateToggle({
    Name = "🔔 Уведомления",
    CurrentValue = true,
    Flag = "NotificationsToggle",
    Callback = function(Value)
        Config.Notifications = Value
    end
})

local SpeedSlider = FarmTab:CreateSlider({
    Name = "⏱️ Скорость сбора (сек)",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Config.FarmSpeed = Value
    end
})

-- Вкладка "Телепорт"
local TeleportTab = Window:CreateTab("📍 Телепорт", 4483362458)

local TeleportSection = TeleportTab:CreateSection("Управление базой")

TeleportTab:CreateButton({
    Name = "📍 Установить базу (текущая позиция)",
    Callback = function()
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            Config.BasePosition = Character.HumanoidRootPart.Position
            Rayfield:Notify({
                Title = "База",
                Content = "Установлена на текущей позиции",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

TeleportTab:CreateButton({
    Name = "🏠 Телепорт на базу",
    Callback = function()
        TeleportTo(Config.BasePosition)
        Rayfield:Notify({
            Title = "Телепорт",
            Content = "Перемещение на базу",
            Duration = 2,
            Image = 4483362458
        })
    end
})

local QuickTeleportSection = TeleportTab:CreateSection("Быстрые телепорты")

TeleportTab:CreateButton({
    Name = "🌲 Телепорт к ближайшему боксу",
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
            Rayfield:Notify({
                Title = "Телепорт",
                Content = "К ближайшему боксу",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Боксы не найдены",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Вкладка "Визуал"
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)

local VisualSection = VisualTab:CreateSection("Настройки визуала")

VisualTab:CreateToggle({
    Name = "💡 Full Bright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
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

VisualTab:CreateToggle({
    Name = "🌫️ No Fog",
    CurrentValue = false,
    Flag = "NoFogToggle",
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

-- Вкладка "Игрок"
local PlayerTab = Window:CreateTab("🏃 Игрок", 4483362458)

local PlayerSection = PlayerTab:CreateSection("Настройки персонажа")

PlayerTab:CreateSlider({
    Name = "🏃 Скорость ходьбы",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "🦘 Сила прыжка",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        Config.JumpPower = Value
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "♾️ Бесконечный прыжок",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        Config.InfiniteJump = Value
    end
})

PlayerTab:CreateButton({
    Name = "🔄 Сбросить настройки персонажа",
    Callback = function()
        Config.WalkSpeed = 16
        Config.JumpPower = 50
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = 16
            Character.Humanoid.JumpPower = 50
        end
        Rayfield:Notify({
            Title = "Персонаж",
            Content = "Настройки сброшены",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Вкладка "Статистика"
local StatsTab = Window:CreateTab("📊 Статистика", 4483362458)

local StatsSection = StatsTab:CreateSection("Текущая статистика")

local CollectedLabel = StatsTab:CreateLabel("📦 Собрано боксов: 0")
local StatusLabel = StatsTab:CreateLabel("📊 Статус: Ожидание")
local BaseLabel = StatsTab:CreateLabel("📍 База: Не установлена")
local BoxesLabel = StatsTab:CreateLabel("🌲 Боксов в мире: 0")

StatsTab:CreateButton({
    Name = "🔄 Сбросить статистику",
    Callback = function()
        Config.BoxesCollected = 0
        Rayfield:Notify({
            Title = "Статистика",
            Content = "Сброшена",
            Duration = 2,
            Image = 4483362458
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
        
        CollectedLabel:Set("📦 Собрано боксов: " .. Config.BoxesCollected)
        StatusLabel:Set("📊 Статус: " .. (Config.Enabled and "🟢 Активен" or "🔴 Остановлен"))
        BaseLabel:Set(string.format("📍 База: %.0f, %.0f, %.0f", 
            Config.BasePosition.X, Config.BasePosition.Y, Config.BasePosition.Z))
        BoxesLabel:Set("🌲 Боксов в мире: " .. #boxes)
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
    FarmToggle:Set(false)
    
    -- Применяем настройки к новому персонажу
    wait(1)
    if Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = Config.WalkSpeed
        Character.Humanoid.JumpPower = Config.JumpPower
    end
end)

-- Уведомление о загрузке
Rayfield:Notify({
    Title = "Wooden Box Farmer",
    Content = "Успешно загружен!",
    Duration = 5,
    Image = 4483362458
})

print("=================================")
print("  Wooden Box Farmer v2.0")
print("  Rayfield UI Edition")
print("=================================")
print("✅ UI загружен")
print("📌 Установите базу перед началом")
print("=================================")
