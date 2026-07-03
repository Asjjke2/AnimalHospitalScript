-- تحسين الواجهة لتظهر فوراً على مشغل دلتا (Delta)
local HospitalGui = Instance.new("ScreenGui")
HospitalGui.Name = "AnimalHospitalGui"
HospitalGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        HospitalGui.Parent = gethui()
    elseif game:GetService("CoreGui") then
        HospitalGui.Parent = game:GetService("CoreGui")
    else
        HospitalGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- اللوحة الرئيسية (تم إضاف ميزة السحب لتتحكم بمكانها على الجوال)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = HospitalGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Animal Hospital [Delta Fix]"
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- زر التشغيل التلقائي (المشي والعلاج)
local AutoWalkButton = Instance.new("TextButton")
AutoWalkButton.Name = "AutoWalkButton"
AutoWalkButton.Text = "Auto Walk (Human): OFF"
AutoWalkButton.Size = UDim2.new(0.85, 0, 0.2, 0)
AutoWalkButton.Position = UDim2.new(0.075, 0, 0.25, 0)
AutoWalkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoWalkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoWalkButton.Font = Enum.Font.SourceSansBold
AutoWalkButton.TextSize = 15
AutoWalkButton.Parent = MainFrame

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 6)
Corner1.Parent = AutoWalkButton

-- زر الحماية وإغلاق السكربت عند ظهور وحش
local AntiMonsterButton = Instance.new("TextButton")
AntiMonsterButton.Name = "AntiMonsterButton"
AntiMonsterButton.Text = "Anti-Monster Mode: ON"
AntiMonsterButton.Size = UDim2.new(0.85, 0, 0.2, 0)
AntiMonsterButton.Position = UDim2.new(0.075, 0, 0.5, 0)
AntiMonsterButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
AntiMonsterButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiMonsterButton.Font = Enum.Font.SourceSansBold
AntiMonsterButton.TextSize = 15
AntiMonsterButton.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 6)
Corner2.Parent = AntiMonsterButton

-- زر السرعة العالية للماب
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Text = "Speed Boost: OFF"
SpeedButton.Size = UDim2.new(0.85, 0, 0.2, 0)
SpeedButton.Position = UDim2.new(0.075, 0, 0.75, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.TextSize = 15
SpeedButton.Parent = MainFrame

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 6)
Corner3.Parent = SpeedButton

-- نظام البرمجة والربط الذكي
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local autoWalk = false
local antiMonster = true
local speedBoost = false

-- ميزة الملاحقة التلقائية للبشر (المجسمات العادية واللاعبين) وتجنب الوحوش
local function getTarget()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestTarget = nil
    local minDistance = math.huge
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= character and v:FindFirstChild("HumanoidRootPart") then
            -- التحقق هل الكائن وحش؟ (تعتمد اللعبة على تصنيفهم كأعداء أو وحوش)
            local isMonster = string.find(string.lower(v.Name), "monster") or string.find(string.lower(v.Name), "ghost") or string.find(string.lower(v.Name), "zombie")
            
            if not isMonster then
                -- استهداف المرضى أو الكائنات العادية المحتاجة علاج
                local distance = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestTarget = v
                end
            end
        end
    end
    return closestTarget
end

-- حلقة التشغيل والحماية (آمنة تماماً ولا تسبب تعليق للجوال)
task.spawn(function()
    while task.wait(0.3) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- نظام تفقد الوحوش: إذا اقترب وحش يقفل السكربت فوراً لحمايتك
            if antiMonster then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and (string.find(string.lower(v.Name), "monster") or string.find(string.lower(v.Name), "ghost")) then
                        if v:FindFirstChild("HumanoidRootPart") then
                            local monsterDist = (rootPart.Position - v.HumanoidRootPart.Position).Magnitude
                            if monsterDist < 30 then -- المسافة الأمنية
                                autoWalk = false
                                AutoWalkButton.Text = "⚠️ STOPPED: Monster Near!"
                                AutoWalkButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                humanoid:MoveTo(rootPart.Position)
                            end
                        end
                    end
                end
            end
            
            -- تشغيل المشي الذكي
            if autoWalk then
                local target = getTarget()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    humanoid:MoveTo(target.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- تفعيل / إيقاف ملاحقة البشر وعلاجهم
AutoWalkButton.MouseButton1Click:Connect(function()
    autoWalk = not autoWalk
    if autoWalk then
        AutoWalkButton.Text = "Auto Walk (Human): ON"
        AutoWalkButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AutoWalkButton.Text = "Auto Walk (Human): OFF"
        AutoWalkButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- تفعيل / إيقاف الحماية من الوحوش
AntiMonsterButton.MouseButton1Click:Connect(function()
    antiMonster = not antiMonster
    if antiMonster then
        AntiMonsterButton.Text = "Anti-Monster Mode: ON"
        AntiMonsterButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AntiMonsterButton.Text = "Anti-Monster Mode: OFF"
        AntiMonsterButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- تفعيل / إيقاف السرعة
SpeedButton.MouseButton1Click:Connect(function()
    speedBoost = not speedBoost
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        if speedBoost then
            humanoid.WalkSpeed = 50
            SpeedButton.Text = "Speed Boost: ON"
            SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            humanoid.WalkSpeed = 16
            SpeedButton.Text = "Speed Boost: OFF"
            SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end
end)
