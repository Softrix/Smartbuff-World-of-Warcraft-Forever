-- Paladin blessing and aura assignments.
-- Each paladin's client is the only writer of that paladin's record.
-- Other clients keep a cache of what that paladin last published.

local SG = SMARTBUFF_GLOBALS;

local PREFIX = "Smartbuff";
local MSG = "PA1 ";

local CLASSES = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" };
local ASSIGN_BTN = 24;
local ASSIGN_GAP = 8;

local BLESSING_ORDER = { "might", "wisdom", "kings", "salvation", "sanctuary", "light" };
local AURA_ORDER = { "devotion", "retribution", "fire", "frost", "shadow", "sanctity" };

local cache = {}; -- [shortName] = { lock, aura, blessings, known }
local menu;
local frame;
local createFrame;
local rows = {};
local publishQueued = false;
local rosterQueued = false;
local syncGen = 0;
local paladinsInGroup;

local function spellName(ref)
  if (type(ref) == "table") then return ref.name; end
  return ref;
end

local function spellId(ref)
  if (type(ref) == "table") then return ref.spellID; end
end

local function shortName(name)
  if (not name or name == "") then return nil; end
  local cut = string.match(name, "^([^%-]+)");
  return cut or name;
end

local function myName()
  return shortName(UnitName("player"));
end

local function knows(ref)
  local name = spellName(ref);
  -- Forever stores each rank as its own spell ID. IsSpellKnown(rank 1) is false
  -- once a higher rank is trained, so look the name up in the spellbook.
  if (name and SMARTBUFF_GetSpellID and SMARTBUFF_GetSpellID(name)) then
    return true;
  end
  local id = spellId(ref);
  if (not id) then return false; end
  if (IsPlayerSpell and IsPlayerSpell(id)) then return true; end
  if (IsSpellKnown and IsSpellKnown(id)) then return true; end
  return false;
end

local function blessingDefs()
  return {
    might      = { greater = SMARTBUFF_GBOM, single = SMARTBUFF_BOM },
    wisdom     = { greater = SMARTBUFF_GBOW, single = SMARTBUFF_BOW },
    kings      = { greater = SMARTBUFF_GBOK, single = SMARTBUFF_BOK },
    salvation  = { greater = SMARTBUFF_GBOSAL, single = SMARTBUFF_BOSAL },
    sanctuary  = { greater = SMARTBUFF_GBOS, single = SMARTBUFF_BOS },
    light      = { greater = SMARTBUFF_GBOL, single = SMARTBUFF_BOL },
  };
end

local function auraDefs()
  return {
    devotion     = SMARTBUFF_DEVOTIONAURA,
    retribution  = SMARTBUFF_RETRIBUTIONAURA,
    fire         = SMARTBUFF_FIREAURA,
    frost        = SMARTBUFF_FROSTAURA,
    shadow       = SMARTBUFF_SHADOWAURA,
    sanctity     = SMARTBUFF_SANCTITYAURA,
  };
end

local function emptyRecord()
  return { lock = false, aura = nil, blessings = {}, known = {} };
end

local function myRecord()
  if (not SG.O.PaladinAssignRecord or type(SG.O.PaladinAssignRecord) ~= "table") then
    SG.O.PaladinAssignRecord = emptyRecord();
  end
  local rec = SG.O.PaladinAssignRecord;
  if (type(rec.blessings) ~= "table") then rec.blessings = {}; end
  if (type(rec.known) ~= "table") then rec.known = {}; end
  rec.lock = SG.O.PaladinAssignLock and true or false;
  return rec;
end

local fullNames = {}; -- roster name -> longer name from the addon sender

local function sameName(a, b)
  return a and b and string.lower(a) == string.lower(b);
end

local function firstWord(name)
  return name and string.match(name, "^(%S+)");
end

-- UnitName on this client is the first word. Addon messages use the full name ("Arabella Tink").
local function namesMatch(a, b)
  if (sameName(a, b)) then return true; end
  local fa, fb = firstWord(a), firstWord(b);
  if (not fa or not fb or not sameName(fa, fb)) then return false; end
  return sameName(a, fa) or sameName(b, fb);
end

local function recordFor(name)
  if (sameName(name, myName())) then return myRecord(); end
  if (not name) then return nil; end
  if (cache[name]) then return cache[name]; end
  local hit = nil;
  for key, rec in pairs(cache) do
    if (type(key) == "string" and namesMatch(key, name)) then
      if (hit) then return nil; end
      hit = rec;
    end
  end
  return hit;
end

local function isChannelToken(name)
  if (not name) then return true; end
  local token = string.upper(name);
  return token == "PARTY" or token == "RAID" or token == "GUILD" or token == "WHISPER"
    or token == "INSTANCE_CHAT" or token == "SAY" or token == "YELL" or token == "OFFICER" or token == "CHANNEL";
end

local function rosterSpell(name)
  if (not name or not paladinsInGroup) then return name; end
  local list = paladinsInGroup();
  for i = 1, #list do
    if (sameName(list[i], name)) then return list[i]; end
  end
  local hit = nil;
  for i = 1, #list do
    if (namesMatch(list[i], name)) then
      if (hit) then return name; end
      hit = list[i];
    end
  end
  return hit or name;
