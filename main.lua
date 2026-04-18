local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local Config = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.F3,
    AimbotSmoothing = 0.15,
    TracerColor = Color3.fromRGB(0, 255, 255), -- Cyan for visibility
    LineThickness = 1
}

-- Create Tracer Object
local Tracer = Drawing.new("Line")
Tracer.Visible = false
Tracer.Thickness = Config.LineThickness
Tracer.Color = Config.TracerColor
Tracer.Transparency = 1

-- Toggle Logic
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Config.ToggleKey then
        Config.Enabled = not Config.Enabled
        if not Config.Enabled then Tracer.Visible = false end
    end
end)

local function getClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if magnitude < dist then
                    target = v.Character.HumanoidRootPart
                    dist = magnitude
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    
    local target = getClosestPlayer()
    
    if target then
        local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
        
        if onScreen then
            -- 1. ESP Tracer Logic (From Bottom Center to Enemy)
            Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            Tracer.Visible = true
            
            -- 2. Invis Aimbot Logic (Smooth Camera Correction)
            local aimPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(aimPos, Config.AimbotSmoothing)
        else
            Tracer.Visible = false
        end
    else
        Tracer.Visible = false
    end
end)
