-- RemoteInjectorControl.lua
-- Client & Server 組合

if CLIENT then

  local chMap = {}   -- [item]=channel

  -- 1) 初始化兩個面板（遙控器/項圈）
  Hook.Add("toggleCustomInterface", "RIC_InitPanel", function(item, opened)
    if not opened then return end
    local id = item.Identifier
    if id ~= "remoteinjector" and id ~= "remoteinjector_collar" then return end

    -- 讀頻道
    local wifi = item:GetComponentString("WifiComponent")
    local ch = (chMap[item] or (wifi and wifi.Channel) or 1)
    chMap[item] = ch

    -- 更新 Label
    local gui  = item.GetCustomInterface(item)
    local lbl  = gui and gui.GetChildById("lblCh")
    if lbl then lbl.Text = "頻道："..ch end
  end)

  -- 2) 處理按鈕
  Hook.Add("guiMessage", "RIC_HandleButtons", function(msg, element)
    if msg ~= "ButtonClicked" then return end
    local id = element.UserData
    local frame = element.Parent
    local item  = frame.UserData
    if not item then return end

    local ident = item.Identifier
    if ident ~= "remoteinjector" and ident ~= "remoteinjector_collar" then return end

    -- +/- 調頻
    if id == "btnUp" or id == "btnDown" then
      local ch = chMap[item] or 1
      if id == "btnUp"   then ch = (ch % 9) +1
      else               ch = (ch-2) %9 +1 end
      chMap[item] = ch
      local w = item:GetComponentString("WifiComponent")
      if w then w.Channel = ch end
      local lbl = frame.GetChildById(frame, "lblCh")
      if lbl then lbl.Text = "頻道："..ch end
      return
    end

    -- 遙控器上的「注射」按鈕
    if ident == "remoteinjector" and id == "btnFire" then
      local ch = chMap[item] or item:GetComponentString("WifiComponent").Channel or 1
      -- 廣播信號：INJ:<channel>
      local msg = string.format("INJ:%d", ch)
      item:GetComponentString("WifiComponent"):SendSignal(msg)
    end
  end)

  return
end

-- ====== SERVER ======

-- 註冊所有項圈
local collars = {}  -- [item]={}

Hook.Add("itemSpawn", "RIC_RegCollar", function(item)
  if item.Identifier == "remoteinjector_collar" then
    collars[item] = true
  end
end)
Hook.Add("itemDespawn", "RIC_UnregCollar", function(item)
  collars[item] = nil
end)

-- 接收遠端注射信號
Hook.Add("signalReceived", "RIC_OnSignal", function(signal, item)
  if item.Identifier ~= "remoteinjector_collar" then return end
  if signal.type ~= SignalType.Wifi then return end

  -- 解析格式 INJ:<channel>
  local msg = signal.signal or ""
  local _, rch = msg:match("^(INJ:(%d+))")
  if not rch then return end
  local w = item:GetComponentString("WifiComponent")
  if not w or tonumber(rch) ~= w.Channel then return end

  -- 找到佩戴此項圈的角色
  local inv = item.ParentInventory
  local wearer = inv and inv.Owner and inv.Owner.GetTag and (inv.Owner) or nil
  if not wearer or not wearer.CharacterHealth then return end

  -- 取出所含藥劑
  local cont = item.Containers[1]
  local drug = cont and cont.ContainedItems[1]
  if not drug then return end

  -- 執行注射：示例使用 m 內建的 UseTarget
  -- (實際可依需要改成 drug.Use( ) 或直接套 Affliction)
  -- 這裡我們用最通用的：對目標呼叫 StatusEffects
  drug:Use(wearer, wearer.WorldPosition)

  -- 移除空藥劑
  drug.Remove = drug.Remove or function() drug.Condition = 0 end
  drug:Remove()
end)
--[[
• 將以上三個檔案放入 YourModFolder，並置於 Barotrauma Mods 資料夾中。
• 後續可自行調整 drug:Use(...) 的注射方式，或直接根據 drug.Identifier 給予不同 Affliction。
• 支援多個項圈同頻道同時注射，遠端按下一次「注射」按鈕即可。
]]