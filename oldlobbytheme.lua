local THEMES_FOLDER = workspace:WaitForChild("Themes")
local TARGET_ID = "rbxassetid://113613352374472"
local CUSTOM_ASSET = getcustomasset("safespace.mp3")

-- Replace logic
local function replaceLobbySound()
	for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
		if sound:IsA("Sound") and sound.Name:lower() == "lobby" and sound.SoundId == TARGET_ID then
			print("🎵 Replacing lobby music with SafeSpace...")
			sound:Destroy()

			local newSound = Instance.new("Sound")
			newSound.Name = "lobby"
			newSound.SoundId = CUSTOM_ASSET
			newSound.Looped = true
			newSound.Volume = 0
			newSound.Parent = THEMES_FOLDER

			newSound.Loaded:Connect(function()
				task.defer(function()
					newSound.Volume = 5
					newSound:Play()
				end)
			end)

			task.delay(2, function()
				if not newSound.IsPlaying then
					newSound.Volume = 5
					newSound:Play()
				end
			end)
		end
	end
end

-- Initial check
replaceLobbySound()

-- Watch for future lobby spawns
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") and child.Name:lower() == "lobby" then
		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			if child.SoundId == TARGET_ID then
				child:Destroy()
				replaceLobbySound()
			end
		end)

		-- If it's already the target ID
		if child.SoundId == TARGET_ID then
			child:Destroy()
			replaceLobbySound()
		end
	end
end)
