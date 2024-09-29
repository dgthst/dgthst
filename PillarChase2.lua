-- Libraries

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Pillar Chase Panel", HidePremium = false, Intro = false, IntroText = "SIGMA ™", SaveConfig = true, ConfigFolder = "PC2Config"})

-- Services

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer.PlayerGui
local CurrentCamera = workspace.CurrentCamera

local ESP_Enabled = false
local ESP_ViewKiller = false
local ESP_ViewSurvivor = false
local ESP_ViewItem = false
local ESP_ViewObjective = false
local ESP_ViewAbility = false
local ESP_ShowHighlight = false
local ESP_ShowName = false
local ESP_ShowIcon = false
local ESP_ShowHealth = false
local ESP_ShowDistance = false
local ESP_Transparency = nil
local ESP_RefreshRate = nil

local Ability_AutoJumpMX = false
local Ability_AutoSolveBaldi = false

local Item_ItemSelected = nil

local Graphic_AntiDebris = false
local Graphic_Fullbright = false
local Graphic_Brightness = nil

local Interaction_IncreasedRange = false
local Interaction_InstantComplete = false

local Farm_MaxCoins = false
local Farm_AutoMove = false
local Farm_AutoJump = false

local Color_Killer = nil
local Color_Zombie = nil
local Color_Survivor = nil
local Color_Item = nil
local Color_Objective = nil
local Color_Ability = nil

local Lobby_MuteRadio = false
local Lobby_AutoPlayFNF = false

local RoleToIcon = {
    ["Survivor"] = {
        ["Image"] = 75665386575731;
        ["Color"] = Color3.fromRGB(255, 255, 255);
    };
    ["Killer"] = {
        ["Image"] = 114497689901216;
        ["Color"] = Color3.fromRGB(255, 255, 255);
    };
    ["Zombie"] = {
        ["Image"] = 117719382297326;
        ["Color"] = Color3.fromRGB(255, 255, 255);
    };
}

local refreshingESP = false

local connectionTab = {}

-- Functions

function RemoveModelESP(model)
    if model then
        local espHighlight = model:FindFirstChild("espHighlight", true)
        if espHighlight then espHighlight:Destroy() end

        local espName = model:FindFirstChild("espName", true)
        if espName then espName:Destroy() end
    
        local espHealth = model:FindFirstChild("espHealth", true)
        if espHealth then espHealth:Destroy() end

        local espDistance = model:FindFirstChild("espDistance", true)
        if espDistance then espDistance:Destroy() end

        local espIcon = model:FindFirstChild("espIcon", true)
        if espIcon then espIcon:Destroy() end
    end
end

function RemoveItemESP()
    for _, itemModel in workspace.Server.PickUps:GetChildren() do
        RemoveModelESP(itemModel)
    end

    for _, player in Players:GetPlayers() do
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Backpack") then continue end
        
        for _, item in player.Character.Backpack:GetChildren() do
            if not item:IsA("Model") then continue end
            
            RemoveModelESP(item)
        end

        for _, item in player.Character:GetChildren() do
            if not item:IsA("Model") then continue end
            
            RemoveModelESP(item)
        end
    end
end

function RemoveGlobalESP()
    RemoveItemESP()

    for _, objectiveModel in GetCurrentObjectives() do
        RemoveModelESP(objectiveModel)
    end

    for _, abilityModel in GetCurrentAbilities() do
        RemoveModelESP(abilityModel)
    end
    
    for _, player in Players:GetPlayers() do
        RemoveModelESP(player.Character)
    end
end

function StartESP()
    while ESP_Enabled == true do
        RefreshESP()

        task.wait(ESP_RefreshRate)
    end
end

