local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local LOCAL_PLAYER = Players.LocalPlayer
local CHARACTER = LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait()
local ROOT = CHARACTER:WaitForChild("HumanoidRootPart")

local MAX_DISTANCE = 200

-- Toggles
local tracersEnabled = true
local boxesEnabled = true

-- KEYBINDS (F3 / F4)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F3 then
        tracersEnabled = not tracersEnabled
        print("Tracers:", tracersEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        boxesEnabled = not boxesEnabled
        print("Boxes:", boxesEnabled and "ON" or "OFF")
    end
end)

-- Get closest target
local function getClosestTarget(origin)
    local closest = nil
    local shortest = MAX_DISTANCE

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LOCAL_PLAYER and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local dist = (hrp.Position - origin).Magnitude

            if dist < shortest then
                shortest = dist
                closest = player.Character
            end
        end
    end

    return closest
end

-- Instant snap aim
local function snapAim(part, targetPos)
    part.CFrame = CFrame.new(part.Position, targetPos)
end

-- Highlight (box)
local function applyHighlight(character)
    if character:FindFirstChild("TargetHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TargetHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Adornee = character
    highlight.Parent = character
end

-- Tracer
local function createTracer(startPos, endPos)
    local p0 = Instance.new("Part")
    p0.Anchored = true
    p0.CanCollide = false
    p0.Transparency = 1
    p0.Position = startPos
    p0.Parent = workspace

    local p1 = p0:Clone()
    p1.Position = endPos
    p1.Parent = workspace

    local a0 = Instance.new("Attachment", p0)
    local a1 = Instance.new("Attachment", p1)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Parent = p0

    Debris:AddItem(p0, 0.1)
    Debris:AddItem(p1, 0.1)
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local targetChar = getClosestTarget(ROOT.Position)

    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetChar.HumanoidRootPart

        -- Always-on snap aim
        snapAim(ROOT, targetHRP.Position)

        -- Box toggle
        if boxesEnabled then
            applyHighlight(targetChar)
        end

        -- Tracer toggle
        if tracersEnabled then
            createTracer(ROOT.Position, targetHRP.Position)
        end
    end
end)
