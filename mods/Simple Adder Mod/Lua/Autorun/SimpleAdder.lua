-- SimpleAdder.lua
-- 監聽 simpleadder 的訊號輸入，將 in1 + in2，並經由 out 輸出總和
--[[
以下是一個最簡易、完整可運行的「簡易加法器」模組範例，示範如何定義 XML、Lua、以及 filelist.xml，放入 Barotrauma 的 LocalMods 或 Workshop Mod 資料夾即可使用。

目錄結構 :

SimpleAdderMod/
├─ filelist.xml
├─ Items/
│  └─ simpleadder_items.xml
└─ Lua/
   └─ Autorun/
      └─ SimpleAdder.lua

1.filelist.xml
2.Items/simpleadder_items.xml
3.Lua/Autorun/SimpleAdder.lua

使用方式 :

1. 將上述資料夾 SimpleAdderMod 放入你的 Mods 目錄（LocalMods 或 Workshop Mods）。
2. 重啟遊戲或在遊戲內輸入 cl_reloadlua。
3. 在關卡中放置一個「Simple Adder」項目。
4. 透過電線（wire）將其他發訊模組的數值訊號接到它的 in1、in2。
5. 再將它的 out 接到可顯示數值的 Receiver（例如另一個 Lua 裝置或測試用輸出板）。
6. 當兩個輸入都觸發後，它會自動計算並從 out 輸出相加結果。

這個範例完整示範了如何：
● 在 <Items> XML 中定義一個帶有輸入/輸出腳位的自訂電路箱（CircuitBox）
● 用 filelist.xml 註冊你的 XML 和 Lua
● 在 Lua 中以 Hook.Add("signalReceived.<identifier>",…) 監聽並處理訊號
新手只要照著此範例改動 identifier、輸入/輸出名稱，就能快速打造屬於自己的電路邏輯模組。
]]
local buffer = {} -- 暫存每個裝置的輸入

Hook.Add("signalReceived.simpleadder", "SimpleAdder.SumInputs", function(signal, connection)
	local item = connection.Item

	-- 初始化暫存
	if not buffer[item] then
		buffer[item] = {}
	end
	local buf = buffer[item]

	-- 對應輸入腳位
	if connection.Name == "in1" then
		buf[1] = tonumber(signal.value) or 0
	elseif connection.Name == "in2" then
		buf[2] = tonumber(signal.value) or 0
	end

	-- 當兩個值都已有，計算並輸出
	if buf[1] and buf[2] then
		local sum = buf[1] + buf[2]
		item.SendSignal(tostring(sum), "out")
		-- 清空以便下一次使用
		buffer[item] = {}
	end
end)
