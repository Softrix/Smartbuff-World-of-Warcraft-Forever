-------------------------------------------------------------------------------
-- SmartBuff Buff
-------------------------------------------------------------------------------

local SG = SMARTBUFF_GLOBALS;
SG.IsChecking = false;

function knownBool(v)
  if (issecretvalue(v)) then return nil; end
  if (v) then return true; end
  return false;
end


-- Party/raid-style gate used by timer paths. wantAlive true = living player; false = dead player.
-- Any secret Unit* bool â†’ false (skip).
function isKnownFriendlyPlayerUnit(unit, wantAlive)
  if (not unit) then return false; end
  if (knownBool(UnitExists(unit)) ~= true) then return false; end
  if (knownBool(UnitIsConnected(unit)) ~= true) then return false; end
  if (knownBool(UnitIsFriend("player", unit)) ~= true) then return false; end
  if (knownBool(UnitIsPlayer(unit)) ~= true) then return false; end
  local dead = knownBool(UnitIsDeadOrGhost(unit));
  if (dead == nil) then return false; end
  if (wantAlive) then
    return not dead;
  end
  return dead;
end


function SMARTBUFF_PreCheck(mode, force)
  if (not SG.isInit) then return false end

  if (not SG.isInitBtn) then
    SMARTBUFF_InitActionButtonPos();
  end

  if (not SG.O.Toggle) then
    if (mode == 0) then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_DISABLED);
    end
    return false;
  end

  -- True when mounted/flying and we should skip the buff check.
  -- Classic Forever has no Crusader Aura, so Paladins skip while mounted like everyone else.
  local function shouldSkipBuffCheckWhenMounted()
    return IsMounted() or IsFlying();
  end

  -- Actively eating/drinking only: pause so we do not interrupt the meal.
  -- Mere sitting must not suppress checks (Forever has no UnitStandState; picnic latches isSitting).
  local pauseForPicnic = SMARTBUFF_IsPicnic("player");
  if (pauseForPicnic) then
    if (SmartBuffSplashFrame) then
      SMARTBUFF_Splash_Clear();
    end
    if (SmartBuff_KeyButton and SG.imgSB) then
      SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
    end
  end

  -- Skip buff check when any of the following are true; only if all are false do we proceed to run buffs.
  if ((mode == 1 and not SG.O.ToggleAuto) or shouldSkipBuffCheckWhenMounted() or LootFrame:IsVisible()
        or UnitOnTaxi("player") or UnitIsDeadOrGhost("player") or UnitIsCorpse("player")
        or pauseForPicnic
        or (mode ~= 1 and SMARTBUFF_IsFishing("player"))
        or (UnitInVehicle("player") or UnitHasVehicleUI("player"))
        --or (mode == 1 and (SG.O.ToggleAutoRest and IsResting()) and knownBool(UnitIsPVP("player")) ~= true)
        or (not SG.O.BuffInCities and IsResting() and knownBool(UnitIsPVP("player")) ~= true)) then
    if (UnitIsDeadOrGhost("player")) then
      SMARTBUFF_CheckBuffTimers();
    end
    return false;
  end

  -- Now check AutoTimer (only if we passed the mount check)
  if (mode == 1 and not force) then
    if ((GetTime() - SG.tLastCheck) < SG.O.AutoTimer) then
      return false;
    end
  end
  --SMARTBUFF_AddMsgD(string.format("%.2f, %.2f", GetTime(), GetTime() - SG.tLastCheck));
  SG.tLastCheck = GetTime();

  -- If buffs can't casted, hide UI elements
  if (C_PetBattles.IsInBattle() or UnitInVehicle("player") or UnitHasVehicleUI("player")) then
    if (not InCombatLockdown() and SmartBuff_KeyButton:IsVisible()) then
      SmartBuff_KeyButton:Hide();
    end
    return false;
  else
    SMARTBUFF_ShowSAButton();
  end

  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, SG.imgSB);
  if (SmartBuffOptionsFrame:IsVisible()) then
    if (SG.O.HideSAIfIdle and not InCombatLockdown() and not UnitAffectingCombat("player")) then
      SMARTBUFF_RefreshSAButtonIdleState(false);
    end
    return false;
  end

  -- Forever may return a secret from UnitAffectingCombat even OOC; secrets are truthy in Lua and
  -- would latch isCombat / skipChecks, silencing every COut reminder (food included).
  SG.isCombat = (knownBool(UnitAffectingCombat("player")) == true);
  if (SG.O.Debug) then
    SMARTBUFF_AddMsgD(SG.isCombat and "In combat" or "Out of combat");
  end

  -- Don't run the check loop until buff list is ready (missing SG.B/Order, or Order has entries but SG.cBuffs wasn't built)
  if (not SG.B or not SG.B[getCurrentSpec()] or not SG.B[getCurrentSpec()].Order or (SG.numBuffs == 0 and next(SG.B[getCurrentSpec()].Order))) then
    SMARTBUFF_ScheduleSetBuffs();
    if (SG.O.HideSAIfIdle and not InCombatLockdown() and not UnitAffectingCombat("player")) then
      SMARTBUFF_RefreshSAButtonIdleState(false);
    end
    return false;
  end

  SG.sMsgWarning = "";
  SG.isFirstError = true;

  return true;
end

-- Bufftimer check functions

function SMARTBUFF_CheckBuffTimers()
  local n = 0;
  local ct = SG.currentTemplate;

  --SMARTBUFF_AddMsgD("SMARTBUFF_CheckBuffTimers");

  local cGrp = SG.cUnits;
  for subgroup in pairs(cGrp) do
    n = 0;
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (unit) then
          if (SMARTBUFF_CheckUnitBuffTimers(unit)) then
            n = n + 1;
          end
        end
      end
      if (SG.cBuffTimer[subgroup]) then
        SG.cBuffTimer[subgroup] = nil;
        SMARTBUFF_AddMsgD("Group " .. subgroup .. ": group timer reseted");
      end
    end
  end
end


-- END SMARTBUFF_CheckBuffTimers

-- if unit is dead, remove all timers
function SMARTBUFF_CheckUnitBuffTimers(unit)
  if (isKnownFriendlyPlayerUnit(unit, false)) then
    local _, uc = UnitClass(unit);
    local fd = nil;
    if (uc == "HUNTER") then
      fd = SMARTBUFF_IsFeignDeath(unit);
    end
    if (not fd) then
      if (SG.cBuffTimer[unit]) then
        SG.cBuffTimer[unit] = nil;
        SMARTBUFF_AddMsgD(UnitName(unit) .. ": unit timer reseted");
      end
      if (SG.cBuffTimer[uc]) then
        SG.cBuffTimer[uc] = nil;
        SMARTBUFF_AddMsgD(uc .. ": class timer reseted");
      end
      return true;
    end
  end
end

-- END SMARTBUFF_CheckUnitBuffTimers


-- Reset BT: clear buff timers only (runtime SG.cBuffTimer; no saved vars).

