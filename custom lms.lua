local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")
local LocalPlayer = Players.LocalPlayer

print("🎵 LMS Replacement System Active")

local PLAYERS_FOLDER = workspace:WaitForChild("Players")

PLAYERS_FOLDER.ChildRemoved:Connect(function()
	-- Check if no models remain
	task.delay(0.25, function()
		local remaining = #PLAYERS_FOLDER:GetChildren()
		if remaining == 0 then
			stopAllLMSMusic()
		end
	end)
end)

-- Optional: handle cases where they all vanish at once
PLAYERS_FOLDER.ChildAdded:Connect(function()
	task.delay(0.25, function()
		if #PLAYERS_FOLDER:GetChildren() == 0 then
			stopAllLMSMusic()
		end
	end)
end)


-- LMS Sound IDs
local LMS_IDS = {
	SelfHatred   = "rbxassetid://115884097233860",
	VanillaLMS   = "rbxassetid://71057332615441",
	VanityLMS    = "rbxassetid://137266220091579",
}

-- Dynamic replacement logic for each LMS type
local SOUND_OPTIONS = {
	["SelfHatred"] = function()
		local killerModel = workspace:FindFirstChild("Players")
			and workspace.Players:FindFirstChild("Killers")
			and workspace.Players.Killers:FindFirstChild("1x1x1x1")

		if not killerModel then return getcustomasset("thedarknessinyourheart.mp3") end

		local humanoid = killerModel:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 500 then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local equippedSkin = LocalPlayer:FindFirstChild("PlayerData")
			and LocalPlayer.PlayerData:FindFirstChild("Equipped")
			and LocalPlayer.PlayerData.Equipped:FindFirstChild("Skins")
			and LocalPlayer.PlayerData.Equipped.Skins:FindFirstChild("1x1x1x1")

		if equippedSkin and equippedSkin.Value == "Hacklord1x1x1x1" then
			return getcustomasset("ProeliumFatale.mp3")
		else
			return getcustomasset("thedarknessinyourheart.mp3")
		end
	end,

	["VanillaLMS"] = function()
		local pool = {
			LMS_IDS.VanillaLMS,
			getcustomasset("oldlms.mp3"),
			getcustomasset("oldestlms.mp3"),
		}
		return pool[math.random(1, #pool)]
	end,

	["VanityLMS"] = function()
		return getcustomasset("vanitylmsretake.mp3")
	end,
}

-- Sound replacement utility
local function replaceSound(assetId, getReplacement)
	local replacement = getReplacement()
	if replacement == assetId then
		print("▶️ Keeping original LMS: " .. assetId)
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "LMSOverride"
	sound.SoundId = replacement
	sound.Looped = false
	sound.Volume = 0
	sound.Parent = THEMES_FOLDER

	sound.Loaded:Connect(function()
		task.defer(function()
			sound.Volume = 5
			sound:Play()
		end)
	end)

	task.delay(2, function()
		if sound and not sound.IsPlaying then
			sound.Volume = 5
			sound:Play()
		end
	end)

	print("🔁 LMS Replaced with:", replacement)
end

-- First pass on existing sounds
for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
	if not sound:IsA("Sound") then continue end

	if sound.SoundId == LMS_IDS.SelfHatred then
		sound:Destroy()
		replaceSound(LMS_IDS.SelfHatred, SOUND_OPTIONS["SelfHatred"])

	elseif sound.SoundId == LMS_IDS.VanillaLMS then
		sound:Destroy()
		replaceSound(LMS_IDS.VanillaLMS, SOUND_OPTIONS["VanillaLMS"])

	elseif sound.SoundId == LMS_IDS.VanityLMS then
		sound:Destroy()
		replaceSound(LMS_IDS.VanityLMS, SOUND_OPTIONS["VanityLMS"])
	end
end

-- Handle LMS being added live
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if not child:IsA("Sound") then return end

	if child.SoundId == LMS_IDS.SelfHatred then
		child:Destroy()
		replaceSound(LMS_IDS.SelfHatred, SOUND_OPTIONS["SelfHatred"])

	elseif child.SoundId == LMS_IDS.VanillaLMS then
		child:Destroy()
		replaceSound(LMS_IDS.VanillaLMS, SOUND_OPTIONS["VanillaLMS"])

	elseif child.SoundId == LMS_IDS.VanityLMS then
		child:Destroy()
		replaceSound(LMS_IDS.VanityLMS, SOUND_OPTIONS["VanityLMS"])
	end
end)




-- 🔇 Stop all LMS music when no players are left
local function stopAllLMSMusic()
	for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
		if sound:IsA("Sound") and sound.IsPlaying then
			print("⛔ Stopping LMS theme:", sound.Name)
			sound:Stop()
		end
	end
end