end

local function inRoster(name)
  local spelled = rosterSpell(name);
  if (not spelled or not paladinsInGroup) then return false; end
  local list = paladinsInGroup();
  for i = 1, #list do
    if (list[i] == spelled) then return true; end
  end
  return false;
end

local function senderName(...)
  local me = myName();
  local fallback = nil;
  for i = 1, select("#", ...) do
    local n = shortName(select(i, ...));
    if (n and not isChannelToken(n)) then
      if (sameName(n, me)) then
        fallback = fallback or me;
      elseif (inRoster(n)) then
        return rosterSpell(n);
      elseif (not fallback) then
        fallback = n;
      end
    end
  end
  return fallback;
end

local function isBlessingKey(key)
  return blessingDefs()[key] ~= nil;
end

local function isAuraKey(key)
  return auraDefs()[key] ~= nil;
end

local function isClassKey(key)
  for i = 1, #CLASSES do
    if (CLASSES[i] == key) then return true; end
  end
  return false;
end

local function isPaladin()
  return SG and SG.sPlayerClass == "PALADIN";
end

local function assignmentsEnabled()
  return SG and SG.O;
end

function SMARTBUFF_PaladinAssignmentActive()
  return assignmentsEnabled() and isPaladin();
end

local function blessingKeyForName(spell)
  local name = spellName(spell);
  if (not name) then return nil; end
  local defs = blessingDefs();
  for key, def in pairs(defs) do
    if (spellName(def.greater) == name or spellName(def.single) == name) then
      return key;
    end
  end
end

local function auraKeyForName(spell)
  local name = spellName(spell);
  if (not name) then return nil; end
  local defs = auraDefs();
  for key, ref in pairs(defs) do
    if (spellName(ref) == name) then return key; end
  end
end

function SMARTBUFF_PaladinAssignmentControlsSpell(spell)
  if (not SMARTBUFF_PaladinAssignmentActive()) then return false; end
  return blessingKeyForName(spell) ~= nil or auraKeyForName(spell) ~= nil;
end

local function preferredBlessing(key)
  local def = blessingDefs()[key];
  if (not def) then return nil; end
  if (knows(def.greater)) then return def.greater; end
  if (knows(def.single)) then return def.single; end
  return nil;
end

local function preferredAura(key)
  local ref = auraDefs()[key];
  if (ref and knows(ref)) then return ref; end
  return nil;
end

local function sameSpell(a, b)
  local na, nb = spellName(a), spellName(b);
  return na ~= nil and na == nb;
end

function SMARTBUFF_PaladinAssignmentAllows(spell, unitClass)
  if (not SMARTBUFF_PaladinAssignmentControlsSpell(spell)) then return true; end
  local rec = myRecord();
  local bkey = blessingKeyForName(spell);
  if (bkey) then
    if (not unitClass or rec.blessings[unitClass] ~= bkey) then return false; end
    local pref = preferredBlessing(bkey);
    return pref ~= nil and sameSpell(pref, spell);
  end
  local akey = auraKeyForName(spell);
  if (akey) then
    if (rec.aura ~= akey) then return false; end
    local pref = preferredAura(akey);
    return pref ~= nil and sameSpell(pref, spell);
  end
  return true;
end

-- A different blessing or aura in the same chain does not count as already done.
function SMARTBUFF_PaladinAssignmentChainSatisfies(defBuff, foundName)
  if (not SMARTBUFF_PaladinAssignmentControlsSpell(defBuff)) then return true; end
  local want = blessingKeyForName(defBuff) or auraKeyForName(defBuff);
  local got = blessingKeyForName(foundName) or auraKeyForName(foundName);
  return want ~= nil and want == got;
end

local function iconFor(ref)
  local id = spellId(ref);
  if (id and C_Spell and C_Spell.GetSpellTexture) then
    local tex = C_Spell.GetSpellTexture(id);
    if (tex) then return tex; end
  end
  if (type(ref) == "table" and ref.iconID) then return ref.iconID; end
  return "Interface\\Icons\\INV_Misc_QuestionMark";
end

local function iconForKey(kind, key)
  if (not key) then return "Interface\\PaperDoll\\UI-Backpack-EmptySlot"; end
  if (kind == "aura") then
    return iconFor(auraDefs()[key]);
  end
  local def = blessingDefs()[key];
  if (not def) then return "Interface\\PaperDoll\\UI-Backpack-EmptySlot"; end
  return iconFor(def.greater or def.single);
end

local function labelForKey(kind, key)
  if (not key) then return SMARTBUFF_PA_NONE or "None"; end
  local ref;
  if (kind == "aura") then
    ref = auraDefs()[key];
  else
    local def = blessingDefs()[key];
    ref = def and (def.greater or def.single);
  end
  return spellName(ref) or key;
end

