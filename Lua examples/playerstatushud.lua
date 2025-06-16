-- playerstatushud.lua
-- 在畫面左上角顯示玩家生命值的 HUD
-- Version: 1.0
--[[用途說明：

本範例會在玩家控制的角色出生並進入遊戲回合後，自動在螢幕左上角顯示一個小型 HUD。
HUD 會即時顯示「當前生命值 / 最大生命值」。
生命值以黃字呈現，並於每次 GUI 更新（AddToGUIUpdateList）時自動刷新。
實際效果：

單／多人遊戲皆可使用（僅在客戶端執行）。
玩家一加入，即可見左上方小框，隨受傷或治療即時變動文字內容。
無需額外操作，並且不會擋住遊戲畫面。
]]
local PlayerStatusHud = {}
local TEXT_COLOR     = Color(255, 200, 0, 255)  -- 生命值文字顏色（偏黃）

--[[
    初始化 HUD：建立一個不可聚焦的 GUI.Frame，裡面放一個 TextBlock，
    並在每次 GUI 更新時刷新玩家生命值數值。
]]
local function initHud()
    if SERVER then
        return
    end

    -- 主框架（佔螢幕寬度 20%、高度 5%，錨點在左上）
    local frame = GUI.Frame(
        GUI.RectTransform(Vector2(0.2, 0.05), nil, GUI.Anchor.TopLeft),
        nil
    )
    frame.CanBeFocused = false

    -- 顯示文字
    local statusText = GUI.TextBlock(
        GUI.RectTransform(Vector2(1, 1), frame.RectTransform),
        "",
        nil, nil,
        GUI.Alignment.Left
    )
    statusText.TextColor = TEXT_COLOR

    -- 在每次 AddToGUIUpdateList 後執行：更新文字內容並繪製框架
    Hook.Patch(
        "Barotrauma.GameScreen",
        "AddToGUIUpdateList",
        function()
            local character = Character.Controlled
            if character and character.CharacterHealth then
                local health    = character.CharacterHealth.Health
                local maxHealth = character.CharacterHealth.MaxHealth
                statusText.Text = string.format("HP: %.0f / %.0f", health, maxHealth)
            end
            frame.AddToGUIUpdateList()
        end,
        Hook.HookMethodType.After
    )
end

-- 遊戲回合開始時呼叫 HUD 初始化
Hook.Add(
    "roundStarted",
    "examples.playerStatusHud.init",
    initHud
)

return PlayerStatusHud