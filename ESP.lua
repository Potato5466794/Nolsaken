local EspLib = {}

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local RunService = Services.RunService
local MapFolder = Services.Workspace:WaitForChild("Map"):WaitForChild("Ingame")

local Floor = math.floor
local Round = math.round
local Sin = math.sin
local Cos = math.cos
local Clear = table.clear
local Unpack = table.unpack
local Find = table.find
local Create = table.create
local FromMatrix = CFrame.fromMatrix
local WTVP = Camera.WorldToViewportPoint
local IsA = Services.Workspace.IsA
local GetPivot = Services.Workspace.GetPivot
local GetChildren = Services.Workspace.GetChildren
local LerpColor = Color3.new().Lerp
local Min2 = Vector2.zero.Min
local Max2 = Vector2.zero.Max
local Lerp2 = Vector2.zero.Lerp
local Min3 = Vector3.zero.Min
local Max3 = Vector3.zero.Max

local VERTICES = {
    Vector3.new(-1, -1, -1), Vector3.new(-1, 1, -1), Vector3.new(-1, 1, 1), Vector3.new(-1, -1, 1),
    Vector3.new(1, -1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(1, -1, 1),
}

local ESPSettings = {
    killerESP = false,
    playerESP = false,
    generatorESP = false,
    itemESP = false,
    pizzaEsp = false,
    pizzaDeliveryEsp = false,
    zombieEsp = false,
    taphTripwireEsp = false,
    tripMineEsp = false,
    twoTimeRespawnEsp = false,
    graffitiEsp = false,
    foldersEsp = false,
    killerSkinESP = false,
    survivorSkinESP = false,
    killerNameESP = false,
    killerHealthESP = false,
    survivorNameESP = false,
    survivorHealthESP = false,
    killerFillTransparency = 0.7,
    killerOutlineTransparency = 0.3,
    survivorFillTransparency = 0.7,
    survivorOutlineTransparency = 0.3,
    killerColor = Color3.fromRGB(180, 40, 40),
    survivorColor = Color3.fromRGB(0, 255, 255),
    generatorColor = Color3.fromRGB(200, 100, 200),
    itemColor = Color3.fromRGB(200, 200, 0),
    pizzaColor = Color3.fromRGB(200, 150, 0),
    pizzaDeliveryColor = Color3.fromRGB(200, 100, 100),
    zombieColor = Color3.fromRGB(200, 100, 100),
    taphTripwireColor = Color3.fromRGB(100, 0, 100),
    tripMineColor = Color3.fromRGB(255, 0, 255),
    twoTimeRespawnColor = Color3.fromRGB(0, 150, 200),
    graffitiColor = Color3.fromRGB(255, 255, 255),
    foldersColor = Color3.fromRGB(255, 204, 51),
    showGeneratorName = true,
    showItemName = true,
    showPizzaName = true,
    showPizzaDeliveryName = true,
    showZombieName = true,
    showTaphTripwireName = true,
    showTripMineName = true,
    showTwoTimeRespawnName = true,
    showGraffitiName = true,
    showFoldersName = true,
    -- 2D Box Settings
    killerBox = false,
    survivorBox = false,
    killerBoxColor = {Color3.fromRGB(180, 40, 40), 1},
    survivorBoxColor = {Color3.fromRGB(0, 255, 255), 1},
    killerBoxOutline = true,
    survivorBoxOutline = true,
    killerBoxOutlineColor = {Color3.new(), 1},
    survivorBoxOutlineColor = {Color3.new(), 1},
    killerBoxFill = false,
    survivorBoxFill = false,
    killerBoxFillColor = {Color3.fromRGB(180, 40, 40), 0.5},
    survivorBoxFillColor = {Color3.fromRGB(0, 255, 255), 0.5},
    killerBox3D = false,
    survivorBox3D = false,
    killerBox3DColor = {Color3.fromRGB(180, 40, 40), 1},
    survivorBox3DColor = {Color3.fromRGB(0, 255, 255), 1},
    -- Health Bar
    killerHealthBar = false,
    survivorHealthBar = false,
    killerHealthBarOutline = true,
    survivorHealthBarOutline = true,
    killerHealthBarOutlineColor = {Color3.new(), 0.5},
    survivorHealthBarOutlineColor = {Color3.new(), 0.5},
    -- Health Text
    killerHealthText = false,
    survivorHealthText = false,
    killerHealthTextColor = {Color3.new(1, 1, 1), 1},
    survivorHealthTextColor = {Color3.new(1, 1, 1), 1},
    killerHealthTextOutline = true,
    survivorHealthTextOutline = true,
    killerHealthTextOutlineColor = Color3.new(),
    survivorHealthTextOutlineColor = Color3.new(),
    -- Distance
    killerDistance = false,
    survivorDistance = false,
    killerDistanceColor = {Color3.new(1, 1, 1), 1},
    survivorDistanceColor = {Color3.new(1, 1, 1), 1},
    -- Tracer
    killerTracer = false,
    survivorTracer = false,
    killerTracerOrigin = "Bottom",
    survivorTracerOrigin = "Bottom",
    killerTracerColor = {Color3.fromRGB(180, 40, 40), 1},
    survivorTracerColor = {Color3.fromRGB(0, 255, 255), 1},
    killerTracerOutline = true,
    survivorTracerOutline = true,
    killerTracerOutlineColor = {Color3.new(), 1},
    survivorTracerOutlineColor = {Color3.new(), 1},
    -- Off-Screen Arrow
    killerOffScreenArrow = false,
    survivorOffScreenArrow = false,
    killerOffScreenArrowColor = {Color3.new(1, 1, 1), 1},
    survivorOffScreenArrowColor = {Color3.new(1, 1, 1), 1},
    killerOffScreenArrowSize = 15,
    survivorOffScreenArrowSize = 15,
    killerOffScreenArrowRadius = 150,
    survivorOffScreenArrowRadius = 150,
    killerOffScreenArrowOutline = true,
    survivorOffScreenArrowOutline = true,
    killerOffScreenArrowOutlineColor = {Color3.new(), 1},
    survivorOffScreenArrowOutlineColor = {Color3.new(), 1},
    -- Shared
    textSize = 13,
    textFont = 2,
    limitDistance = false,
    maxDistance = 150,
    useTeamColor = false,
    healthyColor = Color3.new(0, 1, 0),
    dyingColor = Color3.new(1, 0, 0),
}

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2",
    "Mafia3", "Mafia4", "Mafia5", "Mafia6", "Mafia7", "Mafia8", "Mafia9",
    "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy", "PinkGuy", "YellowGuy",
    "OrangeGuy", "GreyGuy"
}