local function knownKeys()
  local list = {};
  for i = 1, #BLESSING_ORDER do
    local key = BLESSING_ORDER[i];
    if (preferredBlessing(key)) then tinsert(list, key); end
  end
  for i = 1, #AURA_ORDER do
    local key = AURA_ORDER[i];
    if (preferredAura(key)) then tinsert(list, key); end
  end
  return list;
end

local function encodeBlessings(blessings)
  local parts = {};
  for i = 1, #CLASSES do
    local class = CLASSES[i];
    local key = blessings and blessings[class];
    if (key and isBlessingKey(key)) then
      tinsert(parts, class .. "=" .. key);
    end
  end
  if (#parts == 0) then return "-"; end
  return table.concat(parts, ",");
end

local function encodeKnown(list)
  if (not list or #list == 0) then return "-"; end
  return table.concat(list, ",");
end

local function decodeBlessings(text)
  local blessings = {};
  if (not text or text == "-" or text == "") then return blessings; end
  for pair in string.gmatch(text, "[^,]+") do
    local class, key = string.match(pair, "^([A-Z]+)=([%a]+)$");
    if (class and key and isClassKey(class) and isBlessingKey(key)) then
      blessings[class] = key;
    end
  end
  return blessings;
end

local function decodeKnown(text)
  local known = {};
  if (not text or text == "-" or text == "") then return known; end
  for key in string.gmatch(text, "[^,]+") do
    if (isBlessingKey(key) or isAuraKey(key)) then
      known[key] = true;
    end
  end
  return known;
end

local function groupChannel()
  -- A client that ignores the category argument makes IsInGroup(instance) true
  -- for a normal party, which would send every update to INSTANCE_CHAT and drop it.
  local home = LE_PARTY_CATEGORY_HOME;
  local inst = LE_PARTY_CATEGORY_INSTANCE;
  local inInst = inst and IsInGroup and IsInGroup(inst);
  local inHome = (not home) or not IsInGroup or IsInGroup(home);
  if (inInst and not inHome) then return "INSTANCE_CHAT"; end
  if (IsInRaid and IsInRaid()) then return "RAID"; end
  if (IsInGroup and IsInGroup()) then return "PARTY"; end
end

local function canSend()
  return assignmentsEnabled() and C_ChatInfo and C_ChatInfo.SendAddonMessage;
end

local function dispatchAddon(text, channel, target)
  local where = channel .. (target and (" to " .. target) or "");
  local sent = false;
  if (C_ChatInfo and C_ChatInfo.SendAddonMessage) then
    local ok, result;
    if (target) then
      ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, text, channel, target);
    else
      ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, text, channel);
    end
    sent = ok and result ~= false;
    if (SMARTBUFF_AddMsgD) then
      SMARTBUFF_AddMsgD("Addon sent (" .. where .. ") ok=" .. tostring(ok) .. " result=" .. tostring(result) .. " " .. tostring(text));
    end
  end
  if ((not sent) and SendAddonMessage and (not C_ChatInfo or SendAddonMessage ~= C_ChatInfo.SendAddonMessage)) then
    local ok, result = pcall(SendAddonMessage, PREFIX, text, channel, target);
    if (SMARTBUFF_AddMsgD) then
      SMARTBUFF_AddMsgD("Addon sent via SendAddonMessage (" .. where .. ") ok=" .. tostring(ok) .. " result=" .. tostring(result) .. " " .. tostring(text));
    end
  end
end

local function sendChannel(text)
  if (not canSend()) then
    if (SMARTBUFF_AddMsgD) then SMARTBUFF_AddMsgD("Addon send skipped: SendAddonMessage is not available"); end
    return;
  end
  local channel = groupChannel();
  if (not channel) then
    if (SMARTBUFF_AddMsgD) then SMARTBUFF_AddMsgD("Addon send skipped: not in a party, raid, or instance group"); end
    return;
  end
  dispatchAddon(text, channel);
end

local function whisperTargetForUnit(unit)
  if (not unit or not UnitExists(unit) or UnitIsUnit(unit, "player")) then return nil; end
  if (select(2, UnitClass(unit)) ~= "PALADIN") then return nil; end
  local name = shortName(UnitName(unit));
  -- Relog: the unit exists before the name arrives, and UnitName returns "Unknown".
  if (not name or name == "" or name == "Unknown" or name == UNKNOWNOBJECT) then return nil; end
  if (UnitFullName) then
    local full, realm = UnitFullName(unit);
    local _, myRealm = UnitFullName("player");
    if (full == "Unknown" or full == UNKNOWNOBJECT) then return nil; end
    if (full and realm and realm ~= "" and realm ~= myRealm) then
      return full .. "-" .. realm;
    end
    if (full) then return full; end
  end
  return name;
end

local function whisperTargets()
  local list = {};
  local function add(unit)
    local target = whisperTargetForUnit(unit);
    if (target) then tinsert(list, target); end
  end
  if (IsInRaid and IsInRaid()) then
    for i = 1, GetNumGroupMembers() do add("raid" .. i); end
  elseif (IsInGroup and IsInGroup()) then
    for i = 1, 4 do add("party" .. i); end
  end
  return list;
end

