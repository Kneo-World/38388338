local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Точні Asset ID для Luger та Deathshard
local SKINS = {
    Gun = {
        MeshId = "rbxassetid://3187399148",
        TextureId = "rbxassetid://3187399222" -- Окрема текстура Luger
    },
    Knife = {
        MeshId = "rbxassetid://3175017717",
        TextureId = "rbxassetid://3175017804" -- Окрема текстура Deathshard
    }
}

local function applyMeshAndTexture(part, skinData)
    if not part then return end

    local function patch(obj)
        if obj:IsA("SpecialMesh") then
            obj.MeshId = skinData.MeshId
            obj.TextureId = skinData.TextureId
        elseif obj:IsA("MeshPart") then
            obj.MeshId = skinData.MeshId
            obj.TextureID = skinData.TextureId
        end

        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.LocalTransparencyModifier = 0
            obj.Transparency = 0
        end
    end

    patch(part)
    for _, desc in ipairs(part:GetDescendants()) do
        patch(desc)
    end
end

local function handleTarget(child)
    if child:IsA("ObjectValue") and child.Value then
        if child.Name == "DisplayRefKnife" then
            applyMeshAndTexture(child.Value, SKINS.Knife)
        elseif child.Name == "DisplayRefGun" then
            applyMeshAndTexture(child.Value, SKINS.Gun)
        end
    elseif child:IsA("Tool") then
        local name = child.Name:lower()
        if name:find("knife") or child:HasTag("Weapon_Knife") then
            applyMeshAndTexture(child, SKINS.Knife)
        elseif name:find("gun") or name:find("revolver") or child:HasTag("Weapon_Gun") then
            applyMeshAndTexture(child, SKINS.Gun)
        end
    end
end

local function setupCharacter(char)
    -- Стежимо за DisplayRef та інструментами в персонажі
    char.ChildAdded:Connect(handleTarget)
    for _, child in ipairs(char:GetChildren()) do
        handleTarget(child)
    end
end

-- Стежимо за інвентарем (Backpack)
local function setupBackpack(bp)
    bp.ChildAdded:Connect(handleTarget)
    for _, child in ipairs(bp:GetChildren()) do
        handleTarget(child)
    end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
if LocalPlayer:FindFirstChild("Backpack") then setupBackpack(LocalPlayer.Backpack) end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
LocalPlayer.ChildAdded:Connect(function(child)
    if child.Name == "Backpack" then
        setupBackpack(child)
    end
end)
