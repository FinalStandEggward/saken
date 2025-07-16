local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")
local LocalPlayer = Players.LocalPlayer

local LMS_IDS = {
	SelfHatred = "rbxassetid://115884097233860",
	VanillaLMS = "rbxassetid://71057332615441",
	VanityLMS  = "rbxassetid://137266220091579",
}

local CUSTOM_NAME = "LMSOverride"

-- 🛑 Stop all other music (except lobby override)
local function stopOtherThemes()
	for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
		if s:IsA("Sound") and s.Name ~= CUSTOM_NAME and s.Name ~= "LobbyOverride" then
			pcall(function()
				s:Stop()
				s:Destroy()
			end)
		end
	end
end

-- 🎯 Choose appropriate LMS track
local function getLMSReplacement(id)
	if id == LMS_IDS.SelfHatred then
		local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
		if not killersFolder then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local killerModel = killersFolder:FindFirstChild("1x1x1x1")
		if not killerModel then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local hum = killerModel:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 500 then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local killerPlayer = nil
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character == killerModel then
				killerPlayer = player
				break
			end
		end

		if not killerPlayer then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local equipped = killerPlayer:FindFirstChild("PlayerData")
			and killerPlayer.PlayerData:FindFirstChild("Equipped")

		if not equipped then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local killerValue = equipped:FindFirstChild("Killer")
		if not killerValue or killerValue.Value ~= "1x1x1x1" then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local skinsFolder = equipped:FindFirstChild("Skins")
		if not skinsFolder then
			return getcustomasset("thedarknessinyourheart.mp3")
		end

		local skinValue = skinsFolder:FindFirstChild("1x1x1x1")
		if skinValue and skinValue.Value == "Hacklord1x1x1x1" then
			return getcustomasset("ProeliumFatale.mp3")
		end

		return getcustomasset("thedarknessinyourheart.mp3")

	elseif id == LMS_IDS.VanillaLMS then
		local options = {
			LMS_IDS.VanillaLMS,
			getcustomasset("oldlms.mp3"),
			getcustomasset("oldestlms.mp3"),
		}
		return options[math.random(1, #options)]

	elseif id == LMS_IDS.VanityLMS then
		return getcustomasset("vanitylmsretake.mp3")
	end
end

-- 🎵 Play a custom LMS theme
local function playCustomLMS(asset)
	if THEMES_FOLDER:FindFirstChild(CUSTOM_NAME) then return end

	stopOtherThemes()

	local sound = Instance.new("Sound")
	sound.Name = CUSTOM_NAME
	sound.SoundId = asset
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = THEMES_FOLDER

	sound.Loaded:Connect(function()
		task.defer(function()
			sound.Volume = 5
			sound:Play()
		end)
	end)

	task.delay(2, function()
		if not sound.IsPlaying then
			sound.Volume = 5
			sound:Play()
		end
	end)

	print("🎵 Custom LMS started:", asset)
end

-- 🔇 Kill any chase themes when LMS starts
local function stopChaseThemes()
	for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
		if s:IsA("Sound") and (s.Name:lower():find("chase") or s.Name == "Destroying") then
			pcall(function()
				s:Stop()
				s:Destroy()
			end)
		end
	end
end




-- 🧠 Handle LMS replacements
local function handleLMS(child)
	for label, id in pairs(LMS_IDS) do
		if child.SoundId == id then
			local replacement = getLMSReplacement(id)
			child:Destroy()
			playCustomLMS(replacement)
			break
		end
	end
end

-- 🔍 Detect LMS music being added
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if not child:IsA("Sound") then return end
	handleLMS(child)

	-- In case SoundId is delayed:
	child:GetPropertyChangedSignal("SoundId"):Connect(function()
		handleLMS(child)
	end)
end)

-- 🧼 Cleanup when LMS ends (Killers + Survivors empty)
local function stopLMSIfGameOver()
	local killers = Players:FindFirstChild("Killers")
	local survivors = Players:FindFirstChild("Survivors")
	if not killers or not survivors then return end

	if #killers:GetChildren() == 0 and #survivors:GetChildren() == 0 then
		local override = THEMES_FOLDER:FindFirstChild(CUSTOM_NAME)
		if override and override:IsA("Sound") and override.IsPlaying then
			print("🛑 LMS over — stopping theme.")
			override:Stop()
			override:Destroy()
		end
	end
end

local killersFolder = Players:FindFirstChild("Killers")
local survivorsFolder = Players:FindFirstChild("Survivors")

if killersFolder then
	killersFolder.ChildRemoved:Connect(stopLMSIfGameOver)
end

if survivorsFolder then
	survivorsFolder.ChildRemoved:Connect(stopLMSIfGameOver)
end

-- 🩺 Watch for override deletion (by game)
THEMES_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == CUSTOM_NAME then
		task.wait(1)
		print("⚠️ LMSOverride removed unexpectedly.")
	end
end)

-- 🔁 Failsafe monitor
task.spawn(function()
	while true do
		task.wait(5)
		stopLMSIfGameOver()
	end
end)
