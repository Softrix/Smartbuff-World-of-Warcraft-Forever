-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "deDE") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         Neuigkeiten:|r\n\n"
  .."          Änderungen in r1.041126:\n\n"
  .."             * World of Warcraft: Forever öffentliche Veröffentlichung.\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic von Codermik, MrWizard &\n"
  .."Speedwaystar. Bitte tritt bei und hole dir Support\n"
  .."über meinen Discord-Server:\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffWenn du mich und die Entwicklung dieses Addons unterstützen möchtest, lade bitte immer von Curse herunter oder nutze einen der folgenden Links:\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffffOriginalautor: Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Dolche", "Äxte", "Schwerter", "Streitkolben", "Stäbe", "Faustwaffen", "Stangenwaffen", "Wurfwaffen", "Armbrüste", "Bögen", "Schilde", "Schusswaffen"};
SMARTBUFF_WEAPON_BLUNT = {"Streitkolben", "Stäbe", "Faustwaffen"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "Gewichtstein$";
SMARTBUFF_WEAPON_SHARP = {"Dolche", "Äxte", "Schwerter", "Stangenwaffen"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "Wetzstein$";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoid";
SMARTBUFF_DEMON     = "Dämon";
SMARTBUFF_BEAST     = "Wildtier";
SMARTBUFF_ELEMENTAL = "Elementar";
SMARTBUFF_DEMONTYPE = "Wichtel";
SMARTBUFF_UNDEAD    = "Untoter";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"Druide", "Jäger", "Magier", "Paladin", "Priester", "Schurke", "Schamane", "Hexenmeister", "Krieger", "Jägerhaustier", "Hexenmeisterhaustier", "Tank", "Heiler", "Schadensverursacher"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"Solo", "Gruppe", "LFG", "Schlachtzug", "Schlachtfeld", "Arena"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "Geschmolzener Kern",
  "Onyxias Hort",
  "Zul'Gurub",
  "Pechschwingenhort",
  "Ruinen von Ahn'Qiraj",
  "Tempel von Ahn'Qiraj",
  "Naxxramas",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"Benutzerdefiniert 1", "Benutzerdefiniert 2", "Benutzerdefiniert 3", "Benutzerdefiniert 4", "Benutzerdefiniert 5"};

-- Mount
SMARTBUFF_MOUNT = "Erhöht Tempo um (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d a";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Auslösen";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Ziel";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Optionsmenü";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Buff-Timer zurücksetzen";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "Wirken reparieren"
SMARTBUFF_OFTT_FIXBUFF       = "Standardmäßig aktiviert. Lässt den SmartBuff-Aktionsbutton korrekt\nauf Mausklicks, Makros und Mausrad reagieren, ohne die globale\nActionButtonUseKeyDown-CVar zu ändern (nutzt das Attribut useOnKeyDown des Buttons).\nKampf-Buffen kann damit trotzdem eingeschränkt sein."

SMARTBUFF_OFT                = "SmartBuff An/Aus";
SMARTBUFF_OFT_MENU           = "Optionsmenü zeigen/verbergen";
SMARTBUFF_OFT_AUTO           = "Erinnerung";
SMARTBUFF_OFT_AUTOTIMER      = "Prüfintervall";
SMARTBUFF_OFT_AUTOCOMBAT     = "im Kampf";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Ton";
SMARTBUFF_OFT_SELECTSOUND    = "Ton auswählen";
SMARTBUFF_OFT_AUTOREST       = "In Städten deaktivieren";
SMARTBUFF_OFT_HUNTERPETS     = "Jägerhaustiere buffen";
SMARTBUFF_OFT_WARLOCKPETS    = "Hexenmeisterhaustiere buffen";
SMARTBUFF_OFT_ARULES         = "Erweiterte Regeln";
SMARTBUFF_OFT_BUFFS          = "Buffs/Fähigkeiten";
SMARTBUFF_OFT_TARGET         = "Bufft das ausgewählte Ziel";
SMARTBUFF_OFT_DONE           = "Schließen";
SMARTBUFF_OFT_APPLY          = "Übernehmen";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Klassengröße";
SMARTBUFF_OFT_MESSAGES       = "Meldungen deaktivieren";
SMARTBUFF_OFT_MSGNORMAL      = "normal";
SMARTBUFF_OFT_MSGWARNING     = "Warnung";
SMARTBUFF_OFT_MSGERROR       = "Fehler";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Minimap-Button verbergen";
SMARTBUFF_OFT_INCLUDETOYS    = "Spielzeuge einbeziehen";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff-Timer";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Vorlage wechseln";
SMARTBUFF_OFT_SELFFIRST      = "Zuerst selbst";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Buff bei Mausrad hoch";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "runter";
SMARTBUFF_OFT_SCROLLZOOMING  = "Zoom";
SMARTBUFF_OFT_TARGETSWITCH   = "Zielwechsel";
SMARTBUFF_OFT_BUFFTARGET     = "Ziel buffen";
SMARTBUFF_OFT_BUFFPVP        = "PvP buffen";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instanzen";
SMARTBUFF_OFT_CHECKCHARGES   = "Aufladungen prüfen";
SMARTBUFF_OFT_RBT            = "Timer zurücksetzen";
SMARTBUFF_OFT_BUFFINCITIES   = "In Städten buffen";
SMARTBUFF_OFT_BLDURATION     = "Blockiert";
SMARTBUFF_OFT_ANTIDAZE       = "Anti-Benommenheit";
SMARTBUFF_OFT_HIDESABUTTON   = "Aktionsbutton verbergen";
SMARTBUFF_OFT_HIDEIFIDLE     = "Bei Leerlauf verbergen";
SMARTBUFF_OFT_RETAINTEMPLATE = "Behalten";
SMARTBUFF_OFT_INCOMBAT       = "im Kampf";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Gestaltwandel";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Gruppenverknüpfung";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Selbstverknüpfung";
SMARTBUFF_OFT_RESETALL       = "Alles zurücksetzen";
SMARTBUFF_OFT_RESETLIST      = "Liste zurücksetzen";
SMARTBUFF_OFT_RESETBUFFS     = "Buffs zurücksetzen";
SMARTBUFF_OFT_NEWS           = "Änderungen";
SMARTBUFF_OFT_PURGE_BUFFS    = "Neue Version, ALLE SmartBuff-Buffdaten zurücksetzen?\nDas setzt alle Buff-Profile zurück!";
SMARTBUFF_OFT_YES            = "Ja";
SMARTBUFF_OFT_NO             = "Nein";
SMARTBUFF_OFT_OKAY           = "Weiter"
SMARTBUFF_OFT_PURGE_DATA     = "Neue Version, ALLE SmartBuff-Daten zurücksetzen?\nDies erzwingt ein Neuladen der UI!";
SMARTBUFF_OFT_REQ_RELOAD     = "Neue Versionen erfordern ein Neuladen der GUI.\nKlicke auf Weiter, wenn du bereit bist.";
SMARTBUFF_OFT_SPLASHICON     = "Symbol anzeigen";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Kurze Meldung";
SMARTBUFF_OFT_FONTSTYLE      = "Schriftart";
SMARTBUFF_OFT_FONTSIZE       = "Schriftgröße";
SMARTBUFF_OFT_ICONSIZE       = "Symbolgröße";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Schaltet SmartBuff An/Aus";
SMARTBUFF_OFTT_RBT           = "Timer zurücksetzen: Nur Buff-Timer löschen (Laufzeit; keine gespeicherten Variablen).";
SMARTBUFF_OFTT_RESETALL      = "Alles zurücksetzen: Alles löschen (Profile + Optionen). Erfordert ReloadUI.";
SMARTBUFF_OFTT_RESETBUFFS    = "Buffs zurücksetzen: Buffs und Profile auf Standard zurücksetzen.";
SMARTBUFF_OFTT_RESETLIST     = "Liste zurücksetzen: Nur Buff-Reihenfolge zurücksetzen.";
SMARTBUFF_OFTT_DONE          = "Optionen schließen.";
SMARTBUFF_OFTT_NEWS          = "Versionshinweise und Changelog anzeigen.";
SMARTBUFF_OFTT_HELPLATE_RESET = "Reset-Buttons (Mauszeiger für Details)";
SMARTBUFF_OFTT_AUTO          = "Schaltet die Buff-Erinnerung An/Aus";
SMARTBUFF_OFTT_AUTOTIMER     = "Verzögerung in Sekunden zwischen zwei Prüfungen.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Prüfung auch im Kampf ausführen.\nDie gesamte Erinnerungslogik ist im Kampf deaktiviert, sofern die Hauptoption „im Kampf“ (im Optionsfenster, nicht diese) nicht aktiviert ist.";
SMARTBUFF_OFTT_AUTOCHAT      = "Zeigt fehlende Buffs als Chatnachricht an.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Zeigt fehlende Buffs als Splash-Meldung\nin der Bildschirmmitte an.";
SMARTBUFF_OFTT_AUTOSOUND     = "Spielt einen Ton ab, wenn Buffs fehlen.";
SMARTBUFF_OFTT_AUTOREST      = "Erinnerung in Hauptstädten deaktivieren";
SMARTBUFF_OFTT_HUNTERPETS    = "Bufft auch die Jägerhaustiere.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Bufft auch die Hexenmeisterhaustiere, außer den " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Wirkt nicht:\n- Dornen auf Magier, Priester und Hexenmeister\n- Arkane Intelligenz auf Einheiten ohne Mana\n- Göttlicher Willen auf Einheiten ohne Mana";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Verbirgt den SmartBuff-Minimap-Button.";
SMARTBUFF_OFTT_INCLUDETOYS   = "Spielzeuge neben Zaubern und Essen in die Liste aufnehmen.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Wie viele Sekunden vor dem Ablauf eines Buffs\ndie Erinnerung dich warnen soll.\n0 = Deaktiviert";
SMARTBUFF_OFTT_SELFFIRST     = "Bufft zuerst deinen Charakter.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Bufft, wenn du das Mausrad\nnach vorne drehst.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Bufft, wenn du das Mausrad\nnach hinten drehst.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Wenn aktiviert, zoomt die Kamera immer beim Mausrad-Buffen.\nWenn deaktiviert (Standard), nur zoomen, wenn nichts mehr zu buffen ist\n(Mausrad bufft weiterhin; leere Scrolls zoomen normal).";
SMARTBUFF_OFTT_TARGETSWITCH  = "Bufft beim Wechsel des Ziels.";
SMARTBUFF_OFTT_BUFFTARGET    = "Bufft zuerst das aktuelle Ziel,\nwenn es freundlich ist.";
SMARTBUFF_OFTT_BUFFPVP       = "Bufft PvP-markierte Spieler,\nauch wenn du nicht PvP-markiert bist.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Wechselt die Vorlage automatisch nach Gruppen-/Instanztyp:\nSolo, Gruppe (auch 5er-Dungeons), Schlachtzug, Schlachtfeld, Arena.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Wechselt auch zu einer benannten Raid-Vorlage,\nwenn du diese Instanz betrittst (muss dem GetInstanceInfo-Namen entsprechen).";
SMARTBUFF_OFTT_CHECKCHARGES  = "Zeigt geringe Anzahl von\nAufladungen eines Buffs an.\n0 = Deaktiviert";
SMARTBUFF_OFTT_BUFFINCITIES  = "Bufft auch in Hauptstädten.\nWenn du PvP-markiert bist, wird in jedem Fall gebufft.";
SMARTBUFF_OFTT_BLDURATION    = "Wie viele Sekunden Spieler blockiert bleiben.\n0 = Deaktiviert";
SMARTBUFF_OFTT_ANTIDAZE      = "Bricht automatisch den\nAspekt des Geparden/Rudels ab,\nwenn jemand benommen wird\n(selbst oder Gruppe).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Ändert den Schriftstil der\nBuff-Meldungen.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Verbirgt den SmartBuff-Aktionsbutton.";
SMARTBUFF_OFTT_HIDEIFIDLE    = "Aktionsbutton verbergen, wenn nichts in der Warteschlange ist; anzeigen, wenn ein Buff aussteht.";
SMARTBUFF_OFTT_RETAINTEMPLATE = "Beim Wechsel zu einer neuen Vorlage (noch nie genutzt oder keine Buffs aktiviert)\nwerden die aktuellen Buff-Einstellungen dorthin kopiert, wenn dies aktiviert ist.\nLeere Vorlagen werden nie überschrieben, sodass du eine konfigurierte Vorlage nicht versehentlich überschreibst.";
SMARTBUFF_OFTT_INCOMBAT      = "Als „im Kampf“ markierte Buffs (in den Buff-Optionen) werden **EINMAL** bestmöglich\nals Sequenz gewirkt — beim Kampfbeginn und erneut nach Kampfwiederbelebung, falls noch gekämpft wird.\nNormale Buff-Logik ist im Kampf deaktiviert!\nKeine Kampfzauber mit Abklingzeiten hinzufügen — sie unterbrechen die Sequenz.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Zeigt das SmartDebuff-Fenster.";
SMARTBUFF_OFTT_SPLASHDURATION= "Wie viele Sekunden die Splash-\nMeldung angezeigt wird,\nbevor sie verblasst.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Bufft auch, wenn du\nin Gestaltwandelform bist.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Prüft, ob ein Buff einer anderen\nKlasse mit ähnlichem Effekt\nbereits aktiv ist.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Prüft, ob ein Selbstbuff aktiv ist,\nvon dem nur einer gleichzeitig\naktiv sein kann.";
SMARTBUFF_OFTT_SOUNDSELECT   = "Wähle den Splash-Erinnerungston.\nEnthält gebündelte SmartBuff-Töne und alle Töne,\ndie über LibSharedMedia registriert sind (z. B. von anderen Addons).";
SMARTBUFF_OFTT_PLAYSOUND     = "Gesteuert über die Lautstärke der Soundeffekte.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Nur ich";
SMARTBUFF_BST_SELFNOT        = "Nicht ich";
SMARTBUFF_BST_COMBATIN       = "Im Kampf";
SMARTBUFF_BST_COMBATOUT      = "Außerhalb des Kampfes";
SMARTBUFF_BST_MAINHAND       = "Waffenhand";
SMARTBUFF_BST_OFFHAND        = "Schildhand";
SMARTBUFF_BST_RANGED         = "Wurfwaffe";
SMARTBUFF_BST_REMINDER       = "Benachrichtigung";
SMARTBUFF_BST_MANALIMIT      = "Untere Grenze";
SMARTBUFF_BST_SKIPBGRES      = "In SFs ausschließen";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Bufft nur deinen Charakter.";
SMARTBUFF_BSTT_SELFNOT       = "Bufft alle anderen ausgewählten Klassen,\naußer deinem Charakter.";
SMARTBUFF_BSTT_SINGLETARGET  = "Bei Einzelziel-Buffs (Erdschild, Seelenstein usw.) die Rollenfilter (z. B. TANK) der Klasse vorziehen.";
SMARTBUFF_BSTT_COMBATIN      = "Diesen Buff in die Kampfsequenz aufnehmen (nur wenn die Hauptoption „im Kampf“ an ist).\nZauber mit Abklingzeiten vermeiden — sie unterbrechen die Sequenz.";
SMARTBUFF_BSTT_COMBATOUT     = "Bufft, wenn du außer Kampf bist.";
SMARTBUFF_BSTT_MAINHAND      = "Bufft die Waffenhand.";
SMARTBUFF_BSTT_OFFHAND       = "Bufft die Schildhand.";
SMARTBUFF_BSTT_RANGED        = "Bufft den Distanzslot.";
SMARTBUFF_BSTT_REMINDER      = "Erinnerungsnachricht anzeigen.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Wie viele Sekunden vor dem Ablauf eines Buffs\ndie Erinnerung dich warnen soll.\n0 = globaler Rebuff-Timer";
SMARTBUFF_BSTT_MANALIMIT     = "Mana-/Wut-/Energie-Schwelle.\nUnter diesem Wert wird der Buff nicht gewirkt.";
SMARTBUFF_BSTT_SKIPBGRES    = "Wenn aktiviert, wird dieser Zauber nach Wiederbelebung in Schlachtfeld oder Arena nicht in die Wirkwarteschlange aufgenommen.";
SMARTBUFF_BSTT_ADDLIST       = "Zusatzliste: Spieler hinzufügen, die diesen Buff erhalten sollen, auch wenn sie nicht zum Klassen-/Rollenfilter passen. Ziel einen Gruppen-/Schlachtzugsmitglied und klicke +, um hinzuzufügen.";
SMARTBUFF_BSTT_IGNORELIST    = "Ignorierliste: Spieler von diesem Buff ausschließen, auch wenn sie zum Klassen-/Rollenfilter passen. Ziel einen Gruppen-/Schlachtzugsmitglied und klicke +, um hinzuzufügen.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Hauptoptionsfenster\nminimieren/maximieren";
SMARTBUFF_PSTT_ADD           = "Aktuelles Ziel zu dieser Liste hinzufügen. Ziel muss in Gruppe oder Schlachtzug sein.";
SMARTBUFF_PSTT_REMOVE        = "Ausgewählten Spieler aus dieser Liste entfernen.";
SMARTBUFF_PSTT_UP            = "Auswahl in der Liste nach oben verschieben.";
SMARTBUFF_PSTT_DOWN          = "Auswahl in der Liste nach unten verschieben.";
SMARTBUFF_PSTT_CLEAR         = "Alle Einträge aus dieser Liste löschen.";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "Hilfe zur Gruppenbuff-Konfiguration öffnen";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffffGruppenbuff-Konfiguration|r\n\n"
  .."|cffffffffRolle vs. Klasse|r\n"
  .."Klasse ist, was jemand ist (Krieger, Magier, Priester usw.). Rolle ist, was er tut (Tank, Heiler, Schaden).\n\n"
  .."|cffffffffEinzelziel-Buffs|r\n"
  .."Manche Buffs (Erdschild, Seelenstein usw.) können nur auf einer Person gleichzeitig liegen. SmartBuff markiert diese als Einzelziel.\n\n"
  .."Der Buff springt oder wechselt nicht, solange ein berechtigtes Gruppenmitglied deinen Buff hat. Sobald jemand Berechtigtes ihn hat, lässt SmartBuff ihn, bis er abläuft oder die Person geht. Für diese Buffs Rolle (z. B. Tank) der Klasse vorziehen.\n\n"
  .."|cffffffffZusatz- und Ignorierlisten|r\n"
  .."Diese Listen überschreiben Klasse/Rolle. Ziel ein Gruppen- oder Schlachtzugsmitglied und klicke +, um hinzuzufügen. Eintrag wählen und - zum Entfernen. c löscht die Liste.\n\n"
  .."Zusatzliste: Diese Spieler (oder NPCs) buffen, auch wenn sie nicht zu den Klassen-/Rollenhäkchen passen.\n"
  .."Ignorierliste: Diese Spieler nicht buffen, auch wenn sie passen. Die Listen haben Vorrang vor den Häkchen.\n\n"
  .."|cffffffffDu musst etwas auswählen|r\n"
  .."Mindestens ein Klassen- oder Rollenhäkchen muss gesetzt sein. Sonst geht der Buff an niemanden (außer auf der Zusatzliste).\n\n"
  .."|cffffffffRollen gelten nur in Gruppen|r\n"
  .."Tank-, Heiler- und Schaden-Filter greifen nur in Gruppe oder Schlachtzug. Solo haben sie keine Wirkung.";

-- Messages
SMARTBUFF_MSG_LOADED         = "geladen. Bitte melde Probleme auf Curse oder tritt Discord bei: discord.gg/R6EkZ94TKK.";
SMARTBUFF_NOTINTENDEDCLIENT  = "Diese Forever-Version von SmartBuff ist für diesen Client nicht vorgesehen. Bitte nutze das passende Classic-Era-/Retail-Paket.";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff Eine neue Version ist verfügbar, du verwendest |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff und Revision |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff steht zum Download bereit. Tritt Discord bei für alle aktuellen Infos: https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "SmartBuff ist deaktiviert!";
SMARTBUFF_MSG_SUBGROUP       = "Du bist einer neuen Untergruppe beigetreten, bitte prüfe die Optionen!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nichts zu tun";
SMARTBUFF_MSG_BUFFED         = "gebufft";
SMARTBUFF_MSG_OOR            = "ist außer Reichweite zum Buffen!";
--SMARTBUFF_MSG_CD             = "hat Abklingzeit!";
SMARTBUFF_MSG_CD             = "Globale Abklingzeit!";
SMARTBUFF_MSG_CHAT           = "im Chat-Modus nicht möglich!";
SMARTBUFF_MSG_SHAPESHIFT     = "Wirken in Gestaltwandelform nicht erlaubt!";
SMARTBUFF_MSG_NOACTIONSLOT   = "braucht einen Slot in einer Aktionsleiste, um richtig zu funktionieren!";
SMARTBUFF_MSG_GROUP          = "Gruppe";
SMARTBUFF_MSG_NEEDS          = "braucht";
SMARTBUFF_MSG_OOM            = "Nicht genug Mana/Wut/Energie!";
SMARTBUFF_MSG_STOCK          = "Aktueller Vorrat an";
SMARTBUFF_MSG_NOREAGENT      = "Kein Reagenz mehr:";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff hat erkannt, dass du %s brauchst, aber die Taschen voll sind.";
SMARTBUFF_MSG_DEACTIVATED    = "deaktiviert!";
SMARTBUFF_MSG_REBUFF         = "Rebuff";
SMARTBUFF_MSG_LEFT           = "übrig";
SMARTBUFF_MSG_CLASS          = "Klasse";
SMARTBUFF_MSG_CHARGES        = "Aufladungen";
SMARTBUFF_MSG_SOUNDS         = "Splash-Ton-Auswahl: "
SMARTBUFF_MSG_SPECCHANGED    = "Spezialisierung gewechselt (%s), lade Buff-Vorlagen...";
SMARTBUFF_OFT_TALENTGROUP    = "Talentgruppe %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "Krieger, eine Nahkampfklasse, die üblicherweise Macht oder Könige benötigt.";
SMARTBUFF_PA_HINT_PALADIN    = "Paladin, je nach Spezialisierung können sie von jedem deiner Segen profitieren.";
SMARTBUFF_PA_HINT_HUNTER     = "Jäger, eine Nahkampfklasse, die üblicherweise Macht oder Könige benötigt.";
SMARTBUFF_PA_HINT_ROGUE      = "Schurke, eine Nahkampfklasse, die üblicherweise Macht oder Könige benötigt.";
SMARTBUFF_PA_HINT_PRIEST     = "Priester, Priester profitieren entweder von Weisheit oder Königen.";
SMARTBUFF_PA_HINT_SHAMAN     = "Schamane, je nach Spezialisierung können sie von jedem deiner Segen profitieren.";
SMARTBUFF_PA_HINT_MAGE       = "Magier, üblicherweise Könige oder Weisheit.";
SMARTBUFF_PA_HINT_WARLOCK    = "Hexenmeister, üblicherweise Könige oder Weisheit.";
SMARTBUFF_PA_HINT_DRUID      = "Druide, je nach Spezialisierung können sie von jedem deiner Segen profitieren.";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "Meinen Segen im Kampf ansagen";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "Sagt dir im Kampf Bescheid, wenn deine zugewiesene Aura oder der dir zugewiesene Segen fehlt oder bald ausläuft.";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "Aufgrund einer API-Einschränkung funktioniert Buffen nur in der Vorbereitung und ist nach Matchbeginn deaktiviert.";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = " (im Kampf)";

-- Support
SMARTBUFF_MINIMAP_TT         = "Linksklick: Optionsmenü\nRechtsklick: An/Aus\nShift-Linksklick: Paladin-Zuweisungen\nAlt-Linksklick: SmartDebuff\nZiehen: Button verschieben";
SMARTBUFF_TITAN_TT           = "Linksklick: Optionen öffnen\nRechtsklick: An/Aus\nAlt-Linksklick: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nLinksklick: Optionen öffnen\nShift-Linksklick: An/Aus\nAlt-Linksklick: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S-Button -|r\nLinksklick: Nach Klassen anzeigen\nShift-Linksklick: Klassenfarben\nAlt-Linksklick: L/R hervorheben\n|cff20d2ff- P-Button -|r\nLinksklick: Haustiere ein-/ausblenden";
