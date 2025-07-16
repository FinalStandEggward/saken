local THEMES_FOLDER = workspace:WaitForChild("Themes")
local TARGET_ID = "rbxassetid://113613352374472"
local CUSTOM_ASSET = getcustomasset("safespace.mp3")
local CUSTOM_NAME = "LobbyOverride"

-- 🛑 Stop all other themes except our own
local function stopOtherMusic()
	for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
		if s:IsA("Sound") and s.Name ~= CUSTOM_NAME then
			pcall(function()
				s:Stop()
				s:Destroy()
			end)
		end
	end
end

-- 🎵 Create and play the lobby override
local function playCustomLobby()
	-- Avoid duplicates
	if THEMES_FOLDER:FindFirstChild(CUSTOM_NAME) then return end

	local sound = Instance.new("Sound")
	sound.Name = CUSTOM_NAME
	sound.SoundId = CUSTOM_ASSET
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = THEMES_FOLDER

	sound.Loaded:Connect(function()
		task.defer(function()
			stopOtherMusic()
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

	print("🎵 Playing SafeSpace as lobby theme.")
end

-- 👁️ Watch for default lobby theme being added (initial or repeated)
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") and child.Name:lower() == "lobby" then
		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			if child.SoundId == TARGET_ID then
				print("🔁 Detected default lobby theme. Replacing...")
				child:Destroy()
				playCustomLobby()
			end
		end)

		if child.SoundId == TARGET_ID then
			child:Destroy()
			playCustomLobby()
		end
	end
end)

-- 🛡️ Monitor for your custom lobby getting deleted
THEMES_FOLDER.ChildRemoved:Connect(function(child)
	if child.Name == CUSTOM_NAME then
		task.wait(1)
		print("⚠️ LobbyOverride was removed. Reapplying...")
		playCustomLobby()
	end
end)

-- 🧹 Periodic safety check
task.spawn(function()
	while true do
		task.wait(6)
		local found = false
		for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
			if s:IsA("Sound") and s.Name == CUSTOM_NAME then
				found = true
			elseif s:IsA("Sound") and s.Name:lower() == "lobby" and s.SoundId == TARGET_ID then
				s:Destroy()
				playCustomLobby()
			end
		end

		if not found then
			playCustomLobby()
		end
	end
end)
