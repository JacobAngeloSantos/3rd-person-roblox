local Players = game:GetService("Players")

-- Time between each sword swing
local SWING_INTERVAL = 0.5

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") then
				local swing = true

				tool.Unequipped:Connect(function()
					swing = false
				end)

				-- Start auto-swing loop
				task.spawn(function()
					while tool.Parent == character and swing do
						if tool:FindFirstChild("Activate") then
							tool:Activate()
						end
						task.wait(SWING_INTERVAL)
					end
				end)
			end
		end)
	end)
end)
