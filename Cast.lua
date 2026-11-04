-------------------------------------------------------------------------------

-- SmartBuff Cast

-------------------------------------------------------------------------------

local SG = SMARTBUFF_GLOBALS;

function resetInCombatCastsequenceProgress()
  wipe(SG.inCombatCastsequenceExpectedSpells);
  SG.inCombatCastsequenceNextIndex = 1;
  SG.inCombatCastsequenceAllDone = false;
end


-- Main Check functions
-- With HideSAIfIdle, show the action button only when a buff is pending. Visibility refresh is skipped in combat.
-- (visibility left unchanged until PLAYER_REGEN_ENABLED / next OOC check).
function SMARTBUFF_RefreshSAButtonIdleState(hasPending)
  if (not SG.isInit or not SG.O) then
    return;
  end
  if (not SG.O.Toggle) then
    if (not InCombatLockdown()) then
      SmartBuff_KeyButton:Hide();
    end
    return;
  end
  if (SG.O.HideSAButton) then
    if (not InCombatLockdown()) then
      SmartBuff_KeyButton:Hide();
    end
    return;
  end
  if (not SG.O.HideSAIfIdle) then
    if (not InCombatLockdown()) then
      SmartBuff_KeyButton:Show();
    end
    return;
  end
  if (InCombatLockdown() or UnitAffectingCombat("player")) then
    return;
  end
  if (hasPending) then
    SmartBuff_KeyButton:Show();
  else
    SmartBuff_KeyButton:Hide();
  end
end

-- 12.1+: tainted code cannot boolean-test secret booleans (e.g. UnitIsPVP when unit identity is secret).
-- Returns true/false when known; nil when secret so callers can skip instead of erroring.

function SMARTBUFF_PopulateBGResQueue()
  wipe(SG.cBuffsToCastAfterBGRes);
  local ct = SG.currentTemplate;
  local ord = buffsTemplateOrder();
  local tm = buffsTemplateTable(ct);
  if (not ord or not tm or not SG.cBuffIndex) then return; end
  for _, buffnS in ipairs(ord) do
    local cBuff = SG.cBuffs[SG.cBuffIndex[buffnS]];
    local bs = getBuffSettings(buffnS);
    if (cBuff and bs and bs.EnableS and cBuff.Type ~= SMARTBUFF_CONST_TRACK) then
      if (cBuff.IDS and not SMARTBUFF_IsItem(cBuff.Type) and not bs.SkipBGResQueue) then
        tinsert(SG.cBuffsToCastAfterBGRes, { actionType = SMARTBUFF_ACTION_SPELL, spellName = buffnS, slot = -1 });
      end
    end
  end
end


-- END SMARTBUFF_PopulateBGResQueue

-- Ephemeral list: all template-enabled CIn spellbook buffs in list order (UI state). Not stored globally.
function SMARTBUFF_BuildInCombatCInEntryList()
  local list = {};
  local ct = SG.currentTemplate;
  local ord = buffsTemplateOrder();
  local tm = buffsTemplateTable(ct);
  if (not ord or not tm or not SG.cBuffIndex) then return list; end
  for _, buffnS in ipairs(ord) do
    local cBuff = SG.cBuffs[SG.cBuffIndex[buffnS]];
    local bs = getBuffSettings(buffnS);
    if (cBuff and bs and bs.EnableS and cBuff.Type ~= SMARTBUFF_CONST_TRACK) then
      if (bs and bs.CIn) then
        if (cBuff.IDS and not SMARTBUFF_IsItem(cBuff.Type)) then
          tinsert(list, { actionType = SMARTBUFF_ACTION_SPELL, spellName = buffnS, slot = -1 });
        end
      end
    end
  end
  return list;
end


