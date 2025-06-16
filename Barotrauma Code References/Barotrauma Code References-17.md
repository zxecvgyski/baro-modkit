

# Barotrauma Code References

**最後更新**：2025-06-14
 **來源**：Vanilla XML 結構說明

所有 XML 標籤依**首字母順序**排列，彷「字典」條目方式呈現。每項包含簡要說明、常用屬性表格與子標籤及其屬性說明。

------

## 目錄

- Affliction
- AndComponent
- Attack
- Body
- BrokenSprite
- ConnectionPanel
- Containable
- ContainedSprite
- CustomInterface
- DamagedInfectedSprite
- Deconstruct
- Fabricate
- Holdable
- IdCard
- InfectedSprite
- InventoryIcon
- IsActive
- Item
- ItemComponent
- ItemContainer
- LevelResource
- LightComponent
- LightTexture
- MeleeWeapon
- ParticleEmitter
- PowerContainer
- Powered
- PowerTransfer
- Price
- PreferredContainer
- Quality
- RangedWeapon
- RequiredItem
- RequiredSkill
- Repairable
- SkillRequirementHint
- SlotIcon
- StatusEffect
- Sprite
- Terminal
- Throwable
- TickBox
- Upgrade
- UpgradePreviewSprite
- WifiComponent
- Wire
- Lua API Mapping

------

## <Affliction>

**說明**：向目標實體附加狀態效果或造成傷害。
 屬性

| 屬性        | 類型   | 說明                   |
| ----------- | ------ | ---------------------- |
| identifier  | string | Affliction ID          |
| amount      | float  | 強度                   |
| probability | float  | 附加時的發生機率 (0–1) |

**子標籤**：無

**範例**：

```xml
<Affliction identifier="nausea" amount="50.0" probability="0.25" />
```



## <AiTarget>

**說明**：用於 AI，指定其目標搜索與行為模式。  
**屬性**

| 屬性       | 類型  | 說明         |
| ---------- | ----- | ------------ |
| sightrange | float | 視野範圍     |
| static     | bool  | 是否保持靜止 |

**子標籤**：無



## <AndComponent>

**說明**：執行邏輯“且”運算。
 屬性

| 屬性   | 類型   | 說明             |
| ------ | ------ | ---------------- |
| inputs | CSV    | 輸入信號名稱列表 |
| output | string | 輸出信號名稱     |

**子標籤**：無



## <Attack>

**說明**：定義攻擊效果，包含結構傷害與連鎖子標籤。

**屬性**

| 屬性            | 類型  | 說明       |
| --------------- | ----- | ---------- |
| structuredamage | float | 結構傷害量 |

**子標籤**  

- `<Affliction>`  
- `<StatusEffect>`


------

## <Body>

**說明**：定義物件的碰撞體屬性，包括形狀、密度與摩擦等。
 屬性

| 屬性                 | 類型  | 說明         |
| -------------------- | ----- | ------------ |
| width                | float | 碰撞箱寬度   |
| height               | float | 碰撞箱高度   |
| radius               | float | 圓形碰撞半徑 |
| density              | float | 密度         |
| friction             | float | 摩擦係數     |
| restitution          | float | 反彈係數     |
| waterdragcoefficient | float | 水中阻力係數 |

**子標籤**：無



## <BrokenSprite>

**說明**：顯示物件耐久低於設定值時的損壞外觀。

**屬性**

| 屬性         | 類型   | 說明                    |
| ------------ | ------ | ----------------------- |
| texture      | string | 精靈貼圖路徑            |
| sourcerect   | CSV    | 貼圖區域                |
| depth        | float  | 渲染深度                |
| maxcondition | float  | 當物件耐久 ≤ 此值時顯示 |
| fadein       | bool   | 耐久降至此值時是否漸顯  |

**子標籤**：無

---

## <ConnectionPanel> 

**說明**：定義物品的接線/控制介面，包含輸入輸出端點及其顯示樣式。

**屬性**

| 屬性          | 類型   | 說明             |
| ------------- | ------ | ---------------- |
| selectkey     | string | 交互選擇鍵       |
| canbeselected | bool   | 是否可被選中     |
| msg           | string | 交互提示文字 Tag |
| hudpriority   | int    | HUD 顯示優先級   |

**子標籤**  

- `<GuiFrame>` (relativesize, minsize, maxsize, anchor, style)

- `<RequiredItem>` (identifier, items, amount, …)

- `<input>` (name, displayname)

  | 屬性        | 類型   | 說明         |
  | ----------- | ------ | ------------ |
  | name        | string | 端點識別名稱 |
  | displayname | string | 顯示文字     |

- `<output>` (name, displayname, fallbackdisplayname)

  | 屬性                | 類型   | 說明                               |
  | ------------------- | ------ | ---------------------------------- |
  | name                | string | 端點識別名稱                       |
  | displayname         | string | 主顯示文字                         |
  | fallbackdisplayname | string | 當主顯示文字不可用時的備用顯示文字 |

**範例**：

```xml
<!-- 範例：ConnectionPanel 定義一個簡單的輸入/輸出介面 -->
<ConnectionPanel
    canbeselected="true"            <!-- 是否可被玩家選中 -->
    msg="use.connectionpanel"        <!-- 交互提示文字 (tag) -->
>
    <!-- 定義多組 output 介面 -->
    <output
        name="Input"                 <!-- 輸入識別符 -->
        displayname="信號輸入"      <!-- 顯示名稱 -->
        fallbackdisplayname="N/A"    <!-- 無法顯示時使用 -->
    />
    <output
        name="Output"
        displayname="信號輸出"
        fallbackdisplayname="N/A"
    />
</ConnectionPanel>

<ConnectionPanel selectkey="Action" canbeselected="true" msg="ItemMsgRewire" hudpriority="10">
  <GuiFrame relativesize="0.2,0.32" minsize="400,350" maxsize="480,420" anchor="Center" style="ConnectionPanel" />
  <RequiredItem items="screwdriver" type="Equipped" />
  <input name="power"    displayname="connection.power" />
  <input name="toggle"   displayname="connection.togglestate" />
</ConnectionPanel>
```



## <Containable>

**說明**：定義可被 ItemContainer 接受的物品範圍與排除條件。

**屬性**

| 屬性          | 類型 | 說明           |
| ------------- | ---- | -------------- |
| items         | CSV  | 允許存放的物品 |
| excludeditems | CSV  | 排除存放的物品 |
| hide          | bool | 隱藏圖示       |
| setactive     | bool | 動態啟用       |

**子標籤**：無



## <ContainedSprite>

**說明**：定義當容器內（或附著時）顯示的精靈。  

**屬性**

| 屬性                     | 類型   | 說明                              |
| ------------------------ | ------ | --------------------------------- |
| texture                  | string | 精靈貼圖路徑                      |
| usewhenattached          | bool   | 僅在附著時顯示                    |
| decorativespritebehavior | string | 顯示行為，如 `HideWhenNotVisible` |
| depth                    | float  | 渲染深度                          |
| sourcerect               | CSV    | 貼圖區域                          |
| origin                   | CSV    | 原點                              |
| canflipx                 | bool   | 水平翻轉                          |
| canflipy                 | bool   | 垂直翻轉                          |

**子標籤**：無



## <Controller> 

| 屬性                        | 類型   | 說明                      |
| --------------------------- | ------ | ------------------------- |
| UserPos                     | CSV    | 玩家定位相對座標          |
| direction                   | string | 面向方向 (`Left`,`Right`) |
| hidehud                     | bool   | 隱藏 HUD                  |
| issecondaryitem             | bool   | 是否為次要物品            |
| canbeselected               | bool   | 是否可被選中              |
| drawuserbehind              | bool   | 玩家是否在物品後方繪製    |
| noninteractablewhenflippedy | bool   | Y 翻轉後是否不可互動      |

