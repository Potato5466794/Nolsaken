local EspLib = {}
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local RunService = Services.RunService

local MapFolder = Services.Workspace:WaitForChild("Map"):WaitForChild("Ingame")

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2",
    "Mafia3", "Mafia4", "Mafia5", "Mafia6", "Mafia7", "Mafia8", "Mafia9",
    "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy", "PinkGuy", "YellowGuy",
    "OrangeGuy", "GreyGuy"
}

local AdvancedNames = {
    "BuildermanDispenser","BuildermanSentry","HumanoidRootProjectile",
    "Swords","shockwave","Voidstar","Shadow"
}

local ESPObjects = {}
local ActiveTracers = {}
local AdvancedHighlights = {}
local AdvancedNametags = {}
local noliByUsername = {}

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
    killerTracers = false,
    survivorTracers = false,
    generatorTracers = false,
    itemTracers = false,
    pizzaTracers = false,
    pizzaDeliveryTracers = false,
    zombieTracers = false,
    taphTripwireTracers = false,
    tripMineTracers = false,
    twoTimeRespawnTracers = false,
    killerSkinESP = false,
    survivorSkinESP = false,
    killerNameESP = true,
    killerHealthESP = true,
    survivorNameESP = true,
    survivorHealthESP = true,
    killerFillTransparency = 0.7,
    killerOutlineTransparency = 0.3,
    survivorFillTransparency = 0.7,
    survivorOutlineTransparency = 0.3,
    killerColor = Color3.fromRGB(255, 100, 100),
    survivorColor = Color3.fromRGB(100, 255, 200),
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
    showFoldersName = true
}

local AdvancedSettings = {
    Enabled = false,
    OutlineOnly = true,
    ShowNametag = false,
    Color = Color3.fromRGB(0, 255, 255)
}

local function IsRagdoll(model)
    local ragdolls = Services.Workspace:FindFirstChild("Ragdolls")
    if not ragdolls then return false end
    return model:IsDescendantOf(ragdolls)
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
            for _, v in generator:GetChildren() do
                if v:IsA("BasePart") then return v end
            end
        end
        for _, v in instances:GetDescendants() do
            if v:IsA("BasePart") and v.Name:lower():find("cube") then
                return v
            end
        end
    end
    for _, v in model:GetDescendants() do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local function SafeDestroy(obj)
    pcall(function()
        if typeof(obj) == "Instance" then
            obj:Destroy()
        elseif typeof(obj) == "RBXScriptConnection" then
            obj:Disconnect()
        end
    end)
end

local function CreateHighlight(model, fillColor, outlineColor, fillTrans, outlineTrans)
    local highlight = Instance.new("Highlight")
    highlight.Name = "TAOWARE_Highlight"
    highlight.Adornee = model
    highlight.FillColor = fillColor
    highlight.OutlineColor = outlineColor
    highlight.FillTransparency = fillTrans
    highlight.OutlineTransparency = outlineTrans
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    return highlight
end

