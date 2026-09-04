local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- База даних скінів MM2 (MeshId та TextureId)
local SkinsDB = {
    Guns = {
        Luger = {Mesh = "rbxassetid://3187399148", Texture = "rbxassetid://3187399148"},
        LugerChroma = {Mesh = "rbxassetid://3187399258", Texture = "rbxassetid://3187399258"},
        RedLuger = {Mesh = "rbxassetid://332044583", Texture = "rbxassetid://332044583"},
        GreenLuger = {Mesh = "rbxassetid://332044679", Texture = "rbxassetid://332044679"},
        Shark = {Mesh = "rbxassetid://3187421705", Texture = "rbxassetid://3187421705"},
        Laser = {Mesh = "rbxassetid://3187422496", Texture = "rbxassetid://3187422496"},
        Sugar = {Mesh = "rbxassetid://3215356000", Texture = "rbxassetid://3215356000"},
        America = {Mesh = "rbxassetid://164676043", Texture = "rbxassetid://164676043"},
        Golden = {Mesh = "rbxassetid://147835357", Texture = "rbxassetid://147835357"},
        Phaser = {Mesh = "rbxassetid://144325423", Texture = "rbxassetid://144325423"}
    },
    Knives = {
        Deathshard = {Mesh = "rbxassetid://3175017717", Texture = "rbxassetid://3175017717"},
        DeathshardChroma = {Mesh = "rbxassetid://3187397317", Texture = "rbxassetid://3187397317"},
        Fang = {Mesh = "rbxassetid://3187397768", Texture = "rbxassetid://3187397768"},
        Saw = {Mesh = "rbxassetid://3187397991", Texture = "rbxassetid://3187397991"},
        Slasher = {Mesh = "rbxassetid://3187398274", Texture = "rbxassetid://3187398274"},
        Heat = {Mesh = "rbxassetid://3187444758", Texture = "rbxassetid://3187444758"},
        Seer = {Mesh = "rbxassetid://3184139765", Texture = "rbxassetid://3184139765"},
        Spider = {Mesh = "rbxassetid://315120760", Texture = "rbxassetid://315120760"},
        Handsaw = {Mesh = "rbxassetid://332042435", Texture = "rbxassetid://332042435"},
        Clockwork = {Mesh = "rbxassetid://360609441", Texture = "rbxassetid://360609441"},
        Xmas = {Mesh = "rbxassetid://332077449", Texture = "rbxassetid://332077449"},
        Candy = {Mesh = "rbxassetid://332021011", Texture = "rbxassetid://332021011"}
    }
}

-- ОБЕРИ ОБРАНІ СКІНИ ТУТ (вкажи назву з бази вище):
local SELECTED_GUN = SkinsDB.Guns.Luger
local SELECTED_KNIFE = SkinsDB.Knives.Deathshard

-- Функція для підміни сітки та текстури
local function applyMeshAndTexture(parentObj, meshId, textureId)
    if not parentObj or not meshId then return end
    
    for _, obj in ipairs(parentObj:GetDescendants()) do
        if obj:IsA("SpecialMesh") then
            obj.MeshId = meshId
            obj.TextureId = textureId
        elseif obj:IsA("MeshPart") then
            obj.MeshId = meshId
            obj.TextureID = textureId
        end
    end
end

-- Патчер персонажа
local function patchCharacter(char)
    -- 1. Відстежуємо пояси на LowerTorso
    local lowerTorso = char:WaitForChild("LowerTorso", 5)
    if lowerTorso then
        lowerTorso.ChildAdded:Connect(function(child)
            if child.Name == "GunBelt" or child.Name:find("Gun") then
                applyMeshAndTexture(child, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
            elseif child.Name == "KnifeBelt" or child.Name:find("Knife") then
                applyMeshAndTexture(child, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
            end
        end)
    end

    -- 2. Відстежуємо зброю в руках (Tool)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("gun") or name:find("revolver") then
                applyMeshAndTexture(child, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
            elseif name:find("knife") then
                applyMeshAndTexture(child, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
            end
        end
    end)
    
    -- 3. Аксесуари на спині/поясі
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local name = acc.Name:lower()
            if name:find("gun") then
                applyMeshAndTexture(acc, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
            elseif name:find("knife") then
                applyMeshAndTexture(acc, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
            end
        end
    end
end

if LocalPlayer.Character then
    patchCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(patchCharacter)
