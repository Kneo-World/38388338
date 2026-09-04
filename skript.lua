local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- База данных скинченджера (MeshID & TextureID)
local WeaponDatabase = {
    ["Icebreaker"] = {MeshId = "rbxassetid://6022874136", TextureId = "rbxassetid://6022874251", Type = "Knife"},
    ["Harvester"] = {MeshId = "rbxassetid://7800847534", TextureId = "rbxassetid://7800847683", Type = "Gun"},
    ["Icepiercer"] = {MeshId = "rbxassetid://11834434264", TextureId = "rbxassetid://11834434400", Type = "Gun"},
    ["Bat"] = {MeshId = "rbxassetid://11229779932", TextureId = "rbxassetid://11229780100", Type = "Knife"},
    ["Corrupt"] = {MeshId = "rbxassetid://197879343", TextureId = "rbxassetid://197879357", Type = "Knife"},
    ["Nikilis"] = {MeshId = "rbxassetid://3184125538", TextureId = "rbxassetid://3184125700", Type = "Knife"},
    ["Lugercane"] = {MeshId = "rbxassetid://4488391411", TextureId = "rbxassetid://4488391550", Type = "Gun"},
    ["ChromaLuger"] = {MeshId = "rbxassetid://332044679", TextureId = "rbxassetid://332044810", Type = "Gun"},
    ["Pixel"] = {MeshId = "rbxassetid://235381341", TextureId = "rbxassetid://235381480", Type = "Knife"},
    ["Slasher"] = {MeshId = "rbxassetid://3187392501", TextureId = "rbxassetid://3187392650", Type = "Knife"},
    ["Bioblade"] = {MeshId = "rbxassetid://4659627458", TextureId = "rbxassetid://4659627600", Type = "Knife"},
    ["Prismatic"] = {MeshId = "rbxassetid://5360359935", TextureId = "rbxassetid://5360360080", Type = "Knife"},
    ["Db"] = {MeshId = "rbxassetid://4749071819", TextureId = "rbxassetid://4749071980", Type = "Gun"}
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

-- Функция смены визуального меша детали
local function applySkinToPart(targetPart, skinData)
    if not targetPart or not skinData then return end

    local mesh = targetPart:FindFirstChildOfClass("SpecialMesh")
    
    if targetPart:IsA("MeshPart") then
        if skinData.MeshId then targetPart.MeshId = skinData.MeshId end
        if skinData.TextureId then targetPart.TextureID = skinData.TextureId end
    else
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.Parent = targetPart
        end
        if skinData.MeshId then mesh.MeshId = skinData.MeshId end
        if skinData.TextureId then mesh.TextureId = skinData.TextureId end
    end
end

-- Получение экипированного скина из ProfileData
local function getEquippedSkinName(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Обновление моделей у персонажа (кобура на теле + оружие в руках)
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local equippedKnife = getEquippedSkinName("Knife")
    local equippedGun = getEquippedSkinName("Gun")

    local knifeData = WeaponDatabase[equippedKnife]
    local gunData = WeaponDatabase[equippedGun]

    -- 1. Отображение на теле (кобура / спина)
    local refKnife = char:FindFirstChild("DisplayRefKnife")
    if refKnife and refKnife.Value and knifeData then
        applySkinToPart(refKnife.Value, knifeData)
    end

    local refGun = char:FindFirstChild("DisplayRefGun")
    if refGun and refGun.Value and gunData then
        applySkinToPart(refGun.Value, gunData)
    end

    -- 2. Предмет в руках (Tool)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local handle = child:FindFirstChild("Handle")
            if handle then
                -- Если держим нож
                if (child.Name == "Knife" or child:FindFirstChild("Knife")) and knifeData then
                    applySkinToPart(handle, knifeData)
                -- Если держим пистолет
                elseif (child.Name == "Gun" or child:FindFirstChild("Gun")) and gunData then
                    applySkinToPart(handle, gunData)
                end
            end
        end
    end
end

-- 3. Подключение обработчиков персонажа
local function setupCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child.Name:find("DisplayRef") then
            task.wait(0.05)
            refreshVisuals()
        end
    end)
    task.spawn(function()
        task.wait(0.2)
        refreshVisuals()
    end)
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Постоянное отслеживание изменений смены скина в GUI
task.spawn(function()
    while task.wait(0.3) do
        refreshVisuals()
    end
end)

