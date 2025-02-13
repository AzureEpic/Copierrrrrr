






local platforms = {}
local ReplicatedStorage = game.ReplicatedStorage
local SetNetworkOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner
local playerCharacter = game.Players.LocalPlayer.Character
local localPlayer = game.Players.LocalPlayer

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")


local houseenabled = false


local function spawnItem(itemName, position, orientation)
	task.spawn(function()
		local cframe = CFrame.new(position)
		local rotation = Vector3.new(0, 90, 0)
		ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
	end)
end


local blobalter = 1
local function blobGrabPlayer(player, blobman)
	if blobalter == 1 then
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local args = {
				[1] = blobman:FindFirstChild("LeftDetector"),
				[2] = player.Character:FindFirstChild("HumanoidRootPart"),
				[3] = blobman:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld")
			}
			blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
			blobalter = 2
		end
	else
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local args = {
				[1] = blobman:FindFirstChild("RightDetector"),
				[2] = player.Character:FindFirstChild("HumanoidRootPart"),
				[3] = blobman:FindFirstChild("RightDetector"):FindFirstChild("RightWeld")
			}
			blobman:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(args))
			blobalter = 1
		end
	end
end



local skibidiAuraCoroutine
local noclipGrabCoroutine
local ufoGrabCoroutine
local poisonGrabCoroutine
local fireGrabCoroutine
local poisonAuraCoroutine
local auraCoroutine
local blobmanCoroutine
local blobman 
_G.BlobmanDelay = 0.005
local crouchJumpCoroutine
local crouchSpeedCoroutine
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local fireAllCoroutine
local hellSendGrabCoroutine
local gravityCoroutine
local auraRadius = 30
local compiledGroups = {}
local compileConnections = {}
local compileCoroutine
local anchoredParts = {}
local renderSteppedConnections = {}
local anchoredConnections = {}
local anchorGrabCoroutine
local U = loadstring(game:HttpGet("https://raw.githubusercontent.com/Undebolted/Utilities/main/utilities.lua", true))()
local localPlayer = game.Players.LocalPlayer
local AutoRecoverDroppedPartsCoroutine
local autoDefendCoroutine
local antiExplosionConnection
local autoStruggleCoroutine
local ragdollAllCoroutine
local anchorAura


local function setupAntiExplosion(character)
	local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
	if partOwner then
		local partOwnerChangedConn
		partOwnerChangedConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
			if partOwner.Value then
				for _, part in ipairs(character:GetChildren()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end
			else
				for _, part in ipairs(character:GetChildren()) do
					if part:IsA("BasePart") then
						part.Anchored = false
					end
				end
			end
		end)
		antiExplosionConnection = partOwnerChangedConn
	end
end
local function getDescendantParts(descendantName)
	local parts = {}
	for _, descendant in ipairs(workspace.Map:GetDescendants()) do
		if descendant:IsA("Part") and descendant.Name == descendantName then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")


local function unanchorPrimaryPart()
	local primaryPart = anchoredParts[1]
	if not primaryPart then return end
	if primaryPart:FindFirstChild("BodyPosition") then
		primaryPart.BodyPosition:Destroy()
	end
	if primaryPart:FindFirstChild("BodyGyro") then
		primaryPart.BodyGyro:Destroy()
	end
	local highlight = primaryPart.Parent:FindFirstChild("Highlight") or primaryPart:FindFirstChild("Highlight")
	if highlight then
		highlight:Destroy()
	end
end

local function grabHandler(grabType)
	while true do
		local success, err = pcall(function()
			local child = workspace:FindFirstChild("GrabParts")
			if child and child.Name == "GrabParts" then
				local grabPart = child:FindFirstChild("GrabPart")
				local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
				local head = grabbedPart.Parent:FindFirstChild("Head")
				if head then
					while workspace:FindFirstChild("GrabParts") do
						local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
						for _, part in pairs(partsTable) do
							part.Size = Vector3.new(2, 2, 2)
							part.Transparency = 1
							part.Position = head.Position
						end
						wait()
						for _, part in pairs(partsTable) do
							part.Position = Vector3.new(0, -200, 0)
						end
					end
					for _, part in pairs(partsTable) do
						part.Position = Vector3.new(0, -200, 0)
					end
				end
			end
		end)
		wait()
	end
end

local function recoverParts()
	while true do
		local success, err = pcall(function()
			local character = localPlayer.Character
			if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
				local head = character.Head
				local humanoidRootPart = character.HumanoidRootPart

				for _, partModel in pairs(anchoredParts) do
					coroutine.wrap(function()
						if partModel then
							local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
							if distance <= 30 then
								local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
								if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
									SetNetworkOwner:FireServer(partModel, partModel.CFrame)
									if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
										highlight.OutlineColor = Color3.new(0, 0, 1)
										print("yoyoyo set and r eady")
									end
								end
							end
						end
					end)()
				end
			end
		end)
		wait(0.02)
	end
end

local function onPartOwnerAdded(descendant, primaryPart)
	if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
		local highlight = primaryPart:FindFirstChild("Highlight") or U.GetDescendant(U.FindFirstAncestorOfType(primaryPart, "Model"), "Highlight", "Highlight")
		if highlight then
			if descendant.Value ~= localPlayer.Name then
				highlight.OutlineColor = Color3.new(1, 0, 0)
			else
				highlight.OutlineColor = Color3.new(0, 0, 1)
			end
		end
	end
end

local function cleanupConnections(connectionTable)
	for _, connection in ipairs(connectionTable) do
		connection:Disconnect()
	end
	connectionTable = {}
end
local function cleanupAnchoredParts()
	for _, part in ipairs(anchoredParts) do
		if part then
			if part:FindFirstChild("BodyPosition") then
				part.BodyPosition:Destroy()
			end
			if part:FindFirstChild("BodyGyro") then
				part.BodyGyro:Destroy()
			end
			local highlight = part:FindFirstChild("Highlight") or part.Parent and part.Parent:FindFirstChild("Highlight")
			if highlight then
				highlight:Destroy()
			end
		end
	end

	cleanupConnections(anchoredConnections)
	anchoredParts = {}
end


local function isDescendantOf(target, other)
	local currentParent = target.Parent
	while currentParent do
		if currentParent == other then
			return true
		end
		currentParent = currentParent.Parent
	end
	return false
end


local function updateBodyMovers(primaryPart)
	-- Iterate through all groups
	for _, group in ipairs(compiledGroups) do
		if group.primaryPart and group.primaryPart == primaryPart then
			-- Collect all parts in the group
			local parts = {}
			for _, item in ipairs(group.group) do
				if item.part:IsA("BasePart") then
					table.insert(parts, item.part)
				else
					warn("Invalid part detected, skipping:", item.part)
				end
			end

			-- Create NoCollisionConstraints between every pair of parts
			for i = 1, #parts do
				for j = i + 1, #parts do
					local partA = parts[i]
					local partB = parts[j]

					-- Check if the constraint already exists
					local constraintName = "NoCollisionConstraint_" .. partB.Name
					if not partA:FindFirstChild(constraintName) then
						local success, err = pcall(function()
							local noCollide = Instance.new("NoCollisionConstraint")
							noCollide.Name = constraintName
							noCollide.Part0 = partA
							noCollide.Part1 = partB
							noCollide.Parent = partA
						end)
						if not success then
							warn("Error creating NoCollisionConstraint:", err)
						end
					else
						print("Constraint already exists for:", partA.Name, "and", partB.Name)
					end
				end
			end

			-- Update BodyMovers for each part in the group
			for _, item in ipairs(group.group) do
				local part = item.part
				local offset = item.offset

				-- Ensure the part has valid BodyMovers
				local bodyPosition = part:FindFirstChild("BodyPosition")
				local bodyGyro = part:FindFirstChild("BodyGyro")

				if bodyPosition then
					bodyPosition.Position = (primaryPart.CFrame * offset).Position
				end
				if bodyGyro then
					bodyGyro.CFrame = primaryPart.CFrame * offset
				end
			end
		end
	end
end





local function createBodyMovers(part, position, rotation)
	local bodyPosition = Instance.new("BodyPosition")
	local bodyGyro = Instance.new("BodyGyro")

	bodyPosition.P = 50000
	bodyPosition.D = 200
	bodyPosition.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyPosition.Position = position
	bodyPosition.Parent = part

	bodyGyro.P = 50000
	bodyGyro.D = 200
	bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
	bodyGyro.CFrame = rotation
	bodyGyro.Parent = part
end

local function cleanupCompiledGroups()
	for _, groupData in ipairs(compiledGroups) do
		for _, data in ipairs(groupData.group) do
			if data.part then
				if data.part:FindFirstChild("BodyPosition") then
					data.part.BodyPosition:Destroy()
				end
				if data.part:FindFirstChild("BodyGyro") then
					data.part.BodyGyro:Destroy()
				end
			end
		end
		if groupData.primaryPart and groupData.primaryPart.Parent then
			local highlight = groupData.primaryPart:FindFirstChild("Highlight") or groupData.primaryPart.Parent:FindFirstChild("Highlight")
			if highlight then
				highlight:Destroy()
			end
		end
	end

	cleanupConnections(compileConnections)
	cleanupConnections(renderSteppedConnections)
	compiledGroups = {}
end

local function compileCoroutineFunc()
	while true do
		pcall(function()
			for _, groupData in ipairs(compiledGroups) do
				updateBodyMovers(groupData.primaryPart)
			end
		end)
		wait()
	end
end



local Players = game:GetService("Players")
local pos 
local function checkSafe(plr)
	local player = Players:FindFirstChild(plr)
	if player then
		local inPlot = player:FindFirstChild("InPlot")
		if inPlot and inPlot:IsA("BoolValue") then
			if inPlot.Value == true then
				return true
			end
		end
	end
	return true
end

local function createHighlight(parent)
	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillTransparency = 1
	highlight.Name = "Highlight"
	highlight.OutlineColor = Color3.new(0, 0, 1)
	highlight.OutlineTransparency = 0.5
	highlight.Parent = parent
	print("highlighted "..parent.Name)
	return highlight
