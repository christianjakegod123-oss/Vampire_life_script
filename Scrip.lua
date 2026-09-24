local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local TP1 = CFrame.new(-471.13, 32.88, 14.91)
local TP2 = CFrame.new(546.43, 31.75, -733.14)
local QZ = CFrame.new(-227.03, 26.39, 390.05)
local SAFE = CFrame.new(2.84, -92.28, -123.06)

local autoHunter = false
local safeMode = false
local safeTriggered = false

local gui = Instance.new("ScreenGui")
gui.Name = "HunterHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0,230,0,270)
main.Position = UDim2.new(0.5,-115,0.5,-135)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner",main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,0,40)
title.Position = UDim2.new(0,5,0,0)
title.BackgroundTransparency = 1
title.Text = "HUNTER HUB"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.BackgroundColor3 = Color3.fromRGB(180,50,50)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.Parent = main

Instance.new("UICorner",close).CornerRadius = UDim.new(0,7)

local function makeButton(text,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Parent = main

    Instance.new("UICorner",b).CornerRadius = UDim.new(0,7)

    return b
end

local tp1 = makeButton("TP 1",45)
local tp2 = makeButton("TP 2",88)
local qz = makeButton("QUEST / QZ HUNTER",131)
local hunter = makeButton("AUTO HUNTER: OFF",174)
local closeButton = makeButton("CLOSE",217)

local open = Instance.new("TextButton")
open.Size = UDim2.new(0,80,0,38)
open.Position = UDim2.new(0,15,0,200)
open.BackgroundColor3 = Color3.fromRGB(45,45,45)
open.Text = "OPEN"
open.TextColor3 = Color3.new(1,1,1)
open.TextSize = 14
open.Font = Enum.Font.GothamBold
open.Visible = false
open.Parent = gui

Instance.new("UICorner",open).CornerRadius = UDim.new(0,8)

local function teleport(cf)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.CFrame = cf
    end
end

tp1.MouseButton1Click:Connect(function()
    teleport(TP1)
end)

tp2.MouseButton1Click:Connect(function()
    teleport(TP2)
end)

qz.MouseButton1Click:Connect(function()
    teleport(QZ)
end)

local function findHunter()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
        and obj.Name:lower() == "hunter" then

            local root = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                return obj
            end
        end
    end

    return nil
end

hunter.MouseButton1Click:Connect(function()
    autoHunter = not autoHunter

    if autoHunter then
        hunter.Text = "AUTO HUNTER: ON"
        hunter.BackgroundColor3 = Color3.fromRGB(40,140,70)
    else
        hunter.Text = "AUTO HUNTER: OFF"
        hunter.BackgroundColor3 = Color3.fromRGB(55,55,55)
    end
end)

RunService.Heartbeat:Connect(function()

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not hum then
        return
    end

    if hum.MaxHealth <= 0 then
        return
    end

    local hp = hum.Health / hum.MaxHealth

    -- AUTO SAFE ZONE AT 30% HP
    if hp <= 0.30 and not safeMode then

        safeMode = true
        safeTriggered = true

        -- SAFE ZONE 4X
        for i = 1,4 do
            if root and root.Parent then
                root.CFrame = SAFE
            end
            task.wait(0.08)
        end

    end

    -- STAY IN SAFE ZONE UNTIL FULL HP
    if safeMode then

        root.CFrame = SAFE

        -- FULL HP = RETURN TO HUNTER
        if hp >= 1 then
            safeMode = false
            safeTriggered = false
        else
            return
        end
    end

    -- AUTO HUNTER
    if autoHunter then

        local target = findHunter()

        if target then

            local targetRoot =
                target:FindFirstChild("HumanoidRootPart")

            if targetRoot then

                hum.AutoRotate = false

                root.CFrame =
                    targetRoot.CFrame * CFrame.new(0,0,6.99)

            end
        end
    end
end)

-- CLOSE
local function hideGui()
    main.Visible = false
    open.Visible = true
end

close.MouseButton1Click:Connect(hideGui)
closeButton.MouseButton1Click:Connect(hideGui)

-- OPEN
open.MouseButton1Click:Connect(function()
    main.Visible = true
    open.Visible = false
end)

-- DRAG
local dragging = false
local dragStart = nil
local startPosition = nil

title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false

    end
end)
