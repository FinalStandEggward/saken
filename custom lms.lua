local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")
local LocalPlayer = Players.LocalPlayer

local LMS_IDS = {
	SelfHatred = "rbxassetid://115884097233860",
	VanityLMS  = "rbxassetid://137266220091579",
	Plead      = "rbxassetid://80814147615195",
	RemorseRedux = "rbxassetid://88279626466849"
}

local CUSTOM_NAME = "LMSOverride"

-- 🚨 Suppress "Destroying" chase themes
local function monitorDestroyingSounds()
	for _, s in ipairs(THEMES_FOLDER:GetChildren()) do
		if s:IsA("Sound") and s.Name == "Destroying" then
			if s.Volume > 0 then
				s.Volume = 0
				print("🔇 Instantly suppressed:", s.SoundId)
			end
			task.defer(function()
				s:GetPropertyChangedSignal("Volume"):Connect(function()
					if s.Volume > 0 then
						s.Volume = 0
						print("🔁 Re-suppressed:", s.SoundId)
					end
				end)
			end)
		end
	end
end

-- 🔇 Wrapper
local function stopChaseThemes()
	monitorDestroyingSounds()
end

-- 🛑 Stop other music except override
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

-- 🎯 LMS replacement logic
local function getLMSReplacement(id)
	if id == LMS_IDS.SelfHatred or id == LMS_IDS.Plead then
		return getcustomasset("meetyourmaking.mp3")
	elseif id == LMS_IDS.VanityLMS then
		return getcustomasset("vanitylmsretake.mp3")
	elseif id == LMS_IDS.RemorseRedux then
		return getcustomasset("remorseredux.mp3")
	end
end

-- 🎵 Play custom LMS theme
local function playCustomLMS(asset)
	if THEMES_FOLDER:FindFirstChild(CUSTOM_NAME) then return end

	stopOtherThemes()

	local sound = Instance.new("Sound")
	sound.Name = CUSTOM_NAME
	sound.SoundId = asset
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
		if not sound.IsPlaying then
			sound.Volume = 5
			sound:Play()
		end
	end)

	print("🎵 Custom LMS started:", asset)
end

-- 🧠 Handle LMS replacements
local function handleLMS(child)
	for label, id in pairs(LMS_IDS) do
		if child.SoundId == id then
			stopChaseThemes()
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
	child:GetPropertyChangedSignal("SoundId"):Connect(function()
		handleLMS(child)
	end)
end)

-- 🧼 Cleanup when LMS ends
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
		stopChaseThemes()
	end
end

-- 📡 Connect LMS end detection
local killersFolder = Players:FindFirstChild("Killers")
local survivorsFolder = Players:FindFirstChild("Survivors")

if killersFolder then
	killersFolder.ChildRemoved:Connect(stopLMSIfGameOver)
end
if survivorsFolder then
	survivorsFolder.ChildRemoved:Connect(stopLMSIfGameOver)
end

-- 🩺 Monitor override deletion
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
		stopChaseThemes()
	end
end)
