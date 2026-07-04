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

    -- Переменные для сохранения характеристик после смерти
    local SavedWalkSpeed = 16
    local SavedJumpPower = 50

    -- Переменная для Anti-Fling
    local AntiFlingEnabled = false

    -- Переменная для Strafe (управление в воздухе без инерции)
    local StrafeEnabled = false

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
            SavedWalkSpeed = Value -- Сохраняем значение
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
            SavedJumpPower = Value -- Сохраняем значение
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

    PlayerTab:CreateToggle({
        Name = "Прохождение сквозь стены (Noclip)",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            NoclipEnabled = Value
        end
    })

    PlayerTab:CreateToggle({
        Name = "Бесконечный прыжок (Inf Jump)",
        CurrentValue = false,
        Flag = "InfJumpToggle",
        Callback = function(Value)
            InfJumpEnabled = Value
        end
    })

    -- Strafe (воздушное управление без инерции)
    PlayerTab:CreateToggle({
        Name = "Strafe (Убирает инерцию в воздухе)",
        CurrentValue = false,
        Flag = "StrafeToggle",
        Callback = function(Value)
            StrafeEnabled = Value
        end
    })

    -- ==========================================
    -- ЗАЩИТА (Anti-Fling)
    -- ==========================================
    PlayerTab:CreateSection("Защита")

    PlayerTab:CreateToggle({
        Name = "Anti-Fling (Без коллизии с игроками <30 ст)",
        CurrentValue = false,
        Flag = "AntiFlingToggle",
        Callback = function(Value)
            AntiFlingEnabled = Value
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
    
    -- Цикл для Noclip, Anti-Fling и Strafe (работает каждый кадр перед рендером физики)
    RunService.Stepped:Connect(function()
        local MyCharacter = LocalPlayer.Character
        if not MyCharacter then return end

        local MyHRP = MyCharacter:FindFirstChild("HumanoidRootPart")

        -- Обработка Noclip
        if NoclipEnabled then
            for _, Part in ipairs(MyCharacter:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end

        -- Обработка Anti-Fling
        if AntiFlingEnabled and MyHRP then
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character then
                    local TargetHRP = Player.Character:FindFirstChild("HumanoidRootPart")
                    -- Если игрок ближе чем на 30 студов
                    if TargetHRP and (MyHRP.Position - TargetHRP.Position).Magnitude <= 30 then
                        for _, Part in ipairs(Player.Character:GetDescendants()) do
                            if Part:IsA("BasePart") then
                                Part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end

        -- Обработка Strafe (управление в воздухе без инерции)
        if StrafeEnabled and MyHRP then
            local Humanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                local state = Humanoid:GetState()
                -- Применяем только в воздухе (свободное падение или прыжок)
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                    local moveDirection = Humanoid.MoveDirection
                    if moveDirection.Magnitude > 0 then
                        -- Движемся в указанном направлении с текущей скоростью бега, сохраняя вертикальную скорость
                        MyHRP.Velocity = moveDirection * Humanoid.WalkSpeed + Vector3.new(0, MyHRP.Velocity.Y, 0)
                    else
                        -- Клавиши не нажаты – гасим горизонтальную скорость, персонаж зависает в воздухе
                        MyHRP.Velocity = Vector3.new(0, MyHRP.Velocity.Y, 0)
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
        -- Ждем прогрузки Humanoid
        local Humanoid = Character:WaitForChild("Humanoid", 3)
        if Humanoid then
            task.wait(0.2) -- Легкая задержка, чтобы игра не успела сбросить наши настройки
            Humanoid.WalkSpeed = SavedWalkSpeed
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = SavedJumpPower
        end
    end)

    -- ==========================================
    -- АВТО-ОБНОВЛЕНИЕ ВСЕХ НАСТРОЕК КАЖДЫЕ 2 СЕКУНДЫ И ПОСЛЕ СМЕРТИ
    -- ==========================================
    local function fullRefresh()
        local char = LocalPlayer.Character
        if not char then return end

        -- Характеристики
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SavedWalkSpeed
            hum.UseJumpPower = true
            hum.JumpPower = SavedJumpPower
        end

        -- Noclip
        if NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        -- Anti-Fling (повторно отключаем коллизию ближайших врагов)
        if AntiFlingEnabled then
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and (myHRP.Position - targetHRP.Position).Magnitude <= 30 then
                            for _, part in ipairs(player.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Остальные функции (InfJump, Strafe, SpinBot) обновляются в реальном времени через свои циклы,
        -- но здесь можно добавить принудительную активацию при необходимости.
    end

    -- Периодический вызов каждые 2 секунды
    task.spawn(function()
        while true do
            task.wait(2)
            fullRefresh()
        end
    end)

    -- Дополнительное полное обновление при возрождении персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        fullRefresh()
    end)
end
