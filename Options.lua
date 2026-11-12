-------------------------------------------------------------------------------
-- SmartBuff Options
-------------------------------------------------------------------------------

local SG = SMARTBUFF_GLOBALS;

-- Helper functions ---------------------------------------------------------------------------------------

function SMARTBUFF_ToggleBool(b, msg)
  if (not b or b == nil) then
    b = true;
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. SG.GR .. "On", true);
  else
    b = false
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. SG.RD .. "Off", true);
  end
  return b;
end


function SMARTBUFF_BoolState(b, msg)
  if (b) then
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. SG.GR .. "On", true);
  else
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. SG.RD .. "Off", true);
  end
end


function SMARTBUFF_Split(msg, char)
  local arr = {};
  while (string.find(msg, char)) do
    local iStart, iEnd = string.find(msg, char);
    tinsert(arr, strsub(msg, 1, iStart - 1));
    msg = strsub(msg, iEnd + 1, strlen(msg));
  end
  if (strlen(msg) > 0) then
    tinsert(arr, msg);
  end
  return arr;
end


-- END Bool helper functions


-- Init the SmartBuff variables ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_Init(self)
  if (SG.isInit) then return; end

  self:UnregisterEvent("CHAT_MSG_CHANNEL");
  self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");

  --DebugChatFrame:AddMessage("Starting init SB");

  _, SG.sPlayerClass = UnitClass("player");
  SG.sRealmName = GetRealmName();
  SG.sPlayerName = UnitName("player");
  SG.sID = SG.sRealmName .. ":" .. SG.sPlayerName;
  --AutoSelfCast = GetCVar("autoSelfCast");

  SMARTBUFF_PLAYERCLASS = SG.sPlayerClass;

  if (type(SMARTBUFF_Buffs) ~= "table") then SMARTBUFF_Buffs = {}; end
  SG.B = SMARTBUFF_Buffs;
  if (type(SMARTBUFF_Options) ~= "table") then SMARTBUFF_Options = {}; end
  SG.O = SMARTBUFF_Options;

  -- Migrate blacklist -> blocklist (inclusive language)
  if (SG.O.BlacklistTimer ~= nil and SG.O.BlocklistTimer == nil) then SG.O.BlocklistTimer = SG.O.BlacklistTimer; SG.O.BlacklistTimer = nil; end

  SMARTBUFF_BROKER_SetIcon();


  if (SG.O.Toggle == nil) then SG.O.Toggle = true; end
  if (SG.O.ToggleAuto == nil) then SG.O.ToggleAuto = true; end
  if (SG.O.AutoTimer == nil) then SG.O.AutoTimer = 5; end
  if (SG.O.BlocklistTimer == nil) then SG.O.BlocklistTimer = 5; end
  if (SG.O.ToggleAutoCombat == nil) then SG.O.ToggleAutoCombat = false; end
  if (SG.O.ToggleAutoChat == nil) then SG.O.ToggleAutoChat = false; end
  if (SG.O.ToggleAutoSplash == nil) then SG.O.ToggleAutoSplash = true; end
  if (SG.O.ToggleAutoSound == nil) then SG.O.ToggleAutoSound = true; end
  SG.InitSharedMediaSounds();
  -- New install / full reset: no saved sound preference → Smartbuff_Player-Blind
  if (SG.O.AutoSoundKey == nil and SG.O.AutoSoundSelection == nil) then
    SG.O.AutoSoundKey = SG.DefaultSoundKey;
  end
  SG.SetSoundSelection(SG.ResolveSoundIndex());
  if (SG.O.CheckCharges == nil) then SG.O.CheckCharges = true; end
  --if (SG.O.ToggleAutoRest == nil) then  SG.O.ToggleAutoRest = true; end
  if (SG.O.RebuffTimer == nil) then SG.O.RebuffTimer = 5; end
  if (SG.O.SplashDuration == nil) then SG.O.SplashDuration = 2; end
  if (SG.O.SplashIconSize == nil) then SG.O.SplashIconSize = 16; end

  if (SG.O.BuffTarget == nil) then SG.O.BuffTarget = true; end
  if (SG.O.BuffPvP == nil) then SG.O.BuffPvP = false; end
  if (SG.O.BuffInCities == nil) then SG.O.BuffInCities = true; end
  if (SG.O.LinkSelfBuffCheck == nil) then SG.O.LinkSelfBuffCheck = true; end
  if (SG.O.LinkGrpBuffCheck == nil) then SG.O.LinkGrpBuffCheck = true; end

  if (SG.O.ScrollWheel ~= nil and SG.O.ScrollWheelUp == nil) then SG.O.ScrollWheelUp = SG.O.ScrollWheel; end
  if (SG.O.ScrollWheel ~= nil and SG.O.ScrollWheelDown == nil) then SG.O.ScrollWheelDown = SG.O.ScrollWheel; end
  if (SG.O.ScrollWheelUp == nil) then SG.O.ScrollWheelUp = true; end
  if (SG.O.ScrollWheelDown == nil) then SG.O.ScrollWheelDown = true; end
  -- Default off: don't CameraZoom while scroll-wheel is casting a buff (override already steals zoom bindings).
  if (SG.O.ScrollWheelZooming == nil) then SG.O.ScrollWheelZooming = false; end

  if (SG.O.InCombat == nil) then SG.O.InCombat = false; end
  if (SG.O.IncludeToys == nil) then SG.O.IncludeToys = false; end
  if (SG.O.RetainTemplate == nil) then SG.O.RetainTemplate = false; end
  if (SG.O.AutoSwitchTemplate == nil) then SG.O.AutoSwitchTemplate = true; end
  if (SG.O.AutoSwitchTemplateInst == nil) then SG.O.AutoSwitchTemplateInst = true; end
  if (SG.O.InShapeshift == nil) then SG.O.InShapeshift = true; end

  SG.O.ToggleGrp = { true, true, true, true, true, true, true, true };

  if (SG.O.ToggleMsgNormal == nil) then SG.O.ToggleMsgNormal = true; end
  if (SG.O.ToggleMsgWarning == nil) then SG.O.ToggleMsgWarning = false; end
  if (SG.O.ToggleMsgError == nil) then SG.O.ToggleMsgError = false; end

  if (SG.O.HideMmButton == nil) then SG.O.HideMmButton = false; end
  if (SG.O.PaladinAssign == nil) then SG.O.PaladinAssign = true; end
  if (SG.O.PaladinAssignLock == nil) then SG.O.PaladinAssignLock = false; end
  if (SG.O.HideSAButton == nil) then SG.O.HideSAButton = false; end
  if (SG.O.HideSAIfIdle == nil) then SG.O.HideSAIfIdle = true; end

  if (SG.O.SBButtonFix == nil) then SG.O.SBButtonFix = true; end
  SMARTBUFF_ApplyKeyButtonUseOnKeyDown();

  if (SG.O.MinCharges == nil) then
    if (SG.sPlayerClass == "SHAMAN" or SG.sPlayerClass == "PRIEST") then
      SG.O.MinCharges = 1;
    else
      SG.O.MinCharges = 3;
    end
  end

  if (not SG.O.AddList) then SG.O.AddList = {}; end
  if (not SG.O.IgnoreList) then SG.O.IgnoreList = {}; end

  if (SG.O.LastTemplate == nil) then SG.O.LastTemplate = SMARTBUFF_TEMPLATES[1]; end
  local b = false;
  while (SMARTBUFF_TEMPLATES[i] ~= nil) do
    if (SMARTBUFF_TEMPLATES[i] == SG.O.LastTemplate) then
      b = true;
      break;
    end
    i = i + 1;
  end
  if (not b) then
    SG.O.LastTemplate = SMARTBUFF_TEMPLATES[1];
  end

  SG.currentTemplate = SG.O.LastTemplate;
  SG.currentSpec = SMARTBUFF_GetActiveTalentGroup();

  if (SG.O.OldWheelUp == nil) then SG.O.OldWheelUp = ""; end
  if (SG.O.OldWheelDown == nil) then SG.O.OldWheelDown = ""; end

  SMARTBUFF_InitActionButtonPos();

  if (SG.O.SplashX == nil) then SG.O.SplashX = 100; end
  if (SG.O.SplashY == nil) then SG.O.SplashY = -100; end
  if (SG.O.CurrentFont == nil) then SG.O.CurrentFont = 6; end
  if (SG.O.ColSplashFont == nil) then
    SG.O.ColSplashFont = {};
    SG.O.ColSplashFont.r = 1.0;
    SG.O.ColSplashFont.g = 1.0;
    SG.O.ColSplashFont.b = 1.0;
  end
  SG.iCurrentFont = SG.O.CurrentFont;

  if (SG.O.Debug == nil) then SG.O.Debug = false; end

  -- Cosmos support
  if (EarthFeature_AddButton) then
    EarthFeature_AddButton(
      {
        id = SMARTBUFF_TITLE,
        name = SMARTBUFF_TITLE,
        subtext = SMARTBUFF_TITLE,
        tooltip = "",
        icon = SG.imgSB,
        callback = SMARTBUFF_OptionsFrame_Toggle,
        test = nil,
      })
  elseif (Cosmos_RegisterButton) then
    Cosmos_RegisterButton(SMARTBUFF_TITLE, SMARTBUFF_TITLE, SMARTBUFF_TITLE, SG.imgSB, SMARTBUFF_OptionsFrame_Toggle);
  end

  if (C_AddOns.IsAddOnLoaded("Parrot")) then
    SG.isParrot = true;
  end

  SMARTBUFF_FindItem("ScanBagsForSBInit");

  SMARTBUFF_AddMsg(SMARTBUFF_VERS_TITLE .. " (" .. tostring(SMARTBUFF_CLIENTLABEL or "Forever") .. ") " .. SMARTBUFF_MSG_LOADED, true);
  SMARTBUFF_AddMsg("/sbm - " .. SMARTBUFF_OFT_MENU, true);
  SG.isInit = true;

  -- Bind global options before anything that can error (splash uses SG.OG).
  if (type(SMARTBUFF_OptionsGlobal) ~= "table") then
    SMARTBUFF_OptionsGlobal = {};
    SMARTBUFF_BuffOrderReset();
  end
  SG.OG = SMARTBUFF_OptionsGlobal;
  if (SG.OG.SplashIcon == nil) then SG.OG.SplashIcon = true; end
  if (SG.OG.SplashMsgShort == nil) then SG.OG.SplashMsgShort = false; end
  if (SG.OG.FirstStart == nil) then SG.OG.FirstStart = "V0"; end

  -- Minimap button must not abort options init (Forever can lack Texture:UpdateCoord).
  pcall(SMARTBUFF_InitMinimapButton);
  pcall(SMARTBUFF_CheckMiniMapButton);
  SMARTBUFF_ShowSAButton();
  SMARTBUFF_Splash_Hide();
  if (SMARTBUFF_PaladinAssign_OnRoster) then SMARTBUFF_PaladinAssign_OnRoster(); end

  SMARTBUFF_MigrateToDualSpec();

  for k, v in pairs(SG.cClasses) do
    if (SMARTBUFF_CLASSES[k] == nil) then
      SMARTBUFF_CLASSES[k] = v;
    end
  end

  SMARTBUFF_Splash_ChangeFont(0);

  -- Version prompt uses SMARTBUFF_VERSION (string); often only this is bumped, not SMARTBUFF_VERSIONNR
  if (SG.OG.FirstStart ~= SMARTBUFF_VERSION) then
    SMARTBUFF_OptionsFrame_Open(true);
    SG.OG.FirstStart = SMARTBUFF_VERSION;
    SmartBuffOptionsCredits_lblText:SetText(SMARTBUFF_CREDITS); -- bugfix, credits now showing at first start
    SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
    -- Ensure options frame is visible and positioned before showing WNF frame
    if (SmartBuffOptionsFrame:IsVisible()) then
      SmartBuffWNF:Show();
    else
      -- If options frame isn't visible yet, show WNF after a short delay
      C_Timer.After(0.1, function()
        if (SmartBuffOptionsFrame:IsVisible()) then
          SmartBuffWNF:Show();
        end
      end);
    end
  end

  -- Buff data reset uses SG.O.VersionNr / SMARTBUFF_VERSIONNR (number); only when that changes (purge + rebuild)
  SG.O.VersionNr = SG.O.VersionNr or SMARTBUFF_VERSIONNR -- don't reset if SG.O.VersionNr == nil
  if (SG.O.VersionNr ~= SMARTBUFF_VERSIONNR) then
    SG.O.VersionNr = SMARTBUFF_VERSIONNR;
    StaticPopup_Show("SMARTBUFF_BUFFS_PURGE");
    SMARTBUFF_SetTemplate()
    initBuffOrder(true);
    SMARTBUFF_AddMsg("Upgraded SmartBuff to " .. SMARTBUFF_VERSION, true);
  end
  -- TODO: Bring back major reset of everything but also there's a UI button still to do it

  if (not isVisibleToPlayer(SmartBuff_KeyButton)) then
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER", 0, 100);
  end

  -- Initialize mount state
  SG.isMounted = IsMounted() or IsFlying();

  -- Call SMARTBUFF_SetTemplate() first to set up SG.currentTemplate and groups
  -- Then it will call SMARTBUFF_SetBuffs() internally
  -- This ensures proper initialization order
  SMARTBUFF_SetTemplate(true);
  SMARTBUFF_RebindKeys();
  SG.isSyncReq = true;
  -- Second SetBuffs after a short delay: first pass often runs before C_Item / container cache is warm on login.
  C_Timer.After(0.4, function()
    if (not SG.isInit or not SG.O or not SG.O.Toggle or InCombatLockdown()) then return end
    SMARTBUFF_SetBuffs();
    SG.isSyncReq = true;
    if (SmartBuffOptionsFrame and SmartBuffOptionsFrame:IsVisible()) then
      SMARTBUFF_BuffOrderOnScroll();
    end
  end);
  -- Initialize SG.tLastCheck to ensure AutoTimer works correctly after dismounting
  SG.tLastCheck = GetTime();
