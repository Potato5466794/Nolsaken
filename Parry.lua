local AutoParryLib = {}
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace")
}

local lp = Services.Players.LocalPlayer

local State = {
    Enabled = false,
    TestMode = false,
    ParryMode = "Slasher",
    WallCheck = true,
    Visualization = false,
    DetectionRange = 20,
    VerificationDelay = 0.02,
    FacingAngle = 70,
    BackAngle = 120,
    LineLength = 10,
    LineColor = Color3.fromRGB(255, 0, 0),
    TwoTimeLineColor = Color3.fromRGB(255, 165, 0)
}

local ShedletskySounds = {
    [12222208] = true, [10548112] = true, [127324570265084] = true,
    [105937652127383] = true, [102923788301986] = true, [116618003477002] = true
}

local GuestSounds = {
    [81976396729343] = true, [92831180929659] = true, [126620220725231] = true,
    [5989939664] = true, [8595983255] = true, [8595977193] = true,
    [100918679787313] = true, [609342351] = true, [121717335514560] = true,
    [107228895075799] = true
}

local ChanceSounds = { ["0"] = true }

local TwoTimeSounds = {
    [144352131] = true, [83419374143723] = true, [81859713902429] = true,
    [86710781315432] = true, [99820161736138] = true
}

local ShedletskyAnims = {
    [116618003477002] = true, [122503338277352] = true, [131696603025265] = true,
    [119462383658044] = true, [98031287364865] = true, [121255898612475] = true,
    [110400453990786] = true, [92004263738493] = true, [105614318732282] = true,
    [103741352379819] = true, [77448521277146] = true
}

local GuestAnims = {
    [87259391926321] = true, [119850211147676] = true, [135018792929847] = true,
    [107757776267592] = true, [108911997126897] = true, [82137285150006] = true,
    [86709774283672] = true, [138040001965654] = true, [108807732150251] = true,
    [86096387000557] = true, [73908019523515] = true, [136007065400978] = true,
    [129843313690921] = true, [90604236361267] = true, [140703210927645] = true,
    [111270184603402] = true, [81905101227053] = true
}

local ChanceAnims = {
    [90499469533503] = true, [101771617803133] = true, [79350075778160] = true,
    [134958187822107] = true, [111313169447787] = true, [71685573690338] = true,
    [73921036900313] = true, [77124578197357] = true, [127128388164133] = true
}

local TwoTimeAnims = {
    [100725497418533] = true, [106086955212611] = true
}

local soundHooks = {}
local animatorHooks = {}
local attackCooldowns = {}
local parryCooldown = false
local visualizationParts = {}
local visualizationFolder = nil
local cachedRemote = nil

local bufferMap = {
    ["Block"] = "\003\005\000\000\000Block",
    ["Punch"] = "\003\005\000\000\000Punch",
    ["Clone"] = "\003\005\000\000\000Clone",
    ["RagingPace"] = "\003\n\000\000\000RagingPace",
    ["404Error"] = "\003\b\000\000\000404Error",
    ["CorruptEnergy"] = "\003\r\000\000\000CorruptEnergy",
    ["DigitalFootprint"] = "\003\016\000\000\000DigitalFootprint",
    ["Crouch"] = "\003\006\000\000\000Crouch",
    ["Ghostburger"] = "\003\v\000\000\000Ghostburger",
    ["Slash"] = "\003\005\000\000\000Slash",
    ["FriedChicken"] = "\003\f\000\000\000FriedChicken",
    ["CoinFlip"] = "\003\b\000\000\000CoinFlip",
    ["Dagger"] = "\003\006\000\000\000Dagger",
    ["Carving Slash"] = "\003\r\000\000\000Carving Slash",
    ["Stab"] = "\003\004\000\000\000Stab",
    ["GashingWound"] = "\003\f\000\000\000GashingWound"
}

local function getRemote()
    if cachedRemote then return cachedRemote end
    local modules = Services.ReplicatedStorage:FindFirstChild("Modules")
    local network = modules and modules:FindFirstChild("Network")
    local network2 = network and network:FindFirstChild("Network")
    cachedRemote = network2 and network2:FindFirstChild("RemoteEvent")
    return cachedRemote
end

local function getDetectionRangeSq()
    return State.DetectionRange * State.DetectionRange
end

local function getFacingAngleCos()
    return math.cos(math.rad(State.FacingAngle / 2))
end

local function getBackAngleCos()
    return math.cos(math.rad((180 - State.BackAngle) / 2))
end

local function extractNumericId(str)
    if not str then return nil end
    local numStr = tostring(str):match("%d+")
    return numStr and tonumber(numStr)
end

