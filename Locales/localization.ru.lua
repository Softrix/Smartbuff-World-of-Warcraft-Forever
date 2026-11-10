-------------------------------------------------------------------------------
-- Russian localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "ruRU") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         Что нового:|r\n\n"
  .."          Изменения в r1.101126:\n\n"
  .."             * Добавлен отсутствующий инкуб чернокнижника.\n"
  .."             * Исправлены напоминания о пищевых баффах.\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic: Codermik, MrWizard &\n"
  .."Speedwaystar. Присоединяйтесь и получайте поддержку\n"
  .."на моём Discord-сервере:\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffЕсли хотите поддержать разработку аддона, всегда скачивайте с Curse или используйте одну из ссылок:\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffffОригинальный автор: Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Кинжалы", "Топоры", "Мечи", "Дробящее", "Посохи", "Кистевое оружие", "Древковое оружие", "Метательное оружие", "Арбалеты", "Луки", "Щиты", "Огнестрельное"};
SMARTBUFF_WEAPON_BLUNT = {"Дробящее", "Посохи", "Кистевое оружие"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "грузил";
SMARTBUFF_WEAPON_SHARP = {"Кинжалы", "Топоры", "Мечи", "Древковое оружие"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "точильн";

-- Creature types
SMARTBUFF_HUMANOID  = "Гуманоид";
SMARTBUFF_DEMON     = "Демон";
SMARTBUFF_BEAST     = "Животное";
SMARTBUFF_ELEMENTAL = "Элементаль";
SMARTBUFF_DEMONTYPE = "Бес";
SMARTBUFF_UNDEAD    = "Нежить";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"Друид", "Охотник", "Маг", "Паладин", "Жрец", "Разбойник", "Шаман", "Чернокнижник", "Воин", "Питомец охотника", "Питомца чернокнижника", "Танк", "Целитель", "Боец"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"Соло", "Группа", "LFG", "Рейд", "Поле боя", "Арена"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "Огненные Недра",
  "Логово Ониксии",
  "Зул'Гуруб",
  "Логово Крыла Тьмы",
  "Руины Ан'Киража",
  "Храм Ан'Киража",
  "Наксрамас",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"Свой 1", "Свой 2", "Свой 3", "Свой 4", "Свой 5"};

-- Mount
SMARTBUFF_MOUNT = "Увеличивает скорость на (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d з";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Запуск";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Цель";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Меню настроек";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Сбросить таймеры баффов";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "Исправить применение"
SMARTBUFF_OFTT_FIXBUFF       = "Включено по умолчанию. Заставляет кнопку действия SmartBuff корректно\nреагировать на клики, макросы и колесо без изменения глобальной\nCVar ActionButtonUseKeyDown (использует атрибут useOnKeyDown кнопки).\nБафф в бою при этом всё ещё может быть ограничен."

SMARTBUFF_OFT                = "SmartBuff Вкл/Выкл";
SMARTBUFF_OFT_MENU           = "Показать/скрыть меню настроек";
SMARTBUFF_OFT_AUTO           = "Напоминание";
SMARTBUFF_OFT_AUTOTIMER      = "Интервал проверки";
SMARTBUFF_OFT_AUTOCOMBAT     = "в бою";
SMARTBUFF_OFT_AUTOCHAT       = "Чат";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Звук";
SMARTBUFF_OFT_SELECTSOUND    = "Выбрать звук";
SMARTBUFF_OFT_AUTOREST       = "Отключить в городах";
SMARTBUFF_OFT_HUNTERPETS     = "Баффать питомцев охотника";
SMARTBUFF_OFT_WARLOCKPETS    = "Баффать питомцев чернокнижника";
SMARTBUFF_OFT_ARULES         = "Расширенные правила";
SMARTBUFF_OFT_BUFFS          = "Баффы/Способности";
SMARTBUFF_OFT_TARGET         = "Баффать выбранную цель";
SMARTBUFF_OFT_DONE           = "Закрыть";
SMARTBUFF_OFT_APPLY          = "Применить";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Размер класса";
SMARTBUFF_OFT_MESSAGES       = "Отключить сообщения";
SMARTBUFF_OFT_MSGNORMAL      = "обычные";
SMARTBUFF_OFT_MSGWARNING     = "предупреждения";
SMARTBUFF_OFT_MSGERROR       = "ошибки";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Скрыть кнопку миникарты";
SMARTBUFF_OFT_INCLUDETOYS    = "Включать игрушки";
SMARTBUFF_OFT_REBUFFTIMER    = "Таймер ребаффа";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Смена шаблона";
SMARTBUFF_OFT_SELFFIRST      = "Сначала себя";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Бафф при прокрутке вверх";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "вниз";
SMARTBUFF_OFT_SCROLLZOOMING  = "Зум";
SMARTBUFF_OFT_TARGETSWITCH   = "смена цели";
SMARTBUFF_OFT_BUFFTARGET     = "Баффать цель";
SMARTBUFF_OFT_BUFFPVP        = "Баффать PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Подземелья";
SMARTBUFF_OFT_CHECKCHARGES   = "Проверять заряды";
SMARTBUFF_OFT_RBT            = "Сбросить таймеры";
SMARTBUFF_OFT_BUFFINCITIES   = "Баффать в городах";
SMARTBUFF_OFT_BLDURATION     = "Заблокировано";
SMARTBUFF_OFT_ANTIDAZE       = "Анти-оглушение";
SMARTBUFF_OFT_HIDESABUTTON   = "Скрыть кнопку действия";
SMARTBUFF_OFT_HIDEIFIDLE     = "Скрывать в простое";
SMARTBUFF_OFT_RETAINTEMPLATE = "Сохранять";
SMARTBUFF_OFT_INCOMBAT       = "в бою";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Облик";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Связь группы";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Связь себя";
SMARTBUFF_OFT_RESETALL       = "Сбросить всё";
SMARTBUFF_OFT_RESETLIST      = "Сбросить список";
SMARTBUFF_OFT_RESETBUFFS     = "Сбросить баффы";
SMARTBUFF_OFT_NEWS           = "Изменения";
SMARTBUFF_OFT_PURGE_BUFFS    = "Новая версия, сбросить ВСЕ данные баффов SmartBuff?\nЭто сбросит все профили баффов!";
SMARTBUFF_OFT_YES            = "Да";
SMARTBUFF_OFT_NO             = "Нет";
SMARTBUFF_OFT_OKAY           = "Продолжить"
SMARTBUFF_OFT_PURGE_DATA     = "Новая версия, сбросить ВСЕ данные SmartBuff?\nЭто принудительно перезагрузит UI!";
SMARTBUFF_OFT_REQ_RELOAD     = "Новые версии требуют перезагрузки интерфейса.\nНажмите «Продолжить», когда будете готовы.";
SMARTBUFF_OFT_SPLASHICON     = "Показать значок";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Короткое сообщение";
SMARTBUFF_OFT_FONTSTYLE      = "Шрифт";
SMARTBUFF_OFT_FONTSIZE       = "Размер шрифта";
SMARTBUFF_OFT_ICONSIZE       = "Размер значка";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Включает/выключает SmartBuff";
SMARTBUFF_OFTT_RBT           = "Сбросить таймеры: очистить только таймеры баффов (runtime; без сохранённых переменных).";
SMARTBUFF_OFTT_RESETALL      = "Сбросить всё: удалить всё (профили + настройки). Требует ReloadUI.";
SMARTBUFF_OFTT_RESETBUFFS    = "Сбросить баффы: вернуть баффы и профили к значениям по умолчанию.";
SMARTBUFF_OFTT_RESETLIST     = "Сбросить список: сбросить только порядок баффов.";
SMARTBUFF_OFTT_DONE          = "Закрыть настройки.";
SMARTBUFF_OFTT_NEWS          = "Посмотреть заметки о выпуске и список изменений.";
SMARTBUFF_OFTT_HELPLATE_RESET = "Кнопки сброса (наведите для подробностей)";
SMARTBUFF_OFTT_AUTO          = "Включает/выключает напоминание о баффах";
SMARTBUFF_OFTT_AUTOTIMER     = "Задержка в секундах между двумя проверками.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Выполнять проверку также в бою.\nВся логика напоминаний отключена в бою, если не включена основная опция «в бою» (в окне настроек, не эта).";
SMARTBUFF_OFTT_AUTOCHAT      = "Показывает отсутствующие баффы сообщением в чате.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Показывает отсутствующие баффы splash-сообщением\nв центре экрана.";
SMARTBUFF_OFTT_AUTOSOUND     = "Воспроизводит звук, если баффы отсутствуют.";
SMARTBUFF_OFTT_AUTOREST      = "Отключить напоминание в столицах";
SMARTBUFF_OFTT_HUNTERPETS    = "Также баффать питомцев охотника.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Также баффать питомцев чернокнижника, кроме " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Не применяет:\n- Шипы на магов, жрецов и чернокнижников\n- Чародейский интеллект на цели без маны\n- Божественный дух на цели без маны";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Скрывает кнопку SmartBuff на миникарте.";
SMARTBUFF_OFTT_INCLUDETOYS   = "Включать игрушки в список вместе со заклинаниями и едой.";
SMARTBUFF_OFTT_REBUFFTIMER   = "За сколько секунд до окончания баффа\nнапоминание должно предупредить.\n0 = Отключено";
SMARTBUFF_OFTT_SELFFIRST     = "Сначала баффать вашего персонажа.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Применять баффы при прокрутке\nколеса вперёд.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Применять баффы при прокрутке\nколеса назад.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Если включено — всегда зумить камеру при баффе колесом.\nЕсли выключено (по умолчанию) — зумить только когда больше нечего баффать\n(колесо всё равно баффает; пустые прокрутки зумят как обычно).";
SMARTBUFF_OFTT_TARGETSWITCH  = "Применять баффы при смене цели.";
SMARTBUFF_OFTT_BUFFTARGET    = "Сначала баффать текущую цель,\nесли она дружественная.";
SMARTBUFF_OFTT_BUFFPVP       = "Баффать игроков с меткой PvP,\nдаже если у вас её нет.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Автоматически переключает шаблон по типу группы/инстанса:\nСоло, Группа (также 5-чел. подземелья), Рейд, Поле боя, Арена.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Также переключаться на именованный рейдовый шаблон при\nвходе в этот инстанс (должно совпадать с именем GetInstanceInfo).";
SMARTBUFF_OFTT_CHECKCHARGES  = "Показывает малое количество\nзарядов на баффе.\n0 = Отключено";
SMARTBUFF_OFTT_BUFFINCITIES  = "Баффать также в столицах.\nЕсли у вас метка PvP — баффает в любом случае.";
SMARTBUFF_OFTT_BLDURATION    = "Сколько секунд игроки будут заблокированы.\n0 = Отключено";
SMARTBUFF_OFTT_ANTIDAZE      = "Автоматически отменяет\nаспект гепарда/стаи,\nесли кого-то оглушило\n(вас или группу).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Меняет стиль шрифта\nсообщений о баффах.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Скрывает кнопку действия SmartBuff.";
SMARTBUFF_OFTT_HIDEIFIDLE    = "Скрывать кнопку действия, когда очередь пуста; показывать, когда бафф ожидает.";
SMARTBUFF_OFTT_RETAINTEMPLATE = "При переключении на новый шаблон (никогда не использовался или нет включённых баффов)\nтекущие настройки баффов будут скопированы, если отмечено.\nПустые шаблоны никогда не перезаписываются, так что вы не сотрёте настроенный шаблон случайно.";
SMARTBUFF_OFTT_INCOMBAT      = "Баффы, отмеченные «в бою» (в настройках баффа), применяются **ОДИН РАЗ** в\nпоследовательности по возможности — при начале боя и снова после воскрешения в бою, если бой продолжается.\nОбычная логика баффов в бою отключена!\nНе добавляйте боевые заклинания с кулдаунами — они ломают последовательность.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Показывает окно SmartDebuff.";
SMARTBUFF_OFTT_SPLASHDURATION= "Сколько секунд отображается splash-\nсообщение, прежде чем исчезнет.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Применять баффы также\nв облике.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Проверяет, активен ли уже бафф\nдругого класса с похожим эффектом.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Проверяет, активен ли личный бафф,\nиз которых одновременно может быть\nтолько один.";
SMARTBUFF_OFTT_SOUNDSELECT   = "Выберите звук splash-напоминания.\nВключает звуки SmartBuff и любые звуки,\nзарегистрированные через LibSharedMedia (напр. из других аддонов).";
SMARTBUFF_OFTT_PLAYSOUND     = "Управляется громкостью звуковых эффектов.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Только я";
SMARTBUFF_BST_SELFNOT        = "Не я";
SMARTBUFF_BST_COMBATIN       = "В бою";
SMARTBUFF_BST_COMBATOUT      = "Вне боя";
SMARTBUFF_BST_MAINHAND       = "Правая рука";
SMARTBUFF_BST_OFFHAND        = "Левая рука";
SMARTBUFF_BST_RANGED         = "Дальний бой";
SMARTBUFF_BST_REMINDER       = "Уведомление";
SMARTBUFF_BST_MANALIMIT      = "Нижний порог";
SMARTBUFF_BST_SKIPBGRES      = "Исключить на ПБ";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Баффать только вашего персонажа.";
SMARTBUFF_BSTT_SELFNOT       = "Баффать все остальные выбранные классы,\nкроме вашего персонажа.";
SMARTBUFF_BSTT_SINGLETARGET  = "Для одиночных баффов (Щит земли, Камень души и т.д.) предпочитайте фильтр роли (напр. ТАНК), а не класс.";
SMARTBUFF_BSTT_COMBATIN      = "Включить этот бафф в боевую последовательность (только если включена основная опция «в бою»).\nИзбегайте заклинаний с кулдаунами — они ломают последовательность.";
SMARTBUFF_BSTT_COMBATOUT     = "Баффать вне боя.";
SMARTBUFF_BSTT_MAINHAND      = "Баффать правую руку.";
SMARTBUFF_BSTT_OFFHAND       = "Баффать левую руку.";
SMARTBUFF_BSTT_RANGED        = "Баффать слот дальнего боя.";
SMARTBUFF_BSTT_REMINDER      = "Показывать сообщение-напоминание.";
SMARTBUFF_BSTT_REBUFFTIMER   = "За сколько секунд до окончания баффа\nнапоминание должно предупредить.\n0 = глобальный таймер ребаффа";
SMARTBUFF_BSTT_MANALIMIT     = "Порог маны/ярости/энергии.\nНиже этого значения бафф не применяется.";
SMARTBUFF_BSTT_SKIPBGRES    = "Если отмечено, это заклинание не добавляется в очередь после воскрешения на поле боя или арене.";
SMARTBUFF_BSTT_ADDLIST       = "Доп. список: добавьте игроков, которые должны получать этот бафф даже если не подходят под фильтр класса/роли. Выберите участника группы/рейда и нажмите +, чтобы добавить.";
SMARTBUFF_BSTT_IGNORELIST    = "Список игнора: исключите игроков из этого баффа даже если они подходят под фильтр класса/роли. Выберите участника группы/рейда и нажмите +, чтобы добавить.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Свернуть/развернуть\nглавное окно настроек";
SMARTBUFF_PSTT_ADD           = "Добавить текущую цель в этот список. Цель должна быть в группе или рейде.";
SMARTBUFF_PSTT_REMOVE        = "Удалить выбранного игрока из этого списка.";
SMARTBUFF_PSTT_UP            = "Переместить выбор вверх по списку.";
SMARTBUFF_PSTT_DOWN          = "Переместить выбор вниз по списку.";
SMARTBUFF_PSTT_CLEAR         = "Очистить все записи в этом списке.";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "Открыть справку по настройке групповых баффов";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffffНастройка групповых баффов|r\n\n"
  .."|cffffffffРоль и класс|r\n"
  .."Класс — кто человек (воин, маг, жрец и т.д.). Роль — что он делает (танк, целитель, урон).\n\n"
  .."|cffffffffОдиночные баффы|r\n"
  .."Некоторые баффы (Щит земли, Камень души и т.д.) могут быть только на одном человеке. SmartBuff помечает их как одиночные.\n\n"
  .."Бафф не перескакивает, пока любой подходящий участник группы уже имеет ваш бафф. Когда подходящий игрок его имеет, SmartBuff оставляет его до истечения или ухода. Для таких баффов предпочитайте роль (напр. Танк), а не класс.\n\n"
  .."|cffffffffДоп. список и игнор|r\n"
  .."Эти списки перекрывают класс/роль. Выберите участника группы или рейда и нажмите +, чтобы добавить. Выберите запись и - чтобы удалить. Нажмите c, чтобы очистить список.\n\n"
  .."Доп. список: баффать этих игроков (или NPC), даже если они не совпадают с галочками класса/роли.\n"
  .."Список игнора: не баффать этих игроков, даже если совпадают. Списки важнее галочек.\n\n"
  .."|cffffffffНужно что-то выбрать|r\n"
  .."Должна быть отмечена хотя бы одна галочка класса или роли. Иначе бафф никому не пойдёт (кроме доп. списка).\n\n"
  .."|cffffffffРоли важны только в группах|r\n"
  .."Фильтры Танк, Целитель и Урон работают только в группе или рейде. В соло они не действуют.";

-- Messages
SMARTBUFF_MSG_LOADED         = "загружен. Сообщайте о проблемах на Curse или в Discord: discord.gg/R6EkZ94TKK.";
SMARTBUFF_NOTINTENDEDCLIENT  = "Эта версия Forever SmartBuff не предназначена для этого клиента. Используйте соответствующий пакет Classic Era / Retail.";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff Доступна новая версия, вы используете |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff и ревизию |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff доступна для скачивания. Присоединяйтесь к Discord за свежей информацией: https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "SmartBuff отключён!";
SMARTBUFF_MSG_SUBGROUP       = "Вы присоединились к новой подгруппе, проверьте настройки!";
SMARTBUFF_MSG_NOTHINGTODO    = "Нечего делать";
SMARTBUFF_MSG_BUFFED         = "забаффан";
SMARTBUFF_MSG_OOR            = "вне зоны действия баффа!";
--SMARTBUFF_MSG_CD             = "на перезарядке!";
SMARTBUFF_MSG_CD             = "Общая перезарядка!";
SMARTBUFF_MSG_CHAT           = "невозможно в режиме чата!";
SMARTBUFF_MSG_SHAPESHIFT     = "Применение в облике запрещено!";
SMARTBUFF_MSG_NOACTIONSLOT   = "нужен слот на панели действий для корректной работы!";
SMARTBUFF_MSG_GROUP          = "Группа";
SMARTBUFF_MSG_NEEDS          = "нуждается в";
SMARTBUFF_MSG_OOM            = "Недостаточно маны/ярости/энергии!";
SMARTBUFF_MSG_STOCK          = "Текущий запас";
SMARTBUFF_MSG_NOREAGENT      = "Нет реагента:";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff определил, что вам нужен %s, но сумки полны.";
SMARTBUFF_MSG_DEACTIVATED    = "отключено!";
SMARTBUFF_MSG_REBUFF         = "Ребафф";
SMARTBUFF_MSG_LEFT           = "осталось";
SMARTBUFF_MSG_CLASS          = "Класс";
SMARTBUFF_MSG_CHARGES        = "заряды";
SMARTBUFF_MSG_SOUNDS         = "Выбор splash-звука: "
SMARTBUFF_MSG_SPECCHANGED    = "Специализация изменена (%s), загрузка шаблонов баффов...";
SMARTBUFF_OFT_TALENTGROUP    = "Группа талантов %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "Воин, класс ближнего боя, которому обычно нужны Могущество или Короли.";
SMARTBUFF_PA_HINT_PALADIN    = "Паладин, в зависимости от специализации им подходит любое из твоих благословений.";
SMARTBUFF_PA_HINT_HUNTER     = "Охотник, класс ближнего боя, которому обычно нужны Могущество или Короли.";
SMARTBUFF_PA_HINT_ROGUE      = "Разбойник, класс ближнего боя, которому обычно нужны Могущество или Короли.";
SMARTBUFF_PA_HINT_PRIEST     = "Жрец, жрецам подходят Мудрость или Короли.";
SMARTBUFF_PA_HINT_SHAMAN     = "Шаман, в зависимости от специализации им подходит любое из твоих благословений.";
SMARTBUFF_PA_HINT_MAGE       = "Маг, обычно Короли или Мудрость.";
SMARTBUFF_PA_HINT_WARLOCK    = "Чернокнижник, обычно Короли или Мудрость.";
SMARTBUFF_PA_HINT_DRUID      = "Друид, в зависимости от специализации им подходит любое из твоих благословений.";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "Объявлять моё благословение в бою";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "В бою сообщает, если ваша назначенная аура или назначенное вам благословение отсутствует или скоро спадёт.";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "Из‑за ограничения API бафф работает только во время подготовки и отключается после начала матча.";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = " (в бою)";

-- Support
SMARTBUFF_MINIMAP_TT         = "ЛКМ: меню настроек\nПКМ: Вкл/Выкл\nShift-ЛКМ: назначения паладина\nAlt-ЛКМ: SmartDebuff\nПеретаскивание: переместить кнопку";
SMARTBUFF_TITAN_TT           = "ЛКМ: открыть настройки\nПКМ: Вкл/Выкл\nAlt-ЛКМ: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nЛКМ: открыть настройки\nShift-ЛКМ: Вкл/Выкл\nAlt-ЛКМ: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-ЛКМ перетаскивание: переместить окно\n|cff20d2ff- Кнопка S -|r\nЛКМ: показ по классам\nShift-ЛКМ: цвета классов\nAlt-ЛКМ: подсветка Л/П\n|cff20d2ff- Кнопка P -|r\nЛКМ: скрыть/показать питомцев";
