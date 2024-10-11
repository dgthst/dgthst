-- Libraries

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Pillar Chase Panel", HidePremium = false, Intro = false, IntroText = "SIGMA ™", SaveConfig = true, ConfigFolder = "PC2Config"})

local currentVersion = "2.0.11"

-- Services

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer.PlayerGui
local CurrentCamera = workspace.CurrentCamera

local PLAYER_StaminaConservation = false

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
local Item_InfiniteStephano = false
local Item_InfiniteFlashlight = false
local Item_InfiniteGauntlet = false

local Notification_PopUpsEnabled = false
local Notification_AttackCooldown = false
local Notification_AbilityUsage = false

local Graphic_AntiDebris = false
local Graphic_Fullbright = false
local Graphic_Brightness = nil
local Graphic_BorgerSuit = false
local Graphic_ThirdPerson = false
local Graphic_FOVEnabled = false
local Graphic_FOVNumber = nil

local Interaction_IncreasedRange = false
local Interaction_InstantComplete = false

local Farm_MaxCoins = false
local Farm_AutoMove = false
local Farm_AutoJump = false
local Farm_AutoLeave = false
local Farm_AutoReset = false
local Farm_AutoMask = false

local Color_Killer = nil
local Color_Zombie = nil
local Color_Survivor = nil
local Color_Item = nil
local Color_Objective = nil
local Color_Ability = nil

local Lobby_MuteRadio = false
local Lobby_AutoPlayFNF = false

local Autobuy_Enabled = false

local refreshingESP = false
local autoActionCooldown = false

local fovConnection = nil
local fullbrightConnection = nil

local AutobuyList = {
    ["Flashlight"] = false;
    ["First Aid Kit"] = false;
    ["Ultra Flashlight"] = false;
    ["Stephano"] = false;
    ["Doom's Guantlet"] = false;
    ["Weird Mask"] = false;
}

