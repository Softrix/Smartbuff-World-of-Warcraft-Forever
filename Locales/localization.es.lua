-------------------------------------------------------------------------------
-- Spanish localization
-------------------------------------------------------------------------------

if (GetLocale() ~= "esES" and GetLocale() ~= "esMX") then return; end

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n|cffffffff         Novedades:|r\n\n"
  .."          Cambios en r1.041126:\n\n"
  .."             * Lanzamiento público de World of Warcraft: Forever.\n"
  .."\n\n\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Forever & Classic por Codermik, MrWizard &\n"
  .."Speedwaystar. Únete y obtén soporte\n"
  .."en mi servidor de Discord:\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffSi quieres apoyar el desarrollo de este addon, descarga siempre desde Curse o usa uno de estos enlaces:\n\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
  .."|cffffffffAutor original: Aeldra|r (EU-Proudmoore)\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Dagas", "Hachas", "Espadas", "Mazas", "Bastones", "Armas de puño", "Armas de asta", "Armas arrojadizas", "Ballestas", "Arcos", "Escudos", "Armas de fuego"};
SMARTBUFF_WEAPON_BLUNT = {"Mazas", "Bastones", "Armas de puño"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "Piedra de peso$";
SMARTBUFF_WEAPON_SHARP = {"Dagas", "Hachas", "Espadas", "Armas de asta"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "Piedra de afilar$";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoide";
SMARTBUFF_DEMON     = "Demonio";
SMARTBUFF_BEAST     = "Bestia";
SMARTBUFF_ELEMENTAL = "Elemental";
SMARTBUFF_DEMONTYPE = "Diablillo";
SMARTBUFF_UNDEAD    = "No-muerto";

-- Classes (Forever / Classic Era)
SMARTBUFF_CLASSES = {"Druida", "Cazador", "Mago", "Paladín", "Sacerdote", "Pícaro", "Chamán", "Brujo", "Guerrero", "Mascota de cazador", "Mascota de brujo", "Tanque", "Sanador", "DPS"};

-- Templates: generics + instances + custom. Assembled into SMARTBUFF_TEMPLATES at load (SmartBuff.lua).
-- GENERICS: Enum.SmartBuffGroup (SmartBuff.lua) matches this order. Do not reorder or add/remove without updating both.
SMARTBUFF_TEMPLATES_GENERICS = {"Solo", "Grupo", "LFG", "Banda", "Campo de batalla", "Arena"};
-- INSTANCES: Must match GetInstanceInfo() / GetRealZoneText() name exactly (localized).
-- Classic Era raids + Forever raids (no TBC).
SMARTBUFF_TEMPLATES_INSTANCES = {
  "Núcleo de Magma",
  "Guarida de Onyxia",
  "Zul'Gurub",
  "Guarida de Alanegra",
  "Ruinas de Ahn'Qiraj",
  "Templo de Ahn'Qiraj",
  "Naxxramas",
  "The Barrow Deeps",
  "Hyjal Summit",
};
SMARTBUFF_TEMPLATES_CUSTOM = {"Personalizado 1", "Personalizado 2", "Personalizado 3", "Personalizado 4", "Personalizado 5"};

-- Mount
SMARTBUFF_MOUNT = "Aumenta la velocidad un (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d c";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Activar";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Objetivo";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Menú de opciones";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Reiniciar temporizadores de buff";

-- Options Frame Text

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF        = "Corregir lanzamiento"
SMARTBUFF_OFTT_FIXBUFF       = "Activado por defecto. Hace que el botón de acción de SmartBuff responda\ncorrectamente a clics, macros y rueda sin cambiar la CVar global\nActionButtonUseKeyDown (usa el atributo useOnKeyDown del botón).\nEl buffeo en combate puede seguir limitado mientras esté activo."

SMARTBUFF_OFT                = "SmartBuff Activar/Desactivar";
SMARTBUFF_OFT_MENU           = "Mostrar/ocultar menú de opciones";
SMARTBUFF_OFT_AUTO           = "Recordatorio";
SMARTBUFF_OFT_AUTOTIMER      = "Temporizador de comprobación";
SMARTBUFF_OFT_AUTOCOMBAT     = "en combate";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Sonido";
SMARTBUFF_OFT_SELECTSOUND    = "Seleccionar sonido";
SMARTBUFF_OFT_AUTOREST       = "Desactivar en ciudades";
SMARTBUFF_OFT_HUNTERPETS     = "Buffear mascotas de cazador";
SMARTBUFF_OFT_WARLOCKPETS    = "Buffear mascotas de brujo";
SMARTBUFF_OFT_ARULES         = "Reglas avanzadas";
SMARTBUFF_OFT_BUFFS          = "Buffs/Habilidades";
SMARTBUFF_OFT_TARGET         = "Buffea el objetivo seleccionado";
SMARTBUFF_OFT_DONE           = "Cerrar";
SMARTBUFF_OFT_APPLY          = "Aplicar";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Tamaño de clase";
SMARTBUFF_OFT_MESSAGES       = "Desactivar mensajes";
SMARTBUFF_OFT_MSGNORMAL      = "normal";
SMARTBUFF_OFT_MSGWARNING     = "aviso";
SMARTBUFF_OFT_MSGERROR       = "error";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Ocultar botón del minimapa";
SMARTBUFF_OFT_INCLUDETOYS    = "Incluir juguetes";
SMARTBUFF_OFT_REBUFFTIMER    = "Temporizador de rebuff";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Cambiar plantilla";
SMARTBUFF_OFT_SELFFIRST      = "Yo primero";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Buff al desplazar arriba";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "abajo";
SMARTBUFF_OFT_SCROLLZOOMING  = "Zoom";
SMARTBUFF_OFT_TARGETSWITCH   = "cambio de objetivo";
SMARTBUFF_OFT_BUFFTARGET     = "Buffear objetivo";
SMARTBUFF_OFT_BUFFPVP        = "Buffear JcJ";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instancias";
SMARTBUFF_OFT_CHECKCHARGES   = "Comprobar cargas";
SMARTBUFF_OFT_RBT            = "Reiniciar temporizadores";
SMARTBUFF_OFT_BUFFINCITIES   = "Buffear en ciudades";
SMARTBUFF_OFT_BLDURATION     = "Bloqueado";
SMARTBUFF_OFT_ANTIDAZE       = "Anti aturdimiento";
SMARTBUFF_OFT_HIDESABUTTON   = "Ocultar botón de acción";
SMARTBUFF_OFT_HIDEIFIDLE     = "Ocultar si inactivo";
SMARTBUFF_OFT_RETAINTEMPLATE = "Conservar";
SMARTBUFF_OFT_INCOMBAT       = "en combate";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Forma";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Enlace de grupo";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Enlace propio";
SMARTBUFF_OFT_RESETALL       = "Reiniciar todo";
SMARTBUFF_OFT_RESETLIST      = "Reiniciar lista";
SMARTBUFF_OFT_RESETBUFFS     = "Reiniciar buffs";
SMARTBUFF_OFT_NEWS           = "Cambios";
SMARTBUFF_OFT_PURGE_BUFFS    = "Nueva versión, ¿reiniciar TODOS los datos de buff de SmartBuff?\n¡Esto reiniciará todos los perfiles de buff!";
SMARTBUFF_OFT_YES            = "Sí";
SMARTBUFF_OFT_NO             = "No";
SMARTBUFF_OFT_OKAY           = "Continuar"
SMARTBUFF_OFT_PURGE_DATA     = "Nueva versión, ¿reiniciar TODOS los datos de SmartBuff?\n¡Esta acción forzará una recarga de la UI!";
SMARTBUFF_OFT_REQ_RELOAD     = "Las nuevas versiones requieren recargar la interfaz.\nHaz clic en Continuar cuando estés listo.";
SMARTBUFF_OFT_SPLASHICON     = "Mostrar icono";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Mensaje corto";
SMARTBUFF_OFT_FONTSTYLE      = "Fuente";
SMARTBUFF_OFT_FONTSIZE       = "Tamaño de fuente";
SMARTBUFF_OFT_ICONSIZE       = "Tamaño de icono";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Activa/desactiva SmartBuff";
SMARTBUFF_OFTT_RBT           = "Reiniciar temporizadores: solo borra temporizadores de buff (runtime; sin vars guardadas).";
SMARTBUFF_OFTT_RESETALL      = "Reiniciar todo: borra todo (perfiles + opciones). Requiere ReloadUI.";
SMARTBUFF_OFTT_RESETBUFFS    = "Reiniciar buffs: restablece buffs y perfiles a los valores por defecto.";
SMARTBUFF_OFTT_RESETLIST     = "Reiniciar lista: solo reinicia el orden de buffs.";
SMARTBUFF_OFTT_DONE          = "Cerrar opciones.";
SMARTBUFF_OFTT_NEWS          = "Ver notas de la versión y registro de cambios.";
SMARTBUFF_OFTT_HELPLATE_RESET = "Botones de reinicio (pasa el ratón para detalles)";
SMARTBUFF_OFTT_AUTO          = "Activa/desactiva el recordatorio de buff";
SMARTBUFF_OFTT_AUTOTIMER     = "Retraso en segundos entre dos comprobaciones.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Ejecutar la comprobación también en combate.\nToda la lógica de recordatorio se desactiva en combate a menos que la opción principal «en combate» (en el marco de opciones, no esta) esté activada.";
SMARTBUFF_OFTT_AUTOCHAT      = "Muestra los buffs faltantes como mensaje de chat.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Muestra los buffs faltantes como mensaje splash\nen el centro de la pantalla.";
SMARTBUFF_OFTT_AUTOSOUND     = "Reproduce un sonido si faltan buffs.";
SMARTBUFF_OFTT_AUTOREST      = "Desactivar recordatorio en capitales";
SMARTBUFF_OFTT_HUNTERPETS    = "Buffear también las mascotas de cazador.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Buffear también las mascotas de brujo, excepto el " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "No lanza:\n- Espinas en Magos, Sacerdotes y Brujos\n- Intelecto Arcano en unidades sin maná\n- Espíritu divino en unidades sin maná";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Oculta el botón de SmartBuff del minimapa.";
SMARTBUFF_OFTT_INCLUDETOYS   = "Incluir juguetes en la lista junto a hechizos y comida.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Cuántos segundos antes de que expire un buff\ndebe avisarte el recordatorio.\n0 = Desactivado";
SMARTBUFF_OFTT_SELFFIRST     = "Buffea primero a tu personaje.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Lanzar buffs al girar la\nrueda hacia adelante.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Lanzar buffs al girar la\nrueda hacia atrás.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Si está activado, siempre hace zoom al buffear con la rueda.\nSi está desactivado (por defecto), solo hace zoom cuando no queda nada que buffear\n(la rueda sigue buffeando; los scrolls vacíos hacen zoom normal).";
SMARTBUFF_OFTT_TARGETSWITCH  = "Lanzar buffs al cambiar de objetivo.";
SMARTBUFF_OFTT_BUFFTARGET    = "Buffea primero el objetivo actual,\nsi es amistoso.";
SMARTBUFF_OFTT_BUFFPVP       = "Buffea a jugadores marcados JcJ,\naunque tú no lo estés.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Cambia automáticamente la plantilla según el tipo de grupo/instancia:\nSolo, Grupo (también mazmorras de 5), Banda, Campo de batalla, Arena.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "También cambia a una plantilla de banda con nombre al\nentrar en esa instancia (debe coincidir con el nombre de GetInstanceInfo).";
SMARTBUFF_OFTT_CHECKCHARGES  = "Muestra una cantidad baja de\ncargas en un buff.\n0 = Desactivado";
SMARTBUFF_OFTT_BUFFINCITIES  = "Buffea también en capitales.\nSi estás marcado JcJ, buffea en cualquier caso.";
SMARTBUFF_OFTT_BLDURATION    = "Cuántos segundos permanecerán bloqueados los jugadores.\n0 = Desactivado";
SMARTBUFF_OFTT_ANTIDAZE      = "Cancela automáticamente el\naspecto del guepardo/manada\nsi alguien queda aturdido\n(tú o el grupo).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Cambia el estilo de fuente de\nlos mensajes de buff.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Oculta el botón de acción de SmartBuff.";
SMARTBUFF_OFTT_HIDEIFIDLE    = "Ocultar el botón de acción cuando no hay nada en cola; mostrarlo cuando haya un buff pendiente.";
SMARTBUFF_OFTT_RETAINTEMPLATE = "Al cambiar a una plantilla nueva (nunca usada o sin buffs activados),\nse copiarán los ajustes de buff actuales si está marcado.\nLas plantillas vacías nunca se sobrescriben, así no borras una plantilla configurada por accidente.";
SMARTBUFF_OFTT_INCOMBAT      = "Los buffs marcados En combate (en opciones por buff) se lanzan **UNA VEZ** en\nsecuencia de mejor esfuerzo — al entrar en combate, y otra vez tras resurrección en combate si sigues luchando.\n¡La lógica normal de buff está desactivada en combate!\nNo añadas hechizos con tiempo de reutilización: rompen la secuencia.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Muestra el marco SmartDebuff.";
SMARTBUFF_OFTT_SPLASHDURATION= "Cuántos segundos se muestra el mensaje splash\nantes de desvanecerse.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Lanzar buffs también si estás\nen forma cambiada.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Comprueba si un buff de otra\nclase con efecto similar\nya está activo.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Comprueba si un buff propio está activo,\ndel que solo uno puede estar\nactivo a la vez.";
SMARTBUFF_OFTT_SOUNDSELECT   = "Selecciona el sonido de recordatorio splash.\nIncluye sonidos de SmartBuff y cualquier sonido\nregistrado vía LibSharedMedia (p. ej. de otros addons).";
SMARTBUFF_OFTT_PLAYSOUND     = "Controlado por el volumen de efectos de sonido.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Solo yo";
SMARTBUFF_BST_SELFNOT        = "Yo no";
SMARTBUFF_BST_COMBATIN       = "En combate";
SMARTBUFF_BST_COMBATOUT      = "Fuera de combate";
SMARTBUFF_BST_MAINHAND       = "Mano principal";
SMARTBUFF_BST_OFFHAND        = "Mano secundaria";
SMARTBUFF_BST_RANGED         = "A distancia";
SMARTBUFF_BST_REMINDER       = "Notificación";
SMARTBUFF_BST_MANALIMIT      = "Límite inferior";
SMARTBUFF_BST_SKIPBGRES      = "Excluir en CB";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Buffea solo a tu personaje.";
SMARTBUFF_BSTT_SELFNOT       = "Buffea todas las demás clases seleccionadas,\nexcepto tu personaje.";
SMARTBUFF_BSTT_SINGLETARGET  = "Para buffs de un solo objetivo (Escudo de tierra, Piedra de alma, etc.), prioriza el filtro de rol (p. ej. TANQUE) sobre la clase.";
SMARTBUFF_BSTT_COMBATIN      = "Incluir este buff en la secuencia en combate (solo si la opción principal en combate está activa).\nEvita hechizos con reutilización: rompen la secuencia.";
SMARTBUFF_BSTT_COMBATOUT     = "Buffea si estás fuera de combate.";
SMARTBUFF_BSTT_MAINHAND      = "Buffea la mano principal.";
SMARTBUFF_BSTT_OFFHAND       = "Buffea la mano secundaria.";
SMARTBUFF_BSTT_RANGED        = "Buffea la ranura a distancia.";
SMARTBUFF_BSTT_REMINDER      = "Mostrar mensaje de recordatorio.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Cuántos segundos antes de que expire un buff\ndebe avisarte el recordatorio.\n0 = temporizador de rebuff global";
SMARTBUFF_BSTT_MANALIMIT     = "Umbral de maná/ira/energía.\nPor debajo de este valor no lanzará el buff.";
SMARTBUFF_BSTT_SKIPBGRES    = "Si está marcado, este hechizo no se añade a la cola tras resurrección en Campo de batalla o Arena.";
SMARTBUFF_BSTT_ADDLIST       = "Lista adicional: añade jugadores que deben recibir este buff aunque no coincidan con el filtro de clase/rol. Apunta a un miembro del grupo/banda y haz clic en + para añadir.";
SMARTBUFF_BSTT_IGNORELIST    = "Lista de ignorados: excluye jugadores de este buff aunque coincidan con el filtro de clase/rol. Apunta a un miembro del grupo/banda y haz clic en + para añadir.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Minimizar/maximizar\nel marco de opciones principal";
SMARTBUFF_PSTT_ADD           = "Añadir tu objetivo actual a esta lista. El objetivo debe estar en tu grupo o banda.";
SMARTBUFF_PSTT_REMOVE        = "Quitar al jugador seleccionado de esta lista.";
SMARTBUFF_PSTT_UP            = "Subir la selección en la lista.";
SMARTBUFF_PSTT_DOWN          = "Bajar la selección en la lista.";
SMARTBUFF_PSTT_CLEAR         = "Borrar todas las entradas de esta lista.";

-- Group Buff Help (INFO button)
SMARTBUFF_GROUPBUFFHELP_TT   = "Abrir ayuda de configuración de buffs de grupo";
SMARTBUFF_GROUPBUFFHELP      = "|cffffffffConfiguración de buffs de grupo|r\n\n"
  .."|cffffffffRol vs Clase|r\n"
  .."La clase es lo que alguien es (Guerrero, Mago, Sacerdote, etc.). El rol es lo que hace (Tanque, Sanador, Daño).\n\n"
  .."|cffffffffBuffs de un solo objetivo|r\n"
  .."Algunos buffs (Escudo de tierra, Piedra de alma, etc.) solo pueden estar en una persona a la vez. SmartBuff los marca como de un solo objetivo.\n\n"
  .."El buff no salta mientras cualquier miembro elegible del grupo tenga tu buff. Cuando alguien elegible lo tiene, SmartBuff lo deja hasta que expire o se vaya. Prefiere rol (p. ej. Tanque) a clase para estos buffs.\n\n"
  .."|cffffffffListas adicional e ignorados|r\n"
  .."Estas listas anulan clase/rol. Apunta a un miembro del grupo o banda y haz clic en + para añadir. Selecciona una entrada y - para quitar. Haz clic en c para vaciar la lista.\n\n"
  .."Lista adicional: buffea a estos jugadores (o PNJ) aunque no coincidan con las casillas de clase/rol.\n"
  .."Lista de ignorados: no buffees a estos jugadores aunque coincidan. Las listas tienen prioridad sobre las casillas.\n\n"
  .."|cffffffffDebes seleccionar algo|r\n"
  .."Al menos una casilla de clase o rol debe estar marcada. Si no, el buff no irá a nadie (salvo que estén en la lista adicional).\n\n"
  .."|cffffffffLos roles solo importan en grupos|r\n"
  .."Los filtros Tanque, Sanador y Daño solo aplican en grupo o banda. En solitario no tienen efecto.";

-- Messages
SMARTBUFF_MSG_LOADED         = "cargado. Informa de problemas en Curse o únete a Discord: discord.gg/R6EkZ94TKK.";
SMARTBUFF_NOTINTENDEDCLIENT  = "Esta versión Forever de SmartBuff no está pensada para este cliente. Usa el paquete Classic Era / Retail correspondiente.";
SMARTBUFF_MSG_NEWVER1        = "|cff00e0ffSmartbuff : |cffffffff Hay una nueva versión disponible, estás usando |cffFFFF00";
SMARTBUFF_MSG_NEWVER2        = "|cffffffff y revisión |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3        = "|cffffffff está disponible para descargar. Únete a Discord para toda la información: https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "¡SmartBuff está desactivado!";
SMARTBUFF_MSG_SUBGROUP       = "Te has unido a un nuevo subgrupo, ¡comprueba las opciones!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nada que hacer";
SMARTBUFF_MSG_BUFFED         = "buffeado";
SMARTBUFF_MSG_OOR            = "¡está fuera de alcance para buffear!";
--SMARTBUFF_MSG_CD             = "¡tiene reutilización!";
SMARTBUFF_MSG_CD             = "¡Reutilización global!";
SMARTBUFF_MSG_CHAT           = "¡no es posible en modo chat!";
SMARTBUFF_MSG_SHAPESHIFT     = "¡No se permite lanzar en forma cambiada!";
SMARTBUFF_MSG_NOACTIONSLOT   = "¡necesita una ranura en una barra de acción para funcionar correctamente!";
SMARTBUFF_MSG_GROUP          = "Grupo";
SMARTBUFF_MSG_NEEDS          = "necesita";
SMARTBUFF_MSG_OOM            = "¡No hay suficiente maná/ira/energía!";
SMARTBUFF_MSG_STOCK          = "Existencias actuales de";
SMARTBUFF_MSG_NOREAGENT      = "Sin reagente:";
SMARTBUFF_MSG_BAGSFULL       = "SmartBuff detectó que necesitabas %s pero las bolsas están llenas.";
SMARTBUFF_MSG_DEACTIVATED    = "¡desactivado!";
SMARTBUFF_MSG_REBUFF         = "Rebuff";
SMARTBUFF_MSG_LEFT           = "restante";
SMARTBUFF_MSG_CLASS          = "Clase";
SMARTBUFF_MSG_CHARGES        = "cargas";
SMARTBUFF_MSG_SOUNDS         = "Selección de sonido splash: "
SMARTBUFF_MSG_SPECCHANGED    = "Especialización cambiada (%s), cargando plantillas de buff...";
SMARTBUFF_OFT_TALENTGROUP    = "Grupo de talentos %d / %d";
SMARTBUFF_PA_HINT_WARRIOR    = "Guerrero, una clase de cuerpo a cuerpo que suele necesitar Poderío o Reyes.";
SMARTBUFF_PA_HINT_PALADIN    = "Paladín, según su especialización pueden beneficiarse de cualquiera de tus bendiciones.";
SMARTBUFF_PA_HINT_HUNTER     = "Cazador, una clase de cuerpo a cuerpo que suele necesitar Poderío o Reyes.";
SMARTBUFF_PA_HINT_ROGUE      = "Pícaro, una clase de cuerpo a cuerpo que suele necesitar Poderío o Reyes.";
SMARTBUFF_PA_HINT_PRIEST     = "Sacerdote, los sacerdotes se benefician de Sabiduría o Reyes.";
SMARTBUFF_PA_HINT_SHAMAN     = "Chamán, según su especialización pueden beneficiarse de cualquiera de tus bendiciones.";
SMARTBUFF_PA_HINT_MAGE       = "Mago, normalmente Reyes o Sabiduría.";
SMARTBUFF_PA_HINT_WARLOCK    = "Brujo, normalmente Reyes o Sabiduría.";
SMARTBUFF_PA_HINT_DRUID      = "Druida, según su especialización pueden beneficiarse de cualquiera de tus bendiciones.";
SMARTBUFF_PA_ANNOUNCE_COMBAT = "Anunciar mi bendición en combate";
SMARTBUFF_PA_ANNOUNCE_COMBAT_TT = "En combate, te avisa si tu aura asignada, o la bendición asignada a ti, falta o está a punto de expirar.";
SMARTBUFF_MSG_PVP_PREP_ONLY  = "Por limitación de la API, el buffeo solo funciona durante la preparación y se desactiva cuando empieza la partida.";
-- After next castsequence spell: "Player needs <spell> (in-combat)" — aligns with in-combat option wording. "" = OOC-style only.
SMARTBUFF_MSG_CASTSEQUENCE_SUFFIX = " (en combate)";

-- Support
SMARTBUFF_MINIMAP_TT         = "Clic izquierdo: menú de opciones\nClic derecho: Activar/Desactivar\nMayús-Clic izquierdo: asignaciones de paladín\nAlt-Clic izquierdo: SmartDebuff\nArrastrar: mover botón";
SMARTBUFF_TITAN_TT           = "Clic izquierdo: abrir opciones\nClic derecho: Activar/Desactivar\nAlt-Clic izquierdo: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nClic izquierdo: abrir opciones\nMayús-Clic izquierdo: Activar/Desactivar\nAlt-Clic izquierdo: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Arrastrar Mayús-Clic izquierdo: mover marco\n|cff20d2ff- Botón S -|r\nClic izquierdo: mostrar por clases\nMayús-Clic izquierdo: colores de clase\nAlt-Clic izquierdo: resaltar I/D\n|cff20d2ff- Botón P -|r\nClic izquierdo: ocultar/mostrar mascotas";