function RefreshESP()
    if refreshingESP == true then return end
    refreshingESP = true

    RemoveGlobalESP()

    for _, player in Players:GetPlayers() do
        if player == localPlayer then continue end

        local character = player.Character
        if not character then continue end
        
        local playerIsKiller = character:FindFirstChild("MonsterNameValue")
        local playerIsSurvivor = character:FindFirstChild("Alive")

        if playerIsKiller then
            if ESP_ViewKiller then
                if playerIsKiller.Value == "Zombie" then
                    AddPlayerESP(character, Color_Zombie, "Zombie")
                else
                    AddPlayerESP(character, Color_Killer, "Killer")
                end
            end
        elseif playerIsSurvivor then
            if ESP_ViewSurvivor then
                AddPlayerESP(character, Color_Survivor, "Survivor")
            end
        end
    end

    if ESP_ViewItem == true then
        local currentItems = GetCurrentItems()

        for _, itemModel in pairs(currentItems) do
            AddItemESP(itemModel)
        end
    end

    if ESP_ViewObjective == true then
        local currentObjectives = GetCurrentObjectives()

        for _, objectiveInstance in pairs(currentObjectives) do
            if not objectiveInstance:FindFirstChild("ObjectivePrompt", true) then continue end

            if objectiveInstance:IsA("Model") then
                local mainPart = objectiveInstance.PrimaryPart or objectiveInstance:FindFirstChildOfClass("BasePart", true)
                AddObjectiveESP(mainPart, objectiveInstance.Name)
            else
                AddObjectiveESP(objectiveInstance, objectiveInstance.Name)
            end                
        end
    end

    if ESP_ViewAbility == true then
        local currentAbilities = GetCurrentAbilities()

        for _, abilityModel in pairs(currentAbilities) do
            AddAbilityESP(abilityModel)
        end
    end

    refreshingESP = false
end

function CreateESPHighlight(parentInstance, espColor)
    local newHighlight = Instance.new("Highlight")
    newHighlight.Name = "espHighlight"
    newHighlight.FillColor = espColor
    newHighlight.FillTransparency = 0.8
    newHighlight.OutlineTransparency = 0.2
    newHighlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    newHighlight.Parent = parentInstance
end

function AddPlayerESP(character, espColor, roleType)
    if ESP_ShowHighlight then
        CreateESPHighlight(character, espColor)
    end

    if ESP_ShowHealth == true then
        if roleType == "Survivor" then
            AddHealthLabel(character)
        end
    end

    if ESP_ShowIcon then
        AddImageLabel(character.PrimaryPart, RoleToIcon[roleType].Color, RoleToIcon[roleType].Image)
    end

    if ESP_ShowDistance == true then
        AddDistanceLabel(character)
    end
end

function AddItemESP(itemModel)
    if ESP_ShowHighlight then
        CreateESPHighlight(itemModel, Color_Item)
    end

    if ESP_ShowName == true then
        local isModel = itemModel:IsA("Model")
        local mainPart = itemModel

        if isModel then
            mainPart = itemModel.PrimaryPart
        end

        AddPartLabel(mainPart, itemModel.Name)
    end
end

function AddObjectiveESP(objectivePart, objectiveName)
    if ESP_ShowHighlight then
        CreateESPHighlight(objectivePart, Color_Objective)
    end

    if ESP_ShowName == true then
        AddPartLabel(objectivePart, objectiveName)
    end

    if ESP_ShowIcon == true then
        AddImageLabel(objectivePart, Color3.fromRGB(255, 255, 255), 12011030159)
    end
end

function AddAbilityESP(model)
    if ESP_ShowHighlight then
        CreateESPHighlight(model, Color_Ability)
    end

    if ESP_ShowName == true then
        AddPartLabel(model, model.Name)
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
    newFrameBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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
    newFrameFiller.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    newFrameFiller.Parent = newFrameBackground

    local newStroke = Instance.new("UIStroke")
    newStroke.Parent = newFrameFiller

    local newTextLabel = Instance.new("TextLabel")
    newTextLabel.AnchorPoint = Vector2.new(0.5,0.5)
    newTextLabel.Position = UDim2.new(0.5,0,0.4,0)
    newTextLabel.Size = UDim2.new(1,0,1,0)
    newTextLabel.BackgroundTransparency = 1
    newTextLabel.TextScaled = true
    newTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    newImageLabel.ImageTransparency = 0.2
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
    newTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

