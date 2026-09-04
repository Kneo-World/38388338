local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SKINS = {
    Gun = {
        MeshId = "rbxassetid://3187399148",
        TextureId = "rbxassetid://3187399222",
        Name = "Luger"
    },
    Knife = {
        MeshId = "rbxassetid://3175017717",
        TextureId = "rbxassetid://3175017804",
        Name = "Deathshard"
    }
}

-- 1. Обробка 3D-моделей на персонажі та в руках
local function applySkinToPart(part, skinData)
    if not part then return end
    
    for _, desc in ipairs(part:GetDescendants()) do
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

local function handleCharacterChild(child)
    task.wait(0.1) -- Даємо MM2 час створити об'єкт
    if child:IsA("ObjectValue") and child.Value then
        if child.Name == "DisplayRefKnife" then
            applySkinToPart(child.Value, SKINS.Knife)
        elseif child.Name == "DisplayRefGun" then
            applySkinToPart(child.Value, SKINS.Gun)
        end
    elseif child:IsA("Tool") then
        local name = child.Name:lower()
        if name:find("knife") or child:FindFirstChild("KnifeServer") then
            applySkinToPart(child, SKINS.Knife)
        elseif name:find("gun") or name:find("revolver") or child:FindFirstChild("GunServer") then
            applySkinToPart(child, SKINS.Gun)
        end
    end
end

-- 2. Обробка GUI інвентарю
local function patchGuiSlot(element)
    local vpf = element:FindFirstChildOfClass("ViewportFrame") or element:FindFirstChild("ItemViewport", true)
    if not vpf then return end

    local textLabel = element:FindFirstChildOfClass("TextLabel") or element:FindFirstChild("ItemName", true)
    local text = textLabel and textLabel.Text:lower() or element.Name:lower()

    if text:find("knife") or text:find("default knife") then
        applySkinToPart(vpf, SKINS.Knife)
        if textLabel and textLabel.Text:find("Default") then textLabel.Text = SKINS.Knife.Name end
    elseif text:find("gun") or text:find("default gun") then
        applySkinToPart(vpf, SKINS.Gun)
        if textLabel and textLabel.Text:find("Default") then textLabel.Text = SKINS.Gun.Name end
    end
end

local function updateInventoryGui()
    for _, desc in ipairs(PlayerGui:GetDescendants()) do
        if desc:IsA("ViewportFrame") then
            if desc.Parent then patchGuiSlot(desc.Parent) end
        end
    end
end

-- Налаштування персонажа
local function setupCharacter(char)
    char.ChildAdded:Connect(handleCharacterChild)
    for _, child in ipairs(char:GetChildren()) do
        handleCharacterChild(child)
    end
end

if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

-- Відстеження GUI
PlayerGui.DescendantAdded:Connect(function(desc)
    if desc:IsA("ViewportFrame") then
        task.wait(0.2)
        if desc.Parent then patchGuiSlot(desc.Parent) end
    end
end)

-- Первинна затримка для стабільного завантаження
task.delay(1, function()
    updateInventoryGui()
end)
