-------------------------------------------------------------------------------
-- SmartBuff
-- Originally created by Aeldra (EU-Proudmoore)
-- Forever / Classic versions by Codermik & Speedwaystar
-- Discord: https://discord.gg/R6EkZ94TKK
-- Cast the most important buffs on you, tanks or party/raid members/pets.
-------------------------------------------------------------------------------

-- Changes to SMARTBUFF_VERSION will pop up a 'what's new'
-- and options frame on first load... could be annoying if done too often
-- What's new is pulled from the SMARTBUFF_WHATSNEW string in localization.en.lua
-- this is mostly optional, but good for internal housekeeping
SMARTBUFF_VERSION            = "r1.121126"; -- Forever
-- Update the NR below to force reload of SB_Buffs on first login
-- This is now OPTIONAL for most changes - only needed for major logical reworks or large patch changes.
-- Definition changes (spell IDs, Links, Chain) in buffs.lua no longer require version bumps.
-- Profile logic changes and buff definition updates are handled automatically without requiring version bumps.
SMARTBUFF_VERSIONNR          = 1;
-- End of version info

local SG = SMARTBUFF_GLOBALS;

-- Buff definitions store the caster's training level for each spell rank, but
-- friendly targets can receive beneficial ranks up to 10 levels earlier.
local BUFF_TARGET_LEVEL_ALLOWANCE = 10;

-- Classic Forever: dual talent groups (retail GetSpecialization is unavailable)
function SMARTBUFF_GetActiveTalentGroup()
  local fn = _G.GetActiveTalentGroup or _G.GetSpecialization;
  if (fn) then
    local n = fn();
    if (type(n) == "number" and n >= 1) then return n; end
  end
  return 1;
end

function SMARTBUFF_GetNumTalentGroups()
  local fn = _G.GetNumTalentGroups or _G.GetNumSpecGroups;
  if (fn) then
    local n = fn();
    if (type(n) == "number" and n >= 1) then return n; end
  end
  return 1;
end

function SMARTBUFF_DeepCopyTable(src)
  if (type(src) ~= "table") then return src; end
  local dst = {};
  for k, v in pairs(src) do
    if (type(v) == "table") then
      dst[k] = SMARTBUFF_DeepCopyTable(v);
    else
      dst[k] = v;
    end
  end
  return dst;
end

function SMARTBUFF_SpecTableHasBuffData(specTbl)
  if (type(specTbl) ~= "table") then return false; end
  if (type(specTbl.Order) == "table" and next(specTbl.Order)) then return true; end
  for k, v in pairs(specTbl) do
    if (k ~= "Order" and type(v) == "table") then
      for bk, bv in pairs(v) do
        if (bk ~= "SelfFirst" and type(bv) == "table") then return true; end
      end
    end
  end
  return false;
end

-- Ensure SG.B[specIndex] exists; seed from another populated talent group when empty.
function SMARTBUFF_EnsureSpecTable(specIndex)
  if (not SG.B) then SG.B = {}; end
  specIndex = specIndex or SMARTBUFF_GetActiveTalentGroup();
  if (SMARTBUFF_SpecTableHasBuffData(SG.B[specIndex])) then
    return SG.B[specIndex];
  end
  local src;
  for n = 1, SMARTBUFF_GetNumTalentGroups() do
    if (n ~= specIndex and SMARTBUFF_SpecTableHasBuffData(SG.B[n])) then
      src = SG.B[n];
      break;
    end
  end
  if (src) then
    SG.B[specIndex] = SMARTBUFF_DeepCopyTable(src);
  elseif (type(SG.B[specIndex]) ~= "table") then
    SG.B[specIndex] = {};
  end
  return SG.B[specIndex];
end

-- Flat SG.B["Solo"] → SG.B[1|2]["Solo"] with deep copy (old path shared refs then wiped them).
function SMARTBUFF_MigrateToDualSpec()
  if (not SG.B or not SG.O) then return; end
  local hasFlat = false;
  if (SMARTBUFF_TEMPLATES) then
    for _, v in pairs(SMARTBUFF_TEMPLATES) do
      if (type(v) == "string" and type(SG.B[v]) == "table") then
        hasFlat = true;
        break;
      end
    end
  end
  if (hasFlat) then
    local num = SMARTBUFF_GetNumTalentGroups();
    for n = 1, num do
      if (type(SG.B[n]) ~= "table") then SG.B[n] = {}; end
      for _, v in pairs(SMARTBUFF_TEMPLATES) do
        if (type(v) == "string" and type(SG.B[v]) == "table") then
          SG.B[n][v] = SMARTBUFF_DeepCopyTable(SG.B[v]);
        end
      end
    end
    for _, v in pairs(SMARTBUFF_TEMPLATES) do
      if (type(v) == "string" and SG.B[v] ~= nil) then
        SG.B[v] = nil;
      end
    end
    SG.O.UpgradeToDualSpec = true;
    if (SMARTBUFF_AddMsg) then SMARTBUFF_AddMsg("Upgraded to dual spec", true); end
  elseif (SG.O.UpgradeToDualSpec == nil) then
    for n = 1, SMARTBUFF_GetNumTalentGroups() do
      if (type(SG.B[n]) ~= "table") then SG.B[n] = {}; end
    end
    SG.O.UpgradeToDualSpec = true;
  end
  for n = 1, SMARTBUFF_GetNumTalentGroups() do
    SMARTBUFF_EnsureSpecTable(n);
  end
end

SMARTBUFF_TITLE              = "SmartBuff";
SMARTBUFF_SUBTITLE           = "Supports you in casting buffs";
SMARTBUFF_DESC               = "Cast the most important buffs on you, your tanks, party/raid members/pets";
SMARTBUFF_VERS_TITLE         = SMARTBUFF_TITLE .. " " .. SMARTBUFF_VERSION;
SMARTBUFF_OPTIONS_TITLE      = SMARTBUFF_VERS_TITLE .. " Forever ";

-- Profession tool slots (Razorstone: same role as INVSLOT_MAINHAND / INVSLOT_OFFHAND for weapon buffs)
INVSLOT_PROF1_TOOL           = 23;  -- Top main profession tool slot
INVSLOT_PROF2_TOOL           = 20;  -- Second main profession tool slot

-- Assemble SMARTBUFF_TEMPLATES from generics + instances + custom (localization sets the three parts).
-- Order matters: generics first, then instances, then custom. Matches Enum.SmartBuffGroup.
do
  SMARTBUFF_TEMPLATES = {}
  for _, src in ipairs({SMARTBUFF_TEMPLATES_GENERICS, SMARTBUFF_TEMPLATES_INSTANCES, SMARTBUFF_TEMPLATES_CUSTOM}) do
    for _, v in ipairs(src) do table.insert(SMARTBUFF_TEMPLATES, v) end
  end
end

-- addon name
local addonName              = ...
local SmartbuffPrefix        = "Smartbuff";
local SmartbuffSession       = true;
local SmartbuffVerCheck      = false; -- for my use when checking guild users/testers versions  :)
local buildInfo              = select(4, GetBuildInfo())
local SmartbuffVerNotifyList = {}

-- Shared runtime state for Cast.lua / Buff.lua / Options.lua
if (not SG._foreverReady) then
  SG._foreverReady = true;
end

SG.OG                     = nil; -- Options global
SG.O                      = nil; -- Options local
SG.B                      = nil; -- Buff settings local
local _;

-- Ensure SavedVariables exist when nil (new install or deleted SavedVariables)
if (type(SMARTBUFF_Options) ~= "table") then SMARTBUFF_Options = {}; end
if (type(SMARTBUFF_Buffs) ~= "table") then SMARTBUFF_Buffs = {}; end
if (type(SMARTBUFF_OptionsGlobal) ~= "table") then
  SMARTBUFF_OptionsGlobal = {};
  SMARTBUFF_OptionsGlobal.FirstStart = "V0";  -- so Options_Init sees version "changed" and pops options + news
end
-- Bind early so splash/reminders never see SG.OG == nil if Options_Init errors mid-way.
SG.OG = SMARTBUFF_OptionsGlobal;
if (SG.OG.SplashIcon == nil) then SG.OG.SplashIcon = true; end
if (SG.OG.SplashMsgShort == nil) then SG.OG.SplashMsgShort = false; end

SG.GlobalCd               = 1.5;
SG.maxSkipCoolDown        = 3;
SG.maxRaid                = 40;
SG.maxBuffs               = 40;
SG.maxScrollButtons       = 33;
SG.numBuffs               = 0;

SG.isLoaded               = false;
SG.isPlayer               = false;
SG.isInit                 = false;
SG.isCombat               = false;
SG.isSetBuffs             = false;
SG.isSetZone              = false;
SG.isFirstError           = false;
SG.isMounted              = false;
SG.isSitting              = false;
SG.isCTRA                 = true;
SG.isKeyUpChanged         = false;
SG.isKeyDownChanged       = false;
SG.isAuraChanged          = false;
SG.isClearSplash          = false;
SG.isRebinding            = false;
SG.isParrot               = false;
SG.isSync                 = false;
SG.isSyncReq              = false;
SG.isInitBtn              = false;
SG.scrollSkipZoom         = false; -- true after scroll PreClick queued a buff (suppress CameraZoom for this notch)
SG.scrollZoomDone         = false; -- zoom at most once per mousewheel notch (down+up)

SG.isShapeshifted         = false;
SG.sShapename             = "";

SG.tStartZone             = 0;
SG.tTicker                = 0;
SG.tSync                  = 0;
SG.setBuffsPending          = false;  -- SMARTBUFF_ScheduleSetBuffs: one timer at a time
SG.buffOrderScrollScheduled = false;  -- SMARTBUFF_ScheduleBuffOrderOnScroll (coalesced redraw)

SG.sRealmName             = nil;
SG.sPlayerName            = nil;
SG.sID                    = nil;
SG.sPlayerClass           = nil;
SG.tLastCheck             = 0;
SG.iLastBuffSetup         = -1;
SG.sLastTexture           = "";
SG.iLastGroupSetup        = -99;
SG.sLastZone              = "";
SG.tAutoBuff              = 0;
SG.tDebuff                = 0;
SG.sMsgWarning            = "";
SG.iCurrentFont           = 6;
SG.iCurrentList           = -1;
SG.iLastPlayer            = -1;

SG.isPlayerMoving         = false;

SG.cGroups                = {};
SG.cClassGroups           = {};
SG.cBuffs                 = {};
SG.cBuffIndex             = {};
SG.cBuffTimer             = {};
SG.cBlocklist             = {};
SG.cUnits                 = {};
SG.cBuffsToCastAfterBGRes = {};  -- Queue of {actionType, spellName, slot} for post-resurrection in BG (aura state secret)
-- Throttle SetMissingBuffMessage for in-combat castsequence (per next-spell key + AutoTimer) to avoid spam every Check tick.
SG.lastInCombatCastsequenceNotifyKey = nil;
SG.lastInCombatCastsequenceNotifyAt = 0;
-- Debounce duplicate UNIT_SPELLCAST_SUCCEEDED for in-combat castsequence index advance.
SG.inCombatCastsequenceLastSucceededAt = 0;
SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_POP_DEBOUNCE = 0.35;
-- SG.O.InCombat CIn path: KeyButton holds /castsequence reset=combat ... (non-PvP instance or arena/BG prep; off during active match).
SG.inCombatCastsequenceActive = false;
SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_MACRO_MAX = 255;
-- Invalid spell name appended to /castsequence: sequence sticks here after real casts until reset=combat (no wrap to spell 1).
SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_SENTINEL = "null";
-- Snapshot of spell names in the macro (after truncation), in cast order; UNIT_SPELLCAST_SUCCEEDED advances next index.
SG.inCombatCastsequenceExpectedSpells = {};
SG.inCombatCastsequenceNextIndex = 1;
SG.inCombatCastsequenceAllDone = false;



SG.cScrBtnBO              = nil;

SG.cAddUnitList           = {};
SG.cIgnoreUnitList        = {};

SG.cClasses               = { "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
  "HPET", "WPET", "TANK", "HEALER", "DAMAGER" };
SG.cOrderGrp              = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
SG.cFonts                 = { "NumberFontNormal", "NumberFontNormalLarge", "NumberFontNormalHuge", "GameFontNormal",
  "GameFontNormalLarge", "GameFontNormalHuge", "ChatFontNormal", "QuestFont", "MailTextFontNormal", "QuestTitleFont" };

SG.currentUnit            = nil;
SG.currentSpell           = nil;
SG.pendingCastSpellID     = nil; -- rank-specific spell ID for the next secure-button cast
SG.SpellRanks             = nil; -- [lower spell name] = { {spellID, rank, order}, ... } low to high
SG.tCastRequested         = 0;
SG.tLastBuffAttempt       = 0;  -- when > 0, next UI_ERROR_MESSAGE within 1.5s (one GCD) is printed to chat (spell or item)
SG.sHunterPetNeedsRevive  = false; -- Call Pet row should cast Revive Pet (dead pet or UI error hint)
SG.sHunterReviveTimerOrderKey = nil; -- Order buff name for SG.cBuffTimer when cast spell is Revive Pet
SG.currentTemplate        = nil;
SG.currentSpec            = nil;

SG.imgSB                  = "Interface\\Icons\\Spell_Nature_Purge";
SG.imgIconOn              = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
SG.imgIconOff             = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";

SG.IconPaths              = {
  ["Pet"]      = "Interface\\Icons\\spell_nature_spiritwolf",
  ["Roles"]    = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
  ["Classes"]  = "Interface\\WorldStateFrame\\Icons-Classes",
};