end

-- END SMARTBUFF_Options_Init



-- SmartBuff commandline menu ---------------------------------------------------------------------------------------
function SMARTBUFF_Command(msg)
  if (not SG.isInit) then
    SMARTBUFF_AddMsgWarn(SMARTBUFF_VERS_TITLE .. " not initialized correctly!", true);
    return;
  end

  if (msg == "toggle" or msg == "t") then
    SMARTBUFF_OToggle();
    SMARTBUFF_SetTemplate();
  elseif (msg == "menu") then
    SMARTBUFF_OptionsFrame_Toggle();
  elseif (msg == "pa" or (msg and string.lower(msg) == "paladin")) then
    SMARTBUFF_PaladinAssign_Toggle();
  elseif (msg == "rbt") then
    SMARTBUFF_ResetBuffTimers();
  elseif (msg == "sbt") then
    SMARTBUFF_ShowBuffTimers();
  elseif (msg == "target") then
    if (SMARTBUFF_PreCheck(0)) then
      SMARTBUFF_CheckBlocklist();
      SMARTBUFF_BuffUnit("target", 0, 0);
    end
  elseif (msg == "debug") then
    SG.O.Debug = SMARTBUFF_ToggleBool(SG.O.Debug, "Debug active = ");
  elseif (msg == "open") then
    SMARTBUFF_OptionsFrame_Open(true);
  elseif (msg == "sync") then
    SMARTBUFF_SyncBuffTimers();
  elseif (msg == "rb") then
    SMARTBUFF_ResetBindings();
    SMARTBUFF_AddMsg("SmartBuff key and mouse bindings reset.", true);
  elseif (msg == "rafp") then
    SmartBuffSplashFrame:ClearAllPoints();
    SmartBuffSplashFrame:SetPoint("CENTER", UIParent, "CENTER");
    if (SG.O.Minimap) then
      SG.O.Minimap.minimapPos = 0;
      local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true);
      if (ldbIcon and ldbIcon:IsRegistered("SmartBuff")) then
        ldbIcon:Refresh("SmartBuff", SG.O.Minimap);
      end
    end
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuffOptionsFrame:ClearAllPoints();
    SmartBuffOptionsFrame:SetPoint("CENTER", UIParent, "CENTER");
  elseif (msg == "test") then
    -- Test Code ******************************************
    -- ****************************************************
    --local spellname = "Mind--numbing Poison";
    --SMARTBUFF_AddMsg("Original: " .. spellname, true);
    --if (string.find(spellname, "%-%-") ~= nil) then
    --  spellname = string.gsub(spellname, "%-%-", "%-");
    --end
    --SMARTBUFF_AddMsg("Modified: " .. spellname, true);
    -- ****************************************************
    -- ****************************************************
  elseif (msg == "changes") then
    SMARTBUFF_OptionsFrame_Open(true);
    SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
    -- Force show the changelog frame after a brief delay to ensure options frame is positioned
    C_Timer.After(0.1, function()
      SmartBuffWNF:Show();
    end);
  elseif (msg == "reload") then
    SMARTBUFF_BuffOrderReset();
    SMARTBUFF_OptionsFrame_Open(true);
  elseif (msg == "cache") then
    SMARTBUFF_PrintCacheStats(SG.cBuffs);
  else
    --SMARTBUFF_Check(0);
    SMARTBUFF_AddMsg(SMARTBUFF_VERS_TITLE, true);
    SMARTBUFF_AddMsg("Syntax: /sbo [command] or /sbuff [command] or /smartbuff [command]", true);
    SMARTBUFF_AddMsg("toggle  -  " .. SMARTBUFF_OFT, true);
    SMARTBUFF_AddMsg("menu     -  " .. SMARTBUFF_OFT_MENU, true);
    SMARTBUFF_AddMsg("paladin  -  " .. "Open or close Paladin assignments", true);
    SMARTBUFF_AddMsg("target  -  " .. SMARTBUFF_OFT_TARGET, true);
    SMARTBUFF_AddMsg("rbt      -  " .. "Reset buff timers", true);
    SMARTBUFF_AddMsg("sbt      -  " .. "Show buff timers", true);
    SMARTBUFF_AddMsg("rafp     -  " .. "Reset all frame positions", true);
    SMARTBUFF_AddMsg("sync     -  " .. "Sync buff timers with UI", true);
    SMARTBUFF_AddMsg("rb       -  " .. "Reset key/mouse bindings", true);
    SMARTBUFF_AddMsg("changes    -  " .. "Display changelog", true);
    SMARTBUFF_AddMsg("reload    -  " .. "Reset buff list", true);
  end
end


-- END SMARTBUFF_Command


-- SmartBuff options toggle ---------------------------------------------------------------------------------------
function SMARTBUFF_OToggle()
  if (not SG.isInit) then return; end
  SG.O.Toggle = SMARTBUFF_ToggleBool(SG.O.Toggle, "Active = ");
  SMARTBUFF_CheckMiniMapButton();
  if (SG.O.Toggle) then
    SMARTBUFF_SetTemplate();
  end
end


function SMARTBUFF_OToggleAuto()
  SG.O.ToggleAuto = not SG.O.ToggleAuto;
end


function SMARTBUFF_OToggleAutoCombat()
  SG.O.ToggleAutoCombat = not SG.O.ToggleAutoCombat;
end


function SMARTBUFF_OToggleAutoChat()
  SG.O.ToggleAutoChat = not SG.O.ToggleAutoChat;
end


function SMARTBUFF_OToggleAutoSplash()
  SG.O.ToggleAutoSplash = not SG.O.ToggleAutoSplash;
end


function SMARTBUFF_OToggleAutoSound()
  SG.O.ToggleAutoSound = not SG.O.ToggleAutoSound;
  SMARTBUFF_UpdateSoundDropdownState();
end


local SOUND_MENU_ROW_HEIGHT = 22;
local SOUND_MENU_WIDTH = 500;
local SOUND_MENU_PAD = 8;

local function SMARTBUFF_GetSoundMenuMaxHeight(anchor)
  local opts = SmartBuffOptionsFrame;
  if (not opts or not anchor) then
    return (SMARTBUFF_OPTIONSFRAME_HEIGHT or 720) - 40;
  end
  local frameH = opts:GetHeight() or (SMARTBUFF_OPTIONSFRAME_HEIGHT or 720);
  local below = (anchor:GetBottom() or 0) - (opts:GetBottom() or 0) - SOUND_MENU_PAD;
  local above = (opts:GetTop() or 0) - (anchor:GetTop() or 0) - SOUND_MENU_PAD;
  local avail = math.max(below, above);
  -- Cap to options frame height and keep a usable minimum.
  avail = math.min(avail, frameH - SOUND_MENU_PAD * 2);
  return math.max(avail, SOUND_MENU_ROW_HEIGHT * 5);
end

