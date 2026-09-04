print("[DEBUG 1] Скрипт запущен!")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    print("[DEBUG ERROR] LocalPlayer не найден!")
    return
end

print("[DEBUG 2] Игрок найден:", LocalPlayer.Name)

-- Функция для отслеживания инвентаря/GUI
local function debugGUI()
    print("[DEBUG 3] Ищем PlayerGui...")
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    if not playerGui then
        print("[DEBUG WARNING] PlayerGui еще не загрузился, ждем...")
        playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    end

    if playerGui then
        print("[DEBUG 4] PlayerGui успешно найден!")
        
        -- Проверка наличия элементов MM2 (например, MainGUI / Shop / Inventory)
        for _, child in ipairs(playerGui:GetChildren()) do
            print("[DEBUG GUI Element]:", child.Name)
        end
    else
        print("[DEBUG ERROR] PlayerGui так и не появился!")
    end
end

-- Запуск проверки
task.spawn(function()
    print("[DEBUG 5] Старт потока проверки...")
    debugGUI()
end)

print("[DEBUG 6] Скрипт полностью инициализирован.")
