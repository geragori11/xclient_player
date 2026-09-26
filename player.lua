return function(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- Переменные состояния перемещения
    local NoclipEnabled = false
    local InfJumpEnabled = false
    local SpinSpeed = 50
    
    -- Переменные для режимов Спинбота
    local CurrentSpinMode = "Классический"
    local SpinBotActive = false
    local PhysicsSpinObj = nil
    local PhysicsAttachment = nil

    -- Сохранение характеристик персонажа
    local SavedWalkSpeed = 16
    local SavedJumpPower = 50

    -- Переменные для защиты и обходов
    local AntiFlingEnabled = false
    local StrafeEnabled = false
    local MM2BypassEnabled = false

    -- Фиксированные углы для режимов дерганья
    local TwitchAngles = {60, 120, 180, 240, 300, 360}
    local TwitchAngles2 = {120, 240, 360}

    -- ==========================================
    -- ИНИЦИАЛИЗАЦИЯ И ЛОГИКА FLY GUI V3
    -- ==========================================
    local speeds = 1
    local nowe = false
    local tpwalking = false
    local FlyGuiNotified = false

    -- Флаги вертикального движения
    local upPressed = false
    local downPressed = false

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton")

    main.Name = "FlyGuiV3"
    main.Parent = LocalPlayer:WaitForChild("PlayerGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false
    main.Enabled = false

    Frame.Name = "Frame"
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
    Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
    Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
    Frame.Size = UDim2.new(0, 190, 0, 57)
    Frame.Active = true
    Frame.Draggable = true

    up.Name = "up"
    up.Parent = Frame
    up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
    up.Size = UDim2.new(0, 44, 0, 28)
    up.Font = Enum.Font.SourceSans
    up.Text = "UP"
    up.TextColor3 = Color3.fromRGB(0, 0, 0)
    up.TextSize = 14.000

    down.Name = "down"
    down.Parent = Frame
    down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
    down.Position = UDim2.new(0, 0, 0.491228074, 0)
    down.Size = UDim2.new(0, 44, 0, 28)
    down.Font = Enum.Font.SourceSans
    down.Text = "DOWN"
    down.TextColor3 = Color3.fromRGB(0, 0, 0)
    down.TextSize = 14.000

    onof.Name = "onof"
    onof.Parent = Frame
    onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
    onof.Size = UDim2.new(0, 56, 0, 28)
    onof.Font = Enum.Font.SourceSans
    onof.Text = "fly"
    onof.TextColor3 = Color3.fromRGB(0, 0, 0)
    onof.TextSize = 14.000

    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
    TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
    TextLabel.Size = UDim2.new(0, 100, 0, 28)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "FLY GUI V3"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true

    plus.Name = "plus"
    plus.Parent = Frame
    plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
    plus.Position = UDim2.new(0.231578946, 0, 0, 0)
    plus.Size = UDim2.new(0, 45, 0, 28)
    plus.Font = Enum.Font.SourceSans
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(0, 0, 0)
    plus.TextScaled = true
    plus.TextSize = 14.000
    plus.TextWrapped = true

    speed.Name = "speed"
    speed.Parent = Frame
    speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
    speed.Size = UDim2.new(0, 44, 0, 28)
    speed.Font = Enum.Font.SourceSans
    speed.Text = "1"
    speed.TextColor3 = Color3.fromRGB(0, 0, 0)
    speed.TextScaled = true
    speed.TextSize = 14.000
    speed.TextWrapped = true

    mine.Name = "mine"
    mine.Parent = Frame
    mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
    mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
    mine.Size = UDim2.new(0, 45, 0, 29)
    mine.Font = Enum.Font.SourceSans
    mine.Text = "-"
    mine.TextColor3 = Color3.fromRGB(0, 0, 0)
    mine.TextScaled = true
    mine.TextSize = 14.000
    mine.TextWrapped = true

    closebutton.Name = "Close"
    closebutton.Parent = Frame
    closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
    closebutton.Font = Enum.Font.SourceSans
    closebutton.Size = UDim2.new(0, 45, 0, 28)
    closebutton.Text = "X"
    closebutton.TextSize = 30
    closebutton.Position = UDim2.new(0, 0, -1, 27)

    mini.Name = "minimize"
    mini.Parent = Frame
    mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini.Font = Enum.Font.SourceSans
    mini.Size = UDim2.new(0, 45, 0, 28)
    mini.Text = "-"
    mini.TextSize = 40
    mini.Position = UDim2.new(0, 44, -1, 27)

    mini2.Name = "minimize2"
    mini2.Parent = Frame
    mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
    mini2.Font = Enum.Font.SourceSans
    mini2.Size = UDim2.new(0, 45, 0, 28)
    mini2.Text = "+"
    mini2.TextSize = 40
    mini2.Position = UDim2.new(0, 44, -1, 57)
    mini2.Visible = false

    -- Глушение звуков воды
    local function muteWaterSounds(char)
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Sound") and (obj.Name == "Swimming" or obj.Name == "Splash") then
                obj.Volume = 0
                obj:Stop()
            end
        end
    end

    local function disableFlyFlight()
        nowe = false
        tpwalking = false
        upPressed = false
        downPressed = false
        local chr = LocalPlayer.Character
        if chr then
            local hum = chr:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                hum.PlatformStand = false
            end
            local anim = chr:FindFirstChild("Animate")
            if anim then
                anim.Disabled = false
            end
        end
    end

    -- Горизонтальный tpwalk (скорость 1 уменьшена ровно в 4 раза: speeds * 0.25)
    local function startTpWalk()
        tpwalking = true
        task.spawn(function()
            local hb = RunService.Heartbeat
            while tpwalking and nowe do
                hb:Wait()
                local chr = LocalPlayer.Character
                local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                if chr and hum and hum.Parent and hum.MoveDirection.Magnitude > 0 then
                    chr:TranslateBy(hum.MoveDirection * (speeds * 0.25))
                end
            end
        end)
    end

    onof.MouseButton1Down:Connect(function()
        if nowe == true then
            disableFlyFlight()
        else
            nowe = true
            startTpWalk()

            local chr = LocalPlayer.Character
            if not chr then return end

            muteWaterSounds(chr)
            
            local anim = chr:FindFirstChild("Animate")
            if anim then
                anim.Disabled = true
            end

            local hum = chr:FindFirstChildOfClass("Humanoid") or chr:FindFirstChildOfClass("AnimationController")
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0)
                end
                hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end

            local humanoid = chr:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
                local torso = chr:FindFirstChild("Torso")
                if not torso then return end

                local bg = Instance.new("BodyGyro", torso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.CFrame = torso.CFrame

                local bv = Instance.new("BodyVelocity", torso)
                bv.Velocity = Vector3.new(0, 0.1, 0)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

                humanoid.PlatformStand = true

                task.spawn(function()
                    while nowe and chr and humanoid and humanoid.Health > 0 and torso.Parent do
                        RunService.RenderStepped:Wait()
                        muteWaterSounds(chr)

                        local camera = workspace.CurrentCamera
                        if not camera then break end

                        -- Динамический расчёт вертикальной скорости без сопротивления BodyVelocity
                        local vVelocityY = 0
                        local vertOffset = 0
                        if upPressed then
                            vVelocityY = math.max(speeds * 18, 30)
                            vertOffset = math.max(speeds * 0.4, 0.7)
                        elseif downPressed then
                            vVelocityY = -math.max(speeds * 18, 30)
                            vertOffset = -math.max(speeds * 0.4, 0.7)
                        else
                            vVelocityY = 0.1
                        end

                        bv.Velocity = Vector3.new(0, vVelocityY, 0)

                        local hrp = chr:FindFirstChild("HumanoidRootPart") or torso
                        if vertOffset ~= 0 and hrp then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, vertOffset, 0)
                        end

                        bg.CFrame = camera.CFrame
                    end

                    pcall(function() bg:Destroy() end)
                    pcall(function() bv:Destroy() end)
                    if humanoid then humanoid.PlatformStand = false end
                    if chr:FindFirstChild("Animate") then chr.Animate.Disabled = false end
                    tpwalking = false
                end)
            else
                local upperTorso = chr:FindFirstChild("UpperTorso") or chr:FindFirstChild("HumanoidRootPart")
                if not upperTorso then return end

                local bg = Instance.new("BodyGyro", upperTorso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.CFrame = upperTorso.CFrame

                local bv = Instance.new("BodyVelocity", upperTorso)
                bv.Velocity = Vector3.new(0, 0.1, 0)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

                if humanoid then humanoid.PlatformStand = true end

                task.spawn(function()
                    while nowe and chr and humanoid and humanoid.Health > 0 and upperTorso.Parent do
                        task.wait()
                        muteWaterSounds(chr)

                        local camera = workspace.CurrentCamera
                        if not camera then break end

                        local vVelocityY = 0
                        local vertOffset = 0
                        if upPressed then
                            vVelocityY = math.max(speeds * 18, 30)
                            vertOffset = math.max(speeds * 0.4, 0.7)
                        elseif downPressed then
                            vVelocityY = -math.max(speeds * 18, 30)
                            vertOffset = -math.max(speeds * 0.4, 0.7)
                        else
                            vVelocityY = 0.1
                        end

                        bv.Velocity = Vector3.new(0, vVelocityY, 0)

                        local hrp = chr:FindFirstChild("HumanoidRootPart") or upperTorso
                        if vertOffset ~= 0 and hrp then
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, vertOffset, 0)
                        end

                        bg.CFrame = camera.CFrame
                    end

                    pcall(function() bg:Destroy() end)
                    pcall(function() bv:Destroy() end)
                    if humanoid then humanoid.PlatformStand = false end
                    if chr:FindFirstChild("Animate") then chr.Animate.Disabled = false end
                    tpwalking = false
                end)
            end
        end
    end)

    -- Корректная обработка удержания и кликов для кнопок UP / DOWN
    up.MouseButton1Down:Connect(function()
        upPressed = true
    end)
    up.MouseButton1Up:Connect(function()
        upPressed = false
    end)
    up.MouseLeave:Connect(function()
        upPressed = false
    end)

    down.MouseButton1Down:Connect(function()
        downPressed = true
    end)
    down.MouseButton1Up:Connect(function()
        downPressed = false
    end)
    down.MouseLeave:Connect(function()
        downPressed = false
    end)

    -- Поддержка клавиатуры для взлёта и спуска (Space / E — вверх, Shift / Ctrl / Q — вниз)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not nowe then return end
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            upPressed = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
            downPressed = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            upPressed = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
            downPressed = false
        end
    end)

    plus.MouseButton1Down:Connect(function()
        speeds = speeds + 1
        speed.Text = tostring(speeds)
    end)

    mine.MouseButton1Down:Connect(function()
        if speeds <= 1 then
            speed.Text = "cannot be less than 1"
            task.wait(1)
            speed.Text = tostring(speeds)
        else
            speeds = speeds - 1
            speed.Text = tostring(speeds)
        end
    end)

    mini.MouseButton1Click:Connect(function()
        up.Visible = false
        down.Visible = false
        onof.Visible = false
        plus.Visible = false
        speed.Visible = false
        mine.Visible = false
        mini.Visible = false
        mini2.Visible = true
        Frame.BackgroundTransparency = 1
        closebutton.Position = UDim2.new(0, 0, -1, 57)
    end)

    mini2.MouseButton1Click:Connect(function()
        up.Visible = true
        down.Visible = true
        onof.Visible = true
        plus.Visible = true
        speed.Visible = true
        mine.Visible = true
        mini.Visible = true
        mini2.Visible = false
        Frame.BackgroundTransparency = 0
        closebutton.Position = UDim2.new(0, 0, -1, 27)
    end)

    local FlyGuiToggleRef = nil

    closebutton.MouseButton1Click:Connect(function()
        main.Enabled = false
        disableFlyFlight()
        if FlyGuiToggleRef and type(FlyGuiToggleRef.Set) == "function" then
            FlyGuiToggleRef:Set(false)
        end
    end)

    -- Очистка физических объектов спинбота
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

    -- Создание вкладки в Rayfield UI
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    -- ==========================================
    -- РАЗДЕЛ: ХАРАКТЕРИСТИКИ
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
            if Humanoid and not MM2BypassEnabled then 
                Humanoid.WalkSpeed = Value 
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
    -- РАЗДЕЛ: ПЕРЕМЕЩЕНИЕ И СТЕНЫ
    -- ==========================================
    PlayerTab:CreateSection("Перемещение и Стены")

    FlyGuiToggleRef = PlayerTab:CreateToggle({
        Name = "Fly GUI V3 (Экранная панель полета)",
        CurrentValue = false,
        Flag = "FlyGuiV3Toggle",
        Callback = function(Value)
            main.Enabled = Value
            if Value then
                if not FlyGuiNotified then
                    FlyGuiNotified = true
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "FLY GUI V3",
                            Text = "BY XNEO",
                            Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150",
                            Duration = 5
                        })
                    end)
                end
            else
                disableFlyFlight()
            end
        end
    })

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
    -- РАЗДЕЛ: ЗАЩИТА
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
    -- РАЗДЕЛ: ФАН УТИЛИТЫ (СПИНБОТ)
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
        Options = {"Классический", "Физический (Плавный)", "Jitter", "Безумный", "Дерганье 6 оси", "Дерганье 3 оси"},
        CurrentOption = "Классический",
        Flag = "SpinModeDropdown",
        Callback = function(Option)
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
    -- ОСНОВНОЙ ПОТОК ОБРАБОТКИ (КАЖДЫЙ КАДР)
    -- ==========================================
    RunService.Stepped:Connect(function()
        local MyCharacter = LocalPlayer.Character
        if not MyCharacter then return end

        local MyHRP = MyCharacter:FindFirstChild("HumanoidRootPart")
        local MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")

        if MyHumanoid then
            if not MM2BypassEnabled then
                MyHumanoid.WalkSpeed = SavedWalkSpeed
            end
            MyHumanoid.UseJumpPower = true
            MyHumanoid.JumpPower = SavedJumpPower
        end

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

        if SpinBotActive and MyHRP and MyHumanoid then
            if CurrentSpinMode == "Безумный" then
                if not MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = true end
            else
                if not nowe and MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = false end
            end

            if MyHumanoid.AutoRotate then MyHumanoid.AutoRotate = false end

            if CurrentSpinMode == "Классический" then
                stopPhysicsSpin()
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                
            elseif CurrentSpinMode == "Безумный" then
                stopPhysicsSpin()
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(math.rad(SpinSpeed), math.rad(SpinSpeed), math.rad(SpinSpeed))
                
            elseif CurrentSpinMode == "Jitter" then
                stopPhysicsSpin()
                local jitter = math.rad(math.random(-180, 180))
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, jitter, 0)
                
            elseif CurrentSpinMode == "Дерганье 6 оси" then
                stopPhysicsSpin()
                local randomAngle = TwitchAngles[math.random(1, #TwitchAngles)]
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, math.rad(randomAngle), 0)

            elseif CurrentSpinMode == "Дерганье 3 оси" then
                stopPhysicsSpin()
                local randomAngle = TwitchAngles2[math.random(1, #TwitchAngles2)]
                MyHRP.CFrame = MyHRP.CFrame * CFrame.Angles(0, math.rad(randomAngle), 0)
                
            elseif CurrentSpinMode == "Физический (Плавный)" then
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
            stopPhysicsSpin()
            if MyHumanoid then
                if not MyHumanoid.AutoRotate then MyHumanoid.AutoRotate = true end
                if not nowe and MyHumanoid.PlatformStand then MyHumanoid.PlatformStand = false end
            end
        end
    end)

    -- Бесконечный прыжок (JumpRequest)
    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Восстановление параметров после респавна
    LocalPlayer.CharacterAdded:Connect(function(Character)
        stopPhysicsSpin()
        disableFlyFlight()
        
        local Humanoid = Character:WaitForChild("Humanoid", 3)
        if Humanoid then
            task.wait(0.1)
            Humanoid.PlatformStand = false
            local anim = Character:FindFirstChild("Animate")
            if anim then
                anim.Disabled = false
            end

            if MM2BypassEnabled and SavedWalkSpeed > 30 then
                Humanoid.WalkSpeed = 30
            else
                Humanoid.WalkSpeed = SavedWalkSpeed
            end
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = SavedJumpPower
        end
    end)

    -- Поток обхода скорости MM2
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
end
