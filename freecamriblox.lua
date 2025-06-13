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
-- (1) BUILD (OR FIND) THE INVISIBLE “FREECAM PART”
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamPart = workspace:FindFirstChild("FreecamPart")
if not freecamPart then
    freecamPart = Instance.new("Part")
    freecamPart.Name         = "FreecamPart"
    freecamPart.Size         = Vector3.new(1, 1, 1)
    freecamPart.Anchored     = true
    freecamPart.CanCollide   = false
    freecamPart.Transparency = 1
    freecamPart.Parent       = workspace
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (2) BUILD THE GUI AND PARENT TO COREGUI
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FreecamGUI"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 9999
screenGui.ResetOnSpawn   = false
screenGui.Parent         = CoreGui      -- Attempt to parent into CoreGui

-- Toggle Button (Top-Left)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name             = "ToggleFreecam"
toggleBtn.Size             = UDim2.new(0, 100, 0, 40)
toggleBtn.Position         = UDim2.new(0, 10, 0, 10)
toggleBtn.Text             = "Freecam"
toggleBtn.Font             = Enum.Font.SourceSansBold
toggleBtn.TextSize         = 18
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent           = screenGui

-- Screenshot Button (Top-Right)
local screenshotBtn = Instance.new("TextButton")
screenshotBtn.Name             = "ScreenshotBtn"
screenshotBtn.Size             = UDim2.new(0, 100, 0, 40)
screenshotBtn.Position         = UDim2.new(1, -110, 0, 10)
screenshotBtn.Text             = "📸 Capture"
screenshotBtn.Font             = Enum.Font.SourceSansBold
screenshotBtn.TextSize         = 18
screenshotBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
screenshotBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
screenshotBtn.Visible          = false
screenshotBtn.Parent           = screenGui

-- Movement buttons
local function createDirButton(name, label, positionUDim)
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.new(0, 50, 0, 50)
    btn.Position         = positionUDim
    btn.Text             = label
    btn.Font             = Enum.Font.SourceSansBold
    btn.TextSize         = 24
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Visible          = false
    btn.Parent           = screenGui
    return btn
end

local btnForward  = createDirButton("BtnForward",  "↑",  UDim2.new(0,  60, 1, -160))
local btnBackward = createDirButton("BtnBackward", "↓",  UDim2.new(0,  60, 1, - 90))
local btnLeft     = createDirButton("BtnLeft",     "←",  UDim2.new(0,  10, 1, -125))
local btnRight    = createDirButton("BtnRight",    "→",  UDim2.new(0, 110, 1, -125))
local btnUp       = createDirButton("BtnUp",       "Up", UDim2.new(1, -110, 1, -160))
local btnDown     = createDirButton("BtnDown",     "Dn", UDim2.new(1, -110, 1, - 90))

-- Look buttons
local lookUp    = createDirButton("LookUp",    "LU", UDim2.new(0,  60, 1, -240))
local lookDown  = createDirButton("LookDown",  "LD", UDim2.new(0,  60, 1, -310))
local lookLeft  = createDirButton("LookLeft",  "LL", UDim2.new(0,  10, 1, -275))
local lookRight = createDirButton("LookRight", "LR", UDim2.new(0, 110, 1, -275))

-- Speed Label & Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Name             = "SpeedLabel"
speedLabel.Size             = UDim2.new(0, 120, 0, 25)
speedLabel.Position         = UDim2.new(0.5, -60, 1, -60)
speedLabel.Text             = "Speed: 16"
speedLabel.Parent           = screenGui

local speedSlider = Instance.new("TextButton")
speedSlider.Name             = "SpeedSlider"
speedSlider.Size             = UDim2.new(0, 200, 0, 30)
speedSlider.Position         = UDim2.new(0.5, -100, 1, -30)
speedSlider.Parent           = screenGui

