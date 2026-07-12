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

local ESPSettings = {
    generatorESP = false, itemESP = false,
    pizzaEsp = false, pizzaDeliveryEsp = false, zombieEsp = false, taphTripwireEsp = false,
    tripMineEsp = false, twoTimeRespawnEsp = false, graffitiEsp = false, foldersEsp = false,
    generatorColor = Color3.fromRGB(200, 100, 200), itemColor = Color3.fromRGB(200, 200, 0),
    pizzaColor = Color3.fromRGB(200, 150, 0), pizzaDeliveryColor = Color3.fromRGB(200, 100, 100),
    zombieColor = Color3.fromRGB(200, 100, 100), taphTripwireColor = Color3.fromRGB(100, 0, 100),
    tripMineColor = Color3.fromRGB(255, 0, 255), twoTimeRespawnColor = Color3.fromRGB(0, 150, 200),
    graffitiColor = Color3.fromRGB(255, 255, 255), foldersColor = Color3.fromRGB(255, 204, 51)
}

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2",
    "Mafia3", "Mafia4", "Mafia5", "Mafia6", "Mafia7", "Mafia8", "Mafia9",
    "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy", "PinkGuy", "YellowGuy",
    "OrangeGuy", "GreyGuy"
}

local ObjectESPData = {}
local TracerData = {}
local Highlights = {}
local Nametags = {}

