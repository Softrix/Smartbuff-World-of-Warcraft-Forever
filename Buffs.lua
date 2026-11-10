local _;
local S = SMARTBUFF_GLOBALS;

SMARTBUFF_PLAYERCLASS = nil;
SMARTBUFF_BUFFLIST = nil;

-- Buff types
SMARTBUFF_CONST_ALL       = "ALL";
SMARTBUFF_CONST_GROUP     = "GROUP";
SMARTBUFF_CONST_GROUPALL  = "GROUPALL";
SMARTBUFF_CONST_SELF      = "SELF";
SMARTBUFF_CONST_FORCESELF = "FORCESELF";
SMARTBUFF_CONST_TRACK     = "TRACK";
SMARTBUFF_CONST_GATHERING = "GATHERING";
SMARTBUFF_CONST_WEAPON    = "WEAPON";
SMARTBUFF_CONST_INV       = "INVENTORY";
SMARTBUFF_CONST_FOOD      = "FOOD";
SMARTBUFF_CONST_SCROLL    = "SCROLL";
SMARTBUFF_CONST_POTION    = "POTION";
SMARTBUFF_CONST_STANCE    = "STANCE";
SMARTBUFF_CONST_ITEM      = "ITEM";
SMARTBUFF_CONST_ITEMGROUP = "ITEMGROUP";
SMARTBUFF_CONST_TOY       = "TOY";

S.CheckPet = "CHECKPET";
S.CheckPetNeeded = "CHECKPETNEEDED";
S.CheckFishingPole = "CHECKFISHINGPOLE";
-- Create-item spells (mage food/water/gems, warlock stones): skip reminder when product is in bags.
S.CheckConjure = "CHECKCONJURE";
-- Same as CheckConjure, but also requires a Soul Shard (item 6265).
S.CheckConjureShard = "CHECKCONJURE_SHARD";
S.NIL = "x";
S.Toybox = S.Toybox or { };

-- Forever: Classic Era content + Skyborne. Return C_Spell-style tables (.name / .spellID).
do
  local _GetSpellInfo = rawget(_G, "GetSpellInfo");
  function GetSpellInfo(spellIdOrName)
    if (C_Spell and C_Spell.GetSpellInfo) then
      local info = C_Spell.GetSpellInfo(spellIdOrName);
      if (type(info) == "table" and info.name) then
        if (not info.spellID and type(spellIdOrName) == "number") then
          info.spellID = spellIdOrName;
        end
        return info;
      end
    end
    if (_GetSpellInfo) then
      local name, rank, icon, castTime, minRange, maxRange, spellID = _GetSpellInfo(spellIdOrName);
      if (name) then
        return { name = name, iconID = icon, castTime = castTime, minRange = minRange, maxRange = maxRange, spellID = spellID or (type(spellIdOrName) == "number" and spellIdOrName or nil) };
      end
    end
    return nil;
  end
  local _GetItemInfo = rawget(_G, "GetItemInfo");
  if (C_Item and C_Item.GetItemInfo) then
    function GetItemInfo(item)
      if (_GetItemInfo) then
        local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q = _GetItemInfo(item);
        if (a or b) then return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q; end
      end
      local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q = C_Item.GetItemInfo(item);
      if (a or b or type(item) ~= "number") then
        return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q;
      end
      -- Preserve an unresolved numeric item as a canonical reference. Static
      -- buff tables can then be built before the client item cache is ready.
      return nil, "item:" .. tostring(item);
    end
  end
end

function SMARTBUFF_BuildItemTables()
end

function SMARTBUFF_LoadToys()
  S.Toybox = S.Toybox or {};
  S.ToyboxByID = S.ToyboxByID or {};
end

SBClassicGatherers = { 2580, 2383, 2481 };

local function GetItems(items)
  local t = { };
  for _, id in pairs(items) do
    local _, name = GetItemInfo(id);
    if (name) then
      tinsert(t, name);
    end
  end
  return t;
end

