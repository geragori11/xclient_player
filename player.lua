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
    -- ПЕРЕМЕННЫЕ ДЛЯ БЕССМЕРТИЯ / TP-DODGE (КАК TRINITY-ULTRA V52.3)
    -- ==========================================
    local GodModeEnabled = false
    local GodKey = Enum.KeyCode.X
    local GhostTransparency = 0.05
    local SpeedMultiplier = 43
    local VerticalPower = 9671405556917033397649407     -- максимальная глубина
    local ShotWindow = 0.2

    local CameraAnchor = Instance.new("Part")
    CameraAnchor.Name = "GodModeAnchor"
    CameraAnchor.Transparency = 1
    CameraAnchor.CanCollide = false
    CameraAnchor.Anchored = true
    CameraAnchor.Size = Vector3.new(1, 1, 1)
    CameraAnchor.Parent = workspace

    local Gyro = Instance.new("BodyGyro")
    Gyro.Name = "GodModeGyro"
    Gyro.MaxTorque = Vector3.new(0, 0, 0)
    Gyro.P = 3000
    Gyro.D = 50

    local function setCharTransparency(trans)
        local char = LocalPlayer.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = trans
                elseif v:IsA("Decal") then
                    v.Transparency = trans
                end
            end
        end
    end

    local function toggleGodMode(enable)
        if enable == GodModeEnabled then return end
        GodModeEnabled = enable
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if enable then
            setCharTransparency(GhostTransparency)
            if root then
                Gyro.Parent = root
                Gyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
                CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
                workspace.CurrentCamera.CameraSubject = CameraAnchor
            end
        else
            setCharTransparency(0)
            Gyro.Parent = nil
            if root then
                root.CanCollide = true
                root.CFrame = CameraAnchor.CFrame * CFrame.new(0, -2, 0)
            end
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
            end
        end
    end

    -- Синхронизация клавиши и тогла
    local function onGodKeyPress()
        local newState = not GodModeEnabled
        toggleGodMode(newState)
        pcall(function()
            if Window and Window.Flags and Window.Flags.InvisibilityToggle then
                Window.Flags.InvisibilityToggle:Set(newState)
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == GodKey then
            onGodKeyPress()
        end
    end)

    -- Основной цикл TP-Dodge (Heartbeat)
    RunService.Heartbeat:Connect(function()
        if not GodModeEnabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and root and hum) then return end

        CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
        workspace.CurrentCamera.CameraSubject = CameraAnchor

        local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or
                           UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
        local startCF = root.CFrame

        -- Горизонтальное движение с умножением скорости
        if hum.MoveDirection.Magnitude > 0 then
            root.Velocity = Vector3.new(
                hum.MoveDirection.X * SpeedMultiplier,
                root.Velocity.Y,
                hum.MoveDirection.Z * SpeedMultiplier
            )
        end

        if isShooting then
            root.CanCollide = true
            root.CFrame = startCF
            task.wait(ShotWindow)
        else
            root.CanCollide = false
            Gyro.CFrame = startCF
            local rx = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
            local rz = math.random(-1.7976931348623157e308, 1.7976931348623157e308)
            root.CFrame = startCF * CFrame.new(rx, -VerticalPower, rz)
            RunService.RenderStepped:Wait()
            if GodModeEnabled and root then
                root.CFrame = startCF
                root.CanCollide = true
            end
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
            SavedWalkSpeed = Value
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
    -- БЕССМЕРТИЕ / TP-DODGE (TRINITY STYLE)
    -- ==========================================
    PlayerTab:CreateSection("Бессмертие (Trinity TP-Dodge)")

    PlayerTab:CreateToggle({
        Name = "Включить бессмертие",
        CurrentValue = false,
        Flag = "InvisibilityToggle",
        Callback = function(Value)
            toggleGodMode(Value)
        end
    })

    PlayerTab:CreateSlider({
        Name = "Прозрачность",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 5,   -- 0.05
        Flag = "TransparencySlider",
        Callback = function(Value)
            GhostTransparency = Value / 100
            if GodModeEnabled then
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
        Flag = "SpeedSlider",
        Callback = function(Value)
            SpeedMultiplier = Value
        end
    })

    PlayerTab:CreateKeybind({
        Name = "Клавиша переключения",
        CurrentKeybind = "X",
        Flag = "GodKeybind",
        Callback = function(Key)
            GodKey = Key
        end
    })

    -- ==========================================
    -- ЦИКЛЫ ОБРАБОТКИ (NOCLIP, ANTI-FLING, STRAFE)
    -- ==========================================
    RunService.Stepped:Connect(function()
        local MyCharacter = LocalPlayer.Character
        if not MyCharacter then return end

        local MyHRP = MyCharacter:FindFirstChild("HumanoidRootPart")

        if NoclipEnabled then
            for _, Part in ipairs(MyCharacter:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end

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

    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid", 3)
        if Humanoid then
            task.wait(0.2)
            Humanoid.WalkSpeed = SavedWalkSpeed
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = SavedJumpPower
        end
        -- При возрождении, если бессмертие было включено, перезапускаем его для нового тела
        if GodModeEnabled then
            toggleGodMode(false)
            task.wait(0.1)
            toggleGodMode(true)
        end
    end)

    -- ==========================================
    -- АВТО-ОБНОВЛЕНИЕ КАЖДЫЕ 2 СЕКУНДЫ
    -- ==========================================
    local function fullRefresh()
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SavedWalkSpeed
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

        if GodModeEnabled then
            setCharTransparency(GhostTransparency)
        end
    end

    task.spawn(function()
        while true do
            task.wait(2)
            fullRefresh()
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        fullRefresh()
    end)
end
