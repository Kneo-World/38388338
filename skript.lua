-- Visual Skin Changer for MM2
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ (замени ID на нужные):
local TARGET_TOOL_NAME = "Default Knife" -- Название ножа/пушки, который у тебя ЕСТЬ в инвентаре
local NEW_NAME = "Chroma Deathshard"     -- Новое название (визуально)
local NEW_TEXTURE_ID = "rbxassetid://241513681" -- ID текстуры нужного скина

local function applyVisuals(tool)
    if tool:IsA("Tool") and tool.Name == TARGET_TOOL_NAME then
        -- Менявшем название
        tool.Name = NEW_NAME
        
        -- Меняем текстуру иконки в инвентаре
        tool.TextureId = NEW_TEXTURE_ID
        
        -- Меняем текстуру на самой 3D-модели ножа
        for _, child in ipairs(tool:GetDescendants()) do
            if child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                child.TextureId = NEW_TEXTURE_ID
            elseif child:IsA("Decal") then
                child.Texture = NEW_TEXTURE_ID
            end
        end
    end
end

-- Проверяем инвентарь (Backpack)
for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
    applyVisuals(item)
end

-- Проверяем, если предмет уже заспавнился в персонаже (в руках)
if LocalPlayer.Character then
    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
        applyVisuals(item)
    end
end

-- Отслеживаем появление новых предметов
LocalPlayer.Backpack.ChildAdded:Connect(applyVisuals)
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(applyVisuals)
end