function SMARTBUFF_ResetBuffTimers()
  if (not SG.isInit) then return; end

  local ct = SG.currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;
  local buff = nil;
  local unit = nil;
  local obj = nil;
  local uc = nil;
  local n = 0;

  local cGrp = SG.cGroups;
  for subgroup in pairs(cGrp) do
    n = 0;
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (isKnownFriendlyPlayerUnit(unit, true)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (SG.cBuffs[i] and SG.cBuffs[i].BuffS) do
            d = -1;
            buff = nil;
            rbTime = 0;
            buffS = SG.cBuffs[i].BuffS;
            local bs = getBuffSettings(buffS);

            if (bs) then rbTime = bs.RBTime or 0; end
            if (rbTime <= 0) then
              rbTime = SG.O.RebuffTimer;
            end

            if (bs and SG.cBuffs[i].BuffG and bs.EnableG and SG.cBuffs[i].IDG ~= nil and SG.cBuffs[i].DurationG > 0) then
              d = SG.cBuffs[i].DurationG;
              buff = SG.cBuffs[i].BuffG;
              obj = subgroup;
            end

            if (d > 0 and buff) then
              if (not SG.cBuffTimer[obj]) then
                SG.cBuffTimer[obj] = {};
              end
              SG.cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end

            buff = nil;
            local assignOn = SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(buffS);
            if (buffS and bs and SG.cBuffs[i].IDS ~= nil and SG.cBuffs[i].DurationS > 0 and uc
                  and ((assignOn and SMARTBUFF_PaladinAssignmentAllows(buffS, uc))
                    or ((not assignOn) and bs.EnableS and bs[uc]))) then
              d = SG.cBuffs[i].DurationS;
              buff = buffS;
              obj = unit;
            end

            if (d > 0 and buff) then
              if (not SG.cBuffTimer[obj]) then
                SG.cBuffTimer[obj] = {};
              end
              SG.cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end

            i = i + 1;
          end
        end
      end
    end
  end
  --SG.isAuraChanged = true;
  SMARTBUFF_Check(1, true);
end


function SMARTBUFF_ShowBuffTimers()
  if (not SG.isInit) then return; end

  local ct = SG.currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;

  for unit in pairs(SG.cBuffTimer) do
    for buff in pairs(SG.cBuffTimer[unit]) do
      if (unit and buff and SG.cBuffTimer[unit][buff]) then
        d = -1;
        buffS = nil;
        if (SG.cBuffIndex[buff]) then
          i = SG.cBuffIndex[buff];
          if (SG.cBuffs[i].BuffS == buff and SG.cBuffs[i].DurationS > 0) then
            d = SG.cBuffs[i].DurationS;
            buffS = SG.cBuffs[i].BuffS;
          elseif (SG.cBuffs[i].BuffG == buff and SG.cBuffs[i].DurationG > 0) then
            d = SG.cBuffs[i].DurationG;
            buffS = SG.cBuffs[i].BuffS;
          end
          i = i + 1;
        end

        local bs = buffS and getBuffSettings(buffS);
        if (buffS and bs) then
          if (d > 0) then
            rbTime = bs.RBTime or 0;
            if (rbTime <= 0) then
              rbTime = SG.O.RebuffTimer;
            end
            tl = SG.cBuffTimer[unit][buff] + d - t;
            if (tl >= 0) then
              local s = "";
              if (string.find(unit, "^party") or string.find(unit, "^raid") or string.find(unit, "^player") or string.find(unit, "^pet")) then
                local un = UnitName(unit);
                if (un) then
                  un = " (" .. un .. ")";
                else
                  un = "";
                end
                s = "Unit " .. unit .. un;
              elseif (string.find(unit, "^%d$")) then
                s = "Grp " .. unit;
              else
                s = "Class " .. unit;
              end
              --SMARTBUFF_AddMsg(s .. ": " .. buff .. ", time left: " .. string.format(": %.0f", tl) .. ", rebuff time: " .. rbTime);
              SMARTBUFF_AddMsg(string.format("%s: %s, time left: %.0f, rebuff time: %.0f", s, buff, tl, rbTime));
            else
              SG.cBuffTimer[unit][buff] = nil;
            end
          else
            --SMARTBUFF_AddMsgD("Removed: " .. buff);
            SG.cBuffTimer[unit][buff] = nil;
          end
        end
      end
    end
  end
end


-- END SMARTBUFF_ResetBuffTimers


-- Synchronize the internal buff timers with the UI timers
function SMARTBUFF_SyncBuffTimers()
  if (not SG.isInit or SG.isSync or SG.isSetBuffs or SMARTBUFF_IsTalentFrameVisible()) then return; end
  SG.isSync = true;
  SG.tSync = GetTime();

  local ct = getCurrentTemplate();
  local rbTime = 0;
  local i = 0;
  local buffS = nil;
  local unit = nil;
  local uc = nil;
  local n = 0;

  local cGrp = SG.cGroups;
  for subgroup in pairs(cGrp) do
    n = 0;
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (isKnownFriendlyPlayerUnit(unit, true)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (SG.cBuffs[i] and SG.cBuffs[i].BuffS) do
            rbTime = 0;
            buffS = SG.cBuffs[i].BuffS;
            local bs = getBuffSettings(buffS);

            if (bs and bs.RBTime ~= nil) then
              rbTime = bs.RBTime;
              if (rbTime <= 0) then
                rbTime = SG.O.RebuffTimer;
              end
            end

            if (buffS and bs and bs.EnableS and SG.cBuffs[i].IDS ~= nil and SG.cBuffs[i].DurationS > 0) then
              if (SG.cBuffs[i].Type ~= SMARTBUFF_CONST_SELF or (SG.cBuffs[i].Type == SMARTBUFF_CONST_SELF and SMARTBUFF_IsPlayer(unit))) then
                SMARTBUFF_SyncBuffTimer(unit, unit, SG.cBuffs[i]);
              end
            end

            i = i + 1;
          end -- END while
        end
      end     -- END for
    end
  end         -- END for

  SG.isSync = false;
  SG.isSyncReq = false;
end


function SMARTBUFF_SyncBuffTimer(unit, grp, cBuff)
  if (not unit or not grp or not cBuff) then return end
  local d = cBuff.DurationS;
  local buff = cBuff.BuffS;
  if (d and d > 0 and buff) then
    local t = GetTime();
    local ret, _, _, timeleft = SMARTBUFF_CheckUnitBuffs(unit, buff, cBuff.Type, cBuff.Links, cBuff.Chain);
    if (ret == nil and timeleft ~= nil) then
      if (not SG.cBuffTimer[grp]) then SG.cBuffTimer[grp] = {} end
      st = round(t - d + timeleft, 2);
      if (not SG.cBuffTimer[grp][buff] or (SG.cBuffTimer[grp][buff] and SG.cBuffTimer[grp][buff] ~= st)) then
        SG.cBuffTimer[grp][buff] = st;
        if (timeleft > 60) then
          SMARTBUFF_AddMsgD("Buff timer sync: " ..
          grp .. ", " .. buff .. ", " .. string.format("%.1f", timeleft / 60) .. "min");
        else
          SMARTBUFF_AddMsgD("Buff timer sync: " ..
          grp .. ", " .. buff .. ", " .. string.format("%.1f", timeleft) .. "sec");
        end
      end
    end
  end
end


-- check if the player is shapeshifted
function SMARTBUFF_IsShapeshifted()
  if (SG.sPlayerClass == "SHAMAN") then
    if (GetShapeshiftForm(true) > 0) then
      local spellInfo = C_Spell.GetSpellInfo("Ghost Wolf");
      if (not spellInfo) then
        -- Spell data not loaded - request loading (AllTheThings pattern)
        C_Spell.RequestLoadSpellData("Ghost Wolf");
      end
      return true, spellInfo;
    end
  elseif (SG.sPlayerClass == "DRUID") then
    local i;
    for i = 1, GetNumShapeshiftForms(), 1 do
      local icon, active, castable, spellId = GetShapeshiftFormInfo(i);
      local spellIinfo = C_Spell.GetSpellInfo(spellId);
      if (not spellIinfo and spellId) then
        -- Spell data not loaded - request loading (AllTheThings pattern)
        C_Spell.RequestLoadSpellData(spellId);
      end
      if (active and castable and not SMARTBUFF_SpellInfoNameMatches(spellIinfo, SMARTBUFF_DRUID_TREANT)) then
        return true, spellIinfo;
      end
    end
  end
  return false, nil;
end

-- END SMARTBUFF_IsShapeshifted


-- Populate SG.cBuffsToCastAfterBGRes from current template (enabled self buffs). Used after death->resurrection in BG when aura state is secret.
-- Only spellbook buffs are queued (including weapon buffs like Windfury); flasks, food, scrolls, potions and other item buffs are skipped.

function checkFinish(hasPending)
  SG.IsChecking = false;
  if (SG.O and SG.O.HideSAIfIdle) then
    SMARTBUFF_RefreshSAButtonIdleState(hasPending);
  end
end


function SMARTBUFF_Check(mode, force)
  -- print("precheck "..tostring(SMARTBUFF_PreCheck(mode, force)))
  if (not SMARTBUFF_PreCheck(mode, force)) then return; end
  -- A Lua error mid-check can leave IsChecking true forever and silence all reminders.
  if (SG.IsChecking) then
    local started = SG.tCheckStarted or 0;
    if ((GetTime() - started) < 3) then
      return;
    end
    SMARTBUFF_AddMsgD("Clearing stuck IsChecking latch");
    SG.IsChecking = false;
  end
  SG.IsChecking = true;
  SG.tCheckStarted = GetTime();
  SG.pendingCastSpellID = nil;

  local ct = SG.currentTemplate;
  local unit = nil;
  local units = nil;
  local unitsGrp = nil;
  local unitB = nil;
  local unitL = nil;
  local unitU = nil;
  local uLevel = nil;
  local uLevelL = nil;
  local uLevelU = nil;
  local idL = nil;
  local idU = nil;
  local subgroup = 0;
  local i;
  local j;
  local n;
  local m;
  local rc;
  local rank;
  local reagent;
  local nGlobal = 0;

  SMARTBUFF_CheckBlocklist();

  -- Retail fact: (1) PvP match active â€” buffs secret to addons whether OOC or IC. (2) Outside PvP â€” secret in combat,
  -- visible OOC. skipChecks during match skips aura-based scan; BGRes + castsequence paths do not rely on match auras.
  -- Skip when: (in combat and SG.O.InCombat disabled) OR (in PvP and match active). Allow PvP prep when SG.O.InCombat.
  -- Forever addition: also skip in combat because helpful aura lookups return nil for player/group units.
  local _, instanceType = GetInstanceInfo();
  local inPvPInstance = (instanceType == "arena" or instanceType == "pvp");
  local pvPMatchState = inPvPInstance and (C_PvP.GetActiveMatchState() or 0) or 0;
  local pvPMatchActive = (pvPMatchState >= 3);
  local inCombat = InCombatLockdown() or (knownBool(UnitAffectingCombat("player")) == true);
  local skipChecks = (SG.isWoWProjectForever and inCombat)
    or (InCombatLockdown() and not SG.O.InCombat)
    or (inPvPInstance and pvPMatchActive);
  -- SG.O.InCombat: skip BuffUnit for "player" when non-PvP instance (always) or PvP with castsequence macro on key.
  -- Reminders: SMARTBUFF_NotifyInCombatCastsequenceReminders. Active match: skipChecks; BGRes returns before skipChecks.
  local skipPlayerBuffUnitForInCombatCastsequence = SG.O.InCombat and inCombat
    and ((not inPvPInstance) or SG.inCombatCastsequenceActive);
  -- In combat + castsequence: mode-1 splash/icon (BuffUnit not run for player).
  if (mode == 1 and skipPlayerBuffUnitForInCombatCastsequence) then
    SMARTBUFF_NotifyInCombatCastsequenceReminders(mode);
    if (not pvPMatchActive and SG.O.PaladinAssignCombatAnnounce and SMARTBUFF_PaladinAssign_RemindSelf) then
      SMARTBUFF_PaladinAssign_RemindSelf();
    end
  end
  -- BG resurrection: match active â†’ auras secret (OOC or IC); return first BGRes buff for SecureActionButton.
  -- Caller removes from queue only when it successfully sets the button (often needs non-combat moment).
  if (inPvPInstance and pvPMatchActive and SG.cBuffsToCastAfterBGRes and #SG.cBuffsToCastAfterBGRes > 0) then
    local entry = SG.cBuffsToCastAfterBGRes[1];
    if (entry and entry.actionType and entry.spellName) then
      checkFinish(true);
      return 0, entry.actionType, entry.spellName, entry.slot or -1, "player", nil, true;  -- 7th = isBGRes
    end
  end
  if skipChecks then
    if (mode == 1 and not pvPMatchActive and SG.O.PaladinAssignCombatAnnounce and SMARTBUFF_PaladinAssign_RemindSelf) then
      SMARTBUFF_PaladinAssign_RemindSelf();
    end
    checkFinish(false);
    return;
  end

  -- 1. buff target, if enabled
  if ((mode == 0 or mode == 5) and SG.O.BuffTarget) then
    local actionType, spellName, slot, buffType;
    i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit("target", 0, mode);
    -- A real cast on the target stops the scan. Cooldown (i == 1) or a bare success with no
    -- spell must not skip the player, who may still need a self or party-only buff.
    if (i == 0 and actionType and spellName) then
      -- Don't surface missing-buff when in combat and SG.O.InCombat disabled
      if (InCombatLockdown() and not SG.O.InCombat) then
        -- skip
      else
        checkFinish(true);
        return i, actionType, spellName, slot, "target", buffType;
      end
    end
  end

  -- 2. check groups
  local cGrp = SG.cGroups;
  local cOrd = SG.cOrderGrp;
  SG.isMounted = IsMounted() or IsFlying();
  -- Forever/template edge: if unit lists were wiped without rebuild, still check the player
  -- (self buffs / food reminders must not silently no-op).
  local sawAnyUnit = false;
  if (cGrp) then
    for _, unitsTbl in pairs(cGrp) do
      if (type(unitsTbl) == "table") then
        for _, u in pairs(unitsTbl) do
          if (u) then sawAnyUnit = true; break; end
        end
      end
      if (sawAnyUnit) then break; end
    end
  end
  if (not sawAnyUnit) then
    SMARTBUFF_AddSoloSetup();
    cGrp = SG.cGroups;
  end
  for _, subgroup in pairs(cOrd) do
    --SMARTBUFF_AddMsgD("Checking subgroup " .. subgroup .. ", " .. GetTime());
    if (cGrp[subgroup] ~= nil or (type(subgroup) == "number" and subgroup == 1)) then
      if (cGrp[subgroup] ~= nil) then
        units = cGrp[subgroup];
      else
        units = nil;
      end

      if (SG.cUnits and type(subgroup) == "number" and subgroup == 1) then
        unitsGrp = SG.cUnits[1];
      else
        unitsGrp = units;
      end

      -- check buffs
      if (units) then
        for _, unit in pairs(units) do
          if (SG.isSetBuffs) then break; end
          if (SG.O.Debug) then SMARTBUFF_AddMsgD("Checking single unit = " .. unit); end
          if (not (unit == "player" and skipPlayerBuffUnitForInCombatCastsequence)) then
            local spellName, actionType, slot, buffType;
            i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit(unit, subgroup, mode);

            if (i ~= nil and i <= 1) then
              -- Don't surface missing-buff when in combat and SG.O.InCombat disabled (aura check unreliable at combat start)
              if (i == 0 and InCombatLockdown() and not SG.O.InCombat) then
                -- skip, continue to next unit
              elseif (not InCombatLockdown() or (SG.O.InCombat and SG.O.ToggleAutoCombat)) then
                if (i == 0 and mode ~= 1) then
                  --SG.tLastCheck = GetTime() - SG.O.AutoTimer + SG.GlobalCd;
                  if (actionType == SMARTBUFF_ACTION_ITEM) then
                    --SG.tLastCheck = SG.tLastCheck + 2;
                  end
                end
                checkFinish(true);
                return i, actionType, spellName, slot, unit, buffType;
              end
            end
          end
        end
      end
    end
  end -- for groups

  if (mode == 0) then
    if (SG.sMsgWarning == "" or SG.sMsgWarning == " ") then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_NOTHINGTODO);
    else
      SMARTBUFF_AddMsgWarn(SG.sMsgWarning);
      SG.sMsgWarning = "";
    end
  end
  --SG.tLastCheck = GetTime();
  checkFinish(false);
end

-- END SMARTBUFF_Check


-- Maps Call Pet row values to Revive Pet (name, spell id, icon). Caller stores results in cast* locals only;
-- never mutates cBuff (shared row template).

function SMARTBUFF_HunterResolvePetSummonSpell(callSpellName, callSpellId, callIcon)
  local rp = SMARTBUFF_REVIVE_PET;
  if (type(rp) ~= "table" or not rp.name or not rp.spellID) then
    return callSpellName, callSpellId, callIcon;
  end
  local tex = C_Spell.GetSpellTexture(rp.spellID) or callIcon;
  return rp.name, rp.spellID, tex;
end



-- Unit eligibility for BuffUnit.
-- Party/raid: secret Unit* bool → skip (safe).
-- Player/self: Forever can secret PvP/visible/etc. even OOC; only skip when known-dead/taxi.
-- That secret→skip on self was silencing food/self reminders (Check ran, never splashed).
function isUnitEligibleForBuff(unit, playerIsPvP)
  if (SG.cBlocklist[unit]) then return false; end

  if (unit == "player") then
    if (knownBool(UnitIsDeadOrGhost("player")) == true) then return false; end
    if (knownBool(UnitIsCorpse("player")) == true) then return false; end
    if (knownBool(UnitOnTaxi("player")) == true) then return false; end
    local unitIsPvP = knownBool(UnitIsPVP("player"));
    if (unitIsPvP == nil) then return true; end
    if ((not unitIsPvP and (not playerIsPvP or SG.O.BuffPvP)) or (unitIsPvP and (playerIsPvP or SG.O.BuffPvP))) then
      return true;
    end
    return false;
  end

  if (knownBool(UnitExists(unit)) ~= true) then return false; end
  if (knownBool(UnitIsFriend("player", unit)) ~= true) then return false; end
  if (knownBool(UnitIsDeadOrGhost(unit)) ~= false) then return false; end
  if (knownBool(UnitIsCorpse(unit)) ~= false) then return false; end
  if (knownBool(UnitIsConnected(unit)) ~= true) then return false; end
  if (knownBool(UnitIsVisible(unit)) ~= true) then return false; end
  if (knownBool(UnitOnTaxi(unit)) ~= false) then return false; end

  local unitIsPvP = knownBool(UnitIsPVP(unit));
  if (unitIsPvP == nil) then return false; end
  if ((not unitIsPvP and (not playerIsPvP or SG.O.BuffPvP)) or (unitIsPvP and (playerIsPvP or SG.O.BuffPvP))) then
    return true;
  end
  return false;
end

-- Buffs a unit

function SMARTBUFF_BuffUnit(unit, subgroup, mode, spell)
  local bs = nil;  -- Buff settings for current buff
  local buff = nil;  -- Current buff name being checked
  local buffname = nil; -- Name of current buff
  local buffnS = nil; -- Order/list spell name for this row (template key; keep for timers and buff checks)
  local uc = nil; -- Unit class
  local ur = "NONE"; -- Unit role
  local un = nil; -- Unit name
  local uct = nil; -- Unit creature type
  local ucf = nil; -- Unit creature family
  local r;  -- Return value: 0 = success, 1 = item found, 20 = item not found
  local i;  -- Index of current buff in SG.cBuffs array
  local bt = 0; -- Buff target
  local cd = 0; -- Cooldown of current buff
  local cds = 0; -- Cooldown start time of current buff
  local charges = 0; -- Charges of current buff
  local handtype = ""; -- Hand type of current buff
  local bExpire = false; -- Expire flag for current buff
  local isPvP = false; -- Is PvP flag
  local bufftarget = nil; -- Buff target
  local rbTime = 0; -- Rebuff timer
  local bUsable = false; -- Usable flag for current buff
  local time = GetTime(); -- Current time
  local cBuff = nil; -- Current buff in SG.cBuffs array
  local iId = nil; -- Item ID of current buff
  local iSlot = -1; -- Item slot of current buff

  isPvP = (knownBool(UnitIsPVP("player")) == true);

  SMARTBUFF_CheckUnitBuffTimers(unit);

  --SMARTBUFF_AddMsgD("Checking " .. unit);

  if (isUnitEligibleForBuff(unit, isPvP)) then

    --print("Prep Check");

    _, uc = UnitClass(unit);
    un = UnitName(unit);
    ur = UnitGroupRolesAssigned(unit);
    uct = UnitCreatureType(unit);
    ucf = UnitCreatureFamily(unit);
    if (uct == nil) then uct = ""; end
    if (ucf == nil) then ucf = ""; end

    --if (un) then print("Grp "..subgroup.." checking "..un.." ("..unit.."/"..uc.."/"..ur.."/"..uct.."/"..ucf..")", 0, 1, 0.5); end

    SG.isShapeshifted, SG.sShapename = SMARTBUFF_IsShapeshifted();
    -- SG.sShapename is spellInfo array
    --while (SG.cBuffs[i] and SG.cBuffs[i].BuffS) do
    for i, buffnS in pairs(SG.B[getCurrentSpec()].Order) do
      --print(buffnS)
      if (SG.isSetBuffs or SmartBuffOptionsFrame:IsVisible()) then break; end
      cBuff = SG.cBuffs[SG.cBuffIndex[buffnS]];
      --buffnS = cBuff.BuffS;
      bs = getBuffSettings(buffnS);
      bExpire = false;
      handtype = "";
      charges = -1;
      bufftarget = nil;
      bUsable = false;
      iId = nil;
      iSlot = -1;

      if (cBuff and bs) then
        if (SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(buffnS)) then
          bUsable = SMARTBUFF_PaladinAssignmentAllows(buffnS, uc);
        else
          bUsable = bs.EnableS;
        end
      end

      -- Effective cast for this iteration only: copy row spell/id/icon into localsâ€”do not mutate cBuff (shared).
      -- buffnS stays the Order entry for timers, SMARTBUFF_CheckUnitBuffs, exclusives, and messages. castBuffnS,
      -- castSpellID, castIconS are what C_Spell, doCast, the spell returned to PreClick, and reminder icon use;
      -- hunter Revive overwrites those three when substituting. On enabled hunter SG.CheckPet self rows, refresh
      -- SG.sHunterPetNeedsRevive: true if pet dead/ghost, false if alive; if no pet unit, leave flag (UI error path).
      local castBuffnS = buffnS;
      local castSpellID = cBuff and cBuff.IDS or nil;
      local castIconS = cBuff and cBuff.IconS or nil;
      if (cBuff and cBuff.Params == SG.CheckPet and SG.sPlayerClass == "HUNTER" and SMARTBUFF_IsPlayer(unit) and bs and bs.EnableS) then
        if (UnitExists("pet")) then
          if (UnitIsDeadOrGhost("pet")) then
            SG.sHunterPetNeedsRevive = true;
          else
            SG.sHunterPetNeedsRevive = false;
          end
        end
      end
      local hunterSubstituteRevive = (cBuff and SG.sPlayerClass == "HUNTER" and cBuff.Params == SG.CheckPet and SG.sHunterPetNeedsRevive);
      if (hunterSubstituteRevive and cBuff) then
        castBuffnS, castSpellID, castIconS = SMARTBUFF_HunterResolvePetSummonSpell(buffnS, cBuff.IDS, cBuff.IconS);
      elseif (bUsable and cBuff and SMARTBUFF_IsSpell(cBuff.Type)) then
        local pickedID, rankReason = SMARTBUFF_PickSpellRank(cBuff, unit);
        if (rankReason == "too_low") then
          bUsable = false;
        elseif (pickedID) then
          castSpellID = pickedID;
        end
      end
      local spellCheck = castSpellID or castBuffnS;

      if (bUsable and spell and spell ~= buffnS) then
        bUsable = false;
        SMARTBUFF_AddMsgD("Exclusive check on " .. spell .. ", current spell = " .. buffnS);
      end
      if (bUsable and cBuff.Type == SMARTBUFF_CONST_SELF and not SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and bs.SelfNot and SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and cBuff.Params == SG.CheckFishingPole and SMARTBUFF_IsFishingPoleEquiped()) then bUsable = false end

      -- Check for buffs which depends on a pet
      if (bUsable and cBuff.Params == SG.CheckPet and UnitExists("pet")
          and not (SG.sPlayerClass == "HUNTER" and hunterSubstituteRevive)) then
        bUsable = false;
      end
      if (bUsable and cBuff.Params == SG.CheckPetNeeded and not UnitExists("pet")) then bUsable = false end

      -- Check for mount auras (Classic Forever has no Crusader Aura)
      if (bUsable and SG.isMounted) then
        bUsable = false;
      end

      -- Create-item spells (mage food/water/gems, warlock stones): skip when product is already in bags.
      if (bUsable and (cBuff.Params == SG.CheckConjure or cBuff.Params == SG.CheckConjureShard)) then
        local needed, reason = SMARTBUFF_ConjureIsNeeded(cBuff, buffnS);
        if (not needed) then
          bUsable = false;
          if (reason == "bags_full") then
            SMARTBUFF_NotifyConjureBagsFull(cBuff, buffnS);
          end
        end
      end

      if (bUsable and not (cBuff.Type == SMARTBUFF_CONST_TRACK or SMARTBUFF_IsItem(cBuff.Type))) then
        -- check if you have enough mana/rage/energy to cast
        local isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellCheck);
        local buffLabel = getBuffDisplayName(cBuff.BuffS, cBuff.Type) or cBuff.BuffS;
        if (notEnoughMana or isUsable == false) then
          bUsable = false;
          if (notEnoughMana) then
            SMARTBUFF_AddMsgD("Buff " .. buffLabel .. ", not enough mana!");
          else
            SMARTBUFF_AddMsgD("Buff " .. buffLabel .. " is not usable!");
          end
        elseif (mode ~= 1 and isUsable == nil and buffnS ~= ((type(SMARTBUFF_PWSHIELD) == "table" and SMARTBUFF_PWSHIELD.name) or SMARTBUFF_PWSHIELD)) then
          bUsable = false;
          SMARTBUFF_AddMsgD("Buff " .. buffLabel .. " is not usable!");
        end
      end

      local assignOn = SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(buffnS);
      -- In-combat assignment announce: reminder only, on the player, for the assigned aura and Paladin blessing.
      local selfAnnounce = SG.paladinSelfRemind and assignOn and SMARTBUFF_IsPlayer(unit);
      if (bUsable and (bs.EnableS or assignOn) and (cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK)
            and ((mode ~= 1 and ((SG.isCombat and bs.CIn) or (not SG.isCombat and bs.COut)))
              or (mode == 1 and (selfAnnounce or (bs.Reminder and ((not SG.isCombat and bs.COut)
                or (SG.isCombat and bs.CIn))))))) then
        --print("Check: "..buffnS)

        if (not bs.SelfOnly or (bs.SelfOnly and SMARTBUFF_IsPlayer(unit))) then
          -- get current spell cooldown
          cd = 0;
          cds = 0;
          if (cBuff.IDS) then
            local cooldown = C_Spell.GetSpellCooldown(spellCheck);
            if cooldown and type(cooldown) == "table" then
              cds = tonumber(cooldown["startTime"]) or 0;
              cd = tonumber(cooldown["duration"]) or 0;
            end
            -- Force numeric: secret values may survive tonumber(), validate with pcall before arithmetic
            local ok, _ = pcall(function() return cds + cd end);
            if not ok then cds = 0; cd = 0; end
            cd = (cds + cd) - GetTime();
            if (cd < 0) then
              cd = 0;
            end
            SMARTBUFF_AddMsgD(castBuffnS .. " cd = " .. cd);
          end

          -- check if spell has cooldown
          if (cd <= 0 or (mode == 1 and cd <= 1.5)) then
            if (cBuff.IDS and SG.sMsgWarning == SMARTBUFF_MSG_CD) then
              SG.sMsgWarning = " ";
            end

            rbTime = bs.RBTime;
            if (rbTime <= 0) then
              rbTime = SG.O.RebuffTimer;
            end

            SMARTBUFF_AddMsgD(tostring(uc) .. " " .. tostring(getCurrentTemplate()));

            -- Note: Only players (and pets) are valid targets for group buffs; NPCs do not benefit from buffs.
            if (not SMARTBUFF_IsInList(unit, un, bs.IgnoreList) and (((cBuff.Type == SMARTBUFF_CONST_GROUP or cBuff.Type == SMARTBUFF_CONST_ITEMGROUP)
                    and knownBool(UnitPlayerControlled(unit)) == true
                    and (bs[ur]
                      or (bs.SelfOnly and SMARTBUFF_IsPlayer(unit))
                      or ((assignOn or bs[uc]) and (knownBool(UnitIsPlayer(unit)) == true or uct == SMARTBUFF_HUMANOID or (uc == "DRUID" and (uct == SMARTBUFF_BEAST or uct == SMARTBUFF_ELEMENTAL))))
                      or (bs["HPET"] and uct == SMARTBUFF_BEAST and uc ~= "DRUID")
                      or (bs["DKPET"] and uct == SMARTBUFF_UNDEAD)
                      or (bs["WPET"] and (uct == SMARTBUFF_DEMON or (uc ~= "DRUID" and uct == SMARTBUFF_ELEMENTAL)) and ucf ~= SMARTBUFF_DEMONTYPE)))
                  or (cBuff.Type ~= SMARTBUFF_CONST_GROUP and SMARTBUFF_IsPlayer(unit))
                  or SMARTBUFF_IsInList(unit, un, bs.AddList))) then
              buff = nil;

              -- Tracking ability ------------------------------------------------------------------------
              if (cBuff.Type == SMARTBUFF_CONST_TRACK) then
                local druidTrackNeedCat = false;
                if (SG.sPlayerClass == "DRUID") then
                  local hu = (type(SMARTBUFF_TRACKHUMANOIDS) == "table" and SMARTBUFF_TRACKHUMANOIDS.name);
                  local be = (type(SMARTBUFF_TRACKBEASTS) == "table" and SMARTBUFF_TRACKBEASTS.name);
                  druidTrackNeedCat = (hu ~= nil and buffnS == hu) or (be ~= nil and buffnS == be);
                end
                local inCat = SMARTBUFF_SpellInfoNameMatches(SG.sShapename, SMARTBUFF_DRUID_CAT);
                -- Druid humanoids/beasts: no minimap check, reminder, or toggle until cat form.
                if (druidTrackNeedCat and not inCat) then
                  buff = nil;
                else
                  local slotIdx, isOn = nil, false;
                  for n = 1, C_Minimap.GetNumTrackingTypes() do
                    local trackN, trackT, trackA, trackC = SMARTBUFF_NormalizeMinimapTrackingInfo(n);
                    if (trackN ~= nil and trackN == buffnS) then
                      slotIdx = n;
                      isOn = (trackA == true or trackA == 1);
                      if (SG.O.Debug) then
                        SMARTBUFF_AddMsgD(n .. ". " .. trackN .. " (" .. tostring(trackC) .. ") active=" .. tostring(trackA));
                      end
                      break;
                    end
                  end
                  if (slotIdx == nil) then
                    buff = nil;
                  elseif (isOn) then
                    buff = nil;
                  elseif (mode == 1) then
                    buff = buffnS;
                  elseif (mode == 0 or mode == 5) then
                    pcall(function() C_Minimap.SetTracking(slotIdx, 1); end);
                    SMARTBUFF_AddMsgD("Tracking enabled: " .. buffnS);
                    return 0;
                  else
                    buff = nil;
                  end
                end

                -- Food, Scroll, Potion or conjured items ------------------------------------------------------------------------
              elseif (cBuff.Type == SMARTBUFF_CONST_FOOD or cBuff.Type == SMARTBUFF_CONST_SCROLL or cBuff.Type == SMARTBUFF_CONST_POTION or cBuff.Type == SMARTBUFF_CONST_ITEM or
                    cBuff.Type == SMARTBUFF_CONST_ITEMGROUP) then
                if (cBuff.Type == SMARTBUFF_CONST_ITEM) then
                  SMARTBUFF_AddMsgD("BuffUnit ITEM type: " .. buffnS);
                  SMARTBUFF_AddMsgD("  Params: " .. tostring(cBuff.Params));
                  SMARTBUFF_AddMsgD("  Chain: " .. (cBuff.Chain and tostring(#cBuff.Chain) .. " items" or "nil"));
                  bt = nil;
                  buff = nil;
                  if (cBuff.Params ~= SG.NIL) then
                    local cr = SMARTBUFF_CountReagent(cBuff.Params, cBuff.Chain);
                    SMARTBUFF_AddMsgD(cr .. " " .. cBuff.Params .. " found");
                    if (cr == 0) then
                      buff = cBuff.Params;
                    end
                  else
                    -- Params is nil, use Chain to find item
                    SMARTBUFF_AddMsgD("  Params is nil, checking Chain for items");
                    local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain);
                    SMARTBUFF_AddMsgD("  FindItem result: count=" .. tostring(count) .. ", bag=" .. tostring(bag) .. ", slot=" .. tostring(slot));
                    if (count == 0) then
                      SMARTBUFF_AddMsgD("  Item not found (count=0), will cast creation spell");
                      buff = buffnS; -- Use spell name for casting
                    else
                      SMARTBUFF_AddMsgD("  Item found in inventory (count=" .. count .. "), skipping cast");
                    end
                  end

                  -- Picnic: never remind/cast (would interrupt the meal).
                  -- Moving: still remind (mode 1) so the player knows to stop and eat; only skip
                  -- actual use below. Also clear a sticky move latch when live speed is 0.
                elseif (cBuff.Type == SMARTBUFF_CONST_FOOD) then
                  if (SG.isPlayerMoving and type(GetUnitSpeed) == "function") then
                    local speed = GetUnitSpeed("player");
                    if (type(speed) == "number" and speed == 0) then
                      SG.isPlayerMoving = false;
                    end
                  end
                  if (SMARTBUFF_IsPicnic(unit)) then
                    SMARTBUFF_AddMsgD("FOOD skip " .. tostring(buffnS) .. " picnic=true");
                    buff = nil;
                  -- TeaItemIds must be a real table: nil==nil was true for every food row and
                  -- routed them into CheckUnitBuffs(nil), which returns nothing → no splash.
                  elseif (SG.TeaItemIds and cBuff.Links and cBuff.Links == SG.TeaItemIds) then
                    buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, SMARTBUFF_RelaxedAura, cBuff.Type, cBuff.Links, cBuff.Chain);
                  else
                    -- Forever Well Fed uses many spell IDs; strict probe rejects junk auraInfo.
                    -- Failed/nil lookup returns missing (hungry), never treated as fed.
                    buff, index, buffname, bt, charges = SMARTBUFF_CheckWellFedBuffs(unit);
                    SMARTBUFF_AddMsgD("FOOD satiety " .. tostring(buffnS) .. " missing=" .. tostring(buff ~= nil) .. " bt=" .. tostring(bt));
                  end
                else
                  if (cBuff.Params ~= SG.NIL) then
                    if (cBuff.Links and cBuff.Links == SG.CheckFishingPole) then
                      if (SMARTBUFF_IsFishingPoleEquiped()) then
                        buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, cBuff.Params, cBuff.Type);
                      else
                        buff = nil;
                      end
                    else
                      buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, cBuff.Params, cBuff.Type,
                        cBuff.Links, cBuff.Chain);
                    end
                    SMARTBUFF_AddMsgD("Buff time (" .. tostring(cBuff.Params) .. ") = " .. tostring(bt));
                  else
                    buff = nil;
                  end
                end

                if (buff == nil and cBuff.DurationS >= 1 and rbTime > 0) then
                  if (charges == nil) then charges = -1; end
                  if (charges > 1) then cBuff.CanCharge = true; end
                  bufftarget = nil;
                end

                if (bt and bt <= rbTime) then
                  buff = buffnS;
                  bExpire = true;
                end

                if (buff) then
                  if (cBuff.Type ~= SMARTBUFF_CONST_ITEM) then
                    local cr, iid = SMARTBUFF_CountReagent(buffnS, cBuff.Chain);
                    if (cr > 0) then
                      buff = buffnS;
                      if (cBuff.Type == SMARTBUFF_CONST_ITEMGROUP or cBuff.Type == SMARTBUFF_CONST_SCROLL) then
                        cds, cd = C_Container.GetItemCooldown(iid);
                        cds = tonumber(cds) or 0;
                        cd = tonumber(cd) or 0;
                        local ok, _ = pcall(function() return cds + cd end);
                        if not ok then cds = 0; cd = 0; end
                        cd = (cds + cd) - GetTime();
                        SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found, cd = " .. cd);
                        if (cd > 0) then
                          buff = nil;
                        end
                      end
                      SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                    else
                      SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                      buff = nil;
                      bExpire = false;
                    end
                  end
                end

                -- Weapon buff ------------------------------------------------------------------------
              elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON or cBuff.Type == SMARTBUFF_CONST_INV) then
                SMARTBUFF_AddMsgD("Check weapon Buff");
                if (SMARTBUFF_IsProfessionToolBuff(cBuff)) then
                  -- Each Razorstone row (q1/q2/q3) has its own MH/OH so user can e.g. q1 on tool1, q3 on tool2; check = any Razor present
                  local slotToApply, razorHandtype, razorBt, razorBExpire = SMARTBUFF_CheckRazorstoneBuff("player", bs.MH, bs.OH, cBuff.DurationS, rbTime, buffloc);
                  if (slotToApply) then
                    iSlot = slotToApply;
                    buff = buffnS;
                    handtype = razorHandtype;
                    bt = razorBt;
                    bExpire = razorBExpire;
                  end
                else
                  local hasMh, expMh, chMh, hasOh, expOh, chOh, enchantsMh, enchantsOh = SMARTBUFF_ReadWeaponEnchantInfo();
                  -- MH first, then OH: if both need the buff, do not let OH overwrite a missing MH.
                  local skipOffHandWeaponCheck = false;
                  local matchName = (cBuff.Type == SMARTBUFF_CONST_WEAPON);

                  if (bs.MH) then
                    iSlot = INVSLOT_MAINHAND;
                    iId = GetInventoryItemID("player", iSlot);
                    if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                      local missing, expiring, secs, nCharges = SMARTBUFF_EvaluateWeaponHand(hasMh, expMh, chMh, iSlot, buffnS, rbTime, cBuff.DurationS, matchName, enchantsMh);
                      if (nCharges > 1) then cBuff.CanCharge = true; end
                      charges = nCharges;
                      SMARTBUFF_AddMsgD(un .. " (WMH): " .. buffnS .. " missing=" .. tostring(missing) .. " expiring=" .. tostring(expiring) .. " secs=" .. tostring(secs));
                      if (missing) then
                        handtype = "main";
                        buff = buffnS;
                        skipOffHandWeaponCheck = true;
                      elseif (expiring) then
                        buff = buffnS;
                        bt = secs or 0;
                        bExpire = true;
                      end
                    else
                      SMARTBUFF_AddMsgD(
                      "Weapon Buff cannot be cast, no mainhand weapon equipped or wrong weapon/stone type");
                    end
                  end

                  if (bs.OH and not skipOffHandWeaponCheck and not bExpire and not buffloc) then
                    iSlot = INVSLOT_OFFHAND;
                    iId = GetInventoryItemID("player", iSlot);
                    if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                      local missing, expiring, secs, nCharges = SMARTBUFF_EvaluateWeaponHand(hasOh, expOh, chOh, iSlot, buffnS, rbTime, cBuff.DurationS, matchName, enchantsOh);
                      if (nCharges > 1) then cBuff.CanCharge = true; end
                      charges = nCharges;
                      SMARTBUFF_AddMsgD(un .. " (WOH): " .. buffnS .. " missing=" .. tostring(missing) .. " expiring=" .. tostring(expiring) .. " secs=" .. tostring(secs));
                      if (missing) then
                        handtype = "off";
                        buff = buffnS;
                      elseif (expiring) then
                        buff = buffnS;
                        bt = secs or 0;
                        bExpire = true;
                      end
                    else
                      SMARTBUFF_AddMsgD(
                      "Weapon Buff cannot be cast, no offhand weapon equipped or wrong weapon/stone type");
                    end
                  end
                end

                if (buff and cBuff.Type == SMARTBUFF_CONST_INV) then
                  local cr = SMARTBUFF_CountReagent(buffnS, cBuff.Chain or cBuff.Links);
                  if (cr > 0) then
                    SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                  else
                    SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                    buff = nil;
                  end
                end
                -- Normal buff ------------------------------------------------------------------------
              else
                local index = nil;

                -- check timer object
                buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, buffnS, cBuff.Type, cBuff.Links,
                  cBuff.Chain);
                if (charges == nil) then charges = -1; end
                if (charges > 1) then cBuff.CanCharge = true; end

                -- Only consider rebuff when the *same* buff (or linked) is on; index > 0 means chained/linked buff found - do not cast another in chain
                if (unit ~= "target" and buff == nil and (not index or index == 0) and cBuff.DurationS >= 1 and rbTime > 0) then
                  if (SMARTBUFF_IsPlayer(unit)) then
                    if (SG.cBuffTimer[unit] ~= nil and SG.cBuffTimer[unit][buffnS] ~= nil) then
                      local tbt = cBuff.DurationS - (time - SG.cBuffTimer[unit][buffnS]);
                      if (not bt or bt - tbt > rbTime) then
                        bt = tbt;
                      end
                    end
                    --if (charges == nil) then charges = -1; end
                    --if (charges > 1) then cBuff.CanCharge = true; end
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (P): " .. index .. ". " .. GetPlayerBuffTexture(index) .. "(" .. charges .. ") - " .. buffnS .. string.format(" %.0f sec left", bt));
                  elseif (SG.cBuffTimer[unit] ~= nil and SG.cBuffTimer[unit][buffnS] ~= nil) then
                    bt = cBuff.DurationS - (time - SG.cBuffTimer[unit][buffnS]);
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. string.format(" %.0f sec left", bt));
                  elseif (cBuff.BuffG ~= nil and SG.cBuffTimer[subgroup] ~= nil and SG.cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - SG.cBuffTimer[subgroup][cBuff.BuffG]);
                    if (type(subgroup) == "number") then
                      bufftarget = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
                    else
                      bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    end
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuff.BuffG .. string.format(" %.0f sec left", bt));
                  elseif (cBuff.BuffG ~= nil and SG.cBuffTimer[uc] ~= nil and SG.cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - SG.cBuffTimer[uc][cBuff.BuffG]);
                    bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuff.BuffG .. string.format(" %.0f sec left", bt));
                  else
                    bt = nil;
                  end

                  if ((bt and bt <= rbTime) or (SG.O.CheckCharges and cBuff.CanCharge and charges > 0 and charges <= SG.O.MinCharges)) then
                    if (buffname) then
                      buff = buffname;
                    else
                      buff = buffnS;
                    end
                    bExpire = true;
                  end
                end

                -- check if the group buff is active, in this case it is not possible to cast the single buff
                if (buffname and mode ~= 1 and buffname ~= buffnS) then
                  buff = nil;
                  --SMARTBUFF_AddMsgD("Group buff is active, single buff canceled!");
                end
              end -- END normal buff

              -- check if shapeshifted and cancel buff if it is not possible to cast it
              if (buff and cBuff.Type ~= SMARTBUFF_CONST_TRACK and cBuff.Type ~= SMARTBUFF_CONST_FORCESELF) then
                --SG.isShapeshifted = true;
                if (SG.isShapeshifted) then
                  -- Buff linked to shapeshift form... or not.
                  -- Params and SG.sShapename are spell-info tables from different calls, so compare names.
                  if (SMARTBUFF_SpellInfoNameMatches(cBuff.Params, SG.sShapename)) then
                    --SMARTBUFF_AddMsgD("Cast " .. buff .. " while shapeshifted");
                  else
                    if (SMARTBUFF_SpellInfoNameMatches(cBuff.Params, SMARTBUFF_DRUID_CAT)) then
                      buff = nil;
                    end
                    if (buff and mode ~= 1 and not SG.O.InShapeshift
                        and not SMARTBUFF_SpellInfoNameMatches(SG.sShapename, SMARTBUFF_DRUID_MOONKIN)
                        and not SMARTBUFF_SpellInfoNameMatches(SG.sShapename, SMARTBUFF_DRUID_TREANT)) then
                      --SG.sMsgWarning = SMARTBUFF_MSG_SHAPESHIFT .. ": " .. SG.sShapename;
                      buff = nil;
                    end
                  end
                elseif (SMARTBUFF_SpellInfoNameMatches(cBuff.Params, SMARTBUFF_DRUID_CAT)) then
                  buff = nil;
                end
              end

              if (buff) then
                -- Single-target group buffs: if our buff is already on an eligible group member, unset buff (do not move).
                -- Past this point: buff is either still set (continue to cast) or nil (skip).
                if (cBuff.SingleTargetGroup == "single" and cBuff.Type == SMARTBUFF_CONST_GROUP
                    and subgroup and type(subgroup) == "number" and subgroup >= 1 and SMARTBUFF_AnyEligibleGroupUnitHasMyBuff(subgroup, buffnS, bs)) then
                  buff = nil;
                  SMARTBUFF_AddMsgD("Single-target buff " .. buffnS .. " already on group member, skipping");
                end
              end
              if (buff) then
                if (cBuff.IDS) then
                  SMARTBUFF_AddMsgD("Checking " .. i .. " - " .. cBuff.IDS .. " " .. buffnS);
                end

                -- Cast mode ---------------------------------------------------------------------------------------
                if (mode == 0 or mode == 5) then
                  SG.currentUnit = nil;
                  SG.currentSpell = nil;

                  --try to apply weapon buffs on main/off hand
                  if (cBuff.Type == SMARTBUFF_CONST_INV) then
                    if (iSlot and (handtype ~= "" or bExpire)) then
                      local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain or cBuff.Links);
                      if (count > 0) then
                        SG.sMsgWarning = "";
                        if (SMARTBUFF_IsProfessionToolBuff(cBuff) and (iSlot == INVSLOT_MAINHAND or iSlot == INVSLOT_OFFHAND)) then
                          local slotToApply = SMARTBUFF_CheckRazorstoneBuff("player", bs.MH, bs.OH, cBuff.DurationS, rbTime, buffloc);
                          if (slotToApply) then iSlot = slotToApply; end
                        end
                        local itemInfo = C_Item.GetItemInfo(buffnS);
                        if (not itemInfo) then
                          -- Item data not loaded - request loading (AllTheThings pattern)
                          local itemID = extractItemID(buffnS);
                          if (itemID) then
                            C_Item.RequestLoadItemDataByID(itemID);
                          end
                        end
                        return 0, SMARTBUFF_ACTION_ITEM, itemInfo or buffnS, iSlot, "player", cBuff.Type;
                      end
                    end
                    r = 50;
                  elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON) then
                    if (iId and (handtype ~= "" or bExpire)) then
                      SG.sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_SPELL, buffnS, iSlot, "player", cBuff.Type;
                      --return 0, SMARTBUFF_ACTION_SPELL, buffnS, iId, "player", cBuff.Type;
                    end
                    r = 50;

                    -- eat food or use scroll or potion
                  elseif (cBuff.Type == SMARTBUFF_CONST_FOOD or cBuff.Type == SMARTBUFF_CONST_SCROLL or cBuff.Type == SMARTBUFF_CONST_POTION) then
                    -- Do not consume food while moving (reminder already allowed above).
                    if (cBuff.Type == SMARTBUFF_CONST_FOOD and SG.isPlayerMoving) then
                      r = 50;
                    else
                      local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain or cBuff.Links);
                      if (count > 0 or bExpire) then
                        SG.sMsgWarning = "";
                        return 0, SMARTBUFF_ACTION_ITEM, buffnS, 0, "player", cBuff.Type;
                      end
                      r = 20;
                    end

                    -- use item on a unit
                  elseif (cBuff.Type == SMARTBUFF_CONST_ITEMGROUP) then
                    local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain or cBuff.Links);
                    if (count > 0) then
                      if (SMARTBUFF_UnitIsOutOfBuffRange(buffnS, unit)) then
                        r = 3;
                      else
                        SG.sMsgWarning = "";
                        return 0, SMARTBUFF_ACTION_ITEM, buffnS, 0, unit, cBuff.Type;
                      end
                    else
                      r = 20;
                    end

                    -- create item
                  elseif (cBuff.Type == SMARTBUFF_CONST_ITEM) then
                    SMARTBUFF_AddMsgD("BuffUnit ITEM type: " .. buffnS);
                    local itemList = cBuff.Chain or cBuff.Links;
                    SMARTBUFF_AddMsgD("  Chain/Links: " .. (itemList and tostring(#itemList) .. " items" or "nil"));
                    local bag, slot, count = SMARTBUFF_FindItem(buff, itemList);
                    SMARTBUFF_AddMsgD("  FindItem result: count=" .. tostring(count) .. ", bag=" .. tostring(bag) .. ", slot=" .. tostring(slot));
                    if (count == 0) then
                      SMARTBUFF_AddMsgD("  Item not found (count=0), attempting to cast: " .. buffnS .. " (IDS: " .. tostring(cBuff.IDS) .. ")");
                      r = SMARTBUFF_DoCast(unit, cBuff.IDS, buffnS, cBuff.LevelsS, cBuff.Type);
                      SMARTBUFF_AddMsgD("  doCast result: " .. tostring(r));
                      if (r == 0) then
                        SG.currentUnit = unit;
                        SG.currentSpell = buffnS;
                      end
                    else
                      SMARTBUFF_AddMsgD("  Item found in inventory (count=" .. count .. "), skipping cast");
                      -- Item exists, no action needed - return early to avoid warning
                      return 0;
                    end

                    -- cast spell (castSpellID / castBuffnS = effective spell for this pass, not mutating cBuff)
                  else
                    r = SMARTBUFF_DoCast(unit, castSpellID, castBuffnS, cBuff.LevelsS, cBuff.Type);
                    if (r == 0) then
                      SG.currentUnit = unit;
                      SG.currentSpell = castBuffnS;
                      SG.tCastRequested = GetTime();
                    end
                  end

                -- Check mode ---------------------------------------------------------------------------------------
                elseif (mode == 1) then
                  SG.currentUnit = nil;
                  SG.currentSpell = nil;
                  if (bufftarget == nil) then bufftarget = un; end

                  if (cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK) then
                    local groupCast = (cBuff.Type == SMARTBUFF_CONST_GROUP or cBuff.Type == SMARTBUFF_CONST_GROUPALL or cBuff.Type == SMARTBUFF_CONST_ITEMGROUP);
                    -- Out of range: no splash, chat, or sound. Keep scanning this unit's other buffs and the rest of the group.
                    if (groupCast and SMARTBUFF_UnitIsOutOfBuffRange(castSpellID or castBuffnS, unit)) then
                      SMARTBUFF_AddMsgD((un or unit) .. " out of range for " .. tostring(buffnS));
                    else
                      -- clean up buff timer, if expired
                      if (bt and bt < 0 and bExpire) then
                        bt = 0;
                        if (SG.cBuffTimer[unit] ~= nil and SG.cBuffTimer[unit][buffnS] ~= nil) then
                          SG.cBuffTimer[unit][buffnS] = nil;
                        end
                        if (cBuff.IDG ~= nil) then
                          if (SG.cBuffTimer[subgroup] ~= nil and SG.cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                            SG.cBuffTimer[subgroup][cBuff.BuffG] = nil;
                          end
                          if (SG.cBuffTimer[uc] ~= nil and SG.cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                            SG.cBuffTimer[uc][cBuff.BuffG] = nil;
                          end
                        end
                        SG.tLastCheck = time - SG.O.AutoTimer + 0.5;
                        return 0;
                      end

                      -- Splash/chat: effective spell when substituting; else buff (may differ from buffnS for links)
                      SMARTBUFF_SetMissingBuffMessage(bufftarget, hunterSubstituteRevive and castBuffnS or buff, castIconS,
                        cBuff.CanCharge, charges, bt, bExpire);
                      SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, castIconS);
                      return 0;
                    end
                  end
                end

                if (r == 0) then
                  -- target buffed
                  -- Message will printed in the "SPELLCAST_STOP" event
                  SG.sMsgWarning = "";
                  if (hunterSubstituteRevive) then
                    -- SG.cBuffTimer keys stay on Order name; UNIT_SPELLCAST_SUCCEEDED remaps Revive cast to buffnS
                    SG.sHunterReviveTimerOrderKey = buffnS;
                  end
                  -- PreClick / secure button need the rank spell ID (name stays the Order key).
                  if (not hunterSubstituteRevive and castSpellID) then
                    SG.pendingCastSpellID = castSpellID;
                  end
                  return 0, SMARTBUFF_ACTION_SPELL, hunterSubstituteRevive and castBuffnS or buffnS, -1, unit, cBuff.Type;
                elseif (r == 1) then
                  -- spell cooldown
                  if (mode == 0) then SMARTBUFF_AddMsgWarn(buffnS .. " " .. SMARTBUFF_MSG_CD); end
                  return 1;
                elseif (r == 2) then
                  -- can not target
                  if (mode == 0 and ucf ~= SMARTBUFF_DEMONTYPE) then SMARTBUFF_AddMsgD("Can not target " .. un); end
                elseif (r == 3) then
                  -- Out of range: try the next buff, then the next unit. One manual-cast note if nobody in range can be buffed.
                  SMARTBUFF_AddMsgD((un or unit) .. " out of range for " .. tostring(buffnS));
                  if (mode == 0 and (SG.sMsgWarning == "" or SG.sMsgWarning == " ")) then
                    SG.sMsgWarning = (un or unit) .. " " .. SMARTBUFF_MSG_OOR;
                  end
                elseif (r == 4) then
                  -- spell cooldown > SG.maxSkipCoolDown
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " " .. SMARTBUFF_MSG_CD .. " > " .. SG.maxSkipCoolDown); end
                elseif (r == 5) then
                  -- target to low
                  if (mode == 0) then SMARTBUFF_AddMsgD(un .. " is to low to get buffed with " .. buffnS); end
                elseif (r == 6) then
                  -- not enough mana/rage/energy
                  SG.sMsgWarning = SMARTBUFF_MSG_OOM;
                elseif (r == 7) then
                  -- tracking ability is already active
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " not used, other ability already active"); end
                elseif (r == 8) then
                  -- actionslot is not defined
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " has no actionslot"); end
                elseif (r == 9) then
                  -- spell ID not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " spellID not found"); end
                elseif (r == 10) then
                  -- target could not buffed
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not buffed on " .. un); end
                elseif (r == 20) then
                  -- item not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not used"); end
                elseif (r == 50) then
                  -- weapon buff could not applied
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not applied"); end
                else
                  -- no spell selected
                  if (mode == 0) then SMARTBUFF_AddMsgD(SMARTBUFF_MSG_CHAT); end
                end
              end
            end
          else
            -- cooldown
            if (SG.sMsgWarning == "") then
              SG.sMsgWarning = SMARTBUFF_MSG_CD;
            end
            --SMARTBUFF_AddMsgD("Spell on cd: "..buffnS);
          end
        end -- group or self
      end
      --i = i + 1;
    end -- for buff
  end
  return 3;