end


local function anchorGrab()
	while true do
		pcall(function()
			local grabParts = workspace:FindFirstChild("GrabParts")
			if not grabParts then return end

			local grabPart = grabParts:FindFirstChild("GrabPart")
			if not grabPart then return end

			local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
			if not weldConstraint or not weldConstraint.Part1 then return end

			local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
			if not primaryPart then return end
			if primaryPart.Anchored then return end

			if isDescendantOf(primaryPart, workspace.Map) then return end
			for _, player in pairs(Players:GetChildren()) do
				---	if isDescendantOf(primaryPart, player.Character) then return end 
			end
			local t = true
			for _, v in pairs(primaryPart:GetDescendants()) do
				if table.find(anchoredParts, v) then
					t = false
				end

			end
			if t and not table.find(anchoredParts, primaryPart) then
				local target 
				if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
					target = U.FindFirstAncestorOfType(primaryPart, "Model")
				else
					target = primaryPart
				end

				local highlight = createHighlight(target)
				table.insert(anchoredParts, primaryPart)

				print(target)
				local connection = target.DescendantAdded:Connect(function(descendant)
					onPartOwnerAdded(descendant, primaryPart)
				end)
				table.insert(anchoredConnections, connection)
			end


			if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then 
				for _, child in ipairs(U.FindFirstAncestorOfType(primaryPart, "Model"):GetDescendants()) do
					if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
						child:Destroy()
					end
				end
			else
				for _, child in ipairs(primaryPart:GetChildren()) do
					if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
						child:Destroy()
					end
				end
			end

			while workspace:FindFirstChild("GrabParts") do
				wait()
			end
			createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
		end)
		wait()
	end
end

