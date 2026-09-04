local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- Список скінів для додавання в GUI
local skinsToAdd = {
    "Icebreaker",
    "Harvester",
    "Icepiercer",
    "Bat",
    "Candyleaf",
    "Corrupt",
    "Nikilis",
    "Lugercane",
    "ChromaLuger",
    "Amerikatan",
    "Pixel",
    "Slasher",
    "Bioblade",
    "Prismatic",
    "Db"
}

-- 1. Додаємо скіни в локальний профіль
for _, skinID in ipairs(skinsToAdd) do
    ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
end

-- 2. Оновлюємо інвентар у GUI
if InventoryModule.MyInventory then
    InventoryModule.MyInventory = InventoryModule.GenerateInventory(
        InventoryModule.GUI.MyInventory, 
        ProfileData, 
        "Main"
    )
    InventoryModule.SortInventory(InventoryModule.MyInventory)
    InventoryModule.ConnectEquipButtons()
end

-- Функція пошуку вихідного меша з бази MM2
local function getSkinMesh(skinName)
    local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons") or ReplicatedStorage:FindFirstChild("Database")
    if not weaponsFolder then return nil end
    
    local customModel = weaponsFolder:FindFirstChild(skinName, true)
    if customModel then
        local mesh = customModel:FindFirstChildOfClass("SpecialMesh") or customModel:FindFirstChildOfClass("MeshPart")
        return mesh
    end
    return nil
end

-- Повна заміна сітки/текстури об'єкта
local function applyMeshToTarget(targetPart, sourceMesh)
    if not targetPart or not sourceMesh then return end
    
    local targetMesh = targetPart:FindFirstChildOfClass("SpecialMesh")
    
    if sourceMesh:IsA("SpecialMesh") and targetMesh then
        targetMesh.MeshId = sourceMesh.MeshId
        targetMesh.TextureId = sourceMesh.TextureId
    elseif sourceMesh:IsA("MeshPart") then
        if targetPart:IsA("MeshPart") then
            targetPart.MeshId = sourceMesh.MeshId
            targetPart.TextureID = sourceMesh.TextureID
        elseif targetMesh then
            targetMesh.MeshId = sourceMesh.MeshId
            targetMesh.TextureId = sourceMesh.TextureID
        end
    end
end

-- 3. Оновлення відображення зброї на тілі (KnifeDisplay / GunDisplay)
local function updateBodyDisplays(char)
    local equippedKnife = ProfileData.Weapons.Equipped.Knife or (ProfileData.Weapons.Equipped.Weapons and ProfileData.Weapons.Equipped.Weapons.Knife)
    local equippedGun = ProfileData.Weapons.Equipped.Gun or (ProfileData.Weapons.Equipped.Weapons and ProfileData.Weapons.Equipped.Weapons.Gun)

    -- Обробка ножа на тілі
    local refKnife = char:FindFirstChild("DisplayRefKnife")
    if refKnife and refKnife.Value and equippedKnife then
        local sourceMesh = getSkinMesh(equippedKnife)
        if sourceMesh then
            applyMeshToTarget(refKnife.Value, sourceMesh)
        end
    end

    -- Обробка гана на тілі
    local refGun = char:FindFirstChild("DisplayRefGun")
    if refGun and refGun.Value and equippedGun then
        local sourceMesh = getSkinMesh(equippedGun)
        if sourceMesh then
            applyMeshToTarget(refGun.Value, sourceMesh)
        end
    end
end

-- 4. Перехоплення екіпірування зброї в руки
local function setupCharacter(char)
    -- Оновлюємо кобуру/спину при появі персонажа
    task.spawn(function()
        task.wait(0.2)
        updateBodyDisplays(char)
    end)

    -- Стежимо за тим, коли гравець бере зброю у руки
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.05)
            
            local equippedKnife = ProfileData.Weapons.Equipped.Knife or (ProfileData.Weapons.Equipped.Weapons and ProfileData.Weapons.Equipped.Weapons.Knife)
            local equippedGun = ProfileData.Weapons.Equipped.Gun or (ProfileData.Weapons.Equipped.Weapons and ProfileData.Weapons.Equipped.Weapons.Gun)

            if (child.Name == "Knife" or child:FindFirstChild("Knife")) and equippedKnife then
                local sourceMesh = getSkinMesh(equippedKnife)
                local handle = child:FindFirstChild("Handle")
                if handle and sourceMesh then
                    applyMeshToTarget(handle, sourceMesh)
                end
            elseif (child.Name == "Gun" or child:FindFirstChild("Gun")) and equippedGun then
                local sourceMesh = getSkinMesh(equippedGun)
                local handle = child:FindFirstChild("Handle")
                if handle and sourceMesh then
                    applyMeshToTarget(handle, sourceMesh)
                end
            end
        end
    end)
end

-- Запуск для поточного персонажа
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Перезапуск при кожному респавні
LocalPlayer.CharacterAdded:Connect(setupCharacter)