end

-- END SMARTBUFF_BuffUnit


-- Matches any unit by name (players, NPCs, pets). Used for AddList and IgnoreList.

function SMARTBUFF_IsInList(unit, unitname, list)
  if (list == nil) then return false end
  for un in pairs(list) do
    if (un ~= nil and un == unitname) then
      return true;
    end
  end
  return false;
end


function SMARTBUFF_SetMissingBuffMessage(target, buff, icon, bCanCharge, nCharges, tBuffTimeLeft, bExpire)
  -- Resolve "item:ID" to display name/link for splash and chat (canonical key is stored; show name to user)
  local displayBuff = (buff and getBuffDisplayName(buff, nil)) or buff;

  local f = SmartBuffSplashFrame;
  -- show splash buff message
  if (f and SG.O.ToggleAutoSplash and not SmartBuffOptionsFrame:IsVisible()) then
    local s;
    local sd = SG.O.SplashDuration;
    local si = "";

    if (SG.OG.SplashIcon and icon) then
      local n = SG.O.SplashIconSize;
      if (n == nil or n <= 0) then
        n = SG.O.CurrentFontSize;
      end
      si = string.format("\124T%s:%d:%d:1:0\124t ", icon, n, n) or "";
    end
    if (SG.OG.SplashMsgShort and si == "") then si = displayBuff end
    if (SG.O.AutoTimer < 4) then
      sd = 1;
      f:Clear();
    end

    f:SetTimeVisible(sd);
    if (not nCharges) then nCharges = 0; end
    if (SG.O.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= SG.O.MinCharges and bExpire) then
      if (SG.OG.SplashMsgShort) then
        s = target .. " > " .. si .. " < " .. format(SMARTBUFF_ABBR_CHARGES_OL, nCharges);
      else
        s = target ..
        "\n" .. SMARTBUFF_MSG_REBUFF ..
        " " .. si .. displayBuff .. ": " .. format(ITEM_SPELL_CHARGES, nCharges) .. " " .. SMARTBUFF_MSG_LEFT;
      end
    elseif (bExpire) then
      if (SG.OG.SplashMsgShort) then
        s = target .. " > " .. si .. " < " .. format(SECOND_ONELETTER_ABBR, tBuffTimeLeft);
      else
        s = target ..
        "\n" .. SMARTBUFF_MSG_REBUFF .. " " ..
        si .. displayBuff .. ": " .. format(SECONDS_ABBR, tBuffTimeLeft) .. " " .. SMARTBUFF_MSG_LEFT;
      end
    else
      if (SG.OG.SplashMsgShort) then
        s = target .. " > " .. si;
      else
        s = target .. " " .. SMARTBUFF_MSG_NEEDS .. " " .. si .. displayBuff;
      end
    end
    f:AddMessage(s, SG.O.ColSplashFont.r, SG.O.ColSplashFont.g, SG.O.ColSplashFont.b, 1.0);
  end

  -- show chat buff message
  if (SG.O.ToggleAutoChat) then
    if (SG.O.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= SG.O.MinCharges and bExpire) then
      SMARTBUFF_AddMsgWarn(
      target ..
      ": " .. SMARTBUFF_MSG_REBUFF .. " " .. displayBuff .. ", " ..
      format(ITEM_SPELL_CHARGES, nCharges) .. " " .. SMARTBUFF_MSG_LEFT, true);
    elseif (bExpire) then
      SMARTBUFF_AddMsgWarn(
      target .. ": " .. SMARTBUFF_MSG_REBUFF .. " " .. displayBuff .. " " ..
      format(SECONDS_ABBR, tBuffTimeLeft) .. " " .. SMARTBUFF_MSG_LEFT, true);
    else
      SMARTBUFF_AddMsgWarn(target .. " " .. SMARTBUFF_MSG_NEEDS .. " " .. displayBuff, true);
    end
  end

  -- play sound
  if (SG.O.ToggleAutoSound) then
    SG.PlaySplashSound();
  end
