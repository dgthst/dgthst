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
local CurrentCamera = workspace.CurrentCamera

local Player_ESP = false
local Player_ShowHealth = false
local Player_ShowDistance = false
local Player_ShowIcon = false

local Item_ESP = false
local Item_ShowName = false
local Item_InteractRange = false
local Item_ItemSelected = "None"
local Item_MaskConfirmTime = 1

local Objective_ESP = false
local Objective_ShowName = false
local Objective_InteractRange = false
local Objective_ShowIcon = false

local Ability_ESP = false
local Ability_ShowName = false
local Ability_AutoJumpMX = false

local Visual_AntiDebris = false
local Visual_Fullbright = false

local Farm_MaxCoins = false
local Farm_AutoMove = false

local Map_DoorRange = false

local Lobby_MuteRadio = false

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

function RemoveItemHighlight()
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

function StartPlayerESP()
    while Player_ESP == true do
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
                    if playerIsKiller.Value == "Zombie" then
                        AddPlayerESP(character, Color3.fromRGB(255,150,50), false, true)
                    else
                        AddPlayerESP(character, Color3.fromRGB(255,0,0), false, false)
                    end
                end
            end
        end
    
        task.wait(0.1)
    end
end

function StartItemESP()
    while Item_ESP == true do
        for _, itemModel in workspace.Server.PickUps:GetChildren() do
            RemoveESP(itemModel)
            AddItemESP(itemModel)
        end
    
        task.wait(0.2)
    end
end

function StartObjectiveESP()
    while Objective_ESP == true do
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
    while Ability_ESP == true do
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

function GetCurrentDoors()
    local doorTable = {}
    local foundMap = workspace:FindFirstChild("Map")

    if foundMap then
        for _, child in foundMap:GetChildren() do
            if child.Name ~= "Unlocked Doors" then continue end

            for _, doorModel in child:GetChildren() do
                table.insert(doorTable, doorModel)
            end
        end
    end
    
    return objectiveTable
end

function AddPlayerESP(character, espColor, isSurvivor, isMinion)
    if character then
        local newHighlight = Instance.new("Highlight")
        newHighlight.Name = "espHighlight"
        newHighlight.FillTransparency = 0.8
        newHighlight.OutlineColor = Color3.fromRGB(0,0,0)
        newHighlight.FillColor = espColor
        newHighlight.Parent = character

        if isSurvivor == true then
            if Player_ShowHealth == true then
                AddHealthLabel(character)
            end
            if Player_ShowIcon then
                AddImageLabel(character.PrimaryPart, Color3.fromRGB(0,0,255), 75665386575731)
            end
        elseif isSurvivor == false then
            if Player_ShowIcon == true then
                if isMinion then
                    AddImageLabel(character.PrimaryPart, Color3.fromRGB(255,255,255), 117719382297326)
                else
                    AddImageLabel(character.PrimaryPart, Color3.fromRGB(255,0,0), 114497689901216)
                end
            end
        end

        if Player_ShowDistance == true then
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

        if Ability_ShowName == true then
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

        if Item_ShowName == true then
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

        if Objective_ShowName == true then
            AddPartLabel(mainPart, mainPart.Name)
        end

        if Objective_ShowIcon == true then
            AddImageLabel(mainPart, Color3.fromRGB(255,255,255), 118495023885321)
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
    while Farm_MaxCoins == true do
        localPlayer.CoinsToGive.Value = 55

        task.wait()
    end
end

function ActivateFullbright()
    while Visual_Fullbright == true do
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
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 5

        task.wait(0.25)
    end
end

function UpdateAntiDebris()
    while Visual_AntiDebris == true do
        local gameGui = PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return end

        local character = localPlayer.Character
        if not character then return end

        local infectedUI = character:FindFirstChild("Infected", true)
        if infectedUI then infectedUI:Destroy() end

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

    local character = localPlayer.character

    if character then
        local playerIsSurvivor = character:FindFirstChild("Alive")

        if playerIsSurvivor then
            TurnEvilEvent:FireServer()
        end
    end
end

function ObjectiveInteractDistance()
    while Objective_InteractRange == true do
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

function ItemInteractDistance()
    while Item_InteractRange == true do
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

function DoorInteractDistance()
    while Map_DoorRange == true do
        local currentDoors = GetCurrentItems()

        for _, doorModel in pairs(currentDoors) do
            local interactPrompt = itemModel:FindFirstChild("NAMEOFTHEPROMPTGOESHERE", true)

            if interactPrompt then
                interactPrompt.MaxActivationDistance = 17
            end
        end
    
        task.wait(0.5)
    end
end

function SetCameraFOV(fovNumber)
    CurrentCamera.FieldOfView = fovNumber
