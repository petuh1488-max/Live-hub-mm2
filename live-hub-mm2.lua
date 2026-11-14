--[[
	Live Hub | MM2 Ultimate Script (With Tap Fling, Auto Farm & Anim Packs)
	Works on PC and Mobile. Toggle: RightShift or Left Menu Button.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local TITLE = "LIVE HUB | MM2"
local TOGGLE_KEY = Enum.KeyCode.RightShift

local THEME = {
	Bg = Color3.fromRGB(12, 12, 16),
	Panel = Color3.fromRGB(19, 19, 25),
	Element = Color3.fromRGB(28, 28, 37),
	Hover = Color3.fromRGB(40, 40, 54),
	Accent = Color3.fromRGB(0, 136, 255),
	Accent2 = Color3.fromRGB(70, 180, 255),
	Text = Color3.fromRGB(236, 236, 246),
	SubText = Color3.fromRGB(150, 150, 175),
}

---------------------------------------------------------------------
-- Помощники
---------------------------------------------------------------------
local function new(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	obj.Parent = parent
	return obj
end

local function round(obj, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r) }, obj)
end

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

---------------------------------------------------------------------
-- Окно
---------------------------------------------------------------------
local function getParent()
	local ok, ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	ok, ui = pcall(function() return game:GetService("CoreGui") end)
	if ok and ui then
		local t = Instance.new("Folder")
		local okParent = pcall(function() t.Parent = ui end)
		t:Destroy()
		if okParent then return ui end
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local parentGui = getParent()
local old = parentGui:FindFirstChild("LiveHubMM2")
if old then old:Destroy() end

local gui = new("ScreenGui", {
	Name = "LiveHubMM2",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
gui.Parent = parentGui

local main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(540, 340),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.Bg,
	BorderSizePixel = 0,
	ClipsDescendants = false,
}, gui)
round(main, 14)
new("UIStroke", { Color = THEME.Accent, Transparency = 0.55, Thickness = 1.5 }, main)

local top = new("Frame", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundColor3 = THEME.Panel,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, main)
round(top, 14)

new("TextLabel", {
	Size = UDim2.new(1, -90, 1, 0),
	Position = UDim2.fromOffset(40, 0),
	BackgroundTransparency = 1,
	Text = TITLE,
	Font = Enum.Font.GothamBlack,
	TextSize = 17,
	TextColor3 = THEME.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local ring = new("Frame", {
	Size = UDim2.fromOffset(10, 10),
	Position = UDim2.fromOffset(16, 17),
	BackgroundColor3 = THEME.Accent,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
}, top)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)
local dot = new("Frame", {
	Size = UDim2.fromOffset(10, 10),
	Position = UDim2.fromOffset(16, 17),
	BackgroundColor3 = THEME.Accent,
	BorderSizePixel = 0,
}, top)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
task.spawn(function()
	while gui.Parent do
		ring.Size = UDim2.fromOffset(10, 10)
		ring.Position = UDim2.fromOffset(16, 17)
		ring.BackgroundTransparency = 0.4
		tween(ring, {
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(8, 9),
			BackgroundTransparency = 1,
		}, 1.2)
		task.wait(1.6)
	end
end)

local line = new("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 0, 44),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
}, main)
new("UIGradient", {
	Color = ColorSequence.new(THEME.Accent, THEME.Accent2),
}, line)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -38, 0.5, -14),
	BackgroundColor3 = Color3.fromRGB(255, 85, 105),
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = false,
}, top)
round(closeBtn, 8)

local sidebar = new("ScrollingFrame", {
	Size = UDim2.new(0, 140, 1, -46),
	Position = UDim2.fromOffset(0, 46),
	BackgroundTransparency = 1,
	CanvasSize = UDim2.new(0, 0, 0, 300),
	ScrollBarThickness = 2,
}, main)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
new("UIPadding", {
	PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),
	PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
}, sidebar)

local content = new("Frame", {
	Size = UDim2.new(1, -140, 1, -46),
	Position = UDim2.fromOffset(140, 46),
	BackgroundTransparency = 1,
}, main)

