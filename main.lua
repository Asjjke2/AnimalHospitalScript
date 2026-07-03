-- تأمين تشغيل الواجهة على دلتا وجوالات أندرويد/آيفون
local HospitalGui = Instance.new("ScreenGui")
HospitalGui.Name = "HospitalGui"
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

-- اللوحة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- ميزة سحب اللوحة بإصبعك على الجوال
MainFrame.Parent = HospitalGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Animal Hospital [Delta]"
Title.Size = UDim2.new(1, 0, 0.25, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- زر التشغيل التلقائي والملاحقة والعلاج
local AutoButton = Instance.new("TextButton")
AutoButton.Name = "AutoButton"
AutoButton.Text = "Auto Walk & Heal: OFF"
AutoButton.Size = UDim2.new(0.85, 0, 0.25, 0)
AutoButton.Position = UDim2.new(0.075, 0, 0.35, 0)
AutoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 15
AutoButton.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoButton

-- زر السرعة
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Text = "Speed: OFF"
SpeedButton.Size = UDim2.new(0.85, 0, 0.25, 0)
SpeedButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.TextSize = 15
SpeedButton.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

-- البرمجة والتحكم لـ Delta
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local isAutoActive = false
local isSpeedActive = false

-- الكلمات الدلالية للوحوش ليتجنبها ويقفل السكربت
local MonsterKeywords = {"Monster", "Zombie", "Monster", "Ghost", "Enemy"}

local function checkIsMonster(obj)
    for _, word in pairs(MonsterKeywords) do
        if string.find(string.lower(obj.Name), string.lower(word)) then
            return true
        end
    end
    return false
end

-- دالة البحث الشامل عن مريض (سواء لاعب أو NPC)
local function findPatient()
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local target = nil
    local maxDist = math.huge
    
    -- البحث في كل مجسمات اللعبة بالـ Workspace
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= myChar and v:FindFirstChild("HumanoidRootPart") then
            -- التأكد أنه ليس وحشاً
            if not checkIsMonster(v) then
                -- إذا كان لاعب مصاب أو يحمل اسماً يدل على مريض
                local humanoid = v:FindFirstChild("Humanoid")
                if (humanoid and humanoid.Health < humanoid.MaxHealth and humanoid.Health > 0) or string.find(string.lower(v.Name), "patient") or string.find(string.lower(v.Name), "sick") then
                    local dist = (myChar.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target = v
                    end
                end
            end
        end
    end
    return target
end

-- حلقة ذكية آمنة على الجوال لتجنب الـ Crash
task.spawn(function()
    while task.wait(0.3) do -- تأخير بسيط لحماية معالج الجوال
        if isAutoActive then
            local myChar = player.Character
            local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHumanoid and myRoot then
                -- فحص فوري لحمايتك إذا كان هناك وحش قريب جداً
                local monsterClose = false
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and checkIsMonster(v) and v:FindFirstChild("HumanoidRootPart") then
                        if (myRoot.Position - v.HumanoidRootPart.Position).Magnitude < 25 then
                            monsterClose = true
                            break
                        end
                    end
                end
                
                if monsterClose then
                    isAutoActive = false
                    AutoButton.Text = "⚠️ Monster! Script Stopped"
                    AutoButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    myHumanoid:MoveTo(myRoot.Position)
                    continue
                end
                
                -- التوجه للمريض
                local patient = findPatient()
                if patient and patient:FindFirstChild("HumanoidRootPart") then
                    myHumanoid:MoveTo(patient.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- تفعيل البوت
AutoButton.MouseButton1Click:Connect(function()
    isAutoActive = not isAutoActive
    if isAutoActive then
        AutoButton.Text = "Auto Walk & Heal: ON"
        AutoButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        AutoButton.Text = "Auto Walk & Heal: OFF"
        AutoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- تفعيل السرعة
SpeedButton.MouseButton1Click:Connect(function()
    isSpeedActive = not isSpeedActive
    local myChar = player.Character
    local hum = myChar and myChar:FindFirstChild("Humanoid")
    if hum then
        if isSpeedActive then
            hum.WalkSpeed = 45
            SpeedButton.Text = "Speed: ON (45)"
            SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            hum.WalkSpeed = 16
            SpeedButton.Text = "Speed: OFF"
            SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end
end)