function GetCurrentAbilities()
    local abilityTable = {}
    local foundMap = workspace:FindFirstChild("Map")

    for _, child in workspace:GetChildren() do
        if child.Name == "SpiderSkull" or child.Name == "Spider Skull" then
            child.Name = "Spider Skull"
            table.insert(abilityTable, child)
        end
    end
    
    if foundMap then
        for _, child in foundMap:GetChildren() do
            if child.Name == "NoteBook" or child.Name == "Notebook" then
                child.Name = "Notebook"
                table.insert(abilityTable, child)
            end
            
            if (child:FindFirstChild("ECT") and child:FindFirstChild("HeadAI")) or child.Name == "Lurking Facade" then
                child.Name = "Lurking Facade"
                table.insert(abilityTable, child)
            end

            local foundForestKingProjectile = child.Name:lower()
            if foundForestKingProjectile:find("projectile") or child.Name == "Glitching Blitz" then
                child.Name = "Glitching Blitz"
                table.insert(abilityTable, child)
            end

            if child.Name == "EXEVINES" or child.Name == "EXE Vines" then
                child.Name = "EXE Vines"
                table.insert(abilityTable, child)
            end

            if child.Name == "NiloPuddle" or child.Name == "Radiation" then
                child.Name = "Radiation"
                table.insert(abilityTable, child)
            end

            local foundWYSTBomb = child.Name:lower()
            if foundWYSTBomb:find("bomb") or child.Name == "Bomb" then
                child.Name = "Bomb"
                table.insert(abilityTable, child)
            end

            if child.Name == "HearingTape" or child.Name == "Hearing Tape" then
                child.Name = "Hearing Tape"
                table.insert(abilityTable, child)
            end
        end

        local samsoniteMap = foundMap:FindFirstChild("SamsoniteMap")

        if samsoniteMap then
            for _, realDoor in samsoniteMap.DoorBank:GetChildren() do
                if realDoor.DoorPrompt.Enabled == true then
                    realDoor.Name = "Escape"
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
                    print(`{objectiveModel.Name}: {objectiveModel.ClassName}`)
                    table.insert(objectiveTable, objectiveModel)
                end
            end
        end

        local foundExit = foundMap:FindFirstChild("Exit")
        if foundExit then
            table.insert(objectiveTable, foundExit)
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

function GetCurrentDoors()
    local doorTable = {}
    local foundMap = workspace:FindFirstChild("Map")

    if foundMap then
        for _, child in foundMap:GetChildren() do
            local childString = child.Name:lower()

            if childString:find("door") then
                table.insert(doorTable, doorModel)
            end
        end
    end
    
    return doorTable
end

function GetMaxCoins()
    while Farm_MaxCoins == true do
        localPlayer.CoinsToGive.Value = 55

        task.wait()
    end
end

function ActivateFullbright()
    while Graphic_Fullbright == true do
        local atmosphere = Lighting:FindFirstChild("Atmosphere")
        if atmosphere then
            atmosphere.Density = 0
            atmosphere.Offset = 0
            atmosphere.Glare = 0
            atmosphere.Haze = 0
        end

        local bloom = Lighting:FindFirstChild("Bloom")
        if bloom then
            bloom.Enabled = false
        end

        local blur = Lighting:FindFirstChild("Blur")
        if blur then
            blur.Enabled = false 
        end

        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
        Lighting.FogStart = 10
        Lighting.FogEnd = 500000000
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = Graphic_Brightness

        task.wait(0.25)
    end
end

function ActivateAntiDebris()
    while Graphic_AntiDebris == true do
        local gameGui = PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return end

        local character = localPlayer.Character
        if not character then return end

        local infectedUI = game:FindFirstChild("Infected", true)
        if infectedUI then infectedUI:Destroy() end

        local foundFlash = gameGui:FindFirstChild("Flash")
        if foundFlash then
            foundFlash.Visible = false
        end

        local ventErrorScript = gameGui:FindFirstChild("VentError")
        if ventErrorScript then
            ventErrorScript.Enabled = false
        end

        local springScare = gameGui:FindFirstChild("SpringScare")
        if springScare then
            springScare.Visible = false
        end

        local bloodUI = gameGui:FindFirstChild("BloodUI")
        if bloodUI then
            bloodUI.Visible = false
        end

        local debuffsFrame = gameGui:FindFirstChild("Debuffs")
        if debuffsFrame then
            debuffsFrame.Visible = false
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

        local blindScript = character:FindFirstChild("Blind")
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
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local currentDirection = os.time() % 4

    if currentDirection == 0 then
        localPlayer.Character.Humanoid:Move(Vector3.new(0, 0, -1), true)
    elseif currentDirection == 1 then
        localPlayer.Character.Humanoid:Move(Vector3.new(1, 0, 0), true)
    elseif currentDirection == 2 then
        localPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 1), true)
    elseif currentDirection == 3 then
        localPlayer.Character.Humanoid:Move(Vector3.new(-1, 0, 0), true)
    end
end

function AutoJump()
    while Farm_AutoJump == true do
        local character = localPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        task.wait(1.75)
    end
end

function AutoSolveBaldi()
    while Ability_AutoSolveBaldi == true do
        local gameGui = PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return end
        
        local thinkpadUI = gameGui.thinkpadUI
        if not thinkpadUI then return end

        local mathQuestion = thinkpadUI.Questions.Question.Value

        -- CONTINUE CODING

        task.wait(0.1)
    end
