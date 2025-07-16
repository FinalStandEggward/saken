local THEMES_FOLDER = workspace:WaitForChild("Themes")
local TARGET_ID = "rbxassetid://113613352374472"
local CUSTOM_ASSET = getcustomasset("safespace.mp3")

-- Utility: stops conflicting lobby tracks
local function stopOtherThemes()
	for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
		if s:IsA("Sound") and s.Name:lower() ~= "lobby" and s.IsPlaying then
			s:Stop()
		end
	end
end

-- Replaces the default lobby track
local function replaceLobbySound(original)
	if original and original:IsDescendantOf(THEMES_FOLDER) then
		original:Destroy()
	end

	local newSound = Instance.new("Sound")
	newSound.Name = "lobby"
	newSound.SoundId = CUSTOM_ASSET
	newSound.Looped = true
	newSound.Volume = 0
	newSound.Parent = THEMES_FOLDER

	newSound.Loaded:Connect(function()
		task.defer(function()
			stopOtherThemes()
			newSound.Volume = 5
			newSound:Play()
		end)
	end)

	task.delay(2, function()
		if newSound and not newSound.IsPlaying then
			newSound.Volume = 5
			newSound:Play()
		end
	end)

	print("🎵 Replaced lobby music with SafeSpace")
end

-- Watch for new lobby sounds being added
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if not child:IsA("Sound") then return end

	if child.Name:lower() == "lobby" then
		-- Watch for changes in SoundId too (sometimes it updates after parenting)
		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			if child.SoundId == TARGET_ID then
				replaceLobbySound(child)
			end
		end)

		-- Immediate match
		if child.SoundId == TARGET_ID then
			replaceLobbySound(child)
		end
	end
end)

-- Safety fallback: check every 5 seconds in case something slipped through
task.spawn(function()
	while true do
		task.wait(5)
		for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
			if s:IsA("Sound") and s.Name:lower() == "lobby" and s.SoundId == TARGET_ID then
				replaceLobbySound(s)
			end
		end
	end
end)
