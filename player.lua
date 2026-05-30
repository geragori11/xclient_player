--[[
    XClientMenuV2 - Advanced Player Module
    Разработчик: geragori11
    Функции: WalkSpeed, JumpPower, SpinBot, Noclip, InfJump, FOV Changer
--]]

return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Глобальные переменные модуля
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    local SpinRenderConnection = nil

    -- Создаем вкладку Player
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- ==========================================
    -- СЕКЦИЯ: ХАРАКТЕРИСТИКИ
    -- ==========================================
    PlayerTab:CreateSection("Характеристики персонажа")

    PlayerTab:CreateSlider({
        Name = "⚡ Скорость бега (WalkSpeed)",
        Range = {16, 300},
        Increment = 1,
        Suffix = " Попугаев",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.WalkSpeed = Value end
        end
    })

    PlayerTab:CreateSlider({
        Name = "🦘 Высота прыжка (JumpPower)",
        Range = {50, 300},
        Increment = 1,
        Suffix = " Сила",
        CurrentValue = 50,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then 
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = Value 
            end
        end
    })

    -- ==========================================
    -- СЕКЦИЯ: ОБХОД СТЕН И ПЕРЕМЕЩЕНИЕ
    -- ==========================================
    PlayerTab:CreateSection("Перемещение и Обход стен")

    -- ТОТ САМЫЙ НОУКЛИП
    PlayerTab:CreateToggle({
        Name = "🧱 Прохождение сквозь стены (Noclip)",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            NoclipEnabled = Value
            -- Если отключили ноуклип, возвращаем коллизию обратно, чтобы не упасть в бездну
            if not Value then
                local Character = LocalPlayer.Character
                if Character then
                    for _, Part in ipairs(Character:GetDescendants()) do
                        if Part:IsA("BasePart") then
                            Part.CanCollide = true
                        end
                    end
                end
            end
        end
    })

    PlayerTab:CreateToggle({
        Name = "🌌 Бесконечный прыжок (Inf Jump)",
        CurrentValue = false,
        Flag = "InfJumpToggle",
        Callback = function(Value)
            InfJumpEnabled = Value
        end
    })

    -- ==========================================
    -- СЕКЦИЯ: ОКРУЖЕНИЕ И ФАН
    -- ==========================================
    PlayerTab:CreateSection("Визуал и Фан утилиты")

    PlayerTab:CreateSlider({
        Name = "👁️ Поле зрения (Camera FOV)",
        Range = {70, 120},
        Increment = 1,
        Suffix = " Градусов",
        CurrentValue = 70,
        Flag = "FOVSlider",
        Callback = function(Value)
            Camera.FieldOfView = Value
        end
    })

    PlayerTab:CreateToggle({
        Name = "🌀 Включить Спинбот (SpinBot)",
        CurrentValue = false,
        Flag = "SpinBotToggle",
        Callback = function(Value)
            if Value then
                if SpinRenderConnection then SpinRenderConnection:Disconnect() end
                SpinRenderConnection = RunService.Heartbeat:Connect(function()
                    local Character = LocalPlayer.Character
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    if RootPart then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                end)
            else
                if SpinRenderConnection then
                    SpinRenderConnection:Disconnect()
                    SpinRenderConnection = nil
                end
            end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Скорость вращения спинбота",
        Range = {10, 300},
        Increment = 5,
        Suffix = " Скорость",
        CurrentValue = 50,
        Flag = "SpinSpeedSlider",
        Callback = function(Value) SpinSpeed = Value end
    })

    -- ==========================================
    -- СЕРВИСНЫЕ ЦИКЛЫ (ОБРАБОТКА КАЖДЫЙ КАДР)
    -- ==========================================
    
    -- Безопасный цикл для обработки Ноуклипа
    RunService.Stepped:Connect(function()
        if NoclipEnabled then
            local Character = LocalPlayer.Character
            if Character then
                for _, Part in ipairs(Character:GetDescendants()) do
                    if Part:IsA("BasePart") and Part.CanCollide == true then
                        Part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Отслеживание зажатия пробела (вызов прыжка в воздухе)
    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Фикс сброса настроек после перезагрузки персонажа (респавна)
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.6) -- Время на прогрузку персонажа игрой
        
        if Window.Flags and Window.Flags["WalkSpeedSlider"] then
            Humanoid.WalkSpeed = Window.Flags["WalkSpeedSlider"].CurrentValue
        end
        if Window.Flags and Window.Flags["JumpPowerSlider"] then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Window.Flags["JumpPowerSlider"].CurrentValue
        end
    end)
