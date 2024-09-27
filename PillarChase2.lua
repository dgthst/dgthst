-- Libraries

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Pillar Chase 2", HidePremium = false, Intro = false, IntroText = "SIGMA ™", SaveConfig = false, ConfigFolder = "PC2Config"})

-- Services

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer.PlayerGui

local ESP_Player = false
local ESP_ShowHealth = false
local ESP_ShowDistance = false
local ESP_ShowIcon = false

local ESP_Item = false
local ESP_ShowItemName = false

local ESP_Objective = false
local ESP_ShowObjectiveName = false

local ESP_Ability = false
local ESP_ShowAbilityName = false

local VISUAL_AntiDebris = false
local VISUAL_Fullbright = false

local ABILITY_AutoJumpMX = false

local OBJECTIVE_IncreaseInteractDistance = false

local ITEM_IncreaseInteractDistance = false

local AUTOFARM_MaxCoins = false
local AUTOFARM_AutoMove = false

local OTHER_MuteLobbyRadio = false

local autoJumpMX_Connection = nil

-- Functions

function RemoveESP(model)
    if model then
        local oldHighlight = model:FindFirstChild("espHighlight", true)
        if oldHighlight then oldHighlight:Destroy() end

        local oldName = model:FindFirstChild("espName", true)
        if oldName then oldName:Destroy() end
    
        local oldHealth = model:FindFirstChild("espHealth", true)
        if oldHealth then oldHealth:Destroy() end

        local oldDistance = model:FindFirstChild("espDistance", true)
        if oldDistance then oldDistance:Destroy() end

        local oldIcon = model:FindFirstChild("espIcon", true)
        if oldIcon then oldIcon:Destroy() end
    end
end

function StartPlayerESP()
    while ESP_Player == true do
        for _, player in Players:GetPlayers() do
            if player == localPlayer then continue end

            local character = player.Character

            RemoveESP(character)

            if character then
                local playerIsSurvivor = character:FindFirstChild("Alive")
                local playerIsKiller = character:FindFirstChild("MonsterNameValue")

                if playerIsSurvivor then
                    AddPlayerESP(character, Color3.fromRGB(255,255,255), true)
                elseif playerIsKiller then
                    AddPlayerESP(character, Color3.fromRGB(255,0,0), false)
                end
            end
        end
    
        task.wait(0.1)
    end
end

function StartItemESP()
    while ESP_Item == true do
        for _, itemModel in workspace.Server.PickUps:GetChildren() do
            RemoveESP(itemModel)
            AddItemESP(itemModel)
        end
    
        task.wait(0.2)
    end
end

function StartObjectiveESP()
    while ESP_Objective == true do
        local currentObjectives = GetCurrentObjectives()

        for _, objectiveModel in pairs(currentObjectives) do
            RemoveESP(objectiveModel)

            if not objectiveModel:FindFirstChild("ObjectivePrompt", true) then continue end

            AddObjectiveESP(objectiveModel)
        end
    
        task.wait(0.5)
    end
end

function StartAbilityESP()
    while ESP_Ability == true do
        local currentAbilities = GetCurrentAbilities()

        for _, abilityModel in pairs(currentAbilities) do
            RemoveESP(abilityModel)
            AddAbilityESP(abilityModel)
        end

        task.wait(0.1)
    end
end

