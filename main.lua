-- CaliXtro Project: Stable Aimbot + ESP
-- Optimized for Xeno & 2GB RAM

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Enabled = true,
    FOV = 150,
    ShowBox = true,
    ShowTracer = true,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(0, 255, 255)
}

-- Storage for drawing objects
local ESP = {}

local function createESP(player)
    local tracer = Drawing.new("Line")
    local box = Drawing.new("Square") -- Re-initializing for stability
    
    tracer.Thickness = 1
    tracer.Color = Config.TracerColor
    
    box.Thickness = 1
    box.Color = Config.BoxColor
    box.Filled = false
    
    ESP[player] = {Tracer = tracer, Box = box}
end

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        ESP[p].Tracer:Remove()
        ESP[p].Box:Remove()
        ESP[p] = nil
    end
end)

local function getTarget()
    local target = nil
    local dist = Config.FOV
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local hrp = v.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                
                if mag < dist then
                    target = hrp
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local target = getTarget()
    
    -- Aimbot Logic
    if target and Config.Enabled then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
    
    -- ESP Rendering Loop
    for player, drawings in pairs(ESP) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid").Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                -- BOX LOGIC (Corrected for Xeno)
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z
                
                drawings.Box.Visible = Config.ShowBox
                drawings.Box.Size = Vector2.new(sizeX, sizeY)
                drawings.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                
                -- TRACER LOGIC
                drawings.Tracer.Visible = Config.ShowTracer
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
            else
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
        end
    end
end)

-- Initialize for current players
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end endv
