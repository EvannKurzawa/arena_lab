# Remaining optional PEMK dialogs, including failure and shop paths.
module ArenaDemo::French
  <<~'TRANSLATIONS'.each_line do |line|
This account was just logged in from another window or device, so this one is now offline. Restart the game to play online here. ||| Ce compte est connecté dans une autre fenêtre ou sur un autre appareil. Cette partie passe hors ligne. Redémarrez le jeu pour vous reconnecter ici.
This account is suspended until {1}. ||| Ce compte est suspendu jusqu'au {1}.
This account is suspended. ||| Ce compte est suspendu.
Reason: {1} ||| Motif : {1}
Connection to the server was lost. Your progress is NO LONGER being saved online. Reconnecting... ||| Connexion au serveur perdue. Votre progression n'est plus sauvegardée en ligne. Reconnexion...
Connection restored. Your progress is saving online again. ||| Connexion rétablie. Votre progression est de nouveau sauvegardée en ligne.
Your online session has expired. Please restart the game to log in again. ||| Votre session en ligne a expiré. Redémarrez le jeu pour vous reconnecter.
Debug mode is off on this server. ||| Le mode debug est désactivé sur ce serveur.
Playing OFFLINE — your progress will NOT be saved to the server. ||| Vous jouez hors ligne. Votre progression ne sera pas sauvegardée sur le serveur.
Your online save could not be loaded (version mismatch?). Playing OFFLINE to protect your data — please contact the server operator. ||| Impossible de charger votre sauvegarde en ligne. Les versions sont peut-être incompatibles. Vous jouez hors ligne pour protéger vos données. Contactez le responsable du serveur.
Your online save could not be migrated to this game version. Playing OFFLINE to protect your data. ||| Impossible d'adapter votre sauvegarde en ligne à cette version. Vous jouez hors ligne pour protéger vos données.
Saved on this device, but NOT synced to the server yet. Retrying in the background... ||| Sauvegarde effectuée sur cet appareil. La synchronisation avec le serveur sera réessayée en arrière-plan...
Could not load your online save. Playing OFFLINE to protect your data. ||| Impossible de charger votre sauvegarde en ligne. Vous jouez hors ligne pour protéger vos données.
that email is already registered ||| cette adresse e-mail est déjà utilisée
that email looks invalid ||| cette adresse e-mail semble incorrecte
password needs at least 8 characters ||| le mot de passe doit contenir au moins 8 caractères
this server needs an updated game ||| ce serveur nécessite une version plus récente du jeu
this account was deleted ||| ce compte a été supprimé
this account is suspended until {1} ||| ce compte est suspendu jusqu'au {1}
this account is suspended ||| ce compte est suspendu
no response from the server ||| aucune réponse du serveur
{1} has no Pokémon able to battle! ||| {1} n'a aucun Pokémon en état de combattre !
Your progress is saving online again. ||| Votre progression est de nouveau sauvegardée en ligne.
This save is too large for the server: your progress is only kept on this computer. ||| Cette sauvegarde est trop volumineuse pour le serveur. Votre progression est conservée uniquement sur cet ordinateur.
Your progress could not be saved to the server. Trying again... ||| Impossible de sauvegarder votre progression sur le serveur. Nouvelle tentative...
You are already in a trade. ||| Vous participez déjà à un échange.
Trade with which player? ||| Avec quel joueur souhaitez-vous échanger ?
Trade request sent to {1}... ||| Demande d'échange envoyée à {1}...
{1} declined the trade. ||| {1} refuse l'échange.
Trade error — the offer did not match. Cancelled. ||| Les offres ne correspondent pas. L'échange est annulé.
{1} cancelled the trade. ||| {1} annule l'échange.
The trade with {1} is complete! ||| L'échange avec {1} est terminé !
That Pokémon was caught too recently to trade — please try again shortly. ||| Ce Pokémon a été capturé trop récemment pour être échangé. Réessayez dans un instant.
The trade could not be completed ({1}). ||| Impossible de terminer l'échange ({1}).
{1} wants to trade! Accept? ||| {1} souhaite faire un échange ! Accepter ?
Trade cancelled. ||| Échange annulé.
Trade your {1} for {2}'s {3}? ||| Échanger votre {1} contre le {3} de {2} ?
The trade timed out. ||| Le délai de l'échange est dépassé.
Your Pokémon changed after the trade was locked. Trade cancelled. ||| Votre Pokémon a changé après la validation. L'échange est annulé.
{1} (Egg) ||| {1} (Œuf)
{1} Lv. {2} ||| {1} N. {2}
Offer which Pokémon? ||| Quel Pokémon souhaitez-vous proposer ?
You can't trade an Egg. ||| Vous ne pouvez pas échanger un Œuf.
You can't trade a fused Pokémon. ||| Vous ne pouvez pas échanger un Pokémon fusionné.
This Pokémon isn't registered on the server yet — try again in a moment. ||| Ce Pokémon n'est pas encore enregistré sur le serveur. Réessayez dans un instant.
You can't trade your last able Pokémon. ||| Vous ne pouvez pas échanger votre dernier Pokémon en état de combattre.
{1} arrived from a trade that was cut short. ||| {1} arrive d'un échange interrompu.
World export OK ->\nserver/data/world.json\n\n{1} maps, {2} objects, {3} warps, {4} passgrids, {5} ledge tiles, {6} connections.\n\nCommit it so the server ships a world model. ||| Export du monde réussi :\nserver/data/world.json\n\n{1} cartes, {2} objets, {3} transferts, {4} grilles de passage, {5} rebords, {6} connexions.\n\nAjoutez ce fichier au dépôt pour fournir le monde au serveur.
World export FAILED:\n{1}: {2} ||| Échec de l'export du monde :\n{1} : {2}
PEMK: Export World (Layer A/B) ||| PEMK : exporter le monde (couches A/B)
Write server/data/world.json (objects, passability, warps, spawns, encounters) for the server-side world model. ||| Générer server/data/world.json : objets, passages, transferts, apparitions et rencontres du monde du serveur.
PEMK: Reset facing event (self-switches) ||| PEMK : réinitialiser l'événement en face (interrupteurs locaux)
Turn off self-switches A-D of the event directly in front of the player (re-arm a taken item ball to re-test Layer C). ||| Désactiver les interrupteurs locaux A à D de l'événement en face du joueur pour tester à nouveau un objet ramassé.
No event on or in front of you. Stand ON (item balls you walk onto) or FACE the ball, then use this. ||| Aucun événement à votre position ou devant vous. Placez-vous sur l'objet ou face à lui, puis réessayez.
Reset event(s) {1}. Step off & back on (or face + press A) to re-trigger. ||| Événements {1} réinitialisés. Revenez dessus ou faites-leur face et interagissez pour les déclencher.
PEMK: Reset my pickups (dev) ||| PEMK : réinitialiser mes objets ramassés (développement)
Ask the server to forget this account's taken item balls so they can be picked up again (needs PEMK_ALLOW_PICKUP_RESET=on). ||| Demander au serveur de réinitialiser les objets ramassés par ce compte. Nécessite PEMK_ALLOW_PICKUP_RESET=on.
Not connected — log in to an MMO server first. ||| Vous n'êtes pas connecté. Connectez-vous d'abord à un serveur MMO.
The server does not allow pickup reset. Boot it with PEMK_ALLOW_PICKUP_RESET=on (dev only). ||| Le serveur n'autorise pas cette réinitialisation. Activez PEMK_ALLOW_PICKUP_RESET=on en développement.
Server cleared {1} recorded pickup(s). Reset the balls' self-switches (or new game) and they can be picked up again. ||| Le serveur a réinitialisé {1} objet(s). Réinitialisez leurs interrupteurs locaux ou commencez une nouvelle partie pour les ramasser à nouveau.
Server refused the pickup reset ({1}). ||| Le serveur refuse la réinitialisation des objets ({1}).
No response from the server (timeout). ||| Aucune réponse du serveur dans le délai imparti.
The Item Ball seems to be empty... ||| Cette Poké Ball semble vide...
You already received the {1}. ||| Vous avez déjà reçu {1}.
The server did not confirm this gift. ||| Le serveur n'a pas confirmé ce cadeau.
Sorry, that isn't something I sell. ||| Désolé, je ne vends pas cet objet.
You don't seem to have that. ||| Vous ne semblez pas avoir cet objet.
I'm still waiting to hear back about your last order. Please try again in a moment. ||| J'attends encore la confirmation de votre dernière commande. Réessayez dans un instant.
One moment, please. Try again in a few seconds. ||| Un instant, s'il vous plaît. Réessayez dans quelques secondes.
I'm sorry, I can't buy that back. It came from the Battle Point exchange. ||| Désolé, je ne peux pas racheter un objet obtenu avec des Points de Combat.
I'm sorry, I've bought all I can of those from you today. Please come back tomorrow. ||| Désolé, j'en ai déjà racheté le maximum pour aujourd'hui. Revenez demain.
The shop can't reach the server right now. Please try again. ||| La boutique ne peut pas joindre le serveur actuellement. Réessayez.
Sorry, I can't do that right now. ||| Désolé, ce n'est pas possible actuellement.
The shop confirmed your purchase: {1} x{2}. ||| La boutique confirme votre achat : {1} x{2}.
The shop confirmed your sale: {1} x{2}. ||| La boutique confirme votre vente : {1} x{2}.
So you want the {1}?\nIt'll be ${2}. All right? ||| Vous voulez {1} ?\nCela coûte {2} $. D'accord ?
So you want {1} {2}?\nThey'll be ${3}. All right? ||| Vous voulez {1} {2} ?\nCela coûte {3} $. D'accord ?
So you want {1} {2}?\nIt'll be ${3}. All right? ||| Vous voulez {1} {2} ?\nCela coûte {3} $. D'accord ?
I can pay ${1}.\nWould that be OK? ||| Je peux vous proposer {1} $.\nCela vous convient ?
You would like the {1}?\nThat will be {2} BP. ||| Vous voulez {1} ?\nCela coûte {2} PC.
You would like {1} {2}?\nThey'll be {3} BP. ||| Vous voulez {1} {2} ?\nCela coûte {3} PC.
So you want {1} {2}?\nIt'll be {3} BP. ||| Vous voulez {1} {2} ?\nCela coûte {3} PC.
Battle data export OK ->\nserver/data/battle_data.json\n\n{1} species/forms, {2} moves, {3} items. ||| Export des données de combat réussi :\nserver/data/battle_data.json\n\n{1} espèces/formes, {2} attaques, {3} objets.
Battle data export FAILED:\n{1}: {2} ||| Échec de l'export des données de combat :\n{1} : {2}
PEMK: Export Battle Data (Layer D) ||| PEMK : exporter les données de combat (couche D)
Write server/data/battle_data.json (species stats/learnsets, moves, items, type chart, natures, caps) for the server-side battle model. ||| Générer server/data/battle_data.json : statistiques, attaques, objets, types, natures et limites pour les combats du serveur.
I'm sorry, I'm not buying cards on this server. ||| Désolé, je ne rachète pas de cartes sur ce serveur.
TRANSLATIONS
    original, translated = line.chomp.split(" ||| ", 2)
    next unless translated
    TEXT[original] = translated
    TEXT[original.gsub('\\n', "\n")] = translated.gsub('\\n', "\n")
  end
end
