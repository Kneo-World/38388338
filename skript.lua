local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ProfileData = require(ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(ReplicatedStorage.Modules.InventoryModule)

-- База скинов: MeshId, TextureId (картинка 3D модели) и IconId (картинка для инвентаря/хотбара)
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

-- 1. Выдаем предметы в инвентарь MM2
for skinID, _ in pairs(WeaponDatabase) do
    ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
end

-- 2. Обновляем GUI меню MM2
if InventoryModule.MyInventory then
    InventoryModule.MyInventory = InventoryModule.GenerateInventory(
        InventoryModule.GUI.MyInventory, 
        ProfileData, 
        "Main"
    )
    InventoryModule.SortInventory(InventoryModule.MyInventory)
    InventoryModule.ConnectEquipButtons()
end

-- Функция подмены 3D-меша
local function applyMeshToPart(part, data)
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
end

-- Получение экипированного скина из ProfileData
local function getEquippedSkin(category)
    local equipped = ProfileData.Weapons and ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        if equipped[category] then return equipped[category] end
        if equipped.Weapons and equipped.Weapons[category] then return equipped.Weapons[category] end
    end
    return nil
end

-- Проверка владельца дисплея на теле
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

-- Обновление всех 3 видов (Инвентарь/Руки/Спина)
local function refreshAllVisuals()
    local char = LocalPlayer.Character
    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- А. Обновляем Tool в Инвентаре и в Руках
    local containers = {LocalPlayer:FindFirstChild("Backpack"), char}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local isKnife = item.Name == "Knife" or item:FindFirstChild("Knife")
                    local isGun = item.Name == "Gun" or item:FindFirstChild("Gun")
                    local data = isKnife and knifeData or (isGun and gunData or nil)

                    if data then
                        -- Меняем иконку в BackpackScript
                        item.TextureId = data.TextureId or data.MeshId
                        
                        -- Меняем 3D меш лезвия/ствола
                        local handle = item:FindFirstChild("Handle")
                        if handle then
                            applyMeshToPart(handle, data)
                        end
                    end
                end
            end
        end
    end

    -- Б. Обновляем модели на теле (Workspace.WeaponDisplays)
    local weaponDisplaysFolder = Workspace:FindFirstChild("WeaponDisplays")
    if weaponDisplaysFolder then
        for _, display in ipairs(weaponDisplaysFolder:GetChildren()) do
            if isMyDisplay(display) then
                if display.Name:find("Knife") and knifeData then
                    applyMeshToPart(display, knifeData)
                elseif display.Name:find("Gun") and gunData then
                    applyMeshToPart(display, gunData)
                end
            end
        end
    end
end

-- Инициализация слушателей
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function()
        task.wait(0.05)
        refreshAllVisuals()
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function()
        task.wait(0.05)
        refreshAllVisuals()
    end)
end)

local displaysFolder = Workspace:WaitForChild("WeaponDisplays", 5)
if displaysFolder then
    displaysFolder.ChildAdded:Connect(function()
        task.wait(0.1)
        refreshAllVisuals()
    end)
end

-- Фоновое обновление
task.spawn(function()
    while task.wait(0.3) do
        refreshAllVisuals()
    end
end)