local function broadcast(text)
  sendChannel(text);
  local targets = whisperTargets();
  for i = 1, #targets do
    if (canSend()) then
      dispatchAddon(text, "WHISPER", targets[i]);
    end
  end
end

local function publishNow()
  if (not SMARTBUFF_PaladinAssignmentActive()) then return; end
  local rec = myRecord();
  local known = knownKeys();
  rec.known = {};
  for i = 1, #known do rec.known[known[i]] = true; end
  local aura = rec.aura and isAuraKey(rec.aura) and rec.aura or "-";
  -- Blessings and known spells are separate so each addon message stays under 255 characters.
  broadcast(MSG .. "STATE " .. (rec.lock and "1" or "0") .. " " .. aura .. " " .. encodeBlessings(rec.blessings));
  broadcast(MSG .. "KNOWN " .. encodeKnown(known));
end

local function publish()
  if (publishQueued) then return; end
  publishQueued = true;
  C_Timer.After(0.25, function()
    publishQueued = false;
    publishNow();
  end);
end

local function request(name, kind, a, b)
  local text;
  if (kind == "aura") then
    text = MSG .. "REQ " .. name .. " aura " .. (a or "-");
  else
    text = MSG .. "REQ " .. name .. " bless " .. a .. " " .. (b or "-");
  end
  broadcast(text);
end

local function paDebug(msg)
  if (SMARTBUFF_AddMsgD) then SMARTBUFF_AddMsgD(msg); end
end