local function CreateBillboard(targetPart, parent, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TAOWARE_Billboard"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 8
    textLabel.Parent = billboard
    
    return billboard, textLabel
end

local function UpdatePlayerESP(espData)
    local model = espData.Model
    if not model or not model.Parent then
        EspLib.RemoveESP(model)
        return
    end
    
    local isKiller = espData.IsKiller
    local actorText = model:GetAttribute("ActorDisplayName") or (isKiller and "杀手" or "幸存者")
    local skinText = model:GetAttribute("SkinNameDisplay")
    
    if actorText == "Noli" and model:GetAttribute("IsFakeNoli") == true then
        actorText = actorText .. " (假)"
    end
    
    local showSkin = (isKiller and ESPSettings.killerSkinESP) or (not isKiller and ESPSettings.survivorSkinESP)
    local displayText = actorText
    if showSkin and skinText and skinText ~= "" then
        displayText = displayText .. " | " .. skinText
    end
    
    local showName = (isKiller and ESPSettings.killerNameESP) or (not isKiller and ESPSettings.survivorNameESP)
    if espData.NameLabel then
        espData.NameLabel.Text = displayText
        espData.NameLabel.Visible = showName
    end
    
    local humanoid = model:FindFirstChild("Humanoid")
    if espData.HpLabel then
        if humanoid then
            espData.HpLabel.Text = string.format("血量: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        end
        local showHealth = (isKiller and ESPSettings.killerHealthESP) or (not isKiller and ESPSettings.survivorHealthESP)
        espData.HpLabel.Visible = showHealth
    end
    
    if espData.Highlight then
        local fillTrans = isKiller and ESPSettings.killerFillTransparency or ESPSettings.survivorFillTransparency
        local outlineTrans = isKiller and ESPSettings.killerOutlineTransparency or ESPSettings.survivorOutlineTransparency
        espData.Highlight.FillTransparency = fillTrans
        espData.Highlight.OutlineTransparency = outlineTrans
    end
end

local function UpdateObjectVisibility(espData)
    if not espData.Billboard then return end
    local textLabel = espData.Billboard:FindFirstChildOfClass("TextLabel")
    if not textLabel then return end
    
    local showName = false
    local objType = espData.ObjectType
    
    if objType == "generator" then showName = ESPSettings.showGeneratorName
    elseif objType == "item" then showName = ESPSettings.showItemName
    elseif objType == "pizza" then showName = ESPSettings.showPizzaName
    elseif objType == "pizzaDelivery" then showName = ESPSettings.showPizzaDeliveryName
    elseif objType == "zombie" then showName = ESPSettings.showZombieName
    elseif objType == "taphTripwire" then showName = ESPSettings.showTaphTripwireName
    elseif objType == "tripMine" then showName = ESPSettings.showTripMineName
    elseif objType == "twoTimeRespawn" then showName = ESPSettings.showTwoTimeRespawnName
    elseif objType == "graffiti" then showName = ESPSettings.showGraffitiName
    elseif objType == "folders" then showName = ESPSettings.showFoldersName
    end
    
    textLabel.Visible = showName
end

function EspLib.CreateESP(model, color, config)
    if not model then return end
    if model:FindFirstChild("TAOWARE_Highlight") then return end
    if ESPObjects[model] then return end
    
    config = config or {}
    local isKiller = config.isKiller or false
    local isGenerator = config.isGenerator or false
    local objectType = config.objectType or ""
    
    if isGenerator then
        local progress = model:FindFirstChild("Progress")
        if progress and progress.Value >= 100 then return end
    end
    
    if IsRagdoll(model) then return end
    
    local targetPart
    if isGenerator then
        targetPart = GetGeneratorPart(model)
    elseif config.objectType == "pizza" or config.objectType == "graffiti" or config.objectType == "folders" then
        targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    else
        targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
    end
    
    if not targetPart then return end
    
    local fillTrans = 0.7
    local outlineTrans = 0.3
    
    if isKiller then
        fillTrans = ESPSettings.killerFillTransparency
        outlineTrans = ESPSettings.killerOutlineTransparency
    elseif not isGenerator and not objectType then
        fillTrans = ESPSettings.survivorFillTransparency
        outlineTrans = ESPSettings.survivorOutlineTransparency
    end
    
    local highlight = CreateHighlight(model, color, color, fillTrans, outlineTrans)
    local billboard, textLabel = CreateBillboard(targetPart, model, color)
    
    local espData = {
        Model = model,
        Highlight = highlight,
        Billboard = billboard,
        NameLabel = nil,
        HpLabel = nil,
        IsKiller = isKiller,
        ObjectType = objectType,
        Color = color
    }
    
    if not isGenerator and not objectType then
        local humanoid = model:FindFirstChild("Humanoid")
        
        textLabel.Size = UDim2.new(1, 0, 0.33, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.Text = "加载中..."
        
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.33, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.3, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.Text = "血量: N/A"
        hpLabel.Font = Enum.Font.GothamBlack
        hpLabel.TextColor3 = color
        hpLabel.TextSize = 8
        hpLabel.TextStrokeTransparency = 0.6
        hpLabel.Parent = billboard
        
        espData.NameLabel = textLabel
        espData.HpLabel = hpLabel
        
        UpdatePlayerESP(espData)
        
        local conn1 = model:GetAttributeChangedSignal("ActorDisplayName"):Connect(function()
            UpdatePlayerESP(espData)
        end)
        local conn2 = model:GetAttributeChangedSignal("SkinNameDisplay"):Connect(function()
            UpdatePlayerESP(espData)
        end)
        local conn3 = model:GetAttributeChangedSignal("IsFakeNoli"):Connect(function()
            UpdatePlayerESP(espData)
        end)
        
        espData._connections = {conn1, conn2, conn3}
        
        if humanoid then
            local conn4 = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                UpdatePlayerESP(espData)
            end)
            local conn5 = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                UpdatePlayerESP(espData)
            end)
            table.insert(espData._connections, conn4)
            table.insert(espData._connections, conn5)
        end
    elseif isGenerator then
        textLabel.Size = UDim2.new(1, 0, 0.5, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.Text = "发电机"
        textLabel.Visible = ESPSettings.showGeneratorName
        
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Size = UDim2.new(1, 0, 0.5, 0)
        progressLabel.Position = UDim2.new(0, 0, 0.5, 0)
        progressLabel.BackgroundTransparency = 1
        progressLabel.Text = "进度: 0%"
        progressLabel.Font = Enum.Font.GothamBlack
        progressLabel.TextColor3 = color
        progressLabel.TextSize = 8
        progressLabel.TextStrokeTransparency = 0.6
        progressLabel.Parent = billboard
        
        espData.NameLabel = textLabel
        
        local progress = model:FindFirstChild("Progress")
        if progress then
            local function updateProgress()
                progressLabel.Text = string.format("进度: %d%%", math.floor(progress.Value))
            end
            updateProgress()
            local conn = progress:GetPropertyChangedSignal("Value"):Connect(updateProgress)
            espData._connections = {conn}
        end
    else
        local displayNames = {
            item = "道具",
            pizza = "披萨",
            pizzaDelivery = "披萨送货员",
            zombie = "僵尸",
            taphTripwire = "绊线",
            tripMine = "地雷",
            twoTimeRespawn = "重生点",
            graffiti = "涂鸦",
            folders = "任务文件"
        }
        
        textLabel.Text = displayNames[objectType] or model.Name
        textLabel.Visible = false
        UpdateObjectVisibility(espData)
    end
    
    ESPObjects[model] = espData
    
    local destroyConn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            EspLib.RemoveESP(model)
        end
    end)
    espData._destroyConn = destroyConn
end

function EspLib.RemoveESP(model)
    if not model then return end
    local espData = ESPObjects[model]
    if not espData then return end
    
    if espData._connections then
        for _, conn in ipairs(espData._connections) do
            SafeDestroy(conn)
        end
        espData._connections = nil
    end
    
    if espData._destroyConn then
        SafeDestroy(espData._destroyConn)
        espData._destroyConn = nil
    end
    
    SafeDestroy(espData.Highlight)
    SafeDestroy(espData.Billboard)
    
    espData.Highlight = nil
    espData.Billboard = nil
    espData.Model = nil
    
    ESPObjects[model] = nil
    EspLib.RemoveTracer(model)
end

function EspLib.CreateTracer(model, part, color)
    if not model or not part or not part:IsA("BasePart") then return end
    if ActiveTracers[model] then return end
    
    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = color or Color3.fromRGB(255, 255, 255)
    line.Thickness = 2
    line.Transparency = 1
    
    ActiveTracers[model] = {Line = line, Part = part}
end

function EspLib.RemoveTracer(model)
    local tracerData = ActiveTracers[model]
    if not tracerData then return end
    
    pcall(function()
        tracerData.Line.Visible = false
        tracerData.Line:Remove()
    end)
    ActiveTracers[model] = nil
end

function EspLib.UpdateTracers()
    local viewportSize = Camera.ViewportSize
    local centerX = viewportSize.X / 2
    local bottomY = viewportSize.Y
    
    for model, data in pairs(ActiveTracers) do
        local part = data.Part
        local line = data.Line
        
        if not part or not part.Parent then
            EspLib.RemoveTracer(model)
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            line.Visible = true
            line.From = Vector2.new(centerX, bottomY)
            line.To = Vector2.new(pos.X, pos.Y)
        else
            line.Visible = false
        end
    end
end

function EspLib.UpdateFakeNolis()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    
    for _, killer in killers:GetChildren() do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            killer:SetAttribute("IsFakeNoli", false)
        end
    end
    
    noliByUsername = {}
    for _, killer in killers:GetChildren() do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            local username = killer:GetAttribute("Username")
            if username then
                if not noliByUsername[username] then
                    noliByUsername[username] = {}
                end
                table.insert(noliByUsername[username], killer)
            end
        end
    end
    
    for _, models in pairs(noliByUsername) do
        if #models > 1 then
            for i = 2, #models do
                models[i]:SetAttribute("IsFakeNoli", true)
            end
            models[1]:SetAttribute("IsFakeNoli", false)
        else
            models[1]:SetAttribute("IsFakeNoli", false)
        end
    end
end

function EspLib.AddHighlightAdvanced(obj, config)
    if AdvancedHighlights[obj] then
        SafeDestroy(AdvancedHighlights[obj])
        AdvancedHighlights[obj] = nil
    end
    
    local hl = Instance.new("Highlight")
    hl.Adornee = obj
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = config.Enabled
    hl.OutlineColor = config.Color
    hl.FillColor = config.Color
    hl.OutlineTransparency = 0
    
    local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, obj.Name) ~= nil
    hl.FillTransparency = config.OutlineOnly and not alwaysFill and 1 or (alwaysFill and 0.65 or 1)
    hl.Parent = obj
    
    AdvancedHighlights[obj] = hl
    
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if AdvancedHighlights[obj] then
                SafeDestroy(AdvancedHighlights[obj])
                AdvancedHighlights[obj] = nil
            end
            if AdvancedNametags[obj] then
                SafeDestroy(AdvancedNametags[obj].Parent)
                AdvancedNametags[obj] = nil
            end
        end
    end)