end

-- True if buff uses profession-tool logic (slots 20/23, tooltip). Flag, Links, or BuffS item ID in list.

function SMARTBUFF_IsProfessionToolBuff(cBuff)
  if (cBuff.IsProfessionTool) then return true; end
  if (SG and SG.ProfessionToolItemIds and cBuff.Links == SG.ProfessionToolItemIds) then return true; end
  if (cBuff.Type ~= SMARTBUFF_CONST_INV or not SG or not SG.ProfessionToolItemIds) then return false; end
  local id = (type(cBuff.BuffS) == "number") and cBuff.BuffS
    or (type(cBuff.BuffS) == "string") and tonumber(string.match(cBuff.BuffS, "item:(%d+)"));
  if (not id) then return false; end
  for _, listId in ipairs(SG.ProfessionToolItemIds) do
    if (listId == id) then return true; end
  end
  return false;
end


-- Profession tool (Razorstone): check one inventory slot's tooltip for "Razor" buff and optional duration in parentheses.
-- Returns: hasRazor, durationText, tooltipKnown. When tooltip not ready, returns (nil, nil, false) so caller does not treat as "missing".
function SMARTBUFF_GetProfessionToolRazorstoneInfo(unit, invSlot)
  local hasRazor = false;
  local durationText = nil;
  if (not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem) then
    return nil, nil, false;
  end
  local tip = C_TooltipInfo.GetInventoryItem(unit, invSlot);
  if (not tip or not tip.lines) then
    return nil, nil, false;
  end
  local seenPlaceholder = false;
  for _, line in ipairs(tip.lines) do
    local left = (line.leftText or line.leftString or line.leftLabel or "");
    if (type(left) == "string" and left ~= "") then
      if (left:lower():find("retrieving item information")) then
        seenPlaceholder = true;
        break;
      end
      if (left:lower():find("razor")) then
        hasRazor = true;
      end
      local inParens = left:match("%((%d+.-)%)");
      if (inParens and not durationText) then
        durationText = inParens;
      end
    end
  end
  if (seenPlaceholder) then
    return nil, nil, false;
  end
  return hasRazor, durationText, true;
