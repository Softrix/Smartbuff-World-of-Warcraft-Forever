-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "frFR") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         Nouveautés :|r\n\n"
  .."          Changements dans r1.041126 :\n\n"
  .."             * Sortie publique de World of Warcraft: Forever.\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic par Codermik, MrWizard &\n"
  .."Speedwaystar. Rejoignez-nous et obtenez de l'aide\n"
  .."via mon serveur Discord :\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffSi vous souhaitez soutenir le développement de cet addon, téléchargez toujours depuis Curse ou utilisez l'un des liens suivants :\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffffAuteur d'origine : Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Dagues", "Haches", "Épées", "Masses", "Bâtons", "Armes de pugilat", "Armes d'hast", "Armes de jet", "Arbalètes", "Arcs", "Boucliers", "Armes à feu"};
SMARTBUFF_WEAPON_BLUNT = {"Masses", "Bâtons", "Armes de pugilat"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "Pierre de lest";
SMARTBUFF_WEAPON_SHARP = {"Dagues", "Haches", "Épées", "Armes d'hast"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "Pierre à aiguiser";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoïde";
SMARTBUFF_DEMON     = "Démon";
SMARTBUFF_BEAST     = "Bête";
SMARTBUFF_ELEMENTAL = "Élémentaire";
SMARTBUFF_DEMONTYPE = "Diablotin";
SMARTBUFF_UNDEAD    = "Mort-vivant";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"Druide", "Chasseur", "Mage", "Paladin", "Prêtre", "Voleur", "Chaman", "Démoniste", "Guerrier", "Familier de chasseur", "Familier de démoniste", "Tank", "Soigneur", "DPS"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"Solo", "Groupe", "LFG", "Raid", "Champ de bataille", "Arène"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "Cœur du Magma",
  "Repaire d'Onyxia",
  "Zul'Gurub",
  "Repaire de l'Aile noire",
  "Ruines d'Ahn'Qiraj",
  "Temple d'Ahn'Qiraj",
  "Naxxramas",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"Perso 1", "Perso 2", "Perso 3", "Perso 4", "Perso 5"};

-- Mount
SMARTBUFF_MOUNT = "Augmente la vitesse de (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d c";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Déclencher";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Cible";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Menu d'options";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Réinitialiser les timers de buff";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "Corriger le lancement"
SMARTBUFF_OFTT_FIXBUFF       = "Activé par défaut. Fait réagir correctement le bouton d'action SmartBuff\naux clics souris, macros et molette sans changer la CVar globale\nActionButtonUseKeyDown (utilise l'attribut useOnKeyDown du bouton).\nLe buff en combat peut rester limité tant que c'est actif."

SMARTBUFF_OFT                = "SmartBuff Marche/Arrêt";
SMARTBUFF_OFT_MENU           = "Afficher/masquer le menu d'options";
SMARTBUFF_OFT_AUTO           = "Rappel";
SMARTBUFF_OFT_AUTOTIMER      = "Intervalle de contrôle";
SMARTBUFF_OFT_AUTOCOMBAT     = "en combat";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Son";
SMARTBUFF_OFT_SELECTSOUND    = "Choisir le son";
SMARTBUFF_OFT_AUTOREST       = "Désactiver en ville";
SMARTBUFF_OFT_HUNTERPETS     = "Buffer les familiers de chasseur";
SMARTBUFF_OFT_WARLOCKPETS    = "Buffer les familiers de démoniste";
SMARTBUFF_OFT_ARULES         = "Règles avancées";
SMARTBUFF_OFT_BUFFS          = "Buffs/Techniques";
SMARTBUFF_OFT_TARGET         = "Buffer la cible sélectionnée";
SMARTBUFF_OFT_DONE           = "Fermer";
SMARTBUFF_OFT_APPLY          = "Appliquer";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Taille de classe";
SMARTBUFF_OFT_MESSAGES       = "Désactiver les messages";
SMARTBUFF_OFT_MSGNORMAL      = "normal";
SMARTBUFF_OFT_MSGWARNING     = "avertissement";
SMARTBUFF_OFT_MSGERROR       = "erreur";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Masquer le bouton de minicarte";
SMARTBUFF_OFT_INCLUDETOYS    = "Inclure les jouets";
SMARTBUFF_OFT_REBUFFTIMER    = "Timer de rebuff";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Changer de modèle";
SMARTBUFF_OFT_SELFFIRST      = "Soi d'abord";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Buffer au scroll haut";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "bas";
SMARTBUFF_OFT_SCROLLZOOMING  = "Zoom";
SMARTBUFF_OFT_TARGETSWITCH   = "changement de cible";
SMARTBUFF_OFT_BUFFTARGET     = "Buffer la cible";
SMARTBUFF_OFT_BUFFPVP        = "Buffer JcJ";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instances";
SMARTBUFF_OFT_CHECKCHARGES   = "Vérifier les charges";
SMARTBUFF_OFT_RBT            = "Réinit. timers";
SMARTBUFF_OFT_BUFFINCITIES   = "Buffer en ville";
SMARTBUFF_OFT_BLDURATION     = "Bloqué";
SMARTBUFF_OFT_ANTIDAZE       = "Anti-étourdissement";
SMARTBUFF_OFT_HIDESABUTTON   = "Masquer le bouton d'action";
SMARTBUFF_OFT_HIDEIFIDLE     = "Masquer si inactif";
SMARTBUFF_OFT_RETAINTEMPLATE = "Conserver";
SMARTBUFF_OFT_INCOMBAT       = "en combat";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Forme";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Lien de groupe";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Lien personnel";
SMARTBUFF_OFT_RESETALL       = "Tout réinitialiser";
SMARTBUFF_OFT_RESETLIST      = "Réinit. liste";
SMARTBUFF_OFT_RESETBUFFS     = "Réinit. buffs";
SMARTBUFF_OFT_NEWS           = "Changements";
SMARTBUFF_OFT_PURGE_BUFFS    = "Nouvelle version, réinitialiser TOUTES les données de buff SmartBuff ?\nCela réinitialisera tous les profils de buff !";
SMARTBUFF_OFT_YES            = "Oui";
SMARTBUFF_OFT_NO             = "Non";
SMARTBUFF_OFT_OKAY           = "Continuer"
SMARTBUFF_OFT_PURGE_DATA     = "Nouvelle version, réinitialiser TOUTES les données SmartBuff ?\nCette action forcera un rechargement de l'UI !";
SMARTBUFF_OFT_REQ_RELOAD     = "Les nouvelles versions nécessitent un rechargement de l'interface.\nCliquez sur Continuer quand vous êtes prêt.";
SMARTBUFF_OFT_SPLASHICON     = "Afficher l'icône";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Message court";
SMARTBUFF_OFT_FONTSTYLE      = "Police";
SMARTBUFF_OFT_FONTSIZE       = "Taille de police";
SMARTBUFF_OFT_ICONSIZE       = "Taille d'icône";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Active/désactive SmartBuff";
SMARTBUFF_OFTT_RBT           = "Réinit. timers : efface uniquement les timers de buff (runtime ; pas de vars sauvegardées).";
SMARTBUFF_OFTT_RESETALL      = "Tout réinitialiser : tout effacer (profils + options). Nécessite ReloadUI.";
SMARTBUFF_OFTT_RESETBUFFS    = "Réinit. buffs : remet buffs et profils aux valeurs par défaut.";
SMARTBUFF_OFTT_RESETLIST     = "Réinit. liste : réinitialise uniquement l'ordre des buffs.";
SMARTBUFF_OFTT_DONE          = "Fermer les options.";
SMARTBUFF_OFTT_NEWS          = "Voir les notes de version et le journal des changements.";
SMARTBUFF_OFTT_HELPLATE_RESET = "Boutons de réinitialisation (survolez pour les détails)";
SMARTBUFF_OFTT_AUTO          = "Active/désactive le rappel de buff";
SMARTBUFF_OFTT_AUTOTIMER     = "Délai en secondes entre deux contrôles.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Exécuter le contrôle aussi en combat.\nToute la logique de rappel est désactivée en combat sauf si l'option principale « en combat » (dans le cadre d'options, pas celle-ci) est activée.";
SMARTBUFF_OFTT_AUTOCHAT      = "Affiche les buffs manquants en message de chat.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Affiche les buffs manquants en message splash\nau centre de l'écran.";
SMARTBUFF_OFTT_AUTOSOUND     = "Joue un son si des buffs manquent.";
SMARTBUFF_OFTT_AUTOREST      = "Désactiver le rappel dans les capitales";
SMARTBUFF_OFTT_HUNTERPETS    = "Buffer aussi les familiers de chasseur.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Buffer aussi les familiers de démoniste, sauf le " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Ne lance pas :\n- Épines sur Mages, Prêtres et Démonistes\n- Intelligence des arcanes sur les unités sans mana\n- Esprit divin sur les unités sans mana";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Masque le bouton SmartBuff de la minicarte.";
SMARTBUFF_OFTT_INCLUDETOYS   = "Inclure les jouets dans la liste avec sorts et nourriture.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Combien de secondes avant l'expiration d'un buff\nle rappel doit vous alerter.\n0 = Désactivé";
SMARTBUFF_OFTT_SELFFIRST     = "Buffer d'abord votre personnage.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Lancer les buffs en faisant\ndéfiler la molette vers l'avant.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Lancer les buffs en faisant\ndéfiler la molette vers l'arrière.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Si activé, zoomer toujours la caméra pendant le buff à la molette.\nSi désactivé (défaut), zoomer seulement quand il n'y a plus rien à buffer\n(la molette buffer toujours ; les scrolls vides zooment normalement).";
SMARTBUFF_OFTT_TARGETSWITCH  = "Lancer les buffs lors d'un changement de cible.";
SMARTBUFF_OFTT_BUFFTARGET    = "Buffer d'abord la cible actuelle,\nsi elle est amicale.";
SMARTBUFF_OFTT_BUFFPVP       = "Buffer les joueurs en mode JcJ,\nmême si vous ne l'êtes pas.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Change automatiquement le modèle selon le type de groupe/instance :\nSolo, Groupe (aussi donjons 5 joueurs), Raid, Champ de bataille, Arène.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Passer aussi à un modèle de raid nommé lorsque vous\nentrez dans cette instance (doit correspondre au nom GetInstanceInfo).";
SMARTBUFF_OFTT_CHECKCHARGES  = "Affiche un faible nombre de\ncharges sur un buff.\n0 = Désactivé";
SMARTBUFF_OFTT_BUFFINCITIES  = "Buffer aussi dans les capitales.\nSi vous êtes en JcJ, buffer dans tous les cas.";
SMARTBUFF_OFTT_BLDURATION    = "Combien de secondes les joueurs restent bloqués.\n0 = Désactivé";
SMARTBUFF_OFTT_ANTIDAZE      = "Annule automatiquement\nl'aspect du guépard/de la meute\nsi quelqu'un est étourdi\n(soi ou groupe).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Change le style de police des\nmessages de buff.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Masque le bouton d'action SmartBuff.";
SMARTBUFF_OFTT_HIDEIFIDLE    = "Masquer le bouton d'action quand rien n'est en file ; l'afficher quand un buff est en attente.";
SMARTBUFF_OFTT_RETAINTEMPLATE = "En passant à un nouveau modèle (jamais utilisé ou aucun buff activé),\nles réglages de buff actuels y seront copiés si coché.\nLes modèles vides ne sont jamais écrasés, vous ne risquez pas d'écraser un modèle configuré.";
SMARTBUFF_OFTT_INCOMBAT      = "Les buffs marqués En combat (dans les options par buff) sont lancés **UNE FOIS** en\nséquence au mieux — au début du combat, et une fois après résurrection de combat si le combat continue.\nLa logique normale de buff est désactivée en combat !\nN'ajoutez pas de sorts avec temps de recharge — ils cassent la séquence.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Affiche le cadre SmartDebuff.";
SMARTBUFF_OFTT_SPLASHDURATION= "Combien de secondes le message splash\nest affiché avant de disparaître.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Lancer aussi les buffs\nen forme changée.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Vérifie si un buff d'une autre\nclasse au effet similaire\nest déjà actif.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Vérifie si un buff personnel est actif,\ndont un seul peut être\nactif à la fois.";
SMARTBUFF_OFTT_SOUNDSELECT   = "Choisir le son de rappel splash.\nInclut les sons SmartBuff fournis et tout son\nenregistré via LibSharedMedia (ex. d'autres addons).";
SMARTBUFF_OFTT_PLAYSOUND     = "Contrôlé par le volume des effets sonores.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Moi uniquement";
SMARTBUFF_BST_SELFNOT        = "Pas moi";
SMARTBUFF_BST_COMBATIN       = "En combat";
SMARTBUFF_BST_COMBATOUT      = "Hors combat";
SMARTBUFF_BST_MAINHAND       = "Main droite";
SMARTBUFF_BST_OFFHAND        = "Main gauche";
SMARTBUFF_BST_RANGED         = "À distance";
SMARTBUFF_BST_REMINDER       = "Notification";
SMARTBUFF_BST_MANALIMIT      = "Seuil bas";
SMARTBUFF_BST_SKIPBGRES      = "Exclure en BG";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Buffer uniquement votre personnage.";
SMARTBUFF_BSTT_SELFNOT       = "Buffer toutes les autres classes sélectionnées,\nsauf votre personnage.";
SMARTBUFF_BSTT_SINGLETARGET  = "Pour les buffs monocible (Bouclier de terre, Pierre d'âme, etc.), préférer le filtre de rôle (ex. TANK) à la classe.";
SMARTBUFF_BSTT_COMBATIN      = "Inclure ce buff dans la séquence en combat (uniquement si l'option principale en combat est activée).\nÉvitez les sorts avec temps de recharge — ils cassent la séquence.";
SMARTBUFF_BSTT_COMBATOUT     = "Buffer hors combat.";
SMARTBUFF_BSTT_MAINHAND      = "Buffer la main droite.";
SMARTBUFF_BSTT_OFFHAND       = "Buffer la main gauche.";
SMARTBUFF_BSTT_RANGED        = "Buffer l'emplacement à distance.";
SMARTBUFF_BSTT_REMINDER      = "Afficher le message de rappel.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Combien de secondes avant l'expiration d'un buff\nle rappel doit vous alerter.\n0 = timer de rebuff global";
SMARTBUFF_BSTT_MANALIMIT     = "Seuil de mana/rage/énergie.\nEn dessous, le buff ne sera pas lancé.";
SMARTBUFF_BSTT_SKIPBGRES    = "Si coché, ce sort n'est pas ajouté à la file après résurrection en Champ de bataille ou Arène.";
SMARTBUFF_BSTT_ADDLIST       = "Liste supplémentaire : ajoutez des joueurs qui doivent recevoir ce buff même s'ils ne correspondent pas au filtre classe/rôle. Ciblez un membre du groupe/raid et cliquez + pour ajouter.";
SMARTBUFF_BSTT_IGNORELIST    = "Liste d'ignore : excluez des joueurs de ce buff même s'ils correspondent au filtre classe/rôle. Ciblez un membre du groupe/raid et cliquez + pour ajouter.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Réduire/agrandir\nle cadre d'options principal";
SMARTBUFF_PSTT_ADD           = "Ajouter votre cible actuelle à cette liste. La cible doit être dans votre groupe ou raid.";
SMARTBUFF_PSTT_REMOVE        = "Retirer le joueur sélectionné de cette liste.";
SMARTBUFF_PSTT_UP            = "Monter la sélection dans la liste.";
SMARTBUFF_PSTT_DOWN          = "Descendre la sélection dans la liste.";
SMARTBUFF_PSTT_CLEAR         = "Effacer toutes les entrées de cette liste.";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "Ouvrir l'aide de configuration des buffs de groupe";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffffConfiguration des buffs de groupe|r\n\n"
  .."|cffffffffRôle vs Classe|r\n"
  .."La classe est ce qu'est quelqu'un (Guerrier, Mage, Prêtre, etc.). Le rôle est ce qu'il fait (Tank, Soigneur, Dégâts).\n\n"
  .."|cffffffffBuffs monocible|r\n"
  .."Certains buffs (Bouclier de terre, Pierre d'âme, etc.) ne peuvent être que sur une personne à la fois. SmartBuff les marque comme monocible.\n\n"
  .."Le buff ne saute pas tant qu'un membre éligible du groupe a déjà votre buff. Une fois qu'un éligible l'a, SmartBuff le laisse jusqu'à expiration ou départ. Préférez le rôle (ex. Tank) à la classe pour ces buffs.\n\n"
  .."|cffffffffListes supplémentaire et d'ignore|r\n"
  .."Ces listes remplacent classe/rôle. Ciblez un membre du groupe ou raid et cliquez + pour ajouter. Sélectionnez une entrée et cliquez - pour retirer. Cliquez c pour vider la liste.\n\n"
  .."Liste supplémentaire : buffer ces joueurs (ou PNJ) même s'ils ne correspondent pas aux cases classe/rôle.\n"
  .."Liste d'ignore : ne pas buffer ces joueurs même s'ils correspondent. Les listes ont priorité sur les cases.\n\n"
  .."|cffffffffVous devez sélectionner quelque chose|r\n"
  .."Au moins une case classe ou rôle doit être cochée. Sinon le buff n'ira à personne (sauf sur la liste supplémentaire).\n\n"
  .."|cffffffffLes rôles ne comptent qu'en groupe|r\n"
  .."Les filtres Tank, Soigneur et Dégâts ne s'appliquent qu'en groupe ou raid. En solo, ils n'ont aucun effet.";

-- Messages
SMARTBUFF_MSG_LOADED         = "chargé. Signalez tout problème sur Curse ou rejoignez Discord : discord.gg/R6EkZ94TKK.";
SMARTBUFF_NOTINTENDEDCLIENT  = "Cette version Forever de SmartBuff n'est pas destinée à ce client. Utilisez le paquet Classic Era / Retail correspondant.";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff Une nouvelle version est disponible, vous utilisez |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff et révision |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff est disponible au téléchargement. Rejoignez Discord pour toutes les infos : https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "SmartBuff est désactivé !";
SMARTBUFF_MSG_SUBGROUP       = "Vous avez rejoint un nouveau sous-groupe, vérifiez les options !";
SMARTBUFF_MSG_NOTHINGTODO    = "Rien à faire";
SMARTBUFF_MSG_BUFFED         = "buffé";
SMARTBUFF_MSG_OOR            = "est hors de portée pour le buff !";
--SMARTBUFF_MSG_CD             = "a un temps de recharge !";
SMARTBUFF_MSG_CD             = "Temps de recharge global !";
SMARTBUFF_MSG_CHAT           = "impossible en mode chat !";
SMARTBUFF_MSG_SHAPESHIFT     = "Lancer un sort n'est pas autorisé en forme changée !";
SMARTBUFF_MSG_NOACTIONSLOT   = "a besoin d'un emplacement dans une barre d'action pour fonctionner correctement !";
SMARTBUFF_MSG_GROUP          = "Groupe";
SMARTBUFF_MSG_NEEDS          = "a besoin de";
SMARTBUFF_MSG_OOM            = "Pas assez de mana/rage/énergie !";
SMARTBUFF_MSG_STOCK          = "Stock actuel de";
SMARTBUFF_MSG_NOREAGENT      = "Plus de réactif :";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff a détecté que vous aviez besoin de %s mais les sacs sont plein.";
SMARTBUFF_MSG_DEACTIVATED    = "désactivé !";
SMARTBUFF_MSG_REBUFF         = "Rebuff";
SMARTBUFF_MSG_LEFT           = "restant";
SMARTBUFF_MSG_CLASS          = "Classe";
SMARTBUFF_MSG_CHARGES        = "charges";
SMARTBUFF_MSG_SOUNDS         = "Sélection du son splash : "
SMARTBUFF_MSG_SPECCHANGED    = "Spécialisation changée (%s), chargement des modèles de buff...";
SMARTBUFF_OFT_TALENTGROUP    = "Groupe de talents %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "Guerrier, une classe de mêlée qui a généralement besoin de Puissance ou des Rois.";
SMARTBUFF_PA_HINT_PALADIN    = "Paladin, selon leur spécialisation ils peuvent profiter de n'importe laquelle de tes bénédictions.";
SMARTBUFF_PA_HINT_HUNTER     = "Chasseur, une classe de mêlée qui a généralement besoin de Puissance ou des Rois.";
SMARTBUFF_PA_HINT_ROGUE      = "Voleur, une classe de mêlée qui a généralement besoin de Puissance ou des Rois.";
SMARTBUFF_PA_HINT_PRIEST     = "Prêtre, les prêtres profitent soit de Sagesse, soit des Rois.";
SMARTBUFF_PA_HINT_SHAMAN     = "Chaman, selon leur spécialisation ils peuvent profiter de n'importe laquelle de tes bénédictions.";
SMARTBUFF_PA_HINT_MAGE       = "Mage, généralement Rois ou Sagesse.";
SMARTBUFF_PA_HINT_WARLOCK    = "Démoniste, généralement Rois ou Sagesse.";
SMARTBUFF_PA_HINT_DRUID      = "Druide, selon leur spécialisation ils peuvent profiter de n'importe laquelle de tes bénédictions.";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "Annoncer ma bénédiction en combat";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "En combat, vous prévient si votre aura assignée, ou la bénédiction qui vous est assignée, est absente ou sur le point d'expirer.";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "En raison d'une limitation de l'API, le buff ne fonctionne que pendant la préparation et est désactivé une fois le match commencé.";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = " (en combat)";

-- Support
SMARTBUFF_MINIMAP_TT         = "Clic gauche : menu d'options\nClic droit : Marche/Arrêt\nShift-Clic gauche : assignations paladin\nAlt-Clic gauche : SmartDebuff\nGlisser : déplacer le bouton";
SMARTBUFF_TITAN_TT           = "Clic gauche : ouvrir les options\nClic droit : Marche/Arrêt\nAlt-Clic gauche : SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nClic gauche : ouvrir les options\nShift-Clic gauche : Marche/Arrêt\nAlt-Clic gauche : SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-Clic gauche glisser : déplacer le cadre\n|cff20d2ff- Bouton S -|r\nClic gauche : afficher par classes\nShift-Clic gauche : couleurs de classe\nAlt-Clic gauche : surligner G/D\n|cff20d2ff- Bouton P -|r\nClic gauche : masquer/afficher les familiers";
