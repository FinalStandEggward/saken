local THEMES_FOLDER = workspace:WaitForChild("Themes")
print("custom lms enabaled")
-- IDs to detect
local TARGET_SOUNDS = {
	["LastSurvivor"] = {
		originalId = "rbxassetid://115884097233860",
		customAsset = getcustomasset("proeliumfatale.mp3"),
	},
	["AmbienceReplacement"] = {
		originalId = "rbxassetid://137266220091579",
		customAsset = getcustomasset("vanitylmsretake.mp3"),
	}
}

-- Function to handle replacement
local function replaceSound(name, asset)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = asset
	sound.Looped = true
	sound.Volume = 0 -- start quiet until loaded
	sound.Parent = THEMES_FOLDER

	sound.Loaded:Connect(function()
		sound.Volume = 5
		sound:Play()
	end)

	task.delay(2, function()
		if sound and not sound.IsPlaying then
			sound.Volume = 5
			sound:Play()
		end
	end)
end

-- Check existing sounds
for name, data in pairs(TARGET_SOUNDS) do
	for _, child in ipairs(THEMES_FOLDER:GetChildren()) do
		if child:IsA("Sound") and child.SoundId == data.originalId then
			child:Destroy()
			replaceSound(name, data.customAsset)
		end
	end
end

-- Monitor for new additions
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		for name, data in pairs(TARGET_SOUNDS) do
			if child.SoundId == data.originalId then
				child:Destroy()
				replaceSound(name, data.customAsset)
			end
		end
	end
end)