end-- Скопируй этот код и обнови им свой файл player.lua на GitHub

return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Переменные для новых функций
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    local SpinRenderConnection = nil

    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- ==========================================
    -- ХАРАКТЕРИСТИКИ
    -- ==========================================
    PlayerTab:CreateSection("Характеристики персонажа")

    PlayerTab:CreateSlider({
        Name = "Скорость бега (WalkSpeed)",
        Range = {16, 500},
        Increment = 1,
        Suffix = " Скорость",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.WalkSpeed = Value end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Высота прыжка (JumpPower)",
        Range = {50, 500},
        Increment = 1,
        Suffix = " Сила",
        CurrentValue = 50,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then 
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = Value 
            end
        end
    })

    -- ==========================================
    -- ПЕРЕМЕЩЕНИЕ И ОБХОД СТЕН
    -- ==========================================
    PlayerTab:CreateSection("Перемещение и Стены")

    -- Новая функция: Ноклип
    PlayerTab:CreateToggle({
        Name = "Прохождение сквозь стены (Noclip)",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            NoclipEnabled = Value
        end
    })

    -- Новая функция: Бесконечный прыжок
    PlayerTab:CreateToggle({
        Name = "Бесконечный прыжок (Inf Jump)",
        CurrentValue = false,
        Flag = "InfJumpToggle",
        Callback = function(Value)
            InfJumpEnabled = Value
        end
    })

    -- ==========================================
    -- ФАН УТИЛИТЫ
    -- ==========================================
    PlayerTab:CreateSection("Фан утилиты")

    PlayerTab:CreateToggle({
        Name = "Включить Спинбот (SpinBot)",
        CurrentValue = false,
        Flag = "SpinBotToggle",
        Callback = function(Value)
            if Value then
                if SpinRenderConnection then SpinRenderConnection:Disconnect() end
                SpinRenderConnection = RunService.Heartbeat:Connect(function()
                    local Character = LocalPlayer.Character
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    if RootPart then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                end)
            else
                if SpinRenderConnection then
                    SpinRenderConnection:Disconnect()
                    SpinRenderConnection = nil
                end
            end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Скорость вращения спинбота",
        Range = {10, 300},
        Increment = 5,
        Suffix = " Скорость",
        CurrentValue = 50,
        Flag = "SpinSpeedSlider",
        Callback = function(Value) SpinSpeed = Value end
    })

    -- ==========================================
    -- ЦИКЛЫ ОБРАБОТКИ (ГЛОБАЛЬНЫЕ СЕРВИСЫ)
    -- ==========================================
    
    -- Цикл для Noclip (работает каждый кадр перед рендером физики)
    RunService.Stepped:Connect(function()
        if NoclipEnabled then
            local Character = LocalPlayer.Character
            if Character then
                for _, Part in ipairs(Character:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        Part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Отслеживание нажатия пробела для Inf Jump
    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Авто-коррекция при возрождении
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.5)
        if Window.Flags and Window.Flags["WalkSpeedSlider"] then
            Humanoid.WalkSpeed = Window.Flags["WalkSpeedSlider"].CurrentValue
        end
        if Window.Flags and Window.Flags["JumpPowerSlider"] then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Window.Flags["JumpPowerSlider"].CurrentValue
        end
    end)
end-- Скопируй этот код и обнови им свой файл player.lua на GitHub