local fab = new("TextButton", {
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.new(0, 12, 0.5, -22),
	BackgroundColor3 = THEME.Accent,
	Text = "☰",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = false,
}, gui)
round(fab, 22)

local function setOpen(state)
	if state then
		main.Visible = true
		main.Size = UDim2.fromOffset(500, 310)
		tween(main, { Size = UDim2.fromOffset(540, 340) }, 0.2)
		fab.Visible = false
	else
		main.Visible = false
		fab.Visible = true
	end
end

closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
fab.MouseButton1Click:Connect(function() setOpen(not main.Visible) end)
UserInputService.InputBegan:Connect(function(i, gpe)
	if not gpe and i.KeyCode == TOGGLE_KEY then
		setOpen(not main.Visible)
	end
end)

do
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, dragStart, startPos = true, i.Position, main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
end

local Menu = {}
local tabs = {}

function Menu:CreateTab(name)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = THEME.Accent,
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = THEME.SubText,
		AutoButtonColor = false,
		LayoutOrder = #tabs,
	}, sidebar)
	round(btn, 8)

	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 16),
	}, page)

	local tab = { Button = btn, Page = page }
	table.insert(tabs, tab)

	local function select()
		for _, t in ipairs(tabs) do
			t.Page.Visible = false
			tween(t.Button, { BackgroundTransparency = 1, TextColor3 = THEME.SubText })
		end
		page.Visible = true
		tween(btn, { BackgroundTransparency = 0.15, TextColor3 = Color3.new(1, 1, 1) })
	end
	btn.MouseButton1Click:Connect(select)
	if #tabs == 1 then select() end

	local function row(height)
		local r = new("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = THEME.Element,
			BorderSizePixel = 0,
		}, page)
		round(r, 8)
		return r
	end

	local function label(parent, text, size, color, font)
		return new("TextLabel", {
			Size = UDim2.new(1, -24, 0, 20),
			Position = UDim2.fromOffset(12, 0),
			BackgroundTransparency = 1,
			Text = text,
			Font = font or Enum.Font.GothamMedium,
			TextSize = size or 14,
			TextColor3 = color or THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, parent)
	end

	function tab:AddLabel(text)
		local l = new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = THEME.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, page)
		return l
	end

	function tab:AddButton(text, callback)
		callback = callback or function() end
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = THEME.Element,
			Text = text,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = THEME.Text,
			AutoButtonColor = false,
		}, page)
		round(b, 8)
		b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = THEME.Hover }) end)
		b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = THEME.Element }) end)
		b.MouseButton1Click:Connect(function()
			tween(b, { BackgroundColor3 = THEME.Accent }, 0.08)
			task.delay(0.1, function() tween(b, { BackgroundColor3 = THEME.Hover }, 0.2) end)
			callback()
		end)
		return b
	end

	function tab:AddToggle(text, default, callback)
		callback = callback or function() end
		local state = default and true or false
		local r = row(38)
		local l = label(r, text)
		l.Size = UDim2.new(1, -80, 1, 0)

		local sw = new("Frame", {
			Size = UDim2.fromOffset(40, 20),
			Position = UDim2.new(1, -52, 0.5, -10),
			BackgroundColor3 = state and THEME.Accent or THEME.Bg,
			BorderSizePixel = 0,
		}, r)
		round(sw, 10)
		local knob = new("Frame", {
			Size = UDim2.fromOffset(14, 14),
			Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, sw)
		round(knob, 7)

		local function set(v)
			state = v
			tween(sw, { BackgroundColor3 = v and THEME.Accent or THEME.Bg })
			tween(knob, { Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
			callback(v)
		end

		local hit = new("TextButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
		}, r)
		hit.MouseButton1Click:Connect(function() set(not state) end)

		return { Set = set, Get = function() return state end }
	end

	function tab:AddSlider(text, min, max, default, callback)
		callback = callback or function() end
		local r = row(56)
		local l = label(r, text)
		l.Position = UDim2.fromOffset(12, 8)
		local valueLabel = label(r, "", 14, THEME.Accent2, Enum.Font.GothamBold)
		valueLabel.Position = UDim2.fromOffset(-12, 8)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right

		local bar = new("Frame", {
			Size = UDim2.new(1, -24, 0, 8),
			Position = UDim2.new(0, 12, 0, 36),
			BackgroundColor3 = THEME.Bg,
			BorderSizePixel = 0,
		}, r)
		round(bar, 4)
		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel = 0,
		}, bar)
		round(fill, 4)
		new("UIGradient", { Color = ColorSequence.new(THEME.Accent, THEME.Accent2) }, fill)

		local value = default or min
		local function set(v, silent)
			v = math.clamp(math.floor(v + 0.5), min, max)
			value = v
			fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
			valueLabel.Text = tostring(v)
			if not silent then callback(v) end
		end
		set(value, true)

		local function fromX(x)
			set(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1))
		end

		local hit = new("TextButton", {
			Size = UDim2.new(1, -24, 0, 26),
			Position = UDim2.new(0, 12, 0, 27),
			BackgroundTransparency = 1,
			Text = "",
		}, r)
		local sliding = false
		hit.InputBegan:Connect(function(i)
			if isPress(i) then sliding = true; fromX(i.Position.X) end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if sliding and isMove(i) then fromX(i.Position.X) end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if isPress(i) then sliding = false end
		end)

		return { Set = set, Get = function() return value end }
	end

	function tab:AddInput(placeholder, callback)
		callback = callback or function() end
		local b = new("TextBox", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = THEME.Element,
			PlaceholderText = placeholder or "Enter text...",
			Text = "",
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = THEME.Text,
			PlaceholderColor3 = THEME.SubText,
			ClearTextOnFocus = false,
		}, page)
		round(b, 8)
		b.FocusLost:Connect(function(enterPressed)
			callback(b.Text)
		end)
		return b
	end

	return tab
