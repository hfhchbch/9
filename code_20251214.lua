local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- 1. 创建主UI容器
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "GameFunctionUI"
mainGui.IgnoreGuiInset = true -- 忽略屏幕安全区（适配全面屏）
mainGui.Parent = playerGui

-- 2. 主面板（可折叠）
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 200, 0, 300)
mainPanel.Position = UDim2.new(0.02, 0, 0.5, -150)
mainPanel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
mainPanel.BorderColor3 = Color3.new(0.4, 0.4, 0.4)
mainPanel.BorderSizePixel = 2
mainPanel.ClipsDescendants = true -- 裁剪超出面板的内容
mainPanel.Parent = mainGui

-- 面板标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
titleBar.Parent = mainPanel

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.8, 0, 1, 0)
titleText.Position = UDim2.new(0.1, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "功能面板"
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.TextSize = 18
titleText.Parent = titleBar

-- 折叠/展开按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(1, -30, 0, 0)
toggleBtn.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
toggleBtn.Text = "−"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 20
toggleBtn.Parent = titleBar

local isPanelOpen = true
toggleBtn.MouseButton1Click:Connect(function()
    isPanelOpen = not isPanelOpen
    mainPanel.Size = isPanelOpen and UDim2.new(0, 200, 0, 300) or UDim2.new(0, 200, 0, 30)
    toggleBtn.Text = isPanelOpen and "−" or "+"
end)

-- 3. 功能按钮（示例：飞行开关、速度调节、退出按钮）
-- 飞行开关按钮
local flyBtn = createFunctionButton("飞行开关", UDim2.new(0.1, 0, 0.15, 0))
flyBtn.MouseButton1Click:Connect(function()
    -- 此处可绑定之前的飞行开关逻辑
    print("飞行开关被点击")
    flyBtn.BackgroundColor3 = flyBtn.BackgroundColor3 == Color3.new(0.2, 0.6, 0.2) and Color3.new(0.6, 0.2, 0.2) or Color3.new(0.2, 0.6, 0.2)
end)

-- 速度调节滑动条
local speedSlider = createSlider("飞行速度", UDim2.new(0.1, 0, 0.3, 0))
speedSlider.Slider.MouseButton1Down:Connect(function()
    local mouseDown = true
    while mouseDown do
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos.X - speedSlider.Slider.AbsolutePosition.X
        local percentage = math.clamp(relativePos / speedSlider.Slider.AbsoluteSize.X, 0, 1)
        speedSlider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
        speedSlider.Value.Text = "当前：" .. math.floor(percentage * 100)
        wait()
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = false
            end
        end)
    end
end)

-- 退出按钮
local exitBtn = createFunctionButton("关闭面板", UDim2.new(0.1, 0, 0.8, 0))
exitBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
exitBtn.MouseButton1Click:Connect(function()
    mainGui.Enabled = false
end)

-- 4. UI创建工具函数
-- 功能按钮创建
function createFunctionButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    btn.BorderSizePixel = 1
    btn.Parent = mainPanel
    return btn
end

-- 滑动条创建
function createSlider(labelText, pos)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0.8, 0, 0, 40)
    sliderContainer.Position = pos
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = mainPanel

    -- 滑动条标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Parent = sliderContainer

    -- 滑动条轨道
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    slider.Parent = sliderContainer

    -- 滑动条填充
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    fill.Parent = slider

    -- 数值显示
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(1, 0, 0, 20)
    valueText.Position = UDim2.new(0, 0, 0.5, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = "当前：50"
    valueText.TextColor3 = Color3.new(1, 1, 1)
    valueText.TextSize = 12
    valueText.Parent = sliderContainer

    return {
        Slider = slider,
        Fill = fill,
        Value = valueText
    }
end

-- 5. 显示面板快捷键（电脑端按F3，手机端可添加悬浮按钮）
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F3 then
        mainGui.Enabled = not mainGui.Enabled
    end
end)

-- 手机端悬浮显示按钮
if UserInputService.TouchEnabled then
    local showBtn = Instance.new("TextButton")
    showBtn.Size = UDim2.new(0, 60, 0, 60)
    showBtn.Position = UDim2.new(0.05, 0, 0.9, -60)
    showBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    showBtn.Text = "功能"
    showBtn.TextColor3 = Color3.new(1, 1, 1)
    showBtn.TextSize = 14
    showBtn.BorderSizePixel = 1
    showBtn.BorderColor3 = Color3.new(0.6, 0.6, 0.6)
    showBtn.Parent = mainGui
    showBtn.MouseButton1Click:Connect(function()
        mainGui.Enabled = not mainGui.Enabled
    end)
end
