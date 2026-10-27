--[[
    Bottle Autofarm v2 - Autofarm + Auto Hunt + Anti-AFK
    LocalScript em StarterPlayerScripts
    Ambiente: Roblox Studio (jogo próprio / autorizado)

    Recursos:
      - Salvar posições com L (evita duplicatas próximas)
      - Autofarm com 2 modos: "ordem da lista" e "mais próxima"
      - Auto Hunt: escaneia workspace procurando bottles
      - Anti-AFK via VirtualUser
      - UI escura, moderna, arrastável, minimizável
]]

--== SERVIÇOS ==--
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local VirtualUser        = game:GetService("VirtualUser")
local CollectionService  = game:GetService("CollectionService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--== CONFIGURAÇÕES ==--
local CONFIG = {
    DEFAULT_SPEED          = 50,
    DEFAULT_WAIT_TIME      = 1,
    MIN_DISTANCE           = 5,       -- distância mínima entre posições salvas
    UI_SIZE                = UDim2.new(0, 420, 0, 570),
    UI_POSITION            = UDim2.new(0, 20, 0, 20),
    COLOR_BG               = Color3.fromRGB(18, 18, 18),
    COLOR_PANEL            = Color3.fromRGB(28, 28, 28),
    COLOR_ACCENT           = Color3.fromRGB(139, 0, 0),
    COLOR_ACCENT_LIGHT     = Color3.fromRGB(178, 34, 34),
    COLOR_TEXT             = Color3.fromRGB(240, 240, 240),
    COLOR_TEXT_DIM         = Color3.fromRGB(170, 170, 170),
    COLOR_SUCCESS          = Color3.fromRGB(0, 180, 0),
    COLOR_ERROR            = Color3.fromRGB(220, 50, 50),
    FONT                   = Enum.Font.Gotham,
    FONT_BOLD              = Enum.Font.GothamBold,
    -- Auto Hunt
    AUTO_HUNT_RADIUS       = 800,
    AUTO_HUNT_SCAN_INTERVAL = 1,
    BOTTLE_TAG             = "Bottle",
    BOTTLE_NAME            = "Bottle",
}

--== ESTADO ==--
local state = {
    positions        = {},
    travelMode       = "nearest",  -- "nearest" ou "sequential"
    autofarmActive   = false,
    autoHuntActive   = false,
    antiAfkActive    = false,
    speed            = CONFIG.DEFAULT_SPEED,
    waitTime         = CONFIG.DEFAULT_WAIT_TIME,
    autofarmTask     = nil,
    huntTask         = nil,
    antiAfkConnection = nil,
    character        = nil,
    humanoid         = nil,
    rootPart         = nil,
    bodyVelocity     = nil,
    connections      = {},
}

local ui = {}

--== UTILITÁRIOS ==--

local function notify(message, color)
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 320, 0, 50)
    toast.Position = UDim2.new(0.5, -160, 0, 20)
    toast.BackgroundColor3 = CONFIG.COLOR_PANEL
    toast.BorderSizePixel = 0
    toast.ZIndex = 100
    toast.Parent = playerGui
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = color or CONFIG.COLOR_ACCENT
    stroke.Thickness = 2

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = CONFIG.COLOR_TEXT
    label.Font = CONFIG.FONT
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toast

    toast.BackgroundTransparency = 1
    label.TextTransparency = 1
    TweenService:Create(toast, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(3, function()
        TweenService:Create(toast, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        toast:Destroy()
    end)
end

local function updateUI()
    if not ui.mainFrame then return end

    ui.statusLabel.Text = state.autofarmActive and "Status: Autofarm ATIVO"
        or (state.autoHuntActive and "Status: Auto Hunt ATIVO" or "Status: Desligado")
    ui.statusLabel.TextColor3 = (state.autofarmActive or state.autoHuntActive)
        and CONFIG.COLOR_SUCCESS or CONFIG.COLOR_TEXT_DIM

    ui.autofarmButton.Text = state.autofarmActive and "Desativar Autofarm" or "Ativar Autofarm"
    ui.autofarmButton.BackgroundColor3 = state.autofarmActive and CONFIG.COLOR_ERROR or CONFIG.COLOR_ACCENT

    ui.huntButton.Text = state.autoHuntActive and "Auto Hunt: ON" or "Auto Hunt: OFF"
    ui.huntButton.BackgroundColor3 = state.autoHuntActive and CONFIG.COLOR_SUCCESS or CONFIG.COLOR_PANEL

    ui.antiAfkButton.Text = state.antiAfkActive and "Anti-AFK: ON" or "Anti-AFK: OFF"
    ui.antiAfkButton.BackgroundColor3 = state.antiAfkActive and CONFIG.COLOR_SUCCESS or CONFIG.COLOR_PANEL

    ui.modeButton.Text = (state.travelMode == "nearest")
        and "Modo: Mais Próxima" or "Modo: Ordem da Lista"

    ui.positionCountLabel.Text = "Posições salvas: " .. #state.positions
end

local function updatePositionList()
    if not ui.positionList then return end
    for _, child in ipairs(ui.positionList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, pos in ipairs(state.positions) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, -10, 0, 30)
        item.BackgroundColor3 = CONFIG.COLOR_PANEL
        item.BorderSizePixel = 0
        item.Parent = ui.positionList
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = string.format("Posição %d (%.0f, %.0f, %.0f)", i, pos.X, pos.Y, pos.Z)
        label.TextColor3 = CONFIG.COLOR_TEXT
        label.Font = CONFIG.FONT
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = item

        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 50, 0, 24)
        removeBtn.Position = UDim2.new(1, -60, 0.5, -12)
        removeBtn.BackgroundColor3 = CONFIG.COLOR_ERROR
        removeBtn.Text = "X"
        removeBtn.TextColor3 = CONFIG.COLOR_TEXT
        removeBtn.Font = CONFIG.FONT_BOLD
        removeBtn.TextSize = 14
        removeBtn.Parent = item
        Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)

        removeBtn.MouseButton1Click:Connect(function()
            table.remove(state.positions, i)
            updatePositionList()
            updateUI()
            notify("Posição " .. i .. " removida.", CONFIG.COLOR_TEXT_DIM)
        end)
    end