local function noclipGrab()
	while true do
		local success, err = pcall(function()
			local child = workspace:FindFirstChild("GrabParts")
			if child and child.Name == "GrabParts" then
				local grabPart = child:FindFirstChild("GrabPart")
				local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
				local character = grabbedPart.Parent
				if character.HumanoidRootPart then
					while workspace:FindFirstChild("GrabParts") do
						for _, part in pairs(character:GetChildren()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
						wait()
					end
					for _, part in pairs(character:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanCollide = true
						end
					end
				end
			end
		end)
		wait()
	end
end



local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local function spawnItemCf(itemName, cframe)
	task.spawn(function()
		local rotation = Vector3.new(0, 0, 0)
		ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
	end)
end


local function DestroyT(toy)
	local toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
	DestroyToy:FireServer(toy)
end



local function arson(part)
	if not toysFolder:FindFirstChild("Campfire") then
		spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
	end
	local campfire = toysFolder:FindFirstChild("Campfire")
	burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
	burnPart.Size = Vector3.new(7, 7, 7)
	burnPart.Position = part.Position
	task.wait(0.3)
	burnPart.Position = Vector3.new(0, -50, 0)
	DestroyT(toysFolder:FindFirstChild("Campfire"))
end


local function fireGrab()
	while true do
		local success, err = pcall(function()
			local child = workspace:FindFirstChild("GrabParts")
			if child and child.Name == "GrabParts" then
				local grabPart = child:FindFirstChild("GrabPart")
				local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
				local head = grabbedPart.Parent:FindFirstChild("Head")
				if head then
					arson(head)
				end
			end
		end)
		wait()
	end
end




local function fireAll()
	while true do
		local success, err = pcall(function()
			if toysFolder:FindFirstChild("Campfire") then
				DestroyT(toysFolder:FindFirstChild("Campfire"))
				wait(0.5)
			end
			spawnItemCf("Campfire", playerCharacter.Head.CFrame)
			local campfire = toysFolder:WaitForChild("Campfire")
			local firePlayerPart
			for _, part in pairs(campfire:GetChildren()) do
				if part.Name == "FirePlayerPart" then
					part.Size = Vector3.new(10, 10, 10)
					firePlayerPart = part
					break
				end
			end
			local originalPosition = playerCharacter.Torso.Position
			SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
			playerCharacter:MoveTo(firePlayerPart.Position)
			wait(0.3)
			playerCharacter:MoveTo(originalPosition)
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.P = 20000
			bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
			bodyPosition.Parent = campfire.Main
			while true do
				for _, player in pairs(Players:GetChildren()) do
					pcall(function()
						bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
						if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
							firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
							wait()
						end
					end)
				end  
				wait()
			end
		end)
		if not success then
			warn("Error in fireAll: " .. tostring(err))
		end
		wait()
	end
end




--[[ 
WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

--[[ 
Creator: SinoXde
Working as of: 10/20/2024
Supports (Tested): Wave, Synapse Z 
This Script falls under the MIT License. Copyright (c) 2024 SinoXde
Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
IN THE SOFTWARE.
]]

local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AzureEpic/orion/main/nee"))()

_G.FTAP = {}
_G.FTAP.GuiLibrary = GuiLibrary
_G.FTAP.connections = {}


_G.Sword = {}
_G.Sword.Range = 17
_G.Sword.Power = 4000
_G.Sword.Pressure = 4000

local Settings = {}
Settings['OwnedParts'] = {}


local function compileGroup()
	if #anchoredParts == 0 then 

		GuiLibrary:Notify({
			Title = "Error",
			Content = "no anchored parts found",
			Duration = 2,
			Image = 4483362458
		})
	else
		GuiLibrary:Notify({
			Title = "Success",
			Content = "welded "..#anchoredParts.. "toys",
			Duration = 2,
			Image = 4483362458
		})
	end

	local primaryPart = anchoredParts[1]
	if not primaryPart then return end

	local highlight =  primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
	if not highlight then
		highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
	end
	highlight.OutlineColor = Color3.new(0, 1, 0) 


	local group = {}
	for _, part in ipairs(anchoredParts) do
		if part ~= primaryPart then
			local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
			table.insert(group, {part = part, offset = offset})
		end
	end
	table.insert(compiledGroups, {primaryPart = primaryPart, group = group})

	local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
		updateBodyMovers(primaryPart)
	end)
	table.insert(compileConnections, connection)

	local renderSteppedConnection = game:GetService("RunService").Heartbeat:Connect(function()
		updateBodyMovers(primaryPart)
	end)
	table.insert(renderSteppedConnections, renderSteppedConnection)
end



local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainWindow = GuiLibrary:CreateWindow({
	Name = "ftap utg " ..  "- " ..identifyexecutor(),
	LoadingTitle = "eskibidi yes",
	LoadingSubtitle = "Azureworks",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "rftedt",
		FileName = "Configuration"
	},
	KeySystem = false
})













local FlingTab = MainWindow:CreateTab("Fling", 4483362458)
local DefenseTab = MainWindow:CreateTab("Defense", 395920626)
local CharTab = MainWindow:CreateTab("Character", 395920626)
local WeaponsTab = MainWindow:CreateTab("Weapons", 4483362458)
local BlobmanTab = MainWindow:CreateTab("Blobman ??", 4483362458)
local AllTab = MainWindow:CreateTab("All", 4483362458)
local AuraTab = MainWindow:CreateTab("Aura", 4483362458)
local PartsTab = MainWindow:CreateTab("Parts", 8236335288)
local SettingsTab = MainWindow:CreateTab("Settings", 4483362458)
local DevTab = MainWindow:CreateTab("DevTest", 18430523207)




-- Settings
SettingsTab:CreateSection("Save")
SettingsTab:CreateButton({
	Name = "Save Configuration",
	Callback = function()
		GuiLibrary:SaveConfiguration()
	end
})

SettingsTab:CreateSection("Exit")

_G.FTAP.Unload = function()
	_G.FTAP.GuiLibrary:Destroy()
	for i, connection in pairs(_G.FTAP.connections) do
		connection:Disconnect()
	end
	_G.FTAP = {}
end

SettingsTab:CreateButton({
	Name = "Unload Script",
	Callback = function()
		pcall(function()
			_G.FTAP.Unload()
			_G.FTAP = {}
		end)
	end
})

-- Fling
FlingTab:CreateSection("OP Fling")
FlingTab:CreateLabel("Just make them vanish...")

Settings['SuperFlingToggle'] = false
local SuperFlingToggle = FlingTab:CreateToggle({
	Name = "Toggle Super Fling",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(Value)
		Settings['SuperFlingToggle'] = Value
		GuiLibrary:Notify({
			Title = (Settings['SuperFlingToggle'] and "Enabled!" or "Disabled!"),
			Content = "Super-Fling has been Toggled!",
			Duration = 2,
			Image = 4483362458
		})
	end
})

local SuperFlingKeybind = FlingTab:CreateKeybind({
	Name = "Toggle Keybind",
	CurrentKeybind = "V",
	HoldToInteract = false,
	Flag = "SuperFlingKeybind",
	Callback = function()
		SuperFlingToggle:Set(not Settings['SuperFlingToggle'])
	end
})

FlingTab:CreateSection("Protection")
FlingTab:CreateLabel("Protect yourself against 'attacks'...")

Settings['ProtectionToggle'] = false
local ProtectionToggle = FlingTab:CreateToggle({
	Name = "Toggle Protection",
	CurrentValue = false,
	Flag = "ProtectionToggle",
	Callback = function(Value)
		Settings['ProtectionToggle'] = Value

		if Value == false then
			if _G.FTAP.connections.Protection then
				_G.FTAP.connections.Protection:Disconnect()
				_G.FTAP.connections.Protection = nil
			end
		else
			_G.FTAP.connections.Protection = Workspace.ChildAdded:Connect(function()
				for i = 1, 10 do
					ReplicatedStorage:WaitForChild("CharacterEvents"):WaitForChild("Struggle"):FireServer()
					task.wait(0.15)
				end
				print("Protected your ass :D!")
			end)
		end

		GuiLibrary:Notify({
			Title = (Value and "Enabled!" or "Disabled!"),
			Content = "Protection has been Toggled!",
			Duration = 2,
			Image = 4483362458
		})
	end
})

local ProtectionKeybind = FlingTab:CreateKeybind({
	Name = "Toggle Keybind",
	CurrentKeybind = "X",
	HoldToInteract = false,
	Flag = "ProtectionKeybind",
	Callback = function()
		ProtectionToggle:Set(not Settings['ProtectionToggle'])
	end
})

-- More script content can be added here if needed...

local OriginalPos = Players.LocalPlayer.Character
	and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	and Players.LocalPlayer.Character.HumanoidRootPart.CFrame

local kall = AllTab:CreateButton({
	Name = "Farlands All",
	Callback = function()
		pos = game.Players.LocalPlayer.Character.Torso.CFrame
		if not OriginalPos then
			GuiLibrary:Notify({
				Title = "Error",
				Content = "Could not find LocalPlayer's position.",
				Duration = 2,
				Image = 4483362458
			})
			return
		end

		for _, targetPlayer in pairs(Players:GetPlayers()) do
			if targetPlayer ~= Players.LocalPlayer
				and targetPlayer.Character
				and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then

				local inPlot = targetPlayer:FindFirstChild("InPlot")
				if inPlot and not inPlot.Value then
					local redos = 0
					repeat
						local targetHRP = targetPlayer.Character.HumanoidRootPart
						-- Ensure target is within range
						if (targetHRP.Position - Vector3.new(0, 0, 0)).Magnitude < 2500 then
							-- Pivot player 5 studs below
							local belowTargetHRP = targetHRP.CFrame * CFrame.new(0, -20, 0)
							game.Players.LocalPlayer.Character:PivotTo(belowTargetHRP)

							-- Fire server to change network ownership
							local args = { [1] = targetHRP, [2] = targetHRP.CFrame }
							game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(unpack(args))

							-- Apply velocity
							targetHRP.AssemblyLinearVelocity = Vector3.new(1000000, 1000000, -1000000)
							task.wait() -- Small delay to prevent client overload
						else
							break -- Exit loop if target is out of range
						end
						redos += 1
					until redos == 15
				end
			end
		end
		game.Players.LocalPlayer.Character:PivotTo(pos)
	end
})

local Input = FlingTab:CreateInput({
	Name = "Farland Player",
	CurrentValue = "",
	PlaceholderText = "Enter Player Name",
	RemoveTextAfterFocusLost = true,
	Flag = "Input1",
	Callback = function(Text)

		pos = game.Players.LocalPlayer.Character.Torso.CFrame

		local targetPlayer = game.Players:FindFirstChild(Text)
		if targetPlayer then
			if targetPlayer ~= game.Players.LocalPlayer
				and targetPlayer.Character
				and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then

				local inPlot = targetPlayer:FindFirstChild("InPlot")
				if inPlot and not inPlot.Value then
					local redos = 0
					repeat
						local targetHRP = targetPlayer.Character.HumanoidRootPart
						-- Ensure target is within range
						if (targetHRP.Position - Vector3.new(0, 0, 0)).Magnitude < 2500 then
							-- Pivot player 20 studs below
							local belowTargetHRP = targetHRP.CFrame * CFrame.new(0, -20, 0)
							game.Players.LocalPlayer.Character:PivotTo(belowTargetHRP)

							-- Fire server to change network ownership
							local args = { [1] = targetHRP, [2] = targetHRP.CFrame }
							game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(unpack(args))

							-- Apply velocity
							targetHRP.AssemblyLinearVelocity = Vector3.new(1000000, 1000000, -1000000)
							task.wait(0.1) -- Small delay to prevent client overload
						else
							GuiLibrary:Notify({
								Title = "Out of Range",
								Content = targetPlayer.Name .. " is too far away",
								Duration = 4,
								Image = 4483362458
							})
							break -- Exit loop if target is out of range
						end
						redos += 1
					until redos == 15
				else
					GuiLibrary:Notify({
						Title = "target plot camping",
						Content = targetPlayer.Name .. " is plot camping :skull:",
						Duration = 4,
						Image = 4483362458
					})
				end
			else
				GuiLibrary:Notify({
					Title = "Invalid Target",
					Content = targetPlayer.Name .. " is not a valid target!",
					Duration = 4,
					Image = 4483362458
				})
			end
		else
			GuiLibrary:Notify({
				Title = "Player Not Found",
				Content = "No such player exists!",
				Duration = 4,
				Image = 4483362458
			})
		end

		game.Players.LocalPlayer.Character:PivotTo(pos)

	end
})





local FireG = FlingTab:CreateToggle({
	Name = "Fire Grab",
	CurrentValue = false,
	Flag = "FireGrab",
	Callback = function(enabled)
		if enabled then
			fireGrabCoroutine = coroutine.create(fireGrab)
			coroutine.resume(fireGrabCoroutine)
		else
			if fireGrabCoroutine then
				coroutine.close(fireGrabCoroutine)
				fireGrabCoroutine = nil
			end
		end
	end
})


local PoisonG = FlingTab:CreateToggle({
	Name = "Poison Grab",
	CurrentValue = false,
	Flag = "PoisonGrab",
	Callback = function(enabled)
		if enabled then
			poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
			coroutine.resume(poisonGrabCoroutine)
		else
			if poisonGrabCoroutine then
				coroutine.close(poisonGrabCoroutine)
				poisonGrabCoroutine = nil
				for _, part in pairs(poisonHurtParts) do
					part.Position = Vector3.new(0, -200, 0)
				end
			end
		end
	end
})




local RadiationG = FlingTab:CreateToggle({
	Name = "Radiation Grab",
	CurrentValue = false,
	Flag = "RadiationGrab",
	Callback = function(enabled)
		if enabled then
			ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
			coroutine.resume(ufoGrabCoroutine)
		else
			if ufoGrabCoroutine then
				coroutine.close(ufoGrabCoroutine)
				ufoGrabCoroutine = nil
				for _, part in pairs(paintPlayerParts) do
					part.Position = Vector3.new(0, -200, 0)
				end
			end
		end
	end
})



local NoclipG = FlingTab:CreateToggle({
	Name = "Noclip Grab",
	CurrentValue = false,
	Flag = "NoclipGrab",
	Callback = function(enabled)
		if enabled then
			noclipGrabCoroutine = coroutine.create(noclipGrab)
			coroutine.resume(noclipGrabCoroutine)
		else
			if noclipGrabCoroutine then
				coroutine.close(noclipGrabCoroutine)
				noclipGrabCoroutine = nil
			end
		end
	end
})







local kall = AllTab:CreateButton({
	Name = "bring all",
	Callback = function()
		pos = game.Players.LocalPlayer.Character.Torso.CFrame
		if not OriginalPos then
			GuiLibrary:Notify({
				Title = "Error",
				Content = "Could not find LocalPlayer's position.",
				Duration = 2,
				Image = 4483362458
			})
			return
		end

		for _, targetPlayer in pairs(Players:GetPlayers()) do
			if targetPlayer ~= Players.LocalPlayer
				and targetPlayer.Character
				and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then

				local inPlot = targetPlayer:FindFirstChild("InPlot")
				if inPlot and not inPlot.Value then
					local redos = 0
					repeat
						local targetHRP = targetPlayer.Character.HumanoidRootPart
						-- Ensure target is within range
						if (targetHRP.Position - Vector3.new(0, 0, 0)).Magnitude < 50000 then
							-- Pivot player 5 studs below
							local belowTargetHRP = targetHRP.CFrame * CFrame.new(0, -20, 0)
							game.Players.LocalPlayer.Character:PivotTo(belowTargetHRP)

							-- Fire server to change network ownership
							local args = { [1] = targetHRP, [2] = targetHRP.CFrame }
							game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(unpack(args))

							-- Apply velocity
							local bodyPosition = Instance.new("BodyPosition")
							bodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)  -- Very high force, but not as extreme as 9e9
							bodyPosition.P = 100000  -- High responsiveness for faster movement, but manageable
							bodyPosition.Position = pos.Position + Vector3.new(0, 5, 0)  -- Position slightly above the target

							-- Parent BodyPosition to the target's HRP
							bodyPosition.Parent = targetHRP

							-- Wait and clean up
							task.delay(2, function()
								bodyPosition:Destroy()
							end)
							task.wait() -- Small delay to prevent client overload
						else
							break -- Exit loop if target is out of range
						end
						redos += 1
					until redos == 15
				end
			end
		end
		game.Players.LocalPlayer.Character:PivotTo(pos + Vector3.new(0,20,0))
	end
})


local rs = WeaponsTab:CreateButton({
	Name = "Remove Sword",
	Callback = function()
		game.Players.LocalPlayer.PlayerGui.Attack:Destroy()
		game.Players.LocalPlayer.Character.EpicTool:Destroy()
		DestroyT(toysFolder:FindFirstChild("NinjaKatana"))
	end
})



WeaponsTab:CreateButton({
	Name = "Fling Sword",
	Callback = function()
		pcall(function()

			local tool = Instance.new("Tool")  -- Create the Tool
			tool.Name = "EpicTool"

			local handle = Instance.new("Part")  -- Create the Handle
			handle.Name = "Handle"
			handle.Size = Vector3.new(2, 1, 1)  -- Adjust size as needed
			handle.Color = Color3.fromRGB(0, 100, 255)  -- Set color (adjust as needed)
			handle.Material = Enum.Material.SmoothPlastic
			handle.Anchored = false
			handle.CanCollide = false

			handle.Parent = tool  -- Parent Handle to the Tool

			local parentFolder = workspace:FindFirstChild(game.Players.LocalPlayer.Name)  -- Find the folder or model
			if parentFolder then
				tool.Parent = parentFolder  -- Parent the tool to "workspace.TheAzureEpic"
			else
				warn("TheAzureEpic not found in workspace!")  -- Warn if the target doesn't exist
			end

			-- Gui to Lua
			-- Version: 3.2

			-- Instances:

			local Attack = Instance.new("ScreenGui")
			local Car = Instance.new("ImageButton")
			local ImageLabel = Instance.new("ImageLabel")

			--Properties:

			Attack.Name = "Attack"
			Attack.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			Attack.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

			Car.Name = "Car"
			Car.Parent = Attack
			Car.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Car.BackgroundTransparency = 1.000
			Car.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Car.BorderSizePixel = 0
			Car.Position = UDim2.new(0.774687111, 0, 0.535222828, 0)
			Car.Size = UDim2.new(0.0576243624, 0, 0.0982319489, 0)
			Car.Image = "rbxassetid://97166444"

			ImageLabel.Parent = Car
			ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageLabel.BackgroundTransparency = 1.000
			ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ImageLabel.BorderSizePixel = 0
			ImageLabel.Position = UDim2.new(0.144329891, 0, 0.109999999, 0)
			ImageLabel.Size = UDim2.new(0.711340189, 0, 0.779999971, 0)
			ImageLabel.Image = "rbxasset://Textures/Sword128.png"

			-- Scripts:

			local function HPFYMBB_fake_script() -- Car.SwordFling 
				local script = Instance.new('LocalScript', Car)

				local deb = false


				local plr = game.Players.LocalPlayer
				local plrname = plr.Name
				local toys = workspace[plr.Name.."SpawnedInToys"]
				if toys then




					local args = {
						[1] = "NinjaKatana",
						[2] = CFrame.new(-21.50967025756836, -5.673497200012207, 96.73792266845703, 0.7071072459220886, -0.2501819431781769, 0.6613686084747314, 0, 0.9353170394897461, 0.3538108766078949, -0.7071064114570618, -0.25018224120140076, 0.6613693833351135),
						[3] = Vector3.new(0, 45, 0)
					}

					game:GetService("ReplicatedStorage"):WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction"):InvokeServer(unpack(args))

					local args = {
						[1] = workspace[plrname.."SpawnedInToys"]:WaitForChild("NinjaKatana"):WaitForChild("StickyPart"),
						[2] = workspace[plrname]:WaitForChild("Right Arm"),
						[3] = CFrame.new(0.1650543212890625, -0.6628170013427734, -2.8087310791015625, -0.0005563026643358171, -0.9999656677246094, -0.00826698075979948, 0.007902976125478745, 0.00826234370470047, -0.9999346733093262, 0.9999686479568481, -0.0006215954781509936, 0.007898111827671528)
					}

					game:GetService("ReplicatedStorage"):WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent"):FireServer(unpack(args))


				end


				script.Parent.MouseButton1Click:Connect(function() 
					if deb == true then return end
					deb = true




					-- Play sword lunge sound
					local sound = Instance.new("Sound")
					sound.Parent = workspace
					sound.SoundId = "http://www.roblox.com/asset/?id=12222208"
					sound:Play()
					local plr = game.Players.LocalPlayer
					local char = plr.Character
					local hum = char:FindFirstChildOfClass("Humanoid")
					local primaryPart = char.PrimaryPart


					local idle = Instance.new("Animation")
					idle.AnimationId = "rbxassetid://182393478" -- Animation ID

					local anim = Instance.new("Animation")
					anim.AnimationId = "rbxassetid://129967390" -- Animation ID

					if hum and primaryPart then
						-- Play the animation

						hum:LoadAnimation(anim):Play()


						for _, thing in pairs(workspace:GetDescendants()) do
							if thing:IsA("Model") then
								local otherhum = thing:FindFirstChildOfClass("Humanoid")
								if otherhum and otherhum ~= hum then
									local hrp = thing.PrimaryPart or thing:FindFirstChild("HumanoidRootPart")
									if hrp and hrp:IsA("BasePart") then
										local distance = (hrp.Position - primaryPart.Position).Magnitude
										if distance < _G.Sword.Range then -- Check if within range
											-- Set the network owner for smooth replication
											local args = {
												[1] = hrp,
												[2] = hrp.CFrame
											}
											game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(unpack(args))

											local flingDirection = (hrp.Position - primaryPart.Position).Unit * 50 -- Direction and force

											-- Create a BodyVelocity instance
											local bodyVelocity = Instance.new("BodyVelocity")
											bodyVelocity.Velocity = flingDirection
											bodyVelocity.MaxForce = Vector3.new(_G.Sword.Power, _G.Sword.Power, _G.Sword.Power) -- Adjust as needed for control
											bodyVelocity.P = _G.Sword.Pressure -- Power of the BodyVelocity
											bodyVelocity.Parent = hrp

											-- Remove the BodyVelocity after a short duration to prevent continuous motion
											game:GetService("Debris"):AddItem(bodyVelocity, 0.2) -- 0.2 seconds is enough for the fling effect
										end
									end
								end
							end
						end
					end

					deb = false
				end)
			end
			coroutine.wrap(HPFYMBB_fake_script)()





		end)
	end
})






local rs = WeaponsTab:CreateButton({
	Name = "Remove Lunge Button",
	Callback = function()
		game.Players.LocalPlayer.PlayerGui.Lunge:Destroy()
	end
})



WeaponsTab:CreateButton({
	Name = "Lunge Button",
	Callback = function()
		pcall(function()
			-- Gui to Lua
			-- Gui to Lua
			-- Version: 3.2

			-- Instances:

			local Attack = Instance.new("ScreenGui")
			local Car = Instance.new("ImageButton")
			local ImageLabel = Instance.new("ImageLabel")

			--Properties:

			Attack.Name = "Lunge"
			Attack.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			Attack.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

			Car.Name = "Car"
			Car.Parent = Attack
			Car.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Car.BackgroundTransparency = 1.000
			Car.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Car.BorderSizePixel = 0
			Car.Position = UDim2.new(0.774687111, 0, 0.424915403, 0)
			Car.Size = UDim2.new(0.0576243624, 0, 0.0982319489, 0)
			Car.Image = "rbxassetid://97166444"

			ImageLabel.Parent = Car
			ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageLabel.BackgroundTransparency = 1.000
			ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ImageLabel.BorderSizePixel = 0
			ImageLabel.Position = UDim2.new(0.144329891, 0, 0.109999999, 0)
			ImageLabel.Size = UDim2.new(0.711340189, 0, 0.779999971, 0)
			ImageLabel.Image = "http://www.roblox.com/asset/?id=13047359280"

			-- Scripts:

			local function BYIL_fake_script() -- Car.lunge 
				local script = Instance.new('LocalScript', Car)

				function getChar()
					return game:GetService("Players").LocalPlayer.Character
				end
				local LocalPlayer = game.Players.LocalPlayer
				local Signal1,Signal2=nil,nil
				function randomString()
					local length=math.random(10,20)
					local array={}
					for i=1,length do
						array[i]=string.char(math.random(32,126))
					end
					return table.concat(array)
				end
				local MobileWeld=nil


				function mobilefly(speed)
					speed = speed or 200 -- Default speed
					local controlModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild("ControlModule"))
					local character = getChar() or LocalPlayer.CharacterAdded:Wait()

					if flyMobile then flyMobile:Destroy() end
					flyMobile = Instance.new("Part", workspace)
					flyMobile.Name = randomString()
					flyMobile.Size, flyMobile.CanCollide = Vector3.new(0.05, 0.05, 0.05), false

					if MobileWeld then MobileWeld:Destroy() end
					MobileWeld = Instance.new("Weld", flyMobile)
					MobileWeld.Name = randomString()
					MobileWeld.Part0, MobileWeld.Part1, MobileWeld.C0 = flyMobile, character:FindFirstChildWhichIsA("Humanoid").RootPart, CFrame.new(0, 0, 0)

					local bv = flyMobile:FindFirstChildWhichIsA("BodyVelocity") or Instance.new("BodyVelocity", flyMobile)
					bv.Name = randomString()
					bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
					bv.Velocity = Vector3.new(0, 0, 0)

					local bg = flyMobile:FindFirstChildWhichIsA("BodyGyro") or Instance.new("BodyGyro", flyMobile)
					bg.Name = randomString()
					--bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
					--bg.P = 1000
					--bg.D = 50

					Signal2 = game:GetService("RunService").RenderStepped:Connect(function()
						local camera = workspace.CurrentCamera
						local direction = controlModule:GetMoveVector()
						local newVelocity = Vector3.new()

						if direction then
							if direction.X ~= 0 then
								newVelocity = newVelocity + camera.CFrame.RightVector * (direction.X * speed)
							end
							if direction.Z ~= 0 then
								newVelocity = newVelocity - camera.CFrame.LookVector * (direction.Z * speed)
							end
						end

						if bv then
							bv.Velocity = newVelocity
						end
					end)
				end
				function unmobilefly()
					local char=getChar()
					if char and flyMobile then
						local humanoid=char:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid.PlatformStand=false
						end
						if flyMobile then flyMobile:Destroy() end
					end
					if Signal1 then Signal1:Disconnect() end
					if Signal2 then Signal2:Disconnect() end
				end


				script.Parent.MouseButton1Click:Connect(function() 

					local sou = Instance.new("Sound")
					sou.Parent = workspace
					sou.SoundId = "rbxassetid://2674547670"
					sou.PlaybackSpeed = 1.5
					--sou:Play()


					mobilefly()
					wait(.2)
					unmobilefly()


				end)




				game:GetService("UserInputService").InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
					-- Ensure the input is a key press and not processed by other systems
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
						local sou = Instance.new("Sound")
						sou.Parent = workspace
						sou.SoundId = "rbxassetid://2674547670"
						sou.PlaybackSpeed = 1.5
						sou:Play()

						mobilefly() -- Provide a speed value for mobilefly
						wait(0.2)
						unmobilefly()
					end
				end)
			end
			coroutine.wrap(BYIL_fake_script)()


		end)
	end
})






