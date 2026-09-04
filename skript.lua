local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Зберігаємо вже оброблені об'єкти, щоб уникнути зациклення з логів
local processed = {}

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

local function applyFakeVisual(part, skinData)
    if not part or processed[part] then return end
    processed[part] = true

    -- Шукаємо SpecialMesh
    local mesh = part:FindFirstChildOfClass("SpecialMesh")
    if mesh then
        mesh.MeshId = skinData.MeshId
        mesh.TextureId = skinData.TextureId
    end

    -- Захист від CharacterClient (постійно тримаємо видимість)
    task.spawn(function()
        while part and part.Parent do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
                part.Transparency = 0
            end
            task.wait(0.2)
        end
    end)
end

local function handleChild(child)
    if child:IsA("ObjectValue") and child.Value then
        if child.Name == "DisplayRefKnife" then
            applyFakeVisual(child.Value, SKINS.Knife)
        elseif child.Name == "DisplayRefGun" then
            applyFakeVisual(child.Value, SKINS.Gun)
        end
    elseif child:IsA("Tool") then
        local name = child.Name:lower()
        local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("Part")
        if handle then
            if name:find("knife") or child:HasTag("Weapon_Knife") then
                applyFakeVisual(handle, SKINS.Knife)
            elseif name:find("gun") or name:find("revolver") or child:HasTag("Weapon_Gun") then
                applyFakeVisual(handle, SKINS.Gun)
            end
        end
    end
end

local function setupCharacter(char)
    table.clear(processed)
    
    char.ChildAdded:Connect(function(child)
        task.defer(function() handleChild(child) end)
    end)
    
    for _, child in ipairs(char:GetChildren()) do
        handleChild(child)
    end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)
