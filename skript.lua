local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- Список скінів для додавання
local skinsToAdd = {
    "Icebreaker", "Harvester", "Icepiercer", "Bat", "Candyleaf",
    "Corrupt", "Nikilis", "Lugercane", "ChromaLuger", "Amerikatan",
    "Pixel", "Slasher", "Bioblade", "Prismatic", "Db"
}

-- 1. Видаємо скіни
for _, skinID in ipairs(skinsToAdd) do
    ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
end

-- 2. Оновлюємо GUI
if InventoryModule.MyInventory then
    InventoryModule.MyInventory = InventoryModule.GenerateInventory(
        InventoryModule.GUI.MyInventory, 
        ProfileData, 
        "Main"
    )
    InventoryModule.SortInventory(InventoryModule.MyInventory)
    InventoryModule.ConnectEquipButtons()
end

-- Гнучкий пошук моделі в ReplicatedStorage
local function findWeaponModel(skinName)
    if not skinName then return nil end
    local cleanName = string.lower(skinName)

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool") then
            local objName = string.lower(obj.Name)
            if objName == cleanName or objName == "knife_" .. cleanName or objName == "gun_" .. cleanName then
                return obj
            end
        end
    end
    return nil
end

-- Отримання поточної екіпірованої зброї з ProfileData
local function getEquippedSkin(category) -- "Knife" або "Gun"
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Заміна візуалу в конкретній Part / Handle
local function swapVisuals(targetPart, sourceModel)
    if not targetPart or not sourceModel then return end

    -- Пошук меша у джерелі
    local sourceMesh = sourceModel:FindFirstChildOfClass("SpecialMesh") or (sourceModel:IsA("MeshPart") and sourceModel)
    if not sourceMesh then
        sourceMesh = sourceModel:FindFirstChildWhichIsA("BasePart", true)
    end

    if not sourceMesh then return end

    -- Пошук або створення SpecialMesh у цілі
    local targetMesh = targetPart:FindFirstChildOfClass("SpecialMesh")
    if not targetMesh and not targetPart:IsA("MeshPart") then
        targetMesh = Instance.new("SpecialMesh", targetPart)
    end

    -- Копіювання параметрів
    if sourceMesh:IsA("SpecialMesh") and targetMesh then
        targetMesh.MeshId = sourceMesh.MeshId
        targetMesh.TextureId = sourceMesh.TextureId
        targetMesh.Scale = sourceMesh.Scale
    elseif sourceMesh:IsA("MeshPart") then
        if targetPart:IsA("MeshPart") then
            targetPart.MeshId = sourceMesh.MeshId
            targetPart.TextureID = sourceMesh.TextureID
        elseif targetMesh then
            targetMesh.MeshId = sourceMesh.MeshId
            targetMesh.TextureId = sourceMesh.TextureID
        end
    end

    -- Копіювання кольору та текстури
    targetPart.Color = sourceMesh.Color
    targetPart.Material = sourceMesh.Material
end

-- Оновлення кобури / спини та інструменту в руках
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    -- 1. Спина / Пояс (DisplayRef)
    local refKnife = char:FindFirstChild("DisplayRefKnife")
    if refKnife and refKnife.Value and knifeSkin then
        local model = findWeaponModel(knifeSkin)
        if model then swapVisuals(refKnife.Value, model) end
    end

    local refGun = char:FindFirstChild("DisplayRefGun")
    if refGun and refGun.Value and gunSkin then
        local model = findWeaponModel(gunSkin)
        if model then swapVisuals(refGun.Value, model) end
    end

    -- 2. Зброя в руках (Tool)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                if (item.Name == "Knife" or item:FindFirstChild("Knife")) and knifeSkin then
                    local model = findWeaponModel(knifeSkin)
                    if model then swapVisuals(handle, model) end
                elseif (item.Name == "Gun" or item:FindFirstChild("Gun")) and gunSkin then
                    local model = findWeaponModel(gunSkin)
                    if model then swapVisuals(handle, model) end
                end
            end
        end
    end
end

-- 3. Підключення до персонажа
local function setupCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child.Name:find("DisplayRef") then
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

-- Авто-оновлення при зміні вибору в GUI
task.spawn(function()
    while task.wait(0.5) do
        refreshVisuals()
    end
end)