local function getSoundCategory(id)
    if not id then return nil end
    local numId = tonumber(id)
    if not numId then return nil end
    if ShedletskySounds[numId] then return "Shedletsky" end
    if GuestSounds[numId] then return "Guest" end
    if ChanceSounds[numId] then return "Chance" end
    if TwoTimeSounds[numId] then return "TwoTime" end
    return nil
end

local function getAnimCategory(id)
    if not id then return nil end
    local numId = tonumber(id)
    if not numId then return nil end
    if ShedletskyAnims[numId] then return "Shedletsky" end
    if GuestAnims[numId] then return "Guest" end
    if ChanceAnims[numId] then return "Chance" end
    if TwoTimeAnims[numId] then return "TwoTime" end
    return nil
end

local function getCharacterFromDescendant(inst)
    if not inst then return nil end
    local current = inst.Parent
    while current do
        if current:FindFirstChildOfClass("Humanoid") then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function hasLineOfSight(fromPos, toPos, ignoreList)
    local direction = toPos - fromPos
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    local result = Services.Workspace:Raycast(fromPos, direction, raycastParams)
    return result == nil
end

local function isFacingMe(enemyRoot, myRoot)
    local dir = (myRoot.Position - enemyRoot.Position).Unit
    local dot = enemyRoot.CFrame.LookVector:Dot(dir)
    return dot > getFacingAngleCos()
end

local function isFacingMyBack(enemyRoot, myRoot)
    local dirToMe = (myRoot.Position - enemyRoot.Position).Unit
    local enemyDot = enemyRoot.CFrame.LookVector:Dot(dirToMe)
    local dirToEnemy = (enemyRoot.Position - myRoot.Position).Unit
    local myBackDot = (-myRoot.CFrame.LookVector):Dot(dirToEnemy)
    return enemyDot > getFacingAngleCos() and myBackDot > getBackAngleCos()
end

local function fireRemoteAbility(abilityName)
    if parryCooldown then return false end
    parryCooldown = true
    local remote = getRemote()
    if remote then
        local bufferStr = bufferMap[abilityName] or ("\003\005\000\000\000" .. abilityName)
        remote:FireServer("UseActorAbility", {buffer.fromstring(bufferStr)})
    end
    task.delay(0.15, function()
        parryCooldown = false
    end)
    return true
end

local function tryParry()
    if State.ParryMode == "John Doe" then
        return fireRemoteAbility("404Error")
    else
        return fireRemoteAbility("RagingPace")
    end
end

local function checkAndParry(enemyHRP, myRoot, category)
    if category == "TwoTime" then
        if isFacingMyBack(enemyHRP, myRoot) then
            return tryParry()
        end
    else
        if isFacingMe(enemyHRP, myRoot) then
            return tryParry()
        end
    end
    return false
end

local function processAttack(char, category)
    if not State.Enabled then return end
    if parryCooldown then return end

    local cooldownKey = tostring(char) .. category
    local now = tick()
    if attackCooldowns[cooldownKey] and now < attackCooldowns[cooldownKey] then return end
    attackCooldowns[cooldownKey] = now + 0.1

    local plr = Services.Players:GetPlayerFromCharacter(char)
    if not State.TestMode and plr and plr == lp then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myChar = lp.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local dvec = hrp.Position - myRoot.Position
    if dvec:Dot(dvec) > getDetectionRangeSq() then return end

    if State.WallCheck then
        if not hasLineOfSight(myRoot.Position, hrp.Position, {myChar, char}) then
            return
        end
    end

    if checkAndParry(hrp, myRoot, category) then
        return
    end

    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < State.VerificationDelay do
            if parryCooldown then return end
            if not State.Enabled then return end

            local currentHRP = char:FindFirstChild("HumanoidRootPart")
            local currentMyChar = lp.Character
            local currentMyRoot = currentMyChar and currentMyChar:FindFirstChild("HumanoidRootPart")
            if not currentHRP or not currentMyRoot then return end

            if State.WallCheck then
                if not hasLineOfSight(currentMyRoot.Position, currentHRP.Position, {currentMyChar, char}) then
                    return
                end
            end

            if checkAndParry(currentHRP, currentMyRoot, category) then
                return
            end

            Services.RunService.RenderStepped:Wait()
        end
    end)
end

local function processSound(sound)
    if not State.Enabled then return end
    if not sound or not sound:IsA("Sound") then return end

    local id = extractNumericId(sound.SoundId)
    if not id then return end

    local category = getSoundCategory(id)
    if not category then return end

    local char = getCharacterFromDescendant(sound)
    if not char then return end

    processAttack(char, category)
end

