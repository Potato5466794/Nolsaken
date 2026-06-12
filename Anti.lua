local GameEnhancementLib = {}

-- ==================== EffectRemover ====================
do
    local Services = {
        Players = game:GetService("Players"),
        Lighting = game:GetService("Lighting")
    }

    local EffectState = { Enabled = false }
    local LoopConnection = nil

    local effectNames = {
        "BlurEffect", "ColorCorrectionEffect", "BloomEffect", "SunRaysEffect",
        "DepthOfFieldEffect", "ScreenFlash", "HitEffect", "DamageOverlay",
        "BloodEffect", "Vignette", "BlackScreen", "WhiteScreen", "ShockEffect",
        "Darkness", "JumpScare", "LowHealthOverlay", "Flashbang", "FadeEffect"
    }

    local effectClasses = {
        "BlurEffect", "BloomEffect", "SunRaysEffect",
        "DepthOfFieldEffect", "ColorCorrectionEffect"
    }

    local function removeEffects()
        local Lighting = Services.Lighting
        local PlayerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
        
        for _, obj in pairs(Lighting:GetDescendants()) do
            if table.find(effectNames, obj.Name) or table.find(effectClasses, obj.ClassName) then
                pcall(function() obj:Destroy() end)
            end
        end
        
        if PlayerGui then
            for _, obj in pairs(PlayerGui:GetDescendants()) do
                if table.find(effectNames, obj.Name) then
                    pcall(function() obj:Destroy() end)
                elseif obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                    if obj:FindFirstChildWhichIsA("ImageLabel") or obj:FindFirstChildWhichIsA("Frame") then
                        if table.find(effectNames, obj.Name) or obj.Name:lower():find("overlay") or obj.Name:lower():find("effect") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end
    end

    local function startEffectLoop()
        if LoopConnection then task.cancel(LoopConnection) end
        LoopConnection = task.spawn(function()
            while EffectState.Enabled do
                removeEffects()
                task.wait(5)
            end
        end)
    end

    local function stopEffectLoop()
        if LoopConnection then
            task.cancel(LoopConnection)
            LoopConnection = nil
        end
    end

    function GameEnhancementLib.SetEffectRemover(state)
        EffectState.Enabled = state
        if state then
            removeEffects()
            startEffectLoop()
        else
            stopEffectLoop()
        end
    end

    function GameEnhancementLib.IsEffectRemoverEnabled()
        return EffectState.Enabled
    end

    function GameEnhancementLib.RemoveEffectsOnce()
        removeEffects()
    end
end

-- ==================== AntiSlow ====================
do
    local Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        Workspace = game:GetService("Workspace")
    }

    local Survivors = Services.Workspace:WaitForChild("Players"):WaitForChild("Survivors")

    local AntiSlowState = { Enabled = false }
    local AntiStunState = { Enabled = false }

    local AntiSlowConfigs = {
        Slowness = {Values = {"SlowedStatus"}, Connection = nil},
        Skills = {Values = {"StunningKiller", "EatFriedChicken", "GuestBlocking", "PunchAbility", "SubspaceTripmine",
                            "TaphTripwire", "PlasmaBeam", "SpawnProtection", "c00lgui", "ShootingGun",
                            "TwoTimeStab", "TwoTimeCrouching", "DrinkingCola", "DrinkingSlateskin",
                            "SlateskinStatus", "EatingGhostburger"}, Connection = nil},
        Items = {Values = {"BloxyColaItem", "Medkit"}, Connection = nil},
        Emotes = {Values = {"Emoting"}, Connection = nil},
        Builderman = {Values = {"DispenserConstruction", "SentryConstruction"}, Connection = nil}
    }

    local AntiStunLoop = nil

    local function hideSlownessUI()
        local mainUI = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        if mainUI then
            local statusContainer = mainUI:FindFirstChild("StatusContainer")
            if statusContainer then
                local slownessUI = statusContainer:FindFirstChild("Slowness")
                if slownessUI then
                    slownessUI.Visible = false
                end
            end
        end
    end

    local function handleAntiSlow(survivor, config)
        if survivor:GetAttribute("Username") ~= Services.Players.LocalPlayer.Name then return end
        
        local function onRenderStep()
            if not survivor.Parent or not AntiSlowState.Enabled then return end
            local speedMultipliers = survivor:FindFirstChild("SpeedMultipliers")
            if speedMultipliers then
                for _, valName in ipairs(config.Values) do
                    local val = speedMultipliers:FindFirstChild(valName)
                    if val and val:IsA("NumberValue") and val.Value ~= 1 then
                        val.Value = 1
                    end
                end
            end
            hideSlownessUI()
        end
        
        if config.Connection then config.Connection:Disconnect() end
        config.Connection = Services.RunService.RenderStepped:Connect(onRenderStep)
    end

    local function startAntiSlow()
        AntiSlowState.Enabled = true
        for _, config in pairs(AntiSlowConfigs) do
            for _, survivor in pairs(Survivors:GetChildren()) do
                handleAntiSlow(survivor, config)
            end
        end
    end

    local function stopAntiSlow()
        AntiSlowState.Enabled = false
        for _, config in pairs(AntiSlowConfigs) do
            if config.Connection then
                config.Connection:Disconnect()
                config.Connection = nil
            end
        end
    end

    local function startAntiStun()
        AntiStunState.Enabled = true
        if AntiStunLoop then task.cancel(AntiStunLoop) end
        AntiStunLoop = task.spawn(function()
            while AntiStunState.Enabled do
                local char = Services.Players.LocalPlayer.Character
                if char then
                    local speedMultipliers = char:FindFirstChild("SpeedMultipliers")
                    if speedMultipliers then
                        local stunned = speedMultipliers:FindFirstChild("Stunned")
                        if stunned then stunned.Value = 1 end
                    end
                end
                task.wait()
            end
        end)
    end

    local function stopAntiStun()
        AntiStunState.Enabled = false
        if AntiStunLoop then
            task.cancel(AntiStunLoop)
            AntiStunLoop = nil
        end
    end

    function GameEnhancementLib.SetAntiSlow(state)
        if state then startAntiSlow() else stopAntiSlow() end
    end

    function GameEnhancementLib.SetAntiStun(state)
        if state then startAntiStun() else stopAntiStun() end
    end

    function GameEnhancementLib.IsAntiSlowEnabled()
        return AntiSlowState.Enabled
    end

    function GameEnhancementLib.IsAntiStunEnabled()
        return AntiStunState.Enabled
    end

    Survivors.ChildAdded:Connect(function(child)
        if AntiSlowState.Enabled then
            task.wait(0.1)
            for _, config in pairs(AntiSlowConfigs) do
                handleAntiSlow(child, config)
            end
        end
    end)
end

-- ==================== Cleanup ====================
function GameEnhancementLib.Cleanup()
    GameEnhancementLib.SetEffectRemover(false)
    GameEnhancementLib.SetAntiSlow(false)
    GameEnhancementLib.SetAntiStun(false)
end

return GameEnhancementLib
