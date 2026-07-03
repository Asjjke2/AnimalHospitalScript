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
Title.Text = "Hospital Helper GUI"
Title.Size = UDim2.new(1, 0, 0.25, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Ubuntu
Title.TextSize = 18
Title.Parent = MainFrame

-- زر الطيران (Fly)
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Text = "Fly Mode: OFF"
FlyButton.Size = UDim2.new(0.85, 0, 0.25, 0)
FlyButton.Position = UDim2.new(0.075, 0, 0.35, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 16
FlyButton.Parent = MainFrame

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 6)
FlyCorner.Parent = FlyButton

-- زر زيادة السرعة (Speed Boost)
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

local isFlying = false
local speed = 60
local bv, bg
local isSpeedCapped = false

-- نظام الطيران
local function startFlying()
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not rootPart or not humanoid then return end

	isFlying = true
	humanoid.PlatformStand = true
	
	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.Parent = rootPart
	
	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.CFrame = rootPart.CFrame
	bg.Parent = rootPart
	
	local camera = workspace.CurrentCamera
	while isFlying and character.Parent do
		RunService.RenderStepped:Wait()
		if humanoid.MoveDirection.Magnitude > 0 then
			bv.Velocity = camera.CFrame.LookVector * speed
		else
			bv.Velocity = Vector3.new(0, 0, 0)
		end
		bg.CFrame = camera.CFrame
	end
end

local function stopFlying()
	isFlying = false
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

FlyButton.MouseButton1Click:Connect(function()
	if isFlying then
		stopFlying()
		FlyButton.Text = "Fly Mode: OFF"
		FlyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else
		FlyButton.Text = "Fly Mode: ON"
		FlyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startFlying()
	end
end)

-- نظام زيادة سرعة المشي العادية
SpeedButton.MouseButton1Click:Connect(function()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		local humanoid = character.Humanoid
		if isSpeedCapped then
			humanoid.WalkSpeed = 16 -- السرعة العادية للعبة
			SpeedButton.Text = "Speed Boost: OFF"
			SpeedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			isSpeedCapped = false
		else
			humanoid.WalkSpeed = 50 -- سرعة مخصصة للتنقل الفوري
			SpeedButton.Text = "Speed Boost: ON"
			SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			isSpeedCapped = true
		end
	end
end)
