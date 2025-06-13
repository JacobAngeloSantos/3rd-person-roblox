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
-- 2) Build GUI
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "FreecamGUI"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder   = 9999
screenGui.ResetOnSpawn   = false
screenGui.Parent         = CoreGui  -- attempt CoreGui

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

-- Screenshot Button
local screenshotBtn = Instance.new("TextButton", screenGui)
screenshotBtn.Size             = UDim2.new(0,100,0,40)
screenshotBtn.Position         = UDim2.new(1,-110,0,10)
screenshotBtn.Text             = "📸 Capture"
screenshotBtn.Font             = Enum.Font.SourceSansBold
screenshotBtn.TextSize         = 18
screenshotBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
screenshotBtn.TextColor3       = Color3.new(1,1,1)
screenshotBtn.Visible          = false

-- Movement buttons
local function createBtn(name,label,pos)
    local b=Instance.new("TextButton",screenGui)
    b.Name=name; b.Size=UDim2.new(0,50,0,50); b.Position=pos
    b.Text=label; b.Font=Enum.Font.SourceSansBold; b.TextSize=24
    b.BackgroundColor3=Color3.fromRGB(60,60,60); b.TextColor3=Color3.new(1,1,1)
    b.Visible=false
    return b
end

local btnForward  = createBtn("BtnForward","↑",  UDim2.new(0,60,1,-160))
local btnBackward = createBtn("BtnBackward","↓",UDim2.new(0,60,1,-90))
local btnLeft     = createBtn("BtnLeft","←",      UDim2.new(0,10,1,-125))
local btnRight    = createBtn("BtnRight","→",     UDim2.new(0,110,1,-125))
local btnUp       = createBtn("BtnUp","Up",        UDim2.new(1,-110,1,-160))
local btnDown     = createBtn("BtnDown","Dn",      UDim2.new(1,-110,1,-90))

-- Look buttons
local lookUp    = createBtn("LookUp","LU",    UDim2.new(0,60,1,-240))
local lookDown  = createBtn("LookDown","LD",  UDim2.new(0,60,1,-310))
local lookLeft  = createBtn("LookLeft","LL",  UDim2.new(0,10,1,-275))
local lookRight = createBtn("LookRight","LR", UDim2.new(0,110,1,-275))

-- Speed slider
local speedLabel=Instance.new("TextLabel",screenGui)
speedLabel.Size=UDim2.new(0,120,0,25); speedLabel.Position=UDim2.new(0.5,-60,1,-60)
speedLabel.Text="Speed: 16"; speedLabel.Font=Enum.Font.SourceSans; speedLabel.TextSize=18
speedLabel.BackgroundColor3=Color3.fromRGB(30,30,30); speedLabel.TextColor3=Color3.new(1,1,1)
speedLabel.Visible=false

local speedSlider=Instance.new("TextButton",screenGui)
speedSlider.Size=UDim2.new(0,200,0,30); speedSlider.Position=UDim2.new(0.5,-100,1,-30)
speedSlider.BackgroundColor3=Color3.fromRGB(100,100,100); speedSlider.Visible=false
local speedKnob=Instance.new("Frame",speedSlider)
speedKnob.Size=UDim2.new(0,20,1,0); speedKnob.Position=UDim2.new((16-8)/56,0,0,0)
speedKnob.BackgroundColor3=Color3.new(1,1,1)

-- FOV slider
local fovLabel=Instance.new("TextLabel",screenGui)
fovLabel.Size=UDim2.new(0,120,0,25); fovLabel.Position=UDim2.new(0.5,-60,1,-120)
fovLabel.Text="FOV: "..math.floor(camera.FieldOfView)
fovLabel.Font=Enum.Font.SourceSans; fovLabel.TextSize=18
fovLabel.BackgroundColor3=Color3.fromRGB(30,30,30); fovLabel.TextColor3=Color3.new(1,1,1)
fovLabel.Visible=false

local fovSlider=Instance.new("TextButton",screenGui)
fovSlider.Size=UDim2.new(0,200,0,30); fovSlider.Position=UDim2.new(0.5,-100,1,-90)
fovSlider.BackgroundColor3=Color3.fromRGB(100,100,100); fovSlider.Visible=false
local fovKnob=Instance.new("Frame",fovSlider)
fovKnob.Size=UDim2.new(0,20,1,0); fovKnob.Position=UDim2.new((camera.FieldOfView-40)/80,0,0,0)
fovKnob.BackgroundColor3=Color3.new(1,1,1)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 3) State
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local freecam=false
local moveState={Forward=false,Backward=false,Left=false,Right=false,Up=false,Down=false}
local lookState={Up=false,Down=false,Left=false,Right=false}
local speed=16
local yaw,pitch=camera.CFrame:ToEulerAnglesYXZ()
local camPos=camera.CFrame.Position
local origWS,origJP
local lookSpeed=math.rad(60)
local draggingSpeed,draggingFOV=false,false

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 4) Show/Hide UI
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