**子標籤**

- `<limbposition>`
- `<StatusEffect>`



## <CustomInterface>

**說明**：定義物品自訂 UI 介面。

**屬性**

| 屬性                | 類型 | 說明             |
| ------------------- | ---- | ---------------- |
| canbeselected       | bool | 是否可被選中     |
| drawhudwhenequipped | bool | 裝備時顯示 HUD   |
| allowuioverlap      | bool | 是否允許 UI 重疊 |

**子標籤**  

- `<GuiFrame>`  
- `<TickBox>`

---

## <DamagedInfectedSprite>

**說明**：顯示被污染或感染且已受損的物件外觀。

**屬性**

| 屬性       | 類型   | 說明         |
| ---------- | ------ | ------------ |
| texture    | string | 精靈貼圖路徑 |
| sourcerect | CSV    | 貼圖區域     |
| origin     | CSV    | 原點         |

**子標籤**：無



## <Deconstruct>

**說明**：定義拆解容器／物件所需時間及產出物。

**屬性**

| 屬性 | 類型  | 說明         |
| ---- | ----- | ------------ |
| time | float | 拆解所需秒數 |

**子標籤**  

- `<Item>` (identifier, amount)  

  | 屬性       | 類型   | 說明      |
  | ---------- | ------ | --------- |
  | identifier | string | 產出物 ID |
  | amount     | int    | 產出數量  |

------

## <Fabricate>

**說明**：標記可被製造站製造的物品。

**屬性**

| 屬性                | 類型  | 說明                        |
| ------------------- | ----- | --------------------------- |
| suitablefabricators | CSV   | 適用製造站，如 `fabricator` |
| hidefornontraitors  | bool  | 非叛徒玩家是否隱藏          |
| requiredtime        | float | 製造所需時間（秒）          |
| requiredmoney       | int   | 需要的金錢                  |
| fabricationlimitmin | int   | 最小可製造數量              |
| fabricationlimitmax | int   | 最大可製造數量              |
| amount              | int   | 每次製造產出數量            |

**子標籤**  

- `<RequiredSkill>`  
- `<RequiredItem>`

------

## <Holdable>

**說明**：定義可手持物件的交互與擺放設定。

**屬性**

| 屬性                    | 類型   | 說明                                |
| ----------------------- | ------ | ----------------------------------- |
| slots                   | CSV    | 可手持插槽，如 `RightHand+LeftHand` |
| holdpos                 | CSV    | 持握時相對座標                      |
| handle1                 | CSV    | 第一手柄相對座標                    |
| handle2                 | CSV    | 第二手柄相對座標                    |
| holdangle               | float  | 持握角度                            |
| aimable                 | bool   | 是否可瞄準                          |
| msg                     | string | 交互提示 Tag                        |
| canbeselected           | bool   | 是否可被選中                        |
| canbepicked             | bool   | 是否可被拾取                        |
| pickkey                 | string | 拾取鍵                              |
| allowswappingwhenpicked | bool   | 撿起時是否允許切換                  |
| controlpose             | bool   | 使用時是否以 ControlPose 播放       |
| swingamount             | CSV    | 擺動幅度，如 `10,20`                |
| swingspeed              | float  | 擺動速度                            |
| swingwhenusing          | bool   | 使用時是否擺動                      |
| aimangle                | float  | 瞄準時的額外角度偏移                |

**子標籤**：無

------

## <IdCard>

**說明**：定義身份證件的欄位與交互設定。

**屬性**

| 屬性               | 類型   | 說明             |
| ------------------ | ------ | ---------------- |
| slots              | CSV    | 可裝卡槽         |
| OwnerNameLocalized | string | 本地化擁有者名稱 |
| msg                | string | 交互提示 Tag     |

**子標籤**：無



## <InfectedSprite>

**說明**：顯示物件被污染或感染後的特殊外觀。

**屬性**

| 屬性       | 類型   | 說明         |
| ---------- | ------ | ------------ |
| texture    | string | 精靈貼圖路徑 |
| sourcerect | CSV    | 貼圖區域     |
| origin     | CSV    | 原點         |

**子標籤**：無



## <InventoryIcon>

**說明**：定義物品在背包或工具列中的顯示圖示。

**屬性**

| 屬性       | 類型   | 說明            |
| ---------- | ------ | --------------- |
| texture    | string | 圖集路徑        |
| sourcerect | CSV    | 圖區（x,y,w,h） |
| origin     | CSV    | 圖示原點（x,y） |

**子標籤**：無



## <IsActive>

**說明**：根據條件判斷並控制元件的啟用與停用狀態。

**屬性**

| 屬性                 | 類型   | 說明                                                    |
| -------------------- | ------ | ------------------------------------------------------- |
| targetitemcomponent  | string | 依據其狀態判斷啟用的子元件 identifier                   |
| overload             | string | (LightComponent) 過載條件，如 `"eq True"` 或 `"gt 0.5"` |
| rechargeratio        | string | (PowerContainer) 充電比率條件                           |
| currpowerconsumption | string | (PowerContainer) 當前消耗功率條件                       |

**子標籤**：無



## <Item>

**說明**：定義遊戲中可放置的物品實體，包括其外觀、交互與行為組件。  

**屬性**

| 屬性                                    | 類型   | 說明                                                 |
| --------------------------------------- | ------ | ---------------------------------------------------- |
| name                                    | string | 顯示名稱，""空字符串用來多語言翻譯                   |
| identifier                              | string | 唯一識別 ID                                          |
| nameidentifier                          | string | （可選）名稱標識，用於對應本地化                     |
| aliases                                 | CSV    | （可選）同義 ID 列表                                 |
| scale                                   | float  | 縮放比例                                             |
| noninteractable                         | bool   | 是否不可交互                                         |
| category                                | string | 分類                                                 |
| subcategory                             | string | 子分類                                               |
| Tags                                    | CSV    | （可選）附加標籤列表                                 |
| variantof                               | string | 繼承自其他 Item 的 ID                                |
| linkable                                | bool   | 是否可連結                                           |
| pickdistance                            | float  | 拾取距離                                             |
| showcontentsintooltip                   | bool   | 在滑鼠提示顯示容器內容                               |
| impactsoundtag                          | string | 撞擊音效 Tag                                         |
| spritecolor                             | CSV    | 精靈渲染顏色，如 `255,128,0,255`                     |
| hideinmenus                             | bool   | 是否在選單中隱藏                                     |
| fireproof                               | bool   | 是否耐火                                             |
| description                             | string | 描述文字，""空字符串用來多語言翻譯                   |
| impacttolerance                         | float  | 撞擊耐受度                                           |
| inventoryiconcolor                      | CSV    | 背包圖示顏色，如 `110,120,110,255`                   |
| health                                  | int    | 耐久值                                               |
| cargocontaineridentifier                | string | 預設裝入貨櫃的容器 ID                                |
| isshootable                             | bool   | 是否可被射擊破壞                                     |
| sonarsize                               | int    | 聲納大小                                             |
| maxstacksizecharacterinventory          | int    | 人物物品欄最大堆疊數量                               |
| MaxStackSizeHoldableOrWearableInventory | int    | 人物物品欄裝備或手持時最大堆疊數量                   |
| RequireAimToUse                         | bool   | 是否需要瞄準後使用                                   |
| price                                   | int    | （舊版屬性）快捷定價，相當於 `<Price baseprice="…">` |
| allowstealingalways                     | bool   | 是否永遠可被偷竊                                     |
| descriptionidentifier                   | string | 本地化描述標識                                       |
| focusonselected                         | bool   | 裝備時自動對焦                                       |
| offsetonselected                        | float  | 對焦偏移量（像素）                                   |