local speedKnob = Instance.new("Frame")
speedKnob.Name             = "SpeedKnob"
speedKnob.Size             = UDim2.new(0, 20, 1, 0)
speedKnob.Position         = UDim2.new((16 - 8)/56, 0, 0, 0)
speedKnob.Parent           = speedSlider

-- FOV Label & Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Name             = "FOVLabel"
fovLabel.Size             = UDim2.new(0, 120, 0, 25)
fovLabel.Position         = UDim2.new(0.5, -60, 1, -120)
fovLabel.Text             = "FOV: " .. math.floor(camera.FieldOfView)
fovLabel.Parent           = screenGui

local fovSlider = Instance.new("TextButton")
fovSlider.Name             = "FOVSlider"
fovSlider.Size             = UDim2.new(0, 200, 0, 30)
fovSlider.Position         = UDim2.new(0.5, -100, 1, -90)
fovSlider.Parent           = screenGui

local fovKnob = Instance.new("Frame")
fovKnob.Name             = "FOVKnob"
fovKnob.Size             = UDim2.new(0, 20, 1, 0)
fovKnob.Position         = UDim2.new((camera.FieldOfView - 40)/80, 0, 0, 0)
fovKnob.Parent           = fovSlider

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (3) STATE VARIABLES
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamEnabled = false
local moveState      = {Forward=false,Backward=false,Left=false,Right=false,Up=false,Down=false}
local lookState      = {Up=false,Down=false,Left=false,Right=false}
local speedValue     = 16
local yaw, pitch     = 0, 0
local camPosition    = camera.CFrame.Position
local origWalkSpeed, origJumpPower
local lookSpeed = math.rad(60)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (4) SHOW/HIDE UI HELPER
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local function setUIVisibility(on)
    for _,b in ipairs({btnForward,btnBackward,btnLeft,btnRight,btnUp,btnDown,lookUp,lookDown,lookLeft,lookRight}) do
        b.Visible = on
    end
    screenshotBtn.Visible = on
    speedLabel.Visible   = on
    speedSlider.Visible  = on
    fovLabel.Visible     = on
    fovSlider.Visible    = on
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (5) TOGGLE FREECAM
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

