local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- База скинченджера с Asset ID из твоего списка
local WeaponDatabase = {
    ["Icebreaker"] = {AssetID = 6022874136, Type = "Knife"},
    ["Harvester"] = {AssetID = 7800847534, Type = "Gun"},
    ["Icepiercer"] = {AssetID = 11834434264, Type = "Gun"},
    ["Bat"] = {AssetID = 11229779932, Type = "Knife"},
    ["Corrupt"] = {AssetID = 197879343, Type = "Knife"},
    ["Nikilis"] = {AssetID = 3184125538, Type = "Knife"},
    ["Lugercane"] = {AssetID = 4488391411, Type = "Gun"},
    ["ChromaLuger"] = {AssetID = 332044679, Type = "Gun"},
    ["Pixel"] = {AssetID = 235381341, Type = "Knife"},
    ["Slasher"] = {AssetID = 3187392501, Type = "Knife"},
    ["Bioblade"] = {AssetID = 4659627458, Type = "Knife"},
    ["Prismatic"] = {AssetID = 5360359935, Type = "Knife"},
    ["Db"] = {AssetID = 4749071819, Type = "Gun"}
}

-- Кеш загруженных мешей, чтобы не спамить запросами
local LoadedMeshCache = {}

-- Функция безопасной загрузки MeshId и TextureId из AssetID
local function getMeshDetails(assetId)
    if LoadedMeshCache[assetId] then
        return LoadedMeshCache[assetId]
    end

    local success, model = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)

    if success and model then
        local meshPart = model:FindFirstChildWhichIsA("MeshPart", true)
        local specialMesh = model:FindFirstChildWhichIsA("SpecialMesh", true)

        local data = {}
        if meshPart then
            data.MeshId = meshPart.MeshId
            data.TextureId = meshPart.TextureID
        elseif specialMesh then
            data.MeshId = specialMesh.MeshId
            data.TextureId = specialMesh.TextureId
        end

        model:Destroy()
        if data.MeshId then
            LoadedMeshCache[assetId] = data
            return data
        end
    end

    return nil
end

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

-- Применение данных к детали (Part / MeshPart)
local function applyToHandle(targetPart, assetId)
    local details = getMeshDetails(assetId)
    if not details then return end

    if targetPart:IsA("MeshPart") then
        targetPart.MeshId = details.MeshId
        if details.TextureId ~= "" then
            targetPart.TextureID = details.TextureId
        end
    else
        local mesh = targetPart:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.Parent = targetPart
        end
        mesh.MeshId = details.MeshId
        if details.TextureId ~= "" then
            mesh.TextureId = details.TextureId
        end
    end
end

-- Отримання скіна з ProfileData
local function getEquippedSkinName(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Полное обновление визуалов (в руках + на теле)
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkinName("Knife")
    local gunSkin = getEquippedSkinName("Gun")

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- 1. Предметы в руках (Tool)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local handle = child:FindFirstChild("Handle")
            if handle then
                if (child.Name == "Knife" or child:FindFirstChild("Knife")) and knifeData then
                    applyToHandle(handle, knifeData.AssetID)
                elseif (child.Name == "Gun" or child:FindFirstChild("Gun")) and gunData then
                    applyToHandle(handle, gunData.AssetID)
                end
            end
        end
    end

    -- 2. Предметы на теле (Нож/Пистолет в кобуре или на спине)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            if child.Name == "Knife" and knifeData then
                local handle = child:IsA("BasePart") and child or child:FindFirstChild("Handle")
                if handle then applyToHandle(handle, knifeData.AssetID) end
            elseif child.Name == "Gun" and gunData then
                local handle = child:IsA("BasePart") and child or child:FindFirstChild("Handle")
                if handle then applyToHandle(handle, gunData.AssetID) end
            end
        end
    end
end

-- Обработка спавна и экипировки
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
