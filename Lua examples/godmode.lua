-- godmode.lua
-- 功能：聊天指令 !god 切換「上帝模式」（無敵狀態），在遊戲中可防止角色受到任何傷害
-- 放在 Lua/Autorun/ 下即自動載入
--[[
用途說明：

玩家在聊天欄輸入 !god，即可切換自己角色的「上帝模式」。
開啟後，角色不會再受到任何傷害（包括爆炸、火焰、電擊、敵對攻擊等）。
再次輸入 !god，可關閉上帝模式，恢復正常受傷機制。
實際效果：

單人遊戲：在本機聊天框中直接輸入並見到「GodMode 已開啟 上帝模式！」
多人遊戲：只有伺服器端接收到 !god 指令時才會執行切換，上帝模式狀態同步於伺服器角色上；伺服器會回傳私訊告知該玩家已開啟或關閉。
開啟後，不論被任何來源攻擊（磕碰、爆炸、武器等），角色血量不會下降。
關閉後，角色會再次正常承受傷害。
]]
local godEnabled = {}  -- 記錄每個角色的上帝模式狀態

-- 1. 攔截角色受傷事件：若上帝模式開啟，則吞掉所有傷害
Hook.Add("character.applyDamage", "examples.godmode.preventDamage", function (characterHealth, attackResult, hitLimb)
    local character = characterHealth.Character
    if godEnabled[character] then
        -- 返回 true 表示已處理傷害，Barotrauma 不會繼續套用原本的傷害
        return true
    end
    -- 若未開啟上帝模式，傷害正常進行
end)

-- 2. 聊天指令 !god：切換當前玩家控制角色的上帝模式
Hook.Add("chatMessage", "examples.godmode.toggle", function (message, client)
    if message ~= "!god" then return end

    -- 單人模式：Character.Controlled；多人模式：client.Character
    local character
    if SERVER then
        if not client or not client.Character then return end
        character = client.Character
    else
        character = Character.Controlled
        if not character then return end
    end

    -- 切換狀態
    godEnabled[character] = not godEnabled[character]
    local statusText = godEnabled[character] and "已開啟" or "已關閉"

    -- 建立回覆訊息
    local prefix = "GodMode"
    local reply = ChatMessage.Create(
        prefix,
        statusText .. " 上帝模式！",
        ChatMessageType.Default, nil, nil
    )
    reply.Color = Color(255, 215, 0, 255)

    if SERVER then
        Game.SendDirectChatMessage(reply, client)
    else
        Game.ChatBox.AddMessage(reply)
    end

    return true  -- 隱藏玩家輸入的原始指令
end)