-- RemoteScooterControl.lua
-- Client & Server 合併腳本

if CLIENT then
	local channelMap = {} -- [item]=channel
	local camBackup = {} -- 鏡頭還原

	-- 初始化面板：頻道 & 電量
	Hook.Add("toggleCustomInterface", "InitPanel", function(item, opened)
		if not opened then
			return
		end
		if item.Identifier ~= "dronescooter" and item.Identifier ~= "scooterterminal" then
			return
		end
		-- 讀 channel
		local wifi = item:GetComponentString("WifiComponent")
		local ch = channelMap[item] or (wifi and wifi.Channel) or 1
		channelMap[item] = ch
		-- 讀 battery Condition
		local cont = item.Containers[1]
		local batt = cont and cont.ContainedItems[1]
		local pct = batt and math.floor((batt.Condition or 0) * 100) or 0
		-- 更新 UI
		local gui = item.GetCustomInterface(item)
		local lblCh = gui and gui.GetChildById("lblChannel")
		local lblBat = gui and gui.GetChildById("lblBattery")
		if lblCh then
			lblCh.Text = "頻道：" .. ch
		end
		if lblBat then
			lblBat.Text = "電量：" .. pct .. "% "
		end
	end)

	-- 處理面板按鈕：＋/－
	Hook.Add("guiMessage", "HandleChannelButtons", function(msg, element)
		if msg ~= "ButtonClicked" then
			return
		end
		local id = element.UserData
		local frame = element.Parent
		local item = frame.UserData
		if not item then
			return
		end

		if item.Identifier == "dronescooter" or item.Identifier == "scooterterminal" then
			local ch = channelMap[item] or 1
			if id == "btnChUp" then
				ch = (ch % 9) + 1
			elseif id == "btnChDown" then
				ch = (ch - 2) % 9 + 1
			else
				return
			end
			channelMap[item] = ch
			-- 同步頻道
			local w = item:GetComponentString("WifiComponent")
			if w then
				w.Channel = ch
			end
			-- 更新 Label
			local lbl = frame.GetChildById(frame, "lblChannel")
			if lbl then
				lbl.Text = "頻道：" .. ch
			end
		end
	end)

	-- 滑鼠控制 & 發送 SC:channel:dx,dy
	Hook.Add("think", "MouseControlAndBattery", function()
		local chr = Client.Character
		if not chr then
			return
		end
		local term = chr.SelectedItem
		if not term or term.Identifier ~= "scooterterminal" then
			return
		end

		local ch = channelMap[term] or term:GetComponentString("WifiComponent").Channel or 1
		-- direction
		local dir = chr.CursorWorldPosition - chr.WorldPosition
		if dir.Length > 0 then
			dir = dir / dir.Length
		end
		local press = Input.GetMouseButton(MouseButton.Primary)

		if not term._lastSend or os.clock() - term._lastSend > 0.1 then
			term._lastSend = os.clock()
			local dx, dy = 0, 0
			if press then
				dx, dy = dir.X, dir.Y
			end
			local msg = string.format("SC:%d:%.3f,%.3f", ch, dx, dy)
			term:GetComponentString("WifiComponent"):SendSignal(msg)
		end

		-- 面板開啟時更新電量
		local gui = term.GetCustomInterface(term)
		if gui then
			local cont = term.Containers[1]
			local batt = cont and cont.ContainedItems[1]
			local pct = batt and math.floor((batt.Condition or 0) * 100) or 0
			local lbl = gui.GetChildById(gui, "lblBattery")
			if lbl then
				lbl.Text = "電量：" .. pct .. "%"
			end
		end
	end)

	-- Select → 切畫面
	Hook.Add("useItem", "RemoteScooter_OpenCam", function(item, user)
		if item.Identifier ~= "scooterterminal" or user ~= Client.Character then
			return
		end
		local ch = channelMap[item] or item:GetComponentString("WifiComponent").Channel or 1
		local best, dist2 = nil, math.huge
		for _, it in pairs(Item.ItemList) do
			if it.Identifier == "dronescooter" then
				local w = it:GetComponentString("WifiComponent")
				if w and w.Channel == ch then
					local d2 = Vector2.DistanceSquared(it.WorldPosition, user.WorldPosition)
					if d2 < dist2 then
						best, dist2 = it, d2
					end
				end
			end
		end
		if not best then
			return
		end
		camBackup.pos = Client.Camera.Position
		camBackup.zoom = Client.Camera.Zoom
		Client.Camera.Position = best.WorldPosition
		Client.Camera.Zoom = 1.2
		return true
	end)

	-- Esc → 還原畫面
	Hook.Add("think", "RemoteScooter_CloseCam", function()
		if camBackup.pos and Input.GetKeyDown(KeyboardKey.Escape) then
			Client.Camera.Position = camBackup.pos
			Client.Camera.Zoom = camBackup.zoom
			camBackup = {}
		end
	end)

	return