local AdvancedSettings = {Enabled = false, OutlineOnly = true, ShowNametag = false, Color = Color3.fromRGB(0, 255, 255)}
local AdvancedNames = {"BuildermanDispenser","BuildermanSentry","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}

local AlertData = {NST = {connection = nil}, NEK = {connection = nil}}

local function IsRagdoll(model)
    local ragdolls = Services.Workspace:FindFirstChild("Ragdolls")
    if not ragdolls then return false end
    return model:IsDescendantOf(ragdolls) or (model.Parent == ragdolls)
end

local function GetGeneratorPart(model)
    if not model then return nil end
    local instances = model:FindFirstChild("Instances")
    if instances then
        local generator = instances:FindFirstChild("Generator")
        if generator then
            local cube = generator:FindFirstChild("Cube.003")
            if cube and cube:IsA("BasePart") then return cube end
            for _, v in ipairs(generator:GetDescendants()) do if v:IsA("BasePart") then return v end end
        end
        for _, v in ipairs(instances:GetDescendants()) do
            if v:IsA("BasePart") and tostring(v.Name):lower():find("cube") then return v end
        end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("cube") then return v end
    end
    for _, v in ipairs(model:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function UpdateGeneratorProgress(data)
    if not data or not data.model or not data.progressLabel then return end
    local progress = data.model:FindFirstChild("Progress")
    if progress then data.progressLabel.Text = string.format("Progress: %d%%", math.floor(progress.Value)) end
end

local function CreateNametag(adornee, text, color)
    if Nametags[adornee] then pcall(function() Nametags[adornee].Parent:Destroy() end); Nametags[adornee] = nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee; billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true; billboard.Enabled = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.Text = text
    textLabel.TextColor3 = color; textLabel.TextStrokeTransparency = 0; textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 6; textLabel.Parent = billboard
    billboard.Parent = adornee; Nametags[adornee] = textLabel
end

local function CreateESP(model, color, isGenerator, isItem, isPizza, isPizzaDelivery, isZombie, isTaph, isTripMine, isRespawn, isGraffiti, isFolders)
    if not model then return end
    if model:FindFirstChild("TAOWARE_Highlight") then return end
    if isGenerator and model:FindFirstChild("Progress") and model.Progress.Value == 100 then return end
    if IsRagdoll(model) then return end

    local targetPart
    if isGenerator then targetPart = GetGeneratorPart(model)
    elseif isItem then targetPart = model:FindFirstChild("ItemRoot")
    elseif isPizza or isPizzaDelivery or isZombie or isGraffiti or isFolders then targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    elseif isTaph or isTripMine or isRespawn then targetPart = model:IsA("Model") and (GetGeneratorPart(model) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or model
    end

    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TAOWARE_Highlight"; highlight.Adornee = model; highlight.FillColor = color; highlight.OutlineColor = color
    highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0.3
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TAOWARE_Billboard"; billboard.Adornee = targetPart; billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0); billboard.AlwaysOnTop = true; billboard.Parent = model

    if isGenerator then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0); nameLabel.Position = UDim2.new(0, 0, 0, 0); nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Generator"; nameLabel.Font = Enum.Font.GothamBlack; nameLabel.TextColor3 = color
        nameLabel.TextSize = 8; nameLabel.TextStrokeTransparency = 0.6; nameLabel.Parent = billboard
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Size = UDim2.new(1, 0, 0.5, 0); progressLabel.Position = UDim2.new(0, 0, 0.5, 0); progressLabel.BackgroundTransparency = 1
        progressLabel.Text = "Progress: 0%"; progressLabel.Font = Enum.Font.GothamBlack; progressLabel.TextColor3 = color
        progressLabel.TextSize = 8; progressLabel.TextStrokeTransparency = 0.6; progressLabel.Parent = billboard
        local espData = {model = model, nameLabel = nameLabel, progressLabel = progressLabel, highlight = highlight, billboard = billboard}
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
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1; textLabel.Text = displayName
        textLabel.Font = Enum.Font.GothamBlack; textLabel.TextColor3 = color; textLabel.TextSize = 8
        textLabel.TextStrokeTransparency = 0.6; textLabel.Parent = billboard
        table.insert(ObjectESPData, {model = model, highlight = highlight, billboard = billboard, type = displayName})
    end
end

local function RemoveESP(model)
    if not model then return end
    for i = #ObjectESPData, 1, -1 do if ObjectESPData[i].model == model then table.remove(ObjectESPData, i) end end
    pcall(function()
        if model:FindFirstChild("TAOWARE_Highlight") then model.TAOWARE_Highlight:Destroy() end
        if model:FindFirstChild("TAOWARE_Billboard") then model.TAOWARE_Billboard:Destroy() end
    end)
end

local function CreateTracer(model, part, color)
    if not model or not part or not part:IsA("BasePart") then return end
    if TracerData[model] then return end
    local line = Drawing.new("Line")
    line.Visible = true; line.Color = color or Color3.fromRGB(255, 255, 255); line.Thickness = 2; line.Transparency = 1
    TracerData[model] = {line = line, part = part}
end

local function RemoveTracer(model)
    if TracerData[model] then pcall(function() TracerData[model].line.Visible = false; TracerData[model].line:Remove() end); TracerData[model] = nil end
end

local function UpdateTracers()
    for model, data in pairs(TracerData) do
        local line, part = data.line, data.part
        if line and part and part.Parent then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then line.Visible = true; line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); line.To = Vector2.new(pos.X, pos.Y)
            else line.Visible = false end
        else RemoveTracer(model) end
    end
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

local function HandleAdvanced(obj)
    if table.find(AdvancedNames, obj.Name) or (obj.Name == "Shadow" and obj.Parent and obj.Parent.Name == "Shadows") then
        AddHighlightAdvanced(obj, AdvancedSettings)
    end
end

for _, v in ipairs(MapFolder:GetDescendants()) do HandleAdvanced(v) end
MapFolder.DescendantAdded:Connect(HandleAdvanced)

local function UpdateAdvancedHighlights()
    for obj, hl in pairs(Highlights) do
        if not hl or not hl.Parent then continue end
        hl.Enabled = AdvancedSettings.Enabled; hl.OutlineColor = AdvancedSettings.Color; hl.FillColor = AdvancedSettings.Color
        hl.OutlineTransparency = 0; hl.FillTransparency = AdvancedSettings.OutlineOnly and 1 or 0.65
        if AdvancedSettings.ShowNametag then
            local nameText = obj.Name
            if Nametags[obj] then Nametags[obj].Text = nameText; Nametags[obj].TextColor3 = AdvancedSettings.Color
            else CreateNametag(obj, nameText, AdvancedSettings.Color) end
        else if Nametags[obj] then pcall(function() Nametags[obj].Parent:Destroy() end); Nametags[obj] = nil end
        end
    end
end

local function UpdateESP()
    local mapFolder = Services.Workspace:FindFirstChild("Map")
    if not mapFolder or not mapFolder:FindFirstChild("Ingame") then
        for i = #ObjectESPData, 1, -1 do RemoveESP(ObjectESPData[i].model) end
        for model in pairs(TracerData) do RemoveTracer(model) end
        return
    end
    local ingame = mapFolder.Ingame
    
    if ingame:FindFirstChild("Map") then
        for _, gen in ipairs(ingame.Map:GetChildren()) do
            if gen:IsA("Model") and gen.Name:lower():find("generator") and gen.Name ~= "FakeGenerator" then
                if IsRagdoll(gen) then RemoveESP(gen); RemoveTracer(gen); continue end
                local progress = gen:FindFirstChild("Progress")
                if ESPSettings.generatorESP and progress and progress.Value < 100 and not gen:FindFirstChild("TAOWARE_Highlight") then CreateESP(gen, ESPSettings.generatorColor, true, false, false, false, false, false, false, false, false, false)
                elseif not ESPSettings.generatorESP or (progress and progress.Value >= 100) then RemoveESP(gen) end
            end
        end
        for _, item in ipairs(ingame.Map:GetDescendants()) do
            if item.Name == "ItemRoot" and item.Parent and item.Parent:IsA("Model") then
                local itemModel = item.Parent
                if ESPSettings.itemESP and not itemModel:FindFirstChild("TAOWARE_Highlight") then CreateESP(itemModel, ESPSettings.itemColor, false, true, false, false, false, false, false, false, false, false)
                elseif not ESPSettings.itemESP then RemoveESP(itemModel) end
            end
        end
    end
    
    for _, pizza in ipairs(ingame:GetChildren()) do
        if pizza.Name == "Pizza" and pizza:IsA("BasePart") then
            if ESPSettings.pizzaEsp and not pizza:FindFirstChild("TAOWARE_Highlight") then CreateESP(pizza, ESPSettings.pizzaColor, false, false, true, false, false, false, false, false, false, false)
            elseif not ESPSettings.pizzaEsp then RemoveESP(pizza) end
        end
    end
    
    for _, delivery in ipairs(ingame:GetChildren()) do
        if delivery:IsA("Model") and table.find(DummyNames, delivery.Name) then
            if ESPSettings.pizzaDeliveryEsp and not delivery:FindFirstChild("TAOWARE_Highlight") and delivery:FindFirstChild("HumanoidRootPart") then CreateESP(delivery, ESPSettings.pizzaDeliveryColor, false, false, false, true, false, false, false, false, false, false)
            elseif not ESPSettings.pizzaDeliveryEsp then RemoveESP(delivery) end
        end
    end
    
    for _, zombie in ipairs(ingame:GetChildren()) do
        if zombie.Name == "1x1x1x1Zombie" and zombie:IsA("Model") then
            if ESPSettings.zombieEsp and not zombie:FindFirstChild("TAOWARE_Highlight") and zombie:FindFirstChild("HumanoidRootPart") then CreateESP(zombie, ESPSettings.zombieColor, false, false, false, false, true, false, false, false, false, false)
            elseif not ESPSettings.zombieEsp then RemoveESP(zombie) end
        end
    end
    
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name:match("TaphTripwire$") and obj:IsA("Model") then
            if ESPSettings.taphTripwireEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.taphTripwireColor, false, false, false, false, false, true, false, false, false, false)
            elseif not ESPSettings.taphTripwireEsp then RemoveESP(obj) end
        end
        if obj.Name == "SubspaceTripmine" and obj:IsA("Model") then
            if ESPSettings.tripMineEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.tripMineColor, false, false, false, false, false, false, true, false, false, false)
            elseif not ESPSettings.tripMineEsp then RemoveESP(obj) end
        end
        if obj.Name == "GraffitiCL" and obj:IsA("BasePart") then
            if ESPSettings.graffitiEsp and not obj:FindFirstChild("TAOWARE_Highlight") then CreateESP(obj, ESPSettings.graffitiColor, false, false, false, false, false, false, false, false, true, false)
            elseif not ESPSettings.graffitiEsp then RemoveESP(obj) end
        end
    end
    
    for _, obj in ipairs(ingame:GetDescendants()) do
        if obj and obj.Name and tostring(obj.Name):lower():find("respawnlocation") then
            local target = obj:IsA("Model") and obj or obj:IsA("BasePart") and obj or (obj:FindFirstAncestorOfClass("Model") or obj)
            if not target or IsRagdoll(target) then continue end
            if ESPSettings.twoTimeRespawnEsp and not target:FindFirstChild("TAOWARE_Highlight") then CreateESP(target, ESPSettings.twoTimeRespawnColor, false, false, false, false, false, false, false, true, false, false)
            elseif not ESPSettings.twoTimeRespawnEsp then RemoveESP(target) end
        end
    end
    
    for _, folder in ipairs(Services.Workspace:GetChildren()) do
        if folder:IsA("MeshPart") and folder.Name == "Model" then
            if ESPSettings.foldersEsp and not folder:FindFirstChild("TAOWARE_Highlight") then CreateESP(folder, ESPSettings.foldersColor, false, false, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.foldersEsp then RemoveESP(folder) end
        end
    end
end

task.spawn(function() while task.wait(3) do UpdateESP() end end)
RunService.RenderStepped:Connect(UpdateTracers)
task.spawn(function() while task.wait(2) do UpdateAdvancedHighlights() end end)

function EspLib.GetSettings() return ESPSettings end
function EspLib.GetAdvancedSettings() return AdvancedSettings end

function EspLib.SetNSTAlert(state, Library)
    if AlertData.NST.connection then AlertData.NST.connection:Disconnect(); AlertData.NST.connection = nil end
    if state then AlertData.NST.connection = Services.Workspace.Map.Ingame.DescendantAdded:Connect(function(v) if v.Name == "SubspaceTripmine" and Library and Library.Notify then Library:Notify("Tripmine spawned!") end end) end
end

function EspLib.SetNEKAlert(state, Library)
    if AlertData.NEK.connection then AlertData.NEK.connection:Disconnect(); AlertData.NEK.connection = nil end
    if state then AlertData.NEK.connection = Services.Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") and (v.Name == "PizzaDeliveryRig" or v.Name == "Mafia1" or v.Name == "Mafia2" or v.Name == "Mafia3" or v.Name == "Mafia4") then if Library and Library.Notify then Library:Notify("Entity '" .. v.Name .. "' spawned!") end
        elseif v:IsA("Model") and v.Name == "1x1x1x1Zombie" then if Library and Library.Notify then Library:Notify("Zombie spawned!") end end
    end) end
end

function EspLib.Cleanup()
    if AlertData.NST.connection then AlertData.NST.connection:Disconnect(); AlertData.NST.connection = nil end
    if AlertData.NEK.connection then AlertData.NEK.connection:Disconnect(); AlertData.NEK.connection = nil end
end

return EspLib
