local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SKINS = {
    Gun = {
        MeshId = "rbxassetid://3187399148",
        TextureId = "rbxassetid://3187399222"
    },
    Knife = {
        MeshId = "rbxassetid://3175017717",
        TextureId = "rbxassetid://3175017804"
    }
}

local function applySkinToModel(model, skinData)
    if not model then return end
    
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("SpecialMesh") then
            desc.MeshId = skinData.MeshId
            desc.TextureId = skinData.TextureId
        elseif desc:IsA("MeshPart") then
            desc.MeshId = skinData.MeshId
            desc.TextureID = skinData.TextureId
        end

        if desc:IsA("BasePart") then
            desc.LocalTransparencyModifier = 0
            desc.Transparency = 0
        end
    end
end

local function checkAndApply(child)
    -- 1. Перевірка зброї на кобурі/спині (DisplayRef)
    if child:IsA("ObjectValue") then
        if child.Name == "DisplayRefKnife" and child.Value then
            applySkinToModel(child.Value, SKINS.Knife)
        elseif child.Name == "DisplayRefGun" and child.Value then
            applySkinToModel(child.Value, SKINS.Gun)
        end
        
        child:GetPropertyChangedSignal("Value"):Connect(function()
            if child.Value then
                local data = (child.Name == "DisplayRefGun") and SKINS.Gun or SKINS.Knife
                applySkinToModel(child.Value, data)
            end
        end)
        
    -- 2. Перевірка зброї, коли ти взяв її в руки
    elseif child:IsA("Tool") then
        local name = child.Name:lower()
        if name:find("knife") or child:FindFirstChild("KnifeServer") then
            applySkinToModel(child, SKINS.Knife)
        elseif name:find("gun") or name:find("revolver") or child:FindFirstChild("GunServer") then
            applySkinToModel(child, SKINS.Gun)
        end
    end
end

local function setupCharacter(char)
    -- Обробка того, що вже є в персонажі
    for _, child in ipairs(char:GetChildren()) do
        checkAndApply(child)
    end
    
    -- Відстеження нових предметів (коли взяв зброю в руки)
    char.ChildAdded:Connect(checkAndApply)
end

if LocalPlayer.Character then 
    setupCharacter(LocalPlayer.Character) 
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
