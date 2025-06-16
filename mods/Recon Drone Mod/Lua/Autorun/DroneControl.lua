-- DroneControl.lua
-- 客戶端：讀 WSAD，透過 WifiComponent 發送控制向量
--[[
YourModFolder/
├─ contentpackage.xml
├─ Items/
│   └─ drone_items.xml
├─ Lua/
│   └─ Autorun/
│       └─ DroneControl.lua
└─ Content/
    └─ Sounds/
        └─ engine_loop.ogg    ← 螺旋槳引擎迴圈音效
]]
if CLIENT then
	Hook.Add("think", "DroneRemoteInput", function()
		local chr = Client.Character
		if not chr then
			return
		end
		local remote = chr.SelectedItem
		if not remote or remote.Identifier ~= "droneremote" then
			return
		end

		local dx, dy = 0, 0
		if Input.GetKey(KeyboardKey.W) then
			dy = dy - 1
		end
		if Input.GetKey(KeyboardKey.S) then
			dy = dy + 1
		end
		if Input.GetKey(KeyboardKey.A) then
			dx = dx - 1
		end
		if Input.GetKey(KeyboardKey.D) then
			dx = dx + 1
		end

		local len = math.sqrt(dx * dx + dy * dy)
		if len > 0 then
			dx, dy = dx / len, dy / len
		end

		if not remote._lastSend or os.clock() - remote._lastSend > 0.1 then
			remote._lastSend = os.clock()
			local wifi = remote:GetComponentString("WifiComponent")
			wifi:SendSignal(string.format("CTRL:%.3f,%.3f", dx, dy))
		end
	end)
	return
end

-- 伺服端：管理所有 Drone 實例
local drones = {} -- [item] = {dx,dy,soundPlaying}

-- 註冊與移除 Drone
Hook.Add("itemSpawn", "RegisterDrone", function(item)
	if item.Identifier == "recondrone" then
		drones[item] = { dx = 0, dy = 0, soundPlaying = false }
	end
end)
Hook.Add("itemDespawn", "UnregisterDrone", function(item)
	drones[item] = nil
end)

-- 接收遙控訊號，更新向量
Hook.Add("signalReceived", "DroneSignalHandler", function(signal, item)
	if item.Identifier ~= "recondrone" then
		return
	end
	if signal.type ~= SignalType.Wifi then
		return
	end
	local msg = signal.signal
	local x, y = msg:match("CTRL:([%-%.%d]+),([%-%.%d]+)")
	if x and y then
		drones[item].dx = tonumber(x)
		drones[item].dy = tonumber(y)
	end
end)

-- 每幀施力與音效控制
Hook.Add("think", "DroneApplyThrust", function()
	local thrustPower = 200 -- 推力係數
	local fadeTime = 0.2 -- 音效淡出秒數

	for drone, state in pairs(drones) do
		-- 如果仍在 Dock 內則停止音效並跳過
		local cont = drone.Containers[1]
		if cont and #cont.ContainedItems > 0 then
			if state.soundPlaying then
				drone:StopSound("engine_loop", fadeTime)
				state.soundPlaying = false
			end
		else
			local dx, dy = state.dx, state.dy
			local body = drone.Body

			if dx ~= 0 or dy ~= 0 then
				local force = Microsoft.Xna.Framework.Vector2(dx * thrustPower, dy * thrustPower)
				body:ApplyForce(force)
				if not state.soundPlaying then
					drone:PlaySound("engine_loop")
					state.soundPlaying = true
				end
			else
				if state.soundPlaying then
					drone:StopSound("engine_loop", fadeTime)
					state.soundPlaying = false
				end
			end
		end
	end
end)
--[[
使用說明
將整個 YourModFolder 放入 Barotrauma 的 Mods 目錄。
確認 Content/Sounds/engine_loop.ogg 存在，並在模組設定中打包。
遊戲內 Fabricator 製造／放置 Dock（dronedock），於 Dock 插槽中取得 Drone。
手持遙控器（droneremote），選中後按 WSAD 控制 Drone、聆聽引擎聲。
可在任何可放置位置（含艙門外的船殼）放置 Drone Dock，並於 Lua 指令或 StatusEffect 中自行擴充發射／回收行為。
]]
-- 前面已載入的 DroneControl.lua ...（省略註冊、遙控、推力部分）--
-- 客戶端：使用 Monitor 切換鏡頭到 Drone
-- 當人物使用 Monitor 時（UseKey），切換鏡頭
--[[
我們利用 Client API：
• 點擊 Monitor → 切換鏡頭到最近的 Drone
• 按 Esc → 回到主潛艇鏡頭
]]

if CLIENT then
	local monitorActive = false
	local savedCamPos, savedCamZoom

	-- 當人物使用 Monitor 時（UseKey），切換鏡頭
	Hook.Add("useItem", "OpenDroneMonitor", function(item, user)
		if item.Identifier ~= "cammonitor" or user ~= Client.Character then
			return
		end

		-- 找到最近的一架 Drone
		local closest, dist2 = nil, math.huge
		for _, it in pairs(Item.ItemList) do
			if it.Identifier == "recondrone" and not (it.Containers[1] and #it.Containers[1].ContainedItems > 0) then
				local d2 = Vector2.DistanceSquared(it.WorldPosition, user.WorldPosition)
				if d2 < dist2 then
					closest, dist2 = it, d2
				end
			end
		end
		if not closest then
			return
		end

		-- 存下當前鏡頭狀態
		savedCamPos = Client.Camera.Position
		savedCamZoom = Client.Camera.Zoom

		-- 切到 Drone
		Client.Camera.Position = closest.WorldPosition
		Client.Camera.Zoom = 1.5
		monitorActive = true

		return true -- 阻止預設交互
	end)

	-- Esc 回到原本的鏡頭
	Hook.Add("think", "CloseDroneMonitor", function()
		if not monitorActive then
			return
		end
		if Input.GetKeyDown(KeyboardKey.Escape) then
			if savedCamPos then
				Client.Camera.Position = savedCamPos
			end
			if savedCamZoom then
				Client.Camera.Zoom = savedCamZoom
			end
			monitorActive = false
		end
	end)
end
--[[
說明：

Client 偵測到玩家 useItem Monitor，找到場上最近、已發射的 Drone。
暫存主鏡頭位置 & Zoom，切換到 Drone。
按 Esc 時還原，模擬「關閉監視畫面」。
───

3. 小結
我們用 Drone 上的 <CameraHud/>＋WifiComponent 作為「理論上的信號管道」，實際上在 Monitor 端用鏡頭切換來模擬畫面輸出。
若要更進一步（真實在 UI 裡嵌入第二個 RenderTarget），目前 Barotrauma Mod API 尚不開放，需等官方擴充。
這樣一來，玩家就能拿 Monitor 走到任何地方，按 Use 鍵即刻「看到」Drone 的視角，按 Esc 返回自己的視角。
]]
