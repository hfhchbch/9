local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- 飞行核心变量
local isFlying = false
local flySpeed = 50
local moveDir = Vector3.new(0, 0, 0)

-- 1. 创建主UI容器
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "ScriptHubUI"
mainGui.IgnoreGuiInset = true
mainGui.Parent = playerGui

-- 2. 主窗口（模拟软件窗口）
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 600, 0, 400)
mainWindow.Position = UDim2.new(0.5, -300, 0.5, -200)
mainWindow.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainWindow.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
mainWindow.BorderSizePixel = 2
mainWindow.ClipsDescendants = true
mainWindow.Parent = mainGui

-- 窗口标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleBar.Parent = mainWindow

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.02, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "RB脚本中心 | 战争大亨 v2"
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.TextSize = 14
titleText.Parent = titleBar

local versionTag = Instance.new("Frame")
versionTag.Size = UDim2.new(0, 12, 0, 12)
versionTag.Position = UDim2.new(0.45, 0, 0.5, -6)
versionTag.BackgroundColor3 = Color3.new(0, 1, 0)
versionTag.CornerRadius = UDim.new(1, 0)
versionTag.Parent = titleBar

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(0, 30, 0, 12)
versionText.Position = UDim2.new(0.48, 0, 0.5, -6)
versionText.BackgroundTransparency = 1
versionText.Text = "v2"
versionText.TextColor3 = Color3.new(1, 1, 1)
versionText.TextSize = 12
versionText.Parent = titleBar

-- 窗口控制按钮
local minBtn = createWindowBtn("−", UDim2.new(1, -60, 0, 0))
local maxBtn = createWindowBtn("□", UDim2.new(1, -35, 0, 0))
local closeBtn = createWindowBtn("×", UDim2.new(1, -10, 0, 0))
closeBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeBtn.MouseButton1Click:Connect(function()
    mainWindow.Visible = false
end)

-- 3. 左侧导航栏
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(0, 150, 1, -30)
navBar.Position = UDim2.new(0, 0, 0, 30)
navBar.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
navBar.Parent = mainWindow

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0.9, 0, 0, 30)
searchFrame.Position = UDim2.new(0.05, 0, 0.02, 0)
searchFrame.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
searchFrame.CornerRadius = UDim.new(0, 5)
searchFrame.Parent = navBar

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 20, 0, 20)
searchIcon.Position = UDim2.new(0.05, 0, 0.5, -10)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 16
searchIcon.Parent = searchFrame

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(0.8, 0, 1, 0)
searchInput.Position = UDim2.new(0.15, 0, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.PlaceholderText = "Search"
searchInput.TextColor3 = Color3.new(1, 1, 1)
searchInput.PlaceholderColor3 = Color3.new(0.6, 0.6, 0.6)
searchInput.TextSize = 14
searchInput.Parent = searchFrame

-- 导航按钮（新增“飞行功能”标签）
local navButtons = {
    {Name = "通用", Pos = UDim2.new(0.05, 0, 0.1, 0)},
    {Name = "游戏信息", Pos = UDim2.new(0.05, 0, 0.18, 0)},
    {Name = "玩家功能", Pos = UDim2.new(0.05, 0, 0.26, 0), IsHighlighted = true},
    {Name = "飞行功能", Pos = UDim2.new(0.05, 0, 0.34, 0)},
    {Name = "主要功能", Pos = UDim2.new(0.05, 0, 0.42, 0)}
}

local activeNavBtn = nil
for _, btnInfo in ipairs(navButtons) do
    local navBtn = createNavButton(btnInfo.Name, btnInfo.Pos)
    if btnInfo.IsHighlighted then
        navBtn.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
        activeNavBtn = navBtn
    end
    -- 导航按钮点击切换
    navBtn.MouseButton1Click:Connect(function()
        if activeNavBtn then
            activeNavBtn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
        end
        navBtn.BackgroundColor3 = Color3.new(0.35, 0.35, 0.35)
        activeNavBtn = navBtn
        -- 切换到飞行功能面板
        if btnInfo.Name == "飞行功能" then
            showFlyPanel()
        else
            hideFlyPanel()
        end
    end)
end

-- 4. 右侧内容面板
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -150, 1, -30)
contentPanel.Position = UDim2.new(0, 150, 0, 30)
contentPanel.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
contentPanel.Parent = mainWindow

-- 基础信息面板（默认显示）
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(1, 0, 1, 0)
infoPanel.BackgroundTransparency = 1
infoPanel.Parent = contentPanel

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(1, 0, 0, 25)
contentTitle.Position = UDim2.new(0, 0, 0.05, 0)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "您的游戏名称："
contentTitle.TextColor3 = Color3.new(1, 1, 1)
contentTitle.TextSize = 16
contentTitle.Parent = infoPanel

