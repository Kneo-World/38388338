local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

print("=== [SKIN CHANGER] Перезапуск с исправлением ProfileData ===")

-- Получаем ProfileData
local ProfileDataModule = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData")
local ProfileData = require(ProfileDataModule)

-- Если ProfileData является функцией, вызываем её
local UserProfile = type(ProfileData) == "function" and ProfileData(LocalPlayer) or ProfileData
if type(UserProfile) == "table" and UserProfile.Get then
    UserProfile = UserProfile:Get() or UserProfile
end

print("[OK] Структура ProfileData найдена!")

-- База данных скинов
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

-- Выдача предметов в табличную структуру
if UserProfile then
    local weaponsTable = UserProfile.Weapons or UserProfile.Owned or UserProfile
    if type(weaponsTable) == "table" then
        weaponsTable.Owned = weaponsTable.Owned or {}
        for skinID, _ in pairs(WeaponDatabase) do
            weaponsTable.Owned[skinID] = (weaponsTable.Owned[skinID] or 0) + 1
        end
        print("[SUCCESS] Скины успешно занесены в профиль!")
    end
end

-- Подмена меша в Part/Tool
local function applyMeshToPart(part, data, skinName)
    if not part or not data then return end

    if part:IsA("MeshPart") then
        part.MeshId = data.MeshId
        if data.TextureId then part.TextureID = data.TextureId end
        return
    end

    local innerMesh = part:FindFirstChild("Mesh") 
        or part:FindFirstChildOfClass("SpecialMesh") 
        or part:FindFirstChildWhichIsA("DataModelMesh")

    if innerMesh then
        innerMesh.MeshId = data.MeshId
        if data.TextureId then innerMesh.TextureId = data.TextureId end
    else
        local newMesh = Instance.new("SpecialMesh")
        newMesh.Name = "Mesh"
        newMesh.MeshId = data.MeshId
        if data.TextureId then newMesh.TextureId = data.TextureId end
        newMesh.Parent = part
    end
    print("  [✓] Заменен меш на:", skinName, "в", part.Name)
end

-- Получение экипированного скина
local function getEquippedSkin(category)
    if not UserProfile then return nil end
    local equipped = UserProfile.Equipped or (UserProfile.Weapons and UserProfile.Weapons.Equipped)
    if type(equipped) == "table" then
        return equipped[category] or (equipped.Weapons and equipped.Weapons[category])
    end
    return nil
end

-- Проверка привязки дисплея на теле
local function isMyDisplay(displayObj)
    local char = LocalPlayer.Character
    if not char then return false end

    for _, descendant in ipairs(displayObj:GetDescendants()) do
        if descendant:IsA("RigidConstraint") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            local p0 = descendant:IsA("RigidConstraint") and descendant.Attachment0 or descendant.Part0
            local p1 = descendant:IsA("RigidConstraint") and descendant.Attachment1 or descendant.Part1
            
            if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                return true
            end
        end
    end
    return false
end

-- Главная функция обновления визуалов
local function refreshAllVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    local knifeSkin = getEquippedSkin("Knife") or "Icebreaker" -- дефолт для теста, если не надето
    local gunSkin = getEquippedSkin("Gun") or "Harvester"

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- 1. Предметы в инвентаре и руках
    local containers = {LocalPlayer:FindFirstChild("Backpack"), char}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local isKnife = item.Name:find("Knife") or item:FindFirstChild("Knife")
                    local isGun = item.Name:find("Gun") or item:FindFirstChild("Gun")
                    local data = isKnife and knifeData or (isGun and gunData or nil)
                    local skinName = isKnife and knifeSkin or gunSkin

                    if data then
                        item.TextureId = data.TextureId or data.MeshId
                        local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            applyMeshToPart(handle, data, skinName)
                        end
                    end
                end
            end
        end
    end

    -- 2. Предметы на теле (WeaponDisplays)
    local weaponDisplaysFolder = Workspace:FindFirstChild("WeaponDisplays")
    if weaponDisplaysFolder then
        for _, display in ipairs(weaponDisplaysFolder:GetChildren()) do
            if isMyDisplay(display) then
                if display.Name:find("Knife") and knifeData then
                    applyMeshToPart(display, knifeData, knifeSkin)
                elseif display.Name:find("Gun") and gunData then
                    applyMeshToPart(display, gunData, gunSkin)
                end
            end
        end
    end
end

-- Запуск цикла
task.spawn(function()
    while task.wait(0.5) do
        refreshAllVisuals()
    end
end)
