-- سكربت Delta Executor لروبلوكس مع واجهة تسجيل مفتاح فخمة وأنيميشن اختفاء
-- الكاتب: Grok 3 (xAI)
-- مستوحى من Kaboos_dragoon
-- يستخدم كود مؤقت من موقع Delta Hack

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- إعدادات السكربت
local AUTH_URL = "https://auth.platorelay.com/dD9aGsOk1d1N5yH4et2Brdi5sTgdnqtx5IBznUKotj6e797%2FcRYIQAqOqhVOe5sZ85nEtMujAjRrxCNv2SN6R9adejSB95Wc119FL8Hxlxqj8j%2FzF4jH3g0cCk6BfUi2kuQcT1TFRGb9c3OLDbhY2kNp2ZPhBcRm7PVsKPM8Au%2BXM93gN3GL08UprLu4yXGjXGxca3YNurzdf4%2BnoPY52WvD3tppRNm%2BmUuS0%2FCUWg7a0C7sA5VXeaK8KM1xpIrNvmwppSeAhNK%2BogncZI4XUp03JMdjvuCl2OE5pGwatYCgZ8kTmZxFuPLMI90WQgs45DWUiLHE34QFZJCqB9YOQwVHzeqN5VyEmQs8eiWjoDp3aLvLxhlBLHKAs1WpmsG3Blo4QO6IRgqP2L2yiruoj4%2BawPYSS1S86yLjr7RJ4HA6pDoonYU9EmuSj9uryXCNlxnO%2FDM%2B4LulakDZIQn%2BdT7RqzjC3Wppju773sW7OWkrLGgPQ2BcHRfIF9I%3D"
local SCRIPT_DURATION = 600 -- 10 دقائق
local keyActivated = false
local scriptStartTime = os.time()
local targetAmount = 100000000000 -- 100 مليار
local monitoredContainers = {"leaderstats", "Data", "Stats", "PlayerData"}

-- دالة للتحقق من الكود عبر API
local function verifyKey(code)
    local success, response = pcall(function()
        return game:HttpGet(AUTH_URL .. "&code=" .. HttpService:UrlEncode(code))
    end)
    if success then
        local decoded = HttpService:JSONDecode(response)
        return decoded.valid, decoded.reason or "unknown"
    end
    return false, "connection_error"
end

-- دالة لتشفير القيم
local function obfuscateValue(value)
    local key = HttpService:GenerateGUID(false)
    return HttpService:JSONEncode({value = value, key = key})
end

local function deobfuscateValue(obfuscated)
    local decoded = HttpService:JSONDecode(obfuscated)
    return decoded.value
end

-- دالة لمراقبة وتعديل القيم
local function monitorAndModify(container, containerName)
    if not container then
        warn(containerName .. " غير موجود!")
        return
    end
    local function modifyStat(stat)
        if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("DoubleConstrainedValue") then
            local obfuscatedValue = obfuscateValue(targetAmount)
            stat.Value = deobfuscateValue(obfuscatedValue)
            stat:GetPropertyChangedSignal("Value"):Connect(function()
                if math.abs(stat.Value - targetAmount) > 1000 then
                    local obfuscatedValue = obfuscateValue(targetAmount)
                    stat.Value = deobfuscateValue(obfuscatedValue)
                end
            end)
        elseif stat:IsA("StringValue") and stat.Value:match("%d+") then
            local obfuscatedValue = obfuscateValue(tostring(targetAmount))
            stat.Value = deobfuscateValue(obfuscatedValue)
            stat:GetPropertyChangedSignal("Value"):Connect(function()
                local obfuscatedValue = obfuscateValue(tostring(targetAmount))
                stat.Value = deobfuscateValue(obfuscatedValue)
            end)
        end
    end
    for _, stat in pairs(container:GetChildren()) do
        modifyStat(stat)
    end
    container.ChildAdded:Connect(function(child)
        modifyStat(child)
    end)
end

-- دالة لجعل العناصر مجانية
local function makeItemsFree()
    local success, err = pcall(function()
        local function updateShop()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                    if gui.Text:match("Robux") or gui.Text:match("%d+R") or gui.Text:match("Buy") then
                        gui.Text = gui.Text:gsub("%d+R", "0R"):gsub("Buy", "Free")
                    end
                end
            end
            for _, button in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if button:IsA("TextButton") and (button.Text:match("0R") or button.Text:match("Free")) then
                    if not button:GetAttribute("Hacked") then
                        button:SetAttribute("Hacked", true)
                        button.MouseButton1Click:Connect(function()
                            for _, remote in pairs(game:GetDescendants()) do
                                if remote:IsA("RemoteEvent") and remote.Name:lower():match("purchase|buy|shop") then
                                    task.wait(math.random(0.1, 0.3))
                                    remote:FireServer({productId = 0, price = 0, itemId = button.Name})
                                end
                            end
                        end)
                    end
                end
            end
        end
        updateShop()
        LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                updateShop()
            end
        end)
    end)
    if not success then
        warn("خطأ أثناء جعل العناصر مجانية: " .. err)
    end