function SMARTBUFF_PaladinAssign_OnMessage(text, ...)
  if (not assignmentsEnabled()) then return; end
  if (type(text) ~= "string" or string.sub(text, 1, 4) ~= MSG) then return; end
  local sender = senderName(...);
  if (not sender) then
    paDebug("Addon ignored, no sender: " .. text);
    return;
  end
  for i = 1, select("#", ...) do
    local n = shortName(select(i, ...));
    if (n and namesMatch(n, sender) and (not fullNames[sender] or #n > #fullNames[sender])) then
      fullNames[sender] = n;
    end
  end
  local body = string.sub(text, 5);
  local mine = sameName(sender, myName());

  if (body == "HELLO") then
    if (not mine) then
      paDebug("Addon HELLO from " .. sender);
      publishNow();
    end
    return;
  end

  if (string.sub(body, 1, 6) == "KNOWN ") then
    if (mine) then return; end
    local rec = cache[sender] or emptyRecord();
    rec.known = decodeKnown(string.sub(body, 7));
    cache[sender] = rec;
    paDebug("Addon applied KNOWN from " .. sender);
    if (frame and frame:IsShown()) then SMARTBUFF_PaladinAssign_Refresh(); end
    return;
  end

  if (string.sub(body, 1, 6) == "STATE ") then
    if (mine) then return; end
    local lock, aura, bless, known = string.match(body, "^STATE (%d) (%S+) (%S+) ?(.*)$");
    if (not lock) then
      paDebug("Addon STATE parse failed from " .. sender .. ": " .. body);
      return;
    end
    local rec = cache[sender] or emptyRecord();
    rec.lock = (lock == "1");
    if (aura ~= "-" and isAuraKey(aura)) then rec.aura = aura; else rec.aura = nil; end
    rec.blessings = decodeBlessings(bless);
    rec.hasState = true;
    -- Older clients put the known-spell list on the same STATE line.
    if (known and known ~= "") then
      rec.known = decodeKnown(known);
    end
    cache[sender] = rec;
    paDebug("Addon applied STATE from " .. sender .. " aura=" .. tostring(rec.aura) .. " blessings=" .. bless);
    if (frame and frame:IsShown()) then SMARTBUFF_PaladinAssign_Refresh(); end
    return;
  end

  if (string.sub(body, 1, 4) == "REQ ") then
    if (not isPaladin()) then return; end
    local name, kind, a, b = string.match(body, "^REQ (%S+) (%S+) (%S+) ?(.*)$");
    if (not name or not sameName(name, myName()) or mine) then
      paDebug("Addon REQ ignored from " .. sender .. ": " .. body);
      return;
    end
    local rec = myRecord();
    if (rec.lock) then
      paDebug("Addon REQ refused, locked, from " .. sender);
      publishNow();
      return;
    end
    if (kind == "aura") then
      rec.aura = (a ~= "-" and isAuraKey(a)) and a or nil;
    elseif (kind == "bless" and isClassKey(a)) then
      if (b == "-" or b == "" or not isBlessingKey(b)) then
        rec.blessings[a] = nil;
      else
        rec.blessings[a] = b;
      end
    else
      paDebug("Addon REQ parse failed from " .. sender .. ": " .. body);
      return;
    end
    paDebug("Addon applied REQ from " .. sender .. ": " .. body);
    publishNow();
    if (frame and frame:IsShown()) then SMARTBUFF_PaladinAssign_Refresh(); end
  end
end

local function inPartyOrRaid()
  return IsInGroup and IsInGroup();
end

-- Party and raid unit names are often missing for several seconds after a relog,
-- even though you are already grouped. GetNumGroupMembers is ready first.
local function groupRosterReady()
  if (not inPartyOrRaid()) then return true; end
  local expected = (GetNumGroupMembers and GetNumGroupMembers()) or 1;
  if (expected < 1) then expected = 1; end
  local seen = 0;
  if (IsInRaid and IsInRaid()) then
    for i = 1, expected do
      if (UnitExists("raid" .. i) and UnitName("raid" .. i)) then seen = seen + 1; end
    end
  else
    if (UnitExists("player") and UnitName("player")) then seen = seen + 1; end
    for i = 1, 4 do
      if (UnitExists("party" .. i) and UnitName("party" .. i)) then seen = seen + 1; end
    end
  end
  return seen >= expected;
end

local wasInGroup = false;

local function autoShowAssignments()
  if (not (SG and SG.O and SG.O.PaladinAssign ~= false and isPaladin() and inPartyOrRaid())) then return; end
  createFrame();
  if (frame and not frame:IsShown()) then frame:Show(); end
end

local function allOtherPaladinsCached()
  if (not paladinsInGroup) then return false; end
  local list = paladinsInGroup();
  local me = myName();
  for i = 1, #list do
    if (list[i] ~= me and not (cache[list[i]] and cache[list[i]].hasState)) then return false; end
  end
  return true;
end

local function announce()
  if (isPaladin()) then publishNow(); end
  broadcast(MSG .. "HELLO");
end

function SMARTBUFF_PaladinAssign_OnRoster()
  if (not assignmentsEnabled()) then
    if (frame and frame:IsShown()) then SMARTBUFF_PaladinAssign_Refresh(); end
    return;
  end
  if (rosterQueued) then return; end
  rosterQueued = true;
  syncGen = syncGen + 1;
  local gen = syncGen;
  C_Timer.After(1, function()
    rosterQueued = false;
    if (gen ~= syncGen or not assignmentsEnabled()) then return; end
    local inGroup = inPartyOrRaid();
    if (inGroup and not wasInGroup) then
      autoShowAssignments();
    end
    wasInGroup = inGroup and true or false;
    local function attempt(n)
      if (gen ~= syncGen or not assignmentsEnabled()) then return; end
      announce();
      if (frame and frame:IsShown()) then SMARTBUFF_PaladinAssign_Refresh(); end
      local waiting = inGroup and (not groupRosterReady() or not allOtherPaladinsCached());
      if (waiting and n < 8) then
        C_Timer.After(2, function() attempt(n + 1); end);
      end
    end
    attempt(1);
  end);
end

local function setOwn(kind, classKey, value)
  local rec = myRecord();
  if (kind == "aura") then
    rec.aura = value;
  elseif (kind == "lock") then
    SG.O.PaladinAssignLock = value and true or false;
    rec.lock = SG.O.PaladinAssignLock;
  else
    rec.blessings[classKey] = value;
  end
  publish();
  SMARTBUFF_PaladinAssign_Refresh();
end

local function choose(owner, kind, classKey, value)
  if (not isPaladin()) then return; end
  if (owner == myName()) then
    setOwn(kind, classKey, value);
  else
    local rec = cache[owner];
    if (rec and rec.lock) then
      if (SMARTBUFF_AddMsg) then SMARTBUFF_AddMsg(SMARTBUFF_PA_LOCKED or "Assignments are locked.", true); end
      return;
    end
    request(owner, kind, kind == "aura" and value or classKey, kind == "bless" and value or nil);
  end
end

local function hideMenu()
  if (menu) then menu:Hide(); end
end

local function showMenu(anchor, owner, kind, classKey)
  if (not menu) then
    menu = CreateFrame("Frame", "SmartBuffPaladinAssignMenu", UIParent, "BackdropTemplate");
    menu:SetFrameStrata("FULLSCREEN_DIALOG");
    menu:SetClampedToScreen(true);
    menu:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    });
    menu:SetBackdropColor(0, 0, 0, 0.95);
    menu:EnableMouse(true);
    menu.buttons = {};
    menu:SetScript("OnHide", function(self)
      self.owner = nil;
    end);
  end
  local rec = recordFor(owner) or emptyRecord();
  local keys = { false };
  local order = (kind == "aura") and AURA_ORDER or BLESSING_ORDER;
  local known = (owner == myName()) and nil or rec.known;
  for i = 1, #order do
    local key = order[i];
    local show = true;
    if (owner == myName()) then
      if (kind == "aura") then
        show = preferredAura(key) ~= nil;
      else
        show = preferredBlessing(key) ~= nil;
      end
    elseif (known and next(known) ~= nil) then
      show = known[key] and true or false;
    end
    if (show) then tinsert(keys, key); end
  end

  local y = -6;
  for i = 1, #keys do
    local btn = menu.buttons[i];
    if (not btn) then
      btn = CreateFrame("Button", nil, menu);
      btn:SetSize(180, 20);
      btn.icon = btn:CreateTexture(nil, "ARTWORK");
      btn.icon:SetSize(16, 16);
      btn.icon:SetPoint("LEFT", 4, 0);
      btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
      btn.label:SetPoint("LEFT", btn.icon, "RIGHT", 4, 0);
      btn.label:SetJustifyH("LEFT");
      btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD");
      menu.buttons[i] = btn;
    end
    local key = keys[i];
    if (key == false) then key = nil; end
    btn:SetPoint("TOPLEFT", 6, y);
    btn.icon:SetTexture(iconForKey(kind, key));
    btn.label:SetText(labelForKey(kind, key));
    btn:SetScript("OnClick", function()
      choose(menu.owner, menu.kind, menu.classKey, key);
      hideMenu();
    end);
    btn:Show();
    y = y - 20;
  end
  for i = #keys + 1, #menu.buttons do
    menu.buttons[i]:Hide();
  end
  menu.owner = owner;
  menu.kind = kind;
  menu.classKey = classKey;
  menu:SetSize(196, 12 + (#keys * 20));
  menu:ClearAllPoints();
  menu:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2);
  menu:Show();
end

local function styleIconButton(btn)
  btn:SetSize(ASSIGN_BTN, ASSIGN_BTN);
  btn.icon = btn:CreateTexture(nil, "ARTWORK");
  btn.icon:SetAllPoints();
  btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
end

local function bindIconButton(btn, owner, kind, classKey)
  btn.owner = owner;
  btn.kind = kind;
  btn.classKey = classKey;
  local rec = recordFor(owner);
  local key = nil;
  if (rec) then
    if (kind == "aura") then key = rec.aura; else key = rec.blessings and rec.blessings[classKey]; end
  end
  btn.icon:SetTexture(iconForKey(kind, key));
  local viewer = not isPaladin();
  local locked = (not viewer) and owner ~= myName() and rec and rec.lock;
  btn.icon:SetDesaturated(false);
  btn:SetScript("OnClick", function(self)
    hideMenu();
    if (not isPaladin()) then return; end
    local current = recordFor(self.owner);
    if (self.owner ~= myName() and current and current.lock) then
      if (SMARTBUFF_AddMsg) then SMARTBUFF_AddMsg(SMARTBUFF_PA_LOCKED or "Assignments are locked.", true); end
      return;
    end
    showMenu(self, self.owner, self.kind, self.classKey);
  end);
  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(labelForKey(self.kind, key));
    if (viewer) then
      GameTooltip:AddLine(SMARTBUFF_PA_VIEWONLY or "You can view assignments, not change them.", 1, 1, 1, true);
    elseif (locked) then
      GameTooltip:AddLine(SMARTBUFF_PA_LOCKED or "Assignments are locked.", 1, 0.2, 0.2, true);
    end
    GameTooltip:Show();
  end);
  btn:SetScript("OnLeave", function() GameTooltip:Hide(); end);