end

function EspLib.HandleAdvanced(obj)
    if table.find(AdvancedNames, obj.Name) or (obj.Name == "Shadow" and obj.Parent and obj.Parent.Name == "Shadows") then
        EspLib.AddHighlightAdvanced(obj, AdvancedSettings)
    end
end

function EspLib.UpdateAdvancedHighlights()
    for obj, hl in pairs(AdvancedHighlights) do
        if not hl or not hl.Parent then
            AdvancedHighlights[obj] = nil
            continue
        end
        
        hl.Enabled = AdvancedSettings.Enabled
        hl.OutlineColor = AdvancedSettings.Color
        hl.FillColor = AdvancedSettings.Color
        hl.OutlineTransparency = 0
        
        local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, obj.Name) ~= nil
        hl.FillTransparency = AdvancedSettings.OutlineOnly and not alwaysFill and 1 or 0.65
        
        if AdvancedSettings.ShowNametag then
            local nametag = AdvancedNametags[obj]
            if not nametag then
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = obj
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Enabled = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = AdvancedSettings.Color
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 6
                textLabel.Text = obj.Name
                textLabel.Parent = billboard
                
                billboard.Parent = obj
                AdvancedNametags[obj] = textLabel
            else
                nametag.TextColor3 = AdvancedSettings.Color
                nametag.Text = obj.Name
            end
        else
            local nametag = AdvancedNametags[obj]
            if nametag then
                SafeDestroy(nametag.Parent)
                AdvancedNametags[obj] = nil
            end
        end
    end