local RoleToIcon = {
    ["Survivor"] = {
        ["Image"] = 130669312277208;
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

local ItemToMaxStats = {
    ["Stephano"] = {
        ["Time"] = nil;
        ["Light"] = 100;
    };
    ["Flashlight"] = {
        ["Time"] = 155;
        ["Light"] = 100;
    };
    ["Ultra Flashlight"] = {
        ["Time"] = 200;
        ["Light"] = 125;
    };
    ["Doom's Gauntlet"] = {
        ["Time"] = nil;
        ["Light"] = 0;
    };
}

local AdminList = {
    "The_BladeNinja";
	"DaSnappleApple";
	"PhoenixFinch";
	"Toket_suu";
	"GojiDev8";
	"peter12121212";
	"Bowserson21";
	"Skeletor427";
	"Taurolostiryx";
	"Rawalc";
	"DrOchikondaMimu";
	"MySteR4y2";
	"punkywav";
	"HazyOwl";
}

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
            local proximityPrompt = objectiveInstance:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not proximityPrompt then continue end

            AddObjectiveESP(objectiveInstance, objectiveInstance.Name)           
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
    newHighlight.FillTransparency = ESP_Transparency
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
        local imageLabel = AddImageLabel(character.PrimaryPart, RoleToIcon[roleType].Color, RoleToIcon[roleType].Image, 0)
        if localPlayer:IsFriendsWith(Players:GetPlayerFromCharacter(character).UserId) then
            AddFriendLabel(imageLabel)
        end
        if roleType == "Survivor" then
            AddStatusLabel(character, imageLabel)
        end
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

function AddObjectiveESP(objectiveInstance, objectiveName)  
    if ESP_ShowHighlight then
        CreateESPHighlight(objectiveInstance, Color_Objective)
    end

    if objectiveInstance:IsA("Model") then
        objectiveInstance = objectiveInstance.PrimaryPart or objectiveInstance:FindFirstChildWhichIsA("BasePart", true)
    end  

    if ESP_ShowName == true then
        AddPartLabel(objectiveInstance, objectiveName)
    end

    if ESP_ShowIcon == true then
        AddImageLabel(objectiveInstance, Color3.fromRGB(255, 255, 255), 12011030159, 3.5)
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
    local StatFolder = character:FindFirstChild("Aspects")
    if not StatFolder then return end

    local currentHealth = StatFolder:FindFirstChild("Health")
    if not currentHealth then return end

    local maxHealth = currentHealth:FindFirstChild("Max")
    if not maxHealth then return end

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

function AddImageLabel(part, imageColor, imageID, yOffset)
    local newIcon = Instance.new("BillboardGui")
    newIcon.Name = "espIcon"
    newIcon.Size = UDim2.new(2.5,0,2.5,0)
    newIcon.StudsOffset = Vector3.new(0, yOffset, 0)
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

    return newImageLabel
end

function AddFriendLabel(parentFrame)
    local newImageLabel = Instance.new("ImageLabel")
    newImageLabel.AnchorPoint = Vector2.new(1,0)
    newImageLabel.Position = UDim2.new(1.2,0,-0.2,0)
    newImageLabel.Size = UDim2.new(0.4,0,0.4,0)
    newImageLabel.BackgroundTransparency = 1
    newImageLabel.Image = `rbxassetid://128275723342163`
    newImageLabel.ImageTransparency = 0.2
    newImageLabel.ScaleType = Enum.ScaleType.Fit
    newImageLabel.Parent = parentFrame
end

function AddStatusLabel(character, parentFrame)
    local StatFolder = character:FindFirstChild("Aspects")
    if not StatFolder then return end

    local currentHealth = StatFolder:FindFirstChild("Health")
    if not currentHealth then return end
    
    local newImageLabel = Instance.new("ImageLabel")
    newImageLabel.AnchorPoint = Vector2.new(0,0)
    newImageLabel.Position = UDim2.new(-0.2,0,-0.2,0)
    newImageLabel.Size = UDim2.new(0.4,0,0.4,0)
    newImageLabel.BackgroundTransparency = 1
    newImageLabel.ImageTransparency = 0.2
    newImageLabel.ScaleType = Enum.ScaleType.Fit

    if currentHealth.Value > 20 then
        newImageLabel.Image = "rbxassetid://138274629807181"
    else
        newImageLabel.Image = "rbxassetid://137914020707389"
    end

    newImageLabel.Parent = parentFrame
end

function AddDistanceLabel(character)
    local mainPart1 = localPlayer.Character.PrimaryPart or localPlayer.Character:FindFirstChildWhichIsA("BasePart")
    local mainPart2 = character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
    
    if not mainPart1 then return end
    if not mainPart2 then return end

    local calculatedDistance = (mainPart1.Position - mainPart2.Position).Magnitude or 0

    local newDistance = Instance.new("BillboardGui")
    newDistance.Name = "espDistance"
    newDistance.Size = UDim2.new(5,0,2,0)

    newDistance.StudsOffset = Vector3.new(0,0.5,0)
    newDistance.AlwaysOnTop = true
    newDistance.Parent = character.PrimaryPart

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

function UpdateCooldownUI(createUI)
	local newUI = PlayerGui:FindFirstChild("Cooldown")

	if createUI then
		if not newUI then
			newUI = Instance.new("ScreenGui")
			newUI.Name = "Cooldown"
			newUI.DisplayOrder = 1000000
			newUI.IgnoreGuiInset = true
			newUI.ResetOnSpawn = false
			newUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			newUI.Parent = PlayerGui
		end

		return newUI
	elseif newUI then
		if #newUI:GetChildren() == 0 then
			newUI:Destroy()
		end
	end
end

function UpdatePopupUI(createUI)
	local newUI = PlayerGui:FindFirstChild("Popups")
	
	if createUI then
		if not newUI then
			newUI = Instance.new("ScreenGui")
			newUI.Name = "Popups"
			newUI.DisplayOrder = 1000000
			newUI.IgnoreGuiInset = true
			newUI.ResetOnSpawn = false
			newUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			newUI.Parent = PlayerGui
			
			local OffsetFrame = Instance.new("Frame")
			OffsetFrame.Name = "Offset"
			OffsetFrame.Transparency = 1
			OffsetFrame.AnchorPoint = Vector2.new(0.5, 1)
			OffsetFrame.Position = UDim2.new(0.5, 0, 1, 0)
			OffsetFrame.Size = UDim2.new(1, 0, 0.4, 0)
			OffsetFrame.Parent = newUI

			local OffsetListLayout = Instance.new("UIListLayout")
			OffsetListLayout.Padding = UDim.new(0.04, 0)
			OffsetListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			OffsetListLayout.Parent = OffsetFrame

			local contentsFrame = Instance.new("Frame")
			contentsFrame.Name = "Contents"
			contentsFrame.Transparency = 1
			contentsFrame.Size = UDim2.new(1, 0, 0.1, 0)
			contentsFrame.Parent = OffsetFrame

			local ContentListLayout = Instance.new("UIListLayout")
			ContentListLayout.Padding = UDim.new(0.005, 0)
			ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			ContentListLayout.FillDirection = Enum.FillDirection.Horizontal
			ContentListLayout.Parent = contentsFrame
		end

		return newUI
	elseif newUI then
		if #newUI:GetChildren() == 0 then
			newUI:Destroy()
		end
	end
end

function CreateCooldown(cooldownTime)
	local cooldownUI = UpdateCooldownUI(true)

	local cooldownFrame = Instance.new("Frame")
	cooldownFrame.Name = "Cooldown"
	cooldownFrame.Transparency = 1
	cooldownFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	cooldownFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	cooldownFrame.Size = UDim2.new(1, 0, 1, 0)
	cooldownFrame.Parent = cooldownUI

	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	canvasGroup.Position = UDim2.new(0.5, 0, 0.58, 0)
	canvasGroup.Size = UDim2.new(0.12, 0, 0.1, 0)
	canvasGroup.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	canvasGroup.Parent = cooldownFrame

	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.AspectRatio = 20
	UIAspectRatioConstraint.Parent = canvasGroup

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = canvasGroup

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 2
	UIStroke.Parent = canvasGroup

	local fillerFrame = Instance.new("Frame")
	fillerFrame.Name = "Filler"
	fillerFrame.AnchorPoint = Vector2.new(0, 0.5)
	fillerFrame.Position = UDim2.new(0, 0, 0.5, 0)
	fillerFrame.Size = UDim2.new(1, 0, 1, 0)
	fillerFrame.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
	fillerFrame.Parent = canvasGroup

	local UICorner2 = Instance.new("UICorner")
	UICorner2.CornerRadius = UDim.new(1, 0)
	UICorner2.Parent = fillerFrame

	local decreaseTween = TweenService:Create(fillerFrame, TweenInfo.new(cooldownTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false), {Size = UDim2.new(0, 0, fillerFrame.Size.Y.Scale, 0)})
	decreaseTween:Play()

	decreaseTween.Completed:Connect(function()
		cooldownFrame:Destroy()
		UpdateCooldownUI()
	end)
end

function AddPopupFrame(popupText, popupTime)
	local PopupFrame = UpdatePopupUI(true)
	local ContentsFrame = PopupFrame.Offset.Contents
	
	local addedFrame = Instance.new("Frame")
	addedFrame.Transparency = 1
	addedFrame.Size = UDim2.new(1, 0, 1, 0)
	addedFrame.LayoutOrder = 1
	addedFrame.Parent = ContentsFrame
	
	local AddedFrameUIAspectRatio = Instance.new("UIAspectRatioConstraint")
	AddedFrameUIAspectRatio.AspectRatio = 5
	AddedFrameUIAspectRatio.Parent = addedFrame
	
	local addedImage = Instance.new("ImageLabel")
	addedImage.Transparency = 1
	addedImage.AnchorPoint = Vector2.new(1, 0.5)
	addedImage.Position = UDim2.new(1, 0, 0.5, 0)
	addedImage.Size = UDim2.new(1, 0, 1, 0)
	addedImage.Image = "rbxassetid://133236435262285"
	addedImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
	addedImage.Parent = addedFrame
	
	local AddedImageUIAspectRatio = Instance.new("UIAspectRatioConstraint")
	AddedImageUIAspectRatio.AspectRatio = 1
	AddedImageUIAspectRatio.Parent = addedImage
	
	local messageFrame = Instance.new("Frame")
	messageFrame.LayoutOrder = 2
	messageFrame.Transparency = 1
	messageFrame.Size = UDim2.new(0, 0, 1, 0)
	messageFrame.AutomaticSize = Enum.AutomaticSize.X
	messageFrame.Parent = ContentsFrame
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	messageLabel.BackgroundTransparency = 0.6
	messageLabel.AnchorPoint = Vector2.new(0, 0.5)
	messageLabel.Position = UDim2.new(0, 0, 0.5, 0)
	messageLabel.Size = UDim2.new(0, 0, 1, 0)
	messageLabel.AutomaticSize = Enum.AutomaticSize.X
	messageLabel.TextScaled = true
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.Text = ` {popupText} `
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.Parent = messageFrame
	
	local messageBorder = Instance.new("UIStroke")
	messageBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	messageBorder.Thickness = 2
	messageBorder.Transparency = 0.4
	messageBorder.Parent = messageLabel
	
	local messageStroke = Instance.new("UIStroke")
	messageStroke.LineJoinMode = Enum.LineJoinMode.Bevel
	messageStroke.Thickness = 1.5
	messageStroke.Parent = messageLabel
	
	local timerFrame = Instance.new("Frame")
	timerFrame.LayoutOrder = 3
	timerFrame.Transparency = 1
	timerFrame.Size = UDim2.new(1, 0, 1, 0)
	timerFrame.Parent = ContentsFrame
	
	local TimerFrameUIAspectRatio = Instance.new("UIAspectRatioConstraint")
	TimerFrameUIAspectRatio.AspectRatio = 5
	TimerFrameUIAspectRatio.Parent = timerFrame
	
	local timerLabel = Instance.new("TextLabel")
	timerLabel.BackgroundTransparency = 1
	timerLabel.AnchorPoint = Vector2.new(0, 0.5)
	timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
	timerLabel.Size = UDim2.new(1, 0, 1, 0)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.SourceSans
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerLabel.TextXAlignment = Enum.TextXAlignment.Left
	timerLabel.Parent = timerFrame
	
	local TimerUIAspectRatio = Instance.new("UIAspectRatioConstraint")
	TimerUIAspectRatio.AspectRatio = 1
	TimerUIAspectRatio.Parent = timerLabel
	
	local timerStroke = Instance.new("UIStroke")
	timerStroke.LineJoinMode = Enum.LineJoinMode.Bevel
	timerStroke.Thickness = 2
	timerStroke.Parent = timerLabel
	
	task.spawn(function()
		for currentTime = popupTime, 0, -0.1 do
			local roundedNumber = math.ceil(currentTime * 10)/10

			if tostring(roundedNumber):len() == 1 then
				timerLabel.Text = `{roundedNumber}.0s`
			else
				timerLabel.Text = `{roundedNumber}s`
			end
			
			task.wait(0.1)
		end
		
		PopupFrame:Destroy()
		UpdatePopupUI(false)
	end)
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

        local SamsoniteMap = foundMap:FindFirstChild("SamsoniteMap")

        if SamsoniteMap then
            local doorBank = SamsoniteMap:FindFirstChild("DoorBank")

            if doorBank then
                for _, realDoor in doorBank:GetChildren() do
                    if realDoor.DoorPrompt.Enabled == true then
                        realDoor.Name = "Escape"
                        table.insert(abilityTable, realDoor)
                    end
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
            if child.Name == "doorhandler" then continue end -- CONTINUE WHEN YOU GET MAP
            local childString = child.Name:lower()

            if childString:find("door") then
                table.insert(doorTable, doorModel)
            end
        end
    end
    
    return doorTable
end

function GetMaxCoins()
    localPlayer.CoinsToGive.Value = 55
end

function ActivateFullbright()
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
end

function UpdateAntiDebris()
    while Graphic_AntiDebris == true do
        local gameGui = PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return end

        local character = localPlayer.Character
        if not character then return end

        local infectedUI = game:FindFirstChild("Infected", true)
        if infectedUI then
            infectedUI:Destroy()
        end

        local stephanoUI = gameGui:FindFirstChild("StephanoLife")
        if stephanoUI then
            -- CONTINUE CODING
        end

        local foundFlash = gameGui:FindFirstChild("Flash")
        if foundFlash then
            foundFlash:Destroy()
        end

        local ventErrorScript = gameGui:FindFirstChild("VentError")
        if ventErrorScript then
            ventErrorScript:Destroy()
        end

        local springScare = gameGui:FindFirstChild("SpringScare")
        if springScare then
            springScare:Destroy()
        end

        local bloodUI = gameGui:FindFirstChild("BloodUI")
        if bloodUI then
            --bloodUI:Destroy()
        end

        local debuffsFrame = gameGui:FindFirstChild("Debuffs")
        if debuffsFrame then
            for _, child in debuffsFrame:GetChildren() do
                if not child:IsA("ImageLabel") then continue end

                child.Transparency = 1
                child.ImageTransparency = 1
            end
        end

        local monsterUIFrame = gameGui:FindFirstChild("MonsterUI")
        if monsterUIFrame then
            local radiatedUIFrame = monsterUIFrame:FindFirstChild("RadiatedUI")
            if radiatedUIFrame then
                radiatedUIFrame:Destroy()
            end
        end

        local overlaysFrame = gameGui:FindFirstChild("Overlays")
        if overlaysFrame then
            for _, child in overlaysFrame:GetChildren() do
                if not child:IsA("ImageLabel") then continue end

                child.Transparency = 1
                child.ImageTransparency = 1
                child.Visible = false
            end
        end

        local blindScript = character:FindFirstChild("Blind")
        if blindScript then
            blindScript:Destroy()
        end
        
        local foundMap = workspace:FindFirstChild("Map")

        if foundMap then
            for _, model in foundMap:GetChildren() do
                if model.Name == "HearingTape" then
                    model.AntiHear.Volume = 0.1
                end
            end
        end

        task.wait(0.1)
    end
end

function AutoMove()
    if KickMessageFound() then
        local character = localPlayer.Character
        if not character then return end
    
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
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
end

function KickMessageFound()
    local lobbyGui = PlayerGui:FindFirstChild("LobbyGUI")
    if not lobbyGui then return end

    local notificationsUI = lobbyGui:FindFirstChild("Notifications", true)
    if notificationsUI then
        for _, notificationLabel in notificationsUI.Notifications:GetChildren() do
            if not notificationLabel:IsA("ImageLabel") then continue end

            local textLabel = notificationLabel:FindFirstChildWhichIsA("TextLabel")
            if textLabel then

                local textContents = textLabel.Text:lower()
                if textContents:find("kicked") then
                    print("Found")
                    return true
                end
            end
        end
    end

    return false
end

function AutoJump()
    if KickMessageFound() then
        local character = localPlayer.Character
        if not character then return end
    
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
    
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

function AutoSolveBaldi()
    local gameGui = PlayerGui:FindFirstChild("GameGui")
    if not gameGui then return end
    
    local thinkpadUI = gameGui:FindFirstChild("ThinkPad")
    if not thinkpadUI then return end

    local mathQuestion = thinkpadUI.Question.Text
    local newQuestion = mathQuestion:gsub("=", "")
    local foundPlus = string.find(newQuestion, "+")

    local answerNumber
    
    if foundPlus then
        local splitEquation = newQuestion:split("+")
        answerNumber = splitEquation[1] + splitEquation[2]
    else
        local splitEquation = newQuestion:split("-")
        answerNumber = splitEquation[1] - splitEquation[2]
    end
    
    thinkpadUI.TextBox.Text = answerNumber

    local enterButton = thinkpadUI.Enter

    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize

    mousemoveabs(absPos.X + absSize.X/2, absPos.Y + absSize.Y)
    mouse1click()
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
    if not character then return end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    if humanoid.Health > 0 then
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

function GetPlayerInventory()
    local character = localPlayer.character
    if not character then return end

    local inventory = character:FindFirstChild("Inventory")
    if not inventory then return end

    return inventory
end

function InfiniteStephano()
    local inventory = GetPlayerInventory()
    if not inventory then return end

    local foundItem = inventory:FindFirstChild("Stephano")
    if not foundItem then return end

    for possibleStat, statValue in pairs(ItemToMaxStats["Stephano"]) do
        if statValue ~= nil then
            foundItem[possibleStat].Value = statValue
        end
    end
end

function InfiniteFlashlight()
    local inventory = GetPlayerInventory()
    if not inventory then return end

    for _, foundItem in inventory:GetChildren() do
        local itemName = foundItem.Name:lower()
        if not itemName:find("flashlight") then continue end

        for possibleStat, statValue in pairs(ItemToMaxStats[foundItem.Name]) do
            if statValue ~= nil then
                foundItem[possibleStat].Value = statValue
            end
        end
    end
end

function InfiniteGauntlet()
    local inventory = GetPlayerInventory()
    if not inventory then return end

    local foundItem = inventory:FindFirstChild("Doom's Gauntlet")
    if not foundItem then return end

    for possibleStat, statValue in pairs(ItemToMaxStats["Doom's Gauntlet"]) do
        if statValue ~= nil then
            foundItem[possibleStat].Value = statValue
        end
    end
end

function AddBorgerSuit()
    while Graphic_BorgerSuit == true do
        for _, player in Players:GetPlayers() do
            local character = player.Character
            if not character then continue end

            local BorgerPart = character:FindFirstChild("Borger")
            if not BorgerPart then continue end

            BorgerPart.Transparency = 0
        end

        task.wait(0.5)
    end
end

function AutoBuyItems()
    while Autobuy_Enabled == true do
        local LobbyGUI = PlayerGui.LobbyGUI
        if not LobbyGUI then return end

        local BuyItemEvent = LobbyGUI.ButtonFrames.ITEMSHOP.WorkItemGUI.BuyItem
        if not BuyItemEvent then return end

        for item, buyBool in AutobuyList do
            if buyBool == true then
                BuyItemEvent:FireServer(true, item)
            end
        end

        task.wait(0.1)
    end
end

function StartGodmodeAnchor()
    local character = localPlayer.character
    if not character then return end

    local PickupModels = ReplicatedStorage.Assets.PickupModels
    local GodEvent = PickupModels["Weird Mask"]["Weird Mask"]["SetupScript"].God
    
    local playerIsSurvivor = character:FindFirstChild("Alive")
    
    if playerIsSurvivor then
        GodEvent:FireServer()

        localPlayer.Character.HumanoidRootPart.Anchored = false
        localPlayer.Character.Head.Anchored = false
        localPlayer.Character.Torso.Anchored = false
        localPlayer.Character["Left Arm"].Anchored = false
        localPlayer.Character["Right Arm"].Anchored = false
        localPlayer.Character["Left Leg"].Anchored = false
        localPlayer.Character["Right Leg"].Anchored = false
    else
        OrionLib:MakeNotification({
            Name = "Not Allowed",
            Content = "You need to be a survivor to use this.",
            Image = "rbxassetid://96055863684080",
            Time = 3
        })
    end
end

function AutoLeaveAdmin()
    while Farm_AutoLeave == true do
        for _, player in Players:GetPlayers() do
            if table.find(AdminList, player.Name) then
                localPlayer:Kick("[Force Exit]: Admin joined experience.")
            end
        end

        task.wait(0.1)
    end
end

function AutoReset()
    while Farm_AutoReset == true do
        if autoActionCooldown == false then
            autoActionCooldown = true

            task.delay(1, function()
                autoActionCooldown = false
            end)

            local character = player.Character
            if not character then continue end
    
            local humanoid = player:FindFirstChildWhichIsA("Humanoid")
            if not humanoid then continue end 
            
            local playerIsSurvivor = character:FindFirstChild("Alive")
    
            if playerIsSurvivor and humanoid.Health > 0 then
                KillHumanoid()
            end
        end

        task.wait(0.1)
    end
end

function AutoMask()
    while Farm_AutoMask == true do
        if autoActionCooldown == false then
            autoActionCooldown = true

            task.delay(1, function()
                autoActionCooldown = false
            end)
            
            local character = player.Character
            if not character then continue end
    
            local humanoid = player:FindFirstChildWhichIsA("Humanoid")
            if not humanoid then continue end 
            
            local playerIsSurvivor = character:FindFirstChild("Alive")
    
            if playerIsSurvivor then
                BecomeZombie()
            end
        end

        task.wait(0.1)
    end
end

function UpdateFOV()
    CurrentCamera.FieldOfView = Graphic_FOVNumber
end

function ConserveStamina()
    local character = localPlayer.Character
    if not character then return end

    local StatFolder = character:FindFirstChild("Aspects")
    if not StatFolder then return end

    local currentStamina = StatFolder:FindFirstChild("Stamina")
    if not currentStamina then return end

    if currentStamina.Value <= 3 then
        StatFolder.CanSprint.Value = false
    else
        StatFolder.CanSprint.Value = true
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

local playerTab = Window:MakeTab({
	Name = "Player",
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

local notificationTab = Window:MakeTab({
	Name = "Notifications",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local graphicTab = Window:MakeTab({
	Name = "Graphics",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local farmTab = Window:MakeTab({
	Name = "Automatic",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local lobbyTab = Window:MakeTab({
	Name = "Lobby",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local autobuyTab = Window:MakeTab({
	Name = "Autobuy",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local configTab = Window:MakeTab({
	Name = "Config",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local helpTab = Window:MakeTab({
	Name = "Help",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local changelogTab = Window:MakeTab({
	Name = "Changelog",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Orion UI

mainTab:AddParagraph(`This GUI covers nearly everything possible on the client-side.`,`Version {currentVersion}`)

--[----]--

local espToggleSection = espTab:AddSection({
	Name = "Vision"
})

espToggleSection:AddToggle({
	Name = "ESP Enabled",
	Default = false,
    Flag = "Toggle_ESPEnabled",
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
    Flag = "Toggle_ViewKiller",
	Callback = function(Value)
        ESP_ViewKiller = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Survivor",
	Default = false,
    Flag = "Toggle_ViewSurvivor",
	Callback = function(Value)
        ESP_ViewSurvivor = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Item",
	Default = false,
    Flag = "Toggle_ViewItem",
	Callback = function(Value)
        ESP_ViewItem = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Objective",
	Default = false,
    Flag = "Toggle_ViewObjective",
	Callback = function(Value)
        ESP_ViewObjective = Value
	end    
})

selectionSection:AddToggle({
	Name = "View Ability",
	Default = false,
    Flag = "Toggle_ViewAbility",
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
    Flag = "Toggle_ShowHighlight",
	Callback = function(Value)
        ESP_ShowHighlight = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Name",
	Default = false,
    Flag = "Toggle_ShowName",
	Callback = function(Value)
        ESP_ShowName = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Icon",
	Default = false,
    Flag = "Toggle_ShowIcon",
	Callback = function(Value)
        ESP_ShowIcon = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Health",
	Default = false,
    Flag = "Toggle_ShowHealth",
	Callback = function(Value)
        ESP_ShowHealth = Value
	end    
})

addonSection:AddToggle({
	Name = "Show Distance",
	Default = false,
    Flag = "Toggle_ShowDistance",
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
    Flag = "Flag_ESPTransparency",
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
    Flag = "Flag_ESPRefreshRate",
	Callback = function(Value)
        ESP_RefreshRate = Value/1000
	end    
})

--[----]--

local playerStatusSection = playerTab:AddSection({
	Name = "Status"
})

playerStatusSection:AddToggle({
	Name = "Stamina Conservation",
	Default = false,
    Flag = "Toggle_StaminaConservation",
	Callback = function(Value)
        PLAYER_StaminaConservation = Value

        if PLAYER_StaminaConservation == true then
            RunService:BindToRenderStep("StaminaConservation", Enum.RenderPriority.First.Value, ConserveStamina)
        else
            RunService:UnbindFromRenderStep("StaminaConservation")
        end
	end    
})

local itemSpecialSection = playerTab:AddSection({
	Name = "Special"
})

itemSpecialSection:AddButton({
	Name = "Godmode Anchor",
	Callback = function()
        StartGodmodeAnchor()

        OrionLib:MakeNotification({
            Name = "Server Side",
            Content = "Your position has been locked in place.",
            Image = "rbxassetid://17889070713",
            Time = 5
        })
  	end    
})

--[----]--

local autoCounterSection = abilityTab:AddSection({
	Name = "Automatic Counter"
})

autoCounterSection:AddToggle({
	Name = "Auto Jump (MX)",
	Default = false,
    Flag = "Toggle_AutoJumpMX",
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

autoCounterSection:AddToggle({
	Name = "Auto Solve (Baldi)",
	Default = false,
    Flag = "Toggle_AutoSolveBaldi",
	Callback = function(Value)
        Ability_AutoSolveBaldi = Value

        if Ability_AutoSolveBaldi == true then
            RunService:BindToRenderStep("AutoSolveBaldi", Enum.RenderPriority.Last.Value, AutoSolveBaldi)
        else
            RunService:UnbindFromRenderStep("AutoSolveBaldi")
        end
	end    
})

local activeCounterSection = abilityTab:AddSection({
	Name = "Active Counter"
})

activeCounterSection:AddToggle({
	Name = "Instant Escape (EXE)",
	Default = false,
    Flag = "Toggle_InstantEscapeEXE",
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

activeCounterSection:AddToggle({
	Name = "Instant Break (Vapor)",
	Default = false,
    Flag = "Toggle_InstantBreakVapor",
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

--[----]--

local itemSpawnSection = itemTab:AddSection({
	Name = "Browser"
})

itemSpawnSection:AddDropdown({
	Name = "Item List",
	Default = "None",
	Options = {"None", "Weird Mask"},
	Callback = function(Value)
        Item_ItemSelected = Value
	end    
})

itemSpawnSection:AddButton({
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

local itemUsageSection = itemTab:AddSection({
	Name = "Usage"
})

itemUsageSection:AddToggle({
	Name = "Infinite Stephano",
	Default = false,
    Flag = "Toggle_InfiniteStephano",
	Callback = function(Value)
        Item_InfiniteStephano = Value

        if Item_InfiniteStephano == true then
            RunService:BindToRenderStep("InfiniteStephano", Enum.RenderPriority.Last.Value, InfiniteStephano)
        else
            RunService:UnbindFromRenderStep("InfiniteStephano")
        end
	end    
})

itemUsageSection:AddToggle({
	Name = "Infinite Flashlight",
	Default = false,
    Flag = "Toggle_InfiniteFlashlight",
	Callback = function(Value)
        Item_InfiniteFlashlight = Value

        if Item_InfiniteFlashlight == true then
            RunService:BindToRenderStep("InfiniteFlashlight", Enum.RenderPriority.Last.Value, InfiniteFlashlight)
        else
            RunService:UnbindFromRenderStep("InfiniteFlashlight")
        end
	end    
})

itemUsageSection:AddToggle({
	Name = "Infinite Gauntlet",
	Default = false,
    Flag = "Toggle_InfiniteGauntlet",
	Callback = function(Value)
        Item_InfiniteGauntlet = Value

        if Item_InfiniteGauntlet == true then
            RunService:BindToRenderStep("InfiniteGauntlet", Enum.RenderPriority.Last.Value, InfiniteGauntlet)
        else
            RunService:UnbindFromRenderStep("InfiniteGauntlet")
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
    Flag = "Toggle_MaximizeInteractDistance",
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
    Flag = "Toggle_InstantCompleteInteraction",
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

--[----]--

local popupSection = notificationTab:AddSection({
	Name = "Pop-Up"
})

popupSection:AddToggle({
	Name = "Pop-Ups Enabled",
	Default = false,
    Flag = "Toggle_PopUpsEnabled",
	Callback = function(Value)
        Notification_PopUpsEnabled = Value
        
        WorkInProgressNotification(Value)
	end    
})

local actionSection = notificationTab:AddSection({
	Name = "Actions"
})

actionSection:AddToggle({
	Name = "Show Attack Cooldown",
	Default = false,
    Flag = "Toggle_ShowAttackCooldown",
	Callback = function(Value)
        Notification_AttackCooldown = Value

        WorkInProgressNotification(Value)
	end    
})

actionSection:AddToggle({
	Name = "Show Ability Usage",
	Default = false,
    Flag = "Toggle_ShowAbilityUsage",
	Callback = function(Value)
        Notification_AbilityUsage = Value

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
    Flag = "Toggle_AntiDebris",
	Callback = function(Value)
        Graphic_AntiDebris = Value

        if Graphic_AntiDebris == true then
            UpdateAntiDebris()
        end
	end    
})

local worldSection = graphicTab:AddSection({
	Name = "World"
})

worldSection:AddToggle({
	Name = "Fullbright",
	Default = false,
    Flag = "Toggle_Fullbright",
	Callback = function(Value)
        Graphic_Fullbright = Value

        if Graphic_Fullbright == true then
            fullbrightConnection = RunService.PreRender:Connect(ActivateFullbright)
        elseif fullbrightConnection then
            fullbrightConnection:Disconnect()
            fullbrightConnection = nil
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
	end    
})

local cameraSection = graphicTab:AddSection({
	Name = "Camera"
})

cameraSection:AddToggle({
	Name = "Set FOV",
	Default = false,
    Flag = "Toggle_SetFOV",
	Callback = function(Value)
        Graphic_ThirdPerson = Value

        if Graphic_ThirdPerson == true then
            fovConnection = RunService.PreRender:Connect(UpdateFOV)
        elseif fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
	end    
})

cameraSection:AddSlider({
	Name = "FOV Degrees",
	Min = 0,
	Max = 120,
	Default = 75,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "°",
    Save = true,
    Flag = "Flag_FOVDegrees",
	Callback = function(Value)
        Graphic_FOVNumber = Value
	end    
})

local additionalSection = graphicTab:AddSection({
	Name = "Additional"
})

additionalSection:AddToggle({
	Name = "Borger Suit",
	Default = false,
    Flag = "Toggle_BorgerSuit",
	Callback = function(Value)
        Graphic_BorgerSuit = Value

        if Graphic_BorgerSuit == true then
            AddBorgerSuit()
        else
            for _, player in Players:GetPlayers() do
                local character = player.Character
                if not character then continue end
    
                local BorgerPart = character:FindFirstChild("Borger")
                if not BorgerPart then continue end
    
                BorgerPart.Transparency = 1
            end
        end
	end    
})

--[----]--

local rewardSection = farmTab:AddSection({
	Name = "Rewards"
})

rewardSection:AddToggle({
	Name = "Max Coins",
	Default = false,
    Flag = "Toggle_MaxCoins",
	Callback = function(Value)
        Farm_MaxCoins = Value

        if Farm_MaxCoins == true then
            RunService:BindToRenderStep("MaxCoins", Enum.RenderPriority.Last.Value, GetMaxCoins)
        else
            RunService:UnbindFromRenderStep("MaxCoins")
        end
	end    
})

local antiAFKSection = farmTab:AddSection({
	Name = "Anti-AFK"
})

antiAFKSection:AddToggle({
	Name = "Auto Walk",
	Default = false,
    Flag = "Toggle_FarmAutoWalk",
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
    Flag = "Toggle_FarmAutoJump",
	Callback = function(Value)
        Farm_AutoJump = Value

        WorkInProgressNotification(Value)
        
        --[[if Farm_AutoJump == true then
            RunService:BindToRenderStep("AutoJump", Enum.RenderPriority.Last.Value, AutoJump)
        else
            RunService:UnbindFromRenderStep("AutoJump")
        end]]
	end    
})

local afkGameplaySection = farmTab:AddSection({
	Name = "Gameplay"
})

afkGameplaySection:AddToggle({
	Name = "Auto Reset (Survivor)",
	Default = false,
    Flag = "Toggle_FarmAutoReset",
	Callback = function(Value)
        Farm_AutoReset = Value

        if Farm_AutoReset == true then
            AutoReset()
            
            OrionLib.Flags["Toggle_FarmAutoMask"]:Set(false)
        end
	end    
})

afkGameplaySection:AddToggle({
	Name = "Auto Mask (Survivor)",
	Default = false,
    Flag = "Toggle_FarmAutoMask",
	Callback = function(Value)
        Farm_AutoMask = Value

        if Farm_AutoMask == true then
            AutoMask()

            OrionLib.Flags["Toggle_FarmAutoReset"]:Set(false)
        end
	end    
})

local safetySection = farmTab:AddSection({
	Name = "Safety"
})

safetySection:AddToggle({
	Name = "Auto Leave (Admin)",
	Default = false,
    Flag = "Toggle_FarmAutoLeave",
	Callback = function(Value)
        Farm_AutoLeave = Value

        if Farm_AutoLeave == true then
            AutoLeaveAdmin()
        end
	end    
})

--[----]--

local colorPlayerSection = configTab:AddSection({
	Name = "Player Color"
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

local colorObjectSection = configTab:AddSection({
	Name = "Object Color"
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

local togglesSection = configTab:AddSection({
	Name = "Toggles"
})

togglesSection:AddToggle({
	Name = "Save Values",
	Default = false,
    Flag = "Toggle_SaveValues",
	Callback = function(Value)
        WorkInProgressNotification(Value)
	end    
})

togglesSection:AddButton({
	Name = "Disable All",
	Callback = function()
        for flag, _ in pairs(OrionLib.Flags) do
            if not flag:find("Toggle") then continue end

            OrionLib.Flags[flag]:Set(false)
        end

        OrionLib:MakeNotification({
            Name = "Pillar Chase Panel",
            Content = "All toggles have been disabled.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
  	end    
})

--[----]--

local lobbyWorldSection = lobbyTab:AddSection({
	Name = "World"
})

lobbyWorldSection:AddToggle({
	Name = "Mute Radio",
	Default = false,
    Flag = "Toggle_MuteLobbyRadio",
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
    Flag = "Toggle_AutoPlayFNF",
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

local autobuyToggleSection = autobuyTab:AddSection({
	Name = "Purchase"
})

autobuyToggleSection:AddToggle({
	Name = "Purchasing Active",
	Default = false,
    Flag = "Toggle_PurchasingActive",
	Callback = function(Value)
        Autobuy_Enabled = Value

        if Autobuy_Enabled == true then
            AutoBuyItems()
        end
	end    
})

local autobuyAvailableSection = autobuyTab:AddSection({
	Name = "Available"
})

autobuyAvailableSection:AddToggle({
	Name = "Flashlight",
	Default = false,
    Flag = "Toggle_AutobuyFlashlight",
	Callback = function(Value)
        AutobuyList["Flashlight"] = Value
	end    
})

autobuyAvailableSection:AddToggle({
	Name = "First Aid Kit",
	Default = false,
    Flag = "Toggle_AutobuyFirstAidKit",
	Callback = function(Value)
        AutobuyList["First Aid Kit"] = Value
	end    
})

autobuyAvailableSection:AddToggle({
	Name = "Ultra Flashlight",
	Default = false,
    Flag = "Toggle_AutobuyUltraFlashlight",
	Callback = function(Value)
        AutobuyList["Ultra Flashlight"] = Value
	end    
})

autobuyAvailableSection:AddToggle({
	Name = "Stephano",
	Default = false,
    Flag = "Toggle_AutobuyStephano",
	Callback = function(Value)
        AutobuyList["Stephano"] = Value
	end    
})

autobuyAvailableSection:AddToggle({
	Name = "Doom's Gauntlet",
	Default = false,
    Flag = "Toggle_AutobuyDoomsGauntlet",
	Callback = function(Value)
        AutobuyList["Doom's Gauntlet"] = Value
	end    
})

autobuyAvailableSection:AddToggle({
	Name = "Weird Mask",
	Default = false,
    Flag = "Toggle_AutobuyWeirdMask",
	Callback = function(Value)
        AutobuyList["Weird Mask"] = Value
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

--[----]--

local updatesSection = changelogTab:AddSection({
	Name = "Updates"
})

updatesSection:AddParagraph(`- Better FPS handling, more features`,"Added (2.0.9)")
updatesSection:AddParagraph(`- Fixed Autobuy, Better farming, +bugs`,"Added (2.0.8)")
updatesSection:AddParagraph(`- Updated Farm, +bugs`,"Added (2.0.7)")
updatesSection:AddParagraph(`- Added FOV, +bugs`,"Added (2.0.6)")
updatesSection:AddParagraph(`- Updated ESP, fixed missing PrimaryPart`,"Added (2.0.5)")
updatesSection:AddParagraph(`- Autobuy tab, Player tab, Better ESP, Safer farming`,"Added (2.0.4)")
updatesSection:AddParagraph(`- Changelog tab`,"Added (2.0.3)")

--[----]--

-- Runtime

OrionLib:Init()
