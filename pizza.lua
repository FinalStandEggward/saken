-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Paths
local mapFolder = Workspace:WaitForChild("Map"):WaitForChild("Ingame")

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PizzaTPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Container Frame
local container = Instance.new("Frame")
container.Name = "InputContainer"
container.Size = UDim2.new(0, 220, 0, 40)
container.Position = UDim2.new(0, 10, 0, 10)
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.BackgroundTransparency = 0.15
container.BorderSizePixel = 0
container.Parent = screenGui

container.Active = true
container.Selectable = true
container.Draggable = true


-- Rounded corners
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 10)
uicorner.Parent = container

-- Drop shadow
local shadow = Instance.new("ImageLabel")
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow.Size = UDim2.new(1, 12, 1, 12)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.85
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0
shadow.Parent = container

-- Textbox
local textBox = Instance.new("TextBox")
textBox.Name = "InputBox"
textBox.Size = UDim2.new(1, -20, 1, -10)
textBox.Position = UDim2.new(0, 10, 0, 5)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.PlaceholderText = "Enter username (2+ letters)"
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.TextSize = 18
textBox.Font = Enum.Font.Gotham
textBox.ClearTextOnFocus = false
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.ZIndex = 1
textBox.Parent = container

-- Animate on focus
local TweenService = game:GetService("TweenService")
textBox.Focused:Connect(function()
	TweenService:Create(container, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 240, 0, 45)
	}):Play()
end)

textBox.FocusLost:Connect(function()
	TweenService:Create(container, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 220, 0, 40)
	}):Play()
end)


-- Utility: Find player by partial name (excluding self)
local function findPlayerByPartialName(partial)
	if not partial or #partial < 2 then return nil end
	partial = partial:lower()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Name:lower():sub(1, #partial) == partial then
			return player
		end
	end
	return nil
end

-- Utility: Get lowest % health player (excluding self)
local function getLowestHealthPlayer()
	local lowestPercent = 101
	local target = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and hum.MaxHealth > 0 then
				local percent = (hum.Health / hum.MaxHealth) * 100
				if percent < lowestPercent then
					lowestPercent = percent
					target = player
				end
			end
		end
	end
	return target
end

-- Main: Watch for "Pizza" appearing
mapFolder.ChildAdded:Connect(function(child)
	if child.Name == "Pizza" then
		task.delay(0.05, function()
			local input = textBox.Text
			local targetPlayer = findPlayerByPartialName(input) or getLowestHealthPlayer()
			if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = targetPlayer.Character.HumanoidRootPart
				child:PivotTo(hrp.CFrame + Vector3.new(0, 3, 0))
				-- Stop motion
				if child:IsA("BasePart") then
					child.AssemblyLinearVelocity = Vector3.zero
				elseif child:IsA("Model") then
					for _, part in ipairs(child:GetDescendants()) do
						if part:IsA("BasePart") then
							part.AssemblyLinearVelocity = Vector3.zero
						end
					end
				end
			end
		end)
	end
end)
