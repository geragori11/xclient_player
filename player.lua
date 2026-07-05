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
    
    -- Переменные для расширенных режимов Спинбота
    local CurrentSpinMode = "Классический"
    local SpinBotActive = false
    local PhysicsSpinObj = nil
    local PhysicsAttachment = nil

    -- Переменные для сохранения характеристик после смерти
    local SavedWalkSpeed = 16
    local SavedJumpPower = 50

    -- Переменная для Anti-Fling
    local AntiFlingEnabled = false

    -- Переменная для Strafe (управление в воздухе без инерции)
    local StrafeEnabled = false

    -- Переменная для Обхода ММ2
    local MM2BypassEnabled = false

    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- Функция очистки физических объектов спинбота
    local function stopPhysicsSpin()
        if PhysicsSpinObj then PhysicsSpinObj:Destroy(); PhysicsSpinObj = nil end
        if PhysicsAttachment then PhysicsAttachment:Destroy(); PhysicsAttachment = nil end
    end

    -- Функция запуска / обновления спинбота
    local function startSpinBot()
        if SpinRenderConnection then SpinRenderConnection:Disconnect(); SpinRenderConnection = nil end
        stopPhysicsSpin()

        if not SpinBotActive then return end

        local Character = LocalPlayer.Character
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then return end

        if CurrentSpinMode == "Классический" then
            SpinRenderConnection = RunService.Heartbeat:Connect(function()
                local Char = LocalPlayer.Character
                local RP = Char and Char:FindFirstChild("HumanoidRootPart")
                if RP then
                    RP.CFrame = RP.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                end
            end)
        elseif CurrentSpinMode == "Безумный (XYZ)" then
            SpinRenderConnection = RunService.Heartbeat:Connect(function()
                local Char = LocalPlayer.Character
                local RP = Char and Char:FindFirstChild("HumanoidRootPart")
                if RP then
                    RP.CFrame = RP.CFrame * CFrame.Angles(math.rad(SpinSpeed), math.rad(SpinSpeed), math.rad(SpinSpeed))
                end
            end)
        elseif CurrentSpinMode == "Дрожание (Jitter)" then
            SpinRenderConnection = RunService.Heartbeat:Connect(function()
                local Char = LocalPlayer.Character
                local RP = Char and Char:FindFirstChild("HumanoidRootPart")
                if RP then
                    local jitter = math.rad(math.random(-180, 180))
                    RP.CFrame = RP.CFrame * CFrame.Angles(0, jitter, 0)
                end
            end)
        elseif CurrentSpinMode == "Физический (Плавный)" then
            PhysicsAttachment = Instance.new("Attachment")
            PhysicsAttachment.Name = "SpinAttachment"
            PhysicsAttachment.Parent = RootPart

            PhysicsSpinObj = Instance.new("AngularVelocity")
            PhysicsSpinObj.Name = "SpinVelocity"
            PhysicsSpinObj.Attachment0 = PhysicsAttachment
            PhysicsSpinObj.MaxTorque = math.huge
            PhysicsSpinObj.AngularVelocity = Vector3.new(0, SpinSpeed / 10, 0) -- Делим, так как у AngularVelocity другие физические единицы
            PhysicsSpinObj.Parent = RootPart
        end
    end

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
            if Humanoid then 
                if MM2BypassEnabled and Value > 30 then
                    Humanoid.WalkSpeed = 30
                else
                    Humanoid.WalkSpeed = Value 
                end
            end
        end
    })

    -- Переключатель для обхода MM2
    PlayerTab:CreateToggle({
        Name = "Обход ММ2 (Для скорости > 30)",
        CurrentValue = false,
        Flag = "MM2BypassToggle",
        Callback = function(Value)
            MM2BypassEnabled = Value
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                if Value and SavedWalkSpeed > 30 then
                    Humanoid.WalkSpeed = 30
                else
                    Humanoid.WalkSpeed = SavedWalkSpeed
                end
            end
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
            SpinBotActive = Value
            startSpinBot()
        end
    })

    PlayerTab:CreateDropdown({
        Name = "Режим Спинбота",
        Options = {"Классический", "Физический (Плавный)", "Дрожание (Jitter)", "Безумный (XYZ)"},
        CurrentOption = "Классический",
        Flag = "SpinModeDropdown",
        Callback = function(Option)
            CurrentSpinMode = Option
            if SpinBotActive then
                startSpinBot()
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
        Callback = function(Value) 
            SpinSpeed = Value 
            if SpinBotActive and CurrentSpinMode == "Физический (Плавный)" and PhysicsSpinObj then
                PhysicsSpinObj.AngularVelocity = Vector3.new(0, Value / 10, 0)
            end
        end
    })

    -- ==========================================
    -- ЦИКЛЫ ОБРАБОТКИ (ГЛОБАЛЬНЫЕ СЕРВИСЫ)
    -- ==========================================
    
    -- Цикл для Noclip, Anti-Fling и Strafe
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

        -- Обработка Strafe
        if StrafeEnabled and MyHRP then
            local Humanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                local state = Humanoid:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                    local moveDirection = Humanoid.MoveDirection
                    if moveDirection.Magnitude > 0 then
                        MyHRP.Velocity = moveDirection * Humanoid.WalkSpeed + Vector3.new(0, MyHRP.Velocity.Y, 0)
                    else
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

    -- Авто-коррекция и восстановление состояний при возрождении
    LocalPlayer.CharacterAdded:Connect(function(Character)
        stopPhysicsSpin() -- Удаляем старые ссылки, так как части персонажа обновились
        
        local Humanoid = Character:WaitForChild("Humanoid", 3)
        if Humanoid then
            task.wait(0.2)
            if MM2BypassEnabled and SavedWalkSpeed > 30 then
                Humanoid.WalkSpeed = 30
            else
                Humanoid.WalkSpeed = SavedWalkSpeed
            end
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = SavedJumpPower
        end

        -- Если спинбот был включен, перезапускаем его на новом теле
        task.wait(0.1)
        if SpinBotActive then
            startSpinBot()
        end
    end)

    -- ==========================================
    -- АВТО-ОБНОВЛЕНИЕ ВСЕХ НАСТРОЕК КАЖДЫЕ 2 СЕКУНДЫ
    -- ==========================================
    local function fullRefresh()
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if MM2BypassEnabled and SavedWalkSpeed > 30 then
                hum.WalkSpeed = 30
            else
                hum.WalkSpeed = SavedWalkSpeed
            end
            hum.UseJumpPower = true
            hum.JumpPower = SavedJumpPower
        end

        if NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

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
    end

    -- Периодический вызов обновления характеристик
    task.spawn(function()
        while true do
            task.wait(2)
            fullRefresh()
        end
    end)

    -- Цикл для пульсации скорости (Обход ММ2)
    task.spawn(function()
        while true do
            task.wait(1.2)
            if MM2BypassEnabled and SavedWalkSpeed > 30 then
                local Character = LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.WalkSpeed = SavedWalkSpeed
                    
                    if SavedWalkSpeed > 65 then
                        task.wait(0.1)
                    else
                        task.wait(0.5)
                    end
                    
                    if MM2BypassEnabled and SavedWalkSpeed > 30 then
                        Humanoid.WalkSpeed = 30
                    end
                end
            end
        end
    end)

    -- Дополнительное полное обновление при смене персонажа
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        fullRefresh()
    end)
end