end

-- Parse Razorstone duration text from tooltip (e.g. "2 hr", "30 min") to seconds; returns nil if unparseable.

function SMARTBUFF_ParseRazorstoneDurationToSeconds(durationText)
  if (not durationText or type(durationText) ~= "string") then
    return nil;
  end
  local sec = 0;
  local hr = durationText:match("(%d+)%s*hr");
  if (hr) then
    sec = sec + tonumber(hr) * 3600;
  end
  local min = durationText:match("(%d+)%s*min");
  if (min) then
    sec = sec + tonumber(min) * 60;
  end
  return (sec > 0) and sec or nil;
end


-- Razorstone: check profession tool slots per buff options. None selected = check nothing. MH = slot 20 only, OH = slot 23 only. Both = both; apply to 20 first if needed, else 23.
-- Returns: slotToApply, handtype, bt, bExpire.
function SMARTBUFF_CheckRazorstoneBuff(unit, checkMH, checkOH, durationS, rbTime, buffloc)
  local slotToApply = nil;
  local handtype = "";
  local bt = nil;
  local bExpire = false;
  if (checkMH) then
    local iSlot = INVSLOT_PROF1_TOOL;
    if (GetInventoryItemID(unit, iSlot)) then
      local hasRazor, durationText, tooltipKnown = SMARTBUFF_GetProfessionToolRazorstoneInfo(unit, iSlot);
      if (not tooltipKnown) then
        SMARTBUFF_AddMsgD("Razorstone: slot " .. tostring(iSlot) .. " (main) tooltip not ready, skip");
      elseif (hasRazor) then
        if (rbTime > 0 and durationS >= 1 and durationText) then
          local tSec = SMARTBUFF_ParseRazorstoneDurationToSeconds(durationText);
          if (tSec and tSec <= rbTime) then
            slotToApply = iSlot;
            bt = tSec;
            bExpire = true;
            SMARTBUFF_AddMsgD(" (Razor MH): " .. string.format(" %.0f sec left", tSec));
          end
        end
      else
        slotToApply = iSlot;
        handtype = "main";
        SMARTBUFF_AddMsgD("Razorstone: slot " .. tostring(iSlot) .. " (main) missing Razor buff");
      end
    else
      SMARTBUFF_AddMsgD("Razorstone: no tool in main slot " .. tostring(INVSLOT_PROF1_TOOL));
    end
  end
  if (checkOH and not bExpire and not buffloc) then
    local iSlot = INVSLOT_PROF2_TOOL;
    if (GetInventoryItemID(unit, iSlot)) then
      local hasRazor, durationText, tooltipKnown = SMARTBUFF_GetProfessionToolRazorstoneInfo(unit, iSlot);
      if (not tooltipKnown) then
        SMARTBUFF_AddMsgD("Razorstone: slot " .. tostring(iSlot) .. " (off) tooltip not ready, skip");
      elseif (hasRazor) then
        if (rbTime > 0 and durationS >= 1 and durationText) then
          local tSec = SMARTBUFF_ParseRazorstoneDurationToSeconds(durationText);
          if (tSec and tSec <= rbTime and not slotToApply) then
            slotToApply = iSlot;
            bt = tSec;
            bExpire = true;
            SMARTBUFF_AddMsgD(" (Razor OH): " .. string.format(" %.0f sec left", tSec));
          end
        end
      else
        if (not slotToApply) then
          slotToApply = iSlot;
          handtype = "off";
          SMARTBUFF_AddMsgD("Razorstone: slot " .. tostring(iSlot) .. " (off) missing Razor buff");
        end
      end
    else
      SMARTBUFF_AddMsgD("Razorstone: no tool in off slot " .. tostring(INVSLOT_PROF2_TOOL));
    end
  end
  return slotToApply, handtype, bt, bExpire;
end

-- Read per-slot weapon enchants on Forever, with the legacy aggregate API as fallback.
-- Returns the legacy six values followed by active-enchant lists for MH and OH when available.
function SMARTBUFF_ReadWeaponEnchantInfo()
  local function unpackEnchant(a, b, c, d, e, f, g, h)
    if (type(a) == "table") then
      return a.hasMainHandEnchant, a.mainHandExpiration, a.mainHandCharges,
        a.hasOffHandEnchant, a.offHandExpiration, a.offHandCharges;
    end
    return a, b, c, e, f, g;
  end
  if (C_Item and C_Item.GetWeaponEnchantInfo) then
    -- Forever exposes weapon enchants per slot. Rogue poisons are Imbue entries
    -- here, but the legacy aggregate GetWeaponEnchantInfo can report them missing.
    local function readSlot(slot)
      local ok, enchants = pcall(C_Item.GetWeaponEnchantInfo, slot);
      if (not ok or type(enchants) ~= "table") then return nil, nil, nil, false, nil; end
      local temporary = (Enum and Enum.ItemEnchantType and Enum.ItemEnchantType.Temporary) or 2;
      local imbue = (Enum and Enum.ItemEnchantType and Enum.ItemEnchantType.Imbue) or 3;
      local active = {};
      for _, info in ipairs(enchants) do
        -- Permanent enchants must not satisfy a requested temporary weapon buff.
        if (type(info) == "table" and (info.enchantType == temporary or info.enchantType == imbue)
            and knownBool(info.hasEnchant) == true) then
          tinsert(active, info);
        end
      end
      local first = active[1];
      return first ~= nil, first and first.timeLeft, first and first.charges, true, active;
    end

    local mainSlot = (Enum and Enum.WeaponSlot and Enum.WeaponSlot.MainHand) or 0;
    local offSlot = (Enum and Enum.WeaponSlot and Enum.WeaponSlot.OffHand) or 1;
    local hasMh, expMh, chMh, mhKnown, enchantsMh = readSlot(mainSlot);
    local hasOh, expOh, chOh, ohKnown, enchantsOh = readSlot(offSlot);
    if (mhKnown and ohKnown) then
      return hasMh, expMh, chMh, hasOh, expOh, chOh, enchantsMh, enchantsOh;
    end
  end
  if (GetWeaponEnchantInfo) then
    local ok, a, b, c, d, e, f, g, h = pcall(GetWeaponEnchantInfo);
    if (ok) then
      return unpackEnchant(a, b, c, d, e, f, g, h);
    end
  end
end