end

local function ensureRow(index)
  local row = rows[index];
  if (row) then return row; end
  row = CreateFrame("Frame", nil, frame);
  row:SetSize(frame:GetWidth() - 16, 26);
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
  row.name:SetPoint("LEFT", 16, 0);
  row.name:SetWidth(150);
  row.name:SetJustifyH("LEFT");
  row.lock = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate");
  row.lock:SetSize(22, 22);
  row.lock:SetPoint("LEFT", row.name, "RIGHT", 0, 0);
  row.lock:SetScript("OnClick", function(self)
    setOwn("lock", nil, self:GetChecked());
  end);
  row.lock:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(SMARTBUFF_PA_LOCK or "Lock my assignments");
    GameTooltip:Show();
  end);
  row.lock:SetScript("OnLeave", function() GameTooltip:Hide(); end);
  row.aura = CreateFrame("Button", nil, row);
  styleIconButton(row.aura);
  row.aura:SetPoint("LEFT", row.lock, "RIGHT", 12, 0);
  row.classes = {};
  local prev = row.aura;
  for i = 1, #CLASSES do
    local btn = CreateFrame("Button", nil, row);
    styleIconButton(btn);
    btn:SetPoint("LEFT", prev, "RIGHT", ASSIGN_GAP, 0);
    row.classes[CLASSES[i]] = btn;
    prev = btn;
  end
  rows[index] = row;
  return row;
end

function paladinsInGroup()
  local list = {};
  local seen = {};
  local function add(unit)
    if (not unit or not UnitExists(unit)) then return; end
    if (select(2, UnitClass(unit)) ~= "PALADIN") then return; end
    local name = shortName(UnitName(unit));
    if (not name or seen[name]) then return; end
    seen[name] = true;
    tinsert(list, name);
  end
  if (IsInRaid and IsInRaid()) then
    for i = 1, GetNumGroupMembers() do add("raid" .. i); end
  elseif (IsInGroup and IsInGroup()) then
    add("player");
    for i = 1, 4 do add("party" .. i); end
  else
    add("player");
  end
  table.sort(list, function(a, b)
    if (a == myName()) then return true; end
    if (b == myName()) then return false; end
    return a < b;
  end);
  return list;
end

