--========================================================
-- SCRIPT_HUB
--========================================================
-- NOTE: This is plain Lua source text. No password or key system.
-- Intended for a Roblox experience you own/control.
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TP1 = CFrame.new(-471.13, 32.88, 14.91)
local TP2 = CFrame.new(546.43, 31.75, -733.14)
local QZ = CFrame.new(-227.03, 26.39, 390.05)

-- Combined TP: TP1 x6 -> stay 3s -> TP2 x6 -> stay 3s -> repeat
local TP_COUNT = 6
local TP_DELAY = 0.05
local STAY_TIME = 3
local CombinedTPEnabled = false
local TPVersion = 0

local function TeleportCombined(TargetCFrame)
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if Root then
        Root.CFrame = TargetCFrame
        return true
    end
    return false
end

local function WaitTP(MyVersion,Seconds)
    local EndTime = os.clock() + Seconds
    while os.clock() < EndTime do
        if not CombinedTPEnabled or MyVersion ~= TPVersion then return false end
        task.wait(0.03)
    end
    return true
end

local function SpamTP(TargetCFrame,MyVersion)
    for _ = 1,TP_COUNT do
        if not CombinedTPEnabled or MyVersion ~= TPVersion then return false end
        TeleportCombined(TargetCFrame)
        task.wait(TP_DELAY)
    end
    return true
end

local function StartCombinedTP()
    TPVersion += 1
    local MyVersion = TPVersion
    task.spawn(function()
        while CombinedTPEnabled and MyVersion == TPVersion do
            if not SpamTP(TP1,MyVersion) then return end
            if not WaitTP(MyVersion,STAY_TIME) then return end
            if not SpamTP(TP2,MyVersion) then return end
            if not WaitTP(MyVersion,STAY_TIME) then return end
        end
    end)
end

local function StopCombinedTP()
    CombinedTPEnabled = false
    TPVersion += 1
end
local SAFE = CFrame.new(2.84, -92.28, -123.06)

local AutoHunter = false
local AutoSafe = true
local SafeMode = false
local SelectedMin = 100
local SelectedMax = 700
local SelectedRange = "100-700"
local CurrentTarget = nil
local LastSearch = 0

local C = {
    Background = Color3.fromRGB(12,8,20),
    Panel = Color3.fromRGB(24,15,38),
    Panel2 = Color3.fromRGB(38,24,58),
    Purple = Color3.fromRGB(145,65,255),
    PurpleDark = Color3.fromRGB(88,35,165),
    Text = Color3.fromRGB(245,240,255),
    Muted = Color3.fromRGB(170,155,190),
    Green = Color3.fromRGB(45,185,95),
    Red = Color3.fromRGB(190,55,70)
}

local Old = PlayerGui:FindFirstChild("SCRIPT_HUB")
if Old then Old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SCRIPT_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(400,300)
Main.Position = UDim2.new(.5,-200,.5,-150)
Main.BackgroundColor3 = C.Background
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,14)

local Border = Instance.new("UIStroke")
Border.Color = C.Purple
Border.Thickness = 1.5
Border.Transparency = .25
Border.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,42)
Header.BackgroundColor3 = C.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner",Header).CornerRadius = UDim.new(0,14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-90,1,0)
Title.Position = UDim2.fromOffset(14,0)
Title.BackgroundTransparency = 1
Title.Text = "SCRIPT_HUB"
Title.TextColor3 = C.Text
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(32,30)
Close.Position = UDim2.new(1,-40,0,9)
Close.BackgroundColor3 = C.Red
Close.Text = "X"
Close.TextColor3 = C.Text
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.Parent = Header
Instance.new("UICorner",Close).CornerRadius = UDim.new(0,8)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,112,1,-50)
Sidebar.Position = UDim2.fromOffset(6,47)
Sidebar.BackgroundColor3 = C.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner",Sidebar).CornerRadius = UDim.new(0,10)

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1,-14,0,32)
Search.Position = UDim2.fromOffset(7,7)
Search.BackgroundColor3 = C.Panel2
Search.Text = ""
Search.PlaceholderText = "Search..."
Search.PlaceholderColor3 = C.Muted
Search.TextColor3 = C.Text
Search.TextSize = 12
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Sidebar
Instance.new("UICorner",Search).CornerRadius = UDim.new(0,7)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-126,1,-50)
Content.Position = UDim2.fromOffset(120,47)
Content.BackgroundColor3 = C.Panel
Content.BorderSizePixel = 0
Content.Parent = Main
Instance.new("UICorner",Content).CornerRadius = UDim.new(0,10)