local function SMARTBUFF_SoundMenu_ShouldOpenBelow(anchor)
  local opts = SmartBuffOptionsFrame;
  if (not opts or not anchor) then return true; end
  local below = (anchor:GetBottom() or 0) - (opts:GetBottom() or 0) - SOUND_MENU_PAD;
  local above = (opts:GetTop() or 0) - (anchor:GetTop() or 0) - SOUND_MENU_PAD;
  return below >= above;
end

local function SMARTBUFF_SoundMenu_Hide()
  if (SmartBuffSoundMenu) then
    SmartBuffSoundMenu:Hide();
  end
end

local function SMARTBUFF_EnsureSoundMenu()
  if (SmartBuffSoundMenu) then
    return SmartBuffSoundMenu;
  end

  local menu = CreateFrame("Frame", "SmartBuffSoundMenu", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil);
  menu:SetFrameStrata("FULLSCREEN_DIALOG");
  menu:SetFrameLevel(100);
  menu:SetToplevel(true);
  menu:SetClampedToScreen(true);
  menu:EnableMouse(true);
  menu:Hide();
  if (menu.SetBackdrop) then
    menu:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    });
    menu:SetBackdropColor(0.05, 0.05, 0.1, 0.95);
    menu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
  end
  menu.buttons = {};

  local scroll = CreateFrame("ScrollFrame", "SmartBuffSoundMenuScroll", menu, "UIPanelScrollFrameTemplate");
  scroll:SetPoint("TOPLEFT", SOUND_MENU_PAD, -SOUND_MENU_PAD);
  scroll:SetPoint("BOTTOMRIGHT", -28, SOUND_MENU_PAD);
  menu.scroll = scroll;

  local child = CreateFrame("Frame", "SmartBuffSoundMenuChild", scroll);
  child:SetPoint("TOPLEFT");
  child:SetSize(SOUND_MENU_WIDTH - 36, SOUND_MENU_ROW_HEIGHT);
  scroll:SetScrollChild(child);
  menu.child = child;

  scroll:EnableMouseWheel(true);
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local step = SOUND_MENU_ROW_HEIGHT * 3;
    local cur = self:GetVerticalScroll() or 0;
    local maxScroll = self:GetVerticalScrollRange() or 0;
    self:SetVerticalScroll(math.min(maxScroll, math.max(0, cur - (delta * step))));
  end);

  menu:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil);
    if (self.UnregisterEvent) then
      pcall(self.UnregisterEvent, self, "GLOBAL_MOUSE_DOWN");
    end
  end);

  menu:SetScript("OnEvent", function(self, event)
    if (event ~= "GLOBAL_MOUSE_DOWN") then return; end
    if ((self.ignoreCloseUntil or 0) > GetTime()) then return; end
    local dd = SmartBuffOptionsFrame_ddSounds;
    if (self:IsMouseOver() or (dd and dd:IsMouseOver()) or (self.scroll and self.scroll:IsMouseOver())) then
      return;
    end
    local sb = _G["SmartBuffSoundMenuScrollScrollBar"];
    if (sb and sb:IsMouseOver()) then return; end
    self:Hide();
  end);

  return menu;
end

