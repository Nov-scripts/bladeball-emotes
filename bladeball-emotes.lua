-- GUI + Emote Playback Script for Blade Ball
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Manual emote name override table
local customNames = {
    Emote173 = "Breakdance",
    Emote170 = "Wave",
    -- Add more as needed
}

-- Emote storage
local emotesFolder = ReplicatedStorage:WaitForChild("Misc"):WaitForChild("Emotes")
local emotes = {}
for _, anim in ipairs(emotesFolder:GetChildren()) do
    if anim:IsA("Animation") then
        table.insert(emotes, anim)
    end
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BladeBall_EmoteGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- TopBar with "Nov script"
local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Active = false

TopBar.Draggable = true
TopBar.ZIndex = 2

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Nov script"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- ❌️ Close Button
local CloseButton = Instance.new("TextButton", TopBar)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "❌️"
CloseButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.ZIndex = 3

-- Mini UI (⛔️)
local MiniUI = Instance.new("Frame", ScreenGui)
MiniUI.Size = UDim2.new(0, 140, 0, 40)
MiniUI.Position = UDim2.new(0.5, -70, 0.5, -20)
MiniUI.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
MiniUI.Visible = false
MiniUI.Active = true
MiniUI.Draggable = true

local ReopenButton = Instance.new("TextButton", MiniUI)
ReopenButton.Size = UDim2.new(0.5, 0, 1, 0)
ReopenButton.Position = UDim2.new(0, 0, 0, 0)
ReopenButton.Text = "🟢"
ReopenButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ReopenButton.TextColor3 = Color3.new(1, 1, 1)

-- Frame Content
local SearchBox = Instance.new("TextBox", Frame)
SearchBox.PlaceholderText = "Search emotes..."
SearchBox.Size = UDim2.new(1, -10, 0, 30)
SearchBox.Position = UDim2.new(0, 5, 0, 35)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.ClearTextOnFocus = false

local RandomButton = Instance.new("TextButton", Frame)
RandomButton.Text = "Random Emote"
RandomButton.Size = UDim2.new(1, -10, 0, 30)
RandomButton.Position = UDim2.new(0, 5, 0, 70)
RandomButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RandomButton.TextColor3 = Color3.new(1, 1, 1)

local Scrolling = Instance.new("ScrollingFrame", Frame)
Scrolling.Size = UDim2.new(1, -10, 1, -110)
Scrolling.Position = UDim2.new(0, 5, 0, 105)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, #emotes * 35)
Scrolling.ScrollBarThickness = 6
Scrolling.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

-- Active Animation Track
local activeTrack

-- Emote Play Function
local function playEmote(animation)
    if activeTrack then activeTrack:Stop() end
    activeTrack = Humanoid:LoadAnimation(animation)
    activeTrack:Play()
end

-- Button Generation
local function refreshButtons(filter)
    Scrolling:ClearAllChildren()
    local y = 0
    for i, anim in ipairs(emotes) do
        local name = customNames[anim.Name] or ("Emote " .. i)
        if not filter or name:lower():find(filter:lower()) then
            local btn = Instance.new("TextButton", Scrolling)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, y)
            btn.Text = name
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.MouseButton1Click:Connect(function()
                playEmote(anim)
            end)
            y += 35
        end
    end
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, y)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshButtons(SearchBox.Text)
end)

RandomButton.MouseButton1Click:Connect(function()
    local anim = emotes[math.random(1, #emotes)]
    playEmote(anim)
end)

-- Stop emote when walking
Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if activeTrack and Humanoid.MoveDirection.Magnitude > 0 then
        activeTrack:Stop()
    end
end)

-- Close and Reopen Logic
CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    MiniUI.Visible = true
end)

ReopenButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    MiniUI.Visible = false
end)

-- Init
refreshButtons()