return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Переменные для новых функций
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    local SpinRenderConnection = nil

    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- ==========================================
    -- ХАРАКТЕРИСТИКИ
    -- ==========================================
    PlayerTab:CreateSection("Характеристики персонажа")

    PlayerTab:CreateSlider({
        Name = "Скорость бега (WalkSpeed)",
        Range = {16, 500},
        Increment = 1,
        Suffix = " Скорость",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.WalkSpeed = Value end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Высота прыжка (JumpPower)",
        Range = {50, 500},
        Increment = 1,
        Suffix = " Сила",
        CurrentValue = 50,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then 
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = Value 
            end
        end
    })

    -- ==========================================
    -- ПЕРЕМЕЩЕНИЕ И ОБХОД СТЕН
    -- ==========================================
    PlayerTab:CreateSection("Перемещение и Стены")

    -- Новая функция: Ноклип
    PlayerTab:CreateToggle({
        Name = "Прохождение сквозь стены (Noclip)",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            NoclipEnabled = Value
        end
    })

    -- Новая функция: Бесконечный прыжок
    PlayerTab:CreateToggle({
        Name = "Бесконечный прыжок (Inf Jump)",
        CurrentValue = false,
        Flag = "InfJumpToggle",
        Callback = function(Value)
            InfJumpEnabled = Value
        end
    })

    -- ==========================================
    -- ФАН УТИЛИТЫ
    -- ==========================================
    PlayerTab:CreateSection("Фан утилиты")

    PlayerTab:CreateToggle({
        Name = "Включить Спинбот (SpinBot)",
        CurrentValue = false,
        Flag = "SpinBotToggle",
        Callback = function(Value)
            if Value then
                if SpinRenderConnection then SpinRenderConnection:Disconnect() end
                SpinRenderConnection = RunService.Heartbeat:Connect(function()
                    local Character = LocalPlayer.Character
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    if RootPart then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                end)
            else
                if SpinRenderConnection then
                    SpinRenderConnection:Disconnect()
                    SpinRenderConnection = nil
                end
            end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Скорость вращения спинбота",
        Range = {10, 300},
        Increment = 5,
        Suffix = " Скорость",
        CurrentValue = 50,
        Flag = "SpinSpeedSlider",
        Callback = function(Value) SpinSpeed = Value end
    })

    -- ==========================================
    -- ЦИКЛЫ ОБРАБОТКИ (ГЛОБАЛЬНЫЕ СЕРВИСЫ)
    -- ==========================================
    
    -- Цикл для Noclip (работает каждый кадр перед рендером физики)
    RunService.Stepped:Connect(function()
        if NoclipEnabled then
            local Character = LocalPlayer.Character
            if Character then
                for _, Part in ipairs(Character:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        Part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Отслеживание нажатия пробела для Inf Jump
    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Авто-коррекция при возрождении
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.5)
        if Window.Flags and Window.Flags["WalkSpeedSlider"] then
            Humanoid.WalkSpeed = Window.Flags["WalkSpeedSlider"].CurrentValue
        end
        if Window.Flags and Window.Flags["JumpPowerSlider"] then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Window.Flags["JumpPowerSlider"].CurrentValue
        end
    end)
end-- [[ TRINITY-ULTRA V52.3 & XCLIENT COMBINED ]] --