local Pages, TabButtons = {}, {}

local function NewPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1,-16,1,-16)
    Page.Position = UDim2.fromOffset(8,8)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = C.Purple
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,7)
    Layout.Parent = Page
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y+15)
    end)

    Pages[name] = Page
    return Page
end

local function NewTab(name,icon,y)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-14,0,35)
    Button.Position = UDim2.fromOffset(7,y)
    Button.BackgroundColor3 = C.Panel
    Button.BorderSizePixel = 0
    Button.Text = icon.."  "..name
    Button.TextColor3 = C.Muted
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Sidebar
    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,7)

    local Page = NewPage(name)
    TabButtons[name] = Button

    Button.Activated:Connect(function()
        for _,p in pairs(Pages) do p.Visible = false end
        for _,b in pairs(TabButtons) do
            b.BackgroundColor3 = C.Panel
            b.TextColor3 = C.Muted
        end
        Page.Visible = true
        Button.BackgroundColor3 = C.PurpleDark
        Button.TextColor3 = C.Text
    end)

    return Page
end

local StatusPage = NewTab("Status","STATUS",48)
local SafePage = NewTab("Safe","SAFE",88)
local QuestPage = NewTab("Quest","QUEST",128)
local SettingsPage = NewTab("Settings","SETTINGS",168)

local function Section(Page,text)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,0,0,25)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = C.Purple
    L.TextSize = 12
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Page
end

local function Info(Page,text)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,0,0,40)
    L.BackgroundColor3 = C.Panel2
    L.Text = text
    L.TextColor3 = C.Text
    L.TextSize = 12
    L.Font = Enum.Font.Gotham
    L.Parent = Page
    Instance.new("UICorner",L).CornerRadius = UDim.new(0,8)
    return L
end

local function Button(Page,text)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,0,0,38)
    B.BackgroundColor3 = C.Panel2
    B.Text = text
    B.TextColor3 = C.Text
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.Parent = Page
    Instance.new("UICorner",B).CornerRadius = UDim.new(0,8)
    return B
end