-- Expiration from GetWeaponEnchantInfo is milliseconds. nil when secret or missing.
function SMARTBUFF_WeaponEnchantSeconds(expiration)
  if (expiration == nil or (issecretvalue and issecretvalue(expiration))) then return nil; end
  local n = tonumber(expiration);
  if (not n) then return nil; end
  local ok, secs = pcall(function() return floor(n / 1000); end);
  if (not ok) then return nil; end
  return secs;
end

function SMARTBUFF_WeaponEnchantCharges(charges)
  if (charges == nil or (issecretvalue and issecretvalue(charges))) then return -1; end
  local n = tonumber(charges);
  if (not n) then return -1; end
  local ok, v = pcall(function() return n + 0; end);
  if (not ok) then return -1; end
  return v;
end

-- Spell imbues (Rockbiter, Windfury, Flametongue, Frostbrand) are not always reported as a temp enchant.
-- The weapon tooltip line is the short name ("Rockbiter"), sometimes with "(5 min)".
function SMARTBUFF_WeaponTooltipImbue(slot, spellName)
  if (not slot or not spellName or type(spellName) ~= "string") then return false, nil; end
  if (not C_TooltipInfo or not C_TooltipInfo.GetInventoryItem) then return false, nil; end
  local ok, tip = pcall(C_TooltipInfo.GetInventoryItem, "player", slot);
  if (not ok or not tip or not tip.lines) then return false, nil; end
  local full = spellName:lower();
  local short = full:gsub("%s+weapon%s*$", "");
  for _, line in ipairs(tip.lines) do
    local left = line.leftText or line.leftString or line.leftLabel or "";
    if (type(left) == "string" and left ~= "") then
      local l = left:lower();
      if (l:find(full, 1, true) or (short ~= "" and short ~= full and l:find(short, 1, true))) then
        local inParens = left:match("%((%d+.-)%)");
        local secs = inParens and SMARTBUFF_ParseRazorstoneDurationToSeconds(inParens) or nil;
        return true, secs;
      end
    end
  end
  return false, nil;
end

function SMARTBUFF_PlayerImbueAuraSeconds(spellName)
  if (not spellName or not getAuraDataBySpellRef) then return false, nil; end
  local aura = getAuraDataBySpellRef("player", spellName, "HELPFUL");
  if (not aura) then
    local short = (type(spellName) == "string") and spellName:gsub("%s+[Ww]eapon%s*$", "") or nil;
    if (short and short ~= spellName) then
      aura = getAuraDataBySpellRef("player", short, "HELPFUL");
    end
  end
  if (not aura) then return false, nil; end
  local exp = tonumber(aura.expirationTime);
  if (exp and exp > 0 and not (issecretvalue and issecretvalue(exp))) then
    local left = exp - GetTime();
    if (left < 0) then left = 0; end
    return true, left;
  end
  return true, nil;
end

-- missing, expiring, secondsLeft, charges.
-- A present enchant with 0 or unreadable time is still applied. Rockbiter often reports 0 ms.
function SMARTBUFF_EvaluateWeaponHand(hasFlag, expiration, rawCharges, slot, spellName, rbTime, durationS, matchName, enchants)
  local has = knownBool(hasFlag);
  local secs = SMARTBUFF_WeaponEnchantSeconds(expiration);
  local charges = SMARTBUFF_WeaponEnchantCharges(rawCharges);
  local present = (has == true);

  -- Forever can keep a Temporary effect (such as a sharpening stone) and an Imbue
  -- (such as poison) on the same hand. Match inventory buffs by enchant icon so each
  -- layer is checked independently without an item-ID-to-enchant-ID table.
  local itemID = extractItemID(spellName);
  local itemIcon = itemID and C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID);
  if (itemIcon and type(enchants) == "table") then
    present = false;
    for _, info in ipairs(enchants) do
      if (type(info) == "table" and info.enchantIconID == itemIcon) then
        present = true;
        secs = SMARTBUFF_WeaponEnchantSeconds(info.timeLeft);
        charges = SMARTBUFF_WeaponEnchantCharges(info.charges);
        break;
      end
    end
  end

  if (not present and matchName) then
    local auraOn, auraSecs = SMARTBUFF_PlayerImbueAuraSeconds(spellName);
    if (auraOn) then
      present = true;
      if (auraSecs and auraSecs > 0) then secs = auraSecs; end
    else
      local tipOn, tipSecs = SMARTBUFF_WeaponTooltipImbue(slot, spellName);
      if (tipOn) then
        present = true;
        if (tipSecs and tipSecs > 0) then secs = tipSecs; end
      end
    end
  end

  if (has == nil and not present) then
    return false, false, secs, charges;
  end
  if (not present) then
    return true, false, nil, charges;
  end

  local chargesLow = (SG.O.CheckCharges and charges > 1 and charges <= (SG.O.MinCharges or 0));
  if (chargesLow or (secs and secs > 0 and rbTime > 0 and durationS >= 1 and secs <= rbTime)) then
    return false, true, secs or 0, charges;
  end
  return false, false, secs, charges;
end


-- check if a spell/reagent could applied on a weapon

-- Inventory rows are stored as "item:ID". Match stone patterns against the item name.
local function weaponBuffLabel(buff)
  local itemID = extractItemID and extractItemID(buff);
  if (itemID and C_Item and C_Item.GetItemInfo) then
    local itemName = C_Item.GetItemInfo(itemID);
    if (type(itemName) == "string" and itemName ~= "") then
      return itemName;
    end
  end
  return buff;
end

-- List entries are plural ("Swords", "Staves"). Client subtypes are often singular ("Sword", "Staff").
local function weaponSubtypeMatches(itemSubType, weapon)
  if (type(itemSubType) ~= "string" or type(weapon) ~= "string" or weapon == "") then
    return false;
  end
  if (string.find(itemSubType, weapon, 1, true)) then
    return true;
  end
  local stem = weapon;
  if (weapon == "Staves") then
    stem = "Staff";
  elseif (string.sub(weapon, -1) == "s" and string.sub(weapon, -2) ~= "ss") then
    stem = string.sub(weapon, 1, -2);
  end
  if (stem ~= weapon and stem ~= "" and string.find(itemSubType, stem, 1, true)) then
    return true;
  end
  return false;
end

function SMARTBUFF_CanApplyWeaponBuff(buff, slot)
  local label = weaponBuffLabel(buff);
  local cWeaponTypes = nil;
  if (type(label) == "string" and SMARTBUFF_WEAPON_SHARP_PATTERN and string.find(label, SMARTBUFF_WEAPON_SHARP_PATTERN)) then
    cWeaponTypes = SMARTBUFF_WEAPON_SHARP;
  elseif (type(label) == "string" and SMARTBUFF_WEAPON_BLUNT_PATTERN and string.find(label, SMARTBUFF_WEAPON_BLUNT_PATTERN)) then
    cWeaponTypes = SMARTBUFF_WEAPON_BLUNT;
  else
    cWeaponTypes = SMARTBUFF_WEAPON_STANDARD;
  end

  local itemLink = GetInventoryItemLink("player", slot);
  if (not itemLink) then
    return false;
  end
  local _, _, itemCode = string.find(itemLink, "item:(%d+)");
  local itemID = itemCode and tonumber(itemCode);
  local _, _, _, _, _, itemType, itemSubType = C_Item.GetItemInfo(itemID);
  if (not itemType and itemID) then
    -- Item data not loaded - request loading (AllTheThings pattern)
    C_Item.RequestLoadItemDataByID(itemID);
  end

  --if (itemType and itemSubType) then
  --  SMARTBUFF_AddMsgD("Type: " .. itemType .. ", Subtype: " .. itemSubType);
  --end

  if (cWeaponTypes and itemSubType) then
    for _, weapon in pairs(cWeaponTypes) do
      --SMARTBUFF_AddMsgD(weapon);
      if (weaponSubtypeMatches(itemSubType, weapon)) then
        --SMARTBUFF_AddMsgD("Can apply " .. buff .. " on " .. itemSubType);
        return true, weapon;
      end
    end
  end
  return false;
end


-- END SMARTBUFF_CanApplyWeaponBuff


-- Check the unit blocklist
function SMARTBUFF_CheckBlocklist()
  local t = GetTime();
  for unit in pairs(SG.cBlocklist) do
    if (t > (SG.cBlocklist[unit] + SG.O.BlocklistTimer)) then
      SG.cBlocklist[unit] = nil;
    end
  end
end

function SMARTBUFF_IsPlayer(unit)
  if (unit and UnitIsUnit("player", unit)) then
    return true;
  end
  return false;
end


-- END SMARTBUFF_IsPlayer


-- Resolve spell name / optional spellID from a string or C_Spell.GetSpellInfo table.
function resolveSpellAuraRef(spellRef)
  if (not spellRef) then return nil, nil; end
  if (type(spellRef) == "table") then
    return spellRef.name, spellRef.spellID;
  end
  return spellRef, nil;
end


-- 12.1+: index/slot/instance aura APIs Lua-error while auras are secret; name/ID lookups remain allowed.
-- Returns auraInfo, resolvedSpellName (string) or nil, nil.
function getAuraDataBySpellRef(unit, spellRef, filter)
  local spellName, spellID = resolveSpellAuraRef(spellRef);
  if (not unit or (not spellName and not spellID)) then return nil, spellName; end

  local ok, auraInfo;
  if (spellID) then
    ok, auraInfo = pcall(C_UnitAuras.GetUnitAuraBySpellID, unit, spellID);
    if (ok and auraInfo) then
      return auraInfo, spellName or auraInfo.name;
    end
  end
  if (spellName) then
    ok, auraInfo = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, spellName, filter);
    if (ok and auraInfo) then
      return auraInfo, spellName;
    end
  end
  return nil, spellName;
end

-- Returns buff data if buffname found on target; nil otherwise. Uses C_UnitAuras (Retail).

function SMARTBUFF_UnitBuffByBuffName(target, buffname, filter)
  local auraInfo, spellName = getAuraDataBySpellRef(target, buffname, filter);
  if (not auraInfo or not spellName) then return; end

  local duration = tonumber(auraInfo.duration) or 0;
  local expirationTime = tonumber(auraInfo.expirationTime) or 0;
  return spellName, auraInfo.icon, (auraInfo.charges or 0), auraInfo.dispelName,
    duration, expirationTime, auraInfo.sourceUnit;
end


-- Seconds left on an aura that is still present.
-- A future expiration (expiration > GetTime()) is a real remaining time, so the rebuff window works.
-- expiration 0 means this client gave no clock time. The aura is still up, so do not treat it as expired
-- or scroll-zoom stays suppressed after the first successful cast.
local function auraSecondsRemaining(expiration)
  local exp = tonumber(expiration) or 0;
  local now = GetTime();
  local left = exp - now;
  if (left > 0) then
    return left;
  end
  if (exp > 0 and exp < 86400) then
    return exp;
  end
  return now;
end


-- Returns true if any eligible unit in the subgroup has our buff (sourceUnit == "player"). Used for single-target group buffs.
-- Only considers units that match current buff settings (class, role, AddList, IgnoreList).
-- Note: Only players (and pets) are valid targets; NPCs do not benefit from buffs.
function SMARTBUFF_AnyEligibleGroupUnitHasMyBuff(subgroup, buffnS, bs)
  if (not subgroup or not buffnS or not SG.cGroups or not SG.cGroups[subgroup]) then return false end
  for _, u in pairs(SG.cGroups[subgroup]) do
    if (u and knownBool(UnitExists(u)) == true and knownBool(UnitPlayerControlled(u)) == true) then
      local _, _, _, _, _, _, src = SMARTBUFF_UnitBuffByBuffName(u, buffnS, "HELPFUL");
      if (src and UnitIsUnit("player", src)) then
        if (not bs) then return true end
        local un = UnitName(u);
        local uc = select(2, UnitClass(u));
        local ur = UnitGroupRolesAssigned(u);
        local uct = UnitCreatureType(u) or "";
        local ucf = UnitCreatureFamily(u) or "";
        if (not SMARTBUFF_IsInList(u, un, bs.IgnoreList)
            and (bs[ur] or (bs.SelfOnly and SMARTBUFF_IsPlayer(u))
              or (((SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(buffnS) and SMARTBUFF_PaladinAssignmentAllows(buffnS, uc)) or bs[uc]) and (knownBool(UnitIsPlayer(u)) == true or uct == SMARTBUFF_HUMANOID or (uc == "DRUID" and (uct == SMARTBUFF_BEAST or uct == SMARTBUFF_ELEMENTAL))))
              or (bs["HPET"] and uct == SMARTBUFF_BEAST and uc ~= "DRUID")
              or (bs["DKPET"] and uct == SMARTBUFF_UNDEAD)
              or (bs["WPET"] and (uct == SMARTBUFF_DEMON or (uc ~= "DRUID" and uct == SMARTBUFF_ELEMENTAL)) and ucf ~= SMARTBUFF_DEMONTYPE))
              or SMARTBUFF_IsInList(u, un, bs.AddList)) then
          return true;
        end
      end
    end
  end
  return false;
end

-- Will return the name of the buff to cast