end

local function ProcessPlayerESP(character, isKiller)
    if not character or not character.Parent then return end
    if character == LocalPlayer.Character then return end
    if IsRagdoll(character) then
        EspLib.RemoveESP(character)
        return
    end
    
    local player = Services.Players:GetPlayerFromCharacter(character)
    if not player or IsSpectating(player) then
        EspLib.RemoveESP(character)
        return
    end
    
    local shouldESP = isKiller and ESPSettings.killerESP or ESPSettings.playerESP
    local shouldTracer = isKiller and ESPSettings.killerTracers or ESPSettings.survivorTracers
    local color = isKiller and ESPSettings.killerColor or ESPSettings.survivorColor
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if shouldESP and hrp and not character:FindFirstChild("TAOWARE_Highlight") then
        EspLib.CreateESP(character, color, {isKiller = isKiller})
    elseif not shouldESP then
        EspLib.RemoveESP(character)
    end
    
    if shouldTracer and hrp then
        EspLib.CreateTracer(character, hrp, color)
    else
        EspLib.RemoveTracer(character)
    end
end

local function ProcessGenerators()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame or not ingame:FindFirstChild("Map") then return end
    
    for _, gen in ingame.Map:GetChildren() do
        if not gen:IsA("Model") then continue end
        if not gen.Name:lower():find("generator") then continue end
        if gen.Name == "FakeGenerator" then continue end
        
        local progress = gen:FindFirstChild("Progress")
        local isComplete = progress and progress.Value >= 100
        
        if ESPSettings.generatorESP and not isComplete and not gen:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(gen, ESPSettings.generatorColor, {
                isGenerator = true,
                objectType = "generator"
            })
        elseif not ESPSettings.generatorESP or isComplete then
            EspLib.RemoveESP(gen)
        end
        
        if ESPSettings.generatorTracers and not isComplete then
            local part = GetGeneratorPart(gen)
            if part then
                EspLib.CreateTracer(gen, part, ESPSettings.generatorColor)
            end
        else
            EspLib.RemoveTracer(gen)
        end
    end