local copyNameBtn = createContentButton("复制您的名称", UDim2.new(0.2, 0, 0.15, 0))
copyNameBtn.MouseButton1Click:Connect(function()
    setclipboard(tostring(game.GameId))
    print("已复制游戏ID到剪贴板")
end)

local userNameTitle = Instance.new("TextLabel")
userNameTitle.Size = UDim2.new(1, 0, 0, 25)
userNameTitle.Position = UDim2.new(0, 0, 0.3, 0)
userNameTitle.BackgroundTransparency = 1
userNameTitle.Text = "您的游戏用户名："
userNameTitle.TextColor3 = Color3.new(1, 1, 1)
userNameTitle.TextSize = 16
userNameTitle.Parent = infoPanel

local copyUsernameBtn = createContentButton("复制您的用户名", UDim2.new(0.2, 0, 0.4, 0))
copyUsernameBtn.MouseButton1Click:Connect(function()
    setclipboard(player.Name)
    print("已复制用户名：" .. player.Name)
end)

-- 5. 飞行功能面板（点击导航栏“飞行功能”显示）
local flyPanel = Instance.new("Frame")
flyPanel.Size = UDim2.new(1, 0, 1, 0)
flyPanel.BackgroundTransparency = 1
flyPanel.Visible = false
flyPanel.Parent = contentPanel

-- 飞行开关按钮
local flyToggleBtn = createContentButton("开启飞行", UDim2.new(0.2, 0, 0.1, 0))
flyToggleBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
flyToggleBtn.Parent = flyPanel
flyToggleBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    humanoid.PlatformStand = isFlying
    flyToggleBtn.Text = isFlying and "关闭飞行" or "开启飞行"
    flyToggleBtn.BackgroundColor3 = isFlying and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
    player:SendNotification(isFlying and "飞行已开启（WASD/方向键控制，空格上升，Shift下降）" or "飞行已关闭")
end)

-- 飞行速度调节滑动条
local speedSlider = createSlider("飞行速度", UDim2.new(0.2, 0, 0.25, 0))
speedSlider.Parent = flyPanel
speedSlider.Slider.MouseButton1Down:Connect(function()
    local mouseDown = true
    while mouseDown do
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos.X - speedSlider.Slider.AbsolutePosition.X
        local percentage = math.clamp(relativePos / speedSlider.Slider.AbsoluteSize.X, 0, 1)
        speedSlider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
        flySpeed = math.floor(percentage * 100)
        speedSlider.Value.Text = "当前：" .. flySpeed
        wait()
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = false
            end
        end)
    end
end)

-- 6. 飞行控制逻辑
RunService.Heartbeat:Connect(function()
    if not isFlying or not rootPart then return end
    
    -- 电脑端键盘控制
    moveDir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
        moveDir += Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
        moveDir += Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
        moveDir += Vector3.new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
        moveDir += Vector3.new(1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDir += Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDir += Vector3.new(0, -1, 0)
    end
    
    -- 适配相机方向
    local camera = workspace.CurrentCamera
    local lookDir = camera.CFrame.LookVector
    lookDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit
    local rightDir = camera.CFrame.RightVector.Unit
    
    local finalDir = (lookDir * moveDir.Z) + (rightDir * moveDir.X) + Vector3.new(0, moveDir.Y, 0)
    rootPart.Velocity = finalDir * flySpeed
end)

-- 7. 角色重生后重新绑定
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    isFlying = false
    flyToggleBtn.Text = "开启飞行"
    flyToggleBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
end)

-- 8. 工具函数
function createWindowBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 25)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = titleBar
    return btn
end

function createNavButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    btn.CornerRadius = UDim.new(0, 3)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = navBar
    return btn
end

function createContentButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.6, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    btn.CornerRadius = UDim.new(0, 5)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    return btn
end

function createSlider(labelText, pos)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0.6, 0, 0, 40)
    sliderContainer.Position = pos
    sliderContainer.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Parent = sliderContainer

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    slider.Parent = sliderContainer

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    fill.Parent = slider

    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(1, 0, 0, 20)
    valueText.Position = UDim2.new(0, 0, 0.5, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = "当前：50"
    valueText.TextColor3 = Color3.new(1, 1, 1)
    valueText.TextSize = 12
    valueText.Parent = sliderContainer

    return {Slider = slider, Fill = fill, Value = valueText, Parent = sliderContainer.Parent}
end

function showFlyPanel()
    infoPanel.Visible = false
    flyPanel.Visible = true
end

function hideFlyPanel()
    flyPanel.Visible = false
    infoPanel.Visible = true
end

-- 9. 窗口拖拽功能
local isDragging = false
local dragStartPos = Vector2.new()
local windowStartPos = UDim2.new()

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPos = input.Position
        windowStartPos = mainWindow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        mainWindow.Position = UDim2.new(
            windowStartPos.X.Scale,
            windowStartPos.X.Offset + delta.X,
            windowStartPos.Y.Scale,
            windowStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
