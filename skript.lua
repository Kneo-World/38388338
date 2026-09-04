local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- База мешей и текстур MM2 (с правильным форматом rbxassetid://)
local WeaponDatabase = {
    ["Icebreaker"] = {MeshId = "rbxassetid://6022874136", TextureId = "rbxassetid://6022874251"},
    ["Harvester"] = {MeshId = "rbxassetid://7800847534", TextureId = "rbxassetid://7800847683"},
    ["Icepiercer"] = {MeshId = "rbxassetid://11834434264", TextureId = "rbxassetid://11834434400"},
    ["Bat"] = {MeshId = "rbxassetid://11229779932", TextureId = "rbxassetid://11229780100"},
    ["Corrupt"] = {MeshId = "rbxassetid://197879343", TextureId = "rbxassetid://197879357"},
    ["Nikilis"] = {MeshId = "rbxassetid://3184125538", TextureId = "rbxassetid://3184125700"},
    ["Lugercane"] = {MeshId = "rbxassetid://4488391411", TextureId = "rbxassetid://4488391550"},
    ["ChromaLuger"] = {MeshId = "rbxassetid://332044679", TextureId = "rbxassetid://332044810"},
    ["Pixel"] = {MeshId = "rbxassetid://235381341", TextureId = "rbxassetid://235381480"},
    ["Slasher"] = {MeshId = "rbxassetid://3187392501", TextureId = "rbxassetid://3187392650"},
    ["Bioblade"] = {MeshId = "rbxassetid://4659627458", TextureId = "rbxassetid://4659627600"},
    ["Prismatic"] = {MeshId = "rbxassetid://5360359935", TextureId = "rbxassetid://5360360080"},
    ["Db"] = {MeshId = "rbxassetid://4749071819", TextureId = "rbxassetid://4749071980"}
}

-- 1. Выдаем скины в инвентарь MM2
for skinID, _ in pairs(WeaponDatabase) do
    ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
end

-- 2. Обновляем GUI инвентаря
if InventoryModule.MyInventory then
    InventoryModule.MyInventory = InventoryModule.GenerateInventory(
        InventoryModule.GUI.MyInventory, 
        ProfileData, 
        "Main"
    )
    InventoryModule.SortInventory(InventoryModule.MyInventory)
    InventoryModule.ConnectEquipButtons()
end

-- Функция принудительной установки меша и текстуры
local function applyMeshToObj(obj, data)
    if not obj or not data then return end

    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    if not targetPart then return end

    if targetPart:IsA("MeshPart") then
        targetPart.MeshId = data.MeshId
        if data.TextureId then targetPart.TextureID = data.TextureId end
    else
        local mesh = targetPart:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.Parent = targetPart
        end
        mesh.MeshId = data.MeshId
        if data.TextureId then mesh.TextureId = data.TextureId end
    end
end

-- Получение надетого скина из ProfileData
local function getEquippedSkin(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Проверка принадлежит ли WeaponDisplay твоему персонажу
local function isMyDisplay(displayObj)
    if not LocalPlayer.Character then return false end

    -- Поиск Weld / WeldConstraint, привязанного к твоему персонажу
    for _, descendant in ipairs(displayObj:GetDescendants()) do
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            if (descendant.Part0 and descendant.Part0:IsDescendantOf(LocalPlayer.Character)) or
               (descendant.Part1 and descendant.Part1:IsDescendantOf(LocalPlayer.Character)) then
                return true
            end
        end
    end
    return false
end

-- Обновление визуала
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- A. Оружие в руках (Tool)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                if (item.Name == "Knife" or item:FindFirstChild("Knife")) and knifeData then
                    applyMeshToObj(handle, knifeData)
                elseif (item.Name == "Gun" or item:FindFirstChild("Gun")) and gunData then
                    applyMeshToObj(handle, gunData)
                end
            end
        end
    end

    -- B. Оружие на теле (в workspace.WeaponDisplays)
    local weaponDisplaysFolder = Workspace:FindFirstChild("WeaponDisplays")
    if weaponDisplaysFolder then
        for _, display in ipairs(weaponDisplaysFolder:GetChildren()) do
            if isMyDisplay(display) then
                if display.Name:find("Knife") and knifeData then
                    applyMeshToObj(display, knifeData)
                elseif display.Name:find("Gun") and gunData then
                    applyMeshToObj(display, gunData)
                end
            end
        end
    end
end

-- Подключение к персонажу и папке WeaponDisplays
local function setupListeners()
    local function connectChar(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.05)
                refreshVisuals()
            end
        end)
    end

    if LocalPlayer.Character then connectChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(connectChar)

    local displaysFolder = Workspace:WaitForChild("WeaponDisplays", 5)
    if displaysFolder then
        displaysFolder.ChildAdded:Connect(function()
            task.wait(0.1)
            refreshVisuals()
        end)
    end
end

setupListeners()

-- Постоянное обновление при смене в инвентаре
task.spawn(function()
    while task.wait(0.3) do
        refreshVisuals()
    end
end)
