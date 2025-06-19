-- CharacterInfoPanel.lua
-- 全功能角色資訊查詢工具

if CLIENT then
	-- 狀態
	local showPanel = false
	local prevI = false
	local sections = {
		basic = true,
		inventory = true,
		aimed = true,
		devinfo = false,
		chat = false,
	}
	local chatInput = ""

	-- 滑鼠指向的角色緩存
	local aimedChar = nil

	-- 切換面板
	Hook.Add("think", "CIP_Toggle", function()
		local down = Game.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.I)
		if down and not prevI then
			showPanel = not showPanel
		end
		prevI = down

		-- 同步瞄準角色
		local mp = PlayerInput.MousePosition
		local worldPos = Game.ScreenToWorld(mp)
		aimedChar = nil
		local bestDist = math.huge
		for _, char in ipairs(Character.CharacterList) do
			local pos = char.WorldPosition
			local d = Vector2.DistanceSquared(pos, worldPos)
			if d < bestDist and d < 100 * 100 then -- 半徑100px範圍檢測
				bestDist = d
				aimedChar = char
			end
		end
	end)

	-- 繪製進度條
	local function drawBar(x, y, w, h, fraction, fg, bg)
		GUI.Box(Rectangle(x, y, w, h), bg)
		GUI.DrawRectangle(Rectangle(x, y, math.floor(w * fraction), h), fg)
	end

	-- 主繪製
	Hook.Add("draw", "CIP_Draw", function()
		if not showPanel then
			return
		end
		local client = Client.Peer
		if not client or not client.Character then
			return
		end
		local char = client.Character

		-- Panel 基礎參數
		local x, y, w = 20, 40, 350
		local line = 0
		local function nextY()
			line = line + 1
			return y + line * 22
		end

		-- 背景
		GUI.Box(Rectangle(x - 5, y - 5, w + 10, 500), Color(0, 0, 0, 180))

		-- 標題列＋展開按鈕
		if GUI.Button(Rectangle(x, y, w, 24), showPanel and "角色資訊 ▼" or "角色資訊 ▲") then
			sections.basic = not sections.basic
		end

		-- BASIC 區塊
		if sections.basic then
			local by = nextY()
			GUI.Label(Rectangle(x, by, w, 20), "Name: " .. tostring(char.Name))
			by = nextY()
			GUI.Label(Rectangle(x, by, w, 20), "Species: " .. tostring(char.SpeciesName))
			-- 血量條
			if char.CharacterHealth then
				local hp = char.CharacterHealth.Health
				local mh = char.CharacterHealth.MaxHealth
				by = nextY()
				GUI.Label(Rectangle(x, by, w, 20), string.format("Health: %.1f/%.1f", hp, mh))
				drawBar(
					x,
					by + 18,
					w,
					8,
					math.max(0, math.min(1, hp / mh)),
					Color(200, 20, 20, 200),
					Color(50, 50, 50, 200)
				)
				-- 編輯欄
				by = nextY()
				GUI.Label(Rectangle(x, by, 100, 20), "Set HP:")
				local hpStr = GUI.TextBox(Rectangle(x + 60, by, 60, 20), tostring(hp))
				if hpStr ~= "" then
					char.CharacterHealth.Health = tonumber(hpStr) or hp
				end
			end
			-- 座標
			local pos = char.WorldPosition
			by = nextY()
			GUI.Label(Rectangle(x, by, w, 20), string.format("Pos: %.1f , %.1f", pos.X, pos.Y))
			-- 可移動座標
			by = nextY()
			GUI.Label(Rectangle(x, by, 50, 20), "Set X:")
			local xs = GUI.TextBox(Rectangle(x + 50, by, 60, 20), string.format("%.1f", pos.X))
			GUI.Label(Rectangle(x + 120, by, 50, 20), "Set Y:")
			local ys = GUI.TextBox(Rectangle(x + 170, by, 60, 20), string.format("%.1f", pos.Y))
			if GUI.Button(Rectangle(x + 240, by, 80, 20), "Teleport") then
				char.WorldPosition = Vector2(tonumber(xs) or pos.X, tonumber(ys) or pos.Y)
			end
			-- 分隔
			by = nextY()
			GUI.DrawLine(Vector2(x, by), Vector2(x + w, by), Color.Gray)
		end

		-- INVENTORY 區塊
		if GUI.Button(Rectangle(x, nextY(), w, 24), "Inventory " .. (sections.inventory and "▼" or "▲")) then
			sections.inventory = not sections.inventory
		end
		if sections.inventory then
			for i, slot in ipairs(char.Inventory.AllItems) do
				local id = slot.ItemPrefab and slot.ItemPrefab.Identifier or "<空>"
				local by = nextY()
				GUI.Label(
					Rectangle(x + 10, by, w - 20, 20),
					string.format("[%d] %s (%.1f)", i, id, slot.Condition or 0)
				)
			end
			GUI.DrawLine(Vector2(x, nextY()), Vector2(x + w, nextY()), Color.Gray)
		end

		-- AIMED 區塊
		if GUI.Button(Rectangle(x, nextY(), w, 24), "Aimed ▼") then
			sections.aimed = not sections.aimed
		end
		if sections.aimed then
			local target = aimedChar
			local by = nextY()
			if target then
				GUI.Label(Rectangle(x + 10, by, w - 20, 20), "Target: " .. tostring(target.Name or "<生物>"))
				-- 同樣顯示其血量
				if target.CharacterHealth then
					local hp, mh = target.CharacterHealth.Health, target.CharacterHealth.MaxHealth
					by = nextY()
					drawBar(x + 10, by, w - 20, 8, hp / mh, Color(200, 20, 20, 200), Color(50, 50, 50, 200))
				end
			else
				GUI.Label(Rectangle(x + 10, by, w - 20, 20), "<無目標>")
			end
			GUI.DrawLine(Vector2(x, nextY()), Vector2(x + w, nextY()), Color.Gray)
		end

		-- CHAT 區塊
		if GUI.Button(Rectangle(x, nextY(), w, 24), "Chat ▼") then
			sections.chat = not sections.chat
		end
		if sections.chat then
			local by = nextY()
			GUI.Label(Rectangle(x, by, 40, 20), "Msg:")
			chatInput = GUI.TextBox(Rectangle(x + 45, by, w - 100, 20), chatInput)
			if GUI.Button(Rectangle(x + w - 50, by, 50, 20), "Send") then
				Game.SendDirectChatMessage(chatInput, ChatMessageType.Default)
				chatInput = ""
			end
			GUI.DrawLine(Vector2(x, nextY()), Vector2(x + w, nextY()), Color.Gray)
		end

		-- DEVINFO 區塊
		if GUI.Button(Rectangle(x, nextY(), w, 24), "Dev Info ▼") then
			sections.devinfo = not sections.devinfo
		end
		if sections.devinfo then
			local by = nextY()
			GUI.Label(Rectangle(x + 10, by, w - 20, 20), "EntityID: " .. tostring(char.ID))
			by = nextY()
			GUI.Label(Rectangle(x + 10, by, w - 20, 20), "Prefab: " .. tostring(char.Prefab.Identifier))
			-- Component 列表
			for _, comp in ipairs(char.Components) do
				by = nextY()
				GUI.Label(Rectangle(x + 10, by, w - 20, 18), "- " .. comp.GetType().Name)
			end
		end
	end)