end

-- ===== SERVER 端 =====
local scooters = {} -- [item]={dx,dy,sound,launched}

-- 註冊滑板
Hook.Add("itemSpawn", "RegScooter", function(item)
	if item.Identifier == "dronescooter" then
		scooters[item] = { dx = 0, dy = 0, sound = false, launched = false }
	end
end)
Hook.Add("itemDespawn", "UnregScooter", function(item)
	scooters[item] = nil
end)

-- 接收控制信號
Hook.Add("signalReceived", "ScooterSignal", function(signal, item)
	if item.Identifier ~= "dronescooter" or signal.type ~= SignalType.Wifi then
		return
	end
	local msg = signal.signal
	local _, rch, dx, dy = msg:match("^(SC:(%d+):([%-%d%.]+),([%-%d%.]+))")
	local w = item:GetComponentString("WifiComponent")
	if not (rch and w and tonumber(rch) == w.Channel) then
		return
	end

	local st = scooters[item]
	st.dx, st.dy = tonumber(dx) or 0, tonumber(dy) or 0

	-- 首次推進：解除附著（Placeable）→啟用動態物理
	if not st.launched and (st.dx ~= 0 or st.dy ~= 0) then
		item.Body.IsStatic = false -- 將 Body 設為動態
		st.launched = true
	end
end)

-- 施力、扣電、音效
Hook.Add("think", "ApplyScooterPhysics", function()
	local power, fade = 200, 0.2
	for item, st in pairs(scooters) do
		if not st.launched then
			goto cont
		end

		-- 扣電
		local cont = item.Containers[1]
		local batt = cont and cont.ContainedItems[1]
		if batt and batt.Condition > 0 then
			if st.dx ~= 0 or st.dy ~= 0 then
				batt.Condition = math.max(batt.Condition - 0.005 * DeltaTime, 0)
			end
		else
			st.dx, st.dy = 0, 0 -- 無電停推
		end

		-- 推進力與音效
		if st.dx ~= 0 or st.dy ~= 0 then
			local f = Microsoft.Xna.Framework.Vector2(st.dx * power, st.dy * power)
			item.Body:ApplyForce(f)
			if not st.sound then
				item:PlaySound("scooter_loop")
				st.sound = true
			end
		else
			if st.sound then
				item:StopSound("scooter_loop", fade)
				st.sound = false
			end
		end

		::cont::
	end
end)
--[[
重點說明：

- Server 端在 首次 收到非零推進向量時，將 item.Body.IsStatic = false，解除 Placeable 的靜態附著，讓滑板以動態物理開始移動。
- 每次推進都會從 mobilebattery 扣除 Condition（0.5%/秒），電量為 0 時自動停止。
- Client 端的面板即時顯示「頻道」與「電量百分比」。
完成以上檔案後，將 YourModFolder 放入 Mods 資料夾即可啟用。祝使用愉快！
]]
