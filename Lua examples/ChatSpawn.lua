-- ChatSpawn.lua
-- ==== SERVER 端：聊天指令生成物品範例 ==== --

-- 請放在文件最末端（CLIENT 區塊之後）
if SERVER then
	-- 幫助函式：去除字串前後空白
	local function trim(s)
		return (s:gsub("^%s*(.-)%s*$", "%1"))
	end

	Hook.Add("characterChatMessage", "HandleSpawnCommand", function(message, speaker)
		-- 只攔截以 /spawn 開頭的聊天
		if not speaker or not message or type(message) ~= "string" then
			return
		end
		if message:sub(1, 6) ~= "/spawn" then
			return
		end

		-- 解析 /spawn <itemIdentifier>
		local itemID = trim(message:sub(7))
		if itemID == "" then
			Game.SendDirectChatMessage(
				ChatMessage.Create("", "用法：/spawn <itemIdentifier>", ChatMessageType.Server),
				speaker
			)
			return false
		end

		-- 計算生成座標：玩家面前 50 單位
		local dir = Microsoft.Xna.Framework.Vector2(speaker.WorldPosition.X, speaker.WorldPosition.Y)
		local facing = speaker.AnimController.FacingDir -- -1 左，+1 右
		local offset = Microsoft.Xna.Framework.Vector2(50 * facing, -10)
		local spawnPos = dir + offset

		-- 將物品排入生成佇列（下一幀 spawn）
		Entity.Spawner.AddItemToSpawnQueue(itemID, spawnPos, nil, speaker.TeamID)

		-- 回覆玩家
		Game.SendDirectChatMessage(
			ChatMessage.Create("", "已生成物品：" .. itemID, ChatMessageType.Server),
			speaker
		)

		-- 阻止此聊天訊息顯示在一般聊天視窗
		return false
	end)
end
--[[
說明：

1. Hook 事件
我們使用

    lua

    複製
    Hook.Add("characterChatMessage", "HandleSpawnCommand", function(message, speaker) ... end)

來攔截所有玩家的聊天文字。

2. 判斷指令
只處理以 /spawn  開頭的訊息，並把後面字串當作 itemIdentifier。

3. 計算生成位置
物品會出現在玩家面前 50 單位，抬高 10 單位，以免重疊地形。

4. 呼叫 Spawner

    lua

    複製
    Entity.Spawner.AddItemToSpawnQueue(itemID, spawnPos, nil, speaker.TeamID)

把物品排入下一幀的生成佇列。
第三個參數 nil 表示使用預設質量，第四個參數指定所屬陣營。

5. 回饋玩家
使用 Game.SendDirectChatMessage 把生成結果回報給該玩家。

6. 阻擋聊天顯示
回傳 false 可以阻止 /spawn 訊息繼續顯示在其他人的聊天視窗。

------

這樣玩家只要在遊戲聊天框輸入：


    複製
    /spawn dronescooter

就能在自己前方生成一台 dronescooter。同理可生成任何其他已註冊的 identifier。
]]