**子標籤**

- `<Sprite>`  
- `<LightComponent>`  
- `<ConnectionPanel>`  
- `<Upgrade>`  
- `<SuitableTreatment>`

**說明**：指定物品可用於何種治療及其適用度。  

| 屬性        | 類型   | 說明                                          |
| ----------- | ------ | --------------------------------------------- |
| type        | string | 治療類型，如 `bleeding`、`burn`、`infection`… |
| suitability | float  | 適用度（數值，可正可負）                      |

- …（其他組件如 `<Holdable>`、`<Price>` 等）  

**範例**：

```xml
<Item identifier="wificam" focusonselected="true" offsetonselected="500" …>
  …
</Item>
```



## <ItemComponent>

**說明**：包裹多個子組件，用於定義 Item 特殊邏輯。

**屬性**：無 
**子標籤**  

- `<StatusEffect>`  



## <ItemContainer>

**說明**：定義物品容器內部結構，包括容量、插槽顯示及交互行為。

**屬性**

| 屬性                 | 類型   | 說明               |
| -------------------- | ------ | ------------------ |
| capacity             | int    | 容量               |
| maxstacksize         | int    | 單格最大堆疊數     |
| canbeselected        | bool   | 可被選中           |
| hideitems            | bool   | 隱藏內部物品       |
| hudpos               | CSV    | HUD 顯示位置       |
| uilabel              | string | HUD 標籤           |
| itempos              | CSV    | 物品圖示起始座標   |
| iteminterval         | CSV    | 物品圖示間隔       |
| itemrotation         | float  | 物品圖示旋轉角度   |
| containedspritedepth | float  | 容器內圖示渲染深度 |
| keepopenwhenequipped | bool   | 裝備時保持打開     |
| movableframe         | bool   | 面板可移動         |
| drawinventory        | bool   | 是否繪製內容清單   |
| slotsperrow          | int    | 每列插槽數         |

**子標籤**

- `<GuiFrame>` (relativesize, minsize, maxsize, anchor, style)  
- `<SlotIcon>` (slotindex, texture, sourcerect, origin)  
- `<Containable>` (items, excludeditems)

- `<SubContainer>`
   **說明**：嵌套的次級容器，用於 ItemContainer 中再細分插槽。

  | 屬性         | 類型 | 說明         |
  | ------------ | ---- | ------------ |
  | capacity     | int  | 容量         |
  | maxstacksize | int  | 單格最大堆疊 |

   **子標籤**：

   - `<Containable>`

**範例**：

```xml
<!-- 範例：misc.xml 中 captainspipe 的 ItemContainer -->
<ItemContainer
    hideitems="true"                    <!-- 隱藏容器內物品圖示 -->
    drawinventory="true"                <!-- 在物品提示中顯示內容列表 -->
    capacity="1"                        <!-- 容量 -->
    maxstacksize="1"                    <!-- 單格最大堆疊數 -->
    slotsperrow="6"                     <!-- 每列插槽數 -->
    itempos="74,-281"                   <!-- 首個插槽相對坐標 -->
    iteminterval="0,0"                  <!-- 插槽間隔 -->
    itemrotation="0"                    <!-- 插槽物品旋轉角度 -->
    canbeselected="false"               <!-- 是否可被選中 -->
    containedspritedepth="0.79"         <!-- 容器內精靈渲染深度 -->
>
  <SlotIcon
      slotindex="0"
      texture="Content/UI/StatusMonitorUI.png"
      sourcerect="0,384,64,64"
      origin="0.5,0.5"
  />
  <Containable items="pipetobacco" />
</ItemContainer>

<ItemContainer …>
  <SubContainer capacity="1" maxstacksize="1">
    <Containable items="mobilebattery" />
  </SubContainer>
</ItemContainer>
```



## <ItemLabel>

**說明**：為物品顯示自訂標籤或說明文字。
**屬性**

| 屬性          | 類型  | 說明                  |
| ------------- | ----- | --------------------- |
| scrollable    | bool  | 是否可滾動            |
| padding       | CSV   | 內邊距（左,上,右,下） |
| textcolor     | CSV   | 文字顏色（R,G,B,A）   |
| textscale     | float | 文字縮放比例          |
| canbeselected | bool  | 是否可被選中          |

**子標籤**：

- `<Upgrade>`（顯示升級提示）

**範例**：

```xml
<Item>
  <ItemLabel scrollable="true" padding="48,39,10,12" textcolor="1,1,1,1" textscale="0.7" canbeselected="false">
    <Upgrade gameversion="1.0.21.0" padding="48,39,10,12" />
  </ItemLabel>
</Item>
```

## 

## <InventoryIcon>

**說明**：定義物品在背包或工具列中的顯示圖示。

**屬性**

| 屬性       | 類型   | 說明     |
| ---------- | ------ | -------- |
| texture    | string | 圖集路徑 |
| sourcerect | CSV    | 素材區域 |
| origin     | CSV    | 圖示原點 |

**子標籤**：無

---

## <LevelResource>

**說明**：標記關卡資源，包含於地圖關卡配置。  
**屬性**：無  
**子標籤**：無



## <LightComponent>

**說明**：定義具備燈光效果的元件屬性，包括光源範圍、色彩、功耗與閃爍行為。

**屬性**

| 屬性                 | 類型   | 說明                             |
| -------------------- | ------ | -------------------------------- |
| range                | float  | 照射範圍                         |
| lightcolor           | string | 顏色 (`R,G,B,A` 或 `#RRGGBB`)    |
| flicker              | float  | 閃爍強度（0=不閃爍，1=強烈閃爍） |
| alphablend           | bool   | 是否使用透明混合                 |
| powerconsumption     | float  | 功率消耗                         |
| currpowerconsumption | float  | 當前實際消耗                     |
| IsOn                 | bool   | 是否預設打開                     |
| castshadows          | bool   | 是否投射陰影                     |
| blinkfrequency       | float  | 閃爍頻率（Hz）                   |
| allowingameediting   | bool   | 是否允許遊戲內編輯               |
| pulseamount          | float  | 脈衝亮度幅度                     |
| pulsefrequency       | float  | 脈衝頻率 (Hz)                    |

**子標籤**

- `<Sprite>` (texture, sourcerect, depth, origin, alpha)  
- `<Upgrade>` (gameversion, lightcolor)  
- `<IsActive>` (targetitemcomponent, overload)
- `<LightTexture>` (texture:string, origin:CSV）)  
- `<Sprite>` 

  | 屬性             | 類型   | 說明                |
  | ---------------- | ------ | ------------------- |
  | texture          | string | 精靈貼圖路徑        |
  | sourcerect       | CSV    | 貼圖區域            |
  | sheetindex       | CSV    | 圖集索引（行,列）   |
  | sheetelementsize | CSV    | 單元素尺寸（寬,高） |
  | depth            | float  | 渲染深度            |
  | origin           | CSV    | 原點                |
  | alpha            | float  | 透明度              |
- `<Upgrade>` (gameversion, lightcolor, indicatorposition, indicatorsize)  

- `<IsActive>` (targetitemcomponent, overload)  

**範例**：