function GetCurrentAbilities()
    local abilityTable = {}
    local foundMap = workspace:FindFirstChild("Map")

    for _, child in workspace:GetChildren() do
        if child.Name == "SpiderSkull" then
            table.insert(abilityTable, child)
        end
    end
    
    if foundMap then
        for _, child in foundMap:GetChildren() do
            if child.Name == "NoteBook" then
                table.insert(abilityTable, child)
            end
            
            if child:FindFirstChild("ECT") and child:FindFirstChild("HeadAI") then
                child.Name = "Lurking Facade"
                table.insert(abilityTable, child)
            end

            local foundForestKingProjectile = child.Name:lower()
            if foundForestKingProjectile:find("projectile") then
                child.Name = "Glitching Blitz"
                table.insert(abilityTable, child)
            end

            if child.Name == "EXEVINES" then
                child.Name = "EXE Vines"
                table.insert(abilityTable, child)
            end

            if child.Name == "NiloPuddle" then
                child.Name = "Radiation"
                table.insert(abilityTable, child)
            end

            local foundWYSTBomb = child.Name:lower()
            if foundWYSTBomb:find("bomb") then
                child.Name = "Bomb"
                table.insert(abilityTable, child)
            end

            if child.Name == "HearingTape" then
                child.Name = "Hearing Tape"
                table.insert(abilityTable, child)
            end
        end

        local samsoniteMap = foundMap:FindFirstChild("SamsoniteMap")

        if samsoniteMap then
            for _, realDoor in samsoniteMap.DoorBank:GetChildren() do
                if realDoor.DoorPrompt.Enabled == true then
                    realDoor.Name = "Real Door"
                    table.insert(abilityTable, realDoor)
                end
            end
        end
    end

    return abilityTable
end

function GetCurrentObjectives()
    local objectiveTable = {}
    local foundMap = workspace:FindFirstChild("Map")

    if foundMap then
        for _, child in foundMap:GetChildren() do
            if not child:IsA("Folder") then continue end

            local folderName = child.Name:lower()
    
            if folderName:find("objective") then
                
                for _, objectiveModel in child:GetChildren() do
                    table.insert(objectiveTable, objectiveModel)
                end
            end
        end
    end
    
    return objectiveTable
end

function GetCurrentItems()
    local itemTable = {}

    for _, itemModel in workspace.Server.PickUps:GetChildren() do
        table.insert(itemTable, itemModel)
    end
    
    return itemTable
end

function AddPlayerESP(character, espColor, isSurvivor)
    if character then
        local newHighlight = Instance.new("Highlight")
        newHighlight.Name = "espHighlight"
        newHighlight.FillTransparency = 0.8
        newHighlight.OutlineColor = Color3.fromRGB(0,0,0)
        newHighlight.FillColor = espColor
        newHighlight.Parent = character

        if isSurvivor == true then
            if ESP_ShowHealth == true then
                AddHealthLabel(character)
            end
        elseif isSurvivor == false then
            if ESP_ShowIcon == true then
                AddImageLabel(character.PrimaryPart, Color3.fromRGB(255,0,0), 114497689901216)
            end
        end

        if ESP_ShowDistance == true then
            AddDistanceLabel(character)
        end
    end
end

function AddAbilityESP(model)
    if model then
        local newHighlight = Instance.new("Highlight")
        newHighlight.Name = "espHighlight"
        newHighlight.FillTransparency = 0.6
        newHighlight.OutlineColor = Color3.fromRGB(0,0,0)
        newHighlight.FillColor = Color3.fromRGB(0,0,255)
        newHighlight.Parent = model

        if ESP_ShowAbilityName == true then
            AddPartLabel(model, model.Name)
        end
    end
end

function AddItemESP(itemModel)
    if itemModel then
        local newHighlight = Instance.new("Highlight")
        newHighlight.Name = "espHighlight"
        newHighlight.FillTransparency = 0.8
        newHighlight.OutlineColor = Color3.fromRGB(0,0,0)
        newHighlight.FillColor = Color3.fromRGB(0,255,0)
        newHighlight.Parent = itemModel

        if ESP_ShowItemName == true then
            local isModel = itemModel:IsA("Model")
            local mainPart = itemModel

            if isModel then
                mainPart = isModel.PrimaryPart
            end

            AddPartLabel(mainPart, itemModel.Name)
        end
    end
end

function AddObjectiveESP(objectiveModel)
    if objectiveModel then
        local isModel = objectiveModel:IsA("Model")
        local mainPart = objectiveModel

        if isModel then
            mainPart = objectiveModel.PrimaryPart or objectiveModel:FindFirstChildOfClass("BasePart")
        end
        
        local newHighlight = Instance.new("Highlight")
        newHighlight.Name = "espHighlight"
        newHighlight.FillTransparency = 0.6
        newHighlight.OutlineColor = Color3.fromRGB(0,0,0)
        newHighlight.FillColor = Color3.fromRGB(255, 50, 150)
        newHighlight.Parent = objectiveModel

        if ESP_ShowObjectiveName == true then
            AddPartLabel(mainPart, mainPart.Name)
        end
    end