local PlayerESPData = {}
local ObjectESPData = {}
local Highlights = {}
local Nametags = {}
local PlayerDrawings = {}

local AdvancedSettings = {
    Enabled = false,
    OutlineOnly = true,
    ShowNametag = false,
    Color = Color3.fromRGB(0, 255, 255)
}

local AdvancedNames = {
    "BuildermanDispenser","BuildermanSentry","HumanoidRootProjectile",
    "Swords","shockwave","Voidstar","Shadow"
}

local noliByUsername = {}

local AlertData = {
    NST = { connection = nil },
    NEK = { connection = nil }
}

local HEALTH_BAR_OFFSET = Vector2.new(5, 0)
local HEALTH_TEXT_OFFSET = Vector2.new(3, 0)
local HEALTH_BAR_OUTLINE_OFFSET = Vector2.new(0, 1)
local NAME_OFFSET = Vector2.new(0, 2)
local DISTANCE_OFFSET = Vector2.new(0, 2)

local function IsBodyPart(Name)
    return Name == "Head" or Name:find("Torso") or Name:find("Leg") or Name:find("Arm")
end

local function GetBoundingBox(Parts)
    local Min, Max
    for i = 1, #Parts do
        local Part = Parts[i]
        local Cframe, Size = Part.CFrame, Part.Size
        Min = Min3(Min or Cframe.Position, (Cframe - Size * 0.5).Position)
        Max = Max3(Max or Cframe.Position, (Cframe + Size * 0.5).Position)
    end
    local Center = (Min + Max) * 0.5
    local Front = Vector3.new(Center.X, Center.Y, Max.Z)
    return CFrame.new(Center, Front), Max - Min
end

local function WorldToScreen(World)
    local Screen, InBounds = WTVP(Camera, World)
    return Vector2.new(Screen.X, Screen.Y), InBounds, Screen.Z
end