end

local function ProcessItems()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame or not ingame:FindFirstChild("Map") then return end
    
    for _, item in ingame.Map:GetDescendants() do
        if item.Name ~= "ItemRoot" then continue end
        if not item.Parent or not item.Parent:IsA("Model") then continue end
        
        local itemModel = item.Parent
        
        if ESPSettings.itemESP and not itemModel:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(itemModel, ESPSettings.itemColor, {objectType = "item"})
        elseif not ESPSettings.itemESP then
            EspLib.RemoveESP(itemModel)
        end
        
        if ESPSettings.itemTracers and item:IsA("BasePart") then
            EspLib.CreateTracer(itemModel, item, ESPSettings.itemColor)
        else
            EspLib.RemoveTracer(itemModel)
        end
    end
end

local function ProcessPizzas()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, pizza in ingame:GetChildren() do
        if pizza.Name ~= "Pizza" or not pizza:IsA("BasePart") then continue end
        
        if ESPSettings.pizzaEsp and not pizza:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(pizza, ESPSettings.pizzaColor, {objectType = "pizza"})
        elseif not ESPSettings.pizzaEsp then
            EspLib.RemoveESP(pizza)
        end
        
        if ESPSettings.pizzaTracers then
            EspLib.CreateTracer(pizza, pizza, ESPSettings.pizzaColor)
        else
            EspLib.RemoveTracer(pizza)
        end
    end
end

local function ProcessDeliveries()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, delivery in ingame:GetChildren() do
        if not delivery:IsA("Model") then continue end
        if not table.find(DummyNames, delivery.Name) then continue end
        
        local hrp = delivery:FindFirstChild("HumanoidRootPart")
        
        if ESPSettings.pizzaDeliveryEsp and hrp and not delivery:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(delivery, ESPSettings.pizzaDeliveryColor, {objectType = "pizzaDelivery"})
        elseif not ESPSettings.pizzaDeliveryEsp then
            EspLib.RemoveESP(delivery)
        end
        
        if ESPSettings.pizzaDeliveryTracers and hrp then
            EspLib.CreateTracer(delivery, hrp, ESPSettings.pizzaDeliveryColor)
        else
            EspLib.RemoveTracer(delivery)
        end
    end
end

local function ProcessZombies()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, zombie in ingame:GetChildren() do
        if zombie.Name ~= "1x1x1x1Zombie" or not zombie:IsA("Model") then continue end
        
        local hrp = zombie:FindFirstChild("HumanoidRootPart")
        
        if ESPSettings.zombieEsp and hrp and not zombie:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(zombie, ESPSettings.zombieColor, {objectType = "zombie"})
        elseif not ESPSettings.zombieEsp then
            EspLib.RemoveESP(zombie)
        end
        
        if ESPSettings.zombieTracers and hrp then
            EspLib.CreateTracer(zombie, hrp, ESPSettings.zombieColor)
        else
            EspLib.RemoveTracer(zombie)
        end
    end
end

local function ProcessSpecialObjects(name, settingESP, settingTracer, color, objectType)
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, obj in ingame:GetChildren() do
        if obj.Name ~= name or not obj:IsA("Model") then continue end
        
        if settingESP and not obj:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(obj, color, {objectType = objectType})
        elseif not settingESP then
            EspLib.RemoveESP(obj)
        end
        
        if settingTracer then
            local part = GetGeneratorPart(obj) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                EspLib.CreateTracer(obj, part, color)
            end
        else
            EspLib.RemoveTracer(obj)
        end
    end
end

