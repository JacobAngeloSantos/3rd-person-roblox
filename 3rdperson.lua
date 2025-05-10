-- LocalScript (place in StarterPlayerScripts)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable

local cameraDistance = 10
local cameraHeight = 5
local minZoom, maxZoom = 5, 20
local rotationSpeed = 0.3

local yaw = 0
local rotating = false
local lastMousePosition = Vector2.zero

-- Input handlers
UserInputService.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
		rotating = true
		lastMousePosition = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
		rotating = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if rotating and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - lastMousePosition
		yaw = yaw - delta.X * rotationSpeed * 0.01
		lastMousePosition = input.Position
	elseif input.UserInputType == Enum.UserInputType.MouseWheel then
		cameraDistance = math.clamp(cameraDistance - input.Position.Z, minZoom, maxZoom)
	end
end)

-- Update camera position each frame
RunService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local direction = CFrame.new(Vector3.zero) * CFrame.Angles(0, yaw, 0)
		local offset = direction.LookVector * -cameraDistance + Vector3.new(0, cameraHeight, 0)
		camera.CFrame = CFrame.new(root.Position + offset, root.Position + Vector3.new(0, cameraHeight / 2, 0))
	end
end)