local function CalculateCorners(Cframe, Size)
    local Corners = Create(#VERTICES)
    for i = 1, #VERTICES do
        Corners[i] = WorldToScreen((Cframe + Size * 0.5 * VERTICES[i]).Position)
    end
    local Min = Min2(Camera.ViewportSize, Unpack(Corners))
    local Max = Max2(Vector2.zero, Unpack(Corners))
    return {
        Corners = Corners,
        TopLeft = Vector2.new(Floor(Min.X), Floor(Min.Y)),
        TopRight = Vector2.new(Floor(Max.X), Floor(Min.Y)),
        BottomLeft = Vector2.new(Floor(Min.X), Floor(Max.Y)),
        BottomRight = Vector2.new(Floor(Max.X), Floor(Max.Y)),
    }
end

local function RotateVector(Vector, Radians)
    local X, Y = Vector.X, Vector.Y
    local C, S = Cos(Radians), Sin(Radians)
    return Vector2.new(X * C - Y * S, X * S + Y * C)
end

local function ParseColor(isKiller, color, isOutline)
    if color == "Team Color" or (ESPSettings.useTeamColor and not isOutline) then return Color3.new(1, 1, 1) end
    return color
end

local function IsRagdoll(model)
    local ragdolls = Services.Workspace:FindFirstChild("Ragdolls")
    if not ragdolls then return false end
    return model:IsDescendantOf(ragdolls) or (model.Parent == ragdolls)
end

local function IsSpectating(player)
    if not player then return false end
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    local spectating = playersFolder:FindFirstChild("Spectating")
    if not spectating then return false end
    return spectating:FindFirstChild(player.Name) ~= nil
end

local function GetGeneratorPart(model)
    if not model then return nil end
    local instances = model:FindFirstChild("Instances")
    if instances then
        local generator = instances:FindFirstChild("Generator")
        if generator then
            local cube = generator:FindFirstChild("Cube.003")
            if cube and cube:IsA("BasePart") then return cube end
            for _, v in ipairs(generator:GetDescendants()) do
                if v:IsA("BasePart") then return v end
            end
        end
        for _, v in ipairs(instances:GetDescendants()) do
            if v:IsA("BasePart") and tostring(v.Name):lower():find("cube") then return v end
        end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("cube") then return v end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local function UpdatePlayerBillboardText(data)
    if not data or not data.model or not data.nameLabel then return end
    local model = data.model
    local isKiller = data.isKiller
    local actorText = model:GetAttribute("ActorDisplayName") or (isKiller and "Killer" or "Survivor")
    local skinText = model:GetAttribute("SkinNameDisplay")
    if actorText == "Noli" and model:GetAttribute("IsFakeNoli") == true then
        actorText = actorText .. " (Fake)"
    end
    local displayText = actorText
    local showSkin = (isKiller and ESPSettings.killerSkinESP) or (not isKiller and ESPSettings.survivorSkinESP)
    if showSkin and skinText and tostring(skinText) ~= "" then
        displayText = displayText .. " | " .. skinText
    end
    local showName = (isKiller and ESPSettings.killerNameESP) or (not isKiller and ESPSettings.survivorNameESP)
    data.nameLabel.Text = showName and displayText or ""
    data.nameLabel.Visible = showName
    if data.hpLabel then
        local humanoid = model:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local maxhp = math.floor(humanoid.MaxHealth)
            data.hpLabel.Text = string.format("HP: %d/%d", hp, maxhp)
        end
        local showHealth = (isKiller and ESPSettings.killerHealthESP) or (not isKiller and ESPSettings.survivorHealthESP)
        data.hpLabel.Visible = showHealth
    end
    local highlight = model:FindFirstChild("TAOWARE_Highlight")
    if highlight then
        if isKiller then
            highlight.FillTransparency = ESPSettings.killerFillTransparency
            highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
        else
            highlight.FillTransparency = ESPSettings.survivorFillTransparency
            highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
        end
    end
end

local function UpdateGeneratorProgress(data)
    if not data or not data.model or not data.progressLabel then return end
    local model = data.model
    local progress = model:FindFirstChild("Progress")
    if progress then
        local progressValue = math.floor(progress.Value)
        data.progressLabel.Text = string.format("Progress: %d%%", progressValue)
    end
end

local function UpdateAllPlayerESPText()
    for _, data in ipairs(PlayerESPData) do
        UpdatePlayerBillboardText(data)
    end
end

local function UpdateObjectNameVisibility()
    for _, data in ipairs(ObjectESPData) do
        if data.billboard and data.billboard:FindFirstChildOfClass("TextLabel") then
            local textLabel = data.billboard:FindFirstChildOfClass("TextLabel")
            local showName = false
            if data.objectType == "generator" then showName = ESPSettings.showGeneratorName
            elseif data.objectType == "item" then showName = ESPSettings.showItemName
            elseif data.objectType == "pizza" then showName = ESPSettings.showPizzaName
            elseif data.objectType == "pizzaDelivery" then showName = ESPSettings.showPizzaDeliveryName
            elseif data.objectType == "zombie" then showName = ESPSettings.showZombieName
            elseif data.objectType == "taphTripwire" then showName = ESPSettings.showTaphTripwireName
            elseif data.objectType == "tripMine" then showName = ESPSettings.showTripMineName
            elseif data.objectType == "twoTimeRespawn" then showName = ESPSettings.showTwoTimeRespawnName
            elseif data.objectType == "graffiti" then showName = ESPSettings.showGraffitiName
            elseif data.objectType == "folders" then showName = ESPSettings.showFoldersName
            end
            textLabel.Visible = showName
        end
    end
end

local function CreateNametag(adornee, text, color)
    if Nametags[adornee] then
        pcall(function() Nametags[adornee].Parent:Destroy() end)
        Nametags[adornee] = nil
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 6
    textLabel.Parent = billboard
    billboard.Parent = adornee
    Nametags[adornee] = textLabel
end

local function CreatePlayerDrawings(model, isKiller)
    if PlayerDrawings[model] then return end
    local color = isKiller and ESPSettings.killerColor or ESPSettings.survivorColor
    local drawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        HealthBar = Drawing.new("Line"),
        HealthBarOutline = Drawing.new("Line"),
        HealthText = Drawing.new("Text"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        TracerOutline = Drawing.new("Line"),
        Arrow = Drawing.new("Triangle"),
        ArrowOutline = Drawing.new("Triangle"),
        Box3D = {
            {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
            {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
            {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
            {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
        },
    }
    drawings.Box.Thickness = 1; drawings.Box.Visible = false
    drawings.BoxOutline.Thickness = 3; drawings.BoxOutline.Visible = false
    drawings.BoxFill.Filled = true; drawings.BoxFill.Visible = false
    drawings.HealthBar.Thickness = 1; drawings.HealthBar.Visible = false
    drawings.HealthBarOutline.Thickness = 3; drawings.HealthBarOutline.Visible = false
    drawings.HealthText.Center = true; drawings.HealthText.Visible = false
    drawings.Name.Center = true; drawings.Name.Text = "Loading..."; drawings.Name.Visible = false
    drawings.Distance.Center = true; drawings.Distance.Visible = false
    drawings.Tracer.Thickness = 1; drawings.Tracer.Visible = false
    drawings.TracerOutline.Thickness = 3; drawings.TracerOutline.Visible = false
    drawings.Arrow.Filled = true; drawings.Arrow.Visible = false
    drawings.ArrowOutline.Thickness = 3; drawings.ArrowOutline.Visible = false
    for _, face in ipairs(drawings.Box3D) do
        for _, line in ipairs(face) do line.Thickness = 1; line.Visible = false end
    end
    PlayerDrawings[model] = drawings
end

local function RenderPlayerDrawings(model, isKiller, health, maxHealth, distance)
    local drawings = PlayerDrawings[model]
    if not drawings then return end

    local char = model
    local cache = {}
    local children = GetChildren(char)
    for i = 1, #children do
        local part = children[i]
        if IsA(part, "BasePart") and IsBodyPart(part.Name) then cache[#cache + 1] = part end
    end

    local cframe, size = GetBoundingBox(cache)
    local corners = CalculateCorners(cframe, size)
    local headPart = char:FindFirstChild("Head")
    local _, onScreen, depth = headPart and WorldToScreen(headPart.Position) or WorldToScreen(cframe.Position)
    if ESPSettings.limitDistance and depth > ESPSettings.maxDistance then onScreen = false end

    local opts = isKiller and {
        box = ESPSettings.killerBox, boxColor = ESPSettings.killerBoxColor,
        boxOutline = ESPSettings.killerBoxOutline, boxOutlineColor = ESPSettings.killerBoxOutlineColor,
        boxFill = ESPSettings.killerBoxFill, boxFillColor = ESPSettings.killerBoxFillColor,
        box3D = ESPSettings.killerBox3D, box3DColor = ESPSettings.killerBox3DColor,
        healthBar = ESPSettings.killerHealthBar, healthBarOutline = ESPSettings.killerHealthBarOutline,
        healthBarOutlineColor = ESPSettings.killerHealthBarOutlineColor,
        healthText = ESPSettings.killerHealthText, healthTextColor = ESPSettings.killerHealthTextColor,
        healthTextOutline = ESPSettings.killerHealthTextOutline, healthTextOutlineColor = ESPSettings.killerHealthTextOutlineColor,
        distance = ESPSettings.killerDistance, distanceColor = ESPSettings.killerDistanceColor,
        tracer = ESPSettings.killerTracer, tracerOrigin = ESPSettings.killerTracerOrigin,
        tracerColor = ESPSettings.killerTracerColor, tracerOutline = ESPSettings.killerTracerOutline,
        tracerOutlineColor = ESPSettings.killerTracerOutlineColor,
        offScreenArrow = ESPSettings.killerOffScreenArrow, offScreenArrowColor = ESPSettings.killerOffScreenArrowColor,
        offScreenArrowSize = ESPSettings.killerOffScreenArrowSize, offScreenArrowRadius = ESPSettings.killerOffScreenArrowRadius,
        offScreenArrowOutline = ESPSettings.killerOffScreenArrowOutline, offScreenArrowOutlineColor = ESPSettings.killerOffScreenArrowOutlineColor,
    } or {
        box = ESPSettings.survivorBox, boxColor = ESPSettings.survivorBoxColor,
        boxOutline = ESPSettings.survivorBoxOutline, boxOutlineColor = ESPSettings.survivorBoxOutlineColor,
        boxFill = ESPSettings.survivorBoxFill, boxFillColor = ESPSettings.survivorBoxFillColor,
        box3D = ESPSettings.survivorBox3D, box3DColor = ESPSettings.survivorBox3DColor,
        healthBar = ESPSettings.survivorHealthBar, healthBarOutline = ESPSettings.survivorHealthBarOutline,
        healthBarOutlineColor = ESPSettings.survivorHealthBarOutlineColor,
        healthText = ESPSettings.survivorHealthText, healthTextColor = ESPSettings.survivorHealthTextColor,
        healthTextOutline = ESPSettings.survivorHealthTextOutline, healthTextOutlineColor = ESPSettings.survivorHealthTextOutlineColor,
        distance = ESPSettings.survivorDistance, distanceColor = ESPSettings.survivorDistanceColor,
        tracer = ESPSettings.survivorTracer, tracerOrigin = ESPSettings.survivorTracerOrigin,
        tracerColor = ESPSettings.survivorTracerColor, tracerOutline = ESPSettings.survivorTracerOutline,
        tracerOutlineColor = ESPSettings.survivorTracerOutlineColor,
        offScreenArrow = ESPSettings.survivorOffScreenArrow, offScreenArrowColor = ESPSettings.survivorOffScreenArrowColor,
        offScreenArrowSize = ESPSettings.survivorOffScreenArrowSize, offScreenArrowRadius = ESPSettings.survivorOffScreenArrowRadius,
        offScreenArrowOutline = ESPSettings.survivorOffScreenArrowOutline, offScreenArrowOutlineColor = ESPSettings.survivorOffScreenArrowOutlineColor,
    }

    if onScreen then
        -- 2D Box
        drawings.Box.Visible = opts.box
        drawings.BoxOutline.Visible = drawings.Box.Visible and opts.boxOutline
        if drawings.Box.Visible then
            drawings.Box.Position = corners.TopLeft
            drawings.Box.Size = corners.BottomRight - corners.TopLeft
            drawings.Box.Color = ParseColor(isKiller, opts.boxColor[1], false)
            drawings.Box.Transparency = opts.boxColor[2]
            local bo = drawings.BoxOutline
            bo.Position = drawings.Box.Position; bo.Size = drawings.Box.Size
            bo.Color = ParseColor(isKiller, opts.boxOutlineColor[1], true)
            bo.Transparency = opts.boxOutlineColor[2]
        end

        -- Box Fill
        drawings.BoxFill.Visible = opts.boxFill
        if drawings.BoxFill.Visible then
            drawings.BoxFill.Position = corners.TopLeft
            drawings.BoxFill.Size = corners.BottomRight - corners.TopLeft
            drawings.BoxFill.Color = ParseColor(isKiller, opts.boxFillColor[1], false)
            drawings.BoxFill.Transparency = opts.boxFillColor[2]
        end

        -- 3D Box
        local box3DEnabled = opts.box3D
        for i = 1, #drawings.Box3D do
            local face = drawings.Box3D[i]
            for _, line in ipairs(face) do
                line.Visible = box3DEnabled
                line.Color = ParseColor(isKiller, opts.box3DColor[1], false)
                line.Transparency = opts.box3DColor[2]
            end
            if box3DEnabled then
                face[1].From = corners.Corners[i]; face[1].To = corners.Corners[i == 4 and 1 or i + 1]
                face[2].From = corners.Corners[i == 4 and 1 or i + 1]; face[2].To = corners.Corners[i == 4 and 5 or i + 5]
                face[3].From = corners.Corners[i == 4 and 5 or i + 5]; face[3].To = corners.Corners[i == 4 and 8 or i + 4]
            end
        end

        -- Health Bar
        drawings.HealthBar.Visible = opts.healthBar
        drawings.HealthBarOutline.Visible = drawings.HealthBar.Visible and opts.healthBarOutline
        if drawings.HealthBar.Visible then
            local barFrom = corners.TopLeft - HEALTH_BAR_OFFSET
            local barTo = corners.BottomLeft - HEALTH_BAR_OFFSET
            drawings.HealthBar.To = barTo
            drawings.HealthBar.From = Lerp2(barTo, barFrom, health / maxHealth)
            drawings.HealthBar.Color = LerpColor(ESPSettings.dyingColor, ESPSettings.healthyColor, health / maxHealth)
            local hbo = drawings.HealthBarOutline
            hbo.To = barTo + HEALTH_BAR_OUTLINE_OFFSET; hbo.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET
            hbo.Color = ParseColor(isKiller, opts.healthBarOutlineColor[1], true)
            hbo.Transparency = opts.healthBarOutlineColor[2]
        end

        -- Health Text
        drawings.HealthText.Visible = opts.healthText
        if drawings.HealthText.Visible then
            local barFrom = corners.TopLeft - HEALTH_BAR_OFFSET
            local barTo = corners.BottomLeft - HEALTH_BAR_OFFSET
            drawings.HealthText.Text = Round(health) .. "hp"
            drawings.HealthText.Size = ESPSettings.textSize; drawings.HealthText.Font = ESPSettings.textFont
            drawings.HealthText.Color = ParseColor(isKiller, opts.healthTextColor[1], false)
            drawings.HealthText.Transparency = opts.healthTextColor[2]
            drawings.HealthText.Outline = opts.healthTextOutline
            drawings.HealthText.OutlineColor = ParseColor(isKiller, opts.healthTextOutlineColor, true)
            drawings.HealthText.Position = Lerp2(barTo, barFrom, health / maxHealth) - drawings.HealthText.TextBounds * 0.5 - HEALTH_TEXT_OFFSET
        end

        -- Name
        drawings.Name.Visible = isKiller and ESPSettings.killerNameESP or ESPSettings.survivorNameESP
        if drawings.Name.Visible then
            drawings.Name.Size = ESPSettings.textSize; drawings.Name.Font = ESPSettings.textFont
            drawings.Name.Color = ParseColor(isKiller, Color3.new(1, 1, 1), false)
            drawings.Name.Position = (corners.TopLeft + corners.TopRight) * 0.5 - Vector2.yAxis * drawings.Name.TextBounds.Y - NAME_OFFSET
        end

        -- Distance
        drawings.Distance.Visible = opts.distance
        if drawings.Distance.Visible then
            drawings.Distance.Text = Round(depth) .. " studs"
            drawings.Distance.Size = ESPSettings.textSize; drawings.Distance.Font = ESPSettings.textFont
            drawings.Distance.Color = ParseColor(isKiller, opts.distanceColor[1], false)
            drawings.Distance.Transparency = opts.distanceColor[2]
            drawings.Distance.Position = (corners.BottomLeft + corners.BottomRight) * 0.5 + DISTANCE_OFFSET
        end

        -- Tracer
        drawings.Tracer.Visible = opts.tracer
        drawings.TracerOutline.Visible = drawings.Tracer.Visible and opts.tracerOutline
        if drawings.Tracer.Visible then
            local t = drawings.Tracer
            t.Color = ParseColor(isKiller, opts.tracerColor[1], false); t.Transparency = opts.tracerColor[2]
            t.To = (corners.BottomLeft + corners.BottomRight) * 0.5
            t.From = opts.tracerOrigin == "Middle" and Camera.ViewportSize * 0.5 or opts.tracerOrigin == "Top" and Camera.ViewportSize * Vector2.new(0.5, 0) or Camera.ViewportSize * Vector2.new(0.5, 1)
            local to = drawings.TracerOutline
            to.Color = ParseColor(isKiller, opts.tracerOutlineColor[1], true); to.Transparency = opts.tracerOutlineColor[2]
            to.To = t.To; to.From = t.From
        end
    else
        for _, key in ipairs({"Box","BoxOutline","BoxFill","HealthBar","HealthBarOutline","HealthText","Name","Distance","Tracer","TracerOutline"}) do
            drawings[key].Visible = false
        end
        for _, face in ipairs(drawings.Box3D) do for _, line in ipairs(face) do line.Visible = false end end
    end

    -- Off-Screen Arrow
    drawings.Arrow.Visible = not onScreen and opts.offScreenArrow
    drawings.ArrowOutline.Visible = drawings.Arrow.Visible and opts.offScreenArrowOutline
    if drawings.Arrow.Visible and headPart then
        local cameraCFrame = Camera.CFrame
        local flat = FromMatrix(cameraCFrame.Position, cameraCFrame.RightVector, Vector3.yAxis)
        local objectSpace = CFrame.identity:PointToObjectSpace(flat, headPart.Position)
        local direction = Vector2.new(objectSpace.X, objectSpace.Z).Unit
        if direction then
            local a = drawings.Arrow
            a.PointA = Min2(Max2(Camera.ViewportSize * 0.5 + direction * opts.offScreenArrowRadius, Vector2.one * 25), Camera.ViewportSize - Vector2.one * 25)
            a.PointB = a.PointA - RotateVector(direction, 0.45) * opts.offScreenArrowSize
            a.PointC = a.PointA - RotateVector(direction, -0.45) * opts.offScreenArrowSize
            a.Color = ParseColor(isKiller, opts.offScreenArrowColor[1], false)
            a.Transparency = opts.offScreenArrowColor[2]
            local ao = drawings.ArrowOutline
            ao.PointA = a.PointA; ao.PointB = a.PointB; ao.PointC = a.PointC
            ao.Color = ParseColor(isKiller, opts.offScreenArrowOutlineColor[1], true)
            ao.Transparency = opts.offScreenArrowOutlineColor[2]
        end
    end
end

local function RemovePlayerDrawings(model)
    local drawings = PlayerDrawings[model]
    if not drawings then return end
    for _, v in pairs(drawings) do
        if type(v) == "table" then
            if v[1] and type(v[1]) == "userdata" then for _, line in ipairs(v) do line:Remove() end
            elseif v.Remove then v:Remove() end
        end
    end
    PlayerDrawings[model] = nil
end

local function CreateESP(model, color, isGenerator, isItem, isPizza, isPizzaDelivery, isZombie, isKiller, isTaph, isTripMine, isRespawn, isGraffiti, isFolders)
    if not model then return end
    if model:FindFirstChild("TAOWARE_Highlight") then return end
    if isGenerator and model:FindFirstChild("Progress") and model.Progress.Value == 100 then return end
    if IsRagdoll(model) then return end

    local targetPart
    local objectType = ""
    if isGenerator then targetPart = GetGeneratorPart(model); objectType = "generator"
    elseif isItem then targetPart = model:FindFirstChild("ItemRoot"); objectType = "item"
    elseif isPizza then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true); objectType = "pizza"
    elseif isPizzaDelivery then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true); objectType = "pizzaDelivery"
    elseif isZombie then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true); objectType = "zombie"
    elseif isTaph then targetPart = model:IsA("Model") and (GetGeneratorPart(model) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model; objectType = "taphTripwire"
    elseif isTripMine then targetPart = model:IsA("Model") and (GetGeneratorPart(model) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model; objectType = "tripMine"
    elseif isRespawn then targetPart = model:IsA("Model") and (GetGeneratorPart(model) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model; objectType = "twoTimeRespawn"
    elseif isGraffiti then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true); objectType = "graffiti"
    elseif isFolders then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true); objectType = "folders"
    else targetPart = model:FindFirstChild("HumanoidRootPart") end

    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TAOWARE_Highlight"
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.OutlineColor = color
    if isKiller then highlight.FillTransparency = ESPSettings.killerFillTransparency; highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
    elseif not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTaph and not isTripMine and not isRespawn and not isGraffiti and not isFolders then highlight.FillTransparency = ESPSettings.survivorFillTransparency; highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
    else highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0.3 end
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TAOWARE_Billboard"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    if not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTaph and not isTripMine and not isRespawn and not isGraffiti and not isFolders then
        CreatePlayerDrawings(model, isKiller)
        local humanoid = model:FindFirstChild("Humanoid")
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.33, 0); nameLabel.Position = UDim2.new(0, 0, 0, 0); nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Loading..."; nameLabel.Font = Enum.Font.GothamBlack; nameLabel.TextColor3 = color
        nameLabel.TextSize = 8; nameLabel.TextStrokeTransparency = 0.6; nameLabel.Parent = billboard
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.33, 0); hpLabel.Position = UDim2.new(0, 0, 0.3, 0); hpLabel.BackgroundTransparency = 1
        hpLabel.Text = "HP: " .. (humanoid and string.format("%.0f", humanoid.Health) or "N/A")
        hpLabel.Font = Enum.Font.GothamBlack; hpLabel.TextColor3 = color; hpLabel.TextSize = 8; hpLabel.TextStrokeTransparency = 0.6; hpLabel.Parent = billboard
        local espData = {model = model, nameLabel = nameLabel, hpLabel = hpLabel, color = color, isKiller = isKiller}
        table.insert(PlayerESPData, espData)
        UpdatePlayerBillboardText(espData)
        model:GetAttributeChangedSignal("ActorDisplayName"):Connect(function() UpdatePlayerBillboardText(espData) end)
        model:GetAttributeChangedSignal("SkinNameDisplay"):Connect(function() UpdatePlayerBillboardText(espData) end)
        model:GetAttributeChangedSignal("IsFakeNoli"):Connect(function() UpdatePlayerBillboardText(espData) end)
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function() UpdatePlayerBillboardText(espData) end)
            humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function() UpdatePlayerBillboardText(espData) end)
        end
    elseif isGenerator then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0); nameLabel.Position = UDim2.new(0, 0, 0, 0); nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Generator"; nameLabel.Font = Enum.Font.GothamBlack; nameLabel.TextColor3 = color
        nameLabel.TextSize = 8; nameLabel.TextStrokeTransparency = 0.6; nameLabel.Visible = ESPSettings.showGeneratorName; nameLabel.Parent = billboard
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Size = UDim2.new(1, 0, 0.5, 0); progressLabel.Position = UDim2.new(0, 0, 0.5, 0); progressLabel.BackgroundTransparency = 1
        progressLabel.Text = "Progress: 0%"; progressLabel.Font = Enum.Font.GothamBlack; progressLabel.TextColor3 = color
        progressLabel.TextSize = 8; progressLabel.TextStrokeTransparency = 0.6; progressLabel.Parent = billboard
        local espData = {model = model, nameLabel = nameLabel, progressLabel = progressLabel, highlight = highlight, billboard = billboard, objectType = objectType}
        table.insert(ObjectESPData, espData)
        UpdateGeneratorProgress(espData)
        local progress = model:FindFirstChild("Progress")
        if progress then progress:GetPropertyChangedSignal("Value"):Connect(function() UpdateGeneratorProgress(espData) end) end
    else
        local displayName = model.Name
        if isPizza then displayName = "Pizza"
        elseif isPizzaDelivery then displayName = "Pizza Delivery"
        elseif isZombie then displayName = "Zombie"
        elseif isTaph then displayName = "Tripwire"
        elseif isTripMine then displayName = "Tripmine"
        elseif isRespawn then displayName = "Respawn Point"
        elseif isGraffiti then displayName = "Graffiti"
        elseif isFolders then displayName = "Mission Folder" end
        local showName = true
        if isPizza then showName = ESPSettings.showPizzaName
        elseif isPizzaDelivery then showName = ESPSettings.showPizzaDeliveryName
        elseif isZombie then showName = ESPSettings.showZombieName
        elseif isTaph then showName = ESPSettings.showTaphTripwireName
        elseif isTripMine then showName = ESPSettings.showTripMineName
        elseif isRespawn then showName = ESPSettings.showTwoTimeRespawnName
        elseif isGraffiti then showName = ESPSettings.showGraffitiName
        elseif isFolders then showName = ESPSettings.showFoldersName
        elseif isItem then showName = ESPSettings.showItemName end
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.Text = displayName
        textLabel.Font = Enum.Font.GothamBlack; textLabel.TextColor3 = color; textLabel.TextSize = 8
        textLabel.TextStrokeTransparency = 0.6; textLabel.Visible = showName; textLabel.Parent = billboard
        table.insert(ObjectESPData, {model = model, highlight = highlight, billboard = billboard, type = displayName, objectType = objectType})
    end
