local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LUGER_ID = "rbxassetid://3187399148"
local DEATHSHARD_ID = "rbxassetid://3175017717"

print("[MM2-DEBUG] Скрипт логування запущено для:", LocalPlayer.Name)

local function patchModel(model, skinType)
    if not model then 
        print("[MM2-DEBUG] ❌ Спроба пропатчити nil модель!")
        return 
    end

    local meshId = (skinType == "Gun") and LUGER_ID or DEATHSHARD_ID
    print(string.format("[MM2-DEBUG] ⚙️ Патчимо об'єкт: %s (Тип: %s, Skin: %s)", model.Name, model.ClassName, skinType))

    local count = 0
    for _, desc in ipairs(model:GetDescendants()) do
        count = count + 1
        print(string.format("[MM2-DEBUG]   ├── Елемент #%d: %s [%s]", count, desc.Name, desc.ClassName))

        if desc:IsA("SpecialMesh") then
            print(string.format("[MM2-DEBUG]   │   ├── Змінюємо SpecialMesh. Старий MeshId: %s", tostring(desc.MeshId)))
            desc.MeshId = meshId
            desc.TextureId = meshId
            print("[MM2-DEBUG]   │   └── ✅ SpecialMesh успішно оновлено!")
            
        elseif desc:IsA("MeshPart") then
            print(string.format("[MM2-DEBUG]   │   ├── Знайдено MeshPart. Старий MeshID: %s", tostring(desc.MeshID)))
            desc.MeshId = meshId
            desc.TextureID = meshId
            print("[MM2-DEBUG]   │   └── ✅ MeshPart успішно оновлено!")
            
        elseif desc:IsA("SurfaceAppearance") then
            print("[MM2-DEBUG]   │   ├── Знайдено SurfaceAppearance, видаляємо для скидання текстури...")
            desc:Destroy()
            print("[MM2-DEBUG]   │   └── 🗑️ SurfaceAppearance видалено.")
        end

        if desc:IsA("BasePart") or desc:IsA("Decal") then
            local oldMod = desc.LocalTransparencyModifier
            desc.LocalTransparencyModifier = 0
            desc.Transparency = 0
            print(string.format("[MM2-DEBUG]   │   └── 👁️ Прозорість скинута на 0 (Була LocalTransparencyModifier: %s)", tostring(oldMod)))
        end
    end
    print(string.format("[MM2-DEBUG] 🏁 Обробку %s завершено. Всього елементів: %d", model.Name, count))
end

local function setupCharacter(char)
    print("[MM2-DEBUG] 👤 Підключено нового персонажа:", char.Name)

    -- Відстеження DisplayRefObjects (спина/пояс)
    char.ChildAdded:Connect(function(child)
        print("[MM2-DEBUG] ➕ Додано новий Child у персонажа:", child.Name, "| Class:", child.ClassName)

        if child:IsA("ObjectValue") then
            print(string.format("[MM2-DEBUG] 🔗 Знайдено ObjectValue: %s | Посилання Value: %s", child.Name, tostring(child.Value)))
            
            if child.Name == "DisplayRefKnife" and child.Value then
                patchModel(child.Value, "Knife")
            elseif child.Name == "DisplayRefGun" and child.Value then
                patchModel(child.Value, "Gun")
            end

            child:GetPropertyChangedSignal("Value"):Connect(function()
                print(string.format("[MM2-DEBUG] 🔄 Змінилося Value у %s -> %s", child.Name, tostring(child.Value)))
                if child.Value then
                    local skinType = (child.Name == "DisplayRefGun") and "Gun" or "Knife"
                    patchModel(child.Value, skinType)
                end
            end)

        elseif child:IsA("Tool") then
            print("[MM2-DEBUG] 🗡️ Знайдено Tool у руках:", child.Name)
            local skinType = (child.Name:lower():find("gun") or child.Name:lower():find("revolver")) and "Gun" or "Knife"
            patchModel(child, skinType)
        end
    end)

    -- Перевірка вже існуючих частин
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("ObjectValue") and child.Value then
            print("[MM2-DEBUG] 🔍 Знайдено існуючий ObjectValue:", child.Name, "Value:", child.Value.Name)
            local skinType = (child.Name == "DisplayRefGun") and "Gun" or "Knife"
            patchModel(child.Value, skinType)
        elseif child:IsA("Tool") then
            print("[MM2-DEBUG] 🔍 Знайдено існуючий Tool:", child.Name)
            local skinType = (child.Name:lower():find("gun") or child.Name:lower():find("revolver")) and "Gun" or "Knife"
            patchModel(child, skinType)
        end
    end
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