--
--  Initialise Item Lists (Classic Era / Forever only)
--
function SMARTBUFF_InitItemList()
  if (S._itemListReady) then return; end

  _,SMARTBUFF_LOCKHEALTHSTONE = GetItemInfo(5512);
  _,SMARTBUFF_LOCKSPELLSTONE  = GetItemInfo(5522) or GetItemInfo(13603);
  _,SMARTBUFF_LOCKFIRESTONE   = GetItemInfo(1254) or GetItemInfo(13699) or GetItemInfo(13700) or GetItemInfo(13701);

  _,SMARTBUFF_HSMINOR         = GetItemInfo(5512);   -- Minor Healthstone
  _,SMARTBUFF_HSLESSER        = GetItemInfo(5511);   -- Lesser Healthstone
  _,SMARTBUFF_HSTONE          = GetItemInfo(5509);   -- Healthstone
  _,SMARTBUFF_HSGREATER       = GetItemInfo(5510);   -- Greater Healthstone
  _,SMARTBUFF_HSMAJOR         = GetItemInfo(9421);   -- Major Healthstone

  _,SMARTBUFF_FIRESLESSER     = GetItemInfo(1254);   -- Lesser Firestone
  _,SMARTBUFF_FIRESSTONE      = GetItemInfo(13699);  -- Firestone
  _,SMARTBUFF_FIRESGREATER    = GetItemInfo(13700);  -- Greater Firestone
  _,SMARTBUFF_FIRESMAJOR      = GetItemInfo(13701);  -- Major Firestone
  _,SMARTBUFF_SPELLSTONE      = GetItemInfo(5522);   -- Spellstone
  _,SMARTBUFF_SPELLSGREATER   = GetItemInfo(13602);  -- Greater Spellstone
  _,SMARTBUFF_SPELLSMAJOR     = GetItemInfo(13603);  -- Major Spellstone

  _,SMARTBUFF_SSROUGH         = GetItemInfo(2862);   -- Rough Sharpening Stone
  _,SMARTBUFF_SSCOARSE        = GetItemInfo(2863);   -- Coarse Sharpening Stone
  _,SMARTBUFF_SSHEAVY         = GetItemInfo(2871);   -- Heavy Sharpening Stone
  _,SMARTBUFF_SSSOLID         = GetItemInfo(7964);   -- Solid Sharpening Stone
  _,SMARTBUFF_SSDENSE         = GetItemInfo(12404);  -- Dense Sharpening Stone
  _,SMARTBUFF_SSELEMENTAL     = GetItemInfo(18262);  -- Elemental Sharpening Stone
  _,SMARTBUFF_WSROUGH         = GetItemInfo(3239);   -- Rough Weightstone
  _,SMARTBUFF_WSCOARSE        = GetItemInfo(3240);   -- Coarse Weightstone
  _,SMARTBUFF_WSHEAVY         = GetItemInfo(3241);   -- Heavy Weightstone
  _,SMARTBUFF_WSSOLID         = GetItemInfo(7965);   -- Solid Weightstone
  _,SMARTBUFF_WSDENSE         = GetItemInfo(12643);  -- Dense Weightstone
  _,SMARTBUFF_SHADOWOIL       = GetItemInfo(3824);   -- Shadow Oil
  _,SMARTBUFF_FROSTOIL        = GetItemInfo(3829);   -- Frost Oil
  _,SMARTBUFF_MANAOIL1        = GetItemInfo(20745);  -- Minor Mana Oil
  _,SMARTBUFF_MANAOIL2        = GetItemInfo(20747);  -- Lesser Mana Oil
  _,SMARTBUFF_MANAOIL3        = GetItemInfo(20748);  -- Brilliant Mana Oil
  _,SMARTBUFF_WIZARDOIL1      = GetItemInfo(20744);  -- Minor Wizard Oil
  _,SMARTBUFF_WIZARDOIL2      = GetItemInfo(20746);  -- Lesser Wizard Oil
  _,SMARTBUFF_WIZARDOIL3      = GetItemInfo(20750);  -- Wizard Oil
  _,SMARTBUFF_WIZARDOIL4      = GetItemInfo(20749);  -- Brilliant Wizard Oil

  -- Food (Classic)
  _,SMARTBUFF_BEERBASTEDBOARRIBS     = GetItemInfo(2888);
  _,SMARTBUFF_CRISPYBATWING          = GetItemInfo(12224);
  _,SMARTBUFF_KALDOREISPIDERKABOB    = GetItemInfo(5472);
  _,SMARTBUFF_ROASTEDKODOMEAT        = GetItemInfo(5474);
  _,SMARTBUFF_HERBBAKEDEGG           = GetItemInfo(6888);
  _,SMARTBUFF_SPICEDWOLFMEAT         = GetItemInfo(2680);
  _,SMARTBUFF_BOILEDCLAMS            = GetItemInfo(5525);
  _,SMARTBUFF_COYOTESTEAK            = GetItemInfo(2684);
  _,SMARTBUFF_CRABCAKE               = GetItemInfo(2683);
  _,SMARTBUFF_DRYPORKRIBS            = GetItemInfo(2687);
  _,SMARTBUFF_BLOODSAUSAGE           = GetItemInfo(3220);
  _,SMARTBUFF_CROCOLISKSTEAK         = GetItemInfo(3662);
  _,SMARTBUFF_FILLETOFFRENZY         = GetItemInfo(5476);
  _,SMARTBUFF_GORETUSKLIVERPIE       = GetItemInfo(724);
  _,SMARTBUFF_STRIDERSTEW            = GetItemInfo(5477);
  _,SMARTBUFF_GOBLINDEVILEDCLAMS     = GetItemInfo(5527);
  _,SMARTBUFF_BIGBEARSTEAK           = GetItemInfo(3726);
  _,SMARTBUFF_CRISPYLIZARDTAIL       = GetItemInfo(5479);
  _,SMARTBUFF_CROCOLISKGUMBO         = GetItemInfo(3664);
  _,SMARTBUFF_CURIOUSLYTASTYOMELET   = GetItemInfo(3665);
  _,SMARTBUFF_GOOEYSPIDERCAKE        = GetItemInfo(3666);
  _,SMARTBUFF_HOTLIONCHOPS           = GetItemInfo(3727);
  _,SMARTBUFF_LEANVENISON            = GetItemInfo(5480);
  _,SMARTBUFF_LEANWOLFSTEAK          = GetItemInfo(12209);
  _,SMARTBUFF_MURLOCFINSOUP          = GetItemInfo(3663);
  _,SMARTBUFF_REDRIDGEGOULASH        = GetItemInfo(1082);
  _,SMARTBUFF_SEASONEDWOLFKABOB      = GetItemInfo(1017);
  _,SMARTBUFF_CARRIONSURPRISE        = GetItemInfo(12213);
  _,SMARTBUFF_ROASTRAPTOR            = GetItemInfo(12210);
  _,SMARTBUFF_GIANTCLAMSCORCHO       = GetItemInfo(6038);
  _,SMARTBUFF_HEAVYCROCOLISKSTEW     = GetItemInfo(20074);
  _,SMARTBUFF_HOTWOLFRIBS            = GetItemInfo(13851);
  _,SMARTBUFF_JUNGLESTEW             = GetItemInfo(12212);
  _,SMARTBUFF_MYSTERYSTEW            = GetItemInfo(12214);
  _,SMARTBUFF_SOOTHINGTURTLEBISQUE   = GetItemInfo(3729);
  _,SMARTBUFF_TASTYLIONSTEAK         = GetItemInfo(3728);
  _,SMARTBUFF_SPIDERSAUSAGE          = GetItemInfo(17222);
  _,SMARTBUFF_HEAVYKODOSTEW          = GetItemInfo(12215);
  _,SMARTBUFF_MONSTEROMELET          = GetItemInfo(12218);
  _,SMARTBUFF_SPICEDCHILICRAB        = GetItemInfo(12216);
  _,SMARTBUFF_TENDERWOLFSTEAK        = GetItemInfo(18045);
  _,SMARTBUFF_SAGEFISHDELIGHT        = GetItemInfo(21217);
  _,SMARTBUFF_SMOKEDSAGEFISH         = GetItemInfo(21072);
  _,SMARTBUFF_GRILLEDSQUID           = GetItemInfo(13928);
  _,SMARTBUFF_BARBECUEDBUZZARDWING   = GetItemInfo(4457);
  _,SMARTBUFF_NIGHTFINSOUP           = GetItemInfo(13931);
  _,SMARTBUFF_RUNNTUMTUBERSURPRISE   = GetItemInfo(18254);
  _,SMARTBUFF_SMOKEDDESERTDUMPLINGS  = GetItemInfo(20452);

  -- Poisons (Classic max ranks)
  _,SMARTBUFF_INSTANTPOISON1   = GetItemInfo(6947);
  _,SMARTBUFF_INSTANTPOISON2   = GetItemInfo(6949);
  _,SMARTBUFF_INSTANTPOISON3   = GetItemInfo(6950);
  _,SMARTBUFF_INSTANTPOISON4   = GetItemInfo(8926);
  _,SMARTBUFF_INSTANTPOISON5   = GetItemInfo(8927);
  _,SMARTBUFF_INSTANTPOISON6   = GetItemInfo(8928);
  _,SMARTBUFF_WOUNDPOISON1     = GetItemInfo(10918);
  _,SMARTBUFF_WOUNDPOISON2     = GetItemInfo(10920);
  _,SMARTBUFF_WOUNDPOISON3     = GetItemInfo(10921);
  _,SMARTBUFF_WOUNDPOISON4     = GetItemInfo(10922);
  _,SMARTBUFF_MINDPOISON1      = GetItemInfo(5237);
  _,SMARTBUFF_MINDPOISON2      = GetItemInfo(6951);
  _,SMARTBUFF_MINDPOISON3      = GetItemInfo(9186);
  _,SMARTBUFF_DEADLYPOISON1    = GetItemInfo(2892);
  _,SMARTBUFF_DEADLYPOISON2    = GetItemInfo(2893);
  _,SMARTBUFF_DEADLYPOISON3    = GetItemInfo(8984);
  _,SMARTBUFF_DEADLYPOISON4    = GetItemInfo(8985);
  _,SMARTBUFF_DEADLYPOISON5    = GetItemInfo(20844);
  _,SMARTBUFF_CRIPPLINGPOISON1 = GetItemInfo(3775);
  _,SMARTBUFF_CRIPPLINGPOISON2 = GetItemInfo(3776);

  SMARTBUFF_MANAAGATE   = GetItemInfo(5514);
  SMARTBUFF_MANACITRINE = GetItemInfo(8007);
  SMARTBUFF_MANAJADE    = GetItemInfo(5513);
  SMARTBUFF_MANARUBY    = GetItemInfo(8008);

  S.FoodItems = GetItems({
    21217, 21072, 18045, 13928, 2888, 12224, 5472, 5474, 6888, 2680, 5525, 2684, 2683, 2687, 3220,
    3662, 5476, 724, 5477, 5527, 3726, 5479, 3664, 3665, 3666, 3727, 5480, 12209, 3663, 1082, 1017,
    12213, 12210, 6038, 20074, 13851, 12212, 12214, 3729, 3728, 17222, 12215, 12218, 12216, 13931,
    18254, 20452, 4457
  });

  S.ConjuredMageFood = { 5349, 1113, 1114, 1487, 8075, 8076, 22895 };
  S.ConjuredMageWater = { 5350, 2288, 2136, 3772, 8077, 8078, 8079 };
  -- Per-rank mana gem products (one spell → one item).
  S.ConjuredMageGemAgate = { 5514 };
  S.ConjuredMageGemJade = { 5513 };
  S.ConjuredMageGemCitrine = { 8007 };
  S.ConjuredMageGemRuby = { 8008 };
  S.ConjuredLockHealthStones = { 5512, 5511, 5509, 5510, 9421 };
  S.ConjuredLockSoulstones = { 5232, 16892, 16893, 16895, 16896 };
  S.ConjuredLockSpellstones = { 5522, 13602, 13603 };
  S.ConjuredLockFirestones = { 1254, 13699, 13700, 13701 };
  S.SoulShardItemID = 6265;

  -- Scrolls I–IV (Classic)
  _,SMARTBUFF_SOAGILITY1   = GetItemInfo(3012);
  _,SMARTBUFF_SOAGILITY2   = GetItemInfo(1477);
  _,SMARTBUFF_SOAGILITY3   = GetItemInfo(4425);
  _,SMARTBUFF_SOAGILITY4   = GetItemInfo(10309);
  _,SMARTBUFF_SOINTELLECT1 = GetItemInfo(955);
  _,SMARTBUFF_SOINTELLECT2 = GetItemInfo(2290);
  _,SMARTBUFF_SOINTELLECT3 = GetItemInfo(4419);
  _,SMARTBUFF_SOINTELLECT4 = GetItemInfo(10308);
  _,SMARTBUFF_SOSTAMINA1   = GetItemInfo(1180);
  _,SMARTBUFF_SOSTAMINA2   = GetItemInfo(1711);
  _,SMARTBUFF_SOSTAMINA3   = GetItemInfo(4422);
  _,SMARTBUFF_SOSTAMINA4   = GetItemInfo(10307);
  _,SMARTBUFF_SOSPIRIT1    = GetItemInfo(1181);
  _,SMARTBUFF_SOSPIRIT2    = GetItemInfo(1712);
  _,SMARTBUFF_SOSPIRIT3    = GetItemInfo(4424);
  _,SMARTBUFF_SOSPIRIT4    = GetItemInfo(10306);
  _,SMARTBUFF_SOSTRENGHT1  = GetItemInfo(954);
  _,SMARTBUFF_SOSTRENGHT2  = GetItemInfo(2289);
  _,SMARTBUFF_SOSTRENGHT3  = GetItemInfo(4426);
  _,SMARTBUFF_SOSTRENGHT4  = GetItemInfo(10310);

  -- Classic flasks / elixirs
  _,SMARTBUFF_FLASKCLASSIC1       = GetItemInfo(13510); -- Flask of the Titans
  _,SMARTBUFF_FLASKCLASSIC2       = GetItemInfo(13511); -- Flask of Distilled Wisdom
  _,SMARTBUFF_FLASKCLASSIC3       = GetItemInfo(13512); -- Flask of Supreme Power
  _,SMARTBUFF_FLASKCLASSIC4       = GetItemInfo(13513); -- Flask of Chromatic Resistance
  -- Forever Hyjal flasks
  _,SMARTBUFF_FLASKNATURAL1       = GetItemInfo(274274); -- Flask of Natural Aggression
  _,SMARTBUFF_FLASKNATURAL2       = GetItemInfo(274276); -- Flask of Natural Swiftness
  _,SMARTBUFF_FLASKNATURAL3       = GetItemInfo(274273); -- Flask of Natural Accuracy
  _,SMARTBUFF_FLASKNATURAL4       = GetItemInfo(274275); -- Flask of Natural Precision
  _,SMARTBUFF_ELIXIR1             = GetItemInfo(8949);  -- Elixir of Agility
  _,SMARTBUFF_ELIXIR15            = GetItemInfo(9187);  -- Elixir of Greater Agility
  _,SMARTBUFF_ELIXIRGIANTS        = GetItemInfo(9206);  -- Elixir of Greater Strength
  _,SMARTBUFF_ELIXIRMONGOOSE      = GetItemInfo(13452); -- Elixir of the Mongoose
  _,SMARTBUFF_ELIXIRMINORARCANE   = GetItemInfo(247754); -- Minor Arcane Elixir (Forever)
  _,SMARTBUFF_ELIXIRLESSERARCANE  = GetItemInfo(250342); -- Lesser Arcane Elixir (Forever)
  _,SMARTBUFF_ELIXIRARCANE        = GetItemInfo(9155);  -- Arcane Elixir
  _,SMARTBUFF_ELIXIRGREATERARCANE = GetItemInfo(13454); -- Greater Arcane Elixir
  _,SMARTBUFF_ELIXIRBRUTEFORCE    = GetItemInfo(13453); -- Elixir of Brute Force
  _,SMARTBUFF_ELIXIRSUPDEF        = GetItemInfo(13445); -- Elixir of Greater Defense
  _,SMARTBUFF_ELIXIRSAGES         = GetItemInfo(13447); -- Elixir of the Sages
  _,SMARTBUFF_MAGEBLOODPOTION     = GetItemInfo(20007); -- Mageblood Elixir
  _,SMARTBUFF_LESSERMAGEBLOOD     = GetItemInfo(250340); -- Lesser Mageblood Elixir (Forever)
  _,SMARTBUFF_GREATERMAGEBLOOD    = GetItemInfo(250341); -- Greater Mageblood Elixir (Forever)
  _,SMARTBUFF_MAJORTROLLBLOOD     = GetItemInfo(20004); -- Major Troll's Blood Elixir
  -- Forever elixirs
  _,SMARTBUFF_ELIXIRFORTITUDE     = GetItemInfo(250334); -- Elixir of Fortitude
  _,SMARTBUFF_ELIXIRGREATERFORT   = GetItemInfo(250335); -- Elixir of Greater Fortitude
  _,SMARTBUFF_ELIXIRPHALANX       = GetItemInfo(250329); -- Elixir of the Phalanx
  _,SMARTBUFF_ELIXIRWICKEDREGEN   = GetItemInfo(250336); -- Elixir of Wicked Regeneration
  _,SMARTBUFF_MINORCLERIC         = GetItemInfo(250330); -- Minor Cleric's Elixir
  _,SMARTBUFF_LESSERCLERIC        = GetItemInfo(250331); -- Lesser Cleric's Elixir
  _,SMARTBUFF_CLERICELIXIR        = GetItemInfo(250332); -- Cleric's Elixir
  _,SMARTBUFF_GREATERCLERIC       = GetItemInfo(250333); -- Greater Cleric's Elixir
  _,SMARTBUFF_ELIXIRNATUREPOWER   = GetItemInfo(250343); -- Elixir of Nature Power
  _,SMARTBUFF_ELIXIRCUNNING       = GetItemInfo(250328); -- Elixir of Cunning
  _,SMARTBUFF_ELIXIRFEROCITY      = GetItemInfo(250350); -- Elixir of Ferocity
  _,SMARTBUFF_ELIXIRGREATERSPIRIT = GetItemInfo(250347); -- Elixir of Greater Spirit
  _,SMARTBUFF_ELIXIRGRIZZLY       = GetItemInfo(250351); -- Elixir of the Grizzly
  _,SMARTBUFF_ELIXIRLESSERINT     = GetItemInfo(250353); -- Elixir of Lesser Intellect
  _,SMARTBUFF_ELIXIRLESSERSPIRIT  = GetItemInfo(250345); -- Elixir of Lesser Spirit
  _,SMARTBUFF_ELIXIROWL           = GetItemInfo(250337); -- Elixir of the Owl
  _,SMARTBUFF_ELIXIRWHALE         = GetItemInfo(250348); -- Elixir of the Whale

  _, _, _, _, _, _, S.FishingPole = GetItemInfo(6256);

  if (SMARTBUFF_HSTONE or SMARTBUFF_SSROUGH) then
    S._itemListReady = true;
    SMARTBUFF_AddMsgD("Item list initialized");
  else
    SMARTBUFF_AddMsgD("Item list pending (item cache not ready)");
  end