local Slider = WeaponsTab:CreateSlider({
	Name = "Fling Sword Power",
	Range = {0, 500000},
	Increment = 3000,
	Suffix = "Power",
	CurrentValue = _G.Sword.Power,
	Flag = "SwordPower", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		_G.Sword.Power = Value
	end,
})


local PressureSlider = WeaponsTab:CreateSlider({
	Name = "Fling Sword Pressure",
	Range = {0, 500000},
	Increment = 3000,
	Suffix = "Pressure",
	CurrentValue = _G.Sword.Pressure,
	Flag = "SwordPressure", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		_G.Sword.Pressure = Value
	end,
})

local PressureSlider = WeaponsTab:CreateSlider({
	Name = "Fling Sword Range",
	Range = {5, 30},
	Increment = 1,
	Suffix = "Pressure",
	CurrentValue = _G.Sword.Range,
	Flag = "SwordPower", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		_G.Sword.Pressure = Value
	end,
})

local Reach = FlingTab:CreateSlider({
	Name = "Reach",
	Range = {1, 30},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = 30,
	Flag = "ReachLimit", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)

		for i,v in pairs(debug.getregistry()) do

			if type(v) == "function" and not is_synapse_function(v) then
				local Values = debug.getupvalues(v)
				for a,b in pairs(Values) do
					if type(b) == "number" and b == 20 then
						debug.setupvalue(v, a, Value)
					end
				end


			end
		end






	end,
})




