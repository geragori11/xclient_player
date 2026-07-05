return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Переменные для перемещения и стен
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    
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

    -- Функция безопасной очистки физических объектов спинбота
    local function stopPhysicsSpin()
        if PhysicsSpinObj then 
            pcall(function() PhysicsSpinObj:Destroy() end) 
            PhysicsSpinObj = nil 
        end
        if PhysicsAttachment then 
            pcall(function() PhysicsAttachment:Destroy() end) 
            PhysicsAttachment = nil 
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
            SavedWalkSpeed = Value
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
            SavedJumpPower = Value
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
        end
    })

    PlayerTab:CreateDropdown({
        Name = "Режим Спинбота",
        Options = {"Классический", "Физический (Плавный)", "Дрожание (Jitter)", "Безумный (XYZ)"},
        CurrentOption = "Классический",
        Flag = "SpinModeDropdown",
        Callback = function(Option)
            -- Защита от возвращения таблицы в Rayfield UI
            local CleanOption = type(Option) == "table" and Option[1] or Option
            if type(CleanOption) == "string" then
                CurrentSpinMode = CleanOption
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
        end
    })

    -- ==========================================
    -- ЦИКЛЫ ОБРАБОТКИ (ГЛОБАЛЬНЫЕ СЕРВИСЫ)
    -- ==========================================
    
    -- Главный поток обработки физики и перемещений
    RunService.Stepped:Connect(function()
        local MyCharacter = LocalPlayer.Character
        if not MyCharacter then return end

        local MyHRP = MyCharacter:FindFirstChild("HumanoidRootPart")
        local MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")

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
        if StrafeEnabled and MyHRP and MyHumanoid then
            local state = MyHumanoid:GetState()
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                local moveDirection = MyHumanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    MyHRP.Velocity = moveDirection * MyHumanoid.WalkSpeed + Vector3.new(0, MyHRP.Velocity.Y, 0)
                else
                    MyHRP.Velocity = Vector3.new(0, MyHRP.Velocity.Y, 0)
                end
            end
        end

        -- ЦЕНТРАЛЬНАЯ ЛОГИКА СПИНБОТА
        if SpinBotActive and MyHRP and MyHumanoid then
            -- Настройка стейтов Humanoid во избежание сопротивления игры
            if CurrentSpinMode == "Безумный (XYZ)" then
                if not MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = true end
            else
                if MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = false end
            end

            if MyHumanoid.AutoRotate then MyHumanoid.AutoRotate = false end

            -- Выполнение режимов вращения
            if CurrentSpinMode == "Классический" then
                stopPhysicsSpin()
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                
            elseif CurrentSpinMode == "Безумный (XYZ)" then
                stopPhysicsSpin()
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(math.rad(SpinSpeed), math.rad(SpinSpeed), math.rad(SpinSpeed))
                
            elseif CurrentSpinMode == "Дрожание (Jitter)" then
                stopPhysicsSpin()
                local jitter = math.rad(math.random(-180, 180))
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, jitter, 0)
                
            elseif CurrentSpinMode == "Физический (Плавный)" then
                -- Динамическое создание физического тела вращения, если его нет
                if not PhysicsSpinObj or PhysicsSpinObj.Parent ~= MyHRP then
                    stopPhysicsSpin()
                    
                    PhysicsAttachment = Instance.new("Attachment")
                    PhysicsAttachment.Name = "SpinAttachment"
                    PhysicsAttachment.Parent = MyHRP

                    PhysicsSpinObj = Instance.new("AngularVelocity")
                    PhysicsSpinObj.Name = "SpinVelocity"
                    PhysicsSpinObj.Attachment0 = PhysicsAttachment
                    PhysicsSpinObj.MaxTorque = math.huge
                    PhysicsSpinObj.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                    PhysicsSpinObj.Parent = MyHRP
                end
                PhysicsSpinObj.AngularVelocity = Vector3.new(0, SpinSpeed / 10, 0)
            end
        else
            -- Если спинбот отключен, возвращаем персонажу стандартные настройки
            stopPhysicsSpin()
            if MyHumanoid then
                if not MyHumanoid.AutoRotate then MyHumanoid.AutoRotate = true end
                if MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = false end
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

    -- Очистка ссылок при смерти персонажа
    LocalPlayer.CharacterAdded:Connect(function(Character)
        stopPhysicsSpin()
        
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

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        fullRefresh()
    end)
end
