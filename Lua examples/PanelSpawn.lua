-- PanelSpawn.lua
-- ==== CLIENT 端：F9 打開生成面板 ==== --
--[[
下面示範如何用 F9 打開一個“生成物品面板”，可在面板中：
- 指定 itemIdentifier
- 數量（Quantity）
- X、Y 偏移（OffsetX、OffsetY）
- 切換「放入身上」（Put In Inventory）或「生成到世界」
然後按「生成」按鈕即可。
伺服端會在玩家前方（或指定偏移）生成物品，若勾選「放入身上」，會自動撿入玩家的 Inventory（最多嘗試 2 秒）。

只要把下面的程式碼附加到你原本的 RemoteScooterControl.lua（CLIENT 區塊之後、SERVER 區塊之前或之後皆可），即可實現此功能。
]]
if CLIENT then
	local spawnPanel = nil

	local function createSpawnPanel()
		if spawnPanel then
			spawnPanel:Dispose()
			spawnPanel = nil
			return
		end

		-- Panel 大小
		local w, h = 320, 240
		local screenW, screenH = Game.MainPlayerInput.ScreenSize.X, Game.MainPlayerInput.ScreenSize.Y

		spawnPanel = GUI.CreateFrame(Rectangle((screenW - w) / 2, (screenH - h) / 2, w, h), nil)
		spawnPanel.CanBeFocused = true
		spawnPanel.Draggable = true

		-- Title
		local title = GUI.CreateLabel(Rectangle(10, 10, w - 20, 20), "Spawn Item Panel (F9 切換)", GUI.LargeFont)
		spawnPanel.AddChild(spawnPanel, title)

		-- 欄位：Item ID
		spawnPanel.AddChild(spawnPanel, GUI.CreateLabel(Rectangle(10, 40, 80, 20), "Item ID:", GUI.SmallFont))
		local txtID = GUI.CreateTextBox(Rectangle(100, 40, 200, 20), "")
		spawnPanel.AddChild(spawnPanel, txtID)

		-- 欄位：Quantity
		spawnPanel.AddChild(spawnPanel, GUI.CreateLabel(Rectangle(10, 70, 80, 20), "Quantity:", GUI.SmallFont))
		local txtQty = GUI.CreateTextBox(Rectangle(100, 70, 80, 20), "1")
		spawnPanel.AddChild(spawnPanel, txtQty)

		-- 欄位：OffsetX
		spawnPanel.AddChild(spawnPanel, GUI.CreateLabel(Rectangle(10, 100, 80, 20), "Offset X:", GUI.SmallFont))
		local txtOffX = GUI.CreateTextBox(Rectangle(100, 100, 80, 20), "50")
		spawnPanel.AddChild(spawnPanel, txtOffX)

		-- 欄位：OffsetY
		spawnPanel.AddChild(spawnPanel, GUI.CreateLabel(Rectangle(10, 130, 80, 20), "Offset Y:", GUI.SmallFont))
		local txtOffY = GUI.CreateTextBox(Rectangle(100, 130, 80, 20), "-10")
		spawnPanel.AddChild(spawnPanel, txtOffY)

		-- Checkbox：Put In Inventory
		local chkInv = GUI.CreateCheckBox(Rectangle(10, 160, w - 20, 20), "放入身上 (Inventory)")
		spawnPanel.AddChild(spawnPanel, chkInv)

		-- 按鈕：Spawn
		local btn = GUI.CreateButton(Rectangle((w - 100) / 2, 190, 100, 30), "Generate")
		btn.OnClicked = function()
			local id = txtID.Text or ""
			local qty = tonumber(txtQty.Text) or 1
			local offX = tonumber(txtOffX.Text) or 50
			local offY = tonumber(txtOffY.Text) or -10
			local inv = chkInv.Selected

			id = id:match("^%s*(.-)%s*$")
			if id == "" then
				Game.ShowMessageBox("Error", "請輸入 Item Identifier", PlayerInputType.Cancel)
			else
				-- 組成指令：/spawn id qty offX offY inv
				local cmd = string.format("/spawn %s %d %d %d %s", id, qty, offX, offY, inv and "inv" or "world")
				-- 透過聊天發送到 Server
				Game.SendDirectChatMessage(ChatMessage.Create("", cmd, ChatMessageType.Default), nil)
				-- 關閉面板
				spawnPanel:Dispose()
				spawnPanel = nil
			end
		end
		spawnPanel.AddChild(spawnPanel, btn)
	end

	Hook.Add("think", "ToggleSpawnPanelWithF9", function()
		if Input.GetKeyDown(KeyboardKey.F9) then
			createSpawnPanel()
		end
	end)

	return
