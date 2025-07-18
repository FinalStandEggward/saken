local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")
print("🔊 Custom Self-Hatred Theme Override Watching Player Loadouts")

-- Theme replacement sets
local SELF_HATRED_REPLACEMENTS = {
	["rbxassetid://139957641994343"] = getcustomasset("layer1selfhatred.mp3"),
	["rbxassetid://107607873139123"] = getcustomasset("layer2selfhatred.mp3"),
	["rbxassetid://105551772469406"] = getcustomasset("layer3selfhatred.mp3"),
	["rbxassetid://97690757653206"]  = getcustomasset("chaseselfhatred.mp3"),
}

local OLD1X_REPLACEMENTS = {
	["rbxassetid://139957641994343"] = getcustomasset("old1xlayer1.mp3"),
	["rbxassetid://107607873139123"] = getcustomasset("old1xlayer2.mp3"),
	["rbxassetid://105551772469406"] = getcustomasset("old1xlayer3.mp3"),
	["rbxassetid://97690757653206"]  = getcustomasset("old1xchase.mp3"),
}

local ActiveReplacements = {}
local CURRENT_THEME = "none"

-- 🔒 Force suppression of old1xlayer1.mp3 or "Destroying"
local function suppressIfOld1xLayer1(sound)
	if not sound:IsA("Sound") then return end
	local sid = sound.SoundId
	if sid == getcustomasset("old1xlayer1.mp3") or sound.Name == "Destroying" then
		if sound.Volume > 0 then
			sound.Volume = 0
			print("🔇 Suppressed:", sound.Name)
		end
		task.defer(function()
			sound:GetPropertyChangedSignal("Volume"):Connect(function()
				if sound.Volume > 0 then
					sound.Volume = 0
					print("🔁 Re-suppressed:", sound.Name)
				end
			end)
		end)
	end
end

-- Applies a REPLACEMENTS table to all current sounds
local function applyTheme(replacementTable)
	for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
		if sound:IsA("Sound") and replacementTable[sound.SoundId] then
			sound.SoundId = replacementTable[sound.SoundId]

			if replacementTable == OLD1X_REPLACEMENTS then
				sound.Loaded:Connect(function()
					sound.Volume = 6
				end)
				suppressIfOld1xLayer1(sound)
			end

			print("🔁 Replaced SoundId for", sound.Name)
		end
	end
end

-- Monitor future sound additions and SoundId changes
local function hookNewSounds()
	THEMES_FOLDER.ChildAdded:Connect(function(child)
		if not child:IsA("Sound") then return end

		child:GetPropertyChangedSignal("SoundId"):Connect(function()
			if ActiveReplacements[child.SoundId] then
				child.SoundId = ActiveReplacements[child.SoundId]

				if ActiveReplacements == OLD1X_REPLACEMENTS then
					child.Volume = 0
					child.Loaded:Connect(function()
						child.Volume = 6
					end)
					suppressIfOld1xLayer1(child)
				end

				print("🔁 Updated SoundId for", child.Name)
			end
		end)

		if ActiveReplacements[child.SoundId] then
			child.SoundId = ActiveReplacements[child.SoundId]

			if ActiveReplacements == OLD1X_REPLACEMENTS then
				child.Volume = 0
				child.Loaded:Connect(function()
					child.Volume = 6
				end)
				suppressIfOld1xLayer1(child)
			end

			print("🔁 Replaced SoundId for", child.Name)
		end
	end)
end

-- Determine whether to use Hacklord or Old1x
local function determineTheme()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if not char then continue end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 500 then continue end

		local equipped = player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("Equipped")
		if not equipped then continue end

		local killer = equipped:FindFirstChild("Killer")
		local skins = equipped:FindFirstChild("Skins")
		if not killer then continue end

		local killerName = killer.Value
		local skinName = skins and skins:FindFirstChild("1x1x1x1")

		if killerName == "1x1x1x1" then
			if skinName and skinName.Value == "Hacklord1x1x1x1" then
				return SELF_HATRED_REPLACEMENTS, "selfhatred"
			else
				return OLD1X_REPLACEMENTS, "old1x"
			end
		end
	end

	return nil, "none"
end

-- 🚀 Begin execution
task.wait(3)
hookNewSounds()

while true do
	task.wait(5)

	local newTheme, themeName = determineTheme()

	if newTheme and newTheme ~= ActiveReplacements then
		print("🎵 Switching theme to:", themeName)
		ActiveReplacements = newTheme
		CURRENT_THEME = themeName
		applyTheme(ActiveReplacements)
	end
end
