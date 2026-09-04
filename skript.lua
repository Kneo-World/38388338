local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- База даних ID моделей та текстур для скінів з твоєї бази
local SKINS_DATABASE = {
    -- Зброя (Guns)
    Luger = {Mesh = "rbxassetid://3187399148", Texture = "rbxassetid://3187399148", Type = "Gun"},
    LugerChroma = {Mesh = "rbxassetid://3187399258", Texture = "rbxassetid://3187399258", Type = "Gun"},
    RedLuger = {Mesh = "rbxassetid://332044583", Texture = "rbxassetid://332044583", Type = "Gun"},
    GreenLuger = {Mesh = "rbxassetid://332044679", Texture = "rbxassetid://332044679", Type = "Gun"},
    Shark = {Mesh = "rbxassetid://3187421705", Texture = "rbxassetid://3187421705", Type = "Gun"},
    Laser = {Mesh = "rbxassetid://3187422496", Texture = "rbxassetid://3187422496", Type = "Gun"},
    Sugar = {Mesh = "rbxassetid://3215356000", Texture = "rbxassetid://3215356000", Type = "Gun"},
    AmericaGun = {Mesh = "rbxassetid://164676043", Texture = "rbxassetid://164676043", Type = "Gun"},
    GoldenGun = {Mesh = "rbxassetid://147835357", Texture = "rbxassetid://147835357", Type = "Gun"},
    Phaser = {Mesh = "rbxassetid://144325423", Texture = "rbxassetid://144325423", Type = "Gun"},
    
    -- Ножі (Knives)
    Deathshard = {Mesh = "rbxassetid://3175017717", Texture = "rbxassetid://3175017717", Type = "Knife"},
    DeathshardChroma = {Mesh = "rbxassetid://3187397317", Texture = "rbxassetid://3187397317", Type = "Knife"},
    Fang = {Mesh = "rbxassetid://3187397768", Texture = "rbxassetid://3187397768", Type = "Knife"},
    Saw = {Mesh = "rbxassetid://3187397991", Texture = "rbxassetid://3187397991", Type = "Knife"},
    Slasher = {Mesh = "rbxassetid://3187398274", Texture = "rbxassetid://3187398274", Type = "Knife"},
    Heat = {Mesh = "rbxassetid://3187444758", Texture = "rbxassetid://3187444758", Type = "Knife"},
    TheSeer = {Mesh = "rbxassetid://3184139765", Texture = "rbxassetid://3184139765", Type = "Knife"},
    Spider = {Mesh = "rbxassetid://315120760", Texture = "rbxassetid://315120760", Type = "Knife"},
    Handsaw = {Mesh = "rbxassetid://332042435", Texture = "rbxassetid://332042435", Type = "Knife"},
    Clockwork = {Mesh = "rbxassetid://360609441", Texture = "rbxassetid://360609441", Type = "Knife"},
    Xmas = {Mesh = "rbxassetid://332077449", Texture = "rbxassetid://332077449", Type = "Knife"},
    Candy = {Mesh = "rbxassetid://332021011", Texture = "rbxassetid://332021011", Type = "Knife"}
}

-- Поточні активні скіни (можеш міняти назву на будь-яку з SKINS_DATABASE)
local currentGunSkin = SKINS_DATABASE.Luger
local currentKnifeSkin = SKINS_DATABASE.Deathshard

-- Зміна Mesh та Texture
local function applyMeshAndTexture(parentObj, meshId, textureId)
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

-- Основна функція патчу
local function patchCharacter(char)
    -- 1. Відстежуємо кобуру / пояс
    local lowerTorso = char:WaitForChild("LowerTorso", 5)
    if lowerTorso then
        lowerTorso.ChildAdded:Connect(function(child)
            if child.Name == "GunBelt" or child.Name:find("Gun") then
                applyMeshAndTexture(child, currentGunSkin.Mesh, currentGunSkin.Texture)
            elseif child.Name == "KnifeBelt" or child.Name:find("Knife") then
                applyMeshAndTexture(child, currentKnifeSkin.Mesh, currentKnifeSkin.Texture)
            end
        end)
    end

    -- 2. Відстежуємо зброю в руках
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            if child.Name == "Gun" or child.Name:find("Gun") or child.Name == "Revolver" then
                applyMeshAndTexture(child, currentGunSkin.Mesh, currentGunSkin.Texture)
            elseif child.Name == "Knife" or child.Name:find("Knife") then
                applyMeshAndTexture(child, currentKnifeSkin.Mesh, currentKnifeSkin.Texture)
            end
        end
    end)

    -- 3. Аксесуари на персонажі
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            if acc.Name:find("Gun") then
                applyMeshAndTexture(acc, currentGunSkin.Mesh, currentGunSkin.Texture)
            elseif acc.Name:find("Knife") then
                applyMeshAndTexture(acc, currentKnifeSkin.Mesh, currentKnifeSkin.Texture)
            end
        end
    end
end

if LocalPlayer.Character then
    patchCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(patchCharacter)