local function SMARTBUFF_SoundMenu_Rebuild(menu)
  local list = SG.SoundList or {};
  local child = menu.child;
  local buttons = menu.buttons;
  local selected = SG.O and SG.O.AutoSoundKey;
  child:SetWidth(SOUND_MENU_WIDTH - 36);

  for i, key in ipairs(list) do
    local btn = buttons[i];
    if (not btn) then
      btn = CreateFrame("Button", nil, child);
      btn:SetHeight(SOUND_MENU_ROW_HEIGHT);
      btn:SetNormalFontObject("GameFontHighlight");
      btn:SetHighlightFontObject("GameFontHighlight");
      btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
      local fs = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
      fs:SetPoint("LEFT", 8, 0);
      fs:SetPoint("RIGHT", -8, 0);
      fs:SetJustifyH("LEFT");
      btn.text = fs;
      btn:SetScript("OnClick", function(self)
        if (not self.soundKey) then return; end
        SMARTBUFF_DropDownSound_OnClick({ value = self.soundKey });
        SMARTBUFF_SoundMenu_Hide();
      end);
      buttons[i] = btn;
    end
    btn.soundKey = key;
    btn:SetHeight(SOUND_MENU_ROW_HEIGHT);
    btn.text:SetFontObject("GameFontHighlight");
    btn.text:SetText(key);
    if (key == selected) then
      btn.text:SetTextColor(1, 0.82, 0);
    else
      btn.text:SetTextColor(1, 1, 1);
    end
    btn:ClearAllPoints();
    btn:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((i - 1) * SOUND_MENU_ROW_HEIGHT));
    btn:SetPoint("TOPRIGHT", child, "TOPRIGHT", 0, -((i - 1) * SOUND_MENU_ROW_HEIGHT));
    btn:Show();
  end

  for i = #list + 1, #buttons do
    buttons[i]:Hide();
  end

  local contentH = math.max(#list * SOUND_MENU_ROW_HEIGHT, SOUND_MENU_ROW_HEIGHT);
  child:SetHeight(contentH);
  return contentH;
end

function SMARTBUFF_DropDownSound_Toggle(self)
  if (not self) then return; end
  -- Resolve parent if click came from the dropdown arrow button.
  if (self.GetParent and self:GetName() and self:GetName():match("Button$")) then
    local parent = self:GetParent();
    if (parent and parent.GetName and parent:GetName() == "SmartBuffOptionsFrame_ddSounds") then
      self = parent;
    end
  end
  if (not SG.O or not SG.O.ToggleAutoSound) then return; end

  CloseDropDownMenus();

  local menu = SMARTBUFF_EnsureSoundMenu();
  if (menu:IsShown()) then
    menu:Hide();
    return;
  end

  SG.InitSharedMediaSounds();
  SG.RebuildSoundList();
  local contentH = SMARTBUFF_SoundMenu_Rebuild(menu);
  local maxH = SMARTBUFF_GetSoundMenuMaxHeight(self);
  local viewH = math.min(contentH + SOUND_MENU_PAD * 2, maxH);
  if (viewH < SOUND_MENU_ROW_HEIGHT * 5) then
    viewH = math.min(SOUND_MENU_ROW_HEIGHT * 5, maxH);
  end
  local needsScroll = contentH + SOUND_MENU_PAD * 2 > viewH;

  menu:SetWidth(SOUND_MENU_WIDTH);
  menu:SetHeight(viewH);
  menu.scroll:ClearAllPoints();
  menu.scroll:SetPoint("TOPLEFT", SOUND_MENU_PAD, -SOUND_MENU_PAD);
  if (needsScroll) then
    menu.scroll:SetPoint("BOTTOMRIGHT", -28, SOUND_MENU_PAD);
  else
    menu.scroll:SetPoint("BOTTOMRIGHT", -SOUND_MENU_PAD, SOUND_MENU_PAD);
  end
  menu.scroll:SetVerticalScroll(0);

  local sb = _G["SmartBuffSoundMenuScrollScrollBar"];
  if (sb) then
    if (needsScroll) then sb:Show(); else sb:Hide(); end
  end

  menu:ClearAllPoints();
  if (SMARTBUFF_SoundMenu_ShouldOpenBelow(self)) then
    menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 16, 2);
  else
    menu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 16, -2);
  end

  menu.ignoreCloseUntil = GetTime() + 0.35;
  pcall(function() menu:RegisterEvent("GLOBAL_MOUSE_DOWN"); end);
  menu:SetScript("OnUpdate", function(frame)
    if ((frame.ignoreCloseUntil or 0) > GetTime()) then return; end
    if (not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton")) then return; end
    local dd = SmartBuffOptionsFrame_ddSounds;
    if (frame:IsMouseOver() or (dd and dd:IsMouseOver()) or (frame.scroll and frame.scroll:IsMouseOver())) then
      return;
    end
    local scrollBar = _G["SmartBuffSoundMenuScrollScrollBar"];
    if (scrollBar and scrollBar:IsMouseOver()) then return; end
    frame:Hide();
  end);
  menu:Show();
  menu:Raise();
end

function SMARTBUFF_DropDownSound_OnShow(self)
  if (not self) then return; end
  SG.InitSharedMediaSounds();
  local idx = SG.ResolveSoundIndex();
  SG.SetSoundSelection(idx);
  local key = SG.O and SG.O.AutoSoundKey or SG.GetSoundDisplayName(idx);
  -- Keep native dropdown list empty; sounds open in the scrollable SmartBuffSoundMenu.
  UIDropDownMenu_Initialize(self, function() end);
  UIDropDownMenu_SetSelectedValue(self, key);
  UIDropDownMenu_SetText(self, key or "?");
  UIDropDownMenu_SetWidth(self, 222);
  if (UIDropDownMenu_JustifyText) then
    UIDropDownMenu_JustifyText(self, "LEFT");
  else
    local text = _G[self:GetName() .. "Text"];
    if (text) then
      text:ClearAllPoints();
      text:SetPoint("LEFT", _G[self:GetName() .. "Left"], "LEFT", 27, 2);
      text:SetPoint("RIGHT", _G[self:GetName() .. "Button"], "LEFT", -4, 2);
      text:SetJustifyH("LEFT");
    end
  end

  -- UIDropDownMenuTemplate routes clicks to the child "…Button", not the parent OnClick.
  local dropBtn = _G[self:GetName() .. "Button"];
  if (dropBtn and not dropBtn._sbSoundWired) then
    dropBtn._sbSoundWired = true;
    dropBtn:SetScript("OnClick", function(btn, button, down)
      CloseDropDownMenus();
      SMARTBUFF_DropDownSound_Toggle(btn:GetParent());
    end);
  end

  SMARTBUFF_UpdateSoundDropdownState();
end

function SMARTBUFF_DropDownSound_OnClick(self)
  local key = self.value;
  if (not key or not SG.O or not SG.O.ToggleAutoSound) then return; end
  SG.O.AutoSoundKey = key;
  for i, k in ipairs(SG.SoundList or {}) do
    if (k == key) then
      SG.O.AutoSoundSelection = i;
      break;
    end
  end
  UIDropDownMenu_SetSelectedValue(SmartBuffOptionsFrame_ddSounds, key);
  UIDropDownMenu_SetText(SmartBuffOptionsFrame_ddSounds, key);
  CloseDropDownMenus();
  SMARTBUFF_SoundMenu_Hide();
  SG.PlaySplashSound();
end

function SMARTBUFF_UpdateSoundDropdownState()
  local enabled = SG.O and SG.O.ToggleAutoSound;
  local dd = SmartBuffOptionsFrame_ddSounds;
  if (dd) then
    if (enabled) then
      UIDropDownMenu_EnableDropDown(dd);
    else
      UIDropDownMenu_DisableDropDown(dd);
      CloseDropDownMenus();
      SMARTBUFF_SoundMenu_Hide();
    end
  end
  local lbl = SmartBuffOptionsFrame_lblSelectSound;
  if (lbl) then
    lbl:SetAlpha(enabled and 1 or 0.5);
  end
end

function SMARTBUFF_UpdateSoundDropdown()
  if (SmartBuffOptionsFrame_ddSounds) then
    SMARTBUFF_DropDownSound_OnShow(SmartBuffOptionsFrame_ddSounds);
  end
  SMARTBUFF_SoundMenu_Hide();
end


--function SMARTBUFF_OToggleCheckCharges()
--  SG.O.ToggleCheckCharges = not SG.O.ToggleCheckCharges;
--end

--function SMARTBUFF_OToggleAutoRest()
--  SG.O.ToggleAutoRest = not SG.O.ToggleAutoRest;
--end


function SMARTBUFF_OAutoSwitchTmp()
  SG.O.AutoSwitchTemplate = not SG.O.AutoSwitchTemplate;
end


function SMARTBUFF_OAutoSwitchTmpInst()
  SG.O.AutoSwitchTemplateInst = not SG.O.AutoSwitchTemplateInst;
end


function SMARTBUFF_OBuffTarget()
  SG.O.BuffTarget = not SG.O.BuffTarget;
end


function SMARTBUFF_OBuffPvP()
  SG.O.BuffPvP = not SG.O.BuffPvP;
end


function SMARTBUFF_OBuffInCities()
  SG.O.BuffInCities = not SG.O.BuffInCities;
end


function SMARTBUFF_OLinkSelfBuffCheck()
  SG.O.LinkSelfBuffCheck = not SG.O.LinkSelfBuffCheck;
end


function SMARTBUFF_OLinkGrpBuffCheck()
  SG.O.LinkGrpBuffCheck = not SG.O.LinkGrpBuffCheck;
end


function SMARTBUFF_OScrollWheelUp()
  SG.O.ScrollWheelUp = not SG.O.ScrollWheelUp;
  SG.isKeyUpChanged = true;
end


function SMARTBUFF_OScrollWheelDown()
  SG.O.ScrollWheelDown = not SG.O.ScrollWheelDown;
  SG.isKeyDownChanged = true;
end


function SMARTBUFF_OScrollWheelZoom()
  SG.O.ScrollWheelZooming = not SG.O.ScrollWheelZooming;
end


function SMARTBUFF_OInShapeshift()
  SG.O.InShapeshift = not SG.O.InShapeshift;
end


function SMARTBUFF_OInCombat()
  SG.O.InCombat = not SG.O.InCombat;
end


function SMARTBUFF_OIncludeToys()
  SG.O.IncludeToys = not SG.O.IncludeToys;
  SMARTBUFF_Options_OnShow();
  -- initBuffOrder(false) is already called in SMARTBUFF_Options_OnShow(), no need to reset order
end


function SMARTBUFF_OToggleMsgNormal()
  SG.O.ToggleMsgNormal = not SG.O.ToggleMsgNormal;
end


function SMARTBUFF_OToggleMsgWarning()
  SG.O.ToggleMsgWarning = not SG.O.ToggleMsgWarning;
end


function SMARTBUFF_OToggleMsgError()
  SG.O.ToggleMsgError = not SG.O.ToggleMsgError;
end


function SMARTBUFF_OHideMmButton()
  SG.O.HideMmButton = not SG.O.HideMmButton;
  if (SG.O.Minimap) then
    SG.O.Minimap.hide = SG.O.HideMmButton and true or false;
  end
  SMARTBUFF_CheckMiniMapButton();
end


function SMARTBUFF_UpdateHideSAIfIdleOptionState()
  if (not SG.isInit or not SmartBuffOptionsFrame_cbHideSAIfIdle) then
    return;
  end
  if (SG.O and SG.O.HideSAButton) then
    SmartBuffOptionsFrame_cbHideSAIfIdle:Disable();
  else
    SmartBuffOptionsFrame_cbHideSAIfIdle:Enable();
  end
end


function SMARTBUFF_OHideSAButton()
  SG.O.HideSAButton = not SG.O.HideSAButton;
  SMARTBUFF_ShowSAButton();
  SMARTBUFF_UpdateHideSAIfIdleOptionState();
  if (SG.O.Toggle and SG.O.HideSAIfIdle and not SG.O.HideSAButton) then
    SMARTBUFF_Check(1, true);
  end
end


function SMARTBUFF_OHideSAIfIdle()
  SG.O.HideSAIfIdle = not SG.O.HideSAIfIdle;
  if (SG.O.Toggle) then
    SMARTBUFF_Check(1, true);
  else
    SMARTBUFF_RefreshSAButtonIdleState(false);
  end
end


function SMARTBUFF_ORetainTemplate()
  SG.O.RetainTemplate = not SG.O.RetainTemplate;
end


function SMARTBUFF_OSelfFirst()
  local tm = ensureBuffsTemplateTable(SG.currentTemplate);
  if (not tm) then return; end
  tm.SelfFirst = not tm.SelfFirst;
end


function SMARTBUFF_OToggleBuff(s, i)
  if (SG.cBuffs[i] == nil) then
    return
  end
  local bs = getBuffSettings(SG.cBuffs[i].BuffS);
  if (bs == nil) then
    return;
  end

  if (s == "S") then
    bs.EnableS = not bs.EnableS;
    --SMARTBUFF_AddMsgD("OToggleBuff = "..cBuffs[i].BuffS..", "..tostring(bs.EnableS));
    if (bs.EnableS) then
      SMARTBUFF_BuffSetup_Show(i);
    else
      SmartBuff_BuffSetup:Hide();
      SG.iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end
  elseif (s == "G") then
    bs.EnableG = not bs.EnableG;
  end
end


function SMARTBUFF_OToggleDebug()
  SG.O.Debug = not SG.O.Debug;
end


function SMARTBUFF_ToggleFixBuffing()
  SG.O.SBButtonFix = not SG.O.SBButtonFix;
  SMARTBUFF_ApplyKeyButtonUseOnKeyDown();
end


function SMARTBUFF_OptionsFrame_Toggle()
  if (not SG.isInit) then return; end

  if (SmartBuffOptionsFrame:IsVisible()) then
    if (SG.iLastBuffSetup > 0) then
      SmartBuff_BuffSetup:Hide();
      SG.iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end
    SMARTBUFF_SoundMenu_Hide();
    SmartBuffOptionsFrame:Hide();
  else
    SmartBuffOptionsCredits_lblText:SetText(SMARTBUFF_CREDITS);
    SmartBuffOptionsFrame:Show();
    SmartBuff_PlayerSetup:Hide();
  end
end


function SMARTBUFF_OptionsFrame_Open(force)
  if (not SG.isInit) then return; end
  if (not SmartBuffOptionsFrame:IsVisible() or force) then
    SmartBuffOptionsFrame:Show();
  end
end


function SMARTBUFF_OptionsFrame_Close(force)
  if (not SG.isInit) then return; end
  if (SmartBuffOptionsFrame:IsVisible() or force) then
    SMARTBUFF_SoundMenu_Hide();
    SmartBuffOptionsFrame:Hide();
  end
end


function SMARTBUFF_BuffSetup_Show(i)
  local icon1 = SG.cBuffs[i].IconS;
  local icon2 = SG.cBuffs[i].IconG;
  local name = SG.cBuffs[i].BuffS;
  local btype = SG.cBuffs[i].Type;
  local hidden = true;
  local n = 0;
  local bs = getBuffSettings(name);

  if (name == nil or btype == SMARTBUFF_CONST_TRACK) then
    SmartBuff_BuffSetup:Hide();
    SG.iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    return;
  end

  if (SmartBuff_BuffSetup:IsVisible() and i == SG.iLastBuffSetup) then
    SmartBuff_BuffSetup:Hide();
    SG.iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    return;
  else
    if (btype == SMARTBUFF_CONST_GROUP or btype == SMARTBUFF_CONST_ITEMGROUP) then
      hidden = false;
    end

    if (icon2 and bs.EnableG) then
      SmartBuff_BuffSetup_BuffIcon2:SetNormalTexture(icon2);
      SmartBuff_BuffSetup_BuffIcon2:Show();
    else
      SmartBuff_BuffSetup_BuffIcon2:Hide();
    end
    if (icon1) then
      SmartBuff_BuffSetup_BuffIcon1:SetNormalTexture(icon1);
      if (icon2 and bs.EnableG) then
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 44, -30);
      else
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 64, -30);
      end
      SmartBuff_BuffSetup_BuffIcon1:Show();
    else
      SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 24, -30);
      SmartBuff_BuffSetup_BuffIcon1:Hide();
    end

    local obj = SmartBuff_BuffSetup_BuffText;
    if (name) then
      local displayName = getBuffDisplayName(name, btype);
      if (SG.cBuffs[i].SingleTargetGroup) then
        displayName = displayName .. " - single";
      end
      obj:SetText(displayName);
      --SMARTBUFF_AddMsgD(name);
    else
      obj:SetText("");
    end

    SmartBuff_BuffSetup_cbSelf:SetChecked(bs.SelfOnly);
    SmartBuff_BuffSetup_cbSelfNot:SetChecked(bs.SelfNot);
    SmartBuff_BuffSetup_cbCombatIn:SetChecked(bs.CIn);
    SmartBuff_BuffSetup_cbCombatOut:SetChecked(bs.COut);
    SmartBuff_BuffSetup_cbMH:SetChecked(bs.MH);
    SmartBuff_BuffSetup_cbOH:SetChecked(bs.OH);
    SmartBuff_BuffSetup_cbRH:SetChecked(bs.RH);
    SmartBuff_BuffSetup_cbReminder:SetChecked(bs.Reminder);
    SmartBuff_BuffSetup_txtManaLimit:SetNumber(bs.ManaLimit);

    --SMARTBUFF_AddMsgD("Test Buff setup show 1");
    if (SG.cBuffs[i].DurationS > 0) then
      SmartBuff_BuffSetup_RBTime:SetMinMaxValues(0, SG.cBuffs[i].DurationS);
      _G[SmartBuff_BuffSetup_RBTime:GetName() .. "High"]:SetText(SG.cBuffs[i].DurationS);
      if (SG.cBuffs[i].DurationS <= 60) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(1);
      elseif (SG.cBuffs[i].DurationS <= 180) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(5);
      elseif (SG.cBuffs[i].DurationS <= 600) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(10);
      else
        SmartBuff_BuffSetup_RBTime:SetValueStep(30);
      end
      SmartBuff_BuffSetup_RBTime:SetValue(bs.RBTime);
      _G[SmartBuff_BuffSetup_RBTime:GetName() .. "Text"]:SetText(bs.RBTime .. "\nsec");
      SmartBuff_BuffSetup_RBTime:Show();
    else
      SmartBuff_BuffSetup_RBTime:Hide();
    end
    --SMARTBUFF_AddMsgD("Test Buff setup show 2");

    SmartBuff_BuffSetup_txtManaLimit:Hide();
    if (SG.cBuffs[i].Type == SMARTBUFF_CONST_INV or SG.cBuffs[i].Type == SMARTBUFF_CONST_WEAPON) then
      SmartBuff_BuffSetup_cbMH:Show();
      SmartBuff_BuffSetup_cbOH:Show();
      SmartBuff_BuffSetup_cbRH:Hide();
    else
      SmartBuff_BuffSetup_cbMH:Hide();
      SmartBuff_BuffSetup_cbOH:Hide();
      SmartBuff_BuffSetup_cbRH:Hide();
      if (SG.cBuffs[i].Type ~= SMARTBUFF_CONST_FOOD and SG.cBuffs[i].Type ~= SMARTBUFF_CONST_SCROLL and SG.cBuffs[i].Type ~= SMARTBUFF_CONST_POTION) then
        SmartBuff_BuffSetup_txtManaLimit:Show();
        --SMARTBUFF_AddMsgD("Show ManaLimit");
      end
    end

    if (SG.cBuffs[i].IDS and not SMARTBUFF_IsItem(SG.cBuffs[i].Type)) then
      SmartBuff_BuffSetup_cbSkipBGResQueue:Show();
      SmartBuff_BuffSetup_cbSkipBGResQueue:SetChecked(bs.SkipBGResQueue == true);
    else
      SmartBuff_BuffSetup_cbSkipBGResQueue:Hide();
    end

    if (SG.cBuffs[i].Type == SMARTBUFF_CONST_GROUP or SG.cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
      SmartBuff_BuffSetup_cbSelf:Show();
      SmartBuff_BuffSetup_cbSelfNot:Show();
      SmartBuff_BuffSetup_btnPriorityList:Show();
      SmartBuff_BuffSetup_btnIgnoreList:Show();
      SmartBuff_BuffSetup_btnInfo:Show();
    else
      SmartBuff_BuffSetup_cbSelf:Hide();
      SmartBuff_BuffSetup_cbSelfNot:Hide();
      SmartBuff_BuffSetup_btnPriorityList:Hide();
      SmartBuff_BuffSetup_btnIgnoreList:Hide();
      SmartBuff_BuffSetup_btnInfo:Hide();
      SmartBuff_PlayerSetup:Hide();
    end

    local cb = nil;
    local btn = nil;
    n = 0;
    --SMARTBUFF_AddMsgD("Test Buff setup show 3");
    for _ in pairs(SG.cClasses) do
      n = n + 1;
      cb = _G["SmartBuff_BuffSetup_cbClass" .. n];
      btn = _G["SmartBuff_BuffSetup_ClassIcon" .. n];
      if (hidden) then
        cb:Hide();
        btn:Hide();
      else
        cb:SetChecked(bs[SG.cClasses[n]]);
        cb:Show();
        btn:Show();
      end
    end
    SG.iLastBuffSetup = i;
    --SMARTBUFF_AddMsgD("Test Buff setup show 4");
    SmartBuff_BuffSetup:Show();

    if (SmartBuff_PlayerSetup:IsVisible()) then
      SMARTBUFF_PS_Show(SG.iCurrentList);
    end
  end
end


-- Returns tooltip text for cbSelf/cbSelfNot; appends single-target guidance when buff has SingleTargetGroup.
function SMARTBUFF_GetSelfTooltipText(baseText)
  if (SG.iLastBuffSetup and SG.iLastBuffSetup > 0 and SG.cBuffs and SG.cBuffs[SG.iLastBuffSetup] and SG.cBuffs[SG.iLastBuffSetup].SingleTargetGroup) then
    return { baseText, SMARTBUFF_BSTT_SINGLETARGET };
  end
  return baseText;
end

function SMARTBUFF_BuffSetup_ManaLimitChanged(self)
  local i = SG.iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local name = SG.cBuffs[i].BuffS;
  local cBuff = getBuffSettings(name);
  if (cBuff) then
    cBuff.ManaLimit = self:GetNumber();
  end
end

function SMARTBUFF_BuffSetup_OnClick()
  local i = SG.iLastBuffSetup;
  local ct = SG.currentTemplate;
  if (i <= 0) then
    return;
  end
  local name     = SG.cBuffs[i].BuffS;
  local cBuff    = getBuffSettings(name);

  cBuff.SelfOnly = SmartBuff_BuffSetup_cbSelf:GetChecked();
  cBuff.SelfNot  = SmartBuff_BuffSetup_cbSelfNot:GetChecked();
  cBuff.CIn      = SmartBuff_BuffSetup_cbCombatIn:GetChecked();
  cBuff.COut     = SmartBuff_BuffSetup_cbCombatOut:GetChecked();
  cBuff.SkipBGResQueue = SmartBuff_BuffSetup_cbSkipBGResQueue:IsShown() and SmartBuff_BuffSetup_cbSkipBGResQueue:GetChecked();
  cBuff.MH       = SmartBuff_BuffSetup_cbMH:GetChecked();
  cBuff.OH       = SmartBuff_BuffSetup_cbOH:GetChecked();
  cBuff.RH       = SmartBuff_BuffSetup_cbRH:GetChecked();
  cBuff.Reminder = SmartBuff_BuffSetup_cbReminder:GetChecked();

  cBuff.RBTime   = SmartBuff_BuffSetup_RBTime:GetValue();
  _G[SmartBuff_BuffSetup_RBTime:GetName() .. "Text"]:SetText(cBuff.RBTime .. "\nsec");

  if (SG.cBuffs[i].Type == SMARTBUFF_CONST_GROUP or SG.cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
    local n = 0;
    local cb = nil;
    for _ in pairs(SG.cClasses) do
      n = n + 1;
      cb = _G["SmartBuff_BuffSetup_cbClass" .. n];
      cBuff[SG.cClasses[n]] = cb:GetChecked();
    end
  end
  --SMARTBUFF_AddMsgD("Buff setup saved");
end


function SMARTBUFF_BuffSetup_ToolTip(mode)
  local i = SG.iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local ids = SG.cBuffs[i].IDS;
  local idg = SG.cBuffs[i].IDG;
  local btype = SG.cBuffs[i].Type

  GameTooltip:ClearLines();
  if (SMARTBUFF_IsItem(btype)) then
    local bag, slot, count, texture = SMARTBUFF_FindItem(SG.cBuffs[i].BuffS, SG.cBuffs[i].Chain or SG.cBuffs[i].Links);
    if (bag and slot) then
      if (bag == 999) then -- Toy
        GameTooltip:SetToyByItemID(slot);
      else
        GameTooltip:SetBagItem(bag, slot);
      end
    end
  else
    if (mode == 1 and ids) then
      local link = C_Spell.GetSpellLink(ids);
      if (link) then GameTooltip:SetHyperlink(link); end
    elseif (mode == 2 and idg) then
      local link = C_Spell.GetSpellLink(idg);
      if (link) then GameTooltip:SetHyperlink(link); end
    end
  end
  GameTooltip:Show();
end


-- END SmartBuff options toggle


-- Options frame functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_OnLoad(self)
end


function SMARTBUFF_UpdateTalentGroupLabel()
  if (not SmartBuffOptionsFrame or not SmartBuffOptionsFrame_cbRetainTemplate) then return; end
  local fs = SmartBuffOptionsFrameTalentGroup;
  if (not fs) then
    fs = SmartBuffOptionsFrame:CreateFontString("SmartBuffOptionsFrameTalentGroup", "ARTWORK", "GameFontNormalSmall");
  end
  -- Soft cyan accent (same family as credits links) so it reads as status, not a control label
  fs:SetTextColor(0.0, 0.88, 1.0);
  local retainText = _G["SmartBuffOptionsFrame_cbRetainTemplateText"];
  fs:ClearAllPoints();
  fs:SetJustifyH("RIGHT");
  fs:SetJustifyV("MIDDLE");
  if (retainText) then
    fs:SetPoint("LEFT", retainText, "RIGHT", 12, 0);
    fs:SetPoint("RIGHT", SmartBuffOptionsFrame, "RIGHT", -36, 0);
    fs:SetPoint("TOP", retainText, "TOP", 0, 0);
    fs:SetPoint("BOTTOM", retainText, "BOTTOM", 0, 0);
  else
    fs:SetPoint("LEFT", SmartBuffOptionsFrame_cbRetainTemplate, "RIGHT", 56, 0);
    fs:SetPoint("RIGHT", SmartBuffOptionsFrame, "RIGHT", -36, 0);
    fs:SetPoint("TOP", SmartBuffOptionsFrame_cbRetainTemplate, "TOP", 0, 0);
    fs:SetPoint("BOTTOM", SmartBuffOptionsFrame_cbRetainTemplate, "BOTTOM", 0, 0);
  end
  local n = getCurrentSpec() or 1;
  local maxN = SMARTBUFF_GetNumTalentGroups() or 1;
  fs:SetText(format(SMARTBUFF_OFT_TALENTGROUP or "Talent group %d / %d", n, maxN));
  fs:Show();
end

function SMARTBUFF_Options_OnShow()
  -- Check if the options frame is out of screen area
  local top    = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetTop());
  local bottom = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetBottom());
  local left   = SmartBuffOptionsFrame:GetLeft();
  local right  = SmartBuffOptionsFrame:GetRight();

  --SMARTBUFF_AddMsgD("X: " .. GetScreenWidth() .. ", " .. left .. ", " .. right);
  --SMARTBUFF_AddMsgD("Y: " .. GetScreenHeight() .. ", " .. top .. ", " .. bottom);

  if (GetScreenWidth() < left + 20 or GetScreenHeight() < top + 20 or right < 20 or bottom < 20) then
    SmartBuffOptionsFrame:SetPoint("TOPLEFT", UIParent, "CENTER", -SmartBuffOptionsFrame:GetWidth() / 2,
      SmartBuffOptionsFrame:GetHeight() / 2);
  end

  SMARTBUFF_ShowControls("SmartBuffOptionsFrame", true);
  SMARTBUFF_UpdateTalentGroupLabel();

  -- Clean up buff order (remove invalid, add missing) without resetting custom order
  initBuffOrder(false);

  SmartBuffOptionsFrame_cbSB:SetChecked(SG.O.Toggle);
  SmartBuffOptionsFrame_cbAuto:SetChecked(SG.O.ToggleAuto);
  SmartBuffOptionsFrameAutoTimer:SetValue(SG.O.AutoTimer);
  SMARTBUFF_SetSliderText(SmartBuffOptionsFrameAutoTimer, SMARTBUFF_OFT_AUTOTIMER, SG.O.AutoTimer, INT_SPELL_DURATION_SEC);
  SmartBuffOptionsFrame_cbAutoCombat:SetChecked(SG.O.ToggleAutoCombat);
  SmartBuffOptionsFrame_cbAutoChat:SetChecked(SG.O.ToggleAutoChat);
  SmartBuffOptionsFrame_cbAutoSplash:SetChecked(SG.O.ToggleAutoSplash);
  SmartBuffOptionsFrame_cbAutoSound:SetChecked(SG.O.ToggleAutoSound);
  SMARTBUFF_UpdateSoundDropdown();

  --SmartBuffOptionsFrame_cbCheckCharges:SetChecked(SG.O.ToggleCheckCharges);
  --SmartBuffOptionsFrame_cbAutoRest:SetChecked(SG.O.ToggleAutoRest);
  SmartBuffOptionsFrame_cbAutoSwitchTmp:SetChecked(SG.O.AutoSwitchTemplate);
  SmartBuffOptionsFrame_cbAutoSwitchTmpInst:SetChecked(SG.O.AutoSwitchTemplateInst);
  SmartBuffOptionsFrame_cbBuffPvP:SetChecked(SG.O.BuffPvP);
  SmartBuffOptionsFrame_cbBuffTarget:SetChecked(SG.O.BuffTarget);
  SmartBuffOptionsFrame_cbBuffInCities:SetChecked(SG.O.BuffInCities);
  SmartBuffOptionsFrame_cbInShapeshift:SetChecked(SG.O.InShapeshift);
  SmartBuffOptionsFrame_cbFixBuffIssue:SetChecked(SG.O.SBButtonFix);

  SmartBuffOptionsFrame_cbLinkGrpBuffCheck:SetChecked(SG.O.LinkGrpBuffCheck);
  SmartBuffOptionsFrame_cbLinkSelfBuffCheck:SetChecked(SG.O.LinkSelfBuffCheck);

  SmartBuffOptionsFrame_cbScrollWheelUp:SetChecked(SG.O.ScrollWheelUp);
  SmartBuffOptionsFrame_cbScrollWheelDown:SetChecked(SG.O.ScrollWheelDown);
  if (SmartBuffOptionsFrame_cbScrollWheelZoom) then
    SmartBuffOptionsFrame_cbScrollWheelZoom:SetChecked(SG.O.ScrollWheelZooming);
  end
  SmartBuffOptionsFrame_cbInCombat:SetChecked(SG.O.InCombat);
  SmartBuffOptionsFrame_cbIncludeToys:SetChecked(SG.O.IncludeToys);
  SmartBuffOptionsFrame_cbMsgNormal:SetChecked(SG.O.ToggleMsgNormal);
  SmartBuffOptionsFrame_cbMsgWarning:SetChecked(SG.O.ToggleMsgWarning);
  SmartBuffOptionsFrame_cbMsgError:SetChecked(SG.O.ToggleMsgError);
  SmartBuffOptionsFrame_cbHideMmButton:SetChecked(SG.O.HideMmButton);
  SmartBuffOptionsFrame_cbHideSAButton:SetChecked(SG.O.HideSAButton);
  SmartBuffOptionsFrame_cbHideSAIfIdle:SetChecked(SG.O.HideSAIfIdle);
  SMARTBUFF_UpdateHideSAIfIdleOptionState();
  SmartBuffOptionsFrame_cbRetainTemplate:SetChecked(SG.O.RetainTemplate);

  SmartBuffOptionsFrameRebuffTimer:SetValue(SG.O.RebuffTimer);
  SMARTBUFF_SetSliderText(SmartBuffOptionsFrameRebuffTimer, SMARTBUFF_OFT_REBUFFTIMER, SG.O.RebuffTimer,
    INT_SPELL_DURATION_SEC);
  SmartBuffOptionsFrameBLDuration:SetValue(SG.O.BlocklistTimer);
  SMARTBUFF_SetSliderText(SmartBuffOptionsFrameBLDuration, SMARTBUFF_OFT_BLDURATION, SG.O.BlocklistTimer,
    INT_SPELL_DURATION_SEC);

  SMARTBUFF_SetCheckButtonBuffs(0);

  local tm = buffsTemplateTable(SG.currentTemplate);
  SmartBuffOptionsFrame_cbSelfFirst:SetChecked(tm and tm.SelfFirst);

  SMARTBUFF_Splash_Show();

  SMARTBUFF_AddMsgD("Option frame updated: " .. SG.currentTemplate);
  if (SMARTBUFF_PaladinAssign_SetupOptions) then SMARTBUFF_PaladinAssign_SetupOptions(); end
