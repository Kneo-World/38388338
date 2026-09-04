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

local function patchViewportFrame(vpf, skinData)
    if not vpf then return end
    
    -- Шукаємо 3D модель усередині ViewportFrame
    for _, desc in ipairs(vpf:GetDescendants()) do
        if desc:IsA("SpecialMesh") then
            desc.MeshId = skinData.MeshId
            desc.TextureId = skinData.TextureId
        elseif desc:IsA("MeshPart") then
            desc.MeshId = skinData.MeshId
            desc.TextureID = skinData.TextureId
        end
    end
end

local function patchInventorySlot(frame)
    local nameContainer = frame:FindFirstChild("ItemName") or frame:FindFirstChild("Title") or frame:FindFirstChildOfClass("TextLabel")
    local vpf = frame:FindFirstChildOfClass("ViewportFrame") or frame:FindFirstChild("ItemViewport", true)
    
    local isKnife = frame.Name:lower():find("knife") or (nameContainer and nameContainer.Text:lower():find("knife"))
    local isGun = frame.Name:lower():find("gun") or (nameContainer and nameContainer.Text:lower():find("gun"))

    if isKnife and vpf then
        patchViewportFrame(vpf, SKINS.Knife)
        if nameContainer then nameContainer.Text = SKINS.Knife.Name end
    elseif isGun and vpf then
        patchViewportFrame(vpf, SKINS.Gun)
        if nameContainer then nameContainer.Text = SKINS.Gun.Name end
    end
end

local function scanGui()
    local mainGui = PlayerGui:FindFirstChild("MainGUI") or PlayerGui:FindFirstChild("GameGUI") or PlayerGui:FindFirstChildOfClass("ScreenGui")
    if not mainGui then return end

    -- Пошук усіх слотів зброї в GUI (як у списку, так і на панелі справа)
    for _, desc in ipairs(mainGui:GetDescendants()) do
        if desc:IsA("Frame") or desc:IsA("ImageButton") then
            if desc:FindFirstChildOfClass("ViewportFrame") then
                patchInventorySlot(desc)
            end
        end
    end
end

-- Автоматично оновлюємо при відкритті GUI або зміні предметів
PlayerGui.DescendantAdded:Connect(function(desc)
    if desc:IsA("ViewportFrame") then
        task.wait(0.1)
        if desc.Parent then patchInventorySlot(desc.Parent) end
    end
end)

-- Запускаємо сканування
scanGui()
