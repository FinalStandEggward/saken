local IngameFolder = workspace:WaitForChild("Map"):WaitForChild("Ingame")

local ESP_COLORS = {
    ["Shockwave"] = Color3.fromRGB(0, 0, 255),     -- Green
    ["Swords"] = Color3.fromRGB(0, 0, 255),         -- Green
    ["PizzaDeliveryRig"] = Color3.fromRGB(255, 50, 50), -- Red
    ["Spike"] = Color3.fromRGB(26, 31, 26),          -- Greyish
    ["Shadow"] = Color3.fromRGB(50, 50, 50),          -- Dark Gray
    ["HumanoidRootProjectile"] = Color3.fromRGB(255, 255, 255),
    ["1x1x1x1Zombie"] = Color3.fromRGB(, , 255),
    ["Pizza"] = Color3.fromRGB(255, 184, 0),
    ["Mafioso2"] = Color3.fromRGB(255, 50, 0),
    ["Mafioso3"] = Color3.fromRGB(255, 50, 0),
    ["BuildermanDispenser"] = Color3.fromRGB(255, 50, 0),
    ["BuildermanSentry"] = Color3.fromRGB(255, 50, 0),

}

local function createESP(target, color)
    if target:FindFirstChild("ESP_Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.8
    highlight.OutlineTransparency = 0.2
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Adornee = target
    highlight.Parent = target
end

local function handleObject(obj)
    local name = obj.Name
    if ESP_COLORS[name] and (obj:IsA("Model") or obj:IsA("Part")) then
        createESP(obj, ESP_COLORS[name])
    end
end

-- Special case for "Shadow" inside "(username)Shadows" folders
local function handleShadowFolder(folder)
    for _, descendant in ipairs(folder:GetDescendants()) do
        if descendant.Name == "Shadow" and (descendant:IsA("Model") or descendant:IsA("Part")) then
            createESP(descendant, ESP_COLORS["Shadow"])
        end
    end

    folder.DescendantAdded:Connect(function(obj)
        if obj.Name == "Shadow" and (obj:IsA("Model") or obj:IsA("Part")) then
            createESP(obj, ESP_COLORS["Shadow"])
        end
    end)
end

-- Monitor new children in Ingame
IngameFolder.ChildAdded:Connect(function(child)
    if child:IsA("Folder") and child.Name:match("Shadows$") then
        handleShadowFolder(child)
    else
        handleObject(child)
    end
end)

-- Apply to existing children/folders
for _, child in ipairs(IngameFolder:GetChildren()) do
    if child:IsA("Folder") and child.Name:match("Shadows$") then
        handleShadowFolder(child)
    else
        handleObject(child)
    end
end

local function createBillboardESP(part, color)
    if part:FindFirstChild("ESP_Billboard") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = part
    billboard.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "trap"
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.Parent = billboard
end

local function processShadowFolders(ingameFolder)
    for _, obj in ipairs(ingameFolder:GetChildren()) do
        if obj:IsA("Folder") and obj.Name:match("Shadows$") then
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "Shadow" then
                    createBillboardESP(part, Color3.fromRGB(120, 120, 120))
                end
            end
            obj.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") and desc.Name == "Shadow" then
                    createBillboardESP(desc, Color3.fromRGB(120, 120, 120))
                end
            end)
        end
    end
end

-- Initial run
local workspace = game:GetService("Workspace")
local ingame = workspace:WaitForChild("Map"):WaitForChild("Ingame")
processShadowFolders(ingame)

-- For new shadows that get created
ingame.ChildAdded:Connect(function(obj)
    if obj:IsA("Folder") and obj.Name:match("Shadows$") then
        processShadowFolders(ingame)
    end
end)