-- Template order entries â†’ only those missing on player (aura / create-item) at snapshot time (combat enter or rez).
-- PvP match active: auras always secret â€” CheckUnitBuffs not authoritative. Outside PvP: auras unreliable in combat;
-- filter is best-effort at stamp time; OOC scans elsewhere use normal visibility.
function SMARTBUFF_FilterInCombatCInEntriesMissingOnPlayer(entries)
  local out = {};
  if (not entries) then return out; end
  for _, e in ipairs(entries) do
    local sn = e and e.spellName;
    if (sn and sn ~= "") then
      local n = SG.cBuffIndex and SG.cBuffIndex[sn];
      local cBuff = n and SG.cBuffs[n];
      local miss = true;
      if (cBuff) then
        if (cBuff.Type == SMARTBUFF_CONST_ITEM) then
          local bag, slot, count = SMARTBUFF_FindItem(sn, cBuff.Chain or cBuff.Links);
          miss = ((count or 0) == 0);
        elseif (cBuff.Type ~= SMARTBUFF_CONST_WEAPON) then
          miss = (SMARTBUFF_CheckUnitBuffs("player", sn, cBuff.Type, cBuff.Links, cBuff.Chain) ~= nil);
        end
      end
      if (miss) then
        tinsert(out, { actionType = e.actionType or SMARTBUFF_ACTION_SPELL, spellName = sn, slot = e.slot or -1 });
      end
    end
  end
  return out;
end


-- Build CIn list (template order) â†’ filter missing on player â†’ /castsequence macro (first spell = step 1).
-- Called from REGEN / PLAYER_ALIVE when SG.O.InCombat; empty CIn â†’ nothing stamped.
-- If stamp fails because of lockdown, keep the macro written on the last out-of-combat pass.
-- Empty list or a macro that is too long still clears the key when attributes can be changed.
function SMARTBUFF_StampInCombatCastsequence()
  local base = SMARTBUFF_BuildInCombatCInEntryList();
  local filtered = SMARTBUFF_FilterInCombatCInEntriesMissingOnPlayer(base);
  if (InCombatLockdown()) then
    return;
  end
  if (SMARTBUFF_EnableInCombatCastsequenceMacroFromEntries(filtered)) then
    return;
  end
  SMARTBUFF_DisableInCombatCastsequenceMacro();
end


-- Turn off in-combat castsequence tracking and clear SmartBuff_KeyButton secure attrs when not in combat lockdown.
function SMARTBUFF_DisableInCombatCastsequenceMacro()
  SG.inCombatCastsequenceActive = false;
  resetInCombatCastsequenceProgress();
  if (InCombatLockdown() or not SmartBuff_KeyButton) then return; end
  SmartBuff_KeyButton:SetAttribute("type", nil);
  SmartBuff_KeyButton:SetAttribute("unit", nil);
  SmartBuff_KeyButton:SetAttribute("spell", nil);
  SmartBuff_KeyButton:SetAttribute("item", nil);
  SmartBuff_KeyButton:SetAttribute("target-slot", nil);
  SmartBuff_KeyButton:SetAttribute("target-item", nil);
  SmartBuff_KeyButton:SetAttribute("macrotext", nil);
  SmartBuff_KeyButton:SetAttribute("action", nil);
end