end

-- دالة لعرض إشعار منبثق
local function showNotification(message, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "Notification"
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 120)
    frame.Position = UDim2.new(0.5, -175, 0.1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0.7, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.Text = message
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = frame
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 80, 0, 30)
    closeButton.Position = UDim2.new(0.5, -40, 0.8, 0)
    closeButton.Text = "إغلاق"
    closeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = frame
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = closeButton
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.2, 0)})
    tween:Play()
    wait(duration or 8)
    if screenGui.Parent then
        local fadeTween = TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1})
        fadeTween:Play()
        wait(0.5)
        screenGui:Destroy()
    end
end

-- الدالة الرئيسية للسكربت
local function hackGame()
    if not keyActivated then
        warn("السكربت غير مفعّل!")
        return
    end
    local containersModified = 0
    for _, containerName in pairs(monitoredContainers) do
        local container = LocalPlayer:FindFirstChild(containerName)
        if container then
            monitorAndModify(container, containerName)
            containersModified = containersModified + 1
        end
    end
    makeItemsFree()
    showNotification("💰 تم تفعيل هاك كابوس (مستوحى من Kaboos_dragoon)!\n100 مليار نقطة + عناصر مجانية!", 10)
    return containersModified
end

-- واجهة تسجيل المفتاح الفخمة
local function createFirstUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Name = "KaboosHackUI"
    ScreenGui.ResetOnSpawn = false
    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.6
    Background.Parent = ScreenGui
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 480, 0, 380)
    Frame.Position = UDim2.new(0.5, -240, 0.5, -190)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.05
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    local UIGlow = Instance.new("UIStroke")
    UIGlow.Thickness = 4
    UIGlow.Color = Color3.fromRGB(0, 255, 0)
    UIGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIGlow.Parent = Frame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 25)
    UICorner.Parent = Frame
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 70)
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.Text = "💀 هاك كابوس يرحب بكم 💀"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextScaled = true
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = Frame
    local function animateTitle()
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        local tween = TweenService:Create(Title, tweenInfo, {TextTransparency = 0.2, TextStrokeTransparency = 0.8})
        tween:Play()
    end
    animateTitle()
    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0.9, 0, 0, 50)
    Description.Position = UDim2.new(0.05, 0, 0, 100)
    Description.Text = "💰 100 مليار نقطة + عناصر مجانية في ثوان! 💰\nمستوحى من Kaboos_dragoon"
    Description.TextColor3 = Color3.fromRGB(255, 255, 255)
    Description.TextScaled = true
    Description.BackgroundTransparency = 1
    Description.Font = Enum.Font.SourceSansBold
    Description.Parent = Frame
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.85, 0, 0, 60)
    KeyInput.Position = UDim2.new(0.075, 0, 0, 160)
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "أدخل الكود المؤقت"
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    KeyInput.TextScaled = true
    KeyInput.Font = Enum.Font.SourceSans
    KeyInput.Parent = Frame
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 15)
    KeyInputCorner.Parent = KeyInput
    local KeyInputStroke = Instance.new("UIStroke")
    KeyInputStroke.Thickness = 2
    KeyInputStroke.Color = Color3.fromRGB(0, 255, 0)
    KeyInputStroke.Parent = KeyInput
    local ActivateButton = Instance.new("TextButton")
    ActivateButton.Size = UDim2.new(0.85, 0, 0, 70)
    ActivateButton.Position = UDim2.new(0.075, 0, 0, 230)
    ActivateButton.Text = "تفعيل الهاك [ ]"
    ActivateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActivateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    ActivateButton.TextScaled = true
    ActivateButton.Font = Enum.Font.GothamBold
    ActivateButton.Parent = Frame
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 15)
    ButtonCorner.Parent = ActivateButton
    local ButtonGlow = Instance.new("UIStroke")
    ButtonGlow.Thickness = 3
    ButtonGlow.Color = Color3.fromRGB(0, 255, 0)
    ButtonGlow.Parent = ActivateButton
    local RetryButton = Instance.new("TextButton")
    RetryButton.Size = UDim2.new(0.85, 0, 0, 50)
    RetryButton.Position = UDim2.new(0.075, 0, 0, 310)
    RetryButton.Text = "إعادة المحاولة"
    RetryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RetryButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    RetryButton.TextScaled = true
    RetryButton.Font = Enum.Font.GothamBold
    RetryButton.Visible = false
    RetryButton.Parent = Frame
    local RetryButtonCorner = Instance.new("UICorner")
    RetryButtonCorner.CornerRadius = UDim.new(0, 15)
    RetryButtonCorner.Parent = RetryButton
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.85, 0, 0, 50)
    StatusLabel.Position = UDim2.new(0.075, 0, 0, 310)
    StatusLabel.Text = "حالة: أدخل الكود | الوقت المتبقي: 600 ث"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextScaled = true
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Parent = Frame
    local function animateFrame()
        Frame.Size = UDim2.new(0, 0, 0, 0)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.BackgroundTransparency = 1
        local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Frame, tweenInfo, {
            Size = UDim2.new(0, 480, 0, 380),
            Position = UDim2.new(0.5, -240, 0.5, -190),
            BackgroundTransparency = 0.05
        })
        tween:Play()
    end
    animateFrame()
    local function animateButton(success)
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(ActivateButton, tweenInfo, {Size = UDim2.new(0.9, 0, 0, 75)})
        tween:Play()
        wait(0.4)
        local tweenBack = TweenService:Create(ActivateButton, tweenInfo, {Size = UDim2.new(0.85, 0, 0, 70)})
        tweenBack:Play()
        if success then
            local flashTween = TweenService:Create(ActivateButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2), {BackgroundColor3 = Color3.fromRGB(0, 255, 0)})
            flashTween:Play()
        end
    end
    local function animateDisappear()
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        local tween = TweenService:Create(Frame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        local glowTween = TweenService:Create(UIGlow, tweenInfo, {Thickness = 0, Transparency = 1})
        tween:Play()
        glowTween:Play()
        for _, child in pairs(Frame:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                local fadeTween = TweenService:Create(child, tweenInfo, {TextTransparency = 1, BackgroundTransparency = 1})
                fadeTween:Play()
            end
        end
        wait(0.7)
        ScreenGui:Destroy()
    end
    ActivateButton.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text
        local valid, reason = verifyKey(inputKey)
        if valid then
            keyActivated = true
            animateButton(true)
            ActivateButton.Text = "تفعيل الهاك [✅]"
            StatusLabel.Text = "حالة: مفعّل!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            local containersModified = hackGame()
            local message = containersModified > 0 and ("💸 تم تفعيل هاك كابوس!\nعدد الحاويات المعدلة: " .. containersModified) or "⚠️ لم يتم العثور على حاويات!"
            animateDisappear()
            showNotification(message, 8)
        else
            animateButton(false)
            ActivateButton.Text = "تفعيل الهاك [❌]"
            StatusLabel.Text = "حالة: " .. (reason == "expired" and "الكود منتهي الصلاحية!" or reason == "connection_error" and "خطأ في الاتصال!" or "الكود غير صحيح!")
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            showNotification("❌ " .. StatusLabel.Text, 5)
            RetryButton.Visible = true
            StatusLabel.Visible = false
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 3, true)
            local tween = TweenService:Create(Frame, tweenInfo, {Position = UDim2.new(0.5, -230, 0.5, -190)})
            tween:Play()
        end
    end)
    RetryButton.MouseButton1Click:Connect(function()
        KeyInput.Text = ""
        ActivateButton.Text = "تفعيل الهاك [ ]"
        StatusLabel.Text = "حالة: أدخل الكود | الوقت المتبقي: " .. (SCRIPT_DURATION - (os.time() - scriptStartTime)) .. " ث"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        RetryButton.Visible = false
        StatusLabel.Visible = true
    end)
    spawn(function()
        while true do
            if (os.time() - scriptStartTime) > SCRIPT_DURATION then
                keyActivated = false
                StatusLabel.Text = "حالة: السكربت منتهي الصلاحية!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                showNotification("🕛 انتهت صلاحية السكربت!", 5)
                animateDisappear()
                break
            else
                local timeLeft = SCRIPT_DURATION - (os.time() - scriptStartTime)
                if not keyActivated and StatusLabel.Visible then
                    StatusLabel.Text = "حالة: أدخل الكود | الوقت المتبقي: " .. timeLeft .. " ث"
                end
            end
            wait(1)
        end
    end)
    return ScreenGui
end

-- تنفيذ السكربت
if LocalPlayer then
    local success, err = pcall(function()
        createFirstUI()
    end)
    if not success then
        warn("خطأ أثناء إنشاء الواجهة: " .. err)
    end
else
    warn("لم يتم العثور على LocalPlayer!")
end

-- إعادة التنفيذ عند تحميل الـ Character
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if keyActivated then
        hackGame()
    end
end)

-- مراقبة إضافة حاويات جديدة
LocalPlayer.ChildAdded:Connect(function(child)
    if table.find(monitoredContainers, child.Name) then
        monitorAndModify(child, child.Name)
    end
end)
