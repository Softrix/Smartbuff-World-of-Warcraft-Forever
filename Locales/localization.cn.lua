-------------------------------------------------------------------------------
-- Simplified Chinese localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "zhCN") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         更新内容：|r\n\n"
  .."          r1.101126 变更：\n\n"
  .."             * 补充缺失的术士梦魔（Incubus）。\n"
  .."             * 修复食物增益提醒。\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic 由 Codermik、MrWizard &\n"
  .."Speedwaystar 制作。请加入 Discord 获取支持：\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffff若想支持本插件开发，请始终从 Curse 下载，或使用以下链接：\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffff原作者：Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"匕首", "斧", "剑", "锤", "法杖", "拳套", "长柄武器", "投掷武器", "弩", "弓", "盾牌", "枪械"};
SMARTBUFF_WEAPON_BLUNT = {"锤", "法杖", "拳套"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "平衡石$";
SMARTBUFF_WEAPON_SHARP = {"匕首", "斧", "剑", "长柄武器"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "磨刀石$";

-- Creature types
SMARTBUFF_HUMANOID  = "人型生物";
SMARTBUFF_DEMON     = "恶魔";
SMARTBUFF_BEAST     = "野兽";
SMARTBUFF_ELEMENTAL = "元素生物";
SMARTBUFF_DEMONTYPE = "小鬼";
SMARTBUFF_UNDEAD    = "亡灵";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"德鲁伊", "猎人", "法师", "圣骑士", "牧师", "潜行者", "萨满祭司", "术士", "战士", "猎人宠物", "术士宠物", "坦克", "治疗", "伤害输出"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"单人", "小队", "LFG", "团队", "战场", "竞技场"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "熔火之心",
  "奥妮克希亚的巢穴",
  "祖尔格拉布",
  "黑翼之巢",
  "安其拉废墟",
  "安其拉神殿",
  "纳克萨玛斯",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"自定义 1", "自定义 2", "自定义 3", "自定义 4", "自定义 5"};

-- Mount
SMARTBUFF_MOUNT = "速度提高(%d+)%%。";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d 次";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "触发";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "目标";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "选项菜单";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "重置增益计时器";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "修复施法"
SMARTBUFF_OFTT_FIXBUFF       = "默认启用。使 SmartBuff 动作按钮正确响应\n鼠标点击、宏和滚轮，而无需更改全局\nActionButtonUseKeyDown CVar（使用按钮的 useOnKeyDown 属性）。\n启用时，战斗中施放增益仍可能受限。"

SMARTBUFF_OFT                = "SmartBuff 开/关";
SMARTBUFF_OFT_MENU           = "显示/隐藏选项菜单";
SMARTBUFF_OFT_AUTO           = "提醒";
SMARTBUFF_OFT_AUTOTIMER      = "检查间隔";
SMARTBUFF_OFT_AUTOCOMBAT     = "战斗中";
SMARTBUFF_OFT_AUTOCHAT       = "聊天";
SMARTBUFF_OFT_AUTOSPLASH     = "屏幕提示";
SMARTBUFF_OFT_AUTOSOUND      = "声音";
SMARTBUFF_OFT_SELECTSOUND    = "选择声音";
SMARTBUFF_OFT_AUTOREST       = "在主城禁用";
SMARTBUFF_OFT_HUNTERPETS     = "增益猎人宠物";
SMARTBUFF_OFT_WARLOCKPETS    = "增益术士宠物";
SMARTBUFF_OFT_ARULES         = "高级规则";
SMARTBUFF_OFT_BUFFS          = "增益/技能";
SMARTBUFF_OFT_TARGET         = "增益当前选中目标";
SMARTBUFF_OFT_DONE           = "关闭";
SMARTBUFF_OFT_APPLY          = "应用";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "职业人数";
SMARTBUFF_OFT_MESSAGES       = "禁用消息";
SMARTBUFF_OFT_MSGNORMAL      = "普通";
SMARTBUFF_OFT_MSGWARNING     = "警告";
SMARTBUFF_OFT_MSGERROR       = "错误";
SMARTBUFF_OFT_HIDEMMBUTTON   = "隐藏小地图按钮";
SMARTBUFF_OFT_INCLUDETOYS    = "包含玩具";
SMARTBUFF_OFT_REBUFFTIMER    = "重新增益计时";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "切换模板";
SMARTBUFF_OFT_SELFFIRST      = "优先自己";
SMARTBUFF_OFT_SCROLLWHEELUP  = "滚轮向上增益";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "向下";
SMARTBUFF_OFT_SCROLLZOOMING  = "缩放";
SMARTBUFF_OFT_TARGETSWITCH   = "切换目标时";
SMARTBUFF_OFT_BUFFTARGET     = "增益目标";
SMARTBUFF_OFT_BUFFPVP        = "增益 PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "副本";
SMARTBUFF_OFT_CHECKCHARGES   = "检查次数";
SMARTBUFF_OFT_RBT            = "重置计时器";
SMARTBUFF_OFT_BUFFINCITIES   = "在主城增益";
SMARTBUFF_OFT_BLDURATION     = "已屏蔽";
SMARTBUFF_OFT_ANTIDAZE       = "防眩晕";
SMARTBUFF_OFT_HIDESABUTTON   = "隐藏动作按钮";
SMARTBUFF_OFT_HIDEIFIDLE     = "空闲时隐藏";
SMARTBUFF_OFT_RETAINTEMPLATE = "保留";
SMARTBUFF_OFT_INCOMBAT       = "战斗中";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "变形";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "团队关联";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "自身关联";
SMARTBUFF_OFT_RESETALL       = "全部重置";
SMARTBUFF_OFT_RESETLIST      = "重置列表";
SMARTBUFF_OFT_RESETBUFFS     = "重置增益";
SMARTBUFF_OFT_NEWS           = "更新";
SMARTBUFF_OFT_PURGE_BUFFS    = "新版本，重置全部 SmartBuff 增益数据？\n这将重置所有增益配置！";
SMARTBUFF_OFT_YES            = "是";
SMARTBUFF_OFT_NO             = "否";
SMARTBUFF_OFT_OKAY           = "继续"
SMARTBUFF_OFT_PURGE_DATA     = "新版本，重置全部 SmartBuff 数据？\n此操作将强制重新加载界面！";
SMARTBUFF_OFT_REQ_RELOAD     = "新版本需要重新加载界面。\n准备好后请点击继续。";
SMARTBUFF_OFT_SPLASHICON     = "显示图标";
SMARTBUFF_OFT_SPLASHMSGSHORT = "短消息";
SMARTBUFF_OFT_FONTSTYLE      = "字体";
SMARTBUFF_OFT_FONTSIZE       = "字体大小";
SMARTBUFF_OFT_ICONSIZE       = "图标大小";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "开关 SmartBuff";
SMARTBUFF_OFTT_RBT           = "重置计时器：仅清除增益计时器（运行时；不改保存变量）。";
SMARTBUFF_OFTT_RESETALL      = "全部重置：清除所有内容（配置 + 选项）。需要 ReloadUI。";
SMARTBUFF_OFTT_RESETBUFFS    = "重置增益：将增益与配置恢复为默认。";
SMARTBUFF_OFTT_RESETLIST     = "重置列表：仅重置增益顺序。";
SMARTBUFF_OFTT_DONE          = "关闭选项。";
SMARTBUFF_OFTT_NEWS          = "查看版本说明与更新日志。";
SMARTBUFF_OFTT_HELPLATE_RESET = "重置按钮（悬停查看详情）";
SMARTBUFF_OFTT_AUTO          = "开关增益提醒";
SMARTBUFF_OFTT_AUTOTIMER     = "两次检查之间的秒数延迟。";
SMARTBUFF_OFTT_AUTOCOMBAT    = "战斗中也执行检查。\n除非启用主选项中的“战斗中”（选项窗口内，而非此项），否则战斗中所有提醒逻辑都会禁用。";
SMARTBUFF_OFTT_AUTOCHAT      = "以聊天消息显示缺失增益。";
SMARTBUFF_OFTT_AUTOSPLASH    = "在屏幕中央以提示消息\n显示缺失增益。";
SMARTBUFF_OFTT_AUTOSOUND     = "缺少增益时播放声音。";
SMARTBUFF_OFTT_AUTOREST      = "在主城禁用提醒";
SMARTBUFF_OFTT_HUNTERPETS    = "同样增益猎人宠物。";
SMARTBUFF_OFTT_WARLOCKPETS   = "同样增益术士宠物，但排除" .. SMARTBUFF_DEMONTYPE .. "。";
SMARTBUFF_OFTT_ARULES        = "不施放：\n- 对法师、牧师和术士施放荆棘术\n- 对无法力单位施放奥术智慧\n- 对无法力单位施放神圣之灵";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "隐藏 SmartBuff 小地图按钮。";
SMARTBUFF_OFTT_INCLUDETOYS   = "在列表中包含玩具，与法术和食物一起。";
SMARTBUFF_OFTT_REBUFFTIMER   = "增益到期前多少秒\n提醒应发出警告。\n0 = 禁用";
SMARTBUFF_OFTT_SELFFIRST     = "优先增益你的角色。";
SMARTBUFF_OFTT_SCROLLWHEELUP = "向前滚动鼠标滚轮时\n施放增益。";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "向后滚动鼠标滚轮时\n施放增益。";
SMARTBUFF_OFTT_SCROLLZOOMING = "启用时，滚轮增益时始终缩放镜头。\n禁用时（默认），仅在没有可增益内容时缩放\n（滚轮仍会增益；空滚动正常缩放）。";
SMARTBUFF_OFTT_TARGETSWITCH  = "切换目标时施放增益。";
SMARTBUFF_OFTT_BUFFTARGET    = "若当前目标为友方，\n优先对其增益。";
SMARTBUFF_OFTT_BUFFPVP       = "增益已开启 PvP 的玩家，\n即使你未开启 PvP。";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "按队伍/副本类型自动切换模板：\n单人、小队（含5人副本）、团队、战场、竞技场。";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "进入对应副本时也切换到命名团队模板\n（必须与 GetInstanceInfo 名称一致）。";
SMARTBUFF_OFTT_CHECKCHARGES  = "显示增益剩余次数过低。\n0 = 禁用";
SMARTBUFF_OFTT_BUFFINCITIES  = "在主城也增益。\n若你开启了 PvP，则无论如何都会增益。";
SMARTBUFF_OFTT_BLDURATION    = "玩家被屏蔽的秒数。\n0 = 禁用";
SMARTBUFF_OFTT_ANTIDAZE      = "有人眩晕时自动取消\n猎豹/豹群守护\n（自己或小队）。";
SMARTBUFF_OFTT_SPLASHSTYLE   = "更改增益消息的字体样式。";
SMARTBUFF_OFTT_HIDESABUTTON  = "隐藏 SmartBuff 动作按钮。";
SMARTBUFF_OFTT_HIDEIFIDLE    = "队列为空时隐藏动作按钮；有待施放增益时显示。";
SMARTBUFF_OFTT_RETAINTEMPLATE = "切换到全新模板（从未使用或未启用任何增益）时，\n若勾选则会将当前增益设置复制过去。\n空白模板不会被覆盖，因此不会误改已配置的模板。";
SMARTBUFF_OFTT_INCOMBAT      = "标记为“战斗中”的增益（在各增益选项中）会**仅一次**尽力\n按序列施放——开战时一次，若仍在战斗则战斗复活后再一次。\n战斗中禁用常规增益逻辑！\n不要添加有冷却的战斗法术——会打断序列。";
SMARTBUFF_OFTT_SMARTDEBUFF   = "显示 SmartDebuff 框架。";
SMARTBUFF_OFTT_SPLASHDURATION= "屏幕提示显示多少秒后消失。";
SMARTBUFF_OFTT_INSHAPESHIFT  = "变形状态下也施放增益。";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "检查是否已有其他职业\n效果相似的增益处于激活。";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "检查自身增益是否激活，\n同一时间只能有一个激活。";
SMARTBUFF_OFTT_SOUNDSELECT   = "选择屏幕提醒声音。\n包含 SmartBuff 自带声音以及通过\nLibSharedMedia 注册的声音（如其他插件）。";
SMARTBUFF_OFTT_PLAYSOUND     = "由音效音量控制。";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "仅自己";
SMARTBUFF_BST_SELFNOT        = "不包括自己";
SMARTBUFF_BST_COMBATIN       = "战斗中";
SMARTBUFF_BST_COMBATOUT      = "非战斗";
SMARTBUFF_BST_MAINHAND       = "主手";
SMARTBUFF_BST_OFFHAND        = "副手";
SMARTBUFF_BST_RANGED         = "远程";
SMARTBUFF_BST_REMINDER       = "通知";
SMARTBUFF_BST_MANALIMIT      = "下限";
SMARTBUFF_BST_SKIPBGRES      = "战场中排除";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "仅增益你的角色。";
SMARTBUFF_BSTT_SELFNOT       = "增益所有其他已选职业，\n不包括你的角色。";
SMARTBUFF_BSTT_SINGLETARGET  = "对于单体增益（大地之盾、灵魂石等），优先使用职责筛选（如坦克）而非职业。";
SMARTBUFF_BSTT_COMBATIN      = "将此增益加入战斗序列（仅当主“战斗中”选项开启时）。\n避免有冷却的法术——会打断序列。";
SMARTBUFF_BSTT_COMBATOUT     = "非战斗时增益。";
SMARTBUFF_BSTT_MAINHAND      = "增益主手。";
SMARTBUFF_BSTT_OFFHAND       = "增益副手。";
SMARTBUFF_BSTT_RANGED        = "增益远程栏位。";
SMARTBUFF_BSTT_REMINDER      = "显示提醒消息。";
SMARTBUFF_BSTT_REBUFFTIMER   = "增益到期前多少秒提醒。\n0 = 使用全局重新增益计时";
SMARTBUFF_BSTT_MANALIMIT     = "法力/怒气/能量阈值。\n低于此值不施放该增益。";
SMARTBUFF_BSTT_SKIPBGRES    = "若勾选，战场或竞技场复活后不会将该法术加入施放队列。";
SMARTBUFF_BSTT_ADDLIST       = "附加列表：添加即使不符合职业/职责筛选也应获得此增益的玩家。选中小队/团队成员并点击 + 添加。";
SMARTBUFF_BSTT_IGNORELIST    = "忽略列表：排除即使符合职业/职责筛选也不应获得此增益的玩家。选中小队/团队成员并点击 + 添加。";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "最小化/最大化\n主选项窗口";
SMARTBUFF_PSTT_ADD           = "将当前目标加入此列表。目标必须在小队或团队中。";
SMARTBUFF_PSTT_REMOVE        = "从此列表移除所选玩家。";
SMARTBUFF_PSTT_UP            = "将所选项在列表中上移。";
SMARTBUFF_PSTT_DOWN          = "将所选项在列表中下移。";
SMARTBUFF_PSTT_CLEAR         = "清除此列表中的全部条目。";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "打开团队增益配置帮助";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffff团队增益配置|r\n\n"
  .."|cffffffff职责与职业|r\n"
  .."职业是角色身份（战士、法师、牧师等）。职责是其扮演的角色（坦克、治疗、伤害）。\n\n"
  .."|cffffffff单体增益|r\n"
  .."有些增益（大地之盾、灵魂石等）同一时间只能存在于一人身上。SmartBuff 会将其标记为单体。\n\n"
  .."只要任何符合条件的队友已有你的增益，增益就不会转移。有人拥有后，SmartBuff 会保留到过期或离开。对此类增益优先选职责（如坦克）而非职业。\n\n"
  .."|cffffffff附加与忽略列表|r\n"
  .."这些列表会覆盖职业/职责。选中小队或团队成员并点击 + 添加。选中条目点击 - 移除。点击 c 清空列表。\n\n"
  .."附加列表：即使不符合职业/职责复选框也增益这些玩家（或 NPC）。\n"
  .."忽略列表：即使符合也不增益这些玩家。列表优先于复选框。\n\n"
  .."|cffffffff必须选择某项|r\n"
  .."至少一个职业或职责复选框必须勾选。否则增益不会给任何人（除非在附加列表中）。\n\n"
  .."|cffffffff职责仅在组队时有效|r\n"
  .."坦克、治疗和伤害筛选仅在小队或团队中生效。单人时无效。";

-- Messages
SMARTBUFF_MSG_LOADED         = "已加载。请在 Curse 反馈问题，或加入 Discord：discord.gg/R6EkZ94TKK。";
SMARTBUFF_NOTINTENDEDCLIENT  = "此 Forever 版 SmartBuff 不适用于当前客户端。请使用对应的 Classic Era / 正式服版本。";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff 有新版本可用，你正在使用 |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff 修订号 |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff 现已可下载。加入 Discord 获取最新信息：https://discord.gg/R6EkZ94TKK。";
SMARTBUFF_MSG_DISABLED       = "SmartBuff 已禁用！";
SMARTBUFF_MSG_SUBGROUP       = "你已加入新的小队，请检查选项！";
SMARTBUFF_MSG_NOTHINGTODO    = "无需操作";
SMARTBUFF_MSG_BUFFED         = "已增益";
SMARTBUFF_MSG_OOR            = "超出增益范围！";
--SMARTBUFF_MSG_CD             = "冷却中！";
SMARTBUFF_MSG_CD             = "公共冷却中！";
SMARTBUFF_MSG_CHAT           = "聊天模式下不可用！";
SMARTBUFF_MSG_SHAPESHIFT     = "变形状态下不允许施法！";
SMARTBUFF_MSG_NOACTIONSLOT   = "需要动作条空位才能正常工作！";
SMARTBUFF_MSG_GROUP          = "小队";
SMARTBUFF_MSG_NEEDS          = "需要";
SMARTBUFF_MSG_OOM            = "法力/怒气/能量不足！";
SMARTBUFF_MSG_STOCK          = "当前库存";
SMARTBUFF_MSG_NOREAGENT      = "缺少材料：";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff 检测到你需要 %s，但背包已满。";
SMARTBUFF_MSG_DEACTIVATED    = "已停用！";
SMARTBUFF_MSG_REBUFF         = "重新增益";
SMARTBUFF_MSG_LEFT           = "剩余";
SMARTBUFF_MSG_CLASS          = "职业";
SMARTBUFF_MSG_CHARGES        = "次数";
SMARTBUFF_MSG_SOUNDS         = "屏幕提示声音选择："
SMARTBUFF_MSG_SPECCHANGED    = "天赋已更改（%s），正在加载增益模板...";
SMARTBUFF_OFT_TALENTGROUP    = "天赋组 %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "战士，近战职业，通常需要力量或王者。";
SMARTBUFF_PA_HINT_PALADIN    = "圣骑士，根据专精可以从你的任何祝福中受益。";
SMARTBUFF_PA_HINT_HUNTER     = "猎人，近战职业，通常需要力量或王者。";
SMARTBUFF_PA_HINT_ROGUE      = "盗贼，近战职业，通常需要力量或王者。";
SMARTBUFF_PA_HINT_PRIEST     = "牧师，牧师适合智慧或王者。";
SMARTBUFF_PA_HINT_SHAMAN     = "萨满，根据专精可以从你的任何祝福中受益。";
SMARTBUFF_PA_HINT_MAGE       = "法师，通常是王者或智慧。";
SMARTBUFF_PA_HINT_WARLOCK    = "术士，通常是王者或智慧。";
SMARTBUFF_PA_HINT_DRUID      = "德鲁伊，根据专精可以从你的任何祝福中受益。";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "战斗中提醒我的祝福";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "在战斗中，如果你被分配的光环或祝福缺失或即将到期，会提醒你。";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "由于 API 限制，增益仅在准备阶段有效，比赛开始后将禁用。";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = "（战斗中）";

-- Support
SMARTBUFF_MINIMAP_TT         = "左键：选项菜单\n右键：开/关\nShift+左键：圣骑士分配\nAlt+左键：SmartDebuff\n拖动：移动按钮";
SMARTBUFF_TITAN_TT           = "左键：打开选项\n右键：开/关\nAlt+左键：SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\n左键：打开选项\nShift+左键：开/关\nAlt+左键：SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift+左键拖动：移动框架\n|cff20d2ff- S 按钮 -|r\n左键：按职业显示\nShift+左键：职业颜色\nAlt+左键：高亮左/右\n|cff20d2ff- P 按钮 -|r\n左键：显示/隐藏宠物";
