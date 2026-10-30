# French presentation only: saved object keys, species IDs and network messages
# retain their original values. Essentials supplies the Pokemon data translations.
module ArenaDemo
  module French
    TEXT = {}
    <<~'TRANSLATIONS'.each_line do |line|
Arena ||| Arène
{1}'s ||| Talent de {1}
Fight ||| Attaque
Bag ||| Sac
Run ||| Fuite
Call ||| Appel
Bait ||| Appât
The opposing {1} ||| Le {1} ennemi
the opposing {1} ||| le {1} ennemi
The wild {1} ||| Le {1} sauvage
the wild {1} ||| le {1} sauvage
The ally {1} ||| Le {1} allié
the ally {1} ||| le {1} allié
{1} used {2}! ||| {1} utilise {2} !
{1} used a {2}. ||| {1} utilise un {2}.
{1} used an {2}. ||| {1} utilise un {2}.
{1} used the move instructed by {2}! ||| {1} utilise l'attaque indiquée par {2} !
{1} fainted! ||| {1} est K.O. !
Arena Village ||| Village Arène
Arena Trainee ||| Apprenti de l'arène
Back ||| Retour
Cancel ||| Annuler
Close ||| Fermer
Done ||| Terminer
Offline ||| Hors ligne
Connected ||| Connecté
Hosting ||| Hébergement
Visiting ||| En visite
Hosting or visiting ||| Hébergement ou visite
Custom mode ||| Personnalisation
Arena visits ||| Visites d'arènes
Host online ||| Héberger en ligne
Find an arena to visit ||| Trouver une arène à visiter
Disconnect ||| Se déconnecter
Request to visit ||| Demander une visite
Leave this visit ||| Quitter cette visite
Open arena to visitors ||| Ouvrir l'arène aux visiteurs
Close arena to visitors ||| Fermer l'arène aux visiteurs
Accept visit request ||| Accepter la visite
Decline visit request ||| Refuser la visite
Players in arena ||| Joueurs dans l'arène
Players in this arena ||| Joueurs dans cette arène
Challenge to battle ||| Proposer un combat
Challenge the sample trainer ||| Affronter l'apprenti
Return to entrance room ||| Retourner dans l'entrée
Add an object ||| Ajouter un objet
Add object ||| Ajouter un objet
Add trainer ||| Ajouter un Dresseur
Remove an object ||| Retirer un objet
Obstacle arrangement ||| Disposition des obstacles
Apply a layout preset ||| Appliquer une disposition
Trainer difficulty ||| Difficulté du Dresseur
Heal my team ||| Soigner mon équipe
Sidelines ||| Sur les côtés
Training ring ||| Cercle d'entraînement
Clear floor ||| Terrain vide
Light training ||| Entraînement léger
Full obstacle course ||| Parcours complet
Beginner (levels 5-6) ||| Débutant (niveaux 5-6)
Standard (levels 8-9) ||| Normal (niveaux 8-9)
Advanced (levels 12-13) ||| Avancé (niveaux 12-13)
Boulder ||| Gros rocher
Rock ||| Rocher
Tree ||| Arbre
Boulder 2 ||| Gros rocher 2
Rock 2 ||| Rocher 2
Tree 2 ||| Arbre 2
Grass ||| Herbe
Concrete / plain ||| Béton / uni
Desert / sand ||| Désert / sable
Ice ||| Glace
Change ground ||| Changer le sol
Change ground type ||| Changer le type de sol
Handle trainers ||| Gérer les Dresseurs
Handle furniture ||| Gérer le mobilier
Make tiles void ||| Créer du vide
Make normal field ||| Créer un terrain normal
Make void ||| Créer du vide
Kick trainer ||| Renvoyer le Dresseur
Remove ||| Retirer
Remove it ||| Retirer
Replace ||| Remplacer
Replace it ||| Remplacer
Arena Furniture ||| Mobilier d'arène
Arena furniture ||| Mobilier d'arène
Recruited Trainers ||| Dresseurs recrutés
Recruited trainers ||| Dresseurs recrutés
Recruit a trainer ||| Recruter un Dresseur
Choose a trainer to recruit ||| Choisissez un Dresseur à recruter
Choose a trainer you own ||| Choisissez un Dresseur recruté
Choose furniture you own ||| Choisissez votre mobilier
Validate edit ||| Valider les modifications
Cancel custom mode ||| Annuler la personnalisation
Validate and save ||| Valider et sauvegarder
Cancel all edits ||| Annuler les modifications
Keep editing ||| Continuer à modifier
Finish custom mode? ||| Terminer la personnalisation ?
What would you like to edit? ||| Que souhaitez-vous modifier ?
Welcome to your arena. What would you like to do? ||| Bienvenue dans votre arène. Que souhaitez-vous faire ?
Choose the ground to paint. ||| Choisissez le sol à appliquer.
Choose a layout preset. ||| Choisissez une disposition prédéfinie.
Choose an obstacle arrangement. ||| Choisissez la disposition des obstacles.
Choose the arena trainer's team level. ||| Choisissez le niveau de l'équipe du Dresseur.
Choose an arena object to add. ||| Choisissez un objet à ajouter.
Choose an object to remove. ||| Choisissez un objet à retirer.
There are no objects to remove. ||| Il n'y a aucun objet à retirer.
No objects selected. ||| Aucun objet sélectionné.
Your team is ready to train again. ||| Votre équipe est prête à reprendre l'entraînement.
You need a Pokemon able to battle first. ||| Il vous faut un Pokémon en état de combattre.
You need a Pokémon able to battle first. ||| Il vous faut un Pokémon en état de combattre.
I'm the arena trainee. Ready for a practice battle? ||| Je suis l'apprenti de l'arène. Prêt pour un combat d'entraînement ?
An obstacle would be placed where you are standing. Step aside and try again. ||| Un obstacle serait placé à votre position. Déplacez-vous puis réessayez.
Customize from the arena menu while it is closed to visitors. ||| Personnalisez l'arène depuis son menu lorsqu'elle est fermée aux visiteurs.
Customize from the arena's pause menu after closing it to visitors. ||| Fermez l'arène aux visiteurs, puis personnalisez-la depuis le menu de pause.
Customization is locked while the arena is open to visitors or an online request is pending. ||| La personnalisation est verrouillée pendant les visites et les demandes en ligne.
Walk through the arena building's entrance to reach the training room. ||| Entrez dans le bâtiment de l'arène pour rejoindre la salle d'entraînement.
Welcome to Arena Village! The marked village building is your arena. Inside, the attendant handles visits and the PC opens Pokemon storage. ||| Bienvenue au Village Arène ! Le bâtiment indiqué est votre arène. À l'intérieur, le responsable gère les visites et le PC donne accès aux Boîtes Pokémon.
ARENA\nThis village building is your training arena. ||| ARÈNE\nCe bâtiment est votre arène d'entraînement.
Leave this visit and return to your own entrance room? ||| Quitter cette visite et retourner dans votre entrée ?
Close your arena with the attendant before returning to town. ||| Fermez votre arène auprès du responsable avant de retourner au village.
Log in to the local server to interact with another player. ||| Connectez-vous au serveur local pour interagir avec un autre joueur.
No other players are in this arena yet. ||| Aucun autre joueur n'est encore dans cette arène.
The connection was lost. Reconnect before sending a battle request. ||| La connexion a été perdue. Reconnectez-vous avant de proposer un combat.
That player has left the arena. ||| Ce joueur a quitté l'arène.
The battle request could not be sent. Check the server connection. ||| Impossible d'envoyer la demande de combat. Vérifiez la connexion au serveur.
The arena could not be opened. Check your connection. ||| Impossible d'ouvrir l'arène. Vérifiez votre connexion.
The close request could not be sent. The arena stays locked until the connection closes or the server confirms. ||| Impossible d'envoyer la demande de fermeture. L'arène reste verrouillée jusqu'à la déconnexion ou la confirmation du serveur.
The visit request could not be sent. Check your connection. ||| Impossible d'envoyer la demande de visite. Vérifiez votre connexion.
The accept action could not be sent. Check your connection. ||| Impossible d'accepter la visite. Vérifiez votre connexion.
The decline action could not be sent. Check your connection. ||| Impossible de refuser la visite. Vérifiez votre connexion.
Use Play-Arena.bat, then ask the entrance attendant to Host online or Find an arena to visit. Each player signs in with their own account. ||| Lancez Play-Arena.bat, puis choisissez Héberger en ligne ou Trouver une arène à visiter auprès du responsable de l'entrée. Chaque joueur utilise son propre compte.
Waiting for the current arena service. Restart the host game and both clients with the latest Arena Lab files. ||| En attente du service d'arène. Redémarrez l'hôte et les deux jeux avec la dernière version d'Arena Lab.
Visit request pending. Waiting for the host. ||| Demande de visite en attente de l'hôte.
Arena customization is locked until the visit closes. ||| La personnalisation est verrouillée jusqu'à la fin de la visite.
Your arena is closed to visitors. ||| Votre arène est fermée aux visiteurs.
Talk to the Arena Guide offline to open Custom mode. The entrance-room attendant handles visits. ||| Parlez au guide hors ligne pour personnaliser l'arène. Le responsable de l'entrée gère les visites.
Would you like me to heal your team? ||| Voulez-vous que je soigne votre équipe ?
Use Play-Arena.bat so the game can manage hosting. ||| Lancez Play-Arena.bat pour activer l'hébergement depuis le jeu.
The host service did not answer. Check tools/runtime/desktop-server logs and try again. ||| Le service d'hébergement ne répond pas. Consultez les journaux desktop-server dans tools/runtime puis réessayez.
Connect from the arena entrance after closing any active visit. ||| Terminez la visite en cours puis connectez-vous depuis l'entrée de l'arène.
The game could not be saved. You remain offline. ||| Impossible de sauvegarder. Vous restez hors ligne.
Not connected. Your game is still offline; your progress has not changed. ||| Connexion non établie. Vous restez hors ligne et votre progression est conservée.
The host does not provide the current arena service. Your game stays offline. ||| Le service d'arène de l'hôte est incompatible. Vous restez hors ligne.
Connected to the arena service. Your character and progress stay on this device. ||| Connexion au service d'arène établie. Votre personnage et votre progression restent sur cet appareil.
The visit is still closing. Please wait and try again. ||| La visite est en cours de fermeture. Patientez puis réessayez.
Offline. Keep playing with the same character and save. ||| Vous êtes hors ligne. Continuez avec le même personnage et la même sauvegarde.
Searching for arenas on your local network... ||| Recherche d'arènes sur le réseau local...
No arena was found. Make sure the host has chosen Host online and both computers are on the same network. ||| Aucune arène trouvée. Vérifiez que l'hôte a choisi Héberger en ligne et que les ordinateurs sont sur le même réseau.
Choose an arena on your network. ||| Choisissez une arène sur votre réseau.
Talk to the attendant in the arena entrance to host, join or go offline. ||| Parlez au responsable de l'entrée pour héberger, rejoindre une partie ou vous déconnecter.
Status: Offline. Connecting keeps your world and character. ||| État : hors ligne. La connexion conserve votre monde et votre personnage.
Wild Pokemon live in the grassy patch just behind me. Catching is available offline. ||| Des Pokémon sauvages vivent dans les hautes herbes derrière moi. Vous pouvez les capturer hors ligne.
Wild Pokemon roam in the grass. Walk into one, or face it and press Confirm, to battle and catch it. ||| Des Pokémon sauvages se promènent dans l'herbe. Approchez-en un ou faites-lui face et appuyez sur Entrée pour le combattre et le capturer.
A cozy village home. The residents are out enjoying the day. ||| Une maison accueillante. Ses habitants profitent de la journée dehors.
Welcome to Arena Village! The stadium is the heart of our town. ||| Bienvenue au Village Arène ! Le stade est le cœur de notre village.
Welcome to Arena Village. Your entrance-room attendant arranges private visits. Wild Pokemon encounters are available offline. ||| Bienvenue au Village Arène. Le responsable de l'entrée organise les visites privées. Les Pokémon sauvages sont disponibles hors ligne.
Our arena began as a meeting place for travelers and their Pokemon. Catch a Rattata, Caterpie or Spearow in the village grass to continue that tradition. ||| Notre arène était un lieu de rencontre pour les voyageurs et leurs Pokémon. Capturez un Rattata, un Chenipan ou un Piafabec dans les herbes du village pour perpétuer cette tradition.
A new partner for your arena! The old keepers carved this promise into the gate: every great arena begins with a friendship. ||| Un nouveau partenaire pour votre arène ! Les anciens gardiens ont gravé cette promesse : toute grande arène commence par une amitié.
Your arena carries the keepers' tradition now. Organize your new partner at the entrance PC, then train together inside. ||| Votre arène perpétue la tradition des gardiens. Préparez votre équipe au PC de l'entrée, puis entraînez-vous ensemble.
Talk to the scout by the grass. Find a partner in the village grass, then come back to me. We are looking for Rattata, Caterpie or Spearow. ||| Parlez à l'éclaireur près des herbes. Capturez un Rattata, un Chenipan ou un Piafabec, puis revenez me voir.
Rest your team before the next expedition? ||| Soigner votre équipe avant la prochaine expédition ?
Recruit a trainer from the arena guide first. ||| Recrutez d'abord un Dresseur auprès du guide de l'arène.
Recruit a trainer first. ||| Recrutez d'abord un Dresseur.
There is no furniture in this Bag pocket. ||| Cette poche du Sac ne contient aucun mobilier.
Remove the occupant or move the arena event before making this tile void. ||| Retirez l'occupant ou déplacez l'événement de l'arène avant de créer du vide ici.
Make this tile a normal field before placing a trainer or furniture. ||| Transformez cette case en terrain normal avant d'y placer un Dresseur ou du mobilier.
Make this tile a normal field before placing an object or trainer. ||| Transformez cette case en terrain normal avant d'y placer un objet ou un Dresseur.
Your arena has reached its furniture capacity. ||| Votre arène a atteint sa capacité maximale de mobilier.
Your arena has reached its trainer capacity. ||| Votre arène a atteint sa capacité maximale de Dresseurs.
You have no more of that item in your Bag. ||| Vous n'avez plus cet objet dans votre Sac.
Replace with which Bag tab? ||| Dans quelle poche du Sac choisir le remplacement ?
Trainers can only be recruited while your arena is offline. ||| Le recrutement est disponible uniquement hors ligne.
You have already recruited every trainer available here. ||| Vous avez déjà recruté tous les Dresseurs disponibles ici.
Custom mode is available only while your arena is offline. ||| La personnalisation est disponible uniquement hors ligne.
Choose a tile with the arrows. Press U to change zoom. Press Enter to choose ground, trainer, or furniture mode, then Enter on tiles to apply it. Press X to leave the mode or finish editing. ||| Choisissez une case avec les flèches. U change le zoom. Entrée choisit le mode sol, Dresseur ou mobilier, puis applique votre choix aux cases. X quitte le mode ou termine les modifications.
This tile can't be edited right now. ||| Cette case ne peut pas être modifiée actuellement.
Edit mode closed. Choose another category with Enter. ||| Mode de modification fermé. Appuyez sur Entrée pour choisir une autre catégorie.
The edit could not be saved. Your previous arena layout was restored. ||| Impossible de sauvegarder les modifications. Votre ancienne disposition a été restaurée.
Arena custom mode saved. ||| Personnalisation de l'arène sauvegardée.
Custom mode cancelled. Your previous arena was restored. ||| Personnalisation annulée. Votre ancienne arène a été restaurée.
Custom mode and trainer recruitment are available offline. I can still heal your team. ||| La personnalisation et le recrutement sont disponibles hors ligne. Je peux toutefois soigner votre équipe.
Place this furniture in your offline arena. ||| Placez ce mobilier dans votre arène hors ligne.
A trainer recruited to your offline arena. ||| Un Dresseur recruté pour votre arène hors ligne.
Void tile. ||| Case vide.
Expedition ||| Expédition
Area chances ||| Probabilités des zones
Return to village ||| Retourner au village
Preparing expedition... ||| Préparation de l'expédition...
Outing finished ||| Expédition terminée
No outings available ||| Aucune expédition disponible
Expeditions are available offline. Disconnect at the arena attendant first. ||| Les expéditions sont disponibles hors ligne. Déconnectez-vous auprès du responsable de l'arène.
Bring an able Pokemon before leaving the village. ||| Emmenez un Pokémon en état de combattre avant de quitter le village.
Return to the village? You keep your Pokemon and items. The next departure creates a new wilderness. ||| Retourner au village ? Vous conservez vos Pokémon et vos objets. Le prochain départ créera de nouvelles terres sauvages.
WILDERNESS EXPEDITIONS\nWalk south through the village gate to explore a new wilderness. Each departure changes the landscape. ||| EXPÉDITIONS SAUVAGES\nFranchissez la porte sud du village pour explorer les terres sauvages. Chaque départ change le paysage.
Each area has up to five local species. Approach visible Pokemon to battle and catch them. Use Expedition in the Space-key pause menu to return home. ||| Chaque zone abrite jusqu'à cinq espèces. Approchez les Pokémon visibles pour les combattre et les capturer. Pour rentrer, choisissez Expédition dans le menu ouvert avec Espace.
These are fixed chances for each of the 15 random sectors, with repeats allowed. The starting sector is always grassland. ||| Ces probabilités s'appliquent à chacun des 15 secteurs aléatoires. Les répétitions sont possibles. Le secteur de départ est toujours une prairie.
You have used your three free outings in the last 24 hours. ||| Vous avez utilisé vos trois expéditions gratuites des dernières 24 heures.
Your outing has ended. You have returned to Arena Village. ||| Votre expédition est terminée. Vous êtes de retour au Village Arène.
Grassland ||| Prairie
Dense Forest ||| Forêt dense
Desert ||| Désert
Volcanic Fields ||| Terres volcaniques
Snow Peaks ||| Sommets enneigés
Lake District ||| Région des lacs
Misty Swamp ||| Marais brumeux
Rocky Canyon ||| Canyon rocheux
Crystal Caverns ||| Cavernes de cristal
Ancient Ruins ||| Ruines anciennes
Flower Meadow ||| Prairie fleurie
Storm Plains ||| Plaines orageuses
Coast and Islands ||| Côte et îles
Bamboo Grove ||| Bambouseraie
Abandoned Power Station ||| Centrale abandonnée
Rookie ||| Débutant
Tactician ||| Tacticien
Oak ||| Chen
Agatha ||| Agatha
Lance ||| Peter
Bruno ||| Aldo
Lorelei ||| Olga
Brock ||| Pierre
Misty ||| Ondine
Surge ||| Major Bob
Sabrina ||| Morgane
Blaine ||| Auguste
Brendan ||| Brice
May ||| Flora
Player ||| Joueur
The host declined the visit request. ||| L'hôte a refusé la demande de visite.
The host is no longer available. ||| L'hôte n'est plus disponible.
The visit request expired. ||| La demande de visite a expiré.
The visit request was cancelled. ||| La demande de visite a été annulée.
Arena request refused. ||| Demande refusée.
Someone is requesting to visit your arena. Talk to the attendant to accept or decline. ||| Un joueur souhaite visiter votre arène. Parlez au responsable pour accepter ou refuser.
Visit request sent. Waiting for the host to accept. ||| Demande de visite envoyée. En attente de l'accord de l'hôte.
Skip intro and start Arena Demo ||| Passer l'introduction et commencer
Play the full intro ||| Jouer l'introduction complète
Arena Entrance ||| Entrée de l'arène
Training Arena ||| Arène d'entraînement
Connect to the game server. ||| Connexion au serveur de jeu.
Log in ||| Se connecter
Create account ||| Créer un compte
Play offline ||| Jouer hors ligne
Enter your email: ||| Saisissez votre adresse e-mail :
Enter your password: ||| Saisissez votre mot de passe :
Enter your email (this is your login): ||| Saisissez votre adresse e-mail (votre identifiant) :
Choose a password (at least 8 characters): ||| Choisissez un mot de passe (8 caractères minimum) :
Confirm your password: ||| Confirmez votre mot de passe :
The passwords did not match. ||| Les mots de passe ne correspondent pas.
Your account is ready. Welcome! ||| Votre compte est prêt. Bienvenue !
Login failed: {1}. ||| Connexion impossible : {1}.
Could not create the account: {1}. ||| Impossible de créer le compte : {1}.
Account created, but automatic login failed — pick "Log in". ||| Compte créé. La connexion automatique a échoué : choisissez Se connecter.
no account with that email ||| aucun compte avec cette adresse e-mail
wrong password ||| mot de passe incorrect
too many attempts, try again later ||| trop de tentatives, réessayez plus tard
too many attempts, wait a moment ||| trop de tentatives, patientez
You are not connected to a server. ||| Vous n'êtes pas connecté à un serveur.
You have no Pokémon able to battle! ||| Aucun de vos Pokémon ne peut combattre !
There are no other players on this map. ||| Aucun autre joueur sur cette carte.
Player {1} ||| Joueur {1}
Challenge which player? ||| Quel joueur voulez-vous affronter ?
Battle request sent to {1}... ||| Demande de combat envoyée à {1}...
{1} declined your battle request. ||| {1} a refusé votre demande de combat.
{1} wants to battle! Accept? ||| {1} souhaite vous affronter ! Accepter ?
Challenge Player ||| Affronter un joueur
TRANSLATIONS
      original, translated = line.chomp.split(" ||| ", 2)
      raise 'Invalid Arena Lab French catalog entry' unless translated
      TEXT[original.gsub('\\n', "\n")] = translated.gsub('\\n', "\n")
    end

    # Templates describe already interpolated UI messages; captures never become
    # code. Replacing at display time preserves saved IDs and multiplayer keys.
    TEMPLATES = [
      [/\AArena layout \((.*?)\)\n(.*)\z/m, 'Disposition de l’arène (\1)\n\2'],
      [/\AStatus: (.*)\z/m, 'État : \1'],
      [/\ASelected: (.*)\z/m, 'Sélection : \1'],
      [/\A(.*) added to your arena layout\.\z/, '\1 ajouté à votre arène.'],
      [/\A(.*) removed from your arena layout\.\z/, '\1 retiré de votre arène.'],
      [/\AThe demo supports up to (\d+) objects\.\z/, 'La démo accepte jusqu’à \1 objets.'],
      [/\ABattle request sent to (.*)\. They must accept in their game window\.\z/, 'Demande de combat envoyée à \1. Ce joueur doit accepter dans son jeu.'],
      [/\AArena on (.*)\z/, 'Arène sur \1'],
      [/\AArena found on (.*)\.\z/, 'Arène trouvée sur \1.'],
      [/\ACould not request hosting: (.*)\z/, 'Hébergement impossible : \1'],
      [/\ACould not find arenas on the local network: (.*)\z/, 'Recherche d’arènes impossible : \1'],
      [/\A(.*) joined your arena staff!\z/, '\1 rejoint votre équipe de Dresseurs !'],
      [/\A(.*) is ready for a practice battle\. Challenge them\?\z/, '\1 est prêt pour un combat d’entraînement. L’affronter ?'],
      [/\AChoose a ground type for tile (.*)\.\z/, 'Choisissez le sol de la case \1.'],
      [/\ARemove an existing (.*)\z/, 'Retirer un élément : \1'],
      [/\ASelect a tile containing a (.*) to remove\.\z/, 'Choisissez une case contenant un élément à retirer : \1.'],
      [/\AThis tile already has (.*)\.\z/, 'Cette case contient déjà un élément : \1.'],
      [/\A(.*) Tile (.*)\.\z/, '\1 Case \2.'],
      [/\AField tile: (.*)\.\z/, 'Sol : \1.'],
      [/\ACustom mode closed safely: (.*)\z/, 'Personnalisation interrompue : \1'],
      [/\AThe expedition could not start: (.*)\z/, 'Impossible de démarrer l’expédition : \1'],
      [/\ACannot read the outing record\. Check your save folder\. (.*)\z/, 'Impossible de lire le registre des expéditions. Vérifiez le dossier de sauvegarde. \1'],
      [/\AOuting: (.*)\z/, 'Expédition : \1'],
      [/\AYou have used your three free outings in the last 24 hours\. Next free outing: (.*)\.\z/, 'Vous avez utilisé vos trois expéditions gratuites des dernières 24 heures. Prochaine expédition gratuite : \1.'],
      [/\A; (\d+) extra\z/, '; \1 supplémentaires'],
      [/\Aplacing (.*)\z/, 'Placement : \1'],
      [/\Aremoving (.*)s\z/, 'Retrait : \1'],
      [/\A(.*)\. Each outing lasts 20 real minutes\. An ongoing battle finishes before you return home\.\z/, '\1. Chaque expédition dure 20 minutes réelles. Un combat en cours se termine avant votre retour.'],
      [/\A(.*)\.\nLeave on a new 20-minute expedition\? Returning home ends this outing\.\z/m, '\1.\nPartir pour une expédition de 20 minutes ? Le retour au village termine cette expédition.'],
      [/\A(.*) - sector (.*)\. Time left: (.*)\.\nThe camp is in sector 2,4\. Clear paths lead to neighboring sectors\.\z/, '\1 - secteur \2. Temps restant : \3.\nLe camp est dans le secteur 2,4. Les chemins relient les secteurs voisins.'],
      [/\APainting (.*)\. Move with the arrows and press Enter on each tile\. Press X to choose another mode\.\z/, 'Sol : \1. Déplacez-vous avec les flèches et appuyez sur Entrée sur chaque case. X change de mode.'],
      [/\A(.*)\. Move with the arrows and press Enter on each tile\. Press X to choose another mode\.\z/, '\1. Déplacez-vous avec les flèches et appuyez sur Entrée sur chaque case. X change de mode.'],
      [/\AAccount #(.*) invited you to their arena\. Talk to the entrance-room attendant within 60 seconds to accept\.\z/, 'Le compte n°\1 vous invite dans son arène. Parlez au responsable de l’entrée sous 60 secondes pour accepter.'],
      [/\A(\d+)\/(\d+) free outings available \(24 hours\)(.*)\z/, '\1/\2 expéditions gratuites disponibles (24 heures)\3']
    ].freeze
    LABEL_PATTERN = Regexp.union(TEXT.keys.select { |key| key.length < 32 && !key.include?("\n") }.sort_by { |key| -key.length }.map { |key| /\b#{Regexp.escape(key)}\b/ })

    def self.text(value)
      return value unless value.is_a?(String)
      return value if value.start_with?('Graphics/', 'Audio/', 'Data/')
      return TEXT[value] if TEXT.key?(value)
      TEMPLATES.each do |pattern, replacement|
        match = pattern.match(value)
        next unless match
        result = replacement.gsub('\\n', "\n").gsub(/\\(\d+)/) { text(match[Regexp.last_match(1).to_i]) }
        # Translate embedded status, biome and object labels without altering IDs.
        return fragments(result)
      end
      fragments(value)
    end

    def self.fragments(value)
      value.split("\n", -1).map do |line|
        TEXT.fetch(line) do
          line.gsub(LABEL_PATTERN) { |key| TEXT[key] }
        end
      end.join("\n")
    end

    module SystemLanguage
      def set_up_system
        super
        $PokemonSystem.language = 0
        MessageTypes.load_message_files('french')
      end
    end

    module MessageWindows
      def pbMessageDisplay(window, message, *args, &block)
        super(window, French.text(message), *args, &block)
      end
      def pbShowCommands(window, commands, *args, &block)
        super(window, commands.map { |command| French.text(command) }, *args, &block)
      end
    end

    module AbilityNames
      def name
        French.core_translation(MessageTypes::ABILITY_NAMES, @real_name, super)
      end
      def description
        French.core_translation(MessageTypes::ABILITY_DESCRIPTIONS, @real_description, super)
      end
    end

    def self.core_translation(section, key, fallback)
      @core ||= File.open('Data/messages_french_core.dat', 'rb') { |file| Marshal.load(file) }
      @core[section]&.fetch(key, fallback) || fallback
    end

    module MapName
      def name; French.text(super); end
    end

    module ItemNames
      def name; French.text(super); end
      def name_plural; French.text(super); end
      def description; French.text(super); end
    end

    module Presentation
      def pbMessage(message, commands = nil, *args, &block)
        super(French.text(message), commands&.map { |text| French.text(text) }, *args, &block)
      end

      def _INTL(message, *args)
        # Match the original engine key first. Replacing words such as Bag in
        # the English key prevents the native French dictionary from finding it.
        French.text(super(message, *args))
      end

      def pbDrawTextPositions(bitmap, positions)
        super(bitmap, positions.map { |row| [French.text(row[0]), *row[1..-1]] })
      end

      def pbDrawShadowText(bitmap, x, y, width, height, text, *args)
        super(bitmap, x, y, width, height, French.text(text), *args)
      end
    end
  end
end
Game.singleton_class.prepend(ArenaDemo::French::SystemLanguage) if defined?(Game)
GameData::MapMetadata.prepend(ArenaDemo::French::MapName) if defined?(GameData::MapMetadata)
GameData::Item.prepend(ArenaDemo::French::ItemNames) if defined?(GameData::Item)
Object.prepend(ArenaDemo::French::Presentation)
Object.prepend(ArenaDemo::French::MessageWindows)
Kernel.singleton_class.prepend(ArenaDemo::French::Presentation)
Kernel.singleton_class.prepend(ArenaDemo::French::MessageWindows)
GameData::Ability.prepend(ArenaDemo::French::AbilityNames) if defined?(GameData::Ability)