end

--== PERSONAGEM ==--

local function onCharacterAdded(character)
    state.character = character
    state.humanoid  = character:WaitForChild("Humanoid")
    state.rootPart  = character:WaitForChild("HumanoidRootPart")

    -- Reinicia o loop que estiver ativo
    if state.autofarmActive and not state.autofarmTask then
        state.autofarmTask = task.spawn(function() autofarmLoop() end)
    end
    if state.autoHuntActive and not state.huntTask then
        state.huntTask = task.spawn(function() autoHuntLoop() end)
    end
end

--== MOVIMENTAÇÃO ==--

local function moveToPosition(target, speed)
    if not state.rootPart or not state.humanoid then return false end

    if not state.bodyVelocity or not state.bodyVelocity.Parent then
        state.bodyVelocity = Instance.new("BodyVelocity")
        state.bodyVelocity.Name = "AutofarmVelocity"
        state.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        state.bodyVelocity.Parent = state.rootPart
    end

    local bv = state.bodyVelocity
    local distanceThreshold = 2
    local maxTime = 10
    local startTime = tick()

    while state.autofarmActive or state.autoHuntActive do
        if not state.rootPart or not state.humanoid or state.humanoid.Health <= 0 then
            break
        end
        local currentPos = state.rootPart.Position
        local direction = target - currentPos
        local distance = direction.Magnitude
        if distance < distanceThreshold then break end
        if tick() - startTime > maxTime then break end

        bv.Velocity = direction.Unit * speed
        RunService.Heartbeat:Wait()
    end

    if bv then bv.Velocity = Vector3.zero end
    return true
end

--== AUTOFARM ==--