local blobGrab = BlobmanTab:CreateInput({
	Name = "Bring Player",
	CurrentValue = "",
	PlaceholderText = "Enter Player Name",
	RemoveTextAfterFocusLost = true,
	Flag = "Input1",
	Callback = function(Value)

		local args = {
			[1] = workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.RightDetector,
			[2] = workspace:FindFirstChild(Value):FindFirstChild("HumanoidRootPart"),
			[3] = workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.RightDetector.RightWeld
		}

		workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
	end
})

local isMounted


local blobspeed = BlobmanTab:CreateKeybind({
	Name = "Toggle Keybind",
	CurrentKeybind = "V",
	HoldToInteract = false,
	Flag = "SuperFlingKeybind",
	Callback = function()
		local function checkMount()
			isMounted = false
			blobman = nil

			for _, v in pairs(game.Workspace:GetDescendants()) do
				if v.Name == "CreatureBlobman" then
					if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
						print("Mounted on Blobman!")
						blobman = v
						isMounted = true
						return true
					end
				end
			end

			print("Not mounted on Blobman.")
			return false
		end
	end
})


local ProtectionToggle = FlingTab:CreateToggle({
	Name = "Toggle Protection",
	CurrentValue = false,
	Flag = "ProtectionToggle",
	Callback = function(Value)
		Settings['ProtectionToggle'] = Value

		if Value == false then
			if _G.FTAP.connections.Protection then
				_G.FTAP.connections.Protection:Disconnect()
				_G.FTAP.connections.Protection = nil
			end
		else
			_G.FTAP.connections.Protection = Workspace.ChildAdded:Connect(function()
				for i = 1, 10 do
					ReplicatedStorage:WaitForChild("CharacterEvents"):WaitForChild("Struggle"):FireServer()
					task.wait(0.15)
				end
				print("Protected your ass :D!")
			end)
		end

		GuiLibrary:Notify({
			Title = (Value and "Enabled!" or "Disabled!"),
			Content = "Protection has been Toggled!",
			Duration = 2,
			Image = 4483362458
		})
	end
})


local barriers = SettingsTab:CreateToggle({
	Name = "Ignore house barriers",
	CurrentValue = false,
	Flag = "HouseBarriers",
	Callback = function(Value)


		if Value == false then

			for _, d in pairs(workspace:GetDescendants()) do
				if d.Name == "PlotBarrier" and d:IsA("BasePart") then
					d.CanCollide = false
					for _, gu in d:GetChildren() do
						if gu:IsA("BillboardGui") then
							gu.Enabled = true
						end
					end

					for _, item in workspace.PlotItems:GetDescendants() do
						if item:IsA("BasePart") then
							item.CanCollide = false
							item.CollisionGroup = "PlotItems"
						end
					end



				end
			end




		else
			for _, d in pairs(workspace:GetDescendants()) do
				if d.Name == "PlotBarrier" and d:IsA("BasePart") then
					--	d.CanCollide = true

					for _, gu in d:GetChildren() do
						if gu:IsA("BillboardGui") then
							gu.Enabled = false
						end
					end




					for _, item in workspace.PlotItems:GetDescendants() do
						if item:IsA("BasePart") then
							item.CanCollide = true
							item.CollisionGroup = "Default"
						end
					end

				end
			end


		end


	end
})




local playerSelected
local plrs = {}

local BlobDrop = BlobmanTab:CreateDropdown({
	Name = "Grab Player",
	Options = plrs,
	CurrentOption = nil,
	MultipleOptions = false,
	Flag = "Plrrr",
	Callback = function(Options)
		local selectedString = Options[1]  -- Get the selected display string
		local username = selectedString:match("^(.-) %(")  -- Extract text before space and (
		playerSelected = username





		local foundBlobman = false
		for i, v in pairs(game.Workspace:GetDescendants()) do
			if v.Name == "CreatureBlobman" then
				print("Found CreatureBlobman")
				if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
					print("Mounted on blobman")
					blobman = v
					foundBlobman = true

					break
				end
			end
		end
		print("Out of the loop!")
		blobGrabPlayer(playerSelected,blobman)
		if not foundBlobman then
			print("No mount found")




			--blobman1:Set(false)
			blobman = nil

			return
		end



		--[[
		-- Extract username from formatted string
	
		-- Now use the clean username
		local args = {
			[1] = workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.RightDetector,
			[2] = workspace:FindFirstChild(playerSelected):FindFirstChild("HumanoidRootPart"),
			[3] = workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.RightDetector.RightWeld
		}
		
		
		
		

		workspace[game.Players.LocalPlayer.Name .. "SpawnedInToys"].CreatureBlobman.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
		]]
	end,
})

-- Rest of your player list management code remains the same


for _, player in game.Players:GetPlayers() do
	if player.Name ~= localPlayer.Name then
		-- Add player to the plrs table
		table.insert(plrs, player.Name .. " (" .. player.DisplayName .. ")")
		BlobDrop:Set(plrs) -- Update the dropdown options
	end


end


-- Handle player joining
game.Players.PlayerAdded:Connect(function(player)
	if player.Name ~= localPlayer.Name then
		-- Add player to the plrs table
		table.insert(plrs, player.Name .. " (" .. player.DisplayName .. ")")
		BlobDrop:Set(plrs) -- Update the dropdown options
	end
end)

-- Handle player leaving
game.Players.PlayerRemoving:Connect(function(player)
	-- Remove the player from the plrs table
	for i, v in ipairs(plrs) do
		if v == player.Name .. " (" .. player.DisplayName .. ")" then
			table.remove(plrs, i)
			break
		end
	end
	BlobDrop:Set(plrs) -- Update the dropdown options
end)


local blobman1
blobman1 = BlobmanTab:CreateToggle({
	Name = "Blobman Skid",
	CurrentValue = false,
	Flag = "blobmanall",
	Callback = function(enabled)
		if enabled then
			print("Toggle enabled")
			blobmanCoroutine = coroutine.create(function()
				local foundBlobman = false
				for i, v in pairs(game.Workspace:GetDescendants()) do
					if v.Name == "CreatureBlobman" then
						print("Found CreatureBlobman")
						if v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") and isDescendantOf(v.VehicleSeat.SeatWeld.Part1, localPlayer.Character) then
							print("Mounted on blobman")
							blobman = v
							foundBlobman = true
							break
						end
					end
				end
				print("Out of the loop!")

				if not foundBlobman then
					print("No mount found")




					blobman1:Set(false)
					blobman = nil
					coroutine.close(blobmanCoroutine)
					blobmanCoroutine = nil
					return
				end

				while true do
					pcall(function()
						while wait() do
							for i, v in pairs(Players:GetChildren()) do
								if blobman and v ~= localPlayer then
									blobGrabPlayer(v, blobman)
									print(v.Name)
									wait(_G.BlobmanDelay)
								end
							end
						end
					end)
					wait(0.02)
				end
			end)
			coroutine.resume(blobmanCoroutine)
		else
			if blobmanCoroutine then
				coroutine.close(blobmanCoroutine)
				blobmanCoroutine = nil
				blobman = nil
			end
		end
	end
})










local fal = AllTab:CreateToggle({
	Name = "Fire All",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(Value)
		if Value then
			fireAllCoroutine = coroutine.create(fireAll)
			coroutine.resume(fireAllCoroutine)
		else
			if fireAllCoroutine then
				coroutine.close(fireAllCoroutine)
				fireAllCoroutine = nil
			end
		end
	end
})




local hellloop = AllTab:CreateToggle({
	Name = "Hell Send All",
	CurrentValue = false,
	Flag = "AuraHell",
	Callback = function(enabled)
		if enabled then
			pos = game.Players.LocalPlayer.Character.Torso.CFrame
			gravityCoroutine = coroutine.create(function()
				while enabled do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do

								if player ~= localPlayer and player.Character then
									if player.InPlot.Value ~= true then


										local playerCharacter = player.Character
										local playerTorso = playerCharacter:FindFirstChild("Torso")
										playerCharacter:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -25, 0))
										if playerTorso then
											local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
											if distance <= auraRadius then
												SetNetworkOwner:FireServer(humanoidRootPart, humanoidRootPart.CFrame)
												task.wait(0.05)
												local force = playerTorso:FindFirstChild("GravityForce") or Instance.new("BodyForce")
												force.Parent = playerTorso
												force.Name = "GravityForce"
												for _, part in ipairs(playerCharacter:GetDescendants()) do
													if part:IsA("BasePart") then
														part.CanCollide = false
													end
												end
												force.Force = Vector3.new(0, 1200, 0)
											end
										end
									end

								end
							end
						end
					end)
					if not success then
						warn("Error in Hell send Aura: " .. tostring(err))
						playerCharacter:PivotTo(pos)
					end
					wait(0.02)
				end
			end)
			coroutine.resume(gravityCoroutine)
		elseif gravityCoroutine then
			coroutine.close(gravityCoroutine)
			gravityCoroutine = nil
		end
	end
})