end

function AddHealthLabel(character)
    local newHealth = Instance.new("BillboardGui")
    newHealth.Name = "espHealth"
    newHealth.Size = UDim2.new(5,0,2,0)
    newHealth.StudsOffset = Vector3.new(0,2.75,0)
    newHealth.AlwaysOnTop = true
    newHealth.Parent = character.Head or character.PrimaryPart

    local newFrameBackground = Instance.new("Frame")
    newFrameBackground.AnchorPoint = Vector2.new(0.5,0.5)
    newFrameBackground.Position = UDim2.new(0.5,0,0.8,0)
    newFrameBackground.Size = UDim2.new(0.6,0,0.1,0)
    newFrameBackground.BackgroundColor3 = Color3.fromRGB(0,0,0)
    newFrameBackground.Parent = newHealth
    
    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newFrameBackground

    local StatFolder = character.Aspects
    local currentHealth = StatFolder.Health
    local maxHealth = currentHealth.Max

    local calculatedSize = currentHealth.Value/maxHealth.Value or 0

    local newFrameFiller = Instance.new("Frame")
    newFrameFiller.AnchorPoint = Vector2.new(0,0.5)
    newFrameFiller.Position = UDim2.new(0,0,0.5,0)
    newFrameFiller.Size = UDim2.new(calculatedSize,0,1,0)
    newFrameFiller.BackgroundColor3 = Color3.fromRGB(0,255,0)
    newFrameFiller.Parent = newFrameBackground

    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newFrameFiller

    local newTextLabel = Instance.new("TextLabel")
    newTextLabel.AnchorPoint = Vector2.new(0.5,0.5)
    newTextLabel.Position = UDim2.new(0.5,0,0.4,0)
    newTextLabel.Size = UDim2.new(1,0,1,0)
    newTextLabel.BackgroundTransparency = 1
    newTextLabel.TextScaled = true
    newTextLabel.TextColor3 = Color3.fromRGB(255,255,255)
    newTextLabel.Font = Enum.Font.Montserrat.Value
    newTextLabel.Text = `❤️ {math.round(currentHealth.Value)}`
    newTextLabel.Parent = newHealth

    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newTextLabel
end

function AddImageLabel(part, imageColor, imageID)
    local newIcon = Instance.new("BillboardGui")
    newIcon.Name = "espIcon"
    newIcon.Size = UDim2.new(2.5,0,2.5,0)
    newIcon.AlwaysOnTop = true
    newIcon.Parent = part

    local newImageLabel = Instance.new("ImageLabel")
    newImageLabel.AnchorPoint = Vector2.new(0.5,0.5)
    newImageLabel.Position = UDim2.new(0.5,0,0.5,0)
    newImageLabel.Size = UDim2.new(1,0,1,0)
    newImageLabel.BackgroundTransparency = 1
    newImageLabel.ImageColor3 = imageColor
    newImageLabel.Image = `rbxassetid://{imageID}`
    newImageLabel.ScaleType = Enum.ScaleType.Fit
    newImageLabel.Parent = newIcon
end