return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Переменные для Trinity-Dodge модуля
    local TrinityEnabled = false
    local ActivationKey = Enum.KeyCode.X -- Клавиша по умолчанию
    local Vertical_Power = 9671405556917033397649407      
    local Speed_Multiplier = 43    
    local Ghost_Transparency = 0.05
    local Shot_Window = 0.2

    -- Создание объектов для Trinity
    local CameraAnchor = Instance.new("Part")
    CameraAnchor.Name = "TrinityAnchor"
    CameraAnchor.Transparency = 1
    CameraAnchor.CanCollide = false
    CameraAnchor.Anchored = true
    CameraAnchor.Size = Vector3.new(1, 1, 1)
    CameraAnchor.Parent = workspace

    local Gyro = Instance.new("BodyGyro")
    Gyro.Name = "TrinityGyro"
    Gyro.MaxTorque = Vector3.new(0, 0, 0)
    Gyro.P = 3000
    Gyro.D = 50

    -- Утилита изменения прозрачности персонажа
    local function setCharTrans(t)
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then 
                    v.Transparency = t
                elseif v:IsA("Decal") then 
                    v.Transparency = t 
                end
            end
        end
    end

    -- Переключение режима Trinity
    local function toggleTrinity(Value)
        if Value ~= nil then
            TrinityEnabled = Value
        else
            TrinityEnabled = not TrinityEnabled
        end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if TrinityEnabled then 
            setCharTrans(Ghost_Transparency)
            if root then 
                Gyro.Parent = root
                Gyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5) 
            end
        else 
            setCharTrans(0)
            Gyro.Parent = nil
            if root then 
                root.CanCollide = true
                root.CFrame = CameraAnchor.CFrame * CFrame.new(0, -2, 0) 
            end
            if char and char:FindFirstChild("Humanoid") then 
                Camera.CameraSubject = char.Humanoid 
            end
        end
    end

    -- ==========================================
    -- СОЗДАНИЕ ВКЛАДКИ EXPLOITS (Остальные убраны)
    -- ==========================================
    local ExploitsTab = Window:CreateTab("Exploits", 4483362458)

    ExploitsTab:CreateSection("Управление Trinity-Dodge")

    -- Переключатель Trinity-Dodge
    local TrinityToggle = ExploitsTab:CreateToggle({
        Name = "🚀 Активировать Trinity (TP-Dodge)",
        CurrentValue = false,
        Flag = "TrinityDodgeToggle",
        Callback = function(Value)
            if TrinityEnabled ~= Value then
                toggleTrinity(Value)
            end
        end
    })

    -- Настройка клавиши активации (Keybind)
    ExploitsTab:CreateKeybind({
        Name = "⌨️ Клавиша активации",
        CurrentKey = "X",
        Flag = "TrinityKeybind",
        Callback = function()
            toggleTrinity()
            -- Синхронизируем визуальное состояние переключателя в меню
            if Window.Flags and Window.Flags["TrinityDodgeToggle"] then
                Window.Flags["TrinityDodgeToggle"]:Set(TrinityEnabled)
            end
        end,
        CustomCallback = function(NewKey)
            ActivationKey = NewKey
        end
    })

    -- ==========================================
    -- СЕРВИСНЫЕ ЦИКЛЫ И ОБРАБОТКА
    -- ==========================================
    
    -- Обработка прыжков при активном Trinity
    UserInputService.JumpRequest:Connect(function()
        if TrinityEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
            end
        end
    end)

    -- Основной цикл Trinity (Heartbeat)
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if char and root and hum and TrinityEnabled then
            CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
            Camera.CameraSubject = CameraAnchor
            
            local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
            local startCF = root.CFrame
            
            if hum.MoveDirection.Magnitude > 0 then
                root.Velocity = Vector3.new(
                    hum.MoveDirection.X * Speed_Multiplier, 
                    root.Velocity.Y, 
                    hum.MoveDirection.Z * Speed_Multiplier
                )
            end

            if isShooting then
                root.CanCollide = true
                root.CFrame = startCF
                task.wait(Shot_Window)
            else
                root.CanCollide = false
                Gyro.CFrame = startCF
                local rx = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
                local rz = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
                root.CFrame = startCF * CFrame.new(rx, -Vertical_Power, rz)
                RunService.RenderStepped:Wait()
                if TrinityEnabled and root then
                    root.CFrame = startCF
                    root.CanCollide = true
                end
            end
        end
    end)

    -- Восстановление прозрачности при респавне персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if TrinityEnabled then
            setCharTrans(Ghost_Transparency)
        end
    end)
end