local function ragdollAll()
	while true do
		local success, err = pcall(function()
			if not toysFolder:FindFirstChild("FoodBanana") then
				spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
			end
			local banana = toysFolder:WaitForChild("FoodBanana")
			local bananaPeel
			for _, part in pairs(banana:GetChildren()) do
				if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
					part.Size = Vector3.new(10, 10, 10)
					part.Transparency = 1
					bananaPeel = part
					break
				end
			end
			local bodyPosition = Instance.new("BodyPosition")
			bodyPosition.P = 20000
			bodyPosition.Parent = banana.Main
			while true do
				for _, player in pairs(Players:GetChildren()) do
					pcall(function()
						if player.Character and player.Character ~= playerCharacter then
							bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
							bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
							wait()
						end
					end)
				end   
				wait()
			end
		end)
		if not success then
			warn("Error in ragdollAll: " .. tostring(err))
		end
		wait()
	end
end





local hellloop = AllTab:CreateToggle({
	Name = "Ragdoll All",
	CurrentValue = false,
	Flag = "BananaAura",
	Callback = function(enabled)




		if enabled then

			ragdollAllCoroutine = coroutine.create(ragdollAll)
			coroutine.resume(ragdollAllCoroutine)
		else
			if ragdollAllCoroutine then
				coroutine.close(ragdollAllCoroutine)
				ragdollAllCoroutine = nil
			end
		end
	end
})














