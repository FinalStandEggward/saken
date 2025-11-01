local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State
local dashActive = false

-- Instant turn logic: matches dash direction to camera forward
local function updateDirection()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end

    local lookVector = Camera.CFrame.LookVector
    local flatDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
    character.Humanoid:Move(flatDirection)
end

-- Start smooth turning during dash
local function startVoidRushOverride()
    if dashActive then return end
    dashActive = true

    RunService:BindToRenderStep("VoidRushTurnOverride", Enum.RenderPriority.Character.Value + 1, function()
        updateDirection()
    end)
end

-- Stop smooth turning
local function stopVoidRushOverride()
    if not dashActive then return end
    dashActive = false
    RunService:UnbindFromRenderStep("VoidRushTurnOverride")
end

-- Monitor Void Rush state
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local state = char:GetAttribute("VoidRushState")
            if state == "Dashing" then
                startVoidRushOverride()
            elseif dashActive and state ~= "Dashing" then
                stopVoidRushOverride()
            end
        end
    end
end)