local function Toggle(Page,text,initial,callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,0,0,40)
    B.BackgroundColor3 = C.Panel2
    B.Text = ""
    B.Parent = Page
    Instance.new("UICorner",B).CornerRadius = UDim.new(0,8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,-65,1,0)
    Label.Position = UDim2.fromOffset(12,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = C.Text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = B

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.fromOffset(38,20)
    Switch.Position = UDim2.new(1,-50,.5,-10)
    Switch.BackgroundColor3 = Color3.fromRGB(70,60,80)
    Switch.Parent = B
    Instance.new("UICorner",Switch).CornerRadius = UDim.new(1,0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.fromOffset(16,16)
    Dot.Position = UDim2.fromOffset(2,2)
    Dot.BackgroundColor3 = C.Text
    Dot.Parent = Switch
    Instance.new("UICorner",Dot).CornerRadius = UDim.new(1,0)

    local State = initial

    local function Refresh()
        if State then
            Switch.BackgroundColor3 = C.Purple
            Dot.Position = UDim2.new(1,-18,0,2)
        else
            Switch.BackgroundColor3 = Color3.fromRGB(70,60,80)
            Dot.Position = UDim2.fromOffset(2,2)
        end
        callback(State)
    end

    B.Activated:Connect(function()
        State = not State
        Refresh()
    end)

    Refresh()
end

Section(StatusPage,"HUNTER STATUS")
local StatusInfo = Info(StatusPage,"Hunter: OFF\nRange: 100-299")
Section(StatusPage,"TARGET")
local TargetInfo = Info(StatusPage,"Target: None")
Section(StatusPage,"PLAYER")
local HealthInfo = Info(StatusPage,"HP: --")

local function GetLevel(Model)
    for _,Name in ipairs({"Level","level","NPCLevel","NpcLevel","npcLevel"}) do
        local Value = Model:GetAttribute(Name)
        if typeof(Value) == "number" then return Value end
        if typeof(Value) == "string" then
            local N = tonumber(Value:match("%d+"))
            if N then return N end
        end
    end

    for _,Object in ipairs(Model:GetDescendants()) do
        if Object:IsA("IntValue") or Object:IsA("NumberValue") then
            local N = Object.Name:lower()
            if N:find("level") or N == "lv" or N == "lvl" then
                return tonumber(Object.Value)
            end
        end
    end

    for _,Object in ipairs(Model:GetDescendants()) do
        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            for Number in (Object.Text or ""):gmatch("%d+") do
                local N = tonumber(Number)
                if N and N >= 10 then return N end
            end
        end
    end

    for Number in Model.Name:gmatch("%d+") do
        local N = tonumber(Number)
        if N and N >= 10 then return N end
    end

    return nil
end

local function IsHunter(Model)
    if not Model:IsA("Model") or Model == Player.Character then return false end

    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    local Root = Model:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not Root or Humanoid.Health <= 0 then return false end

    if Model.Name:lower():find("hunter") then return true end

    for _,Object in ipairs(Model:GetDescendants()) do
        if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
            if Object.Text and Object.Text:lower():find("hunter") then return true end
        end
    end

    return false
end

local function FindHunter()
    local Character = Player.Character
    if not Character then return nil end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Best, BestDistance = nil, math.huge

    for _,Model in ipairs(workspace:GetDescendants()) do
        if IsHunter(Model) then
            local Level = GetLevel(Model)
            if Level and Level >= 100 and Level <= 700 then
                local NPC_Root = Model:FindFirstChild("HumanoidRootPart")
                if NPC_Root then
                    local Distance = (NPC_Root.Position-Root.Position).Magnitude
                    if Distance < BestDistance then
                        BestDistance, Best = Distance, Model
                    end
                end
            end
        end
    end

    return Best
end

Section(SafePage,"AUTO SAFE")
Toggle(SafePage,"Auto Safe at 30% HP",true,function(State)
    AutoSafe = State
end)
Info(SafePage,"30% HP -> SAFE\nFull HP -> resume Hunter")

Section(QuestPage,"QUEST / QZ")

Info(QuestPage,"QUIZ 1 - TP 1 / 2\nTP1 x6 -> wait 3s -> TP2 x6 -> wait 3s -> repeat")

local Tutorial = Instance.new("TextLabel")
Tutorial.Size = UDim2.new(1,0,0,84)
Tutorial.BackgroundColor3 = C.Panel2
Tutorial.Text = "TUTORIAL\n1. Open the game's Settings.\n2. Turn ON Auto Quest.\n3. Turn ON TP 1 / 2.\n4. TP1 x6 -> wait 3s.\n5. TP2 x6 -> wait 3s.\n6. Repeat while ON."
Tutorial.TextColor3 = C.Text
Tutorial.TextSize = 11
Tutorial.Font = Enum.Font.Gotham
Tutorial.TextWrapped = true
Tutorial.TextXAlignment = Enum.TextXAlignment.Left
Tutorial.Parent = QuestPage
Instance.new("UICorner",Tutorial).CornerRadius = UDim.new(0,8)

local Quiz1TP = Button(QuestPage,"1 - TP 1 / 2: OFF")
local Quiz2Hunter = Button(QuestPage,"2 - HUNTER: OFF")

Quiz1TP.Activated:Connect(function()
    if CombinedTPEnabled then
        StopCombinedTP()
        Quiz1TP.Text = "1 - TP 1 / 2: OFF"
        Quiz1TP.BackgroundColor3 = C.Panel2
    else
        CombinedTPEnabled = true
        Quiz1TP.Text = "1 - TP 1 / 2: ON"
        Quiz1TP.BackgroundColor3 = C.Purple
        StartCombinedTP()
    end
end)

Quiz2Hunter.Activated:Connect(function()
    AutoHunter = not AutoHunter

    if AutoHunter then
        Quiz2Hunter.Text = "2 - HUNTER: ON"
        Quiz2Hunter.BackgroundColor3 = C.Purple
        StatusInfo.Text = "Hunter: ON\nRange: Level 100-700"
    else
        Quiz2Hunter.Text = "2 - HUNTER: OFF"
        Quiz2Hunter.BackgroundColor3 = C.Panel2
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then Humanoid.AutoRotate = true end
        StatusInfo.Text = "Hunter: OFF\nRange: Level 100-700"
    end
end)

Section(SettingsPage,"SETTINGS")
Info(SettingsPage,"SCRIPT_HUB\nMobile Edition\nQUIZ 1 = TP 1 / 2\nQUIZ 2 = HUNTER ON / OFF")
Info(SettingsPage,"Hunter range: Level 100-700\nTP cycle: 6x + 3s each location")

local function GoSafe(Root)
    SafeMode = true
    CurrentTarget = nil
    for _ = 1,4 do
        if Root and Root.Parent then Root.CFrame = SAFE end
        task.wait(0.08)
    end
end

RunService.Heartbeat:Connect(function()
    local Character = Player.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Root or not Humanoid or Humanoid.MaxHealth <= 0 then return end

    local HP = Humanoid.Health/Humanoid.MaxHealth
    HealthInfo.Text = "HP: "..math.floor(Humanoid.Health).." / "..math.floor(Humanoid.MaxHealth)

    if AutoSafe and HP <= .30 and not SafeMode then GoSafe(Root) end

    if SafeMode then
        Root.CFrame = SAFE
        if HP >= .99 then
            SafeMode = false
            CurrentTarget = nil
        else
            return
        end
    end

    if AutoHunter then
        if not CurrentTarget or not CurrentTarget.Parent or os.clock()-LastSearch > .25 then
            CurrentTarget = FindHunter()
            LastSearch = os.clock()
        end

        if CurrentTarget then
            local TargetRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = CurrentTarget:FindFirstChildOfClass("Humanoid")

            if TargetRoot and TargetHumanoid and TargetHumanoid.Health > 0 then
                Humanoid.AutoRotate = false
                Root.CFrame = TargetRoot.CFrame*CFrame.new(0,0,6.99)

                TargetInfo.Text =
                    "Target: "..CurrentTarget.Name..
                    "\nLevel: "..(GetLevel(CurrentTarget) or "?")
            else
                CurrentTarget = nil
            end
        else
            TargetInfo.Text = "Target: No Hunter Found"
        end
    else
        Humanoid.AutoRotate = true
        TargetInfo.Text = "Target: None"
    end
end)

for _,Page in pairs(Pages) do Page.Visible = false end
StatusPage.Visible = true
TabButtons["Status"].BackgroundColor3 = C.Purple
TabButtons["Status"].TextColor3 = C.Text

--========================================================
-- X + OPEN ONLY
--========================================================

local Open = Instance.new("TextButton")
Open.Name = "OpenButton"
Open.Size = UDim2.fromOffset(80,38)
Open.Position = UDim2.fromOffset(15,200)
Open.BackgroundColor3 = C.Purple
Open.Text = "OPEN"
Open.TextColor3 = C.Text
Open.TextSize = 13
Open.Font = Enum.Font.GothamBold
Open.Visible = false
Open.ZIndex = 100
Open.Parent = Gui
Instance.new("UICorner",Open).CornerRadius = UDim.new(0,9)

Close.Activated:Connect(function()
    Main.Visible = false
    Open.Visible = true
end)

Open.Activated:Connect(function()
    Main.Visible = true
    Open.Visible = false
end)

--========================================================
-- MOBILE DRAG
--========================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Touch
    or Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then return end

    if Input.UserInputType == Enum.UserInputType.Touch
    or Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position-DragStart
        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset+Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset+Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.Touch
    or Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

Player.CharacterAdded:Connect(function()
    CurrentTarget = nil
    SafeMode = false
    task.wait(1)

    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid.AutoRotate = true end
end)

print("SCRIPT_HUB LOADED")
