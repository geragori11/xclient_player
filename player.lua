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
end