end

function ToggleLobbyRadio()
    if Lobby_MuteRadio == true then
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

function BecomeZombie()
    local PickupModels = ReplicatedStorage.Assets.PickupModels
    local TurnEvilEvent = PickupModels["Weird Mask"]["Weird Mask"].SetupScript.TurnEvil

    local character = localPlayer.character
    if not character then return end

    local playerIsSurvivor = character:FindFirstChild("Alive")

    if playerIsSurvivor then
        TurnEvilEvent:FireServer()
        task.wait(1.5)
        SetCameraFOV(90)
    else
        OrionLib:MakeNotification({
            Name = "Not Allowed",
            Content = "You need to be a survivor to use this.",
            Image = "rbxassetid://96055863684080",
            Time = 3
        })
    end
end

function MaximizeInteractDistance()
    while Interaction_IncreasedRange == true do
        local currentObjectives = GetCurrentObjectives()

        for _, objectiveModel in pairs(currentObjectives) do
            local proximityPrompt = objectiveModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.MaxActivationDistance = 11
            end
        end

        local currentItems = GetCurrentItems()

        for _, itemModel in pairs(currentItems) do
            local proximityPrompt = itemModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.MaxActivationDistance = 8
            end
        end

        local currentDoors = GetCurrentDoors()

        for _, doorModel in pairs(currentDoors) do
            local proximityPrompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.MaxActivationDistance = 17
            end
        end
    
        task.wait(0.5)
    end
end

function InstantCompleteInteraction()
    while Interaction_InstantComplete == true do
        local currentObjectives = GetCurrentObjectives()

        for _, objectiveModel in pairs(currentObjectives) do
            local proximityPrompt = objectiveModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.HoldDuration = 0.25
            end
        end

        local currentItems = GetCurrentItems()

        for _, itemModel in pairs(currentItems) do
            local proximityPrompt = itemModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.HoldDuration = 0.25
            end
        end

        local currentDoors = GetCurrentDoors()

        for _, doorModel in pairs(currentDoors) do
            local proximityPrompt = doorModel:FindFirstChildWhichIsA("ProximityPrompt", true)

            if proximityPrompt then
                proximityPrompt.HoldDuration = 0.25
            end
        end

        task.wait(0.5)
    end
end

function SetCameraFOV(fovNumber)
    CurrentCamera.FieldOfView = fovNumber
end

function WorkInProgressNotification(toggle)
    if toggle == true then
        OrionLib:MakeNotification({
            Name = "Work In Progress",
            Content = "This feature is still being worked on, check back later.",
            Image = "rbxassetid://96055863684080",
            Time = 5
        })
    end
end

function AutoPlayFNF()
    local LemonFunkyUI = PlayerGui.LemonFunky
    if LemonFunkyUI.P2Stats.Visible == true then return end

    local NoteHolderUI = LemonFunkyUI.NotesRight.Notes
    local HitBoxes = NoteHolderUI.HitBoxes

    for _, noteFrame in NoteHolderUI:GetChildren() do
        if not noteFrame:IsA("Frame") then continue end

        for _, buttonImage in noteFrame:GetChildren() do
            if buttonImage.Name ~= "Note" then continue end
            if buttonImage.AbsolutePosition.Y == noteFrame[noteFrame.Name].AbsolutePosition.Y then continue end
            if math.round(buttonImage.AbsolutePosition.Y) == 681 then continue end

            if math.round(buttonImage.AbsolutePosition.Y/10) == math.round(HitBoxes.Sick.AbsolutePosition.Y/10) then
                print("Press [SPACE]")
            end
        end
    end
end

-- Tabs

