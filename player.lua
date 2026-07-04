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

    -- ==========================================
    -- ПЕРЕМЕННЫЕ ДЛЯ НЕВИДИМОСТИ (TRINITY DODGE)
    -- ==========================================
    local InvisibilityEnabled = false
    local InvisibilityKey = Enum.KeyCode.X
    local GhostTransparency = 0.05
    local DodgeSpeedMultiplier = 43
    local VerticalPower = 9671405556917033397649407  -- большое число для вертикального смещения
    local ShotWindow = 0.2

    local CameraAnchor = nil
    local Gyro = nil
    local InvisibilityHeartbeat = nil  -- соединение Heartbeat

    -- Вспомогательная функция установки прозрачности (как в Trinity)
    local function setCharTransparency(transparency)
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = transparency
            elseif v:IsA("Decal") then
                v.Transparency = transparency
            end
        end
    end

    -- Функция включения/выключения невидимости
    local function toggleInvisibility(enable)
        if enable == InvisibilityEnabled then return end
        InvisibilityEnabled = enable
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if enable then
            -- Создаём якорь для камеры, если его ещё нет
            if not CameraAnchor then
                CameraAnchor = Instance.new("Part")
                CameraAnchor.Name = "TrinityInvisAnchor"
                CameraAnchor.Transparency = 1
                CameraAnchor.CanCollide = false
                CameraAnchor.Anchored = true
                CameraAnchor.Size = Vector3.new(1, 1, 1)
                CameraAnchor.Parent = workspace
            end
            if not Gyro then
                Gyro = Instance.new("BodyGyro")
                Gyro.Name = "TrinityInvisGyro"
                Gyro.MaxTorque = Vector3.new(0, 0, 0)
                Gyro.P = 3000
                Gyro.D = 50
            end

            setCharTransparency(GhostTransparency)
            if root then
                Gyro.Parent = root
                Gyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
                -- Обновляем позицию якоря
                CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
                workspace.CurrentCamera.CameraSubject = CameraAnchor
            end

            -- Запускаем цикл Heartbeat
            if InvisibilityHeartbeat then
                InvisibilityHeartbeat:Disconnect()
            end
            InvisibilityHeartbeat = RunService.Heartbeat:Connect(function()
                if not InvisibilityEnabled then return end
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not (char and root and hum) then return end

                -- Обновляем позицию якоря камеры
                CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
                workspace.CurrentCamera.CameraSubject = CameraAnchor

                local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or
                                   UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
                local startCF = root.CFrame

                -- Движение с увеличенной скоростью
                if hum.MoveDirection.Magnitude > 0 then
                    root.Velocity = Vector3.new(
                        hum.MoveDirection.X * DodgeSpeedMultiplier,
                        root.Velocity.Y,
                        hum.MoveDirection.Z * DodgeSpeedMultiplier
                    )
                end

                if isShooting then
                    -- При стрельбе временно включаем коллизию и возвращаем на место
                    root.CanCollide = true
                    root.CFrame = startCF
                    task.wait(ShotWindow)
                    root.CanCollide = false
                else
                    -- Додж: отключаем коллизию, смещаем на огромное расстояние вниз, ждём кадр и возвращаем
                    root.CanCollide = false
                    Gyro.CFrame = startCF
                    local rx = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
                    local rz = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
                    root.CFrame = startCF * CFrame.new(rx, -VerticalPower, rz)
                    RunService.RenderStepped:Wait()
                    if InvisibilityEnabled and root then
                        root.CFrame = startCF
                        root.CanCollide = true
                    end
                end
            end)
        else
            -- Выключение режима
            setCharTransparency(0)
            if Gyro then
                Gyro.Parent = nil
            end
            if root then
                root.CanCollide = true
                if CameraAnchor then
                    root.CFrame = CameraAnchor.CFrame * CFrame.new(0, -2, 0)
                end
            end
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
            end
            if InvisibilityHeartbeat then
                InvisibilityHeartbeat:Disconnect()
                InvisibilityHeartbeat = nil
            end
        end
    end

    -- Обработчик нажатия клавиши для невидимости (если задана)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == InvisibilityKey then
            toggleInvisibility(not InvisibilityEnabled)
        end
    end)

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
    -- НОВЫЙ РЕЖИМ: НЕВИДИМОСТЬ (TRINITY DODGE)
    -- ==========================================
    PlayerTab:CreateSection("Невидимость (Trinity Dodge)")

    PlayerTab:CreateToggle({
        Name = "Включить невидимость",
        CurrentValue = false,
        Flag = "InvisibilityToggle",
        Callback = function(Value)
            toggleInvisibility(Value)
        end
    })

    PlayerTab:CreateSlider({
        Name = "Прозрачность",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 5,  -- 0.05 -> 5%
        Flag = "GhostTransparencySlider",
        Callback = function(Value)
            GhostTransparency = Value / 100
            if InvisibilityEnabled then
                setCharTransparency(GhostTransparency)
            end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Скорость перемещения",
        Range = {10, 200},
        Increment = 1,
        Suffix = " studs/s",
        CurrentValue = 43,
        Flag = "DodgeSpeedSlider",
        Callback = function(Value)
            DodgeSpeedMultiplier = Value
        end
    })

    -- Настройка клавиши активации
    PlayerTab:CreateKeybind({
        Name = "Клавиша переключения",
        CurrentKeybind = "X",
        Flag = "InvisibilityKeybind",
        Callback = function(Key)
            InvisibilityKey = Key
        end
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
        -- Если невидимость была включена, применяем прозрачность заново
        if InvisibilityEnabled then
            setCharTransparency(GhostTransparency)
            -- Переподключаем Gyro к новому RootPart
            local root = Character:FindFirstChild("HumanoidRootPart")
            if root and Gyro then
                Gyro.Parent = root
            end
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

        -- Обновление прозрачности для невидимости
        if InvisibilityEnabled then
            setCharTransparency(GhostTransparency)
        end
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