local function ProcessRespawns()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, obj in ingame:GetDescendants() do
        if not obj or not obj.Name then continue end
        if not obj.Name:lower():find("respawnlocation") then continue end
        
        local target = obj:IsA("Model") and obj or obj:IsA("BasePart") and obj
        if not target then continue end
        if IsRagdoll(target) then continue end
        
        if ESPSettings.twoTimeRespawnEsp and not target:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(target, ESPSettings.twoTimeRespawnColor, {objectType = "twoTimeRespawn"})
        elseif not ESPSettings.twoTimeRespawnEsp then
            EspLib.RemoveESP(target)
        end
        
        if ESPSettings.twoTimeRespawnTracers then
            local part = target:IsA("Model") and (GetGeneratorPart(target) or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)) or target
            if part then
                EspLib.CreateTracer(target, part, ESPSettings.twoTimeRespawnColor)
            end
        else
            EspLib.RemoveTracer(target)
        end
    end
end

local function ProcessGraffiti()
    local ingame = Services.Workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
    if not ingame then return end
    
    for _, obj in ingame:GetChildren() do
        if obj.Name ~= "GraffitiCL" or not obj:IsA("BasePart") then continue end
        
        if ESPSettings.graffitiEsp and not obj:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(obj, ESPSettings.graffitiColor, {objectType = "graffiti"})
        elseif not ESPSettings.graffitiEsp then
            EspLib.RemoveESP(obj)
        end
    end
end

local function ProcessFolders()
    for _, folder in Services.Workspace:GetChildren() do
        if not folder:IsA("MeshPart") or folder.Name ~= "Model" then continue end
        
        if ESPSettings.foldersEsp and not folder:FindFirstChild("TAOWARE_Highlight") then
            EspLib.CreateESP(folder, ESPSettings.foldersColor, {objectType = "folders"})
        elseif not ESPSettings.foldersEsp then
            EspLib.RemoveESP(folder)
        end
    end
end

function EspLib.UpdateESP()
    if not Services.Workspace:FindFirstChild("Map") or not Services.Workspace.Map:FindFirstChild("Ingame") then
        for model in pairs(ESPObjects) do
            EspLib.RemoveESP(model)
        end
        for model in pairs(ActiveTracers) do
            EspLib.RemoveTracer(model)
        end
        return
    end
    
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            for _, killer in killers:GetChildren() do
                ProcessPlayerESP(killer, true)
            end
        end
        
        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in survivors:GetChildren() do
                ProcessPlayerESP(survivor, false)
            end
        end
    end
    
    ProcessGenerators()
    ProcessItems()
    ProcessPizzas()
    ProcessDeliveries()
    ProcessZombies()
    ProcessSpecialObjects("TaphTripwire", ESPSettings.taphTripwireEsp, ESPSettings.taphTripwireTracers, ESPSettings.taphTripwireColor, "taphTripwire")
    ProcessSpecialObjects("SubspaceTripmine", ESPSettings.tripMineEsp, ESPSettings.tripMineTracers, ESPSettings.tripMineColor, "tripMine")
    ProcessRespawns()
    ProcessGraffiti()
    ProcessFolders()
end

function EspLib.UpdateAllPlayerText()
    for _, espData in pairs(ESPObjects) do
        if espData.IsKiller ~= nil then
            UpdatePlayerESP(espData)
        end
    end
end

function EspLib.UpdateObjectNames()
    for _, espData in pairs(ESPObjects) do
        if espData.ObjectType ~= "" then
            UpdateObjectVisibility(espData)
        end
    end
end

function EspLib.GetSettings()
    return ESPSettings
end

function EspLib.GetAdvancedSettings()
    return AdvancedSettings
end

function EspLib.StartLoop()
    task.spawn(function()
        while true do
            EspLib.UpdateESP()
            EspLib.UpdateFakeNolis()
            task.wait(0.5)
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        EspLib.UpdateTracers()
    end)
    
    for _, v in MapFolder:GetDescendants() do
        EspLib.HandleAdvanced(v)
    end
    
    MapFolder.DescendantAdded:Connect(function(v)
        EspLib.HandleAdvanced(v)
    end)
    
    task.spawn(function()
        while true do
            EspLib.UpdateAdvancedHighlights()
            task.wait(0.3)
        end
    end)
end

return EspLib