local function hookSound(sound)
    if not sound:IsA("Sound") then return end
    if soundHooks[sound] then return end

    local conn1 = sound.Played:Connect(function()
        processSound(sound)
    end)

    local conn2 = sound:GetPropertyChangedSignal("Playing"):Connect(function()
        if sound.Playing then
            processSound(sound)
        end
    end)

    local conn3 = sound.Destroying:Connect(function()
        conn1:Disconnect()
        conn2:Disconnect()
        conn3:Disconnect()
        soundHooks[sound] = nil
    end)

    soundHooks[sound] = {conn1, conn2, conn3}

    if sound.Playing then
        processSound(sound)
    end
end

local function processAnimationTrack(animTrack, char)
    if not State.Enabled then return end
    if not animTrack or not animTrack.Animation then return end

    local id = extractNumericId(animTrack.Animation.AnimationId)
    if not id then return end

    local category = getAnimCategory(id)
    if not category then return end

    processAttack(char, category)
end

local function hookAnimator(animator, char)
    if not animator:IsA("Animator") then return end
    if animatorHooks[animator] then return end

    local conn1 = animator.AnimationPlayed:Connect(function(animTrack)
        processAnimationTrack(animTrack, char)
    end)

    local conn2 = animator.Destroying:Connect(function()
        conn1:Disconnect()
        conn2:Disconnect()
        animatorHooks[animator] = nil
    end)

    animatorHooks[animator] = {conn1, conn2}
end

local function hookCharacter(char)
    if not char then return end

    for _, desc in char:GetDescendants() do
        if desc:IsA("Sound") then
            task.spawn(hookSound, desc)
        elseif desc:IsA("Animator") then
            task.spawn(hookAnimator, desc, char)
        end
    end

    char.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            hookSound(desc)
        elseif desc:IsA("Animator") then
            hookAnimator(desc, char)
        end
    end)
end

local function onPlayerAdded(player)
    if player.Character then
        hookCharacter(player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        hookCharacter(char)
    end)
end

local function angleToDirection(lookVector, rightVector, angleDegrees)
    local angleRad = math.rad(angleDegrees)
    local cosA = math.cos(angleRad)
    local sinA = math.sin(angleRad)
    return (lookVector * cosA + rightVector * sinA).Unit
end

local function ensureVisualizationFolder()
    if not visualizationFolder or not visualizationFolder.Parent then
        visualizationFolder = Instance.new("Folder")
        visualizationFolder.Name = "AutoParryVisualization"
        visualizationFolder.Parent = Services.Workspace
    end
    return visualizationFolder
end

local function createLinePart()
    local part = Instance.new("Part")
    part.Name = "FacingLine"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Material = Enum.Material.Neon
    part.Size = Vector3.new(0.1, 0.1, State.LineLength)
    part.Transparency = 0.3
    part.Parent = ensureVisualizationFolder()
    return part
end

local function updateVisualization()
    if not State.Visualization or not State.Enabled then
        for _, data in pairs(visualizationParts) do
            if data.line1 then data.line1.Transparency = 1 end
            if data.line2 then data.line2.Transparency = 1 end
            if data.backLine1 then data.backLine1.Transparency = 1 end
            if data.backLine2 then data.backLine2.Transparency = 1 end
        end
        return
    end

    local myChar = lp.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local processedPlayers = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= lp or State.TestMode then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local dvec = hrp.Position - myRoot.Position
            local inRange = dvec:Dot(dvec) <= getDetectionRangeSq()

            if not visualizationParts[player] then
                visualizationParts[player] = {
                    line1 = createLinePart(),
                    line2 = createLinePart(),
                    backLine1 = createLinePart(),
                    backLine2 = createLinePart()
                }
            end

            local data = visualizationParts[player]
            processedPlayers[player] = true

            if inRange then
                local pos = hrp.Position
                local look = hrp.CFrame.LookVector
                local right = hrp.CFrame.RightVector
                local halfAngle = State.FacingAngle / 2
                local lineLen = State.LineLength

                local dir1 = angleToDirection(look, right, -halfAngle)
                local dir2 = angleToDirection(look, right, halfAngle)
                local endPos1 = pos + dir1 * lineLen
                local endPos2 = pos + dir2 * lineLen

                data.line1.Size = Vector3.new(0.1, 0.1, lineLen)
                data.line1.CFrame = CFrame.new((pos + endPos1) / 2, endPos1)
                data.line1.Color = State.LineColor
                data.line1.Transparency = 0.3

                data.line2.Size = Vector3.new(0.1, 0.1, lineLen)
                data.line2.CFrame = CFrame.new((pos + endPos2) / 2, endPos2)
                data.line2.Color = State.LineColor
                data.line2.Transparency = 0.3

                local myPos = myRoot.Position
                local myLook = myRoot.CFrame.LookVector
                local myRight = myRoot.CFrame.RightVector
                local backLook = -myLook
                local backHalfAngle = (180 - State.BackAngle) / 2
                local backDir1 = angleToDirection(backLook, myRight, -backHalfAngle)
                local backDir2 = angleToDirection(backLook, myRight, backHalfAngle)
                local backEndPos1 = myPos + backDir1 * lineLen
                local backEndPos2 = myPos + backDir2 * lineLen

                data.backLine1.Size = Vector3.new(0.1, 0.1, lineLen)
                data.backLine1.CFrame = CFrame.new((myPos + backEndPos1) / 2, backEndPos1)
                data.backLine1.Color = State.TwoTimeLineColor
                data.backLine1.Transparency = 0.3

                data.backLine2.Size = Vector3.new(0.1, 0.1, lineLen)
                data.backLine2.CFrame = CFrame.new((myPos + backEndPos2) / 2, backEndPos2)
                data.backLine2.Color = State.TwoTimeLineColor
                data.backLine2.Transparency = 0.3
            else
                data.line1.Transparency = 1
                data.line2.Transparency = 1
                data.backLine1.Transparency = 1
                data.backLine2.Transparency = 1
            end
        end
    end

    for player, data in pairs(visualizationParts) do
        if not processedPlayers[player] then
            if data.line1 then data.line1:Destroy() end
            if data.line2 then data.line2:Destroy() end
            if data.backLine1 then data.backLine1:Destroy() end
            if data.backLine2 then data.backLine2:Destroy() end
            visualizationParts[player] = nil
        end
    end
