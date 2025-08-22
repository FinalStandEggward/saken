-- // 🔊 Custom Theme Override Script with Auto Downloader
local Players = game:GetService("Players")
local THEMES_FOLDER = workspace:WaitForChild("Themes")

-- Folder for local MP3s
local FOLDER_NAME = "CustomThemes"

if not isfolder(FOLDER_NAME) then
    makefolder(FOLDER_NAME)
    print("📂 Created folder:", FOLDER_NAME)
end

-- // Downloader Function
local function downloadIfMissing(filename, url)
    local filepath = FOLDER_NAME.."/"..filename
    if not isfile(filepath) then
        print("⬇️ Downloading:", filename)
        local data = game:HttpGet(url)
        writefile(filepath, data)
    else
        print("✅ File already exists:", filename)
    end
    return getcustomasset(filepath)
end

-- // Base GitHub URL
local GITHUB_BASE = "https://github.com/FinalStandEggward/saken/raw/refs/heads/main/"

-- // Theme replacement sets
local SELF_HATRED_REPLACEMENTS = {
    ["rbxassetid://139957641994343"] = downloadIfMissing("layer1selfhatred.mp3", GITHUB_BASE.."layer1selfhatred.mp3"),
    ["rbxassetid://107607873139123"] = downloadIfMissing("layer2selfhatred.mp3", GITHUB_BASE.."layer2selfhatred.mp3"),
    ["rbxassetid://105551772469406"] = downloadIfMissing("layer3selfhatred.mp3", GITHUB_BASE.."layer3selfhatred.mp3"),
    ["rbxassetid://97690757653206"]  = downloadIfMissing("chaseselfhatred.mp3", GITHUB_BASE.."chaseselfhatred.mp3"),
}
local OLD1X_REPLACEMENTS = {
    ["rbxassetid://139957641994343"] = downloadIfMissing("old1xlayer1.mp3", GITHUB_BASE.."old1xlayer1.mp3"),
    ["rbxassetid://107607873139123"] = downloadIfMissing("old1xlayer2.mp3", GITHUB_BASE.."old1xlayer2.mp3"),
    ["rbxassetid://105551772469406"] = downloadIfMissing("old1xlayer3.mp3", GITHUB_BASE.."old1xlayer3.mp3"),
    ["rbxassetid://97690757653206"]  = downloadIfMissing("old1xchase.mp3", GITHUB_BASE.."old1xchase.mp3"),
}
local NIGHT16_REPLACEMENTS = {
    ["rbxassetid://139957641994343"] = downloadIfMissing("16thlayer1.mp3", GITHUB_BASE.."16thlayer1.mp3"),
    ["rbxassetid://107607873139123"] = downloadIfMissing("16thlayer2.mp3", GITHUB_BASE.."16thlayer2.mp3"),
    ["rbxassetid://105551772469406"] = downloadIfMissing("16thlayer3.mp3", GITHUB_BASE.."16thlayer3.mp3"),
    ["rbxassetid://97690757653206"]  = downloadIfMissing("16thchase.mp3", GITHUB_BASE.."16thchase.mp3"),
}

local ActiveReplacements = {}
local CURRENT_THEME = "none"

print("🔊 Custom Theme Override Watching Player Loadouts")

-- Applies a REPLACEMENTS table to all current sounds
local function applyTheme(replacementTable)
    for _, sound in ipairs(THEMES_FOLDER:GetChildren()) do
        if sound:IsA("Sound") and replacementTable[sound.SoundId] then
            sound.SoundId = replacementTable[sound.SoundId]
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
                print("🔁 Updated SoundId for", child.Name)
            end
        end)
        if ActiveReplacements[child.SoundId] then
            child.SoundId = ActiveReplacements[child.SoundId]
            print("🔁 Replaced SoundId for", child.Name)
        end
    end)
end

-- Determine which theme to use
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
            elseif skinName and skinName.Value == "16thNight1x1x1x1" then
                return NIGHT16_REPLACEMENTS, "16thnight"
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