end

--
--  Initialise Spell IDs (Classic Era / Forever only)
--
function SMARTBUFF_InitSpellIDs()

  SMARTBUFF_TESTSPELL = GetSpellInfo(774);

  -- Paladin ------------------------------------------------------------------
  SMARTBUFF_GBOM            = GetSpellInfo(25782);  -- Greater Blessing of Might
  SMARTBUFF_GBOK            = GetSpellInfo(25898);  -- Greater Blessing of Kings
  SMARTBUFF_GBOW            = GetSpellInfo(25894);  -- Greater Blessing of Wisdom
  SMARTBUFF_GBOS            = GetSpellInfo(25899);  -- Greater Blessing of Sanctuary
  SMARTBUFF_GBOSAL          = GetSpellInfo(25895);  -- Greater Blessing of Salvation
  SMARTBUFF_GBOL            = GetSpellInfo(25890);  -- Greater Blessing of Light
  SMARTBUFF_BOM             = GetSpellInfo(19740);  -- Blessing of Might
  SMARTBUFF_BOK             = GetSpellInfo(20217);  -- Blessing of Kings
  SMARTBUFF_BOW             = GetSpellInfo(19742);  -- Blessing of Wisdom
  SMARTBUFF_BOS             = GetSpellInfo(20911);  -- Blessing of Sanctuary
  SMARTBUFF_BOL             = GetSpellInfo(19977);  -- Blessing of Light
  SMARTBUFF_BOSAL           = GetSpellInfo(1038);   -- Blessing of Salvation

  SMARTBUFF_HOF             = GetSpellInfo(1044);   -- Blessing of Freedom
  SMARTBUFF_HOP             = GetSpellInfo(1022);   -- Blessing of Protection
  SMARTBUFF_HOSAL           = GetSpellInfo(1038);   -- Blessing of Salvation (same spell; listed under "hands" for UI parity)
  SMARTBUFF_HOSAC           = GetSpellInfo(6940);   -- Blessing of Sacrifice

  SMARTBUFF_SOCOMMAND       = GetSpellInfo(20375);  -- Seal of Command
  SMARTBUFF_SOJUSTICE       = GetSpellInfo(20164);  -- Seal of Justice
  SMARTBUFF_SORIGHTEOUSNESS = GetSpellInfo(21084);  -- Seal of Righteousness
  SMARTBUFF_SOWISDOM        = GetSpellInfo(20166);  -- Seal of Wisdom
  SMARTBUFF_SOLIGHT         = GetSpellInfo(20165);  -- Seal of Light
  SMARTBUFF_SEALCRUSADER    = GetSpellInfo(21082);  -- Seal of the Crusader

  SMARTBUFF_DEVOTIONAURA    = GetSpellInfo(465);    -- Devotion Aura
  SMARTBUFF_RETRIBUTIONAURA = GetSpellInfo(7294);   -- Retribution Aura
  SMARTBUFF_FIREAURA        = GetSpellInfo(19891);  -- Fire Resistance Aura
  SMARTBUFF_FROSTAURA       = GetSpellInfo(19888);  -- Frost Resistance Aura
  SMARTBUFF_SHADOWAURA      = GetSpellInfo(19876);  -- Shadow Resistance Aura
  SMARTBUFF_SANCTITYAURA    = GetSpellInfo(20218);  -- Sanctity Aura

  SMARTBUFF_RIGHTEOUSFURY   = GetSpellInfo(25780);  -- Righteous Fury
  SMARTBUFF_HOLYSHIELD      = GetSpellInfo(20925);  -- Holy Shield

  S.ChainPaladinAura     = { SMARTBUFF_DEVOTIONAURA, SMARTBUFF_RETRIBUTIONAURA, SMARTBUFF_FIREAURA, SMARTBUFF_FROSTAURA, SMARTBUFF_SHADOWAURA, SMARTBUFF_SANCTITYAURA };
  S.ChainPaladinSeal     = { SMARTBUFF_SOCOMMAND, SMARTBUFF_SOJUSTICE, SMARTBUFF_SORIGHTEOUSNESS, SMARTBUFF_SOWISDOM, SMARTBUFF_SOLIGHT, SMARTBUFF_SEALCRUSADER };
  S.ChainPaladinHand     = { SMARTBUFF_HOF, SMARTBUFF_HOP, SMARTBUFF_HOSAL, SMARTBUFF_HOSAC };
  S.ChainPaladinBlessing = { SMARTBUFF_GBOM, SMARTBUFF_GBOK, SMARTBUFF_GBOW, SMARTBUFF_GBOS, SMARTBUFF_GBOSAL, SMARTBUFF_GBOL, SMARTBUFF_BOM, SMARTBUFF_BOK, SMARTBUFF_BOW, SMARTBUFF_BOS, SMARTBUFF_BOSAL, SMARTBUFF_BOL };

  -- Mage --------------------------------------------------------------------
  SMARTBUFF_AI                 = GetSpellInfo(1459);   -- Arcane Intellect
  SMARTBUFF_AB                 = GetSpellInfo(23028);  -- Arcane Brilliance
  SMARTBUFF_ICEARMOR           = GetSpellInfo(7302);   -- Ice Armor
  SMARTBUFF_FROSTARMOR         = GetSpellInfo(168);    -- Frost Armor
  SMARTBUFF_MAGEARMOR          = GetSpellInfo(6117);   -- Mage Armor
  SMARTBUFF_MANASHIELD         = GetSpellInfo(1463);   -- Mana Shield
  SMARTBUFF_ICEBARRIER         = GetSpellInfo(11426);  -- Ice Barrier
  SMARTBUFF_FIREWARD           = GetSpellInfo(543);    -- Fire Ward
  SMARTBUFF_FROSTWARD          = GetSpellInfo(6143);   -- Frost Ward
  SMARTBUFF_AMPLIFYMAGIC       = GetSpellInfo(1008);   -- Amplify Magic
  SMARTBUFF_DAMPENMAGIC        = GetSpellInfo(604);    -- Dampen Magic
  SMARTBUFF_ARCANEPOWER        = GetSpellInfo(12042);  -- Arcane Power
  SMARTBUFF_PRESENCEOFMIND     = GetSpellInfo(12043);  -- Presence of Mind
  SMARTBUFF_ICYVEINS           = GetSpellInfo(12472);  -- Icy Veins
  SMARTBUFF_CONJFOOD           = GetSpellInfo(587);    -- Conjure Food
  SMARTBUFF_CONJWATER          = GetSpellInfo(5504);   -- Conjure Water
  SMARTBUFF_CREATEMGEM_AGATE   = GetSpellInfo(759);    -- Conjure Mana Agate
  SMARTBUFF_CREATEMGEM_JADE    = GetSpellInfo(3552);   -- Conjure Mana Jade
  SMARTBUFF_CREATEMGEM_CITRINE = GetSpellInfo(10053);  -- Conjure Mana Citrine
  SMARTBUFF_CREATEMGEM_RUBY    = GetSpellInfo(10054);  -- Conjure Mana Ruby

  S.ChainMageArmor = { SMARTBUFF_ICEARMOR, SMARTBUFF_FROSTARMOR, SMARTBUFF_MAGEARMOR };
  S.ChainMageBuffs = { SMARTBUFF_AI, SMARTBUFF_AB };

  -- Druid -------------------------------------------------------------------
  SMARTBUFF_MOTW           = GetSpellInfo(1126);   -- Mark of the Wild
  SMARTBUFF_GOTW           = GetSpellInfo(21849);  -- Gift of the Wild
  SMARTBUFF_THORNS         = GetSpellInfo(467);    -- Thorns
  SMARTBUFF_BARKSKIN       = GetSpellInfo(22812);  -- Barkskin
  SMARTBUFF_NATURESGRASP   = GetSpellInfo(16689);  -- Nature's Grasp
  SMARTBUFF_DRUID_CAT      = GetSpellInfo(768);    -- Cat Form
  SMARTBUFF_DRUID_MOONKIN  = GetSpellInfo(24858);  -- Moonkin Form
  SMARTBUFF_DRUID_BEAR     = GetSpellInfo(5487);   -- Bear Form
  SMARTBUFF_DRUID_DIREBEAR = GetSpellInfo(9634);   -- Dire Bear Form
  SMARTBUFF_DRUID_TRACK    = GetSpellInfo(5225);   -- Track Humanoids
  SMARTBUFF_OMENOFCLARITY  = GetSpellInfo(16864);  -- Omen of Clarity

  S.ChainDruidBuffs = { SMARTBUFF_MOTW, SMARTBUFF_GOTW };

  -- Priest ------------------------------------------------------------------
  SMARTBUFF_PWFORTITUDE      = GetSpellInfo(1243);   -- Power Word: Fortitude
  SMARTBUFF_PRAYERFORTITUDE  = GetSpellInfo(21562);  -- Prayer of Fortitude
  SMARTBUFF_DIVINESPIRIT     = GetSpellInfo(14752);  -- Divine Spirit
  SMARTBUFF_PRAYERSPIRIT     = GetSpellInfo(27681);  -- Prayer of Spirit
  SMARTBUFF_SHADOWPROT       = GetSpellInfo(976);    -- Shadow Protection
  SMARTBUFF_PRAYERSHADOWPROT = GetSpellInfo(27683);  -- Prayer of Shadow Protection
  SMARTBUFF_INNERFOCUS       = GetSpellInfo(14751);  -- Inner Focus
  SMARTBUFF_INNERFIRE        = GetSpellInfo(588);    -- Inner Fire
  SMARTBUFF_FEARWARD         = GetSpellInfo(6346);   -- Fear Ward
  SMARTBUFF_SHADOWFORM       = GetSpellInfo(15473);  -- Shadowform
  SMARTBUFF_PWSHIELD         = GetSpellInfo(17);     -- Power Word: Shield
  SMARTBUFF_ELUNESGRACE      = GetSpellInfo(2651);   -- Elune's Grace
  SMARTBUFF_FEEDBACK         = GetSpellInfo(13896);  -- Feedback
  SMARTBUFF_SHADOWGUARD      = GetSpellInfo(18137);  -- Shadowguard
  SMARTBUFF_TOUCHOFWEAKNESS  = GetSpellInfo(2652);   -- Touch of Weakness
  SMARTBUFF_VAMPIRICEMB      = GetSpellInfo(15286);  -- Vampiric Embrace

  S.LinkPriestSpirit  = { SMARTBUFF_DIVINESPIRIT, SMARTBUFF_PRAYERSPIRIT };
  S.LinkPriestShadow  = { SMARTBUFF_SHADOWPROT, SMARTBUFF_PRAYERSHADOWPROT };
  S.ChainPriestFort   = { SMARTBUFF_PWFORTITUDE, SMARTBUFF_PRAYERFORTITUDE };
  S.ChainPriestSpirit = { SMARTBUFF_DIVINESPIRIT, SMARTBUFF_PRAYERSPIRIT };
  S.ChainPriestShadow = { SMARTBUFF_SHADOWPROT, SMARTBUFF_PRAYERSHADOWPROT };

  -- Warrior -----------------------------------------------------------------
  SMARTBUFF_BATTLESHOUT   = GetSpellInfo(5242);   -- Battle Shout (Forever)
  SMARTBUFF_BATSTANCE     = GetSpellInfo(2457);   -- Battle Stance
  SMARTBUFF_DEFSTANCE     = GetSpellInfo(71);     -- Defensive Stance
  SMARTBUFF_BESSTANCE     = GetSpellInfo(2458);   -- Berserker Stance
  SMARTBUFF_BERSERKERRAGE = GetSpellInfo(18499);  -- Berserker Rage
  SMARTBUFF_BLOODRAGE     = GetSpellInfo(2687);   -- Bloodrage
  SMARTBUFF_SHIELDBLOCK   = GetSpellInfo(2565);   -- Shield Block

  S.ChainWarriorStance = { SMARTBUFF_BATSTANCE, SMARTBUFF_DEFSTANCE, SMARTBUFF_BESSTANCE };
  S.ChainWarriorShout  = { SMARTBUFF_BATTLESHOUT };

  -- Shaman ------------------------------------------------------------------
  SMARTBUFF_LIGHTNINGSHIELD = GetSpellInfo(324);   -- Lightning Shield
  SMARTBUFF_ROCKBITERW      = GetSpellInfo(8017);  -- Rockbiter Weapon
  SMARTBUFF_FROSTBRANDW     = GetSpellInfo(8033);  -- Frostbrand Weapon
  SMARTBUFF_FLAMETONGUEW    = GetSpellInfo(8024);  -- Flametongue Weapon
  SMARTBUFF_WINDFURYW       = GetSpellInfo(8232);  -- Windfury Weapon
  SMARTBUFF_WATERBREATHING  = GetSpellInfo(131);   -- Water Breathing
  SMARTBUFF_WATERWALKING    = GetSpellInfo(546);   -- Water Walking

  S.ChainShamanShield = { SMARTBUFF_LIGHTNINGSHIELD };

  -- Hunter ------------------------------------------------------------------
  SMARTBUFF_TRUESHOTAURA = GetSpellInfo(19506); -- Trueshot Aura
  SMARTBUFF_RAPIDFIRE    = GetSpellInfo(3045);  -- Rapid Fire
  SMARTBUFF_CALLPET1     = GetSpellInfo(883);   -- Call Pet
  SMARTBUFF_REVIVEPET    = GetSpellInfo(982);   -- Revive Pet
  SMARTBUFF_AOTH         = GetSpellInfo(13165); -- Aspect of the Hawk
  SMARTBUFF_AOTM         = GetSpellInfo(13163); -- Aspect of the Monkey
  SMARTBUFF_AOTW         = GetSpellInfo(20043); -- Aspect of the Wild
  SMARTBUFF_AOTB         = GetSpellInfo(13161); -- Aspect of the Beast
  SMARTBUFF_AOTC         = GetSpellInfo(5118);  -- Aspect of the Cheetah
  SMARTBUFF_AOTP         = GetSpellInfo(13159); -- Aspect of the Pack

  S.ChainAspects = { SMARTBUFF_AOTH, SMARTBUFF_AOTM, SMARTBUFF_AOTW, SMARTBUFF_AOTB, SMARTBUFF_AOTC, SMARTBUFF_AOTP };

  -- Warlock -----------------------------------------------------------------
  SMARTBUFF_DEMONSKIN        = GetSpellInfo(687);   -- Demon Skin
  SMARTBUFF_DEMONARMOR       = GetSpellInfo(706);   -- Demon Armor
  SMARTBUFF_SUMMONINFERNAL   = GetSpellInfo(1122);  -- Inferno
  SMARTBUFF_SUMMONFELHUNTER  = GetSpellInfo(691);   -- Summon Felhunter
  SMARTBUFF_SUMMONIMP        = GetSpellInfo(688);   -- Summon Imp
  SMARTBUFF_SUMMONSUCCUBUS   = GetSpellInfo(712);   -- Summon Succubus
  SMARTBUFF_SUMMONINCUBUS    = GetSpellInfo(713);   -- Summon Incubus
  SMARTBUFF_SUMMONVOIDWALKER = GetSpellInfo(697);   -- Summon Voidwalker
  SMARTBUFF_UNENDINGBREATH   = GetSpellInfo(5697);  -- Unending Breath
  SMARTBUFF_CREATEHS         = GetSpellInfo(6201);  -- Create Healthstone
  SMARTBUFF_CREATESOULS      = GetSpellInfo(693);   -- Create Soulstone
  SMARTBUFF_CREATESPELLS     = GetSpellInfo(2362);  -- Create Spellstone
  SMARTBUFF_CREATEFIRES      = GetSpellInfo(6366);  -- Create Firestone
  SMARTBUFF_LOCKLESSERINVIS  = GetSpellInfo(6512);  -- Detect Lesser Invisibility
  SMARTBUFF_LOCKINVISIBILITY = GetSpellInfo(132);   -- Detect Invisibility
  SMARTBUFF_LOCKSENSEDEMONS  = GetSpellInfo(5500);  -- Sense Demons
  SMARTBUFF_SOULLINK         = GetSpellInfo(19028); -- Soul Link

  -- Rogue -------------------------------------------------------------------
  SMARTBUFF_STEALTH     = GetSpellInfo(1784);  -- Stealth
  SMARTBUFF_BLADEFLURRY = GetSpellInfo(13877); -- Blade Flurry
  SMARTBUFF_SAD         = GetSpellInfo(5171);  -- Slice and Dice
  SMARTBUFF_EVASION     = GetSpellInfo(5277);  -- Evasion

  -- Skyborne racials (Forever)
  SMARTBUFF_WALKONAIR   = GetSpellInfo(1259416);
  SMARTBUFF_READLEYLINE = GetSpellInfo(1259705);
  SMARTBUFF_SKYSIGHT    = GetSpellInfo(1259686);

  -- Tracking / gathering
  SMARTBUFF_FINDMINERALS    = GetSpellInfo(2580);
  SMARTBUFF_FINDHERBS       = GetSpellInfo(2383);
  SMARTBUFF_FINDTREASURE    = GetSpellInfo(2481);
  SMARTBUFF_TRACKHUMANOIDS  = GetSpellInfo(19883);
  SMARTBUFF_TRACKBEASTS     = GetSpellInfo(1494);
  SMARTBUFF_TRACKUNDEAD     = GetSpellInfo(19884);
  SMARTBUFF_TRACKHIDDEN     = GetSpellInfo(19885);
  SMARTBUFF_TRACKELEMENTALS = GetSpellInfo(19880);
  SMARTBUFF_TRACKDEMONS     = GetSpellInfo(19878);
  SMARTBUFF_TRACKGIANTS     = GetSpellInfo(19882);
  SMARTBUFF_TRACKDRAGONKIN  = GetSpellInfo(19879);

  -- Racial
  SMARTBUFF_STONEFORM   = GetSpellInfo(20594); -- Stoneform
  SMARTBUFF_BLOODFURY   = GetSpellInfo(20572); -- Blood Fury
  SMARTBUFF_BERSERKING  = GetSpellInfo(26297); -- Berserking
  SMARTBUFF_WOTFORSAKEN = GetSpellInfo(7744);  -- Will of the Forsaken
  SMARTBUFF_WarStomp    = GetSpellInfo(20549); -- War Stomp

  -- Food / drink auras. Forever Well Fed uses many spell IDs (AP/Int/Str/Stam/...).
  -- Probe all known IDs; name match is a secondary fallback in Buff.lua.
  SMARTBUFF_WellFedSpellIDs = {
    1248406, -- Stamina
    1248420, -- Agility
    1248421, -- Intellect
    1248422, -- Strength
    1248688, -- Movement speed
    1249519, -- Attack Power (e.g. Brilliant Smallfish)
    1249520,
    1249521,
    1249523,
    1319310,
    19705,   -- Classic Well Fed fallback
  };
  SMARTBUFF_WellFedAuras = {};
  for _, wfId in ipairs(SMARTBUFF_WellFedSpellIDs) do
    local info = GetSpellInfo(wfId);
    if (info) then
      tinsert(SMARTBUFF_WellFedAuras, info);
    end
  end
  SMARTBUFF_WellFedAura = GetSpellInfo(1248421) or SMARTBUFF_WellFedAuras[1] or GetSpellInfo(19705);
  SMARTBUFF_FOOD_AURA   = SMARTBUFF_WellFedAura;
  -- Forever eat-while-seated effect only (not Well Fed satiety IDs — those must not pause checks).
  SMARTBUFF_NutritiousFoodSpellIDs = { 1248383, 1249500, 1249515, 1249516, 1249517, 1249518, };
  SMARTBUFF_NutritiousFoodAuras = {};
  for _, nutriId in ipairs(SMARTBUFF_NutritiousFoodSpellIDs) do
    local info = GetSpellInfo(nutriId);
    if (info) then
      tinsert(SMARTBUFF_NutritiousFoodAuras, info);
    end
  end
  SMARTBUFF_NUTRITIOUS_FOOD_SPELL = SMARTBUFF_NutritiousFoodAuras[1] or GetSpellInfo(1248383) or GetSpellInfo(1249500);
  SMARTBUFF_FOOD_SPELL  = GetSpellInfo(433);   -- Food
  SMARTBUFF_DRINK_SPELL = GetSpellInfo(430);   -- Drink
  SMARTBUFF_FISHING     = GetSpellInfo(7620);  -- Fishing

  -- Scroll buff auras
  SMARTBUFF_SBAGILITY  = GetSpellInfo(8115);
  SMARTBUFF_SBINTELLECT = GetSpellInfo(8096);
  SMARTBUFF_SBSTAMINA  = GetSpellInfo(8099);
  SMARTBUFF_SBSPIRIT   = GetSpellInfo(8112);
  SMARTBUFF_SBSTRENGTH = GetSpellInfo(8118);

  -- Classic flask / elixir buffs
  SMARTBUFF_BFLASKCLASSIC1       = GetSpellInfo(17626); -- Flask of the Titans
  SMARTBUFF_BFLASKCLASSIC2       = GetSpellInfo(17627); -- Distilled Wisdom
  SMARTBUFF_BFLASKCLASSIC3       = GetSpellInfo(17628); -- Supreme Power
  SMARTBUFF_BFLASKCLASSIC4       = GetSpellInfo(17629); -- Chromatic Resistance
  SMARTBUFF_BFLASKNATURAL1       = GetSpellInfo(1293741); -- Flask of Natural Aggression
  SMARTBUFF_BFLASKNATURAL2       = GetSpellInfo(1293743); -- Flask of Natural Swiftness
  SMARTBUFF_BFLASKNATURAL3       = GetSpellInfo(1293740); -- Flask of Natural Accuracy
  SMARTBUFF_BFLASKNATURAL4       = GetSpellInfo(1293742); -- Flask of Natural Precision
  SMARTBUFF_BELIXIR1             = GetSpellInfo(11328); -- Agility
  SMARTBUFF_BELIXIR15            = GetSpellInfo(11334); -- Greater Agility
  SMARTBUFF_BELIXIRGIANTS        = GetSpellInfo(11405); -- Greater Strength
  SMARTBUFF_BELIXIRMONGOOSE      = GetSpellInfo(17538); -- Elixir of the Mongoose
  SMARTBUFF_BELIXIRMINORARCANE   = GetSpellInfo(1245244); -- Minor Arcane Elixir
  SMARTBUFF_BELIXIRLESSERARCANE  = GetSpellInfo(1250971); -- Lesser Arcane Elixir
  SMARTBUFF_BELIXIRARCANE        = GetSpellInfo(11390);  -- Arcane Elixir
  SMARTBUFF_BELIXIRGREATERARCANE = GetSpellInfo(17539); -- Greater Arcane Elixir
  SMARTBUFF_BELIXIRBRUTEFORCE    = GetSpellInfo(17537); -- Elixir of Brute Force
  SMARTBUFF_BELIXIRSUPDEF        = GetSpellInfo(11348); -- Greater Defense
  SMARTBUFF_BELIXIRSAGES         = GetSpellInfo(17535); -- Elixir of the Sages
  SMARTBUFF_BMAGEBLOODPOTION     = GetSpellInfo(24363); -- Mageblood Elixir
  SMARTBUFF_BLESSERMAGEBLOOD     = GetSpellInfo(1250944); -- Lesser Mageblood Elixir
  SMARTBUFF_BGREATERMAGEBLOOD    = GetSpellInfo(1250948); -- Greater Mageblood Elixir
  SMARTBUFF_BMAJORTROLLBLOOD     = GetSpellInfo(24361); -- Major Troll's Blood Elixir
  SMARTBUFF_BELIXIRFORTITUDE     = GetSpellInfo(1250928); -- Elixir of Fortitude
  SMARTBUFF_BELIXIRGREATERFORT   = GetSpellInfo(1250931); -- Elixir of Greater Fortitude
  SMARTBUFF_BELIXIRPHALANX       = GetSpellInfo(1250920); -- Elixir of the Phalanx
  SMARTBUFF_BELIXIRWICKEDREGEN   = GetSpellInfo(1250932); -- Elixir of Wicked Regeneration
  SMARTBUFF_BMINORCLERIC         = GetSpellInfo(1250922); -- Minor Cleric's Elixir
  SMARTBUFF_BLESSERCLERIC        = GetSpellInfo(1250924); -- Lesser Cleric's Elixir
  SMARTBUFF_BCLERICELIXIR        = GetSpellInfo(1250925); -- Cleric's Elixir
  SMARTBUFF_BGREATERCLERIC       = GetSpellInfo(1250926); -- Greater Cleric's Elixir
  SMARTBUFF_BELIXIRNATUREPOWER   = GetSpellInfo(1250972); -- Elixir of Nature Power
  SMARTBUFF_BELIXIRCUNNING       = GetSpellInfo(1250918); -- Elixir of Cunning
  SMARTBUFF_BELIXIRFEROCITY      = GetSpellInfo(1250985); -- Elixir of Ferocity
  SMARTBUFF_BELIXIRGREATERSPIRIT = GetSpellInfo(1250979); -- Elixir of Greater Spirit
  SMARTBUFF_BELIXIRGRIZZLY       = GetSpellInfo(1250986); -- Elixir of the Grizzly
  SMARTBUFF_BELIXIRLESSERINT     = GetSpellInfo(1250988); -- Elixir of Lesser Intellect
  SMARTBUFF_BELIXIRLESSERSPIRIT  = GetSpellInfo(1250976); -- Elixir of Lesser Spirit
  SMARTBUFF_BELIXIROWL           = GetSpellInfo(1250940); -- Elixir of the Owl
  SMARTBUFF_BELIXIRWHALE         = GetSpellInfo(1250981); -- Elixir of the Whale

  S.LinkFlaskClassic = {
    SMARTBUFF_BFLASKCLASSIC1, SMARTBUFF_BFLASKCLASSIC2, SMARTBUFF_BFLASKCLASSIC3, SMARTBUFF_BFLASKCLASSIC4,
    SMARTBUFF_BFLASKNATURAL1, SMARTBUFF_BFLASKNATURAL2, SMARTBUFF_BFLASKNATURAL3, SMARTBUFF_BFLASKNATURAL4,
  };

  -- Forever: Kings stacks with Mark/Gift, Wisdom stacks with Arcane Intellect/Brilliance.
  -- Links stay inside one spell family (normal + greater, or intellect + brilliance).
  S.LinkStats = { SMARTBUFF_BOK, SMARTBUFF_GBOK };
  S.LinkSta   = { SMARTBUFF_PWFORTITUDE, SMARTBUFF_PRAYERFORTITUDE };
  S.LinkAp    = { SMARTBUFF_BATTLESHOUT, SMARTBUFF_TRUESHOTAURA };
  S.LinkMa    = { SMARTBUFF_BOM, SMARTBUFF_GBOM };
  S.LinkWis   = { SMARTBUFF_BOW, SMARTBUFF_GBOW };
  S.LinkInt   = { SMARTBUFF_AI, SMARTBUFF_AB };