end


function SMARTBUFF_ShowSubGroups(frame, grpTable)
  local i;
  for i = 1, 8, 1 do
    obj = _G[frame .. "_cbGrp" .. i];
    if (obj) then
      obj:SetChecked(grpTable[i]);
    end
  end
end


function SMARTBUFF_Options_OnHide()
  if (SmartBuffWNF:IsVisible()) then
    SmartBuffWNF:Hide();
  end
  SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  SmartBuff_BuffSetup:Hide();
  SmartBuff_PlayerSetup:Hide();
  SMARTBUFF_Splash_Hide();
  SMARTBUFF_RebindKeys();
  --collectgarbage();
end


function SMARTBUFF_ShowControls(sName, bShow)
  local children = { _G[sName]:GetChildren() };
  for i, child in pairs(children) do
    --SMARTBUFF_AddMsgD(i .. ": " .. child:GetName());
    if (i > 1 and string.find(child:GetName(), "^" .. sName .. ".+")) then
      if (bShow) then
        child:Show();
      else
        child:Hide();
      end
    end
  end
end


function SMARTBUFF_OptionsFrameSlider_OnLoad(self, low, high, step, labels)
  _G[self:GetName() .. "Text"]:SetFontObject(GameFontNormalSmall);
  if (labels) then
    if (self:GetOrientation() ~= "VERTICAL") then
      _G[self:GetName() .. "Low"]:SetText(low);
    else
      _G[self:GetName() .. "Low"]:SetText("");
    end
    _G[self:GetName() .. "High"]:SetText(high);
  else
    _G[self:GetName() .. "Low"]:SetText("");
    _G[self:GetName() .. "High"]:SetText("");
  end
  self:SetMinMaxValues(low, high);
  self:SetValueStep(step);
  self:SetStepsPerPage(step);

  if (step < 1) then return; end

  self.GetValueBase = self.GetValue;
  self.GetValue = function()
    local n = self:GetValueBase();
    if (n) then
      local r = round(n);
      if (r ~= n) then
        self:SetValue(n);
      end
      return r;
    end
    return low;
  end;
