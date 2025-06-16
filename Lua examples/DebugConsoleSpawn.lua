-- DebugConsoleSpawn.lua
--[[
下面示範如何用 Barotrauma Lua API 的 Hook.AddCommand 在 Debug Console（F3）中直接註冊一個 spawn 指令，支援：
- spawn <itemIdentifier> [quantity] [offsetX] [offsetY] [inv/world]
- 若指定 inv 則嘗試把生成的物品放到玩家身上

只要把下面程式碼貼到你任意會被載入的 .lua裡即可：
]]

if SERVER then
	-- pendingInv[speaker] = {id, count, offset, ticks}
	local pendingInv = {}

	-- 1) 用 Hook.AddCommand 在 Debug Console 中註冊 spawn 指令
	Hook.AddCommand(
		"spawn",
		"spawn <id> [qty] [offX] [offY] [inv/world] － 生成物品到世界或背包",
		function(cmdname, args, speaker)
			-- args: table of strings 拆自你在 console 打的那串文字
			-- speaker: 若經由玩家 F3 console 執行，speaker 就是該 Character

			-- 參數解析
			local id = args[1]
			local cnt = tonumber(args[2]) or 1
			local offX = tonumber(args[3])
			local offY = tonumber(args[4])
			local mode = args[5] -- "inv" or "world"

			if not id then
				ConsoleContext.SendMessage("用法：spawn <id> [qty] [offX] [offY] [inv/world]", Color.Red)
				return
			end

			-- 計算生成座標（玩家面前偏移 offX,offY 或 預設 50, -10）
			local px, py = speaker.WorldPosition.X, speaker.WorldPosition.Y
			local facing = speaker.AnimController.FacingDir
			local pos = Microsoft.Xna.Framework.Vector2(px, py)
			if offX and offY then
				pos = pos + Microsoft.Xna.Framework.Vector2(offX * facing, offY)
			else
				pos = pos + Microsoft.Xna.Framework.Vector2(50 * facing, -10)
			end

			if mode == "inv" then
				-- 將請求放到 pendingInv，Think 裡面處理自動拾取
				pendingInv[speaker] = {
					id = id,
					count = cnt,
					offset = pos,
					ticks = 0,
				}
				ConsoleContext.SendMessage(string.format("將生成並放入背包：%s x%d", id, cnt), Color.White)
			else
				-- 直接生成到場景
				for i = 1, cnt do
					Entity.Spawner.AddItemToSpawnQueue(id, pos, nil, speaker.TeamID)
				end
				ConsoleContext.SendMessage(string.format("已生成到世界：%s x%d", id, cnt), Color.White)
			end
		end
	)

	-- 2) Think 裡面處理 pendingInv：嘗試自動放入背包，最多等待約 2 秒
	Hook.Add("think", "ProcessPendingSpawnInventory", function()
		for speaker, info in pairs(pendingInv) do
			info.ticks = info.ticks + 1
			-- 找附近剛生成的同 ID 物品
			for _, item in pairs(Item.ItemList) do
				if
					info.count > 0
					and item.Identifier == info.id
					and Vector2.DistanceSquared(item.WorldPosition, info.offset) < 2000
				then
					if speaker.Inventory and speaker.Inventory.TryPutItem(item, false, true) then
						info.count = info.count - 1
					end
				end
			end
			-- 完成或超時就清掉
			if info.count <= 0 or info.ticks > 120 then
				pendingInv[speaker] = nil
			end
		end
	end)
end
--[[
使用方式：

1. 遊戲裡按 F3 開啟 Debug Console。

2. 在底部輸入，例如：
- spawn dronescooter
- spawn mobilebattery 5  20 -10 inv

參數含義：
- <id>：要生成的物品 Identifier
- [qty]：數量（預設 1）
- [offX] [offY]：相對玩家的 X/Y 偏移（預設 50, -10）
- [inv/world]：選 inv 生成後自動放背包，否則放在世界

3.按 Enter 後，命令自動執行：
- 若模式為 world，則直接將物品推入生成佇列；
- 若模式為 inv，則兩秒內嘗試將它們放入對應玩家的 Inventory。

這樣就能在 Barotrauma 的原生 F3 Debug Console 中，用 spawn 指令靈活生成任何物品！
]]