```xml
<!-- 範例：LightComponent 用於可開關的燈光元件 -->
<LightComponent
    range="300"                      <!-- 燈光照射範圍 -->
    lightcolor="255,200,150,100"     <!-- RGBA 或 #FFAABB -->
    powerconsumption="0.5"           <!-- 消耗功率 -->
    currpowerconsumption="0.2"       <!-- 當前實際消耗 -->
    IsOn="false"                     <!-- 初始是否開啟 -->
    castshadows="true"               <!-- 是否投射陰影 -->
    blinkfrequency="1.0"             <!-- 閃爍頻率(Hz) -->
    allowingameediting="true"        <!-- 遊戲內是否可編輯 -->
>
    <!-- 精靈定義 -->
    <Sprite
        texture="Content/Items/Light.png"
        sourcerect="0,0,32,32"
        depth="0.8"
        origin="16,16"
        alpha="0.9"
    />
    <!-- 升級資訊 -->
    <Upgrade
        gameversion="0.15.0"
        lightcolor="255,255,255,200"
        indicatorposition="0.5,0.1"
        indicatorsize="0.2,0.2"
    />
    <!-- 動態啟用條件 -->
    <IsActive
        targetitemcomponent="Battery"
        overload="gt 0.1"
    />
</LightComponent>

<LightComponent range="0" lightcolor="47,146,209,255" flicker="0.3" powerconsumption="0" IsOn="true" castshadows="false" alphablend="true">
  <LightTexture texture="Content/Lights/pointlight.png" origin="0.5,0.5" />
  <Sprite texture="Content/Map/NeonSign_light.png" sheetindex="0,0" sheetelementsize="128,128" depth="0.1" origin="0.5,0.52" alpha="0.5" />
</LightComponent>
```



## <LightTexture> 

**說明**：定義點光源質地，用於 LightComponent 的光暈效果。

**屬性**

| 屬性    | 類型   | 說明         |
| ------- | ------ | ------------ |
| texture | string | 貼圖路徑     |
| origin  | CSV    | 貼圖原點     |
| size    | CSV    | 霓虹光暈尺寸 |

**子標籤**：無

```xml
<LightTexture texture="…/visioncircle.png" origin="0.5,0.5" size="0.1,0.1" />
```



## <limbposition> 

**說明**：定義近戰武器的攻擊與行為。

**屬性**

| 屬性           | 類型       | 說明           |
| -------------- | ---------- | -------------- |
| limb           | string     | 肢體名稱       |
| position       | CSV        | 相對座標       |
| allowusinglimb | bool, 可選 | 該肢體是否可用 |

**子標籤**：無

**範例**：

```xml
<limbposition limb="Head" position="x,y" [allowusinglimb="false"] />
```

---

## <MeleeWeapon>

**說明**：定義近戰武器的攻擊與行為。

**屬性**

| 屬性              | 類型   | 說明                     |
| ----------------- | ------ | ------------------------ |
| canBeCombined     | bool   | 是否可與其他物品合併使用 |
| removeOnCombined  | bool   | 合併後是否移除自身       |
| slots             | CSV    | 可裝備插槽               |
| aimpos            | CSV    | 瞄準位置                 |
| handle1           | CSV    | 手柄位置1                |
| handle2           | CSV    | 手柄位置2                |
| holdangle         | float  | 持握角度                 |
| reload            | float  | 重裝時間                 |
| msg               | string | 交互提示 Tag             |
| HitOnlyCharacters | bool   | 僅對角色造成傷害         |

**子標籤**  

- `<Attack>`  
- `<StatusEffect>`

------

## <ParticleEmitter>

**說明**：生成並管理粒子效果（如煙霧、火花、氣泡等），支援位置、速率與條件設定。

**屬性**

| 屬性                | 類型   | 說明         |
| ------------------- | ------ | ------------ |
| particle            | string | 粒子類型     |
| particlespersecond  | float  | 每秒發射數量 |
| particleamount      | int    | 單次發射數量 |
| emitinterval        | float  | 發射間隔     |
| ScaleMin / scalemin | float  | 最小縮放     |
| ScaleMax / scalemax | float  | 最大縮放     |
| DistanceMin         | float  | 最小距離     |
| DistanceMax         | float  | 最大距離     |
| distancemin         | float  | 同上（小寫） |
| distancemax         | float  | 同上（小寫） |
| anglemin / angle    | float  | 最小角度     |
| anglemax            | float  | 最大角度     |
| velocitymin         | float  | 最小速度     |
| velocitymax         | float  | 最大速度     |
| mincondition        | float  | 最小耐久顯示 |
| maxcondition        | float  | 最大耐久顯示 |

**子標籤**：無

**範例**：

```xml
<!-- 範例：ParticleEmitter 產生氣泡效果 -->
<ParticleEmitter
    particle="bubbles"               <!-- 粒子類型 -->
    particlespersecond="20"          <!-- 每秒發射數量 -->
    particleamount="5"               <!-- 每次發射數量 -->
    emitinterval="0.2"               <!-- 多久發一次 -->
    scalemin="0.1"
    scalemax="0.3"
    distancemin="0"                  <!-- 粒子起始最小距離 -->
    distancemax="20"                 <!-- 粒子起始最大距離 -->
    anglemin="0"
    anglemax="360"
    velocitymin="30"
    velocitymax="60"
    mincondition="0.0"               <!-- 物品耐久條件最小 -->
    maxcondition="1.0"               <!-- 物品耐久條件最大 -->
/>
```

---

## <PowerContainer>

**說明**：定義可充放電的電力容器屬性，包括容量、充電速率、效率與輸出限制。

**屬性**

| 屬性                         | 類型   | 說明             |
| ---------------------------- | ------ | ---------------- |
| capacity                     | float  | 最大儲能         |
| rechargespeed                | float  | 自動充電速率     |
| maxrechargespeed             | float  | 最大充電速率     |
| maxoutput                    | float  | 最大輸出功率     |
| efficiency                   | float  | 充放電效率       |
| exponentialrechargespeed     | bool   | 使用指數充電曲線 |
| rechargeadjustspeed          | float  | 充電調節速率     |
| rechargewarningindicatorlow  | float  | 低警告閾值       |
| rechargewarningindicatorhigh | float  | 高警告閾值       |
| canbeselected                | bool   | 可否選中         |
| indicatorposition            | CSV    | 指示器座標       |
| indicatorsize                | CSV    | 指示器尺寸       |
| ishorizontal                 | bool   | 水平顯示         |
| msg                          | string | 交互提示訊息     |
| currpowerconsumption         | float  | 當前消耗功率     |

**子標籤**

- `<GuiFrame>`  
- `<Upgrade>`  
- `<StatusEffect>`  
- `<IsActive>`

**範例**：

```xml
<!-- 範例：PowerContainer 定義一個可充放電的電池盒 -->
<PowerContainer
    capacity="1000"                  <!-- 最大儲能 -->
    rechargespeed="50"               <!-- 自動充電速率 -->
    maxrechargespeed="200"           <!-- 最大充電速率 -->
    maxoutput="150"                  <!-- 最大輸出功率 -->
    efficiency="0.85"                <!-- 充放電效率 -->
    exponentialrechargespeed="false" <!-- 充電曲線使用指數 -->
    rechargeadjustspeed="5"          <!-- 充電調節速率 -->
    rechargewarningindicatorlow="0.2"  <!-- 低電量警告閾值 -->
    rechargewarningindicatorhigh="0.8" <!-- 高電量警告閾值 -->
    canbeselected="true"
    msg="use.powercontainer"
    indicatorposition="0.4,0.9"
    indicatorsize="0.2,0.05"
    ishorizontal="true"
    currpowerconsumption="10"
>
    <GuiFrame relativesize="0.9,0.2" anchor="top,center" style="IndicatorFrame" />
    <Upgrade gameversion="0.15.0" maxrechargespeed="300" maxoutput="250" />
    <StatusEffect type="OnBroken" condition="lt 0.1">
        <ParticleEmitter particle="sparks" particlespersecond="30" />
    </StatusEffect>
    <IsActive rechargeratio="gt 0.5" />
</PowerContainer>
```

## <Powered>

