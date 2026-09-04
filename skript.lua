local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- База даних скінів MM2
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

-- Початковий вибір
local SELECTED_GUN = SkinsDB.Guns.Luger
local SELECTED_KNIFE = SkinsDB.Knives.Deathshard

-- Заміна меша і текстури
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

-- Сканування та оновлення конкретного об'єкта
local function processObject(obj)
    local name = obj.Name:lower()
    
    if obj:IsA("Tool") then
        if name:find("gun") or name:find("revolver") then
            applyMeshAndTexture(obj, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
        elseif name:find("knife") then
            applyMeshAndTexture(obj, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
        end
    elseif obj:IsA("Accessory") then
        if name:find("gun") then
            applyMeshAndTexture(obj, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
        elseif name:find("knife") then
            applyMeshAndTexture(obj, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
        end
    end
end

-- Оновлення скінів на всьому персонажі та в рюкзаку
local function updateAllSkins()
    local char = LocalPlayer.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            processObject(child)
        end
        
        local lowerTorso = char:FindFirstChild("LowerTorso")
        if lowerTorso then
            for _, child in ipairs(lowerTorso:GetChildren()) do
                if child.Name == "GunBelt" or child.Name:find("Gun") then
                    applyMeshAndTexture(child, SELECTED_GUN.Mesh, SELECTED_GUN.Texture)
                elseif child.Name == "KnifeBelt" or child.Name:find("Knife") then
                    applyMeshAndTexture(child, SELECTED_KNIFE.Mesh, SELECTED_KNIFE.Texture)
                end
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            processObject(tool)
        end
    end
end

-- Підключення слухачів до персонажа
local function patchCharacter(char)
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

    char.ChildAdded:Connect(function(child)
        processObject(child)
    end)

    updateAllSkins()
end

-- Глобальна функція для зміни скінів (викликай її з GUI або з коду)
_G.SetSkin = function(category, skinData)
    if category == "Gun" or category == "Guns" then
        SELECTED_GUN = skinData
    elseif category == "Knife" or category == "Knives" then
        SELECTED_KNIFE = skinData
    end
    updateAllSkins()
end

-- Ініціалізація
if LocalPlayer.Character then
    patchCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(patchCharacter)