end


function SMARTBUFF_SetSliderText(self, text, value, valformat, setval)
  if (not self or not value) then return end
  local s;
  if (setval) then self:SetValue(value) end
  if (valformat) then
    s = string.format(valformat, value);
  else
    s = tostring(value);
  end
  _G[self:GetName() .. "Text"]:SetText(text .. " " .. SG.WH .. s .. "|r");
end


function SMARTBUFF_BuffSetup_RBTime_OnValueChanged(self)
  _G[SmartBuff_BuffSetup_RBTime:GetName() .. "Text"]:SetText(SG.WH .. format("%.0f", self:GetValue()) .. "\nsec|r");
end


function SMARTBUFF_SetCheckButtonBuffs(mode)
  local objS;
  local objG;
  local i = 1;
  local ct = SG.currentTemplate;

  if (mode == 0) then
    SMARTBUFF_SetBuffs();
  end

  if (SG.sPlayerClass == "DRUID" or SG.sPlayerClass == "SHAMAN") then
    SmartBuffOptionsFrame_cbInShapeshift:Show();
  else
    SmartBuffOptionsFrame_cbInShapeshift:Hide();
  end

  SMARTBUFF_BuffOrderOnScroll();
end


function SMARTBUFF_DropDownTemplate_OnShow(self)
  local i = 0;
  for _, tmp in pairs(SMARTBUFF_TEMPLATES) do
    i = i + 1;
    --SMARTBUFF_AddMsgD(i .. "." .. tmp);
    if (tmp == SG.currentTemplate) then
      break;
    end
  end
  UIDropDownMenu_Initialize(self, SMARTBUFF_DropDownTemplate_Initialize);
  UIDropDownMenu_SetSelectedValue(SmartBuffOptionsFrame_ddTemplates, i);
  UIDropDownMenu_SetWidth(SmartBuffOptionsFrame_ddTemplates, 135);
end


function SMARTBUFF_DropDownTemplate_Initialize()
  local info = UIDropDownMenu_CreateInfo();
  info.text = ALL;
  info.value = -1;
  info.func = SMARTBUFF_DropDownTemplate_OnClick;
  for k, v in pairs(SMARTBUFF_TEMPLATES) do
    info.text = SMARTBUFF_TEMPLATES[k];
    info.value = k;
    info.func = SMARTBUFF_DropDownTemplate_OnClick;
    info.checked = nil;
    UIDropDownMenu_AddButton(info);
  end
end


function SMARTBUFF_DropDownTemplate_OnClick(self)
  local i = self.value;
  local tmp = nil;
  UIDropDownMenu_SetSelectedValue(SmartBuffOptionsFrame_ddTemplates, i);
  tmp = SMARTBUFF_TEMPLATES[i];
  if (SG.currentTemplate ~= tmp) then
    maybeCopyTemplateOnFirstSwitch(SG.currentTemplate, tmp);
    SmartBuff_BuffSetup:Hide();
    SG.iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();

    SG.currentTemplate = tmp;
    -- SetBuffs must run with the NEW template so SG.B[spec][template] is created; otherwise uninitialized templates show wrong/empty data
    SMARTBUFF_SetBuffs();
    SMARTBUFF_Options_OnShow();
    SG.O.LastTemplate = SG.currentTemplate;
  else
    SMARTBUFF_SetBuffs();
  end