end

local function RemoveESP(model)
    if not model then return end
    for i = #PlayerESPData, 1, -1 do if PlayerESPData[i].model == model then table.remove(PlayerESPData, i) end end
    for i = #ObjectESPData, 1, -1 do if ObjectESPData[i].model == model then table.remove(ObjectESPData, i) end end
    RemovePlayerDrawings(model)
    pcall(function()
        if model:FindFirstChild("TAOWARE_Highlight") then model.TAOWARE_Highlight:Destroy() end
        if model:FindFirstChild("TAOWARE_Billboard") then model.TAOWARE_Billboard:Destroy() end
    end)
end

local function clearFakeTags()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then killer:SetAttribute("IsFakeNoli", false) end
    end
end

local function scanNolis()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    noliByUsername = {}
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            local username = killer:GetAttribute("Username")
            if username then
                if not noliByUsername[username] then noliByUsername[username] = {} end
                table.insert(noliByUsername[username], killer)
            end
        end
    end
    for _, models in pairs(noliByUsername) do
        if #models > 1 then for i = 2, #models do models[i]:SetAttribute("IsFakeNoli", true) end
        else models[1]:SetAttribute("IsFakeNoli", false) end
    end
end

local function updateFakeNolis()
    clearFakeTags()
    scanNolis()
