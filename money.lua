local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for Money
local function waitForValue()
	local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
	if not leaderstats then return end
	return leaderstats:WaitForChild("Money", 10)
end

local Money = waitForValue()
if not Money then
	warn("Money not found.")
	return
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "DraggableFrame"
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.3
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Money"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 18
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Parent = frame

local valueLabel = Instance.new("TextLabel")
valueLabel.Text = "Money: 0"
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.TextSize = 16
valueLabel.BackgroundTransparency = 1
valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
valueLabel.Parent = frame

-- Check if this player has the most malice
local function hasMostMoney()
	local myValue = Money.Value
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local ls = player:FindFirstChild("leaderstats")
			local kc = ls and ls:FindFirstChild("Money")
			if kc and kc.Value > myValue then
				return false
			end
		end
	end
	return true
end

-- Update display
local function update()
	local msg = "$ " .. tostring(Money.Value)
	if hasMostMoney() then
		msg = msg .. " (🤑🤑🤑)"
	end
	valueLabel.Text = msg
end

-- Initial update
update()

-- Update on change
Money:GetPropertyChangedSignal("Value"):Connect(update)
Players.PlayerAdded:Connect(function(p)
	p:GetPropertyChangedSignal("leaderstats"):Connect(update)
end)
Players.PlayerRemoving:Connect(update)
