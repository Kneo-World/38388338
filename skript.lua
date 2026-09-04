local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

print("=== [SKIN CHANGER] Скрипт запущен! ===")

-- Безопасное подключение модулей
local ProfileData, InventoryModule
local successProfile, errProfile = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Modules", 3):WaitForChild("ProfileData", 3))
end)
local successInv, errInv = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Modules", 3):WaitForChild("InventoryModule", 3))
end)

if not successProfile then
    print("[ERROR] Не удалось загрузить ProfileData:", errProfile)
else
    print("[OK] ProfileData успешно загружен")
end

if not successInv then
    print("[ERROR] Не удалось загрузить InventoryModule:", errInv)
else
    print("[OK] InventoryModule успешно загружен")
end

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

-- 1. Выдача скинов в профиль
if ProfileData and ProfileData.Weapons and ProfileData.Weapons.Owned then
    local count = 0
    for skinID, _ in pairs(WeaponDatabase) do
        ProfileData.Weapons.Owned[skinID] = (ProfileData.Weapons.Owned[skinID] or 0) + 1
        count = count + 1
    end
    print("[INFO] Добавлено скинов в инвентарь:", count)
else
    print("[WARN] Не удалось найти структуру ProfileData.Weapons.Owned")
end

-- 2. Обновление GUI
if InventoryModule and InventoryModule.MyInventory then
    pcall(function()
        InventoryModule.MyInventory = InventoryModule.GenerateInventory(
            InventoryModule.GUI.MyInventory, 
            ProfileData, 
            "Main"
        )
        InventoryModule.SortInventory(InventoryModule.MyInventory)
        InventoryModule.ConnectEquipButtons()
        print("[OK] GUI Инвентаря перезагружен")
    end)
end

-- Функция подмены Меша с подробными принтами
local function applyMeshToPart(part, data, skinName)
    if not part then 
        print("[WARN] Передан пустой part для подмены!")
        return 
    end
    if not data then 
        print("[WARN] Нет данных скина для:", tostring(skinName))
        return 
    end

    print(" -> Пробуем применить скин [" .. tostring(skinName) .. "] к объекту:", part:GetFullName())

    -- Если партик сам является MeshPart
    if part:IsA("MeshPart") then
        part.MeshId = data.MeshId
        if data.TextureId then part.TextureID = data.TextureId end
        print("   [SUCCESS] Изменен MeshPart!")
        return
    end

    -- Поиск внутреннего Mesh объекта
    local innerMesh = part:FindFirstChild("Mesh") 
        or part:FindFirstChildOfClass("SpecialMesh") 
        or part:FindFirstChildWhichIsA("DataModelMesh")

    if innerMesh then
        innerMesh.MeshId = data.MeshId
        if data.TextureId then innerMesh.TextureId = data.TextureId end
        print("   [SUCCESS] Изменен найденный внутренний " .. innerMesh.ClassName .. " (" .. innerMesh.Name .. ")")
    else
        print("   [INFO] Внутренний меш не найден, создаем новый SpecialMesh...")
        local newMesh = Instance.new("SpecialMesh")
        newMesh.Name = "Mesh"
        newMesh.MeshId = data.MeshId
        if data.TextureId then newMesh.TextureId = data.TextureId end
        newMesh.Parent = part
        print("   [SUCCESS] Новый SpecialMesh создан и прикреплен!")
    end
end

-- Получение надетого скина из ProfileData
local function getEquippedSkin(category)
    if not ProfileData or not ProfileData.Weapons then 
        print("[WARN] ProfileData недоступен в getEquippedSkin")
        return nil 
    end

    local equipped = ProfileData.Weapons.Equipped
    if not equipped then return nil end

    if type(equipped) == "table" then
        local found = equipped[category] or (equipped.Weapons and equipped.Weapons[category])
        print(" -> Надетая категория [" .. category .. "]:", tostring(found))
        return found
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

-- Обновление всех визуалов
local function refreshAllVisuals()
    local char = LocalPlayer.Character
    if not char then 
        print("[WARN] Персонаж еще не создан!")
        return 
    end

    local knifeSkin = getEquippedSkin("Knife")
    local gunSkin = getEquippedSkin("Gun")

    local knifeData = WeaponDatabase[knifeSkin]
    local gunData = WeaponDatabase[gunSkin]

    -- Обновляем предметы в Backpack и в руках Character
    local containers = {LocalPlayer:FindFirstChild("Backpack"), char}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local isKnife = item.Name == "Knife" or item:FindFirstChild("Knife")
                    local isGun = item.Name == "Gun" or item:FindFirstChild("Gun")
                    local data = isKnife and knifeData or (isGun and gunData or nil)
                    local skinName = isKnife and knifeSkin or gunSkin

                    if data then
                        print("[TOOL FOUND] Найден Tool:", item.Name, "в", container.Name)
                        
                        -- Обновление иконки
                        item.TextureId = data.TextureId or data.MeshId
                        
                        -- Обновление меша ручки/лезвия
                        local handle = item:FindFirstChild("Handle")
                        if handle then
                            applyMeshToPart(handle, data, skinName)
                        else
                            print("   [WARN] У предмета", item.Name, "нет объекта Handle!")
                        end
                    end
                end
            end
        end
    end

    -- Обновляем скины на теле (WeaponDisplays)
    local weaponDisplaysFolder = Workspace:FindFirstChild("WeaponDisplays")
    if weaponDisplaysFolder then
        for _, display in ipairs(weaponDisplaysFolder:GetChildren()) do
            if isMyDisplay(display) then
                if display.Name:find("Knife") and knifeData then
                    print("[DISPLAY FOUND] Найден Knife Display на теле!")
                    local targetPart = display:IsA("BasePart") and display or display:FindFirstChild("Handle") or display:FindFirstChildWhichIsA("BasePart", true)
                    applyMeshToPart(targetPart, knifeData, knifeSkin)
                elseif display.Name:find("Gun") and gunData then
                    print("[DISPLAY FOUND] Найден Gun Display на теле!")
                    local targetPart = display:IsA("BasePart") and display or display:FindFirstChild("Handle") or display:FindFirstChildWhichIsA("BasePart", true)
                    applyMeshToPart(targetPart, gunData, gunSkin)
                end
            end
        end
    end
end

-- Старт отслеживания
print("[INFO] Запуск цикла проверки...")
task.spawn(function()
    while task.wait(1) do
        refreshAllVisuals()
    end
end)