end


-- END Options frame functions


-- Splash screen functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Splash_Show()
  if (not SG.isInit) then return; end
  SMARTBUFF_Splash_ChangeFont(1);
  SmartBuffSplashFrame:EnableMouse(true);
  SmartBuffSplashFrame:Show();
  SmartBuffSplashFrame:SetTimeVisible(60);
  SmartBuffSplashFrameOptions:Show();
end


function SMARTBUFF_Splash_Hide()
  if (not SG.isInit) then return; end
  SMARTBUFF_Splash_Clear();
  SMARTBUFF_Splash_ChangePos();
  SmartBuffSplashFrame:EnableMouse(false);
  SmartBuffSplashFrame:SetFadeDuration(SG.O.SplashDuration);
  SmartBuffSplashFrame:SetTimeVisible(SG.O.SplashDuration);
  SmartBuffSplashFrameOptions:Hide();
end


function SMARTBUFF_Splash_Clear()
  SmartBuffSplashFrame:Clear();
end


function SMARTBUFF_Splash_ChangePos()
  local x, y = SmartBuffSplashFrame:GetLeft(), SmartBuffSplashFrame:GetTop() - UIParent:GetHeight();
  if (SG.O) then
    SG.O.SplashX = x;
    SG.O.SplashY = y;
  end
end


function SMARTBUFF_Splash_ChangeFont(mode)
  local f = SmartBuffSplashFrame;

  if (mode > 1) then
    SMARTBUFF_Splash_ChangePos();
    SG.iCurrentFont = SG.iCurrentFont + 1;
  end
  if (not SG.cFonts[SG.iCurrentFont]) then
    SG.iCurrentFont = 1;
  end
  SG.O.CurrentFont = SG.iCurrentFont;
  f:ClearAllPoints();
  f:SetPoint("TOPLEFT", SG.O.SplashX, SG.O.SplashY);

  local fo = f:GetFontObject();
  local fName, fHeight, fFlags = _G[SG.cFonts[SG.iCurrentFont]]:GetFont();
  if (mode > 1 or SG.O.CurrentFontSize == nil) then
    SG.O.CurrentFontSize = fHeight;
  end
  fo:SetFont(fName, SG.O.CurrentFontSize, fFlags);
  SmartBuffSplashFrameOptions.size:SetValue(SG.O.CurrentFontSize);

  f:SetInsertMode("TOP");
  f:SetJustifyV("MIDDLE");
  if (mode > 0) then
    local si = "";
    if (SG.OG.SplashIcon) then
      local n = SG.O.SplashIconSize;
      if (n == nil or n <= 0) then
        n = SG.O.CurrentFontSize;
      end
      si = string.format(" \124T%s:%d:%d:1:0\124t", "Interface\\Icons\\INV_Misc_QuestionMark", n, n) or "";
    else
      si = " BuffXYZ";
    end
    SMARTBUFF_Splash_Clear();
    if (SG.OG.SplashMsgShort) then
      f:AddMessage(SG.cFonts[SG.iCurrentFont] .. " >" .. si .. "\ndrag'n'drop to move", SG.O.ColSplashFont.r, SG.O.ColSplashFont.g,
        SG.O.ColSplashFont.b, 1.0);
    else
      f:AddMessage(SG.cFonts[SG.iCurrentFont] .. " " .. SMARTBUFF_MSG_NEEDS .. si .. "\ndrag'n'drop to move", SG.O.ColSplashFont
      .r, SG.O.ColSplashFont.g, SG.O.ColSplashFont.b, 1.0);
    end
  end
end


-- END Splash screen events


-- Playerlist functions ---------------------------------------------------------------------------------------
function SMARTBUFF_PlayerSetup_OnShow()
end


function SMARTBUFF_PlayerSetup_OnHide()
end


function SMARTBUFF_PS_GetList()
  if (SG.iLastBuffSetup <= 0) then return {} end

  local name = SG.cBuffs[SG.iLastBuffSetup].BuffS;
  if (name) then
    local cBuff = getBuffSettings(name);
    if (cBuff) then
      if (SG.iCurrentList == 1) then
        if (not cBuff.AddList) then cBuff.AddList = {}; end
        return cBuff.AddList;
      else
        if (not cBuff.IgnoreList) then cBuff.IgnoreList = {}; end
        return cBuff.IgnoreList;
      end
    end
  end
  return {};
end


function SMARTBUFF_PS_GetUnitList()
  if (SG.iCurrentList == 1) then
    return SG.cAddUnitList;
  else
    return SG.cIgnoreUnitList;
  end
end


function SMARTBUFF_PS_Show(i)
  SG.iCurrentList = i;
  SG.iLastPlayer = -1;
  local obj = SmartBuff_PlayerSetup_Title;
  if (SG.iCurrentList == 1) then
    obj:SetText("Additional list");
  else
    obj:SetText("Ignore list");
  end
  obj:ClearFocus();
  SmartBuff_PlayerSetup_EditBox:ClearFocus();
  SmartBuff_PlayerSetup:Show();
  SMARTBUFF_PS_SelectPlayer(0);
end


function SMARTBUFF_PS_AddPlayer()
  local cList = SMARTBUFF_PS_GetList();
  local un = UnitName("target");
  if (un and (UnitInRaid("target") or UnitInParty("target") or SG.O.Debug)) then
    if (not cList[un]) then
      cList[un] = true;
      SMARTBUFF_PS_SelectPlayer(0);
    end
  end
end


function SMARTBUFF_PS_RemovePlayer()
  local n = 0;
  local cList = SMARTBUFF_PS_GetList();
  for player in pairs(cList) do
    n = n + 1;
    if (n == SG.iLastPlayer) then
      cList[player] = nil;
      break;
    end
  end
  SMARTBUFF_PS_SelectPlayer(0);
end


function SMARTBUFF_PS_ClearList()
  local cList = SMARTBUFF_PS_GetList();
  for k in pairs(cList) do
    cList[k] = nil;
  end
  if (SG.iCurrentList == 1) then
    wipe(SG.cAddUnitList);
  else
    wipe(SG.cIgnoreUnitList);
  end
  SMARTBUFF_PS_SelectPlayer(0);
end


function SMARTBUFF_AddToUnitList(idx, unit, subgroup)
  SG.iCurrentList = idx;
  local cList = SMARTBUFF_PS_GetList();
  local cUnitList = SMARTBUFF_PS_GetUnitList();
  if (unit and subgroup) then
    local un = UnitName(unit);
    if (un and cList[un]) then
      cUnitList[unit] = subgroup;
      --SMARTBUFF_AddMsgD("Added to UnitList:" .. un .. "(" .. unit .. ")");
    end
  end
end


function SMARTBUFF_PS_SelectPlayer(iOp)
  local idx = SG.iLastPlayer + iOp;
  local cList = SMARTBUFF_PS_GetList();
  local s = "";

  local tn = 0;
  for player in pairs(cList) do
    tn = tn + 1;
    s = s .. player .. "\n";
  end

  -- update list in textbox
  if (iOp == 0) then
    SmartBuff_PlayerSetup_EditBox:SetText(s);
    --SmartBuff_PlayerSetup_EditBox:ClearFocus();
  end

  -- highlight selected player
  if (tn > 0) then
    if (idx > tn) then idx = tn; end
    if (idx < 1) then idx = 1; end
    SG.iLastPlayer = idx;
    --SmartBuff_PlayerSetup_EditBox:ClearFocus();
    local n = 0;
    local i = 0;
    local w = 0;
    for player in pairs(cList) do
      n = n + 1;
      w = string.len(player);
      if (n == idx) then
        SmartBuff_PlayerSetup_EditBox:HighlightText(i + n - 1, i + n + w);
        break;
      end
      i = i + w;
    end
  end
end


function SMARTBUFF_PS_Resize()
  local h = SmartBuffOptionsFrame:GetHeight();
  local b = true;

  if (h < 200) then
    SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    b = true;
  else
    SmartBuffOptionsFrame:SetHeight(40);
    --SmartBuff_BuffSetup:SetHeight(40);
    b = false;
  end
  SMARTBUFF_ShowControls("SmartBuffOptionsFrame", b);
  if (b) then
    SMARTBUFF_SetCheckButtonBuffs(1);
  end
end


-- END secure button functions


-- Minimap button (LibDBIcon). Uses the original MiniMapButtonEnabled / Disabled textures.
local MINIMAP_ICON = "SmartBuff";

local function SMARTBUFF_MinimapAngleFromSavedOffset()
  if (not SG.O.MMCPosX or not SG.O.MMCPosY or not Minimap) then return nil; end
  local w = Minimap:GetWidth();
  local h = Minimap:GetHeight();
  if (not w or not h or w <= 0 or h <= 0) then return nil; end
  local cx = SG.O.MMCPosX + 16 - (w / 2);
  local cy = (h / 2) + SG.O.MMCPosY - 16;
  return math.deg(math.atan2(cy, cx)) % 360;
end

function SMARTBUFF_InitMinimapButton()
  if (SG.minimapReady) then return; end
  local ldb = LibStub and LibStub("LibDataBroker-1.1", true);
  local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true);
  if (not ldb or not ldbIcon) then return; end
  local obj = ldb:GetDataObjectByName(MINIMAP_ICON);
  if (not obj) then return; end

  SG.O.Minimap = SG.O.Minimap or {};
  SG.O.Minimap.hide = SG.O.HideMmButton and true or false;
  if (SG.O.Minimap.minimapPos == nil) then
    SG.O.Minimap.minimapPos = SMARTBUFF_MinimapAngleFromSavedOffset() or 0;
  end

  if (not ldbIcon:IsRegistered(MINIMAP_ICON)) then
    ldbIcon:Register(MINIMAP_ICON, obj, SG.O.Minimap);
  else
    ldbIcon:Refresh(MINIMAP_ICON, SG.O.Minimap);
  end
  -- The saved art is the full round button, so drop LibDBIcon's own ring and fill the button.
  -- Avoid SetButtonIcon/ResetButtonIcon: Forever textures may not keep UpdateCoord and that
  -- used to error mid-Options_Init and leave the rest of the addon uninitialized.
  ldbIcon:RemoveButtonBorder(MINIMAP_ICON);
  ldbIcon:RemoveButtonBackground(MINIMAP_ICON);
  ldbIcon:SetButtonSize(MINIMAP_ICON, 32);
  local button = ldbIcon:GetMinimapButton(MINIMAP_ICON);
  if (button and button.icon) then
    if (obj.icon) then button.icon:SetTexture(obj.icon); end
    button.icon:ClearAllPoints();
    button.icon:SetPoint("CENTER", 0, 0);
    button.icon:SetSize(32, 32);
    button.icon:SetTexCoord(0, 1, 0, 1);
    button:HookScript("OnMouseDown", function(self)
      if (self.icon) then self.icon:SetTexCoord(0, 1, 0, 1); end
    end);
    button:HookScript("OnMouseUp", function(self)
      if (self.icon) then self.icon:SetTexCoord(0, 1, 0, 1); end
    end);
  end
  SG.minimapReady = true;
