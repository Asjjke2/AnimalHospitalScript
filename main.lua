-- إنشاء الواجهة في CoreGui ليظهر للمشغلات
local HospitalGui = Instance.new("ScreenGui")
HospitalGui.Name = "HospitalGui"
HospitalGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HospitalGui.Parent = game:GetService("CoreGui")

-- اللوحة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = HospitalGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Animal Hospital Auto-Helper"
Title.Size = UDim2.new(1, 0, 0.25, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Ubuntu
Title.TextSize = 18
Title.Parent = MainFrame

-- زر التشغيل التلقائي والملاحقة والعلاج
local AutoButton = Instance.new("TextButton")
AutoButton.Name = "AutoButton"
AutoButton.Text = "Auto Heal & Walk: OFF"
AutoButton.Size = UDim2.new(0.85, 0, 0.25, 0)
AutoButton.Position = UDim2.new(0.075, 0, 0.35, 0)
AutoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 16
AutoButton.Parent = MainFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoButton

-- زر سرعة المشي الذكية
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Text = "Speed Boost: OFF"
SpeedButton.Size = UDim2.new(0.85, 0, 0.25, 0)
SpeedButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.TextSize = 16
SpeedButton.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

-- البرمجة والتحكم
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local isAutoActive = false
local isSpeedCapped = false

-- قائمة بأسماء الوحوش أو الأعداء لتجنبهم (عدّلها حسب أسماء الوحوش باللعبة)
local MonsterNames = {"Monster", "Zombie", "EvilAnimal", "Ghost"} 

-- دالة للتحقق هل الكائن وحش؟
local function isMonster(target)
    for _, name in pairs(MonsterNames) do
        if string.find(target.Name, name) or (target:FindFirstChild("Humanoid") and string.find(target.Humanoid.DisplayName, name)) then
            return true
        end
    end
    return false
end

-- دالة البحث عن أقرب إنسان/لاعب يحتاج علاج
local function getClosestPatient()
    local closestPatient = nil
    local shortestDistance = math.huge
    local myCharacter = player.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return nil end
    
    -- البحث في بقية اللاعبين أو الشخصيات بـ Workspace
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local targetChar = p.Character
            local targetHumanoid = targetChar.Humanoid
            
            -- التأكد أنه إنسان طبيعي وليس وحش، وأن صحته ناقصة ويحتاج علاج
            if not isMonster(targetChar) and targetHumanoid.Health < targetHumanoid.MaxHealth and targetHumanoid.Health > 0 then
                local distance = (myCharacter.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPatient = targetChar
                end
            end
        end
    end
    return closestPatient
end

-- حلقة التشغيل التلقائي والملاحقة
task.spawn(function()
    while true do
        task.wait(0.1)
        if isAutoActive then
            local myCharacter = player.Character
            local myHumanoid = myCharacter and myCharacter:FindFirstChild("Humanoid")
            
            -- فحص إذا كان هناك وحش قريب جداً منا لإيقاف السكربت فوراً لحمايتك
            local monsterAlert = false
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and isMonster(v) and v:FindFirstChild("HumanoidRootPart") and myCharacter and myCharacter:FindFirstChild("HumanoidRootPart") then
                    local distToMonster = (myCharacter.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if distToMonster < 30 then -- إذا كان الوحش على بعد أقل من 30 خطوة
                        monsterAlert = true
                        break
                    end
                end
            end
            
            if monsterAlert then
                -- وحش قريب! قفل السكربت فوراً لحمايتك
                isAutoActive = false
                AutoButton.Text = "⚠️ WARNING: Monster Near! OFF"
                AutoButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                if myHumanoid then myHumanoid:MoveTo(myCharacter.HumanoidRootPart.Position) end -- إيقاف الحركة
                continue
            end
            
            -- إذا الوضع آمن، ابحث عن مريض للمشي إليه وعلاجه
            local patient = getClosestPatient()
            if patient and myHumanoid and myCharacter:FindFirstChild("HumanoidRootPart") then
                -- المشي التلقائي باتجاه الهدف
                myHumanoid:MoveTo(patient.HumanoidRootPart.Position)