**說明**：定義簡易通電狀態管理，適用於只需通電指示而無複雜充放電邏輯的元件。

**屬性**

| 屬性                 | 類型  | 說明             |
| -------------------- | ----- | ---------------- |
| powerconsumption     | float | 功率消耗         |
| currpowerconsumption | float | 當前消耗         |
| isactive             | bool  | 是否處於工作狀態 |

**子標籤**

- `<GuiFrame>`  
- `<StatusEffect>`  

## <PowerTransfer>

**說明**：定義電力傳輸模組及其交互介面，包含連接控制與狀態顯示。

**屬性**

| 屬性          | 類型   | 說明         |
| ------------- | ------ | ------------ |
| canbeselected | bool   | 可選中       |
| msg           | string | 交互提示訊息 |

**子標籤**

- `<GuiFrame>`  
- `<StatusEffect>` (type, target, condition)  

## <Price>

**說明**：定義物品的基礎價格及各商店的價格參數（倍率、庫存條件等）。

**屬性**

| 屬性               | 類型  | 說明                         |
| ------------------ | ----- | ---------------------------- |
| baseprice          | int   | 基礎價格                     |
| sold               | bool  | 是否在商店販售               |
| boughtelsewhere    | bool  | 其他商店是否販售             |
| buyingmultiplier   | float | 買入價倍率                   |
| displaynonempty    | bool  | 商店顯示非空庫存             |
| minleveldifficulty | int   | 達到該難度才出現             |
| canbespecial       | bool  | 是否可作為特殊或特價商品出售 |

**子標籤**

- `<Price>`
  
  | 屬性                               | 類型   | 說明             |
  | ---------------------------------- | ------ | ---------------- |
  | storeidentifier                    | string | 商店 ID          |
  | minavailable                       | int    | 最低庫存         |
  | maxavailable                       | int    | 最大庫存         |
  | multiplier                         | float  | 該商店價格倍率   |
  | mindifficulty / minleveldifficulty | int    | 達到該難度才出現 |
  | sold                               | bool   | 是否在商店販售   |
  
- `<Reputation>`
  
  **說明**：指定商店對派系的最低聲望要求。 
  
  | 屬性    | 類型   | 說明     |
  | ------- | ------ | -------- |
  | faction | string | 派系 ID  |
  | min     | int    | 最低聲望 |

**範例**：

```xml
<Price baseprice="200" sold="true" minleveldifficulty="15">
  <Price storeidentifier="merchantresearch"
         minavailable="1"
         maxavailable="2"
         multiplier="0.9"
         sold="true"
         minleveldifficulty="35" />
</Price>
```
------

## <PreferredContainer>

**說明**：指定物品在世界生成時的首選與次選容器條件，包括數量與機率。

**屬性**

| 屬性             | 類型  | 說明          |
| ---------------- | ----- | ------------- |
| primary          | CSV   | 首選容器 ID   |
| secondary        | CSV   | 次選容器 ID   |
| amount           | int   | 固定生成數量  |
| minamount        | int   | 最少生成數量  |
| maxamount        | int   | 最多生成數量  |
| spawnprobability | float | 生成機率      |
| notcampaign      | bool  | 排除 Campaign |
| notpvp           | bool  | 排除 PvP      |

**子標籤**：無

------

## <Quality>

**說明**：組合多個品質統計值，用於隨機化物品的品質屬性。

**屬性**：無

**子標籤**

- `<QualityStat>`
  - stattype (string): 品質類型
  - value (float): 影響值

------

## <RangedWeapon>

**說明**：定義遠程武器的專屬屬性、發射邏輯與相關 UI 支援。

**屬性**

| 屬性                                 | 類型  | 說明               |
| ------------------------------------ | ----- | ------------------ |
| reload                               | float | 裝填時間           |
| spread                               | float | 命中分散度         |
| unskilledspread                      | float | 未專精分散度       |
| drawhudwhenequipped                  | bool  | 裝備時顯示準心     |
| crosshairscale                       | float | 準心縮放           |
| launchimpulse                        | float | 發射推力           |
| holdtrigger                          | bool  | 長按持續射擊       |
| combatPriority                       | int   | AI 戰鬥優先度      |
| barrelpos                            | CSV   | 槍口位置           |
| DualWieldReloadTimePenaltyMultiplier | float | 雙持重裝填懲罰倍率 |
| DualWieldAccuracyPenalty             | float | 雙持精度懲罰倍率   |

**子標籤**

- `<Crosshair>` (texture, sourcerect, origin)
- `<CrosshairPointer>` (texture, sourcerect, origin)
- `<Sound>` (file, type, range)
- `<RequiredItems>` (items, type, msg)
- `<RequiredSkill>` (identifier, level)
- `<StatusEffect>` (type, target, …)
- `<Explosion>` (range, force, smoke, sparks)



## <RequiredItem>

**說明**：指定製造、升級或互動操作所需的物品及其條件（數量、耐久等）。

**屬性**

| 屬性          | 類型   | 說明                            |
| ------------- | ------ | ------------------------------- |
| identifier    | string | 物品 ID                         |
| items         | CSV    | 允許的標籤列表                  |
| amount        | int    | 數量                            |
| description   | string | 額外提示                        |
| mincondition  | float  | 最低耐久                        |
| maxcondition  | float  | 最高耐久                        |
| usecondition  | float  | 使用後耐久                      |
| type          | string | 檢測方式                        |
| excludeditems | CSV    | 排除的標籤                      |
| count         | int    | 需求數量，也可用於替代 `amount` |

**子標籤**：無

**範例**：

```xml
<Fabricate …>
  <RequiredItem identifier="chlorine" count="2" />
</Fabricate>
```



## <RequiredSkill>

**說明**：指定製造或升級操作所需的技能與等級門檻。

**屬性**

| 屬性       | 類型   | 說明     |
| ---------- | ------ | -------- |
| identifier | string | 技能 ID  |
| level      | int    | 所需等級 |

**子標籤**：無

------

## <Repairable>

**說明**：定義物件維修流程、所需技能與物品，以及耐久恢復與磨損規則。

**屬性**

| 屬性                      | 類型   | 說明           |
| ------------------------- | ------ | -------------- |
| selectkey                 | string | 選中鍵         |
| header                    | string | 修理標題       |
| deteriorationspeed        | float  | 日常磨損速率   |
| mindeteriorationdelay     | float  | 首次磨損前延遲 |
| maxdeteriorationdelay     | float  | 最大磨損延遲   |
| mindeteriorationcondition | float  | 最低磨損耐久   |
| RepairThreshold           | float  | 可修理耐久閾值 |
| fixDurationHighSkill      | float  | 高技能修理耗時 |
| fixDurationLowSkill       | float  | 低技能修理耗時 |
| msg                       | string | 修理提示訊息   |
| hudpriority               | int    | HUD 顯示優先度 |

**子標籤**

- `<GuiFrame>`  
- `<RequiredSkill>`  
- `<RequiredItem>`  
- `<StatusEffect>`  
- `<ParticleEmitter>`  

**範例**：