function SMARTBUFF_PaladinAssign_AlignHeader(row)
  if (not frame or not frame.header or not row) then return; end
  frame.header.lockLabel:ClearAllPoints();
  frame.header.lockLabel:SetPoint("BOTTOM", row.lock, "TOP", 0, 2);
  frame.header.auraLabel:ClearAllPoints();
  frame.header.auraLabel:SetPoint("BOTTOM", row.aura, "TOP", 0, 2);
  for i = 1, #CLASSES do
    local class = CLASSES[i];
    local icon = frame.header.icons[class];
    local btn = row.classes[class];
    if (icon and btn) then
      icon:ClearAllPoints();
      icon:SetPoint("BOTTOM", btn, "TOP", 0, 3);
    end
  end
end

local function ensureCombatAnnounce()
  if (frame.combatAnnounce) then return frame.combatAnnounce; end
  local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate");
  cb:SetSize(22, 22);
  local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
  text:SetText(SMARTBUFF_PA_ANNOUNCE_COMBAT or "Announce my blessing while in combat");
  cb.label = text;
  cb:SetScript("OnClick", function(self)
    if (not SG.O) then return; end
    SG.O.PaladinAssignCombatAnnounce = self:GetChecked() and true or false;
  end);
  cb:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(SMARTBUFF_PA_ANNOUNCE_COMBAT or "Announce my blessing while in combat", 1, 1, 1);
    if (SMARTBUFF_PA_ANNOUNCE_COMBAT_TT) then
      GameTooltip:AddLine(SMARTBUFF_PA_ANNOUNCE_COMBAT_TT, 1, 0.82, 0, true);
    end
    GameTooltip:Show();
  end);
  cb:SetScript("OnLeave", function() GameTooltip:Hide(); end);
  frame.combatAnnounce = cb;
  return cb;
end

function SMARTBUFF_PaladinAssign_RemindSelf()
  if (not (SG.O and SG.O.PaladinAssignCombatAnnounce and isPaladin())) then return; end
  -- Forever hides helpful aura results in combat: allowed lookups return nil
  -- for active auras, so scanning here would announce false missing buffs.
  if (SG.isWoWProjectForever and (InCombatLockdown() or UnitAffectingCombat("player"))) then return; end
  if (not SMARTBUFF_BuffUnit) then return; end
  SG.paladinSelfRemind = true;
  pcall(SMARTBUFF_BuffUnit, "player", 1, 1);
  SG.paladinSelfRemind = false;
end

function SMARTBUFF_PaladinAssign_Refresh()
  if (not frame) then return; end
  local list = paladinsInGroup();
  local y = -46;
  for i = 1, #list do
    local name = list[i];
    local row = ensureRow(i);
    row:SetPoint("TOPLEFT", 8, y);
    row.name:SetText(fullNames[name] or name);
    local mine = (name == myName());
    row.lock:SetShown(mine);
    if (mine) then row.lock:SetChecked(SG.O.PaladinAssignLock and true or false); end
    bindIconButton(row.aura, name, "aura", nil);
    for c = 1, #CLASSES do
      bindIconButton(row.classes[CLASSES[c]], name, "bless", CLASSES[c]);
    end
    row:Show();
    y = y - 28;
  end
  if (list[1]) then SMARTBUFF_PaladinAssign_AlignHeader(rows[1]); end
  for i = #list + 1, #rows do
    rows[i]:Hide();
  end
  local cb = ensureCombatAnnounce();
  -- Forever cannot reliably determine whether assigned blessings or auras are
  -- missing in combat, so do not offer a reminder that produces false alerts.
  local showCb = isPaladin() and not SG.isWoWProjectForever;
  cb:SetShown(showCb);
  local extra = 0;
  if (showCb) then
    local lock = rows[1] and rows[1].lock;
    cb:ClearAllPoints();
    cb.label:ClearAllPoints();
    if (lock) then
      local drop = 28 * math.max(#list - 1, 0) + 16;
      cb:SetPoint("TOPLEFT", lock, "BOTTOMLEFT", 0, -drop);
    end
    cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 0);
    cb:SetChecked(SG.O and SG.O.PaladinAssignCombatAnnounce and true or false);
    extra = 40;
  end
  local height = 54 + math.max(#list, 1) * 28 + extra;
  frame:SetHeight(height);
end

local function savePosition()
  if (not frame or not SG.O) then return; end
  local point, _, rel, x, y = frame:GetPoint(1);
  SG.O.PaladinAssignPos = { point or "CENTER", rel or "CENTER", x or 0, y or 0 };
end

function createFrame()
  if (frame) then return frame; end
  frame = CreateFrame("Frame", "SmartBuffPaladinAssignFrame", UIParent, "BackdropTemplate");
  frame:SetSize(28 + 150 + 22 + 12 + ASSIGN_BTN + (#CLASSES * (ASSIGN_BTN + ASSIGN_GAP)) + 28, 80);
  frame:SetFrameStrata("DIALOG");
  frame:SetClampedToScreen(true);
  frame:SetMovable(true);
  frame:EnableMouse(true);
  frame:RegisterForDrag("LeftButton");
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  });
  frame:SetScript("OnDragStart", function(self) self:StartMoving(); end);
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing();
    savePosition();
  end);
  frame:SetScript("OnHide", hideMenu);
  frame:SetScript("OnShow", function()
    SMARTBUFF_PaladinAssign_Refresh();
    if (assignmentsEnabled()) then
      announce();
    end
  end);

  local banner = frame:CreateTexture(nil, "OVERLAY");
  banner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header");
  banner:SetSize(360, 64);
  banner:SetPoint("TOP", frame, "TOP", 0, 12);
  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
  frame.title:SetPoint("TOP", banner, "TOP", 0, -14);
  frame.title:SetText(SMARTBUFF_PA_TITLE or "Paladin Assignments");

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
  close:SetPoint("TOPRIGHT", -4, -4);

  frame.header = {};
  frame.header.lockLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
  frame.header.lockLabel:SetText("Lock");
  frame.header.auraLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
  frame.header.auraLabel:SetText(SMARTBUFF_PA_AURA or "Aura");
  frame.header.icons = {};
  for i = 1, #CLASSES do
    local class = CLASSES[i];
    local btn = CreateFrame("Button", nil, frame);
    btn:SetSize(18, 18);
    local icon = btn:CreateTexture(nil, "ARTWORK");
    icon:SetAllPoints();
    local coords = SG.Icons and SG.Icons[class];
    if (coords) then
      icon:SetTexture(coords[1]);
      icon:SetTexCoord(coords[2], coords[3], coords[4], coords[5]);
    end
    btn:SetScript("OnEnter", function(self)
      local text = _G["SMARTBUFF_PA_HINT_" .. class];
      if (not text or text == "") then return; end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      GameTooltip:SetText(text, 1, 0.82, 0, 1, true);
      GameTooltip:Show();
    end);
    btn:SetScript("OnLeave", function() GameTooltip:Hide(); end);
    frame.header.icons[class] = btn;
  end

  local pos = SG.O and SG.O.PaladinAssignPos;
  if (pos) then
    frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]);
  else
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
  end
  frame:Hide();
  tinsert(UISpecialFrames, "SmartBuffPaladinAssignFrame");
  return frame;
