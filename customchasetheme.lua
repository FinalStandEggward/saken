local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local THEMES_FOLDER = workspace:WaitForChild("Themes")

print("🔊 Custom Self-Hatred Theme Override Watching Player Loadouts")

-- Roblox SoundIds mapped to your local MP3s
local REPLACEMENTS = {
	["rbxassetid://139957641994343"] = getcustomasset("layer1selfhatred.mp3"),
	["rbxassetid://107607873139123"] = getcustomasset("layer2selfhatred.mp3"),
	["rbxassetid://105551772469406"] = getcustomasset("layer3selfhatred.mp3"),
	["rbxassetid://97690757653206"]  = getcustomasset("chaseselfhatred.mp3"),
}

-- Function to override a sound if it's in REPLACEMENTS
local function overrideSound(sound)
	if sound:IsA("Sound") and REPLACEMENTS[sound.SoundId] then
		sound.SoundId = REPLACEMENTS[sound.SoundId]
		print("🔁 Replaced SoundId for", sound.Name)
	end
end

-- Hook new sounds added to Themes
local function hookNewSounds()
	THEMES_FOLDER.ChildAdded:Connect(function(child)
		if child:IsA("Sound") then
			-- Replace immediately if matched
			overrideSound(child)

			-- Watch for future SoundId changes
			child:GetPropertyChangedSignal("SoundId"):Connect(function()
				overrideSound(child)
			end)
		end
	end)
end

-- Check player loadout
local function shouldOverrideForPlayer(player)
	local char = player.Character
	if not char then return false end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 500 then return false end

	local equipped = player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("Equipped")
	if not equipped then return false end

	local killer = equipped:FindFirstChild("Killer")
	local skins = equipped:FindFirstChild("Skins")
	if not (killer and skins) then return false end

	local killerName = killer.Value
	local skinName = skins:FindFirstChild("1x1x1x1")
	if killerName == "1x1x1x1" and skinName and skinName.Value == "Hacklord1x1x1x1" then
		return true
	end

	return false
end

-- Scan all players for override trigger
local function tryOverrideFromAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		if shouldOverrideForPlayer(player) then
			print("✅ Match found — Overriding music")

			-- Replace all existing sounds
			for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
				overrideSound(sound)
			end

			-- Hook up future replacements
			hookNewSounds()
			break
		end
	end
end

-- Start script logic
task.wait(3)
tryOverrideFromAllPlayers()

-- Check periodically
while true do
	task.wait(5)
	tryOverrideFromAllPlayers()
end


local THEMES_FOLDER = workspace:WaitForChild("Themes")
print("🔊 Custom Self-Hatred Theme Override Enabled")

-- Roblox SoundIds mapped to your local MP3s
local REPLACEMENTS = {
	["rbxassetid://139957641994343"] = getcustomasset("old1xlayer1.mp3"),
	["rbxassetid://107607873139123"] = getcustomasset("old1xlayer2.mp3"),
	["rbxassetid://105551772469406"] = getcustomasset("old1xlayer3.mp3"),
	["rbxassetid://97690757653206"]  = getcustomasset("old1xchase.mp3"),
}

-- Function to apply replacements to all current sounds
local function replaceExistingSounds()
	for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
		if sound:IsA("Sound") and REPLACEMENTS[sound.SoundId] then
			sound.SoundId = REPLACEMENTS[sound.SoundId]
			print("🔁 Replaced SoundId for", sound.Name)
		end
	end
end

-- Apply on existing sounds immediately
replaceExistingSounds()

-- Hook into newly added sounds
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			local newAsset = REPLACEMENTS[child.SoundId]
			if newAsset then
				child.SoundId = newAsset
				print("🔁 Replaced SoundId for", child.Name)
			end
		end)
		
		local newAsset = REPLACEMENTS[child.SoundId]
		if newAsset then
			child.SoundId = newAsset
			print("🔁 Replaced SoundId for", child.Name)
		end
	end
end)

-- Periodic recheck every 5 seconds
while true do
	task.wait(5)
	replaceExistingSounds()
end
