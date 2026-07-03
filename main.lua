-- سكربت المستشفى الذكي المخصص لـ Delta
print("Animal Hospital AI Script Loaded!")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- إعدادات الأمان والمسافات
local SAFE_ZONE_POS = Vector3.new(0, 5, 0) -- ضع هنا إحداثيات الغرفة الآمنة إذا كنت تعرفها (اختياري)
local MONSTER_DISTANCE = 35 -- المسافة التي يعتبر فيها الوحش خطراً

-- دالة فحص إذا كان الكائن وحشاً
local function isMonster(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "monster") or string.find(name, "ghost") or string.find(name, "zombie") or string.find(name, "وحش") then
        return true
    end
    return false
end

-- دالة لتشغيل أزرار التفاعل تلقائياً (علاج، فتح/قفل باب)
local function interactWithPrompt(object)
    if object:IsA("ProximityPrompt") then
        fireproximityprompt(object) -- أمر خاص بمشغلات الجوال لتفعيل الأزرار تلقائياً
    end
end

-- دالة البحث عن أقرب مريض (لاعب أو شخصية عامة) ليس وحشاً
local function findClosestPatient()
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest = nil
    local shortestDist = math.huge
    
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v ~= myChar and v:FindFirstChild("HumanoidRootPart") then
            if not isMonster(v) then
                local dist = (myChar.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

-- الحلقة الذكية لإدارة الحركة، الأبواب، والعلاج
task.spawn(function()
    while task.wait(0.3) do
        local myChar = player.Character
        local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if myHumanoid and myRoot then
            -- 1. فحص وجود وحش قريب
            local monsterDetected = nil
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and isMonster(v) and v:FindFirstChild("HumanoidRootPart") then
                    local dist = (myRoot.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < MONSTER_DISTANCE then
                        monsterDetected = v
                        break
                    end
                end
            end
            
            -- [حالة وجود وحش]: اقفل الباب واحمِ نفسك
            if monsterDetected then
                print("⚠️ وحش قريب! جاري قفل الأبواب وتأمين المكان...")
                
                -- البحث عن أزرار الأبواب القريبة لقفلها
                for _, child in pairs(workspace:GetDescendants()) do
                    if child:IsA("ProximityPrompt") and (string.find(string.lower(child.Parent.Name), "door") or string.find(string.lower(child.Parent.Name), "gate")) then
                        local doorDist = (myRoot.Position - child.Parent:GetPivot().Position).Magnitude
                        if doorDist < 20 then
                            -- تفاعل مع الباب لقفله (حسب نظام اللعبة إذا كان الزر يغلق أو يقفل)
                            interactWithPrompt(child)
                        end
                    end
                end
                
                -- التوقف عن الحركة تماماً خلف الباب
                myHumanoid:MoveTo(myRoot.Position) 
                continue -- تخطي بقية الأوامر حتى يذهب الوحش
            end
            
            -- [حالة الوضع آمن]: اذهب للمريض وعالجه وافتح الأبواب في طريقك
            local patient = findClosestPatient()
            if patient and patient:FindFirstChild("HumanoidRootPart") then
                -- المشي باتجاه المريض
                myHumanoid:MoveTo(patient.HumanoidRootPart.Position)
                
                -- فحص إذا كان هناك باب يعترض طريقك أثناء المشي لفتحه
                for _, child in pairs(workspace:GetDescendants()) do
                    if child:IsA("ProximityPrompt") and (string.find(string.lower(child.Parent.Name), "door") or string.find(string.lower(child.Parent.Name), "gate")) then
                        local doorDist = (myRoot.Position - child.Parent:GetPivot().Position).Magnitude
                        if doorDist < 10 then
                            interactWithPrompt(child) -- فتح البارد فوراً للمرور
                        end
                    end
                end
                
                -- إذا وصلت للمريض (مسافة قريبة جداً)، قم بعلاجه تلقائياً
                local patientDist = (myRoot.Position - patient.HumanoidRootPart.Position).Magnitude
                if patientDist < 7 then
                    local prompt = patient:FindFirstChildOfClass("ProximityPrompt") or patient:FindFirstChild("HealPrompt", true)
                    if prompt then
                        interactWithPrompt(prompt)
                    end
                end
            end
        end
    end
end)
