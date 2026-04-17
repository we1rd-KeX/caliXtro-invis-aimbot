-- [[ CALIXTRO LIGHT AIM ASSIST ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- Settings (Low power)
local AssistRange = 500 -- Max distance
local Smoothness = 0.15 -- Lower = Snappier, Higher = More natural

local function getClosestPlayer()
    local closest = nil
    local shortestDist = AssistRange

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("Head") then
            -- Check if they are alive (Health > 0)
            local human = player.Character:FindFirstChild("Humanoid")
            if human and human.Health > 0 then
                local dist = (lp.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < shortestDist then
                    closest = player.Character.Head
                    shortestDist = dist
                end
            end
        end
    end
    return closest
end

-- The "Stealth" Loop
RunService.RenderStepped:Connect(function()
    -- Only assist if you are holding Right Click (Aiming)
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target then
            local cam = workspace.CurrentCamera
            local targetPos = CFrame.new(cam.CFrame.Position, target.Position)
            
            -- Smoothly rotate the camera toward the head
            cam.CFrame = cam.CFrame:Lerp(targetPos, Smoothness)
        end
    end
end)

print("CaliXtro: Aim Assist Loaded")