end
--[[
-- CharacterInfoPanel.lua
-- 在畫面上顯示玩家角色的所有基本資訊

if CLIENT then

  local showPanel = false    -- 是否顯示面板
  local prevI = false        -- 上一幀 I 鍵狀態，用於單次觸發

  -- 每幀檢查鍵盤，I 鍵切換面板
  Hook.Add("think", "CIP_ToggleKey", function()
    -- 使用 XNA Keys I
    local down = Game.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.I)
    if down and not prevI then
      showPanel = not showPanel
    end
    prevI = down
  end)

  -- 畫面繪製時呼叫
  Hook.Add("draw", "CIP_DrawPanel", function()
    if not showPanel then return end

    -- 取得本地玩家角色
    local client = Client.Peer -- 或 Client.ClientList[1]
    if not client or not client.Character then return end
    local char = client.Character

    -- 位置與大小
    local x, y, w, h = 20, 40, 300, 200
    -- 半透明底色
    GUI.Box(Rectangle(x, y, w, h), Color(0, 0, 0, 160))

    local line = 0
    local function drawLabel(text)
      local ly = y + 10 + line * 20
      GUI.Label(Rectangle(x + 10, ly, w - 20, 20), text)
      line = line + 1
    end

    -- 基本資訊
    drawLabel("Name: " .. tostring(char.Name))
    drawLabel("Species: " .. tostring(char.SpeciesName))
    if char.CharacterHealth then
      local hp = math.floor(char.CharacterHealth.Health)
      local mh = math.floor(char.CharacterHealth.MaxHealth)
      drawLabel("Health: " .. hp .. " / " .. mh)
    end
    local pos = char.WorldPosition
    if pos then
      drawLabel(string.format("Position: %.1f, %.1f", pos.X, pos.Y))
    end

    -- 庫存物品
    drawLabel("Inventory:")
    if char.Inventory then
      for i, slot in ipairs(char.Inventory.AllItems) do
        local id = slot.ItemPrefab and slot.ItemPrefab.Identifier or "nil"
        drawLabel(string.format("  [%d] %s", i, id))
        if y + 10 + line * 20 > y + h - 20 then break end
      end
    end

    -- 按鍵提示
    GUI.Label(Rectangle(x + 10, y + h - 20, w - 20, 20),
      "按 I 關閉面板", GUI.Font, GUI.Alignment.Right)
  end)

end
]]
