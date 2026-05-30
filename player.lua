--[[
    XClientMenuV2 - Player Module (Rayfield-based)
    Вкладка функций локального игрока: WalkSpeed, JumpPower, SpinBot
--]]

return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- Дефолтные значения
    local NormalSpeed = 16
    local NormalJump = 50
    local SpinSpeed = 50

    local SpinRenderConnection = nil

    -- Создаем вкладку Player
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    PlayerTab:CreateSection("Характеристики персонажа")

    -- Ползунок скорости (WalkSpeed)
    PlayerTab:CreateSlider({
        Name = "Скорость бега (WalkSpeed)",
        Range = {16, 500},
        Increment = 1,
        Suffix = " Характеристика",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
        end
    })

    -- Ползунок прыжка (JumpPower)
    PlayerTab:CreateSlider({
        Name = "Высота прыжка (JumpPower)",
        Range = {50, 500},
        Increment = 1,
        Suffix = " Характеристика",
        CurrentValue = 50,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.UseJumpPower = true -- Гарантируем, что используется JumpPower вместо JumpHeight
                Humanoid.JumpPower = Value
            end
        end
    })

    PlayerTab:CreateSection("Фан утилиты")

    -- Переключатель Спинбота
    PlayerTab:CreateToggle({
        Name = "Включить Спинбот (SpinBot)",
        CurrentValue = false,
        Flag = "SpinBotToggle",
        Callback = function(Value)
            if Value then
                -- Активация спинбота через Heartbeat (чтобы не лагало и работало плавно)
                if SpinRenderConnection then SpinRenderConnection:Disconnect() end
                
                SpinRenderConnection = RunService.Heartbeat:Connect(function()
                    local Character = LocalPlayer.Character
                    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                    if RootPart then
                        RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                end)
            else
                -- Отключение спинбота
                if SpinRenderConnection then
                    SpinRenderConnection:Disconnect()
                    SpinRenderConnection = nil
                end
            end
        end
    })

    -- Настройка скорости вращения спинбота
    PlayerTab:CreateSlider({
        Name = "Скорость вращения спинбота",
        Range = {10, 300},
        Increment = 5,
        Suffix = " Скорость",
        CurrentValue = 50,
        Flag = "SpinSpeedSlider",
        Callback = function(Value)
            SpinSpeed = Value
        end
    })

    -- Авто-коррекция характеристик при возрождении персонажа
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid")
        task.wait(0.5) -- Небольшая задержка для загрузки флагов интерфейса
        
        -- Проверяем текущие значения в слайдерах интерфейса (если они сохранены в флагах)
        if Window.Flags and Window.Flags["WalkSpeedSlider"] then
            Humanoid.WalkSpeed = Window.Flags["WalkSpeedSlider"].CurrentValue
        end
        if Window.Flags and Window.Flags["JumpPowerSlider"] then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Window.Flags["JumpPowerSlider"].CurrentValue
        end
    end)
end