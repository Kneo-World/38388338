print("[MM2 Visual] Запуск скрипта...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ:
local TARGET_NAME = "Default Knife"          -- Что меняем
local NEW_NAME = "Chroma Deathshard"         -- Новое имя
local NEW_TEXTURE_ID = "rbxassetid://241513681" -- ID текстуры

local function applyVisualsToInstance(inst)
    if not inst then return end
    
    -- Если это MeshPart / SpecialMesh / Decal
    if inst:IsA("MeshPart") or inst:IsA("SpecialMesh") then
        inst.TextureId = NEW_TEXTURE_ID
        print("[MM2 Visual] Изменена 3D-текстура в:", inst:GetFullName())
    elseif inst:IsA("Decal") then
        inst.Texture = NEW_TEXTURE_ID
        print("[MM2 Visual] Изменён Decal в:", inst:GetFullName())
    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
        -- Подмена иконки в инвентаре/магазине
        if inst.Name:lower():find("icon") or inst.Name:lower():find("item") then
            inst.Image = NEW_TEXTURE_ID
            print("[MM2 Visual] Изменена иконка UI:", inst:GetFullName())
        end
    end
end

local function scanAndReplace()
    print("[MM2 Visual] Сканирование персонажа и UI...")
    
    -- 1. Проверяем модель в руках персонажа
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetDescendants()) do
            if item:IsA("Tool") and (item.Name == TARGET_NAME or item.Name == "Knife" or item.Name == "Gun") then
                item.Name = NEW_NAME
                print("[MM2 Visual] Переименован Tool в руках:", NEW_NAME)
                for _, child in ipairs(item:GetDescendants()) do
                    applyVisualsToInstance(child)
                end
            end
        end
    end
    
    -- 2. Проверяем PlayerGui (инвентарь на экране)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, guiItem in ipairs(pGui:GetDescendants()) do
            if guiItem:IsA("TextLabel") and guiItem.Text == TARGET_NAME then
                guiItem.Text = NEW_NAME
                print("[MM2 Visual] Изменен текст в UI на:", NEW_NAME)
            end
        end
    end
end

-- Запускаем первичную подмену
local success, err = pcall(scanAndReplace)
if not success then
    warn("[MM2 Visual ERROR]:", err)
else
    print("[MM2 Visual] Первичное сканирование завершено успешно!")
end

-- Отслеживаем взятие оружия в руки
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        task.wait(0.1)
        pcall(scanAndReplace)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        task.wait(0.1)
        pcall(scanAndReplace)
    end)
end)