end

function SMARTBUFF_PaladinAssign_Show()
  createFrame();
  frame:Show();
  SMARTBUFF_PaladinAssign_Refresh();
end

function SMARTBUFF_PaladinAssign_Toggle()
  createFrame();
  if (frame:IsShown()) then
    frame:Hide();
    return;
  end
  SMARTBUFF_PaladinAssign_Show();
end

function SMARTBUFF_PaladinAssign_SetupOptions()
  if (not SmartBuffOptionsFrame or SmartBuffPaladinAssignOpt) then
    if (SmartBuffPaladinAssignOpt) then
      SmartBuffPaladinAssignOpt:SetShown(true);
      SmartBuffPaladinAssignOpen:SetShown(true);
      SmartBuffPaladinAssignOpt:SetChecked(SG.O.PaladinAssign ~= false);
    end
    return;
  end
  if (not SmartBuffOptionsFrame_cbHideSAIfIdle) then return; end
  local cb = CreateFrame("CheckButton", "SmartBuffPaladinAssignOpt", SmartBuffOptionsFrame, "UICheckButtonTemplate");
  cb:SetSize(20, 20);
  cb:SetPoint("TOPLEFT", SmartBuffOptionsFrame_cbHideSAIfIdle, "BOTTOMLEFT", 0, -6);
  local text = _G[cb:GetName() .. "Text"];
  if (text) then
    text:SetText(SMARTBUFF_OFT_PALADINASSIGN or "Auto show Paladin assignments");
    text:SetFontObject(GameFontNormalSmall);
  end
  cb:SetScript("OnClick", function(self)
    SG.O.PaladinAssign = self:GetChecked() and true or false;
    if (SG.O.PaladinAssign) then autoShowAssignments(); end
  end);
  cb:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(SMARTBUFF_OFT_PALADINASSIGN or "Auto show Paladin assignments");
    if (SMARTBUFF_OFTT_PALADINASSIGN) then GameTooltip:AddLine(SMARTBUFF_OFTT_PALADINASSIGN, 1, 1, 1, true); end
    GameTooltip:Show();
  end);
  cb:SetScript("OnLeave", function() GameTooltip:Hide(); end);
  local btn = CreateFrame("Button", "SmartBuffPaladinAssignOpen", SmartBuffOptionsFrame, "UIPanelButtonTemplate");
  btn:SetSize(70, 33);
  btn:SetPoint("LEFT", SmartBuffOptionsFrameNews, "RIGHT", 5, 0);
  btn:SetText(SMARTBUFF_PA_OPEN or "Paladin");
  btn:SetScript("OnClick", SMARTBUFF_PaladinAssign_Toggle);
  if (SMARTBUFF_AttachTooltip and SMARTBUFF_OFTT_PALADINASSIGN) then
    SMARTBUFF_AttachTooltip(btn, SMARTBUFF_OFTT_PALADINASSIGN);
  end
  cb:SetShown(true);
  btn:SetShown(true);
  cb:SetChecked(SG.O.PaladinAssign ~= false);
end
