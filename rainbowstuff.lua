local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Global toggle
_G.RAINBOW_HITBOXES_ENABLED = true

local rainbowParts = {}
local rainbowTexts = {}
local rainbowTime = 0
local colorSpeed = 3

local HitboxFolder = Workspace:WaitForChild("Hitboxes")
local MiscFolder = Workspace:WaitForChild("Misc")

-- Rainbow function
local function getRainbowColor(time)
	local r = math.sin(time) * 0.5 + 0.5
	local g = math.sin(time + 2) * 0.5 + 0.5
	local b = math.sin(time + 4) * 0.5 + 0.5
	return Color3.new(r, g, b)
end

-- Add part
local function addPart(part)
	if not rainbowParts[part] then
		rainbowParts[part] = true
	end
end

-- Attach dynamic text color tracking to any BillboardGui descendants
local function watchForBillboardText(part)
	local function attachWatcher(gui)
		if gui:IsA("BillboardGui") then
			gui.DescendantAdded:Connect(function(desc)
				if desc:IsA("TextLabel") then
					rainbowTexts[desc] = true
				end
			end)
		end
	end

	-- Check existing
	for _, obj in ipairs(part:GetDescendants()) do
		attachWatcher(obj)
		if obj:IsA("TextLabel") then
			rainbowTexts[obj] = true
		end
	end

	-- Monitor for future BillboardGuis/TextLabels
	part.DescendantAdded:Connect(attachWatcher)
end

-- Scan existing
for _, part in ipairs(HitboxFolder:GetChildren()) do
	if part:IsA("BasePart") then
		addPart(part)
	end
end

for _, part in ipairs(MiscFolder:GetChildren()) do
	if part:IsA("BasePart") then
		watchForBillboardText(part)
	end
end

-- New additions
HitboxFolder.ChildAdded:Connect(function(part)
	if part:IsA("BasePart") then
		addPart(part)
	end
end)

MiscFolder.ChildAdded:Connect(function(part)
	if part:IsA("BasePart") then
		watchForBillboardText(part)
	end
end)

-- Removal cleanup
HitboxFolder.ChildRemoved:Connect(function(part)
	rainbowParts[part] = nil
end)

MiscFolder.ChildRemoved:Connect(function(part)
	for _, d in ipairs(part:GetDescendants()) do
		if d:IsA("TextLabel") then
			rainbowTexts[d] = nil
		end
	end
end)

-- Animate everything
RunService.Heartbeat:Connect(function(dt)
	if not _G.RAINBOW_HITBOXES_ENABLED then return end

	rainbowTime += dt * (math.pi * 2 / colorSpeed)
	local rainbow = getRainbowColor(rainbowTime)

	for part in pairs(rainbowParts) do
		if part:IsA("BasePart") then
			part.Color = rainbow
		else
			rainbowParts[part] = nil
		end
	end

	for label in pairs(rainbowTexts) do
		if label:IsA("TextLabel") then
			label.TextColor3 = rainbow
		else
			rainbowTexts[label] = nil
		end
	end
end)