function SMARTBUFF_CheckUnitBuffs(unit, buffN, buffT, buffL, buffC)
  if (not unit or (not buffN and not buffL)) then return end

  local i, n, v;
  local buff = nil;
  local defBuff = nil;
  local timeleft = nil;
  local duration = nil;
  local caster = nil;
  local count = nil;
  local icon = nil;
  -- local time = GetTime();
  local uname = UnitName(unit) or "?";
  if (buffN) then
    if (type(buffN) == "table") then
      defBuff = buffN.name;
    else
      defBuff = buffN;
    end
  else
    defBuff = buffL[1];
  end

  -- Stance check — warrior stances are shapeshift forms, not unit auras
  n = SG.cBuffIndex[defBuff];
  if (SG.cBuffs[n] and SG.cBuffs[n].Type == SMARTBUFF_CONST_STANCE) then
    if (defBuff and buffC and #buffC >= 1) then
      local t = SG.B[getCurrentSpec()].Order;
      if (t and #t >= 1) then
        for i = 1, #t, 1 do
          if (t[i] and chainContains(buffC, t[i])) then
            v = getBuffSettings(t[i]);
            if (v and v.EnableS) then
              for formIndex = 1, GetNumShapeshiftForms(), 1 do
                -- Classic API: icon, active, castable, spellId
                local _, active, castable, spellId = GetShapeshiftFormInfo(formIndex);
                local name = spellId and C_Spell.GetSpellName(spellId);
                if (not name and spellId) then
                  local info = GetSpellInfo(spellId);
                  name = (type(info) == "table" and info.name) or (type(info) == "string" and info) or nil;
                end
                if (name and name == t[i]) then
                  if (active and castable) then
                    return nil, i, defBuff, 1800, -1;
                  elseif (not active and castable) then
                    return defBuff, nil, nil, nil, nil;
                  end
                end
              end
            end
          end
        end
      end
    end
    return defBuff, nil, nil, nil, nil;
  end

  -- Check linked buffs
  if (buffL) then
    if (not SG.O.LinkSelfBuffCheck and buffT == SMARTBUFF_CONST_SELF) then
      -- Do not check linked self buffs
    elseif (not SG.O.LinkGrpBuffCheck and buffT == SMARTBUFF_CONST_GROUP) then
      -- Do not check linked group buffs
    else
      for n, vt in pairs(buffL) do
        v = resolveChainOrLinkEntry(vt);
        if (v and v ~= defBuff) then
          SMARTBUFF_AddMsgD("Check linked buff (" .. uname .. "): " .. v);
          buff, icon, count, _, duration, timeleft, caster = SMARTBUFF_UnitBuffByBuffName(unit, v);
          if (buff) then
            timeleft = auraSecondsRemaining(timeleft);
            SMARTBUFF_AddMsgD("Linked buff found: " .. buff .. ", " .. timeleft .. ", " .. icon);
            return nil, n, defBuff, timeleft, count;
          end
        end
      end
    end
  end

  -- Check chained buffs
  if (defBuff and buffC and #buffC > 1) then
    local t = SG.B[getCurrentSpec()].Order;
    if (t and #t > 1) then
      --SMARTBUFF_AddMsgD("Check chained buff ("..uname.."): "..defBuff);
      for i = 1, #t, 1 do
        if (t[i] and chainContains(buffC, t[i])) then
          v = getBuffSettings(t[i]);
          local cBI = SG.cBuffs[SG.cBuffIndex[t[i]]];
          if (v and cBI and (v.EnableS or (SMARTBUFF_PaladinAssignmentControlsSpell and SMARTBUFF_PaladinAssignmentControlsSpell(t[i])))) then
            local b, tl, im = SMARTBUFF_CheckBuff(unit, t[i]);
            if (b and im) then
              --SMARTBUFF_AddMsgD("Chained buff found: "..t[i]..", "..tl);
              local satisfies = (not SMARTBUFF_PaladinAssignmentChainSatisfies) or SMARTBUFF_PaladinAssignmentChainSatisfies(defBuff, t[i]);
              if (satisfies and SMARTBUFF_CheckBuffLink(unit, t[i], cBI.Type, cBI.Links)) then
                -- Same spell: index 0 so BuffUnit can rebuff on RBTime. Different chain member: index > 0 skips cast.
                if (t[i] == defBuff) then
                  return nil, 0, defBuff, tl, -1;
                end
                return nil, i, defBuff, tl, -1;
              end
            elseif (not b and t[i] == defBuff) then
              return defBuff, nil, nil, nil, nil;
            end
          end
        end
      end
    end
  end

  -- Check default buff
  if (defBuff) then
    SMARTBUFF_AddMsgD("Check default buff (" .. uname .. "): " .. defBuff);
    buff, icon, count, _, duration, timeleft, caster = SMARTBUFF_UnitBuffByBuffName(unit, defBuff);
    if (buff) then
      timeleft = auraSecondsRemaining(timeleft);
      if (SMARTBUFF_IsPlayer(caster)) then
        SMARTBUFF_UpdateBuffDuration(defBuff, duration);
      end
      SMARTBUFF_AddMsgD("Default buff found: " .. buff .. ", " .. timeleft .. ", " .. icon);
      return nil, 0, defBuff, timeleft, count;
    end
  end

  -- Buff not found, return default buff
  return defBuff, nil, nil, nil, nil;
end


function SMARTBUFF_CheckBuffLink(unit, defBuff, buffT, buffL)
  -- Check linked buffs
  if (buffL) then
    if (not SG.O.LinkSelfBuffCheck and buffT == SMARTBUFF_CONST_SELF) then
      -- Do not check linked self buffs
    elseif (not SG.O.LinkGrpBuffCheck and buffT == SMARTBUFF_CONST_GROUP) then
      -- Do not check linked group buffs
    else
      for n, v in pairs(buffL) do
        local linkName = resolveChainOrLinkEntry(v);
        if (linkName and linkName ~= defBuff) then
          SMARTBUFF_AddMsgD("Check linked buff (" .. (UnitName(unit) or "?") .. "): " .. linkName);
          buff, icon, count, _, duration, timeleft, caster = SMARTBUFF_UnitBuffByBuffName(unit, linkName);
          if (buff) then
            timeleft = auraSecondsRemaining(timeleft);
            SMARTBUFF_AddMsgD("Linked buff found: " .. buff .. ", " .. timeleft .. ", " .. icon);
            return nil, n, defBuff, timeleft, count;
          end
        end
      end
    end
  end
  return defBuff;
end


function SMARTBUFF_CheckBuffChain(unit, buff, chain)
  local i;
  if (buff and chain and #chain > 1) then
    local t = SG.B[getCurrentSpec()].Order;
    if (t and #t > 1) then
      SMARTBUFF_AddMsgD("Check chained buff: " .. buff);
      for i = 1, #t, 1 do
        if (t[i] and t[i] ~= buff and chainContains(chain, t[i])) then
          local b, tl, im = SMARTBUFF_CheckBuff(unit, t[i], true);
          if (b and im) then
            SMARTBUFF_AddMsgD("Chained buff found: " .. t[i]);
            return nil, i, buff, tl, -1;
          end
        end
      end
    end
  end
  return buff;
end


function SMARTBUFF_UpdateBuffDuration(buff, duration)
  local i = SG.cBuffIndex[buff];
  if (i ~= nil and SG.cBuffs[i] ~= nil and buff == SG.cBuffs[i].BuffS) then
    if (SG.cBuffs[i].DurationS ~= nil and SG.cBuffs[i].DurationS > 0 and SG.cBuffs[i].DurationS ~= duration) then
      SMARTBUFF_AddMsgD("Updated buff duration: " .. buff .. " = " .. duration .. "sec, old = " .. SG.cBuffs[i].DurationS);
      SG.cBuffs[i].DurationS = duration;
    end
  end
end


-- Returns aura data if spellname found on target; nil otherwise. Uses C_UnitAuras (Retail).
-- spellname may be a localized string or a GetSpellInfo table (.name / .spellID).
function SMARTBUFF_UnitAuraBySpellName(target, spellname, filter)
  local auraInfo, name = getAuraDataBySpellRef(target, spellname, filter);
  if (not auraInfo or not name) then return; end

  local expirationTime = tonumber(auraInfo.expirationTime) or 0;
  return name, expirationTime, auraInfo.sourceUnit;
end


function SMARTBUFF_CheckBuff(unit, buffName, isMine)
  if (not unit or not buffName) then
    return false, 0;
  end
  local wantName = resolveSpellAuraRef(buffName);
  if (not wantName) then
    return false, 0;
  end
  local buff, timeleft, caster = SMARTBUFF_UnitAuraBySpellName(unit, buffName, "HELPFUL");
  if (buff) then
    SMARTBUFF_AddMsgD(UnitName(unit) .. " buff found: " .. buff, 0, 1, 0.5);
    if (buff == wantName) then
      timeleft = auraSecondsRemaining(timeleft);
      if (isMine and caster) then
        if (SMARTBUFF_IsPlayer(caster)) then
          return true, timeleft, caster;
        end
        return false, 0, nil;
      end
      return true, timeleft, SMARTBUFF_IsPlayer(caster);
    end
  end
  return false, 0;
end


-- END SMARTBUFF_CheckUnitBuffs


-- IsFeignDeath(unit)
function SMARTBUFF_IsFeignDeath(unit)
  return UnitIsFeignDeath(unit);
end


-- END SMARTBUFF_IsFeignDeath

local function mealSpellName(info)
  if (type(info) == "table") then return info.name; end
  if (type(info) == "string") then return info; end
end

local function mealSpellId(info)
  if (type(info) == "table") then return info.spellID; end
  if (type(info) == "number") then return info; end
end

-- Forever may return a non-nil junk table from GetUnitAuraBySpellID for missing auras.
-- Require spellId and a future expirationTime — duration alone is not enough (false "fed"/"picnic").
local function isValidSatietyAuraInfo(auraInfo)
  if (type(auraInfo) ~= "table") then return false; end
  local spellId = tonumber(auraInfo.spellId) or tonumber(auraInfo.spellID);
  if (not spellId or spellId <= 0) then return false; end
  local exp = tonumber(auraInfo.expirationTime);
  return exp ~= nil and exp > GetTime();
end

local function mealMatchesChannel(channelName, channelId, spellRef)
  if (not spellRef) then return false; end
  local name = mealSpellName(spellRef);
  local id = mealSpellId(spellRef);
  if (channelName and name and channelName == name) then return true; end
  if (channelId and id and channelId == id) then return true; end
  return false;
end

local function mealMatchesAura(unit, spellRef)
  if (not spellRef) then return false; end
  local wantName = mealSpellName(spellRef);
  local id = mealSpellId(spellRef);
  if (id) then
    local ok, auraInfo = pcall(C_UnitAuras.GetUnitAuraBySpellID, unit, id);
    if (ok and isValidSatietyAuraInfo(auraInfo)) then
      -- Require name match when known so junk ID hits cannot fake Food/Drink.
      if (not wantName or auraInfo.name == wantName) then return true; end
    end
  end
  if (wantName) then
    local ok, auraInfo = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, wantName, "HELPFUL");
    if (ok and isValidSatietyAuraInfo(auraInfo) and auraInfo.name == wantName) then return true; end
  end
  return false;
end

-- Forever has neither the [sitting] macro option nor UnitStandState.
-- The sit key calls SitStandOrDescendStart (a toggle). Movement, jump, combat, and casts stand you up.
local sitToggleAt = 0;

local function noteStand()
  if (SG) then SG.isSitting = false; end
end

local function noteSit()
  if (not SG) then return; end
  SG.isSitting = true;
end

local function noteSitToggle()
  if (not SG) then return; end
  if (IsFlying() or IsSwimming() or IsMounted()) then return; end
  local now = GetTime();
  if ((now - sitToggleAt) < 0.3) then return; end
  sitToggleAt = now;
  if (SG.isSitting) then
    noteStand();
  else
    noteSit();
  end
end

local sitWatch = CreateFrame("Frame");
sitWatch:RegisterEvent("PLAYER_STARTED_MOVING");
sitWatch:RegisterEvent("PLAYER_ENTERING_WORLD");
sitWatch:RegisterEvent("PLAYER_REGEN_DISABLED");
sitWatch:RegisterEvent("UNIT_SPELLCAST_START");
sitWatch:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
sitWatch:SetScript("OnEvent", function(_, event, unit)
  -- Casting stands you on Forever (no UnitStandState). Picnic pause still covers active meals.
  if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED") then
    if (unit ~= "player") then return; end
  end
  if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED"
      or event == "PLAYER_STARTED_MOVING" or event == "PLAYER_ENTERING_WORLD"
      or event == "PLAYER_REGEN_DISABLED") then
    noteStand();
  end
end);
if (type(hooksecurefunc) == "function") then
  if (type(SitStandOrDescendStart) == "function") then
    hooksecurefunc("SitStandOrDescendStart", noteSitToggle);
  end
  if (type(JumpOrAscendStart) == "function") then
    hooksecurefunc("JumpOrAscendStart", function()
      if (not IsFlying()) then noteStand(); end
    end);
  end
  if (type(DoEmote) == "function") then
    hooksecurefunc("DoEmote", function(emote)
      if (type(emote) ~= "string" or not SG) then return; end
      local e = string.upper(emote);
      if (e == "SIT") then
        sitToggleAt = GetTime();
        noteSit();
      elseif (e == "STAND") then
        sitToggleAt = GetTime();
        noteStand();
      end
    end);
  end
end

function SMARTBUFF_IsSitting()
  if (IsMounted() or IsFlying() or UnitOnTaxi("player")) then
    noteStand();
    return false;
  end
  if (type(UnitStandState) == "function") then
    local state = UnitStandState("player");
    if (state == 1 or state == 2 or state == 4 or state == 5 or state == 6) then
      return true;
    end
  end
  return SG.isSitting and true or false;
end

---True while the unit is channeling or buffed by Food, Drink, or Forever Nutritious Food. Well Fed does not count.
---@param unit? string default: "player"
---@return boolean
function SMARTBUFF_IsPicnic(unit)
  if not unit then unit = "player" end
  local channelName, _, _, _, _, _, _, channelId = UnitChannelInfo(unit);
  local eating = mealMatchesChannel(channelName, channelId, SMARTBUFF_FOOD_SPELL)
    or mealMatchesChannel(channelName, channelId, SMARTBUFF_DRINK_SPELL);
  if (not eating and SMARTBUFF_NutritiousFoodAuras) then
    for _, nutri in ipairs(SMARTBUFF_NutritiousFoodAuras) do
      if (mealMatchesChannel(channelName, channelId, nutri)) then
        eating = true;
        break;
      end
    end
  end
  if (not eating) then
    eating = mealMatchesAura(unit, SMARTBUFF_FOOD_SPELL)
      or mealMatchesAura(unit, SMARTBUFF_DRINK_SPELL);
  end
  if (not eating and SMARTBUFF_NutritiousFoodAuras) then
    for _, nutri in ipairs(SMARTBUFF_NutritiousFoodAuras) do
      if (mealMatchesAura(unit, nutri)) then
        eating = true;
        break;
      end
    end
  end
  if (eating) then
    if (unit == "player") then noteSit(); end
    return true;
  end
  return false
end

---Find any Forever/classic Well Fed (or Hearty Well Fed) aura on the unit.
---Rejects junk auraInfo tables from Forever GetUnitAuraBySpellID.
---@param unit? string default: "player"
---@return table|nil auraInfo
---@return string|nil spellName
function SMARTBUFF_GetWellFedAuraData(unit)
  if not unit then unit = "player" end
  if (SMARTBUFF_WellFedAuras) then
    for _, ref in ipairs(SMARTBUFF_WellFedAuras) do
      local spellID = mealSpellId(ref);
      if (spellID) then
        local ok, auraInfo = pcall(C_UnitAuras.GetUnitAuraBySpellID, unit, spellID);
        if (ok and isValidSatietyAuraInfo(auraInfo)) then
          return auraInfo, mealSpellName(ref) or auraInfo.name;
        end
      end
    end
  end
  -- Name fallback when the client supports it (variants share "Well Fed").
  local nameW = SMARTBUFF_WellFedAura and SMARTBUFF_WellFedAura.name;
  if (nameW) then
    local ok, auraInfo = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, nameW, "HELPFUL");
    if (ok and isValidSatietyAuraInfo(auraInfo)) then
      return auraInfo, nameW;
    end
  end
  local nameH = SMARTBUFF_HeartyFedAura and SMARTBUFF_HeartyFedAura.name;
  if (nameH) then
    local ok, auraInfo = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, nameH, "HELPFUL");
    if (ok and isValidSatietyAuraInfo(auraInfo)) then
      return auraInfo, nameH;
    end
  end
  -- Index scan fallback: Forever may lack GetAuraDataBySpellName.
  -- Exact name only (avoid matching "Well Fed XP Boost"). Entire body pcall'd — secret/odd names must not abort Check.
  if (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then
    local wantW = nameW and string.lower(nameW) or "well fed";
    local wantH = nameH and string.lower(nameH) or nil;
    local foundInfo, foundName = nil, nil;
    pcall(function()
      for i = 1, 40 do
        local ok, auraInfo = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL");
        if (not ok or not auraInfo) then break; end
        if (isValidSatietyAuraInfo(auraInfo) and type(auraInfo.name) == "string") then
          local n = string.lower(auraInfo.name);
          if (n == wantW or (wantH and n == wantH)) then
            foundInfo, foundName = auraInfo, auraInfo.name;
            break;
          end
        end
      end
    end);
    if (foundInfo) then
      return foundInfo, foundName;
    end
  end
  return nil, nil;
end

---Same return shape as SMARTBUFF_CheckUnitBuffs: nil buff means satiety present.
---Failed lookup returns missing (hungry), never silent-fed.
---@param unit? string default: "player"
function SMARTBUFF_CheckWellFedBuffs(unit)
  if not unit then unit = "player" end
  local defBuff = SMARTBUFF_WellFedAura or SMARTBUFF_FOOD_AURA or "Well Fed";
  -- Splash/messages need a string; WellFedAura is often a GetSpellInfo table.
  local defName = (type(defBuff) == "table" and defBuff.name) or defBuff or "Well Fed";
  local auraInfo, spellName = SMARTBUFF_GetWellFedAuraData(unit);
  if (auraInfo) then
    local timeleft = auraSecondsRemaining(auraInfo.expirationTime);
    local duration = tonumber(auraInfo.duration) or 0;
    if (duration > 0 and spellName) then
      SMARTBUFF_UpdateBuffDuration(spellName, duration);
    end
    return nil, 0, defName, timeleft, auraInfo.charges or 0;
  end
  return defName, nil, nil, nil, nil;
end

---@param unit? string default: "player"
---@return boolean
function SMARTBUFF_IsWellFed(unit)
  if not unit then unit = "player" end
  return SMARTBUFF_GetWellFedAuraData(unit) ~= nil;
end


-- IsFishing(unit)
function SMARTBUFF_IsFishing(unit)
  -- name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, notInterruptible,
  -- spellID, isEmpowered, numEmpowerStages = UnitChannelInfo(unitToken)
  local spell = UnitChannelInfo(unit);
  if (spell ~= nil and SMARTBUFF_FISHING.name ~= nil and spell == SMARTBUFF_FISHING.name) then
    SMARTBUFF_AddMsgD("Channeling "..SMARTBUFF_FISHING.name);
    return true;
  end
  return false;
end


function SMARTBUFF_IsFishingPoleEquiped()
  if (not SG or not SG.FishingPole) then return false end

  local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"));
  if (not link) then return false end

  local itemID = extractItemID(link);
  local _, _, _, _, _, _, subType = C_Item.GetItemInfo(itemID);
  if (not subType) then
    -- Item data not loaded - request loading (AllTheThings pattern)
    if (itemID) then
      C_Item.RequestLoadItemDataByID(itemID);
    end
    return false;
  end

  --print(SG.FishingPole.." - "..subType);
  if (SG.FishingPole == subType) then return true end

  return false;
end


-- END SMARTBUFF_IsFishing

-- SMARTBUFF_IsSpell(sType)
function SMARTBUFF_IsSpell(sType)
  return sType == SMARTBUFF_CONST_GROUP or sType == SMARTBUFF_CONST_GROUPALL or sType == SMARTBUFF_CONST_SELF or
  sType == SMARTBUFF_CONST_FORCESELF or sType == SMARTBUFF_CONST_WEAPON or sType == SMARTBUFF_CONST_STANCE or
  sType == SMARTBUFF_CONST_ITEM;
end


-- END SMARTBUFF_IsSpell

-- SMARTBUFF_IsItem(sType)
function SMARTBUFF_IsItem(sType)
  return sType == SMARTBUFF_CONST_INV or sType == SMARTBUFF_CONST_FOOD or sType == SMARTBUFF_CONST_SCROLL or
  sType == SMARTBUFF_CONST_POTION or sType == SMARTBUFF_CONST_ITEMGROUP;
end


-- END SMARTBUFF_IsItem


-- Unified internal function for finding items in bags
-- Searches on ItemLink in addition to itemText to support Dragonflight and above item qualities
-- Returns: firstBag, firstSlot, firstCount, totalCount, itemID, texture
--   - firstBag, firstSlot: First match location (or 999, toyID for toys)
--   - firstCount: Stack count of first match (for FindItem)
--   - totalCount: Sum of all matching items across all bags (for CountReagent)
--   - itemID: Item ID of first match
--   - texture: Icon of first match

function findItemInternal(reagent, chain, debug)
  if (reagent == nil) then
    if (debug) then
      SMARTBUFF_AddMsgD("FindItem: reagent is nil");
    end
    return nil, nil, 0, 0, nil, nil;
  end

  -- Init: read-only bag warm-up (~2x typical slot count); stop on first item or iteration cap (slower systems scan more before SetBuffs).
  if (type(reagent) == "string" and reagent == "ScanBagsForSBInit") then
    local maxIter = 200;
    local iter = 0;
    local foundItem = false;
    for bag = 0, NUM_BAG_FRAMES do
      if (foundItem or iter >= maxIter) then break; end
      local numSlots = C_Container.GetContainerNumSlots(bag) or 0;
      for slot = 1, numSlots do
        iter = iter + 1;
        local id = C_Container.GetContainerItemID(bag, slot);
        if (id) then
          foundItem = true;
          break;
        end
        if (iter >= maxIter) then break; end
      end
    end
    return nil, nil, 0, 0, nil, nil;
  end

  if (SG.O.IncludeToys) then
    -- reagent can be itemLink (string), itemID (number), or placeholder "item:12345"
    local link = nil;
    local itemID = nil;

    if (type(reagent) == "string") then
      -- Check if it's a full itemLink (starts with |c)
      if (string.match(reagent, "^|c")) then
        link = reagent;
        -- Extract itemID from full itemLink for matching
        itemID = tonumber(string.match(reagent, "item:(%d+)"));
      elseif (string.match(reagent, "^item:%d+$")) then
        -- Placeholder format "item:12345" - extract itemID
        itemID = tonumber(string.match(reagent, "item:(%d+)"));
        -- Try to get full itemLink from API
        if (itemID) then
          local _, itemLink = C_Item.GetItemInfo(itemID);
          link = itemLink;
        end
      end
    elseif (type(reagent) == "number") then
      -- itemID - need to get itemLink
      itemID = reagent;
      local _, itemLink = C_Item.GetItemInfo(reagent);
      link = itemLink;
    end

    -- Try direct link match first
    if (link) then
      local toy = SG.Toybox[link];
      if (toy) then
        if (debug) then
          SMARTBUFF_AddMsgD("FindItem: Found toy by link");
        end
        -- For toys: bag=999 (special marker), slot=toyID, firstCount=1, totalCount=1, id=toyID, texture=toyIcon
        return 999, toy[1], 1, 1, toy[1], toy[2];
      end
    end

    -- SG.O(1) toy lookup by itemID via ToyboxByID index (avoids SG.O(n) pairs over Toybox every check)
    if (itemID and SG.ToyboxByID) then
      local toy = SG.ToyboxByID[itemID];
      if (toy) then
        if (debug) then
          SMARTBUFF_AddMsgD("FindItem: Found toy by itemID");
        end
        return 999, toy[1], 1, 1, toy[1], toy[2];
      end
    end
  end

  local totalCount = 0;
  local itemID = nil;
  local firstBag = nil;
  local firstSlot = nil;
  local firstCount = 0;
  local texture = nil;

  -- Resolve reagent to itemID so we always search for the requested item, not only chain (e.g. buff key "item:147707" with Chain=LinkFlaskLeg would never match 147707)
  local reagentItemID = nil;
  if type(reagent) == "number" then
    reagentItemID = reagent;
  elseif type(reagent) == "string" then
    reagentItemID = tonumber(string.match(reagent, "item:(%d+)"));
  end

  if not (chain) then chain = { reagent }; end

  -- Precompute chain item IDs once (avoids string.match per bag slot per FindItem call)
  local chainMatch = {};
  for i = 1, #chain do
    local cid = nil;
    if type(chain[i]) == "number" then
      cid = chain[i];
    elseif type(chain[i]) == "string" then
      cid = tonumber(string.match(chain[i], "item:(%d+)"));
    end
    if cid then
      chainMatch[cid] = true;
    end
  end

  if (debug) then
    SMARTBUFF_AddMsgD("FindItem: Searching for reagent=" .. tostring(reagent) .. " (reagentItemID=" .. tostring(reagentItemID) .. "), chain size=" .. #chain);
    for i = 1, #chain do
      local chainItem = chain[i];
      SMARTBUFF_AddMsgD("  Chain[" .. i .. "]: " .. tostring(chainItem) .. " (type: " .. type(chainItem) .. ")");
    end
  end

  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      local bagItemID = C_Container.GetContainerItemID(bag, slot);
      if (bagItemID) then
        local matched = false;
        -- Match reagent's item ID first (so e.g. "item:147707" is found even when chain is LinkFlaskLeg)
        if (reagentItemID and bagItemID == reagentItemID) then
          matched = true;
        elseif chainMatch[bagItemID] then
          matched = true;
        end
        if (matched) then
          local buffItemID = bagItemID;
          local containerInfo = C_Container.GetContainerItemInfo(bag, slot);
          if (containerInfo) then
            -- Store first match location, count, and icon
            if (firstBag == nil) then
              firstBag = bag;
              firstSlot = slot;
              firstCount = containerInfo.stackCount;
              itemID = buffItemID;
              texture = containerInfo.iconFileID;
            end
            -- Sum all matches for total count
            totalCount = totalCount + containerInfo.stackCount;

            if (debug) then
              SMARTBUFF_AddMsgD("FindItem: MATCH! bagItemID=" .. bagItemID .. " (reagent or chain)");
            end
          end
        end
      end
    end
  end

  if (debug and totalCount == 0) then
    SMARTBUFF_AddMsgD("FindItem: Not found in inventory, returning count=0");
  end

  return firstBag, firstSlot, firstCount, totalCount, itemID, texture;
end

-- Returns the number of a reagent currently in player's bag
-- we now search on ItemLink in addition to itemText, in order to support Dragonflight item qualities
-- Returns: totalCount, itemID (sum of all matches across all bags)

function SMARTBUFF_CountReagent(reagent, chain)
  local _, _, _, totalCount, itemID = findItemInternal(reagent, chain, false);
  if (reagent == nil) then
    return -1, nil;
  end
  return totalCount, itemID;
end


-- Returns the first matching item location and icon
-- we now search on ItemLink in addition to itemText, in order to support Dragonflight item qualities
-- Returns: bag, slot, count, texture (first match only - count is stackCount of first match)
function SMARTBUFF_FindItem(reagent, chain)
  local bag, slot, firstCount, _, _, texture = findItemInternal(reagent, chain, SG.O and SG.O.Debug);
  if (reagent == nil) then
    return nil, nil, -1, nil;
  end
  return bag, slot, firstCount, texture;
end

local function itemNameFromID(itemID)
  if (not itemID) then return nil; end
  if (C_Item and C_Item.GetItemNameByID) then
    local name = C_Item.GetItemNameByID(itemID);
    if (type(name) == "string" and name ~= "") then return name; end
  end
  local name = GetItemInfo(itemID);
  if (type(name) == "string" and name ~= "") then return name; end
  return nil;
end

-- True if any item ID from the list is present in bags (also matches by localized name).
function SMARTBUFF_HasConjuredItemList(itemList)
  if (not itemList) then return false; end
  local wantIDs = {};
  local wantNames = {};
  for _, itemID in pairs(itemList) do
    if (type(itemID) == "number") then
      wantIDs[itemID] = true;
      local name = itemNameFromID(itemID);
      if (name) then wantNames[name] = true; end
    end
  end
  for bag = 0, NUM_BAG_FRAMES do
    local numSlots = C_Container.GetContainerNumSlots(bag) or 0;
    for slot = 1, numSlots do
      local bagItemID = C_Container.GetContainerItemID(bag, slot);
      if (bagItemID) then
        if (wantIDs[bagItemID]) then return true; end
        local bagName = itemNameFromID(bagItemID);
        if (bagName and wantNames[bagName]) then return true; end
      end
    end
  end
  return false;
end

function SMARTBUFF_HasBagItemID(itemID)
  if (not itemID) then return false; end
  local _, _, count = SMARTBUFF_FindItem(itemID);
  return (count or 0) > 0;
end

-- Free slots across backpack + equipped bags (family-agnostic).
function SMARTBUFF_GetBagFreeSlots()
  local free = 0;
  for bag = 0, NUM_BAG_FRAMES do
    local n = C_Container.GetContainerNumFreeSlots(bag);
    if (n and n > 0) then
      free = free + n;
    end
  end
  return free;
end

-- Create-item gate for S.CheckConjure / S.CheckConjureShard.
-- Returns true when the create spell should still be reminded/cast.
-- Second return "bags_full" when the product is missing but inventory has no free slots.
function SMARTBUFF_ConjureIsNeeded(cBuff, buffnS)
  if (not cBuff) then return false; end
  if (SG.isPlayerMoving) then
    return false;
  end
  if (cBuff.Params == SG.CheckConjureShard) then
    local shardID = SG.SoulShardItemID or 6265;
    if (not SMARTBUFF_HasBagItemID(shardID)) then
      SMARTBUFF_AddMsgD("Soul Shard is missing in bag, cannot create conjured item.");
      return false;
    end
  end
  local products = cBuff.Chain;
  if (products and SMARTBUFF_HasConjuredItemList(products)) then
    SMARTBUFF_AddMsgD("Conjure product already in bags, skip: " .. tostring(buffnS));
    return false;
  end
  -- Healthstone: no point creating at full health.
  if (SMARTBUFF_CREATEHS and SMARTBUFF_SpellInfoNameMatches(buffnS, SMARTBUFF_CREATEHS)
      and UnitHealth("player") == UnitHealthMax("player")) then
    return false;
  end
  if (SMARTBUFF_GetBagFreeSlots() < 1) then
    SMARTBUFF_AddMsgD("Bags full, skip conjure: " .. tostring(buffnS));
    return false, "bags_full";
  end
  return true;
end

-- Warn once per spell (throttled) when conjure splash is blocked by full bags.
function SMARTBUFF_NotifyConjureBagsFull(cBuff, buffnS)
  local name = getBuffDisplayName(cBuff and cBuff.BuffS, cBuff and cBuff.Type) or buffnS or "?";
  local now = GetTime();
  if (not SG.tLastConjureBagsFullWarn) then
    SG.tLastConjureBagsFullWarn = {};
  end
  local last = SG.tLastConjureBagsFullWarn[name] or 0;
  if ((now - last) < 30) then
    return;
  end
  SG.tLastConjureBagsFullWarn[name] = now;
  local msg = SMARTBUFF_MSG_BAGSFULL;
  if (type(msg) == "string" and msg:find("%%s")) then
    SMARTBUFF_AddMsgWarn(string.format(msg, name), true);
  else
    SMARTBUFF_AddMsgWarn("SmartBuff detected you needed " .. name .. " but bags are full.", true);
  end
end