end

local murderTab = Menu:CreateTab("murder")
murderTab:AddLabel("MURDERER UTILITIES")
murderTab:AddButton("Kill All", function()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
	if knife then knife.Parent = char else return end
	task.wait(0.1)
	local myRoot = char.HumanoidRootPart
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				myRoot.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
				task.wait(0.1)
				if char:FindFirstChild("Knife") then char.Knife:Activate() end
			end
		end
	end
end)

getgenv().KillAura = false
murderTab:AddToggle("Toggle Kill Aura", false, function(on)
	getgenv().KillAura = on
	task.spawn(function()
		while getgenv().KillAura do
			task.wait(0.2)
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
				if knife then
					knife.Parent = char
					local myRoot = char.HumanoidRootPart
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local hum = player.Character:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
								if dist <= 18 then
									knife:Activate()
								end
							end
						end
					end
				end
			end
		end
	end)
end)

getgenv().MurderAim = false
murderTab:AddToggle("Murderer Silent Aim", false, function(on)
	getgenv().MurderAim = on
	task.spawn(function()
		while getgenv().MurderAim do
			task.wait(0.1)
			local char = LocalPlayer.Character
			local knife = char and (char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife"))
			if knife then
				if LocalPlayer.Backpack:FindFirstChild("Knife") then
					LocalPlayer.Backpack.Knife.Parent = char
				end
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local hum = player.Character:FindFirstChildOfClass("Humanoid")
						local hasKnife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
						if hum and hum.Health > 0 and not hasKnife then
							char.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
							knife:Activate()
							task.wait(0.15)
						end
					end
				end
			end
		end
	end)
end)

local sheriffTab = Menu:CreateTab("sheriff")
sheriffTab:AddLabel("SHERIFF UTILITIES")
sheriffTab:AddButton("TP to Gun Drop", function()
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name == "GunDrop" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
		end
	end
end)

getgenv().SheriffAim = false
sheriffTab:AddToggle("Sheriff Auto-Aim", false, function(on)
	getgenv().SheriffAim = on
	task.spawn(function()
		while getgenv().SheriffAim do
			task.wait(0.15)
			local char = LocalPlayer.Character
			local gun = char and (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun"))
			if gun then
				if LocalPlayer.Backpack:FindFirstChild("Gun") then
					LocalPlayer.Backpack.Gun.Parent = char
				end
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local hasKnife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
						local hum = player.Character:FindFirstChildOfClass("Humanoid")
						if hasKnife and hum and hum.Health > 0 then
							local targetPos = player.Character.HumanoidRootPart.Position
							Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
							if char:FindFirstChild("Gun") then
								char.Gun:Activate()
							end
						end
					end
				end
			end
		end
	end)
end)

local playerTab = Menu:CreateTab("player")
playerTab:AddLabel("PLAYER CHEATS")

getgenv().NoclipEnabled = false
playerTab:AddToggle("Toggle Noclip", false, function(on)
	getgenv().NoclipEnabled = on
	local connection
	connection = RunService.Stepped:Connect(function()
		if not getgenv().NoclipEnabled then
			connection:Disconnect()
			return
		end
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end)

getgenv().FlyEnabled = false
playerTab:AddToggle("Toggle Fly (Hybrid)", false, function(on)
	getgenv().FlyEnabled = on
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if getgenv().FlyEnabled then
		if humanoid then humanoid.PlatformStand = true end
		
		local bv = Instance.new("BodyVelocity", root)
		bv.Name = "HybridFlyVel"
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(0, 0, 0)

		local bg = Instance.new("BodyGyro", root)
		bg.Name = "HybridFlyGyro"
		bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bg.CFrame = Camera.CFrame

		task.spawn(function()
			local speed = 50
			while getgenv().FlyEnabled do
				task.wait()
				local moveDir = Vector3.new()
				
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

				if moveDir.Magnitude == 0 then
					bv.Velocity = Camera.CFrame.LookVector * speed
				else
					bv.Velocity = moveDir.Unit * speed
				end
				
				bg.CFrame = Camera.CFrame
			end
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
			if humanoid then humanoid.PlatformStand = false end
		end)
	else
		if root:FindFirstChild("HybridFlyVel") then root.HybridFlyVel:Destroy() end
		if root:FindFirstChild("HybridFlyGyro") then root.HybridFlyGyro:Destroy() end
		if humanoid then humanoid.PlatformStand = false end
	end
end)

getgenv().AutoFarm = false
playerTab:AddToggle("Toggle Auto Farm Coins", false, function(on)
	getgenv().AutoFarm = on
	task.spawn(function()
		while getgenv().AutoFarm do
			task.wait(0.2)
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				local coinContainer = Workspace:FindFirstChild("CoinContainer") or Workspace:FindFirstChild("Normal")
				if coinContainer then
					for _, coin in ipairs(coinContainer:GetDescendants()) do
						if not getgenv().AutoFarm then break end
						if coin:IsA("BasePart") and (coin.Name == "Coin" or coin.Name == "CoinVisual" or coin:FindFirstChild("TouchInterest")) then
							hrp.CFrame = coin.CFrame
							task.wait(0.1)
						end
					end
				else
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if not getgenv().AutoFarm then break end
						if obj:IsA("BasePart") and obj.Name == "CoinContainer" then
							for _, coin in ipairs(obj:GetChildren()) do
								if coin:IsA("BasePart") then
									hrp.CFrame = coin.CFrame
									task.wait(0.1)
								end
							end
						end
					end
				end
			end
		end
	end)
end)

getgenv().TapFling = false
playerTab:AddToggle("Toggle Tap Fling", false, function(on)
	getgenv().TapFling = on
	task.spawn(function()
		local bv, angular
		while getgenv().TapFling do
			task.wait(0.1)
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				local mouse = LocalPlayer:GetMouse()
				
				if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService.TouchStarted then
					local target = mouse.Target
					if target and target.Parent and target.Parent:FindFirstChild("HumanoidRootPart") then
						local targetHrp = target.Parent.HumanoidRootPart
						hrp.CFrame = targetHrp.CFrame
						
						if not hrp:FindFirstChild("FlingAngular") then
							angular = Instance.new("BodyAngularVelocity", hrp)
							angular.Name = "FlingAngular"
							angular.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
							angular.AngularVelocity = Vector3.new(0, 99999, 0)
						end
					else
						if hrp:FindFirstChild("FlingAngular") then
							hrp.FlingAngular:Destroy()
						end
					end
				else
					if hrp:FindFirstChild("FlingAngular") then
						hrp.FlingAngular:Destroy()
					end
				end
			end
		end
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FlingAngular") then
			char.HumanoidRootPart.FlingAngular:Destroy()
		end
	end)
end)

local animTab = Menu:CreateTab("animations")
animTab:AddLabel("CUSTOM ANIMATION PACK")

local animInput = animTab:AddInput("Paste AnimPack ID (e.g. 782841499)", function() end)

animTab:AddButton("Apply Anim Pack", function()
	local text = animInput.Text
	local packId = text:match("%d+")
	if not packId then return end

	local char = LocalPlayer.Character
	if not char then return end
	local animateScript = char:FindFirstChild("Animate")
	if not animateScript then
		animateScript = LocalPlayer.CharacterAdded:Wait():FindFirstChild("Animate")
	end

	if animateScript then
		local function replaceAnim(folderName, animName, newId)
			local folder = animateScript:FindFirstChild(folderName)
			if folder then
				local animObj = folder:FindFirstChild(animName)
				if animObj then
					local idVal = animObj:FindFirstChildOfClass("StringValue") or animObj:FindFirstChildOfClass("IntValue") or animObj:FindFirstChild("AnimationId")
					if idVal then
						idVal.Value = "rbxassetid://" .. newId
					end
				end
			end
		end

		local mappings = {
			{"idle", "Animation1", packId},
			{"idle", "Animation2", packId},
			{"walk", "WalkAnim", packId},
			{"run", "RunAnim", packId},
			{"jump", "JumpAnim", packId},
			{"fall", "FallAnim", packId},
			{"climb", "ClimbAnim", packId},
			{"swim", "Swim", packId},
			{"swimidle", "SwimIdle", packId}
		}

		for _, map in ipairs(mappings) do
			pcall(function()
				replaceAnim(map[1], map[2], map[3])
			end)
		end

		animateScript.Disabled = true
		task.wait(0.05)
		animateScript.Disabled = false
	end
end)

local visualsTab = Menu:CreateTab("visuals")
visualsTab:AddLabel("VISUALS & ESP")

getgenv().ESPEnabled = false
visualsTab:AddToggle("Toggle Role ESP", false, function(on)
	getgenv().ESPEnabled = on
	task.spawn(function()
		while getgenv().ESPEnabled do
			task.wait(0.5)
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local char = player.Character
					local hrp = char.HumanoidRootPart
					if hrp:FindFirstChild("ShitaroESP") then hrp.ShitaroESP:Destroy() end
					local hl = Instance.new("Highlight")
					hl.Name = "ShitaroESP"
					hl.Adornee = char
					hl.Parent = hrp
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					
					local hasKnife = player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
					local hasGun = player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
					
					if hasKnife then
						hl.FillColor = Color3.fromRGB(240, 40, 40)
					elseif hasGun then
						hl.FillColor = Color3.fromRGB(40, 120, 255)
					else
						hl.FillColor = Color3.fromRGB(40, 220, 40)
					end
				end
			end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				let hl = player.Character.HumanoidRootPart:FindFirstChild("ShitaroESP")
				if hl then hl:Destroy() end
			end
		end
	end)
end)

local tpTab = Menu:CreateTab("teleports")
tpTab:AddLabel("MAP TELEPORTS")
tpTab:AddButton("TP to Lobby", function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 150, 0)
	end
end)

local settingsTab = Menu:CreateTab("settings")
settingsTab:AddLabel("SETTINGS / UNLOAD")
settingsTab:AddButton("Unload / Close UI", function()
	getgenv().ESPEnabled = false
	getgenv().NoclipEnabled = false
	getgenv().FlyEnabled = false
	getgenv().MurderAim = false
	getgenv().SheriffAim = false
	getgenv().KillAura = false
	getgenv().AutoFarm = false
	getgenv().TapFling = false
	gui:Destroy()
end)

return Menu
