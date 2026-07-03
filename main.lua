-- استدعاء مكتبة واجهات متوافقة 100% مع دلتا والمشغلات الحديثة
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- إنشاء النافذة الرئيسية
local Window = Fluent:CreateWindow({
    Title = "Animal Hospital Helper",
    SubTitle = "by Delta Fix",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 280),
    Acrylic = false, -- تم إغلاقه لتجنب الـ Lag والـ Crash على الجوال
    Theme = "Dark"
})

-- إضافة تبويب التحكم
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

-- المتغيرات الأساسية
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local autoWalk = false
local antiMonster = true

-- دالة البحث عن البشر والحيوانات المصابة وتجنب الوحوش
local function getTarget()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestTarget = nil
    local minDistance = math.huge
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= character and v:FindFirstChild("HumanoidRootPart") then
            -- فحص الكلمات الدلالية للوحوش داخل اللعبة
            local isMonster = string.find(string.lower(v.Name), "monster") or string.find(string.lower(v.Name), "ghost") or string.find(string.lower(v.Name), "zombie")
            
            if not isMonster then
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

-- حلقة التشغيل والحماية الخلفية الآمنة
task.spawn(function()
    while task.wait(0.4) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- الحماية الذكية من الوحوش
            if antiMonster then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and (string.find(string.lower(v.Name), "monster") or string.find(string.lower(v.Name), "ghost")) then
                        if v:FindFirstChild("HumanoidRootPart") then
                            local monsterDist = (rootPart.Position - v.HumanoidRootPart.Position).Magnitude
                            if monsterDist < 30 then
                                autoWalk = false
                                humanoid:MoveTo(rootPart.Position) -- إيقاف فوري للحركة
                                Fluent:Notify({
                                    Title = "⚠️ Warning!",
                                    Content = "Monster detected nearby! Script paused.",
                                    Duration = 3
                                })
                            end
                        end
                    end
                end
            end
            
            -- حركة المشي التلقائي
            if autoWalk then
                local target = getTarget()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    humanoid:MoveTo(target.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- إضافة الأزرار داخل الواجهة الجديدة

-- 1. زر تشغيل وإيقاف البوت
local ToggleAuto = Tabs.Main:AddToggle("AutoWalkToggle", {Title = "Auto Walk & Heal (Human)", Default = false })
ToggleAuto:OnChanged(function(Value)
    autoWalk = Value
end)

-- 2. زر تشغيل وإيقاف حماية الوحوش
local ToggleAnti = Tabs.Main:AddToggle("AntiMonsterToggle", {Title = "Anti-Monster Mode", Default = true })
ToggleAnti:OnChanged(function(Value)
    antiMonster = Value
end)

-- 3. زر التحكم بالسرعة
local SliderSpeed = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "WalkSpeed Boost",
    Description = "Adjust your speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0
})
SliderSpeed:OnChanged(function(Value)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Value
    end
end)

-- تنبيه بنجاح التشغيل
Fluent:Notify({
    Title = "Animal Hospital Fixed",
    Content = "Script loaded successfully using Fluent UI!",
    Duration = 5
})
