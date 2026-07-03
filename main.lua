-- Animal Hospital AI Script [Delta Compatible]
print("Animal Hospital AI Script Loaded Successfully!")

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

local MONSTER_DISTANCE = 35 -- المسافة الأمنية من الوحوش

-- دالة فحص الوحوش
local function isMonster(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "monster") or string.find(name, "ghost") or string.find(name, "zombie") or string.find(name, "وحش") then
        return true
    end
    return false
end

-- دالة التفاعل المضمونة مع الأزرار لفتح الأبواب والعلاج
local function interactWithPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        task.spawn(function()
            -- استخدام الطريقة الرسمية المتوافقة مع دلتا والمشغلات الحديثة
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.1)
            prompt:InputHoldEnd()
        end)
    end
end

-- دالة البحث عن أقرب مريض
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

-- الحلقة الذكية (مؤمنة لحماية معالج الجوال من الكراش)
task.spawn(function()
    while task.wait(0.4) do
        local myChar = player.Character
        local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if myHumanoid and myRoot then
            -- 1. فحص وجود وحش قريب جداً لقفل الأبواب
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
            
            -- [إذا وجد وحش]: قفل الأبواب فوراً وتوقف
            if monsterDetected then
                -- قفل الأبواب القريبة
                for _, child in pairs(workspace:GetDescendants()) do
                    if child:IsA("ProximityPrompt") and (string.find(string.lower(child.Parent.Name), "door") or string.find(string.lower(child.Parent.Name), "gate")) then
                        local doorDist = (myRoot.Position - child.Parent:GetPivot().Position).Magnitude
                        if doorDist < 25 then
                            interactWithPrompt(child)
                        end
                    end
                end
                myHumanoid:MoveTo(myRoot.Position) -- قف مكانك لحمايتك
                continue 
            end
            
            -- [إذا الوضع آمن]: اذهب للمريض وافتح الأبواب في طريقك
            local patient = findClosestPatient()
            if patient and patient:FindFirstChild("HumanoidRootPart") then
                myHumanoid:MoveTo(patient.HumanoidRootPart.Position)
                
                -- فتح الأبواب التي تعترض طريقك
                for _, child in pairs(workspace:GetDescendants()) do
                    if child:IsA("ProximityPrompt") and (string.find(string.lower(child.Parent.Name), "door") or string.find(string.lower(child.Parent.Name), "gate")) then
                        local doorDist = (myRoot.Position - child.Parent:GetPivot().Position).Magnitude
                        if doorDist < 12 then
                            interactWithPrompt(child)
                        end
                    end
                end
                
                -- علاج المريض عند الوصول إليه
                local patientDist = (myRoot.Position - patient.HumanoidRootPart.Position).Magnitude
                if patientDist < 8 then
                    -- البحث عن أي زر تفاعل داخل مجسم المريض
                    for _, prompt in pairs(patient:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            interactWithPrompt(prompt)
                        end
                    end
                end
            end
        end
    end
end)
