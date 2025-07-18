-- ✅ Sleek Rebuild with Native Roblox UI (styled like Starlight / Luna Suite)
-- 📜 UI Hub for executing scripts, toggleable via minus key, single execution guard

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Guard to prevent re-running
if CoreGui:FindFirstChild("SakenScriptHub") then return end

local scriptList = {
    ["Custom LMS"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/custom%20lms.lua",
    ["Custom Chase Theme"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/customchasetheme.lua",
    ["Pizza"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/pizza.lua",
    ["Sigma Saken"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/sigmasaken.lua",
    ["Old Lobby Theme"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/oldlobbytheme.lua",
    ["Rainbow Hitboxes/Markers"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/rainbowstuff.lua",
    ["MaliceGui"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/malice.lua",
    ["MoneyGui"] = "https://raw.githubusercontent.com/FinalStandEggward/saken/refs/heads/main/money.lua",
}

local executedScripts = {}

-- Create UI
local Gui = Instance.new("ScreenGui")
Gui.Name = "SakenScriptHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 450, 0, 520)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.5
Shadow.BackgroundTransparency = 1
Shadow.ZIndex = 0
Shadow.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "☄️ Saken Script Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextStrokeTransparency = 0.8
Title.TextWrapped = true
Title.Parent = Frame

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 42)
Line.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
Line.BorderSizePixel = 0
Line.Parent = Frame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -20, 1, -60)
Scrolling.Position = UDim2.new(0, 10, 0, 50)
Scrolling.BackgroundTransparency = 1
Scrolling.BorderSizePixel = 0
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scrolling.ScrollBarThickness = 4
Scrolling.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Scrolling

local function createScriptButton(name, url)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(36, 36, 46)
    Button.BorderSizePixel = 0
    Button.Text = "▶ " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 14
    Button.AutoButtonColor = true
    Button.Parent = Scrolling

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = Button

    local shadow = Instance.new("UIStroke")
    shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    shadow.Color = Color3.fromRGB(60, 60, 80)
    shadow.Thickness = 1
    shadow.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if executedScripts[name] then
            Button.Text = "⚠️ Already executed"
            return
        end
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success then
            Button.Text = "✅ " .. name .. " loaded"
            executedScripts[name] = true
        else
            Button.Text = "❌ Failed"
            warn("[SakenHub] Failed to load", name, result)
        end
    end)
end

for name, url in pairs(scriptList) do
    createScriptButton(name, url)
end

-- Minus key toggle
local visible = true
UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Minus then
        visible = not visible
        Gui.Enabled = visible
        Frame.Visible = visible
    end
end)