end

function SMARTBUFF_CheckMiniMapButton()
  SMARTBUFF_BROKER_SetIcon();

  local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true);
  if (ldbIcon and ldbIcon:IsRegistered(MINIMAP_ICON)) then
    if (SG.O.Minimap) then
      SG.O.Minimap.hide = SG.O.HideMmButton and true or false;
    end
    if (SG.O.HideMmButton) then
      ldbIcon:Hide(MINIMAP_ICON);
    else
      ldbIcon:Show(MINIMAP_ICON);
    end
  end

  -- Update the Titan Panel icon
  if (TitanPanelBarButton and TitanPanelSmartBuffButton_SetIcon ~= nil) then
    TitanPanelSmartBuffButton_SetIcon();
  end

  -- Update the FuBar icon
  if (C_AddOns.IsAddOnLoaded("FuBar") and C_AddOns.IsAddOnLoaded("FuBar_SmartBuffFu") and SMARTBUFF_Fu_SetIcon ~= nil) then
    SMARTBUFF_Fu_SetIcon();
  end
end



-- Scroll frame functions ---------------------------------------------------------------------------------------

local ScrBtnSize = 20;
local ScrIconSize = 16;
local ScrIconPad = 2;
local ScrLineHeight = 18;
function setPosScrollButtons(parent, cBtn)
  local btn;
  local name;
  for i = 1, #cBtn, 1 do
    btn = cBtn[i];
    btn:ClearAllPoints();
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2 - ScrLineHeight * (i - 1));
  end
end


local StartY, EndY;

-- Paladin blessing/aura rows: hide checkbox art, show a cog in the same slot (icon/name stay aligned).
function SMARTBUFF_SetBuffOrderRowMode(btn, isAssign)
  if (not btn) then return; end
  local function setTexAlpha(tex, a)
    if (tex) then tex:SetAlpha(a); end
  end
  if (isAssign) then
    setTexAlpha(btn:GetNormalTexture(), 0);
    setTexAlpha(btn:GetPushedTexture(), 0);
    setTexAlpha(btn:GetCheckedTexture(), 0);
    setTexAlpha(btn:GetDisabledCheckedTexture(), 0);
    btn:SetChecked(false);
    if (btn.cog) then btn.cog:Show(); end
  else
    if (btn.cog) then btn.cog:Hide(); end
    setTexAlpha(btn:GetNormalTexture(), 1);
    setTexAlpha(btn:GetPushedTexture(), 1);
    setTexAlpha(btn:GetCheckedTexture(), 1);
    setTexAlpha(btn:GetDisabledCheckedTexture(), 1);
  end
end

function createScrollButton(name, parent, cBtn, onClick, onDragStop)
  local btn = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate");
  btn:SetWidth(ScrBtnSize);
  btn:SetHeight(ScrBtnSize);
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp");
  btn:SetScript("OnClick", onClick);
  --  btn:SetScript("OnMouseUp", onClick);

  if (onDragStop ~= nil) then
    btn:SetMovable(true);
    btn:RegisterForDrag("LeftButton");
    btn:SetScript("OnDragStart", function(self, b)
      StartY = self:GetTop();
      self:StartMoving();
    end
    );
    btn:SetScript("OnDragStop", function(self, b)
      EndY = self:GetTop();
      local i = tonumber(self:GetID()) + FauxScrollFrame_GetOffset(parent);
      local n = math.floor((StartY - EndY) / ScrLineHeight);
      self:StopMovingOrSizing();
      setPosScrollButtons(parent, cBtn);
      onDragStop(i, n);
    end
    );
  end

  local cog = btn:CreateTexture(nil, "OVERLAY");
  cog:SetSize(ScrBtnSize, ScrBtnSize);
  cog:SetPoint("CENTER", btn, "CENTER", 0, 0);
  cog:SetTexture("Interface\\Buttons\\UI-OptionsButton");
  cog:Hide();
  btn.cog = cog;

  -- Spell/ability/item icon after the checkbox, before the name.
  local icon = btn:CreateTexture(nil, "ARTWORK");
  icon:SetSize(ScrIconSize, ScrIconSize);
  icon:SetPoint("LEFT", btn, "RIGHT", ScrIconPad, 0);
  btn.icon = icon;

  local text = btn:CreateFontString(nil, nil, "GameFontNormal");
  text:SetJustifyH("LEFT");
  text:SetPoint("LEFT", icon, "RIGHT", ScrIconPad, 0);
  text:SetWidth(parent:GetWidth() - ScrBtnSize - ScrIconSize - (ScrIconPad * 2));
  text:SetHeight(ScrBtnSize);
  btn:SetFontString(text);
  btn:SetHighlightFontObject("GameFontHighlight");

  local highlight = btn:CreateTexture();
  highlight:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -2);
  highlight:SetWidth(parent:GetWidth());
  highlight:SetHeight(ScrLineHeight - 3);

  highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight");
  btn:SetHighlightTexture(highlight);

  return btn;
end



function createScrollButtons(self, cBtn, sBtnName, onClick, onDragStop)
  local btn, i;
  for i = 1, SG.maxScrollButtons, 1 do
    btn = createScrollButton(sBtnName .. i, self, cBtn, onClick, onDragStop);
    btn:SetID(i);
    cBtn[i] = btn;
  end
  setPosScrollButtons(self, cBtn);
end



function onScroll(self, cData, sBtnName)
  local num = #cData;
  local n, numToDisplay;

  if (num <= SG.maxScrollButtons) then
    numToDisplay = num - 1;
  else
    numToDisplay = SG.maxScrollButtons;
  end

  FauxScrollFrame_Update(self, num, floor(numToDisplay / 3 + 0.5), ScrLineHeight);
  -- [SG.B]ufflist for current spec, current template; use getBuffSettings so item keys (link vs item:ID) resolve to same entry
  local t = buffsTemplateTable();
  for i = 1, SG.maxScrollButtons, 1 do
    n = i + FauxScrollFrame_GetOffset(self);
    btn = _G[sBtnName .. i];
    if (btn) then
      if (n <= num and t ~= nil) then
        btn:SetNormalFontObject("GameFontNormalSmall");
        btn:SetHighlightFontObject("GameFontHighlightSmall");
        local idx = SG.cBuffIndex[cData[n]];
        local cBI = idx and SG.cBuffs[idx];
        local btype = cBI and cBI.Type or nil;
        local displayName = getBuffDisplayName(cData[n], btype);
        if (cBI and cBI.SingleTargetGroup) then
          displayName = displayName .. " - single";
        end
        btn:SetText(displayName);
        if (btn.icon) then
          local iconTex = cBI and cBI.IconS;
          if (iconTex) then
            btn.icon:SetTexture(iconTex);
            btn.icon:Show();
          else
            btn.icon:SetTexture(nil);
            btn.icon:Hide();
          end
        end
        local bs = getBuffSettings(cData[n]);
        local isAssign = (SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(cData[n]));
        SMARTBUFF_SetBuffOrderRowMode(btn, isAssign);
        if (isAssign) then
          btn:SetChecked(false);
        elseif (bs) then
          btn:SetChecked(bs.EnableS);
        else
          btn:SetChecked(false);
        end
        btn:Show();
      else
        btn:Hide();
      end
    end
  end
end



function SMARTBUFF_BuffOrderOnScroll(self, arg1)
  if (not self) then
    self = SmartBuffOptionsFrame_ScrollFrameBuffs;
  end

  local name = "SMARTBUFF_BtnScrollBO";
  if (not SG.cScrBtnBO and self) then
    SG.cScrBtnBO = {};
    createScrollButtons(self, SG.cScrBtnBO, name, SMARTBUFF_BuffOrderBtnOnClick, SMARTBUFF_BuffOrderBtnOnDragStop);
  end

  SMARTBUFF_EnsureSpecTable(getCurrentSpec());
  if (SG.B[getCurrentSpec()].Order == nil) then
    SG.B[getCurrentSpec()].Order = {};
  end

  local t = {};
  for _, v in pairs(SG.B[getCurrentSpec()].Order) do
    if (v) then
      tinsert(t, v);
    end
  end
  onScroll(self, t, name);
end


-- Left click toggles buff enable; right click opens buff options (checkbox state restored so it does not toggle).
-- Guards (i and i > 0) avoid nil index if order/index is out of sync when the row is clicked.
-- Paladin blessings/auras open the assignments window instead of BuffSetup; EnableS is left unchanged.
function SMARTBUFF_BuffOrderBtnOnClick(self, button)
  local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
  local ord = SG.B[getCurrentSpec()].Order;
  local buffnS = ord and ord[n];
  local i = buffnS and SG.cBuffIndex[buffnS];
  if (i and i > 0 and SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(buffnS)) then
    if (SMARTBUFF_PaladinAssign_Show) then SMARTBUFF_PaladinAssign_Show(); end
    local bs = getBuffSettings(buffnS);
    self:SetChecked(bs and bs.EnableS);
    return;
  end
  if (button == "LeftButton") then
    if (i and i > 0) then SMARTBUFF_OToggleBuff("S", i); end
  else
    if (i and i > 0) then
      SMARTBUFF_BuffSetup_Show(i);
      local bs = getBuffSettings(buffnS);
      self:SetChecked(bs and bs.EnableS);
    end
  end
end


function SMARTBUFF_BuffOrderBtnOnDragStop(i, n)
  treorder(SG.B[getCurrentSpec()].Order, i, n);
  SMARTBUFF_BuffOrderOnScroll();
end


-- Reset List: buff order/sorting only (SG.B[].Order); no options or buff profiles.
function SMARTBUFF_BuffOrderReset()
  SMARTBUFF_InvalidateBuffCache();
  initBuffOrder(true);
  SMARTBUFF_BuffOrderOnScroll();
end