end

function NotifyUser_NotWorking(toggle)
    if toggle == true then
        OrionLib:MakeNotification({
            Name = "Work In Progress",
            Content = "This feature is still being worked on, check back later.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
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

local farmTab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local mapTab = Window:MakeTab({
	Name = "Map",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local lobbyTab = Window:MakeTab({
	Name = "Lobby",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Toggles

playerTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        Player_ESP = Value

        if Player_ESP == true then
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
        Player_ShowHealth = Value
	end    
})

playerTab:AddToggle({
	Name = "Show Distance",
	Default = false,
	Callback = function(Value)
        Player_ShowDistance = Value
	end    
})

playerTab:AddToggle({
	Name = "Show Icon",
	Default = false,
	Callback = function(Value)
        Player_ShowIcon = Value
	end    
})

itemTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        Item_ESP = Value
        
        if Item_ESP == true then
            workspace.Server.PickUps.ChildRemoved:Connect(function(itemTaken)
                RemoveESP(itemTaken)
            end)

            StartItemESP()
        else
            RemoveItemHighlight()
        end
	end    
})

itemTab:AddToggle({
	Name = "Show Name",
	Default = false,
	Callback = function(Value)
        Item_ShowName = Value
	end    
})

itemTab:AddToggle({
	Name = "Pickup Distance",
	Default = false,
	Callback = function(Value)
        Item_InteractRange = Value

        if Item_InteractRange == true then
            ItemInteractDistance()
        end
	end    
})

itemTab:AddDropdown({
	Name = "Item List",
	Default = "None",
	Options = {"None", "Weird Mask"},
	Callback = function(Value)
        Item_ItemSelected = Value
	end    
})

itemTab:AddButton({
	Name = "Use Selected Item",
	Callback = function()
        if Item_ItemSelected == "None" then
            OrionLib:MakeNotification({
                Name = "Item Not Selected",
                Content = "Please select a valid item to use.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        elseif Item_ItemSelected == "Weird Mask" then
            BecomeMinion()
            task.wait(1.5)
            SetCameraFOV(90)
        end
  	end    
})

objectiveTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        Objective_ESP = Value

        if Objective_ESP == true then
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
        Objective_ShowName = Value
	end    
})

objectiveTab:AddToggle({
	Name = "Show Icon",
	Default = false,
	Callback = function(Value)
        Objective_ShowIcon = Value
	end    
})

objectiveTab:AddToggle({
	Name = "Interact Distance",
	Default = false,
	Callback = function(Value)
        Objective_InteractRange = Value

        if Objective_InteractRange == true then
            ObjectiveInteractDistance()
        end
	end    
})

abilityTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
        Ability_ESP = Value

        if Ability_ESP == true then
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
        Ability_ShowName = Value
	end    
})

abilityTab:AddToggle({
	Name = "Interact Range",
	Default = false,
	Callback = function(Value)
        NotifyUser_NotWorking(Value)
	end    
})

abilityTab:AddToggle({
	Name = "Auto Jump (MX)",
	Default = false,
	Callback = function(Value)
        NotifyUser_NotWorking(Value)
	end    
})

abilityTab:AddToggle({
	Name = "Auto Solve (Baldi)",
	Default = false,
	Callback = function(Value)
        NotifyUser_NotWorking(Value)
	end    
})

visualTab:AddToggle({
	Name = "Anti Debris",
	Default = false,
	Callback = function(Value)
        Visual_AntiDebris = Value

        if Visual_AntiDebris == true then
            UpdateAntiDebris()
        end
	end    
})

visualTab:AddToggle({
	Name = "Fullbright",
	Default = false,
	Callback = function(Value)
        Visual_Fullbright = Value

        if Visual_Fullbright == true then
            ActivateFullbright()
        end
	end    
})

farmTab:AddToggle({
	Name = "Max Coins",
	Default = false,
	Callback = function(Value)
        Farm_MaxCoins = Value

        if Farm_MaxCoins == true then
            GiveMaxCoins()
        end
	end    
})

farmTab:AddToggle({
	Name = "Auto Move (Anti-AFK)",
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

mapTab:AddToggle({
	Name = "Door Range",
	Default = false,
	Callback = function(Value)

	end    
})

lobbyTab:AddToggle({
	Name = "Mute Radio",
	Default = false,
	Callback = function(Value)
        Lobby_MuteRadio = Value

        ToggleLobbyRadio()
	end    
})

lobbyTab:AddButton({
	Name = "Reset (Death)",
	Callback = function()
        KillHumanoid()
  	end    
})

mainTab:AddLabel("This GUI covers nearly everything possible on the client-side.")

-- Runtime

OrionLib:Init()
