-- Créditos: unicorntears2012
print("[Unicorn Hub] Carregador iniciado")
pcall(function()
local old = rawget(_G, "__UnicornHubRestoreEquippedUIs")
if type(old) ~= "function" and type(getgenv) == "function" then
local env = getgenv()
if type(env) == "table" then old = rawget(env, "__UnicornHubRestoreEquippedUIs") end
end
if type(old) == "function" then old() end
end)
local function showStartError(stage, err)
local message = "[Unicorn Hub] " .. tostring(stage) .. ": " .. tostring(err)
warn(message)
pcall(function()
local players = game:GetService("Players")
local player = players.LocalPlayer
local parent = player and player:FindFirstChildOfClass("PlayerGui")
if not parent then return end
local existing = parent:FindFirstChild("UnicornHubStartupError")
if existing then existing:Destroy() end
local screen = Instance.new("ScreenGui")
screen.Name = "UnicornHubStartupError"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 1000002
screen.Parent = parent
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.new(0.9, 0, 0, 168)
frame.BackgroundColor3 = Color3.fromRGB(23, 23, 29)
frame.Parent = screen
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(620, 168)
constraint.Parent = frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Position = UDim2.new(0, 14, 0, 10)
label.Size = UDim2.new(1, -28, 1, -58)
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.TextColor3 = Color3.fromRGB(250, 230, 230)
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextWrapped = true
label.Text = "Falha ao iniciar Unicorn Hub (" .. tostring(stage) .. ")\n" .. string.sub(tostring(err), 1, 500)
label.Parent = frame
local close = Instance.new("TextButton")
close.Position = UDim2.new(0, 14, 1, -42)
close.Size = UDim2.fromOffset(100, 30)
close.BackgroundColor3 = Color3.fromRGB(90, 60, 65)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Text = "FECHAR"
close.Parent = frame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close
close.Activated:Connect(function() screen:Destroy() end)
end)
end
if type(loadstring) ~= "function" then
showStartError("executor", "loadstring indisponivel no ambiente")
return
end
local pieces = {
[===================================[print("[Unicorn Hub] Script iniciado; carregando servicos...")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer local playerGui = player:WaitForChild("PlayerGui")
local State local UnicornHubHumanoidWrites = { OwnWrites = setmetatable({}, {__mode = "k"}) }
function UnicornHubHumanoidWrites.set(humanoid, property, value)
if not humanoid then return end local own = UnicornHubHumanoidWrites.OwnWrites[humanoid]
if not own then
own = {} UnicornHubHumanoidWrites.OwnWrites[humanoid] = own end local writes = own[property]
if not writes then
writes = {} own[property] = writes end
writes[#writes + 1] = {Value = value, At = os.clock()}
if #writes > 12 then table.remove(writes, 1) end humanoid[property] = value end
function UnicornHubHumanoidWrites.isOwn(humanoid, property, value)
local own = UnicornHubHumanoidWrites.OwnWrites[humanoid] local writes = own and own[property]
if not writes then return false end local now = os.clock() for i = #writes, 1, -1 do
local entry = writes[i] if now - entry.At > 0.7 then
table.remove(writes, i)
elseif (entry.Value == value)
or (type(entry.Value) == "number" and type(value) == "number"
and math.abs(entry.Value - value) < 0.001) then
table.remove(writes, i) return true end end return false end pcall(function()
local environments = {_G} if type(getgenv) == "function" then
local ok, env = pcall(getgenv) if ok and type(env) == "table" and env ~= _G then
table.insert(environments, env) end end for _, env in ipairs(environments) do
local old = rawget(env, "__UnicornHubCandyOverlayCleaner")
if type(old) == "table" and type(old.Stop) == "function" then
pcall(old.Stop) end end local cleaner = {Active = true, Connections = {}}
function cleaner.Stop() if not cleaner.Active then return end cleaner.Active = false
for _, connection in ipairs(cleaner.Connections) do
pcall(function() connection:Disconnect() end) end table.clear(cleaner.Connections) end
local function isOldCandyHud(gui)
if not gui or not gui:IsA("ScreenGui") or gui.Name == "UnicornHubCustom" then
return false end if gui.Name == "UnicornHubCandyFarmHUD" then return true end
local hasBalance, hasCollected, hasMap = false, false, false
for _, object in ipairs(gui:GetDescendants()) do
if object:IsA("TextLabel") or object:IsA("TextButton") then
local value = string.upper(object.Text)
hasBalance = hasBalance or value:find("SALDO:", 1, true) ~= nil
hasCollected = hasCollected or value:find("COLETADOS:", 1, true) ~= nil
hasMap = hasMap or value:find("MAPA:", 1, true) ~= nil
if hasBalance and hasCollected and hasMap then
return true end end end return false end local function removeOverlay(gui)
if cleaner.Active and gui and gui.Parent and isOldCandyHud(gui) then
pcall(function() gui:Destroy() end) end end
local function removeCandyMiniElement(instance)
if not cleaner.Active or not instance or not instance.Parent then
return false end local name = string.lower(instance.Name)
if name ~= "candyministats" and name ~= "candyminibalancetext" then
return false end pcall(function() instance:Destroy() end) return true end
local boundRoots = {} local function observe(root)
if not root or boundRoots[root] then return end boundRoots[root] = true
for _, descendant in ipairs(root:GetDescendants()) do
if not removeCandyMiniElement(descendant) and descendant:IsA("ScreenGui") then
removeOverlay(descendant) end end
table.insert(cleaner.Connections, root.DescendantAdded:Connect(function(obj)
if not cleaner.Active then return end if removeCandyMiniElement(obj) then return end
if obj:IsA("ScreenGui") then
task.defer(function() removeOverlay(obj) end)
task.delay(0.3, function() removeOverlay(obj) end)
elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
if screenGui and screenGui.Name ~= "UnicornHubCustom" then
local value = string.upper(obj.Text)
if value:find("SALDO:", 1, true) or value:find("COLETADOS:", 1, true)
or value:find("MAPA:", 1, true) then
task.defer(function() removeOverlay(screenGui) end) end end end end)) end
observe(playerGui)
if not (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) then
pcall(function() observe(game:GetService("CoreGui")) end)
if type(gethui) == "function" then pcall(function() observe(gethui()) end) end
end
for _, env in ipairs(environments) do
env.__UnicornHubCandyOverlayCleaner = cleaner end end)
local UnicornHubIconThumb = { Candy = "rbxthumb://type=Asset&id=126341856038505&w=150&h=150",
Potion = "rbxassetid://119206604109473",
Profile = "rbxthumb://type=Asset&id=134373119798521&w=150&h=150",
Warns = "rbxthumb://type=Asset&id=94502062489080&w=150&h=150", }
local function preloadUnicornHubIcons() task.spawn(function() pcall(function()
ContentProvider:PreloadAsync({ UnicornHubIconThumb.Candy, UnicornHubIconThumb.Potion, UnicornHubIconThumb.Profile, UnicornHubIconThumb.Warns, }) end) end) end
preloadUnicornHubIcons() local PlayerCargo = { groupId = 35221900,
rankNames = { [255] = "Owner", [254] = "CoOwner", [111] = "Manager", [211] = "Admin", [100] = "Moderator", },
rankColors = { Owner = Color3.fromRGB(130, 255, 161), CoOwner = Color3.fromRGB(130, 255, 161),
Manager = Color3.fromRGB(255, 85, 127), Admin = Color3.fromRGB(255, 0, 0),
Moderator = Color3.fromRGB(0, 85, 255), },
tagColors = { artist = Color3.new(1, 0.286275, 0.192157), marketing = Color3.new(0.482353, 0.352941, 1),
marketing1 = Color3.new(0.482353, 0.352941, 1), supporter = Color3.new(1, 0.572549, 0.223529),
moderator = Color3.new(0.113725, 0.129412, 1), mvp = Color3.new(0.313725, 0.737255, 1),
helper = Color3.new(1, 0.870588, 0.611765), influencer = Color3.new(0.901961, 0.423529, 1),
vip = Color3.fromRGB(255, 239, 116), celebrity = Color3.fromRGB(157, 186, 255), },
defaultPlayerColor = Color3.fromRGB(255, 255, 255), defaultTagColor = Color3.new(0.556863, 1, 0.556863),
rankCache = {}, rankLoading = {}, rankWaiters = {}, }
function PlayerCargo.getActiveTag(targetPlayer) if not targetPlayer then
return nil end local activeTag = targetPlayer:GetAttribute("_LastActiveTag")
if type(activeTag) == "string" then
activeTag = activeTag:match("^%s*(.-)%s*$") if activeTag and activeTag ~= "" then
return activeTag end end
for _, attributeName in ipairs({ "LastActiveTag", "ActiveTag", "CurrentTag", "Tag", "Role", "Cargo", }) do
local value = targetPlayer:GetAttribute(attributeName) if type(value) == "string" then
value = value:match("^%s*(.-)%s*$") if value and value ~= "" then
return value end end end return nil end
function PlayerCargo.ensureGroupRank(targetPlayer, callback) if not targetPlayer then
if callback then
task.defer(callback, nil) end return nil end local userId = targetPlayer.UserId
local cached = PlayerCargo.rankCache[userId] if cached ~= nil then
if cached == false then
if callback then
task.defer(callback, nil) end return nil end if callback then
task.defer(callback, cached) end return cached end if callback then
PlayerCargo.rankWaiters[userId] = PlayerCargo.rankWaiters[userId] or {}
table.insert(PlayerCargo.rankWaiters[userId], callback) end
if PlayerCargo.rankLoading[userId] then
return nil end PlayerCargo.rankLoading[userId] = true task.spawn(function()
local ok, rank = pcall(function()
return targetPlayer:GetRankInGroup(PlayerCargo.groupId) end)
local finalRank = ok and tonumber(rank) or nil
PlayerCargo.rankCache[userId] = finalRank ~= nil and finalRank or false
PlayerCargo.rankLoading[userId] = nil local waiters = PlayerCargo.rankWaiters[userId]
PlayerCargo.rankWaiters[userId] = nil if waiters then
for _, waiter in ipairs(waiters) do
task.defer(waiter, finalRank) end end end) return nil end
function PlayerCargo.getStaffRank(targetPlayer) if not targetPlayer then
return nil, nil, nil end local userId = targetPlayer.UserId
local cached = PlayerCargo.rankCache[userId] if cached == nil then
PlayerCargo.ensureGroupRank(targetPlayer) return nil, nil, nil end if cached == false then
return nil, nil, nil end local rank = tonumber(cached)
local rankName = rank and PlayerCargo.rankNames[rank] or nil
local rankColor = rankName and PlayerCargo.rankColors[rankName] or nil
return rankName, rankColor, rank end function PlayerCargo.get(targetPlayer)
if not targetPlayer then
return "Player" end local staffName = PlayerCargo.getStaffRank(targetPlayer)
local activeTag = PlayerCargo.getActiveTag(targetPlayer) if staffName and activeTag then
if string.lower(staffName) == string.lower(activeTag) then
return staffName end return staffName .. " · " .. activeTag end if staffName then
return staffName end if activeTag then
return activeTag end return "Player" end function PlayerCargo.color(targetPlayer)
if not targetPlayer then
return PlayerCargo.defaultPlayerColor end
local _, staffColor = PlayerCargo.getStaffRank(targetPlayer) if staffColor then
return staffColor end local activeTag = PlayerCargo.getActiveTag(targetPlayer)
if activeTag then
local normalized = string.lower(activeTag)
:gsub("[%s_%-]", "") if normalized == "player" then
return PlayerCargo.defaultPlayerColor end
return PlayerCargo.tagColors[normalized] or PlayerCargo.defaultTagColor end
return PlayerCargo.defaultPlayerColor end
local PlayerDonate = { amounts = {10, 25, 50, 100, 250, 500}, allowed = { [10] = true, [25] = true,
[50] = true, [100] = true, [250] = true, [500] = true, },
requestRemote = nil, transferFailedRemote = nil, failureConnection = nil,
gui = nil, target = nil, selectedAmount = nil, sending = false, statusLabel = nil, confirmButton = nil,
amountButtons = {}, soundCache = {}, } function PlayerDonate.playSound(kind)
local sound = PlayerDonate.soundCache[kind] if not sound or not sound.Parent then
local folder = SoundService:FindFirstChild("CoinClickerHubSounds")
sound = folder and folder:FindFirstChild(kind) if not sound then
if kind == "Click" then
sound = SoundService:FindFirstChild("click", true)
elseif kind == "Error" then
sound = SoundService:FindFirstChild("error", true) end end
PlayerDonate.soundCache[kind] = sound and sound:IsA("Sound") and sound or nil end
if sound and sound:IsA("Sound") then
pcall(function() sound:Stop() sound.TimePosition = 0 sound:Play() end) end end
function PlayerDonate.hoverButton(button, normalBackground, hoverBackground, normalText, hoverText)
button.MouseEnter:Connect(function() PlayerDonate.playSound("Hover")
TweenService:Create(button, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
{ BackgroundColor3 = hoverBackground, TextColor3 = hoverText, }):Play() end)
button.MouseLeave:Connect(function()
TweenService:Create(button, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
{ BackgroundColor3 = normalBackground, TextColor3 = normalText, }):Play() end) end
function PlayerDonate.close(playSound) if playSound then
PlayerDonate.playSound("Click") end local gui = PlayerDonate.gui
local panel = gui and gui:FindFirstChild("DonatePanel", true)
if panel and panel:IsA("GuiObject") then
local scale = panel:FindFirstChildOfClass("UIScale") if scale then
TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In
), {Scale = 0.94}):Play() end
TweenService:Create(panel, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
{BackgroundTransparency = 0.18}):Play() task.wait(0.10) end if gui and gui.Parent then
gui:Destroy() end PlayerDonate.gui = nil PlayerDonate.target = nil
PlayerDonate.selectedAmount = nil PlayerDonate.sending = false
PlayerDonate.statusLabel = nil PlayerDonate.confirmButton = nil
table.clear(PlayerDonate.amountButtons) end
function PlayerDonate.setStatus(message, isError) local label = PlayerDonate.statusLabel
if not label or not label.Parent then
return end label.Text = tostring(message or "")
label.TextColor3 = isError and Color3.fromRGB(255, 116, 116) or Color3.fromRGB(145, 145, 156) end
function PlayerDonate.ensureRemotes()
if PlayerDonate.requestRemote and PlayerDonate.requestRemote.Parent then
return true end local remotesRoot = ReplicatedStorage:FindFirstChild("Remotes")
local donateSystem = remotesRoot and remotesRoot:FindFirstChild("DonateSystem")
local remotes = donateSystem and donateSystem:FindFirstChild("Remotes")
local request = remotes and remotes:FindFirstChild("RequestTransfer")
local failed = remotes and remotes:FindFirstChild("TransferFailed")
if not request or not request:IsA("RemoteEvent") then
return false end PlayerDonate.requestRemote = request
PlayerDonate.transferFailedRemote = failed and failed:IsA("RemoteEvent") and failed or nil
if PlayerDonate.failureConnection then
PlayerDonate.failureConnection:Disconnect() PlayerDonate.failureConnection = nil end
if PlayerDonate.transferFailedRemote then
PlayerDonate.failureConnection = PlayerDonate.transferFailedRemote.OnClientEvent:Connect( function(message)
PlayerDonate.sending = false PlayerDonate.playSound("Error")
if PlayerDonate.confirmButton and PlayerDonate.confirmButton.Parent then
PlayerDonate.confirmButton.Active = true if PlayerDonate.selectedAmount then
PlayerDonate.confirmButton.Text = "DOAR R$" .. tostring(PlayerDonate.selectedAmount)
else
PlayerDonate.confirmButton.Text = "ESCOLHA UM VALOR" end end
PlayerDonate.setStatus(tostring(message or "Não foi possível doar."), true) end
) end return true end function PlayerDonate.selectAmount(amount) amount = tonumber(amount)
if not amount or not PlayerDonate.allowed[amount] then
return end PlayerDonate.playSound("Click") PlayerDonate.selectedAmount = amount
for value, button in pairs(PlayerDonate.amountButtons) do
if button and button.Parent then
local selected = value == amount
TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad,
Enum.EasingDirection.Out), { BackgroundColor3 = selected
and Color3.fromRGB(244, 244, 247) or Color3.fromRGB(28, 28, 33),
TextColor3 = selected and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(224, 224, 230), }
):Play() local stroke = button:FindFirstChildOfClass("UIStroke") if stroke then
stroke.Transparency = selected and 0 or 0.65
stroke.Color = selected and Color3.fromRGB(244, 244, 247) or Color3.fromRGB(78, 78, 88) end end end
if PlayerDonate.confirmButton and PlayerDonate.confirmButton.Parent then
PlayerDonate.confirmButton.Text = "DOAR R$" .. tostring(amount) end
PlayerDonate.setStatus("Clique em DOAR para confirmar.", false) end
function PlayerDonate.send() if PlayerDonate.sending then
return end PlayerDonate.playSound("Click") local target = PlayerDonate.target
local amount = tonumber(PlayerDonate.selectedAmount)
if not target or target.Parent ~= Players then
PlayerDonate.playSound("Error")
PlayerDonate.setStatus("Esse jogador saiu do servidor.", true) return end
if target == player then
PlayerDonate.playSound("Error")
PlayerDonate.setStatus("Você não pode doar para si mesmo.", true) return end
if not amount or not PlayerDonate.allowed[amount] then
PlayerDonate.playSound("Error") PlayerDonate.setStatus("Escolha um valor primeiro.", true)
return end if not PlayerDonate.ensureRemotes() then
PlayerDonate.playSound("Error")
PlayerDonate.setStatus("Sistema oficial de doação não encontrado.", true) return end
PlayerDonate.sending = true
if PlayerDonate.confirmButton and PlayerDonate.confirmButton.Parent then
PlayerDonate.confirmButton.Active = false
PlayerDonate.confirmButton.Text = "ENVIANDO..." end
PlayerDonate.setStatus("Aguardando validação do servidor...", false)
local ok, err = pcall(function()
PlayerDonate.requestRemote:FireServer(target.UserId, amount) end) if not ok then
PlayerDonate.sending = false PlayerDonate.playSound("Error")
if PlayerDonate.confirmButton and PlayerDonate.confirmButton.Parent then
PlayerDonate.confirmButton.Active = true
PlayerDonate.confirmButton.Text = "DOAR R$" .. tostring(amount) end
PlayerDonate.setStatus("Falha ao enviar: " .. tostring(err), true) return end
task.delay(1.25, function() if not PlayerDonate.gui or not PlayerDonate.gui.Parent then
return end if PlayerDonate.sending then
PlayerDonate.sending = false
if PlayerDonate.confirmButton and PlayerDonate.confirmButton.Parent then
PlayerDonate.confirmButton.Active = true
PlayerDonate.confirmButton.Text = "DOAR R$" .. tostring(amount) end
PlayerDonate.setStatus("Solicitação enviada ao servidor.", false) end end) end
function PlayerDonate.open(targetPlayer)
if not targetPlayer or targetPlayer.Parent ~= Players or targetPlayer == player then
return end PlayerDonate.close(false) if not PlayerDonate.ensureRemotes() then
warn("[Unicorn Hub] DonateSystem/RequestTransfer não encontrado.") return end
local oldGui = playerGui:FindFirstChild("CoinClickerHubDonate") if oldGui then
oldGui:Destroy() end PlayerDonate.target = targetPlayer PlayerDonate.playSound("Click")
local gui = Instance.new("ScreenGui") gui.Name = "CoinClickerHubDonate"
gui.ResetOnSpawn = false gui.IgnoreGuiInset = true gui.DisplayOrder = 1000001
gui.Parent = playerGui PlayerDonate.gui = gui local dim = Instance.new("TextButton")
dim.Name = "Dim" dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0) dim.BackgroundTransparency = 0.35
dim.BorderSizePixel = 0 dim.Text = "" dim.AutoButtonColor = false dim.Parent = gui
local frame = Instance.new("Frame") frame.Name = "DonatePanel"
frame.AnchorPoint = Vector2.new(0.5, 0.5) frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(404, 326)
frame.BackgroundColor3 = Color3.fromRGB(14, 14, 17) frame.BorderSizePixel = 0
frame.ClipsDescendants = true frame.Parent = gui
local frameCorner = Instance.new("UICorner") frameCorner.CornerRadius = UDim.new(0, 17)
frameCorner.Parent = frame local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(52, 52, 61) frameStroke.Thickness = 1
frameStroke.Transparency = 0.15 frameStroke.Parent = frame
local frameScale = Instance.new("UIScale") frameScale.Scale = 0.92
frameScale.Parent = frame
local header = Instance.new("Frame") header.Position = UDim2.fromOffset(0, 3)
header.Size = UDim2.new(1, 0, 0, 47) header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
header.BorderSizePixel = 0 header.Parent = frame
local robuxBadge = Instance.new("TextLabel")
robuxBadge.Position = UDim2.fromOffset(15, 11) robuxBadge.Size = UDim2.fromOffset(28, 26)
robuxBadge.BackgroundColor3 = Color3.fromRGB(244, 244, 247) robuxBadge.BorderSizePixel = 0
robuxBadge.Text = "R$" robuxBadge.TextColor3 = Color3.fromRGB(10, 10, 12)
robuxBadge.Font = Enum.Font.GothamBold robuxBadge.TextSize = 14 robuxBadge.Parent = header
local badgeCorner = Instance.new("UICorner") badgeCorner.CornerRadius = UDim.new(0, 8)
badgeCorner.Parent = robuxBadge local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(53, 8) title.Size = UDim2.new(1, -108, 0, 18)
title.BackgroundTransparency = 1 title.Text = "DOAR ROBUX"
title.TextColor3 = Color3.fromRGB(245, 245, 248) title.Font = Enum.Font.GothamBold
title.TextSize = 12 title.TextXAlignment = Enum.TextXAlignment.Left title.Parent = header
local subtitle = Instance.new("TextLabel") subtitle.Position = UDim2.fromOffset(53, 25)
subtitle.Size = UDim2.new(1, -108, 0, 14) subtitle.BackgroundTransparency = 1
subtitle.Text = "Unicorn Hub · transferência entre jogadores"
subtitle.TextColor3 = Color3.fromRGB(116, 116, 128) subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 8 subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0) close.Position = UDim2.new(1, -12, 0, 10)
close.Size = UDim2.fromOffset(30, 28) close.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
close.BorderSizePixel = 0 close.Text = "×"
close.TextColor3 = Color3.fromRGB(205, 205, 214) close.Font = Enum.Font.GothamBold
close.TextSize = 16 close.AutoButtonColor = false close.Parent = header
local closeCorner = Instance.new("UICorner") closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close local profile = Instance.new("Frame")
profile.Position = UDim2.fromOffset(14, 61) profile.Size = UDim2.new(1, -28, 0, 70)
profile.BackgroundColor3 = Color3.fromRGB(19, 19, 23) profile.BorderSizePixel = 0
profile.Parent = frame local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 12) profileCorner.Parent = profile
local profileStroke = Instance.new("UIStroke")
profileStroke.Color = Color3.fromRGB(44, 44, 52) profileStroke.Thickness = 1
profileStroke.Transparency = 0.45 profileStroke.Parent = profile
local avatar = Instance.new("ImageLabel") avatar.Position = UDim2.fromOffset(10, 10)
avatar.Size = UDim2.fromOffset(50, 50)
avatar.BackgroundColor3 = Color3.fromRGB(28, 28, 32) avatar.BorderSizePixel = 0
avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
avatar.ScaleType = Enum.ScaleType.Crop avatar.Parent = profile
local avatarCorner = Instance.new("UICorner") avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatar local avatarStroke = Instance.new("UIStroke")
avatarStroke.Color = Color3.fromRGB(67, 67, 77) avatarStroke.Thickness = 1
avatarStroke.Transparency = 0.2 avatarStroke.Parent = avatar
local display = Instance.new("TextLabel") display.Position = UDim2.fromOffset(72, 13)
display.Size = UDim2.new(1, -86, 0, 21) display.BackgroundTransparency = 1
display.Text = targetPlayer.DisplayName display.TextColor3 = Color3.fromRGB(245, 245, 248)
display.Font = Enum.Font.GothamBold display.TextSize = 12
display.TextXAlignment = Enum.TextXAlignment.Left
display.TextTruncate = Enum.TextTruncate.AtEnd display.Parent = profile
local username = Instance.new("TextLabel") username.Position = UDim2.fromOffset(72, 35)
username.Size = UDim2.new(1, -86, 0, 18) username.BackgroundTransparency = 1
username.Text = "@" .. targetPlayer.Name .. "  ·  ID " .. tostring(targetPlayer.UserId)
username.TextColor3 = Color3.fromRGB(133, 133, 145) username.Font = Enum.Font.Gotham
username.TextSize = 9 username.TextXAlignment = Enum.TextXAlignment.Left
username.TextTruncate = Enum.TextTruncate.AtEnd username.Parent = profile
local instruction = Instance.new("TextLabel")
instruction.Position = UDim2.fromOffset(16, 144)
instruction.Size = UDim2.new(1, -32, 0, 17) instruction.BackgroundTransparency = 1
instruction.Text = "ESCOLHA O VALOR"
instruction.TextColor3 = Color3.fromRGB(186, 186, 196)
instruction.Font = Enum.Font.GothamBold instruction.TextSize = 9
instruction.TextXAlignment = Enum.TextXAlignment.Left instruction.Parent = frame
local gridHolder = Instance.new("Frame") gridHolder.Position = UDim2.fromOffset(16, 168)
gridHolder.Size = UDim2.new(1, -32, 0, 74) gridHolder.BackgroundTransparency = 1
gridHolder.Parent = frame local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.333333, -7, 0, 32) grid.CellPadding = UDim2.fromOffset(10, 10)
grid.FillDirectionMaxCells = 3 grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridHolder for index, amount in ipairs(PlayerDonate.amounts) do
local button = Instance.new("TextButton") button.LayoutOrder = index
button.BackgroundColor3 = Color3.fromRGB(28, 28, 33) button.BorderSizePixel = 0
button.Text = "R$ " .. tostring(amount) button.TextColor3 = Color3.fromRGB(224, 224, 230)
button.Font = Enum.Font.GothamBold button.TextSize = 10 button.AutoButtonColor = false
button.Parent = gridHolder local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 9) buttonCorner.Parent = button
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(78, 78, 88) buttonStroke.Thickness = 1
buttonStroke.Transparency = 0.65 buttonStroke.Parent = button
PlayerDonate.amountButtons[amount] = button button.MouseEnter:Connect(function()
if PlayerDonate.selectedAmount ~= amount then
PlayerDonate.playSound("Hover")
button.BackgroundColor3 = Color3.fromRGB(36, 36, 43) end end)
button.MouseLeave:Connect(function() if PlayerDonate.selectedAmount ~= amount then
button.BackgroundColor3 = Color3.fromRGB(28, 28, 33) end end)
button.Activated:Connect(function() PlayerDonate.selectAmount(amount) end) end
local status = Instance.new("TextLabel") status.Position = UDim2.fromOffset(16, 252)
status.Size = UDim2.new(1, -184, 0, 25) status.BackgroundTransparency = 1
status.Text = "Nenhum valor selecionado."
status.TextColor3 = Color3.fromRGB(145, 145, 156) status.Font = Enum.Font.Gotham
status.TextSize = 8 status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Center status.Parent = frame
PlayerDonate.statusLabel = status local cancel = Instance.new("TextButton")
cancel.AnchorPoint = Vector2.new(0, 1) cancel.Position = UDim2.new(0, 16, 1, -14)
cancel.Size = UDim2.fromOffset(92, 32)
cancel.BackgroundColor3 = Color3.fromRGB(28, 28, 33) cancel.BorderSizePixel = 0
cancel.Text = "CANCELAR" cancel.TextColor3 = Color3.fromRGB(190, 190, 199)
cancel.Font = Enum.Font.GothamBold cancel.TextSize = 9 cancel.AutoButtonColor = false
cancel.Parent = frame local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 9) cancelCorner.Parent = cancel
local confirm = Instance.new("TextButton") confirm.AnchorPoint = Vector2.new(1, 1)
confirm.Position = UDim2.new(1, -16, 1, -14) confirm.Size = UDim2.fromOffset(160, 32)
confirm.BackgroundColor3 = Color3.fromRGB(244, 244, 247) confirm.BorderSizePixel = 0
confirm.Text = "ESCOLHA UM VALOR" confirm.TextColor3 = Color3.fromRGB(10, 10, 12)
confirm.Font = Enum.Font.GothamBold confirm.TextSize = 9 confirm.AutoButtonColor = false
confirm.Parent = frame PlayerDonate.confirmButton = confirm
local confirmCorner = Instance.new("UICorner") confirmCorner.CornerRadius = UDim.new(0, 9)
confirmCorner.Parent = confirm
PlayerDonate.hoverButton(close, Color3.fromRGB(28, 28, 33), Color3.fromRGB(46, 46, 54),
Color3.fromRGB(205, 205, 214), Color3.fromRGB(245, 245, 248))
PlayerDonate.hoverButton(cancel, Color3.fromRGB(28, 28, 33), Color3.fromRGB(40, 40, 47),
Color3.fromRGB(190, 190, 199), Color3.fromRGB(235, 235, 240))
PlayerDonate.hoverButton(confirm, Color3.fromRGB(244, 244, 247), Color3.fromRGB(218, 218, 224),
Color3.fromRGB(10, 10, 12), Color3.fromRGB(10, 10, 12)) dim.Activated:Connect(function()
PlayerDonate.close(true) end) close.Activated:Connect(function()
PlayerDonate.close(true) end) cancel.Activated:Connect(function()
PlayerDonate.close(true) end) confirm.Activated:Connect(PlayerDonate.send)
TweenService:Create(frameScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
{Scale = 1}):Play() task.spawn(function() local ok, image = pcall(function()
return Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot,
Enum.ThumbnailSize.Size150x150) end) if ok and image and avatar.Parent then
avatar.Image = image end end) end
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local RuntimeStore = nil pcall(function() if type(getgenv) == "function" then
local env = getgenv() env.__CoinClickerHubRuntime = env.__CoinClickerHubRuntime or {}
RuntimeStore = env.__CoinClickerHubRuntime end end)
if RuntimeStore and type(RuntimeStore.StopPreviousHub) == "function" then
local oldStop = RuntimeStore.StopPreviousHub RuntimeStore.StopPreviousHub = nil
pcall(oldStop) end for _, child in ipairs(playerGui:GetChildren()) do
if child.Name == "UnicornHubLuckyBlockAlert" and child:IsA("ScreenGui") then
pcall(function() child:Destroy() end) end end
if RuntimeStore and type(RuntimeStore.CleanupAntiRagdoll) == "function" then
pcall(RuntimeStore.CleanupAntiRagdoll) RuntimeStore.CleanupAntiRagdoll = nil end
local AntiRagdollEnabled = false local AntiRagdollCharacterConnection = nil
local AntiRagdollStateConnection = nil local AntiRagdollHeartbeatConnection = nil
local AntiRagdollToolConnections = {
JokerState = {Connection = nil, PhysicsConnection = nil, RenderConnection = nil,
Until = 0, Anchor = nil, Snapshot = nil, SnapshotAt = 0,
LockedRoot = nil, OwnsAnchor = false},
ThreatState = {Connection = nil, Generation = 0, SafeTime = 0, LastAttempt = 0},
AntiToolHold = {LockedRoot = nil, OwnsAnchor = false, Anchor = nil,
Reason = nil, PullUntil = 0, LastRelease = 0,
FrozenParts = {}, NativeLock = false, SkipNativeResidual = false},
ImpactState = {PhysicsConnection = nil, RenderConnection = nil, LockedRoot = nil,
OwnsAnchor = false, Anchor = nil, Until = 0, LastSafe = nil,
LastSafeAt = 0, LastVelocity = nil, LastVelocityAt = 0,
LastPosition = nil, LastPositionAt = 0, LastRelease = 0},
CarryLanding = {Token = 0, Character = nil, Recovering = false,
LockedRoot = nil, OwnsAnchor = false},
ActiveListeners = {},
} local AntiRagdollWatchConnections = {} local AntiRagdollSafeAt = 0
local AntiRagdollRecovering = false local AntiRagdollToolSuspended = false
local AntiRagdollFlySuspended = false local AntiRagdollResumeToken = 0
local AntiRagdollAirborneSince = 0 local ANTI_RAGDOLL_SAFE_REFRESH = 0.12
local ANTI_RAGDOLL_HORIZONTAL_KNOCKBACK = 42 local ANTI_RAGDOLL_TOTAL_KNOCKBACK = 68
local ANTI_RAGDOLL_AIR_STALL_GRACE = 0.48 local ANTI_RAGDOLL_AIR_STALL_Y_SPEED = 2.25
local bindAntiRagdoll local watchAntiRagdollTools
if type(_G.__UnicornHubStopDaggerDiagnostics) == "function" then
pcall(_G.__UnicornHubStopDaggerDiagnostics) end
_G.__UnicornHubDaggerDiagRuntime = _G.__UnicornHubDaggerDiagRuntime or { Connections = {}, RemoteEvents = {},
LastReport = "", LastReportAt = 0, BoundCharacter = nil, }
_G.__UnicornHubStopDaggerDiagnostics = function() local diag = _G.__UnicornHubDaggerDiagRuntime
if not diag then
return end for _, connection in ipairs(diag.Connections) do
pcall(function() connection:Disconnect() end) end table.clear(diag.Connections)
diag.BoundCharacter = nil end _G.__UnicornHubDaggerDiagValue = function(value)
local valueType = typeof(value) if valueType == "string" then
local cleaned = string.gsub(value, "[\r\n]", " " ) if #cleaned > 80 then
cleaned = string.sub(cleaned, 1, 80) .. "..." end return string.format("%q", cleaned) end
if valueType == "number" or valueType == "boolean" or valueType == "nil" then
return tostring(value) end if valueType == "Instance" then
local ok, fullName = pcall(function() return value:GetFullName() end)
return ok and (value.ClassName .. ":" .. tostring(fullName)) or (value.ClassName .. ":"
.. tostring(value.Name)) end
if valueType == "Vector3" or valueType == "CFrame" or valueType == "Color3" or valueType == "EnumItem" then
return tostring(value) end return "<" .. tostring(valueType) .. ">" end
_G.__UnicornHubRecordDaggerRemote = function(remote, ...)
local diag = _G.__UnicornHubDaggerDiagRuntime if not diag then
return end local args = table.pack(...) local rendered = {}
for index = 1, math.min(args.n, 6) do
rendered[index] = _G.__UnicornHubDaggerDiagValue(args[index]) end
local ok, fullName = pcall(function() return remote:GetFullName() end)
table.insert(diag.RemoteEvents, { At = os.clock(), Name = ok and tostring(fullName) or tostring(
remote.Name), Args = table.concat(rendered, ", " ), }) while #diag.RemoteEvents > 80 do
table.remove(diag.RemoteEvents, 1) end end
_G.__UnicornHubCaptureDaggerReport = function(character, reason)
local diag = _G.__UnicornHubDaggerDiagRuntime
if not diag or not character or player.Character ~= character then
return end local nowClock = os.clock() if nowClock - (diag.LastReportAt or 0) < 1.5 then
return end diag.LastReportAt = nowClock
local humanoid = character:FindFirstChildOfClass("Humanoid" )
local root = character:FindFirstChild("HumanoidRootPart" )
local lines = { "=== Unicorn Hub Dagger Diagnostic V4 ===", "Reason: " .. tostring(reason or "unknown" ),
"Clock: " .. string.format("%.3f", nowClock), "Player: " .. tostring(player.Name) .. " ("
.. tostring(player.UserId) .. ")", "PlaceId: " .. tostring(game.PlaceId), "JobId: "
.. tostring(game.JobId), } if humanoid then
table.insert(lines, "HumanoidState: " .. tostring(humanoid:GetState()))
table.insert(lines, "WalkSpeed: " .. tostring(humanoid.WalkSpeed))
table.insert(lines, "JumpPower: " .. tostring(humanoid.JumpPower))
table.insert(lines, "JumpHeight: " .. tostring(humanoid.JumpHeight))
table.insert(lines, "UseJumpPower: " .. tostring(humanoid.UseJumpPower))
table.insert(lines, "PlatformStand: " .. tostring(humanoid.PlatformStand))
table.insert(lines, "AutoRotate: " .. tostring(humanoid.AutoRotate))
table.insert(lines, "Sit: " .. tostring(humanoid.Sit)) end if root then
table.insert(lines, "RootAnchored: " .. tostring(root.Anchored))
table.insert(lines, "RootVelocity: " .. tostring(root.AssemblyLinearVelocity))
table.insert(lines, "RootPosition: " .. tostring(root.Position)) end
table.insert(lines, "" ) table.insert(lines, "[Attributes]" )
for _, instance in ipairs({ character, humanoid, root, }) do
if instance then
local attributes = instance:GetAttributes() for name, value in pairs(attributes) do
table.insert(lines, instance.ClassName .. "." .. tostring(name) .. " = "
.. _G.__UnicornHubDaggerDiagValue(value)) end end end table.insert(lines, "" )
table.insert(lines, "[Suspicious descendants]" ) local suspiciousCount = 0
for _, descendant in ipairs(character:GetDescendants()) do
local lower = string.lower(tostring(descendant.Name or "" ))
local suspiciousName = string.find(lower, "dagger", 1, true) or string.find(lower, "freeze", 1,
true) or string.find(lower, "frozen", 1, true) or string.find(lower, "stun", 1, true)
or string.find(lower, "shatter", 1, true) or string.find(lower, "dimension", 1, true)
or string.find(lower, "lock", 1, true)
local isOwnBackpackConstraint = string.sub(tostring(descendant.Name or "" ), 1, 16 ) == "__UnicornHubBackpack"
local suspiciousClass = not isOwnBackpackConstraint and (descendant:IsA("Constraint" )
or descendant:IsA("BodyMover" ) or descendant:IsA("LinearVelocity" ) or descendant:IsA(
"AngularVelocity" ) or descendant:IsA("VectorForce" ) or descendant:IsA(
"AlignPosition" ) or descendant:IsA("AlignOrientation" ))
if suspiciousName or suspiciousClass then
suspiciousCount += 1 if suspiciousCount <= 50 then
local ok, fullName = pcall(function() return descendant:GetFullName() end)
table.insert(lines, tostring(descendant.ClassName) .. " | " .. (ok and tostring(
fullName) or tostring(descendant.Name))) end end end if suspiciousCount == 0 then
table.insert(lines, "(none)" ) end table.insert(lines, "" )
table.insert(lines, "[Recent server -> client RemoteEvents, last 4s]" )
local remoteCount = 0 for _, entry in ipairs(diag.RemoteEvents) do
if nowClock - entry.At <= 4 then
remoteCount += 1
table.insert(lines, string.format("- %.3fs | %s | %s", nowClock - entry.At, tostring(
entry.Name), tostring(entry.Args))) end end if remoteCount == 0 then
table.insert(lines, "(none captured)" ) end local report = table.concat(lines, "\n" )
diag.LastReport = report _G.__UnicornHubDaggerReport = report
if type(getgenv) == "function" then
local env = getgenv() if type(env) == "table" then
env.__UnicornHubDaggerReport = report end end pcall(function()
if type(writefile) == "function" then
writefile("UnicornHub_Dagger_Report.txt", report) end end)
print("[Unicorn Hub][DaggerDiag] Report captured. " .. "Saved to _G.__UnicornHubDaggerReport" )
print(report) end _G.__UnicornHubStartDaggerDiagnostics = function(character)
_G.__UnicornHubStopDaggerDiagnostics()
local diagnosticEnabled = _G.__UnicornHubDaggerDiagnosticEnabled == true
if not diagnosticEnabled and type(getgenv) == "function" then
local ok, env = pcall(getgenv) diagnosticEnabled = ok and type(env) == "table"
and env.__UnicornHubDaggerDiagnosticEnabled == true end
if not diagnosticEnabled or not character then
return end local diag = _G.__UnicornHubDaggerDiagRuntime diag.BoundCharacter = character
local function rememberConnection(connection) table.insert(diag.Connections, connection)
return connection end local boundRemotes = {} local function bindRemote(remote)
if not remote or not remote:IsA("RemoteEvent" ) or boundRemotes[remote] then
return end boundRemotes[remote] = true local ok, connection = pcall(function()
return remote.OnClientEvent:Connect(function(...)
_G.__UnicornHubRecordDaggerRemote(remote, ...) end
) end) if ok and connection then
rememberConnection(connection) end end
for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
bindRemote(descendant) end
rememberConnection(ReplicatedStorage.DescendantAdded:Connect(bindRemote))
local humanoid = character:FindFirstChildOfClass("Humanoid" )
local root = character:FindFirstChild("HumanoidRootPart" ) local function capture(reason)
task.defer(function() if player.Character == character then
_G.__UnicornHubCaptureDaggerReport(character, reason) end end) end if humanoid then
for _, propertyName in ipairs({ "WalkSpeed", "JumpPower", "JumpHeight", "UseJumpPower",
"PlatformStand", "AutoRotate", "Sit", }) do
rememberConnection(humanoid:GetPropertyChangedSignal(propertyName):Connect(function()
local suspicious = humanoid.WalkSpeed <= 0.05 or humanoid.PlatformStand or (
humanoid.UseJumpPower and humanoid.JumpPower <= 0) or (
not humanoid.UseJumpPower and humanoid.JumpHeight <= 0) if suspicious then
capture("Humanoid." .. propertyName .. " changed" ) end end)) end
rememberConnection(humanoid.StateChanged:Connect(function(_, newState)
if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll
or newState == Enum.HumanoidStateType.FallingDown then
capture("Humanoid state " .. tostring(newState)) end end
)) end if root then
rememberConnection(root:GetPropertyChangedSignal("Anchored" ):Connect(function()
if root.Anchored then
capture("HumanoidRootPart.Anchored" ) end end)) end
rememberConnection(character.DescendantAdded:Connect(function(descendant)
local lower = string.lower(tostring(descendant.Name or "" ))
if string.find(lower, "freeze", 1, true) or string.find(lower, "stun", 1, true)
or string.find(lower, "shatter", 1, true) or string.find(lower, "dagger", 1, true)
or string.find(lower, "dimension", 1, true) then
capture("DescendantAdded " .. tostring(descendant.ClassName) .. ":" .. tostring( descendant.Name)) end end))
print("[Unicorn Hub][DaggerDiag] Passive diagnostics enabled." ) end
local function getAntiRagdollParts(character) if not character then
return nil, nil end local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
or character:FindFirstChild("Torso") return humanoid, root end
local function normalizeToolName(name) local lower = string.lower(tostring(name or ""))
return string.gsub(lower, "[%s_%-]", "") end
local function isAntiRagdollIncompatibleTool(tool)
if not tool or not tool:IsA("Tool") then
return false end local name = normalizeToolName(tool.Name)
return name == "fly" or name == "flytool" or name == "flying"
or name == "twoseatermagiccarpet" or string.find(name, "magiccarpet", 1, true) ~= nil
or string.find(name, "carpet", 1, true) ~= nil or name == "fusioncoil"
or string.find(name, "coil", 1, true) ~= nil end
local function restoreHumanoidRagdollStates(humanoid) if not humanoid then
return end pcall(function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end) end
local function clearAntiRagdollActiveConnections()
local nativeJointGuard = AntiRagdollToolConnections.NativeJointGuard
if nativeJointGuard and type(nativeJointGuard.Cleanup) == "function" then
pcall(nativeJointGuard.Cleanup) end AntiRagdollToolConnections.NativeJointGuard = nil
local hold = AntiRagdollToolConnections.AntiToolHold
for part in pairs(hold.FrozenParts or {}) do
if part.Parent and part.Anchored then
pcall(function() part.AssemblyLinearVelocity = Vector3.zero
part.AssemblyAngularVelocity = Vector3.zero part.Anchored = false end) end end
hold.FrozenParts = {} hold.NativeLock = false hold.SkipNativeResidual = false
if hold.OwnsAnchor and hold.LockedRoot and hold.LockedRoot.Parent then
pcall(function()
if hold.LockedRoot.Anchored then hold.LockedRoot.Anchored = false end end) end
hold.LockedRoot = nil hold.OwnsAnchor = false hold.Anchor = nil hold.Reason = nil
hold.PullUntil = 0 hold.LastRelease = 0 if AntiRagdollStateConnection then
AntiRagdollStateConnection:Disconnect() AntiRagdollStateConnection = nil end
if AntiRagdollHeartbeatConnection then
AntiRagdollHeartbeatConnection:Disconnect() AntiRagdollHeartbeatConnection = nil end
local jokerState = AntiRagdollToolConnections.JokerState
for _, key in ipairs({"Connection", "PhysicsConnection", "RenderConnection"}) do
if jokerState[key] then
jokerState[key]:Disconnect() jokerState[key] = nil end end
if jokerState.OwnsAnchor and jokerState.LockedRoot
and jokerState.LockedRoot.Parent and jokerState.LockedRoot.Anchored then
jokerState.LockedRoot.Anchored = false end jokerState.LockedRoot = nil
jokerState.OwnsAnchor = false jokerState.Until = 0 jokerState.Anchor = nil
jokerState.Snapshot = nil jokerState.SnapshotAt = 0
local impactState = AntiRagdollToolConnections.ImpactState
for _, key in ipairs({"PhysicsConnection", "RenderConnection"}) do
if impactState[key] then
impactState[key]:Disconnect() impactState[key] = nil end end
if impactState.OwnsAnchor and impactState.LockedRoot
and impactState.LockedRoot.Parent and impactState.LockedRoot.Anchored then
impactState.LockedRoot.Anchored = false end impactState.LockedRoot = nil
impactState.OwnsAnchor = false impactState.Anchor = nil impactState.Until = 0
impactState.LastSafe = nil impactState.LastSafeAt = 0 impactState.LastVelocity = nil
impactState.LastVelocityAt = 0 impactState.LastPosition = nil
impactState.LastPositionAt = 0 impactState.LastRelease = 0
local threat = AntiRagdollToolConnections.ThreatState threat.Generation += 1
if threat.Connection then
threat.Connection:Disconnect() threat.Connection = nil end threat.SafeTime = 0
threat.LastAttempt = 0 local carryLanding = AntiRagdollToolConnections.CarryLanding
carryLanding.Token += 1 if carryLanding.OwnsAnchor and carryLanding.LockedRoot
and carryLanding.LockedRoot.Parent and carryLanding.LockedRoot.Anchored then
carryLanding.LockedRoot.Anchored = false end carryLanding.LockedRoot = nil
carryLanding.OwnsAnchor = false carryLanding.Recovering = false
]===================================],
[===================================[carryLanding.Character = nil local listeners = AntiRagdollToolConnections.ActiveListeners
for _, connection in ipairs(listeners) do
connection:Disconnect() end table.clear(listeners) AntiRagdollRecovering = false end
local function clearAntiRagdollToolConnections()
for _, connection in ipairs(AntiRagdollToolConnections) do
connection:Disconnect() end for index = #AntiRagdollToolConnections, 1, -1 do
AntiRagdollToolConnections[index] = nil end end
local function clearAntiRagdollWatchConnections()
for _, connection in ipairs(AntiRagdollWatchConnections) do
connection:Disconnect() end table.clear(AntiRagdollWatchConnections)
clearAntiRagdollToolConnections() end local function clearAntiRagdollConnections()
clearAntiRagdollActiveConnections() end
local function hardDisableAntiRagdollForTool(character, tool)
if not AntiRagdollEnabled then
return end AntiRagdollResumeToken += 1 AntiRagdollToolSuspended = true
clearAntiRagdollActiveConnections() AntiRagdollSafeAt = 0
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
restoreHumanoidRagdollStates(humanoid)
print("[Unicorn Hub] Anti Ragdoll pausado para usar " .. tostring(tool and tool.Name or "Tool") .. "." ) end
local function resumeAntiRagdollWhenStable(character) AntiRagdollResumeToken += 1
local myToken = AntiRagdollResumeToken task.spawn(function() task.wait(0.45)
if myToken ~= AntiRagdollResumeToken or not AntiRagdollEnabled or AntiRagdollFlySuspended
or player.Character ~= character then
return end for _, equipped in ipairs(character:GetChildren()) do
if isAntiRagdollIncompatibleTool(equipped) then
return end end local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not root or humanoid.Health <= 0 then
return end restoreHumanoidRagdollStates(humanoid) if humanoid.PlatformStand then
humanoid.PlatformStand = false end if humanoid.Sit and not humanoid.SeatPart then
humanoid.Sit = false end local state = humanoid:GetState()
if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.FallingDown then
pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end) end
local deadline = os.clock() + 4 while os.clock() < deadline do
if myToken ~= AntiRagdollResumeToken or not AntiRagdollEnabled or player.Character ~= character then
return end for _, equipped in ipairs(character:GetChildren()) do
if isAntiRagdollIncompatibleTool(equipped) then
return end end humanoid = character:FindFirstChildOfClass("Humanoid")
root = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not root or humanoid.Health <= 0 then
return end local currentState = humanoid:GetState()
local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
local normalState = currentState ~= Enum.HumanoidStateType.Physics
and currentState ~= Enum.HumanoidStateType.Ragdoll
and currentState ~= Enum.HumanoidStateType.FallingDown and not humanoid.PlatformStand
if grounded and normalState then
AntiRagdollSafeAt = os.clock() AntiRagdollToolSuspended = false bindAntiRagdoll(character)
print("[Unicorn Hub] Anti Ragdoll reativado após pousar.") return end task.wait(0.08) end
if myToken == AntiRagdollResumeToken and AntiRagdollEnabled and not AntiRagdollFlySuspended
and player.Character == character then
task.delay(0.5, function()
if myToken == AntiRagdollResumeToken and AntiRagdollEnabled and not AntiRagdollFlySuspended
and player.Character == character then
resumeAntiRagdollWhenStable(character) end end) end end) end
local function bindIncompatibleTool(tool, character)
if not isAntiRagdollIncompatibleTool(tool) then
return end table.insert(AntiRagdollToolConnections, tool.Equipped:Connect(function()
hardDisableAntiRagdollForTool(character, tool) end))
table.insert(AntiRagdollToolConnections, tool.Activated:Connect(function()
hardDisableAntiRagdollForTool(character, tool) end))
table.insert(AntiRagdollToolConnections, tool.Unequipped:Connect(function()
resumeAntiRagdollWhenStable(character) end)) if tool.Parent == character then
hardDisableAntiRagdollForTool(character, tool) end end
watchAntiRagdollTools = function(character) clearAntiRagdollWatchConnections()
if not AntiRagdollEnabled or not character then
return end
local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
if backpack then
for _, obj in ipairs(backpack:GetChildren()) do
bindIncompatibleTool(obj, ch... (2 MB restante(s))
