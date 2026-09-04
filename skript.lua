local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- База данных мешей и текстур (вместо моделек используем прямые rbxassetid://)
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

-- 1. Добавляем скины в ProfileData
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

-- Функция безопасной подмены меша и текстуры на детали
local function applyMeshAndTexture(part, data)
    if not part or not data then return end

    if part:IsA("MeshPart") then
        part.MeshId = data.MeshId
        if data.TextureId then part.TextureID = data.TextureId end
    else
        local mesh = part:FindFirstChildOfClass("SpecialMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.Parent = part
        end
        mesh.MeshId = data.MeshId
        if data.TextureId then mesh.TextureId = data.TextureId end
    end
end

-- Получаем текущий выбранный скин из профиля
local function getEquippedSkin(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Обновляем визуал на персонаже
local function refreshVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- 1. Нож / Пистолет в руках (Tool)
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle then
                if (item.Name == "Knife" or item:FindFirstChild("Knife")) and knifeData then
                    applyMeshAndTexture(handle, knifeData)
                elseif (item.Name == "Gun" or item:FindFirstChild("Gun")) and gunData then
                    applyMeshAndTexture(handle, gunData)
                end
            end
        end
    end

    -- 2. Предметы на теле (кобура / за спиной / DisplayRef)
    for _, child in ipairs(char:GetChildren()) do
        -- Если MM2 использует DisplayRef
        if child.Name == "DisplayRefKnife" and child.Value and knifeData then
            applyMeshAndTexture(child.Value, knifeData)
        elseif child.Name == "DisplayRefGun" and child.Value and gunData then
            applyMeshAndTexture(child.Value, gunData)
        end

        -- Если меш висит как модель на теле
        if child:IsA("Model") then
            local handle = child:FindFirstChild("Handle") or child:FindFirstChildWhichIsA("BasePart")
            if handle then
                if child.Name == "Knife" and knifeData then
                    applyMeshAndTexture(handle, knifeData)
                elseif child.Name == "Gun" and gunData then
                    applyMeshAndTexture(handle, gunData)
                end
            end
        end
    end
end

-- Следим за обновлением персонажа
local function setupCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") or child:IsA("Model") or child.Name:find("DisplayRef") then
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

-- Цикл проверки смены скина в инвентаре
task.spawn(function()
    while task.wait(0.4) do
        refreshVisuals()
    end
end)
