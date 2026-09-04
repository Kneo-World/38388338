local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

print("=== [FULL HARDCODE SKIN CHANGER] Запущен! ===")

-- Выбери скины, которые хочешь видеть вместо дефолтных
local DEFAULT_KNIFE_SKIN = {
    MeshId = "rbxassetid://6022874136",  -- Icebreaker
    TextureId = "rbxassetid://6022874251"
}

local DEFAULT_GUN_SKIN = {
    MeshId = "rbxassetid://7800847534",    -- Harvester
    TextureId = "rbxassetid://7800847683"
}

-- Жесткая замена меша
local function forceApplyMesh(part, skinData)
    if not part or not skinData then return end

    -- Если объект сразу MeshPart
    if part:IsA("MeshPart") then
        part.MeshId = skinData.MeshId
        if skinData.TextureId then part.TextureID = skinData.TextureId end
        return
    end

    -- Ищем внутренний Mesh
    local innerMesh = part:FindFirstChild("Mesh") 
        or part:FindFirstChildOfClass("SpecialMesh") 
        or part:FindFirstChildWhichIsA("DataModelMesh")

    if innerMesh then
        innerMesh.MeshId = skinData.MeshId
        if skinData.TextureId then innerMesh.TextureId = skinData.TextureId end
    else
        local newMesh = Instance.new("SpecialMesh")
        newMesh.Name = "Mesh"
        newMesh.MeshId = skinData.MeshId
        if skinData.TextureId then newMesh.TextureId = skinData.TextureId end
        newMesh.Parent = part
    end
end

-- Проверка: принадлежит ли дисплей на спине нашему персонажу
local function isMyDisplay(displayObj)
    local char = LocalPlayer.Character
    if not char then return false end

    for _, descendant in ipairs(displayObj:GetDescendants()) do
        if descendant:IsA("RigidConstraint") or descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
            local p0 = descendant:IsA("RigidConstraint") and descendant.Attachment0 or descendant.Part0
            local p1 = descendant:IsA("RigidConstraint") and descendant.Attachment1 or descendant.Part1
            
            if (p0 and p0:IsDescendantOf(char)) or (p1 and p1:IsDescendantOf(char)) then
                return true
            end
        end
    end
    return false
end

-- Основная функция зачистки и замены
local function updateVisuals()
    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Инвентарь (Backpack) и Персонаж (Character)
    local containers = {LocalPlayer:FindFirstChild("Backpack"), char}
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local nameLower = item.Name:lower()
                    local isKnife = nameLower:find("knife") or item:FindFirstChild("Knife")
                    local isGun = nameLower:find("gun") or item:FindFirstChild("Gun")

                    if isKnife then
                        item.TextureId = DEFAULT_KNIFE_SKIN.TextureId
                        local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                        if handle then forceApplyMesh(handle, DEFAULT_KNIFE_SKIN) end
                    elseif isGun then
                        item.TextureId = DEFAULT_GUN_SKIN.TextureId
                        local handle = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                        if handle then forceApplyMesh(handle, DEFAULT_GUN_SKIN) end
                    end
                end
            end
        end
    end

    -- 2. Дисплеи на спине/поясе (WeaponDisplays)
    local weaponDisplaysFolder = Workspace:FindFirstChild("WeaponDisplays")
    if weaponDisplaysFolder then
        for _, display in ipairs(weaponDisplaysFolder:GetChildren()) do
            if isMyDisplay(display) then
                local displayLower = display.Name:lower()
                local targetPart = display:IsA("BasePart") and display or display:FindFirstChild("Handle") or display:FindFirstChildWhichIsA("BasePart", true)

                if displayLower:find("knife") then
                    forceApplyMesh(targetPart, DEFAULT_KNIFE_SKIN)
                elseif displayLower:find("gun") then
                    forceApplyMesh(targetPart, DEFAULT_GUN_SKIN)
                end
            end
        end
    end
end

-- Постоянное обновление каждые 0.2 сек
task.spawn(function()
    while task.wait(0.2) do
        pcall(updateVisuals)
    end
end)
