local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")
local LocalPlayer = Players.LocalPlayer

print("🎵 Custom LMS Enabled")

-- Base sound ID map (Ambience untouched)
local TARGET_SOUNDS = {
	["LastSurvivor"] = {
		originalId = "rbxassetid://115884097233860", -- LMS music
		customAsset = nil, -- We'll choose this dynamically below
	},
	["AmbienceReplacement"] = {
		originalId = "rbxassetid://137266220091579", -- Ambient music
		customAsset = getcustomasset("vanitylmsretake.mp3"),
	}
}

-- Determine proper LMS track based on killer and skin
local function determineLMSAsset()
	local killerModel = workspace:FindFirstChild("Players")
		and workspace.Players:FindFirstChild("Killers")
		and workspace.Players.Killers:FindFirstChild("1x1x1x1")

	if not killerModel then
		return getcustomasset("thedarknessinyourheart.mp3")
	end

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
end

-- Inject appropriate custom asset into slot
local function replaceSound(name, asset)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = asset
	sound.Looped = true
	sound.Volume = 0 -- quiet until loaded
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

-- First scan
for name, data in pairs(TARGET_SOUNDS) do
	for _, child in ipairs(THEMES_FOLDER:GetChildren()) do
		if child:IsA("Sound") and child.SoundId == data.originalId then
			child:Destroy()
			if name == "LastSurvivor" then
				data.customAsset = determineLMSAsset()
			end
			replaceSound(name, data.customAsset)
		end
	end
end

-- Live monitoring
THEMES_FOLDER.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		for name, data in pairs(TARGET_SOUNDS) do
			if child.SoundId == data.originalId then
				child:Destroy()
				if name == "LastSurvivor" then
					data.customAsset = determineLMSAsset()
				end
				replaceSound(name, data.customAsset)
			end
		end
	end
end)