```xml
<!-- 範例：Repairable 定義可修理物件的流程 -->
<Repairable
    selectkey="Repair"               <!-- 工具互動鍵 -->
    header="修理面板"                <!-- HUD 標題 -->
    deteriorationspeed="0.01"        <!-- 每秒磨損速度 -->
    mindeteriorationdelay="5.0"      <!-- 首次磨損延遲 -->
    maxdeteriorationdelay="60.0"     <!-- 最大磨損延遲 -->
    mindeteriorationcondition="0.2"  <!-- 最低磨損耐久 -->
    RepairThreshold="0.8"            <!-- 可修理耐久閾值 -->
    fixDurationHighSkill="3.0"       <!-- 高技能修理時間 -->
    fixDurationLowSkill="6.0"        <!-- 低技能修理時間 -->
    msg="use.repair"
    hudpriority="10"
>
    <!-- 需要技能 -->
    <RequiredSkill identifier="mechanics" level="2" />
    <!-- 需要物品 -->
    <RequiredItem identifier="wrench" amount="1" mincondition="0.5" />
    <!-- 修理成功時觸發粒子效果 -->
    <StatusEffect type="OnSuccess">
        <ParticleEmitter particle="sparks" particlespersecond="50" />
    </StatusEffect>
    <!-- 可視化修理範圍 -->
    <ParticleEmitter particle="repair" particlespersecond="10" />
</Repairable>
```

---

## <SkillRequirementHint>

**說明**：為製造或升級介面提供所需技能提示與建議等級。

**屬性**

| 屬性       | 類型   | 說明     |
| ---------- | ------ | -------- |
| identifier | string | 技能 ID  |
| level      | int    | 建議等級 |

**子標籤**：無

------

## <SlotIcon>

**說明**：定義容器插槽圖示的顯示屬性與位置。

**屬性**

| 屬性       | 類型   | 說明     |
| ---------- | ------ | -------- |
| slotindex  | int    | 插槽索引 |
| texture    | string | 圖片路徑 |
| sourcerect | CSV    | 素材區域 |
| origin     | CSV    | 圖片原點 |

**子標籤**：無

---

## <StatusEffect>

**說明**：定義條件滿足或事件觸發後執行的效果，如附加狀態、聲音、粒子或移除。

**屬性**

| 屬性                             | 類型   | 說明                                 |
| -------------------------------- | ------ | ------------------------------------ |
| type                             | string | 觸發類型 (OnUse, OnImpact…)          |
| target / targettype              | string | 作用目標 (This, Character…)          |
| delay                            | float  | 延遲時間                             |
| comparison                       | string | 邏輯組合 (And, Or)                   |
| disabledeltatime                 | bool   | 忽略時間縮放                         |
| condition                        | string | 額外條件                             |
| setvalue                         | any    | 設定值                               |
| statuseffecttags                 | string | 自訂狀態標籤，如 `playingharmonica`  |
| duration                         | float  | 持續時間（秒）                       |
| AllowWhenBroken                  | bool   | 是否允許在物品損壞後仍執行           |
| multiplyafflictionsbymaxvitality | bool   | 是否按最大生命值縮放 affliction 效果 |
| stackable                        | bool   | 是否可堆疊多次應用效果               |
| linktochat                       | bool   | 設定 WifiComponent.linktochat        |
| targettype                       | string | 作用目標類型，如 `Contained`         |
| Voltage                          | float  | 電壓門檻                             |
| targetslot                       | int    | 作用插槽索引                         |

**子標籤**

- `<Conditional>`
  **說明**：用於 `<StatusEffect>` 中，根據條件判斷是否執行子效果。
  **屬性**

  | 屬性                | 類型   | 說明                                                         |
  | ------------------- | ------ | ------------------------------------------------------------ |
  | entitytype          | string | 實體類型比較，如 `eq Character`                              |
  | targetitemcomponent | string | 指定元件狀態比較                                             |
  | Attached            | any    | 檢查附著狀態，例如 `eq true`                                 |
  | InWater             | any    | 檢查是否浸水                                                 |
  | Voltage             | string | 檢查電壓條件，如 `lte 0.5`                                   |
  | HasStatusTag        | string | 檢查實體是否具有指定的狀態標籤（可用 `!` 取反），例如 `HasStatusTag="!bloodsampletaken"` |
  | Snapped             | bool   | 檢查物件是否處於「Snapped」狀態（如已固定或連接）            |
  | ishuman             | bool   | 是否為人類                                                   |
  | speciesgroup        | string | 生物類群（群組）                                             |
  | speciesname         | string | 生物具體名稱                                                 |
  
- `<Affliction>` (identifier, amount)

- `<Explosion>` (range, force, smoke, sparks)

- `<ParticleEmitter>` (file, range, emitinterval, …)

- `<Sound>`
**說明**：在 `<StatusEffect>` 或其他可產生音效的位置定義音效。
**屬性**

  | 屬性                | 類型   | 說明                              |
  | ------------------- | ------ | --------------------------------- |
  | file                | string | 音效檔案路徑                      |
  | type                | string | 觸發類型 (OnUse, OnBroken…)       |
  | range               | float  | 聲音範圍                          |
  | selectionmode       | string | 選擇模式 (`random`、`sequential`) |
  | frequencymultiplier | float  | 播放頻率倍率                      |
  | loop                | bool   | 是否循環播放                      |
  | volume              | float  | 播放音量 (0.0–1.0)                |

- `<Remove>` (—)

- `<DropContainedItems>` (—)

- `<Use>`

  **說明**：在 `<StatusEffect>` 中觸發「使用」動作。

- `<ReduceAffliction>` (identifier, amount)
  **說明**：減少指定 Affliction 的強度。 

- `<Explosion>`

  **說明**：在 `<StatusEffect>` 或投射爆炸時產生爆炸效果。

  **屬性**

  | 屬性                  | 類型   | 說明                         |
  | --------------------- | ------ | ---------------------------- |
  | range                 | float  | 爆炸半徑                     |
  | structuredamage       | float  | 對結構造成的傷害             |
  | itemdamage            | float  | 對物品造成的傷害             |
  | ballastfloradamage    | float  | 對浮力室地板造成的傷害       |
  | force                 | float  | 施加推力                     |
  | severlimbsprobability | float  | 斷肢機率                     |
  | debris                | bool   | 是否生成碎片                 |
  | decal                 | string | 地面貼花 ID                  |
  | decalsize             | float  | 貼花尺寸                     |
  | penetration           | float  | 穿透率                       |
  | camerashake           | float  | 鏡頭震動強度                 |
  | camerashakerange      | float  | 鏡頭震動範圍                 |
  | flashrange            | float  | 閃光範圍                     |
  | flashduration         | float  | 閃光持續時間                 |
  | showeffects           | bool   | 是否顯示預設粒子、聲音等特效 |
  | screencolor           | CSV    | 屏幕閃白顏色 (`R,G,B,A`)     |
  | screencolorrange      | float  | 屏幕閃白半徑                 |
  | screencolorduration   | float  | 屏幕閃白持續時間             |
  | levelwalldamage       | float  | 爆炸對牆體造成的結構傷害     |

  **子標籤**

  - `<Affliction>` (identifier, amount…)  
  - `<Remove>`
  - …（其他如 `<ParticleEmitter>`、`<Sound>` 等可混合）

- `<Clear/>` 
  **說明**：清除當前常駐狀態效果。 
  
- `<RefundTalents>`
  **說明**：在 `<StatusEffect>` 中重置目標的天賦點數。
  
- `<SpawnItem>` 
  **說明**：在指定時機生成新物品。 
  
  | 屬性          | 類型   | 說明                                    |
  | ------------- | ------ | --------------------------------------- |
  | identifier    | string | 要生成的物品 ID                         |
  | identifiers   | CSV    | （可選）生成多個物品 ID 列表            |
  | spawnposition | string | 生成位置（如 `ThisInventory`、`World`） |
  | count         | int    | 固定生成數量                            |
  | mincount      | int    | 最少生成數量                            |
  | maxcount      | int    | 最多生成數量                            |
  | probability   | float  | 生成機率（0–1）                         |

**範例**：

