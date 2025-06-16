-- FastMiningHelp.lua
-- 功能：列出「快速挖掘模組」的所有指令與簡易說明，讓新手也能一目了然
--[[
    下面以「快速挖掘模組（Fast Mining Mod）」為例示範，如何寫一個簡單易懂的「幫助」指令，讓新手也能快速上手。

	1. 在 Lua/Autorun/ 下新增檔案 FastMiningHelp.lua，內容如下：

	2. 如何使用：
		a. 將 FastMiningHelp.lua 放到你的模組目錄下的 Lua/Autorun/ 資料夾。
		b. 重新啟動遊戲或執行 cl_reloadlua。
		c. 在遊戲中按 F3 開啟控制台，輸入：fmining-help
		d. 你會看到上述逐行列出的所有指令與操作步驟說明。

    3.使用說明：
		1. 將此檔案放在 Barotrauma 的 Lua 模組資料夾中。
		2. 在遊戲中按 F3 打開控制台。
		3. 輸入 fmining-help 查看所有指令與說明。
		4. 可以使用其他指令來啟動或停止快速挖掘模式。

    注意：本模組必須先裝上「Lua for Barotrauma」才能正常運作。
]]
-- 僅在單人或伺服器端註冊
if SERVER or Game.IsSingleplayer then
	Game.AddCommand("fmining-help", "顯示「快速挖掘模組」所有指令與說明", function()
		local helpLines = {
			"=== 快速挖掘模組 使用說明 ===",
			"",
			"fmining-help               顯示本說明（你現在看到的畫面）",
			"fmining-start              啟動快速挖掘模式（自動切換至強化鑽頭）",
			"fmining-stop               停止快速挖掘模式，恢復原本鑽頭性能",
			"fmining-speed <倍率>       設定挖掘速度倍率，例如：fmining-speed 2 表示挖掘速度加倍",
			"",
			"使用範例：",
			"  1. 按 F3 打開控制台",
			"  2. 輸入 fmining-help 查看說明",
			"  3. 輸入 fmining-start 開始快速挖掘",
			"  4. 輸入 fmining-speed 3 將挖掘速度設為原本的 3 倍",
			"  5. 輸入 fmining-stop 關閉快速挖掘模式",
			"",
			"注意：本模組必須先裝上「Lua for Barotrauma」才能正常運作",
			"    如果不知道如何安裝，請參考模組說明頁面或官方指南。",
			"=================================",
		}

		-- 將每一行文字印到控制台
		for _, line in ipairs(helpLines) do
			print(line)
		end
	end)
end