SG.Icons                  = {
  ["WARRIOR"]     = { SG.IconPaths.Classes, 0.00, 0.25, 0.00, 0.25 },
  ["MAGE"]        = { SG.IconPaths.Classes, 0.25, 0.50, 0.00, 0.25 },
  ["ROGUE"]       = { SG.IconPaths.Classes, 0.50, 0.75, 0.00, 0.25 },
  ["DRUID"]       = { SG.IconPaths.Classes, 0.75, 1.00, 0.00, 0.25 },
  ["HUNTER"]      = { SG.IconPaths.Classes, 0.00, 0.25, 0.25, 0.50 },
  ["SHAMAN"]      = { SG.IconPaths.Classes, 0.25, 0.50, 0.25, 0.50 },
  ["PRIEST"]      = { SG.IconPaths.Classes, 0.50, 0.75, 0.25, 0.50 },
  ["WARLOCK"]     = { SG.IconPaths.Classes, 0.75, 1.00, 0.25, 0.50 },
  ["PALADIN"]     = { SG.IconPaths.Classes, 0.00, 0.25, 0.50, 0.75 },
  ["PET"]         = { SG.IconPaths.Pet, 0.08, 0.92, 0.08, 0.92 },
  ["TANK"]        = { SG.IconPaths.Roles, 0.0, 19 / 64, 22 / 64, 41 / 64 },
  ["HEALER"]      = { SG.IconPaths.Roles, 20 / 64, 39 / 64, 1 / 64, 20 / 64 },
  ["DAMAGER"]     = { SG.IconPaths.Roles, 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
  ["NONE"]        = { SG.IconPaths.Roles, 20 / 64, 39 / 64, 22 / 64, 41 / 64 },
};

-- Bundled splash sounds (Interface\AddOns\SmartBuff\Sounds\)
SG.soundPath = "Interface\\AddOns\\SmartBuff\\Sounds\\";
SG.Sounds = {
  "Smartbuff_Aggro-Warning.ogg",
  "Smartbuff_Dungeon-Ready.ogg",
  "Smartbuff_Emote-Whistle.ogg",
  "Smartbuff_Female-Sigh.ogg",
  "Smartbuff_FluteRun.ogg",
  "Smartbuff_Kologarn-Slay.ogg",
  "Smartbuff_LFG-Rewards.ogg",
  "Smartbuff_Male-Sigh.ogg",
  "Smartbuff_Millhouse-Manastorm-Oh.ogg",
  "Smartbuff_Millhouse-Manastorm-Warn.ogg",
  "Smartbuff_Peasant-Pissed.ogg",
  "Smartbuff_Player-Blind.ogg",
  "Smartbuff_PVP-Warning.ogg",
  "Smartbuff_You-Are-Weak.ogg",
};

SG.LSM = LibStub:GetLibrary("LibSharedMedia-3.0", true);
SG.SoundList = SG.SoundList or {};
SG.DefaultSoundName = "Smartbuff_Player-Blind";
SG.DefaultSoundKey = "SmartBuff: " .. SG.DefaultSoundName;

-- Builds a LibSharedMedia sound key from a bundled filename.
local function SG_SoundKeyFromFile(file)
  return "SmartBuff: " .. (file:gsub("%.ogg$", ""):gsub("%.mp3$", ""));
end

function SG.FindDefaultSoundIndex(list)
  list = list or SG.SoundList;
  if (not list) then return 1; end
  local needle = SG.DefaultSoundName;
  for i, key in ipairs(list) do
    if (key == SG.DefaultSoundKey or (type(key) == "string" and key:find(needle, 1, true))) then
      return i;
    end
  end
  return 1;
end

function SG.RebuildSoundList()
  if (SG.LSM) then
    SG.SoundList = SG.LSM:List("sound") or {};
    local filtered = {};
    for _, key in ipairs(SG.SoundList) do
      if (key ~= "None") then
        filtered[#filtered + 1] = key;
      end
    end
    SG.SoundList = filtered;
  else
    SG.SoundList = {};
    for i, file in ipairs(SG.Sounds) do
      SG.SoundList[i] = SG_SoundKeyFromFile(file);
    end
  end
end

function SG.InitSharedMediaSounds()
  if (SG._lsmSoundsReady) then
    SG.RebuildSoundList();
    return;
  end
  SG._lsmSoundsReady = true;

  if (SG.LSM) then
    for _, file in ipairs(SG.Sounds) do
      local key = SG_SoundKeyFromFile(file);
      if (not SG.LSM:IsValid("sound", key)) then
        SG.LSM:Register(SG.LSM.MediaType.SOUND, key, SG.soundPath .. file);
      end
    end
    SG.LSM.RegisterCallback(SG, "LibSharedMedia_Registered", function(_, mediatype)
      if (mediatype == "sound") then
        SG.RebuildSoundList();
        if (SmartBuffOptionsFrame_ddSounds and SmartBuffOptionsFrame and SmartBuffOptionsFrame:IsVisible()) then
          SMARTBUFF_UpdateSoundDropdown();
        end
      end
    end);
  end

  SG.RebuildSoundList();
end

function SG.GetSoundDisplayName(index)
  if (SG.SoundList and SG.SoundList[index]) then
    return SG.SoundList[index];
  end
  return tostring(index or "?");
end

function SG.ResolveSoundIndex()
  SG.RebuildSoundList();
  local list = SG.SoundList;
  local count = list and #list or 0;
  if (count == 0) then
    return 1;
  end

  if (SG.O and SG.O.AutoSoundKey) then
    for i, key in ipairs(list) do
      if (key == SG.O.AutoSoundKey) then
        return i;
      end
    end
  end

  -- Legacy numeric index into bundled SG.Sounds (not into LSM list order)
  local legacyIdx = SG.O and SG.O.AutoSoundSelection;
  if (type(legacyIdx) == "number" and SG.Sounds[legacyIdx]) then
    local legacyFile = SG.Sounds[legacyIdx]:lower();
    local legacyStem = legacyFile:gsub("%.ogg$", ""):gsub("%.mp3$", "");
    if (SG.LSM) then
      for i, key in ipairs(list) do
        local path = SG.LSM:Fetch("sound", key);
        if (type(path) == "string" and path:lower():find(legacyFile, 1, true)) then
          return i;
        end
      end
    end
    for i, key in ipairs(list) do
      if (type(key) == "string" and key:lower():find(legacyStem, 1, true)) then
        return i;
      end
    end
  end

  return SG.FindDefaultSoundIndex(list);
end

function SG.SetSoundSelection(index)
  if (not SG.O) then return; end
  SG.RebuildSoundList();
  local count = SG.SoundList and #SG.SoundList or 0;
  if (count < 1) then return; end
  if (not index or index < 1) then index = SG.FindDefaultSoundIndex(); end
  if (index > count) then index = count; end
  SG.O.AutoSoundSelection = index;
  SG.O.AutoSoundKey = SG.SoundList[index];
end

function SG.PlaySplashSoundMedia(media)
  if (not media) then return; end
  if (type(media) == "number") then
    PlaySound(media);
  else
    PlaySoundFile(media);
  end
end

function SG.PlaySplashSound()
  if (not SG.O) then return; end
  local idx = SG.ResolveSoundIndex();
  local key = SG.SoundList and SG.SoundList[idx];
  if (key and SG.LSM) then
    SG.PlaySplashSoundMedia(SG.LSM:Fetch("sound", key));
    return;
  end
  if (SG.Sounds and SG.O.AutoSoundSelection and SG.Sounds[SG.O.AutoSoundSelection]) then
    PlaySoundFile(SG.soundPath .. SG.Sounds[SG.O.AutoSoundSelection]);
  end
end

local DebugChatFrame = DEFAULT_CHAT_FRAME;

-- Popup reset all data
StaticPopupDialogs["SMARTBUFF_DATA_PURGE"] = {
  text = SMARTBUFF_OFT_PURGE_DATA,
  button1 = SMARTBUFF_OFT_YES,
  button2 = SMARTBUFF_OFT_NO,
  OnAccept = function() SMARTBUFF_ResetAll() end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

-- Popup reset buffs
StaticPopupDialogs["SMARTBUFF_BUFFS_PURGE"] = {
  text = SMARTBUFF_OFT_PURGE_BUFFS,
  button1 = SMARTBUFF_OFT_YES,
  button2 = SMARTBUFF_OFT_NO,
  OnAccept = function() SMARTBUFF_ResetBuffs() end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

-- Popup to reloadui
StaticPopupDialogs["SMARTBUFF_GUI_RELOAD"] = {
  text = SMARTBUFF_OFT_REQ_RELOAD,
  button1 = SMARTBUFF_OFT_OKAY,
  OnAccept = function() ReloadUI() end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

-- rounds a number to the given number of decimal places.
local r_mult;
function round(num, idp)
  r_mult = 10 ^ (idp or 0);
  return math.floor(num * r_mult + 0.5) / r_mult;
end

-- Returns a WoW chat color code string from normalized 0-1 RGB.

function sbChatColorFromRGB(r, g, b)
  return string.format("|cff%02x%02x%02x", (r * 255), (g * 255), (b * 255));
end


SG.BL  = sbChatColorFromRGB(0, 0, 1);
SG.BLD = sbChatColorFromRGB(0, 0, 0.7);
SG.BLL = sbChatColorFromRGB(0.5, 0.8, 1);
SG.GR  = sbChatColorFromRGB(0, 1, 0);
SG.GRD = sbChatColorFromRGB(0, 0.7, 0);
SG.GRL = sbChatColorFromRGB(0.6, 1, 0.6);
SG.RD  = sbChatColorFromRGB(1, 0, 0);
SG.RDD = sbChatColorFromRGB(0.7, 0, 0);
SG.RDL = sbChatColorFromRGB(1, 0.3, 0.3);
SG.YL  = sbChatColorFromRGB(1, 1, 0);
SG.YLD = sbChatColorFromRGB(0.7, 0.7, 0);
SG.YLL = sbChatColorFromRGB(1, 1, 0.5);
SG.OR  = sbChatColorFromRGB(1, 0.7, 0);
SG.ORD = sbChatColorFromRGB(0.7, 0.5, 0);
SG.ORL = sbChatColorFromRGB(1, 0.6, 0.3);
SG.WH  = sbChatColorFromRGB(1, 1, 1);
SG.CY  = sbChatColorFromRGB(0.5, 1, 1);

-- Reorders values in the table
function treorder(t, i, n)
  if (t and type(t) == "table" and t[i]) then
    local s = t[i];
    tremove(t, i);
    if (i + n < 1) then
      tinsert(t, 1, s);
    elseif (i + n > #t) then
      tinsert(t, s);
    else
      tinsert(t, i + n, s);
    end
  end
end


-- Chain/link entries: spell ID (number), spell name (string), or spell info table (.name).
-- Order can be string or table (saved state).
-- Resolve numeric IDs at use time so chains/links don't depend on globals being set when assembled.
function resolveChainOrLinkEntry(entry)
  if (type(entry) == "number") then
    local name = C_Spell.GetSpellName(entry);
    if (name and name ~= "") then return name; end
    return "item:" .. tostring(entry);
  end
  if (type(entry) == "table" and entry.name) then return entry.name; end
  return type(entry) == "string" and entry or nil;
end


function chainContains(chain, buffName)
  if (not chain or type(chain) ~= "table" or not buffName) then return false; end
  local nameToMatch = (type(buffName) == "table" and buffName.name) or buffName;
  if (not nameToMatch) then return false; end
  local cbi = nameToMatch and SG.cBuffIndex[nameToMatch];
  if (type(nameToMatch) == "string" and cbi and SG.cBuffs[cbi] and SG.cBuffs[cbi].IDS) then
    local resolved = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(SG.cBuffs[cbi].IDS);
    if (resolved and resolved ~= "") then nameToMatch = resolved; end
  end
  for _, entry in ipairs(chain) do
    if (not entry) then
    elseif (entry == nameToMatch) then return true;
    elseif (type(entry) == "table" and entry.name == nameToMatch) then return true;
    elseif (type(entry) == "number") then
      if (resolveChainOrLinkEntry(entry) == nameToMatch) then return true; end
    end
  end
  return false;
end


function isVisibleToPlayer(self)
  if (not self) then return false; end

  local w, h = UIParent:GetWidth(), UIParent:GetHeight();
  local x, y = self:GetLeft(), UIParent:GetHeight() - self:GetTop();

  --print(format("w = %.0f, h = %.0f, x = %.0f, y = %.0f", w, h, x, y));
  if (x >= 0 and x < (w - self:GetWidth()) and y >= 0 and y < (h - self:GetHeight())) then
    return true;
  end
  return false;
end


function getCurrentSpec()
  if (SG.currentSpec == nil) then
    SG.currentSpec = SMARTBUFF_GetActiveTalentGroup();
  end
  if (SG.currentSpec == nil) then
    SG.currentSpec = 1;
    SMARTBUFF_AddMsgErr("Could not detect active talent group, set to default = 1");
    SMARTBUFF_Printd("Could not detect active talent group, set to default = 1");
  end
  return SG.currentSpec;
end


-- SMARTBUFF_TEMPLATES entry for a SmartBuffGroup key (e.g. "Solo"); nil if enum or index missing.
function smartBuffTemplateForGroupKey(key)
  if (not SMARTBUFF_TEMPLATES or not Enum or not Enum.SmartBuffGroup or not key) then
    return nil;
  end
  local idx = Enum.SmartBuffGroup[key];
  if (not idx) then
    return nil;
  end
  return SMARTBUFF_TEMPLATES[idx];
end

-- Resolves the active profile name (string from SMARTBUFF_TEMPLATES, not a numeric index).
-- Defaults like Options_Init (SMARTBUFF_TEMPLATES[1], valid SG.O.LastTemplate) and SetTemplate (Solo).

function getCurrentTemplate()
  if (SG.currentTemplate ~= nil) then
    return SG.currentTemplate;
  end
  if (SG.O and SG.O.LastTemplate and SMARTBUFF_TEMPLATES) then
    for _, tname in ipairs(SMARTBUFF_TEMPLATES) do
      if (tname == SG.O.LastTemplate) then
        SG.currentTemplate = SG.O.LastTemplate;
        return SG.currentTemplate;
      end
    end
  end
  if (SMARTBUFF_TEMPLATES and SMARTBUFF_TEMPLATES[1]) then
    SG.currentTemplate = SMARTBUFF_TEMPLATES[1];
    return SG.currentTemplate;
  end
  SG.currentTemplate = smartBuffTemplateForGroupKey("Solo");
  return SG.currentTemplate;
end


-- Safe access to SG.B[spec][template]. Tables may be missing briefly after spec/template changes.
function buffsSpecTable()
  return SG.B and SG.B[getCurrentSpec()] or nil;
end


-- Optional templateName; defaults to current template (getCurrentTemplate()).
function buffsTemplateTable(templateName)
  local spec = buffsSpecTable();
  if (not spec) then return nil; end
  templateName = templateName or getCurrentTemplate();
  if (not templateName) then return nil; end
  return spec[templateName];
end


function buffsTemplateOrder()
  local spec = buffsSpecTable();
  return spec and spec.Order or nil;
end


-- Ensures SG.B[getCurrentSpec()][templateName] exists (SelfFirst seeded). templateName optional, defaults to getCurrentTemplate().
function ensureBuffsTemplateTable(templateName)
  templateName = templateName or getCurrentTemplate();
  if (not SG.B or not templateName) then return nil; end
  local spec = SMARTBUFF_EnsureSpecTable(getCurrentSpec());
  if (not spec) then
    return nil;
  end
  local tm = spec[templateName];
  if (not tm) then
    tm = {};
    tm.SelfFirst = false;
    spec[templateName] = tm;
  end
  return tm;
end


function getBuffSettings(buff)
  if (not buff) then return nil; end
  local tmplB = buffsTemplateTable();
  if (not tmplB) then return nil; end
  local cBuff = tmplB[buff];
  local id = (type(buff) == "string") and tonumber(string.match(buff, "item:(%d+)"));
  -- If found via direct key and key is a full item link (not canonical), migrate to canonical so
  -- SavedVariables persist next session (link string can differ between sessions).
  if (cBuff and id and type(buff) == "string") then
    local canKey = "item:" .. tostring(id);
    if (buff ~= canKey) then
      tmplB[canKey] = cBuff;
      tmplB[buff] = nil;
    end
  end
  -- Item-type keys can be full link or "item:ID"; try canonical key so settings persist across load order
  if (not cBuff and type(buff) == "string") then
    if (not id) then id = tonumber(string.match(buff, "item:(%d+)")); end
    if (id) then
      cBuff = tmplB["item:" .. tostring(id)];
      -- Last session may have saved under full link; find any key that refers to this item
      if (not cBuff) then
        for k, v in pairs(tmplB) do
          if (type(k) == "string" and type(v) == "table") then
            local kid = tonumber(string.match(k, "item:(%d+)"));
            if (kid == id) then
              cBuff = v;
              -- Migrate to canonical key so future lookups and saves use one key
              local canKey = "item:" .. tostring(id);
              tmplB[canKey] = v;
              tmplB[k] = nil;
              break;
            end
          end
        end
      end
    end
  end
  return cBuff;
end


-- Remove duplicate item-type keys in SG.B[spec][template]: keep only canonical "item:ID",
-- migrate or drop link/name orphans so SavedVariables stay clean and we avoid confused state.
-- Rate-limited to CRUFT_CLEANUP_CHUNK keys per iteration; continues next frame if more keys remain.
local CRUFT_CLEANUP_CHUNK = 500;
function cleanBuffSettingsCruftOneTable(t, keys, startIdx)
  if (not t or type(t) ~= "table") then return; end
  local expected = SMARTBUFF_ExpectedData;
  if (not expected or not expected.items) then return; end
  if (not keys) then
    keys = {};
    for k, v in pairs(t) do
      if (k ~= "SelfFirst" and type(v) == "table") then
        tinsert(keys, k);
      end
    end
    startIdx = 1;
  end
  local toRemove = {};
  local toMigrate = {};
  local last = math.min(startIdx + CRUFT_CLEANUP_CHUNK - 1, #keys);
  for i = startIdx, last do
    local k = keys[i];
    if (k and t[k] ~= nil) then
      local id = (type(k) == "string") and tonumber(string.match(k, "item:(%d+)"));
      if (id) then
        local canKey = "item:" .. tostring(id);
        if (k ~= canKey) then
          if (t[canKey]) then
            toRemove[k] = true;
          else
            toMigrate[k] = canKey;
          end
        end
      else
        for varName, itemId in pairs(expected.items) do
          if (_G[varName] == k) then
            local canKey = "item:" .. tostring(itemId);
            if (t[canKey]) then
              toRemove[k] = true;
            else
              toMigrate[k] = canKey;
            end
            break;
          end
        end
      end
    end
  end
  for k, canKey in pairs(toMigrate) do
    t[canKey] = t[k];
    t[k] = nil;
  end
  for k in pairs(toRemove) do
    t[k] = nil;
  end
  if (last < #keys) then
    C_Timer.After(0, function()
      cleanBuffSettingsCruftOneTable(t, keys, last + 1);
    end);
  end
end


function cleanBuffSettingsCruft()
  if (not SG.B or not SG.B[getCurrentSpec()]) then return; end
  if (not SMARTBUFF_ExpectedData or not SMARTBUFF_ExpectedData.items) then return; end
  for ctKey, ctTbl in pairs(SG.B[getCurrentSpec()]) do
    if (ctKey ~= "Order" and type(ctTbl) == "table") then
      cleanBuffSettingsCruftOneTable(ctTbl);
    end
  end
end


function initBuffSettings(cBI, reset)
  local buff = cBI.BuffS;
  local cBuff = getBuffSettings(buff);
  local id = (type(buff) == "string") and tonumber(string.match(buff, "item:(%d+)"));
  if (cBuff == nil) then
    -- Use canonical key for item-type buffs so link vs placeholder doesn't lose saved settings
    local key = buff;
    if (type(buff) == "string") then
      if (not id) then id = tonumber(string.match(buff, "item:(%d+)")); end
      -- Item-type buffs: resolve id from ExpectedData when buff has no "item:ID" (e.g. init timing/name).
      -- Use canonical key and restore EnableS from cache.
      if (not id and SMARTBUFF_ExpectedData and SMARTBUFF_ExpectedData.items) then
        for varName, itemId in pairs(SMARTBUFF_ExpectedData.items) do
          if (_G[varName] == buff) then id = itemId; break; end
        end
      end
      if (id) then key = "item:" .. tostring(id); end
    end
    local tm = ensureBuffsTemplateTable();
    if (not tm) then return; end
    tm[key] = {};
    cBuff = tm[key];
    reset = true;
  end

  if (reset) then
    wipe(cBuff);
    cBuff.EnableS = false;
    cBuff.EnableG = false;
    cBuff.SelfOnly = false;
    cBuff.SelfNot = false;
    cBuff.CIn = false;
    cBuff.COut = true;
    cBuff.MH = true; -- default to checked
    cBuff.OH = false;
    cBuff.RH = false;
    cBuff.Reminder = true;
    cBuff.RBTime = 0;
    cBuff.ManaLimit = 0;
    if (cBI.Type == SMARTBUFF_CONST_GROUP or cBI.Type == SMARTBUFF_CONST_ITEMGROUP) then
      for n in pairs(SG.cClasses) do
        local params = cBI.Params;
        if (cBI.Type == SMARTBUFF_CONST_GROUP and type(params) == "string" and not string.find(params, SG.cClasses[n])) then
          cBuff[SG.cClasses[n]] = true;
        else
          cBuff[SG.cClasses[n]] = false;
        end
      end
    end
    -- Restore EnableS from cache only for the same template AND talent group (do not cross dual-spec).
    if (SmartBuffBuffListCache and SmartBuffBuffListCache.enabledBuffs
        and SmartBuffBuffListCache.lastTemplate == getCurrentTemplate()
        and SmartBuffBuffListCache.lastSpec == getCurrentSpec()) then
      if (not id) then id = (type(buff) == "string") and tonumber(string.match(buff, "item:(%d+)")); end
      if (not id and SMARTBUFF_ExpectedData and SMARTBUFF_ExpectedData.items) then
        for varName, itemId in pairs(SMARTBUFF_ExpectedData.items) do
          if (_G[varName] == buff) then id = itemId; break; end
        end
      end
      for _, en in ipairs(SmartBuffBuffListCache.enabledBuffs) do
        if (en == buff or (id and type(en) == "string" and (("item:" .. tostring(id)) == en or tonumber(string.match(en, "item:(%d+)")) == id))) then
          cBuff.EnableS = true;
          break;
        end
      end
    end
  end

  -- Upgrades
  if (cBuff.RBTime == nil) then
    cBuff.Reminder = true; cBuff.RBTime = 0;
  end                                                                        -- to 1.10g
  if (cBuff.ManaLimit == nil) then cBuff.ManaLimit = 0; end                  -- to 1.12b
  if (cBuff.SelfNot == nil) then cBuff.SelfNot = false; end                  -- to 2.0i
  if (cBuff.AddList == nil) then cBuff.AddList = {}; end                     -- to 2.1a
  if (cBuff.IgnoreList == nil) then cBuff.IgnoreList = {}; end               -- to 2.1a
  if (cBuff.RH == nil) then cBuff.RH = false; end                            -- to 4.0b
  if (cBuff.SkipBGResQueue == nil) then cBuff.SkipBGResQueue = false; end
end


function initBuffOrder(reset)
  if not SG.B then SG.B = {} end
  local spec = SMARTBUFF_EnsureSpecTable(getCurrentSpec());
  if not spec then return end
  if not spec.Order then spec.Order = {} end

  local b;
  local i;
  local ord = spec.Order;

  if (reset) then
    wipe(ord);
    SMARTBUFF_AddMsgD("Reset buff order");
  end

  -- Normalize Order: item-type keys to canonical "item:ID" and dedupe (single source of truth;
  -- avoids link vs placeholder duplicates on reload).
  -- Also normalize numeric item IDs (corrupt/old saved state) so they don't show as separate rows
  do
    local function idFrom(s)
      if (type(s) == "number" and s > 0) then return s; end
      if (type(s) == "string") then return tonumber(string.match(s, "item:(%d+)")); end
      return nil;
    end
    for k, v in pairs(ord) do
      if (v ~= nil) then
        local id = idFrom(v);
        if (id) then ord[k] = "item:" .. tostring(id); end
      end
    end
    local seen, newOrd = {}, {};
    for idx = 1, #ord do
      local key = ord[idx];
      if (key and not seen[key]) then
        seen[key] = true;
        tinsert(newOrd, key);
      end
    end
    wipe(ord);
    for _, key in ipairs(newOrd) do tinsert(ord, key); end
  end

  -- Remove not longer existing buffs in the order list
  -- Also remove toys if IncludeToys is disabled
  local toRemove = {};
  local includeToys = (SG.O and SG.O.IncludeToys) or false;
  for k, v in pairs(ord) do
    if (v and SG.cBuffIndex[v] == nil) then
      SMARTBUFF_AddMsgD("Remove from buff order: " .. v);
      tinsert(toRemove, k);
    elseif (v and not includeToys and SG.Toybox and SG.Toybox[v]) then
      SMARTBUFF_AddMsgD("Remove toy from buff order (toys excluded): " .. v);
      tinsert(toRemove, k);
    end
  end
  -- Remove collected indices in reverse order to avoid index shifting issues
  table.sort(toRemove, function(a, b) return a > b; end);
  for _, k in ipairs(toRemove) do
    tremove(ord, k);
  end

  i = 1;
  while (SG.cBuffs[i] and SG.cBuffs[i].BuffS) do
    -- Skip toys if IncludeToys is disabled
    if (includeToys or not SG.Toybox or not SG.Toybox[SG.cBuffs[i].BuffS]) then
      b = false;
      for _, v in pairs(ord) do
        if (v and v == SG.cBuffs[i].BuffS) then
          b = true;
          break;
        end
      end
      -- buff not found add it to order list
      if (not b) then
        tinsert(ord, SG.cBuffs[i].BuffS);
        SMARTBUFF_AddMsgD("Add to buff order: " .. SG.cBuffs[i].BuffS);
      end
    end
    i = i + 1;
  end
end


function isMinLevel(minLevel)
  if (not minLevel) then
    return true;
  end
  if (minLevel > UnitLevel("player")) then
    return false;
  end
  return true;
end


function isPlayerInGuild()
  return IsInGuild()   -- and GetGuildInfo("player")
end


function sendSmartbuffVersion(player, unit)
  -- if ive announced to this player / the player is me then just return.
  if player == UnitName("player") then return end
  for count, value in ipairs(SmartbuffVerNotifyList) do
    if value[1] == player then return end
  end
  -- not announced, add the player and announce.
  tinsert(SmartbuffVerNotifyList, { player, unit, GetTime() })
  C_ChatInfo.SendAddonMessage(SmartbuffPrefix, SMARTBUFF_VERSION, "WHISPER", player)
  SMARTBUFF_AddMsgD(string.format("%s was sent version information.", player))
end


-- SMARTBUFF_OnLoad
function SMARTBUFF_OnLoad(self)
  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_LOGIN"); -- added
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("UNIT_NAME_UPDATE");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");
  self:RegisterEvent("PLAYER_STARTED_MOVING"); -- added
  self:RegisterEvent("PLAYER_STOPPED_MOVING"); -- added
  self:RegisterEvent("PLAYER_TALENT_UPDATE");
  self:RegisterEvent("SPELLS_CHANGED");
  self:RegisterEvent("ACTIONBAR_HIDEGRID");
  self:RegisterEvent("UNIT_AURA");
  self:RegisterEvent("CHAT_MSG_ADDON");
  self:RegisterEvent("CHAT_MSG_CHANNEL");
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
  self:RegisterEvent("UNIT_SPELLCAST_FAILED");
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  self:RegisterEvent("PLAYER_ALIVE");
  self:RegisterEvent("PLAYER_UNGHOST");
  self:RegisterEvent("PLAYER_LEVEL_UP");
  self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
  -- Cache-related events for partial reloads
  self:RegisterEvent("NEW_TOY_ADDED");
  self:RegisterEvent("BAG_UPDATE");
  self:RegisterEvent("ITEM_DATA_LOAD_RESULT");
  self:RegisterEvent("SPELL_DATA_LOAD_RESULT");
  self:RegisterEvent("UI_ERROR_MESSAGE");  -- surface item-buff errors to chat
  --auto template events
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  self:RegisterEvent("GROUP_ROSTER_UPDATE")
  self:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE")

  --One of them allows SmartBuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartBuffOptionsFrame");
  UIPanelWindows["SmartBuffOptionsFrame"] = nil;

  SlashCmdList["SMARTBUFF"] = SMARTBUFF_Command;
  SLASH_SMARTBUFF1 = "/sbo";
  SLASH_SMARTBUFF2 = "/sbuff";
  SLASH_SMARTBUFF3 = "/smartbuff";
  SLASH_SMARTBUFF4 = "/sb";

  SlashCmdList["SMARTBUFFMENU"] = SMARTBUFF_OptionsFrame_Toggle;
  SLASH_SMARTBUFFMENU1 = "/sbm";

  SlashCmdList["SmartReloadUI"] = function(msg) ReloadUI(); end;
  SLASH_SmartReloadUI1 = "/rui";

  SMARTBUFF_InitSpellIDs();
  SMARTBUFF_InitItemList();
  SG.InitSharedMediaSounds();
  -- BuildItemTables and InitSpellList run only in SetBuffs when SMARTBUFF_BUFFLIST == nil
  -- (single init path, avoids duplicate potion/flask entries).

  --DEFAULT_CHAT_FRAME:AddMessage("SB OnLoad");
end

-- END SMARTBUFF_OnLoad


-- SMARTBUFF_OnEvent

function SMARTBUFF_OnEvent(self, event, ...)
local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...;
  -- Surface item-buff errors to chat
  if (event == "UI_ERROR_MESSAGE") then
    if (SG.tLastBuffAttempt > 0 and (GetTime() - SG.tLastBuffAttempt) < 1.5) then
      local errText = arg2 or arg1;
      local rp = SMARTBUFF_REVIVE_PET;
      if (SG.sPlayerClass == "HUNTER" and errText and type(rp) == "table" and rp.name and rp.name ~= "" and
          string.find(errText, rp.name, 1, true)) then
        SG.sHunterPetNeedsRevive = true;
        SMARTBUFF_AddMsgWarn("[SmartBuff] Need Revive Pet; I'll cast it next instead of Call Pet.");
      else
        SMARTBUFF_AddMsgWarn("[SmartBuff] Buff Warning: " .. tostring(errText or "?"));
      end
      SG.tLastBuffAttempt = 0;
    end
  end

  if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then
    -- Clear valid-spells on login/reload so next buff list build re-validates
    -- (runs before SG.isInit return so combat doesn't skip it).
    if (event == "PLAYER_ENTERING_WORLD" and (arg1 or arg2) and SmartBuffValidSpells) then
      SMARTBUFF_ClearValidSpells();
    end
    if isPlayerInGuild() and event == "PLAYER_ENTERING_WORLD" then
      C_ChatInfo.SendAddonMessage(SmartbuffPrefix, SMARTBUFF_VERSION, "GUILD")
    end
    SG.isPlayer = true;
    if (event == "PLAYER_ENTERING_WORLD" and SG.isInit and SG.O and SG.O.Toggle) then
      SG.isSetZone = true;
      SG.tStartZone = GetTime();
    end
    if (event == "PLAYER_ENTERING_WORLD" and SG.isLoaded and SG.isPlayer and not SG.isInit and not InCombatLockdown()) then
      SMARTBUFF_Options_Init(self);
    end
    -- Relog into an existing party does not raise a join event. Unit names arrive late,
    -- so ask again after the first roster pass has had time to see everyone.
    if (event == "PLAYER_ENTERING_WORLD" and SMARTBUFF_PaladinAssign_OnRoster) then
      C_Timer.After(5, SMARTBUFF_PaladinAssign_OnRoster);
      C_Timer.After(10, SMARTBUFF_PaladinAssign_OnRoster);
    end
  elseif (event == "ADDON_LOADED" and arg1 and (arg1 == SMARTBUFF_TITLE or strfind(arg1, "SmartBuff") == 1)) then
    SG.isLoaded = true;
    SMARTBUFF_SetupTooltips();
    if (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) then
      C_ChatInfo.RegisterAddonMessagePrefix(SmartbuffPrefix);
    end
  end

  -- PLAYER_LOGIN
  if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
    if (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix) then
      C_ChatInfo.RegisterAddonMessagePrefix(SmartbuffPrefix);
    end
  end
  if event == "PLAYER_LOGIN" then
    -- Load cache on login
    SMARTBUFF_LoadCache();
  end

  -- CHAT_MSG_ADDON
  if event == "CHAT_MSG_ADDON" then
    local prefix, text = arg1, arg2;
    local function prefixIsOurs(p)
      return type(p) == "string" and string.lower(p) == string.lower(SmartbuffPrefix);
    end
    if (not prefixIsOurs(prefix)) then
      local args = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 };
      for i = 1, #args do
        if (type(args[i]) == "string" and string.sub(args[i], 1, 4) == "PA1 ") then
          text = args[i];
          prefix = SmartbuffPrefix;
          break;
        elseif (prefixIsOurs(args[i]) and type(args[i + 1]) == "string") then
          prefix = args[i];
          text = args[i + 1];
          break;
        end
      end
    end
    if (prefixIsOurs(prefix)) then
      if (SMARTBUFF_AddMsgD) then
        SMARTBUFF_AddMsgD("Addon received channel=" .. tostring(arg3) .. " from=" .. tostring(arg4) .. "/" .. tostring(arg5) .. " " .. tostring(text));
      end
      if (type(text) == "string" and string.sub(text, 1, 4) == "PA1 ") then
        if (SMARTBUFF_PaladinAssign_OnMessage) then
          SMARTBUFF_PaladinAssign_OnMessage(text, arg4, arg5, arg6, arg7, arg8, arg9);
        end
      elseif (text) then
        if text > SMARTBUFF_VERSION and SmartbuffSession then
          DEFAULT_CHAT_FRAME:AddMessage(SMARTBUFF_MSG_NEWVER1 ..
          SMARTBUFF_VERSION .. SMARTBUFF_MSG_NEWVER2 .. text .. SMARTBUFF_MSG_NEWVER3)
          SmartbuffSession = false
        end
        if arg5 and arg5 ~= UnitName("player") and SmartbuffVerCheck then
          DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff : |cffFFFF00" ..
          arg5 .. " (" .. arg3 .. ")|cffffffff has revision |cffFFFF00r" .. text .. "|cffffffff installed.")
        end
      end
    end
  end

  if (event == "SMARTBUFF_UPDATE" and SG.isLoaded and SG.isPlayer and not SG.isInit and not InCombatLockdown()) then
    SMARTBUFF_Options_Init(self);
    --    print(buildInfo)
  end

  if (not SG.isInit or SG.O == nil) then
    return;
  end;

  if (event == "PLAYER_REGEN_DISABLED") then
    SMARTBUFF_Ticker(true);

    if (SG.O.Toggle) then
      if (SG.O.InCombat) then
        -- Filtered CIn /castsequence (template order). Lockdown keeps the macro stamped out of combat.
        SMARTBUFF_StampInCombatCastsequence();
      else
        -- In-combat option off: clear button so we don't show a stale out-of-combat reminder in combat
        SMARTBUFF_DisableInCombatCastsequenceMacro();
        SmartBuff_KeyButton:SetAttribute("type", nil);
        SmartBuff_KeyButton:SetAttribute("unit", nil);
        SmartBuff_KeyButton:SetAttribute("spell", nil);
        SmartBuff_KeyButton:SetAttribute("item", nil);
        SmartBuff_KeyButton:SetAttribute("target-slot", nil);
        SmartBuff_KeyButton:SetAttribute("macrotext", nil);
        SmartBuff_KeyButton:SetAttribute("action", nil);
      end
      SMARTBUFF_SyncBuffTimers();
      SMARTBUFF_Check(1, true);
    end
  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTBUFF_Ticker(true);

    if (SG.O.Toggle) then
      -- Leave combat: clear in-combat castsequence below. BGRes: wipe if we are not in arena/BG anymore
      -- (e.g. left the match/instance â€” avoids carrying SG.cBuffsToCastAfterBGRes into open world). Still inside
      -- arena/BG OOC â†’ keep queue so the next secure click can consume it.
      local _, instanceTypeRE = GetInstanceInfo();
      if (instanceTypeRE ~= "arena" and instanceTypeRE ~= "pvp") then
        wipe(SG.cBuffsToCastAfterBGRes);
      end
      if (SG.O.InCombat) then
        SMARTBUFF_DisableInCombatCastsequenceMacro();
      end
      SMARTBUFF_SyncBuffTimers();
      SMARTBUFF_Check(1, true);
    end

    -- PLAYER_STARTED_MOVING / PLAYER_STOPPED_MOVING
  elseif (event == "PLAYER_STARTED_MOVING") then
    SG.isPlayerMoving = true;
  elseif (event == "PLAYER_STOPPED_MOVING") then
    SG.isPlayerMoving = false;
    -- Forever sometimes omits STOPPED; OnUpdate food path also clears via GetUnitSpeed==0.
  elseif (event == "PLAYER_TALENT_UPDATE") then
    if (SmartBuffOptionsFrame:IsVisible()) then
      SmartBuffOptionsFrame:Hide();
    end
    local newSpec = SMARTBUFF_GetActiveTalentGroup();
    if (SG.currentSpec ~= newSpec) then
      SG.currentSpec = newSpec;
      SMARTBUFF_EnsureSpecTable(SG.currentSpec);
      SMARTBUFF_AddMsg(format(SMARTBUFF_MSG_SPECCHANGED, tostring(SG.currentSpec)), true);
      SMARTBUFF_ScheduleSetBuffs();
    end
  elseif (event == "SPELLS_CHANGED" or event == "ACTIONBAR_HIDEGRID") then
    SMARTBUFF_ScheduleSetBuffs();
  end

  if (not SG.isInit or SG.O == nil) then
    return;
  end;

  if (not SG.O.Toggle) then
    return;
  end;

  if (event == "UNIT_AURA") then
    if (UnitAffectingCombat("player") and (arg1 == "player" or string.find(arg1, "^party") or string.find(arg1, "^raid"))) then
      SG.isSyncReq = true;
    end
    -- Detect dismounting: trigger check on next ticker cycle during initialization
    if (arg1 == "player" and SG.isInit) then
      local wasMounted = SG.isMounted;
      SG.isMounted = IsMounted() or IsFlying();
      -- If player just dismounted, trigger check on next ticker cycle
      if (wasMounted and not SG.isMounted) then
        SG.isAuraChanged = true;
      end
    end
  end

  if (event == "UI_ERROR_MESSAGE") then
    SMARTBUFF_AddMsgD(string.format("Error message: %s", arg1));
  end

  if (event == "UNIT_SPELLCAST_FAILED") then
    SG.currentUnit = arg1;
    SMARTBUFF_AddMsgD(string.format("Spell failed: %s", arg1));
    if (SG.currentUnit and (string.find(SG.currentUnit, "party") or string.find(SG.currentUnit, "raid") or (SG.currentUnit == "target" and SG.O.Debug))) then
      if (UnitName(SG.currentUnit) ~= SG.sPlayerName and SG.O.BlocklistTimer > 0) then
        SG.cBlocklist[SG.currentUnit] = GetTime();
        if (SG.currentUnit and UnitName(SG.currentUnit)) then
        end
      end
    end
    SG.currentUnit = nil;
    SG.currentSpell = nil;
    SG.tCastRequested = 0;
    SG.sHunterReviveTimerOrderKey = nil;
  elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
    if (arg1 and arg1 == "player") then
      local castSpellId = nil;
      if (type(arg3) == "number") then
        castSpellId = arg3;
      elseif (arg3 ~= nil and arg3 ~= "") then
        castSpellId = tonumber(arg3);
      end
      SMARTBUFF_UpdateInCombatCastsequenceAfterSpellSucceeded(castSpellId);
      local unit = nil;
      local spell = nil;
      local target = nil;
      if (arg1 and arg2) then
        if (not arg3) then arg3 = ""; end
        if (not arg4) then arg4 = ""; end
        SMARTBUFF_AddMsgD("Spellcast succeeded: target " ..
        arg1 .. ", spellID " .. arg3 .. " (" .. C_Spell.GetSpellName(arg3) .. "), " .. arg4)
        if (string.find(arg1, "party") or string.find(arg1, "raid")) then
          spell = arg2;
        end
        --SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
      end

      if (SG.currentUnit and SG.currentSpell and SG.currentUnit ~= "target") then
        unit = SG.currentUnit;
        spell = SG.currentSpell;
      end

      if (unit) then
        local name = UnitName(unit);
        if (SG.cBuffTimer[unit] == nil) then
          SG.cBuffTimer[unit] = {};
        end
        local timerSpellKey = spell;
        if (SMARTBUFF_REVIVE_PET and type(SMARTBUFF_REVIVE_PET) == "table" and SMARTBUFF_REVIVE_PET.name and spell and
            spell == SMARTBUFF_REVIVE_PET.name and SG.sHunterReviveTimerOrderKey) then
          timerSpellKey = SG.sHunterReviveTimerOrderKey;
          SG.sHunterReviveTimerOrderKey = nil;
        end
        SG.cBuffTimer[unit][timerSpellKey] = GetTime();

        -- Check if this is an ITEM type creation spell (like Create Healthstone)
        -- If so, reset SG.tLastCheck to prevent immediate extra check before item appears in inventory
        if (spell and SG.cBuffIndex[spell]) then
          local buffIndex = SG.cBuffIndex[spell];
          local cBI = SG.cBuffs[buffIndex];
          if (cBI and cBI.Type == SMARTBUFF_CONST_ITEM) then
            -- Reset check timer so next check happens after normal interval (prevents extra out-of-order check)
            SG.tLastCheck = GetTime();
            SMARTBUFF_AddMsgD("ITEM type spell cast succeeded, resetting check timer");
          end
        end

        if (name ~= nil) then
          SMARTBUFF_AddMsg(name .. ": " .. spell .. " " .. SMARTBUFF_MSG_BUFFED);
          SG.currentUnit = nil;
          SG.currentSpell = nil;
          SG.tCastRequested = 0;
        end
      end

      if (SG.isClearSplash) then
        SG.isClearSplash = false;
        SMARTBUFF_Splash_Clear();
      end
    end
  elseif ((event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST") and SG.isInit and SG.B and SG.B[getCurrentSpec()]) then
    -- BG resurrection: queue buffs to try (aura state is secret during match)
    -- PLAYER_ALIVE = release to GY or accept res; PLAYER_UNGHOST = spawn after running as ghost
    local _, instanceType = GetInstanceInfo();
    local inPvPInstance = (instanceType == "arena" or instanceType == "pvp");
    local pvPMatchState = inPvPInstance and (C_PvP.GetActiveMatchState() or 0) or 0;
    local pvPMatchActive = (pvPMatchState >= 3);
    if (inPvPInstance and pvPMatchActive) then
      SMARTBUFF_PopulateBGResQueue();
    end
    -- Still in combat after rez: rebuild castsequence (same rules as REGEN). Client resets /castsequence on death;
    -- Enable path here resets Lua progress (nextIndex, expected list, notifies) and refreshes the macro.
    if (SG.O and SG.O.Toggle and SG.O.InCombat and UnitAffectingCombat("player")) then
      SMARTBUFF_StampInCombatCastsequence();
    end
  end

  -- Cache-related event handlers for partial reloads
  -- Note: These handlers are after SG.isInit check, so SG.isInit and SG.O are guaranteed to be valid
  if (event == "NEW_TOY_ADDED") then
    if (SG.O.Toggle) then
      -- Reload toys when a new toy is added (full rebuild; toyID not always guaranteed)
      SMARTBUFF_ReloadToys();
    end
  elseif (event == "BAG_UPDATE") then
    -- Only process character bags (0-5: backpack, equipped bags, reagent bag)
    -- Bank bags (6-12) don't need to trigger reload
    local bagID = arg1;
    if (bagID and bagID >= 0 and bagID <= 5 and SG.O.Toggle) then
      -- Check for new items in character bags (debounced to avoid spam)
      if (not SMARTBUFF_BagUpdateTimer) then
        SMARTBUFF_BagUpdateTimer = C_Timer.After(0.5, function()
          SMARTBUFF_ReloadItems();
          SMARTBUFF_BagUpdateTimer = nil;
        end);
      end
    end
  elseif (event == "SPELLS_CHANGED" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_SPECIALIZATION_CHANGED") then
    -- Clear valid-spells cache so next buff list build re-validates (level-up, spec change, false negatives)
    SMARTBUFF_ClearValidSpells();
    if (SG.O.Toggle) then
      -- Reload spells when spells change, level up, or spec changes
      -- Only reload spell IDs, not static tables from buffs.lua
      SMARTBUFF_ReloadSpells();
    end
  elseif (event == "ITEM_DATA_LOAD_RESULT" or event == "SPELL_DATA_LOAD_RESULT") then
    -- Item/Spell data finished loading (or failed); successful loads refresh cached data and unresolved item rows.
    local dataID, success = ...;
    if (success and SG.isInit and SG.O and SG.O.Toggle) then
      local cache = SmartBuffItemSpellCache;
      local didUpdate = false;  -- Tracks cache writes; successful item loads can also resolve uncached item:ID rows.
      if (cache and cache.needsRefresh) then
        if (event == "ITEM_DATA_LOAD_RESULT") then
          local varName = SMARTBUFF_ExpectedData.itemIDToVarName and SMARTBUFF_ExpectedData.itemIDToVarName[dataID];
          if (varName) then
            local itemName, itemLink, itemRarity, itemLevel, minLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, texture = C_Item.GetItemInfo(dataID);
            if (itemLink and SMARTBUFF_ValidateItemData(itemLink, minLevel, texture)) then
              if (not cache.items) then cache.items = {}; end
              if (not cache.itemIDs) then cache.itemIDs = {}; end
              if (not cache.itemData) then cache.itemData = {}; end
              cache.items[varName] = itemLink;
              cache.itemIDs[varName] = dataID;
              cache.itemData[varName] = {minLevel or 0, texture or 0};
              SMARTBUFF_ItemCacheBindItemID(cache, dataID, varName);
              cache.needsRefresh[varName] = false;
              _G[varName] = itemLink;
              local placeholder = "item:" .. tostring(dataID);
              for _, buffTable in pairs({SMARTBUFF_SCROLL, SMARTBUFF_FOOD, SMARTBUFF_POTION, SMARTBUFF_WEAPON}) do
                if (buffTable) then
                  for _, buff in pairs(buffTable) do
                    if (buff[1] == placeholder) then buff[1] = itemLink; end
                  end
                end
              end
              if (SG.Toybox and SG.Toybox[placeholder]) then
                local toyData = SG.Toybox[placeholder];
                SG.Toybox[itemLink] = toyData;
                SG.Toybox[placeholder] = nil;
                if (SG.ToyboxByID) then
                  SG.ToyboxByID[dataID] = toyData;
                end
              end
              didUpdate = true;
            else
              cache.needsRefresh[varName] = true;
              C_Item.RequestLoadItemDataByID(dataID);
            end
          end
        elseif (event == "SPELL_DATA_LOAD_RESULT") then
          local varName = SMARTBUFF_ExpectedData.spellIDToVarName and SMARTBUFF_ExpectedData.spellIDToVarName[dataID];
          if (varName) then
            local spellInfo = C_Spell.GetSpellInfo(dataID);
            if (spellInfo and SMARTBUFF_ValidateSpellData(spellInfo)) then
              if (not cache.spells) then cache.spells = {}; end
              cache.spells[varName] = spellInfo;
              cache.needsRefresh[varName] = false;
              _G[varName] = spellInfo;
              didUpdate = true;
            else
              cache.needsRefresh[varName] = true;
              C_Spell.RequestLoadSpellData(dataID);
            end
          end
        end
      end
      -- Canonical item:ID rows remain valid while data loads; rebuild after any
      -- successful item load so newly available name, level, and texture data is used.
      if (didUpdate or event == "ITEM_DATA_LOAD_RESULT") then
        SMARTBUFF_ScheduleSetBuffs();
      end
      -- Any successful load can resolve names for rows keyed by item:ID / numeric id (not in ExpectedData)
      if (SmartBuffOptionsFrame and SmartBuffOptionsFrame:IsVisible()) then
        SMARTBUFF_ScheduleBuffOrderOnScroll();
      end
    end
  end

  if event == "ZONE_CHANGED_NEW_AREA" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_SPECIALIZATION_CHANGED" then
      SMARTBUFF_SetTemplate()
  end
  if (event == "GROUP_ROSTER_UPDATE" and SMARTBUFF_PaladinAssign_OnRoster) then
    SMARTBUFF_PaladinAssign_OnRoster();
  end
end

-- END SMARTBUFF_OnEvent



function SMARTBUFF_OnUpdate(self, elapsed)
  if not self.Elapsed then
    self.Elapsed = 0.5  -- Throttle: 0.5s reduces CPU vs 0.2s (2 checks/sec vs 5)
  end
  self.Elapsed = self.Elapsed - elapsed
  if self.Elapsed > 0 then
    return
  end
  self.Elapsed = 0.5

  if (not SG.isInit) then
    if (SG.isLoaded and GetTime() > SG.tAutoBuff + 0.5) then
      SG.tAutoBuff = GetTime();
      local specID = SMARTBUFF_GetActiveTalentGroup();
      if (specID) then
        SMARTBUFF_OnEvent(self, "SMARTBUFF_UPDATE");
      end
    end
  else
    SMARTBUFF_Ticker();
    SMARTBUFF_Check(1);
  end
end


function SMARTBUFF_Ticker(force)
  if (force or GetTime() > SG.tTicker + 1) then
    SG.tTicker = GetTime();

    if (SG.isSyncReq or SG.tTicker > SG.tSync + 10) then
      SMARTBUFF_SyncBuffTimers();
    end

    if (SG.isAuraChanged) then
      SG.isAuraChanged = false;
      SMARTBUFF_Check(1, true);
    end
  end
end


-- Will dump the value of msg to the default chat window
function SMARTBUFF_AddMsg(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SG.O.ToggleMsgNormal)) then
    DEFAULT_CHAT_FRAME:AddMessage(SG.YLL .. msg .. "|r");
  end
end


function SMARTBUFF_AddMsgErr(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SG.O.ToggleMsgError)) then
    DEFAULT_CHAT_FRAME:AddMessage(SG.RDL .. SMARTBUFF_TITLE .. ": " .. msg .. "|r");
  end
end


function SMARTBUFF_AddMsgWarn(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not SG.O.ToggleMsgWarning)) then
    if (SG.isParrot) then
      Parrot:ShowMessage(SG.CY .. msg .. "|r");
    else
      DEFAULT_CHAT_FRAME:AddMessage(SG.CY .. msg .. "|r");
    end
  end
end


function SMARTBUFF_AddMsgD(msg, r, g, b)
  if (not SG.O or not SG.O.Debug) then return; end  -- Early-out to avoid work when Debug off
  if (r == nil) then r = 0.5; end
  if (g == nil) then g = 0.8; end
  if (b == nil) then b = 1; end
  if (DebugChatFrame) then
    DebugChatFrame:AddMessage(msg, r, g, b);
  end
end


-- Derived from template structure: indices 1-6 = GENERICS (order must match localization TEMPLATES_GENERICS; update both if changed).
-- Named instances and custom templates use templateLookup; no enum entries needed.
Enum.SmartBuffGroup = {}
for i, key in ipairs({"Solo", "Party", "LFG", "Raid", "Battleground", "Arena"}) do
  Enum.SmartBuffGroup[key] = i
end

-- True if template has at least one buff with EnableS or EnableG.
function templateHasEnabledBuffs(templateName)
  local t = buffsTemplateTable(templateName);
  if (not t or type(t) ~= "table") then return false; end
  for k, v in pairs(t) do
    if (type(v) == "table" and (v.EnableS or v.EnableG)) then return true; end
  end
  return false;
end

-- Copy buff settings from one template to another (for RetainTemplate on first switch).
-- Only copies when: RetainTemplate is true, source has enabled buffs, and dest is "fresh" (no data or no buffs enabled).
-- Does not copy blank templates, so users cannot accidentally overwrite a configured template with a blank one.

function maybeCopyTemplateOnFirstSwitch(fromT, toT)
  if (not buffsTemplateTable(fromT)) then return; end
  if (not SG.O or not SG.O.RetainTemplate) then return; end
  if (not templateHasEnabledBuffs(fromT)) then return; end  -- do not copy blank over configured
  -- Dest is "fresh" if nil/empty or has no enabled buffs
  if (buffsTemplateTable(toT) and templateHasEnabledBuffs(toT)) then return; end  -- dest already has enabled buffs, not fresh

  local src = buffsTemplateTable(fromT);
  local spec = buffsSpecTable();
  spec[toT] = spec[toT] or {};
  local dst = spec[toT];

  for k, v in pairs(src) do
    if (type(v) == "table") then
      dst[k] = {};
      for k2, v2 in pairs(v) do
        dst[k][k2] = (type(v2) == "table") and (function(t) local r = {}; for a, b in pairs(t) do r[a] = b; end return r; end)(v2) or v2;
      end
    else
      dst[k] = v;
    end
  end
end

-- Set the current template and create an array of units

function SMARTBUFF_SetTemplate(force)
  -- Only block in combat (not when mounted) - setup should work when mounted
  -- Mount check only blocks actual buff checking/casting, not data structure setup
  if (not force and InCombatLockdown()) then return end
  -- When force (e.g. from Options_Init), always run SetBuffs so reminder loop has state even if version prompt left options open
  if (not force and SmartBuffOptionsFrame:IsVisible()) then return end

  -- Ensure SG.currentTemplate is set (fallback to Solo if nil)
  if (SG.currentTemplate == nil) then
    SG.currentTemplate = smartBuffTemplateForGroupKey("Solo") or (SMARTBUFF_TEMPLATES and SMARTBUFF_TEMPLATES[1]);
  end

  local newTemplate = SG.currentTemplate -- default to old template
  local switchReason = nil -- reason for auto-switch (for chat message)
  local isRaidInstanceTemplate = false;

  -- Autoswitch by group/instance type; named raids when AutoSwitchTemplateInst is on.
  if SG.O.AutoSwitchTemplate then
    local instName, instanceType, _, _, _, _, _, _, _, LfgDungeonID = GetInstanceInfo();
    local templateLookup = Enum.MakeEnumFromTable(SMARTBUFF_TEMPLATES);

    if instanceType == "party" then
      if (SG.IsLFGGroup and SG.IsLFGGroup()) or (LfgDungeonID and LfgDungeonID > 0) then
        newTemplate = smartBuffTemplateForGroupKey("LFG")
        switchReason = "LFG"
      else
        newTemplate = smartBuffTemplateForGroupKey("Party")
        switchReason = "party"
      end
    elseif instanceType == "raid" then
      if SG.O.AutoSwitchTemplateInst then
        local templateIdx = templateLookup[instName] or templateLookup[GetRealZoneText()];
        if templateIdx and SMARTBUFF_TEMPLATES[templateIdx] then
          newTemplate = SMARTBUFF_TEMPLATES[templateIdx];
          isRaidInstanceTemplate = true;
          switchReason = "instance";
        end
      end
      if (not isRaidInstanceTemplate) then
        newTemplate = smartBuffTemplateForGroupKey("Raid")
        switchReason = switchReason or "raid"
      end
    elseif instanceType == "pvp" then
      newTemplate = smartBuffTemplateForGroupKey("Battleground") or smartBuffTemplateForGroupKey("Solo")
      switchReason = "battleground"
    elseif instanceType == "arena" then
      newTemplate = smartBuffTemplateForGroupKey("Arena") or smartBuffTemplateForGroupKey("Solo")
      switchReason = "arena"
    end

    if (not switchReason and SG.O.AutoSwitchTemplateInst) then
      local templateIdx = templateLookup[instName] or templateLookup[GetRealZoneText()];
      if templateIdx and SMARTBUFF_TEMPLATES[templateIdx] then
        newTemplate = SMARTBUFF_TEMPLATES[templateIdx];
        isRaidInstanceTemplate = true;
        switchReason = "instance";
      end
    end

    if (not switchReason) then
      if instanceType and instanceType ~= "none" then
        if IsInRaid() then
          newTemplate = smartBuffTemplateForGroupKey("Raid")
          switchReason = "raid"
        elseif IsInGroup() then
          if (SG.IsLFGGroup and SG.IsLFGGroup()) then
            newTemplate = smartBuffTemplateForGroupKey("LFG")
            switchReason = "LFG"
          else
            newTemplate = smartBuffTemplateForGroupKey("Party")
            switchReason = "party"
          end
        else
          newTemplate = smartBuffTemplateForGroupKey("Solo")
          switchReason = "unknown instance"
        end
      else
        -- Open world
        if IsInRaid() then
          newTemplate = smartBuffTemplateForGroupKey("Raid")
          switchReason = "raid"
        elseif IsInGroup() then
          if (SG.IsLFGGroup and SG.IsLFGGroup()) then
            newTemplate = smartBuffTemplateForGroupKey("LFG")
            switchReason = "LFG"
          else
            newTemplate = smartBuffTemplateForGroupKey("Party")
            switchReason = "party"
          end
        else
          newTemplate = smartBuffTemplateForGroupKey("Solo")
          switchReason = "solo"
        end
      end
    end
  end

  if SG.currentTemplate ~= newTemplate then
    maybeCopyTemplateOnFirstSwitch(SG.currentTemplate, newTemplate);
    SMARTBUFF_AddMsgD("Current tmpl: " .. (SG.currentTemplate or "nil") .. " - new tmpl: " .. (newTemplate or "nil"));
    local reason = switchReason or "instance"
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. SMARTBUFF_OFT_AUTOSWITCHTMP .. " (" .. reason .. ") " .. SG.currentTemplate .. " -> " .. newTemplate);
    if (reason == "arena" or reason == "battleground") then
      SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. SMARTBUFF_MSG_PVP_PREP_ONLY, true);
    end
  end
  SG.currentTemplate = newTemplate;

  -- Named raid templates (from SMARTBUFF_TEMPLATES_INSTANCES) use raid unit setup.
  if (not isRaidInstanceTemplate and SMARTBUFF_TEMPLATES_INSTANCES) then
    for _, name in ipairs(SMARTBUFF_TEMPLATES_INSTANCES) do
      if name == SG.currentTemplate then
        isRaidInstanceTemplate = true;
        break;
      end
    end
  end

  SMARTBUFF_SetBuffs();
  wipe(SG.cBlocklist);
  wipe(SG.cBuffTimer);
  wipe(SG.cUnits);
  wipe(SG.cGroups);
  SG.cClassGroups = nil;
  wipe(SG.cAddUnitList);
  wipe(SG.cIgnoreUnitList);

  -- Raid Setup (or named raid instance, or Arena/BG when in raid)
  local isArenaOrBG = (SG.currentTemplate == smartBuffTemplateForGroupKey("Arena")) or (SG.currentTemplate == smartBuffTemplateForGroupKey("Battleground"));
  if (SG.currentTemplate == smartBuffTemplateForGroupKey("Raid")) or isRaidInstanceTemplate or (isArenaOrBG and IsInRaid()) then
    SG.cClassGroups = {};
    local name, server, rank, subgroup, level, class, classeng, zone, online, isDead;
    local sRUnit = nil;

    j = 1;
    for n = 1, SG.maxRaid, 1 do
      name, rank, subgroup, level, class, classeng, zone, online, isDead = GetRaidRosterInfo(n);
      if (name) then
        server = nil;
        i = string.find(name, "-", 1, true);
        if (i and i > 0) then
          server = string.sub(name, i + 1);
          name   = string.sub(name, 1, i - 1);
          SMARTBUFF_AddMsgD(name .. ", " .. server);
        end
        sRUnit = "raid" .. n;

        --SMARTBUFF_AddMsgD(name .. ", " .. sRUnit .. ", " .. UnitName(sRUnit));

        SMARTBUFF_AddUnitToClass("raid", n);
        SMARTBUFF_AddToUnitList(1, sRUnit, subgroup);
        SMARTBUFF_AddToUnitList(2, sRUnit, subgroup);

        if (name == SG.sPlayerName and not server) then
          psg = subgroup;
        end

        if (SG.O.ToggleGrp[subgroup]) then
          s = "";
          if (name == UnitName(sRUnit)) then
            if (SG.cGroups[subgroup] == nil) then
              SG.cGroups[subgroup] = {};
            end
            if (name == SG.sPlayerName and not server) then b = true; end
            SG.cGroups[subgroup][j] = sRUnit;
            j = j + 1;
          end
        end
        -- attempt to announce the addon version (if they have it)
        -- seems to be an issue with cross-realm, need to look at this later
        -- but in the meantime I am disabling it...  CM
        -- if online then sendSmartbuffVersion(name, sRUnit) end
      end
    end --end for

    local curTm = buffsTemplateTable(SG.currentTemplate);
    if (not b or (curTm and curTm.SelfFirst)) then
      SMARTBUFF_AddSoloSetup();
      --SMARTBUFF_AddMsgD("Player not in selected groups or buff self first");
    end

    SMARTBUFF_AddMsgD("Raid Unit-Setup finished");

    -- Party Setup (or Arena/BG when in party)
  elseif (SG.currentTemplate == smartBuffTemplateForGroupKey("Party")) or (isArenaOrBG and IsInGroup()) then
    SG.cClassGroups = {};
    local curTm = buffsTemplateTable(SG.currentTemplate);
    if (curTm and curTm.SelfFirst) then
      SMARTBUFF_AddSoloSetup();
      --SMARTBUFF_AddMsgD("Buff self first");
    end

    SG.cGroups[1] = {};
    SG.cGroups[1][0] = "player";
    SMARTBUFF_AddUnitToClass("player", 0);
    for j = 1, 4, 1 do
      SG.cGroups[1][j] = "party" .. j;
      SMARTBUFF_AddUnitToClass("party", j);
      SMARTBUFF_AddToUnitList(1, "party" .. j, 1);
      SMARTBUFF_AddToUnitList(2, "party" .. j, 1);
      name, _, _, _, _, _, _, online, _, _ = GetRaidRosterInfo(j);
      if name and online then sendSmartbuffVersion(name, "party") end
    end
    SMARTBUFF_AddMsgD("Party Unit-Setup finished");

    -- Solo Setup (and Arena/BG when not in group)
  else
    SMARTBUFF_AddSoloSetup();
    SMARTBUFF_AddMsgD("Solo Unit-Setup finished");
  end
  --collectgarbage();
end


function SMARTBUFF_AddUnitToClass(unit, i)
  local u = unit;
  local up = "pet";
  if (unit ~= "player") then
    u = unit .. i;
    up = unit .. "pet" .. i;
  end
  if (UnitExists(u)) then
    if (not SG.cUnits[1]) then
      SG.cUnits[1] = {};
    end
    SG.cUnits[1][i] = u;
    SMARTBUFF_AddMsgD("Unit added: " .. UnitName(u) .. ", " .. u);

    local _, uc = UnitClass(u);
    if (uc and not SG.cClassGroups[uc]) then
      SG.cClassGroups[uc] = {};
    end
    if (uc) then
      SG.cClassGroups[uc][i] = u;
    end
  end
end


function SMARTBUFF_AddSoloSetup()
  SG.cGroups[0] = {};
  SG.cGroups[0][0] = "player";
  SG.cUnits[0] = {};
  SG.cUnits[0][0] = "player";
  if (SG.sPlayerClass == "HUNTER" or SG.sPlayerClass == "WARLOCK" or SG.sPlayerClass == "MAGE") then SG.cGroups[0][1] =
    "pet"; end

  local curTm = buffsTemplateTable(SG.currentTemplate);
  if (curTm and curTm.SelfFirst) then
    if (not SG.cClassGroups) then
      SG.cClassGroups = {};
    end
    SG.cClassGroups[0] = {};
    SG.cClassGroups[0][0] = "player";
  end
end


-- END SMARTBUFF_SetUnits


-- Parse a numeric rank from spellbook subtext or C_Spell.GetSpellSubtext ("Rank 3", localized).
local function SMARTBUFF_ParseSpellRank(subtext, spellID)
  local sub = subtext;
  if ((sub == nil or sub == "") and spellID and C_Spell and C_Spell.GetSpellSubtext) then
    sub = C_Spell.GetSpellSubtext(spellID);
  end
  if (type(sub) ~= "string") then return nil; end
  return tonumber(string.match(sub, "(%d+)"));
end

-- Known ranks for each spell name, lowest rank first. Rebuilt on spellbook changes, not per unit.
function SMARTBUFF_RebuildSpellRankCache()
  SG.SpellRanks = {};
  local bank = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player;
  if (not (C_SpellBook and C_SpellBook.GetSpellBookItemName and bank)) then return; end
  local i = 1;
  while (true) do
    local spellN, spellSubName = C_SpellBook.GetSpellBookItemName(i, bank);
    if (not spellN) then break; end
    local skillType, spellId = C_SpellBook.GetSpellBookItemType(i, bank);
    if (spellId and type(spellN) == "string" and skillType ~= "FUTURESPELL" and skillType ~= "FLYOUT") then
      local key = string.lower(spellN);
      local list = SG.SpellRanks[key];
      if (not list) then
        list = {};
        SG.SpellRanks[key] = list;
      end
      local seen = false;
      for _, entry in ipairs(list) do
        if (entry.spellID == spellId) then seen = true; break; end
      end
      if (not seen) then
        tinsert(list, {
          spellID = spellId,
          rank = SMARTBUFF_ParseSpellRank(spellSubName, spellId),
          order = i,
        });
      end
    end
    i = i + 1;
    if (i > 500) then break; end
  end
  for _, list in pairs(SG.SpellRanks) do
    local anyRank = false;
    for _, entry in ipairs(list) do
      if (entry.rank) then anyRank = true; break; end
    end
    table.sort(list, function(a, b)
      if (anyRank) then
        local ra = a.rank or 9999;
        local rb = b.rank or 9999;
        if (ra ~= rb) then return ra < rb; end
      end
      return a.order < b.order;
    end);
    if (not anyRank) then
      for idx, entry in ipairs(list) do
        entry.rank = idx;
      end
    end
  end
end

-- Highest known spell ID the unit can receive.
-- Returns spellID, or nil, "too_low" when the unit is below every known rank.
function SMARTBUFF_PickSpellRank(cBuff, unit)
  if (not cBuff or not cBuff.BuffS) then return nil; end
  if (not SG.SpellRanks) then
    SMARTBUFF_RebuildSpellRankCache();
  end
  local key = string.lower(cBuff.BuffS);
  local ranks = SG.SpellRanks and SG.SpellRanks[key];
  if (not ranks or #ranks == 0) then
    return cBuff.IDS;
  end
  local levels = cBuff.LevelsS;
  if (not levels) then
    return ranks[#ranks].spellID;
  end
  if (#ranks ~= #levels and not ranks.mismatchLogged) then
    ranks.mismatchLogged = true;
    SMARTBUFF_AddMsgD(string.format("Rank count mismatch for %s: spellbook %d, LevelsS %d", tostring(cBuff.BuffS), #ranks, #levels));
  end
  local uLevel = UnitLevel(unit);
  if (not uLevel or uLevel < 0) then
    return ranks[#ranks].spellID;
  end
  local effectiveLevel = uLevel + BUFF_TARGET_LEVEL_ALLOWANCE;
  local bestID, bestRank = nil, 0;
  for _, entry in ipairs(ranks) do
    local idx = entry.rank;
    local minLevel = idx and levels[idx];
    if (minLevel and effectiveLevel >= minLevel and idx >= bestRank) then
      bestRank = idx;
      bestID = entry.spellID;
    end
  end
  if (not bestID) then
    return nil, "too_low";
  end
  return bestID;
end

-- Get Spell ID from spellbook (highest known rank when the rank cache has this name).
function SMARTBUFF_GetSpellID(spellname)
  local i, id = 1, nil;
  local spellN, spellId, skillType;
  if (spellname) then
    spellname = string.lower(spellname);
  else
    return nil;
  end
  if (not SG.SpellRanks) then
    SMARTBUFF_RebuildSpellRankCache();
  end
  local cached = SG.SpellRanks and SG.SpellRanks[spellname];
  if (cached and #cached > 0) then
    local top = cached[#cached];
    return top.spellID, top.order;
  end
  while C_SpellBook.GetSpellBookItemName(i, Enum.SpellBookSpellBank.Player) do
    spellN = C_SpellBook.GetSpellBookItemName(i, Enum.SpellBookSpellBank.Player);
    skillType, spellId = C_SpellBook.GetSpellBookItemType(i, Enum.SpellBookSpellBank.Player);
--    print(spellN .. " " .. spellId);
--    print(skillType)
    if (skillType == "FLYOUT") then
      for j = 1, GetNumFlyouts() do
        local fid = GetFlyoutID(j);
        local name, description, numSlots, isKnown = GetFlyoutInfo(fid)
        if (isKnown) then
          for s = 1, numSlots do
            local flySpellID, overrideSpellID, isKnown, spellN, slotSpecID = GetFlyoutSlotInfo(fid, s);
            if (isKnown and string.lower(spellN) == spellname) then
--              print(spellname .. " " .. spellN .. " " .. flySpellID);
              return flySpellID;
            end
          end
        end
      end
    end
    if (spellN ~= nil and string.lower(spellN) == spellname) then
      id = spellId;
      break;
    end
    i = i + 1;
  end
  if (id) then
    -- FUTURESPELL = listed but not learned yet. Otherwise trust the spellbook match:
    -- Forever uses per-rank IDs (e.g. Battle Shout 5242), and IsSpellKnown(baseRank)
    -- can return false even when a higher rank is in the book.
    if (skillType == "FUTURESPELL") then
      id = nil;
      i = nil;
    end
  end
  return id, i;
end

-- END SMARTBUFF_GetSpellID

-- Get current buff counts from SG.cBuffs array (final list)
-- Returns a table with counts by category

function SMARTBUFF_GetCurrentBuffCounts()
  local counts = {
    SCROLL = 0,
    FOOD = 0,
    POTION = 0,
    SELF = 0,
    GROUP = 0,
    ITEM = 0,
    TOTAL = 0
  };

  -- Count from SG.cBuffs array (final list)
  local maxIndex = 0;
  for i, _ in pairs(SG.cBuffs) do
    if (type(i) == "number" and i > maxIndex) then
      maxIndex = i;
    end
  end

  for i = 1, maxIndex do
    if (SG.cBuffs[i] and SG.cBuffs[i].Type) then
      local buffType = SG.cBuffs[i].Type;
      if (counts[buffType] ~= nil) then
        counts[buffType] = counts[buffType] + 1;
      end
      counts.TOTAL = counts.TOTAL + 1;
    end
  end

  return counts;
end

-- Partial reload functions for event-based updates
-- These functions only update what's needed without rebuilding static tables from buffs.lua
-- Static tables (SMARTBUFF_SCROLL, SMARTBUFF_FOOD, etc.) are only rebuilt on initial load or reset

-- Reload toys only (called when NEW_TOY_ADDED fires)
-- Only reloads toy collection, does NOT rebuild static tables

function SMARTBUFF_ReloadToys()
  if (InCombatLockdown()) then return; end
  SMARTBUFF_LoadToys();
  -- Trigger rebuild of SG.cBuffs from existing static tables to include new toys
  SMARTBUFF_ScheduleSetBuffs();
end


-- Reload items from inventory (called when BAG_UPDATE fires for character bags)
-- Does NOT rebuild static tables - just triggers rebuild of SG.cBuffs which checks bags
function SMARTBUFF_ReloadItems()
  if (InCombatLockdown()) then return; end
  -- Trigger rebuild of SG.cBuffs - SMARTBUFF_SetBuff() will check bags via SMARTBUFF_FindItem()
  -- Don't call SMARTBUFF_InitItemList() as that rebuilds static item variables unnecessarily
  SMARTBUFF_ScheduleSetBuffs();
end

-- Reload spells (called when SPELLS_CHANGED, PLAYER_LEVEL_UP, or PLAYER_SPECIALIZATION_CHANGED fires)
-- Only reloads spell IDs, does NOT rebuild static tables from buffs.lua

function SMARTBUFF_ReloadSpells()
  if (InCombatLockdown()) then return; end
  -- Only reload spell IDs - static tables from buffs.lua don't change during gameplay
  SG.SpellRanks = nil;
  SMARTBUFF_RebuildSpellRankCache();
  SMARTBUFF_InitSpellIDs();
  -- Trigger rebuild of SG.cBuffs from existing static tables with updated spell IDs
  SMARTBUFF_ScheduleSetBuffs();
end


-- Schedule a single full buff list rebuild after 0.5s. Only one timer at a time: further calls
-- while pending are ignored, so a burst of events yields one run 0.5s after the first. PreCheck
-- no longer calls SetBuffs from OnUpdate, so this avoids high CPU/memory after login/reload.
function SMARTBUFF_ScheduleSetBuffs()
  if (SG.setBuffsPending) then return; end
  SG.setBuffsPending = true;
  SG.isSetBuffs = true;
  C_Timer.After(0.5, function()
    SG.setBuffsPending = false;
    SG.isSetBuffs = false;
    if (not InCombatLockdown() and SG.isInit and SG.O and SG.O.Toggle) then
      SMARTBUFF_SetBuffs();
      SG.isSyncReq = true;
    end
  end);
end

-- Global name so SMARTBUFF_OnEvent (defined earlier in file) resolves it; closes over SG.buffOrderScrollScheduled above.

function SMARTBUFF_ScheduleBuffOrderOnScroll()
  if (SG.buffOrderScrollScheduled) then return end;
  SG.buffOrderScrollScheduled = true;
  C_Timer.After(0, function()
    SG.buffOrderScrollScheduled = false;
    if (SmartBuffOptionsFrame and SmartBuffOptionsFrame:IsVisible()) then
      SMARTBUFF_BuffOrderOnScroll();
    end
  end);
end


-- Set the buff array
function SMARTBUFF_SetBuffs()
  if (InCombatLockdown()) then return end
  if (SG.B == nil) then return; end

  local n = 1;
  local buff = nil;
  local ct = SG.currentTemplate;

  SMARTBUFF_EnsureSpecTable(getCurrentSpec());

  -- Load cache for verification
  SMARTBUFF_LoadCache();

  -- Only rebuild static tables from buffs.lua if they're not already populated
  -- Static tables don't change during gameplay, only on initial load or reset
  if (SMARTBUFF_BUFFLIST == nil) then
    -- Clear expected data list before building
    SMARTBUFF_ExpectedData.items = {};
    SMARTBUFF_ExpectedData.spells = {};
    SMARTBUFF_InitSpellIDs();
    SMARTBUFF_InitItemList();
    -- Sync cache with expected list (remove extras, add missing, flag all as needsRefresh)
    SMARTBUFF_SyncItemSpellCache();
    SMARTBUFF_BuildItemTables();
    SMARTBUFF_InitSpellList();
    -- Load toys on initial setup
    SMARTBUFF_LoadToys();
    -- Retry once after a delay so item data (flasks, toys) that was not yet loaded can be picked up
    C_Timer.After(1.5, function()
      if (SG.isInit and SG.O and SG.O.Toggle and not InCombatLockdown() and SG.B) then
        SMARTBUFF_LoadToys();
        SMARTBUFF_SetBuffs();
      end
    end);
  elseif (SMARTBUFF_PLAYERCLASS ~= SG.sPlayerClass) then
    -- Player class changed (shouldn't happen, but be safe)
    SMARTBUFF_ExpectedData.items = {};
    SMARTBUFF_ExpectedData.spells = {};
    SMARTBUFF_InitSpellIDs();
    SMARTBUFF_SyncItemSpellCache();
    SMARTBUFF_InitSpellList();
  else
    -- Static tables already populated - only reload spell IDs if needed (for spell availability)
    -- Don't rebuild static tables unnecessarily
    SMARTBUFF_ExpectedData.spells = {};  -- Only rebuild spell expected list
    SMARTBUFF_InitSpellIDs();
    -- Sync only spells (items haven't changed)
    if (SmartBuffItemSpellCache and SmartBuffItemSpellCache.spells) then
      local expected = SMARTBUFF_ExpectedData;
      for varName, _ in pairs(SmartBuffItemSpellCache.spells) do
        if (not expected.spells[varName]) then
          SmartBuffItemSpellCache.spells[varName] = nil;
          if (SmartBuffItemSpellCache.needsRefresh) then
            SmartBuffItemSpellCache.needsRefresh[varName] = nil;
          end
        end
      end
      for varName, spellId in pairs(expected.spells) do
        if (not SmartBuffItemSpellCache.spells[varName]) then
          SmartBuffItemSpellCache.spells[varName] = nil;
          if (not SmartBuffItemSpellCache.needsRefresh) then
            SmartBuffItemSpellCache.needsRefresh = {};
          end
          SmartBuffItemSpellCache.needsRefresh[varName] = true;
        else
          if (not SmartBuffItemSpellCache.needsRefresh) then
            SmartBuffItemSpellCache.needsRefresh = {};
          end
          SmartBuffItemSpellCache.needsRefresh[varName] = true;
        end
      end
    end
    -- Don't reload toys if already verified via cache
    -- Toys will only reload when NEW_TOY_ADDED event fires
  end

  ensureBuffsTemplateTable(ct);

  cleanBuffSettingsCruft();

  wipe(SG.cBuffs);
  wipe(SG.cBuffIndex);
  SG.numBuffs = 0;

  for _, buff in pairs(SMARTBUFF_BUFFLIST) do
    n = SMARTBUFF_SetBuff(buff, n, true);
  end

  for _, buff in pairs(SMARTBUFF_WEAPON) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_RACIAL) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_TRACKING) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_POTION) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_SCROLL) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_FOOD) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  SG.numBuffs = n - 1;

  -- Accept current state (even if incomplete) - following AllTheThings pattern
  -- Don't retry indefinitely - accept partial data and let events handle updates
  local currentCounts = SMARTBUFF_GetCurrentBuffCounts();

  -- Count toys separately (stored in S.Toybox, not in static tables)
  local toyCount = 0;
  if (SG.Toybox) then
    for _ in pairs(SG.Toybox) do
      toyCount = toyCount + 1;
    end
  end

  -- Note: currentCounts includes items/spells that made it into SG.cBuffs[]
  -- Items/spells that returned nil during SMARTBUFF_SetBuff() were filtered out
  -- This is expected - they'll be added when ITEM_DATA_LOAD_RESULT/SPELL_DATA_LOAD_RESULT fires

  -- Save cache with current state (accept partial data like AllTheThings)
  -- For items use only canonical key "item:ID" and that entry's state so duplicate keys (link vs canonical) don't both get added
  local enabledBuffsSnapshot = {};
  local seenItemIDs = {};
  local tmSnap = buffsTemplateTable(ct);
  if (tmSnap) then
    for buffName, settings in pairs(tmSnap) do
      if (type(settings) == "table" and (settings.EnableS or settings.EnableG)) then
        local id = (type(buffName) == "string") and tonumber(string.match(buffName, "item:(%d+)"));
        if (id) then
          if (not seenItemIDs[id]) then
            seenItemIDs[id] = true;
            local canonical = "item:" .. tostring(id);
            local entry = tmSnap[canonical] or settings;
            if (type(entry) == "table" and (entry.EnableS or entry.EnableG)) then
              tinsert(enabledBuffsSnapshot, canonical);
            end
          end
        else
          tinsert(enabledBuffsSnapshot, buffName);
        end
      end
    end
  end
  SMARTBUFF_SaveCache(currentCounts, enabledBuffsSnapshot, toyCount, ct, getCurrentSpec());
  initBuffOrder(false);

  -- Redraw options buff list if open so item/spell names appear when data loads (no close/reopen needed)
  if (SmartBuffOptionsFrame and SmartBuffOptionsFrame:IsVisible()) then SMARTBUFF_BuffOrderOnScroll(); end

  -- Note: If items/spells are still loading, ITEM_DATA_LOAD_RESULT/SPELL_DATA_LOAD_RESULT events will trigger rebuild
  -- This follows AllTheThings pattern: accept partial data, mark what's missing, let events handle updates

  SG.isSetBuffs = false;
end

-- Helper function to extract itemID from itemLink string or itemID number
-- Returns itemID (number) or nil

function extractItemID(item)
  if (type(item) == "number") then
    return item;
  elseif (type(item) == "string") then
    return tonumber(string.match(item, "item:(%d+)"));
  end
  return nil;
end


-- SG.O(1) minLevel/texture from SmartBuffItemSpellCache (avoids pairs(cache.items) per buff row).
function getItemSpellCacheMinLevelTexture(cache, buffLink)
  if (not cache or not cache.itemData or not buffLink) then return nil, nil; end
  local id = extractItemID(buffLink);
  if (not id) then return nil, nil; end
  if (not cache.varNameByItemID) then
    SMARTBUFF_ItemCacheRebuildVarNameByItemID(cache);
  end
  local varName = cache.varNameByItemID and cache.varNameByItemID[id];
  if (not varName) then return nil, nil; end
  local itemData = cache.itemData[varName];
  if (not itemData) then return nil, nil; end
  return itemData[1], itemData[2];
end


-- Helper for UI display: resolve spell/item IDs and varNames to display names using cache first, then API.
-- buffType (optional): when provided and SMARTBUFF_IsItem(buffType), resolve numeric/ID as item only;
-- when spell-like, spell only; when nil, keep current fallback.
function getBuffDisplayName(buffName, buffType)
  if (buffName == nil) then return nil; end

  local cache = SmartBuffItemSpellCache;
  local expected = SMARTBUFF_ExpectedData;
  local forceItem = (buffType ~= nil) and SMARTBUFF_IsItem(buffType);
  local forceSpell = (buffType ~= nil) and not SMARTBUFF_IsItem(buffType);

  if (type(buffName) == "number") then
    if (not forceItem) then
      local varName = expected and expected.spellIDToVarName and expected.spellIDToVarName[buffName];
      if (varName and cache and cache.spells and cache.spells[varName]) then
        local spellInfo = cache.spells[varName];
        if (spellInfo and spellInfo.name) then
          return spellInfo.name;
        end
      end
      if (forceSpell) then
        local spellName = C_Spell.GetSpellName(buffName);
        if (spellName) then return spellName; end
        return tostring(buffName);
      end
    end
    if (not forceSpell) then
      local varName = expected and expected.itemIDToVarName and expected.itemIDToVarName[buffName];
      if (varName and cache and cache.items and cache.items[varName]) then
        return cache.items[varName];
      end
      local itemName, itemLink = C_Item.GetItemInfo(buffName);
      if (itemLink) then return itemLink; end
      if (itemName) then return itemName; end
      if (forceItem) then
        C_Item.RequestLoadItemDataByID(buffName);
        return tostring(buffName);
      end
    end
    if (buffType == nil) then
      local spellName = C_Spell.GetSpellName(buffName);
      if (spellName) then return spellName; end
      C_Item.RequestLoadItemDataByID(buffName);
    end
    return tostring(buffName);
  elseif (type(buffName) == "string") then
    if (string.match(buffName, "^|c")) then
      return buffName;
    end

    if (not forceItem) then
      if (cache and cache.spells and cache.spells[buffName]) then
        local spellInfo = cache.spells[buffName];
        if (spellInfo and spellInfo.name) then
          return spellInfo.name;
        end
      end
    end
    if (not forceSpell) then
      if (cache and cache.items and cache.items[buffName]) then
        return cache.items[buffName];
      end
    end

    local itemID = nil;
    local isItemKey = string.match(buffName, "^item:%d+");
    if (isItemKey) then
      itemID = extractItemID(buffName);
    else
      local num = tonumber(buffName);
      if (num and tostring(num) == buffName) then
        itemID = num;
      end
    end

    if (itemID) then
      -- "item:ID" format: always resolve as item only
      if (isItemKey or forceItem) then
        local varName = expected and expected.itemIDToVarName and expected.itemIDToVarName[itemID];
        if (varName and cache and cache.items and cache.items[varName]) then
          return cache.items[varName];
        end
      local itemName, itemLink = C_Item.GetItemInfo(itemID);
      if (itemLink) then return itemLink; end
      if (itemName) then return itemName; end
      C_Item.RequestLoadItemDataByID(itemID);
        return tostring(itemID);
      end
      if (forceSpell) then
        local varName = expected and expected.spellIDToVarName and expected.spellIDToVarName[itemID];
        if (varName and cache and cache.spells and cache.spells[varName]) then
          local spellInfo = cache.spells[varName];
          if (spellInfo and spellInfo.name) then
            return spellInfo.name;
          end
        end
        local spellName = C_Spell.GetSpellName(itemID);
        if (spellName) then return spellName; end
        return tostring(itemID);
      end
      -- buffType == nil: current fallback (spell then item)
      local varName = expected and expected.spellIDToVarName and expected.spellIDToVarName[itemID];
      if (varName and cache and cache.spells and cache.spells[varName]) then
        local spellInfo = cache.spells[varName];
        if (spellInfo and spellInfo.name) then
          return spellInfo.name;
        end
      end
      varName = expected and expected.itemIDToVarName and expected.itemIDToVarName[itemID];
      if (varName and cache and cache.items and cache.items[varName]) then
        return cache.items[varName];
      end
      local itemName, itemLink = C_Item.GetItemInfo(itemID);
      if (itemName) then return itemName; end
      if (itemLink) then return itemLink; end
      C_Item.RequestLoadItemDataByID(itemID);
      return ("Item " .. tostring(itemID));
    end
  end

  -- Never show raw "item:ID" to user (splash, chat, UI) â€“ only if we didn't handle it above
  local id = (type(buffName) == "string") and tonumber(string.match(buffName, "item:(%d+)"));
  if (id) then
    local itemName, itemLink = C_Item.GetItemInfo(id);
    if (itemName) then return itemName; end
    if (itemLink) then return itemLink; end
    return ("Item " .. tostring(id));
  end
  return buffName;
end

-- Retail often returns one table from GetTrackingInfo; older builds returned name, texture, active, category.

function SMARTBUFF_NormalizeMinimapTrackingInfo(slotIndex)
  local ok, r1, r2, r3, r4 = pcall(function() return C_Minimap.GetTrackingInfo(slotIndex); end);
  if (not ok or r1 == nil) then return nil, nil, nil, nil; end
  if (type(r1) == "table") then
    return r1.name, r1.texture, r1.active, r1.type;
  end
  return r1, r2, r3, r4;
end


-- Compare spellInfo table (from GetSpellInfo) to another spell ref; both may be tables with .name.
function SMARTBUFF_SpellInfoNameMatches(spellInfoA, spellRefB)
  if (spellInfoA == nil or spellRefB == nil) then return false; end
  local na = (type(spellInfoA) == "table" and spellInfoA.name) or spellInfoA;
  local nb = (type(spellRefB) == "table" and spellRefB.name) or spellRefB;
  return na ~= nil and nb ~= nil and na == nb;
end


function SMARTBUFF_SetBuff(buff, i, ia)
  if (buff == nil or buff[1] == nil) then return i; end
  local isItemType = (SMARTBUFF_IsItem(buff[3]) or buff[3] == SMARTBUFF_CONST_WEAPON);
  -- For item-type buffs, always resolve canonical itemID (from number, "item:ID", or link) so we dedupe and store one key only
  local itemID = nil;
  if (type(buff[1]) == "number" and buff[1] > 0) then
    itemID = buff[1];
  elseif (type(buff[1]) == "string") then
    itemID = extractItemID(buff[1]);
  end
  local key = (type(buff[1]) == "string") and buff[1] or nil;
  -- Dedupe item-type buffs: same key or same canonical item ID (avoids duplicate potion/flask/food entries)
  if (key and isItemType and SG.cBuffIndex[key]) then return i; end
  if (itemID and isItemType and SG.cBuffIndex["item:" .. tostring(itemID)]) then return i; end
  SG.cBuffs[i] = nil;
  SG.cBuffs[i] = {};
  if (type(buff[1]) == "table")
  then
    SG.cBuffs[i].BuffS = buff[1].name;
  else
    -- Item-type buffs: store canonical "item:ID" only so Order and SG.B[][][] use one key (no link vs placeholder vs number split)
    if (itemID and isItemType) then
      SG.cBuffs[i].BuffS = "item:" .. tostring(itemID);
    else
      SG.cBuffs[i].BuffS = buff[1];
    end
  end
  SG.cBuffs[i].DurationS = ceil(buff[2] * 60);
  SG.cBuffs[i].Type = buff[3];
  SG.cBuffs[i].CanCharge = false;

  if (SMARTBUFF_IsSpell(SG.cBuffs[i].Type)) then
    -- Resolve the player's known rank from the spellbook by name (Forever per-rank IDs).
    if (SG.cBuffs[i].BuffS) then
      SG.cBuffs[i].IDS, SG.cBuffs[i].BookID = SMARTBUFF_GetSpellID(SG.cBuffs[i].BuffS);
    end
    -- Definition spellID only if the player actually knows that spell (not other races' racials, etc.).
    if (not SG.cBuffs[i].IDS and type(buff[1]) == "table" and buff[1].spellID) then
      local sid = buff[1].spellID;
      if ((IsSpellKnown and IsSpellKnown(sid)) or (IsPlayerSpell and IsPlayerSpell(sid))) then
        SG.cBuffs[i].IDS = sid;
      end
    end

    -- Filter invalid/uncastable spells using valid spells cache
    if (SG.cBuffs[i].IDS and SmartBuffValidSpells and SmartBuffValidSpells.spells) then
      local isValid = SmartBuffValidSpells.spells[SG.cBuffs[i].IDS];
      if (isValid == false) then
        SG.cBuffs[i] = nil;
        return i;
      elseif (isValid == nil) then
        local spellName = C_Spell.GetSpellName(SG.cBuffs[i].IDS);
        if (not spellName) then
          if (not SmartBuffValidSpells.spells) then SmartBuffValidSpells.spells = {}; end
          SmartBuffValidSpells.spells[SG.cBuffs[i].IDS] = false;
          SG.cBuffs[i] = nil;
          return i;
        end
        -- Must be in the player's spellbook or known — do NOT use IsSpellKnownOrInSpellBook
        -- (Forever returns true for racials/spells the character does not have).
        local isSpellbookType = not SMARTBUFF_IsItem(SG.cBuffs[i].Type) and SG.cBuffs[i].Type ~= SMARTBUFF_CONST_TRACK and SG.cBuffs[i].Type ~= SMARTBUFF_CONST_TOY;
        if (isSpellbookType) then
          local isKnown = false;
          if (SG.cBuffs[i].BookID) then
            isKnown = true;
          elseif (IsSpellKnown and IsSpellKnown(SG.cBuffs[i].IDS)) then
            isKnown = true;
          elseif (IsPlayerSpell and IsPlayerSpell(SG.cBuffs[i].IDS)) then
            isKnown = true;
          end
          if (not isKnown) then
            if (not SmartBuffValidSpells.spells) then SmartBuffValidSpells.spells = {}; end
            SmartBuffValidSpells.spells[SG.cBuffs[i].IDS] = false;
            SG.cBuffs[i] = nil;
            return i;
          end
        end
        if (not SmartBuffValidSpells.spells) then SmartBuffValidSpells.spells = {}; end
        SmartBuffValidSpells.spells[SG.cBuffs[i].IDS] = true;
      end
    end
  end
  if (SG.cBuffs[i].IDS == nil and not (SMARTBUFF_IsItem(SG.cBuffs[i].Type) or SG.cBuffs[i].Type == SMARTBUFF_CONST_TRACK)) then
    SG.cBuffs[i] = nil;
    return i;
  end

  if (buff[4] ~= nil) then SG.cBuffs[i].LevelsS = buff[4] else SG.cBuffs[i].LevelsS = nil end
  if (buff[5] ~= nil) then SG.cBuffs[i].Params = buff[5] else SG.cBuffs[i].Params = SG.NIL end
  -- buff[6]=Links, buff[7]=Chain. Chain = exclusivity (one-of-these).
  -- Links = established groups that act in unexpected ways (e.g. weapon vs profession-tool).
  SG.cBuffs[i].Links = buff[6];
  SG.cBuffs[i].Chain = buff[7];
  SG.cBuffs[i].IsProfessionTool = SMARTBUFF_IsProfessionToolBuff(SG.cBuffs[i]);
  SG.cBuffs[i].SingleTargetGroup = (buff[8] == "single") and "single" or nil;

  if (SG.cBuffs[i].IDS ~= nil) then
    -- Try to get icon from cached spellInfo first
    local icon = nil;
    if (type(buff[1]) == "table" and buff[1].icon) then
      icon = buff[1].icon;
    else
      -- Fallback to API call
      icon = C_Spell.GetSpellTexture(SG.cBuffs[i].IDS);
    end
    SG.cBuffs[i].IconS = icon;
  else
    if (SG.cBuffs[i].Type == SMARTBUFF_CONST_TRACK) then
      local b = false;
      for n = 1, C_Minimap.GetNumTrackingTypes() do
        local trackN, trackT, trackA, trackC = SMARTBUFF_NormalizeMinimapTrackingInfo(n);
        if (trackN ~= nil) then
          --SMARTBUFF_AddMsgD(n..". "..trackN.." ("..tostring(trackC)..")");
          if (trackN == SG.cBuffs[i].BuffS) then
            b = true;
            --SG.cBuffs[i].IDS = SMARTBUFF_GetSpellID(SG.cBuffs[i].BuffS);
            SG.cBuffs[i].IDS = nil;
            SG.cBuffs[i].IconS = trackT;
          end
        end
      end
      if (not b) then
        SG.cBuffs[i] = nil;
        return i;
      end
    elseif (ia or SG.cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
      -- Try to get minLevel and texture from cache first
      local minLevel, texture = nil, nil;
      local cache = SmartBuffItemSpellCache;
      if (cache and cache.itemData) then
        minLevel, texture = getItemSpellCacheMinLevelTexture(cache, SG.cBuffs[i].BuffS);
      end

      -- If not in cache, try API call
      if (minLevel == nil) then
        local _, _, _, _, apiMinLevel, _, _, _, _, apiTexture = C_Item.GetItemInfo(SG.cBuffs[i].BuffS);
        minLevel = apiMinLevel;
        texture = apiTexture;
      end

      if (minLevel == nil) then
        -- Item data not loaded yet - request loading and keep buff (AllTheThings pattern: accept partial data)
        local itemID = extractItemID(SG.cBuffs[i].BuffS);
        if (itemID) then
          C_Item.RequestLoadItemDataByID(itemID);
        end
        -- Keep buff in list - will be validated when ITEM_DATA_LOAD_RESULT fires
        SG.cBuffs[i].IconS = nil;  -- No texture yet
      elseif (not isMinLevel(minLevel)) then
        SG.cBuffs[i] = nil;
        return i;
      else
        SG.cBuffs[i].IconS = texture;
      end
    else
      -- ITEM type (conjured items like Create Healthstone) or FOOD/SCROLL/POTION types
      SMARTBUFF_AddMsgD("SetBuff item-related type: " .. SG.cBuffs[i].BuffS .. " (Type: " .. SG.cBuffs[i].Type .. ")");
      -- Try to get minLevel and texture from cache first
      local minLevel, texture = nil, nil;
      local cache = SmartBuffItemSpellCache;
      if (cache and cache.itemData) then
        minLevel, texture = getItemSpellCacheMinLevelTexture(cache, SG.cBuffs[i].BuffS);
      end

      -- If not in cache, try API call
      if (minLevel == nil) then
        local _, _, _, _, apiMinLevel, _, _, _, _, apiTexture = C_Item.GetItemInfo(SG.cBuffs[i].BuffS);
        minLevel = apiMinLevel;
        texture = apiTexture;
      end

      SMARTBUFF_AddMsgD("  GetItemInfo(BuffS) minLevel: " .. tostring(minLevel));
      if (minLevel == nil) then
        -- Item data not loaded yet - request loading and keep buff (AllTheThings pattern: accept partial data)
        local itemID = extractItemID(SG.cBuffs[i].BuffS);
        if (itemID) then
          C_Item.RequestLoadItemDataByID(itemID);
          SMARTBUFF_AddMsgD("  Item data not loaded yet, requested loading (itemID: " .. itemID .. ")");
        end
        -- Keep buff in list - will be validated when ITEM_DATA_LOAD_RESULT fires
      elseif (not isMinLevel(minLevel)) then
        SMARTBUFF_AddMsgD("  Filtered out: level requirement not met");
        SG.cBuffs[i] = nil;
        return i;
      end
      -- For chained/linked items (e.g. Razorstone q1/q2/q3): count only this row's quality so we show each quality the player has
      local itemList = SG.cBuffs[i].Chain or SG.cBuffs[i].Links;
      local searchChain = itemList;
      if (itemList and #itemList > 1) then
        local requestedID = extractItemID(SG.cBuffs[i].BuffS);
        if (requestedID) then
          searchChain = { requestedID };
        end
      end
      local _, _, count, findItemTexture = SMARTBUFF_FindItem(SG.cBuffs[i].BuffS, searchChain);
      -- Use texture from cache if available, otherwise use FindItem result
      if (not texture) then
        texture = findItemTexture;
      end
      SMARTBUFF_AddMsgD("  FindItem result: count=" .. tostring(count) .. ", texture=" .. tostring(texture));

      if count then
        if (count == 0) then
          -- For ITEM type (conjured items), count == 0 is expected - spell creates the item
          -- For FOOD/SCROLL/POTION types, count == 0 means item not available - filter out
          if (SG.cBuffs[i].Type == SMARTBUFF_CONST_ITEM) then
            SMARTBUFF_AddMsgD("  Item not found (count=0), keeping buff (ITEM type - spell creates item)");
            -- Try to get texture from item name/chain or links for icon
            local chainTexture = nil;
            local iconList = SG.cBuffs[i].Chain or SG.cBuffs[i].Links;
            if (iconList and #iconList > 0) then
              -- Try first item in list for texture
              local itemID = extractItemID(iconList[1]);
              if (itemID) then
                local _, _, _, _, _, _, _, _, _, chainTexture = C_Item.GetItemInfo(itemID);
                if (chainTexture) then
                  SG.cBuffs[i].IconS = chainTexture;
                else
                  -- Chain item data not loaded - request loading
                  C_Item.RequestLoadItemDataByID(itemID);
                end
              end
            end
            if (not SG.cBuffs[i].IconS) then
              -- Fallback: texture from BuffS (already retrieved above)
              SG.cBuffs[i].IconS = texture;
            end
          else
            -- FOOD/SCROLL/POTION types - filter out if item not found
            SMARTBUFF_AddMsgD("  Filtered out: count=0 (item not in inventory for " .. SG.cBuffs[i].Type .. " type)");
            SG.cBuffs[i] = nil;
            return i;
          end
        else
          -- count > 0: Item found in inventory
          SMARTBUFF_AddMsgD("  Item found in inventory (count=" .. count .. "), keeping buff");
          SG.cBuffs[i].IconS = texture;
        end
      else
        SMARTBUFF_AddMsgD("  Filtered out: FindItem returned nil");
        SG.cBuffs[i] = nil;
        return i;
      end
    end
  end

  SMARTBUFF_AddMsgD("Add " .. SG.cBuffs[i].BuffS);

  SG.cBuffs[i].BuffG = nil; --buff[6]; -- Disabled for Cataclysm
  SG.cBuffs[i].IDG = nil;   --SMARTBUFF_GetSpellID(SG.cBuffs[i].BuffG);
  if (SG.cBuffs[i].IDG ~= nil) then
    SG.cBuffs[i].IconG = C_Spell.GetSpellTexture(SG.cBuffs[i].BuffG);
  else
    SG.cBuffs[i].IconG = nil;
  end
  --if (buff[7] ~= nil) then SG.cBuffs[i].DurationG = ceil(buff[7] * 60); else SG.cBuffs[i].DurationG = nil; end
  --if (buff[8] ~= nil) then SG.cBuffs[i].LevelsG = buff[8]; else SG.cBuffs[i].LevelsG = nil; end
  --if (buff[9] ~= nil) then SG.cBuffs[i].ReagentG = buff[9]; else SG.cBuffs[i].ReagentG = nil; end

  --[[
  if (SG.O.Debug) then
    local s = name;
    if (SG.cBuffs[i].IDS) then s = s .. " ID = " .. SG.cBuffs[i].IDS .. ", Icon = " .. SG.cBuffs[i].IconS; else s = s .. " ID = nil"; end
    if (SG.cBuffs[i].BuffG ~= nil) then
      s = s .. " - " .. SG.cBuffs[i].BuffG;
      if (SG.cBuffs[i].IDG) then s = s .. " ID = " .. SG.cBuffs[i].IDG .. ", Icon = " .. SG.cBuffs[i].IconG; else s = s .. " ID = nil"; end
    end
    SMARTBUFF_AddMsgD(s);
  end
  ]] --
  SG.cBuffIndex[SG.cBuffs[i].BuffS] = i;
  -- Register canonical item key so template / lookups find this buff when key is "item:ID"
  local itemID = extractItemID(SG.cBuffs[i].BuffS);
  if (itemID) then
    SG.cBuffIndex["item:" .. tostring(itemID)] = i;
  end
  if (SG.cBuffs[i].IDG ~= nil) then
    SG.cBuffIndex[SG.cBuffs[i].BuffG] = i;
  end
  initBuffSettings(SG.cBuffs[i]);

  return i + 1;
end

-- END SMARTBUFF_SetBuffs



function SMARTBUFF_IsTalentFrameVisible()
  return PlayerTalentFrame and PlayerTalentFrame:IsVisible();
end