local function toggleUI(on)
    for _,b in ipairs({btnForward,btnBackward,btnLeft,btnRight,btnUp,btnDown,lookUp,lookDown,lookLeft,lookRight}) do
        b.Visible=on
    end
    toggleBtn.Visible=true
    teleportBtn.Visible=on
    screenshotBtn.Visible=on
    speedLabel.Visible=on
    speedSlider.Visible=on
    fovLabel.Visible=on
    fovSlider.Visible=on
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 5) Toggle Freecam
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

toggleBtn.MouseButton1Click:Connect(function()
    freecam=not freecam
    toggleBtn.Text=freecam and "Exit Cam" or "Freecam"
    toggleUI(freecam)
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if freecam then
        local cf=camera.CFrame
        camPos, yaw, pitch = cf.Position, cf:ToEulerAnglesYXZ()
        camera.CameraType=Enum.CameraType.Scriptable
        if hum then origWS,origJP=hum.WalkSpeed,hum.JumpPower; hum.WalkSpeed,hum.JumpPower=0,0 end
    else
        camera.CameraType=Enum.CameraType.Custom
        if hum and origWS then hum.WalkSpeed,hum.JumpPower=origWS,origJP end
    end
end)

--–– connect movement & look buttons ––

local function bind(b,t,state)
    b.InputBegan:Connect(function(i) if freecam then state[t]=true end end)
    b.InputEnded:Connect(function(i) if freecam then state[t]=false end end)
end
for k,b in pairs({Forward=btnForward,Backward=btnBackward,Left=btnLeft,Right=btnRight,Up=btnUp,Down=btnDown}) do
    bind(b,k,moveState)
end
for k,b in pairs({Up=lookUp,Down=lookDown,Left=lookLeft,Right=lookRight}) do
    bind(b,k,lookState)
end

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 6) Sliders
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

speedSlider.InputBegan:Connect(function(i) if freecam then draggingSpeed=true end end)
fovSlider.InputBegan:Connect(function(i) if freecam then draggingFOV=true end end)

UserInput.InputChanged:Connect(function(i)
    if freecam and draggingSpeed then
        local rel=(i.Position.X-speedSlider.AbsolutePosition.X)/speedSlider.AbsoluteSize.X
        speed=math.floor(8+math.clamp(rel,0,1)*56)
        speedKnob.Position=UDim2.new((speed-8)/56,0,0,0)
        speedLabel.Text="Speed: "..speed
    end
    if freecam and draggingFOV then
        local rel=(i.Position.X-fovSlider.AbsolutePosition.X)/fovSlider.AbsoluteSize.X
        local f=math.floor(40+math.clamp(rel,0,1)*80)
        camera.FieldOfView=f
        fovKnob.Position=UDim2.new((f-40)/80,0,0,0)
        fovLabel.Text="FOV: "..f
    end
end)

UserInput.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingSpeed=false; draggingFOV=false
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 7) Teleport
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

teleportBtn.MouseButton1Click:Connect(function()
    if not freecam then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(camPos) * CFrame.Angles(0,yaw,0)
    end
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 8) Screenshot
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

screenshotBtn.MouseButton1Click:Connect(function()
    if not freecam then return end
    screenGui.Enabled=false
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
    task.wait(0.1)
    CaptureService:CaptureScreenshot(function(id)
        screenGui.Enabled=true
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
        CaptureService:PromptSaveCapturesToGallery({id},function(res) end)
    end)
end)

--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
-- 9) RunService – move + look
--––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

RunService.RenderStepped:Connect(function(dt)
    if not freecam then return end
    -- movement
    local fwd=Vector3.new(-math.sin(yaw),0,-math.cos(yaw))
    local rt=Vector3.new(math.cos(yaw),0,-math.sin(yaw))
    local up=Vector3.new(0,1,0)
    local mv=Vector3.new()
    if moveState.Forward then mv+=fwd end
    if moveState.Backward then mv-=fwd end
    if moveState.Right then mv+=rt end
    if moveState.Left then mv-=rt end
    if moveState.Up then mv+=up end
    if moveState.Down then mv-=up end
    if mv.Magnitude>0 then camPos+=mv.Unit*speed*dt end
    -- look buttons
    if lookState.Up    then pitch=math.clamp(pitch-lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Down  then pitch=math.clamp(pitch+lookSpeed*dt,-math.pi/2,math.pi/2) end
    if lookState.Left  then yaw-=lookSpeed*dt end
    if lookState.Right then yaw+=lookSpeed*dt end
    -- apply
    camera.CFrame=CFrame.new(camPos)*CFrame.Angles(pitch,yaw,0)
end)