function AddDistanceLabel(character)
    local newDistance = Instance.new("BillboardGui")
    newDistance.Name = "espDistance"
    newDistance.Size = UDim2.new(5,0,2,0)

    newDistance.StudsOffset = Vector3.new(0,0.5,0)
    newDistance.AlwaysOnTop = true
    newDistance.Parent = character.PrimaryPart

    local calculatedDistance = (localPlayer.Character.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude or 0

    local newTextLabel = Instance.new("TextLabel")
    newTextLabel.AnchorPoint = Vector2.new(0.5,0.5)
    newTextLabel.Position = UDim2.new(0.5,0,0.5,0)
    newTextLabel.Size = UDim2.new(1,0,1,0)
    newTextLabel.BackgroundTransparency = 1
    newTextLabel.TextScaled = true
    newTextLabel.TextColor3 = Color3.fromRGB(255,255,255)
    newTextLabel.Font = Enum.Font.Montserrat.Value
    newTextLabel.Text = `↔ {math.round(calculatedDistance)}`
    newTextLabel.Parent = newDistance

    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newTextLabel
end

function AddPartLabel(part, labelText)
    local newName = Instance.new("BillboardGui")
    newName.Name = "espName"
    newName.Size = UDim2.new(20,0,1,0)
    newName.StudsOffset = Vector3.new(0,1.5,0)
    newName.AlwaysOnTop = true
    newName.Parent = part

    local newTextLabel = Instance.new("TextLabel")
    newTextLabel.AnchorPoint = Vector2.new(0.5,0.5)
    newTextLabel.Position = UDim2.new(0.5,0,0.5,0)
    newTextLabel.Size = UDim2.new(1,0,1,0)
    newTextLabel.BackgroundTransparency = 1
    newTextLabel.TextScaled = true
    newTextLabel.TextColor3 = Color3.fromRGB(255,255,255)
    newTextLabel.Font = Enum.Font.Montserrat.Value
    newTextLabel.Text = labelText
    newTextLabel.Parent = newName

    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newTextLabel
end

function GiveMaxCoins()
    while AUTOFARM_MaxCoins == true do
        localPlayer.CoinsToGive.Value = 55

        task.wait()
    end
end

function ActivateFullbright()
    while VISUAL_Fullbright == true do
        local atmosphere = Lighting:FindFirstChild("Atmosphere")
        if atmosphere then atmosphere:Destroy() end

        local bloom = Lighting:FindFirstChild("Bloom")
        if bloom then bloom:Destroy() end

        local blur = Lighting:FindFirstChild("Blur")
        if blur then blur:Destroy() end

        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
        Lighting.FogEnd = 50000
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 5

        task.wait(0.25)
    end
end

function UpdateAntiDebris()
    while VISUAL_AntiDebris == true do
        local gameGui = PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return end

        local foundFlash = gameGui:FindFirstChild("Flash")
        if foundFlash then foundFlash:Destroy() end

        local ventErrorScript = gameGui:FindFirstChild("VentError")
        if ventErrorScript then ventErrorScript:Destroy() end

        local springScare = gameGui:FindFirstChild("SpringScare")
        if springScare then springScare:Destroy() end

        local bloodUI = gameGui:FindFirstChild("BloodUI")
        if bloodUI then bloodUI:Destroy() end

        local debuffsFrame = gameGui:FindFirstChild("Debuffs")
        if debuffsFrame then
            for _, child in debuffsFrame:GetChildren() do
                if child:IsA("ImageLabel") or child:IsA("Frame") then
                    child.Visible = false
                end
            end
        end

        local monsterUIFrame = gameGui:FindFirstChild("MonsterUI")
        if monsterUIFrame then
            local radiatedUIFrame = monsterUIFrame:FindFirstChild("RadiatedUI")
            if radiatedUIFrame then radiatedUIFrame:Destroy() end
        end

        local overlaysFrame = gameGui:FindFirstChild("Overlays")
        if overlaysFrame then
            for _, child in overlaysFrame:GetChildren() do
                if child:IsA("ImageLabel") or child:IsA("Frame") then
                    child.Visible = false
                end
            end
        end

        local blindScript = localPlayer.Character:FindFirstChild("Blind")
        if blindScript then blindScript:Destroy() end
        
        local foundMap = workspace:FindFirstChild("Map")

        if foundMap then
            for _, model in foundMap:GetChildren() do
                if model.Name == "HearingTape" then
                    model.AntiHear.Volume = 0.1
                end
            end
        end

        task.wait()
    end
end

function AutoMove()
    local currentDirection = os.time() % 4
    local character = localPlayer.Character

    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            if currentDirection == 0 then
                localPlayer.Character.Humanoid:Move(Vector3.new(0, 0, -1), true)
            elseif currentDirection == 1 then
                localPlayer.Character.Humanoid:Move(Vector3.new(1, 0, 0), true)
            elseif currentDirection == 2 then
                localPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 1), true)
            else
                localPlayer.Character.Humanoid:Move(Vector3.new(-1, 0, 0), true)
            end
        end
    end