end

-- ==== SERVER 端：解析 /spawn 指令並生成物品 ==== --
if SERVER then
	-- 暫存「放入身上」佇列：{speaker -> {id, count, offset, invFlag, ticks}}
	local pendingInv = {}

	Hook.Add("characterChatMessage", "HandleSpawnCommand", function(message, speaker)
		if not message:find("^/spawn") then
			return
		end

		-- 以空白拆分參數
		local args = {}
		for token in message:gmatch("%S+") do
			table.insert(args, token)
		end
		-- args[1] = "/spawn"
		local id = args[2]
		local cnt = tonumber(args[3]) or 1
		local offX = tonumber(args[4])
		local offY = tonumber(args[5])
		local mode = args[6] -- "inv" or "world"
		if not id then
			Game.SendDirectChatMessage(
				ChatMessage.Create("", "用法：/spawn <id> [qty] [offX] [offY] [inv/world]", ChatMessageType.Server),
				speaker
			)
			return false
		end

		-- 計算 spawn 位置
		local pos = Microsoft.Xna.Framework.Vector2(speaker.WorldPosition.X, speaker.WorldPosition.Y)
		local facing = speaker.AnimController.FacingDir
		if offX and offY then
			pos = pos + Microsoft.Xna.Framework.Vector2(offX * facing, offY)
		else
			pos = pos + Microsoft.Xna.Framework.Vector2(50 * facing, -10)
		end

		if mode == "inv" then
			-- 加入待放身上佇列（2 秒內嘗試自動撿取）
			pendingInv[speaker] = {
				id = id,
				count = cnt,
				offset = pos,
				ticks = 0,
			}
			Game.SendDirectChatMessage(
				ChatMessage.Create("", "即將生成並放入身上：" .. id .. " x" .. cnt, ChatMessageType.Server),
				speaker
			)
		else
			-- 直接生成到世界
			for i = 1, cnt do
				Entity.Spawner.AddItemToSpawnQueue(id, pos, nil, speaker.TeamID)
			end
			Game.SendDirectChatMessage(
				ChatMessage.Create("", "已生成到世界：" .. id .. " x" .. cnt, ChatMessageType.Server),
				speaker
			)
		end

		return false
	end)

	-- 每幀嘗試把 pendingInv 裡的物品放到玩家 Inventory
	Hook.Add("think", "ProcessPendingInventory", function()
		for speaker, info in pairs(pendingInv) do
			info.ticks = info.ticks + 1
			-- 查找半徑內的同 ID 物品
			for _, item in pairs(Item.ItemList) do
				if
					info.count > 0
					and item.Identifier == info.id
					and Vector2.DistanceSquared(item.WorldPosition, info.offset) < 2000
				then
					-- 嘗試放入 Inventory
					if speaker.Inventory and speaker.Inventory.TryPutItem(item, false, true) then
						info.count = info.count - 1
					end
				end
			end
			-- 完成或超時（120 ticks 約2秒）就清理
			if info.count <= 0 or info.ticks > 120 then
				pendingInv[speaker] = nil
			end
		end
	end)
end
--[[
用法：

• 客戶端按 F9 開閉面板
• 面板中輸入
    • Item ID（必填）
    • Quantity（數量，預設 1）
    • Offset X/Y（偏移，可留空預設玩家前方）
    • 勾選「放入身上」→自動嘗試放進背包；否則直生成世界
• 按 「Generate」 即可
這樣就可以方便地透過 F9 控制台面板來生成物品！
]]
