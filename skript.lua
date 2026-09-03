local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Вкажи тут ID скинів, на які хочеш замінити (зараз стоять Luger та Deathshard)
local NEW_SKINS = {
    Gun = {
        MeshId = "rbxassetid://3187399148",
        TextureId = "rbxassetid://3187399222"
    },
    Knife = {
        MeshId = "rbxassetid://3175017717",
        TextureId = "rbxassetid://3175017804"
    }
}

local function applySkin(target, skinData)
    if not target then return end

    local function patch(obj)
        if obj:IsA("SpecialMesh") then
            -- Перевіряємо, щоб не перезаписувати сітку повторно, якщо ID вже той самий
            if obj.MeshId ~= skinData.MeshId then
                obj.MeshId = skinData.MeshId
                obj.TextureId = skinData.TextureId
            end
        elseif obj:IsA("MeshPart") then
            if obj.MeshId ~= skinData.MeshId then
                obj.MeshId = skinData.MeshId
                obj.TextureID = skinData.TextureId
            end
        end

        -- Форсуємо видимість, щоб CharacterClient не робив зброю невидимою
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.LocalTransparencyModifier = 0
            obj.Transparency = 0
        end
    end

    patch(target)
    for _, desc in ipairs(target:GetDescendants()) do
        patch(desc)
    end
end

local function handleChild(child)
    if child:IsA("ObjectValue") and child.Value then
        if child.Name == "DisplayRefKnife" then
            applySkin(child.Value, NEW_SKINS.Knife)
        elseif child.Name == "DisplayRefGun" then
            applySkin(child.Value, NEW_SKINS.Gun)
        end
    elseif child:IsA("Tool") then
        local name = child.Name:lower()
        if name:find("knife") or child:HasTag("Weapon_Knife") then
            applySkin(child, NEW_SKINS.Knife)
        elseif name:find("gun") or name:find("revolver") or child:HasTag("Weapon_Gun") then
            applySkin(child, NEW_SKINS.Gun)
        end
    end
end

local function setupCharacter(char)
    char.ChildAdded:Connect(handleChild)
    for _, child in ipairs(char:GetChildren()) do
        handleChild(child)
    end
end

local function setupBackpack(bp)
    bp.ChildAdded:Connect(handleChild)
    for _, child in ipairs(bp:GetChildren()) do
        handleChild(child)
    end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
if LocalPlayer:FindFirstChild("Backpack") then setupBackpack(LocalPlayer.Backpack) end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
LocalPlayer.ChildAdded:Connect(function(child)
    if child.Name == "Backpack" then setupBackpack(child) end
end)
