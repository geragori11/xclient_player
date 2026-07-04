return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Основные переменные
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    local SpinRenderConnection = nil

    local SavedWalkSpeed = 16
    local SavedJumpPower = 50

    local AntiFlingEnabled = false
    local StrafeEnabled = false

    -- ==========================================
    -- БЕССМЕРТИЕ (TRINITY TP-DODGE) – Rayfield‑версия
    -- ==========================================
    local GodModeEnabled = false
    local GodKey = Enum.KeyCode.X
    local GhostTransparency = 0.05
    local SpeedMultiplier = 43
    local VerticalPower = 9671405556917033397649407
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

    local function toggleGodModePhysics(enable)
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
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                hum.PlatformStand = false
            end
        end
        GodModeEnabled = enable
    end

    local function SetGodMode(enable)
        if GodModeEnabled == enable then return end
        toggleGodModePhysics(enable)

        -- Синхронизируем флаг Rayfield
        if Window and Window.Flags and Window.Flags["GodToggle"] then
            Window.Flags["GodToggle"]:Set(enable)
        end
    end

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

    -- ==========================================
    -- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
    -- ==========================================
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- Характеристики
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
        end
    })

    -- Перемещение и стены
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

    -- Защита
    PlayerTab:CreateSection("Защита")

    PlayerTab:CreateToggle({
        Name = "Anti-Fling (Без коллизии с игроками <30 ст)",
        CurrentValue = false,
        Flag = "AntiFlingToggle",
        Callback = function(Value)
            AntiFlingEnabled = Value
        end
    })

    -- Фан утилиты
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

    -- БЕССМЕРТИЕ (интерфейс)
    PlayerTab:CreateSection("Бессмертие (Trinity TP-Dodge)")

    PlayerTab:CreateToggle({
        Name = "Включить бессмертие",
        CurrentValue = false,
        Flag = "GodToggle",
        Callback = function(Value)
            -- Защита от рекурсивного вызова: если состояние уже совпадает, ничего не делаем
            if GodModeEnabled ~= Value then
                SetGodMode(Value)
            end
        end
    })

    PlayerTab:CreateSlider({
        Name = "Прозрачность",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 5,
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

    -- Обработчик клавиши
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == GodKey then
            SetGodMode(not GodModeEnabled)
        end
    end)

    -- ==========================================
    -- ОСНОВНОЙ ЦИКЛ (Stepped)
    -- ==========================================
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        -- Принудительная установка скорости и прыжка (каждый кадр)
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

        -- Anti-Fling
        if AntiFlingEnabled and root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot and (root.Position - targetRoot.Position).Magnitude <= 30 then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end

        -- Strafe
        if StrafeEnabled and root and hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    root.Velocity = moveDir * hum.WalkSpeed + Vector3.new(0, root.Velocity.Y, 0)
                else
                    root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
                end
            end
        end
    end)

    -- Бесконечный прыжок
    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Перезапуск бессмертия при возрождении
    LocalPlayer.CharacterAdded:Connect(function()
        if GodModeEnabled then
            toggleGodModePhysics(false)
            task.wait(0.1)
            toggleGodModePhysics(true)
            -- Обновляем флаг в интерфейсе
            if Window and Window.Flags and Window.Flags["GodToggle"] then
                Window.Flags["GodToggle"]:Set(true)
            end
        end
    end)
end