end


function SMARTBUFF_InitSpellList()

  if (SMARTBUFF_PLAYERCLASS == nil) then return; end

  SMARTBUFF_BUFFLIST = SMARTBUFF_BUFFLIST or {};
  SMARTBUFF_WEAPON = SMARTBUFF_WEAPON or {};
  SMARTBUFF_TRACKING = SMARTBUFF_TRACKING or {};
  SMARTBUFF_RACIAL = SMARTBUFF_RACIAL or {};
  SMARTBUFF_FOOD = SMARTBUFF_FOOD or {};
  SMARTBUFF_SCROLL = SMARTBUFF_SCROLL or {};
  SMARTBUFF_POTION = SMARTBUFF_POTION or {};

  -- Paladin (Forever: 60-minute blessings)
  if (SMARTBUFF_PLAYERCLASS == "PALADIN") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_GBOM, 60, SMARTBUFF_CONST_GROUP, {52, 60}, nil, S.LinkMa, S.ChainPaladinBlessing},
      {SMARTBUFF_GBOK, 60, SMARTBUFF_CONST_GROUP, {60}, nil, S.LinkStats, S.ChainPaladinBlessing},
      {SMARTBUFF_GBOW, 60, SMARTBUFF_CONST_GROUP, {54, 60}, nil, S.LinkWis, S.ChainPaladinBlessing},
      {SMARTBUFF_GBOS, 60, SMARTBUFF_CONST_GROUP, {60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_GBOSAL, 60, SMARTBUFF_CONST_GROUP, {60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_GBOL, 60, SMARTBUFF_CONST_GROUP, {60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_BOM, 60, SMARTBUFF_CONST_GROUP, {4, 12, 22, 32, 42, 52, 60}, nil, S.LinkMa, S.ChainPaladinBlessing},
      {SMARTBUFF_BOK, 60, SMARTBUFF_CONST_GROUP, {20}, nil, S.LinkStats, S.ChainPaladinBlessing},
      {SMARTBUFF_BOW, 60, SMARTBUFF_CONST_GROUP, {14, 24, 34, 44, 54, 60}, nil, S.LinkWis, S.ChainPaladinBlessing},
      {SMARTBUFF_BOS, 60, SMARTBUFF_CONST_GROUP, {30, 40, 50, 60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_BOSAL, 60, SMARTBUFF_CONST_GROUP, {26}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_BOL, 60, SMARTBUFF_CONST_GROUP, {40, 50, 60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_HOF, 0.1, SMARTBUFF_CONST_GROUP, {18}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET", S.ChainPaladinHand},
      {SMARTBUFF_HOP, 0.1, SMARTBUFF_CONST_GROUP, {10, 24, 38}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET", S.ChainPaladinHand},
      {SMARTBUFF_HOSAL, 0.1, SMARTBUFF_CONST_GROUP, {26}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET", S.ChainPaladinHand},
      {SMARTBUFF_HOSAC, 0.1, SMARTBUFF_CONST_GROUP, {46}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET", S.ChainPaladinHand},
      {SMARTBUFF_SOCOMMAND, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOJUSTICE, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SORIGHTEOUSNESS, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOWISDOM, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOLIGHT, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SEALCRUSADER, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_DEVOTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_RETRIBUTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_FIREAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_FROSTAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_SHADOWAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_SANCTITYAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_RIGHTEOUSFURY, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_HOLYSHIELD, 0.17, SMARTBUFF_CONST_SELF},
    };
  end

  -- Mage
  if (SMARTBUFF_PLAYERCLASS == "MAGE") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_AI, 30, SMARTBUFF_CONST_GROUP, {1, 14, 28, 42, 56}, "WARRIOR;ROGUE;HPET;WPET", S.LinkInt, S.ChainMageBuffs},
      {SMARTBUFF_AB, 60, SMARTBUFF_CONST_GROUP, {56}, "WARRIOR;ROGUE;HPET;WPET", S.LinkInt, S.ChainMageBuffs},
      {SMARTBUFF_ICEARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_FROSTARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MAGEARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MANASHIELD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICEBARRIER, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FIREWARD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FROSTWARD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_AMPLIFYMAGIC, 10, SMARTBUFF_CONST_GROUP, {18, 30, 42, 54}, "WARRIOR;ROGUE;HPET;WPET"},
      {SMARTBUFF_DAMPENMAGIC, 10, SMARTBUFF_CONST_GROUP, {12, 24, 36, 48, 60}, "WARRIOR;ROGUE;HPET;WPET"},
      {SMARTBUFF_ARCANEPOWER, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_PRESENCEOFMIND, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICYVEINS, 0.333, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CONJFOOD, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageFood},
      {SMARTBUFF_CONJWATER, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageWater},
      {SMARTBUFF_CREATEMGEM_AGATE, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageGemAgate},
      {SMARTBUFF_CREATEMGEM_JADE, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageGemJade},
      {SMARTBUFF_CREATEMGEM_CITRINE, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageGemCitrine},
      {SMARTBUFF_CREATEMGEM_RUBY, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjure, nil, S.ConjuredMageGemRuby},
    };
  end

  -- Druid
  if (SMARTBUFF_PLAYERCLASS == "DRUID") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_MOTW, 30, SMARTBUFF_CONST_GROUP, {1, 10, 20, 30, 40, 50, 60}, "HPET;WPET", S.ChainDruidBuffs, S.ChainDruidBuffs},
      {SMARTBUFF_GOTW, 60, SMARTBUFF_CONST_GROUP, {50, 60}, "HPET;WPET", S.ChainDruidBuffs, S.ChainDruidBuffs},
      {SMARTBUFF_THORNS, 10, SMARTBUFF_CONST_GROUP, {6, 14, 24, 34, 44, 54}, "HPET;WPET"},
      {SMARTBUFF_BARKSKIN, 0.25, SMARTBUFF_CONST_FORCESELF},
      {SMARTBUFF_NATURESGRASP, 0.25, SMARTBUFF_CONST_FORCESELF},
      {SMARTBUFF_DRUID_CAT, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_MOONKIN, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_BEAR, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_DIREBEAR, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_TRACK, -1, SMARTBUFF_CONST_SELF, nil, SMARTBUFF_DRUID_CAT},
      {SMARTBUFF_OMENOFCLARITY, 10, SMARTBUFF_CONST_SELF},
    };
  end

  -- Priest
  if (SMARTBUFF_PLAYERCLASS == "PRIEST") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_PWFORTITUDE, 30, SMARTBUFF_CONST_GROUP, {1, 12, 24, 36, 48, 60}, "HPET;WPET", S.LinkSta, S.ChainPriestFort},
      {SMARTBUFF_PRAYERFORTITUDE, 60, SMARTBUFF_CONST_GROUP, {48, 60}, "HPET;WPET", S.LinkSta, S.ChainPriestFort},
      {SMARTBUFF_DIVINESPIRIT, 30, SMARTBUFF_CONST_GROUP, {30, 40, 50, 60}, "WARRIOR;ROGUE;HPET;WPET", S.LinkPriestSpirit, S.ChainPriestSpirit},
      {SMARTBUFF_PRAYERSPIRIT, 60, SMARTBUFF_CONST_GROUP, {60}, "WARRIOR;ROGUE;HPET;WPET", S.LinkPriestSpirit, S.ChainPriestSpirit},
      {SMARTBUFF_SHADOWPROT, 30, SMARTBUFF_CONST_GROUP, {30, 42, 56}, "HPET;WPET", S.LinkPriestShadow, S.ChainPriestShadow},
      {SMARTBUFF_PRAYERSHADOWPROT, 60, SMARTBUFF_CONST_GROUP, {56}, "HPET;WPET", S.LinkPriestShadow, S.ChainPriestShadow},
      {SMARTBUFF_FEARWARD, 10, SMARTBUFF_CONST_GROUP, {20}, "HPET;WPET"},
      {SMARTBUFF_INNERFOCUS, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_INNERFIRE, 10, SMARTBUFF_CONST_FORCESELF},
      {SMARTBUFF_VAMPIRICEMB, 30, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHADOWFORM, -1, SMARTBUFF_CONST_FORCESELF},
      {SMARTBUFF_PWSHIELD, 0.5, SMARTBUFF_CONST_GROUP, {6, 12, 18, 24, 30, 36, 42, 48, 54, 60}, "MAGE;WARLOCK;ROGUE;PALADIN;WARRIOR;DRUID;HUNTER;SHAMAN;HPET;WPET"},
      {SMARTBUFF_ELUNESGRACE, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FEEDBACK, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHADOWGUARD, 10, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_TOUCHOFWEAKNESS, 10, SMARTBUFF_CONST_SELF},
    };
  end

  -- Warrior
  if (SMARTBUFF_PLAYERCLASS == "WARRIOR") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_BATSTANCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainWarriorStance},
      {SMARTBUFF_DEFSTANCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainWarriorStance},
      {SMARTBUFF_BESSTANCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainWarriorStance},
      {SMARTBUFF_BATTLESHOUT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarriorShout},
      {SMARTBUFF_BERSERKERRAGE, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHIELDBLOCK, 0.1666, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLOODRAGE, 0.165, SMARTBUFF_CONST_SELF},
    };
  end

  -- Shaman
  if (SMARTBUFF_PLAYERCLASS == "SHAMAN") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_LIGHTNINGSHIELD, 10, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainShamanShield},
      {SMARTBUFF_WINDFURYW, 5, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FLAMETONGUEW, 5, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FROSTBRANDW, 5, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_ROCKBITERW, 5, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_WATERBREATHING, 10, SMARTBUFF_CONST_GROUP, {22}},
      {SMARTBUFF_WATERWALKING, 10, SMARTBUFF_CONST_GROUP, {28}},
    };
  end

  -- Hunter
  if (SMARTBUFF_PLAYERCLASS == "HUNTER") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_TRUESHOTAURA, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAPIDFIRE, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_AOTH, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTM, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTW, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTB, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTC, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTP, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_REVIVEPET, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CALLPET1, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
    };
  end

  -- Warlock
  if (SMARTBUFF_PLAYERCLASS == "WARLOCK") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_DEMONARMOR, 30, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DEMONSKIN, 30, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SOULLINK, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_LOCKSENSEDEMONS, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_UNENDINGBREATH, 10, SMARTBUFF_CONST_GROUP, {16}, "HPET;WPET"},
      {SMARTBUFF_LOCKLESSERINVIS, 10, SMARTBUFF_CONST_GROUP, {26}, "HPET;WPET"},
      {SMARTBUFF_LOCKINVISIBILITY, 10, SMARTBUFF_CONST_GROUP, {38}, "HPET;WPET"},
      {SMARTBUFF_SUMMONINFERNAL, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONFELHUNTER, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONIMP, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONSUCCUBUS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONINCUBUS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONVOIDWALKER, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_CREATEHS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjureShard, nil, S.ConjuredLockHealthStones},
      {SMARTBUFF_CREATESOULS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjureShard, nil, S.ConjuredLockSoulstones},
      {SMARTBUFF_CREATESPELLS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjureShard, nil, S.ConjuredLockSpellstones},
      {SMARTBUFF_CREATEFIRES, -1, SMARTBUFF_CONST_SELF, nil, S.CheckConjureShard, nil, S.ConjuredLockFirestones},
    };
  end

  -- Rogue
  if (SMARTBUFF_PLAYERCLASS == "ROGUE") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_STEALTH, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLADEFLURRY, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SAD, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_EVASION, 0.2, SMARTBUFF_CONST_SELF},
    };
  end

  -- Stones, oils, poisons
  SMARTBUFF_WEAPON = {
    {SMARTBUFF_SSROUGH, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSCOARSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSHEAVY, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSSOLID, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSDENSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSELEMENTAL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSROUGH, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSCOARSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSHEAVY, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSSOLID, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSDENSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SHADOWOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FROSTOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FIRESLESSER, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FIRESSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FIRESGREATER, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FIRESMAJOR, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SPELLSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SPELLSGREATER, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SPELLSMAJOR, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON6, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_CRIPPLINGPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_CRIPPLINGPOISON2, 60, SMARTBUFF_CONST_INV},
  };

  SMARTBUFF_TRACKING = {
    {SMARTBUFF_FINDMINERALS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_FINDHERBS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_FINDTREASURE, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKHUMANOIDS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKBEASTS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKUNDEAD, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKHIDDEN, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKELEMENTALS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKDEMONS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKGIANTS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKDRAGONKIN, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_FINDMINERALS, -1, SMARTBUFF_CONST_GATHERING},
    {SMARTBUFF_FINDHERBS, -1, SMARTBUFF_CONST_GATHERING},
    {SMARTBUFF_FINDTREASURE, -1, SMARTBUFF_CONST_GATHERING},
  };

  SMARTBUFF_RACIAL = {
    {SMARTBUFF_STONEFORM, 0.133, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_BLOODFURY, 0.416, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_BERSERKING, 0.166, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_WOTFORSAKEN, 0.083, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_WarStomp, 0.033, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_WALKONAIR, 0.166, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_READLEYLINE, 0.25, SMARTBUFF_CONST_SELF},
    {SMARTBUFF_SKYSIGHT, 0.166, SMARTBUFF_CONST_SELF},
  };

  SMARTBUFF_FOOD = {
    {SMARTBUFF_HERBBAKEDEGG, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICEDWOLFMEAT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BEERBASTEDBOARRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRISPYBATWING, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_KALDOREISPIDERKABOB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ROASTEDKODOMEAT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BOILEDCLAMS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_COYOTESTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRABCAKE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_DRYPORKRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BLOODSAUSAGE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CROCOLISKSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_FILLETOFFRENZY, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GORETUSKLIVERPIE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_STRIDERSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GOBLINDEVILEDCLAMS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BIGBEARSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRISPYLIZARDTAIL, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CROCOLISKGUMBO, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CURIOUSLYTASTYOMELET, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GOOEYSPIDERCAKE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HOTLIONCHOPS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_LEANVENISON, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_LEANWOLFSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MURLOCFINSOUP, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_REDRIDGEGOULASH, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SEASONEDWOLFKABOB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CARRIONSURPRISE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ROASTRAPTOR, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GIANTCLAMSCORCHO, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HEAVYCROCOLISKSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HOTWOLFRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_JUNGLESTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MYSTERYSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SOOTHINGTURTLEBISQUE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_TASTYLIONSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPIDERSAUSAGE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HEAVYKODOSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MONSTEROMELET, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICEDCHILICRAB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_TENDERWOLFSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SMOKEDSAGEFISH, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SAGEFISHDELIGHT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_NIGHTFINSOUP, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GRILLEDSQUID, 10, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_RUNNTUMTUBERSURPRISE, 10, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SMOKEDDESERTDUMPLINGS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BARBECUEDBUZZARDWING, 15, SMARTBUFF_CONST_FOOD},
  };

  for _, name in pairs(S.FoodItems) do
    if (name) then
      tinsert(SMARTBUFF_FOOD, 1, {name, 15, SMARTBUFF_CONST_FOOD});
    end
  end

  -- Well Fed food missing from the named list above (Classic + Forever). Item id keeps the row if the name is not cached yet.
  local extraFood = {
    733, 787, 2681, 2682, 2685, 4592, 4593, 4594, 5095, 6290, 6316, 6887, 6890, 8364, 8957, 10841,
    13927, 13929, 13930, 13932, 13933, 13934, 13935, 17197, 17198, 20516, 21023, 21254, 238638,
    248613, 249865, 249866, 249867, 249868, 249870, 249871, 249872, 249873, 249874, 249875, 249876,
    250065, 250066, 250067, 250068, 250069, 250070, 250071, 250072, 250073, 250074, 250075, 250076,
    250077, 250078, 250079, 250080, 263509, 263512, 267341, 274971, 274976, 286152
  };
  for _, itemId in ipairs(extraFood) do
    tinsert(SMARTBUFF_FOOD, { itemId, 15, SMARTBUFF_CONST_FOOD });
  end

  SMARTBUFF_SCROLL = {
    {SMARTBUFF_SOAGILITY4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOINTELLECT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOSTAMINA4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSPIRIT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSTRENGHT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
  };

  SMARTBUFF_POTION = {
    {SMARTBUFF_FLASKCLASSIC1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCLASSIC1, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKCLASSIC2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCLASSIC2, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKCLASSIC3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCLASSIC3, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKCLASSIC4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCLASSIC4, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKNATURAL1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKNATURAL1, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKNATURAL2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKNATURAL2, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKNATURAL3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKNATURAL3, S.LinkFlaskClassic},
    {SMARTBUFF_FLASKNATURAL4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKNATURAL4, S.LinkFlaskClassic},
    {SMARTBUFF_ELIXIR1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR1},
    {SMARTBUFF_ELIXIR15, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR15},
    {SMARTBUFF_ELIXIRGIANTS, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRGIANTS},
    {SMARTBUFF_ELIXIRMONGOOSE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMONGOOSE},
    {SMARTBUFF_ELIXIRMINORARCANE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMINORARCANE},
    {SMARTBUFF_ELIXIRLESSERARCANE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRLESSERARCANE},
    {SMARTBUFF_ELIXIRARCANE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRARCANE},
    {SMARTBUFF_ELIXIRGREATERARCANE, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRGREATERARCANE},
    {SMARTBUFF_ELIXIRBRUTEFORCE, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRBRUTEFORCE},
    {SMARTBUFF_ELIXIRSUPDEF, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRSUPDEF},
    {SMARTBUFF_ELIXIRSAGES, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRSAGES},
    {SMARTBUFF_MAGEBLOODPOTION, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BMAGEBLOODPOTION},
    {SMARTBUFF_LESSERMAGEBLOOD, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BLESSERMAGEBLOOD},
    {SMARTBUFF_GREATERMAGEBLOOD, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGREATERMAGEBLOOD},
    {SMARTBUFF_MAJORTROLLBLOOD, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BMAJORTROLLBLOOD},
    {SMARTBUFF_ELIXIRFORTITUDE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRFORTITUDE},
    {SMARTBUFF_ELIXIRGREATERFORT, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRGREATERFORT},
    {SMARTBUFF_ELIXIRPHALANX, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRPHALANX},
    {SMARTBUFF_ELIXIRWICKEDREGEN, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRWICKEDREGEN},
    {SMARTBUFF_MINORCLERIC, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BMINORCLERIC},
    {SMARTBUFF_LESSERCLERIC, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BLESSERCLERIC},
    {SMARTBUFF_CLERICELIXIR, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BCLERICELIXIR},
    {SMARTBUFF_GREATERCLERIC, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGREATERCLERIC},
    {SMARTBUFF_ELIXIRNATUREPOWER, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRNATUREPOWER},
    {SMARTBUFF_ELIXIRCUNNING, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCUNNING},
    {SMARTBUFF_ELIXIRFEROCITY, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRFEROCITY},
    {SMARTBUFF_ELIXIRGREATERSPIRIT, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRGREATERSPIRIT},
    {SMARTBUFF_ELIXIRGRIZZLY, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRGRIZZLY},
    {SMARTBUFF_ELIXIRLESSERINT, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRLESSERINT},
    {SMARTBUFF_ELIXIRLESSERSPIRIT, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRLESSERSPIRIT},
    {SMARTBUFF_ELIXIROWL, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIROWL},
    {SMARTBUFF_ELIXIRWHALE, 30, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRWHALE},
  };

  -- { itemId, buffSpellId, durationMinutes }. Item id is resolved later to "item:ID".
  -- Stat, regen, armor, and damage buffs only. Instant heals, mana pots, and thrown clouds are omitted.
  local trackedConsumables = {
    {2454, 2367, 60}, {2457, 2374, 60}, {2458, 2378, 60}, {3382, 3219, 60}, {3383, 3166, 60},
    {3388, 3222, 60}, {3389, 3220, 60}, {3390, 3160, 60}, {3391, 3164, 60}, {3825, 3593, 60},
    {3826, 3223, 60}, {5997, 673, 60}, {8410, 10667, 60}, {8411, 10668, 60}, {8412, 10669, 60},
    {8423, 10692, 60}, {8424, 10693, 60}, {8951, 11349, 60}, {9179, 11396, 60},
    {6373, 7844, 30}, {9088, 11371, 30}, {9264, 11474, 30}, {17708, 21920, 30}, {21546, 1310077, 30},
    {217398, 439959, 30}, {247755, 1245249, 30}, {250338, 1250941, 30}, {250339, 1250942, 30},
    {250344, 1250974, 30}, {250346, 1250978, 30}, {250349, 1250984, 30}, {250354, 1250989, 30},
    {12820, 17038, 20}, {246948, 17038, 20}, {6662, 8212, 2}, {9224, 11406, 5},
    {20079, 24382, 120}, {20080, 24417, 120}, {20081, 24383, 120},
    {1450, 806, 1}, {2459, 2379, 0.25}, {3384, 2380, 3}, {3823, 3680, 0.25}, {4623, 4941, 1.5},
    {5634, 6615, 0.5}, {6048, 7242, 2}, {6049, 7233, 2}, {6050, 7239, 2}, {6051, 7245, 2},
    {6052, 7254, 2}, {9030, 11359, 0.5}, {9036, 11364, 3}, {9172, 11392, 0.3}, {13442, 17528, 0.333},
    {13455, 17540, 2}, {13456, 17544, 2}, {13457, 17543, 2}, {13458, 17546, 2}, {13459, 17548, 2},
    {13460, 17545, 2}, {13461, 17549, 2}, {20008, 24364, 0.083},
    {250932, 1251919, 0.5}, {250933, 1251922, 0.5}, {250934, 1251923, 0.5}, {250935, 1251924, 0.5},
    {250936, 1251931, 0.5}, {250937, 1251932, 0.5}, {250938, 1251933, 0.5}, {250939, 1251935, 0.5},
    {250940, 1251936, 0.5}, {250941, 1251937, 0.5}, {250942, 1251938, 0.5}, {250943, 1251940, 0.5},
    {250944, 1251942, 0.5}, {250945, 1251944, 0.5}, {250946, 1251945, 0.5}, {250947, 1251946, 0.5},
    {250948, 1251947, 0.5}, {250949, 1251948, 0.5}, {250950, 1251986, 0.333}, {250954, 1252558, 5},
    {250955, 1252559, 5},
  };
  local linkZanza = { GetSpellInfo(24382), GetSpellInfo(24417), GetSpellInfo(24383) };
  for _, row in ipairs(trackedConsumables) do
    local link = nil;
    if (row[2] == 24382 or row[2] == 24417 or row[2] == 24383) then
      link = linkZanza;
    end
    tinsert(SMARTBUFF_POTION, { row[1], row[3], SMARTBUFF_CONST_POTION, nil, GetSpellInfo(row[2]), link });
  end

  SMARTBUFF_AddMsgD("Spell list initialized");
end