end

local function AddHighlightAdvanced(Obj, Config)
    if Highlights[Obj] then pcall(function() Highlights[Obj]:Destroy() end); Highlights[Obj] = nil end
    local hl = Instance.new("Highlight")
    hl.Adornee = Obj; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = Config.Enabled
    hl.OutlineColor = Config.Color; hl.FillColor = Config.Color; hl.OutlineTransparency = 0
    local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, Obj.Name)
    hl.FillTransparency = Config.OutlineOnly and 1 or (alwaysFill and 0.65 or 1)
    hl.Parent = Obj; Highlights[Obj] = hl
    Obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if Highlights[Obj] then pcall(function() Highlights[Obj]:Destroy() end); Highlights[Obj] = nil end
            if Nametags[Obj] then pcall(function() Nametags[Obj].Parent:Destroy() end); Nametags[Obj] = nil end
        end
    end)
end

local function ApplyToTargetAdvanced(target, Config)
    if not target or not target.Parent then return end
    AddHighlightAdvanced(target, Config)
end

local function HandleAdvanced(obj)
    if table.find(AdvancedNames, obj.Name) or (obj.Name == "Shadow" and obj.Parent and obj.Parent.Name == "Shadows") then
        ApplyToTargetAdvanced(obj, AdvancedSettings)
    end
