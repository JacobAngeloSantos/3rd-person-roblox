-- LocalScript (place under StarterPlayer → StarterPlayerScripts)

local Players        = game:GetService("Players")
local UserInput      = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CaptureService = game:GetService("CaptureService")
local StarterGui     = game:GetService("StarterGui")
local CoreGui        = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 1) Freecam Part
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamPart = workspace:FindFirstChild("FreecamPart")
if not freecamPart then
    freecamPart = Instance.new("Part")
    freecamPart.Name         = "FreecamPart"
    freecamPart.Size         = Vector3.new(1,1,1)
    freecamPart.Anchored     = true
    freecamPart.CanCollide   = false
    freecamPart.Transparency = 1
    freecamPart.Parent       = workspace
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 2) Build GUI (parented to CoreGui as you asked)
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FreecamGUI"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 9999
screenGui.ResetOnSpawn   = false
screenGui.Parent         = CoreGui

-- Freecam Toggle
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size             = UDim2.new(0,100,0,40)
toggleBtn.Position         = UDim2.new(0,10,0,10)
toggleBtn.Text             = "Freecam"
toggleBtn.Font             = Enum.Font.SourceSansBold
toggleBtn.TextSize         = 18
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
toggleBtn.TextColor3       = Color3.new(1,1,1)

-- Teleport Button
local teleportBtn = Instance.new("TextButton", screenGui)
teleportBtn.Size             = UDim2.new(0,100,0,40)
teleportBtn.Position         = UDim2.new(0,10,0,60)
teleportBtn.Text             = "Teleport"
teleportBtn.Font             = Enum.Font.SourceSansBold
teleportBtn.TextSize         = 18
teleportBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)
teleportBtn.TextColor3       = Color3.new(1,1,1)
teleportBtn.Visible          = false

-- Screenshot Button (unchanged)
local screenshotBtn = Instance.new("TextButton", screenGui)
screenshotBtn.Size             = UDim2.new(0,100,0,40)
screenshotBtn.Position         = UDim2.new(1,-110,0,10)
screenshotBtn.Text             = "📸 Capture"
screenshotBtn.Font             = Enum.Font.SourceSansBold
screenshotBtn.TextSize         = 18
screenshotBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
screenshotBtn.TextColor3       = Color3.new(1,1,1)
screenshotBtn.Visible          = false

-- (Movement, look, speed, FOV buttons created exactly as before, omitted for brevity)
-- … [YOUR EXISTING BUTTON CREATION CODE GOES HERE] …

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 3) State Vars
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamEnabled = false
local camPosition    = camera.CFrame.Position
local yaw,pitch      = camera.CFrame:ToEulerAnglesYXZ()
local humanoid
local origWalkSpeed, origJumpPower

-- (moveState, lookState, speedValue, etc. as before)
-- … [YOUR EXISTING STATE VARS CODE GOES HERE] …

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 4) Toggle Freecam & Disable Movement
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

toggleBtn.MouseButton1Click:Connect(function()
    freecamEnabled = not freecamEnabled
    toggleBtn.Text = freecamEnabled and "Exit Cam" or "Freecam"
    teleportBtn.Visible    = freecamEnabled
    screenshotBtn.Visible  = freecamEnabled
    -- (show/hide your other buttons here)
    -- …

    humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if freecamEnabled then
        local cf = camera.CFrame
        camPosition = cf.Position
        yaw,pitch,_ = cf:ToEulerAnglesYXZ()
        camera.CameraType = Enum.CameraType.Scriptable
        if humanoid then
            origWalkSpeed = humanoid.WalkSpeed
            origJumpPower = humanoid.JumpPower
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    else
        camera.CameraType    = Enum.CameraType.Custom
        camera.CameraSubject = humanoid or nil
        if humanoid then
            humanoid.WalkSpeed = origWalkSpeed
            humanoid.JumpPower = origJumpPower
        end
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 5) Teleport Logic
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

teleportBtn.MouseButton1Click:Connect(function()
    if not freecamEnabled or not humanoid then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        -- Move the character to freecam position and match yaw
        root.CFrame = CFrame.new(camPosition) * CFrame.Angles(0, yaw, 0)
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 6) Your existing input-handling, sliders, look & move loops…
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

RunService.RenderStepped:Connect(function(dt)
    if not freecamEnabled then return end
    -- [update camPosition with movement inputs]
    -- [update yaw/pitch with look inputs]
    camera.CFrame = CFrame.new(camPosition) * CFrame.Angles(pitch, yaw, 0)
end)

-- (Plus screenshot logic, unchanged)
-- … [YOUR EXISTING SCREENSHOT CODE] …