end

function AutoParryLib.SetEnabled(state)
    State.Enabled = state
end

function AutoParryLib.IsEnabled()
    return State.Enabled
end

function AutoParryLib.SetParryMode(mode)
    State.ParryMode = mode
end

function AutoParryLib.GetParryMode()
    return State.ParryMode
end

function AutoParryLib.SetWallCheck(state)
    State.WallCheck = state
end

function AutoParryLib.SetVisualization(state)
    State.Visualization = state
end

function AutoParryLib.SetDetectionRange(range)
    State.DetectionRange = math.max(1, range)
end

function AutoParryLib.GetDetectionRange()
    return State.DetectionRange
end

function AutoParryLib.SetVerificationDelay(delay)
    State.VerificationDelay = math.max(0, delay)
end

function AutoParryLib.SetFacingAngle(angle)
    State.FacingAngle = math.clamp(angle, 1, 180)
end

function AutoParryLib.SetBackAngle(angle)
    State.BackAngle = math.clamp(angle, 1, 180)
end

function AutoParryLib.SetLineLength(length)
    State.LineLength = math.max(1, length)
    for _, data in pairs(visualizationParts) do
        if data.line1 then data.line1.Size = Vector3.new(0.1, 0.1, State.LineLength) end
        if data.line2 then data.line2.Size = Vector3.new(0.1, 0.1, State.LineLength) end
        if data.backLine1 then data.backLine1.Size = Vector3.new(0.1, 0.1, State.LineLength) end
        if data.backLine2 then data.backLine2.Size = Vector3.new(0.1, 0.1, State.LineLength) end
    end
end

function AutoParryLib.SetLineColor(color)
    State.LineColor = color
end

function AutoParryLib.SetTwoTimeLineColor(color)
    State.TwoTimeLineColor = color
end

function AutoParryLib.SetTestMode(state)
    State.TestMode = state
end

function AutoParryLib.GetState()
    return State
end

function AutoParryLib.Start()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
    Services.Players.PlayerAdded:Connect(onPlayerAdded)

    for _, desc in ipairs(Services.Workspace:GetDescendants()) do
        if desc:IsA("Sound") then
            task.spawn(hookSound, desc)
        end
    end
    Services.Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            hookSound(desc)
        end
    end)

    Services.RunService.RenderStepped:Connect(updateVisualization)
end

function AutoParryLib.Cleanup()
    for sound, conns in pairs(soundHooks) do
        for _, conn in ipairs(conns) do
            pcall(function() conn:Disconnect() end)
        end
    end
    for animator, conns in pairs(animatorHooks) do
        for _, conn in ipairs(conns) do
            pcall(function() conn:Disconnect() end)
        end
    end
    soundHooks = {}
    animatorHooks = {}
    attackCooldowns = {}

    for _, data in pairs(visualizationParts) do
        if data.line1 then data.line1:Destroy() end
        if data.line2 then data.line2:Destroy() end
        if data.backLine1 then data.backLine1:Destroy() end
        if data.backLine2 then data.backLine2:Destroy() end
    end
    visualizationParts = {}

    if visualizationFolder then
        visualizationFolder:Destroy()
        visualizationFolder = nil
    end

    cachedRemote = nil
    parryCooldown = false
end

return AutoParryLib
