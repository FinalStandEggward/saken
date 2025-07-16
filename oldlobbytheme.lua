local THEMES_FOLDER = workspace:WaitForChild("Themes")
local MAP_FOLDER = workspace:WaitForChild("Map")

local TARGET_ID = "rbxassetid://113613352374472"
local CUSTOM_ASSET = getcustomasset("safespace.mp3")
local CUSTOM_NAME = "LobbyOverride"

print("▶️ Target Sound ID:", TARGET_ID)
print("▶️ Custom Asset:", CUSTOM_ASSET)

local function stopLobbyOverride()
	local sound = THEMES_FOLDER:FindFirstChild(CUSTOM_NAME)
	if sound and sound:IsA("Sound") then
		print("🛑 Stopping lobby override theme")
		sound:Stop()
		sound:Destroy()
	end
end

local function playLobbyOverride()
	if THEMES_FOLDER:FindFirstChild(CUSTOM_NAME) then 
		print("ℹ️ Custom lobby override sound already playing")
		return 
	end

	local sound = Instance.new("Sound")
	sound.Name = CUSTOM_NAME
	sound.SoundId = CUSTOM_ASSET
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = THEMES_FOLDER

	sound.Loaded:Connect(function()
		print("✅ Custom sound loaded, playing")
		task.defer(function()
			sound.Volume = 5
			sound:Play()
		end)
	end)

	task.delay(2, function()
		if not sound.IsPlaying then
			print("⚠️ Custom sound not playing, forcing play")
			sound.Volume = 5
			sound:Play()
		end
	end)

	print("🎵 Playing lobby theme override (SafeSpace)")
end

local function isInLobbyOrIngame()
	return MAP_FOLDER:FindFirstChild("Lobby") or MAP_FOLDER:FindFirstChild("Ingame")
end

-- Override existing lobby sounds at script start
for _, child in pairs(THEMES_FOLDER:GetChildren()) do
	if child:IsA("Sound") and child.Name:lower() == "lobby" and child.SoundId == TARGET_ID then
		print("🔍 Found existing lobby sound, destroying and overriding")
		child:Destroy()
		playLobbyOverride()
	end
end

THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		print("🎧 Sound added:", child.Name, child.SoundId)
		if child.Name:lower() == "lobby" and child.SoundId == TARGET_ID then
			print("🛠️ Lobby sound detected, destroying and overriding")
			child:Destroy()
			playLobbyOverride()
		end
	end
end)

THEMES_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == CUSTOM_NAME then
		task.delay(1, function()
			if isInLobbyOrIngame() then
				print("⚠️ Lobby theme was deleted, recreating...")
				playLobbyOverride()
			end
		end)
	end
end)

MAP_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == "Lobby" or child.Name == "Ingame" then
		if not isInLobbyOrIngame() then
			stopLobbyOverride()
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if not isInLobbyOrIngame() then
			stopLobbyOverride()
		end
	end
end)
