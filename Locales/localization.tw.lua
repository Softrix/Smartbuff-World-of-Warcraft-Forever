-------------------------------------------------------------------------------
-- Traditional Chinese localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "zhTW") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         更新內容：|r\n\n"
  .."          r1.121126 變更：\n\n"
  .."             * 修復 Forever 下與 LibDBIcon 相關的錯誤。\n"
  .."             * 補上缺失的聖騎士憤怒聖印（Seal of Fury）。\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic 由 Codermik、MrWizard &\n"
  .."Speedwaystar 製作。請加入 Discord 取得支援：\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffff若想支援本插件開發，請一律從 Curse 下載，或使用以下連結：\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffff原始作者：Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"匕首", "斧", "劍", "錘", "法杖", "拳套", "長柄武器", "投擲武器", "弩", "弓", "盾牌", "槍械"};
SMARTBUFF_WEAPON_BLUNT = {"錘", "法杖", "拳套"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "平衡石$";
SMARTBUFF_WEAPON_SHARP = {"匕首", "斧", "劍", "長柄武器"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "磨刀石$";

-- Creature types
SMARTBUFF_HUMANOID  = "人形生物";
SMARTBUFF_DEMON     = "惡魔";
SMARTBUFF_BEAST     = "野獸";
SMARTBUFF_ELEMENTAL = "元素生物";
SMARTBUFF_DEMONTYPE = "小鬼";
SMARTBUFF_UNDEAD    = "不死生物";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"德魯伊", "獵人", "法師", "聖騎士", "牧師", "盜賊", "薩滿", "術士", "戰士", "獵人寵物", "術士寵物", "坦克", "治療", "傷害輸出"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"單人", "小隊", "LFG", "團隊", "戰場", "競技場"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "熔火之心",
  "奧妮克希亞的巢穴",
  "祖爾格拉布",
  "黑翼之巢",
  "安其拉廢墟",
  "安其拉神廟",
  "納克薩瑪斯",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"自訂 1", "自訂 2", "自訂 3", "自訂 4", "自訂 5"};

-- Mount
SMARTBUFF_MOUNT = "速度提高(%d+)%%。";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d 次";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "觸發";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "目標";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "選項選單";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "重設增益計時器";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "修復施法"
SMARTBUFF_OFTT_FIXBUFF       = "預設啟用。使 SmartBuff 動作按鈕正確回應\n滑鼠點擊、巨集與滾輪，而不需更改全域\nActionButtonUseKeyDown CVar（使用按鈕的 useOnKeyDown 屬性）。\n啟用時，戰鬥中施放增益仍可能受限。"

SMARTBUFF_OFT                = "SmartBuff 開/關";
SMARTBUFF_OFT_MENU           = "顯示/隱藏選項選單";
SMARTBUFF_OFT_AUTO           = "提醒";
SMARTBUFF_OFT_AUTOTIMER      = "檢查間隔";
SMARTBUFF_OFT_AUTOCOMBAT     = "戰鬥中";
SMARTBUFF_OFT_AUTOCHAT       = "聊天";
SMARTBUFF_OFT_AUTOSPLASH     = "螢幕提示";
SMARTBUFF_OFT_AUTOSOUND      = "音效";
SMARTBUFF_OFT_SELECTSOUND    = "選擇音效";
SMARTBUFF_OFT_AUTOREST       = "在主城停用";
SMARTBUFF_OFT_HUNTERPETS     = "增益獵人寵物";
SMARTBUFF_OFT_WARLOCKPETS    = "增益術士寵物";
SMARTBUFF_OFT_ARULES         = "進階規則";
SMARTBUFF_OFT_BUFFS          = "增益/技能";
SMARTBUFF_OFT_TARGET         = "增益目前選取目標";
SMARTBUFF_OFT_DONE           = "關閉";
SMARTBUFF_OFT_APPLY          = "套用";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "職業人數";
SMARTBUFF_OFT_MESSAGES       = "停用訊息";
SMARTBUFF_OFT_MSGNORMAL      = "一般";
SMARTBUFF_OFT_MSGWARNING     = "警告";
SMARTBUFF_OFT_MSGERROR       = "錯誤";
SMARTBUFF_OFT_HIDEMMBUTTON   = "隱藏小地圖按鈕";
SMARTBUFF_OFT_INCLUDETOYS    = "包含玩具";
SMARTBUFF_OFT_REBUFFTIMER    = "重新增益計時";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "切換範本";
SMARTBUFF_OFT_SELFFIRST      = "優先自己";
SMARTBUFF_OFT_SCROLLWHEELUP  = "滾輪向上增益";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "向下";
SMARTBUFF_OFT_SCROLLZOOMING  = "縮放";
SMARTBUFF_OFT_TARGETSWITCH   = "切換目標時";
SMARTBUFF_OFT_BUFFTARGET     = "增益目標";
SMARTBUFF_OFT_BUFFPVP        = "增益 PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "副本";
SMARTBUFF_OFT_CHECKCHARGES   = "檢查次數";
SMARTBUFF_OFT_RBT            = "重設計時器";
SMARTBUFF_OFT_BUFFINCITIES   = "在主城增益";
SMARTBUFF_OFT_BLDURATION     = "已封鎖";
SMARTBUFF_OFT_ANTIDAZE       = "防暈眩";
SMARTBUFF_OFT_HIDESABUTTON   = "隱藏動作按鈕";
SMARTBUFF_OFT_HIDEIFIDLE     = "閒置時隱藏";
SMARTBUFF_OFT_RETAINTEMPLATE = "保留";
SMARTBUFF_OFT_INCOMBAT       = "戰鬥中";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "變身";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "團隊關聯";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "自身關聯";
SMARTBUFF_OFT_RESETALL       = "全部重設";
SMARTBUFF_OFT_RESETLIST      = "重設列表";
SMARTBUFF_OFT_RESETBUFFS     = "重設增益";
SMARTBUFF_OFT_NEWS           = "更新";
SMARTBUFF_OFT_PURGE_BUFFS    = "新版本，重設全部 SmartBuff 增益資料？\n這將重設所有增益設定檔！";
SMARTBUFF_OFT_YES            = "是";
SMARTBUFF_OFT_NO             = "否";
SMARTBUFF_OFT_OKAY           = "繼續"
SMARTBUFF_OFT_PURGE_DATA     = "新版本，重設全部 SmartBuff 資料？\n此操作將強制重新載入介面！";
SMARTBUFF_OFT_REQ_RELOAD     = "新版本需要重新載入介面。\n準備好後請點擊繼續。";
SMARTBUFF_OFT_SPLASHICON     = "顯示圖示";
SMARTBUFF_OFT_SPLASHMSGSHORT = "短訊息";
SMARTBUFF_OFT_FONTSTYLE      = "字型";
SMARTBUFF_OFT_FONTSIZE       = "字型大小";
SMARTBUFF_OFT_ICONSIZE       = "圖示大小";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "開關 SmartBuff";
SMARTBUFF_OFTT_RBT           = "重設計時器：僅清除增益計時器（執行階段；不改儲存變數）。";
SMARTBUFF_OFTT_RESETALL      = "全部重設：清除所有內容（設定檔 + 選項）。需要 ReloadUI。";
SMARTBUFF_OFTT_RESETBUFFS    = "重設增益：將增益與設定檔恢復為預設。";
SMARTBUFF_OFTT_RESETLIST     = "重設列表：僅重設增益順序。";
SMARTBUFF_OFTT_DONE          = "關閉選項。";
SMARTBUFF_OFTT_NEWS          = "檢視版本說明與更新紀錄。";
SMARTBUFF_OFTT_HELPLATE_RESET = "重設按鈕（暫留游標查看詳情）";
SMARTBUFF_OFTT_AUTO          = "開關增益提醒";
SMARTBUFF_OFTT_AUTOTIMER     = "兩次檢查之間的秒數延遲。";
SMARTBUFF_OFTT_AUTOCOMBAT    = "戰鬥中也執行檢查。\n除非啟用主選項中的「戰鬥中」（選項視窗內，而非此項），否則戰鬥中所有提醒邏輯都會停用。";
SMARTBUFF_OFTT_AUTOCHAT      = "以聊天訊息顯示缺少的增益。";
SMARTBUFF_OFTT_AUTOSPLASH    = "在螢幕中央以提示訊息\n顯示缺少的增益。";
SMARTBUFF_OFTT_AUTOSOUND     = "缺少增益時播放音效。";
SMARTBUFF_OFTT_AUTOREST      = "在主城停用提醒";
SMARTBUFF_OFTT_HUNTERPETS    = "同樣增益獵人寵物。";
SMARTBUFF_OFTT_WARLOCKPETS   = "同樣增益術士寵物，但排除" .. SMARTBUFF_DEMONTYPE .. "。";
SMARTBUFF_OFTT_ARULES        = "不施放：\n- 對法師、牧師和術士施放荊棘術\n- 對無法力單位施放秘法智慧\n- 對無法力單位施放神聖之靈";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "隱藏 SmartBuff 小地圖按鈕。";
SMARTBUFF_OFTT_INCLUDETOYS   = "在列表中包含玩具，與法術和食物一起。";
SMARTBUFF_OFTT_REBUFFTIMER   = "增益到期前多少秒\n提醒應發出警告。\n0 = 停用";
SMARTBUFF_OFTT_SELFFIRST     = "優先增益你的角色。";
SMARTBUFF_OFTT_SCROLLWHEELUP = "向前滾動滑鼠滾輪時\n施放增益。";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "向後滾動滑鼠滾輪時\n施放增益。";
SMARTBUFF_OFTT_SCROLLZOOMING = "啟用時，滾輪增益時一律縮放鏡頭。\n停用時（預設），僅在沒有可增益內容時縮放\n（滾輪仍會增益；空滾動正常縮放）。";
SMARTBUFF_OFTT_TARGETSWITCH  = "切換目標時施放增益。";
SMARTBUFF_OFTT_BUFFTARGET    = "若目前目標為友方，\n優先對其增益。";
SMARTBUFF_OFTT_BUFFPVP       = "增益已開啟 PvP 的玩家，\n即使你未開啟 PvP。";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "依隊伍/副本類型自動切換範本：\n單人、小隊（含5人副本）、團隊、戰場、競技場。";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "進入對應副本時也切換到命名團隊範本\n（必須與 GetInstanceInfo 名稱一致）。";
SMARTBUFF_OFTT_CHECKCHARGES  = "顯示增益剩餘次數過低。\n0 = 停用";
SMARTBUFF_OFTT_BUFFINCITIES  = "在主城也增益。\n若你開啟了 PvP，則無論如何都會增益。";
SMARTBUFF_OFTT_BLDURATION    = "玩家被封鎖的秒數。\n0 = 停用";
SMARTBUFF_OFTT_ANTIDAZE      = "有人暈眩時自動取消\n獵豹/豹群守護\n（自己或小隊）。";
SMARTBUFF_OFTT_SPLASHSTYLE   = "更改增益訊息的字型樣式。";
SMARTBUFF_OFTT_HIDESABUTTON  = "隱藏 SmartBuff 動作按鈕。";
SMARTBUFF_OFTT_HIDEIFIDLE    = "佇列為空時隱藏動作按鈕；有待施放增益時顯示。";
SMARTBUFF_OFTT_RETAINTEMPLATE = "切換到全新範本（從未使用或未啟用任何增益）時，\n若勾選則會將目前增益設定複製過去。\n空白範本不會被覆蓋，因此不會誤改已設定的範本。";
SMARTBUFF_OFTT_INCOMBAT      = "標記為「戰鬥中」的增益（在各增益選項中）會**僅一次**盡力\n依序列施放——開戰時一次，若仍在戰鬥則戰鬥復活後再一次。\n戰鬥中停用一般增益邏輯！\n不要加入有冷卻的戰鬥法術——會打斷序列。";
SMARTBUFF_OFTT_SMARTDEBUFF   = "顯示 SmartDebuff 框架。";
SMARTBUFF_OFTT_SPLASHDURATION= "螢幕提示顯示多少秒後消失。";
SMARTBUFF_OFTT_INSHAPESHIFT  = "變身狀態下也施放增益。";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "檢查是否已有其他職業\n效果相似的增益處於作用中。";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "檢查自身增益是否作用中，\n同一時間只能有一個作用。";
SMARTBUFF_OFTT_SOUNDSELECT   = "選擇螢幕提醒音效。\n包含 SmartBuff 內建音效以及透過\nLibSharedMedia 註冊的音效（如其他插件）。";
SMARTBUFF_OFTT_PLAYSOUND     = "由音效音量控制。";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "僅自己";
SMARTBUFF_BST_SELFNOT        = "不包括自己";
SMARTBUFF_BST_COMBATIN       = "戰鬥中";
SMARTBUFF_BST_COMBATOUT      = "非戰鬥";
SMARTBUFF_BST_MAINHAND       = "主手";
SMARTBUFF_BST_OFFHAND        = "副手";
SMARTBUFF_BST_RANGED         = "遠程";
SMARTBUFF_BST_REMINDER       = "通知";
SMARTBUFF_BST_MANALIMIT      = "下限";
SMARTBUFF_BST_SKIPBGRES      = "戰場中排除";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "僅增益你的角色。";
SMARTBUFF_BSTT_SELFNOT       = "增益所有其他已選職業，\n不包括你的角色。";
SMARTBUFF_BSTT_SINGLETARGET  = "對於單體增益（大地之盾、靈魂石等），優先使用職責篩選（如坦克）而非職業。";
SMARTBUFF_BSTT_COMBATIN      = "將此增益加入戰鬥序列（僅當主「戰鬥中」選項開啟時）。\n避免有冷卻的法術——會打斷序列。";
SMARTBUFF_BSTT_COMBATOUT     = "非戰鬥時增益。";
SMARTBUFF_BSTT_MAINHAND      = "增益主手。";
SMARTBUFF_BSTT_OFFHAND       = "增益副手。";
SMARTBUFF_BSTT_RANGED        = "增益遠程欄位。";
SMARTBUFF_BSTT_REMINDER      = "顯示提醒訊息。";
SMARTBUFF_BSTT_REBUFFTIMER   = "增益到期前多少秒提醒。\n0 = 使用全域重新增益計時";
SMARTBUFF_BSTT_MANALIMIT     = "法力/怒氣/能量閾值。\n低於此值不施放該增益。";
SMARTBUFF_BSTT_SKIPBGRES    = "若勾選，戰場或競技場復活後不會將該法術加入施放佇列。";
SMARTBUFF_BSTT_ADDLIST       = "附加列表：新增即使不符合職業/職責篩選也應獲得此增益的玩家。選取小隊/團隊成員並點擊 + 新增。";
SMARTBUFF_BSTT_IGNORELIST    = "忽略列表：排除即使符合職業/職責篩選也不應獲得此增益的玩家。選取小隊/團隊成員並點擊 + 新增。";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "最小化/最大化\n主選項視窗";
SMARTBUFF_PSTT_ADD           = "將目前目標加入此列表。目標必須在小隊或團隊中。";
SMARTBUFF_PSTT_REMOVE        = "從此列表移除所選玩家。";
SMARTBUFF_PSTT_UP            = "將所選項目在列表中上移。";
SMARTBUFF_PSTT_DOWN          = "將所選項目在列表中下移。";
SMARTBUFF_PSTT_CLEAR         = "清除此列表中的全部項目。";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "開啟團隊增益設定說明";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffff團隊增益設定|r\n\n"
  .."|cffffffff職責與職業|r\n"
  .."職業是角色身分（戰士、法師、牧師等）。職責是其扮演的角色（坦克、治療、傷害）。\n\n"
  .."|cffffffff單體增益|r\n"
  .."有些增益（大地之盾、靈魂石等）同一時間只能存在於一人身上。SmartBuff 會將其標記為單體。\n\n"
  .."只要任何符合條件的隊友已有你的增益，增益就不會轉移。有人擁有後，SmartBuff 會保留到過期或離開。對此類增益優先選職責（如坦克）而非職業。\n\n"
  .."|cffffffff附加與忽略列表|r\n"
  .."這些列表會覆蓋職業/職責。選取小隊或團隊成員並點擊 + 新增。選取項目點擊 - 移除。點擊 c 清空列表。\n\n"
  .."附加列表：即使不符合職業/職責核取方塊也增益這些玩家（或 NPC）。\n"
  .."忽略列表：即使符合也不增益這些玩家。列表優先於核取方塊。\n\n"
  .."|cffffffff必須選擇某項|r\n"
  .."至少一個職業或職責核取方塊必須勾選。否則增益不會給任何人（除非在附加列表中）。\n\n"
  .."|cffffffff職責僅在組隊時有效|r\n"
  .."坦克、治療和傷害篩選僅在小隊或團隊中生效。單人時無效。";

-- Messages
SMARTBUFF_MSG_LOADED         = "已載入。請在 Curse 回報問題，或加入 Discord：discord.gg/R6EkZ94TKK。";
SMARTBUFF_NOTINTENDEDCLIENT  = "此 Forever 版 SmartBuff 不適用於目前用戶端。請使用對應的 Classic Era / 正式服版本。";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff 有新版本可用，你正在使用 |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff 修訂號 |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff 現已可下載。加入 Discord 取得最新資訊：https://discord.gg/R6EkZ94TKK。";
SMARTBUFF_MSG_DISABLED       = "SmartBuff 已停用！";
SMARTBUFF_MSG_SUBGROUP       = "你已加入新的小隊，請檢查選項！";
SMARTBUFF_MSG_NOTHINGTODO    = "無需操作";
SMARTBUFF_MSG_BUFFED         = "已增益";
SMARTBUFF_MSG_OOR            = "超出增益範圍！";
--SMARTBUFF_MSG_CD             = "冷卻中！";
SMARTBUFF_MSG_CD             = "公共冷卻中！";
SMARTBUFF_MSG_CHAT           = "聊天模式下不可用！";
SMARTBUFF_MSG_SHAPESHIFT     = "變身狀態下不允許施法！";
SMARTBUFF_MSG_NOACTIONSLOT   = "需要動作列空位才能正常運作！";
SMARTBUFF_MSG_GROUP          = "小隊";
SMARTBUFF_MSG_NEEDS          = "需要";
SMARTBUFF_MSG_OOM            = "法力/怒氣/能量不足！";
SMARTBUFF_MSG_STOCK          = "目前庫存";
SMARTBUFF_MSG_NOREAGENT      = "缺少材料：";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff 偵測到你需要 %s，但背包已滿。";
SMARTBUFF_MSG_DEACTIVATED    = "已停用！";
SMARTBUFF_MSG_REBUFF         = "重新增益";
SMARTBUFF_MSG_LEFT           = "剩餘";
SMARTBUFF_MSG_CLASS          = "職業";
SMARTBUFF_MSG_CHARGES        = "次數";
SMARTBUFF_MSG_SOUNDS         = "螢幕提示音效選擇："
SMARTBUFF_MSG_SPECCHANGED    = "天賦已變更（%s），正在載入增益範本...";
SMARTBUFF_OFT_TALENTGROUP    = "天賦群組 %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "戰士，近戰職業，通常需要力量或王者。";
SMARTBUFF_PA_HINT_PALADIN    = "聖騎士，根據專精可以從你的任何祝福中受益。";
SMARTBUFF_PA_HINT_HUNTER     = "獵人，近戰職業，通常需要力量或王者。";
SMARTBUFF_PA_HINT_ROGUE      = "盜賊，近戰職業，通常需要力量或王者。";
SMARTBUFF_PA_HINT_PRIEST     = "牧師，牧師適合智慧或王者。";
SMARTBUFF_PA_HINT_SHAMAN     = "薩滿，根據專精可以從你的任何祝福中受益。";
SMARTBUFF_PA_HINT_MAGE       = "法師，通常是王者或智慧。";
SMARTBUFF_PA_HINT_WARLOCK    = "術士，通常是王者或智慧。";
SMARTBUFF_PA_HINT_DRUID      = "德魯伊，根據專精可以從你的任何祝福中受益。";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "戰鬥中提醒我的祝福";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "在戰鬥中，如果你被分配的光環或祝福缺失或即將到期，會提醒你。";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "由於 API 限制，增益僅在準備階段有效，比賽開始後將停用。";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = "（戰鬥中）";

-- Support
SMARTBUFF_MINIMAP_TT         = "左鍵：選項選單\n右鍵：開/關\nShift+左鍵：聖騎士分配\nAlt+左鍵：SmartDebuff\n拖曳：移動按鈕";
SMARTBUFF_TITAN_TT           = "左鍵：開啟選項\n右鍵：開/關\nAlt+左鍵：SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\n左鍵：開啟選項\nShift+左鍵：開/關\nAlt+左鍵：SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift+左鍵拖曳：移動框架\n|cff20d2ff- S 按鈕 -|r\n左鍵：依職業顯示\nShift+左鍵：職業顏色\nAlt+左鍵：突顯左/右\n|cff20d2ff- P 按鈕 -|r\n左鍵：顯示/隱藏寵物";
