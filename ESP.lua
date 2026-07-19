local EuphoriaESP = {}

local Services = {
    Workspace = cloneref(game:GetService("Workspace")),
    RunService = cloneref(game:GetService("RunService")),
    Players = cloneref(game:GetService("Players")),
    CoreGui = game:GetService("CoreGui"),
    Lighting = cloneref(game:GetService("Lighting"))
}

local Workspace, RunService, Players, CoreGui, Lighting = Services.Workspace, Services.RunService, Services.Players, Services.CoreGui, Services.Lighting
local lplayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local Cam = camera

local ESP = {
    Enabled = true,
    MaxDistance = 200,
    FontSize = 11,
    FadeOut = {
        OnDistance = true,
        OnDeath = false,
        OnLeave = false,
    },
    Options = { 
        Friendcheck = true, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            Enabled = true,
            KillerEnabled = true,
            SurvivorEnabled = true,
            Thermal = false,
            FillRGB = Color3.fromRGB(119, 120, 255),
            Fill_Transparency = 50,
            OutlineRGB = Color3.fromRGB(119, 120, 255),
            Outline_Transparency = 50,
            VisibleCheck = false,
            KillerColor = Color3.fromRGB(150, 0, 255),
            SurvivorColor = Color3.fromRGB(0, 255, 255),
        },
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
            KillerShow = true,
            SurvivorShow = true,
            ShowSkin = false,
            ShowUsername = false,
        },
        -- 状态标签配置（已改为英文）
        StatusLabel = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 200, 0),
            InvincibleText = "[Unhittable]",
            StunnedDisabledText = "[Stun Immune]",
        },
        Flags = {Enabled = false},
        Distances = {Enabled = true, RGB = Color3.fromRGB(255, 255, 255)},
        Healthbar = {
            Enabled = true, 
            HealthText = false,
            Lerp = false, 
            HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 1.5,
            KillerDefaultColor = Color3.fromRGB(255, 0, 0),
            SurvivorDefaultColor = Color3.fromRGB(0, 255, 0),
        },
        Boxes = {
            Animate = false, RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(119, 120, 255), GradientRGB2 = Color3.fromRGB(0, 0, 0), 
            GradientFill = false, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0), 
            Filled = {Enabled = false, Transparency = 0.75, RGB = Color3.fromRGB(0, 0, 0)},
            Full = {Enabled = false, RGB = Color3.fromRGB(255, 255, 255)},
            Corner = {Enabled = false, RGB = Color3.fromRGB(255, 255, 255)},
        },
    },
    Connections = {RunService = RunService},
    Fonts = {},
}

local Euphoria = ESP.Connections
local RotationAngle, Tick = -45, tick()
local ScreenGui = nil

local function IsKiller(plr)
    if not plr or not plr.Character then return false end
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers and plr.Character:IsDescendantOf(killers) then return true end
    end
    if plr.Team and plr.Team.Name == "Killers" then return true end
    return false
end

local function IsSurvivor(plr)
    if plr == lplayer then return false end
    if IsKiller(plr) then return false end
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors and plr.Character and plr.Character:IsDescendantOf(survivors) then return true end
    end
    if plr.Team and plr.Team.Name == "Survivors" then return true end
    return false
end

local function GetRoleName(plr)
    if not plr or not plr.Character then return "" end
    local actorName = plr.Character:GetAttribute("ActorDisplayName")
    if actorName and actorName ~= "" then return actorName end
    return ""
end

local function GetSkinName(plr)
    if not plr or not plr.Character then return "" end
    local skinName = plr.Character:GetAttribute("SkinNameDisplay")
    if skinName and skinName ~= "" then return skinName end
    return ""
end

local function IsFakeNoli(plr)
    if not plr or not plr.Character then return false end
    if plr.Character:GetAttribute("ActorDisplayName") == "Noli" and plr.Character:GetAttribute("IsFakeNoli") == true then return true end
    return false
end

local function UpdateFakeNolis()
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then killer:SetAttribute("IsFakeNoli", false) end
    end
    local noliByUsername = {}
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
        if #models > 1 then for i = 2, #models do models[i]:SetAttribute("IsFakeNoli", true) end end
    end