toggleBtn.MouseButton1Click:Connect(function()
    freecamEnabled = not freecamEnabled
    toggleBtn.Text = freecamEnabled and "Exit Cam" or "Freecam"
    setUIVisibility(freecamEnabled)

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

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
-- (6) CONNECT BUTTON STATES
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local function connectState(btn, tbl, key)
    btn.InputBegan:Connect(function(i) if freecamEnabled then tbl[key]=true end end)
    btn.InputEnded:Connect(function(i) if freecamEnabled then tbl[key]=false end end)
end

for k,v in pairs({Forward=btnForward,Backward=btnBackward,Left=btnLeft,Right=btnRight,Up=btnUp,Down=btnDown}) do
    connectState(v, moveState, k)
end
for k,v in pairs({Up=lookUp,Down=lookDown,Left=lookLeft,Right=lookRight}) do
    connectState(v, lookState, k)
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (7) SLIDER LOGIC
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local draggingSpeed, draggingFOV=false,false

speedSlider.InputBegan:Connect(function(i) if freecamEnabled then draggingSpeed=true end end)
fovSlider.InputBegan:Connect(function(i) if freecamEnabled then draggingFOV=true end end)

UserInput.InputChanged:Connect(function(i)
    if freecamEnabled and draggingSpeed then
        local rel = math.clamp((i.Position.X-speedSlider.AbsolutePosition.X)/speedSlider.AbsoluteSize.X,0,1)
        speedValue=math.floor(8+rel*56)
        speedKnob.Position=UDim2.new((speedValue-8)/56,0,0,0)
        speedLabel.Text="Speed: "..speedValue
    end
    if freecamEnabled and draggingFOV then
        local rel = math.clamp((i.Position.X-fovSlider.AbsolutePosition.X)/fovSlider.AbsoluteSize.X,0,1)
        local newFOV=math.floor(40+rel*80)
        camera.FieldOfView=newFOV
        fovKnob.Position=UDim2.new((newFOV-40)/80,0,0,0)
        fovLabel.Text="FOV: "..newFOV
    end
end)

UserInput.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingSpeed=false
        draggingFOV=false
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (8) UPDATE CAMERA EACH FRAME
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

RunService.RenderStepped:Connect(function(dt)
    if not freecamEnabled then return end

    -- Movement
    local fwd=Vector3.new(-math.sin(yaw),0,-math.cos(yaw))
    local right=Vector3.new(math.cos(yaw),0,-math.sin(yaw))
    local up=Vector3.new(0,1,0)
    local move=Vector3.new()
    if moveState.Forward then move=move+fwd end
    if moveState.Backward then move=move-fwd end
    if moveState.Right then move=move+right end
    if moveState.Left then move=move-right end
    if moveState.Up then move=move+up end
    if moveState.Down then move=move-up end
    if move.Magnitude>0 then
        camPosition=camPosition+move.Unit*speedValue*dt
    end

    -- Look buttons
    if lookState.Up    then pitch=math.clamp(pitch-lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Down  then pitch=math.clamp(pitch+lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Left  then yaw=yaw-lookSpeed*dt end
    if lookState.Right then yaw=yaw+lookSpeed*dt end

    camera.CFrame=CFrame.new(camPosition)*CFrame.Angles(pitch,yaw,0)
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (9) SCREENSHOT LOGIC
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

screenshotBtn.MouseButton1Click:Connect(function()
    if not freecamEnabled then return end

    screenGui.Enabled = false
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
    task.wait(0.1)

    CaptureService:CaptureScreenshot(function(id)
        screenGui.Enabled = true
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
        CaptureService:PromptSaveCapturesToGallery({id},function(res)
            -- popup logic omitted for brevity
        end)
    end)
end)-- LocalScript (place under StarterPlayer → StarterPlayerScripts)

local Players        = game:GetService("Players")
local UserInput      = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CaptureService = game:GetService("CaptureService")
local StarterGui     = game:GetService("StarterGui")
local CoreGui        = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (1) BUILD (OR FIND) THE INVISIBLE “FREECAM PART”
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamPart = workspace:FindFirstChild("FreecamPart")
if not freecamPart then
    freecamPart = Instance.new("Part")
    freecamPart.Name         = "FreecamPart"
    freecamPart.Size         = Vector3.new(1, 1, 1)
    freecamPart.Anchored     = true
    freecamPart.CanCollide   = false
    freecamPart.Transparency = 1
    freecamPart.Parent       = workspace
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (2) BUILD THE GUI AND PARENT TO COREGUI
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FreecamGUI"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 9999
screenGui.ResetOnSpawn   = false
screenGui.Parent         = CoreGui      -- Attempt to parent into CoreGui

-- Toggle Button (Top-Left)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name             = "ToggleFreecam"
toggleBtn.Size             = UDim2.new(0, 100, 0, 40)
toggleBtn.Position         = UDim2.new(0, 10, 0, 10)
toggleBtn.Text             = "Freecam"
toggleBtn.Font             = Enum.Font.SourceSansBold
toggleBtn.TextSize         = 18
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.Parent           = screenGui

-- Screenshot Button (Top-Right)
local screenshotBtn = Instance.new("TextButton")
screenshotBtn.Name             = "ScreenshotBtn"
screenshotBtn.Size             = UDim2.new(0, 100, 0, 40)
screenshotBtn.Position         = UDim2.new(1, -110, 0, 10)
screenshotBtn.Text             = "📸 Capture"
screenshotBtn.Font             = Enum.Font.SourceSansBold
screenshotBtn.TextSize         = 18
screenshotBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
screenshotBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
screenshotBtn.Visible          = false
screenshotBtn.Parent           = screenGui

-- Movement buttons
local function createDirButton(name, label, positionUDim)
    local btn = Instance.new("TextButton")
    btn.Name             = name
    btn.Size             = UDim2.new(0, 50, 0, 50)
    btn.Position         = positionUDim
    btn.Text             = label
    btn.Font             = Enum.Font.SourceSansBold
    btn.TextSize         = 24
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Visible          = false
    btn.Parent           = screenGui
    return btn
end

local btnForward  = createDirButton("BtnForward",  "↑",  UDim2.new(0,  60, 1, -160))
local btnBackward = createDirButton("BtnBackward", "↓",  UDim2.new(0,  60, 1, - 90))
local btnLeft     = createDirButton("BtnLeft",     "←",  UDim2.new(0,  10, 1, -125))
local btnRight    = createDirButton("BtnRight",    "→",  UDim2.new(0, 110, 1, -125))
local btnUp       = createDirButton("BtnUp",       "Up", UDim2.new(1, -110, 1, -160))
local btnDown     = createDirButton("BtnDown",     "Dn", UDim2.new(1, -110, 1, - 90))

-- Look buttons
local lookUp    = createDirButton("LookUp",    "LU", UDim2.new(0,  60, 1, -240))
local lookDown  = createDirButton("LookDown",  "LD", UDim2.new(0,  60, 1, -310))
local lookLeft  = createDirButton("LookLeft",  "LL", UDim2.new(0,  10, 1, -275))
local lookRight = createDirButton("LookRight", "LR", UDim2.new(0, 110, 1, -275))

-- Speed Label & Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Name             = "SpeedLabel"
speedLabel.Size             = UDim2.new(0, 120, 0, 25)
speedLabel.Position         = UDim2.new(0.5, -60, 1, -60)
speedLabel.Text             = "Speed: 16"
speedLabel.Parent           = screenGui

local speedSlider = Instance.new("TextButton")
speedSlider.Name             = "SpeedSlider"
speedSlider.Size             = UDim2.new(0, 200, 0, 30)
speedSlider.Position         = UDim2.new(0.5, -100, 1, -30)
speedSlider.Parent           = screenGui

local speedKnob = Instance.new("Frame")
speedKnob.Name             = "SpeedKnob"
speedKnob.Size             = UDim2.new(0, 20, 1, 0)
speedKnob.Position         = UDim2.new((16 - 8)/56, 0, 0, 0)
speedKnob.Parent           = speedSlider

-- FOV Label & Slider
local fovLabel = Instance.new("TextLabel")
fovLabel.Name             = "FOVLabel"
fovLabel.Size             = UDim2.new(0, 120, 0, 25)
fovLabel.Position         = UDim2.new(0.5, -60, 1, -120)
fovLabel.Text             = "FOV: " .. math.floor(camera.FieldOfView)
fovLabel.Parent           = screenGui

local fovSlider = Instance.new("TextButton")
fovSlider.Name             = "FOVSlider"
fovSlider.Size             = UDim2.new(0, 200, 0, 30)
fovSlider.Position         = UDim2.new(0.5, -100, 1, -90)
fovSlider.Parent           = screenGui

local fovKnob = Instance.new("Frame")
fovKnob.Name             = "FOVKnob"
fovKnob.Size             = UDim2.new(0, 20, 1, 0)
fovKnob.Position         = UDim2.new((camera.FieldOfView - 40)/80, 0, 0, 0)
fovKnob.Parent           = fovSlider

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (3) STATE VARIABLES
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecamEnabled = false
local moveState      = {Forward=false,Backward=false,Left=false,Right=false,Up=false,Down=false}
local lookState      = {Up=false,Down=false,Left=false,Right=false}
local speedValue     = 16
local yaw, pitch     = 0, 0
local camPosition    = camera.CFrame.Position
local origWalkSpeed, origJumpPower
local lookSpeed = math.rad(60)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (4) SHOW/HIDE UI HELPER
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local function setUIVisibility(on)
    for _,b in ipairs({btnForward,btnBackward,btnLeft,btnRight,btnUp,btnDown,lookUp,lookDown,lookLeft,lookRight}) do
        b.Visible = on
    end
    screenshotBtn.Visible = on
    speedLabel.Visible   = on
    speedSlider.Visible  = on
    fovLabel.Visible     = on
    fovSlider.Visible    = on
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (5) TOGGLE FREECAM
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

toggleBtn.MouseButton1Click:Connect(function()
    freecamEnabled = not freecamEnabled
    toggleBtn.Text = freecamEnabled and "Exit Cam" or "Freecam"
    setUIVisibility(freecamEnabled)

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

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
-- (6) CONNECT BUTTON STATES
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local function connectState(btn, tbl, key)
    btn.InputBegan:Connect(function(i) if freecamEnabled then tbl[key]=true end end)
    btn.InputEnded:Connect(function(i) if freecamEnabled then tbl[key]=false end end)
end

for k,v in pairs({Forward=btnForward,Backward=btnBackward,Left=btnLeft,Right=btnRight,Up=btnUp,Down=btnDown}) do
    connectState(v, moveState, k)
end
for k,v in pairs({Up=lookUp,Down=lookDown,Left=lookLeft,Right=lookRight}) do
    connectState(v, lookState, k)
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (7) SLIDER LOGIC
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local draggingSpeed, draggingFOV=false,false

speedSlider.InputBegan:Connect(function(i) if freecamEnabled then draggingSpeed=true end end)
fovSlider.InputBegan:Connect(function(i) if freecamEnabled then draggingFOV=true end end)

UserInput.InputChanged:Connect(function(i)
    if freecamEnabled and draggingSpeed then
        local rel = math.clamp((i.Position.X-speedSlider.AbsolutePosition.X)/speedSlider.AbsoluteSize.X,0,1)
        speedValue=math.floor(8+rel*56)
        speedKnob.Position=UDim2.new((speedValue-8)/56,0,0,0)
        speedLabel.Text="Speed: "..speedValue
    end
    if freecamEnabled and draggingFOV then
        local rel = math.clamp((i.Position.X-fovSlider.AbsolutePosition.X)/fovSlider.AbsoluteSize.X,0,1)
        local newFOV=math.floor(40+rel*80)
        camera.FieldOfView=newFOV
        fovKnob.Position=UDim2.new((newFOV-40)/80,0,0,0)
        fovLabel.Text="FOV: "..newFOV
    end
end)

UserInput.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingSpeed=false
        draggingFOV=false
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (8) UPDATE CAMERA EACH FRAME
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

RunService.RenderStepped:Connect(function(dt)
    if not freecamEnabled then return end

    -- Movement
    local fwd=Vector3.new(-math.sin(yaw),0,-math.cos(yaw))
    local right=Vector3.new(math.cos(yaw),0,-math.sin(yaw))
    local up=Vector3.new(0,1,0)
    local move=Vector3.new()
    if moveState.Forward then move=move+fwd end
    if moveState.Backward then move=move-fwd end
    if moveState.Right then move=move+right end
    if moveState.Left then move=move-right end
    if moveState.Up then move=move+up end
    if moveState.Down then move=move-up end
    if move.Magnitude>0 then
        camPosition=camPosition+move.Unit*speedValue*dt
    end

    -- Look buttons
    if lookState.Up    then pitch=math.clamp(pitch-lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Down  then pitch=math.clamp(pitch+lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Left  then yaw=yaw-lookSpeed*dt end
    if lookState.Right then yaw=yaw+lookSpeed*dt end

    camera.CFrame=CFrame.new(camPosition)*CFrame.Angles(pitch,yaw,0)
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- (9) SCREENSHOT LOGIC
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

screenshotBtn.MouseButton1Click:Connect(function()
    if not freecamEnabled then return end

    screenGui.Enabled = false
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
    task.wait(0.1)

    CaptureService:CaptureScreenshot(function(id)
        screenGui.Enabled = true
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
        CaptureService:PromptSaveCapturesToGallery({id},function(res)
            -- popup logic omitted for brevity
        end)
    end)
end)