function autofarmLoop()
    local visited   = {}
    local seqIndex  = 1

    while state.autofarmActive do
        if #state.positions == 0 then
            notify("Nenhuma posição salva!", CONFIG.COLOR_ERROR)
            state.autofarmActive = false
            updateUI()
            break
        end

        -- Aguarda respawn se necessário
        if not state.humanoid or state.humanoid.Health <= 0 then
            repeat task.wait(0.5)
            until (state.humanoid and state.humanoid.Health > 0) or not state.autofarmActive
            if not state.autofarmActive then break end
        end

        local target

        if state.travelMode == "nearest" then
            -- reseta quando visitou todas
            local vc = 0
            for _ in pairs(visited) do vc += 1 end
            if vc >= #state.positions then visited = {} end

            local myPos = state.rootPart.Position
            local bestDist = math.huge
            for i, pos in ipairs(state.positions) do
                if not visited[i] then
                    local d = (pos - myPos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        target = pos
                        visited[i] = true
                    end
                end
            end
        else
            if seqIndex > #state.positions then seqIndex = 1 end
            target = state.positions[seqIndex]
            seqIndex += 1
        end

        if not target then break end
        if not moveToPosition(target, state.speed) then break end
        if state.humanoid then state.humanoid.Jump = true end
        task.wait(state.waitTime)
    end

    if state.bodyVelocity then
        state.bodyVelocity:Destroy()
        state.bodyVelocity = nil
    end
    state.autofarmTask = nil
end

local function startAutofarm()
    if #state.positions == 0 then
        notify("Salve pelo menos uma posição antes de iniciar.", CONFIG.COLOR_ERROR)
        return
    end
    if state.autofarmActive then return end

    -- Desliga o Auto Hunt para não brigar
    if state.autoHuntActive then
        state.autoHuntActive = false
        if state.huntTask then task.cancel(state.huntTask); state.huntTask = nil end
    end

    state.autofarmActive = true
    updateUI()
    state.autofarmTask = task.spawn(autofarmLoop)
    notify("Autofarm ativado (modo: " ..
        (state.travelMode == "nearest" and "mais próxima" or "ordem da lista") .. ").",
        CONFIG.COLOR_SUCCESS)
end

local function stopAutofarm()
    if not state.autofarmActive then return end
    state.autofarmActive = false
    if state.autofarmTask then
        task.cancel(state.autofarmTask)
        state.autofarmTask = nil
    end
    if state.bodyVelocity then
        state.bodyVelocity.Velocity = Vector3.zero
        state.bodyVelocity:Destroy()
        state.bodyVelocity = nil
    end
    updateUI()
    notify("Autofarm desativado.", CONFIG.COLOR_TEXT_DIM)
end

--== AUTO HUNT ==--

local function scanForBottles()
    local found = {}
    for _, obj in ipairs(CollectionService:GetTagged(CONFIG.BOTTLE_TAG)) do
        if obj:IsA("BasePart") and obj.Parent then table.insert(found, obj) end
    end
    if #found == 0 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == CONFIG.BOTTLE_NAME and obj.Parent then
                table.insert(found, obj)
            end
        end
    end
    return found
end

local function findNearestBottle()
    if not state.rootPart then return nil end
    local myPos = state.rootPart.Position
    local bottles = scanForBottles()
    local nearest, nearestDist = nil, CONFIG.AUTO_HUNT_RADIUS
    for _, bottle in ipairs(bottles) do
        local d = (bottle.Position - myPos).Magnitude
        if d < nearestDist then nearest, nearestDist = bottle, d end
    end
    return nearest
end

function autoHuntLoop()
    while state.autoHuntActive do
        if not state.rootPart or not state.humanoid or state.humanoid.Health <= 0 then
            task.wait(0.5)
        else
            local bottle = findNearestBottle()
            if bottle then
                moveToPosition(bottle.Position, state.speed)
                if bottle.Parent and state.humanoid then state.humanoid.Jump = true end
                task.wait(0.3)
            else
                task.wait(CONFIG.AUTO_HUNT_SCAN_INTERVAL)
            end
        end
    end
    if state.bodyVelocity then
        state.bodyVelocity:Destroy()
        state.bodyVelocity = nil
    end
    state.huntTask = nil
end

local function startAutoHunt()
    if state.autoHuntActive then return end

    -- Desliga autofarm para não brigar
    if state.autofarmActive then
        state.autofarmActive = false
        if state.autofarmTask then task.cancel(state.autofarmTask); state.autofarmTask = nil end
    end

    state.autoHuntActive = true
    state.huntTask = task.spawn(autoHuntLoop)
    updateUI()
    notify("Auto Hunt ativado.", CONFIG.COLOR_SUCCESS)
end

local function stopAutoHunt()
    if not state.autoHuntActive then return end
    state.autoHuntActive = false
    if state.huntTask then task.cancel(state.huntTask); state.huntTask = nil end
    if state.bodyVelocity then
        state.bodyVelocity.Velocity = Vector3.zero
        state.bodyVelocity:Destroy()
        state.bodyVelocity = nil
    end
    updateUI()
    notify("Auto Hunt desativado.", CONFIG.COLOR_TEXT_DIM)
end

--== ANTI-AFK ==--

local function startAntiAfk()
    if state.antiAfkActive then return end
    state.antiAfkActive = true
    state.antiAfkConnection = player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    updateUI()
    notify("Anti-AFK ativado.", CONFIG.COLOR_SUCCESS)
end

local function stopAntiAfk()
    if not state.antiAfkActive then return end
    state.antiAfkActive = false
    if state.antiAfkConnection then
        state.antiAfkConnection:Disconnect()
        state.antiAfkConnection = nil
    end
    updateUI()
    notify("Anti-AFK desativado.", CONFIG.COLOR_TEXT_DIM)
end

--== SALVAR POSIÇÃO ==--

local function savePosition()
    if not state.rootPart then
        notify("Personagem não encontrado.", CONFIG.COLOR_ERROR)
        return
    end
    local pos = state.rootPart.Position
    for _, existing in ipairs(state.positions) do
        if (existing - pos).Magnitude < CONFIG.MIN_DISTANCE then
            notify("Posição muito próxima de uma já salva.", CONFIG.COLOR_ERROR)
            return
        end
    end
    table.insert(state.positions, pos)
    updatePositionList()
    updateUI()
    notify("Posição " .. #state.positions .. " salva!", CONFIG.COLOR_SUCCESS)
end

--== UI ==--

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BottleAutofarmUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = CONFIG.UI_SIZE
    mainFrame.Position = CONFIG.UI_POSITION
    mainFrame.BackgroundColor3 = CONFIG.COLOR_BG
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = CONFIG.COLOR_ACCENT
    stroke.Thickness = 2

    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Bottle Autofarm"
    title.TextColor3 = CONFIG.COLOR_TEXT
    title.Font = CONFIG.FONT_BOLD
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame

    -- Minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 10)
    minimizeBtn.BackgroundColor3 = CONFIG.COLOR_PANEL
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = CONFIG.COLOR_TEXT
    minimizeBtn.Font = CONFIG.FONT_BOLD
    minimizeBtn.TextSize = 16
    minimizeBtn.Parent = mainFrame
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

    -- Fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = CONFIG.COLOR_ERROR
    closeBtn.Text = "X"
    closeBtn.TextColor3 = CONFIG.COLOR_TEXT
    closeBtn.Font = CONFIG.FONT_BOLD
    closeBtn.TextSize = 16
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
        stopAutofarm()
        stopAutoHunt()
        stopAntiAfk()
    end)

    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Desligado"
    statusLabel.TextColor3 = CONFIG.COLOR_TEXT_DIM
    statusLabel.Font = CONFIG.FONT
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    ui.statusLabel = statusLabel

    -- Botão Autofarm
    local autofarmButton = Instance.new("TextButton")
    autofarmButton.Size = UDim2.new(1, -20, 0, 40)
    autofarmButton.Position = UDim2.new(0, 10, 0, 80)
    autofarmButton.BackgroundColor3 = CONFIG.COLOR_ACCENT
    autofarmButton.Text = "Ativar Autofarm"
    autofarmButton.TextColor3 = CONFIG.COLOR_TEXT
    autofarmButton.Font = CONFIG.FONT_BOLD
    autofarmButton.TextSize = 16
    autofarmButton.Parent = mainFrame
    Instance.new("UICorner", autofarmButton).CornerRadius = UDim.new(0, 8)
    autofarmButton.MouseButton1Click:Connect(function()
        if state.autofarmActive then stopAutofarm() else startAutofarm() end
    end)
    ui.autofarmButton = autofarmButton

    -- Botão Auto Hunt
    local huntButton = Instance.new("TextButton")
    huntButton.Size = UDim2.new(1, -20, 0, 40)
    huntButton.Position = UDim2.new(0, 10, 0, 130)
    huntButton.BackgroundColor3 = CONFIG.COLOR_PANEL
    huntButton.Text = "Auto Hunt: OFF"
    huntButton.TextColor3 = CONFIG.COLOR_TEXT
    huntButton.Font = CONFIG.FONT_BOLD
    huntButton.TextSize = 16
    huntButton.Parent = mainFrame
    Instance.new("UICorner", huntButton).CornerRadius = UDim.new(0, 8)
    huntButton.MouseButton1Click:Connect(function()
        if state.autoHuntActive then stopAutoHunt() else startAutoHunt() end
    end)
    ui.huntButton = huntButton

    -- Botão Anti-AFK
    local antiAfkButton = Instance.new("TextButton")
    antiAfkButton.Size = UDim2.new(1, -20, 0, 40)
    antiAfkButton.Position = UDim2.new(0, 10, 0, 180)
    antiAfkButton.BackgroundColor3 = CONFIG.COLOR_PANEL
    antiAfkButton.Text = "Anti-AFK: OFF"
    antiAfkButton.TextColor3 = CONFIG.COLOR_TEXT
    antiAfkButton.Font = CONFIG.FONT_BOLD
    antiAfkButton.TextSize = 16
    antiAfkButton.Parent = mainFrame
    Instance.new("UICorner", antiAfkButton).CornerRadius = UDim.new(0, 8)
    antiAfkButton.MouseButton1Click:Connect(function()
        if state.antiAfkActive then stopAntiAfk() else startAntiAfk() end
    end)
    ui.antiAfkButton = antiAfkButton

    -- Botão de modo
    local modeButton = Instance.new("TextButton")
    modeButton.Size = UDim2.new(1, -20, 0, 30)
    modeButton.Position = UDim2.new(0, 10, 0, 230)
    modeButton.BackgroundColor3 = CONFIG.COLOR_PANEL
    modeButton.Text = "Modo: Mais Próxima"
    modeButton.TextColor3 = CONFIG.COLOR_TEXT
    modeButton.Font = CONFIG.FONT_BOLD
    modeButton.TextSize = 13
    modeButton.Parent = mainFrame
    Instance.new("UICorner", modeButton).CornerRadius = UDim.new(0, 6)
    modeButton.MouseButton1Click:Connect(function()
        if state.travelMode == "nearest" then
            state.travelMode = "sequential"
        else
            state.travelMode = "nearest"
        end
        updateUI()
        notify("Modo alterado para: " ..
            (state.travelMode == "nearest" and "mais próxima" or "ordem da lista") .. ".",
            CONFIG.COLOR_ACCENT_LIGHT)
    end)
    ui.modeButton = modeButton

    -- Contador
    local positionCountLabel = Instance.new("TextLabel")
    positionCountLabel.Size = UDim2.new(1, -20, 0, 20)
    positionCountLabel.Position = UDim2.new(0, 10, 0, 270)
    positionCountLabel.BackgroundTransparency = 1
    positionCountLabel.Text = "Posições salvas: 0"
    positionCountLabel.TextColor3 = CONFIG.COLOR_TEXT
    positionCountLabel.Font = CONFIG.FONT
    positionCountLabel.TextSize = 14
    positionCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    positionCountLabel.Parent = mainFrame
    ui.positionCountLabel = positionCountLabel

    -- Lista de posições
    local positionList = Instance.new("ScrollingFrame")
    positionList.Size = UDim2.new(1, -20, 0, 130)
    positionList.Position = UDim2.new(0, 10, 0, 295)
    positionList.BackgroundColor3 = CONFIG.COLOR_PANEL
    positionList.BorderSizePixel = 0
    positionList.CanvasSize = UDim2.new(0, 0, 0, 0)
    positionList.ScrollBarThickness = 6
    positionList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    positionList.Parent = mainFrame
    Instance.new("UICorner", positionList).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = positionList
    ui.positionList = positionList

    -- Botão Limpar Tudo
    local clearButton = Instance.new("TextButton")
    clearButton.Size = UDim2.new(1, -20, 0, 30)
    clearButton.Position = UDim2.new(0, 10, 0, 435)
    clearButton.BackgroundColor3 = CONFIG.COLOR_ERROR
    clearButton.Text = "Limpar Todas as Posições"
    clearButton.TextColor3 = CONFIG.COLOR_TEXT
    clearButton.Font = CONFIG.FONT_BOLD
    clearButton.TextSize = 14
    clearButton.Parent = mainFrame
    Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 6)
    clearButton.MouseButton1Click:Connect(function()
        state.positions = {}
        updatePositionList()
        updateUI()
        notify("Todas as posições removidas.", CONFIG.COLOR_TEXT_DIM)
    end)

    -- Label Velocidade
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.5, -15, 0, 16)
    speedLabel.Position = UDim2.new(0, 10, 0, 475)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Velocidade (studs/s):"
    speedLabel.TextColor3 = CONFIG.COLOR_TEXT_DIM
    speedLabel.Font = CONFIG.FONT
    speedLabel.TextSize = 12
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainFrame

    -- Label Espera
    local waitLabel = Instance.new("TextLabel")
    waitLabel.Size = UDim2.new(0.5, -15, 0, 16)
    waitLabel.Position = UDim2.new(0.5, 5, 0, 475)
    waitLabel.BackgroundTransparency = 1
    waitLabel.Text = "Espera (s):"
    waitLabel.TextColor3 = CONFIG.COLOR_TEXT_DIM
    waitLabel.Font = CONFIG.FONT
    waitLabel.TextSize = 12
    waitLabel.TextXAlignment = Enum.TextXAlignment.Left
    waitLabel.Parent = mainFrame

    -- Box Velocidade
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.5, -15, 0, 28)
    speedBox.Position = UDim2.new(0, 10, 0, 493)
    speedBox.BackgroundColor3 = CONFIG.COLOR_PANEL
    speedBox.Text = tostring(state.speed)
    speedBox.TextColor3 = CONFIG.COLOR_TEXT
    speedBox.Font = CONFIG.FONT
    speedBox.TextSize = 14
    speedBox.Parent = mainFrame
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)
    speedBox.FocusLost:Connect(function()
        local num = tonumber(speedBox.Text)
        if num and num > 0 then state.speed = num
        else speedBox.Text = tostring(state.speed) end
    end)

    -- Box Espera
    local waitBox = Instance.new("TextBox")
    waitBox.Size = UDim2.new(0.5, -15, 0, 28)
    waitBox.Position = UDim2.new(0.5, 5, 0, 493)
    waitBox.BackgroundColor3 = CONFIG.COLOR_PANEL
    waitBox.Text = tostring(state.waitTime)
    waitBox.TextColor3 = CONFIG.COLOR_TEXT
    waitBox.Font = CONFIG.FONT
    waitBox.TextSize = 14
    waitBox.Parent = mainFrame
    Instance.new("UICorner", waitBox).CornerRadius = UDim.new(0, 4)
    waitBox.FocusLost:Connect(function()
        local num = tonumber(waitBox.Text)
        if num and num >= 0 then state.waitTime = num
        else waitBox.Text = tostring(state.waitTime) end
    end)

    -- Minimizar
    local isMinimized = false
    local function setMinimized(min)
        isMinimized = min
        if min then
            mainFrame.Size = UDim2.new(0, 200, 0, 60)
            for _, child in ipairs(mainFrame:GetChildren()) do
                if child ~= title and child ~= minimizeBtn and child ~= closeBtn
                   and child ~= statusLabel and child ~= stroke then
                    if child:IsA("GuiObject") then child.Visible = false end
                end
            end
            title.Size = UDim2.new(1, -130, 0, 40)
            statusLabel.Position = UDim2.new(0, 10, 0, 45)
        else
            mainFrame.Size = CONFIG.UI_SIZE
            for _, child in ipairs(mainFrame:GetChildren()) do
                if child:IsA("GuiObject") then child.Visible = true end
            end
            title.Size = UDim2.new(1, -80, 0, 40)
            statusLabel.Position = UDim2.new(0, 10, 0, 50)
        end
    end
    minimizeBtn.MouseButton1Click:Connect(function() setMinimized(not isMinimized) end)

    ui.mainFrame = mainFrame
    ui.screenGui = screenGui

    updateUI()
    updatePositionList()
end

--== INICIALIZAÇÃO ==--

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Tecla L salva posição
local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        savePosition()
    end
end)
table.insert(state.connections, inputConnection)

createUI()
notify("Pressione L para salvar posições.", CONFIG.COLOR_ACCENT_LIGHT)