local hellsend = AuraTab:CreateToggle({
	Name = "Hell send aura",
	CurrentValue = false,
	Flag = "AuraHell",
	Callback = function(enabled)
		if enabled then
			gravityCoroutine = coroutine.create(function()
				while enabled do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								if player ~= localPlayer and player.Character then
									local playerCharacter = player.Character
									local playerTorso = playerCharacter:FindFirstChild("Torso")
									if playerTorso then
										local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
										if distance <= auraRadius then
											SetNetworkOwner:FireServer(playerTorso, humanoidRootPart.FirePlayerPart.CFrame)
											task.wait(0.1)
											local force = playerTorso:FindFirstChild("GravityForce") or Instance.new("BodyForce")
											force.Parent = playerTorso
											force.Name = "GravityForce"
											for _, part in ipairs(playerCharacter:GetDescendants()) do
												if part:IsA("BasePart") then
													part.CanCollide = false
												end
											end
											force.Force = Vector3.new(0, 1200, 0)
										end
									end
								end
							end
						end
					end)
					if not success then
						warn("Error in Hell send Aura: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(gravityCoroutine)
		elseif gravityCoroutine then
			coroutine.close(gravityCoroutine)
			gravityCoroutine = nil
		end
	end
})




local topAura = AuraTab:CreateToggle({
	Name = "Test aura",
	CurrentValue = false,
	Flag = "TestAura",
	Callback = function(enabled)
		if enabled then
			skibidiAuraCoroutine = coroutine.create(function()
				while enabled and skibidiAuraCoroutine do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								if player ~= localPlayer and player.Character then
									local playerCharacter = player.Character
									local playerTorso = playerCharacter:FindFirstChild("Torso")

									if playerTorso then
										local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
										if distance <= auraRadius then
											-- Fire server event (keeping your original function)
											SetNetworkOwner:FireServer(playerTorso, humanoidRootPart.FirePlayerPart.CFrame)
											task.wait()

											-- Ensure BodyPosition exists
											local force = playerTorso:FindFirstChild("AuraForce") 
												or Instance.new("BodyPosition")
											force.Name = "AuraForce"
											force.MaxForce = Vector3.new(50000, 50000, 50000)  -- High force to keep in position
											force.P = 100000000 -- Responsiveness
											force.D = 500  -- Damping to avoid jitter
											force.Position = humanoidRootPart.Position + Vector3.new(0, 30, 0)
											force.Parent = playerTorso

											-- Properly controlled loop
											task.spawn(function()
												while enabled and force.Parent do
													task.wait(0.05)
													force.Position = humanoidRootPart.Position + Vector3.new(0, 30, 0)
												end
												-- Cleanup when the aura is disabled
												if force.Parent then
													force:Destroy()
												end
											end)
										end
									end
								end
							end
						end
					end)

					if not success then
						warn("skibidi aura error: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(skibidiAuraCoroutine)

		elseif skibidiAuraCoroutine then
			-- Stop the coroutine properly
			skibidiAuraCoroutine = nil
		end
	end
})







local spinCOr
local spinAura = AuraTab:CreateToggle({
	Name = "Spin aura",
	CurrentValue = false,
	Flag = "SpinAura",
	Callback = function(enabled)
		if enabled then
			spinCOr = coroutine.create(function()
				while enabled and spinCOr do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								if player ~= localPlayer and player.Character then
									local playerCharacter = player.Character
									local playerTorso = playerCharacter:FindFirstChild("Torso")

									if playerTorso then
										local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
										if distance <= auraRadius then
											-- Fire server event (keeping your original function)
											SetNetworkOwner:FireServer(playerTorso, humanoidRootPart.FirePlayerPart.CFrame)
											task.wait()

											-- Ensure BodyAngularVelocity exists
											local force = playerTorso:FindFirstChild("Spinner") 
												or Instance.new("BodyAngularVelocity")
											force.Name = "Spinner"
											force.MaxTorque = Vector3.new(50000, 50000, 50000)  -- High torque to allow spinning
											force.AngularVelocity = Vector3.new(0, 50, 0) -- Spins around Y-axis (adjust speed here)
											force.Parent = playerTorso

											-- Keep the player's torso floating
											--local positionForce = playerTorso:FindFirstChild("SpinPosition") 
											--	or Instance.new("BodyPosition")
											--	positionForce.Name = "SpinPosition"
											---	positionForce.MaxForce = Vector3.new(50000, 50000, 50000)
											--	positionForce.Position = humanoidRootPart.Position + Vector3.new(0, 30, 0)
											--	positionForce.Parent = playerTorso

											-- Properly controlled loop
											task.spawn(function()
												while enabled and force.Parent do
													task.wait(0.05)
													--	positionForce.Position = humanoidRootPart.Position + Vector3.new(0, 30, 0)
												end
												-- Cleanup when the aura is disabled

												if force.Parent then
													force:Destroy()
												end
											end)
										end
									end
								end
							end
						end
					end)

					if not success then
						warn("spin aura error: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(spinCOr)

		elseif spinCOr then
			-- Stop the coroutine properly
			spinCOr = nil
		end
	end
})




--[[
local auraToggle = 1
local kickCoroutine

local kickAura = AuraTab:CreateToggle({
	Name = "Kick text aura",
	CurrentValue = false,
	Flag = "KickAura",
	Callback = function(enabled)
		if auraToggle == 1 then
			if enabled then
				kickCoroutine = coroutine.create(function()
					while enabled do
						local success, err = pcall(function()
							local character = localPlayer.Character
							if character and character:FindFirstChild("HumanoidRootPart") then
								local humanoidRootPart = character.HumanoidRootPart

								for _, player in pairs(Players:GetPlayers()) do
									if player ~= localPlayer and player.Character then
										local playerCharacter = player.Character
										local playerTorso = playerCharacter:FindFirstChild("Head")

										if playerTorso then
											local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
											if distance <= auraRadius then
												SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
												if not platforms[player] then
													local platform = playerCharacter:FindFirstChild("FloatingPlatform") or Instance.new("Part")
													platform.Name = "FloatingPlatform"
													platform.Size = Vector3.new(5, 2, 5)
													platform.Anchored = true
													platform.Transparency = 1
													platform.CanCollide = true
													platform.Parent = playerCharacter
													platforms[player] = platform
												end
											end
										end
									end
								end
								for player, platform in pairs(platforms) do
									if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 1 then
										local playerHumanoidRootPart = player.Character.HumanoidRootPart
										platform.Position = playerHumanoidRootPart.Position - Vector3.new(0, 3.994, 0)
									else
										platforms[player] = nil
									end
								end
							end
						end)
						if not success then
							warn("kick err: " .. tostring(err))
						end
						wait(0.02)
					end
				end)
				coroutine.resume(kickCoroutine)
			elseif kickCoroutine then
				coroutine.close(kickCoroutine)
				kickCoroutine = nil
				for _, platform in pairs(platforms) do
					if platform then
						platform:Destroy()
					end
				end
				platforms = {}
			end
		elseif auraToggle == 2 then
			if enabled then
				kickCoroutine = coroutine.create(function()
					while enabled do
						local success, err = pcall(function()
							local character = localPlayer.Character
							if character and character:FindFirstChild("HumanoidRootPart") then
								local humanoidRootPart = character.HumanoidRootPart

								for _, player in pairs(Players:GetPlayers()) do
									if player ~= localPlayer and player.Character then
										local playerCharacter = player.Character
										local playerTorso = playerCharacter:FindFirstChild("Head")

										if playerTorso then
											local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
											if distance <= auraRadius then
												SetNetworkOwner:FireServer(playerCharacter:WaitForChild("HumanoidRootPart").FirePlayerPart, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
												if not playerCharacter.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
													local bodyVelocity = Instance.new("BodyVelocity")
													bodyVelocity.Name = "BodyVelocity"
													bodyVelocity.Velocity = Vector3.new(0, 20, 0) 
													bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
													bodyVelocity.Parent = playerCharacter.HumanoidRootPart.FirePlayerPart
												end
											end
										end
									end
								end
							end
						end)
						if not success then
							warn("Error in Kick Aura (Sky mode): " .. tostring(err))
						end
						wait(0.02)
					end
				end)
				coroutine.resume(kickCoroutine)
			else
				if kickCoroutine then
					coroutine.close(kickCoroutine)
					kickCoroutine = nil
				end
			end
		end
	end
})
]]










local hellsend = AuraTab:CreateToggle({
	Name = "Fly Aura",
	CurrentValue = false,
	Flag = "AuraHell",
	Callback = function(enabled)
		if enabled then
			auraCoroutine = coroutine.create(function()
				while true do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
							local head = character.Head
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								coroutine.wrap(function()
									if player ~= localPlayer and player.Character then
										local playerCharacter = player.Character
										local playerTorso = playerCharacter:FindFirstChild("Torso")
										if playerTorso then
											local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
											if distance <= auraRadius then
												SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
												task.wait(0.1)
												local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
												velocity.Name = "l"
												velocity.Velocity = Vector3.new(0, 50, 0)
												velocity.MaxForce = Vector3.new(0, math.huge, 0)
												game:GetService("Debris"):AddItem(velocity, 100)
											end
										end
									end
								end)()
							end
						end
					end)
					if not success then
						warn("Error in Air Suspend Aura: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(auraCoroutine)
		else
			if auraCoroutine then
				coroutine.close(auraCoroutine)
				auraCoroutine = nil
			end
		end
	end
})

local hellsend = AuraTab:CreateToggle({
	Name = "Null Aura",
	CurrentValue = false,
	Flag = "AuraHell",
	Callback = function(enabled)
		if enabled then
			auraCoroutine = coroutine.create(function()
				while true do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
							local head = character.Head
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								coroutine.wrap(function()
									if player ~= localPlayer and player.Character then
										local playerCharacter = player.Character
										local playerTorso = playerCharacter:FindFirstChild("Torso")
										if playerTorso then
											local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
											if distance <= auraRadius then
												SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.FirePlayerPart.CFrame)
												task.wait(0.1)
												local velocity = playerTorso:FindFirstChild("l") or Instance.new("BodyVelocity", playerTorso)
												velocity.Name = "l"
												velocity.Velocity = Vector3.new(0, 9e9, 0)
												velocity.MaxForce = Vector3.new(0, 9e9, 0)
												game:GetService("Debris"):AddItem(velocity, 100)
											end
										end
									end
								end)()
							end
						end
					end)
					if not success then
						warn("Error in Air Suspend Aura: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(auraCoroutine)
		else
			if auraCoroutine then
				coroutine.close(auraCoroutine)
				auraCoroutine = nil
			end
		end
	end
})







local hellsend = AuraTab:CreateToggle({
	Name = "Anchor Aura",
	CurrentValue = false,
	Flag = "AnchorAura",
	Callback = function(enabled)
		if enabled then
			anchorAura = coroutine.create(function()
				while true do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, descendant in pairs(workspace:GetDescendants()) do
								if descendant:IsA("Model") and descendant ~= character then
									local otherCharacter = descendant
									local otherTorso = otherCharacter:FindFirstChild("Torso")  or otherCharacter.PrimaryPart
									if otherTorso then
										local distance = (otherTorso.Position - humanoidRootPart.Position).Magnitude
										if distance <= auraRadius then
											-- Anchor the other player's part
											SetNetworkOwner:FireServer(otherTorso, humanoidRootPart.CFrame)
											table.insert(anchoredParts, otherTorso)
										end
									end
								end
							end
						end
					end)
					if not success then
						warn("Error in anchor aura: " .. tostring(err))
					end
					task.wait(0.02)
				end
			end)
			coroutine.resume(anchorAura)
		else
			if anchorAura then
				-- Stop the coroutine by setting a flag or condition
				coroutine.close(anchorAura)
				anchorAura = nil
			end
		end
	end
})





local hellsend = AuraTab:CreateToggle({
	Name = "Poison Aura",
	CurrentValue = false,
	Flag = "AuraHell",
	Callback = function(enabled)
		if enabled then
			poisonAuraCoroutine = coroutine.create(function()
				while enabled do
					local success, err = pcall(function()
						local character = localPlayer.Character
						if character and character:FindFirstChild("HumanoidRootPart") then
							local humanoidRootPart = character.HumanoidRootPart

							for _, player in pairs(Players:GetPlayers()) do
								if player ~= localPlayer and player.Character then
									local playerCharacter = player.Character
									local playerTorso = playerCharacter:FindFirstChild("Torso")
									if playerTorso then
										local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
										if distance <= auraRadius then
											local head = playerCharacter:FindFirstChild("Head")
											while distance <= auraRadius do
												SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
												distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
												for _, part in pairs(poisonHurtParts) do
													part.Size = Vector3.new(1, 3, 1)
													part.Transparency = 1
													part.Position = head.Position
												end
												wait()
												for _, part in pairs(poisonHurtParts) do
													part.Position = Vector3.new(0, -200, 0)
												end
											end
											for _, part in pairs(poisonHurtParts) do
												part.Position = Vector3.new(0, -200, 0)
											end
										end
									end
								end
							end
						end
					end)
					if not success then
						warn("Error in Poison Aura: " .. tostring(err))
					end
					wait(0.02)
				end
			end)
			coroutine.resume(poisonAuraCoroutine)
		elseif poisonAuraCoroutine then
			coroutine.close(poisonAuraCoroutine)
			for _, part in pairs(poisonHurtParts) do
				part.Position = Vector3.new(0, -200, 0)
			end
			poisonAuraCoroutine = nil
		end
	end
})










local aparts = PartsTab:CreateToggle({
	Name = "AnchorGrab",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then	
			if not anchorGrabCoroutine or coroutine.status(anchorGrabCoroutine) == "dead" then
				anchorGrabCoroutine = coroutine.create(anchorGrab)
				coroutine.resume(anchorGrabCoroutine)
			end
		else
			if anchorGrabCoroutine and coroutine.status(anchorGrabCoroutine) ~= "dead" then
				coroutine.close(anchorGrabCoroutine)
				anchorGrabCoroutine = nil
			end
		end
	end
})



local comparts = PartsTab:CreateButton({
	Name = "Compile (weld) Parts",
	Callback = function()
		compileGroup()
		if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
			compileCoroutine = coroutine.create(compileCoroutineFunc)
			coroutine.resume(compileCoroutine)
		end

	end
})


local decomp = PartsTab:CreateButton({
	Name = "Decompile Parts (unweld)",
	Callback = function()
		cleanupCompiledGroups()
		cleanupAnchoredParts()

		if compileCoroutine and coroutine.status(compileCoroutine) ~= "dead" then
			coroutine.close(compileCoroutine)
			compileCoroutine = nil
		end
	end
})



local comparts2 = PartsTab:CreateButton({
	Name = "Compile to torso test",
	Callback = function()
		table.insert(anchoredParts, anchoredParts[1])
		anchoredParts[1] = playerCharacter:FindFirstChild("Torso")
		compileGroup()
		if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
			compileCoroutine = coroutine.create(compileCoroutineFunc)
			coroutine.resume(compileCoroutine)
		end

	end
})



local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()


local limbToComp
-- Limb parts
local limbNames = {
	"Head", "Torso", "Left Leg", "Right Leg", "Left Arm", "Right Arm"
}

-- Iterate through the parts in the character and print limb parts
for _, part in pairs(character:GetChildren()) do
	if part:IsA("BasePart") then
		-- Check if the part's name matches any of the limb names
		for _, limbName in ipairs(limbNames) do
			if part.Name == limbName then
				print(part.Name)  -- Print the limb part name
				break  -- Move to the next part once a match is found
			end
		end
	end
end

local LimbDrop = PartsTab:CreateDropdown({
	Name = "Compile to Limb",
	Options = limbNames,
	CurrentOption = limbNames["Torso"],
	MultipleOptions = false,
	Flag = "LimbCompile", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Options)
		print(Options)
		limbToComp = Options[1]
		--limbToComp = LimbDrop.CurrentOption

	end,
})






local comparts2 = PartsTab:CreateButton({
	Name = "Compile to Limb",
	Callback = function()
		table.insert(anchoredParts, anchoredParts[1])
		anchoredParts[1] = playerCharacter:FindFirstChild(limbToComp)
		compileGroup()
		if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
			compileCoroutine = coroutine.create(compileCoroutineFunc)
			coroutine.resume(compileCoroutine)
		end

	end
})



local comparts2 = PartsTab:CreateButton({
	Name = "TESTTTTT",
	Callback = function()
		table.insert(anchoredParts, anchoredParts[1])
		anchoredParts[1] = playerCharacter:FindFirstChild("Left Leg")
		compileGroup()
		if not compileCoroutine or coroutine.status(compileCoroutine) == "dead" then
			compileCoroutine = coroutine.create(compileCoroutineFunc)
			coroutine.resume(compileCoroutine)
		end

	end
})


local recov = PartsTab:CreateToggle({
	Name = "Auto Recover Parts",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then
			if not AutoRecoverDroppedPartsCoroutine or coroutine.status(AutoRecoverDroppedPartsCoroutine) == "dead" then
				AutoRecoverDroppedPartsCoroutine = coroutine.create(recoverParts)
				coroutine.resume(AutoRecoverDroppedPartsCoroutine)
			end
		else
			if AutoRecoverDroppedPartsCoroutine and coroutine.status(AutoRecoverDroppedPartsCoroutine) ~= "dead" then
				coroutine.close(AutoRecoverDroppedPartsCoroutine)
				AutoRecoverDroppedPartsCoroutine = nil
			end
		end
	end
})








local fly = DefenseTab:CreateToggle({
	Name = "Anti Grab",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then

			if enabled then
				autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
					local character = localPlayer.Character
					if character and character:FindFirstChild("Head") then
						local head = character.Head
						local partOwner = head:FindFirstChild("PartOwner")
						if partOwner then
							Struggle:FireServer()
							ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
							for _, part in pairs(character:GetChildren()) do
								if part:IsA("BasePart") then
									part.Anchored = true
								end
							end
							while localPlayer.IsHeld.Value do
								wait()
							end
							for _, part in pairs(character:GetChildren()) do
								if part:IsA("BasePart") then
									part.Anchored = false
								end
							end
						end
					end
				end)
			else
				if autoStruggleCoroutine then
					autoStruggleCoroutine:Disconnect()
					autoStruggleCoroutine = nil
				end
			end

		end
	end
})






local fly = DefenseTab:CreateToggle({
	Name = "Self defense - fly attackers (idk)",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then
			autoDefendCoroutine = coroutine.create(function()
				while wait(0.02) do
					local character = localPlayer.Character
					if character and character:FindFirstChild("Head") then
						local head = character.Head
						local partOwner = head:FindFirstChild("PartOwner")
						if partOwner then
							local attacker = Players:FindFirstChild(partOwner.Value)
							if attacker and attacker.Character then
								Struggle:FireServer()
								SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
								task.wait(0.1)
								local target = attacker.Character:FindFirstChild("Torso")
								if target then
									local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
									velocity.Name = "l"
									velocity.Parent = target
									velocity.Velocity = Vector3.new(0, 50, 0)
									velocity.MaxForce = Vector3.new(0, math.huge, 0)
									game:GetService("Debris"):AddItem(velocity, 100)
								end
							end
						end
					end
				end
			end)
			coroutine.resume(autoDefendCoroutine)
		else
			if autoDefendCoroutine then
				coroutine.close(autoDefendCoroutine)
				autoDefendCoroutine = nil
			end
		end
	end
})




local fly = DefenseTab:CreateToggle({
	Name = "Self defense - Null attackers (idk)",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then
			autoDefendCoroutine = coroutine.create(function()
				while wait(0.02) do
					local character = localPlayer.Character
					if character and character:FindFirstChild("Head") then
						local head = character.Head
						local partOwner = head:FindFirstChild("PartOwner")
						if partOwner then
							local attacker = Players:FindFirstChild(partOwner.Value)
							if attacker and attacker.Character then
								Struggle:FireServer()
								SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
								task.wait(0.1)
								local target = attacker.Character:FindFirstChild("Torso")
								if target then
									local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
									velocity.Name = "l"
									velocity.Parent = target
									velocity.Velocity = Vector3.new(0, 45354453454, 0)
									velocity.MaxForce = Vector3.new(9e9,9e9,9e9)
									game:GetService("Debris"):AddItem(velocity, 100)
								end
							end
						end
					end
				end
			end)
			coroutine.resume(autoDefendCoroutine)
		else
			if autoDefendCoroutine then
				coroutine.close(autoDefendCoroutine)
				autoDefendCoroutine = nil
			end
		end
	end
})







local spe = CharTab:CreateToggle({
	Name = "Speed",
	CurrentValue = false,
	Flag = "SuperFlingToggle",
	Callback = function(enabled)
		if enabled then
			crouchSpeedCoroutine = coroutine.create(function()
				while true do
					pcall(function()
						if not playerCharacter.Humanoid then return end

						playerCharacter.Humanoid.WalkSpeed = crouchWalkSpeed

					end)
					wait()
				end
			end)
			coroutine.resume(crouchSpeedCoroutine)
		elseif crouchSpeedCoroutine then
			coroutine.close(crouchSpeedCoroutine)
			crouchSpeedCoroutine = nil
			if playerCharacter.Humanoid then
				playerCharacter.Humanoid.WalkSpeed = 16
			end
		end
	end
})


local SpeedSlider = CharTab:CreateSlider({
	Name = "Set Speed",
	Range = {5, 500},
	Increment = 1,
	Suffix = "Walkspeed",
	CurrentValue = 16,
	Flag = "Speed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		crouchWalkSpeed = Value
	end,
})





local jump = CharTab:CreateToggle({
	Name = "Jump",
	CurrentValue = false,
	Flag = "JumpEnabled",
	Callback = function(enabled)
		if enabled then
			crouchSpeedCoroutine = coroutine.create(function()
				while true do
					pcall(function()
						if not playerCharacter.Humanoid then return end

						playerCharacter.Humanoid.JumpPower = crouchWalkSpeed

					end)
					wait()
				end
			end)
			coroutine.resume(crouchSpeedCoroutine)
		elseif crouchSpeedCoroutine then
			coroutine.close(crouchSpeedCoroutine)
			crouchSpeedCoroutine = nil
			if playerCharacter.Humanoid then
				playerCharacter.Humanoid.JumpPower = 50
			end
		end
	end
})


local SpeedSlider = CharTab:CreateSlider({
	Name = "Set Jump Power",
	Range = {5, 500},
	Increment = 1,
	Suffix = "Power",
	CurrentValue = 50,
	Flag = "Speed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		crouchJumpPower = Value
	end,
})



local housemake = DevTab:CreateButton({
	Name = "bobman",
	Callback = function()


--[[
local function tempAnchor(m)
		for _, p in toysFolder:GetChildren() do
			createBodyMovers(p, p.Position, p.CFrame)
		end
			
	
wait()
	end
	
	
	for _, toy in toysFolder:GetChildren() do
		DestroyT(toy.Name)
	end
	
	
		playerCharacter:PivotTo(CFrame.new(4202.5888671875, 8158.7099609375, -3299.248291015625, -0.28680428862571716, -0.917309582233429, 0.27620020508766174, 0, 0.2883124351501465, 0.9575364589691162, -0.9579892158508301, 0.2746255695819855, -0.08268924802541733))
	
		local args = {
			[1] = "PalletLightBrown",
			[2] = CFrame.new(4202.5888671875, 8158.7099609375, -3299.248291015625, -0.28680428862571716, -0.917309582233429, 0.27620020508766174, 0, 0.2883124351501465, 0.9575364589691162, -0.9579892158508301, 0.2746255695819855, -0.08268924802541733),
			[3] = Vector3.new(0, 106.66699981689453, 0)
		}

		game:GetService("ReplicatedStorage"):WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction"):InvokeServer(unpack(args))

	
		tempAnchor(toysFolder.PalletLightBrown)
	
	
	]]


	end
})



local brange = DevTab:CreateSlider({
	Name = "bobman grab range",
	Range = {5, 500},
	Increment = 1,
	Suffix = "Power",
	CurrentValue = 5,
	Flag = "Bobrange", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		toysFolder:FindFirstChild("CreatureBlobman").LeftDetector.Size = Vector3.new(Value,Value,Value)
		toysFolder:FindFirstChild("CreatureBlobman").RightDetector.Size = Vector3.new(Value,Value,Value)
	end,
})


task.spawn(function()


	table.insert(_G.FTAP.connections, RunService.Heartbeat:Connect(function()
		if #Settings["OwnedParts"] >= 1 and Settings["SuperFlingToggle"] == true then
			for i, v in pairs(Settings["OwnedParts"]) do
				if Players:GetPlayerFromCharacter(v.Parent) ~= Players.LocalPlayer and v.Anchored == false then
					local redos = 0
					repeat
						v.AssemblyLinearVelocity = Vector3.new(1000000, 1000000, -1000000)
						task.wait()
						redos += 1
					until redos == 15
				end
			end
		end
	end))

end)



local sends = SettingsTab:CreateInput({
	Name = "Send Feedback",
	CurrentValue = "",
	PlaceholderText = "Feedback...",
	RemoveTextAfterFocusLost = true,
	Flag = "Input1",
	Callback = function(Text)
		local deb = false
		if deb == true then return end
		deb = true

		local HttpService = game:GetService("HttpService")
		local Players = game:GetService("Players")
		local MarketplaceService = game:GetService("MarketplaceService")
		local LocalPlayer = Players.LocalPlayer
		local Userid = LocalPlayer.UserId
		local DName = LocalPlayer.DisplayName
		local Name = LocalPlayer.Name
		local GAMENAME = MarketplaceService:GetProductInfo(game.PlaceId).Name
		local webhookUrl = "https://discord.com/api/webhooks/1328465863942078555/cZey9BgXoOeloDJlXUVYH0RLI9Xf0dLa1s6oMOoUBCexcU-RuflkbsOTVHTPc6hkm3yg"

		local function createWebhookData()
			local webhookcheck = identifyexecutor()
			local playerCount = #Players:GetPlayers()

			local joinLink = string.format(
				"**script to join server:**\n```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s', game.Players.LocalPlayer)\n```",
				game.PlaceId, game.JobId
			)
			local data = {
				["avatar_url"] = "",
				["content"] = "",
				["embeds"] = {
					{
						["author"] = {
							["name"] = "HELLLOOOOOOOOOOOOOOOOO!",
							["url"] = "https://roblox.com"
						},
						["description"] = string.format(
							"**Game:** %s \n" ..
								"__[Player Info](https://www.roblox.com/users/%d)__" ..
								" **\nDisplay Name:** %s \n**Username:** %s \n**User Id:** %d" ..
								"\n\n__[Game Info](https://www.roblox.com/games/%d)__" ..
								"\n**Game:** %s \n**Game Id:** %d \n**Exploit:** %s" ..
								"\n**Player Count:** %d\n\n%s\n\n**Feedback:** %s",
							GAMENAME, Userid, DName, Name, Userid,
							game.PlaceId, GAMENAME, game.PlaceId, webhookcheck,
							playerCount, joinLink, Text -- Including feedback text here
						),
						["type"] = "rich",
						["color"] = tonumber("0xFFD700"),
						["thumbnail"] = {
							["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..Userid.."&width=150&height=150&format=png"
						},
						["footer"] = {
							["text"] = "Feedback"
						}
					}
				}
			}
			return HttpService:JSONEncode(data)
		end

		local function sendWebhook(webhookUrl, data)
			local headers = {
				["content-type"] = "application/json"
			}
			local request = http_request or request or HttpPost or syn.request
			local abcdef = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
			request(abcdef)
		end

		local webhookData = createWebhookData()
		sendWebhook(webhookUrl, webhookData)
		wait(10)

		deb = false
	end
})







local OldNameCall = nil
OldNameCall = hookmetamethod(game, "namecall", function(Self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if tostring(Self) == "SetNetworkOwner" and method == "FireServer" then
		local Part = args[1]
		print("Now becoming networkOwner of: " .. Part.Name)
		table.insert(Settings["OwnedParts"], Part)

		Part.Destroying:Connect(function()
			for i, v in pairs(Settings["OwnedParts"]) do
				if v == Part then
					table.remove(Settings["OwnedParts"], i)
				end
			end
		end)

		return OldNameCall(Self, ...)
	elseif tostring(Self) == "DestroyGrabLine" and method == "FireServer" then
		local Part = args[1]
		print("Losing Ownership of: " .. Part.Name)

		if table.find(Settings["OwnedParts"], Part) ~= nil then
			table.remove(Settings["OwnedParts"], table.find(Settings["OwnedParts"], Part))
		end
	end

	return OldNameCall(Self, ...)
end)