end

function ToggleLobbyRadio(toggle)
    if OTHER_MuteLobbyRadio == true then
        for _, sound in workspace.Lobby["Old Radio"]:GetChildren() do
            if not sound:IsA("Sound") then continue end

            if not sound:FindFirstChild("OriginalVolume") then
                local newOriginalSound = Instance.new("NumberValue")
                newOriginalSound.Name = "OriginalVolume"
                newOriginalSound.Value = sound.Volume
                newOriginalSound.Parent = sound
            end
            
            sound.Volume = 0
        end
    else
        for _, sound in workspace.Lobby["Old Radio"]:GetChildren() do
            if not sound:IsA("Sound") then continue end
            
            if sound:FindFirstChild("OriginalVolume") then
                sound.Volume = sound.OriginalVolume.Value
            end
        end
    end
end

function KillHumanoid()
    local character = localPlayer.Character

    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        humanoid.Health = 0
    end
end

function AutoJumpMX()
    local character = localPlayer.Character

    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        print(humanoid)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

function BecomeMinion()
    local PickupModels = ReplicatedStorage.Assets.PickupModels
    local TurnEvilEvent = PickupModels["Weird Mask"]["Weird Mask"].SetupScript.TurnEvil

    local playerIsSurvivor = character:FindFirstChild("Alive")

    if playerIsSurvivor then
        TurnEvilEvent:FireServer()
    end
end

function ObjectiveIncreaseInteractDistance()
    while OBJECTIVE_IncreaseInteractDistance == true do
        local currentObjectives = GetCurrentObjectives()

        for _, objectiveModel in pairs(currentObjectives) do
            local interactPrompt = objectiveModel:FindFirstChild("ObjectivePrompt", true)

            if interactPrompt then
                interactPrompt.MaxActivationDistance = 11
            end
        end
    
        task.wait(0.5)
    end
end

function ItemIncreaseInteractDistance()
    while ITEM_IncreaseInteractDistance == true do
        local currentItems = GetCurrentItems()

        for _, itemModel in pairs(currentItems) do
            local interactPrompt = itemModel:FindFirstChild("ProximityPrompt", true)

            if interactPrompt then
                interactPrompt.MaxActivationDistance = 8
            end
        end
    
        task.wait(0.5)
    end
end

-- Tabs