local mainTab = Window:MakeTab({
	Name = "Info",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local espTab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local abilityTab = Window:MakeTab({
	Name = "Abilities",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local itemTab = Window:MakeTab({
	Name = "Items",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local interactionTab = Window:MakeTab({
	Name = "Interaction",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local graphicTab = Window:MakeTab({
	Name = "Graphics",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local farmTab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local lobbyTab = Window:MakeTab({
	Name = "Lobby",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local colorTab = Window:MakeTab({
	Name = "Color",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local helpTab = Window:MakeTab({
	Name = "Help",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Orion UI

mainTab:AddParagraph(`This GUI covers nearly everything possible on the client-side.`,"Version 2.0")

--[----]--

local espToggleSection = espTab:AddSection({
	Name = "Toggle"
})

espToggleSection:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        ESP_Enabled = Value

        if ESP_Enabled == true then
            workspace.Server.PickUps.ChildRemoved:Connect(function(itemTaken)
                RemoveModelESP(itemTaken)
            end)

            StartESP()
        else
            RemoveGlobalESP()
        end
	end    
})

local selectionSection = espTab:AddSection({
	Name = "Selection"
})

selectionSection:AddToggle({
	Name = "View Killer",
	Default = false,
	Callback = function(Value)
        ESP_ViewKiller = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Survivor",
	Default = false,
	Callback = function(Value)
        ESP_ViewSurvivor = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Item",
	Default = false,
	Callback = function(Value)
        ESP_ViewItem = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Objective",
	Default = false,
	Callback = function(Value)
        ESP_ViewObjective = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Ability",
	Default = false,
	Callback = function(Value)
        ESP_ViewAbility = Value
	end    
})

local addonSection = espTab:AddSection({
	Name = "Add-On"
})

addonSection:AddToggle({
	Name = "Show Highlight",
	Default = false,
	Callback = function(Value)
        ESP_ShowHighlight = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Name",
	Default = false,
	Callback = function(Value)
        ESP_ShowName = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Icon",
	Default = false,
	Callback = function(Value)
        ESP_ShowIcon = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Health",
	Default = false,
	Callback = function(Value)
        ESP_ShowHealth = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Distance",
	Default = false,
	Callback = function(Value)
        ESP_ShowDistance = Value
        RefreshESP()
	end    
})

local settingsSection = espTab:AddSection({
	Name = "Settings"
})

settingsSection:AddSlider({
	Name = "Transparency",
	Min = 0,
	Max = 100,
	Default = 80,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "%",
    Save = true,
    Flag = "Transparency_ESP",
	Callback = function(Value)
        ESP_Transparency = Value/100
	end    
})

settingsSection:AddSlider({
	Name = "Refresh Rate",
	Min = 25,
	Max = 1000,
	Default = 250,
	Color = Color3.fromRGB(255,255,255),
	Increment = 25,
	ValueName = "milliseconds",
    Save = true,
    Flag = "RefreshRate_ESP",
	Callback = function(Value)
        ESP_RefreshRate = Value/1000
	end    
})

--[----]--

local autoCounterSection = abilityTab:AddSection({
	Name = "Automatic Counter"
})

autoCounterSection:AddToggle({
	Name = "Auto Jump (MX)",
	Default = false,
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

autoCounterSection:AddToggle({
	Name = "Auto Solve (Baldi)",
	Default = false,
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

local activeCounterSection = abilityTab:AddSection({
	Name = "Active Counter"
})

activeCounterSection:AddToggle({
	Name = "Instant Escape (EXE)",
	Default = false,
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

--[----]--

local itemUsageSection = itemTab:AddSection({
	Name = "Usage"
})

itemUsageSection:AddDropdown({
	Name = "Item List",
	Default = "None",
	Options = {"None", "Weird Mask"},
	Callback = function(Value)
        Item_ItemSelected = Value
	end    
})

itemUsageSection:AddButton({
	Name = "Use Selected Item",
	Callback = function()
        if Item_ItemSelected == "None" then
            OrionLib:MakeNotification({
                Name = "No Item Selected",
                Content = "Please select a valid item to use.",
                Image = "rbxassetid://86342899097629",
                Time = 3
            })
        elseif Item_ItemSelected == "Weird Mask" then
            BecomeZombie()
        end
  	end    
})

--[----]--

local interactOptionsSection = interactionTab:AddSection({
	Name = "Options"
})

interactOptionsSection:AddToggle({
	Name = "Maximize Interact Distance",
	Default = false,
	Callback = function(Value)
        Interaction_IncreasedRange = Value

        if Interaction_IncreasedRange == true then
            MaximizeInteractDistance()
        end
	end    
})

interactOptionsSection:AddToggle({
	Name = "Instant Complete Interaction",
	Default = false,
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

--[----]--

local screenSection = graphicTab:AddSection({
	Name = "Screen"
})

screenSection:AddToggle({
	Name = "Anti Debris",
	Default = false,
	Callback = function(Value)
        Graphic_AntiDebris = Value

        if Graphic_AntiDebris == true then
            ActivateAntiDebris()
        end
	end    
})

local worldSection = graphicTab:AddSection({
	Name = "World"
})

worldSection:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(Value)
        Graphic_Fullbright = Value

        if Graphic_Fullbright == true then
            ActivateFullbright()
        end
	end    
})

worldSection:AddSlider({
	Name = "Brightness",
	Min = 0,
	Max = 500,
	Default = 100,
	Color = Color3.fromRGB(255,255,255),
	Increment = 25,
	ValueName = "%",
    Save = true,
    Flag = "Brightness_Graphic",
	Callback = function(Value)
        Graphic_Brightness = Value/100
        ActivateFullbright()
	end    
})

--[----]--

local rewardSection = farmTab:AddSection({
	Name = "Rewards"
})

rewardSection:AddToggle({
	Name = "Max Coins",
	Default = false,
	Callback = function(Value)
        Farm_MaxCoins = Value

        if Farm_MaxCoins == true then
            GetMaxCoins()
        end
	end    
})

local antiAFKSection = farmTab:AddSection({
	Name = "Anti-AFK"
})

antiAFKSection:AddToggle({
	Name = "Auto Walk",
	Default = false,
	Callback = function(Value)
        Farm_AutoMove = Value

        if Farm_AutoMove == true then
            RunService:BindToRenderStep("AutoMove", Enum.RenderPriority.Last.Value, AutoMove)
        else
            RunService:UnbindFromRenderStep("AutoMove")
        end
	end    
})

antiAFKSection:AddToggle({
	Name = "Auto Jump",
	Default = false,
	Callback = function(Value)
        Farm_AutoJump = Value

        if Farm_AutoJump == true then
            AutoJump()
        end
	end    
})

--[----]--

local colorPlayerSection = colorTab:AddSection({
	Name = "Players"
})

colorPlayerSection:AddColorpicker({
	Name = "Killer",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Killer",
	Callback = function(Value)
		Color_Killer = Value
	end	  
})

colorPlayerSection:AddColorpicker({
	Name = "Zombie",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Zombie",
	Callback = function(Value)
		Color_Zombie = Value
	end	  
})

colorPlayerSection:AddColorpicker({
	Name = "Survivor",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Survivor",
	Callback = function(Value)
		Color_Survivor = Value
	end	  
})

local colorObjectSection = colorTab:AddSection({
	Name = "Objects"
})

colorObjectSection:AddColorpicker({
	Name = "Item",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Item",
	Callback = function(Value)
		Color_Item = Value
	end	  
})

colorObjectSection:AddColorpicker({
	Name = "Objective",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Objective",
	Callback = function(Value)
		Color_Objective = Value
	end	  
})

colorObjectSection:AddColorpicker({
	Name = "Ability",
	Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "ColorESP_Ability",
	Callback = function(Value)
        Color_Ability = Value
	end	  
})

--[----]--

local lobbyWorldSection = lobbyTab:AddSection({
	Name = "World"
})

lobbyWorldSection:AddToggle({
	Name = "Mute Radio",
	Default = false,
	Callback = function(Value)
        Lobby_MuteRadio = Value

        ToggleLobbyRadio()
	end    
})

local lobbyArcadeSection = lobbyTab:AddSection({
	Name = "Arcade Machine"
})

lobbyArcadeSection:AddToggle({
	Name = "Auto Play",
	Default = false,
	Callback = function(Value)
        WorkInProgressNotification(Value)

        --[[
        Lobby_AutoPlayFNF = Value

        if Lobby_AutoPlayFNF == true then
            RunService:BindToRenderStep("AutoPlayFNF", Enum.RenderPriority.Last.Value, AutoPlayFNF)
        else
            RunService:UnbindFromRenderStep("AutoPlayFNF")
        end
        ]]--
	end    
})

local lobbyOptionSection = lobbyTab:AddSection({
	Name = "Options"
})

lobbyOptionSection:AddButton({
	Name = "Reset (Death)",
	Callback = function()
        KillHumanoid()
  	end    
})


--[----]--

local infoSection = helpTab:AddSection({
	Name = "Information"
})

infoSection:AddParagraph(`Some objectives cannot be highlighted. Prefer 'Show Icon'.`,"ROBLOX has a graphical limit of 31 for performance.")
infoSection:AddLabel(`Most items can only be used when you're a survivor.`)
infoSection:AddLabel(`Increase 'Refresh Rate' if you experience lag while using ESP.`)
infoSection:AddLabel(`Using 'Reset' may break your game.`)

local contactSection = helpTab:AddSection({
	Name = "Contact"
})

contactSection:AddParagraph("If something stops working, check F9 console for errors.","Take a screenshot of any errors and send them to me.")

-- Runtime

OrionLib:Init()
