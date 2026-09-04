local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- 1. Список скинов для добавления в инвентарь
local skinsToAdd = {
    "Icebreaker", "Harvester", "Icepiercer", "Bat", "Candyleaf",
    "Corrupt", "Nikilis", "Lugercane", "ChromaLuger", "Amerikatan",
    "Pixel", "Slasher", "Bioblade", "Prismatic", "Db"
}

-- Выдаем скины в инвентарь MM2
for _, skinID in ipairs(skinsToAdd) do
    ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
end

-- Обновляем GUI инвентаря
if InventoryModule.MyInventory then
    InventoryModule.MyInventory = InventoryModule.GenerateInventory(
        InventoryModule.GUI.MyInventory, 
        ProfileData, 
        "Main"
    )
    InventoryModule.SortInventory(InventoryModule.MyInventory)
    InventoryModule.ConnectEquipButtons()
end

-- Поиск оригинальной модели оружия в ReplicatedStorage или каталогах игры
local function getGameWeaponModel(skinName)
    if not skinName then return nil end
    local searchName = string.lower(skinName)

    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Tool")) then
            local objName = string.lower(obj.Name)
            if objName == searchName or objName == "knife_" .. searchName or objName == "gun_" .. searchName then
                return obj
            end
        end
    end
    return nil
end

-- Скопировать визуал из оригинальной модели в Handle
local function copyVisuals(targetHandle, sourceModel)
    if not targetHandle or not sourceModel then return end

    local sourcePart = sourceModel:FindFirstChild("Handle") or sourceModel:FindFirstChildWhichIsA("BasePart", true)
    if not sourcePart then return end

    -- Очищаем старый визуал у целевой детали
    for _, child in ipairs(targetHandle:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") then
            child:Destroy()
        end
    end

    -- Переносим меш
    local sourceMesh = sourcePart:FindFirstChildOfClass("SpecialMesh")
    if sourceMesh then
        local newMesh = sourceMesh:Clone()
        newMesh.Parent = targetHandle
    elseif sourcePart:IsA("MeshPart") then
        local newMesh = Instance.new("SpecialMesh")
        newMesh.MeshId = sourcePart.MeshId
        newMesh.TextureId = sourcePart.TextureID
        newMesh.Scale = sourcePart.Size
        newMesh.Parent = targetHandle
    end

    -- Переносим цвет и материал
    targetHandle.Color = sourcePart.Color
    targetHandle.Material = sourcePart.Material
    targetHandle.Transparency = sourcePart.Transparency
end

-- Получить экипированный скин из ProfileData
local function getEquippedSkin(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Обновление моделей у персонажа
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    -- 1. Нож / Пистолет в руках (Tool)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                if (item.Name == "Knife" or item:FindFirstChild("Knife")) and knifeSkin then
                    local model = getGameWeaponModel(knifeSkin)
                    if model then copyVisuals(handle, model) end
                elseif (item.Name == "Gun" or item:FindFirstChild("Gun")) and gunSkin then
                    local model = getGameWeaponModel(gunSkin)
                    if model then copyVisuals(handle, model) end
                end
            end
        end
    end

    -- 2. Нож / Пистолет на теле (кобура / спина)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and (child.Name == "Knife" or child.Name == "Gun") then
            local handle = child:FindFirstChild("Handle") or child:FindFirstChildWhichIsA("BasePart")
            if handle then
                if child.Name == "Knife" and knifeSkin then
                    local model = getGameWeaponModel(knifeSkin)
                    if model then copyVisuals(handle, model) end
                elseif child.Name == "Gun" and gunSkin then
                    local model = getGameWeaponModel(gunSkin)
                    if model then copyVisuals(handle, model) end
                end
            end
        end
    end
end

-- Слушатели персонажа
local function setupCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child:IsA("Model") then
            task.wait(0.1)
            refreshVisuals()
        end
    end)
    task.spawn(function()
        task.wait(0.3)
        refreshVisuals()
    end)
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

task.spawn(function()
    while task.wait(0.5) do
        refreshVisuals()
    end
end)