local mainTab = Window:MakeTab({
	Name = "Info",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local playerTab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local abilityTab = Window:MakeTab({
	Name = "Ability",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local itemTab = Window:MakeTab({
	Name = "Item",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local objectiveTab = Window:MakeTab({
	Name = "Objective",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local visualTab = Window:MakeTab({
	Name = "Visual",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local autofarmTab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local extraTab = Window:MakeTab({
	Name = "Extra",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Toggles

playerTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        ESP_Player = Value

        if ESP_Player == true then
            StartPlayerESP()
        else
            for _, player in Players:GetPlayers() do
                RemoveESP(player.Character)
            end
        end
	end    
})

playerTab:AddToggle({
	Name = "Show Health",
	Default = false,
	Callback = function(Value)
        ESP_ShowHealth = Value
	end    
})

playerTab:AddToggle({
	Name = "Show Distance",
	Default = false,
	Callback = function(Value)
        ESP_ShowDistance = Value
	end    
})

playerTab:AddToggle({
	Name = "Show Icon",
	Default = false,
	Callback = function(Value)
        ESP_ShowIcon = Value
	end    
})

itemTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        ESP_Item = Value
        
        if ESP_Item == true then
            workspace.Server.PickUps.ChildRemoved:Connect(function(itemTaken)
                RemoveESP(itemTaken)
            end)

            StartItemESP()
        else
            for _, itemModel in workspace.Server.PickUps:GetChildren() do
                RemoveESP(itemModel)
            end

            for _, player in Players:GetPlayers() do
                if not player.Character then continue end
                if not player.Character:FindFirstChild("Backpack") then continue end
                
                for _, item in player.Character.Backpack:GetChildren() do
                    if not item:IsA("Model") then continue end
                    
                    RemoveESP(item)
                end

                for _, item in player.Character:GetChildren() do
                    if not item:IsA("Model") then continue end
                    
                    RemoveESP(item)
                end
            end
        end
	end    
})

itemTab:AddToggle({
	Name = "Show Name",
	Default = false,
	Callback = function(Value)
        ESP_ShowItemName = Value
	end    
})

itemTab:AddToggle({
	Name = "Increase Pickup Distance",
	Default = false,
	Callback = function(Value)
        ITEM_IncreaseInteractDistance = Value

        if ITEM_IncreaseInteractDistance == true then
            ItemIncreaseInteractDistance()
        end
	end    
})

objectiveTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        ESP_Objective = Value

        if ESP_Objective == true then
            StartObjectiveESP()
        else
            for _, objectiveModel in pairs(GetCurrentObjectives()) do
                RemoveESP(objectiveModel)
            end
        end
	end    
})

objectiveTab:AddToggle({
	Name = "Show Name",
	Default = false,
	Callback = function(Value)
        ESP_ShowObjectiveName = Value
	end    
})

objectiveTab:AddToggle({
	Name = "Increase Interact Distance",
	Default = false,
	Callback = function(Value)
        OBJECTIVE_IncreaseInteractDistance = Value

        if OBJECTIVE_IncreaseInteractDistance == true then
            ObjectiveIncreaseInteractDistance()
        end
	end    
})

abilityTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        ESP_Ability = Value

        if ESP_Ability == true then
            StartAbilityESP()
        else
            for _, abilityModel in pairs(GetCurrentAbilities()) do
                RemoveESP(abilityModel)
            end
        end
	end    
})

abilityTab:AddToggle({
	Name = "Show Name",
	Default = false,
	Callback = function(Value)
        ESP_ShowAbilityName = Value
	end    
})

abilityTab:AddToggle({
	Name = "Auto Jump (MX)",
	Default = false,
	Callback = function(Value)
        ABILITY_AutoJumpMX = Value

        if ABILITY_AutoJumpMX == true then
            autoJumpMX_Connection = PlayerGui.DescendantAdded:Connect(function(descendantUI)
                if descendantUI.Name == "JumpWarning" then
                    AutoJumpMX()
                end
            end)
        else
            if autoJumpMX_Connection then
                autoJumpMX_Connection:Disconnect()
            end
        end
	end    
})

abilityTab:AddToggle({
	Name = "Auto Solve (Baldi)",
	Default = false,
	Callback = function(Value)
        
	end    
})

itemTab:AddButton({
	Name = "Use Weird Mask",
	Callback = function()
        BecomeMinion()
  	end    
})

visualTab:AddToggle({
	Name = "Anti Debris",
	Default = false,
	Callback = function(Value)
        VISUAL_AntiDebris = Value

        if VISUAL_AntiDebris == true then
            UpdateAntiDebris()
        end
	end    
})

visualTab:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(Value)
        VISUAL_Fullbright = Value

        if VISUAL_Fullbright == true then
            ActivateFullbright()
        end
	end    
})

autofarmTab:AddToggle({
	Name = "Max Coins",
	Default = false,
	Callback = function(Value)
        AUTOFARM_MaxCoins = Value

        if AUTOFARM_MaxCoins == true then
            GiveMaxCoins()
        end
	end    
})

autofarmTab:AddToggle({
	Name = "Auto Move (Anti-AFK)",
	Default = false,
	Callback = function(Value)
        AUTOFARM_AutoMove = Value

        if AUTOFARM_AutoMove == true then
            RunService:BindToRenderStep("AutoMove", Enum.RenderPriority.Last.Value, AutoMove)
        else
            RunService:UnbindFromRenderStep("AutoMove")
        end
	end    
})

extraTab:AddToggle({
	Name = "Mute Lobby Radio",
	Default = false,
	Callback = function(Value)
        OTHER_MuteLobbyRadio = Value

        ToggleLobbyRadio()
	end    
})

extraTab:AddButton({
	Name = "Reset (Death)",
	Callback = function()
        KillHumanoid()
  	end    
})

mainTab:AddLabel("This GUI covers nearly everything possible on the client-side.")

-- Runtime

OrionLib:Init()
