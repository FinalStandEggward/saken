local THEMES_FOLDER = workspace:WaitForChild("Themes")
local MAP_FOLDER = workspace:WaitForChild("Map")

local TARGET_ID = "rbxassetid://113613352374472"
local CUSTOM_ASSET = getcustomasset("safespace.mp3")
local CUSTOM_NAME = "LobbyOverride"

-- 🧼 Stop only this sound
local function stopLobbyOverride()
	local sound = THEMES_FOLDER:FindFirstChild(CUSTOM_NAME)
	if sound and sound:IsA("Sound") then
		print("🛑 Stopping lobby override theme")
		sound:Stop()
		sound:Destroy()
	end
end

-- 🎵 Create and play the lobby override
local function playLobbyOverride()
	if THEMES_FOLDER:FindFirstChild(CUSTOM_NAME) then return end

	local sound = Instance.new("Sound")
	sound.Name = CUSTOM_NAME
	sound.SoundId = CUSTOM_ASSET
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

	print("🎵 Playing lobby theme override (SafeSpace)")
end

-- 🧠 Watch for actual lobby music being inserted
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") and child.Name:lower() == "lobby" then
		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			if child.SoundId == TARGET_ID then
				child:Destroy()
				playLobbyOverride()
			end
		end)

		if child.SoundId == TARGET_ID then
			child:Destroy()
			playLobbyOverride()
		end
	end
end)

-- 🛡️ Watch for override deletion
THEMES_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == CUSTOM_NAME then
		-- Only recreate if we're still in lobby
		task.delay(1, function()
			if MAP_FOLDER:FindFirstChild("Lobby") then
				print("⚠️ Lobby theme was deleted, recreating...")
				playLobbyOverride()
			end
		end)
	end
end)

-- 🚪 Detect when intermission ends (Map changes to not be Lobby)
MAP_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == "Lobby" then
		stopLobbyOverride()
	end
end)

-- 🛑 Optional: Watch for match start
task.spawn(function()
	while true do
		task.wait(3)
		if not MAP_FOLDER:FindFirstChild("Lobby") then
			stopLobbyOverride()
		end
	end
end)