```xml
<!-- 範例：traitor_items.xml 中的 Explosion -->
<Explosion range="500.0" ballastfloradamage="300" structuredamage="300" itemdamage="1000"
           force="20" severlimbsprobability="0.75" debris="true" decal="explosion" decalsize="0.75"
           penetration="0.5" camerashake="200" camerashakerange="10000"
           flashrange="1000" flashduration="2.0" screencolor="255,255,255,255"
           screencolorrange="5000" screencolorduration="3.0">
  <Affliction identifier="explosiondamage" strength="200" />
  <Affliction identifier="burn" strength="200" />
  <Affliction identifier="bleeding" strength="40" probability="0.05" />
  <Affliction identifier="stun" strength="10" />
  <Affliction identifier="radiationsickness" strength="30" />
</Explosion>

<StatusEffect type="OnImpact" …>
  <Explosion
    range="200.0"
    ballastfloradamage="50"
    structuredamage="10"
    levelwalldamage="50"
    itemdamage="250"
    force="5"
  >
    …
  </Explosion>
</StatusEffect>

<!-- 可用於立即執行消耗動作 -->
<StatusEffect type="OnSecondaryUse" target="This,Character">
  <Conditional Condition="lte 1" />
  <Use/>
</StatusEffect>

<StatusEffect …>
  <Conditional ishuman="true" />
  <Conditional speciesgroup="mudraptor" />
  <Conditional speciesname="Mudraptor_pet" />
</StatusEffect>

<StatusEffect type="OnSecondaryUse" target="This,Character" stackable="false" duration="7.5">
  …
</StatusEffect>

<StatusEffect type="OnUse" target="UseTarget">
  <Conditional entitytype="eq Character" />
  <RefundTalents />
  <Sound file="Content/Items/Medical/Syringe.ogg" range="500" />
</StatusEffect>

<StatusEffect type="OnContaining" targettype="This" Voltage="1.0" setvalue="true" />
<StatusEffect type="OnActive" target="This" linktochat="true" comparison="and" interval="0.5">
  <Conditional IsOn="true" />
  <Conditional voltage="gte 0.5" />
</StatusEffect>
```

------

## <Sprite>

**說明**：定義物品的精靈渲染屬性，包括貼圖路徑、區域、原點與渲染深度。

**屬性**

| 屬性             | 類型   | 說明                          |
| ---------------- | ------ | ----------------------------- |
| texture          | string | 圖片路徑                      |
| sourcerect       | CSV    | 圖片區域                      |
| origin           | CSV    | 原點                          |
| depth            | float  | 渲染深度                      |
| canflipx         | bool   | 水平翻轉                      |
| alpha            | float  | 透明度                        |
| premultiplyalpha | bool   | 是否預乘透明（僅部分 sprite） |

**子標籤**：無

------

## <Terminal>

**說明**：定義可交互終端裝置的 UI 配置（面板樣式、錨點）與交互訊息行為。

**屬性**

| 屬性                | 類型   | 說明               |
| ------------------- | ------ | ------------------ |
| canbeselected       | bool   | 可被選中           |
| msg                 | string | 交互訊息 Tag       |
| AllowInGameEditing  | bool   | 是否允許遊戲內編輯 |
| drawhudwhenequipped | bool   | 裝備時顯示 HUD     |
| AutoHideScrollbar   | bool   | 是否自動隱藏滾動條 |
| readonly            | bool   | 是否唯讀           |
| autoscrolltobottom  | bool   | 是否自動滾動到底部 |
| linestartsymbol     | string | 行首符號           |
| marginmultiplier    | float  | 邊距倍率           |

**子標籤**

- `<GuiFrame>`

   **屬性**

  | 屬性          | 類型   | 說明                                |
  | ------------- | ------ | ----------------------------------- |
  | hidedragicons | bool   | 隱藏拖曳圖示                        |
  | relativesize  | CSV    | 相對尺寸（width,height）            |
  | minsize       | CSV    | 最小像素尺寸（width,height）        |
  | maxsize       | CSV    | 最大像素尺寸（width,height）        |
  | anchor        | string | 錨點位置，如 `Center`、`TopLeft` 等 |
  | style         | string | UI 樣式名稱                         |



## <TextBox>

**說明**：自訂介面中的文字輸入框。
**屬性**

| 屬性          | 類型   | 說明         |
| ------------- | ------ | ------------ |
| text          | string | 顯示文字 Tag |
| propertyname  | string | 綁定屬性名稱 |
| maxtextlength | int    | 最大輸入長度 |

```xml
<CustomInterface …>
  <TextBox text="Set Channel" propertyname="channel" maxtextlength="4" />
</CustomInterface>
```

## 


## <Throwable>

**說明**：定義擲出物的交互與物理行為。

**屬性**

| 屬性             | 類型   | 說明                           |
| ---------------- | ------ | ------------------------------ |
| slots            | CSV    | 可擲出插槽，如 `Any,RightHand` |
| holdpos          | CSV    | 持握位置                       |
| handle1          | CSV    | 第一手柄位置                   |
| handle2          | CSV    | 第二手柄位置                   |
| throwforce       | float  | 擲出推力                       |
| msg              | string | 交互提示 Tag                   |
| characterusable  | bool   | （可選）角色是否可扔           |
| canbecombined    | bool   | （可選）可否與其他物品組合     |
| removeoncombined | bool   | （可選）組合後是否移除自身     |
| aimpos           | CSV    | （可選）瞄準位置               |

**子標籤**  

- `<StatusEffect>`



## <TickBox>

**說明**：自訂 UI 中的勾選框。

**屬性**

| 屬性 | 類型   | 說明         |
| ---- | ------ | ------------ |
| text | string | 顯示文字 Tag |

**子標籤**  

- `<StatusEffect>`

------

## <Upgrade>

**說明**：定義物件或元件的升級參數及 UI 指示器配置（位置、大小等）。

> 注意：scale 屬性亦可為字串運算式，如 `*0.5`。

**屬性**

| 屬性        | 類型   | 說明       |
| ----------- | ------ | ---------- |
| gameversion | string | 遊戲版本   |
| scale       | float  | 升級後縮放，可為浮點數或包含運算符的字串（如 `*0.5`、`+0.2`） |
| indicatorposition | CSV  | 指示器座標（x,y） |
| indicatorsize     | CSV  | 指示器尺寸（w,h） |

**子標籤**

- `<RequiredItems>` (items, type, msg, ignoreineditor)  
- `<Upgrade>` (gameversion, scale, indicatorposition, indicatorsize, maxrechargespeed, maxoutput)  

  | 屬性              | 類型   | 說明                                 |
  | ----------------- | ------ | ------------------------------------ |
  | gameversion       | string | 目標遊戲版本                         |
  | scale             | float  | 縮放比例                             |
  | indicatorposition | CSV    | UI 中指示器座標                      |
  | indicatorsize     | CSV    | UI 中指示器尺寸                      |
  | maxrechargespeed  | float  | （PowerContainer）升級後最大充電速率 |
  | maxoutput         | float  | （PowerContainer）升級後最大輸出功率 |

**範例**：

```xml
<!-- 範例：Upgrade 使用字串運算式 -->
<Upgrade gameversion="0.10.0.0" scale="*0.5" indicatorposition="0.1,0.1" indicatorsize="0.15,0.15" />
```



## <UpgradePreviewSprite>

**說明**：用於 UI 中顯示升級後物件的預覽精靈及其原點設定。

**屬性**

| 屬性       | 類型   | 說明         |
| ---------- | ------ | ------------ |
| texture    | string | 精靈貼圖路徑 |
| sourcerect | CSV    | 貼圖區域     |
| origin     | CSV    | 原點         |

**子標籤**：無

------

## <Projectile>

**說明**：定義物品作為投射體的行為與傷害。

**屬性**