end

for _, v in ipairs(MapFolder:GetDescendants()) do HandleAdvanced(v) end
MapFolder.DescendantAdded:Connect(HandleAdvanced)

task.spawn(function()
    while task.wait(0.3) do
        for obj, hl in pairs(Highlights) do
            if not hl or not hl.Parent then continue end
            hl.Enabled = AdvancedSettings.Enabled; hl.OutlineColor = AdvancedSettings.Color; hl.FillColor = AdvancedSettings.Color
            hl.OutlineTransparency = 0; hl.FillTransparency = AdvancedSettings.OutlineOnly and 1 or 0.65
            if AdvancedSettings.ShowNametag then
                local nameText = obj.Name
                if Nametags[obj] then Nametags[obj].Text = nameText; Nametags[obj].TextColor3 = AdvancedSettings.Color
                else CreateNametag(obj, nameText, AdvancedSettings.Color) end
            else
                if Nametags[obj] then pcall(function() Nametags[obj].Parent:Destroy() end); Nametags[obj] = nil end
            end
        end
    end
end)

local function UpdateESP()
    local mapFolder = Services.Workspace:FindFirstChild("Map")
    if not mapFolder or not mapFolder:FindFirstChild("Ingame") then
        for i = #PlayerESPData, 1, -1 do RemoveESP(PlayerESPData[i].model) end
        for i = #ObjectESPData, 1, -1 do RemoveESP(ObjectESPData[i].model) end
        return
    end
    local ingame = mapFolder.Ingame
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            for _, killer in ipairs(killers:GetChildren()) do
                if killer == LocalPlayer.Character then continue end
                if IsRagdoll(killer) then RemoveESP(killer); continue end
                local player = Services.Players:GetPlayerFromCharacter(killer)
                if not player or IsSpectating(player) then RemoveESP(killer); continue end
                if ESPSettings.killerESP and not killer:FindFirstChild("TAOWARE_Highlight") and killer:FindFirstChild("HumanoidRootPart") then CreateESP(killer, ESPSettings.killerColor, false, false, false, false, false, true)
                elseif not ESPSettings.killerESP then RemoveESP(killer) end
            end
        end
        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in ipairs(survivors:GetChildren()) do
                if survivor == LocalPlayer.Character then continue end
                if IsRagdoll(survivor) then RemoveESP(survivor); continue end
                local player = Services.Players:GetPlayerFromCharacter(survivor)
                if not player or IsSpectating(player) then RemoveESP(survivor); continue end
                if ESPSettings.playerESP and not survivor:FindFirstChild("TAOWARE_Highlight") and survivor:FindFirstChild("HumanoidRootPart") then CreateESP(survivor, ESPSettings.survivorColor, false, false, false, false, false, false)
                elseif not ESPSettings.playerESP then RemoveESP(survivor) end
            end
        end
    end
    if ingame:FindFirstChild("Map") then
        for _, gen in ipairs(ingame.Map:GetChildren()) do
            if gen:IsA("Model") and gen.Name:lower():find("generator") and gen.Name ~= "FakeGenerator" then
                if IsRagdoll(gen) then RemoveESP(gen); continue end
                local progress = gen:FindFirstChild("Progress")
                if ESPSettings.generatorESP and progress and progress.Value < 100 and not gen:FindFirstChild("TAOWARE_Highlight") then CreateESP(gen, ESPSettings.generatorColor, true, false, false, false, false, false)
                elseif not ESPSettings.generatorESP or (progress and progress.Value >= 100) then RemoveESP(gen) end
            end
        end
        for _, item in ipairs(ingame.Map:GetDescendants()) do
            if item.Name == "ItemRoot" and item.Parent and item.Parent:IsA("Model") then
                local itemModel = item.Parent
                if ESPSettings.itemESP and not itemModel:FindFirstChild("TAOWARE_Highlight") then CreateESP(itemModel, ESPSettings.itemColor, false, true, false, false, false, false)
                elseif not ESPSettings.itemESP then RemoveESP(itemModel) end
            end
        end
    end
    for _, pizza in ipairs(ingame:GetChildren()) do
        if pizza.Name == "Pizza" and pizza:IsA("BasePart") then
            if ESPSettings.pizzaEsp and not pizza:FindFirstChild("TAOWARE_Highlight") then CreateESP(pizza, ESPSettings.pizzaColor, false, false, true, false, false, false)
            elseif not ESPSettings.pizzaEsp then RemoveESP(pizza) end
        end
    end
    for _, delivery in ipairs(ingame:GetChildren()) do
        if delivery:IsA("Model") and table.find(DummyNames, delivery.Name) then
            if ESPSettings.pizzaDeliveryEsp and not delivery:FindFirstChild("TAOWARE_Highlight") then local hrp = delivery:FindFirstChild("HumanoidRootPart"); if hrp then CreateESP(delivery, ESPSettings.pizzaDeliveryColor, false, false, false, true, false, false) end
            elseif not ESPSettings.pizzaDeliveryEsp then RemoveESP(delivery) end
        end
    end
    for _, zombie in ipairs(ingame:GetChildren()) do
        if zombie.Name == "1x1x1x1Zombie" and zombie:IsA("Model") then
            if ESPSettings.zombieEsp and not zombie:FindFirstChild("TAOWARE_Highlight") then local hrp = zombie:FindFirstChild("HumanoidRootPart"); if hrp then CreateESP(zombie, ESPSettings.zombieColor, false, false, false, false, true, false) end
            elseif not ESPSettings.zombieEsp then RemoveESP(zombie) end
        end
    end
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name:match("TaphTripwire$") and obj:IsA("Model") then
            if ESPSettings.taphTripwireEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.taphTripwireColor, false, false, false, false, false, false, true)
            elseif not ESPSettings.taphTripwireEsp then RemoveESP(obj) end
        end
    end
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name == "SubspaceTripmine" and obj:IsA("Model") then
            if ESPSettings.tripMineEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.tripMineColor, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.tripMineEsp then RemoveESP(obj) end
        end
    end
    for _, obj in ipairs(ingame:GetDescendants()) do
        if obj and obj.Name and tostring(obj.Name):lower():find("respawnlocation") then
            local target = obj:IsA("Model") and obj or obj:IsA("BasePart") and obj or (obj:FindFirstAncestorOfClass("Model") or obj)
            if not target or IsRagdoll(target) then continue end
            if ESPSettings.twoTimeRespawnEsp and not target:FindFirstChild("TAOWARE_Highlight") then CreateESP(target, ESPSettings.twoTimeRespawnColor, false, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.twoTimeRespawnEsp then RemoveESP(target) end
        end
    end
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name == "GraffitiCL" and obj:IsA("BasePart") then
            if ESPSettings.graffitiEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.graffitiColor, false, false, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.graffitiEsp then RemoveESP(obj) end
        end
    end
    for _, folder in ipairs(Services.Workspace:GetChildren()) do
        if folder:IsA("MeshPart") and folder.Name == "Model" then
            if ESPSettings.foldersEsp and not folder:FindFirstChild("TAOWARE_Highlight") then CreateESP(folder, ESPSettings.foldersColor, false, false, false, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.foldersEsp then RemoveESP(folder) end
        end
    end

    -- Render 2D drawings for players
    for _, data in ipairs(PlayerESPData) do
        local model = data.model
        if model and model.Parent then
            local humanoid = model:FindFirstChild("Humanoid")
            local health, maxHealth = 100, 100
            if humanoid then health, maxHealth = humanoid.Health, humanoid.MaxHealth end
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local distance = hrp and (hrp.Position - Camera.CFrame.Position).Magnitude or 0
            RenderPlayerDrawings(model, data.isKiller, health, maxHealth, distance)
        end
    end
end

task.spawn(function()
    while true do
        UpdateESP()
        updateFakeNolis()
        task.wait(0.5)
    end
end)

function EspLib.GetSettings() return ESPSettings end
function EspLib.GetAdvancedSettings() return AdvancedSettings end
function EspLib.UpdateAllPlayerText() UpdateAllPlayerESPText() end
function EspLib.UpdateObjectNames() UpdateObjectNameVisibility() end

function EspLib.SetNSTAlert(state, Library)
    if AlertData.NST.connection then AlertData.NST.connection:Disconnect(); AlertData.NST.connection = nil end
    if state then
        AlertData.NST.connection = Services.Workspace.Map.Ingame.DescendantAdded:Connect(function(v)
            if v.Name == "SubspaceTripmine" and Library and Library.Notify then Library:Notify("Tripmine spawned!") end
        end)
    end
end

function EspLib.SetNEKAlert(state, Library)
    if AlertData.NEK.connection then AlertData.NEK.connection:Disconnect(); AlertData.NEK.connection = nil end
    if state then
        AlertData.NEK.connection = Services.Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("Model") and (v.Name == "PizzaDeliveryRig" or v.Name == "Mafia1" or v.Name == "Mafia2" or v.Name == "Mafia3" or v.Name == "Mafia4") then
                if Library and Library.Notify then Library:Notify("Entity '" .. v.Name .. "' spawned!") end
            elseif v:IsA("Model") and v.Name == "1x1x1x1Zombie" then
                if Library and Library.Notify then Library:Notify("Zombie spawned!") end
            end
        end)
    end
end

function EspLib.Cleanup()
    if AlertData.NST.connection then AlertData.NST.connection:Disconnect(); AlertData.NST.connection = nil end
    if AlertData.NEK.connection then AlertData.NEK.connection:Disconnect(); AlertData.NEK.connection = nil end
    for model in pairs(PlayerDrawings) do RemovePlayerDrawings(model) end
end

return EspLib