-- Stamp KeyButton from filtered CIn entries (spell names only in macro + null sentinel). Fails if lockdown or nothing to cast.
function SMARTBUFF_EnableInCombatCastsequenceMacroFromEntries(filteredEntries)
  if (InCombatLockdown() or not SmartBuff_KeyButton) then return false; end
  SG.inCombatCastsequenceActive = false;
  resetInCombatCastsequenceProgress();
  if (not filteredEntries or #filteredEntries == 0) then
    return false;
  end
  local parts = {};
  for _, e in ipairs(filteredEntries) do
    local sn = e and e.spellName;
    if (sn and sn ~= "") then
      tinsert(parts, sn);
    end
  end
  if (#parts == 0) then
    return false;
  end
  local prefix = "/castsequence reset=combat ";
  local sent = SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_SENTINEL;
  local function macroWithSpellList(realParts)
    return prefix .. table.concat(realParts, ", ") .. ", " .. sent;
  end
  local macro = macroWithSpellList(parts);
  if (#macro > SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_MACRO_MAX) then
    SMARTBUFF_AddMsgWarn("[SmartBuff] In-combat castsequence exceeds " .. SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_MACRO_MAX .. " chars; truncating.", true);
    while (#macro > SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_MACRO_MAX and #parts > 1) do
      tremove(parts);
      macro = macroWithSpellList(parts);
    end
    if (#macro > SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_MACRO_MAX) then
      return false;
    end
  end
  local snapshot = parts;
  for i, sn in ipairs(snapshot) do
    SG.inCombatCastsequenceExpectedSpells[i] = sn;
  end
  SG.inCombatCastsequenceNextIndex = 1;
  SG.inCombatCastsequenceAllDone = false;
  SG.lastInCombatCastsequenceNotifyKey = nil;
  SG.lastInCombatCastsequenceNotifyAt = 0;
  SmartBuff_KeyButton:SetAttribute("unit", nil);
  SmartBuff_KeyButton:SetAttribute("spell", nil);
  SmartBuff_KeyButton:SetAttribute("item", nil);
  SmartBuff_KeyButton:SetAttribute("target-slot", nil);
  SmartBuff_KeyButton:SetAttribute("target-item", nil);
  SmartBuff_KeyButton:SetAttribute("action", nil);
  SmartBuff_KeyButton:SetAttribute("type", "macro");
  SmartBuff_KeyButton:SetAttribute("macrotext", macro);
  SG.inCombatCastsequenceActive = true;
  SMARTBUFF_AddMsgD("In-combat castsequence on key (" .. tostring(#macro) .. " chars, " .. tostring(#snapshot) .. " spells)");
  return true;
end

-- Whether UNIT_SPELLCAST_SUCCEEDED matches expected CIn spell (template id, display name, or base spell).

function SMARTBUFF_InCombatCastsequenceMatchesSucceededSpell(spellId, spellKey)
  if (not spellId or not spellKey) then return false; end
  local okC, castName = pcall(C_Spell.GetSpellName, spellId);
  if (not okC or not castName) then return false; end
  if (castName == spellKey) then return true; end
  local idx = SG.cBuffIndex and SG.cBuffIndex[spellKey];
  local bookId = idx and SG.cBuffs[idx] and SG.cBuffs[idx].IDS;
  if (not bookId) then return false; end
  if (spellId == bookId) then return true; end
  local okB, bookName = pcall(C_Spell.GetSpellName, bookId);
  if (okB and bookName and castName == bookName) then return true; end
  if (C_Spell and C_Spell.GetBaseSpell) then
    local ok1, baseCast = pcall(C_Spell.GetBaseSpell, spellId);
    local ok2, baseBook = pcall(C_Spell.GetBaseSpell, bookId);
    if (ok1 and ok2 and type(baseCast) == "number" and type(baseBook) == "number" and baseCast == baseBook) then
      return true;
    end
  end
  return false;
end


-- Advance in-combat castsequence on spell success (any instance; BGRes is separate queue / Check path).
function SMARTBUFF_UpdateInCombatCastsequenceAfterSpellSucceeded(spellId)
  if (not spellId) then return; end
  if (not SG.O or not SG.O.Toggle or not SG.O.InCombat) then return; end
  if (not UnitAffectingCombat("player")) then return; end

  if (not SG.inCombatCastsequenceActive) then return; end
  if (SG.inCombatCastsequenceAllDone) then return; end
  local n = SG.inCombatCastsequenceNextIndex;
  local expected = SG.inCombatCastsequenceExpectedSpells and SG.inCombatCastsequenceExpectedSpells[n];
  if (not expected or not SMARTBUFF_InCombatCastsequenceMatchesSucceededSpell(spellId, expected)) then return; end
  local now = GetTime();
  if ((now - SG.inCombatCastsequenceLastSucceededAt) < SG.SMARTBUFF_IN_COMBAT_CASTSEQUENCE_POP_DEBOUNCE) then return; end
  SG.inCombatCastsequenceLastSucceededAt = now;
  SG.inCombatCastsequenceNextIndex = n + 1;
  SG.lastInCombatCastsequenceNotifyKey = nil;
  if (SG.inCombatCastsequenceNextIndex > #(SG.inCombatCastsequenceExpectedSpells)) then
    SG.inCombatCastsequenceAllDone = true;
  end
end


-- Castsequence macro: no per-spell secure attrs â€” next stepâ€™s spell name + icon (same info as OOC â€œneeds Xâ€); throttled per step.
function SMARTBUFF_NotifyInCombatCastsequenceVisual(mode)
  if (mode ~= 1) then return; end
  if (SG.inCombatCastsequenceAllDone) then
    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
    return;
  end
  local spellKey = SG.inCombatCastsequenceExpectedSpells[SG.inCombatCastsequenceNextIndex]
    or SG.inCombatCastsequenceExpectedSpells[1];
  if (not spellKey) then
    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
    return;
  end
  local idx = SG.cBuffIndex and SG.cBuffIndex[spellKey];
  local cBuff = idx and SG.cBuffs[idx];
  local icon = (cBuff and cBuff.IconS) or nil;
  if (not icon and cBuff and cBuff.IDS) then
    icon = C_Spell.GetSpellTexture(cBuff.IDS);
  end
  if (not icon) then
    icon = SG.imgSB;
  end
  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, icon);
  local minGap = (SG.O and SG.O.AutoTimer) or 3;
  if (minGap < 1) then minGap = 1; end
  local now = GetTime();
  if (SG.lastInCombatCastsequenceNotifyKey == spellKey and (now - SG.lastInCombatCastsequenceNotifyAt) < minGap) then
    return;
  end
  SG.lastInCombatCastsequenceNotifyKey = spellKey;
  SG.lastInCombatCastsequenceNotifyAt = now;
  local target = UnitName("player") or "player";
  -- Same path as BuffUnit: spell name + short "in combat" tag (localized); getBuffDisplayName in SetMissingBuffMessage.
  local combatTag = SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX;
  if (combatTag == nil) then
    combatTag = " (in-combat)";
  end
  local buffLabel = spellKey .. combatTag;
  SMARTBUFF_SetMissingBuffMessage(target, buffLabel, icon, (cBuff and cBuff.CanCharge) or false, -1, nil, false);
end


-- Mode 1 reminder path: BuffUnit is skipped for "player" when skipPlayerBuffUnitForInCombatCastsequence (SG.O.InCombat castsequence path).
-- PvP OOC during active match uses BGRes list, not this. In combat: castsequence icon + throttled hint, or default icon if no macro.
function SMARTBUFF_NotifyInCombatCastsequenceReminders(mode)
  if (mode ~= 1) then return; end
  if (SG.inCombatCastsequenceActive) then
    SMARTBUFF_NotifyInCombatCastsequenceVisual(mode);
    return;
  end
  SG.lastInCombatCastsequenceNotifyKey = nil;
  if (SmartBuff_KeyButton) then
    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
  end
end


-- True when this spell cannot be cast on the unit. IsSpellInRange nil means the unit is not a valid
-- target (party-only spells on someone outside the group), not "in range".
-- UnitInRange is boolean on this client (true = in range); classic returned 1.
function SMARTBUFF_UnitIsOutOfBuffRange(spellRef, unit)
  if (not unit or unit == "player" or (UnitIsUnit and UnitIsUnit(unit, "player"))) then
    return false;
  end
  if (not UnitExists(unit)) then
    return false;
  end
  if (spellRef and C_Spell and C_Spell.SpellHasRange and C_Spell.SpellHasRange(spellRef)) then
    local inRange = C_Spell.IsSpellInRange(spellRef, unit);
    return inRange == false or inRange == 0 or inRange == nil;
  end
  if ((UnitInParty and UnitInParty(unit)) or (UnitInRaid and UnitInRaid(unit))) then
    local inRange = UnitInRange(unit);
    return inRange == false or inRange == 0;
  end
  return false;
end


-- Casts a spell
function SMARTBUFF_DoCast(unit, id, spellName, levels, buffType)
  local spellRef = id or spellName;
  SMARTBUFF_AddMsgD("doCast spell " .. tostring(spellRef));
  if (id == nil) then return 9; end
  if (buffType == SMARTBUFF_CONST_TRACK and (GetTrackingTexture() ~= "Interface\\Minimap\\Tracking\\None")) then
    --SMARTBUFF_AddMsgD("Track already enabled: " .. iconTrack);
    return 7;
  end

  -- check if spell has cooldown
  local cooldown = C_Spell.GetSpellCooldown(spellRef);
  local cd = nil;
  if (cooldown and type(cooldown) == "table") then
    cd = cooldown["duration"];
  end
  cd = tonumber(cd) or 0;
  -- Force numeric: secret values may survive tonumber(), validate with pcall before comparison
  local ok, _ = pcall(function() return cd + 0 end);
  if not ok then cd = 0; end
  if (cd > SG.maxSkipCoolDown) then
    return 4;
  elseif (cd > 0) then
    return 1;
  end

  -- Rangecheck. Group and group-item buffs only; self buffs are always in range.
  if (buffType == SMARTBUFF_CONST_GROUP or buffType == SMARTBUFF_CONST_GROUPALL or buffType == SMARTBUFF_CONST_ITEMGROUP) then
    if (SMARTBUFF_UnitIsOutOfBuffRange(spellRef, unit)) then
      return 3;
    end
  end

  -- check if you have enough mana/energy/rage to cast
  local isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellRef);
  if (notEnoughMana) then
    return 6;
  end

  return 0;
end

-- END SMARTBUFF_DoCast

-- checks if the unit is the player

function SMARTBUFF_InitActionButtonPos()
  if (InCombatLockdown()) then return end

  SG.isInitBtn = true;
  if (SG.O.ActionBtnX == nil) then
    SMARTBUFF_SetButtonPos(SmartBuff_KeyButton);
  else
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", SG.O.ActionBtnX, SG.O.ActionBtnY);
  end
  --print(format("x = %.0f, y = %.0f", SG.O.ActionBtnX, SG.O.ActionBtnY));
end


-- Reset all: SG.O, SG.B, and all caches (keeps SG.OG: account-level splash/tutorial). Full clear; requires ReloadUI.
function SMARTBUFF_ResetAll()
  SG.currentUnit = nil;
  SG.currentSpell = nil;
  SG.tCastRequested = 0;
  SMARTBUFF_InvalidateBuffCache();

  wipe(SMARTBUFF_Options);
  SMARTBUFF_Options = {};

  wipe(SMARTBUFF_Buffs);
  SMARTBUFF_Buffs = {};

  SMARTBUFF_WipeAndInitBuffListCache();
  SMARTBUFF_WipeAndInitItemSpellCache();
  SMARTBUFF_WipeAndInitBuffRelationsCache();
  SMARTBUFF_WipeAndInitToyCache();
  SMARTBUFF_WipeAndInitValidSpells();

  ReloadUI();
end


-- Reset only buffs: wipe all buff-related saved vars and reinit to safe defaults. Keeps SMARTBUFF_Options and global caches.
function SMARTBUFF_ResetBuffs()
  SG.currentUnit = nil;
  SG.currentSpell = nil;
  SG.tCastRequested = 0;
  SMARTBUFF_InvalidateBuffCache();

  wipe(SMARTBUFF_Buffs);
  SMARTBUFF_Buffs = {};
  SG.B = SMARTBUFF_Buffs;  -- Re-sync: SG.B was still pointing at old table; SetBuffs and UI use SG.B, so reset had no effect on second+ use

  SMARTBUFF_ClearValidSpells();

  SMARTBUFF_SetTemplate();
  initBuffOrder(true);
  SMARTBUFF_OptionsFrame_Close(true);
end


function SMARTBUFF_SetButtonPos(self)
  local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight();
  SG.O.ActionBtnX = x;
  SG.O.ActionBtnY = y;
  --print(format("x = %.0f, y = %.0f", x, y));
end


function SMARTBUFF_RebindKeys()
  -- Keybinding APIs are protected during combat; skip so we don't trigger ADDON_ACTION_BLOCKED
  if (InCombatLockdown()) then return; end
  ClearOverrideBindings(SmartBuffFrame);
  local i;
  SG.isRebinding = true;
  for i = 1, GetNumBindings(), 1 do
    local s = "";
    local command, category, key1, key2 = GetBinding(i);

    --if (command and key1) then
    --  SMARTBUFF_AddMsgD(i .. " = " .. command .. " - " .. key1;
    --end

    if (key1 and key1 == "MOUSEWHEELUP" and command ~= "SmartBuff_KeyButton") then
      SG.O.OldWheelUp = command;
      --SMARTBUFF_AddMsgD("Old wheel up: " .. command);
    elseif (key1 and key1 == "MOUSEWHEELDOWN" and command ~= "SmartBuff_KeyButton") then
      SG.O.OldWheelDown = command;
      --SMARTBUFF_AddMsgD("Old wheel down: " .. command);
    end

    if (command and command == "SMARTBUFF_BIND_TRIGGER") then
      --s = i .. " = " .. command;
      if (key1) then
        --s = s .. ", key1 = " .. key1 .. " rebound";
        SetOverrideBindingClick(SmartBuffFrame, false, key1, "SmartBuff_KeyButton");
      end
      if (key2) then
        --s = s .. ", key2 = " .. key2 .. " rebound";
        SetOverrideBindingClick(SmartBuffFrame, false, key2, "SmartBuff_KeyButton");
      end
      --SMARTBUFF_AddMsgD(s);
      break;
    end
  end

  if (SG.O.ScrollWheelUp) then
    SG.isKeyUpChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELUP", "SmartBuff_KeyButton", "MOUSEWHEELUP");
    --SMARTBUFF_AddMsgD("Set wheel up");
  else
    if (SG.isKeyUpChanged) then
      SG.isKeyUpChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELUP");
      --SMARTBUFF_AddMsgD("Set old wheel up: " .. SG.O.OldWheelUp);
    end
  end

  if (SG.O.ScrollWheelDown) then
    SG.isKeyDownChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELDOWN", "SmartBuff_KeyButton", "MOUSEWHEELDOWN");
    --SMARTBUFF_AddMsgD("Set wheel down");
  else
    if (SG.isKeyDownChanged) then
      SG.isKeyDownChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELDOWN");
      --SMARTBUFF_AddMsgD("Set old wheel down: " .. SG.O.OldWheelDown);
    end
  end
  SG.isRebinding = false;
end


function SMARTBUFF_ResetBindings()
  if (not SG.isRebinding) then
    SG.isRebinding = true;
    if (SG.O.OldWheelUp == "SmartBuff_KeyButton") then
      SetBinding("MOUSEWHEELUP", "CAMERAZOOMIN");
    else
      SetBinding("MOUSEWHEELUP", SG.O.OldWheelUp);
    end
    if (SG.O.OldWheelDown == "SmartBuff_KeyButton") then
      SetBinding("MOUSEWHEELDOWN", "CAMERAZOOMOUT");
    else
      SetBinding("MOUSEWHEELDOWN", SG.O.OldWheelDown);
    end
    SaveBindings(GetCurrentBindingSet());
    SMARTBUFF_RebindKeys();
  end
end


-- END Playerlist functions


-- Secure button functions, NEW TBC ---------------------------------------------------------------------------------------

-- Apply Fix Casting via the KeyButton's useOnKeyDown attribute (never touches the global CVar).
-- Mouse-wheel overrides need an explicit key-down action. Ordinary trigger keys,
-- mouse clicks, and /click macros must follow WoW's normal input transition;
-- forcing them to key-up makes keyboard overrides scan without casting.
function SMARTBUFF_ApplyKeyButtonUseOnKeyDown(forceDown)
  if (InCombatLockdown() or not SmartBuff_KeyButton) then return; end
  if (not SG.O or not SG.O.SBButtonFix or not forceDown) then
    SmartBuff_KeyButton:SetAttribute("useOnKeyDown", nil);
    return;
  end
  SmartBuff_KeyButton:SetAttribute("useOnKeyDown", true);
end


function SMARTBUFF_ShowSAButton()
  if (InCombatLockdown()) then
    return;
  end
  if (SG.O.HideSAButton) then
    SmartBuff_KeyButton:Hide();
  elseif (SG.O.HideSAIfIdle) then
    return;
  else
    SmartBuff_KeyButton:Show();
  end
end


-- Self and "cast on me" spells must not follow the current target. Rank comes from the spell ID
-- already chosen for this pass; subtext is the localized "Rank N" the macro token expects.
local function SMARTBUFF_PlayerSelfCastMacro(spellRef, fallbackName)
  local name = fallbackName;
  local spellID = nil;
  if (type(spellRef) == "number") then
    spellID = spellRef;
    local info = GetSpellInfo(spellRef);
    if (info and info.name) then
      name = info.name;
    end
  end
  if (type(name) ~= "string" or name == "") then
    return nil;
  end
  local sub = nil;
  if (spellID and C_Spell and C_Spell.GetSpellSubtext) then
    sub = C_Spell.GetSpellSubtext(spellID);
  end
  if (type(sub) == "string" and sub ~= "") then
    return string.format("/cast [@player] %s(%s)", name, sub);
  end
  return string.format("/cast [@player] %s", name);
end


local lastBuffType = "";
function SMARTBUFF_OnPreClick(self, button, down)
  if (not SG.isInit) then return end
  local mode = 0;
  local wheel = (button == "MOUSEWHEELUP" or button == "MOUSEWHEELDOWN");
  if (button) then
    if (wheel) then
      mode = 5;
      -- New wheel notch (key-down): reset zoom suppression for this gesture.
      -- Mousewheel often reports down=true only; also reset when down is omitted.
      if (down ~= false) then
        SG.scrollSkipZoom = false;
        SG.scrollZoomDone = false;
      end
    end
  end

  local td;
  if (lastBuffType == "") then
    td = 0.8;
  else
    td = SG.GlobalCd;
  end
  -- If we requested a cast but never got SUCCEEDED/FAILED (cast never went off), expire cooldown
  -- so scroll can retry. Do not expire while player is casting (e.g. long pet summon).
  -- Safe if combat interrupts (FAILED fires) or cast started then combat (SUCCEEDED/FAILED when done).
  local isCasting = false;
  do
    local ok, name = pcall(UnitCastingInfo, "player");
    if ok and name then isCasting = true; end
  end
  if ((SG.currentUnit or SG.currentSpell) and SG.tCastRequested > 0 and (GetTime() - SG.tCastRequested) > 2 and not isCasting) then
    SG.tAutoBuff = GetTime() - td - 0.1;
    SG.currentUnit = nil;
    SG.currentSpell = nil;
    SG.tCastRequested = 0;
  end

  -- Do not wipe secure attrs while in combat: InCombatLockdown() is often still false on the first combat
  -- ticks while UnitAffectingCombat("player") is true — that erased REGEN in-combat castsequence macro on SmartBuff_KeyButton.
  -- OOC clears so normal PreClick+Check can repopulate; in combat we keep attrs set by the macro stamp.
  if (not InCombatLockdown() and not UnitAffectingCombat("player")) then
    self:SetAttribute("type", nil);
    self:SetAttribute("unit", nil);
    self:SetAttribute("spell", nil);
    self:SetAttribute("item", nil);
    self:SetAttribute("macrotext", nil);
    self:SetAttribute("target-slot", nil);
    self:SetAttribute("target-item", nil);
    self:SetAttribute("action", nil);
  end

  -- Fix Casting: ordinary clicks follow WoW's setting; scroll fires on key-down. No global CVar change.
  if (SG.O.SBButtonFix and not InCombatLockdown()) then
    local isClick = (button == "LeftButton" or button == "RightButton");
    SMARTBUFF_ApplyKeyButtonUseOnKeyDown(not isClick);
  end

  --SMARTBUFF_AddMsgD("Last buff type: " .. lastBuffType .. ", set cd: " .. td);

  if (UnitCastingInfo("player")) then
    --print("Channeling...reset AutoBuff timer");
    SG.tAutoBuff = GetTime() + 0.7;
    return;
  end

  -- In-combat castsequence macro: each key press must reach the secure button; skip SG.tAutoBuff throttle and Check remap.
  if (SG.inCombatCastsequenceActive and SG.O and SG.O.Toggle and SG.O.InCombat and UnitAffectingCombat("player")) then
    local _, itPre = GetInstanceInfo();
    if (itPre ~= "arena" and itPre ~= "pvp") then
      return;
    end
    if ((C_PvP.GetActiveMatchState() or 0) < 3) then
      return;
    end
  end

  if (GetTime() < (SG.tAutoBuff + td)) then return end

  --SMARTBUFF_AddMsgD("next buff check");
  SG.tAutoBuff = GetTime();
  lastBuffType = "";
  SG.currentUnit = nil;
  SG.currentSpell = nil;
  SG.tCastRequested = 0;

  -- Call Check regardless of combat so BG-res queue can return a buff (user clicks when they have a non-combat moment)
  local ret, actionType, spellName, slot, unit, buffType, isBGRes = SMARTBUFF_Check(mode);
  if (ret and ret == 0 and actionType and spellName and unit and (not InCombatLockdown())) then
    SG.tLastBuffAttempt = GetTime();
    if (mode == 5) then
      SG.scrollSkipZoom = true; -- buff queued: do not CameraZoom for this scroll notch
    end
    lastBuffType = buffType or (isBGRes and spellName) or "";
    self:SetAttribute("type", actionType);
    self:SetAttribute("unit", unit);
    if (actionType == SMARTBUFF_ACTION_SPELL) then
      if (slot and slot > 0 and unit == "player") then
        self:SetAttribute("type", "macro");
        self:SetAttribute("macrotext", string.format("/cast %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
        --self:SetAttribute("target-item", slot);
        SMARTBUFF_AddMsgD("Weapon buff " .. spellName .. ", " .. slot);
      else
        local castSpell = (not isBGRes and SG.pendingCastSpellID) or spellName;
        SG.pendingCastSpellID = nil;
        local onPlayer = (unit == "player") or (UnitIsUnit and UnitIsUnit(unit, "player"));
        local macrotext = onPlayer and SMARTBUFF_PlayerSelfCastMacro(castSpell, spellName);
        if (macrotext) then
          self:SetAttribute("type", "macro");
          self:SetAttribute("unit", nil);
          self:SetAttribute("macrotext", macrotext);
        else
          self:SetAttribute("spell", castSpell);
        end
      end

      if (SG.cBuffIndex and SG.cBuffIndex[spellName]) then
        SG.currentUnit = unit;
        SG.currentSpell = spellName;
        SG.tCastRequested = GetTime();
      elseif (SMARTBUFF_REVIVE_PET and type(SMARTBUFF_REVIVE_PET) == "table" and SMARTBUFF_REVIVE_PET.name and spellName == SMARTBUFF_REVIVE_PET.name) then
        SG.currentUnit = unit;
        SG.currentSpell = spellName;
        SG.tCastRequested = GetTime();
      end
    elseif (actionType == SMARTBUFF_ACTION_ITEM) then
      self:SetAttribute("item", spellName);
      if (slot and slot > 0) then
        self:SetAttribute("type", "macro");
        self:SetAttribute("macrotext", string.format("/use %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
      end
    elseif (actionType == "action" and slot) then
      self:SetAttribute("action", slot);
    else
      SMARTBUFF_AddMsgD("Preclick: not supported actiontype -> " .. tostring(actionType));
    end

    if (isBGRes and SG.cBuffsToCastAfterBGRes and #SG.cBuffsToCastAfterBGRes > 0) then
      tremove(SG.cBuffsToCastAfterBGRes, 1);
    end

    --SG.isClearSplash = true;
    SG.tLastCheck = GetTime() - SG.O.AutoTimer + SG.GlobalCd;
  end
end


function SMARTBUFF_OnPostClick(self, button, down)
  if (not SG.isInit) then return end
  -- Mousewheel override steals CAMERAZOOM*. Re-zoom only when Zoom is on, or when this
  -- notch did not queue a buff (queue empty). Guard down+up so we zoom at most once.
  if (button == "MOUSEWHEELUP" or button == "MOUSEWHEELDOWN") then
    local allowZoom = SG.O.ScrollWheelZooming or not SG.scrollSkipZoom;
    if (allowZoom and not SG.scrollZoomDone) then
      if (button == "MOUSEWHEELUP") then
        CameraZoomIn(1);
      else
        CameraZoomOut(1);
      end
      SG.scrollZoomDone = true;
    end
    -- down=false is the key-up half. down=nil is a wheel click that does not report it.
    -- Only a real key-down (down==true) keeps the flag until that half's PostClick.
    if (down ~= true) then
      SG.scrollSkipZoom = false;
      SG.scrollZoomDone = false;
    end
  end

  if (InCombatLockdown()) then
    return
  end

  self:SetAttribute("type", nil);
  self:SetAttribute("unit", nil);
  self:SetAttribute("spell", nil);
  self:SetAttribute("item", nil);
  self:SetAttribute("target-slot", nil);
  self:SetAttribute("target-item", nil);
  self:SetAttribute("macrotext", nil);
  self:SetAttribute("action", nil);

  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);

  -- Resting Fix Casting state (click/macro friendly); no global CVar restore
  SMARTBUFF_ApplyKeyButtonUseOnKeyDown();

  --SMARTBUFF_AddMsgD("Button reseted, " .. button);
  --self:SetScript("OnClick", sScript);
end


function SMARTBUFF_SetButtonTexture(button, texture, text)
  --if (InCombatLockdown()) then return; end

  if (button and texture and texture ~= SG.sLastTexture) then
    SG.sLastTexture = texture;
    button:SetNormalTexture(texture);
    --SMARTBUFF_AddMsgD("Button slot texture set -> " .. texture);
    if (text) then
      --button.title:SetText(spell);
    end
  end
end