end

local Functions = {}
function Functions.Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do _Instance[Property] = Value end
    return _Instance
end

function Functions.FadeOutOnDist(element, distance)
    local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
    if element:IsA("TextLabel") then element.TextTransparency = 1 - transparency
    elseif element:IsA("ImageLabel") then element.ImageTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then element.BackgroundTransparency = 1 - transparency
    elseif element:IsA("Highlight") then 
        element.FillTransparency = 1 - transparency
        element.OutlineTransparency = 1 - transparency 
    end
end

local function CreateESPForPlayer(plr)
    if ScreenGui:FindFirstChild(plr.Name) then ScreenGui[plr.Name]:Destroy() end
    local RoleName = Functions.Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -35), Size = UDim2.new(0, 200, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 0), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    local Name = Functions.Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 200, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    local Distance = Functions.Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 200, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
    
    local StatusLabel = Functions.Create("TextLabel", {
        Parent = ScreenGui, 
        Position = UDim2.new(0.5, 0, 0, -23), 
        Size = UDim2.new(0, 200, 0, 20), 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundTransparency = 1, 
        TextColor3 = ESP.Drawing.StatusLabel.RGB, 
        Font = Enum.Font.Code, 
        TextSize = ESP.FontSize, 
        TextStrokeTransparency = 0, 
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
        RichText = true,
        Visible = false
    })
    
    local Box = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
    local Gradient1 = Functions.Create("UIGradient", {Parent = Box, Enabled = ESP.Drawing.Boxes.GradientFill, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)}})
    local Outline = Functions.Create("UIStroke", {Parent = Box, Enabled = ESP.Drawing.Boxes.Gradient, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
    local Gradient2 = Functions.Create("UIGradient", {Parent = Outline, Enabled = ESP.Drawing.Boxes.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)}})
    local Healthbar = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
    local BehindHealthbar = Functions.Create("Frame", {Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
    local HealthText = Functions.Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 200, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
    local Chams = Functions.Create("Highlight", {Parent = ScreenGui, FillTransparency = 1, OutlineTransparency = 0, OutlineColor = Color3.fromRGB(119, 120, 255), DepthMode = "Occluded"})
    local LeftTop = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local LeftSide = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local RightTop = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local RightSide = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local BottomSide = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local BottomDown = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local BottomRightSide = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})
    local BottomRightDown = Functions.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB})

    local Connection
    local function HideESP()
        Box.Visible = false; RoleName.Visible = false; Name.Visible = false; Distance.Visible = false
        Healthbar.Visible = false; BehindHealthbar.Visible = false; HealthText.Visible = false
        LeftTop.Visible = false; LeftSide.Visible = false; BottomSide.Visible = false; BottomDown.Visible = false
        RightTop.Visible = false; RightSide.Visible = false; BottomRightSide.Visible = false; BottomRightDown.Visible = false
        Chams.Enabled = false
        StatusLabel.Visible = false
        if not plr then if ScreenGui then ScreenGui:Destroy() end; if Connection then Connection:Disconnect() end end
    end

    Connection = Euphoria.RunService.RenderStepped:Connect(function()
        if IsFakeNoli(plr) then HideESP(); return end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local Humanoid = plr.Character:FindFirstChild("Humanoid")
            if not Humanoid then return end
            local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
            local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
            if OnScreen and Dist <= ESP.MaxDistance then
                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                if ESP.FadeOut.OnDistance then
                    Functions.FadeOutOnDist(Box, Dist); Functions.FadeOutOnDist(Outline, Dist)
                    Functions.FadeOutOnDist(RoleName, Dist); Functions.FadeOutOnDist(Name, Dist)
                    Functions.FadeOutOnDist(Distance, Dist); Functions.FadeOutOnDist(Healthbar, Dist)
                    Functions.FadeOutOnDist(BehindHealthbar, Dist); Functions.FadeOutOnDist(HealthText, Dist)
                    Functions.FadeOutOnDist(LeftTop, Dist); Functions.FadeOutOnDist(LeftSide, Dist)
                    Functions.FadeOutOnDist(BottomSide, Dist); Functions.FadeOutOnDist(BottomDown, Dist)
                    Functions.FadeOutOnDist(RightTop, Dist); Functions.FadeOutOnDist(RightSide, Dist)
                    Functions.FadeOutOnDist(BottomRightSide, Dist); Functions.FadeOutOnDist(BottomRightDown, Dist)
                    Functions.FadeOutOnDist(Chams, Dist)
                    Functions.FadeOutOnDist(StatusLabel, Dist)
                end

                local isKiller = IsKiller(plr)
                local isSurvivor = IsSurvivor(plr)

                if (isKiller or isSurvivor) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                    -- Chams
                    Chams.Adornee = plr.Character
                    local shouldShowChams = false
                    if ESP.Drawing.Chams.Enabled then
                        if isKiller and ESP.Drawing.Chams.KillerEnabled then shouldShowChams = true
                        elseif isSurvivor and ESP.Drawing.Chams.SurvivorEnabled then shouldShowChams = true end
                    end
                    Chams.Enabled = shouldShowChams
                    if shouldShowChams then
                        if isKiller then 
                            Chams.FillColor = ESP.Drawing.Chams.KillerColor
                            Chams.OutlineColor = ESP.Drawing.Chams.KillerColor
                        elseif isSurvivor then 
                            Chams.FillColor = ESP.Drawing.Chams.SurvivorColor
                            Chams.OutlineColor = ESP.Drawing.Chams.SurvivorColor
                        end
                        local fillTrans = ESP.Drawing.Chams.Fill_Transparency / 100
                        local outlineTrans = ESP.Drawing.Chams.Outline_Transparency / 100
                        if ESP.Drawing.Chams.Thermal then
                            local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
                            fillTrans = fillTrans * breathe_effect
                            outlineTrans = outlineTrans * breathe_effect
                        end
                        Chams.FillTransparency = fillTrans
                        Chams.OutlineTransparency = outlineTrans
                    end
                    Chams.DepthMode = ESP.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"

                    -- Corner Box
                    LeftTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2); LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
                    LeftSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2); LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
                    BottomSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2); BottomSide.Size = UDim2.new(0, 1, 0, h / 5); BottomSide.AnchorPoint = Vector2.new(0, 5)
                    BottomDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2); BottomDown.Size = UDim2.new(0, w / 5, 0, 1); BottomDown.AnchorPoint = Vector2.new(0, 1)
                    RightTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2); RightTop.Size = UDim2.new(0, w / 5, 0, 1); RightTop.AnchorPoint = Vector2.new(1, 0)
                    RightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2); RightSide.Size = UDim2.new(0, 1, 0, h / 5); RightSide.AnchorPoint = Vector2.new(0, 0)
                    BottomRightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2); BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5); BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                    BottomRightDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                    BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2); BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1); BottomRightDown.AnchorPoint = Vector2.new(1, 1)

                    -- Full Box
                    Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2); Box.Size = UDim2.new(0, w, 0, h)
                    Box.Visible = ESP.Drawing.Boxes.Full.Enabled
                    if ESP.Drawing.Boxes.Filled.Enabled then
                        Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        Box.BackgroundTransparency = ESP.Drawing.Boxes.GradientFill and ESP.Drawing.Boxes.Filled.Transparency or 1
                        Box.BorderSizePixel = 1
                    else Box.BackgroundTransparency = 1 end
                    RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                    if ESP.Drawing.Boxes.Animate then Gradient1.Rotation = RotationAngle; Gradient2.Rotation = RotationAngle
                    else Gradient1.Rotation = -45; Gradient2.Rotation = -45 end
                    Tick = tick()

                    -- Healthbar
                    local health = Humanoid.Health / Humanoid.MaxHealth
                    Healthbar.Visible = ESP.Drawing.Healthbar.Enabled
                    Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))
                    Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)
                    BehindHealthbar.Visible = ESP.Drawing.Healthbar.Enabled
                    BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)
                    BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)
                    if isKiller then Healthbar.BackgroundColor3 = ESP.Drawing.Healthbar.KillerDefaultColor
                    elseif isSurvivor then Healthbar.BackgroundColor3 = ESP.Drawing.Healthbar.SurvivorDefaultColor end
                    if ESP.Drawing.Healthbar.HealthText then
                        local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                        HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - healthPercentage / 100) + 3)
                        HealthText.Text = tostring(healthPercentage)
                        HealthText.Visible = Humanoid.Health < Humanoid.MaxHealth
                        HealthText.TextColor3 = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    end

                    -- Role Name
                    local roleName = GetRoleName(plr)
                    local skinName = GetSkinName(plr)
                    local shouldShowRole = false
                    if isKiller and ESP.Drawing.Names.KillerShow then shouldShowRole = true
                    elseif isSurvivor and ESP.Drawing.Names.SurvivorShow then shouldShowRole = true end
                    if roleName ~= "" and shouldShowRole then
                        RoleName.Visible = true
                        if ESP.Drawing.Names.ShowSkin and skinName ~= "" then
                            RoleName.Text = string.format("%s | %s", roleName, skinName)
                        else
                            RoleName.Text = roleName
                        end
                        RoleName.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 35)
                        RoleName.TextColor3 = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255)
                    else RoleName.Visible = false end

                    -- 杀手状态标签（英文）
                    if ESP.Drawing.StatusLabel.Enabled and isKiller then
                        local invincible = plr.Character:GetAttribute("Invincible")
                        local stunnedDisabled = plr.Character:GetAttribute("StunnedDisabled")
                        local statuses = {}
                        if invincible == 1 or invincible == true then
                            table.insert(statuses, ESP.Drawing.StatusLabel.InvincibleText)
                        end
                        if stunnedDisabled == 1 or stunnedDisabled == true then
                            table.insert(statuses, ESP.Drawing.StatusLabel.StunnedDisabledText)
                        end
                        
                        if #statuses > 0 then
                            StatusLabel.Text = table.concat(statuses, " ")
                            StatusLabel.TextColor3 = ESP.Drawing.StatusLabel.RGB
                            StatusLabel.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 23)
                            StatusLabel.Visible = true
                        else
                            StatusLabel.Visible = false
                        end
                    else
                        StatusLabel.Visible = false
                    end

                    -- Username
                    local shouldShowName = false
                    if ESP.Drawing.Names.Enabled and ESP.Drawing.Names.ShowUsername then
                        if isKiller and ESP.Drawing.Names.KillerShow then shouldShowName = true
                        elseif isSurvivor and ESP.Drawing.Names.SurvivorShow then shouldShowName = true end
                    end
                    Name.Visible = shouldShowName
                    if shouldShowName then
                        local roleTag = isKiller and "K" or "S"
                        local roleColor = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255)
                        Name.Text = string.format('(<font color="rgb(%d, %d, %d)">%s</font>) %s', roleColor.R * 255, roleColor.G * 255, roleColor.B * 255, roleTag, plr.Name)
                        Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 11)
                    end

                    -- Distance
                    if ESP.Drawing.Distances.Enabled then
                        Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                        Distance.Text = string.format("%d meters", math.floor(Dist))
                        Distance.Visible = true
                    else Distance.Visible = false end
                else HideESP() end
            else HideESP() end
        else HideESP() end
    end)
end

function EuphoriaESP.Start()
    if ScreenGui then ScreenGui:Destroy() end
    ScreenGui = Functions.Create("ScreenGui", {Parent = CoreGui, Name = "ESPHolder", ResetOnSpawn = false})
    task.spawn(function() while task.wait(0.5) do UpdateFakeNolis() end end)
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= lplayer.Name then CreateESPForPlayer(v) end
    end
    Players.PlayerAdded:Connect(function(v) CreateESPForPlayer(v) end)
end

function EuphoriaESP.Stop()
    if ScreenGui then ScreenGui:Destroy(); ScreenGui = nil end
end

function EuphoriaESP.GetSettings() return ESP end

return EuphoriaESP