| 屬性                      | 類型   | 說明                                |
| ------------------------- | ------ | ----------------------------------- |
| characterusable           | bool   | 角色是否可使用                      |
| launchimpulse             | float  | 發射初速度                          |
| sticktocharacters         | bool   | 是否黏附在角色身上                  |
| launchrotation            | float  | 發射旋轉角度                        |
| inheritstatuseffectsfrom  | string | 繼承哪個 `<MeleeWeapon>` 的狀態效果 |
| inheritrequiredskillsfrom | string | 繼承哪個 `<MeleeWeapon>` 的所需技能 |

**子標籤**  

- `<Attack>`  
- `<StatusEffect>`

**範例**：

```xml
<Projectile
  characterusable="false"
  launchimpulse="18.0"
  sticktocharacters="true"
  launchrotation="-90"
  inheritStatusEffectsFrom="MeleeWeapon"
  inheritrequiredskillsfrom="MeleeWeapon"
/>
```

------

## <Wearable>

**說明**：定義穿戴物品的插槽、對應肢體與狀態顯示行為。

**屬性**

| 屬性                   | 類型   | 說明         |
| ---------------------- | ------ | ------------ |
| slots                  | CSV    | 可穿戴插槽   |
| limbtype               | string | 部位類型     |
| msg                    | string | 訊息 Tag     |
| displaycontainedstatus | bool   | 顯示內含狀態 |
| variants               | int    | 可用造型數量 |

**子標籤**

- `<damagemodifier>`  

**說明**：Wearable 中定義護甲對不同傷害類型的減免。

| 屬性                  | 類型   | 說明                      |
| --------------------- | ------ | ------------------------- |
| afflictionidentifiers | CSV    | 影響的 Affliction ID 列表 |
| afflictiontypes       | CSV    | 影響的 Affliction 類型    |
| armorsector           | CSV    | 作用方向角度範圍          |
| damagemultiplier      | float  | 傷害倍率                  |
| damagesound           | string | 撞擊音效 Tag              |
| deflectprojectiles    | bool   | 是否偏轉飛彈              |

- `<SkillModifier>`  
**說明**：Wearable 中臨時提升或降低玩家技能值。

| 屬性            | 類型   | 說明    |
| --------------- | ------ | ------- |
| skillidentifier | string | 技能 ID |
| skillvalue      | float  | 加成量  |

```xml
<Wearable ...>
    <damagemodifier afflictionidentifiers="lacerations,gunshotwound"
                armorsector="0.0,360.0"
                damagemultiplier="0.2"
                damagesound="LimbArmor"
                deflectprojectiles="true" />
                
	<SkillModifier skillidentifier="weapons" skillvalue="5" />
</Wearable>
```



## <WifiComponent>

**說明**：定義無線通訊元件的參數與訊息處理邏輯。

**屬性**

| 屬性                         | 類型  | 說明                          |
| ---------------------------- | ----- | ----------------------------- |
| canbeselected                | bool  | 可被選中                      |
| MinChatMessageInterval       | float | 最小訊息間隔                  |
| DiscardDuplicateChatMessages | bool  | 丟棄重複訊息                  |
| range                        | float | 作用範圍                      |
| linktochat                   | bool  | 是否將訊號發送到 chat channel |
| channel                      | int   | 頻道編號                      |

**子標籤**：無

```xml
<WifiComponent canbeselected="false" MinChatMessageInterval="0.0"
               range="35000.0" DiscardDuplicateChatMessages="true"
               linktochat="false" channel="1" … />
```



## <Wire>

**說明**：定義電路中信號線的外觀屬性與連接行為。

**屬性**

| 屬性      | 類型   | 說明             |
| --------- | ------ | ---------------- |
| color     | string | 線顏色 (#RRGGBB) |
| width     | float  | 線寬             |
| thickness | float  | 線粗             |

**子標籤**：無

------
# Lua API Mapping（整合並排序）

| XML 標籤               | C# 類別                                           | Lua 類別                                          |
| ---------------------- | ------------------------------------------------- | ------------------------------------------------- |
| `<Affliction>`         | `Barotrauma.Affliction`                           | `Barotrauma.Affliction`                           |
| `<AiTarget>`           | `Barotrauma.Items.Components.AiTarget`            | `Barotrauma.Items.Components.AiTarget`            |
| `<CircuitBox>`         | `Barotrauma.Items.Components.CircuitBox`          | `Barotrauma.Items.Components.CircuitBox`          |
| `<ConnectionPanel>`    | `Barotrauma.Items.Components.ConnectionPanel`     | `Barotrauma.Items.Components.ConnectionPanel`     |
| `<Conditional>`        | `Barotrauma.StatusEffectCondition`                | `Barotrauma.StatusEffectCondition`                |
| `<Deconstruct>`        | `Barotrauma.Items.Components.Deconstruct`         | `Barotrauma.Items.Components.Deconstruct`         |
| `<Explosion>`          | `Barotrauma.Items.Components.Explosion`           | `Barotrauma.Items.Components.Explosion`           |
| `<Fabricate>`          | `Barotrauma.Items.Components.Fabricate`           | `Barotrauma.Items.Components.Fabricate`           |
| `<Holdable>`           | `Barotrauma.Items.Components.Holdable`            | `Barotrauma.Items.Components.Holdable`            |
| `<Item>`               | `Barotrauma.ItemPrefab` / `Barotrauma.Item`       | `Barotrauma.ItemPrefab` / `Barotrauma.Item`       |
| `<Price>`              | `Barotrauma.Items.Components.Price`               | `Barotrauma.Items.Components.Price`               |
| `<PreferredContainer>` | `Barotrauma.Items.Primitives.PreferredContainer`  | `Barotrauma.Items.Primitives.PreferredContainer`  |
| `<Projectile>`         | `Barotrauma.Items.Components.Projectile`          | `Barotrauma.Items.Components.Projectile`          |
| `<Quality>`            | `Barotrauma.Items.Components.Quality`             | `Barotrauma.Items.Components.Quality`             |
| `<RangedWeapon>`       | `Barotrauma.Items.Components.RangedWeapon`        | `Barotrauma.Items.Components.RangedWeapon`        |
| `<Reputation>`         | `Barotrauma.Items.Primitives.Reputation`          | `Barotrauma.Items.Primitives.Reputation`          |
| `<RequiredItem>`       | `Barotrauma.Items.Components.RequiredItem`        | `Barotrauma.Items.Components.RequiredItem`        |
| `<RequiredSkill>`      | `Barotrauma.Items.Components.RequiredSkill`       | `Barotrauma.Items.Components.RequiredSkill`       |
| `<Sprite>`             | `Barotrauma.Items.Primitives.Sprite`              | `Barotrauma.Sprite`                               |
| `<StatusEffect>`       | `Barotrauma.StatusEffect`                         | `Barotrauma.StatusEffect`                         |
| `<SuitableTreatment>`  | `Barotrauma.Items.Components.SuitableTreatment`   | `Barotrauma.Items.Components.SuitableTreatment`   |
| `<Terminal>`           | `Barotrauma.Items.Components.Terminal`            | `Barotrauma.Items.Components.Terminal`            |
| `<Use>`                | `Barotrauma.Items.Components.UseAction`           | `Barotrauma.Items.Components.UseAction`           |
| `<Upgrade>`            | `Barotrauma.Items.Components.Upgrade`             | `Barotrauma.Items.Components.Upgrade`             |
| `<Wearable>`           | `Barotrauma.Items.Components.Wearable`            | `Barotrauma.Items.Components.Wearable`            |
| `<WifiComponent>`      | `Barotrauma.Items.Components.WifiComponent`       | `Barotrauma.Items.Components.WifiComponent`       |
| `<Wire>`               | `Barotrauma.Items.Components.Wire`                | `Barotrauma.Items.Components.Wire`                |
------

