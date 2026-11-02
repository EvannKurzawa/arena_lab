# Offline, tile-by-tile arena editor and its two dedicated Bag pockets.
module ArenaDemo
  FURNITURE_POCKET = 7
  TRAINER_POCKET = 8
  FURNITURE_SLOT_BASE = 200
  TRAINER_SLOT_BASE = 300
  MAX_ARENA_FURNITURE = 80
  MAX_ARENA_TRAINERS = 16
  MAP_WIDTH = 100
  MAP_HEIGHT = 100
  GROUND_FILE = "Data/ArenaDemoGround.txt"
  TILE_EDIT_MIGRATION_VERSION = 1
  INITIAL_FIELD_SIZE = 25
  INITIAL_FIELD_X = (MAP_WIDTH - INITIAL_FIELD_SIZE) / 2
  INITIAL_FIELD_Y = (MAP_HEIGHT - INITIAL_FIELD_SIZE) / 2
  SURFACE_TAGS = { "grass" => :Grass, "desert" => :Sand,
                   "ice" => :Ice, "rock" => :Rock,
                   "water" => :Water, "marsh_water" => :StillWater }.freeze
  SURFACE_NAMES = ArenaMaterials::FLOORS.transform_values(&:first).freeze
  VISIT_SURFACE_CODES = ArenaMaterials::SURFACE_CODES
  FURNITURE_STOCK = {
    :ARENA_FURNITURE_BOULDER => ["Rocher à pousser", "Object boulder", 2],
    :ARENA_FURNITURE_ROCK    => ["Rocher à briser", "Object rock", 2],
    :ARENA_FURNITURE_TREE    => ["Pousse à couper", "Object tree 1", 2]
    }.freeze
  TRAINER_PROFILES = {
    :ARENA_TRAINER_ROOKIE => {
      :name => "Rookie", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:RATTATA, 8], [:EKANS, 9]]
    },
    :ARENA_TRAINER_TACTICIAN => {
      :name => "Tactician", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MAGNEMITE, 10], [:KOFFING, 10]]
    },
    :ARENA_TRAINER_LEADER => {
      :name => "Giovanni", :sprite => "trainer_LEADER_Giovanni", :type => :ROCKETBOSS,
      :team => [[:MEWTWO, 70], [:PERSIAN, 72], [:RHYPERIOR, 70], [:MEOWTH, 76]]
    },
    :ARENA_TRAINER_CHAMPION => {
      :name => "Blue", :sprite => "trainer_CHAMPION", :type => :CHAMPION,
      :team => [[:BLASTOISE, 67], [:PIDGEOT, 65], [:EXEGGUTOR, 62], [:ALAKAZAM, 70]]
    },
 :ARENA_TRAINER_PROFESSOR => {
      :name => "Oak", :sprite => "trainer_PROFESSOR", :type => :PROFESSOR,
      :team => [[:BLASTOISE, 95], [:CHARIZARD, 95], [:VENUSAUR, 95], [:PIKACHU, 95], [:EEVEE, 95]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_RED => {
      :name => "Red", :sprite => "trainer_POKEMONTRAINER_Red", :type => :POKEMONTRAINER_Red,
      :team => [[:CHARIZARD, 100], [:PIKACHU, 100], [:LAPRAS, 100], [:SNORLAX, 100], [:ARTICUNO, 100], [:MEW, 100]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_LEAF => {
      :name => "Leaf", :sprite => "trainer_POKEMONTRAINER_Leaf", :type => :POKEMONTRAINER_Leaf,
      :team => [[:BULBASAUR, 10], [:PIDGEY, 8], [:MANKEY, 9]]
    },
 :ARENA_TRAINER_ELITEFOUR_AGATHA => {
      :name => "Agatha", :sprite => "trainer_ELITEFOUR_Agatha", :type => :ELITEFOUR_Agatha,
      :team => [[:ARBOK, 51], [:CROBAT, 50], [:HAUNTER, 52], [:GENGAR, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_LANCE => {
      :name => "Lance", :sprite => "trainer_ELITEFOUR_Lance", :type => :ELITEFOUR_Lance,
      :team => [[:GYARADOS, 51], [:DRAGONAIR, 50], [:AERODACTYL, 52], [:DRAGONITE, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_BRUNO => {
      :name => "Bruno", :sprite => "trainer_ELITEFOUR_Bruno", :type => :ELITEFOUR_Bruno,
      :team => [[:HITMONCHAN, 51], [:HITMONLEE, 50], [:HITMONTOP, 52], [:MACHAMP, 55]]
    },
 :ARENA_TRAINER_ELITEFOUR_LORELEI => {
      :name => "Lorelei", :sprite => "trainer_ELITEFOUR_Lorelei", :type => :ELITEFOUR_Lorelei,
      :team => [[:DEWGONG, 51], [:JYNX, 50], [:CLOYSTER, 52], [:LAPRAS, 55]]
    },
 :ARENA_TRAINER_LEADER_BROCK => {
      :name => "Brock", :sprite => "trainer_LEADER_Brock", :type => :LEADER_Brock,
      :team => [[:CROAGUNK, 15], [:SUDOWOODO, 17], [:ONIX, 19]]
    },
 :ARENA_TRAINER_LEADER_MISTY => {
      :name => "Misty", :sprite => "trainer_LEADER_Misty", :type => :LEADER_Misty,
      :team => [[:STARYU, 15], [:PSYDUCK, 17], [:TOGEPI, 19]]
    },
 :ARENA_TRAINER_LEADER_SURGE => {
      :name => "Surge", :sprite => "trainer_LEADER_Surge", :type => :LEADER_Surge,
      :team => [[:MAGNEMITE, 25], [:ELECTABUZZ, 27], [:RAICHU, 29]]
    },
 :ARENA_TRAINER_LEADER_ERIKA => {
      :name => "Erika", :sprite => "trainer_LEADER_Erika", :type => :LEADER_Erika,
      :team => [[:TANGELA, 25], [:VILEPLUME, 27], [:IVYSAUR, 29]]
    },
 :ARENA_TRAINER_LEADER_KOGA => {
      :name => "Koga", :sprite => "trainer_LEADER_Koga", :type => :LEADER_Koga,
      :team => [[:KOFFING, 25], [:GRIMER, 27], [:SKUNTANK, 29]]
    },
 :ARENA_TRAINER_LEADER_SABRINA => {
      :name => "Sabrina", :sprite => "trainer_LEADER_Sabrina", :type => :LEADER_Sabrina,
      :team => [[:MRMIME, 35], [:VENOMOTH, 37], [:ALAKAZAM, 39]]
    },
 :ARENA_TRAINER_LEADER_BLAINE => {
      :name => "Blaine", :sprite => "trainer_LEADER_Blaine", :type => :LEADER_Blaine,
      :team => [[:RAPIDASH, 35], [:ARCANINE, 37], [:MAGMORTAR, 39]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_BRENDAN => {
      :name => "Brendan", :sprite => "trainer_POKEMONTRAINER_Brendan", :type => :POKEMONTRAINER_Brendan,
      :team => [[:TREECKO, 10], [:ZIGZAGOON, 8], [:RALTS, 9]]
    },
 :ARENA_TRAINER_POKEMONTRAINER_MAY => {
      :name => "May", :sprite => "trainer_POKEMONTRAINER_May", :type => :POKEMONTRAINER_May,
      :team => [[:BLAZIKEN, 100], [:ABSOL, 100], [:RAYQUAZA, 100]]
    },
  :ARENA_TRAINER_BIRDKEEPER_1 => {
      :name => "Philémon", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
      :team => [[:PIDOVE, 5], [:PIDGEY, 3], [:STARLY, 2]]
    },
:ARENA_TRAINER_BIRDKEEPER_2 => {
  :name => "Mickaël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SWABLU, 10], [:DUCKLETT, 14], [:FARFETCHD, 18], [:STARAVIA, 20]]
},

:ARENA_TRAINER_BIRDKEEPER_3 => {
  :name => "Damien", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:FARFETCHD, 12], [:WINGULL, 14], [:VULLABY, 16], [:NATU, 17], [:SPEAROW, 17], [:DELIBIRD, 18]]
},

:ARENA_TRAINER_BIRDKEEPER_4 => {
  :name => "Ismaël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DUCKLETT, 10], [:FARFETCHD, 10], [:SWABLU, 11], [:RUFFLET, 12], [:DELIBIRD, 16], [:HOOTHOOT, 17]]
},

:ARENA_TRAINER_BIRDKEEPER_5 => {
  :name => "Gérard", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEOTTO, 19]]
},

:ARENA_TRAINER_BIRDKEEPER_6 => {
  :name => "Thomas", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEY, 12], [:STARLY, 14], [:VULLABY, 15], [:DODUO, 20], [:RUFFLET, 20]]
},

:ARENA_TRAINER_BIRDKEEPER_7 => {
  :name => "Aurélien", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DUCKLETT, 4], [:PIDOVE, 9]]
},

:ARENA_TRAINER_BIRDKEEPER_8 => {
  :name => "Joachim", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DUCKLETT, 3], [:TAILLOW, 4], [:RUFFLET, 4], [:MURKROW, 6], [:WINGULL, 8]]
},

:ARENA_TRAINER_BIRDKEEPER_9 => {
  :name => "Gaspard", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MURKROW, 5], [:PIDGEY, 10]]
},

:ARENA_TRAINER_BIRDKEEPER_10 => {
  :name => "Anthony", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:VULLABY, 8]]
},

:ARENA_TRAINER_BIRDKEEPER_11 => {
  :name => "Ethan", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:RUFFLET, 6]]
},

:ARENA_TRAINER_BIRDKEEPER_12 => {
  :name => "Mathis", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEY, 20], [:SWABLU, 25], [:CHATOT, 30]]
},

:ARENA_TRAINER_BIRDKEEPER_13 => {
  :name => "Raphaël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MURKROW, 24], [:DODUO, 27], [:TRANQUILL, 30]]
},

:ARENA_TRAINER_BIRDKEEPER_14 => {
  :name => "Ulysse", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDOVE, 22], [:STARAVIA, 22], [:NATU, 29], [:CHATOT, 29]]
},

:ARENA_TRAINER_BIRDKEEPER_15 => {
  :name => "Erwan", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:VULLABY, 23], [:SPEAROW, 25], [:TRANQUILL, 27], [:PELIPPER, 29], [:FEAROW, 30]]
},

:ARENA_TRAINER_BIRDKEEPER_16 => {
  :name => "Eliott", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEOTTO, 22], [:DUCKLETT, 30]]
},

:ARENA_TRAINER_BIRDKEEPER_17 => {
  :name => "Gaël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:VULLABY, 37]]
},

:ARENA_TRAINER_BIRDKEEPER_18 => {
  :name => "Killian", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:CHATOT, 30], [:NOCTOWL, 32], [:UNFEZANT, 33], [:DODUO, 37], [:DELIBIRD, 40], [:XATU, 40]]
},

:ARENA_TRAINER_BIRDKEEPER_19 => {
  :name => "Patrick", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:FARFETCHD, 34], [:PELIPPER, 36], [:HONCHKROW, 36], [:DELIBIRD, 38]]
},

:ARENA_TRAINER_BIRDKEEPER_20 => {
  :name => "Alexandre", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:STARAVIA, 32], [:PELIPPER, 34], [:MURKROW, 37]]
},

:ARENA_TRAINER_BIRDKEEPER_21 => {
  :name => "Karim", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SWABLU, 32], [:DODUO, 35], [:CHATOT, 37], [:TRANQUILL, 38]]
},

:ARENA_TRAINER_BIRDKEEPER_22 => {
  :name => "Dorian", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEOTTO, 41], [:FARFETCHD, 43], [:CHATOT, 45]]
},

:ARENA_TRAINER_BIRDKEEPER_23 => {
  :name => "Fabien", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SKARMORY, 40], [:DELIBIRD, 42], [:ALTARIA, 45], [:PELIPPER, 46], [:UNFEZANT, 48], [:CHATOT, 50]]
},

:ARENA_TRAINER_BIRDKEEPER_24 => {
  :name => "Nolan", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:UNFEZANT, 41], [:NOCTOWL, 43], [:RUFFLET, 44], [:DELIBIRD, 48], [:ALTARIA, 49]]
},

:ARENA_TRAINER_BIRDKEEPER_25 => {
  :name => "Florian", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:FARFETCHD, 42], [:SWELLOW, 48], [:DELIBIRD, 50]]
},

:ARENA_TRAINER_BIRDKEEPER_26 => {
  :name => "Mattéo", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:VULLABY, 40], [:SWELLOW, 41], [:DELIBIRD, 42], [:STARAPTOR, 50]]
},

:ARENA_TRAINER_BIRDKEEPER_27 => {
  :name => "Lény", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SWELLOW, 51], [:ALTARIA, 51], [:NOCTOWL, 54], [:PELIPPER, 55], [:DELIBIRD, 58], [:FEAROW, 59]]
},

:ARENA_TRAINER_BIRDKEEPER_28 => {
  :name => "Hector", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SKARMORY, 56]]
},

:ARENA_TRAINER_BIRDKEEPER_29 => {
  :name => "Lucas", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEOT, 50], [:PELIPPER, 50], [:DELIBIRD, 51], [:NOCTOWL, 55]]
},

:ARENA_TRAINER_BIRDKEEPER_30 => {
  :name => "Pierre", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MANDIBUZZ, 55], [:FEAROW, 55], [:CHATOT, 57], [:ALTARIA, 58], [:PELIPPER, 59], [:DELIBIRD, 59]]
},

:ARENA_TRAINER_BIRDKEEPER_31 => {
  :name => "Stéphane", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:ALTARIA, 51], [:VULLABY, 56], [:SKARMORY, 57], [:UNFEZANT, 60], [:DELIBIRD, 60]]
},

:ARENA_TRAINER_BIRDKEEPER_32 => {
  :name => "Jonathan", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SWELLOW, 60], [:ALTARIA, 60], [:PELIPPER, 66]]
},

:ARENA_TRAINER_BIRDKEEPER_33 => {
  :name => "Rodolphe", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:VULLABY, 60], [:PELIPPER, 61], [:XATU, 64], [:FEAROW, 65], [:UNFEZANT, 66], [:FARFETCHD, 69]]
},

:ARENA_TRAINER_BIRDKEEPER_34 => {
  :name => "Thibault", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DODRIO, 61], [:FEAROW, 69]]
},

:ARENA_TRAINER_BIRDKEEPER_35 => {
  :name => "Yoann", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:SWELLOW, 65], [:PIDGEOT, 68]]
},

:ARENA_TRAINER_BIRDKEEPER_36 => {
  :name => "Lyam", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:STARAPTOR, 62], [:CHATOT, 65], [:HONCHKROW, 66], [:SWANNA, 69]]
},

:ARENA_TRAINER_BIRDKEEPER_37 => {
  :name => "Alban", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MANDIBUZZ, 72], [:PIDGEOT, 72], [:CHATOT, 73], [:BRAVIARY, 80]]
},

:ARENA_TRAINER_BIRDKEEPER_38 => {
  :name => "Étienne", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:PIDGEOT, 70], [:SWELLOW, 72], [:MANDIBUZZ, 75]]
},

:ARENA_TRAINER_BIRDKEEPER_39 => {
  :name => "Hugo", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:FARFETCHD, 72], [:XATU, 74], [:FEAROW, 75], [:CHATOT, 80]]
},

:ARENA_TRAINER_BIRDKEEPER_40 => {
  :name => "Maël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:FEAROW, 74], [:PIDGEOT, 75], [:SWELLOW, 75], [:PELIPPER, 78], [:FARFETCHD, 80]]
},

:ARENA_TRAINER_BIRDKEEPER_41 => {
  :name => "Tom", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DELIBIRD, 78], [:CHATOT, 80]]
},

:ARENA_TRAINER_BIRDKEEPER_42 => {
  :name => "Samuel", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:ALTARIA, 83], [:STARAPTOR, 83], [:BRAVIARY, 84], [:PELIPPER, 85], [:HONCHKROW, 85], [:SWELLOW, 88]]
},

:ARENA_TRAINER_BIRDKEEPER_43 => {
  :name => "Lorenzo", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:NOCTOWL, 83], [:UNFEZANT, 84], [:DELIBIRD, 89], [:SWELLOW, 90]]
},

:ARENA_TRAINER_BIRDKEEPER_44 => {
  :name => "Yanis", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:BRAVIARY, 85]]
},

:ARENA_TRAINER_BIRDKEEPER_45 => {
  :name => "Bruno", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:ALTARIA, 80], [:SKARMORY, 81], [:DELIBIRD, 82], [:UNFEZANT, 84], [:SWANNA, 86], [:FEAROW, 90]]
},

:ARENA_TRAINER_BIRDKEEPER_46 => {
  :name => "David", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:XATU, 88]]
},

:ARENA_TRAINER_BIRDKEEPER_47 => {
  :name => "Baptiste", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MANDIBUZZ, 90], [:BRAVIARY, 94], [:NOCTOWL, 96], [:SWELLOW, 96], [:FEAROW, 99], [:FARFETCHD, 99]]
},

:ARENA_TRAINER_BIRDKEEPER_48 => {
  :name => "Axel", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:MANDIBUZZ, 95], [:SKARMORY, 96]]
},

:ARENA_TRAINER_BIRDKEEPER_49 => {
  :name => "Noé", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:XATU, 90], [:NOCTOWL, 99], [:ALTARIA, 100]]
},

:ARENA_TRAINER_BIRDKEEPER_50 => {
  :name => "Gwenaël", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:DELIBIRD, 94], [:CHATOT, 95], [:HONCHKROW, 98]]
},

:ARENA_TRAINER_BIRDKEEPER_51 => {
  :name => "Valentin", :sprite => "trainer_BIRDKEEPER", :type => :BIRDKEEPER,
  :team => [[:ALTARIA, 90], [:NOCTOWL, 96], [:PIDGEOT, 97], [:DODRIO, 99], [:SKARMORY, 100], [:CHATOT, 100]]
},

:ARENA_TRAINER_BUGCATCHER_1 => {
  :name => "Dimitri", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:COMBEE, 2], [:VENIPEDE, 5]]
},

:ARENA_TRAINER_BUGCATCHER_2 => {
  :name => "Christophe", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VENONAT, 2], [:SHELMET, 6]]
},

:ARENA_TRAINER_BUGCATCHER_3 => {
  :name => "Sylvain", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:SHELMET, 2], [:LEDYBA, 3], [:SURSKIT, 5], [:SPINARAK, 6], [:KAKUNA, 7], [:KRICKETOT, 7]]
},

:ARENA_TRAINER_BUGCATCHER_4 => {
  :name => "Ludovic", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:LARVESTA, 3], [:NINCADA, 3], [:VENONAT, 6], [:SURSKIT, 8]]
},

:ARENA_TRAINER_BUGCATCHER_5 => {
  :name => "Matéo", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:WURMPLE, 3], [:SURSKIT, 9], [:SHELMET, 10], [:JOLTIK, 10]]
},

:ARENA_TRAINER_BUGCATCHER_6 => {
  :name => "Oscar", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ILLUMISE, 11], [:LEDYBA, 11], [:VENIPEDE, 11], [:LILEEP, 15], [:PINSIR, 17]]
},

:ARENA_TRAINER_BUGCATCHER_7 => {
  :name => "Cédric", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:JOLTIK, 15], [:ILLUMISE, 16]]
},

:ARENA_TRAINER_BUGCATCHER_8 => {
  :name => "Didier", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VOLBEAT, 16], [:PINECO, 17], [:HERACROSS, 20]]
},

:ARENA_TRAINER_BUGCATCHER_9 => {
  :name => "Barnabé", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:KARRABLAST, 13], [:KRICKETUNE, 15], [:SHUCKLE, 15], [:PARAS, 16]]
},

:ARENA_TRAINER_BUGCATCHER_10 => {
  :name => "Franck", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:NINCADA, 12], [:ANORITH, 16], [:PINSIR, 19], [:VOLBEAT, 20]]
},

:ARENA_TRAINER_BUGCATCHER_11 => {
  :name => "Augustin", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:NINJASK, 22], [:BEAUTIFLY, 24], [:PINECO, 27]]
},

:ARENA_TRAINER_BUGCATCHER_12 => {
  :name => "Ronan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:YANMA, 21], [:PINECO, 28]]
},

:ARENA_TRAINER_BUGCATCHER_13 => {
  :name => "Éric", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:KARRABLAST, 20], [:WORMADAM, 26], [:PINECO, 26], [:MOTHIM, 27], [:DWEBBLE, 30]]
},

:ARENA_TRAINER_BUGCATCHER_14 => {
  :name => "Nathan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:JOLTIK, 21], [:KRICKETUNE, 27], [:LARVESTA, 30]]
},

:ARENA_TRAINER_BUGCATCHER_15 => {
  :name => "Kévin", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ANORITH, 25], [:BEEDRILL, 26]]
},

:ARENA_TRAINER_BUGCATCHER_16 => {
  :name => "Armand", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:MASQUERAIN, 30], [:ARIADOS, 32], [:LILEEP, 34], [:ANORITH, 38]]
},

:ARENA_TRAINER_BUGCATCHER_17 => {
  :name => "Basile", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:PARAS, 30], [:HERACROSS, 35], [:ARIADOS, 36], [:ILLUMISE, 37], [:SCIZOR, 37], [:BUTTERFREE, 39]]
},

:ARENA_TRAINER_BUGCATCHER_18 => {
  :name => "Jules", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:NINJASK, 37], [:MOTHIM, 38]]
},

:ARENA_TRAINER_BUGCATCHER_19 => {
  :name => "Grégory", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:HERACROSS, 38]]
},

:ARENA_TRAINER_BUGCATCHER_20 => {
  :name => "Anatole", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:DWEBBLE, 30], [:HERACROSS, 31], [:PINECO, 32], [:ILLUMISE, 33], [:SCYTHER, 35]]
},

:ARENA_TRAINER_BUGCATCHER_21 => {
  :name => "Yohan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:YANMEGA, 46], [:LEDIAN, 48], [:BUTTERFREE, 48], [:HERACROSS, 49], [:VOLBEAT, 50]]
},

:ARENA_TRAINER_BUGCATCHER_22 => {
  :name => "Guillaume", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:LARVESTA, 45]]
},

:ARENA_TRAINER_BUGCATCHER_23 => {
  :name => "Gabriel", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:KRICKETUNE, 47], [:WORMADAM, 50]]
},

:ARENA_TRAINER_BUGCATCHER_24 => {
  :name => "Maxime", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:NINJASK, 45], [:LARVESTA, 47], [:ACCELGOR, 49]]
},

:ARENA_TRAINER_BUGCATCHER_25 => {
  :name => "Alexis", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ESCAVALIER, 40], [:YANMEGA, 44], [:BUTTERFREE, 50]]
},

:ARENA_TRAINER_BUGCATCHER_26 => {
  :name => "Félix", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:MOTHIM, 53], [:VOLBEAT, 54], [:NINJASK, 55], [:ACCELGOR, 57]]
},

:ARENA_TRAINER_BUGCATCHER_27 => {
  :name => "Loïc", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:SCYTHER, 50], [:CRADILY, 53], [:NINJASK, 54], [:WORMADAM, 56], [:PARASECT, 56], [:VOLCARONA, 59]]
},

:ARENA_TRAINER_BUGCATCHER_28 => {
  :name => "Fabrice", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:KRICKETUNE, 55], [:VESPIQUEN, 55], [:PINSIR, 57], [:PARASECT, 58], [:ARMALDO, 59]]
},

:ARENA_TRAINER_BUGCATCHER_29 => {
  :name => "Tristan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VESPIQUEN, 54], [:LEDIAN, 58]]
},

:ARENA_TRAINER_BUGCATCHER_30 => {
  :name => "Paul", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:CRUSTLE, 50], [:YANMEGA, 53], [:VOLBEAT, 53], [:LEDIAN, 53], [:ACCELGOR, 57]]
},

:ARENA_TRAINER_BUGCATCHER_31 => {
  :name => "Vincent", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:CRADILY, 62], [:VESPIQUEN, 67], [:KRICKETUNE, 68]]
},

:ARENA_TRAINER_BUGCATCHER_32 => {
  :name => "Casimir", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:FORRETRESS, 63], [:SCIZOR, 68], [:LEAVANNY, 68], [:SCYTHER, 69]]
},

:ARENA_TRAINER_BUGCATCHER_33 => {
  :name => "Timothée", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VENOMOTH, 69], [:PARASECT, 70]]
},

:ARENA_TRAINER_BUGCATCHER_34 => {
  :name => "Adrien", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VOLBEAT, 62], [:MOTHIM, 62], [:SCYTHER, 65]]
},

:ARENA_TRAINER_BUGCATCHER_35 => {
  :name => "Simon", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:FORRETRESS, 60], [:CRUSTLE, 62], [:KRICKETUNE, 62], [:CRADILY, 65]]
},

:ARENA_TRAINER_BUGCATCHER_36 => {
  :name => "Maxence", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VOLCARONA, 70], [:MOTHIM, 73], [:ACCELGOR, 74], [:VOLBEAT, 78]]
},

:ARENA_TRAINER_BUGCATCHER_37 => {
  :name => "Yannick", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:SCOLIPEDE, 77]]
},

:ARENA_TRAINER_BUGCATCHER_38 => {
  :name => "Marius", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VOLCARONA, 72], [:PARASECT, 75]]
},

:ARENA_TRAINER_BUGCATCHER_39 => {
  :name => "Théodore", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:NINJASK, 70], [:WORMADAM, 70], [:SCOLIPEDE, 71], [:BUTTERFREE, 75]]
},

:ARENA_TRAINER_BUGCATCHER_40 => {
  :name => "Sofiane", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:PINSIR, 73], [:ESCAVALIER, 78]]
},

:ARENA_TRAINER_BUGCATCHER_41 => {
  :name => "Marc", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:DURANT, 82], [:BEAUTIFLY, 83], [:HERACROSS, 83], [:PINSIR, 83], [:CRADILY, 86], [:VOLCARONA, 90]]
},

:ARENA_TRAINER_BUGCATCHER_42 => {
  :name => "Bertrand", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ARMALDO, 83], [:ACCELGOR, 85], [:DURANT, 86], [:VOLBEAT, 87]]
},

:ARENA_TRAINER_BUGCATCHER_43 => {
  :name => "Dylan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:PINSIR, 81], [:MOTHIM, 81], [:VESPIQUEN, 83], [:WORMADAM, 83], [:CRADILY, 87]]
},

:ARENA_TRAINER_BUGCATCHER_44 => {
  :name => "Mehdi", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:SHUCKLE, 81], [:ESCAVALIER, 82], [:BUTTERFREE, 82], [:ARMALDO, 83], [:PINSIR, 86], [:VESPIQUEN, 90]]
},

:ARENA_TRAINER_BUGCATCHER_45 => {
  :name => "Denis", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ACCELGOR, 80], [:VOLBEAT, 84], [:CRUSTLE, 84], [:HERACROSS, 85], [:NINJASK, 86], [:SCYTHER, 87]]
},

:ARENA_TRAINER_BUGCATCHER_46 => {
  :name => "Louis", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:DUSTOX, 95]]
},

:ARENA_TRAINER_BUGCATCHER_47 => {
  :name => "Quentin", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:VENOMOTH, 96], [:KRICKETUNE, 97], [:SCOLIPEDE, 99]]
},

:ARENA_TRAINER_BUGCATCHER_48 => {
  :name => "Martin", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:ACCELGOR, 91], [:WORMADAM, 97], [:VOLBEAT, 100]]
},

:ARENA_TRAINER_BUGCATCHER_49 => {
  :name => "Evan", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:PINSIR, 90], [:PARASECT, 91], [:VENOMOTH, 94], [:ARMALDO, 94], [:VOLBEAT, 98]]
},

:ARENA_TRAINER_BUGCATCHER_50 => {
  :name => "Benoît", :sprite => "trainer_BUGCATCHER", :type => :BUGCATCHER,
  :team => [[:GALVANTULA, 91], [:BEEDRILL, 96], [:PINSIR, 97], [:DURANT, 99], [:SHUCKLE, 100]]
},

  :ARENA_TRAINER_BEAUTY_1 => {
      :name => "Lydia", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:CHIKORITA, 5], [:JIGGLYPUFF, 4]]
    },
 :ARENA_TRAINER_BEAUTY_2 => {
      :name => "Maya", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:HOPPIP, 2], [:MUNNA, 4], [:MARILL, 8], [:LUVDISC, 8]]
    },
 :ARENA_TRAINER_BEAUTY_3 => {
      :name => "Emma", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:LILLIPUP, 2], [:AZURILL, 4], [:IGGLYBUFF, 4], [:MAREEP, 9]]
    },
 :ARENA_TRAINER_BEAUTY_4 => {
      :name => "Éléonore", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:SPHEAL, 3], [:RALTS, 4], [:LILLIPUP, 4], [:IGGLYBUFF, 4], [:BUNEARY, 7]]
    },
 :ARENA_TRAINER_BEAUTY_5 => {
      :name => "Agathe", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:CUBCHOO, 2], [:AIPOM, 4], [:DEERLING, 7]]
    },
 :ARENA_TRAINER_BEAUTY_6 => {
      :name => "Mélanie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PACHIRISU, 16], [:HERDIER, 16], [:MINUN, 19]]
    },
 :ARENA_TRAINER_BEAUTY_7 => {
      :name => "Rose", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:SUNKERN, 15], [:SUNFLORA, 19]]
    },
 :ARENA_TRAINER_BEAUTY_8 => {
      :name => "Iris", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:SKITTY, 11], [:TOGETIC, 17], [:WOOPER, 17]]
    },
 :ARENA_TRAINER_BEAUTY_9 => {
      :name => "Estelle", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PLUSLE, 14], [:EEVEE, 17]]
    },
 :ARENA_TRAINER_BEAUTY_10 => {
      :name => "Capucine", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:GLAMEOW, 16]]
    },
 :ARENA_TRAINER_BEAUTY_11 => {
      :name => "Sophie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PETILIL, 23], [:CHERRIM, 27], [:GLACEON, 27], [:ROSELIA, 30]]
    },
 :ARENA_TRAINER_BEAUTY_12 => {
      :name => "Océane", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PACHIRISU, 23], [:FEEBAS, 23], [:GLACEON, 26], [:LILLIGANT, 28]]
    },
 :ARENA_TRAINER_BEAUTY_13 => {
      :name => "Salomé", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:LOPUNNY, 20], [:EEVEE, 21], [:COTTONEE, 24], [:CLEFAIRY, 28]]
    },
 :ARENA_TRAINER_BEAUTY_14 => {
      :name => "Anaïs", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:BUNEARY, 20], [:COTTONEE, 26], [:LUXIO, 28], [:SPHEAL, 29], [:GLACEON, 29], [:MILOTIC, 30]]
    },
 :ARENA_TRAINER_BEAUTY_15 => {
      :name => "Célia", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:BIBAREL, 22], [:MINCCINO, 23], [:CLEFAIRY, 26]]
    },
 :ARENA_TRAINER_BEAUTY_16 => {
      :name => "Lilou", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:CHERRIM, 31], [:LIEPARD, 36], [:MRMIME, 37], [:AIPOM, 39], [:AMPHAROS, 40]]
    },
 :ARENA_TRAINER_BEAUTY_17 => {
      :name => "Flora", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AZUMARILL, 38]]
    },
 :ARENA_TRAINER_BEAUTY_18 => {
      :name => "Alix", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:DELCATTY, 35]]
    },
 :ARENA_TRAINER_BEAUTY_19 => {
      :name => "Louna", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AUDINO, 38]]
    },
 :ARENA_TRAINER_BEAUTY_20 => {
      :name => "Margaux", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:SUNKERN, 33], [:JYNX, 35]]
    },
 :ARENA_TRAINER_BEAUTY_21 => {
      :name => "Inès", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PIKACHU, 41], [:COTTONEE, 45]]
    },
 :ARENA_TRAINER_BEAUTY_22 => {
      :name => "Ambre", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:COTTONEE, 40], [:LUVDISC, 44], [:PLUSLE, 44], [:FLAREON, 49]]
    },
 :ARENA_TRAINER_BEAUTY_23 => {
      :name => "Éva", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:MRMIME, 42], [:VAPOREON, 42], [:GLACEON, 42], [:JOLTEON, 49], [:JYNX, 50], [:CHERRIM, 50]]
    },
 :ARENA_TRAINER_BEAUTY_24 => {
      :name => "Morgane", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:QUAGSIRE, 45]]
    },
 :ARENA_TRAINER_BEAUTY_25 => {
      :name => "Camille", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:MANTINE, 42], [:MUSHARNA, 43], [:SAWSBUCK, 44], [:GLACEON, 46]]
    },
 :ARENA_TRAINER_BEAUTY_26 => {
      :name => "Noémie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:GARDEVOIR, 58], [:LOPUNNY, 59]]
    },
 :ARENA_TRAINER_BEAUTY_27 => {
      :name => "Pauline", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PURUGLY, 51], [:ESPEON, 57]]
    },
 :ARENA_TRAINER_BEAUTY_28 => {
      :name => "Sixtine", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:LOPUNNY, 54], [:DONPHAN, 58]]
    },
 :ARENA_TRAINER_BEAUTY_29 => {
      :name => "Constance", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:BEARTIC, 55]]
    },
 :ARENA_TRAINER_BEAUTY_30 => {
      :name => "Chloé", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:ROSERADE, 52], [:UMBREON, 54], [:WIGGLYTUFF, 56], [:LIEPARD, 59]]
    },
 :ARENA_TRAINER_BEAUTY_31 => {
      :name => "Gabrielle", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:GLACEON, 60], [:BEARTIC, 65], [:LEAFEON, 66], [:BLISSEY, 67], [:PACHIRISU, 67], [:CINCCINO, 68]]
    },
 :ARENA_TRAINER_BEAUTY_32 => {
      :name => "Joséphine", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:GRANBULL, 61], [:SUNFLORA, 63], [:DONPHAN, 63], [:BEARTIC, 65], [:SAWSBUCK, 67], [:TOGEKISS, 70]]
    },
 :ARENA_TRAINER_BEAUTY_33 => {
      :name => "Perrine", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:URSARING, 64], [:VAPOREON, 70]]
    },
 :ARENA_TRAINER_BEAUTY_34 => {
      :name => "Faustine", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:DONPHAN, 61], [:DELCATTY, 62], [:JOLTEON, 62], [:ESPEON, 66], [:CHANSEY, 67], [:ROSELIA, 67]]
    },
 :ARENA_TRAINER_BEAUTY_35 => {
      :name => "Apolline", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:TOGETIC, 65]]
    },
 :ARENA_TRAINER_BEAUTY_36 => {
      :name => "Maëlys", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:DELCATTY, 70], [:FURRET, 79]]
    },
 :ARENA_TRAINER_BEAUTY_37 => {
      :name => "Nora", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:LUVDISC, 70], [:SAWSBUCK, 72], [:MRMIME, 76], [:SUNFLORA, 76], [:AMPHAROS, 77]]
    },
 :ARENA_TRAINER_BEAUTY_38 => {
      :name => "Solène", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:WHIMSICOTT, 70], [:CASTFORM, 77], [:FLAREON, 78], [:NINETALES, 79], [:BLISSEY, 80]]
    },
 :ARENA_TRAINER_BEAUTY_39 => {
      :name => "Jeanne", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:RAICHU, 73], [:QUAGSIRE, 74], [:WALREIN, 74], [:WHIMSICOTT, 75]]
    },
 :ARENA_TRAINER_BEAUTY_40 => {
      :name => "Bérénice", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AZUMARILL, 70], [:WALREIN, 73], [:MILOTIC, 78]]
    },
 :ARENA_TRAINER_BEAUTY_41 => {
      :name => "Romane", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:LILLIGANT, 89]]
    },
 :ARENA_TRAINER_BEAUTY_42 => {
      :name => "Émilie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AZUMARILL, 80], [:TOGEKISS, 80], [:CHERRIM, 84], [:CINCCINO, 85], [:MUSHARNA, 87], [:VAPOREON, 90]]
    },
 :ARENA_TRAINER_BEAUTY_43 => {
      :name => "Adèle", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:PLUSLE, 85], [:BEARTIC, 87], [:LEAFEON, 87]]
    },
 :ARENA_TRAINER_BEAUTY_44 => {
      :name => "Mélissa", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:CASTFORM, 81], [:MRMIME, 90]]
    },
 :ARENA_TRAINER_BEAUTY_45 => {
      :name => "Nina", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AZUMARILL, 80], [:JYNX, 80], [:JOLTEON, 84], [:EMOLGA, 84], [:STOUTLAND, 87], [:ALTARIA, 89]]
    },
 :ARENA_TRAINER_BEAUTY_46 => {
      :name => "Anouk", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:AZUMARILL, 95]]
    },
 :ARENA_TRAINER_BEAUTY_47 => {
      :name => "Aurélie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:EMOLGA, 91], [:UMBREON, 92], [:PIKACHU, 92], [:URSARING, 99], [:AMBIPOM, 100]]
    },
 :ARENA_TRAINER_BEAUTY_48 => {
      :name => "Élise", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:MEGANIUM, 90], [:LILLIGANT, 91], [:CINCCINO, 100]]
    },
 :ARENA_TRAINER_BEAUTY_49 => {
      :name => "Élodie", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:NINETALES, 98]]
    },
 :ARENA_TRAINER_BEAUTY_50 => {
      :name => "Lola", :sprite => "trainer_BEAUTY", :type => :BEAUTY,
      :team => [[:TOGETIC, 93], [:BEARTIC, 97]]
    },
  :ARENA_TRAINER_BIKER_1 => {
      :name => "Titouan", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGIKARP, 5], [:POOCHYENA, 4]]
    },
:ARENA_TRAINER_BIKER_2 => {
      :name => "Orazio", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:ELEKID, 6]]
    },
:ARENA_TRAINER_BIKER_3 => {
      :name => "Massimo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:DRILBUR, 6]]
    },
:ARENA_TRAINER_BIKER_4 => {
      :name => "Tommaso", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:TYROGUE, 6]]
    },
:ARENA_TRAINER_BIKER_5 => {
      :name => "Rocco", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGBY, 3], [:PURRLOIN, 10], [:GLIGAR, 10]]
    },
:ARENA_TRAINER_BIKER_6 => {
      :name => "Vinnie", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:PURRLOIN, 12], [:SCRAGGY, 13], [:CROAGUNK, 13], [:LARVITAR, 14], [:ELECTRIKE, 16], [:DRILBUR, 17]]
    },
:ARENA_TRAINER_BIKER_7 => {
      :name => "Angelo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:GROWLITHE, 12], [:LARVITAR, 14], [:SPINARAK, 17]]
    },
:ARENA_TRAINER_BIKER_8 => {
      :name => "Salvatore", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGIKARP, 15]]
    },
:ARENA_TRAINER_BIKER_9 => {
      :name => "Ettore", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:CROAGUNK, 10], [:DRILBUR, 14], [:MEOWTH, 18], [:GROWLITHE, 19]]
    },
:ARENA_TRAINER_BIKER_10 => {
      :name => "Tano", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGBY, 13], [:CACNEA, 14], [:MAGIKARP, 15], [:SPINARAK, 18], [:SEVIPER, 20]]
    },
:ARENA_TRAINER_BIKER_11 => {
      :name => "Giuseppe", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:CACNEA, 20], [:GOLBAT, 24], [:STUNKY, 26], [:THROH, 29]]
    },
:ARENA_TRAINER_BIKER_12 => {
      :name => "Carmine", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:RATTATA, 20], [:RATICATE, 21], [:CACNEA, 21], [:SKORUPI, 22], [:ABSOL, 28], [:ZANGOOSE, 30]]
    },
:ARENA_TRAINER_BIKER_13 => {
      :name => "Domenico", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:HITMONCHAN, 21], [:SNEASEL, 22], [:ELECTRIKE, 24], [:MANKEY, 26], [:THROH, 26], [:LIEPARD, 28]]
    },
:ARENA_TRAINER_BIKER_14 => {
      :name => "Silvio", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:SKORUPI, 22], [:GYARADOS, 25]]
    },
:ARENA_TRAINER_BIKER_15 => {
      :name => "Franco", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:ELECTRIKE, 23], [:LIEPARD, 25], [:SNEASEL, 27]]
    },
:ARENA_TRAINER_BIKER_16 => {
      :name => "Leonardo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MURKROW, 30], [:TORKOAL, 31], [:HITMONTOP, 31], [:ABSOL, 32], [:MAGMAR, 38], [:SKORUPI, 40]]
    },
:ARENA_TRAINER_BIKER_17 => {
      :name => "Mario", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:HITMONTOP, 33], [:EXCADRILL, 36], [:SKARMORY, 37]]
    },
:ARENA_TRAINER_BIKER_18 => {
      :name => "Marcello", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:CROAGUNK, 33], [:SHARPEDO, 33], [:GOLBAT, 36], [:ABSOL, 38], [:KROKOROK, 38], [:GYARADOS, 39]]
    },
:ARENA_TRAINER_BIKER_19 => {
      :name => "Luciano", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MANECTRIC, 31], [:SKORUPI, 33], [:CACTURNE, 33], [:LIEPARD, 38], [:THROH, 39]]
    },
:ARENA_TRAINER_BIKER_20 => {
      :name => "Santino", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:WEEZING, 36], [:CACTURNE, 40]]
    },
:ARENA_TRAINER_BIKER_21 => {
      :name => "Nino", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:HONCHKROW, 46]]
    },
:ARENA_TRAINER_BIKER_22 => {
      :name => "Jimmy", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGMORTAR, 40], [:PUPITAR, 46], [:SHARPEDO, 50]]
    },
:ARENA_TRAINER_BIKER_23 => {
      :name => "Gianni", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:WEAVILE, 41], [:SAWK, 41], [:MIGHTYENA, 50]]
    },
:ARENA_TRAINER_BIKER_24 => {
      :name => "Raimondo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:ARCANINE, 42], [:TORKOAL, 43], [:GLISCOR, 44], [:MACHAMP, 46], [:ELECTIVIRE, 47], [:SHARPEDO, 50]]
    },
:ARENA_TRAINER_BIKER_25 => {
      :name => "Ignazio", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:PERSIAN, 50]]
    },
:ARENA_TRAINER_BIKER_26 => {
      :name => "Dante", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MANECTRIC, 51], [:SEVIPER, 55], [:HITMONCHAN, 56], [:SKUNTANK, 57], [:THROH, 58]]
    },
:ARENA_TRAINER_BIKER_27 => {
      :name => "Enzo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGMAR, 57]]
    },
:ARENA_TRAINER_BIKER_28 => {
      :name => "Ottavio", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:KROOKODILE, 53], [:MUK, 55]]
    },
:ARENA_TRAINER_BIKER_29 => {
      :name => "Lorenzo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:GOLBAT, 50], [:MUK, 51], [:SKUNTANK, 57], [:SHARPEDO, 57], [:ARCANINE, 58], [:ELECTABUZZ, 60]]
    },
:ARENA_TRAINER_BIKER_30 => {
      :name => "Paulie", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:CACTURNE, 50], [:DARMANITAN, 50], [:PERSIAN, 53], [:MACHAMP, 53], [:TOXICROAK, 54], [:SCRAFTY, 56]]
    },
:ARENA_TRAINER_BIKER_31 => {
      :name => "Antonio", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:THROH, 60], [:KROOKODILE, 63], [:WEAVILE, 68], [:TAUROS, 69], [:MANECTRIC, 70]]
    },
:ARENA_TRAINER_BIKER_32 => {
      :name => "Raffaele", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:TOXICROAK, 60], [:BISHARP, 60], [:SEVIPER, 63], [:TAUROS, 65], [:PRIMEAPE, 66]]
    },
:ARENA_TRAINER_BIKER_33 => {
      :name => "Sandro", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MACHAMP, 63], [:MAGMAR, 66], [:ABSOL, 66], [:ZANGOOSE, 66]]
    },
:ARENA_TRAINER_BIKER_34 => {
      :name => "Carlo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGMAR, 64], [:GOLBAT, 66], [:TYRANITAR, 66], [:HONCHKROW, 67], [:PERSIAN, 68], [:ELECTIVIRE, 70]]
    },
:ARENA_TRAINER_BIKER_35 => {
      :name => "Lenny", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:ZANGOOSE, 61], [:HOUNDOOM, 64], [:HITMONTOP, 65], [:GOLBAT, 68]]
    },
:ARENA_TRAINER_BIKER_36 => {
      :name => "Tony", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:GLISCOR, 80]]
    },
:ARENA_TRAINER_BIKER_37 => {
      :name => "Aldo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:HITMONLEE, 71], [:GLISCOR, 71], [:ABSOL, 75], [:ARIADOS, 79], [:TOXICROAK, 79], [:ARCANINE, 79]]
    },
:ARENA_TRAINER_BIKER_38 => {
      :name => "Pasquale", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:EXCADRILL, 73], [:PRIMEAPE, 75], [:MAGMAR, 76]]
    },
:ARENA_TRAINER_BIKER_39 => {
      :name => "Vito", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:THROH, 72], [:DARMANITAN, 75]]
    },
:ARENA_TRAINER_BIKER_40 => {
      :name => "Bernardo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:LIEPARD, 70], [:HOUNDOOM, 71], [:DRAPION, 80], [:MAGMAR, 80]]
    },
:ARENA_TRAINER_BIKER_41 => {
      :name => "Johnny", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:TOXICROAK, 85]]
    },
:ARENA_TRAINER_BIKER_42 => {
      :name => "Sal", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:TAUROS, 87], [:HITMONLEE, 88], [:GYARADOS, 89], [:MUK, 90], [:TOXICROAK, 90]]
    },
:ARENA_TRAINER_BIKER_43 => {
      :name => "Mikey", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:BISHARP, 83], [:TAUROS, 83], [:ELECTABUZZ, 84], [:SEVIPER, 85], [:DRAPION, 85], [:THROH, 88]]
    },
:ARENA_TRAINER_BIKER_44 => {
      :name => "Gaetano", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:THROH, 88]]
    },
:ARENA_TRAINER_BIKER_45 => {
      :name => "Cosimo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:DRAPION, 85], [:SCRAFTY, 87], [:PERSIAN, 89], [:ELECTIVIRE, 89], [:SAWK, 90], [:DARMANITAN, 90]]
    },
:ARENA_TRAINER_BIKER_46 => {
      :name => "Gino", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:ELECTIVIRE, 96], [:MACHOKE, 97], [:EXCADRILL, 97]]
    },
:ARENA_TRAINER_BIKER_47 => {
      :name => "Sonny", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:CROBAT, 92], [:HITMONCHAN, 95], [:GLISCOR, 97], [:MAGMORTAR, 97], [:ARCANINE, 100]]
    },
:ARENA_TRAINER_BIKER_48 => {
      :name => "Rinaldo", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:MAGMAR, 90], [:MACHAMP, 91], [:GARBODOR, 92], [:ARIADOS, 96], [:SKUNTANK, 99], [:SAWK, 100]]
    },
:ARENA_TRAINER_BIKER_49 => {
      :name => "Calogero", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:SKARMORY, 93], [:TAUROS, 93], [:ELECTIVIRE, 95], [:LIEPARD, 98]]
    },
:ARENA_TRAINER_BIKER_50 => {
      :name => "Corrado", :sprite => "trainer_BIKER", :type => :BIKER,
      :team => [[:DRAPION, 90], [:GLISCOR, 91], [:MAGMAR, 92], [:HITMONLEE, 94], [:BISHARP, 97], [:WEEZING, 99]]
    },
:ARENA_TRAINER_BLACKBELT_1 => {
      :name => "Teddy", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:CHIMCHAR, 5], [:CUBONE, 4]]
    },
:ARENA_TRAINER_BLACKBELT_2 => {
      :name => "Goro", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TYROGUE, 5], [:ONIX, 5], [:MEDITITE, 7]]
    },
:ARENA_TRAINER_BLACKBELT_3 => {
      :name => "Conor", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TEPIG, 2], [:MANKEY, 4], [:RHYHORN, 5], [:RIOLU, 10], [:TORCHIC, 10]]
    },
:ARENA_TRAINER_BLACKBELT_4 => {
      :name => "Wladimir", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MACHOP, 3], [:CHIMCHAR, 4], [:MIENFOO, 7], [:RIOLU, 7], [:MEDITITE, 8]]
    },
:ARENA_TRAINER_BLACKBELT_5 => {
      :name => "Kimbo", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TORCHIC, 6]]
    },
:ARENA_TRAINER_BLACKBELT_6 => {
      :name => "Igor", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TEPIG, 11], [:ZANGOOSE, 11], [:MONFERNO, 18], [:COMBUSKEN, 19]]
    },
:ARENA_TRAINER_BLACKBELT_7 => {
      :name => "Shinji", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:SCRAGGY, 15]]
    },
:ARENA_TRAINER_BLACKBELT_8 => {
      :name => "Alain", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:ZANGOOSE, 18]]
    },
:ARENA_TRAINER_BLACKBELT_9 => {
      :name => "Dolph", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:ZANGOOSE, 17], [:TIMBURR, 18], [:SAWK, 20]]
    },
:ARENA_TRAINER_BLACKBELT_10 => {
      :name => "Royce", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:RIOLU, 13], [:MIENFOO, 18], [:PIGNITE, 19], [:MONFERNO, 19]]
    },
:ARENA_TRAINER_BLACKBELT_11 => {
      :name => "Jackie", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:SCRAGGY, 20], [:MONFERNO, 20], [:PIGNITE, 20], [:GURDURR, 27]]
    },
:ARENA_TRAINER_BLACKBELT_12 => {
      :name => "Joe", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MACHOP, 27], [:SAWK, 28], [:COMBUSKEN, 29]]
    },
:ARENA_TRAINER_BLACKBELT_13 => {
      :name => "Toshiro", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HARIYAMA, 25]]
    },
:ARENA_TRAINER_BLACKBELT_14 => {
      :name => "Bruce", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HERACROSS, 25]]
    },
:ARENA_TRAINER_BLACKBELT_15 => {
      :name => "Georges", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MACHOP, 20], [:MIENFOO, 26], [:PIGNITE, 29]]
    },
:ARENA_TRAINER_BLACKBELT_16 => {
      :name => "Khabib", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:LUCARIO, 35]]
    },
:ARENA_TRAINER_BLACKBELT_17 => {
      :name => "Hugo", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:LUCARIO, 31], [:HITMONTOP, 31], [:HERACROSS, 32], [:HITMONCHAN, 36], [:MEDITITE, 37], [:MACHOKE, 37]]
    },
:ARENA_TRAINER_BLACKBELT_18 => {
      :name => "Canelo", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:BRELOOM, 38], [:PINSIR, 40]]
    },
:ARENA_TRAINER_BLACKBELT_19 => {
      :name => "Oscar", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:POLIWHIRL, 34], [:HERACROSS, 36], [:SAWK, 37], [:THROH, 38], [:SCRAFTY, 39]]
    },
:ARENA_TRAINER_BLACKBELT_20 => {
      :name => "Randy", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:CROAGUNK, 30], [:MACHOKE, 33], [:PRIMEAPE, 37]]
    },
:ARENA_TRAINER_BLACKBELT_21 => {
      :name => "Marvin", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:POLIWRATH, 40], [:MACHAMP, 45]]
    },
:ARENA_TRAINER_BLACKBELT_22 => {
      :name => "Kazuya", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:BRELOOM, 41], [:HITMONCHAN, 50]]
    },
:ARENA_TRAINER_BLACKBELT_23 => {
      :name => "Brock", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HITMONCHAN, 44], [:GALLADE, 46], [:THROH, 46], [:LUCARIO, 47], [:HERACROSS, 47], [:MAROWAK, 48]]
    },
:ARENA_TRAINER_BLACKBELT_24 => {
      :name => "Cain", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:EMBOAR, 43], [:ABSOL, 44], [:SAWK, 45], [:INFERNAPE, 45], [:BRELOOM, 45]]
    },
:ARENA_TRAINER_BLACKBELT_25 => {
      :name => "Gennady", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:CONKELDURR, 44], [:EMBOAR, 46], [:SCRAFTY, 46], [:INFERNAPE, 48], [:LUCARIO, 48]]
    },
:ARENA_TRAINER_BLACKBELT_26 => {
      :name => "Hwoarang", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:BLAZIKEN, 55]]
    },
:ARENA_TRAINER_BLACKBELT_27 => {
      :name => "Rocco", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:RHYDON, 52], [:BLAZIKEN, 55]]
    },
:ARENA_TRAINER_BLACKBELT_28 => {
      :name => "Lennox", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:SCRAFTY, 59], [:BLAZIKEN, 59]]
    },
:ARENA_TRAINER_BLACKBELT_29 => {
      :name => "Marduk", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:PRIMEAPE, 58]]
    },
:ARENA_TRAINER_BLACKBELT_30 => {
      :name => "Ryu", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:POLIWRATH, 51], [:HARIYAMA, 52], [:INFERNAPE, 52], [:EMBOAR, 54], [:MIENSHAO, 59], [:MEDICHAM, 60]]
    },
:ARENA_TRAINER_BLACKBELT_31 => {
      :name => "Apollo", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:EMBOAR, 61], [:PRIMEAPE, 64], [:SAWK, 65], [:HERACROSS, 67], [:MIENSHAO, 69], [:BRELOOM, 70]]
    },
:ARENA_TRAINER_BLACKBELT_32 => {
      :name => "Balrog", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:CONKELDURR, 60], [:MACHAMP, 60], [:STEELIX, 61], [:BLAZIKEN, 61], [:LUCARIO, 66]]
    },
:ARENA_TRAINER_BLACKBELT_33 => {
      :name => "Luis", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MACHAMP, 62], [:MACHOKE, 64], [:ABSOL, 68], [:EMBOAR, 70], [:MIENSHAO, 70]]
    },
:ARENA_TRAINER_BLACKBELT_34 => {
      :name => "Diego", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:EMBOAR, 65]]
    },
:ARENA_TRAINER_BLACKBELT_35 => {
      :name => "Takeshi", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:EMBOAR, 68], [:MEDICHAM, 69]]
    },
:ARENA_TRAINER_BLACKBELT_36 => {
      :name => "Jorge", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:THROH, 73], [:TOXICROAK, 73], [:EMBOAR, 77], [:HERACROSS, 79]]
    },
:ARENA_TRAINER_BLACKBELT_37 => {
      :name => "Lyoto", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HITMONTOP, 71], [:POLIWRATH, 76]]
    },
:ARENA_TRAINER_BLACKBELT_38 => {
      :name => "Muhammad", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:THROH, 74], [:MIENSHAO, 75], [:MEDICHAM, 75], [:BLAZIKEN, 80], [:HITMONTOP, 80], [:GALLADE, 80]]
    },
:ARENA_TRAINER_BLACKBELT_39 => {
      :name => "Ken", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HITMONLEE, 75], [:MEDICHAM, 80]]
    },
:ARENA_TRAINER_BLACKBELT_40 => {
      :name => "Evander", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:INFERNAPE, 73], [:MACHAMP, 74], [:TOXICROAK, 74], [:MACHOKE, 77]]
    },
:ARENA_TRAINER_BLACKBELT_41 => {
      :name => "Rocky", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TOXICROAK, 80], [:THROH, 82], [:MIENSHAO, 85]]
    },
:ARENA_TRAINER_BLACKBELT_42 => {
      :name => "Akira", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:BRELOOM, 81], [:MIENSHAO, 86], [:THROH, 87], [:STEELIX, 90]]
    },
:ARENA_TRAINER_BLACKBELT_43 => {
      :name => "Hiroshi", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:HERACROSS, 86], [:THROH, 86]]
    },
:ARENA_TRAINER_BLACKBELT_44 => {
      :name => "Manny", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:TAUROS, 80], [:THROH, 84], [:HERACROSS, 89]]
    },
:ARENA_TRAINER_BLACKBELT_45 => {
      :name => "Anderson", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MAROWAK, 80], [:CONKELDURR, 81], [:LUCARIO, 85], [:ABSOL, 86], [:MACHAMP, 89], [:THROH, 89]]
    },
:ARENA_TRAINER_BLACKBELT_46 => {
      :name => "Jet", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:INFERNAPE, 97]]
    },
:ARENA_TRAINER_BLACKBELT_47 => {
      :name => "Rickson", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:MIENSHAO, 90], [:LUCARIO, 95]]
    },
:ARENA_TRAINER_BLACKBELT_48 => {
      :name => "Mohamed", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:EMBOAR, 91], [:HITMONLEE, 94], [:HARIYAMA, 100]]
    },
:ARENA_TRAINER_BLACKBELT_49 => {
      :name => "Kenji", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:THROH, 90], [:HITMONCHAN, 91], [:BLAZIKEN, 97], [:PRIMEAPE, 98], [:TAUROS, 99], [:MIENSHAO, 100]]
    },
:ARENA_TRAINER_BLACKBELT_50 => {
      :name => "Boris", :sprite => "trainer_BLACKBELT", :type => :BLACKBELT,
      :team => [[:INFERNAPE, 90], [:SAWK, 90], [:LUCARIO, 90], [:SCRAFTY, 91], [:HERACROSS, 96]]
    },
:ARENA_TRAINER_AROMALADY_1 => {
      :name => "Laury", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:DEERLING, 5], [:LOTAD, 4]]
    },
:ARENA_TRAINER_AROMALADY_2 => {
      :name => "Odette", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:EXEGGCUTE, 4], [:PETILIL, 6]]
    },
:ARENA_TRAINER_AROMALADY_3 => {
      :name => "Hélène", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:HOPPIP, 6]]
    },
:ARENA_TRAINER_AROMALADY_4 => {
      :name => "Opaline", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:CHERUBI, 6], [:BULBASAUR, 10]]
    },
:ARENA_TRAINER_AROMALADY_5 => {
      :name => "Sylvie", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SNIVY, 2], [:BELLSPROUT, 9]]
    },
:ARENA_TRAINER_AROMALADY_6 => {
      :name => "Églantine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TURTWIG, 15]]
    },
:ARENA_TRAINER_AROMALADY_7 => {
      :name => "Lucille", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:DEERLING, 12], [:CHERUBI, 14], [:PETILIL, 15], [:CARNIVINE, 16], [:ODDISH, 19]]
    },
:ARENA_TRAINER_AROMALADY_8 => {
      :name => "Eugénie", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:DEERLING, 12], [:BEAUTIFLY, 12], [:FERROSEED, 13], [:PANSAGE, 14], [:BELLSPROUT, 14], [:EXEGGCUTE, 15]]
    },
:ARENA_TRAINER_AROMALADY_9 => {
      :name => "Pervenche", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SUNKERN, 13], [:HOPPIP, 14], [:EXEGGCUTE, 14], [:GROTLE, 20], [:SNOVER, 20]]
    },
:ARENA_TRAINER_AROMALADY_10 => {
      :name => "Éloïse", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TURTWIG, 11], [:CARNIVINE, 20]]
    },
:ARENA_TRAINER_AROMALADY_11 => {
      :name => "Ophélie", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:FERROSEED, 20], [:LOMBRE, 24], [:WORMADAM, 26], [:GLOOM, 26], [:MARACTUS, 29]]
    },
:ARENA_TRAINER_AROMALADY_12 => {
      :name => "Oriane", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:GLOOM, 23], [:BRELOOM, 24], [:SWADLOON, 24], [:LILLIGANT, 25], [:PARASECT, 30]]
    },
:ARENA_TRAINER_AROMALADY_13 => {
      :name => "Ysabel", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:GROTLE, 21], [:SUNKERN, 23], [:SERVINE, 30]]
    },
:ARENA_TRAINER_AROMALADY_14 => {
      :name => "Azalée", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LEAFEON, 29]]
    },
:ARENA_TRAINER_AROMALADY_15 => {
      :name => "Léonie", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:ROSELIA, 22], [:SWADLOON, 25]]
    },
:ARENA_TRAINER_AROMALADY_16 => {
      :name => "Victoire", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:VICTREEBEL, 35]]
    },
:ARENA_TRAINER_AROMALADY_17 => {
      :name => "Violette", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:EXEGGCUTE, 30], [:CARNIVINE, 32], [:JUMPLUFF, 32], [:FOONGUS, 33], [:LUDICOLO, 35], [:NUZLEAF, 37]]
    },
:ARENA_TRAINER_AROMALADY_18 => {
      :name => "Clémence", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SERVINE, 31], [:SNOVER, 33], [:BELLOSSOM, 37], [:LUDICOLO, 40]]
    },
:ARENA_TRAINER_AROMALADY_19 => {
      :name => "Jacinthe", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:VENUSAUR, 32], [:WHIMSICOTT, 39], [:PARASECT, 40]]
    },
:ARENA_TRAINER_AROMALADY_20 => {
      :name => "Cerise", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SUNKERN, 30], [:DUSTOX, 31], [:EXEGGUTOR, 36], [:SUNFLORA, 37], [:FERROSEED, 37], [:LILLIGANT, 39]]
    },
:ARENA_TRAINER_AROMALADY_21 => {
      :name => "Aurore", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LUDICOLO, 40], [:SHIFTRY, 41], [:ROSELIA, 47], [:TROPIUS, 48], [:WHIMSICOTT, 48]]
    },
:ARENA_TRAINER_AROMALADY_22 => {
      :name => "Iris", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:PETILIL, 42], [:TANGROWTH, 46], [:CARNIVINE, 48], [:PARASECT, 49]]
    },
:ARENA_TRAINER_AROMALADY_23 => {
      :name => "Mélisande", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SAWSBUCK, 40], [:LEDIAN, 40], [:SUNFLORA, 45], [:VENUSAUR, 50]]
    },
:ARENA_TRAINER_AROMALADY_24 => {
      :name => "Camélia", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:VICTREEBEL, 41], [:PETILIL, 42], [:VESPIQUEN, 43], [:ROSERADE, 44], [:LEAFEON, 46]]
    },
:ARENA_TRAINER_AROMALADY_25 => {
      :name => "Mathilde", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TROPIUS, 40], [:ABOMASNOW, 44], [:LILLIGANT, 44], [:BEAUTIFLY, 46], [:VICTREEBEL, 47], [:CARNIVINE, 48]]
    },
:ARENA_TRAINER_AROMALADY_26 => {
      :name => "Mirabelle", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:WHIMSICOTT, 53], [:ROSELIA, 56], [:VENUSAUR, 57], [:JUMPLUFF, 59], [:ILLUMISE, 60], [:CACTURNE, 60]]
    },
:ARENA_TRAINER_AROMALADY_27 => {
      :name => "Jasmine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:MARACTUS, 54], [:CHERRIM, 54], [:LEAFEON, 56], [:TORTERRA, 59]]
    },
:ARENA_TRAINER_AROMALADY_28 => {
      :name => "Philomène", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SCEPTILE, 53], [:WHIMSICOTT, 56], [:TROPIUS, 58], [:TANGROWTH, 59], [:MEGANIUM, 59], [:CARNIVINE, 60]]
    },
:ARENA_TRAINER_AROMALADY_29 => {
      :name => "Solange", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:MARACTUS, 52], [:CRADILY, 57], [:TROPIUS, 58]]
    },
:ARENA_TRAINER_AROMALADY_30 => {
      :name => "Prune", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:ABOMASNOW, 50], [:JUMPLUFF, 55], [:SIMISAGE, 57], [:ROSELIA, 60], [:TORTERRA, 60]]
    },
:ARENA_TRAINER_AROMALADY_31 => {
      :name => "Adélaïde", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:ABOMASNOW, 60], [:SCEPTILE, 64], [:PARASECT, 65], [:TANGROWTH, 65]]
    },
:ARENA_TRAINER_AROMALADY_32 => {
      :name => "Madeleine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TORTERRA, 68], [:SUNFLORA, 70], [:FERROTHORN, 70]]
    },
:ARENA_TRAINER_AROMALADY_33 => {
      :name => "Joséphine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LILLIGANT, 60], [:WHIMSICOTT, 60], [:MARACTUS, 66], [:CACTURNE, 67], [:VESPIQUEN, 69]]
    },
:ARENA_TRAINER_AROMALADY_34 => {
      :name => "Capucine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SAWSBUCK, 60], [:TANGROWTH, 63], [:VESPIQUEN, 66], [:LEAVANNY, 69]]
    },
:ARENA_TRAINER_AROMALADY_35 => {
      :name => "Pivoine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:VENUSAUR, 61], [:VILEPLUME, 65]]
    },
:ARENA_TRAINER_AROMALADY_36 => {
      :name => "Bérénice", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:CACTURNE, 75]]
    },
:ARENA_TRAINER_AROMALADY_37 => {
      :name => "Rosalie", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:AMOONGUSS, 73], [:CHERRIM, 75], [:ROSELIA, 77], [:ABOMASNOW, 80]]
    },
:ARENA_TRAINER_AROMALADY_38 => {
      :name => "Gwendoline", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:WORMADAM, 70], [:TROPIUS, 72], [:SAWSBUCK, 77], [:FERROTHORN, 77], [:SCEPTILE, 80]]
    },
:ARENA_TRAINER_AROMALADY_39 => {
      :name => "Olympe", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LEAVANNY, 70], [:SAWSBUCK, 71], [:SCEPTILE, 73], [:SERPERIOR, 73], [:LEAFEON, 76], [:VOLBEAT, 77]]
    },
:ARENA_TRAINER_AROMALADY_40 => {
      :name => "Bruyère", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:MEGANIUM, 72], [:ROSERADE, 72], [:CHERRIM, 73], [:TANGROWTH, 78], [:VICTREEBEL, 80]]
    },
:ARENA_TRAINER_AROMALADY_41 => {
      :name => "Cécile", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:FERROTHORN, 89]]
    },
:ARENA_TRAINER_AROMALADY_42 => {
      :name => "Marguerite", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:AMOONGUSS, 80], [:VENUSAUR, 81], [:WHIMSICOTT, 84], [:CARNIVINE, 90], [:LEAFEON, 90]]
    },
:ARENA_TRAINER_AROMALADY_43 => {
      :name => "Séraphine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:VENUSAUR, 80], [:SERPERIOR, 81], [:WORMADAM, 83], [:LILLIGANT, 83], [:ABOMASNOW, 83], [:PARASECT, 85]]
    },
:ARENA_TRAINER_AROMALADY_44 => {
      :name => "Daphné", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TORTERRA, 85], [:SERPERIOR, 89]]
    },
:ARENA_TRAINER_AROMALADY_45 => {
      :name => "Hortense", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LUDICOLO, 82], [:CARNIVINE, 82], [:TROPIUS, 90]]
    },
:ARENA_TRAINER_AROMALADY_46 => {
      :name => "Lavande", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:WORMADAM, 92], [:SCEPTILE, 98]]
    },
:ARENA_TRAINER_AROMALADY_47 => {
      :name => "Magnolia", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:LEAFEON, 92], [:TROPIUS, 92], [:TANGROWTH, 96], [:FERROTHORN, 97], [:VENUSAUR, 97]]
    },
:ARENA_TRAINER_AROMALADY_48 => {
      :name => "Perrine", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:SHIFTRY, 90], [:SCEPTILE, 92], [:SIMISAGE, 95], [:LEDIAN, 95], [:ROSERADE, 100]]
    },
:ARENA_TRAINER_AROMALADY_49 => {
      :name => "Colombe", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:ROSERADE, 91], [:VICTREEBEL, 91], [:CHERRIM, 91], [:BEAUTIFLY, 96], [:LEAFEON, 100]]
    },
:ARENA_TRAINER_AROMALADY_50 => {
      :name => "Marthe", :sprite => "trainer_AROMALADY", :type => :AROMALADY,
      :team => [[:TORTERRA, 91], [:FERROTHORN, 92], [:ROSERADE, 92], [:CRADILY, 95]]
    },
 :ARENA_TRAINER_BURGLAR_1 => {
      :name => "Zoubir", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:KOFFING, 5], [:CHARMENDER, 4]]
    },
:ARENA_TRAINER_BURGLAR_2 => {
      :name => "Billy", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:ZUBAT, 2], [:TEDDIURSA, 4], [:KLINK, 4], [:KOFFING, 5], [:SANDILE, 6], [:MAWILE, 10]]
    },
:ARENA_TRAINER_BURGLAR_3 => {
      :name => "Bonnot", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DIGLETT, 2], [:GOTHITA, 3], [:YAMASK, 4], [:AIPOM, 6], [:MEOWTH, 7], [:KLINK, 10]]
    },
:ARENA_TRAINER_BURGLAR_4 => {
      :name => "Nono", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DIGLETT, 4], [:AIPOM, 9]]
    },
:ARENA_TRAINER_BURGLAR_5 => {
      :name => "Kiki", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:VOLTORB, 5], [:TEDDIURSA, 7], [:PHANPY, 7]]
    },
:ARENA_TRAINER_BURGLAR_6 => {
      :name => "Danny", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:SANDILE, 10], [:MISDREAVUS, 12], [:SNEASEL, 15], [:KOFFING, 15], [:STUNKY, 16], [:MURKROW, 17]]
    },
:ARENA_TRAINER_BURGLAR_7 => {
      :name => "Mickey", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MEOWTH, 13], [:PACHIRISU, 17], [:DRILBUR, 17], [:SHEDINJA, 20]]
    },
:ARENA_TRAINER_BURGLAR_8 => {
      :name => "Fantômas", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MURKROW, 15]]
    },
:ARENA_TRAINER_BURGLAR_9 => {
      :name => "Loulou", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:GASTLY, 10], [:DRILBUR, 12], [:SANDILE, 13], [:ZIGZAGOON, 14], [:TEDDIURSA, 19]]
    },
:ARENA_TRAINER_BURGLAR_10 => {
      :name => "Zézé", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DITTO, 10], [:AIPOM, 11], [:DUSKULL, 15], [:MURKROW, 16], [:SABLEYE, 19]]
    },
:ARENA_TRAINER_BURGLAR_11 => {
      :name => "Momo", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MURKROW, 23], [:STUNKY, 26], [:GOTHITA, 29]]
    },
:ARENA_TRAINER_BURGLAR_12 => {
      :name => "Dillinger", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MISDREAVUS, 28]]
    },
:ARENA_TRAINER_BURGLAR_13 => {
      :name => "Toto", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:ZUBAT, 21], [:VOLTORB, 22], [:SPIRITOMB, 26]]
    },
:ARENA_TRAINER_BURGLAR_14 => {
      :name => "Gégé", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:SHEDINJA, 20], [:MISDREAVUS, 21], [:SNEASEL, 22], [:PAWNIARD, 25], [:KECLEON, 30]]
    },
:ARENA_TRAINER_BURGLAR_15 => {
      :name => "Vidocq", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MAGNEMITE, 24], [:NINJASK, 26]]
    },
:ARENA_TRAINER_BURGLAR_16 => {
      :name => "Dédé", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:AIPOM, 31], [:MAWILE, 31], [:URSARING, 33], [:YAMASK, 34], [:CROBAT, 37], [:HAUNTER, 39]]
    },
:ARENA_TRAINER_BURGLAR_17 => {
      :name => "Arsène", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:HAUNTER, 36]]
    },
:ARENA_TRAINER_BURGLAR_18 => {
      :name => "Mimile", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:EXCADRILL, 31], [:SNEASEL, 38], [:BANETTE, 39]]
    },
:ARENA_TRAINER_BURGLAR_19 => {
      :name => "Cartouche", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:EXCADRILL, 36], [:URSARING, 37], [:BANETTE, 38], [:DITTO, 39], [:ZOROARK, 39]]
    },
:ARENA_TRAINER_BURGLAR_20 => {
      :name => "Fifi", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:URSARING, 31], [:KROKOROK, 31], [:DRILBUR, 31], [:HYPNO, 33], [:GOTHORITA, 35], [:AIPOM, 37]]
    },
:ARENA_TRAINER_BURGLAR_21 => {
      :name => "Carlos", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:URSARING, 42], [:DUGTRIO, 44], [:KROOKODILE, 44], [:HYPNO, 45]]
    },
:ARENA_TRAINER_BURGLAR_22 => {
      :name => "Coco", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:WEAVILE, 42], [:MAGNEZONE, 43], [:SNEASEL, 47]]
    },
:ARENA_TRAINER_BURGLAR_23 => {
      :name => "Yanis", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:GOTHITELLE, 43], [:ZOROARK, 47], [:DITTO, 48]]
    },
:ARENA_TRAINER_BURGLAR_24 => {
      :name => "Pierrot", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:ELECTRODE, 40], [:GOTHITELLE, 49]]
    },
:ARENA_TRAINER_BURGLAR_25 => {
      :name => "Jojo", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:BANETTE, 43], [:LIEPARD, 44], [:ZOROARK, 45], [:NINJASK, 46], [:GOTHITELLE, 48], [:KECLEON, 50]]
    },
:ARENA_TRAINER_BURGLAR_26 => {
      :name => "Linus", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:ELECTRODE, 51], [:KLINKLANG, 56], [:MISMAGIUS, 57], [:LINOONE, 58], [:EXCADRILL, 60]]
    },
:ARENA_TRAINER_BURGLAR_27 => {
      :name => "Mandrin", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:GOTHITELLE, 54], [:DUSKNOIR, 60]]
    },
:ARENA_TRAINER_BURGLAR_28 => {
      :name => "Rico", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:LINOONE, 50], [:KROOKODILE, 53], [:GOTHITELLE, 54], [:URSARING, 54], [:AMBIPOM, 55]]
    },
:ARENA_TRAINER_BURGLAR_29 => {
      :name => "Jesse", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:BANETTE, 50], [:HONCHKROW, 56]]
    },
:ARENA_TRAINER_BURGLAR_30 => {
      :name => "Frankie", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:LAMPENT, 52], [:EXCADRILL, 58]]
    },
:ARENA_TRAINER_BURGLAR_31 => {
      :name => "Bébert", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:GOTHITELLE, 60], [:SHEDINJA, 70], [:DUSKNOIR, 70]]
    },
:ARENA_TRAINER_BURGLAR_32 => {
      :name => "Rusty", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DUSKNOIR, 60], [:CHANDELURE, 67], [:SPIRITOMB, 69], [:NINJASK, 69]]
    },
:ARENA_TRAINER_BURGLAR_33 => {
      :name => "Jacquot", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DITTO, 61], [:GOLBAT, 67], [:URSARING, 67], [:PERSIAN, 69], [:MAGNETON, 70]]
    },
:ARENA_TRAINER_BURGLAR_34 => {
      :name => "Riton", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:BISHARP, 62], [:KECLEON, 70]]
    },
:ARENA_TRAINER_BURGLAR_35 => {
      :name => "Raffles", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:CROBAT, 61], [:GENGAR, 63], [:PERSIAN, 65], [:MAGNEZONE, 65], [:CHANDELURE, 67], [:GOLBAT, 70]]
    },
:ARENA_TRAINER_BURGLAR_36 => {
      :name => "Fredo", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DUSKNOIR, 70], [:KECLEON, 77]]
    },
:ARENA_TRAINER_BURGLAR_37 => {
      :name => "Saul", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MAGNETON, 70], [:PACHIRISU, 73], [:KROOKODILE, 76], [:BANETTE, 78]]
    },
:ARENA_TRAINER_BURGLAR_38 => {
      :name => "Bobby", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:DUGTRIO, 71], [:KROOKODILE, 71], [:LINOONE, 76], [:DITTO, 78], [:SHEDINJA, 79]]
    },
:ARENA_TRAINER_BURGLAR_39 => {
      :name => "Terry", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:HONCHKROW, 71], [:CROBAT, 72], [:BANETTE, 72], [:GOLBAT, 74], [:HAUNTER, 76], [:COFAGRIGUS, 78]]
    },
:ARENA_TRAINER_BURGLAR_40 => {
      :name => "Dodo", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:LINOONE, 75]]
    },
:ARENA_TRAINER_BURGLAR_41 => {
      :name => "Gaston", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:BANETTE, 90]]
    },
:ARENA_TRAINER_BURGLAR_42 => {
      :name => "Rémi", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:GOLBAT, 86], [:DUSKNOIR, 88], [:URSARING, 90]]
    },
:ARENA_TRAINER_BURGLAR_43 => {
      :name => "Roro", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:KLINKLANG, 84], [:SABLEYE, 84], [:HYPNO, 85], [:BISHARP, 87]]
    },
:ARENA_TRAINER_BURGLAR_44 => {
      :name => "Vinny", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:KECLEON, 82], [:CHANDELURE, 89]]
    },
:ARENA_TRAINER_BURGLAR_45 => {
      :name => "Titi", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:PERSIAN, 88], [:BANETTE, 90], [:HONCHKROW, 90]]
    },
:ARENA_TRAINER_BURGLAR_46 => {
      :name => "Lenny", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:NINJASK, 99]]
    },
:ARENA_TRAINER_BURGLAR_47 => {
      :name => "Max", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MAGNETON, 91], [:DUSCLOPS, 92], [:URSARING, 92], [:KROOKODILE, 93], [:MISMAGIUS, 94], [:AMBIPOM, 98]]
    },
:ARENA_TRAINER_BURGLAR_48 => {
      :name => "Sundance", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:MAGNETON, 90], [:KLINKLANG, 93], [:MISMAGIUS, 94], [:EXCADRILL, 95], [:KROOKODILE, 97], [:SHEDINJA, 98]]
    },
:ARENA_TRAINER_BURGLAR_49 => {
      :name => "Albert", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:KROOKODILE, 90], [:AMBIPOM, 91], [:ZOROARK, 94], [:EXCADRILL, 100]]
    },
:ARENA_TRAINER_BURGLAR_50 => {
      :name => "Tonio", :sprite => "trainer_BURGLAR", :type => :BURGLAR,
      :team => [[:EXCADRILL, 96], [:HYPNO, 99]]
    },
:ARENA_TRAINER_CHANNELER_1 => {
      :name => "Jason", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:LITWICK, 5], [:GASTLY, 4]]
    },
:ARENA_TRAINER_CHANNELER_2 => {
      :name => "Lestat", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:GOTHITA, 5], [:POOCHYENA, 6], [:DROWZEE, 6], [:DUSKULL, 7], [:ZUBAT, 8]]
    },
:ARENA_TRAINER_CHANNELER_3 => {
      :name => "Cerbère", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:GOLETT, 3], [:HOUNDOUR, 5], [:DRIFLOON, 6], [:DUSKULL, 6]]
    },
:ARENA_TRAINER_CHANNELER_4 => {
      :name => "Morphée", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:LITWICK, 2], [:YAMASK, 3], [:GOTHITA, 5], [:CARVANHA, 7], [:DEINO, 10]]
    },
:ARENA_TRAINER_CHANNELER_5 => {
      :name => "Mordred", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:POOCHYENA, 3], [:VULLABY, 9], [:PURRLOIN, 9]]
    },
:ARENA_TRAINER_CHANNELER_6 => {
      :name => "Gaspard", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SKORUPI, 11], [:GOLETT, 18]]
    },
:ARENA_TRAINER_CHANNELER_7 => {
      :name => "Belzébuth", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SNEASEL, 10], [:VULLABY, 11], [:POOCHYENA, 15], [:SABLEYE, 16], [:YAMASK, 17], [:PAWNIARD, 17]]
    },
:ARENA_TRAINER_CHANNELER_8 => {
      :name => "Lazare", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:EKANS, 10], [:POOCHYENA, 13], [:DEINO, 13], [:GOLETT, 17]]
    },
:ARENA_TRAINER_CHANNELER_9 => {
      :name => "Astaroth", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:CARVANHA, 12], [:FRILLISH, 13], [:YAMASK, 18], [:SKORUPI, 19]]
    },
:ARENA_TRAINER_CHANNELER_10 => {
      :name => "Théophile", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:LITWICK, 20]]
    },
:ARENA_TRAINER_CHANNELER_11 => {
      :name => "Dagon", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:MIGHTYENA, 20], [:CROAGUNK, 23], [:DRIFLOON, 26], [:PAWNIARD, 29], [:KROKOROK, 29], [:HOUNDOOM, 30]]
    },
:ARENA_TRAINER_CHANNELER_12 => {
      :name => "Seth", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DEINO, 26]]
    },
:ARENA_TRAINER_CHANNELER_13 => {
      :name => "Nostradamus", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ROTOM, 30]]
    },
:ARENA_TRAINER_CHANNELER_14 => {
      :name => "Belial", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSKULL, 25]]
    },
:ARENA_TRAINER_CHANNELER_15 => {
      :name => "Érèbe", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:MIGHTYENA, 25]]
    },
:ARENA_TRAINER_CHANNELER_16 => {
      :name => "Barnabas", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ARIADOS, 34], [:CACTURNE, 34], [:SKORUPI, 35], [:PAWNIARD, 35], [:SHEDINJA, 38], [:SNEASEL, 39]]
    },
:ARENA_TRAINER_CHANNELER_17 => {
      :name => "Pluton", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ZOROARK, 32], [:COFAGRIGUS, 36]]
    },
:ARENA_TRAINER_CHANNELER_18 => {
      :name => "Ambroise", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:HONCHKROW, 31], [:VULLABY, 34], [:GENGAR, 39], [:HOUNDOOM, 40]]
    },
:ARENA_TRAINER_CHANNELER_19 => {
      :name => "Samael", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SHARPEDO, 31], [:FRILLISH, 31], [:ARIADOS, 33], [:KROKOROK, 36], [:BANETTE, 37], [:ZOROARK, 38]]
    },
:ARENA_TRAINER_CHANNELER_20 => {
      :name => "Lucifer", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:UMBREON, 30], [:HAUNTER, 33], [:HONCHKROW, 35], [:SEVIPER, 37], [:SABLEYE, 39], [:ROTOM, 40]]
    },
:ARENA_TRAINER_CHANNELER_21 => {
      :name => "Baal", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:KROOKODILE, 45]]
    },
:ARENA_TRAINER_CHANNELER_22 => {
      :name => "Malachie", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:PAWNIARD, 40], [:KROOKODILE, 46], [:SEVIPER, 48], [:SHARPEDO, 49]]
    },
:ARENA_TRAINER_CHANNELER_23 => {
      :name => "Ignace", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SPIRITOMB, 50]]
    },
:ARENA_TRAINER_CHANNELER_24 => {
      :name => "Odin", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:CROBAT, 43], [:HONCHKROW, 48], [:LAMPENT, 50]]
    },
:ARENA_TRAINER_CHANNELER_25 => {
      :name => "Loki", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:LITWICK, 40], [:DRAPION, 45]]
    },
:ARENA_TRAINER_CHANNELER_26 => {
      :name => "Morbius", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:VULLABY, 50], [:COFAGRIGUS, 54], [:HONCHKROW, 59]]
    },
:ARENA_TRAINER_CHANNELER_27 => {
      :name => "Osiris", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ROTOM, 55]]
    },
:ARENA_TRAINER_CHANNELER_28 => {
      :name => "Cornélius", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:UMBREON, 50], [:GOLURK, 51], [:DRAPION, 53], [:ARIADOS, 58], [:ABSOL, 60]]
    },
:ARENA_TRAINER_CHANNELER_29 => {
      :name => "Hadès", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:KROOKODILE, 55], [:TYRANITAR, 56]]
    },
:ARENA_TRAINER_CHANNELER_30 => {
      :name => "Melchior", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ARIADOS, 50], [:MIGHTYENA, 51], [:HAUNTER, 52], [:JELLICENT, 59], [:MANDIBUZZ, 59], [:ABSOL, 60]]
    },
:ARENA_TRAINER_CHANNELER_31 => {
      :name => "Absalon", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ZWEILOUS, 60], [:SHEDINJA, 62], [:JELLICENT, 67], [:BISHARP, 69]]
    },
:ARENA_TRAINER_CHANNELER_32 => {
      :name => "Wolfgang", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:GENGAR, 60], [:SPIRITOMB, 62], [:DUSKNOIR, 66], [:MIGHTYENA, 67]]
    },
:ARENA_TRAINER_CHANNELER_33 => {
      :name => "Damien", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SPIRITOMB, 60], [:GOTHITELLE, 61], [:DRIFBLIM, 62], [:MANDIBUZZ, 65]]
    },
:ARENA_TRAINER_CHANNELER_34 => {
      :name => "Anubis", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:BANETTE, 60], [:KROOKODILE, 66], [:HOUNDOOM, 69]]
    },
:ARENA_TRAINER_CHANNELER_35 => {
      :name => "Fenrir", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSCLOPS, 60], [:HAUNTER, 60], [:DRAPION, 61], [:ABSOL, 61], [:SHEDINJA, 65]]
    },
:ARENA_TRAINER_CHANNELER_36 => {
      :name => "Moloch", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:ABSOL, 75]]
    },
:ARENA_TRAINER_CHANNELER_37 => {
      :name => "Azazel", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSKNOIR, 76], [:KROOKODILE, 77]]
    },
:ARENA_TRAINER_CHANNELER_38 => {
      :name => "Lucius", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:CROBAT, 74], [:GOLURK, 75], [:TYRANITAR, 79]]
    },
:ARENA_TRAINER_CHANNELER_39 => {
      :name => "Mammon", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:GOLURK, 70], [:CHANDELURE, 74], [:DUSKNOIR, 74], [:CACTURNE, 80]]
    },
:ARENA_TRAINER_CHANNELER_40 => {
      :name => "Azrael", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:HYDREIGON, 76]]
    },
:ARENA_TRAINER_CHANNELER_41 => {
      :name => "Rasputin", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:HONCHKROW, 81], [:HOUNDOOM, 82], [:CHANDELURE, 87], [:GOLURK, 88], [:JELLICENT, 89], [:MIGHTYENA, 90]]
    },
:ARENA_TRAINER_CHANNELER_42 => {
      :name => "Ankou", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:CACTURNE, 80], [:JELLICENT, 81], [:COFAGRIGUS, 82], [:TYRANITAR, 83], [:MANDIBUZZ, 84], [:SABLEYE, 88]]
    },
:ARENA_TRAINER_CHANNELER_43 => {
      :name => "Dracul", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:LIEPARD, 80], [:HYPNO, 80], [:JELLICENT, 84], [:CACTURNE, 84], [:DUSCLOPS, 85]]
    },
:ARENA_TRAINER_CHANNELER_44 => {
      :name => "Ézéchiel", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:CACTURNE, 88], [:WEAVILE, 90]]
    },
:ARENA_TRAINER_CHANNELER_45 => {
      :name => "Draven", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSKNOIR, 85]]
    },
:ARENA_TRAINER_CHANNELER_46 => {
      :name => "Mordecai", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSKNOIR, 98]]
    },
:ARENA_TRAINER_CHANNELER_47 => {
      :name => "Mortimer", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:MIGHTYENA, 98]]
    },
:ARENA_TRAINER_CHANNELER_48 => {
      :name => "Faust", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:HONCHKROW, 95]]
    },
:ARENA_TRAINER_CHANNELER_49 => {
      :name => "Balthazar", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:SHARPEDO, 93], [:SABLEYE, 95]]
    },
:ARENA_TRAINER_CHANNELER_50 => {
      :name => "Abaddon", :sprite => "trainer_CHANNELER", :type => :CHANNELER,
      :team => [[:DUSKNOIR, 91], [:MISMAGIUS, 91], [:MIGHTYENA, 92], [:BISHARP, 93], [:LIEPARD, 100]]
    },
:ARENA_TRAINER_CAMPER_1 => {
      :name => "Pascal", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:CYNDAQUIL, 5], [:SHELLOS, 4]]
    },
:ARENA_TRAINER_CAMPER_2 => {
      :name => "Gaby", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:POLIWAG, 4], [:LILLIPUP, 5], [:OSHAWOTT, 6], [:SEWADDLE, 8]]
    },
:ARENA_TRAINER_CAMPER_3 => {
      :name => "Claude", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:WOOPER, 5], [:LILLIPUP, 8], [:GOLDEEN, 10]]
    },
:ARENA_TRAINER_CAMPER_4 => {
      :name => "Maurice", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MUDKIP, 3], [:MUNCHLAX, 4], [:CHIMCHAR, 5], [:REMORAID, 9], [:DRILBUR, 10]]
    },
:ARENA_TRAINER_CAMPER_5 => {
      :name => "Francky", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:REMORAID, 3], [:GOLDEEN, 4], [:BARBOACH, 7], [:TOTODILE, 9]]
    },
:ARENA_TRAINER_CAMPER_6 => {
      :name => "Christian", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:TAUROS, 15], [:HOUNDOUR, 16], [:HOOTHOOT, 16]]
    },
:ARENA_TRAINER_CAMPER_7 => {
      :name => "Jean-Michel", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:CYNDAQUIL, 10], [:POLIWAG, 13], [:STANTLER, 13], [:WOOPER, 15]]
    },
:ARENA_TRAINER_CAMPER_8 => {
      :name => "Bernard", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:SEWADDLE, 11], [:POOCHYENA, 15], [:LITWICK, 16], [:PRINPLUP, 19], [:PIKACHU, 20]]
    },
:ARENA_TRAINER_CAMPER_9 => {
      :name => "Manu", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MUNCHLAX, 12], [:SENTRET, 13], [:CUBCHOO, 15]]
    },
:ARENA_TRAINER_CAMPER_10 => {
      :name => "Dominique", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:HOOTHOOT, 12], [:FARFETCHD, 14], [:FLAAFFY, 15], [:HEATMOR, 15], [:SCYTHER, 16], [:MIGHTYENA, 19]]
    },
:ARENA_TRAINER_CAMPER_11 => {
      :name => "Gilles", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BOUFFALANT, 23], [:BIBAREL, 25]]
    },
:ARENA_TRAINER_CAMPER_12 => {
      :name => "Momo", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:RIOLU, 25]]
    },
:ARENA_TRAINER_CAMPER_13 => {
      :name => "Jean-Kévin", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:REMORAID, 20], [:PINSIR, 25]]
    },
:ARENA_TRAINER_CAMPER_14 => {
      :name => "Loulou", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:GROWLITHE, 23], [:LITWICK, 25]]
    },
:ARENA_TRAINER_CAMPER_15 => {
      :name => "Bruno", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:PRINPLUP, 23], [:PIKACHU, 27], [:MACHOKE, 29]]
    },
:ARENA_TRAINER_CAMPER_16 => {
      :name => "Jean-Claude", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:POLIWHIRL, 31], [:PSYDUCK, 33], [:WHISCASH, 36], [:PONYTA, 40]]
    },
:ARENA_TRAINER_CAMPER_17 => {
      :name => "Dédé", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:LITWICK, 31], [:HOUNDOOM, 34], [:LUCARIO, 37], [:SEAKING, 38], [:TORKOAL, 40]]
    },
:ARENA_TRAINER_CAMPER_18 => {
      :name => "Raymond", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BIBAREL, 30], [:DWEBBLE, 33], [:CRUSTLE, 35], [:GIRAFARIG, 35], [:EMBOAR, 39]]
    },
:ARENA_TRAINER_CAMPER_19 => {
      :name => "Alain", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MONFERNO, 35]]
    },
:ARENA_TRAINER_CAMPER_20 => {
      :name => "Jean-Luc", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:VOLBEAT, 31], [:HEATMOR, 32], [:MARSHTOMP, 33], [:RAICHU, 39], [:TAUROS, 40]]
    },
:ARENA_TRAINER_CAMPER_21 => {
      :name => "Robert", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MIGHTYENA, 41], [:TAUROS, 41], [:MACHAMP, 42], [:NOCTOWL, 42], [:STANTLER, 42], [:SCYTHER, 49]]
    },
:ARENA_TRAINER_CAMPER_22 => {
      :name => "Thierry", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:NINETALES, 49]]
    },
:ARENA_TRAINER_CAMPER_23 => {
      :name => "Guy", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:SWAMPERT, 40], [:TYPHLOSION, 41], [:LAMPENT, 42], [:EMBOAR, 45], [:MAGCARGO, 48]]
    },
:ARENA_TRAINER_CAMPER_24 => {
      :name => "Poupou", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:URSARING, 43], [:LAMPENT, 43], [:RAICHU, 49], [:HOUNDOOM, 49], [:SNORLAX, 49], [:GASTRODON, 50]]
    },
:ARENA_TRAINER_CAMPER_25 => {
      :name => "Titi", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:EXCADRILL, 47], [:HERACROSS, 47], [:FARFETCHD, 50]]
    },
:ARENA_TRAINER_CAMPER_26 => {
      :name => "Tonton", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BEARTIC, 56], [:AMPHAROS, 59]]
    },
:ARENA_TRAINER_CAMPER_27 => {
      :name => "Rudy", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:GOLDUCK, 52], [:OCTILLERY, 52], [:LAMPENT, 53], [:MIGHTYENA, 59]]
    },
:ARENA_TRAINER_CAMPER_28 => {
      :name => "Roger", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BIBAREL, 55], [:CHARIZARD, 57]]
    },
:ARENA_TRAINER_CAMPER_29 => {
      :name => "Bibi", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BIBAREL, 55]]
    },
:ARENA_TRAINER_CAMPER_30 => {
      :name => "René", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:LEAVANNY, 55]]
    },
:ARENA_TRAINER_CAMPER_31 => {
      :name => "Dave", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:PIKACHU, 60], [:MILTANK, 63], [:ILLUMISE, 66], [:BOUFFALANT, 69], [:BEARTIC, 70]]
    },
:ARENA_TRAINER_CAMPER_32 => {
      :name => "Jean-Marc", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:QUAGSIRE, 66]]
    },
:ARENA_TRAINER_CAMPER_33 => {
      :name => "Jean-Jacques", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:QUAGSIRE, 68]]
    },
:ARENA_TRAINER_CAMPER_34 => {
      :name => "Gégé", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:NINETALES, 62], [:EXCADRILL, 63], [:LUCARIO, 64], [:AMPHAROS, 69], [:EMBOAR, 70]]
    },
:ARENA_TRAINER_CAMPER_35 => {
      :name => "Eustache", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BEARTIC, 60], [:QUAGSIRE, 65]]
    },
:ARENA_TRAINER_CAMPER_36 => {
      :name => "Cédric", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:SEAKING, 72], [:NOCTOWL, 74], [:RAICHU, 77]]
    },
:ARENA_TRAINER_CAMPER_37 => {
      :name => "Mimile", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:BLAZIKEN, 72], [:MIGHTYENA, 75], [:MAGCARGO, 77], [:TORKOAL, 79]]
    },
:ARENA_TRAINER_CAMPER_38 => {
      :name => "Fabrice", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:ILLUMISE, 72], [:CRUSTLE, 76], [:NINETALES, 80]]
    },
:ARENA_TRAINER_CAMPER_39 => {
      :name => "Riton", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:LANTURN, 80]]
    },
:ARENA_TRAINER_CAMPER_40 => {
      :name => "Ludo", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:FERALIGATR, 75]]
    },
:ARENA_TRAINER_CAMPER_41 => {
      :name => "Nanard", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MACHOKE, 85]]
    },
:ARENA_TRAINER_CAMPER_42 => {
      :name => "Serge", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:LANTURN, 81], [:NINETALES, 82], [:STANTLER, 83], [:FURRET, 89], [:LEAVANNY, 89]]
    },
:ARENA_TRAINER_CAMPER_43 => {
      :name => "Steeve", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:FURRET, 82], [:FERALIGATR, 86], [:CHARIZARD, 88]]
    },
:ARENA_TRAINER_CAMPER_44 => {
      :name => "Kiki", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:OCTILLERY, 81], [:PIKACHU, 83], [:BOUFFALANT, 86], [:EXCADRILL, 88], [:HOUNDOOM, 89]]
    },
:ARENA_TRAINER_CAMPER_45 => {
      :name => "Dudu", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:AMPHAROS, 83], [:URSARING, 84], [:RAPIDASH, 84], [:OCTILLERY, 85], [:LANTURN, 88], [:EXCADRILL, 89]]
    },
:ARENA_TRAINER_CAMPER_46 => {
      :name => "Jean-Paul", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:FERALIGATR, 95], [:EMPOLEON, 98], [:NOCTOWL, 98]]
    },
:ARENA_TRAINER_CAMPER_47 => {
      :name => "Jean-François", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:MILTANK, 93], [:GOLDUCK, 96], [:POLIWRATH, 97]]
    },
:ARENA_TRAINER_CAMPER_48 => {
      :name => "Patrick", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:EMPOLEON, 90], [:WHISCASH, 93], [:NOCTOWL, 97], [:SCYTHER, 98], [:BLASTOISE, 100], [:POLIWRATH, 100]]
    },
:ARENA_TRAINER_CAMPER_49 => {
      :name => "Jacky", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:POLIWRATH, 92], [:HERACROSS, 95], [:MACHAMP, 98], [:NOCTOWL, 100]]
    },
:ARENA_TRAINER_CAMPER_50 => {
      :name => "Norbert", :sprite => "trainer_CAMPER", :type => :CAMPER,
      :team => [[:FERALIGATR, 91], [:RAICHU, 98]]
    },
:ARENA_TRAINER_COOLTRAINER_F_1 => {
      :name => "Pauline", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:ELEKID, 5], [:SQUIRTLE, 4]]
    },
:ARENA_TRAINER_COOLTRAINER_F_2 => {
      :name => "Naomi", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:RHYHORN, 4], [:VULPIX, 6], [:SCRAGGY, 9]]
    },
:ARENA_TRAINER_COOLTRAINER_F_3 => {
      :name => "Selma", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:CHARMANDER, 4], [:STARLY, 5], [:BELDUM, 9], [:TIMBURR, 10]]
    },
:ARENA_TRAINER_COOLTRAINER_F_4 => {
      :name => "Kimberly", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:EEVEE, 6]]
    },
:ARENA_TRAINER_COOLTRAINER_F_5 => {
      :name => "Eden", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:RIOLU, 2], [:STARLY, 2], [:SCRAGGY, 3], [:PAWNIARD, 6], [:TRAPINCH, 10]]
    },
:ARENA_TRAINER_COOLTRAINER_F_6 => {
      :name => "Mia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:RHYHORN, 10], [:AXEW, 12], [:RALTS, 13], [:MAGBY, 16], [:MURKROW, 17]]
    },
:ARENA_TRAINER_COOLTRAINER_F_7 => {
      :name => "Chiara", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GLIGAR, 11], [:ARON, 12], [:TIMBURR, 18], [:MAGBY, 19]]
    },
:ARENA_TRAINER_COOLTRAINER_F_8 => {
      :name => "Cléo", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:PINSIR, 18], [:STARAVIA, 19]]
    },
:ARENA_TRAINER_COOLTRAINER_F_9 => {
      :name => "Gaïa", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GIBLE, 10], [:LITWICK, 16], [:MAGIKARP, 17], [:SCYTHER, 18], [:DEINO, 19]]
    },
:ARENA_TRAINER_COOLTRAINER_F_10 => {
      :name => "Ruby", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:YANMA, 14], [:SNORUNT, 18]]
    },
:ARENA_TRAINER_COOLTRAINER_F_11 => {
      :name => "Vanessa", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:HOUNDOUR, 23], [:MANECTRIC, 26], [:TAUROS, 29]]
    },
:ARENA_TRAINER_COOLTRAINER_F_12 => {
      :name => "Alexia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:SANDILE, 24], [:GYARADOS, 25], [:DRATINI, 27], [:LUXIO, 27], [:SCYTHER, 28], [:STARAVIA, 29]]
    },
:ARENA_TRAINER_COOLTRAINER_F_13 => {
      :name => "Zoé", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:LARVITAR, 21], [:PAWNIARD, 25]]
    },
:ARENA_TRAINER_COOLTRAINER_F_14 => {
      :name => "Roxane", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GIBLE, 20], [:LARVESTA, 21], [:LOPUNNY, 25]]
    },
:ARENA_TRAINER_COOLTRAINER_F_15 => {
      :name => "Kiara", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:TRAPINCH, 25], [:MAGBY, 25], [:JOLTEON, 29]]
    },
:ARENA_TRAINER_COOLTRAINER_F_16 => {
      :name => "Nova", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:BAGON, 30], [:GALLADE, 33], [:LUCARIO, 35], [:SNORUNT, 35], [:TAUROS, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_F_17 => {
      :name => "Nikita", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:ELECTABUZZ, 32], [:ESPEON, 33], [:YANMA, 39], [:ROSERADE, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_F_18 => {
      :name => "Dakota", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MILOTIC, 30], [:PINSIR, 31], [:SNORUNT, 35], [:WEAVILE, 35], [:NINETALES, 37], [:LOPUNNY, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_F_19 => {
      :name => "Safia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:SCRAGGY, 35], [:GLACEON, 37]]
    },
:ARENA_TRAINER_COOLTRAINER_F_20 => {
      :name => "Stella", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:WEAVILE, 30], [:LOPUNNY, 31], [:EXCADRILL, 38], [:SHARPEDO, 39], [:EMPOLEON, 40]]
    },
:ARENA_TRAINER_COOLTRAINER_F_21 => {
      :name => "Amber", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:FROSLASS, 45]]
    },
:ARENA_TRAINER_COOLTRAINER_F_22 => {
      :name => "Léna", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:WEAVILE, 41], [:VAPOREON, 43], [:LUXRAY, 43], [:YANMEGA, 47], [:GARCHOMP, 49]]
    },
:ARENA_TRAINER_COOLTRAINER_F_23 => {
      :name => "Noa", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:ELECTABUZZ, 40], [:FERALIGATR, 42], [:PUPITAR, 43], [:DRAGONAIR, 46], [:NINETALES, 47], [:BLAZIKEN, 48]]
    },
:ARENA_TRAINER_COOLTRAINER_F_24 => {
      :name => "Lexie", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MISMAGIUS, 41], [:BLAZIKEN, 45]]
    },
:ARENA_TRAINER_COOLTRAINER_F_25 => {
      :name => "Léonie", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:WEAVILE, 44], [:GLALIE, 48], [:SAMUROTT, 48]]
    },
:ARENA_TRAINER_COOLTRAINER_F_26 => {
      :name => "Giulia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:EXCADRILL, 54], [:UMBREON, 55], [:GYARADOS, 55], [:PINSIR, 60]]
    },
:ARENA_TRAINER_COOLTRAINER_F_27 => {
      :name => "Aria", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:SERPERIOR, 58], [:SCYTHER, 60], [:SNEASEL, 60]]
    },
:ARENA_TRAINER_COOLTRAINER_F_28 => {
      :name => "Yasmine", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:ABSOL, 55]]
    },
:ARENA_TRAINER_COOLTRAINER_F_29 => {
      :name => "Raven", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:FERALIGATR, 51], [:AGGRON, 52], [:GLALIE, 54], [:LOPUNNY, 57], [:EMPOLEON, 58]]
    },
:ARENA_TRAINER_COOLTRAINER_F_30 => {
      :name => "Skylar", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MAMOSWINE, 53], [:GLACEON, 54], [:ZOROARK, 55], [:TYPHLOSION, 56], [:UMBREON, 56]]
    },
:ARENA_TRAINER_COOLTRAINER_F_31 => {
      :name => "Kim", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:TYPHLOSION, 61], [:LEAFEON, 65]]
    },
:ARENA_TRAINER_COOLTRAINER_F_32 => {
      :name => "Lyra", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:JOLTEON, 60], [:EMPOLEON, 64], [:ELECTIVIRE, 65]]
    },
:ARENA_TRAINER_COOLTRAINER_F_33 => {
      :name => "Kayla", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:TAUROS, 60], [:MISMAGIUS, 62], [:INFERNAPE, 62], [:HONCHKROW, 68]]
    },
:ARENA_TRAINER_COOLTRAINER_F_34 => {
      :name => "Kenza", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GYARADOS, 65]]
    },
:ARENA_TRAINER_COOLTRAINER_F_35 => {
      :name => "Jenna", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MILOTIC, 60], [:GARDEVOIR, 62], [:SCRAFTY, 62], [:FERALIGATR, 63], [:BISHARP, 68]]
    },
:ARENA_TRAINER_COOLTRAINER_F_36 => {
      :name => "Thalia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:NINETALES, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_F_37 => {
      :name => "Skye", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:EMPOLEON, 70], [:DUSKNOIR, 73], [:STARAPTOR, 79]]
    },
:ARENA_TRAINER_COOLTRAINER_F_38 => {
      :name => "Mélina", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GARDEVOIR, 70], [:HONCHKROW, 72], [:ZOROARK, 78]]
    },
:ARENA_TRAINER_COOLTRAINER_F_39 => {
      :name => "Océane", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:FROSLASS, 76], [:TYPHLOSION, 78], [:LOPUNNY, 79], [:GALLADE, 80], [:CHANDELURE, 80]]
    },
:ARENA_TRAINER_COOLTRAINER_F_40 => {
      :name => "Tess", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:TORTERRA, 74], [:HERACROSS, 77], [:RHYPERIOR, 78]]
    },
:ARENA_TRAINER_COOLTRAINER_F_41 => {
      :name => "Ivy", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MAGMAR, 85], [:GARCHOMP, 86], [:TOXICROAK, 88], [:HAXORUS, 90]]
    },
:ARENA_TRAINER_COOLTRAINER_F_42 => {
      :name => "Maeva", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:HONCHKROW, 80], [:SCRAFTY, 85], [:DRAPION, 86], [:HERACROSS, 87], [:MAMOSWINE, 88], [:LUXRAY, 90]]
    },
:ARENA_TRAINER_COOLTRAINER_F_43 => {
      :name => "Tiffany", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GYARADOS, 89]]
    },
:ARENA_TRAINER_COOLTRAINER_F_44 => {
      :name => "Elena", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:SKARMORY, 81], [:BRAVIARY, 81], [:LUXRAY, 85], [:SALAMENCE, 86], [:MILOTIC, 88]]
    },
:ARENA_TRAINER_COOLTRAINER_F_45 => {
      :name => "Lisa", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:MAGMAR, 86], [:SERPERIOR, 87]]
    },
:ARENA_TRAINER_COOLTRAINER_F_46 => {
      :name => "Maya", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GLACEON, 91], [:HOUNDOOM, 94], [:TORTERRA, 97], [:VOLCARONA, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_F_47 => {
      :name => "Lou", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:HONCHKROW, 90], [:SCYTHER, 92], [:SERPERIOR, 93], [:TAUROS, 93], [:CHANDELURE, 94], [:GALLADE, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_F_48 => {
      :name => "Karma", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:GALLADE, 90], [:JOLTEON, 93], [:MAGMORTAR, 95]]
    },
:ARENA_TRAINER_COOLTRAINER_F_49 => {
      :name => "Shana", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:SCYTHER, 93], [:UMBREON, 95], [:SCEPTILE, 99], [:SKARMORY, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_F_50 => {
      :name => "Alicia", :sprite => "trainer_COOLTRAINER_F", :type => :COOLTRAINER_F,
      :team => [[:VOLCARONA, 90], [:METAGROSS, 93], [:BLAZIKEN, 93], [:DRAPION, 97], [:TAUROS, 97], [:GLACEON, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_M_1 => {
      :name => "Loris", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:CHARMANDER, 5], [:AXEW, 4]]
    },
:ARENA_TRAINER_COOLTRAINER_M_2 => {
      :name => "Tyler", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GROWLITHE, 5], [:CHARMANDER, 8]]
    },
:ARENA_TRAINER_COOLTRAINER_M_3 => {
      :name => "Xavier", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GROWLITHE, 6], [:RHYHORN, 8], [:ELEKID, 8], [:GIBLE, 9], [:LITWICK, 10]]
    },
:ARENA_TRAINER_COOLTRAINER_M_4 => {
      :name => "Gabin", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:ABRA, 4], [:BAGON, 6]]
    },
:ARENA_TRAINER_COOLTRAINER_M_5 => {
      :name => "Noah", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:PAWNIARD, 6]]
    },
:ARENA_TRAINER_COOLTRAINER_M_6 => {
      :name => "Jett", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:EEVEE, 10], [:DEINO, 12], [:VULPIX, 14], [:MAGIKARP, 15], [:BAGON, 20]]
    },
:ARENA_TRAINER_COOLTRAINER_M_7 => {
      :name => "Diego", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:DRATINI, 14], [:SNEASEL, 16], [:GLIGAR, 17]]
    },
:ARENA_TRAINER_COOLTRAINER_M_8 => {
      :name => "Zayn", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:TRAPINCH, 12], [:CHARMANDER, 12], [:DRATINI, 13], [:SANDILE, 19], [:ZORUA, 20]]
    },
:ARENA_TRAINER_COOLTRAINER_M_9 => {
      :name => "Logan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:STARLY, 10], [:LARVESTA, 14], [:CHARMANDER, 14], [:GROWLITHE, 16], [:HOUNDOUR, 16], [:STARAVIA, 19]]
    },
:ARENA_TRAINER_COOLTRAINER_M_10 => {
      :name => "Nolan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:RHYHORN, 10], [:RUFFLET, 14], [:CHARMANDER, 16], [:EEVEE, 17], [:PINSIR, 18], [:MAGIKARP, 19]]
    },
:ARENA_TRAINER_COOLTRAINER_M_11 => {
      :name => "Tristan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:HOUNDOUR, 20], [:VULPIX, 21], [:MAGBY, 21], [:HITMONTOP, 26], [:VAPOREON, 28], [:FEEBAS, 28]]
    },
:ARENA_TRAINER_COOLTRAINER_M_12 => {
      :name => "Dylan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GLIGAR, 20], [:VAPOREON, 23], [:DEINO, 24], [:RIOLU, 27]]
    },
:ARENA_TRAINER_COOLTRAINER_M_13 => {
      :name => "Maverick", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:HOUNDOUR, 21], [:TAUROS, 27], [:DEINO, 29]]
    },
:ARENA_TRAINER_COOLTRAINER_M_14 => {
      :name => "Ryan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:HITMONTOP, 23], [:TRAPINCH, 26], [:AXEW, 26], [:RIOLU, 27], [:MANECTRIC, 27]]
    },
:ARENA_TRAINER_COOLTRAINER_M_15 => {
      :name => "Vince", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:BAGON, 30]]
    },
:ARENA_TRAINER_COOLTRAINER_M_16 => {
      :name => "Mathis", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:ROSERADE, 32], [:DEINO, 34], [:MANECTRIC, 34], [:ALAKAZAM, 37], [:VAPOREON, 39], [:GLIGAR, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_M_17 => {
      :name => "Kane", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:WEAVILE, 34], [:MURKROW, 34], [:LUCARIO, 34], [:BLAZIKEN, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_M_18 => {
      :name => "Yanis", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GLIGAR, 34], [:CROBAT, 35]]
    },
:ARENA_TRAINER_COOLTRAINER_M_19 => {
      :name => "Luka", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:VIBRAVA, 35], [:WEAVILE, 35], [:TORTERRA, 37]]
    },
:ARENA_TRAINER_COOLTRAINER_M_20 => {
      :name => "Elias", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:ELECTABUZZ, 30], [:ESPEON, 31], [:GLACEON, 32], [:LUXRAY, 36], [:HITMONCHAN, 39]]
    },
:ARENA_TRAINER_COOLTRAINER_M_21 => {
      :name => "Liam", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:DRAPION, 40], [:LUXRAY, 43], [:KROOKODILE, 44], [:HITMONLEE, 45]]
    },
:ARENA_TRAINER_COOLTRAINER_M_22 => {
      :name => "Kaïs", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:LITWICK, 40], [:ESPEON, 40], [:NINETALES, 42], [:CROBAT, 47], [:MAGMORTAR, 48]]
    },
:ARENA_TRAINER_COOLTRAINER_M_23 => {
      :name => "Ilyes", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:STEELIX, 49]]
    },
:ARENA_TRAINER_COOLTRAINER_M_24 => {
      :name => "Zed", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:FERALIGATR, 41], [:TYPHLOSION, 42], [:SHELGON, 44], [:ROSERADE, 47], [:KROOKODILE, 50]]
    },
:ARENA_TRAINER_COOLTRAINER_M_25 => {
      :name => "Blaze", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:BLAZIKEN, 44], [:STARAPTOR, 47], [:GYARADOS, 48]]
    },
:ARENA_TRAINER_COOLTRAINER_M_26 => {
      :name => "Lenny", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GENGAR, 56]]
    },
:ARENA_TRAINER_COOLTRAINER_M_27 => {
      :name => "Raphaël", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:TYPHLOSION, 54], [:JOLTEON, 58], [:MAGMORTAR, 60]]
    },
:ARENA_TRAINER_COOLTRAINER_M_28 => {
      :name => "Storm", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:EMBOAR, 52], [:MAMOSWINE, 53], [:MACHOKE, 53], [:SNEASEL, 56], [:ABSOL, 58], [:DRAGONITE, 59]]
    },
:ARENA_TRAINER_COOLTRAINER_M_29 => {
      :name => "Axel", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:DRAGONAIR, 52], [:RUFFLET, 52], [:HERACROSS, 56]]
    },
:ARENA_TRAINER_COOLTRAINER_M_30 => {
      :name => "Maxime", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GLALIE, 51], [:EMBOAR, 52], [:HERACROSS, 55]]
    },
:ARENA_TRAINER_COOLTRAINER_M_31 => {
      :name => "Dante", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:HERACROSS, 60], [:HONCHKROW, 60], [:YANMEGA, 66], [:EXCADRILL, 67], [:UMBREON, 69], [:ALAKAZAM, 69]]
    },
:ARENA_TRAINER_COOLTRAINER_M_32 => {
      :name => "Enzo", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:JOLTEON, 61], [:NINETALES, 61], [:INFERNAPE, 64], [:MILOTIC, 68], [:DRAPION, 68], [:RHYDON, 70]]
    },
:ARENA_TRAINER_COOLTRAINER_M_33 => {
      :name => "Orion", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GALLADE, 62], [:DRAPION, 66], [:KROOKODILE, 66], [:GLISCOR, 70]]
    },
:ARENA_TRAINER_COOLTRAINER_M_34 => {
      :name => "Zack", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:MACHAMP, 63], [:ROSERADE, 63], [:SCIZOR, 64], [:FLAREON, 64], [:MAGMORTAR, 69], [:SWAMPERT, 70]]
    },
:ARENA_TRAINER_COOLTRAINER_M_35 => {
      :name => "Alexis", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:MISMAGIUS, 61], [:JOLTEON, 68], [:METAGROSS, 69], [:GENGAR, 69]]
    },
:ARENA_TRAINER_COOLTRAINER_M_36 => {
      :name => "Rayan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:WEAVILE, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_M_37 => {
      :name => "Phoenix", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:TYPHLOSION, 70], [:BRAVIARY, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_M_38 => {
      :name => "Rémy", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:RHYDON, 71], [:DUSKNOIR, 72], [:STEELIX, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_M_39 => {
      :name => "Ryder", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:FLAREON, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_M_40 => {
      :name => "Cyril", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:NINETALES, 72], [:CONKELDURR, 75]]
    },
:ARENA_TRAINER_COOLTRAINER_M_41 => {
      :name => "Ezra", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:DRAPION, 89]]
    },
:ARENA_TRAINER_COOLTRAINER_M_42 => {
      :name => "Soren", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:GALLADE, 86], [:GLALIE, 89]]
    },
:ARENA_TRAINER_COOLTRAINER_M_43 => {
      :name => "Kobe", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:FLAREON, 80], [:SCEPTILE, 90], [:ELECTIVIRE, 90]]
    },
:ARENA_TRAINER_COOLTRAINER_M_44 => {
      :name => "Wyatt", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:EMPOLEON, 80], [:INFERNAPE, 80], [:SCRAFTY, 86], [:TYPHLOSION, 88], [:MACHOKE, 88]]
    },
:ARENA_TRAINER_COOLTRAINER_M_45 => {
      :name => "Nate", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:MAGMORTAR, 80], [:HERACROSS, 83], [:PINSIR, 90]]
    },
:ARENA_TRAINER_COOLTRAINER_M_46 => {
      :name => "Hunter", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:JOLTEON, 93], [:SCRAFTY, 94], [:VAPOREON, 96], [:RHYPERIOR, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_M_47 => {
      :name => "Aaron", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:HITMONCHAN, 91], [:INFERNAPE, 92], [:SCRAFTY, 97], [:BISHARP, 98], [:TYRANITAR, 99]]
    },
:ARENA_TRAINER_COOLTRAINER_M_48 => {
      :name => "Hugo", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:RHYDON, 90], [:CHANDELURE, 96], [:SKARMORY, 96], [:TOXICROAK, 99], [:NINETALES, 100], [:MAGMORTAR, 100]]
    },
:ARENA_TRAINER_COOLTRAINER_M_49 => {
      :name => "Lucky", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:SHARPEDO, 90], [:BISHARP, 93], [:TYRANITAR, 99]]
    },
:ARENA_TRAINER_COOLTRAINER_M_50 => {
      :name => "Jordan", :sprite => "trainer_COOLTRAINER_M", :type => :COOLTRAINER_M,
      :team => [[:VOLCARONA, 91], [:MISMAGIUS, 92], [:VAPOREON, 93], [:GENGAR, 97], [:HERACROSS, 98], [:UMBREON, 100]]
    },
:ARENA_TRAINER_CRUSHGIRL_1 => {
      :name => "Emma", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MAKUHITA, 5], [:TYROGUE, 4]]
    },
:ARENA_TRAINER_CRUSHGIRL_2 => {
      :name => "Brenda", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MANKEY, 9], [:MIENFOO, 10]]
    },
:ARENA_TRAINER_CRUSHGIRL_3 => {
      :name => "Becky", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MANKEY, 2], [:TORCHIC, 6], [:RIOLU, 7]]
    },
:ARENA_TRAINER_CRUSHGIRL_4 => {
      :name => "Natasha", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:CHIMCHAR, 2], [:TEPIG, 4], [:RIOLU, 4], [:TYROGUE, 6], [:CROAGUNK, 7], [:MIENFOO, 10]]
    },
:ARENA_TRAINER_CRUSHGIRL_5 => {
      :name => "Sylvia", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MEDITITE, 6]]
    },
:ARENA_TRAINER_CRUSHGIRL_6 => {
      :name => "Amanda", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MAKUHITA, 15]]
    },
:ARENA_TRAINER_CRUSHGIRL_7 => {
      :name => "Nadia", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MANKEY, 20]]
    },
:ARENA_TRAINER_CRUSHGIRL_8 => {
      :name => "Marion", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HERACROSS, 15]]
    },
:ARENA_TRAINER_CRUSHGIRL_9 => {
      :name => "Estelle", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:CHIMCHAR, 11], [:SAWK, 17]]
    },
:ARENA_TRAINER_CRUSHGIRL_10 => {
      :name => "Germaine", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:TORCHIC, 11], [:MACHOP, 12], [:MEDITITE, 18], [:MAKUHITA, 18]]
    },
:ARENA_TRAINER_CRUSHGIRL_11 => {
      :name => "Sandy", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MONFERNO, 21], [:MIENFOO, 25]]
    },
:ARENA_TRAINER_CRUSHGIRL_12 => {
      :name => "Laila", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:THROH, 23], [:COMBUSKEN, 23], [:SCRAGGY, 24], [:HERACROSS, 25], [:MONFERNO, 25]]
    },
:ARENA_TRAINER_CRUSHGIRL_13 => {
      :name => "Alexa", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 24], [:SCRAGGY, 25], [:PIGNITE, 26], [:MEDITITE, 29], [:SAWK, 29]]
    },
:ARENA_TRAINER_CRUSHGIRL_14 => {
      :name => "Anissa", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MACHOP, 28], [:MONFERNO, 29], [:PRIMEAPE, 29]]
    },
:ARENA_TRAINER_CRUSHGIRL_15 => {
      :name => "Ketlen", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 20], [:MAKUHITA, 20], [:THROH, 25]]
    },
:ARENA_TRAINER_CRUSHGIRL_16 => {
      :name => "Cindy", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:SAWK, 30], [:MEDITITE, 32], [:MACHOKE, 35], [:MEDICHAM, 39]]
    },
:ARENA_TRAINER_CRUSHGIRL_17 => {
      :name => "Nikki", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:SAWK, 38]]
    },
:ARENA_TRAINER_CRUSHGIRL_18 => {
      :name => "Brie", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HERACROSS, 34], [:PIGNITE, 36], [:POLIWHIRL, 37]]
    },
:ARENA_TRAINER_CRUSHGIRL_19 => {
      :name => "Jennifer", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:COMBUSKEN, 30], [:HARIYAMA, 33], [:HITMONCHAN, 33], [:GURDURR, 36], [:INFERNAPE, 40], [:MACHAMP, 40]]
    },
:ARENA_TRAINER_CRUSHGIRL_20 => {
      :name => "Rose", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:SCRAGGY, 34], [:HITMONLEE, 37], [:SAWK, 38], [:MACHAMP, 40]]
    },
:ARENA_TRAINER_CRUSHGIRL_21 => {
      :name => "Bayley", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 42], [:LUCARIO, 43], [:EMBOAR, 46], [:BLAZIKEN, 47]]
    },
:ARENA_TRAINER_CRUSHGIRL_22 => {
      :name => "Ronda", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MIENFOO, 40], [:LUCARIO, 41], [:HARIYAMA, 45], [:SCRAFTY, 45], [:MIENSHAO, 50]]
    },
:ARENA_TRAINER_CRUSHGIRL_23 => {
      :name => "Weili", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONCHAN, 40], [:MACHAMP, 45], [:TOXICROAK, 46], [:SAWK, 50]]
    },
:ARENA_TRAINER_CRUSHGIRL_24 => {
      :name => "Julianna", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MEDICHAM, 40], [:SAWK, 41], [:LUCARIO, 42], [:THROH, 42], [:PRIMEAPE, 46]]
    },
:ARENA_TRAINER_CRUSHGIRL_25 => {
      :name => "Gwen", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:INFERNAPE, 40], [:HITMONCHAN, 40], [:HERACROSS, 41], [:SAWK, 46], [:MACHAMP, 49]]
    },
:ARENA_TRAINER_CRUSHGIRL_26 => {
      :name => "Zoé", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONTOP, 55], [:POLIWRATH, 56], [:HITMONLEE, 58], [:HARIYAMA, 58], [:THROH, 59], [:LUCARIO, 59]]
    },
:ARENA_TRAINER_CRUSHGIRL_27 => {
      :name => "Lucie", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MACHAMP, 56], [:LUCARIO, 56]]
    },
:ARENA_TRAINER_CRUSHGIRL_28 => {
      :name => "Marloes", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:THROH, 51], [:INFERNAPE, 54], [:BLAZIKEN, 58], [:SAWK, 58], [:HITMONCHAN, 58], [:HITMONLEE, 59]]
    },
:ARENA_TRAINER_CRUSHGIRL_29 => {
      :name => "Fatou", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:SCRAFTY, 52], [:HITMONTOP, 56], [:LUCARIO, 57], [:SAWK, 57]]
    },
:ARENA_TRAINER_CRUSHGIRL_30 => {
      :name => "Priscilla", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:CONKELDURR, 51], [:INFERNAPE, 52], [:EMBOAR, 55]]
    },
:ARENA_TRAINER_CRUSHGIRL_31 => {
      :name => "Megan", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MEDICHAM, 61], [:BRELOOM, 62], [:MACHAMP, 67]]
    },
:ARENA_TRAINER_CRUSHGIRL_32 => {
      :name => "Maïa", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:POLIWRATH, 62], [:BLAZIKEN, 64], [:SCRAFTY, 69]]
    },
:ARENA_TRAINER_CRUSHGIRL_33 => {
      :name => "Miesha", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MACHOKE, 61], [:HITMONTOP, 61], [:PRIMEAPE, 64], [:MIENSHAO, 65], [:TOXICROAK, 69]]
    },
:ARENA_TRAINER_CRUSHGIRL_34 => {
      :name => "Karine", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MEDICHAM, 62], [:EMBOAR, 63], [:PRIMEAPE, 66], [:HITMONCHAN, 68], [:HERACROSS, 69]]
    },
:ARENA_TRAINER_CRUSHGIRL_35 => {
      :name => "Trish", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HERACROSS, 63], [:BRELOOM, 64], [:GALLADE, 64], [:EMBOAR, 65]]
    },
:ARENA_TRAINER_CRUSHGIRL_36 => {
      :name => "Valentina", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MIENSHAO, 76], [:HITMONLEE, 76]]
    },
:ARENA_TRAINER_CRUSHGIRL_37 => {
      :name => "Kimberley", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONCHAN, 74], [:POLIWRATH, 76], [:THROH, 77], [:PRIMEAPE, 79], [:LUCARIO, 80]]
    },
:ARENA_TRAINER_CRUSHGIRL_38 => {
      :name => "Julie", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONCHAN, 75]]
    },
:ARENA_TRAINER_CRUSHGIRL_39 => {
      :name => "Chyna", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:TOXICROAK, 75]]
    },
:ARENA_TRAINER_CRUSHGIRL_40 => {
      :name => "Paige", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MIENSHAO, 73], [:HITMONTOP, 77], [:HERACROSS, 78]]
    },
:ARENA_TRAINER_CRUSHGIRL_41 => {
      :name => "Mélanie", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:CONKELDURR, 83], [:SAWK, 84], [:MACHAMP, 86], [:BLAZIKEN, 87], [:TOXICROAK, 89]]
    },
:ARENA_TRAINER_CRUSHGIRL_42 => {
      :name => "Sijara", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 81], [:THROH, 83], [:GALLADE, 84], [:EMBOAR, 86], [:BRELOOM, 88]]
    },
:ARENA_TRAINER_CRUSHGIRL_43 => {
      :name => "Cristiane", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 85], [:SCRAFTY, 86], [:SAWK, 89], [:THROH, 90], [:HITMONTOP, 90], [:TOXICROAK, 90]]
    },
:ARENA_TRAINER_CRUSHGIRL_44 => {
      :name => "Tecia", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:MEDICHAM, 81], [:MIENSHAO, 81], [:EMBOAR, 82], [:GALLADE, 86], [:LUCARIO, 90]]
    },
:ARENA_TRAINER_CRUSHGIRL_45 => {
      :name => "Samia", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:TOXICROAK, 82], [:HITMONLEE, 82], [:MEDICHAM, 84], [:POLIWRATH, 85], [:HARIYAMA, 90]]
    },
:ARENA_TRAINER_CRUSHGIRL_46 => {
      :name => "Holly", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:BRELOOM, 91], [:HITMONCHAN, 95], [:HITMONTOP, 96], [:EMBOAR, 97], [:POLIWRATH, 99], [:INFERNAPE, 100]]
    },
:ARENA_TRAINER_CRUSHGIRL_47 => {
      :name => "Roxane", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:PRIMEAPE, 91], [:TOXICROAK, 94], [:GALLADE, 94], [:MACHAMP, 94], [:MIENSHAO, 95], [:MACHOKE, 97]]
    },
:ARENA_TRAINER_CRUSHGIRL_48 => {
      :name => "Gina", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HARIYAMA, 93], [:HITMONCHAN, 93], [:HERACROSS, 93], [:THROH, 96], [:SAWK, 99], [:TOXICROAK, 100]]
    },
:ARENA_TRAINER_CRUSHGIRL_49 => {
      :name => "Kaitlyn", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:HITMONLEE, 91], [:HARIYAMA, 95], [:HITMONCHAN, 96], [:MIENSHAO, 100], [:THROH, 100]]
    },
:ARENA_TRAINER_CRUSHGIRL_50 => {
      :name => "Katia", :sprite => "trainer_CRUSHGIRL", :type => :CRUSHGIRL,
      :team => [[:TOXICROAK, 93], [:HITMONTOP, 99]]
    },
:ARENA_TRAINER_CUEBALL_1 => {
      :name => "Quasimodo", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:TRUBBISH, 5], [:BELDUM, 4]]
    },
:ARENA_TRAINER_CUEBALL_2 => {
      :name => "Wayne", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:CORPHISH, 4], [:ZUBAT, 6]]
    },
:ARENA_TRAINER_CUEBALL_3 => {
      :name => "Boris", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:BARBOACH, 4], [:PAWNIARD, 6]]
    },
:ARENA_TRAINER_CUEBALL_4 => {
      :name => "Stéphane", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SKORUPI, 9]]
    },
:ARENA_TRAINER_CUEBALL_5 => {
      :name => "Gus", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SKORUPI, 2], [:VENIPEDE, 8], [:CROAGUNK, 9]]
    },
:ARENA_TRAINER_CUEBALL_6 => {
      :name => "Marlon", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SKORUPI, 15]]
    },
:ARENA_TRAINER_CUEBALL_7 => {
      :name => "Vernon", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:PAWNIARD, 11], [:HIPPOPOTAS, 12], [:SHIELDON, 15], [:CARVANHA, 19], [:ZUBAT, 20], [:GOLETT, 20]]
    },
:ARENA_TRAINER_CUEBALL_8 => {
      :name => "Rufus", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:GULPIN, 14], [:TRUBBISH, 15]]
    },
:ARENA_TRAINER_CUEBALL_9 => {
      :name => "Clyde", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:POOCHYENA, 15], [:SANDILE, 20]]
    },
:ARENA_TRAINER_CUEBALL_10 => {
      :name => "Tony", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:RHYHORN, 16]]
    },
:ARENA_TRAINER_CUEBALL_11 => {
      :name => "Jean-Pierre", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:ARON, 26]]
    },
:ARENA_TRAINER_CUEBALL_12 => {
      :name => "Rocco", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:RHYHORN, 25], [:SHIELDON, 27]]
    },
:ARENA_TRAINER_CUEBALL_13 => {
      :name => "Billy", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:BOUFFALANT, 21], [:BAGON, 21], [:GIBLE, 22], [:ROGGENROLA, 23], [:GOLBAT, 25]]
    },
:ARENA_TRAINER_CUEBALL_14 => {
      :name => "Walter", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:TRUBBISH, 24], [:GOLETT, 26], [:SHIELDON, 27], [:HOUNDOOM, 28], [:GABITE, 28]]
    },
:ARENA_TRAINER_CUEBALL_15 => {
      :name => "Didier", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:HIPPOPOTAS, 23], [:CRANIDOS, 23], [:SEVIPER, 23], [:RHYHORN, 25], [:TAUROS, 29], [:KROKOROK, 30]]
    },
:ARENA_TRAINER_CUEBALL_16 => {
      :name => "Chad", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:CROAGUNK, 35]]
    },
:ARENA_TRAINER_CUEBALL_17 => {
      :name => "Thierry", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:TENTACRUEL, 33], [:GRIMER, 35]]
    },
:ARENA_TRAINER_CUEBALL_18 => {
      :name => "Cole", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:CROBAT, 36], [:RAMPARDOS, 37], [:SKUNTANK, 38]]
    },
:ARENA_TRAINER_CUEBALL_19 => {
      :name => "Brock", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SNORLAX, 35]]
    },
:ARENA_TRAINER_CUEBALL_20 => {
      :name => "Lenny", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MACHOKE, 35]]
    },
:ARENA_TRAINER_CUEBALL_21 => {
      :name => "Igor", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MIGHTYENA, 40], [:SCOLIPEDE, 41], [:TAUROS, 42], [:GIGALITH, 45], [:QWILFISH, 48], [:GOLBAT, 49]]
    },
:ARENA_TRAINER_CUEBALL_22 => {
      :name => "Dimitri", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:DONPHAN, 40], [:GOLEM, 46], [:KROOKODILE, 49], [:SEVIPER, 49], [:GARBODOR, 49], [:GOLBAT, 50]]
    },
:ARENA_TRAINER_CUEBALL_23 => {
      :name => "Kevin", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:ARBOK, 40], [:SCRAFTY, 42], [:URSARING, 42], [:HIPPOWDON, 42], [:GOLBAT, 43], [:STEELIX, 50]]
    },
:ARENA_TRAINER_CUEBALL_24 => {
      :name => "Dallas", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MUK, 40], [:DRAPION, 40], [:TENTACRUEL, 44], [:CRAWDAUNT, 45], [:CRUSTLE, 47]]
    },
:ARENA_TRAINER_CUEBALL_25 => {
      :name => "Chuck", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SKORUPI, 40], [:MIGHTYENA, 41], [:KROOKODILE, 41], [:ARBOK, 48]]
    },
:ARENA_TRAINER_CUEBALL_26 => {
      :name => "Ray", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:KROOKODILE, 50], [:CRUSTLE, 56], [:SHARPEDO, 58], [:MACHAMP, 60]]
    },
:ARENA_TRAINER_CUEBALL_27 => {
      :name => "Ricky", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SEVIPER, 50], [:GARBODOR, 51], [:KROOKODILE, 52], [:TOXICROAK, 57], [:RHYPERIOR, 60]]
    },
:ARENA_TRAINER_CUEBALL_28 => {
      :name => "Colt", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MAMOSWINE, 50], [:GOLBAT, 55]]
    },
:ARENA_TRAINER_CUEBALL_29 => {
      :name => "Travis", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:EELEKTROSS, 51], [:HIPPOWDON, 52], [:TENTACRUEL, 52], [:METAGROSS, 60], [:SCRAFTY, 60]]
    },
:ARENA_TRAINER_CUEBALL_30 => {
      :name => "Marcel", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:CONKELDURR, 51], [:MACHAMP, 58], [:RHYDON, 59], [:SWALOT, 59], [:HIPPOWDON, 60]]
    },
:ARENA_TRAINER_CUEBALL_31 => {
      :name => "Eddie", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:HIPPOWDON, 63], [:GARCHOMP, 63], [:TOXICROAK, 64], [:RAMPARDOS, 65], [:EELEKTROSS, 68]]
    },
:ARENA_TRAINER_CUEBALL_32 => {
      :name => "Gérard", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:CROBAT, 61], [:RAMPARDOS, 64], [:BOUFFALANT, 70]]
    },
:ARENA_TRAINER_CUEBALL_33 => {
      :name => "Harley", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:GOLEM, 61], [:KROOKODILE, 62], [:MUK, 66]]
    },
:ARENA_TRAINER_CUEBALL_34 => {
      :name => "Gilles", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SNORLAX, 64], [:SEVIPER, 64], [:MUK, 65], [:SCOLIPEDE, 67]]
    },
:ARENA_TRAINER_CUEBALL_35 => {
      :name => "Ivan", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:RHYPERIOR, 64], [:TOXICROAK, 65], [:SHARPEDO, 67]]
    },
:ARENA_TRAINER_CUEBALL_36 => {
      :name => "Wyatt", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SWALOT, 75]]
    },
:ARENA_TRAINER_CUEBALL_37 => {
      :name => "Raymond", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:ELECTIVIRE, 71], [:SKUNTANK, 75], [:MAGMORTAR, 80]]
    },
:ARENA_TRAINER_CUEBALL_38 => {
      :name => "Otis", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:ARBOK, 78]]
    },
:ARENA_TRAINER_CUEBALL_39 => {
      :name => "Johnny", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:HOUNDOOM, 70], [:ARBOK, 73], [:SHARPEDO, 79], [:TENTACRUEL, 80]]
    },
:ARENA_TRAINER_CUEBALL_40 => {
      :name => "Mike", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:HOUNDOOM, 71], [:TORTERRA, 72], [:ARBOK, 72], [:CROBAT, 72], [:KROOKODILE, 75]]
    },
:ARENA_TRAINER_CUEBALL_41 => {
      :name => "Lloyd", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SEVIPER, 87]]
    },
:ARENA_TRAINER_CUEBALL_42 => {
      :name => "Bobby", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MIGHTYENA, 85]]
    },
:ARENA_TRAINER_CUEBALL_43 => {
      :name => "Dwayne", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:TOXICROAK, 85], [:STEELIX, 88], [:BASTIODON, 89]]
    },
:ARENA_TRAINER_CUEBALL_44 => {
      :name => "Vladimir", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:TAUROS, 85]]
    },
:ARENA_TRAINER_CUEBALL_45 => {
      :name => "Lucien", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:URSARING, 82], [:SEVIPER, 82], [:KROOKODILE, 90]]
    },
:ARENA_TRAINER_CUEBALL_46 => {
      :name => "Mario", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:WHISCASH, 90], [:HIPPOWDON, 93], [:TYRANITAR, 95], [:BOUFFALANT, 99]]
    },
:ARENA_TRAINER_CUEBALL_47 => {
      :name => "Axel", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:MIGHTYENA, 95], [:SCRAFTY, 96], [:WEEZING, 98]]
    },
:ARENA_TRAINER_CUEBALL_48 => {
      :name => "Cliff", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SHARPEDO, 90], [:ELECTIVIRE, 92], [:MUK, 95], [:STEELIX, 96], [:CROBAT, 98]]
    },
:ARENA_TRAINER_CUEBALL_49 => {
      :name => "Fabrice", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SCRAFTY, 93], [:GARBODOR, 94], [:DRAPION, 95]]
    },
:ARENA_TRAINER_CUEBALL_50 => {
      :name => "Wesley", :sprite => "trainer_CUEBALL", :type => :CUEBALL,
      :team => [[:SNORLAX, 90], [:KROOKODILE, 92], [:MACHAMP, 96], [:TORTERRA, 97], [:SEVIPER, 100]]
    },
:ARENA_TRAINER_ENGINEER_1 => {
      :name => "Thibaut", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MAGNEMITE, 5], [:MAWILE, 4]]
    },
:ARENA_TRAINER_ENGINEER_2 => {
      :name => "Édouard", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:SHINX, 2], [:VOLTORB, 4], [:ELEKID, 4], [:MAREEP, 7]]
    },
:ARENA_TRAINER_ENGINEER_3 => {
      :name => "Wilbur", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:NOSEPASS, 4], [:DRILBUR, 9], [:MAREEP, 9]]
    },
:ARENA_TRAINER_ENGINEER_4 => {
      :name => "Émile", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PAWNIARD, 2], [:VOLTORB, 5], [:MAWILE, 6]]
    },
:ARENA_TRAINER_ENGINEER_5 => {
      :name => "Alberto", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTRIKE, 2], [:DRILBUR, 6]]
    },
:ARENA_TRAINER_ENGINEER_6 => {
      :name => "Adolphe", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PINECO, 11], [:MAREEP, 11], [:MINUN, 14], [:NOSEPASS, 16], [:JOLTEON, 20]]
    },
:ARENA_TRAINER_ENGINEER_7 => {
      :name => "Tim", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PINECO, 16]]
    },
:ARENA_TRAINER_ENGINEER_8 => {
      :name => "Bill", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MAGNEMITE, 13], [:NOSEPASS, 16], [:DRILBUR, 19]]
    },
:ARENA_TRAINER_ENGINEER_9 => {
      :name => "Blaise", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELEKID, 10], [:NOSEPASS, 12], [:PINECO, 16], [:BELDUM, 19], [:FERROSEED, 20]]
    },
:ARENA_TRAINER_ENGINEER_10 => {
      :name => "Denis", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PLUSLE, 20]]
    },
:ARENA_TRAINER_ENGINEER_11 => {
      :name => "Henry", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BLITZLE, 25]]
    },
:ARENA_TRAINER_ENGINEER_12 => {
      :name => "Étienne", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BRONZOR, 20], [:STUNFISK, 20], [:RIOLU, 29]]
    },
:ARENA_TRAINER_ENGINEER_13 => {
      :name => "Alessandro", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LANTURN, 30]]
    },
:ARENA_TRAINER_ENGINEER_14 => {
      :name => "Maurice", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MAWILE, 30]]
    },
:ARENA_TRAINER_ENGINEER_15 => {
      :name => "Archimède", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:STUNFISK, 26], [:PLUSLE, 29]]
    },
:ARENA_TRAINER_ENGINEER_16 => {
      :name => "Jean-Baptiste", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:KLINK, 33], [:STEELIX, 33], [:FORRETRESS, 33], [:ELECTABUZZ, 39]]
    },
:ARENA_TRAINER_ENGINEER_17 => {
      :name => "Isambard", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:METANG, 32], [:AMPHAROS, 40]]
    },
:ARENA_TRAINER_ENGINEER_18 => {
      :name => "Eugène", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MINUN, 31], [:STEELIX, 33], [:KLINK, 34], [:LAIRON, 34], [:ZEBSTRIKA, 37]]
    },
:ARENA_TRAINER_ENGINEER_19 => {
      :name => "Léonard", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:METANG, 33], [:EXCADRILL, 35]]
    },
:ARENA_TRAINER_ENGINEER_20 => {
      :name => "Dmitri", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ROTOM, 33], [:ZEBSTRIKA, 34], [:MINUN, 35], [:LANTURN, 36], [:EXCADRILL, 40]]
    },
:ARENA_TRAINER_ENGINEER_21 => {
      :name => "Fernand", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:METANG, 44], [:EELEKTRIK, 44], [:ELECTABUZZ, 49], [:METAGROSS, 50]]
    },
:ARENA_TRAINER_ENGINEER_22 => {
      :name => "Clément", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:JOLTEON, 41], [:AMPHAROS, 43], [:STEELIX, 49], [:RAICHU, 50]]
    },
:ARENA_TRAINER_ENGINEER_23 => {
      :name => "Antoine", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:FORRETRESS, 40], [:ESCAVALIER, 40], [:STEELIX, 42], [:LANTURN, 43], [:STUNFISK, 45]]
    },
:ARENA_TRAINER_ENGINEER_24 => {
      :name => "Ferdinand", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LUXRAY, 46], [:FORRETRESS, 47], [:PAWNIARD, 48], [:STUNFISK, 48]]
    },
:ARENA_TRAINER_ENGINEER_25 => {
      :name => "Igor", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BASTIODON, 42], [:EXCADRILL, 49]]
    },
:ARENA_TRAINER_ENGINEER_26 => {
      :name => "Orville", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BRONZONG, 50], [:RAICHU, 51], [:PLUSLE, 55]]
    },
:ARENA_TRAINER_ENGINEER_27 => {
      :name => "Lucien", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PACHIRISU, 51], [:LUCARIO, 52], [:ESCAVALIER, 52], [:SKARMORY, 60]]
    },
:ARENA_TRAINER_ENGINEER_28 => {
      :name => "Armand", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MINUN, 54], [:PIKACHU, 58]]
    },
:ARENA_TRAINER_ENGINEER_29 => {
      :name => "Alexander", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PACHIRISU, 52], [:EMPOLEON, 57], [:EMOLGA, 59]]
    },
:ARENA_TRAINER_ENGINEER_30 => {
      :name => "Gustave", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:KLINKLANG, 50], [:JOLTEON, 51], [:STEELIX, 54], [:BRONZONG, 56]]
    },
:ARENA_TRAINER_ENGINEER_31 => {
      :name => "Ken", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTRODE, 60], [:EMPOLEON, 65]]
    },
:ARENA_TRAINER_ENGINEER_32 => {
      :name => "Nicolas", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LUCARIO, 60], [:AMPHAROS, 62], [:ROTOM, 65], [:AGGRON, 65], [:PLUSLE, 67], [:EMPOLEON, 70]]
    },
:ARENA_TRAINER_ENGINEER_33 => {
      :name => "Michael", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:AMPHAROS, 66], [:GALVANTULA, 69]]
    },
:ARENA_TRAINER_ENGINEER_34 => {
      :name => "Ettore", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:AGGRON, 63], [:BISHARP, 63], [:MANECTRIC, 66], [:EXCADRILL, 66], [:KLINKLANG, 66]]
    },
:ARENA_TRAINER_ENGINEER_35 => {
      :name => "Guglielmo", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BRONZONG, 65], [:ESCAVALIER, 66], [:MAWILE, 67], [:LANTURN, 69]]
    },
:ARENA_TRAINER_ENGINEER_36 => {
      :name => "Ludovic", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ESCAVALIER, 71], [:PROBOPASS, 72], [:ELECTRODE, 77]]
    },
:ARENA_TRAINER_ENGINEER_37 => {
      :name => "Hector", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PACHIRISU, 70], [:ROTOM, 71], [:DURANT, 76], [:ELECTABUZZ, 78], [:EMPOLEON, 78], [:MAGNETON, 79]]
    },
:ARENA_TRAINER_ENGINEER_38 => {
      :name => "Ernst", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTABUZZ, 75]]
    },
:ARENA_TRAINER_ENGINEER_39 => {
      :name => "Achille", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:EXCADRILL, 77]]
    },
:ARENA_TRAINER_ENGINEER_40 => {
      :name => "Pierre", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LUXRAY, 70], [:AGGRON, 70], [:EXCADRILL, 75], [:ESCAVALIER, 79], [:BRONZONG, 80]]
    },
:ARENA_TRAINER_ENGINEER_41 => {
      :name => "Hippolyte", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ROTOM, 80], [:SKARMORY, 81], [:PROBOPASS, 84], [:MINUN, 85], [:GALVANTULA, 90]]
    },
:ARENA_TRAINER_ENGINEER_42 => {
      :name => "Jacques", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTRODE, 81], [:EMPOLEON, 81], [:KLINKLANG, 83], [:DURANT, 83], [:ZEBSTRIKA, 88], [:BASTIODON, 88]]
    },
:ARENA_TRAINER_ENGINEER_43 => {
      :name => "Thomas", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MAWILE, 82], [:MANECTRIC, 88]]
    },
:ARENA_TRAINER_ENGINEER_44 => {
      :name => "Rudolf", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LANTURN, 88]]
    },
:ARENA_TRAINER_ENGINEER_45 => {
      :name => "Santos", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTRODE, 82], [:METAGROSS, 82], [:LUCARIO, 85], [:GALVANTULA, 85]]
    },
:ARENA_TRAINER_ENGINEER_46 => {
      :name => "Joseph", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:BISHARP, 92], [:SKARMORY, 92], [:PROBOPASS, 95], [:MANECTRIC, 96]]
    },
:ARENA_TRAINER_ENGINEER_47 => {
      :name => "Augustin", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:PLUSLE, 93], [:EXCADRILL, 99]]
    },
:ARENA_TRAINER_ENGINEER_48 => {
      :name => "Nikola", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:MANECTRIC, 92], [:EXCADRILL, 92], [:MINUN, 93], [:ROTOM, 97], [:ELECTABUZZ, 98]]
    },
:ARENA_TRAINER_ENGINEER_49 => {
      :name => "Steve", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:LUCARIO, 93], [:EMOLGA, 94], [:EXCADRILL, 97], [:EELEKTROSS, 97], [:RAICHU, 99]]
    },
:ARENA_TRAINER_ENGINEER_50 => {
      :name => "Samuel", :sprite => "trainer_ENGINEER", :type => :ENGINEER,
      :team => [[:ELECTRODE, 93], [:MINUN, 98], [:SCIZOR, 99], [:BASTIODON, 100]]
    },
:ARENA_TRAINER_FISHERMAN_1 => {
      :name => "Steven", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:FINNEON, 5], [:LUVDISC, 4]]
    },
:ARENA_TRAINER_FISHERMAN_2 => {
      :name => "Fernand", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:BASCULIN, 3], [:MAGIKARP, 3], [:CHINCHOU, 4], [:LUVDISC, 8]]
    },
:ARENA_TRAINER_FISHERMAN_3 => {
      :name => "Loïc", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:GOLDEEN, 2], [:TYNAMO, 6], [:WAILMER, 6], [:MAGIKARP, 7], [:BARBOACH, 9], [:LUVDISC, 10]]
    },
:ARENA_TRAINER_FISHERMAN_4 => {
      :name => "Michel", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:MANTYKE, 2], [:BARBOACH, 2], [:MAGIKARP, 2], [:REMORAID, 7], [:CARVANHA, 8], [:FINNEON, 9]]
    },
:ARENA_TRAINER_FISHERMAN_5 => {
      :name => "Kévin", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:CARVANHA, 2], [:GOLDEEN, 5], [:BASCULIN, 6], [:TYNAMO, 6], [:BARBOACH, 10]]
    },
:ARENA_TRAINER_FISHERMAN_6 => {
      :name => "Fañch", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:GOLDEEN, 11], [:HORSEA, 13], [:TYNAMO, 15], [:FINNEON, 19]]
    },
:ARENA_TRAINER_FISHERMAN_7 => {
      :name => "Mathieu", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:RELICANTH, 15]]
    },
:ARENA_TRAINER_FISHERMAN_8 => {
      :name => "Pierrick", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:HORSEA, 10], [:QWILFISH, 15]]
    },
:ARENA_TRAINER_FISHERMAN_9 => {
      :name => "Bernard", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:BARBOACH, 15]]
    },
:ARENA_TRAINER_FISHERMAN_10 => {
      :name => "Briac", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:MAGIKARP, 10], [:HORSEA, 12], [:TYNAMO, 14], [:FEEBAS, 17]]
    },
:ARENA_TRAINER_FISHERMAN_11 => {
      :name => "Daniel", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:QWILFISH, 20], [:MANTINE, 20], [:RELICANTH, 28], [:STUNFISK, 29], [:TYNAMO, 29], [:SHARPEDO, 30]]
    },
:ARENA_TRAINER_FISHERMAN_12 => {
      :name => "Bastien", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:FEEBAS, 23], [:LUVDISC, 24], [:ALOMOMOLA, 25]]
    },
:ARENA_TRAINER_FISHERMAN_13 => {
      :name => "Alain", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:RELICANTH, 22], [:FEEBAS, 24], [:CHINCHOU, 27], [:LUVDISC, 29], [:SHARPEDO, 30]]
    },
:ARENA_TRAINER_FISHERMAN_14 => {
      :name => "Maël", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LUVDISC, 22], [:CHINCHOU, 24], [:HORSEA, 25]]
    },
:ARENA_TRAINER_FISHERMAN_15 => {
      :name => "Thierry", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:STUNFISK, 23], [:RELICANTH, 23], [:CHINCHOU, 26]]
    },
:ARENA_TRAINER_FISHERMAN_16 => {
      :name => "Hugo", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WAILMER, 31], [:FINNEON, 31], [:BASCULIN, 35], [:ALOMOMOLA, 38], [:WHISCASH, 38], [:QWILFISH, 39]]
    },
:ARENA_TRAINER_FISHERMAN_17 => {
      :name => "René", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WHISCASH, 31], [:LUVDISC, 35], [:SEADRA, 35], [:BASCULIN, 40]]
    },
:ARENA_TRAINER_FISHERMAN_18 => {
      :name => "Jean-Claude", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:QWILFISH, 30], [:SHARPEDO, 34], [:LANTURN, 35], [:WAILMER, 37], [:GYARADOS, 38]]
    },
:ARENA_TRAINER_FISHERMAN_19 => {
      :name => "Ismaël", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:GOLDEEN, 32], [:BASCULIN, 33], [:STUNFISK, 35], [:WHISCASH, 37]]
    },
:ARENA_TRAINER_FISHERMAN_20 => {
      :name => "Patrick", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:QWILFISH, 36], [:WAILMER, 39], [:MANTINE, 40]]
    },
:ARENA_TRAINER_FISHERMAN_21 => {
      :name => "Ernest", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SEAKING, 42], [:OCTILLERY, 44], [:LUVDISC, 45], [:LANTURN, 47], [:WHISCASH, 49]]
    },
:ARENA_TRAINER_FISHERMAN_22 => {
      :name => "Santiago", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WHISCASH, 44], [:QWILFISH, 45], [:GYARADOS, 47], [:RELICANTH, 48], [:MILOTIC, 49]]
    },
:ARENA_TRAINER_FISHERMAN_23 => {
      :name => "Serge", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WAILORD, 46], [:LUMINEON, 46], [:SEAKING, 47]]
    },
:ARENA_TRAINER_FISHERMAN_24 => {
      :name => "Guy", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:ALOMOMOLA, 43], [:SEADRA, 48]]
    },
:ARENA_TRAINER_FISHERMAN_25 => {
      :name => "Gilles", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:BASCULIN, 41], [:RELICANTH, 42], [:SHARPEDO, 47]]
    },
:ARENA_TRAINER_FISHERMAN_26 => {
      :name => "Tom", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:KINGDRA, 52], [:OCTILLERY, 57], [:EELEKTROSS, 57], [:LANTURN, 58], [:SEADRA, 59], [:MANTINE, 59]]
    },
:ARENA_TRAINER_FISHERMAN_27 => {
      :name => "Jean-Luc", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SHARPEDO, 53], [:LUVDISC, 57], [:SEADRA, 58], [:WAILORD, 58]]
    },
:ARENA_TRAINER_FISHERMAN_28 => {
      :name => "Quint", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LUVDISC, 55], [:LUMINEON, 56]]
    },
:ARENA_TRAINER_FISHERMAN_29 => {
      :name => "Marcel", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SEADRA, 54], [:SHARPEDO, 55], [:BASCULIN, 55], [:WAILORD, 56], [:GYARADOS, 57]]
    },
:ARENA_TRAINER_FISHERMAN_30 => {
      :name => "Yves", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:KINGDRA, 55]]
    },
:ARENA_TRAINER_FISHERMAN_31 => {
      :name => "Albert", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:QWILFISH, 68]]
    },
:ARENA_TRAINER_FISHERMAN_32 => {
      :name => "Corentin", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SHARPEDO, 65]]
    },
:ARENA_TRAINER_FISHERMAN_33 => {
      :name => "Gaël", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:STUNFISK, 60], [:WAILORD, 63], [:SEADRA, 63], [:RELICANTH, 65], [:LUVDISC, 67], [:SEAKING, 70]]
    },
:ARENA_TRAINER_FISHERMAN_34 => {
      :name => "Jacques", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LUVDISC, 60], [:SHARPEDO, 60], [:RELICANTH, 63], [:KINGDRA, 63], [:QWILFISH, 67], [:WHISCASH, 70]]
    },
:ARENA_TRAINER_FISHERMAN_35 => {
      :name => "Kerian", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:EELEKTROSS, 60], [:MILOTIC, 60], [:STUNFISK, 62], [:LUVDISC, 65]]
    },
:ARENA_TRAINER_FISHERMAN_36 => {
      :name => "Jean-Yves", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LUMINEON, 73], [:EELEKTROSS, 74], [:OCTILLERY, 77]]
    },
:ARENA_TRAINER_FISHERMAN_37 => {
      :name => "Marin", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:MANTINE, 70], [:RELICANTH, 80]]
    },
:ARENA_TRAINER_FISHERMAN_38 => {
      :name => "Ronan", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:ALOMOMOLA, 71], [:SEAKING, 73], [:LANTURN, 74], [:BASCULIN, 79]]
    },
:ARENA_TRAINER_FISHERMAN_39 => {
      :name => "Tanguy", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LANTURN, 71], [:SEAKING, 77]]
    },
:ARENA_TRAINER_FISHERMAN_40 => {
      :name => "Roger", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:OCTILLERY, 72], [:QWILFISH, 76], [:KINGDRA, 77]]
    },
:ARENA_TRAINER_FISHERMAN_41 => {
      :name => "Morgan", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:LUMINEON, 82], [:SEAKING, 82], [:GYARADOS, 82], [:WAILORD, 86], [:WHISCASH, 87], [:BASCULIN, 88]]
    },
:ARENA_TRAINER_FISHERMAN_42 => {
      :name => "Maurice", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:OCTILLERY, 81], [:MILOTIC, 81], [:RELICANTH, 85]]
    },
:ARENA_TRAINER_FISHERMAN_43 => {
      :name => "Olivier", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:GYARADOS, 80], [:LANTURN, 82], [:WAILORD, 85], [:SEADRA, 85], [:SHARPEDO, 87]]
    },
:ARENA_TRAINER_FISHERMAN_44 => {
      :name => "Soren", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SEADRA, 83], [:WAILORD, 83], [:LUVDISC, 83], [:LUMINEON, 90]]
    },
:ARENA_TRAINER_FISHERMAN_45 => {
      :name => "Killian", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:KINGDRA, 83], [:SEADRA, 90]]
    },
:ARENA_TRAINER_FISHERMAN_46 => {
      :name => "Erwan", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WAILORD, 92], [:GYARADOS, 95], [:MANTINE, 96], [:EELEKTROSS, 96], [:RELICANTH, 96], [:BASCULIN, 100]]
    },
:ARENA_TRAINER_FISHERMAN_47 => {
      :name => "Christian", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:SEADRA, 92], [:STUNFISK, 94], [:WAILORD, 97]]
    },
:ARENA_TRAINER_FISHERMAN_48 => {
      :name => "Goulven", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:MILOTIC, 97]]
    },
:ARENA_TRAINER_FISHERMAN_49 => {
      :name => "Brieuc", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:WAILORD, 97], [:ALOMOMOLA, 98], [:STUNFISK, 100]]
    },
:ARENA_TRAINER_FISHERMAN_50 => {
      :name => "Armel", :sprite => "trainer_FISHERMAN", :type => :FISHERMAN,
      :team => [[:BASCULIN, 93], [:MANTINE, 95], [:SHARPEDO, 98], [:SEAKING, 99]]
    },
:ARENA_TRAINER_GAMBLER_1 => {
      :name => "Lucien", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:ABRA, 5], [:LARVESTA, 4]]
    },
:ARENA_TRAINER_GAMBLER_2 => {
      :name => "Armand", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SPINDA, 7], [:GOTHITA, 10]]
    },
:ARENA_TRAINER_GAMBLER_3 => {
      :name => "Zacharie", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SABLEYE, 8]]
    },
:ARENA_TRAINER_GAMBLER_4 => {
      :name => "Eugène", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:VULPIX, 2], [:FOONGUS, 9], [:DRATINI, 10], [:EEVEE, 10], [:CHANSEY, 10]]
    },
:ARENA_TRAINER_GAMBLER_5 => {
      :name => "Fulgence", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SKITTY, 4], [:DROWZEE, 6], [:DRATINI, 6], [:MEOWTH, 10]]
    },
:ARENA_TRAINER_GAMBLER_6 => {
      :name => "Barnabé", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:STARYU, 10], [:SKITTY, 15]]
    },
:ARENA_TRAINER_GAMBLER_7 => {
      :name => "Théodule", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:HAPPINY, 11], [:NATU, 13], [:MUNNA, 16], [:EEVEE, 16]]
    },
:ARENA_TRAINER_GAMBLER_8 => {
      :name => "Joachim", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:LUVDISC, 16], [:VOLTORB, 20]]
    },
:ARENA_TRAINER_GAMBLER_9 => {
      :name => "Gaston", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:WYNAUT, 10], [:SKITTY, 10], [:NATU, 19]]
    },
:ARENA_TRAINER_GAMBLER_10 => {
      :name => "Jules", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PINSIR, 20]]
    },
:ARENA_TRAINER_GAMBLER_11 => {
      :name => "Onésime", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:EEVEE, 20], [:NATU, 25], [:CLEFAIRY, 26]]
    },
:ARENA_TRAINER_GAMBLER_12 => {
      :name => "Honoré", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SKITTY, 20], [:VOLTORB, 22], [:CLEFAIRY, 27]]
    },
:ARENA_TRAINER_GAMBLER_13 => {
      :name => "Paulin", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON, 29], [:DRAGONAIR, 30]]
    },
:ARENA_TRAINER_GAMBLER_14 => {
      :name => "Rémy", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:DELCATTY, 23], [:DELIBIRD, 24], [:FOONGUS, 28], [:MUSHARNA, 28]]
    },
:ARENA_TRAINER_GAMBLER_15 => {
      :name => "Octave", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:WOBBUFFET, 20], [:PORYGON2, 20], [:CLEFAIRY, 21], [:CASTFORM, 25]]
    },
:ARENA_TRAINER_GAMBLER_16 => {
      :name => "Célestin", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:TOGEKISS, 33], [:WOBBUFFET, 35]]
    },
:ARENA_TRAINER_GAMBLER_17 => {
      :name => "Sylvain", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SCYTHER, 31], [:PERSIAN, 33], [:STARMIE, 35], [:DRAGONAIR, 37], [:NINETALES, 37], [:BLISSEY, 40]]
    },
:ARENA_TRAINER_GAMBLER_18 => {
      :name => "Albéric", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:DRAGONAIR, 32], [:GOTHORITA, 38]]
    },
:ARENA_TRAINER_GAMBLER_19 => {
      :name => "Aurèle", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PERSIAN, 30], [:MUSHARNA, 30], [:NINETALES, 31], [:PINSIR, 31], [:DELIBIRD, 38], [:PORYGON, 39]]
    },
:ARENA_TRAINER_GAMBLER_20 => {
      :name => "Amédée", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:NATU, 35]]
    },
:ARENA_TRAINER_GAMBLER_21 => {
      :name => "Henri", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:CASTFORM, 45]]
    },
:ARENA_TRAINER_GAMBLER_22 => {
      :name => "Casimir", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SCYTHER, 42], [:TOGEKISS, 45], [:GOTHITELLE, 48], [:PORYGONZ, 49], [:WOBBUFFET, 50], [:ELECTRODE, 50]]
    },
:ARENA_TRAINER_GAMBLER_23 => {
      :name => "Alphonse", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON, 42], [:ALAKAZAM, 43], [:MUSHARNA, 45]]
    },
:ARENA_TRAINER_GAMBLER_24 => {
      :name => "Prosper", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON, 40], [:TOGETIC, 44], [:TOGEKISS, 46], [:SABLEYE, 47]]
    },
:ARENA_TRAINER_GAMBLER_25 => {
      :name => "Xavier", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:NINETALES, 43], [:TOGEKISS, 44], [:DELCATTY, 46], [:PINSIR, 50]]
    },
:ARENA_TRAINER_GAMBLER_26 => {
      :name => "Télesphore", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:BLISSEY, 52], [:PORYGON, 53], [:HYPNO, 56], [:CHANSEY, 56], [:DITTO, 57]]
    },
:ARENA_TRAINER_GAMBLER_27 => {
      :name => "Léopold", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON2, 55]]
    },
:ARENA_TRAINER_GAMBLER_28 => {
      :name => "Norbert", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:CHANSEY, 50], [:CLEFABLE, 50], [:PINSIR, 51], [:STARMIE, 52], [:DELIBIRD, 56], [:SABLEYE, 60]]
    },
:ARENA_TRAINER_GAMBLER_29 => {
      :name => "Gontran", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGONZ, 51], [:PORYGON2, 57], [:CHIMECHO, 57], [:XATU, 59]]
    },
:ARENA_TRAINER_GAMBLER_30 => {
      :name => "Valentin", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:TOGETIC, 56], [:ALAKAZAM, 57], [:LUVDISC, 58], [:MUSHARNA, 59], [:SCIZOR, 60]]
    },
:ARENA_TRAINER_GAMBLER_31 => {
      :name => "Anselme", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:BLISSEY, 61], [:STARMIE, 62], [:SCIZOR, 65], [:PORYGONZ, 66], [:SPINDA, 67], [:WOBBUFFET, 68]]
    },
:ARENA_TRAINER_GAMBLER_32 => {
      :name => "Hippolyte", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON2, 61], [:BLISSEY, 69]]
    },
:ARENA_TRAINER_GAMBLER_33 => {
      :name => "Ludovic", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:ELECTRODE, 65]]
    },
:ARENA_TRAINER_GAMBLER_34 => {
      :name => "Émile", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:TOGETIC, 67], [:SCIZOR, 67], [:DELCATTY, 69]]
    },
:ARENA_TRAINER_GAMBLER_35 => {
      :name => "Albert", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:HYPNO, 62], [:SPINDA, 63], [:ELECTRODE, 63], [:BLISSEY, 64], [:ALAKAZAM, 66], [:SCYTHER, 68]]
    },
:ARENA_TRAINER_GAMBLER_36 => {
      :name => "Hilaire", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:AMOONGUSS, 70], [:CLEFABLE, 74], [:SCIZOR, 74], [:ELECTRODE, 76], [:SPINDA, 77], [:PORYGONZ, 80]]
    },
:ARENA_TRAINER_GAMBLER_37 => {
      :name => "Edmond", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:HYPNO, 71], [:BLISSEY, 71], [:DELCATTY, 73], [:CHIMECHO, 73], [:ELECTRODE, 74], [:PORYGON2, 76]]
    },
:ARENA_TRAINER_GAMBLER_38 => {
      :name => "Narcisse", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:STARMIE, 73], [:DELIBIRD, 77], [:LUVDISC, 79]]
    },
:ARENA_TRAINER_GAMBLER_39 => {
      :name => "Fernand", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:TOGETIC, 73], [:WOBBUFFET, 75], [:PORYGON, 77]]
    },
:ARENA_TRAINER_GAMBLER_40 => {
      :name => "Basile", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PORYGON2, 70], [:GOTHITELLE, 71], [:STARMIE, 72], [:PORYGONZ, 72], [:ELECTRODE, 73], [:PORYGON, 75]]
    },
:ARENA_TRAINER_GAMBLER_41 => {
      :name => "Oscar", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SCIZOR, 81], [:PINSIR, 84], [:DRAGONITE, 88]]
    },
:ARENA_TRAINER_GAMBLER_42 => {
      :name => "Clément", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:DRAGONITE, 80], [:CHANSEY, 84], [:PORYGONZ, 84], [:SCYTHER, 86], [:NINETALES, 87], [:SABLEYE, 89]]
    },
:ARENA_TRAINER_GAMBLER_43 => {
      :name => "Marcel", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:TOGEKISS, 81], [:CHIMECHO, 81], [:SPINDA, 82], [:PORYGONZ, 83], [:DRAGONITE, 86], [:CASTFORM, 87]]
    },
:ARENA_TRAINER_GAMBLER_44 => {
      :name => "Élie", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:DELIBIRD, 84], [:CHANSEY, 89]]
    },
:ARENA_TRAINER_GAMBLER_45 => {
      :name => "Séraphin", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SABLEYE, 80], [:NINETALES, 81], [:SCYTHER, 83], [:DELIBIRD, 85]]
    },
:ARENA_TRAINER_GAMBLER_46 => {
      :name => "Isidore", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:ALAKAZAM, 90], [:BLISSEY, 90], [:DELCATTY, 91], [:DITTO, 97]]
    },
:ARENA_TRAINER_GAMBLER_47 => {
      :name => "Médéric", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:MUSHARNA, 98], [:SCYTHER, 99]]
    },
:ARENA_TRAINER_GAMBLER_48 => {
      :name => "Eusèbe", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:CHANSEY, 90], [:LUVDISC, 96], [:STARMIE, 96], [:CLEFABLE, 100], [:SCIZOR, 100], [:BLISSEY, 100]]
    },
:ARENA_TRAINER_GAMBLER_49 => {
      :name => "Théophile", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:PERSIAN, 91], [:DELIBIRD, 92], [:PORYGONZ, 96], [:MUSHARNA, 97], [:SABLEYE, 100], [:SCIZOR, 100]]
    },
:ARENA_TRAINER_GAMBLER_50 => {
      :name => "Hubert", :sprite => "trainer_GAMBLER", :type => :GAMBLER,
      :team => [[:SCIZOR, 96], [:PINSIR, 97], [:TOGETIC, 98], [:PORYGON2, 100], [:DRAGONITE, 100], [:HYPNO, 100]]
    },
:ARENA_TRAINER_GENTLEMAN_1 => {
      :name => "Verso", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LILLIPUP, 5], [:GROWLITHE, 4]]
    },
:ARENA_TRAINER_GENTLEMAN_2 => {
      :name => "Constantin", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SHINX, 2], [:DUCKLETT, 2], [:PIPLUP, 2], [:PONYTA, 3], [:RALTS, 9], [:MINCCINO, 9]]
    },
:ARENA_TRAINER_GENTLEMAN_3 => {
      :name => "Évariste", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LILLIPUP, 3], [:MINCCINO, 4], [:ABRA, 7], [:BUDEW, 8], [:SKITTY, 10]]
    },
:ARENA_TRAINER_GENTLEMAN_4 => {
      :name => "Raoul", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:RALTS, 4], [:BEAUTIFLY, 10]]
    },
:ARENA_TRAINER_GENTLEMAN_5 => {
      :name => "Archibald", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ZORUA, 2], [:DEERLING, 6]]
    },
:ARENA_TRAINER_GENTLEMAN_6 => {
      :name => "Theodore", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SNIVY, 14], [:COTTONEE, 17], [:ZORUA, 17]]
    },
:ARENA_TRAINER_GENTLEMAN_7 => {
      :name => "Édouard", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:MUNNA, 14], [:SKITTY, 17], [:MISDREAVUS, 20]]
    },
:ARENA_TRAINER_GENTLEMAN_8 => {
      :name => "Humbert", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:PURRLOIN, 11], [:SNIVY, 15], [:LUXIO, 17]]
    },
:ARENA_TRAINER_GENTLEMAN_9 => {
      :name => "Rodolphe", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:PIPLUP, 13], [:BUTTERFREE, 13], [:SKITTY, 14], [:DELCATTY, 17], [:MURKROW, 19]]
    },
:ARENA_TRAINER_GENTLEMAN_10 => {
      :name => "Julian", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:DUCKLETT, 15]]
    },
:ARENA_TRAINER_GENTLEMAN_11 => {
      :name => "Henri", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ZORUA, 28]]
    },
:ARENA_TRAINER_GENTLEMAN_12 => {
      :name => "Anatole", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SOLOSIS, 21], [:TOGETIC, 22], [:GOTHITA, 26]]
    },
:ARENA_TRAINER_GENTLEMAN_13 => {
      :name => "Alistair", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ABSOL, 23], [:KADABRA, 29]]
    },
:ARENA_TRAINER_GENTLEMAN_14 => {
      :name => "Lancelot", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:MASQUERAIN, 25], [:DUCKLETT, 25], [:GROWLITHE, 25], [:ESPEON, 25], [:EEVEE, 28], [:MISDREAVUS, 30]]
    },
:ARENA_TRAINER_GENTLEMAN_15 => {
      :name => "Gauthier", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:KADABRA, 20], [:ROSELIA, 21], [:SOLOSIS, 26], [:GLAMEOW, 27]]
    },
:ARENA_TRAINER_GENTLEMAN_16 => {
      :name => "Percival", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LUCARIO, 31], [:GLAMEOW, 33], [:EEVEE, 36], [:SLOWKING, 37], [:MINCCINO, 40]]
    },
:ARENA_TRAINER_GENTLEMAN_17 => {
      :name => "Jean-Baptiste", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:DEWOTT, 32], [:PERSIAN, 34], [:AMPHAROS, 39], [:VULPIX, 39]]
    },
:ARENA_TRAINER_GENTLEMAN_18 => {
      :name => "Guillaume", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:EEVEE, 32], [:JOLTEON, 34], [:GOTHORITA, 38], [:WHIMSICOTT, 38], [:PETILIL, 39]]
    },
:ARENA_TRAINER_GENTLEMAN_19 => {
      :name => "Aymeric", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LIEPARD, 30], [:LEAFEON, 35], [:WHIMSICOTT, 35], [:PONYTA, 39]]
    },
:ARENA_TRAINER_GENTLEMAN_20 => {
      :name => "Louis-Philippe", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:GARDEVOIR, 33], [:GALLADE, 33], [:SWANNA, 40]]
    },
:ARENA_TRAINER_GENTLEMAN_21 => {
      :name => "Maximilien", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ROSELIA, 40], [:GARDEVOIR, 43], [:LAPRAS, 45], [:NINETALES, 46]]
    },
:ARENA_TRAINER_GENTLEMAN_22 => {
      :name => "Edmund", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:TOGETIC, 47], [:GALLADE, 47], [:AMPHAROS, 47], [:ROSERADE, 48]]
    },
:ARENA_TRAINER_GENTLEMAN_23 => {
      :name => "Léopold", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:VAPOREON, 40], [:LUXRAY, 44], [:LUCARIO, 49]]
    },
:ARENA_TRAINER_GENTLEMAN_24 => {
      :name => "Valère", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:BRONZONG, 41], [:ALTARIA, 42], [:MEGANIUM, 45], [:AMPHAROS, 48], [:DRAGONAIR, 50]]
    },
:ARENA_TRAINER_GENTLEMAN_25 => {
      :name => "Victor", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LILLIGANT, 40], [:MUNNA, 40], [:AMPHAROS, 47], [:SWANNA, 49]]
    },
:ARENA_TRAINER_GENTLEMAN_26 => {
      :name => "Gaétan", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ESPEON, 51], [:GOTHITELLE, 56]]
    },
:ARENA_TRAINER_GENTLEMAN_27 => {
      :name => "Étienne", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:GALLADE, 50], [:RUFFLET, 51], [:DELCATTY, 55]]
    },
:ARENA_TRAINER_GENTLEMAN_28 => {
      :name => "Augustin", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:RAPIDASH, 50], [:GOTHITELLE, 56], [:BUTTERFREE, 58], [:TOGETIC, 59]]
    },
:ARENA_TRAINER_GENTLEMAN_29 => {
      :name => "Alexandre", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SWANNA, 56], [:SAMUROTT, 57], [:ABSOL, 57], [:BEAUTIFLY, 58]]
    },
:ARENA_TRAINER_GENTLEMAN_30 => {
      :name => "Winston", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:EMPOLEON, 51], [:RUFFLET, 54], [:LILLIGANT, 55], [:VAPOREON, 56], [:SWANNA, 58]]
    },
:ARENA_TRAINER_GENTLEMAN_31 => {
      :name => "Montgomery", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:MUSHARNA, 63], [:GARDEVOIR, 64], [:ESPEON, 65], [:JOLTEON, 69]]
    },
:ARENA_TRAINER_GENTLEMAN_32 => {
      :name => "Gabriel", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SLOWKING, 62], [:GARDEVOIR, 63], [:BEAUTIFLY, 66]]
    },
:ARENA_TRAINER_GENTLEMAN_33 => {
      :name => "Foulques", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SLOWKING, 63], [:DELCATTY, 66], [:RAPIDASH, 66], [:STOUTLAND, 68], [:FLAREON, 68], [:LILLIGANT, 70]]
    },
:ARENA_TRAINER_GENTLEMAN_34 => {
      :name => "Édgar", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:DELCATTY, 67], [:LEAFEON, 67]]
    },
:ARENA_TRAINER_GENTLEMAN_35 => {
      :name => "Auguste", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:RAPIDASH, 63], [:MASQUERAIN, 63], [:KINGDRA, 63], [:LUCARIO, 65], [:GOTHITELLE, 65]]
    },
:ARENA_TRAINER_GENTLEMAN_36 => {
      :name => "Reginald", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SERPERIOR, 70], [:MASQUERAIN, 72], [:WHIMSICOTT, 73], [:RAPIDASH, 74], [:MILOTIC, 75], [:LEAFEON, 78]]
    },
:ARENA_TRAINER_GENTLEMAN_37 => {
      :name => "Perceval", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ALTARIA, 77]]
    },
:ARENA_TRAINER_GENTLEMAN_38 => {
      :name => "Nigel", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ABSOL, 76], [:JOLTEON, 80]]
    },
:ARENA_TRAINER_GENTLEMAN_39 => {
      :name => "Philibert", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ARCANINE, 72], [:CINCCINO, 73], [:BRAVIARY, 75], [:SAMUROTT, 76], [:MUSHARNA, 77]]
    },
:ARENA_TRAINER_GENTLEMAN_40 => {
      :name => "Baudouin", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ALTARIA, 75]]
    },
:ARENA_TRAINER_GENTLEMAN_41 => {
      :name => "Lionel", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:HONCHKROW, 82], [:WHIMSICOTT, 88], [:MEGANIUM, 88]]
    },
:ARENA_TRAINER_GENTLEMAN_42 => {
      :name => "Clarence", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:MILOTIC, 80], [:ABSOL, 83], [:MUSHARNA, 86]]
    },
:ARENA_TRAINER_GENTLEMAN_43 => {
      :name => "Barnabé", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:SAWSBUCK, 80], [:SAMUROTT, 85]]
    },
:ARENA_TRAINER_GENTLEMAN_44 => {
      :name => "Thaddée", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:ALAKAZAM, 81], [:PERSIAN, 87], [:ROSELIA, 90]]
    },
:ARENA_TRAINER_GENTLEMAN_45 => {
      :name => "Maxence", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:GALLADE, 80], [:MISMAGIUS, 84], [:UMBREON, 85], [:TOGETIC, 90]]
    },
:ARENA_TRAINER_GENTLEMAN_46 => {
      :name => "Ludovic", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:BRAVIARY, 90], [:ROSELIA, 98]]
    },
:ARENA_TRAINER_GENTLEMAN_47 => {
      :name => "Gonzague", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:MISMAGIUS, 95]]
    },
:ARENA_TRAINER_GENTLEMAN_48 => {
      :name => "Gontran", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:LUXRAY, 93], [:FLAREON, 95], [:MEGANIUM, 96], [:BEAUTIFLY, 97], [:AMPHAROS, 98], [:ZOROARK, 99]]
    },
:ARENA_TRAINER_GENTLEMAN_49 => {
      :name => "Casimir", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:DELCATTY, 92], [:GALLADE, 94], [:ALAKAZAM, 94], [:MASQUERAIN, 96], [:REUNICLUS, 100]]
    },
:ARENA_TRAINER_GENTLEMAN_50 => {
      :name => "Arthur", :sprite => "trainer_GENTLEMAN", :type => :GENTLEMAN,
      :team => [[:TOGEKISS, 90], [:ZOROARK, 92], [:JOLTEON, 95], [:UMBREON, 95], [:SWANNA, 100]]
    },
:ARENA_TRAINER_HIKER_1 => {
      :name => "Noah", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:GEODUDE, 5], [:LARVITAR, 4]]
    },
:ARENA_TRAINER_HIKER_2 => {
      :name => "Joël", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:TIRTOUGA, 2], [:ANORITH, 10]]
    },
:ARENA_TRAINER_HIKER_3 => {
      :name => "Gaston", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:TIRTOUGA, 2], [:ARCHEN, 5], [:DWEBBLE, 7], [:NOSEPASS, 10], [:ARON, 10], [:RHYHORN, 10]]
    },
:ARENA_TRAINER_HIKER_4 => {
      :name => "Heinrich", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CRANIDOS, 2], [:DWEBBLE, 3], [:GEODUDE, 4], [:RHYHORN, 8], [:BONSLY, 8]]
    },
:ARENA_TRAINER_HIKER_5 => {
      :name => "Anselme", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:GEODUDE, 6], [:DWEBBLE, 7]]
    },
:ARENA_TRAINER_HIKER_6 => {
      :name => "Bastien", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RHYHORN, 10], [:CRANIDOS, 13], [:BONSLY, 15], [:SHIELDON, 17], [:GEODUDE, 20]]
    },
:ARENA_TRAINER_HIKER_7 => {
      :name => "Riccardo", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:DWEBBLE, 17]]
    },
:ARENA_TRAINER_HIKER_8 => {
      :name => "Sylvain", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CUBCHOO, 11], [:ONIX, 17], [:SUDOWOODO, 18]]
    },
:ARENA_TRAINER_HIKER_9 => {
      :name => "Ludovic", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RHYHORN, 10], [:CRANIDOS, 16], [:SUDOWOODO, 18], [:ARON, 20]]
    },
:ARENA_TRAINER_HIKER_10 => {
      :name => "Nawang", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:ROGGENROLA, 11], [:DWEBBLE, 14], [:RIOLU, 14], [:NOSEPASS, 17], [:ARCHEN, 18]]
    },
:ARENA_TRAINER_HIKER_11 => {
      :name => "Clément", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SHIELDON, 21], [:ANORITH, 25]]
    },
:ARENA_TRAINER_HIKER_12 => {
      :name => "Christophe", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:NOSEPASS, 25], [:DWEBBLE, 25], [:KABUTO, 30]]
    },
:ARENA_TRAINER_HIKER_13 => {
      :name => "Arnaud", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:GEODUDE, 21], [:ARCHEN, 22], [:ARON, 23], [:LILEEP, 26], [:TIRTOUGA, 29]]
    },
:ARENA_TRAINER_HIKER_14 => {
      :name => "Frédéric", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:PHANPY, 20], [:GEODUDE, 21], [:RELICANTH, 24], [:ARCHEN, 25], [:RIOLU, 27], [:CRANIDOS, 29]]
    },
:ARENA_TRAINER_HIKER_15 => {
      :name => "Roland", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:TIRTOUGA, 20], [:DONPHAN, 27]]
    },
:ARENA_TRAINER_HIKER_16 => {
      :name => "George", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:STEELIX, 35]]
    },
:ARENA_TRAINER_HIKER_17 => {
      :name => "Mathieu", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SHUCKLE, 35]]
    },
:ARENA_TRAINER_HIKER_18 => {
      :name => "Éric", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:GOLEM, 38]]
    },
:ARENA_TRAINER_HIKER_19 => {
      :name => "Alex", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RELICANTH, 30], [:DONPHAN, 33], [:LILEEP, 35], [:PUPITAR, 35], [:AERODACTYL, 35], [:GIGALITH, 36]]
    },
:ARENA_TRAINER_HIKER_20 => {
      :name => "Edmund", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RELICANTH, 32], [:LAIRON, 34], [:RHYHORN, 35], [:SKARMORY, 38]]
    },
:ARENA_TRAINER_HIKER_21 => {
      :name => "Pierre", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RHYHORN, 41], [:MAMOSWINE, 49]]
    },
:ARENA_TRAINER_HIKER_22 => {
      :name => "Lorenzo", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:AERODACTYL, 42], [:RAMPARDOS, 43], [:SHUCKLE, 45]]
    },
:ARENA_TRAINER_HIKER_23 => {
      :name => "Marc", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:LUNATONE, 50]]
    },
:ARENA_TRAINER_HIKER_24 => {
      :name => "Jérémie", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:AERODACTYL, 44], [:GIGALITH, 45], [:PILOSWINE, 49]]
    },
:ARENA_TRAINER_HIKER_25 => {
      :name => "Benoît", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:ANORITH, 40], [:RAMPARDOS, 41], [:RELICANTH, 43], [:CORSOLA, 46], [:CARRACOSTA, 50], [:STEELIX, 50]]
    },
:ARENA_TRAINER_HIKER_26 => {
      :name => "Bernard", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CORSOLA, 51], [:CARRACOSTA, 55]]
    },
:ARENA_TRAINER_HIKER_27 => {
      :name => "Patrick", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RHYPERIOR, 52], [:RAMPARDOS, 57]]
    },
:ARENA_TRAINER_HIKER_28 => {
      :name => "Hugo", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:LUNATONE, 56], [:ABOMASNOW, 60]]
    },
:ARENA_TRAINER_HIKER_29 => {
      :name => "Yannick", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:TYRANITAR, 56]]
    },
:ARENA_TRAINER_HIKER_30 => {
      :name => "Pascal", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CRUSTLE, 50], [:RHYDON, 51], [:ARCHEOPS, 53], [:BASTIODON, 59]]
    },
:ARENA_TRAINER_HIKER_31 => {
      :name => "Étienne", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RHYPERIOR, 66], [:ARMALDO, 67]]
    },
:ARENA_TRAINER_HIKER_32 => {
      :name => "Kami", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:TYRANITAR, 65]]
    },
:ARENA_TRAINER_HIKER_33 => {
      :name => "Hermann", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CRADILY, 63], [:RAMPARDOS, 67]]
    },
:ARENA_TRAINER_HIKER_34 => {
      :name => "Jean-Antoine", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:PILOSWINE, 60], [:RAMPARDOS, 66], [:GOLEM, 68], [:TYRANITAR, 68]]
    },
:ARENA_TRAINER_HIKER_35 => {
      :name => "Sandro", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SUDOWOODO, 61], [:TYRANITAR, 65], [:SHUCKLE, 65], [:CARRACOSTA, 66], [:RHYPERIOR, 68], [:ARMALDO, 70]]
    },
:ARENA_TRAINER_HIKER_36 => {
      :name => "Maurice", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:RAMPARDOS, 70], [:GLISCOR, 72], [:CORSOLA, 78], [:RELICANTH, 79]]
    },
:ARENA_TRAINER_HIKER_37 => {
      :name => "Jean-Marc", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:PROBOPASS, 73], [:AERODACTYL, 73], [:CRADILY, 74], [:RAMPARDOS, 74], [:ARMALDO, 76]]
    },
:ARENA_TRAINER_HIKER_38 => {
      :name => "Gérard", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:LUCARIO, 71], [:SOLROCK, 71], [:MAMOSWINE, 73], [:PROBOPASS, 80]]
    },
:ARENA_TRAINER_HIKER_39 => {
      :name => "Jacques", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SHUCKLE, 70], [:CORSOLA, 70], [:PROBOPASS, 71], [:RAMPARDOS, 72], [:SUDOWOODO, 74], [:OMASTAR, 77]]
    },
:ARENA_TRAINER_HIKER_40 => {
      :name => "Walter", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SUDOWOODO, 75]]
    },
:ARENA_TRAINER_HIKER_41 => {
      :name => "Anatoli", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:PILOSWINE, 85], [:ARMALDO, 86], [:CARRACOSTA, 87], [:AERODACTYL, 88], [:TYRANITAR, 89], [:AGGRON, 90]]
    },
:ARENA_TRAINER_HIKER_42 => {
      :name => "Axel", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:ABOMASNOW, 88], [:STEELIX, 89], [:SHUCKLE, 89]]
    },
:ARENA_TRAINER_HIKER_43 => {
      :name => "Dorje", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:GIGALITH, 90]]
    },
:ARENA_TRAINER_HIKER_44 => {
      :name => "Rémi", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:STEELIX, 80], [:RELICANTH, 80], [:OMASTAR, 82], [:ABOMASNOW, 86]]
    },
:ARENA_TRAINER_HIKER_45 => {
      :name => "Gaspard", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:AGGRON, 80], [:SHUCKLE, 81], [:ARMALDO, 88], [:CORSOLA, 90]]
    },
:ARENA_TRAINER_HIKER_46 => {
      :name => "Ueli", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:SKARMORY, 93], [:BASTIODON, 93], [:MAMOSWINE, 94], [:SUDOWOODO, 95], [:ARMALDO, 100]]
    },
:ARENA_TRAINER_HIKER_47 => {
      :name => "Lucien", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:AGGRON, 92], [:RELICANTH, 93], [:SOLROCK, 97], [:KABUTOPS, 99]]
    },
:ARENA_TRAINER_HIKER_48 => {
      :name => "Dawa", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:CORSOLA, 93], [:LUNATONE, 94], [:TYRANITAR, 96]]
    },
:ARENA_TRAINER_HIKER_49 => {
      :name => "Tenzing", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:AGGRON, 93], [:KABUTOPS, 96], [:BASTIODON, 99], [:MACHAMP, 100]]
    },
:ARENA_TRAINER_HIKER_50 => {
      :name => "Marco", :sprite => "trainer_HIKER", :type => :HIKER,
      :team => [[:MAMOSWINE, 91], [:CORSOLA, 98]]
    },
:ARENA_TRAINER_JUGGLER_1 => {
      :name => "Pinder", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:VOLTORB, 5], [:DROWZEE, 4]]
    },
:ARENA_TRAINER_JUGGLER_2 => {
      :name => "Xavier", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:FOONGUS, 7], [:WHISMUR, 8], [:SPHEAL, 9]]
    },
:ARENA_TRAINER_JUGGLER_3 => {
      :name => "Tiberio", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:WAILMER, 6]]
    },
:ARENA_TRAINER_JUGGLER_4 => {
      :name => "Calixte", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PHANPY, 3], [:PANSEAR, 6], [:VOLTORB, 10]]
    },
:ARENA_TRAINER_JUGGLER_5 => {
      :name => "Ignace", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:CHINGLING, 4], [:WAILMER, 6], [:TYROGUE, 7], [:DITTO, 7], [:DRIFLOON, 8]]
    },
:ARENA_TRAINER_JUGGLER_6 => {
      :name => "Séraphin", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:KECLEON, 19]]
    },
:ARENA_TRAINER_JUGGLER_7 => {
      :name => "Buster", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:IGGLYBUFF, 11], [:WYNAUT, 11], [:SPHEAL, 12], [:FOONGUS, 18], [:TYROGUE, 19], [:WOBBUFFET, 20]]
    },
:ARENA_TRAINER_JUGGLER_8 => {
      :name => "Rafael", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:AZURILL, 11], [:DELIBIRD, 12], [:ZORUA, 15], [:PINECO, 17], [:EXEGGCUTE, 18]]
    },
:ARENA_TRAINER_JUGGLER_9 => {
      :name => "Barnabé", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DRIFLOON, 10], [:PINECO, 13], [:EXEGGCUTE, 16], [:PHANPY, 17], [:CHERUBI, 19]]
    },
:ARENA_TRAINER_JUGGLER_10 => {
      :name => "Quentin", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PINECO, 10], [:SEEL, 14], [:MACHOP, 17], [:PACHIRISU, 18], [:VOLTORB, 19]]
    },
:ARENA_TRAINER_JUGGLER_11 => {
      :name => "Valentin", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:WOBBUFFET, 22], [:MUNCHLAX, 22], [:PONYTA, 22], [:DRIFLOON, 27], [:MANKEY, 27], [:AZUMARILL, 28]]
    },
:ARENA_TRAINER_JUGGLER_12 => {
      :name => "Antoine", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:WIGGLYTUFF, 21], [:WAILMER, 25], [:VOLTORB, 25], [:DONPHAN, 28]]
    },
:ARENA_TRAINER_JUGGLER_13 => {
      :name => "Cosimo", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:FOONGUS, 21], [:SMOOCHUM, 21], [:WAILMER, 25], [:DELIBIRD, 26], [:CHATOT, 26]]
    },
:ARENA_TRAINER_JUGGLER_14 => {
      :name => "Wolfgang", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PACHIRISU, 20], [:KADABRA, 22], [:PANPOUR, 23], [:HITMONLEE, 26], [:HYPNO, 28]]
    },
:ARENA_TRAINER_JUGGLER_15 => {
      :name => "Néo", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SPHEAL, 20], [:VOLTORB, 21], [:ZORUA, 23], [:SPINDA, 24], [:JUMPLUFF, 29]]
    },
:ARENA_TRAINER_JUGGLER_16 => {
      :name => "Pierre", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DRIFBLIM, 34], [:CHIMECHO, 34], [:WOBBUFFET, 35], [:EXEGGCUTE, 36], [:KECLEON, 40], [:WIGGLYTUFF, 40]]
    },
:ARENA_TRAINER_JUGGLER_17 => {
      :name => "Achille", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:CHERRIM, 30], [:EXEGGUTOR, 34], [:GRUMPIG, 35], [:WIGGLYTUFF, 36], [:CHIMECHO, 39]]
    },
:ARENA_TRAINER_JUGGLER_18 => {
      :name => "Jonathan", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:CHERRIM, 31], [:FOONGUS, 35], [:JUMPLUFF, 38], [:JYNX, 39]]
    },
:ARENA_TRAINER_JUGGLER_19 => {
      :name => "Roy", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PANPOUR, 30], [:MRMIME, 30], [:JYNX, 32], [:PANSEAR, 37], [:FORRETRESS, 39]]
    },
:ARENA_TRAINER_JUGGLER_20 => {
      :name => "Dimitri", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DELIBIRD, 31], [:FORRETRESS, 32], [:WOBBUFFET, 33], [:WAILMER, 34], [:AMOONGUSS, 39]]
    },
:ARENA_TRAINER_JUGGLER_21 => {
      :name => "Alphonse", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SIMIPOUR, 41], [:SEALEO, 42], [:DITTO, 42], [:CHERRIM, 44], [:HYPNO, 50]]
    },
:ARENA_TRAINER_JUGGLER_22 => {
      :name => "Gaston", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SMEARGLE, 48]]
    },
:ARENA_TRAINER_JUGGLER_23 => {
      :name => "Bertrand", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:WAILORD, 42], [:DRIFBLIM, 50]]
    },
:ARENA_TRAINER_JUGGLER_24 => {
      :name => "Grock", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SPINDA, 46], [:CHERRIM, 48], [:SIMIPOUR, 49]]
    },
:ARENA_TRAINER_JUGGLER_25 => {
      :name => "Marcel", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SIMIPOUR, 40], [:WIGGLYTUFF, 43], [:AMBIPOM, 47], [:HYPNO, 48], [:WOBBUFFET, 48], [:RAPIDASH, 50]]
    },
:ARENA_TRAINER_JUGGLER_26 => {
      :name => "Maurice", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DITTO, 54], [:CHERRIM, 54], [:HITMONLEE, 57]]
    },
:ARENA_TRAINER_JUGGLER_27 => {
      :name => "Oleg", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SMEARGLE, 50], [:WIGGLYTUFF, 51], [:JUMPLUFF, 51], [:SPINDA, 53], [:DITTO, 53], [:ELECTRODE, 58]]
    },
:ARENA_TRAINER_JUGGLER_28 => {
      :name => "Yanis", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DITTO, 52], [:ZOROARK, 56], [:EXEGGUTOR, 56], [:DONPHAN, 60], [:GRUMPIG, 60]]
    },
:ARENA_TRAINER_JUGGLER_29 => {
      :name => "Gianni", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DONPHAN, 52], [:SMEARGLE, 54], [:AMOONGUSS, 55], [:SIMIPOUR, 56], [:MACHAMP, 60]]
    },
:ARENA_TRAINER_JUGGLER_30 => {
      :name => "Emmett", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:AZUMARILL, 51], [:HITMONLEE, 52], [:SPINDA, 54], [:GRUMPIG, 56]]
    },
:ARENA_TRAINER_JUGGLER_31 => {
      :name => "Ludovic", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DELIBIRD, 66]]
    },
:ARENA_TRAINER_JUGGLER_32 => {
      :name => "Ulysse", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SMEARGLE, 67], [:HYPNO, 67]]
    },
:ARENA_TRAINER_JUGGLER_33 => {
      :name => "Joseph", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:MRMIME, 60], [:SIMISEAR, 62], [:WOBBUFFET, 63], [:HYPNO, 63], [:AMOONGUSS, 65], [:HITMONCHAN, 65]]
    },
:ARENA_TRAINER_JUGGLER_34 => {
      :name => "Fabrizio", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:GRUMPIG, 66]]
    },
:ARENA_TRAINER_JUGGLER_35 => {
      :name => "Pablo", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:WALREIN, 60], [:CHATOT, 63], [:CHERRIM, 64], [:DONPHAN, 66], [:HYPNO, 69]]
    },
:ARENA_TRAINER_JUGGLER_36 => {
      :name => "Max", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:AMOONGUSS, 76]]
    },
:ARENA_TRAINER_JUGGLER_37 => {
      :name => "Zéphyr", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:EXPLOUD, 75], [:MACHAMP, 76], [:SIMIPOUR, 79]]
    },
:ARENA_TRAINER_JUGGLER_38 => {
      :name => "Léon", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DEWGONG, 71], [:PRIMEAPE, 76], [:JYNX, 77], [:FORRETRESS, 79], [:DONPHAN, 80]]
    },
:ARENA_TRAINER_JUGGLER_39 => {
      :name => "Théo", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:CHERRIM, 70], [:ALAKAZAM, 74], [:CHATOT, 77], [:MACHAMP, 79]]
    },
:ARENA_TRAINER_JUGGLER_40 => {
      :name => "Lorenzo", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:AMOONGUSS, 70], [:MACHAMP, 72], [:HITMONTOP, 73], [:WALREIN, 75], [:WIGGLYTUFF, 76]]
    },
:ARENA_TRAINER_JUGGLER_41 => {
      :name => "Harry", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:DEWGONG, 85]]
    },
:ARENA_TRAINER_JUGGLER_42 => {
      :name => "Gédéon", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:RAPIDASH, 82], [:SPINDA, 83], [:KECLEON, 84], [:AZUMARILL, 86], [:FORRETRESS, 87], [:SIMIPOUR, 90]]
    },
:ARENA_TRAINER_JUGGLER_43 => {
      :name => "Charlie", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:FORRETRESS, 88], [:JUMPLUFF, 89], [:WAILORD, 89], [:AMBIPOM, 90]]
    },
:ARENA_TRAINER_JUGGLER_44 => {
      :name => "David", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:RAPIDASH, 80], [:AZUMARILL, 82], [:HITMONCHAN, 86], [:AMBIPOM, 88]]
    },
:ARENA_TRAINER_JUGGLER_45 => {
      :name => "Auguste", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:CHIMECHO, 80], [:EXPLOUD, 82], [:SIMIPOUR, 84], [:DRIFBLIM, 85], [:SPINDA, 88], [:SNORLAX, 90]]
    },
:ARENA_TRAINER_JUGGLER_46 => {
      :name => "Hector", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:AMOONGUSS, 92], [:DONPHAN, 98]]
    },
:ARENA_TRAINER_JUGGLER_47 => {
      :name => "Rodolphe", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:SIMISAGE, 91], [:DRIFBLIM, 91], [:SNORLAX, 99]]
    },
:ARENA_TRAINER_JUGGLER_48 => {
      :name => "Philibert", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PRIMEAPE, 92], [:PACHIRISU, 94], [:CHERRIM, 98], [:ZOROARK, 100], [:DITTO, 100], [:GRUMPIG, 100]]
    },
:ARENA_TRAINER_JUGGLER_49 => {
      :name => "Vittorio", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:PRIMEAPE, 90], [:GRUMPIG, 91], [:ZOROARK, 92], [:EXEGGUTOR, 93], [:MRMIME, 95], [:DITTO, 100]]
    },
:ARENA_TRAINER_JUGGLER_50 => {
      :name => "Grippe-sou", :sprite => "trainer_JUGGLER", :type => :JUGGLER,
      :team => [[:ELECTRODE, 91], [:MACHAMP, 91], [:JYNX, 96], [:JUMPLUFF, 97]]
    },
:ARENA_TRAINER_LADY_1 => {
      :name => "Ludivine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:PURRLOIN, 5], [:CLEFFA, 4]]
    },
:ARENA_TRAINER_LADY_2 => {
      :name => "Philippine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:AZURILL, 4], [:PETILIL, 6], [:VULPIX, 9]]
    },
:ARENA_TRAINER_LADY_3 => {
      :name => "Isabella", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MUNNA, 4], [:BUNEARY, 4], [:WURMPLE, 6]]
    },
:ARENA_TRAINER_LADY_4 => {
      :name => "Genevieve", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:COTTONEE, 7], [:BUDEW, 8], [:DUCKLETT, 10], [:ROSELIA, 10]]
    },
:ARENA_TRAINER_LADY_5 => {
      :name => "Octavia", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:BUDEW, 2], [:HAPPINY, 5], [:PETILIL, 7], [:TOGEPI, 10]]
    },
:ARENA_TRAINER_LADY_6 => {
      :name => "Madeleine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:KIRLIA, 20]]
    },
:ARENA_TRAINER_LADY_7 => {
      :name => "Eleanor", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:FEEBAS, 15]]
    },
:ARENA_TRAINER_LADY_8 => {
      :name => "Cecilia", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CHIKORITA, 12], [:CLEFAIRY, 14], [:CLEFABLE, 15], [:DELCATTY, 17]]
    },
:ARENA_TRAINER_LADY_9 => {
      :name => "Salomé", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:PETILIL, 10], [:ROSELIA, 10], [:MUNNA, 11], [:BEAUTIFLY, 13], [:VULPIX, 14], [:EEVEE, 19]]
    },
:ARENA_TRAINER_LADY_10 => {
      :name => "Garance", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:TOGEPI, 15], [:CLEFABLE, 15], [:COTTONEE, 19]]
    },
:ARENA_TRAINER_LADY_11 => {
      :name => "Ophélie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MANTINE, 20], [:MASQUERAIN, 28], [:CHERRIM, 29], [:GLACEON, 29]]
    },
:ARENA_TRAINER_LADY_12 => {
      :name => "Capucine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:LOPUNNY, 20], [:SERVINE, 23], [:DELCATTY, 24], [:SURSKIT, 24], [:DUCKLETT, 27], [:WHIMSICOTT, 30]]
    },
:ARENA_TRAINER_LADY_13 => {
      :name => "Seraphina", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSELIA, 23], [:AZUMARILL, 24], [:VESPIQUEN, 30]]
    },
:ARENA_TRAINER_LADY_14 => {
      :name => "Rosalie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:SERVINE, 23], [:DELCATTY, 24], [:VESPIQUEN, 24], [:CHERRIM, 27]]
    },
:ARENA_TRAINER_LADY_15 => {
      :name => "Amelia", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:SWABLU, 20], [:ESPEON, 25], [:LOPUNNY, 25], [:WHIMSICOTT, 26]]
    },
:ARENA_TRAINER_LADY_16 => {
      :name => "Astrid", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MINCCINO, 31], [:PETILIL, 33], [:GLACEON, 37], [:LOPUNNY, 38], [:ALTARIA, 38]]
    },
:ARENA_TRAINER_LADY_17 => {
      :name => "Aurore", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MASQUERAIN, 35], [:BEAUTIFLY, 35], [:ROSERADE, 37], [:CINCCINO, 37]]
    },
:ARENA_TRAINER_LADY_18 => {
      :name => "Marie-Charlotte", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:AZUMARILL, 35]]
    },
:ARENA_TRAINER_LADY_19 => {
      :name => "Mathilde", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MINCCINO, 34], [:CHIMECHO, 37], [:MUSHARNA, 39], [:LEAFEON, 40]]
    },
:ARENA_TRAINER_LADY_20 => {
      :name => "Theodora", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MILOTIC, 30], [:SERVINE, 34], [:LIEPARD, 37], [:SWANNA, 38]]
    },
:ARENA_TRAINER_LADY_21 => {
      :name => "Albane", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CHANSEY, 42], [:BEAUTIFLY, 43], [:AZUMARILL, 44], [:SERPERIOR, 46], [:UMBREON, 48]]
    },
:ARENA_TRAINER_LADY_22 => {
      :name => "Lavinia", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CLEFABLE, 43], [:ESPEON, 45], [:SAWSBUCK, 47], [:RAPIDASH, 47], [:CINCCINO, 49], [:NINETALES, 50]]
    },
:ARENA_TRAINER_LADY_23 => {
      :name => "Evangeline", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSELIA, 40], [:DELCATTY, 41], [:MEGANIUM, 44], [:VESPIQUEN, 47], [:UMBREON, 50], [:TOGEKISS, 50]]
    },
:ARENA_TRAINER_LADY_24 => {
      :name => "Léonie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:BLISSEY, 48], [:ROSELIA, 49]]
    },
:ARENA_TRAINER_LADY_25 => {
      :name => "Tiphaine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MEGANIUM, 46]]
    },
:ARENA_TRAINER_LADY_26 => {
      :name => "Sixtine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MANTINE, 59]]
    },
:ARENA_TRAINER_LADY_27 => {
      :name => "Eugénie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSERADE, 55]]
    },
:ARENA_TRAINER_LADY_28 => {
      :name => "Georgiana", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MUSHARNA, 55], [:RAPIDASH, 59]]
    },
:ARENA_TRAINER_LADY_29 => {
      :name => "Arabella", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSELIA, 50], [:LEAFEON, 56], [:RAPIDASH, 59]]
    },
:ARENA_TRAINER_LADY_30 => {
      :name => "Pénélope", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:SAWSBUCK, 54], [:LIEPARD, 58]]
    },
:ARENA_TRAINER_LADY_31 => {
      :name => "Juliette", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSELIA, 61], [:UMBREON, 61], [:TOGEKISS, 64], [:LOPUNNY, 65], [:PERSIAN, 68]]
    },
:ARENA_TRAINER_LADY_32 => {
      :name => "Camille", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:BEAUTIFLY, 65]]
    },
:ARENA_TRAINER_LADY_33 => {
      :name => "Anne-Sophie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:BEAUTIFLY, 61], [:ROSERADE, 62], [:CLEFABLE, 62], [:LOPUNNY, 62], [:MEGANIUM, 67], [:NINETALES, 68]]
    },
:ARENA_TRAINER_LADY_34 => {
      :name => "Charlotte", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MEGANIUM, 62], [:NINETALES, 70]]
    },
:ARENA_TRAINER_LADY_35 => {
      :name => "Cordélia", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:SWANNA, 64], [:CLEFABLE, 66], [:LIEPARD, 67], [:AZUMARILL, 69], [:PERSIAN, 70]]
    },
:ARENA_TRAINER_LADY_36 => {
      :name => "Josephine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:BLISSEY, 75]]
    },
:ARENA_TRAINER_LADY_37 => {
      :name => "Beatrice", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CHIMECHO, 72], [:GLACEON, 80]]
    },
:ARENA_TRAINER_LADY_38 => {
      :name => "Rosamund", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:UMBREON, 70], [:CINCCINO, 73], [:SERPERIOR, 75], [:WHIMSICOTT, 75], [:CLEFABLE, 76]]
    },
:ARENA_TRAINER_LADY_39 => {
      :name => "Diane", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CLEFABLE, 75], [:WHIMSICOTT, 76], [:SERPERIOR, 79], [:ROSERADE, 80]]
    },
:ARENA_TRAINER_LADY_40 => {
      :name => "Hélène", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:VAPOREON, 77]]
    },
:ARENA_TRAINER_LADY_41 => {
      :name => "Joséphine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CINCCINO, 81], [:ESPEON, 90]]
    },
:ARENA_TRAINER_LADY_42 => {
      :name => "Clémence", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:CHIMECHO, 86]]
    },
:ARENA_TRAINER_LADY_43 => {
      :name => "Honorine", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ROSELIA, 83], [:LIEPARD, 90]]
    },
:ARENA_TRAINER_LADY_44 => {
      :name => "Marguerite", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:ALTARIA, 80], [:MASQUERAIN, 83], [:LOPUNNY, 84], [:NINETALES, 85], [:GARDEVOIR, 90]]
    },
:ARENA_TRAINER_LADY_45 => {
      :name => "Violette", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MANTINE, 88]]
    },
:ARENA_TRAINER_LADY_46 => {
      :name => "Victoire", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:LEAFEON, 90], [:CINCCINO, 94], [:LILLIGANT, 96], [:SERPERIOR, 99]]
    },
:ARENA_TRAINER_LADY_47 => {
      :name => "Éloïse", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:MILOTIC, 93], [:BLISSEY, 93], [:GARDEVOIR, 93], [:MEGANIUM, 98]]
    },
:ARENA_TRAINER_LADY_48 => {
      :name => "Domitille", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:LILLIGANT, 93], [:MANTINE, 95], [:CHERRIM, 98]]
    },
:ARENA_TRAINER_LADY_49 => {
      :name => "Ingrid", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:SERPERIOR, 90], [:MEGANIUM, 95], [:AZUMARILL, 98], [:TOGETIC, 99]]
    },
:ARENA_TRAINER_LADY_50 => {
      :name => "Zélie", :sprite => "trainer_LADY", :type => :LADY,
      :team => [[:LILLIGANT, 90], [:AZUMARILL, 93], [:DELCATTY, 98]]
    },
:ARENA_TRAINER_LASS_1 => {
      :name => "Olivia", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:SMOOCHUM, 5], [:PICHU, 4]]
    },
:ARENA_TRAINER_LASS_2 => {
      :name => "Lola", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:BIDOOF, 4], [:OSHAWOTT, 4], [:CLEFAIRY, 8]]
    },
:ARENA_TRAINER_LASS_3 => {
      :name => "Maëlle", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:KLINK, 6], [:COTTONEE, 8], [:CHERUBI, 10]]
    },
:ARENA_TRAINER_LASS_4 => {
      :name => "Léonie", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:VULPIX, 2], [:TURTWIG, 8], [:LILLIPUP, 8], [:PIPLUP, 9]]
    },
:ARENA_TRAINER_LASS_5 => {
      :name => "Sasha", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MUNNA, 4], [:CHIMCHAR, 5], [:SEEDOT, 7], [:CHIKORITA, 8]]
    },
:ARENA_TRAINER_LASS_6 => {
      :name => "Manon", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PICHU, 11], [:SENTRET, 15]]
    },
:ARENA_TRAINER_LASS_7 => {
      :name => "Ninon", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:DUCKLETT, 10], [:COTTONEE, 11], [:LILLIPUP, 12], [:AZURILL, 13], [:CUBCHOO, 18], [:SPINDA, 18]]
    },
:ARENA_TRAINER_LASS_8 => {
      :name => "Roxane", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:WOOPER, 13], [:PHANPY, 18], [:MEOWTH, 18], [:SWABLU, 18], [:MUNNA, 18], [:FOONGUS, 19]]
    },
:ARENA_TRAINER_LASS_9 => {
      :name => "Mélia", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:RATTATA, 15]]
    },
:ARENA_TRAINER_LASS_10 => {
      :name => "Lina", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:VULPIX, 10], [:CLEFAIRY, 15]]
    },
:ARENA_TRAINER_LASS_11 => {
      :name => "Inès", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:CHERUBI, 22], [:TOGETIC, 25]]
    },
:ARENA_TRAINER_LASS_12 => {
      :name => "Lyna", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:COTTONEE, 20], [:PIKACHU, 21], [:FOONGUS, 24], [:PHANPY, 24], [:TOGETIC, 28], [:SMOOCHUM, 28]]
    },
:ARENA_TRAINER_LASS_13 => {
      :name => "Agathe", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MEOWTH, 24], [:DEERLING, 25], [:AZUMARILL, 26], [:CUBCHOO, 30], [:MINUN, 30]]
    },
:ARENA_TRAINER_LASS_14 => {
      :name => "Émilie", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 22], [:PIDGEY, 23], [:MINCCINO, 24], [:DUCKLETT, 29]]
    },
:ARENA_TRAINER_LASS_15 => {
      :name => "Lison", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:TOGETIC, 23], [:PETILIL, 26], [:ELEKID, 30], [:FLAAFFY, 30]]
    },
:ARENA_TRAINER_LASS_16 => {
      :name => "Jade", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PLUSLE, 32], [:DUCKLETT, 35], [:PACHIRISU, 35]]
    },
:ARENA_TRAINER_LASS_17 => {
      :name => "Naïs", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PETILIL, 32], [:MUNNA, 34], [:EMOLGA, 36], [:MINCCINO, 37], [:PACHIRISU, 37], [:SUNKERN, 39]]
    },
:ARENA_TRAINER_LASS_18 => {
      :name => "Nina", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 35], [:TOGETIC, 40]]
    },
:ARENA_TRAINER_LASS_19 => {
      :name => "Ambre", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PETILIL, 31], [:AZUMARILL, 31], [:SPINDA, 32], [:FOONGUS, 34], [:SUNKERN, 38], [:PLUSLE, 40]]
    },
:ARENA_TRAINER_LASS_20 => {
      :name => "Lana", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:SWABLU, 33], [:CUBCHOO, 34], [:COTTONEE, 34], [:MUNNA, 36], [:FOONGUS, 37]]
    },
:ARENA_TRAINER_LASS_21 => {
      :name => "Suzanne", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 42], [:MINUN, 47], [:TOGETIC, 50]]
    },
:ARENA_TRAINER_LASS_22 => {
      :name => "Olympe", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:AZUMARILL, 40], [:PLUSLE, 40], [:PIKACHU, 42], [:EEVEE, 42], [:PACHIRISU, 44], [:TOGETIC, 47]]
    },
:ARENA_TRAINER_LASS_23 => {
      :name => "Jeanne", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 40], [:EMOLGA, 40], [:COTTONEE, 44], [:AZUMARILL, 48], [:MINUN, 48], [:PLUSLE, 50]]
    },
:ARENA_TRAINER_LASS_24 => {
      :name => "Faustine", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:TOGETIC, 40], [:SPINDA, 46]]
    },
:ARENA_TRAINER_LASS_25 => {
      :name => "Maïwenn", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 48]]
    },
:ARENA_TRAINER_LASS_26 => {
      :name => "Eden", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 53], [:MINUN, 55], [:AZUMARILL, 58], [:EMOLGA, 59]]
    },
:ARENA_TRAINER_LASS_27 => {
      :name => "Lou", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PLUSLE, 53], [:SPINDA, 57], [:MINUN, 58], [:PACHIRISU, 59], [:PIKACHU, 59]]
    },
:ARENA_TRAINER_LASS_28 => {
      :name => "Gabrielle", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:SPINDA, 52], [:PLUSLE, 54], [:PIKACHU, 58], [:PACHIRISU, 58]]
    },
:ARENA_TRAINER_LASS_29 => {
      :name => "Clémence", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:EMOLGA, 50], [:PLUSLE, 52], [:MINUN, 53], [:TOGETIC, 59]]
    },
:ARENA_TRAINER_LASS_30 => {
      :name => "Lilas", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:EMOLGA, 50], [:MINUN, 53], [:TOGETIC, 54], [:AZUMARILL, 59], [:PACHIRISU, 60]]
    },
:ARENA_TRAINER_LASS_31 => {
      :name => "Apolline", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:TOGETIC, 60], [:EMOLGA, 65], [:SPINDA, 66], [:PLUSLE, 67]]
    },
:ARENA_TRAINER_LASS_32 => {
      :name => "Zoé", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 65]]
    },
:ARENA_TRAINER_LASS_33 => {
      :name => "Thaïs", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 65]]
    },
:ARENA_TRAINER_LASS_34 => {
      :name => "Maëlys", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 60], [:PACHIRISU, 62], [:PLUSLE, 63], [:EMOLGA, 64], [:SPINDA, 66], [:TOGETIC, 67]]
    },
:ARENA_TRAINER_LASS_35 => {
      :name => "Mia", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PACHIRISU, 61], [:PIKACHU, 62], [:EMOLGA, 62], [:AZUMARILL, 68], [:PLUSLE, 69]]
    },
:ARENA_TRAINER_LASS_36 => {
      :name => "Chloé", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:EMOLGA, 70], [:AZUMARILL, 70], [:PACHIRISU, 72], [:MINUN, 73], [:SPINDA, 73], [:PLUSLE, 76]]
    },
:ARENA_TRAINER_LASS_37 => {
      :name => "Clara", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:EMOLGA, 77]]
    },
:ARENA_TRAINER_LASS_38 => {
      :name => "Salomé", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PLUSLE, 71], [:PIKACHU, 73], [:AZUMARILL, 73], [:TOGETIC, 74], [:SPINDA, 74], [:MINUN, 77]]
    },
:ARENA_TRAINER_LASS_39 => {
      :name => "Mila", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:SPINDA, 71], [:EMOLGA, 74], [:TOGETIC, 78], [:PIKACHU, 79], [:AZUMARILL, 80]]
    },
:ARENA_TRAINER_LASS_40 => {
      :name => "Emma", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 72], [:SPINDA, 78]]
    },
:ARENA_TRAINER_LASS_41 => {
      :name => "Rose", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:MINUN, 80], [:PACHIRISU, 83], [:AZUMARILL, 85]]
    },
:ARENA_TRAINER_LASS_42 => {
      :name => "Capucine", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 80], [:EMOLGA, 82], [:AZUMARILL, 86], [:SPINDA, 88], [:MINUN, 88], [:PACHIRISU, 89]]
    },
:ARENA_TRAINER_LASS_43 => {
      :name => "Léa", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:TOGETIC, 81], [:SPINDA, 83], [:AZUMARILL, 85], [:MINUN, 86]]
    },
:ARENA_TRAINER_LASS_44 => {
      :name => "Anna", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:TOGETIC, 86], [:PACHIRISU, 87], [:SPINDA, 87], [:MINUN, 89]]
    },
:ARENA_TRAINER_LASS_45 => {
      :name => "Romane", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PACHIRISU, 83], [:MINUN, 85], [:EMOLGA, 89]]
    },
:ARENA_TRAINER_LASS_46 => {
      :name => "Alice", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:AZUMARILL, 91], [:PACHIRISU, 92], [:TOGETIC, 96], [:EMOLGA, 98], [:MINUN, 99], [:PIKACHU, 100]]
    },
:ARENA_TRAINER_LASS_47 => {
      :name => "Gaïa", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PIKACHU, 91], [:PLUSLE, 92], [:AZUMARILL, 92], [:MINUN, 93], [:EMOLGA, 100]]
    },
:ARENA_TRAINER_LASS_48 => {
      :name => "Maya", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:EMOLGA, 93], [:AZUMARILL, 98]]
    },
:ARENA_TRAINER_LASS_49 => {
      :name => "Louise", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PLUSLE, 99]]
    },
:ARENA_TRAINER_LASS_50 => {
      :name => "Ella", :sprite => "trainer_LASS", :type => :LASS,
      :team => [[:PACHIRISU, 90], [:PIKACHU, 91], [:SPINDA, 96], [:TOGETIC, 97]]
    },
:ARENA_TRAINER_PAINTER_1 => {
      :name => "Paloma", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SMEARGLE, 5], [:DITTO, 4]]
    },
:ARENA_TRAINER_PAINTER_2 => {
      :name => "Dora", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SPINARAK, 3], [:ABRA, 4], [:MINCCINO, 4], [:SEEL, 9]]
    },
:ARENA_TRAINER_PAINTER_3 => {
      :name => "Rosa", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:STARYU, 4], [:UNOWN, 9]]
    },
:ARENA_TRAINER_PAINTER_4 => {
      :name => "Sarah", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SPINARAK, 3], [:SPINDA, 5], [:SEEL, 6], [:SMOOCHUM, 6], [:FEEBAS, 6], [:MINCCINO, 10]]
    },
:ARENA_TRAINER_PAINTER_5 => {
      :name => "Frida", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SHELLDER, 3], [:FEEBAS, 5], [:MIMEJR, 6], [:REMORAID, 7]]
    },
:ARENA_TRAINER_PAINTER_6 => {
      :name => "Judith", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DITTO, 16], [:SHUPPET, 19]]
    },
:ARENA_TRAINER_PAINTER_7 => {
      :name => "Berthe", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SHELLDER, 10], [:MINCCINO, 16], [:SPINDA, 16], [:LEDIAN, 19]]
    },
:ARENA_TRAINER_PAINTER_8 => {
      :name => "Lee", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DELIBIRD, 11], [:ZORUA, 13], [:REMORAID, 18], [:ROSELIA, 19]]
    },
:ARENA_TRAINER_PAINTER_9 => {
      :name => "Lavinia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SPINDA, 13], [:CHINGLING, 15], [:MISDREAVUS, 16], [:REMORAID, 18]]
    },
:ARENA_TRAINER_PAINTER_10 => {
      :name => "Vanessa", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:FEEBAS, 11], [:MIMEJR, 14], [:SPINDA, 14], [:MEOWTH, 17], [:ILLUMISE, 18]]
    },
:ARENA_TRAINER_PAINTER_11 => {
      :name => "Élaine", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:CASTFORM, 23], [:MEOWTH, 24], [:ARIADOS, 24], [:LAPRAS, 26], [:ILLUMISE, 26], [:NATU, 28]]
    },
:ARENA_TRAINER_PAINTER_12 => {
      :name => "Élisabeth", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DUSKULL, 22], [:SMEARGLE, 22], [:UNOWN, 23], [:FEEBAS, 24], [:CHIMECHO, 26], [:SMOOCHUM, 27]]
    },
:ARENA_TRAINER_PAINTER_13 => {
      :name => "Alma", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DELIBIRD, 21], [:VOLBEAT, 30]]
    },
:ARENA_TRAINER_PAINTER_14 => {
      :name => "Clara", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SHUPPET, 22], [:SMOOCHUM, 23], [:SHELLDER, 26], [:DUSKULL, 30]]
    },
:ARENA_TRAINER_PAINTER_15 => {
      :name => "Agnes", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:HYPNO, 26], [:MINCCINO, 27], [:PERSIAN, 30]]
    },
:ARENA_TRAINER_PAINTER_16 => {
      :name => "Eva", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:TOGEKISS, 32], [:ROSERADE, 32], [:NATU, 33], [:ALAKAZAM, 36]]
    },
:ARENA_TRAINER_PAINTER_17 => {
      :name => "Lygia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:STARYU, 30], [:WHIMSICOTT, 33], [:MUNNA, 33], [:HYPNO, 35], [:BUTTERFREE, 37], [:ARIADOS, 40]]
    },
:ARENA_TRAINER_PAINTER_18 => {
      :name => "Sonia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:CLOYSTER, 38], [:VOLBEAT, 39]]
    },
:ARENA_TRAINER_PAINTER_19 => {
      :name => "Mary", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:FEEBAS, 30], [:CHATOT, 35], [:UNOWN, 39]]
    },
:ARENA_TRAINER_PAINTER_20 => {
      :name => "Suzanne", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:HYPNO, 34], [:CHIMECHO, 36], [:JYNX, 38]]
    },
:ARENA_TRAINER_PAINTER_21 => {
      :name => "Marguerite", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:PERSIAN, 40], [:ARIADOS, 43], [:ILLUMISE, 45], [:SMEARGLE, 49], [:ROSERADE, 50]]
    },
:ARENA_TRAINER_PAINTER_22 => {
      :name => "Mathilde", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ARIADOS, 41], [:BANETTE, 44], [:TOGEKISS, 48], [:SMEARGLE, 50]]
    },
:ARENA_TRAINER_PAINTER_23 => {
      :name => "Marie", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:XATU, 40], [:ROSERADE, 42], [:MRMIME, 44], [:CLOYSTER, 45], [:ZOROARK, 47]]
    },
:ARENA_TRAINER_PAINTER_24 => {
      :name => "Angelica", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DEWGONG, 40], [:STARMIE, 40], [:REUNICLUS, 42], [:KECLEON, 46], [:MUSHARNA, 50], [:BANETTE, 50]]
    },
:ARENA_TRAINER_PAINTER_25 => {
      :name => "Yayoi", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:CHATOT, 45], [:CHIMECHO, 48], [:STARMIE, 50]]
    },
:ARENA_TRAINER_PAINTER_26 => {
      :name => "Jeanne", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:BUTTERFREE, 55]]
    },
:ARENA_TRAINER_PAINTER_27 => {
      :name => "Lucie", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DITTO, 52], [:ARIADOS, 55], [:PERSIAN, 56], [:GOTHITELLE, 56]]
    },
:ARENA_TRAINER_PAINTER_28 => {
      :name => "Helen", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:LILLIGANT, 51], [:EXPLOUD, 51], [:XATU, 55]]
    },
:ARENA_TRAINER_PAINTER_29 => {
      :name => "Artemisia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:STARMIE, 50], [:ALAKAZAM, 50], [:BUTTERFREE, 50], [:DELIBIRD, 51], [:MUSHARNA, 55], [:CLOYSTER, 55]]
    },
:ARENA_TRAINER_PAINTER_30 => {
      :name => "Hilma", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:VOLBEAT, 50], [:CHIMECHO, 50], [:REUNICLUS, 53], [:BANETTE, 55], [:JYNX, 59]]
    },
:ARENA_TRAINER_PAINTER_31 => {
      :name => "Käthe", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:BANETTE, 62], [:BEAUTIFLY, 64], [:EXPLOUD, 66], [:ROSERADE, 66], [:SUNFLORA, 66], [:LEDIAN, 70]]
    },
:ARENA_TRAINER_PAINTER_32 => {
      :name => "Camille", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:CASTFORM, 67], [:SMEARGLE, 67], [:ILLUMISE, 67]]
    },
:ARENA_TRAINER_PAINTER_33 => {
      :name => "Rosalba", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:BANETTE, 63], [:ZOROARK, 66], [:SMEARGLE, 67]]
    },
:ARENA_TRAINER_PAINTER_34 => {
      :name => "Louise", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ROSELIA, 64], [:UNOWN, 66], [:XATU, 69], [:LAPRAS, 70], [:CHIMECHO, 70]]
    },
:ARENA_TRAINER_PAINTER_35 => {
      :name => "Georgia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:XATU, 61], [:DITTO, 65]]
    },
:ARENA_TRAINER_PAINTER_36 => {
      :name => "Remedios", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:DITTO, 70], [:CLOYSTER, 73], [:LEDIAN, 80]]
    },
:ARENA_TRAINER_PAINTER_37 => {
      :name => "Natalia", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:BANETTE, 73], [:ARIADOS, 75], [:BUTTERFREE, 79]]
    },
:ARENA_TRAINER_PAINTER_38 => {
      :name => "Gabrielle", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ROSELIA, 80]]
    },
:ARENA_TRAINER_PAINTER_39 => {
      :name => "Joan", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:SUNFLORA, 71], [:JYNX, 73], [:VOLBEAT, 76], [:ARIADOS, 77], [:LILLIGANT, 77], [:EXPLOUD, 77]]
    },
:ARENA_TRAINER_PAINTER_40 => {
      :name => "Niki", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ZOROARK, 71], [:BEAUTIFLY, 71], [:CHATOT, 74], [:CASTFORM, 75], [:MISMAGIUS, 76], [:SPINDA, 77]]
    },
:ARENA_TRAINER_PAINTER_41 => {
      :name => "Séraphine", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:REUNICLUS, 80], [:LEDIAN, 82], [:CASTFORM, 86], [:CLOYSTER, 89]]
    },
:ARENA_TRAINER_PAINTER_42 => {
      :name => "Carmen", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ZOROARK, 81], [:KECLEON, 83], [:DITTO, 84], [:BEAUTIFLY, 85], [:ROSERADE, 87], [:GOTHITELLE, 88]]
    },
:ARENA_TRAINER_PAINTER_43 => {
      :name => "Léonie", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:STARMIE, 80], [:KECLEON, 84], [:MRMIME, 87], [:ROSERADE, 87], [:UNOWN, 89], [:BUTTERFREE, 90]]
    },
:ARENA_TRAINER_PAINTER_44 => {
      :name => "Sofonisba", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:HYPNO, 86], [:MASQUERAIN, 87], [:STARMIE, 87], [:CHIMECHO, 89]]
    },
:ARENA_TRAINER_PAINTER_45 => {
      :name => "Gwen", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:ARIADOS, 90]]
    },
:ARENA_TRAINER_PAINTER_46 => {
      :name => "Dorothea", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:VOLBEAT, 97], [:BUTTERFREE, 98], [:BANETTE, 99], [:DEWGONG, 99], [:CHIMECHO, 99]]
    },
:ARENA_TRAINER_PAINTER_47 => {
      :name => "Hannah", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:CASTFORM, 90], [:ALAKAZAM, 90], [:UNOWN, 95]]
    },
:ARENA_TRAINER_PAINTER_48 => {
      :name => "Maria", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:JYNX, 97]]
    },
:ARENA_TRAINER_PAINTER_49 => {
      :name => "Leonora", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:VOLBEAT, 91], [:ROTOM, 94], [:ARIADOS, 96]]
    },
:ARENA_TRAINER_PAINTER_50 => {
      :name => "Paula", :sprite => "trainer_PAINTER", :type => :PAINTER,
      :team => [[:MRMIME, 92], [:BUTTERFREE, 93], [:GOTHITELLE, 94], [:KECLEON, 94], [:ROTOM, 96], [:TOGEKISS, 99]]
    },
:ARENA_TRAINER_PICNICKER_1 => {
      :name => "Cidjy", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:BONSLY, 5], [:POLIWAG, 4]]
    },
:ARENA_TRAINER_PICNICKER_2 => {
      :name => "Pomme", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:CHERUBI, 10]]
    },
:ARENA_TRAINER_PICNICKER_3 => {
      :name => "Lola", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PANSAGE, 2], [:SHROOMISH, 4], [:CHERUBI, 4], [:SLOWPOKE, 6]]
    },
:ARENA_TRAINER_PICNICKER_4 => {
      :name => "Clara", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:FOONGUS, 5], [:WOOPER, 9]]
    },
:ARENA_TRAINER_PICNICKER_5 => {
      :name => "Lyna", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PICHU, 7], [:PETILIL, 8], [:EXEGGCUTE, 8]]
    },
:ARENA_TRAINER_PICNICKER_6 => {
      :name => "Apolline", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SMEARGLE, 10], [:DELIBIRD, 11], [:ODDISH, 19]]
    },
:ARENA_TRAINER_PICNICKER_7 => {
      :name => "Victoire", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PIDOVE, 10], [:STANTLER, 10], [:COTTONEE, 10], [:CHIKORITA, 14], [:PACHIRISU, 15]]
    },
:ARENA_TRAINER_PICNICKER_8 => {
      :name => "Lou", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SHROOMISH, 11], [:SMEARGLE, 11], [:SENTRET, 14], [:HERDIER, 17]]
    },
:ARENA_TRAINER_PICNICKER_9 => {
      :name => "Noisette", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:MARILL, 11], [:CHANSEY, 13], [:BUNEARY, 13], [:TOGETIC, 16], [:SUDOWOODO, 19], [:SHROOMISH, 20]]
    },
:ARENA_TRAINER_PICNICKER_10 => {
      :name => "Noémie", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PICHU, 15]]
    },
:ARENA_TRAINER_PICNICKER_11 => {
      :name => "Célestine", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:DELCATTY, 21], [:SKITTY, 25]]
    },
:ARENA_TRAINER_PICNICKER_12 => {
      :name => "Ambre", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:EEVEE, 20], [:DELCATTY, 23], [:MILTANK, 28], [:BLISSEY, 29], [:TEDDIURSA, 29], [:BUTTERFREE, 29]]
    },
:ARENA_TRAINER_PICNICKER_13 => {
      :name => "Margaux", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:CHANSEY, 25]]
    },
:ARENA_TRAINER_PICNICKER_14 => {
      :name => "Mila", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SKITTY, 20], [:GIRAFARIG, 26], [:TEDDIURSA, 26], [:PANSEAR, 27], [:SUNFLORA, 29]]
    },
:ARENA_TRAINER_PICNICKER_15 => {
      :name => "Iris", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:CHERRIM, 26]]
    },
:ARENA_TRAINER_PICNICKER_16 => {
      :name => "Inès", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:BUTTERFREE, 31], [:VESPIQUEN, 32], [:MINUN, 34], [:SIMIPOUR, 38]]
    },
:ARENA_TRAINER_PICNICKER_17 => {
      :name => "Gabrielle", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LILLIGANT, 37], [:LEAVANNY, 39]]
    },
:ARENA_TRAINER_PICNICKER_18 => {
      :name => "Eden", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:FURRET, 31], [:FOONGUS, 32], [:WHIMSICOTT, 33], [:GRANBULL, 38]]
    },
:ARENA_TRAINER_PICNICKER_19 => {
      :name => "Elsa", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:GIRAFARIG, 30], [:STANTLER, 35]]
    },
:ARENA_TRAINER_PICNICKER_20 => {
      :name => "Cerise", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:DELIBIRD, 30], [:TAUROS, 33], [:PIKACHU, 40]]
    },
:ARENA_TRAINER_PICNICKER_21 => {
      :name => "Faustine", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:CHERRIM, 41], [:BOUFFALANT, 42], [:EEVEE, 43], [:FARFETCHD, 45]]
    },
:ARENA_TRAINER_PICNICKER_22 => {
      :name => "Éva", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SUNFLORA, 41], [:MILTANK, 42], [:SMEARGLE, 46], [:PLUSLE, 46], [:LEDIAN, 46], [:AMOONGUSS, 46]]
    },
:ARENA_TRAINER_PICNICKER_23 => {
      :name => "Capucine", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LOPUNNY, 42], [:FARFETCHD, 42], [:AMOONGUSS, 43], [:SMEARGLE, 45], [:PACHIRISU, 46], [:LEAVANNY, 49]]
    },
:ARENA_TRAINER_PICNICKER_24 => {
      :name => "Mélia", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LILLIGANT, 40], [:SUDOWOODO, 43], [:BIBAREL, 45], [:TAUROS, 48], [:DODRIO, 49], [:CHERRIM, 50]]
    },
:ARENA_TRAINER_PICNICKER_25 => {
      :name => "Léa", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SUDOWOODO, 50]]
    },
:ARENA_TRAINER_PICNICKER_26 => {
      :name => "Anna", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SIMIPOUR, 50], [:FURRET, 51], [:BIBAREL, 52], [:LOPUNNY, 56], [:AZUMARILL, 60]]
    },
:ARENA_TRAINER_PICNICKER_27 => {
      :name => "Roxane", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SMEARGLE, 55]]
    },
:ARENA_TRAINER_PICNICKER_28 => {
      :name => "Maëlys", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:AZUMARILL, 52], [:TAUROS, 53], [:CHANSEY, 55], [:GIRAFARIG, 56]]
    },
:ARENA_TRAINER_PICNICKER_29 => {
      :name => "Manon", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LOPUNNY, 50], [:URSARING, 55], [:MILTANK, 60]]
    },
:ARENA_TRAINER_PICNICKER_30 => {
      :name => "Lana", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PACHIRISU, 50], [:EXEGGUTOR, 50], [:STANTLER, 51], [:MILTANK, 55]]
    },
:ARENA_TRAINER_PICNICKER_31 => {
      :name => "Juliette", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:STANTLER, 62], [:BIBAREL, 63], [:SIMISEAR, 64], [:BOUFFALANT, 65], [:MINUN, 68], [:TAUROS, 69]]
    },
:ARENA_TRAINER_PICNICKER_32 => {
      :name => "Ninon", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:DELCATTY, 60], [:AZUMARILL, 61], [:STANTLER, 63], [:VESPIQUEN, 69], [:SIMIPOUR, 70]]
    },
:ARENA_TRAINER_PICNICKER_33 => {
      :name => "Mirabelle", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:GRANBULL, 62], [:SIMISAGE, 66]]
    },
:ARENA_TRAINER_PICNICKER_34 => {
      :name => "Violette", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:EXEGGUTOR, 61], [:URSARING, 65]]
    },
:ARENA_TRAINER_PICNICKER_35 => {
      :name => "Léonie", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SIMIPOUR, 60], [:BOUFFALANT, 69]]
    },
:ARENA_TRAINER_PICNICKER_36 => {
      :name => "Clémence", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:CHANSEY, 76]]
    },
:ARENA_TRAINER_PICNICKER_37 => {
      :name => "Maëlle", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:URSARING, 77]]
    },
:ARENA_TRAINER_PICNICKER_38 => {
      :name => "Camille", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SIMISAGE, 75]]
    },
:ARENA_TRAINER_PICNICKER_39 => {
      :name => "Thaïs", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LEDIAN, 74], [:SIMISEAR, 75]]
    },
:ARENA_TRAINER_PICNICKER_40 => {
      :name => "Marguerite", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:PIKACHU, 70], [:LOPUNNY, 79]]
    },
:ARENA_TRAINER_PICNICKER_41 => {
      :name => "Romane", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:BOUFFALANT, 83], [:SIMISEAR, 88], [:SAWSBUCK, 89]]
    },
:ARENA_TRAINER_PICNICKER_42 => {
      :name => "Anaïs", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:SMEARGLE, 81], [:PLUSLE, 81], [:DODRIO, 83], [:SIMIPOUR, 85], [:AZUMARILL, 89], [:STANTLER, 89]]
    },
:ARENA_TRAINER_PICNICKER_43 => {
      :name => "Tess", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:DODRIO, 83], [:URSARING, 85]]
    },
:ARENA_TRAINER_PICNICKER_44 => {
      :name => "Olympe", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:BIBAREL, 83], [:GIRAFARIG, 85]]
    },
:ARENA_TRAINER_PICNICKER_45 => {
      :name => "Jeanne", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:FARFETCHD, 85], [:EXEGGUTOR, 86], [:STANTLER, 89]]
    },
:ARENA_TRAINER_PICNICKER_46 => {
      :name => "Sasha", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:FARFETCHD, 90], [:BLISSEY, 90], [:LEAVANNY, 94], [:TOGETIC, 99]]
    },
:ARENA_TRAINER_PICNICKER_47 => {
      :name => "Louise", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:MINUN, 91], [:AZUMARILL, 92], [:STOUTLAND, 96], [:SMEARGLE, 96], [:LOPUNNY, 99]]
    },
:ARENA_TRAINER_PICNICKER_48 => {
      :name => "Alice", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LEDIAN, 91], [:SAWSBUCK, 96], [:WHIMSICOTT, 97], [:AMOONGUSS, 97], [:BEAUTIFLY, 98]]
    },
:ARENA_TRAINER_PICNICKER_49 => {
      :name => "Églantine", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:LEDIAN, 90], [:SNORLAX, 91], [:STANTLER, 93], [:MILTANK, 96], [:BRELOOM, 97], [:TOGETIC, 98]]
    },
:ARENA_TRAINER_PICNICKER_50 => {
      :name => "Zoé", :sprite => "trainer_PICNICKER", :type => :PICNICKER,
      :team => [[:DELCATTY, 96], [:AZUMARILL, 98]]
    },
:ARENA_TRAINER_POKEMANIAC_1 => {
      :name => "Kévin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 5], [:PSYDUCK, 4]]
    },
:ARENA_TRAINER_POKEMANIAC_2 => {
      :name => "Clodomir", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 9], [:PSYDUCK, 10]]
    },
:ARENA_TRAINER_POKEMANIAC_3 => {
      :name => "Alphonse", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 8], [:PSYDUCK, 9], [:PSYDUCK, 9]]
    },
:ARENA_TRAINER_POKEMANIAC_4 => {
      :name => "Sosthène", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 7], [:PSYDUCK, 9]]
    },
:ARENA_TRAINER_POKEMANIAC_5 => {
      :name => "Hubert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 2], [:PSYDUCK, 5], [:PSYDUCK, 5], [:PSYDUCK, 8], [:PSYDUCK, 9]]
    },
:ARENA_TRAINER_POKEMANIAC_6 => {
      :name => "Fulbert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 11], [:PSYDUCK, 15], [:PSYDUCK, 17], [:PSYDUCK, 18], [:PSYDUCK, 19]]
    },
:ARENA_TRAINER_POKEMANIAC_7 => {
      :name => "Gégé", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 12], [:PSYDUCK, 14], [:PSYDUCK, 14], [:PSYDUCK, 16], [:PSYDUCK, 18]]
    },
:ARENA_TRAINER_POKEMANIAC_8 => {
      :name => "Albert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 20]]
    },
:ARENA_TRAINER_POKEMANIAC_9 => {
      :name => "Billy", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 14], [:PSYDUCK, 17], [:PSYDUCK, 19]]
    },
:ARENA_TRAINER_POKEMANIAC_10 => {
      :name => "Fridolin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 16]]
    },
:ARENA_TRAINER_POKEMANIAC_11 => {
      :name => "Zébulon", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 20], [:PSYDUCK, 20], [:PSYDUCK, 20], [:PSYDUCK, 23], [:PSYDUCK, 24], [:PSYDUCK, 25]]
    },
:ARENA_TRAINER_POKEMANIAC_12 => {
      :name => "Popol", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 22], [:PSYDUCK, 26]]
    },
:ARENA_TRAINER_POKEMANIAC_13 => {
      :name => "Bouboule", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 20], [:PSYDUCK, 25]]
    },
:ARENA_TRAINER_POKEMANIAC_14 => {
      :name => "Eustache", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 22], [:PSYDUCK, 26], [:PSYDUCK, 27], [:PSYDUCK, 29]]
    },
:ARENA_TRAINER_POKEMANIAC_15 => {
      :name => "Timothée", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 23], [:PSYDUCK, 30]]
    },
:ARENA_TRAINER_POKEMANIAC_16 => {
      :name => "Philibert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 30], [:PSYDUCK, 33], [:PSYDUCK, 37], [:PSYDUCK, 38], [:PSYDUCK, 40]]
    },
:ARENA_TRAINER_POKEMANIAC_17 => {
      :name => "Gontran", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 36], [:PSYDUCK, 36], [:PSYDUCK, 36]]
    },
:ARENA_TRAINER_POKEMANIAC_18 => {
      :name => "Ulrich", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 30], [:PSYDUCK, 35], [:PSYDUCK, 37], [:PSYDUCK, 38]]
    },
:ARENA_TRAINER_POKEMANIAC_19 => {
      :name => "Cunibert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 33], [:PSYDUCK, 34], [:PSYDUCK, 35], [:PSYDUCK, 37]]
    },
:ARENA_TRAINER_POKEMANIAC_20 => {
      :name => "Pépito", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 30], [:PSYDUCK, 31], [:PSYDUCK, 40]]
    },
:ARENA_TRAINER_POKEMANIAC_21 => {
      :name => "Quentin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 42], [:PSYDUCK, 43], [:PSYDUCK, 47], [:PSYDUCK, 47], [:PSYDUCK, 48]]
    },
:ARENA_TRAINER_POKEMANIAC_22 => {
      :name => "Loulou", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 44], [:PSYDUCK, 45], [:PSYDUCK, 48], [:PSYDUCK, 49]]
    },
:ARENA_TRAINER_POKEMANIAC_23 => {
      :name => "Bertrand", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 40], [:PSYDUCK, 41], [:PSYDUCK, 45]]
    },
:ARENA_TRAINER_POKEMANIAC_24 => {
      :name => "Bibi", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 45], [:PSYDUCK, 46], [:PSYDUCK, 46], [:PSYDUCK, 46], [:PSYDUCK, 46]]
    },
:ARENA_TRAINER_POKEMANIAC_25 => {
      :name => "Jordan", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 45], [:PSYDUCK, 46]]
    },
:ARENA_TRAINER_POKEMANIAC_26 => {
      :name => "Steeve", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 56], [:PSYDUCK, 57], [:PSYDUCK, 59]]
    },
:ARENA_TRAINER_POKEMANIAC_27 => {
      :name => "Barnabé", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 55]]
    },
:ARENA_TRAINER_POKEMANIAC_28 => {
      :name => "Kenny", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 54], [:PSYDUCK, 55], [:PSYDUCK, 57], [:PSYDUCK, 58], [:PSYDUCK, 59]]
    },
:ARENA_TRAINER_POKEMANIAC_29 => {
      :name => "Momo", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 52], [:PSYDUCK, 52], [:PSYDUCK, 54], [:PSYDUCK, 55], [:PSYDUCK, 56], [:PSYDUCK, 58]]
    },
:ARENA_TRAINER_POKEMANIAC_30 => {
      :name => "Mathurin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 51], [:PSYDUCK, 51], [:PSYDUCK, 54], [:PSYDUCK, 54], [:PSYDUCK, 57]]
    },
:ARENA_TRAINER_POKEMANIAC_31 => {
      :name => "Hyppolite", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 61], [:PSYDUCK, 69]]
    },
:ARENA_TRAINER_POKEMANIAC_32 => {
      :name => "Xavier", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 62], [:PSYDUCK, 65]]
    },
:ARENA_TRAINER_POKEMANIAC_33 => {
      :name => "Bébert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 62], [:PSYDUCK, 63], [:PSYDUCK, 63], [:PSYDUCK, 64], [:PSYDUCK, 70]]
    },
:ARENA_TRAINER_POKEMANIAC_34 => {
      :name => "Jojo", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 62], [:PSYDUCK, 63], [:PSYDUCK, 65], [:PSYDUCK, 65], [:PSYDUCK, 65], [:PSYDUCK, 66]]
    },
:ARENA_TRAINER_POKEMANIAC_35 => {
      :name => "Anatole", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 61], [:PSYDUCK, 68], [:PSYDUCK, 69]]
    },
:ARENA_TRAINER_POKEMANIAC_36 => {
      :name => "Titi", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 70], [:PSYDUCK, 70], [:PSYDUCK, 70], [:PSYDUCK, 72], [:PSYDUCK, 74], [:PSYDUCK, 80]]
    },
:ARENA_TRAINER_POKEMANIAC_37 => {
      :name => "Jean-Kévin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 75], [:PSYDUCK, 75], [:PSYDUCK, 77], [:PSYDUCK, 77]]
    },
:ARENA_TRAINER_POKEMANIAC_38 => {
      :name => "Robert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 75]]
    },
:ARENA_TRAINER_POKEMANIAC_39 => {
      :name => "Désiré", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 78]]
    },
:ARENA_TRAINER_POKEMANIAC_40 => {
      :name => "Jimmy", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 71], [:PSYDUCK, 72], [:PSYDUCK, 73], [:PSYDUCK, 77]]
    },
:ARENA_TRAINER_POKEMANIAC_41 => {
      :name => "Basile", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 80], [:PSYDUCK, 86], [:PSYDUCK, 87], [:PSYDUCK, 89]]
    },
:ARENA_TRAINER_POKEMANIAC_42 => {
      :name => "Ignace", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 80], [:PSYDUCK, 83], [:PSYDUCK, 84], [:PSYDUCK, 85], [:PSYDUCK, 88], [:PSYDUCK, 89]]
    },
:ARENA_TRAINER_POKEMANIAC_43 => {
      :name => "Wilfried", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 80], [:PSYDUCK, 82], [:PSYDUCK, 83], [:PSYDUCK, 86], [:PSYDUCK, 86], [:PSYDUCK, 86]]
    },
:ARENA_TRAINER_POKEMANIAC_44 => {
      :name => "Zéphirin", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 80], [:PSYDUCK, 81], [:PSYDUCK, 82], [:PSYDUCK, 86], [:PSYDUCK, 88]]
    },
:ARENA_TRAINER_POKEMANIAC_45 => {
      :name => "Gaston", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 85], [:PSYDUCK, 86]]
    },
:ARENA_TRAINER_POKEMANIAC_46 => {
      :name => "Bobby", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 90], [:PSYDUCK, 91], [:PSYDUCK, 91], [:PSYDUCK, 92], [:PSYDUCK, 94], [:PSYDUCK, 97]]
    },
:ARENA_TRAINER_POKEMANIAC_47 => {
      :name => "Dédé", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 90], [:PSYDUCK, 93], [:PSYDUCK, 94], [:PSYDUCK, 95], [:PSYDUCK, 98], [:PSYDUCK, 100]]
    },
:ARENA_TRAINER_POKEMANIAC_48 => {
      :name => "Dylan", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 99]]
    },
:ARENA_TRAINER_POKEMANIAC_49 => {
      :name => "Gilbert", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 90], [:PSYDUCK, 93], [:PSYDUCK, 94], [:PSYDUCK, 95], [:PSYDUCK, 97], [:PSYDUCK, 99]]
    },
:ARENA_TRAINER_POKEMANIAC_50 => {
      :name => "Nono", :sprite => "trainer_POKEMANIAC", :type => :POKEMANIAC,
      :team => [[:PSYDUCK, 90], [:PSYDUCK, 96], [:PSYDUCK, 98], [:PSYDUCK, 100]]
    },
:ARENA_TRAINER_POKEMONBREEDER_1 => {
      :name => "Amaya", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:MILTANK, 5], [:MAREEP, 4]]
    },
:ARENA_TRAINER_POKEMONBREEDER_2 => {
      :name => "Félicie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:SPINARAK, 5], [:MARILL, 6], [:PIDGEY, 7], [:SUNKERN, 7]]
    },
:ARENA_TRAINER_POKEMONBREEDER_3 => {
      :name => "Odette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:BLITZLE, 6]]
    },
:ARENA_TRAINER_POKEMONBREEDER_4 => {
      :name => "Marie-Claude", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:POOCHYENA, 8]]
    },
:ARENA_TRAINER_POKEMONBREEDER_5 => {
      :name => "Marcelle", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:TEPIG, 8], [:TEDDIURSA, 10]]
    },
:ARENA_TRAINER_POKEMONBREEDER_6 => {
      :name => "Josette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:HOPPIP, 10], [:FARFETCHD, 11], [:BELLSPROUT, 15], [:PATRAT, 16], [:STARLY, 16], [:PIDGEY, 20]]
    },
:ARENA_TRAINER_POKEMONBREEDER_7 => {
      :name => "Rose", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:CHANSEY, 10], [:FURRET, 15]]
    },
:ARENA_TRAINER_POKEMONBREEDER_8 => {
      :name => "Huguette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:COTTONEE, 17]]
    },
:ARENA_TRAINER_POKEMONBREEDER_9 => {
      :name => "Thérèse", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:HOOTHOOT, 16]]
    },
:ARENA_TRAINER_POKEMONBREEDER_10 => {
      :name => "Mauricette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:HAPPINY, 10], [:BLITZLE, 13], [:PIDOVE, 14], [:STARLY, 15], [:PIDGEOTTO, 20]]
    },
:ARENA_TRAINER_POKEMONBREEDER_11 => {
      :name => "Marie-Louise", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:PSYDUCK, 30]]
    },
:ARENA_TRAINER_POKEMONBREEDER_12 => {
      :name => "Delphine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:VESPIQUEN, 25], [:WEEPINBELL, 30]]
    },
:ARENA_TRAINER_POKEMONBREEDER_13 => {
      :name => "Noëlle", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:PINSIR, 27]]
    },
:ARENA_TRAINER_POKEMONBREEDER_14 => {
      :name => "Joséphine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:QUAGSIRE, 22], [:ZEBSTRIKA, 30]]
    },
:ARENA_TRAINER_POKEMONBREEDER_15 => {
      :name => "Odile", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:FURRET, 21], [:STARAVIA, 22], [:BOUFFALANT, 23], [:VESPIQUEN, 26], [:FEAROW, 29]]
    },
:ARENA_TRAINER_POKEMONBREEDER_16 => {
      :name => "Fernande", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:DODUO, 32], [:DODRIO, 33], [:WHIMSICOTT, 35], [:STARAVIA, 36], [:EMBOAR, 39]]
    },
:ARENA_TRAINER_POKEMONBREEDER_17 => {
      :name => "Madeleine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:DODRIO, 31], [:STARAVIA, 35], [:LEAVANNY, 36]]
    },
:ARENA_TRAINER_POKEMONBREEDER_18 => {
      :name => "Lucette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:RATICATE, 30], [:BOUFFALANT, 36], [:BRELOOM, 36], [:MIGHTYENA, 38], [:AZUMARILL, 39], [:QUAGSIRE, 40]]
    },
:ARENA_TRAINER_POKEMONBREEDER_19 => {
      :name => "Denise", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:MILTANK, 30], [:VESPIQUEN, 30], [:LEDIAN, 33], [:DEERLING, 34], [:PILOSWINE, 38], [:STARAVIA, 40]]
    },
:ARENA_TRAINER_POKEMONBREEDER_20 => {
      :name => "Zélie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:GIRAFARIG, 31], [:DODUO, 36], [:CHANSEY, 37], [:DODRIO, 37], [:STARAVIA, 38], [:SAWSBUCK, 40]]
    },
:ARENA_TRAINER_POKEMONBREEDER_21 => {
      :name => "Perrine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:DODRIO, 45]]
    },
:ARENA_TRAINER_POKEMONBREEDER_22 => {
      :name => "Yvette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:LINOONE, 41], [:PERSIAN, 41], [:ARCANINE, 47], [:JUMPLUFF, 47], [:MAMOSWINE, 47], [:SWANNA, 50]]
    },
:ARENA_TRAINER_POKEMONBREEDER_23 => {
      :name => "Marthe", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:WEEPINBELL, 40], [:BRELOOM, 43], [:LEAVANNY, 44], [:CHANSEY, 48], [:WATCHOG, 48]]
    },
:ARENA_TRAINER_POKEMONBREEDER_24 => {
      :name => "Ginette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:DODRIO, 44], [:JUMPLUFF, 45], [:FEAROW, 47], [:PERSIAN, 47], [:TAUROS, 49]]
    },
:ARENA_TRAINER_POKEMONBREEDER_25 => {
      :name => "Adèle", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:TRANQUILL, 41], [:MAMOSWINE, 45]]
    },
:ARENA_TRAINER_POKEMONBREEDER_26 => {
      :name => "Augustine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:BOUFFALANT, 56]]
    },
:ARENA_TRAINER_POKEMONBREEDER_27 => {
      :name => "Paulette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:WHIMSICOTT, 51], [:QUAGSIRE, 52], [:BLISSEY, 58], [:SWANNA, 59], [:NOCTOWL, 60]]
    },
:ARENA_TRAINER_POKEMONBREEDER_28 => {
      :name => "Germaine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:RAPIDASH, 51], [:LEAVANNY, 53], [:GIRAFARIG, 57], [:FEAROW, 58]]
    },
:ARENA_TRAINER_POKEMONBREEDER_29 => {
      :name => "Blanche", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:SAWSBUCK, 58]]
    },
:ARENA_TRAINER_POKEMONBREEDER_30 => {
      :name => "Eulalie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:LEAVANNY, 51], [:JUMPLUFF, 56]]
    },
:ARENA_TRAINER_POKEMONBREEDER_31 => {
      :name => "Hortense", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:BLISSEY, 60], [:MAMOSWINE, 60], [:FURRET, 61], [:JUMPLUFF, 61], [:SAWSBUCK, 67]]
    },
:ARENA_TRAINER_POKEMONBREEDER_32 => {
      :name => "Victorine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:STOUTLAND, 65]]
    },
:ARENA_TRAINER_POKEMONBREEDER_33 => {
      :name => "Philomène", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:NOCTOWL, 63], [:DODRIO, 63], [:URSARING, 65], [:GOLDUCK, 65], [:SNORLAX, 68]]
    },
:ARENA_TRAINER_POKEMONBREEDER_34 => {
      :name => "Raymonde", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:SWANNA, 61], [:MILTANK, 65], [:SLOWBRO, 67], [:WATCHOG, 70], [:BLISSEY, 70]]
    },
:ARENA_TRAINER_POKEMONBREEDER_35 => {
      :name => "Solange", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:SNORLAX, 62], [:QUAGSIRE, 65]]
    },
:ARENA_TRAINER_POKEMONBREEDER_36 => {
      :name => "Mélanie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:AMPHAROS, 76], [:MIGHTYENA, 79], [:TAUROS, 80]]
    },
:ARENA_TRAINER_POKEMONBREEDER_37 => {
      :name => "Berthe", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:STOUTLAND, 70], [:GIRAFARIG, 71], [:ZEBSTRIKA, 73], [:FEAROW, 73], [:ARCANINE, 80]]
    },
:ARENA_TRAINER_POKEMONBREEDER_38 => {
      :name => "Jeannine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:STOUTLAND, 73], [:SAWSBUCK, 78]]
    },
:ARENA_TRAINER_POKEMONBREEDER_39 => {
      :name => "Clémentine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:MIGHTYENA, 80]]
    },
:ARENA_TRAINER_POKEMONBREEDER_40 => {
      :name => "Eugénie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:TAUROS, 70], [:FEAROW, 72], [:STOUTLAND, 73], [:MIGHTYENA, 74], [:WATCHOG, 79]]
    },
:ARENA_TRAINER_POKEMONBREEDER_41 => {
      :name => "Hélène", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:ZEBSTRIKA, 82], [:HERACROSS, 85]]
    },
:ARENA_TRAINER_POKEMONBREEDER_42 => {
      :name => "Irène", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:FURRET, 82], [:BLISSEY, 85], [:GOLDUCK, 86]]
    },
:ARENA_TRAINER_POKEMONBREEDER_43 => {
      :name => "Fanchon", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:URSARING, 82], [:HERACROSS, 82], [:MAMOSWINE, 85]]
    },
:ARENA_TRAINER_POKEMONBREEDER_44 => {
      :name => "Georgette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:FARFETCHD, 85]]
    },
:ARENA_TRAINER_POKEMONBREEDER_45 => {
      :name => "Lucienne", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:FEAROW, 83], [:MIGHTYENA, 89]]
    },
:ARENA_TRAINER_POKEMONBREEDER_46 => {
      :name => "Simone", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:SWANNA, 90], [:HERACROSS, 91], [:FARFETCHD, 99]]
    },
:ARENA_TRAINER_POKEMONBREEDER_47 => {
      :name => "Léontine", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:BRELOOM, 94], [:BLISSEY, 99], [:EMBOAR, 99], [:LINOONE, 99], [:SWANNA, 100]]
    },
:ARENA_TRAINER_POKEMONBREEDER_48 => {
      :name => "Rosalie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:DODRIO, 95], [:PINSIR, 96], [:ZEBSTRIKA, 97]]
    },
:ARENA_TRAINER_POKEMONBREEDER_49 => {
      :name => "Anne-Marie", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:WHIMSICOTT, 90], [:PERSIAN, 95], [:FEAROW, 98], [:CHANSEY, 99], [:FARFETCHD, 100]]
    },
:ARENA_TRAINER_POKEMONBREEDER_50 => {
      :name => "Pâquerette", :sprite => "trainer_POKEMONBREEDER", :type => :POKEMONBREEDER,
      :team => [[:FARFETCHD, 90], [:WHIMSICOTT, 91], [:STOUTLAND, 92], [:SLOWBRO, 95], [:AMPHAROS, 97]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_1 => {
      :name => "Ambre", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STARLY, 5], [:RIOLU, 4]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_2 => {
      :name => "Roxane", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:RIOLU, 2], [:ZUBAT, 4], [:ONIX, 6], [:TORCHIC, 8], [:SHINX, 10]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_3 => {
      :name => "Kira", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:BLITZLE, 2], [:FARFETCHD, 5], [:MANTYKE, 6], [:EEVEE, 7]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_4 => {
      :name => "Kenza", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:RIOLU, 4], [:SENTRET, 6], [:FARFETCHD, 9], [:TIMBURR, 10]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_5 => {
      :name => "Nora", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:TORCHIC, 2], [:CHINCHOU, 4], [:TOTODILE, 6], [:MACHOP, 7], [:EMOLGA, 8], [:DEERLING, 9]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_6 => {
      :name => "Sylvia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STARLY, 16]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_7 => {
      :name => "Livia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:DEERLING, 13], [:TORCHIC, 14], [:AIPOM, 17], [:SANDSHREW, 18]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_8 => {
      :name => "Eden", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FARFETCHD, 14], [:RUFFLET, 14], [:PIKACHU, 14], [:BIBAREL, 18], [:PIDOVE, 19]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_9 => {
      :name => "Bessie", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:RUFFLET, 15], [:KADABRA, 20], [:SPEAROW, 20]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_10 => {
      :name => "Amélie", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:THROH, 12], [:ZANGOOSE, 13], [:DIGLETT, 14], [:BLITZLE, 17], [:ZUBAT, 18], [:GROWLITHE, 18]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_11 => {
      :name => "Gaïa", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:MIGHTYENA, 23], [:TRAPINCH, 24], [:TRANQUILL, 27], [:AIPOM, 28]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_12 => {
      :name => "Ella", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:KADABRA, 23], [:GYARADOS, 26], [:HEATMOR, 28], [:HERACROSS, 29]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_13 => {
      :name => "Lou", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STARAVIA, 22], [:CROCONAW, 28], [:GYARADOS, 30]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_14 => {
      :name => "Thalia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FEAROW, 20], [:SEVIPER, 21], [:THROH, 22], [:SAWK, 25]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_15 => {
      :name => "Sacagawea", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:TORKOAL, 29]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_16 => {
      :name => "Zoé", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:MANTINE, 36]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_17 => {
      :name => "Isabella", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STARAPTOR, 35]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_18 => {
      :name => "Margot", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:BIBAREL, 33], [:LAPRAS, 40]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_19 => {
      :name => "Alexia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:LUCARIO, 35]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_20 => {
      :name => "Wangari", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:GOLBAT, 35]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_21 => {
      :name => "Sasha", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FEAROW, 46], [:ZANGOOSE, 48], [:CAMERUPT, 50]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_22 => {
      :name => "Mathilde", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:HEATMOR, 43], [:GOLBAT, 46]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_23 => {
      :name => "Willow", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FEAROW, 41], [:NOCTOWL, 41], [:SAWK, 43], [:ALAKAZAM, 47], [:DRAGONAIR, 50]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_24 => {
      :name => "Quinn", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FURRET, 42], [:DURANT, 43], [:RHYDON, 45]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_25 => {
      :name => "Lara", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:LUXRAY, 45]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_26 => {
      :name => "Junko", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:CAMERUPT, 50], [:FEAROW, 53], [:HEATMOR, 58]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_27 => {
      :name => "Gertrude", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:LUCARIO, 53], [:TORKOAL, 54], [:WAILORD, 58], [:UMBREON, 60], [:BOUFFALANT, 60], [:GLISCOR, 60]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_28 => {
      :name => "Mia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:SCIZOR, 50], [:TAUROS, 55], [:ARCANINE, 56]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_29 => {
      :name => "Marlowe", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STARAPTOR, 54], [:FERALIGATR, 55], [:HEATMOR, 57], [:ALAKAZAM, 57]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_30 => {
      :name => "Alix", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:FERALIGATR, 51], [:SANDSLASH, 52], [:ARCANINE, 53], [:AMBIPOM, 53], [:RAICHU, 59], [:ESPEON, 59]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_31 => {
      :name => "Capucine", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:UNFEZANT, 60], [:LUCARIO, 61], [:NOCTOWL, 62], [:BOUFFALANT, 65]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_32 => {
      :name => "Jade", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:RHYDON, 60], [:SANDSLASH, 61], [:THROH, 62], [:STOUTLAND, 66], [:SCIZOR, 66], [:SAMUROTT, 69]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_33 => {
      :name => "Léna", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:LUXRAY, 66], [:UMBREON, 67], [:SCYTHER, 69]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_34 => {
      :name => "Skye", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:BRAVIARY, 62], [:STEELIX, 70]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_35 => {
      :name => "Tess", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:GYARADOS, 60], [:TORKOAL, 65]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_36 => {
      :name => "Freya", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:MIGHTYENA, 80], [:STARAPTOR, 80]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_37 => {
      :name => "Anouk", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:RAPIDASH, 70], [:STOUTLAND, 73], [:FLYGON, 74], [:UMBREON, 74], [:ZOROARK, 75], [:MACHAMP, 80]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_38 => {
      :name => "Elena", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:NOCTOWL, 71], [:FEAROW, 75]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_39 => {
      :name => "Amelia", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STEELIX, 75]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_40 => {
      :name => "Harriet", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:CHARIZARD, 75]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_41 => {
      :name => "Aurore", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:SCRAFTY, 80], [:CHARIZARD, 83], [:FEAROW, 89]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_42 => {
      :name => "Camille", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:SWELLOW, 88]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_43 => {
      :name => "Dian", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:STEELIX, 88]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_44 => {
      :name => "Annie", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:SAWK, 83], [:NINETALES, 85]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_45 => {
      :name => "Maëlle", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:CROBAT, 80], [:STEELIX, 85]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_46 => {
      :name => "Inès", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:MACHAMP, 92], [:MANTINE, 95], [:STOUTLAND, 96], [:RAPIDASH, 100], [:MIGHTYENA, 100]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_47 => {
      :name => "Alexandra", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:ABSOL, 93], [:DRAGONITE, 94], [:TAUROS, 95]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_48 => {
      :name => "Jane", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:KROOKODILE, 95]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_49 => {
      :name => "Maya", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:LUCARIO, 90], [:LUXRAY, 94], [:GYARADOS, 97]]
    },
:ARENA_TRAINER_POKEMONRANGER_F_50 => {
      :name => "Marianne", :sprite => "trainer_POKEMONRANGER_F", :type => :POKEMONRANGER_F,
      :team => [[:SANDSLASH, 90], [:SKARMORY, 92], [:STOUTLAND, 93], [:STEELIX, 97]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_1 => {
      :name => "Fernand", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:MACHOP, 2], [:DRATINI, 7]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_2 => {
      :name => "Axel", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:GROWLITHE, 2], [:SANDILE, 7]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_3 => {
      :name => "Paul-Émile", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:RHYHORN, 2], [:WAILMER, 9]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_4 => {
      :name => "Neil", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:RUFFLET, 4], [:SENTRET, 6]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_5 => {
      :name => "Christophe", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:PIDOVE, 6]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_6 => {
      :name => "Mike", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ZORUA, 10], [:LILLIPUP, 10], [:TIMBURR, 11], [:SHINX, 15]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_7 => {
      :name => "Gabin", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:PIDGEY, 12], [:HOOTHOOT, 14], [:MACHOP, 16]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_8 => {
      :name => "Phileas", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:RIOLU, 15]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_9 => {
      :name => "Henry", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:MANTYKE, 10], [:SANDILE, 19], [:NATU, 20], [:WAILMER, 20]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_10 => {
      :name => "Francisco", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SEVIPER, 14], [:ZUBAT, 14], [:BAGON, 15]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_11 => {
      :name => "Hudson", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ONIX, 22], [:FARFETCHD, 25]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_12 => {
      :name => "Léo", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:TRANQUILL, 22], [:SCYTHER, 26], [:COMBUSKEN, 30]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_13 => {
      :name => "Nicolas", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:KADABRA, 25]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_14 => {
      :name => "Théo", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:UMBREON, 25]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_15 => {
      :name => "Cole", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:THROH, 24], [:PINSIR, 26], [:STARAVIA, 30]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_16 => {
      :name => "Bear", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:FERALIGATR, 31], [:GLIGAR, 33], [:AIPOM, 34], [:STARAPTOR, 34], [:BIBAREL, 35], [:GYARADOS, 37]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_17 => {
      :name => "Robert", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:MANTINE, 36], [:HEATMOR, 40]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_18 => {
      :name => "Allan", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:DRAGONAIR, 30], [:CAMERUPT, 33], [:MACHOKE, 35], [:ABSOL, 40]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_19 => {
      :name => "Edmund", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SANDSLASH, 33], [:ARCANINE, 34], [:TORKOAL, 36], [:MANTINE, 38]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_20 => {
      :name => "Tenzing", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SHELGON, 34], [:TRANQUILL, 39]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_21 => {
      :name => "Richard", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:BLAZIKEN, 44], [:WAILORD, 45]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_22 => {
      :name => "Ferdinand", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SAWSBUCK, 43], [:THROH, 48], [:GIRAFARIG, 49], [:SHELGON, 50]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_23 => {
      :name => "Charles", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:BLAZIKEN, 40], [:MANTINE, 42], [:LANTURN, 42], [:MACHOKE, 45], [:MACHAMP, 49], [:PINSIR, 50]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_24 => {
      :name => "Noé", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:PIDGEOT, 40], [:TRANQUILL, 42], [:LANTURN, 46]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_25 => {
      :name => "Alexander", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SCRAFTY, 40], [:SWELLOW, 45], [:STOUTLAND, 47]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_26 => {
      :name => "Soren", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SCRAFTY, 53], [:ZEBSTRIKA, 54], [:MIGHTYENA, 58]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_27 => {
      :name => "Sven", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:DUGTRIO, 58], [:SALAMENCE, 60]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_28 => {
      :name => "David", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SANDSLASH, 54], [:KROOKODILE, 54], [:EEVEE, 56], [:DURANT, 57], [:CAMERUPT, 59]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_29 => {
      :name => "Jack", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:THROH, 52], [:RHYDON, 53], [:RUFFLET, 53], [:CHARIZARD, 53], [:FURRET, 55]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_30 => {
      :name => "Yuri", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:EMOLGA, 55], [:FEAROW, 59]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_31 => {
      :name => "Aaron", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SCRAFTY, 61], [:SAWK, 62], [:SCYTHER, 64], [:NOCTOWL, 67], [:UMBREON, 68]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_32 => {
      :name => "William", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ZOROARK, 70]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_33 => {
      :name => "Hugo", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:CROBAT, 65], [:FARFETCHD, 68]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_34 => {
      :name => "Reinhold", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ARCANINE, 60], [:HERACROSS, 60], [:PINSIR, 61], [:BLAZIKEN, 63], [:EXCADRILL, 66], [:SEVIPER, 70]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_35 => {
      :name => "Ethan", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:LANTURN, 64], [:GYARADOS, 64], [:MIGHTYENA, 69]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_36 => {
      :name => "Buzz", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:HERACROSS, 71], [:PINSIR, 72], [:STARAPTOR, 73], [:TORKOAL, 75], [:PIKACHU, 78], [:NOCTOWL, 80]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_37 => {
      :name => "Kylian", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:FARFETCHD, 70], [:STOUTLAND, 71], [:BLAZIKEN, 71], [:BIBAREL, 71], [:DUGTRIO, 78], [:XATU, 78]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_38 => {
      :name => "Américo", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:TAUROS, 72], [:FERALIGATR, 74], [:GIRAFARIG, 75], [:NINETALES, 75]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_39 => {
      :name => "Indiana", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ESPEON, 71], [:STARAPTOR, 78], [:FLYGON, 80]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_40 => {
      :name => "Samuel", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:STARAPTOR, 76], [:ALAKAZAM, 77]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_41 => {
      :name => "Elias", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:DRAGONITE, 83], [:HEATMOR, 90]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_42 => {
      :name => "Jonas", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:FLYGON, 80], [:ESPEON, 83], [:LANTURN, 83], [:SCRAFTY, 86]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_43 => {
      :name => "Thor", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ARCANINE, 80], [:CROBAT, 80], [:FERALIGATR, 83], [:STOUTLAND, 88], [:GYARADOS, 88], [:EXCADRILL, 90]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_44 => {
      :name => "Jean-Louis", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:NOCTOWL, 81], [:MANTINE, 81], [:UMBREON, 86], [:SCRAFTY, 89]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_45 => {
      :name => "Meriwether", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:HEATMOR, 80], [:CAMERUPT, 81], [:ALAKAZAM, 82], [:NINETALES, 83], [:BRAVIARY, 85]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_46 => {
      :name => "Ernest", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:ZANGOOSE, 91], [:NINETALES, 91], [:SCYTHER, 94], [:EMOLGA, 95]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_47 => {
      :name => "Vasco", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:SANDSLASH, 95]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_48 => {
      :name => "Marco", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:MANTINE, 95], [:GYARADOS, 96], [:ESPEON, 98], [:BLAZIKEN, 99], [:RAPIDASH, 99], [:SKARMORY, 100]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_49 => {
      :name => "Lewis", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:FERALIGATR, 96], [:RAICHU, 96]]
    },
:ARENA_TRAINER_POKEMONRANGER_M_50 => {
      :name => "Rick", :sprite => "trainer_POKEMONRANGER_M", :type => :POKEMONRANGER_M,
      :team => [[:LAPRAS, 97]]
    },
:ARENA_TRAINER_PSYCHIC_F_1 => {
      :name => "Vénus", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:RALTS, 5]]
    },
:ARENA_TRAINER_PSYCHIC_F_2 => {
      :name => "Hathor", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ELGYEM, 5], [:EXEGGCUTE, 7]]
    },
:ARENA_TRAINER_PSYCHIC_F_3 => {
      :name => "Nyx", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:NATU, 3], [:MIMEJR, 9], [:WOOBAT, 10]]
    },
:ARENA_TRAINER_PSYCHIC_F_4 => {
      :name => "Séléné", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ELGYEM, 3], [:NATU, 4], [:RALTS, 9]]
    },
:ARENA_TRAINER_PSYCHIC_F_5 => {
      :name => "Calypso", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BRONZOR, 7]]
    },
:ARENA_TRAINER_PSYCHIC_F_6 => {
      :name => "Mérope", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:EXEGGCUTE, 13], [:WOOBAT, 14], [:CHINGLING, 15]]
    },
:ARENA_TRAINER_PSYCHIC_F_7 => {
      :name => "Nout", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:MUNNA, 11], [:EXEGGCUTE, 15], [:ABRA, 16], [:BALTOY, 17], [:RALTS, 17]]
    },
:ARENA_TRAINER_PSYCHIC_F_8 => {
      :name => "Maïa", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:WYNAUT, 12], [:CHINGLING, 17]]
    },
:ARENA_TRAINER_PSYCHIC_F_9 => {
      :name => "Circé", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:KADABRA, 20]]
    },
:ARENA_TRAINER_PSYCHIC_F_10 => {
      :name => "Aurore", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BALTOY, 13], [:RALTS, 19]]
    },
:ARENA_TRAINER_PSYCHIC_F_11 => {
      :name => "Phoebé", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:METANG, 25], [:STARMIE, 29]]
    },
:ARENA_TRAINER_PSYCHIC_F_12 => {
      :name => "Isis", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:GOTHITA, 22], [:UNOWN, 23], [:EXEGGCUTE, 28], [:SIGILYPH, 30], [:GALLADE, 30]]
    },
:ARENA_TRAINER_PSYCHIC_F_13 => {
      :name => "Cassandre", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:GIRAFARIG, 23], [:MRMIME, 26], [:SPOINK, 27], [:MUNNA, 29]]
    },
:ARENA_TRAINER_PSYCHIC_F_14 => {
      :name => "Delphine", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BRONZOR, 22], [:SIGILYPH, 25]]
    },
:ARENA_TRAINER_PSYCHIC_F_15 => {
      :name => "Uranie", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ELGYEM, 22], [:SLOWPOKE, 23], [:EXEGGCUTE, 24], [:STARMIE, 29]]
    },
:ARENA_TRAINER_PSYCHIC_F_16 => {
      :name => "Mnémosyne", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SOLROCK, 31], [:EXEGGCUTE, 35], [:GALLADE, 38], [:SIGILYPH, 38], [:GIRAFARIG, 39], [:SLOWBRO, 39]]
    },
:ARENA_TRAINER_PSYCHIC_F_17 => {
      :name => "Aria", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SLOWPOKE, 37], [:MRMIME, 38], [:SLOWBRO, 40]]
    },
:ARENA_TRAINER_PSYCHIC_F_18 => {
      :name => "Séraphine", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ELGYEM, 32], [:ESPEON, 33], [:GARDEVOIR, 33], [:STARMIE, 34], [:WOBBUFFET, 35]]
    },
:ARENA_TRAINER_PSYCHIC_F_19 => {
      :name => "Théa", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SOLROCK, 30], [:MUNNA, 33], [:EXEGGUTOR, 34], [:DUOSION, 35], [:WOBBUFFET, 38]]
    },
:ARENA_TRAINER_PSYCHIC_F_20 => {
      :name => "Sibylle", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:NATU, 30], [:STARYU, 35]]
    },
:ARENA_TRAINER_PSYCHIC_F_21 => {
      :name => "Morgane", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ELGYEM, 41], [:GARDEVOIR, 44], [:ESPEON, 45], [:SLOWKING, 50]]
    },
:ARENA_TRAINER_PSYCHIC_F_22 => {
      :name => "Alcyone", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:MUSHARNA, 45], [:MRMIME, 46], [:CLAYDOL, 49]]
    },
:ARENA_TRAINER_PSYCHIC_F_23 => {
      :name => "Orianne", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ESPEON, 42], [:METANG, 44], [:SIGILYPH, 44], [:SOLROCK, 45], [:XATU, 46], [:METAGROSS, 49]]
    },
:ARENA_TRAINER_PSYCHIC_F_24 => {
      :name => "Pléiade", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:GIRAFARIG, 48]]
    },
:ARENA_TRAINER_PSYCHIC_F_25 => {
      :name => "Zoltana", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:MUSHARNA, 41], [:STARMIE, 44], [:JYNX, 47]]
    },
:ARENA_TRAINER_PSYCHIC_F_26 => {
      :name => "Ariane", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:CHIMECHO, 55], [:JYNX, 58], [:WOBBUFFET, 60], [:SOLROCK, 60]]
    },
:ARENA_TRAINER_PSYCHIC_F_27 => {
      :name => "Cassiopée", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SIGILYPH, 59]]
    },
:ARENA_TRAINER_PSYCHIC_F_28 => {
      :name => "Pythie", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:XATU, 60]]
    },
:ARENA_TRAINER_PSYCHIC_F_29 => {
      :name => "Luna", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BRONZONG, 60]]
    },
:ARENA_TRAINER_PSYCHIC_F_30 => {
      :name => "Oriane", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:CHIMECHO, 58], [:GRUMPIG, 59]]
    },
:ARENA_TRAINER_PSYCHIC_F_31 => {
      :name => "Taygète", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BEHEEYEM, 61], [:REUNICLUS, 64], [:GARDEVOIR, 66]]
    },
:ARENA_TRAINER_PSYCHIC_F_32 => {
      :name => "Céléno", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BRONZONG, 60], [:GIRAFARIG, 64], [:SOLROCK, 70]]
    },
:ARENA_TRAINER_PSYCHIC_F_33 => {
      :name => "Gaïa", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SIGILYPH, 63], [:GOTHITELLE, 66], [:STARMIE, 69], [:METAGROSS, 70]]
    },
:ARENA_TRAINER_PSYCHIC_F_34 => {
      :name => "Eurydice", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SLOWKING, 62], [:ESPEON, 62], [:UNOWN, 65], [:SOLROCK, 69], [:SLOWBRO, 70], [:ALAKAZAM, 70]]
    },
:ARENA_TRAINER_PSYCHIC_F_35 => {
      :name => "Métis", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ALAKAZAM, 60], [:SWOOBAT, 63], [:BEHEEYEM, 68], [:MUSHARNA, 68]]
    },
:ARENA_TRAINER_PSYCHIC_F_36 => {
      :name => "Thémis", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:STARMIE, 70], [:XATU, 70], [:GIRAFARIG, 71], [:SOLROCK, 72], [:SLOWKING, 76], [:WOBBUFFET, 79]]
    },
:ARENA_TRAINER_PSYCHIC_F_37 => {
      :name => "Astrée", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:STARMIE, 73], [:MRMIME, 74], [:SOLROCK, 77], [:SWOOBAT, 78], [:ALAKAZAM, 78]]
    },
:ARENA_TRAINER_PSYCHIC_F_38 => {
      :name => "Cléo", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:WOBBUFFET, 74], [:ALAKAZAM, 76], [:BEHEEYEM, 80]]
    },
:ARENA_TRAINER_PSYCHIC_F_39 => {
      :name => "Stella", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:MUSHARNA, 71], [:MRMIME, 72], [:SLOWBRO, 79], [:XATU, 80]]
    },
:ARENA_TRAINER_PSYCHIC_F_40 => {
      :name => "Astrid", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:CLAYDOL, 70], [:CHIMECHO, 72], [:LUNATONE, 73], [:SWOOBAT, 75], [:UNOWN, 80]]
    },
:ARENA_TRAINER_PSYCHIC_F_41 => {
      :name => "Athéna", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SLOWKING, 84], [:JYNX, 85], [:ESPEON, 86]]
    },
:ARENA_TRAINER_PSYCHIC_F_42 => {
      :name => "Andromède", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:SOLROCK, 80], [:XATU, 82], [:WOBBUFFET, 84], [:ESPEON, 86]]
    },
:ARENA_TRAINER_PSYCHIC_F_43 => {
      :name => "Iris", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:GARDEVOIR, 80], [:UNOWN, 82], [:SOLROCK, 83], [:BEHEEYEM, 86], [:GRUMPIG, 90]]
    },
:ARENA_TRAINER_PSYCHIC_F_44 => {
      :name => "Astérope", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:CHIMECHO, 80], [:XATU, 86]]
    },
:ARENA_TRAINER_PSYCHIC_F_45 => {
      :name => "Lyra", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ALAKAZAM, 82], [:CHIMECHO, 88]]
    },
:ARENA_TRAINER_PSYCHIC_F_46 => {
      :name => "Rhéa", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:BEHEEYEM, 95]]
    },
:ARENA_TRAINER_PSYCHIC_F_47 => {
      :name => "Esméralda", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:CLAYDOL, 100]]
    },
:ARENA_TRAINER_PSYCHIC_F_48 => {
      :name => "Hécate", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:ESPEON, 92], [:GIRAFARIG, 94], [:GOTHITELLE, 95], [:EXEGGUTOR, 98], [:SLOWKING, 99]]
    },
:ARENA_TRAINER_PSYCHIC_F_49 => {
      :name => "Diane", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:MUSHARNA, 91], [:STARMIE, 92], [:JYNX, 93], [:CHIMECHO, 96]]
    },
:ARENA_TRAINER_PSYCHIC_F_50 => {
      :name => "Artémis", :sprite => "trainer_PSYCHIC_F", :type => :PSYCHIC_F,
      :team => [[:GALLADE, 92], [:HYPNO, 95], [:EXEGGUTOR, 98], [:WOBBUFFET, 100]]
    },
:ARENA_TRAINER_PSYCHIC_M_1 => {
      :name => "Cosmo", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:EXEGGCUTE, 10], [:UNOWN, 10]]
    },
:ARENA_TRAINER_PSYCHIC_M_2 => {
      :name => "Mesmer", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:MIMEJR, 2], [:ELGYEM, 7], [:DROWZEE, 9], [:MEDITITE, 10], [:CHINGLING, 10]]
    },
:ARENA_TRAINER_PSYCHIC_M_3 => {
      :name => "Élisée", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:ELGYEM, 3], [:SPOINK, 10]]
    },
:ARENA_TRAINER_PSYCHIC_M_4 => {
      :name => "Hypnos", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:WOOBAT, 2], [:SOLOSIS, 2], [:BALTOY, 4], [:WYNAUT, 5], [:ABRA, 7]]
    },
:ARENA_TRAINER_PSYCHIC_M_5 => {
      :name => "Lucien", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:MUNNA, 9]]
    },
:ARENA_TRAINER_PSYCHIC_M_6 => {
      :name => "Mathias", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:UNOWN, 11], [:DROWZEE, 14], [:SIGILYPH, 15]]
    },
:ARENA_TRAINER_PSYCHIC_M_7 => {
      :name => "Odin", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:MUNNA, 12], [:RALTS, 16], [:UNOWN, 16], [:EXEGGCUTE, 20]]
    },
:ARENA_TRAINER_PSYCHIC_M_8 => {
      :name => "Astor", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:BALTOY, 12], [:EXEGGCUTE, 14], [:UNOWN, 14], [:BRONZOR, 17]]
    },
:ARENA_TRAINER_PSYCHIC_M_9 => {
      :name => "Jupiter", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SMOOCHUM, 14], [:DROWZEE, 17], [:WOBBUFFET, 17], [:STARYU, 19], [:SPOINK, 20], [:SOLOSIS, 20]]
    },
:ARENA_TRAINER_PSYCHIC_M_10 => {
      :name => "Aurélien", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:BRONZOR, 11], [:EXEGGCUTE, 17], [:SPOINK, 19], [:BELDUM, 20]]
    },
:ARENA_TRAINER_PSYCHIC_M_11 => {
      :name => "Melchior", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SOLROCK, 20], [:MRMIME, 22], [:MUSHARNA, 25]]
    },
:ARENA_TRAINER_PSYCHIC_M_12 => {
      :name => "Isaïe", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GOTHITA, 21], [:MEDITITE, 21], [:NATU, 22], [:KADABRA, 27], [:ELGYEM, 27]]
    },
:ARENA_TRAINER_PSYCHIC_M_13 => {
      :name => "Tirésias", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:BALTOY, 23], [:SPOINK, 28], [:HYPNO, 28], [:UNOWN, 29], [:MEDITITE, 30]]
    },
:ARENA_TRAINER_PSYCHIC_M_14 => {
      :name => "Calchas", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:BRONZOR, 20], [:MUNNA, 30]]
    },
:ARENA_TRAINER_PSYCHIC_M_15 => {
      :name => "Merlin", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:NATU, 20], [:BRONZOR, 26]]
    },
:ARENA_TRAINER_PSYCHIC_M_16 => {
      :name => "Rasputin", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:HYPNO, 34], [:CHIMECHO, 35], [:MRMIME, 35], [:STARMIE, 37], [:METANG, 38], [:CLAYDOL, 40]]
    },
:ARENA_TRAINER_PSYCHIC_M_17 => {
      :name => "Franz", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:METANG, 35]]
    },
:ARENA_TRAINER_PSYCHIC_M_18 => {
      :name => "Sylvestre", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:HYPNO, 37], [:METANG, 37], [:DUOSION, 38]]
    },
:ARENA_TRAINER_PSYCHIC_M_19 => {
      :name => "Orphée", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SWOOBAT, 34], [:GARDEVOIR, 37]]
    },
:ARENA_TRAINER_PSYCHIC_M_20 => {
      :name => "Octave", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GALLADE, 30], [:LUNATONE, 30], [:MRMIME, 31], [:WOOBAT, 36], [:MUNNA, 38]]
    },
:ARENA_TRAINER_PSYCHIC_M_21 => {
      :name => "Saturne", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:EXEGGUTOR, 41], [:SLOWKING, 44], [:SLOWBRO, 44], [:HYPNO, 45]]
    },
:ARENA_TRAINER_PSYCHIC_M_22 => {
      :name => "Eliphas", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:UNOWN, 44], [:GOTHITELLE, 45], [:SIGILYPH, 45], [:SOLROCK, 49]]
    },
:ARENA_TRAINER_PSYCHIC_M_23 => {
      :name => "Aleister", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:METAGROSS, 49], [:SWOOBAT, 50]]
    },
:ARENA_TRAINER_PSYCHIC_M_24 => {
      :name => "Darius", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SLOWBRO, 41], [:MRMIME, 46], [:UNOWN, 48], [:SIGILYPH, 48], [:EXEGGUTOR, 49], [:WOBBUFFET, 49]]
    },
:ARENA_TRAINER_PSYCHIC_M_25 => {
      :name => "Léandre", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GARDEVOIR, 48], [:CHIMECHO, 48]]
    },
:ARENA_TRAINER_PSYCHIC_M_26 => {
      :name => "Zoltar", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:LUNATONE, 56], [:SIGILYPH, 59]]
    },
:ARENA_TRAINER_PSYCHIC_M_27 => {
      :name => "Alphonse", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:MRMIME, 55]]
    },
:ARENA_TRAINER_PSYCHIC_M_28 => {
      :name => "Hermès", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:HYPNO, 55]]
    },
:ARENA_TRAINER_PSYCHIC_M_29 => {
      :name => "Morphée", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SOLROCK, 55]]
    },
:ARENA_TRAINER_PSYCHIC_M_30 => {
      :name => "Morgan", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:LUNATONE, 56]]
    },
:ARENA_TRAINER_PSYCHIC_M_31 => {
      :name => "Daniel", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SOLROCK, 60], [:GARDEVOIR, 60], [:MUSHARNA, 61], [:BRONZONG, 64], [:LUNATONE, 64], [:ALAKAZAM, 69]]
    },
:ARENA_TRAINER_PSYCHIC_M_32 => {
      :name => "Pythagore", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:REUNICLUS, 67], [:GARDEVOIR, 68], [:JYNX, 70]]
    },
:ARENA_TRAINER_PSYCHIC_M_33 => {
      :name => "Balthazar", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:LUNATONE, 64], [:SOLROCK, 64], [:ESPEON, 64], [:CLAYDOL, 65], [:UNOWN, 65], [:SIGILYPH, 66]]
    },
:ARENA_TRAINER_PSYCHIC_M_34 => {
      :name => "Paracelse", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:JYNX, 65]]
    },
:ARENA_TRAINER_PSYCHIC_M_35 => {
      :name => "Uri", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:METAGROSS, 60], [:SWOOBAT, 61], [:SLOWBRO, 62], [:REUNICLUS, 67], [:SOLROCK, 69]]
    },
:ARENA_TRAINER_PSYCHIC_M_36 => {
      :name => "Nikola", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SIGILYPH, 71], [:SLOWBRO, 72], [:WOBBUFFET, 74], [:ALAKAZAM, 79], [:LUNATONE, 80], [:MUSHARNA, 80]]
    },
:ARENA_TRAINER_PSYCHIC_M_37 => {
      :name => "Apollon", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GIRAFARIG, 75]]
    },
:ARENA_TRAINER_PSYCHIC_M_38 => {
      :name => "Zoltan", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GARDEVOIR, 70], [:EXEGGUTOR, 72], [:UNOWN, 72], [:CLAYDOL, 73], [:SOLROCK, 73], [:SWOOBAT, 75]]
    },
:ARENA_TRAINER_PSYCHIC_M_39 => {
      :name => "Cagliostro", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SIGILYPH, 71], [:HYPNO, 72], [:WOBBUFFET, 73], [:BEHEEYEM, 74], [:MUSHARNA, 78]]
    },
:ARENA_TRAINER_PSYCHIC_M_40 => {
      :name => "Osiris", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:CHIMECHO, 70], [:BRONZONG, 80]]
    },
:ARENA_TRAINER_PSYCHIC_M_41 => {
      :name => "Gérard", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:XATU, 83], [:REUNICLUS, 87], [:GIRAFARIG, 89]]
    },
:ARENA_TRAINER_PSYCHIC_M_42 => {
      :name => "Socrate", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:CLAYDOL, 83], [:GALLADE, 86]]
    },
:ARENA_TRAINER_PSYCHIC_M_43 => {
      :name => "Carl", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:LUNATONE, 88], [:BEHEEYEM, 89], [:ESPEON, 89], [:CLAYDOL, 89], [:EXEGGUTOR, 89]]
    },
:ARENA_TRAINER_PSYCHIC_M_44 => {
      :name => "Orion", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GALLADE, 86]]
    },
:ARENA_TRAINER_PSYCHIC_M_45 => {
      :name => "Alaric", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:GOTHITELLE, 82], [:BRONZONG, 83], [:MRMIME, 84], [:METAGROSS, 86], [:LUNATONE, 89], [:GALLADE, 89]]
    },
:ARENA_TRAINER_PSYCHIC_M_46 => {
      :name => "Horus", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:REUNICLUS, 91], [:GIRAFARIG, 91], [:GOTHITELLE, 91], [:SLOWBRO, 97], [:XATU, 98], [:ALAKAZAM, 100]]
    },
:ARENA_TRAINER_PSYCHIC_M_47 => {
      :name => "Gaspard", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:JYNX, 90], [:GIRAFARIG, 91], [:HYPNO, 91], [:UNOWN, 93], [:BEHEEYEM, 98], [:LUNATONE, 100]]
    },
:ARENA_TRAINER_PSYCHIC_M_48 => {
      :name => "Nostradamus", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:SOLROCK, 91], [:GALLADE, 94], [:REUNICLUS, 97]]
    },
:ARENA_TRAINER_PSYCHIC_M_49 => {
      :name => "Mélampous", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:MUSHARNA, 94], [:GARDEVOIR, 98], [:XATU, 98]]
    },
:ARENA_TRAINER_PSYCHIC_M_50 => {
      :name => "Sirius", :sprite => "trainer_PSYCHIC_M", :type => :PSYCHIC_M,
      :team => [[:WOBBUFFET, 96], [:CHIMECHO, 98], [:JYNX, 100]]
    },
:ARENA_TRAINER_ROCKER_1 => {
      :name => "Cédric", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MINUN, 5], [:JOLTIK, 5], [:ELEKID, 6], [:MACHOP, 8], [:ELECTRIKE, 8], [:CHINCHOU, 9]]
    },
:ARENA_TRAINER_ROCKER_2 => {
      :name => "Marcel", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:VOLTORB, 2], [:JOLTIK, 6]]
    },
:ARENA_TRAINER_ROCKER_3 => {
      :name => "Alessandro", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEMITE, 2], [:TYNAMO, 3], [:BRONZOR, 6], [:EMOLGA, 6], [:MAREEP, 7]]
    },
:ARENA_TRAINER_ROCKER_4 => {
      :name => "Werner", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:SHINX, 3], [:ELEKID, 7], [:PICHU, 10]]
    },
:ARENA_TRAINER_ROCKER_5 => {
      :name => "Gérard", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:KLINK, 6]]
    },
:ARENA_TRAINER_ROCKER_6 => {
      :name => "Florian", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:FLAAFFY, 15], [:JOLTIK, 17], [:PLUSLE, 17], [:KLINK, 19]]
    },
:ARENA_TRAINER_ROCKER_7 => {
      :name => "Gustav", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PACHIRISU, 11], [:MINUN, 14], [:KLINK, 17], [:EMOLGA, 18], [:ELECTRIKE, 19]]
    },
:ARENA_TRAINER_ROCKER_8 => {
      :name => "Benjamin", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ELECTRIKE, 17]]
    },
:ARENA_TRAINER_ROCKER_9 => {
      :name => "Kévin", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEMITE, 10], [:MAREEP, 11], [:BLITZLE, 13], [:ELEKID, 14], [:VOLBEAT, 20]]
    },
:ARENA_TRAINER_ROCKER_10 => {
      :name => "James", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAREEP, 10], [:ELECTRIKE, 12], [:BLITZLE, 12], [:EMOLGA, 12], [:PACHIRISU, 14], [:DRILBUR, 16]]
    },
:ARENA_TRAINER_ROCKER_11 => {
      :name => "Raymond", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PLUSLE, 24], [:MINUN, 29]]
    },
:ARENA_TRAINER_ROCKER_12 => {
      :name => "Pieter", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MACHOP, 25]]
    },
:ARENA_TRAINER_ROCKER_13 => {
      :name => "Frédéric", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STUNFISK, 20], [:PIKACHU, 22], [:JOLTIK, 22], [:ILLUMISE, 22], [:MAGNEMITE, 24], [:JOLTEON, 27]]
    },
:ARENA_TRAINER_ROCKER_14 => {
      :name => "Michel", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:TYNAMO, 20], [:BLITZLE, 21], [:MINUN, 24], [:MANECTRIC, 25], [:JOLTIK, 27], [:ONIX, 28]]
    },
:ARENA_TRAINER_ROCKER_15 => {
      :name => "Jérôme", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEMITE, 22], [:RAICHU, 22], [:MANECTRIC, 26], [:PIKACHU, 27], [:TYNAMO, 29]]
    },
:ARENA_TRAINER_ROCKER_16 => {
      :name => "Dylan", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PACHIRISU, 30], [:LANTURN, 33], [:MANECTRIC, 36], [:KLANG, 38]]
    },
:ARENA_TRAINER_ROCKER_17 => {
      :name => "Mickaël", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STUNFISK, 32], [:JOLTEON, 33], [:MANECTRIC, 33], [:BRONZONG, 34], [:ELECTRODE, 35]]
    },
:ARENA_TRAINER_ROCKER_18 => {
      :name => "Lucien", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:RAICHU, 31], [:DURANT, 35]]
    },
:ARENA_TRAINER_ROCKER_19 => {
      :name => "Zénobe", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ROTOM, 34], [:AMPHAROS, 35], [:JOLTEON, 35], [:PIKACHU, 36], [:PLUSLE, 37], [:LUXRAY, 39]]
    },
:ARENA_TRAINER_ROCKER_20 => {
      :name => "Heinrich", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEMITE, 30], [:EMOLGA, 35]]
    },
:ARENA_TRAINER_ROCKER_21 => {
      :name => "Charles-Augustin", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ELECTRODE, 42], [:GALVANTULA, 44], [:EXCADRILL, 46], [:PIKACHU, 48]]
    },
:ARENA_TRAINER_ROCKER_22 => {
      :name => "Joseph", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:EELEKTRIK, 47], [:MAGNETON, 47], [:MAGNEZONE, 48]]
    },
:ARENA_TRAINER_ROCKER_23 => {
      :name => "Anthony", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MINUN, 43], [:EELEKTRIK, 45], [:VOLBEAT, 45], [:JOLTEON, 45], [:DURANT, 47], [:BRONZONG, 47]]
    },
:ARENA_TRAINER_ROCKER_24 => {
      :name => "George", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MINUN, 47], [:STUNFISK, 48]]
    },
:ARENA_TRAINER_ROCKER_25 => {
      :name => "Hippolyte", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:LUXRAY, 45]]
    },
:ARENA_TRAINER_ROCKER_26 => {
      :name => "Wilhelm", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STEELIX, 51], [:LANTURN, 55], [:EMOLGA, 56]]
    },
:ARENA_TRAINER_ROCKER_27 => {
      :name => "Ludovic", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PLUSLE, 55]]
    },
:ARENA_TRAINER_ROCKER_28 => {
      :name => "Jean-Claude", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MINUN, 58]]
    },
:ARENA_TRAINER_ROCKER_29 => {
      :name => "Jean-Marc", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEZONE, 53], [:PLUSLE, 55], [:ELECTRODE, 57], [:CONKELDURR, 60]]
    },
:ARENA_TRAINER_ROCKER_30 => {
      :name => "Charles", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:EELEKTROSS, 53], [:ZEBSTRIKA, 53], [:ILLUMISE, 55], [:ELECTRODE, 55], [:ELECTIVIRE, 57], [:MAGNETON, 59]]
    },
:ARENA_TRAINER_ROCKER_31 => {
      :name => "Guy", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:FERROTHORN, 68], [:GALVANTULA, 68]]
    },
:ARENA_TRAINER_ROCKER_32 => {
      :name => "Roger", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ELECTIVIRE, 63], [:MANECTRIC, 63], [:KLINKLANG, 66], [:PLUSLE, 70]]
    },
:ARENA_TRAINER_ROCKER_33 => {
      :name => "Bernard", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STUNFISK, 62], [:AMPHAROS, 63], [:EELEKTROSS, 65], [:MANECTRIC, 69], [:KLINKLANG, 70]]
    },
:ARENA_TRAINER_ROCKER_34 => {
      :name => "Carl", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:EELEKTROSS, 61], [:RAICHU, 62], [:KLINKLANG, 62], [:EMOLGA, 62], [:AMPHAROS, 67], [:LANTURN, 70]]
    },
:ARENA_TRAINER_ROCKER_35 => {
      :name => "Jean-Pierre", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STUNFISK, 66], [:CHANDELURE, 67], [:PACHIRISU, 67], [:ELECTABUZZ, 69], [:AMPHAROS, 69]]
    },
:ARENA_TRAINER_ROCKER_36 => {
      :name => "Serge", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PLUSLE, 70], [:ILLUMISE, 76], [:ELECTIVIRE, 77]]
    },
:ARENA_TRAINER_ROCKER_37 => {
      :name => "Thomas", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ZEBSTRIKA, 70], [:KLINKLANG, 74], [:JOLTEON, 80]]
    },
:ARENA_TRAINER_ROCKER_38 => {
      :name => "Guglielmo", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ELECTRODE, 78]]
    },
:ARENA_TRAINER_ROCKER_39 => {
      :name => "Gilbert", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:STUNFISK, 73], [:STEELIX, 77], [:JOLTEON, 80]]
    },
:ARENA_TRAINER_ROCKER_40 => {
      :name => "Samuel", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MINUN, 70], [:EMOLGA, 70], [:SKARMORY, 74], [:ELECTABUZZ, 77], [:GALVANTULA, 80]]
    },
:ARENA_TRAINER_ROCKER_41 => {
      :name => "Olivier", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:EMOLGA, 89], [:PIKACHU, 90], [:MINUN, 90]]
    },
:ARENA_TRAINER_ROCKER_42 => {
      :name => "Luigi", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:LUXRAY, 81], [:TORKOAL, 85]]
    },
:ARENA_TRAINER_ROCKER_43 => {
      :name => "Steeve", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:MAGNEZONE, 81], [:ILLUMISE, 82], [:RAICHU, 86]]
    },
:ARENA_TRAINER_ROCKER_44 => {
      :name => "Michael", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:CONKELDURR, 89]]
    },
:ARENA_TRAINER_ROCKER_45 => {
      :name => "René", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:LUXRAY, 87]]
    },
:ARENA_TRAINER_ROCKER_46 => {
      :name => "Édouard", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:EELEKTROSS, 95]]
    },
:ARENA_TRAINER_ROCKER_47 => {
      :name => "Rodolphe", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:PIKACHU, 90], [:JOLTEON, 97], [:RAICHU, 100]]
    },
:ARENA_TRAINER_ROCKER_48 => {
      :name => "André-Marie", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ROTOM, 91], [:AMPHAROS, 96], [:ELECTIVIRE, 97], [:STUNFISK, 99], [:EMOLGA, 100]]
    },
:ARENA_TRAINER_ROCKER_49 => {
      :name => "Yves", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ZEBSTRIKA, 91], [:ROTOM, 93], [:LANTURN, 98]]
    },
:ARENA_TRAINER_ROCKER_50 => {
      :name => "Pascal", :sprite => "trainer_ROCKER", :type => :ROCKER,
      :team => [[:ELECTRODE, 90], [:MAGNETON, 93], [:EELEKTROSS, 97], [:BRONZONG, 99], [:EMOLGA, 100]]
    },
:ARENA_TRAINER_RUINMANIAC_1 => {
      :name => "Stéphane", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:UNOWN, 5], [:DRILBUR, 4]]
    },
:ARENA_TRAINER_RUINMANIAC_2 => {
      :name => "Bernard", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:GEODUDE, 3], [:TIRTOUGA, 5], [:CRANIDOS, 7], [:BRONZOR, 10], [:UNOWN, 10]]
    },
:ARENA_TRAINER_RUINMANIAC_3 => {
      :name => "Lionel", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:YAMASK, 5], [:BALTOY, 8]]
    },
:ARENA_TRAINER_RUINMANIAC_4 => {
      :name => "Jean-Antoine", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:SABLEYE, 6]]
    },
:ARENA_TRAINER_RUINMANIAC_5 => {
      :name => "Gaston", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:DIGLETT, 3], [:HIPPOPOTAS, 6], [:SANDSHREW, 9], [:GASTLY, 10]]
    },
:ARENA_TRAINER_RUINMANIAC_6 => {
      :name => "Bastien", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:CACNEA, 10], [:GOLETT, 12], [:ROGGENROLA, 13], [:TORKOAL, 15], [:BALTOY, 18]]
    },
:ARENA_TRAINER_RUINMANIAC_7 => {
      :name => "Marco", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:UNOWN, 10], [:ONIX, 19], [:GEODUDE, 20]]
    },
:ARENA_TRAINER_RUINMANIAC_8 => {
      :name => "Kilian", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:LITWICK, 13], [:YAMASK, 19], [:SANDSHREW, 20]]
    },
:ARENA_TRAINER_RUINMANIAC_9 => {
      :name => "Sylvain", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:ONIX, 15], [:DIGLETT, 19]]
    },
:ARENA_TRAINER_RUINMANIAC_10 => {
      :name => "Lorenzo", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:YAMASK, 10], [:KABUTO, 10], [:SABLEYE, 13], [:SIGILYPH, 18]]
    },
:ARENA_TRAINER_RUINMANIAC_11 => {
      :name => "Loïc", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:TRAPINCH, 22], [:LARVITAR, 30]]
    },
:ARENA_TRAINER_RUINMANIAC_12 => {
      :name => "Jacques", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:LUNATONE, 22], [:GOLETT, 24], [:SANDSLASH, 24], [:NOSEPASS, 25]]
    },
:ARENA_TRAINER_RUINMANIAC_13 => {
      :name => "Jérôme", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:HAUNTER, 25]]
    },
:ARENA_TRAINER_RUINMANIAC_14 => {
      :name => "Fabien", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:RELICANTH, 21], [:ELGYEM, 25]]
    },
:ARENA_TRAINER_RUINMANIAC_15 => {
      :name => "Théo", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:DARUMAKA, 22], [:CACNEA, 23], [:ABSOL, 24], [:GOLBAT, 26], [:YAMASK, 26], [:SANDSLASH, 29]]
    },
:ARENA_TRAINER_RUINMANIAC_16 => {
      :name => "Riccardo", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:MISDREAVUS, 38], [:GRAVELER, 39]]
    },
:ARENA_TRAINER_RUINMANIAC_17 => {
      :name => "Marc", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:TIRTOUGA, 32], [:PUPITAR, 32], [:ARCHEN, 35]]
    },
:ARENA_TRAINER_RUINMANIAC_18 => {
      :name => "Sandro", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:NOSEPASS, 31], [:UNOWN, 33], [:HIPPOPOTAS, 34], [:DUGTRIO, 38]]
    },
:ARENA_TRAINER_RUINMANIAC_19 => {
      :name => "Walter", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:YAMASK, 31], [:MISDREAVUS, 36]]
    },
:ARENA_TRAINER_RUINMANIAC_20 => {
      :name => "Anatoli", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:LITWICK, 36]]
    },
:ARENA_TRAINER_RUINMANIAC_21 => {
      :name => "Hans", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:ARMALDO, 46]]
    },
:ARENA_TRAINER_RUINMANIAC_22 => {
      :name => "Dawa", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:ABSOL, 46], [:PROBOPASS, 46]]
    },
:ARENA_TRAINER_RUINMANIAC_23 => {
      :name => "Alex", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:CLAYDOL, 43], [:MISDREAVUS, 44], [:SPIRITOMB, 46], [:DARMANITAN, 50]]
    },
:ARENA_TRAINER_RUINMANIAC_24 => {
      :name => "Jérémie", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:ABSOL, 43], [:SOLROCK, 45], [:AERODACTYL, 46], [:BANETTE, 50]]
    },
:ARENA_TRAINER_RUINMANIAC_25 => {
      :name => "Andrew", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:CRADILY, 41], [:LAMPENT, 42], [:ARMALDO, 43], [:PUPITAR, 46], [:FLYGON, 49]]
    },
:ARENA_TRAINER_RUINMANIAC_26 => {
      :name => "Nawang", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:LAMPENT, 55]]
    },
:ARENA_TRAINER_RUINMANIAC_27 => {
      :name => "Hugo", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:GOLURK, 50], [:KROOKODILE, 53], [:CACTURNE, 55], [:STEELIX, 58]]
    },
:ARENA_TRAINER_RUINMANIAC_28 => {
      :name => "Olivier", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:KROOKODILE, 52], [:RELICANTH, 52], [:SANDSLASH, 56], [:GOLBAT, 56], [:BANETTE, 60]]
    },
:ARENA_TRAINER_RUINMANIAC_29 => {
      :name => "Ludovic", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:CACTURNE, 55], [:DARMANITAN, 57], [:GIGALITH, 60]]
    },
:ARENA_TRAINER_RUINMANIAC_30 => {
      :name => "Mathieu", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:TORKOAL, 54], [:ARCHEOPS, 56], [:GOLURK, 58], [:DUSCLOPS, 59], [:SKARMORY, 59]]
    },
:ARENA_TRAINER_RUINMANIAC_31 => {
      :name => "Clément", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:BEHEEYEM, 66], [:BANETTE, 68], [:CLAYDOL, 68], [:RELICANTH, 69]]
    },
:ARENA_TRAINER_RUINMANIAC_32 => {
      :name => "Toni", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:MAROWAK, 66], [:GIGALITH, 66], [:HIPPOWDON, 67]]
    },
:ARENA_TRAINER_RUINMANIAC_33 => {
      :name => "Chris", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:GENGAR, 60], [:GIGALITH, 63], [:ARCHEOPS, 67], [:TYRANITAR, 70]]
    },
:ARENA_TRAINER_RUINMANIAC_34 => {
      :name => "Edmund", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:MAROWAK, 66]]
    },
:ARENA_TRAINER_RUINMANIAC_35 => {
      :name => "Michel", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:BANETTE, 65]]
    },
:ARENA_TRAINER_RUINMANIAC_36 => {
      :name => "Tenzing", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:KROOKODILE, 73], [:GENGAR, 78], [:GOLEM, 78]]
    },
:ARENA_TRAINER_RUINMANIAC_37 => {
      :name => "Patrick", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:FLYGON, 73], [:SPIRITOMB, 74], [:TORKOAL, 76], [:UNOWN, 76], [:CACTURNE, 77], [:DUSKNOIR, 78]]
    },
:ARENA_TRAINER_RUINMANIAC_38 => {
      :name => "Sepp", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:TYRANITAR, 71], [:SOLROCK, 75], [:BANETTE, 80], [:CHANDELURE, 80], [:CARRACOSTA, 80]]
    },
:ARENA_TRAINER_RUINMANIAC_39 => {
      :name => "Roland", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:AERODACTYL, 72], [:GOLEM, 80]]
    },
:ARENA_TRAINER_RUINMANIAC_40 => {
      :name => "Rémi", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:RAMPARDOS, 70], [:XATU, 72], [:FLYGON, 73], [:KABUTOPS, 77], [:GIGALITH, 79], [:BASTIODON, 80]]
    },
:ARENA_TRAINER_RUINMANIAC_41 => {
      :name => "Benoît", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:GOLEM, 80], [:GIGALITH, 81], [:XATU, 81], [:MAWILE, 88], [:MAROWAK, 88]]
    },
:ARENA_TRAINER_RUINMANIAC_42 => {
      :name => "Pasang", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:STEELIX, 80], [:MISMAGIUS, 80], [:MAWILE, 85], [:XATU, 87], [:DUSCLOPS, 88]]
    },
:ARENA_TRAINER_RUINMANIAC_43 => {
      :name => "Sébastien", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:TYRANITAR, 85]]
    },
:ARENA_TRAINER_RUINMANIAC_44 => {
      :name => "Gérard", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:SIGILYPH, 80], [:GIGALITH, 81], [:UNOWN, 84], [:MAWILE, 88]]
    },
:ARENA_TRAINER_RUINMANIAC_45 => {
      :name => "Ueli", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:ARCHEOPS, 82], [:BASTIODON, 84], [:HIPPOWDON, 87], [:MAROWAK, 89], [:KROOKODILE, 89]]
    },
:ARENA_TRAINER_RUINMANIAC_46 => {
      :name => "Franz", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:OMASTAR, 95], [:TYRANITAR, 95], [:ARCHEOPS, 95], [:DUGTRIO, 97], [:SPIRITOMB, 99]]
    },
:ARENA_TRAINER_RUINMANIAC_47 => {
      :name => "Gaspard", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:CHANDELURE, 94], [:SABLEYE, 95], [:RAMPARDOS, 96], [:DUSCLOPS, 97], [:DUGTRIO, 99]]
    },
:ARENA_TRAINER_RUINMANIAC_48 => {
      :name => "Anselme", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:DARMANITAN, 92], [:OMASTAR, 94], [:FLYGON, 96], [:GOLURK, 98], [:KABUTOPS, 98], [:TORKOAL, 100]]
    },
:ARENA_TRAINER_RUINMANIAC_49 => {
      :name => "Frédéric", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:RAMPARDOS, 90], [:STEELIX, 93], [:DUSKNOIR, 97], [:SANDSLASH, 98]]
    },
:ARENA_TRAINER_RUINMANIAC_50 => {
      :name => "Clément", :sprite => "trainer_RUINMANIAC", :type => :RUINMANIAC,
      :team => [[:GOLEM, 91], [:SOLROCK, 94], [:BRONZONG, 97], [:MAWILE, 97], [:MISMAGIUS, 98]]
    },
:ARENA_TRAINER_SAILOR_1 => {
      :name => "Hadock", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WINGULL, 5], [:SHELLDER, 4]]
    },
:ARENA_TRAINER_SAILOR_2 => {
      :name => "Jonas", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SHELLDER, 2], [:DUCKLETT, 4], [:CHINCHOU, 6], [:GOLDEEN, 8], [:FEEBAS, 10]]
    },
:ARENA_TRAINER_SAILOR_3 => {
      :name => "Titouan", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CORPHISH, 2], [:CLAMPERL, 4], [:BUIZEL, 5], [:TYNAMO, 6], [:MANTYKE, 7], [:TOTODILE, 9]]
    },
:ARENA_TRAINER_SAILOR_4 => {
      :name => "Joshua", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CORPHISH, 2], [:SHELLOS, 2], [:OSHAWOTT, 9], [:SPHEAL, 10]]
    },
:ARENA_TRAINER_SAILOR_5 => {
      :name => "Fernand", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WINGULL, 3], [:FRILLISH, 6], [:GOLDEEN, 8], [:BASCULIN, 8], [:CHINCHOU, 9], [:BARBOACH, 10]]
    },
:ARENA_TRAINER_SAILOR_6 => {
      :name => "Yann", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SLOWPOKE, 14], [:PSYDUCK, 14], [:RELICANTH, 16], [:WAILMER, 18], [:CLAMPERL, 19], [:MANTYKE, 19]]
    },
:ARENA_TRAINER_SAILOR_7 => {
      :name => "Nemo", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WAILMER, 15], [:CROCONAW, 20], [:TENTACOOL, 20]]
    },
:ARENA_TRAINER_SAILOR_8 => {
      :name => "Christophe", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:MUDKIP, 12], [:SQUIRTLE, 13], [:REMORAID, 14], [:TIRTOUGA, 17], [:CORPHISH, 18], [:BUIZEL, 18]]
    },
:ARENA_TRAINER_SAILOR_9 => {
      :name => "Bill", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SQUIRTLE, 13], [:LUVDISC, 14], [:TENTACOOL, 17], [:PSYDUCK, 18], [:BUIZEL, 19]]
    },
:ARENA_TRAINER_SAILOR_10 => {
      :name => "Sinbad", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SLOWPOKE, 11], [:SEEL, 13], [:TOTODILE, 15], [:RELICANTH, 16], [:MANTYKE, 19]]
    },
:ARENA_TRAINER_SAILOR_11 => {
      :name => "Fañch", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:RELICANTH, 27]]
    },
:ARENA_TRAINER_SAILOR_12 => {
      :name => "Goulven", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CORPHISH, 21], [:SHELLDER, 26]]
    },
:ARENA_TRAINER_SAILOR_13 => {
      :name => "Ferdinand", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:DUCKLETT, 20], [:TENTACOOL, 22], [:CLAMPERL, 24], [:PSYDUCK, 27], [:KRABBY, 28], [:LUVDISC, 30]]
    },
:ARENA_TRAINER_SAILOR_14 => {
      :name => "Erwan", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WINGULL, 20], [:OCTILLERY, 25]]
    },
:ARENA_TRAINER_SAILOR_15 => {
      :name => "Briac", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SHELLDER, 20], [:SEEL, 21], [:DEWOTT, 21], [:CROCONAW, 21], [:TIRTOUGA, 23], [:WARTORTLE, 26]]
    },
:ARENA_TRAINER_SAILOR_16 => {
      :name => "Marin", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GOREBYSS, 35]]
    },
:ARENA_TRAINER_SAILOR_17 => {
      :name => "Pierrick", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GASTRODON, 33], [:GOLDEEN, 33], [:DUCKLETT, 34], [:MILOTIC, 36], [:OCTILLERY, 39], [:FRILLISH, 40]]
    },
:ARENA_TRAINER_SAILOR_18 => {
      :name => "Corentin", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CLOYSTER, 35]]
    },
:ARENA_TRAINER_SAILOR_19 => {
      :name => "Ulysse", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GYARADOS, 35], [:POLIWRATH, 37], [:SEAKING, 38], [:QWILFISH, 40]]
    },
:ARENA_TRAINER_SAILOR_20 => {
      :name => "Flint", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:HUNTAIL, 37], [:QWILFISH, 39]]
    },
:ARENA_TRAINER_SAILOR_21 => {
      :name => "Jacques-Yves", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:BASCULIN, 45]]
    },
:ARENA_TRAINER_SAILOR_22 => {
      :name => "Jason", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:DEWGONG, 44], [:PELIPPER, 48]]
    },
:ARENA_TRAINER_SAILOR_23 => {
      :name => "Bernard", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GOREBYSS, 40], [:SHARPEDO, 45], [:SEAKING, 48], [:BASCULIN, 48], [:PELIPPER, 50], [:LANTURN, 50]]
    },
:ARENA_TRAINER_SAILOR_24 => {
      :name => "Tanguy", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GOLDUCK, 41], [:FERALIGATR, 43], [:KINGLER, 46], [:LUVDISC, 47], [:MACHAMP, 49]]
    },
:ARENA_TRAINER_SAILOR_25 => {
      :name => "Horatio", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:JELLICENT, 45]]
    },
:ARENA_TRAINER_SAILOR_26 => {
      :name => "Brieuc", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SKARMORY, 55], [:PELIPPER, 57], [:JELLICENT, 57]]
    },
:ARENA_TRAINER_SAILOR_27 => {
      :name => "Amerigo", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GOREBYSS, 51], [:MILOTIC, 52], [:OCTILLERY, 53], [:JELLICENT, 55], [:GOLDUCK, 60]]
    },
:ARENA_TRAINER_SAILOR_28 => {
      :name => "Surcouf", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SLOWBRO, 55]]
    },
:ARENA_TRAINER_SAILOR_29 => {
      :name => "Jack", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CRAWDAUNT, 50], [:POLITOED, 56], [:SEADRA, 56]]
    },
:ARENA_TRAINER_SAILOR_30 => {
      :name => "Yvon", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:PELIPPER, 59]]
    },
:ARENA_TRAINER_SAILOR_31 => {
      :name => "Popeye", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SAMUROTT, 67], [:MILOTIC, 70], [:FERALIGATR, 70]]
    },
:ARENA_TRAINER_SAILOR_32 => {
      :name => "Olivier", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WAILORD, 65]]
    },
:ARENA_TRAINER_SAILOR_33 => {
      :name => "Sven", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:JELLICENT, 64], [:SWAMPERT, 69]]
    },
:ARENA_TRAINER_SAILOR_34 => {
      :name => "Ismaël", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:JELLICENT, 64], [:SKARMORY, 66]]
    },
:ARENA_TRAINER_SAILOR_35 => {
      :name => "Ahab", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SKARMORY, 66], [:SLOWBRO, 70]]
    },
:ARENA_TRAINER_SAILOR_36 => {
      :name => "Barnabé", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WAILORD, 72], [:GOREBYSS, 80]]
    },
:ARENA_TRAINER_SAILOR_37 => {
      :name => "Gwenaël", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SHARPEDO, 78]]
    },
:ARENA_TRAINER_SAILOR_38 => {
      :name => "Alphonse", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:GYARADOS, 70], [:SEAKING, 75]]
    },
:ARENA_TRAINER_SAILOR_39 => {
      :name => "Loïc", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CARRACOSTA, 80], [:SWAMPERT, 80]]
    },
:ARENA_TRAINER_SAILOR_40 => {
      :name => "Jean-Baptiste", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:POLIWRATH, 70], [:SEADRA, 70], [:SAMUROTT, 73], [:SEAKING, 74], [:GOREBYSS, 75], [:JELLICENT, 80]]
    },
:ARENA_TRAINER_SAILOR_41 => {
      :name => "Bartholomew", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:CLOYSTER, 81], [:KINGLER, 82], [:LAPRAS, 82], [:DEWGONG, 83], [:STARMIE, 85], [:GYARADOS, 85]]
    },
:ARENA_TRAINER_SAILOR_42 => {
      :name => "Abel", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:RELICANTH, 80], [:JELLICENT, 82], [:WAILORD, 83], [:CLOYSTER, 84], [:SEADRA, 90]]
    },
:ARENA_TRAINER_SAILOR_43 => {
      :name => "Francis", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:QWILFISH, 80], [:POLIWRATH, 80], [:FLOATZEL, 82], [:MANTINE, 83], [:POLITOED, 88]]
    },
:ARENA_TRAINER_SAILOR_44 => {
      :name => "Hector", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:WALREIN, 85]]
    },
:ARENA_TRAINER_SAILOR_45 => {
      :name => "Ronan", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SAMUROTT, 89], [:SEISMITOAD, 90]]
    },
:ARENA_TRAINER_SAILOR_46 => {
      :name => "Léon", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:SWAMPERT, 91], [:SEADRA, 92], [:EMPOLEON, 95]]
    },
:ARENA_TRAINER_SAILOR_47 => {
      :name => "Armel", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:LAPRAS, 93], [:WHISCASH, 94], [:WAILORD, 95]]
    },
:ARENA_TRAINER_SAILOR_48 => {
      :name => "René", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:OCTILLERY, 95]]
    },
:ARENA_TRAINER_SAILOR_49 => {
      :name => "Mathurin", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:MANTINE, 90], [:GYARADOS, 90], [:ALOMOMOLA, 94], [:KINGLER, 94], [:LUMINEON, 97]]
    },
:ARENA_TRAINER_SAILOR_50 => {
      :name => "Gaston", :sprite => "trainer_SAILOR", :type => :SAILOR,
      :team => [[:KINGLER, 93], [:EMPOLEON, 95]]
    },
:ARENA_TRAINER_SCIENTIST_1 => {
      :name => "Evann", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PORYGON, 5], [:KOFFING, 4]]
    },
:ARENA_TRAINER_SCIENTIST_2 => {
      :name => "Erwin", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:MAGNEMITE, 6]]
    },
:ARENA_TRAINER_SCIENTIST_3 => {
      :name => "Heinrich", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:OMANYTE, 2], [:DITTO, 9]]
    },
:ARENA_TRAINER_SCIENTIST_4 => {
      :name => "Jean", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:STARYU, 3], [:GRIMER, 5], [:SOLOSIS, 7], [:UNOWN, 7], [:BELDUM, 10]]
    },
:ARENA_TRAINER_SCIENTIST_5 => {
      :name => "Alexander", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:GRIMER, 2], [:KLINK, 4], [:SHIELDON, 6], [:GOLETT, 10]]
    },
:ARENA_TRAINER_SCIENTIST_6 => {
      :name => "Étienne", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:EXEGGCUTE, 15]]
    },
:ARENA_TRAINER_SCIENTIST_7 => {
      :name => "Auguste", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:WYNAUT, 12], [:ARCHEN, 16]]
    },
:ARENA_TRAINER_SCIENTIST_8 => {
      :name => "Charles", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:MAGNEMITE, 18], [:VOLTORB, 20]]
    },
:ARENA_TRAINER_SCIENTIST_9 => {
      :name => "Georg", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:KOFFING, 15]]
    },
:ARENA_TRAINER_SCIENTIST_10 => {
      :name => "Louis", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:KLINK, 12], [:TRUBBISH, 13], [:SHIELDON, 14], [:TIRTOUGA, 15], [:CASTFORM, 18], [:PIKACHU, 18]]
    },
:ARENA_TRAINER_SCIENTIST_11 => {
      :name => "Euclide", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PIKACHU, 23], [:SHIELDON, 24], [:DITTO, 26], [:ELEKID, 28], [:MUSHARNA, 29], [:METANG, 29]]
    },
:ARENA_TRAINER_SCIENTIST_12 => {
      :name => "Gregor", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:VAPOREON, 20], [:KOFFING, 20], [:SPINDA, 23], [:METANG, 25], [:KABUTO, 30]]
    },
:ARENA_TRAINER_SCIENTIST_13 => {
      :name => "Nicolas", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SHIELDON, 25]]
    },
:ARENA_TRAINER_SCIENTIST_14 => {
      :name => "Alessandro", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:BALTOY, 20], [:UNOWN, 25]]
    },
:ARENA_TRAINER_SCIENTIST_15 => {
      :name => "Michael", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:LILEEP, 20], [:KABUTO, 24], [:SOLOSIS, 25], [:AERODACTYL, 26], [:ESPEON, 26], [:ANORITH, 27]]
    },
:ARENA_TRAINER_SCIENTIST_16 => {
      :name => "Nikola", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SWALOT, 37]]
    },
:ARENA_TRAINER_SCIENTIST_17 => {
      :name => "Richard", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:OMANYTE, 33], [:MRMIME, 36]]
    },
:ARENA_TRAINER_SCIENTIST_18 => {
      :name => "Ludwig", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PORYGON, 32], [:KADABRA, 33], [:AERODACTYL, 33], [:ELECTABUZZ, 35]]
    },
:ARENA_TRAINER_SCIENTIST_19 => {
      :name => "André-Marie", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:LILEEP, 34], [:OMANYTE, 34], [:BRONZONG, 37], [:FLAREON, 40]]
    },
:ARENA_TRAINER_SCIENTIST_20 => {
      :name => "Gustav", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:METANG, 30], [:KLINK, 32], [:JOLTEON, 33], [:ARCHEN, 34], [:ELECTABUZZ, 37]]
    },
:ARENA_TRAINER_SCIENTIST_21 => {
      :name => "Christiaan", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:CASTFORM, 48]]
    },
:ARENA_TRAINER_SCIENTIST_22 => {
      :name => "Edwin", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:CASTFORM, 41], [:ELECTIVIRE, 42], [:ESPEON, 42], [:MRMIME, 45], [:ELECTRODE, 50]]
    },
:ARENA_TRAINER_SCIENTIST_23 => {
      :name => "Anders", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PORYGON2, 40], [:MAGNEZONE, 40], [:GOLETT, 41], [:SWALOT, 43], [:REUNICLUS, 45], [:JOLTEON, 50]]
    },
:ARENA_TRAINER_SCIENTIST_24 => {
      :name => "Julius", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:GOLETT, 43], [:CARRACOSTA, 45]]
    },
:ARENA_TRAINER_SCIENTIST_25 => {
      :name => "Hans", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:LEAFEON, 45], [:WOBBUFFET, 49], [:KLINKLANG, 49]]
    },
:ARENA_TRAINER_SCIENTIST_26 => {
      :name => "Jean-Baptiste", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:DITTO, 51], [:CLAYDOL, 56], [:JOLTEON, 58], [:KABUTOPS, 58], [:PORYGON, 60]]
    },
:ARENA_TRAINER_SCIENTIST_27 => {
      :name => "Claude", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:EEVEE, 54], [:ROTOM, 54], [:FLAREON, 55], [:ALAKAZAM, 56]]
    },
:ARENA_TRAINER_SCIENTIST_28 => {
      :name => "Rudolf", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:STARMIE, 50], [:ELECTABUZZ, 50], [:SHUCKLE, 60]]
    },
:ARENA_TRAINER_SCIENTIST_29 => {
      :name => "Konrad", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SIGILYPH, 58]]
    },
:ARENA_TRAINER_SCIENTIST_30 => {
      :name => "Enrico", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PORYGON2, 51], [:MRMIME, 57], [:WEEZING, 58], [:MAGNETON, 60]]
    },
:ARENA_TRAINER_SCIENTIST_31 => {
      :name => "Blaise", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SWALOT, 69]]
    },
:ARENA_TRAINER_SCIENTIST_32 => {
      :name => "Paul", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:WEEZING, 63], [:CRADILY, 66], [:JOLTEON, 68], [:ESPEON, 68], [:UMBREON, 70]]
    },
:ARENA_TRAINER_SCIENTIST_33 => {
      :name => "Georges", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:EXEGGUTOR, 66], [:CLAYDOL, 68], [:CASTFORM, 69], [:LEAFEON, 70]]
    },
:ARENA_TRAINER_SCIENTIST_34 => {
      :name => "Niels", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SIGILYPH, 61], [:CASTFORM, 69], [:JOLTEON, 69]]
    },
:ARENA_TRAINER_SCIENTIST_35 => {
      :name => "Johannes", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PORYGONZ, 66]]
    },
:ARENA_TRAINER_SCIENTIST_36 => {
      :name => "Otto", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:UMBREON, 78]]
    },
:ARENA_TRAINER_SCIENTIST_37 => {
      :name => "Francis", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:BASTIODON, 70], [:CLAYDOL, 71], [:ELECTRODE, 75]]
    },
:ARENA_TRAINER_SCIENTIST_38 => {
      :name => "Marcellin", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:JOLTEON, 70], [:ARMALDO, 76]]
    },
:ARENA_TRAINER_SCIENTIST_39 => {
      :name => "Évariste", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:MRMIME, 72], [:ARMALDO, 73], [:DITTO, 75], [:PORYGON2, 75], [:EXEGGUTOR, 77], [:BASTIODON, 79]]
    },
:ARENA_TRAINER_SCIENTIST_40 => {
      :name => "Thalès", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:FLAREON, 72], [:TANGROWTH, 72], [:GLACEON, 76], [:EXEGGUTOR, 78], [:MRMIME, 80]]
    },
:ARENA_TRAINER_SCIENTIST_41 => {
      :name => "Archimède", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:CARRACOSTA, 85]]
    },
:ARENA_TRAINER_SCIENTIST_42 => {
      :name => "Dmitri", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:STARMIE, 80], [:ROTOM, 82], [:MRMIME, 83], [:CRADILY, 87], [:UNOWN, 88], [:BRONZONG, 90]]
    },
:ARENA_TRAINER_SCIENTIST_43 => {
      :name => "Tycho", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:AERODACTYL, 85], [:PORYGON2, 85], [:ARMALDO, 86], [:DITTO, 89]]
    },
:ARENA_TRAINER_SCIENTIST_44 => {
      :name => "Joseph", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:PIKACHU, 80], [:RAMPARDOS, 85], [:SPINDA, 86], [:ELECTRODE, 89], [:METAGROSS, 90]]
    },
:ARENA_TRAINER_SCIENTIST_45 => {
      :name => "Pieter", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:ELECTRODE, 85]]
    },
:ARENA_TRAINER_SCIENTIST_46 => {
      :name => "Sadi", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:KABUTOPS, 91], [:PORYGON2, 96], [:ELECTABUZZ, 97], [:UMBREON, 98], [:ELECTRODE, 99], [:KLINKLANG, 100]]
    },
:ARENA_TRAINER_SCIENTIST_47 => {
      :name => "Jonas", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:FLAREON, 95], [:KABUTOPS, 99]]
    },
:ARENA_TRAINER_SCIENTIST_48 => {
      :name => "Linus", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:EXEGGUTOR, 91], [:WEEZING, 96], [:JOLTEON, 98], [:MAGNEZONE, 99]]
    },
:ARENA_TRAINER_SCIENTIST_49 => {
      :name => "Stephen", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:CRADILY, 95]]
    },
:ARENA_TRAINER_SCIENTIST_50 => {
      :name => "Max", :sprite => "trainer_SCIENTIST", :type => :SCIENTIST,
      :team => [[:SWALOT, 95], [:DITTO, 95], [:GARBODOR, 97], [:BRONZONG, 98]]
    },
:ARENA_TRAINER_SUPERNERD_1 => {
      :name => "Nathan", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:PATRAT, 5], [:GRIMER, 4]]
    },
:ARENA_TRAINER_SUPERNERD_2 => {
      :name => "Cyril", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:PATRAT, 2], [:SPINDA, 5], [:MAGNEMITE, 6], [:ABRA, 7], [:MIMEJR, 9]]
    },
:ARENA_TRAINER_SUPERNERD_3 => {
      :name => "Florian", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SWABLU, 6]]
    },
:ARENA_TRAINER_SUPERNERD_4 => {
      :name => "Bastien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:DROWZEE, 2], [:MUNCHLAX, 3], [:TYNAMO, 4], [:BIDOOF, 7], [:SWABLU, 7], [:GOLETT, 9]]
    },
:ARENA_TRAINER_SUPERNERD_5 => {
      :name => "Wassim", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MAGNEMITE, 2], [:SLOWPOKE, 4], [:SLAKOTH, 7], [:BALTOY, 8], [:PSYDUCK, 8]]
    },
:ARENA_TRAINER_SUPERNERD_6 => {
      :name => "Aurélien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:WYNAUT, 11], [:KLINK, 11], [:SLOWPOKE, 12], [:EEVEE, 14], [:SMEARGLE, 15]]
    },
:ARENA_TRAINER_SUPERNERD_7 => {
      :name => "Romain", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:BELDUM, 10], [:CASTFORM, 17]]
    },
:ARENA_TRAINER_SUPERNERD_8 => {
      :name => "Mehdi", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:KECLEON, 12], [:EEVEE, 12], [:GRIMER, 13], [:WYNAUT, 13], [:ELGYEM, 17], [:SLAKOTH, 18]]
    },
:ARENA_TRAINER_SUPERNERD_9 => {
      :name => "Léo", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MUNCHLAX, 10], [:SMEARGLE, 11], [:ABRA, 11], [:BALTOY, 15]]
    },
:ARENA_TRAINER_SUPERNERD_10 => {
      :name => "Alexis", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SLOWPOKE, 12], [:MIMEJR, 14], [:BRONZOR, 18], [:MUNNA, 19], [:BIBAREL, 20]]
    },
:ARENA_TRAINER_SUPERNERD_11 => {
      :name => "Anthony", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MIMEJR, 20], [:PORYGON, 22], [:GOLETT, 26]]
    },
:ARENA_TRAINER_SUPERNERD_12 => {
      :name => "Baptiste", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SWABLU, 21], [:MIMEJR, 21], [:CASTFORM, 24], [:MUSHARNA, 25], [:PORYGON2, 26], [:MRMIME, 27]]
    },
:ARENA_TRAINER_SUPERNERD_13 => {
      :name => "Adrien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MUNCHLAX, 25]]
    },
:ARENA_TRAINER_SUPERNERD_14 => {
      :name => "Alexandre", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:GRIMER, 21], [:MUNCHLAX, 23], [:STUNFISK, 26], [:GYARADOS, 27], [:MUNNA, 30], [:ELECTRODE, 30]]
    },
:ARENA_TRAINER_SUPERNERD_15 => {
      :name => "Hugo", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:GYARADOS, 22], [:PIKACHU, 22], [:GOTHITA, 24], [:BRONZOR, 26], [:BIBAREL, 27], [:EEVEE, 30]]
    },
:ARENA_TRAINER_SUPERNERD_16 => {
      :name => "Vincent", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:HYPNO, 31], [:BALTOY, 31], [:SMEARGLE, 32], [:SHUCKLE, 33], [:MUSHARNA, 38]]
    },
:ARENA_TRAINER_SUPERNERD_17 => {
      :name => "Matthieu", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ROTOM, 35]]
    },
:ARENA_TRAINER_SUPERNERD_18 => {
      :name => "Martin", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:UNOWN, 35]]
    },
:ARENA_TRAINER_SUPERNERD_19 => {
      :name => "Yanis", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:CHATOT, 30], [:SIGILYPH, 34], [:GOLETT, 34], [:MRMIME, 36], [:SHUCKLE, 39]]
    },
:ARENA_TRAINER_SUPERNERD_20 => {
      :name => "Samy", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:BIBAREL, 30], [:PIKACHU, 31], [:GOLETT, 35], [:ALAKAZAM, 40]]
    },
:ARENA_TRAINER_SUPERNERD_21 => {
      :name => "Joris", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:GOLETT, 42], [:SPINDA, 42], [:SNORLAX, 42], [:SLOWBRO, 45], [:PORYGON2, 48], [:ALAKAZAM, 50]]
    },
:ARENA_TRAINER_SUPERNERD_22 => {
      :name => "Sofiane", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ALAKAZAM, 41], [:DITTO, 42], [:BEHEEYEM, 42], [:SLAKING, 50]]
    },
:ARENA_TRAINER_SUPERNERD_23 => {
      :name => "Samuel", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:UNOWN, 48]]
    },
:ARENA_TRAINER_SUPERNERD_24 => {
      :name => "Jérémy", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:UNOWN, 45]]
    },
:ARENA_TRAINER_SUPERNERD_25 => {
      :name => "Valentin", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:KLANG, 45]]
    },
:ARENA_TRAINER_SUPERNERD_26 => {
      :name => "Rémi", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:CLAYDOL, 51], [:MAGNETON, 52], [:MUK, 57], [:BRONZONG, 58], [:CASTFORM, 59]]
    },
:ARENA_TRAINER_SUPERNERD_27 => {
      :name => "Maxime", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:WOBBUFFET, 52], [:GOLDUCK, 54], [:MRMIME, 55], [:STUNFISK, 56]]
    },
:ARENA_TRAINER_SUPERNERD_28 => {
      :name => "Jean-Baptiste", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MUSHARNA, 51], [:KLINKLANG, 54], [:MAGNETON, 58], [:REUNICLUS, 59]]
    },
:ARENA_TRAINER_SUPERNERD_29 => {
      :name => "Damien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:CLAYDOL, 53], [:SIGILYPH, 54], [:HYPNO, 55], [:GARBODOR, 58]]
    },
:ARENA_TRAINER_SUPERNERD_30 => {
      :name => "Gaëtan", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:STUNFISK, 57], [:SLOWKING, 57], [:CASTFORM, 59], [:MAGNETON, 60]]
    },
:ARENA_TRAINER_SUPERNERD_31 => {
      :name => "Yannick", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:KECLEON, 61], [:SLOWKING, 67]]
    },
:ARENA_TRAINER_SUPERNERD_32 => {
      :name => "Jordan", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MAGNETON, 60], [:SMEARGLE, 64], [:SPINDA, 66]]
    },
:ARENA_TRAINER_SUPERNERD_33 => {
      :name => "Sébastien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MRMIME, 61], [:BRONZONG, 62], [:PIKACHU, 64], [:KECLEON, 66], [:KLINKLANG, 68]]
    },
:ARENA_TRAINER_SUPERNERD_34 => {
      :name => "Pierre-Yves", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:HYPNO, 64], [:CLAYDOL, 66], [:SPINDA, 70]]
    },
:ARENA_TRAINER_SUPERNERD_35 => {
      :name => "Brice", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SLOWKING, 60], [:BRONZONG, 63], [:CASTFORM, 64], [:KLINKLANG, 64], [:SLOWBRO, 70]]
    },
:ARENA_TRAINER_SUPERNERD_36 => {
      :name => "Kévin", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SHUCKLE, 72], [:MUSHARNA, 77], [:SPINDA, 77], [:ALAKAZAM, 78]]
    },
:ARENA_TRAINER_SUPERNERD_37 => {
      :name => "Tristan", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:KLINKLANG, 70], [:HYPNO, 72], [:ALAKAZAM, 73], [:SPINDA, 77], [:SIGILYPH, 78]]
    },
:ARENA_TRAINER_SUPERNERD_38 => {
      :name => "Étienne", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:WEEZING, 70], [:MUK, 75]]
    },
:ARENA_TRAINER_SUPERNERD_39 => {
      :name => "Julien", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:MAGNEZONE, 75]]
    },
:ARENA_TRAINER_SUPERNERD_40 => {
      :name => "Nicolas", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:BRONZONG, 70], [:KLINKLANG, 72], [:CHATOT, 72], [:PORYGONZ, 77], [:PORYGON, 79]]
    },
:ARENA_TRAINER_SUPERNERD_41 => {
      :name => "Théo", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ALAKAZAM, 83], [:WATCHOG, 88], [:CHATOT, 90]]
    },
:ARENA_TRAINER_SUPERNERD_42 => {
      :name => "Ludovic", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:REUNICLUS, 86]]
    },
:ARENA_TRAINER_SUPERNERD_43 => {
      :name => "Benoît", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:BRONZONG, 88], [:CLAYDOL, 88], [:ALAKAZAM, 89], [:MUSHARNA, 90], [:GYARADOS, 90]]
    },
:ARENA_TRAINER_SUPERNERD_44 => {
      :name => "Steven", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:GYARADOS, 84], [:SMEARGLE, 85], [:DITTO, 89]]
    },
:ARENA_TRAINER_SUPERNERD_45 => {
      :name => "Quentin", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:WEEZING, 82], [:CASTFORM, 85]]
    },
:ARENA_TRAINER_SUPERNERD_46 => {
      :name => "Thibault", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ELECTRODE, 92], [:BIBAREL, 93], [:GARBODOR, 94], [:SPINDA, 94], [:KLINKLANG, 98], [:GOLDUCK, 98]]
    },
:ARENA_TRAINER_SUPERNERD_47 => {
      :name => "Corentin", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:SHUCKLE, 95]]
    },
:ARENA_TRAINER_SUPERNERD_48 => {
      :name => "Arnaud", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ALAKAZAM, 92], [:PORYGON2, 92], [:DITTO, 93], [:CASTFORM, 94], [:BRONZONG, 95], [:KLINKLANG, 96]]
    },
:ARENA_TRAINER_SUPERNERD_49 => {
      :name => "Karim", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:CHATOT, 95]]
    },
:ARENA_TRAINER_SUPERNERD_50 => {
      :name => "Dylan", :sprite => "trainer_SUPERNERD", :type => :SUPERNERD,
      :team => [[:ELECTRODE, 91], [:ROTOM, 92], [:METAGROSS, 93], [:HYPNO, 95], [:SLAKING, 96]]
    },
:ARENA_TRAINER_SWIMMER_F_1 => {
      :name => "Manon", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:FRILLISH, 5], [:CHINCHOU, 4]]
    },
:ARENA_TRAINER_SWIMMER_F_2 => {
      :name => "Marina", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:POLIWAG, 3], [:LOTAD, 4], [:HORSEA, 5], [:MAGIKARP, 6], [:WAILMER, 6], [:GOLDEEN, 9]]
    },
:ARENA_TRAINER_SWIMMER_F_3 => {
      :name => "Federica", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CORPHISH, 5], [:TIRTOUGA, 6]]
    },
:ARENA_TRAINER_SWIMMER_F_4 => {
      :name => "Maëlle", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:TIRTOUGA, 2], [:POLIWAG, 7]]
    },
:ARENA_TRAINER_SWIMMER_F_5 => {
      :name => "Regan", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SQUIRTLE, 5], [:FEEBAS, 8]]
    },
:ARENA_TRAINER_SWIMMER_F_6 => {
      :name => "Katinka", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CHINCHOU, 16], [:FRILLISH, 18], [:SPHEAL, 19]]
    },
:ARENA_TRAINER_SWIMMER_F_7 => {
      :name => "Laure", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SPHEAL, 10], [:MARILL, 17], [:FRILLISH, 20]]
    },
:ARENA_TRAINER_SWIMMER_F_8 => {
      :name => "Missy", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:MARILL, 14], [:MAGIKARP, 15], [:RELICANTH, 15]]
    },
:ARENA_TRAINER_SWIMMER_F_9 => {
      :name => "Chloé", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:STARYU, 11], [:FINNEON, 14], [:QWILFISH, 17], [:FEEBAS, 18], [:SLOWPOKE, 19]]
    },
:ARENA_TRAINER_SWIMMER_F_10 => {
      :name => "Dara", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:FINNEON, 14], [:STARYU, 19], [:MANTYKE, 20]]
    },
:ARENA_TRAINER_SWIMMER_F_11 => {
      :name => "Bronte", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:MARSHTOMP, 24], [:LUVDISC, 28], [:CORPHISH, 29]]
    },
:ARENA_TRAINER_SWIMMER_F_12 => {
      :name => "Léa", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:MILOTIC, 30]]
    },
:ARENA_TRAINER_SWIMMER_F_13 => {
      :name => "Emma", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:LANTURN, 28]]
    },
:ARENA_TRAINER_SWIMMER_F_14 => {
      :name => "Eva", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:REMORAID, 22], [:CROCONAW, 26]]
    },
:ARENA_TRAINER_SWIMMER_F_15 => {
      :name => "Charlotte", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:TENTACOOL, 22], [:PRINPLUP, 24], [:CORPHISH, 24], [:DEWOTT, 28]]
    },
:ARENA_TRAINER_SWIMMER_F_16 => {
      :name => "Mireia", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:MANTINE, 32], [:SEADRA, 34], [:SWAMPERT, 36]]
    },
:ARENA_TRAINER_SWIMMER_F_17 => {
      :name => "Sarah", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SHELLOS, 30], [:SEEL, 34], [:STARMIE, 35], [:HUNTAIL, 39], [:CORSOLA, 39]]
    },
:ARENA_TRAINER_SWIMMER_F_18 => {
      :name => "Penny", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:HUNTAIL, 36]]
    },
:ARENA_TRAINER_SWIMMER_F_19 => {
      :name => "Alizée", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SHELLOS, 30], [:DEWOTT, 31], [:OCTILLERY, 33], [:PRINPLUP, 36], [:ALOMOMOLA, 38]]
    },
:ARENA_TRAINER_SWIMMER_F_20 => {
      :name => "Annette", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:LUVDISC, 31], [:VAPOREON, 31], [:FLOATZEL, 34], [:LUMINEON, 35], [:SEALEO, 37], [:QWILFISH, 38]]
    },
:ARENA_TRAINER_SWIMMER_F_21 => {
      :name => "Ondine", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CRAWDAUNT, 40], [:CLOYSTER, 42], [:SWAMPERT, 42], [:GASTRODON, 45]]
    },
:ARENA_TRAINER_SWIMMER_F_22 => {
      :name => "Kaylee", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:JELLICENT, 40], [:CLOYSTER, 45], [:OCTILLERY, 47]]
    },
:ARENA_TRAINER_SWIMMER_F_23 => {
      :name => "Maëva", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CARRACOSTA, 40], [:SHARPEDO, 44], [:SWAMPERT, 44], [:PELIPPER, 46], [:BLASTOISE, 50]]
    },
:ARENA_TRAINER_SWIMMER_F_24 => {
      :name => "Romane", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:WAILORD, 40], [:CRAWDAUNT, 43], [:SEADRA, 47], [:EMPOLEON, 47], [:SAMUROTT, 48]]
    },
:ARENA_TRAINER_SWIMMER_F_25 => {
      :name => "Clara", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:LAPRAS, 41], [:SWAMPERT, 46], [:TENTACRUEL, 47], [:SAMUROTT, 47]]
    },
:ARENA_TRAINER_SWIMMER_F_26 => {
      :name => "Maya", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEAKING, 53], [:STARMIE, 54], [:LUMINEON, 56], [:SEADRA, 56], [:ALOMOMOLA, 57]]
    },
:ARENA_TRAINER_SWIMMER_F_27 => {
      :name => "Natalie", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:EMPOLEON, 50], [:GYARADOS, 52], [:AZUMARILL, 52], [:WALREIN, 59]]
    },
:ARENA_TRAINER_SWIMMER_F_28 => {
      :name => "Katie", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SWAMPERT, 50], [:PELIPPER, 55], [:FLOATZEL, 59]]
    },
:ARENA_TRAINER_SWIMMER_F_29 => {
      :name => "Maïwenn", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:LUVDISC, 50], [:GASTRODON, 52], [:SHARPEDO, 56], [:DEWGONG, 57], [:LANTURN, 58]]
    },
:ARENA_TRAINER_SWIMMER_F_30 => {
      :name => "Éléonore", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEAKING, 50], [:GYARADOS, 51], [:SWAMPERT, 55]]
    },
:ARENA_TRAINER_SWIMMER_F_31 => {
      :name => "Inès", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CLOYSTER, 61], [:GASTRODON, 61], [:SAMUROTT, 63], [:MILOTIC, 63], [:GYARADOS, 67], [:ALOMOMOLA, 69]]
    },
:ARENA_TRAINER_SWIMMER_F_32 => {
      :name => "Esther", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:EMPOLEON, 60], [:LANTURN, 64], [:QWILFISH, 65], [:CORSOLA, 67], [:GOREBYSS, 69], [:SHARPEDO, 70]]
    },
:ARENA_TRAINER_SWIMMER_F_33 => {
      :name => "Diana", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:AZUMARILL, 61], [:BLASTOISE, 64], [:WAILORD, 67], [:HUNTAIL, 68], [:QWILFISH, 69], [:DEWGONG, 70]]
    },
:ARENA_TRAINER_SWIMMER_F_34 => {
      :name => "Gertrude", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEAKING, 60], [:LANTURN, 67], [:SEADRA, 69]]
    },
:ARENA_TRAINER_SWIMMER_F_35 => {
      :name => "Cate", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:JELLICENT, 61], [:LAPRAS, 63], [:KINGLER, 65], [:SAMUROTT, 68], [:FLOATZEL, 69]]
    },
:ARENA_TRAINER_SWIMMER_F_36 => {
      :name => "Jade", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:GASTRODON, 78], [:CLOYSTER, 80], [:WALREIN, 80]]
    },
:ARENA_TRAINER_SWIMMER_F_37 => {
      :name => "Nolwenn", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:VAPOREON, 74], [:OCTILLERY, 77], [:EMPOLEON, 78], [:SEAKING, 79]]
    },
:ARENA_TRAINER_SWIMMER_F_38 => {
      :name => "Lola", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:GOREBYSS, 73], [:LUMINEON, 73], [:WAILORD, 79], [:MILOTIC, 80]]
    },
:ARENA_TRAINER_SWIMMER_F_39 => {
      :name => "Louna", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CORSOLA, 72], [:SAMUROTT, 73], [:CLOYSTER, 73], [:JELLICENT, 80]]
    },
:ARENA_TRAINER_SWIMMER_F_40 => {
      :name => "Zoé", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:MILOTIC, 77]]
    },
:ARENA_TRAINER_SWIMMER_F_41 => {
      :name => "Solène", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:RELICANTH, 82], [:EMPOLEON, 83], [:LUVDISC, 88]]
    },
:ARENA_TRAINER_SWIMMER_F_42 => {
      :name => "Océane", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEADRA, 85]]
    },
:ARENA_TRAINER_SWIMMER_F_43 => {
      :name => "Justine", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEAKING, 81], [:WALREIN, 81], [:LAPRAS, 84], [:STARMIE, 88]]
    },
:ARENA_TRAINER_SWIMMER_F_44 => {
      :name => "Armelle", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:BLASTOISE, 81], [:SHARPEDO, 82], [:SAMUROTT, 86], [:TENTACRUEL, 87], [:WALREIN, 89], [:CLOYSTER, 90]]
    },
:ARENA_TRAINER_SWIMMER_F_45 => {
      :name => "Gaëlle", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:VAPOREON, 80], [:RELICANTH, 81], [:SEAKING, 90]]
    },
:ARENA_TRAINER_SWIMMER_F_46 => {
      :name => "Mélanie", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:GASTRODON, 100]]
    },
:ARENA_TRAINER_SWIMMER_F_47 => {
      :name => "Lynne", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:SEADRA, 92], [:WAILORD, 93], [:LUVDISC, 97], [:MANTINE, 97]]
    },
:ARENA_TRAINER_SWIMMER_F_48 => {
      :name => "Camille", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:KINGLER, 100]]
    },
:ARENA_TRAINER_SWIMMER_F_49 => {
      :name => "Lou", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:CARRACOSTA, 92], [:FLOATZEL, 92], [:SEADRA, 93], [:SWAMPERT, 94], [:KINGLER, 94], [:MANTINE, 100]]
    },
:ARENA_TRAINER_SWIMMER_F_50 => {
      :name => "Amy", :sprite => "trainer_SWIMMER_F", :type => :SWIMMER_F,
      :team => [[:RELICANTH, 92], [:TENTACRUEL, 93], [:CRAWDAUNT, 93], [:GASTRODON, 96], [:VAPOREON, 99]]
    },
:ARENA_TRAINER_SWIMMER_M_1 => {
      :name => "Ryan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CHINCHOU, 4], [:STARYU, 4], [:FINNEON, 6], [:MANTYKE, 8]]
    },
:ARENA_TRAINER_SWIMMER_M_2 => {
      :name => "Romain", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:POLIWAG, 6]]
    },
:ARENA_TRAINER_SWIMMER_M_3 => {
      :name => "Titouan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:LUVDISC, 8]]
    },
:ARENA_TRAINER_SWIMMER_M_4 => {
      :name => "Bastien", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SQUIRTLE, 2], [:FINNEON, 3], [:AZURILL, 6], [:CLAMPERL, 9]]
    },
:ARENA_TRAINER_SWIMMER_M_5 => {
      :name => "Ethan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CORPHISH, 7], [:TIRTOUGA, 7], [:FINNEON, 7], [:OSHAWOTT, 7], [:SLOWPOKE, 10]]
    },
:ARENA_TRAINER_SWIMMER_M_6 => {
      :name => "Noé", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:REMORAID, 11], [:QWILFISH, 13], [:AZURILL, 15], [:OSHAWOTT, 17], [:CLAMPERL, 18], [:FINNEON, 19]]
    },
:ARENA_TRAINER_SWIMMER_M_7 => {
      :name => "Gabriel", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SQUIRTLE, 11], [:KRABBY, 15], [:PSYDUCK, 15], [:GOLDEEN, 17], [:QWILFISH, 18], [:TIRTOUGA, 20]]
    },
:ARENA_TRAINER_SWIMMER_M_8 => {
      :name => "Simon", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MANTYKE, 15], [:RELICANTH, 18]]
    },
:ARENA_TRAINER_SWIMMER_M_9 => {
      :name => "Pascal", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:STARYU, 11], [:TENTACOOL, 12], [:REMORAID, 13], [:FRILLISH, 13], [:OSHAWOTT, 15], [:WARTORTLE, 19]]
    },
:ARENA_TRAINER_SWIMMER_M_10 => {
      :name => "Camille", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CHINCHOU, 19]]
    },
:ARENA_TRAINER_SWIMMER_M_11 => {
      :name => "Briac", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:DEWOTT, 21], [:GYARADOS, 23], [:SLOWPOKE, 29], [:ALOMOMOLA, 30]]
    },
:ARENA_TRAINER_SWIMMER_M_12 => {
      :name => "Jordan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:HORSEA, 22], [:STARMIE, 26], [:FRILLISH, 26], [:ALOMOMOLA, 27]]
    },
:ARENA_TRAINER_SWIMMER_M_13 => {
      :name => "Antoine", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:BUIZEL, 20], [:SEEL, 21], [:CORSOLA, 21], [:SHELLDER, 22], [:MANTINE, 24], [:CROCONAW, 27]]
    },
:ARENA_TRAINER_SWIMMER_M_14 => {
      :name => "Florent", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CHINCHOU, 20], [:FEEBAS, 22], [:CORSOLA, 22], [:RELICANTH, 25], [:SHELLOS, 25]]
    },
:ARENA_TRAINER_SWIMMER_M_15 => {
      :name => "Axel", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARVANHA, 29], [:GYARADOS, 30]]
    },
:ARENA_TRAINER_SWIMMER_M_16 => {
      :name => "Lucas", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CRAWDAUNT, 33], [:STARYU, 35], [:EMPOLEON, 38], [:LUMINEON, 38], [:SAMUROTT, 40], [:CARRACOSTA, 40]]
    },
:ARENA_TRAINER_SWIMMER_M_17 => {
      :name => "Sébastien", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CLAMPERL, 30], [:HUNTAIL, 33], [:AZUMARILL, 38], [:LAPRAS, 38], [:VAPOREON, 39], [:KINGLER, 40]]
    },
:ARENA_TRAINER_SWIMMER_M_18 => {
      :name => "Yann", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MANTINE, 31], [:MILOTIC, 34], [:DEWGONG, 35]]
    },
:ARENA_TRAINER_SWIMMER_M_19 => {
      :name => "Benjamin", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:PELIPPER, 30], [:OCTILLERY, 31], [:MANTINE, 34], [:LUMINEON, 38], [:SHARPEDO, 38]]
    },
:ARENA_TRAINER_SWIMMER_M_20 => {
      :name => "Raphaël", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MILOTIC, 40]]
    },
:ARENA_TRAINER_SWIMMER_M_21 => {
      :name => "Ronan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:LAPRAS, 40], [:KINGDRA, 43], [:RELICANTH, 45], [:LANTURN, 48], [:GYARADOS, 49]]
    },
:ARENA_TRAINER_SWIMMER_M_22 => {
      :name => "Adam", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:KINGDRA, 41], [:CORSOLA, 42], [:PELIPPER, 42], [:GASTRODON, 44], [:LUVDISC, 47]]
    },
:ARENA_TRAINER_SWIMMER_M_23 => {
      :name => "Rémi", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:LUMINEON, 44], [:FERALIGATR, 45], [:LANTURN, 46], [:SWAMPERT, 46], [:BLASTOISE, 48], [:CLOYSTER, 49]]
    },
:ARENA_TRAINER_SWIMMER_M_24 => {
      :name => "Cédric", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARRACOSTA, 45], [:GASTRODON, 46], [:BLASTOISE, 48], [:FLOATZEL, 48], [:OCTILLERY, 50]]
    },
:ARENA_TRAINER_SWIMMER_M_25 => {
      :name => "Kerian", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:PELIPPER, 40], [:OCTILLERY, 43], [:LAPRAS, 45], [:CRAWDAUNT, 50]]
    },
:ARENA_TRAINER_SWIMMER_M_26 => {
      :name => "Kyle", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:AZUMARILL, 53], [:HUNTAIL, 56], [:SEADRA, 58], [:CARRACOSTA, 58], [:KINGLER, 60], [:LUMINEON, 60]]
    },
:ARENA_TRAINER_SWIMMER_M_27 => {
      :name => "Julien", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:QWILFISH, 50], [:RELICANTH, 51], [:SEAKING, 53], [:EMPOLEON, 53], [:KINGDRA, 54], [:VAPOREON, 57]]
    },
:ARENA_TRAINER_SWIMMER_M_28 => {
      :name => "Alain", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MILOTIC, 53], [:PELIPPER, 53], [:AZUMARILL, 55], [:QWILFISH, 57], [:SHARPEDO, 58], [:CRAWDAUNT, 59]]
    },
:ARENA_TRAINER_SWIMMER_M_29 => {
      :name => "Pieter", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:QWILFISH, 51], [:AZUMARILL, 52], [:STARMIE, 56]]
    },
:ARENA_TRAINER_SWIMMER_M_30 => {
      :name => "Kilian", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SWAMPERT, 57]]
    },
:ARENA_TRAINER_SWIMMER_M_31 => {
      :name => "Loïc", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:JELLICENT, 65]]
    },
:ARENA_TRAINER_SWIMMER_M_32 => {
      :name => "Alexis", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARRACOSTA, 63], [:HUNTAIL, 70]]
    },
:ARENA_TRAINER_SWIMMER_M_33 => {
      :name => "Grant", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CRAWDAUNT, 63], [:CARRACOSTA, 67], [:AZUMARILL, 67], [:GYARADOS, 67], [:SEADRA, 69]]
    },
:ARENA_TRAINER_SWIMMER_M_34 => {
      :name => "Maxime", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:ALOMOMOLA, 60], [:KINGLER, 67], [:DEWGONG, 67], [:GYARADOS, 67], [:QWILFISH, 68]]
    },
:ARENA_TRAINER_SWIMMER_M_35 => {
      :name => "Fred", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SWAMPERT, 66], [:HUNTAIL, 66], [:EMPOLEON, 68], [:MILOTIC, 70]]
    },
:ARENA_TRAINER_SWIMMER_M_36 => {
      :name => "Mathis", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:QWILFISH, 80]]
    },
:ARENA_TRAINER_SWIMMER_M_37 => {
      :name => "Louis", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARRACOSTA, 70], [:WAILORD, 71], [:GYARADOS, 74], [:CRAWDAUNT, 75], [:OCTILLERY, 76]]
    },
:ARENA_TRAINER_SWIMMER_M_38 => {
      :name => "Ian", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SWAMPERT, 70], [:WAILORD, 73], [:EMPOLEON, 74], [:CORSOLA, 77], [:QWILFISH, 77]]
    },
:ARENA_TRAINER_SWIMMER_M_39 => {
      :name => "Tanguy", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARRACOSTA, 72], [:CRAWDAUNT, 76], [:RELICANTH, 80], [:FERALIGATR, 80], [:SAMUROTT, 80], [:VAPOREON, 80]]
    },
:ARENA_TRAINER_SWIMMER_M_40 => {
      :name => "Armel", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:CARRACOSTA, 74], [:MANTINE, 75], [:EMPOLEON, 79], [:CLOYSTER, 80], [:HUNTAIL, 80]]
    },
:ARENA_TRAINER_SWIMMER_M_41 => {
      :name => "Nathan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:KINGLER, 80], [:GOREBYSS, 85]]
    },
:ARENA_TRAINER_SWIMMER_M_42 => {
      :name => "Enzo", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:LAPRAS, 86], [:CLOYSTER, 90]]
    },
:ARENA_TRAINER_SWIMMER_M_43 => {
      :name => "Michael", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MILOTIC, 84], [:AZUMARILL, 89], [:SHARPEDO, 89], [:QWILFISH, 90]]
    },
:ARENA_TRAINER_SWIMMER_M_44 => {
      :name => "Léon", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:AZUMARILL, 88]]
    },
:ARENA_TRAINER_SWIMMER_M_45 => {
      :name => "Marc", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MILOTIC, 81], [:TENTACRUEL, 85]]
    },
:ARENA_TRAINER_SWIMMER_M_46 => {
      :name => "Erwan", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:FLOATZEL, 90], [:KINGLER, 91], [:SEADRA, 95], [:SHARPEDO, 95], [:MANTINE, 96], [:EMPOLEON, 97]]
    },
:ARENA_TRAINER_SWIMMER_M_47 => {
      :name => "Caeleb", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SWAMPERT, 95]]
    },
:ARENA_TRAINER_SWIMMER_M_48 => {
      :name => "Corentin", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:SEADRA, 99]]
    },
:ARENA_TRAINER_SWIMMER_M_49 => {
      :name => "Mathurin", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:GASTRODON, 92], [:TENTACRUEL, 96], [:GOREBYSS, 97], [:AZUMARILL, 97]]
    },
:ARENA_TRAINER_SWIMMER_M_50 => {
      :name => "César", :sprite => "trainer_SWIMMER_M", :type => :SWIMMER_M,
      :team => [[:MILOTIC, 94], [:GYARADOS, 95], [:KINGDRA, 96], [:LAPRAS, 97], [:SWAMPERT, 98], [:WAILORD, 100]]
    },
:ARENA_TRAINER_TAMER_1 => {
      :name => "Joseph", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:HOUNDOUR, 5], [:PONYTA, 4]]
    },
:ARENA_TRAINER_TAMER_2 => {
      :name => "Bruno", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:PURRLOIN, 7]]
    },
:ARENA_TRAINER_TAMER_3 => {
      :name => "Diego", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:SHINX, 3], [:EEVEE, 5], [:ELECTRIKE, 5], [:GROWLITHE, 9], [:LILLIPUP, 9], [:VULPIX, 10]]
    },
:ARENA_TRAINER_TAMER_4 => {
      :name => "Alberto", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:EEVEE, 10]]
    },
:ARENA_TRAINER_TAMER_5 => {
      :name => "Karl", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:SHINX, 7], [:LILLIPUP, 7], [:POOCHYENA, 9], [:MEOWTH, 9]]
    },
:ARENA_TRAINER_TAMER_6 => {
      :name => "Igor", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GLAMEOW, 11], [:VULPIX, 12], [:BLITZLE, 16], [:LUXIO, 19], [:HERDIER, 19]]
    },
:ARENA_TRAINER_TAMER_7 => {
      :name => "Rafael", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZORUA, 10], [:BLITZLE, 11], [:PONYTA, 12], [:SKITTY, 14], [:PURRLOIN, 17], [:EEVEE, 18]]
    },
:ARENA_TRAINER_TAMER_8 => {
      :name => "Milan", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:DELCATTY, 18], [:GROWLITHE, 18]]
    },
:ARENA_TRAINER_TAMER_9 => {
      :name => "Ivan", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ELECTRIKE, 10], [:EEVEE, 11], [:SKITTY, 12], [:ZORUA, 14], [:GLAMEOW, 18]]
    },
:ARENA_TRAINER_TAMER_10 => {
      :name => "Dimitri", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:EEVEE, 10], [:MEOWTH, 13], [:POOCHYENA, 14], [:SHINX, 15], [:LUXIO, 18], [:FLAREON, 20]]
    },
:ARENA_TRAINER_TAMER_11 => {
      :name => "Victor", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ABSOL, 24], [:ESPEON, 25], [:GLACEON, 26], [:JOLTEON, 30]]
    },
:ARENA_TRAINER_TAMER_12 => {
      :name => "Charles", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:PONYTA, 24], [:HERDIER, 27], [:ZEBSTRIKA, 27], [:PERSIAN, 28]]
    },
:ARENA_TRAINER_TAMER_13 => {
      :name => "Ernest", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:VULPIX, 25], [:NINETALES, 25], [:MEOWTH, 26]]
    },
:ARENA_TRAINER_TAMER_14 => {
      :name => "Enrique", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:MIGHTYENA, 22], [:ARCANINE, 30]]
    },
:ARENA_TRAINER_TAMER_15 => {
      :name => "Tibor", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ABSOL, 28], [:HERDIER, 29], [:PERSIAN, 30], [:UMBREON, 30], [:GLAMEOW, 30]]
    },
:ARENA_TRAINER_TAMER_16 => {
      :name => "Attila", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:MIGHTYENA, 35]]
    },
:ARENA_TRAINER_TAMER_17 => {
      :name => "Piotr", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZOROARK, 30], [:NINETALES, 33], [:STOUTLAND, 36], [:DELCATTY, 37], [:VAPOREON, 39], [:ZEBSTRIKA, 40]]
    },
:ARENA_TRAINER_TAMER_18 => {
      :name => "Alexandre", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:UMBREON, 40]]
    },
:ARENA_TRAINER_TAMER_19 => {
      :name => "Emil", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ABSOL, 30], [:PONYTA, 35]]
    },
:ARENA_TRAINER_TAMER_20 => {
      :name => "Gunther", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ESPEON, 31], [:GRANBULL, 34], [:ABSOL, 35], [:LUXRAY, 38]]
    },
:ARENA_TRAINER_TAMER_21 => {
      :name => "Carl", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZOROARK, 40], [:LUCARIO, 41], [:GRANBULL, 43], [:MANECTRIC, 46], [:STOUTLAND, 47], [:EEVEE, 48]]
    },
:ARENA_TRAINER_TAMER_22 => {
      :name => "Pablo", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:NINETALES, 45]]
    },
:ARENA_TRAINER_TAMER_23 => {
      :name => "Mario", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GLACEON, 46]]
    },
:ARENA_TRAINER_TAMER_24 => {
      :name => "Oscar", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GRANBULL, 40], [:LUXRAY, 41], [:STOUTLAND, 42], [:LUCARIO, 49], [:ESPEON, 50], [:VAPOREON, 50]]
    },
:ARENA_TRAINER_TAMER_25 => {
      :name => "Zoltan", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LIEPARD, 42], [:LUXRAY, 42], [:RAPIDASH, 44], [:GRANBULL, 45], [:ZEBSTRIKA, 50]]
    },
:ARENA_TRAINER_TAMER_26 => {
      :name => "Radu", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LEAFEON, 50], [:LUCARIO, 54], [:NINETALES, 55], [:ABSOL, 56], [:PERSIAN, 60]]
    },
:ARENA_TRAINER_TAMER_27 => {
      :name => "Henri", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZEBSTRIKA, 50], [:EEVEE, 50], [:HOUNDOOM, 53], [:PERSIAN, 57], [:UMBREON, 60]]
    },
:ARENA_TRAINER_TAMER_28 => {
      :name => "Léon", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ESPEON, 51], [:UMBREON, 52], [:EEVEE, 56], [:DELCATTY, 60], [:GRANBULL, 60]]
    },
:ARENA_TRAINER_TAMER_29 => {
      :name => "Lucien", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LIEPARD, 50], [:LUXRAY, 51], [:UMBREON, 52], [:NINETALES, 52], [:PERSIAN, 59]]
    },
:ARENA_TRAINER_TAMER_30 => {
      :name => "Frank", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LEAFEON, 51], [:HOUNDOOM, 51], [:UMBREON, 59], [:ARCANINE, 59], [:LUCARIO, 60]]
    },
:ARENA_TRAINER_TAMER_31 => {
      :name => "Fernand", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZOROARK, 65]]
    },
:ARENA_TRAINER_TAMER_32 => {
      :name => "Stefan", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GLACEON, 60], [:LEAFEON, 68], [:ZEBSTRIKA, 70]]
    },
:ARENA_TRAINER_TAMER_33 => {
      :name => "Florian", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:UMBREON, 60], [:ZOROARK, 64], [:PERSIAN, 68]]
    },
:ARENA_TRAINER_TAMER_34 => {
      :name => "Santiago", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LEAFEON, 61], [:VAPOREON, 63], [:LUCARIO, 63], [:GRANBULL, 70]]
    },
:ARENA_TRAINER_TAMER_35 => {
      :name => "Clyde", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ESPEON, 65]]
    },
:ARENA_TRAINER_TAMER_36 => {
      :name => "Émile", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:JOLTEON, 75], [:DELCATTY, 78], [:PURUGLY, 78]]
    },
:ARENA_TRAINER_TAMER_37 => {
      :name => "Albert", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LEAFEON, 73], [:GLACEON, 73], [:RAPIDASH, 78], [:LIEPARD, 80]]
    },
:ARENA_TRAINER_TAMER_38 => {
      :name => "Alfred", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:JOLTEON, 75]]
    },
:ARENA_TRAINER_TAMER_39 => {
      :name => "Hippolyte", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ZOROARK, 70], [:GLACEON, 71], [:PURUGLY, 71], [:JOLTEON, 76], [:DELCATTY, 77], [:ESPEON, 80]]
    },
:ARENA_TRAINER_TAMER_40 => {
      :name => "Théodore", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GLACEON, 75]]
    },
:ARENA_TRAINER_TAMER_41 => {
      :name => "Siegfried", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ARCANINE, 82], [:LIEPARD, 83], [:PERSIAN, 83], [:HOUNDOOM, 90], [:VAPOREON, 90]]
    },
:ARENA_TRAINER_TAMER_42 => {
      :name => "Boris", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:ESPEON, 81], [:ZOROARK, 83], [:GRANBULL, 86]]
    },
:ARENA_TRAINER_TAMER_43 => {
      :name => "Sergueï", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:PERSIAN, 80], [:LIEPARD, 81], [:NINETALES, 86]]
    },
:ARENA_TRAINER_TAMER_44 => {
      :name => "Gianni", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GLACEON, 84], [:ABSOL, 86], [:PURUGLY, 87], [:LUCARIO, 89], [:STOUTLAND, 89], [:LIEPARD, 89]]
    },
:ARENA_TRAINER_TAMER_45 => {
      :name => "Hector", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:LEAFEON, 80], [:STOUTLAND, 81], [:UMBREON, 88], [:LUXRAY, 90], [:MANECTRIC, 90]]
    },
:ARENA_TRAINER_TAMER_46 => {
      :name => "Béla", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:FLAREON, 95], [:LUXRAY, 97], [:ZOROARK, 100]]
    },
:ARENA_TRAINER_TAMER_47 => {
      :name => "Marcel", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:NINETALES, 93], [:FLAREON, 94], [:GLACEON, 96]]
    },
:ARENA_TRAINER_TAMER_48 => {
      :name => "Alexis", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:JOLTEON, 90], [:NINETALES, 96], [:VAPOREON, 96], [:HOUNDOOM, 96]]
    },
:ARENA_TRAINER_TAMER_49 => {
      :name => "Gustave", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:GRANBULL, 95]]
    },
:ARENA_TRAINER_TAMER_50 => {
      :name => "Auguste", :sprite => "trainer_TAMER", :type => :TAMER,
      :team => [[:DELCATTY, 91], [:ZOROARK, 92], [:GLACEON, 92], [:LEAFEON, 94], [:RAPIDASH, 94], [:MANECTRIC, 95]]
    },
:ARENA_TRAINER_TEAMROCKET_F_1 => {
      :name => "Bonnie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:EKANS, 5], [:RATTATA, 4]]
    },
:ARENA_TRAINER_TEAMROCKET_F_2 => {
      :name => "Dolores", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:VENONAT, 3], [:ZUBAT, 7]]
    },
:ARENA_TRAINER_TEAMROCKET_F_3 => {
      :name => "Olga", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MISDREAVUS, 9]]
    },
:ARENA_TRAINER_TEAMROCKET_F_4 => {
      :name => "Sylvie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GRIMER, 4], [:MEOWTH, 5], [:HOUNDOUR, 6], [:MAGIKARP, 6], [:GASTLY, 10]]
    },
:ARENA_TRAINER_TEAMROCKET_F_5 => {
      :name => "Joanna", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:ZUBAT, 6], [:EXEGGCUTE, 7]]
    },
:ARENA_TRAINER_TEAMROCKET_F_6 => {
      :name => "Frida", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:DIGLETT, 15]]
    },
:ARENA_TRAINER_TEAMROCKET_F_7 => {
      :name => "Vera", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:ELEKID, 10], [:GEODUDE, 12], [:SANDSHREW, 13], [:MISDREAVUS, 15]]
    },
:ARENA_TRAINER_TEAMROCKET_F_8 => {
      :name => "Kiki", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GLIGAR, 14], [:MAGIKARP, 15], [:GROWLITHE, 16], [:GASTLY, 16], [:MEOWTH, 17], [:SNEASEL, 18]]
    },
:ARENA_TRAINER_TEAMROCKET_F_9 => {
      :name => "Karine", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:KOFFING, 11], [:EXEGGCUTE, 11], [:GROWLITHE, 12], [:SANDSHREW, 16], [:DROWZEE, 20]]
    },
:ARENA_TRAINER_TEAMROCKET_F_10 => {
      :name => "Tiffany", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:TENTACOOL, 18]]
    },
:ARENA_TRAINER_TEAMROCKET_F_11 => {
      :name => "Sandra", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MAGBY, 20], [:ONIX, 21], [:MURKROW, 23], [:DIGLETT, 25], [:SNEASEL, 27], [:EXEGGUTOR, 30]]
    },
:ARENA_TRAINER_TEAMROCKET_F_12 => {
      :name => "Rita", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MURKROW, 22], [:GRAVELER, 25], [:MAROWAK, 29], [:GLISCOR, 30]]
    },
:ARENA_TRAINER_TEAMROCKET_F_13 => {
      :name => "Anouk", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:RATICATE, 20], [:ELEKID, 20], [:DROWZEE, 20], [:HOUNDOUR, 24], [:CUBONE, 27]]
    },
:ARENA_TRAINER_TEAMROCKET_F_14 => {
      :name => "Fiona", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:DRATINI, 25], [:GOLBAT, 29], [:MAROWAK, 30]]
    },
:ARENA_TRAINER_TEAMROCKET_F_15 => {
      :name => "Mimi", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:VENONAT, 20], [:HITMONCHAN, 21], [:SANDSHREW, 21], [:VULPIX, 22], [:GASTLY, 25]]
    },
:ARENA_TRAINER_TEAMROCKET_F_16 => {
      :name => "Vicky", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PUPITAR, 33], [:EXEGGUTOR, 39]]
    },
:ARENA_TRAINER_TEAMROCKET_F_17 => {
      :name => "Annie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:QWILFISH, 30], [:MISDREAVUS, 31], [:RHYHORN, 32], [:GLISCOR, 34], [:KANGASKHAN, 35], [:ARBOK, 37]]
    },
:ARENA_TRAINER_TEAMROCKET_F_18 => {
      :name => "Quitterie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MAROWAK, 31], [:SKARMORY, 34], [:QWILFISH, 37], [:HAUNTER, 40], [:SANDSLASH, 40], [:RHYHORN, 40]]
    },
:ARENA_TRAINER_TEAMROCKET_F_19 => {
      :name => "Wendy", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MISMAGIUS, 30], [:DUGTRIO, 30], [:ELECTABUZZ, 30], [:RATICATE, 33], [:KANGASKHAN, 37], [:TENTACRUEL, 39]]
    },
:ARENA_TRAINER_TEAMROCKET_F_20 => {
      :name => "Gabrielle", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:ARCANINE, 35]]
    },
:ARENA_TRAINER_TEAMROCKET_F_21 => {
      :name => "Ursula", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GLISCOR, 45]]
    },
:ARENA_TRAINER_TEAMROCKET_F_22 => {
      :name => "Raquel", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:WEEZING, 40], [:GOLEM, 41], [:MACHAMP, 44], [:PORYGON2, 46], [:GYARADOS, 47]]
    },
:ARENA_TRAINER_TEAMROCKET_F_23 => {
      :name => "Xénia", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:DUGTRIO, 43], [:PORYGON2, 45], [:MUK, 46], [:ELECTABUZZ, 47], [:CROBAT, 48]]
    },
:ARENA_TRAINER_TEAMROCKET_F_24 => {
      :name => "Rosa", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:WEEZING, 49]]
    },
:ARENA_TRAINER_TEAMROCKET_F_25 => {
      :name => "Patricia", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GOLEM, 42], [:PRIMEAPE, 42], [:KANGASKHAN, 47], [:QWILFISH, 50]]
    },
:ARENA_TRAINER_TEAMROCKET_F_26 => {
      :name => "Gina", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PUPITAR, 50], [:PINSIR, 50], [:PORYGON, 51], [:MACHAMP, 53], [:QWILFISH, 56]]
    },
:ARENA_TRAINER_TEAMROCKET_F_27 => {
      :name => "Lola", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:DUGTRIO, 57]]
    },
:ARENA_TRAINER_TEAMROCKET_F_28 => {
      :name => "Sabrina", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PERSIAN, 51], [:MUK, 53], [:SLOWBRO, 53], [:ELECTRODE, 57], [:MACHAMP, 58]]
    },
:ARENA_TRAINER_TEAMROCKET_F_29 => {
      :name => "Lucia", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:EXEGGUTOR, 50], [:MUK, 56], [:TAUROS, 59]]
    },
:ARENA_TRAINER_TEAMROCKET_F_30 => {
      :name => "Nina", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:HOUNDOOM, 53], [:MISMAGIUS, 59], [:UMBREON, 60]]
    },
:ARENA_TRAINER_TEAMROCKET_F_31 => {
      :name => "Hélène", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:SANDSLASH, 67]]
    },
:ARENA_TRAINER_TEAMROCKET_F_32 => {
      :name => "Esmeralda", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PRIMEAPE, 60], [:KANGASKHAN, 63], [:CROBAT, 65]]
    },
:ARENA_TRAINER_TEAMROCKET_F_33 => {
      :name => "Paula", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:TENTACRUEL, 61], [:TYRANITAR, 64], [:STEELIX, 67], [:ARCANINE, 68], [:MAROWAK, 69], [:ESPEON, 70]]
    },
:ARENA_TRAINER_TEAMROCKET_F_34 => {
      :name => "Mélanie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MACHAMP, 62], [:UMBREON, 65], [:WOBBUFFET, 68], [:TYRANITAR, 69]]
    },
:ARENA_TRAINER_TEAMROCKET_F_35 => {
      :name => "Béatrice", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MISMAGIUS, 60], [:MAROWAK, 63], [:VENOMOTH, 68]]
    },
:ARENA_TRAINER_TEAMROCKET_F_36 => {
      :name => "Mathilde", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:MISMAGIUS, 74], [:PINSIR, 80]]
    },
:ARENA_TRAINER_TEAMROCKET_F_37 => {
      :name => "Isabelle", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PERSIAN, 70], [:VENOMOTH, 70], [:HOUNDOOM, 73], [:QWILFISH, 77], [:TAUROS, 79]]
    },
:ARENA_TRAINER_TEAMROCKET_F_38 => {
      :name => "Natasha", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PORYGON, 75]]
    },
:ARENA_TRAINER_TEAMROCKET_F_39 => {
      :name => "Cécile", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:HITMONLEE, 73], [:SKARMORY, 77], [:PERSIAN, 78], [:CROBAT, 78], [:PORYGON, 79]]
    },
:ARENA_TRAINER_TEAMROCKET_F_40 => {
      :name => "Maya", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:SKARMORY, 71], [:RHYDON, 73], [:HITMONCHAN, 77]]
    },
:ARENA_TRAINER_TEAMROCKET_F_41 => {
      :name => "Valérie", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PORYGON2, 85]]
    },
:ARENA_TRAINER_TEAMROCKET_F_42 => {
      :name => "Tania", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:HOUNDOOM, 83], [:TENTACRUEL, 88]]
    },
:ARENA_TRAINER_TEAMROCKET_F_43 => {
      :name => "Elvira", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GYARADOS, 82], [:ESPEON, 84], [:GENGAR, 85]]
    },
:ARENA_TRAINER_TEAMROCKET_F_44 => {
      :name => "Odile", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:WOBBUFFET, 81], [:HITMONLEE, 85], [:KANGASKHAN, 86]]
    },
:ARENA_TRAINER_TEAMROCKET_F_45 => {
      :name => "Zoé", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:TENTACRUEL, 82], [:GENGAR, 86], [:STEELIX, 88], [:UMBREON, 88], [:RATICATE, 89], [:ESPEON, 90]]
    },
:ARENA_TRAINER_TEAMROCKET_F_46 => {
      :name => "Irène", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:GOLEM, 92], [:DRAGONITE, 96], [:RATICATE, 97], [:TENTACRUEL, 100]]
    },
:ARENA_TRAINER_TEAMROCKET_F_47 => {
      :name => "Yvonne", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:ELECTABUZZ, 90], [:NINETALES, 91], [:QWILFISH, 95], [:CROBAT, 96], [:MACHAMP, 99]]
    },
:ARENA_TRAINER_TEAMROCKET_F_48 => {
      :name => "Wanda", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:PORYGON, 100]]
    },
:ARENA_TRAINER_TEAMROCKET_F_49 => {
      :name => "Lydia", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:HOUNDOOM, 91], [:CROBAT, 93], [:TYRANITAR, 96], [:HONCHKROW, 100]]
    },
:ARENA_TRAINER_TEAMROCKET_F_50 => {
      :name => "Stella", :sprite => "trainer_TEAMROCKET_F", :type => :TEAMROCKET_F,
      :team => [[:HITMONLEE, 95], [:MISMAGIUS, 95], [:SCYTHER, 96], [:CROBAT, 96], [:WOBBUFFET, 99]]
    },
:ARENA_TRAINER_TEAMROCKET_M_1 => {
      :name => "Santino", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SLOWPOKE, 2], [:WYNAUT, 3], [:MANKEY, 5], [:MAGIKARP, 6], [:ZUBAT, 7], [:HOUNDOUR, 8]]
    },
:ARENA_TRAINER_TEAMROCKET_M_2 => {
      :name => "Dante", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ONIX, 6]]
    },
:ARENA_TRAINER_TEAMROCKET_M_3 => {
      :name => "Matteo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:GRIMER, 6]]
    },
:ARENA_TRAINER_TEAMROCKET_M_4 => {
      :name => "Lucca", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:KOFFING, 2], [:TENTACOOL, 2], [:SLOWPOKE, 9]]
    },
:ARENA_TRAINER_TEAMROCKET_M_5 => {
      :name => "Bernardo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:EKANS, 3], [:MEOWTH, 6]]
    },
:ARENA_TRAINER_TEAMROCKET_M_6 => {
      :name => "Franco", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:HOUNDOUR, 11], [:GRIMER, 13], [:MACHOP, 13], [:VOLTORB, 14], [:VULPIX, 16]]
    },
:ARENA_TRAINER_TEAMROCKET_M_7 => {
      :name => "Nino", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:MAGBY, 19], [:ELEKID, 20], [:LARVITAR, 20]]
    },
:ARENA_TRAINER_TEAMROCKET_M_8 => {
      :name => "Mikey", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ONIX, 12], [:TAUROS, 15]]
    },
:ARENA_TRAINER_TEAMROCKET_M_9 => {
      :name => "Igor", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:VENONAT, 13], [:GROWLITHE, 13], [:HOUNDOUR, 15], [:PINSIR, 18], [:RATTATA, 20]]
    },
:ARENA_TRAINER_TEAMROCKET_M_10 => {
      :name => "Sal", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:MISDREAVUS, 10], [:CUBONE, 11], [:KOFFING, 19], [:MANKEY, 19]]
    },
:ARENA_TRAINER_TEAMROCKET_M_11 => {
      :name => "Dimitri", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:EXEGGCUTE, 21], [:MACHOP, 22], [:PORYGON2, 25], [:MAGBY, 28], [:HITMONCHAN, 29]]
    },
:ARENA_TRAINER_TEAMROCKET_M_12 => {
      :name => "Raffaele", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:RATICATE, 28]]
    },
:ARENA_TRAINER_TEAMROCKET_M_13 => {
      :name => "Ignazio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:GYARADOS, 20], [:WOBBUFFET, 25]]
    },
:ARENA_TRAINER_TEAMROCKET_M_14 => {
      :name => "Fabrizio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:GRAVELER, 25]]
    },
:ARENA_TRAINER_TEAMROCKET_M_15 => {
      :name => "Sonny", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:MISDREAVUS, 25]]
    },
:ARENA_TRAINER_TEAMROCKET_M_16 => {
      :name => "Frankie", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:VULPIX, 30], [:NINETALES, 32], [:WEAVILE, 35], [:GRAVELER, 40]]
    },
:ARENA_TRAINER_TEAMROCKET_M_17 => {
      :name => "Boris", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:MAGMAR, 30], [:KOFFING, 34], [:GYARADOS, 37], [:PINSIR, 38], [:TAUROS, 39]]
    },
:ARENA_TRAINER_TEAMROCKET_M_18 => {
      :name => "Emilio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:QWILFISH, 37]]
    },
:ARENA_TRAINER_TEAMROCKET_M_19 => {
      :name => "Yuri", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ELECTRODE, 31], [:SLOWPOKE, 36], [:HONCHKROW, 38], [:UMBREON, 40], [:SCYTHER, 40], [:ARBOK, 40]]
    },
:ARENA_TRAINER_TEAMROCKET_M_20 => {
      :name => "Mario", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ONIX, 30], [:SKARMORY, 33], [:GOLBAT, 36], [:DUGTRIO, 36]]
    },
:ARENA_TRAINER_TEAMROCKET_M_21 => {
      :name => "Vladimir", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:PORYGON2, 43], [:MAGMAR, 46], [:DUGTRIO, 48], [:SLOWBRO, 49]]
    },
:ARENA_TRAINER_TEAMROCKET_M_22 => {
      :name => "Sandro", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SLOWBRO, 43], [:HITMONLEE, 45], [:MACHOKE, 45]]
    },
:ARENA_TRAINER_TEAMROCKET_M_23 => {
      :name => "Bruno", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ARCANINE, 41], [:ELECTABUZZ, 41], [:ARBOK, 46], [:MAGMAR, 49], [:STEELIX, 50]]
    },
:ARENA_TRAINER_TEAMROCKET_M_24 => {
      :name => "Viktor", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:TAUROS, 42], [:NINETALES, 46], [:MUK, 50]]
    },
:ARENA_TRAINER_TEAMROCKET_M_25 => {
      :name => "Ivan", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:WOBBUFFET, 42], [:DUGTRIO, 43], [:SANDSLASH, 47], [:ELECTABUZZ, 47], [:SKARMORY, 47], [:EXEGGUTOR, 48]]
    },
:ARENA_TRAINER_TEAMROCKET_M_26 => {
      :name => "Alfonso", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:NINETALES, 52], [:PRIMEAPE, 52], [:MISMAGIUS, 53], [:SNEASEL, 53], [:GOLEM, 55], [:TENTACRUEL, 55]]
    },
:ARENA_TRAINER_TEAMROCKET_M_27 => {
      :name => "Rocco", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:RHYDON, 51], [:GLISCOR, 51], [:SNEASEL, 56], [:UMBREON, 60]]
    },
:ARENA_TRAINER_TEAMROCKET_M_28 => {
      :name => "Vinnie", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:GOLEM, 50], [:WEEZING, 52], [:PINSIR, 53], [:STEELIX, 59]]
    },
:ARENA_TRAINER_TEAMROCKET_M_29 => {
      :name => "Pasquale", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SKARMORY, 53], [:PUPITAR, 55]]
    },
:ARENA_TRAINER_TEAMROCKET_M_30 => {
      :name => "Furio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SNEASEL, 58]]
    },
:ARENA_TRAINER_TEAMROCKET_M_31 => {
      :name => "Fredo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:DRAGONITE, 68]]
    },
:ARENA_TRAINER_TEAMROCKET_M_32 => {
      :name => "Angelo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:HYPNO, 63], [:MAROWAK, 69]]
    },
:ARENA_TRAINER_TEAMROCKET_M_33 => {
      :name => "Domenico", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:QWILFISH, 61], [:PINSIR, 62], [:PORYGON, 62], [:GOLEM, 63], [:STEELIX, 65]]
    },
:ARENA_TRAINER_TEAMROCKET_M_34 => {
      :name => "Salvatore", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SKARMORY, 60], [:CROBAT, 70]]
    },
:ARENA_TRAINER_TEAMROCKET_M_35 => {
      :name => "Corrado", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:HYPNO, 63], [:MUK, 64], [:WOBBUFFET, 68]]
    },
:ARENA_TRAINER_TEAMROCKET_M_36 => {
      :name => "Vincenzo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:MAROWAK, 78], [:HOUNDOOM, 79], [:SLOWBRO, 80]]
    },
:ARENA_TRAINER_TEAMROCKET_M_37 => {
      :name => "Orazio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:RATICATE, 74], [:HITMONLEE, 77]]
    },
:ARENA_TRAINER_TEAMROCKET_M_38 => {
      :name => "Lenny", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ESPEON, 70], [:HOUNDOOM, 72], [:ARCANINE, 73], [:GENGAR, 73], [:PORYGON, 75], [:TYRANITAR, 80]]
    },
:ARENA_TRAINER_TEAMROCKET_M_39 => {
      :name => "Rinaldo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:SLOWBRO, 74], [:TENTACRUEL, 74], [:MAGMAR, 75], [:ARCANINE, 76], [:ELECTABUZZ, 79]]
    },
:ARENA_TRAINER_TEAMROCKET_M_40 => {
      :name => "Michele", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:GOLEM, 72], [:PORYGON2, 73], [:PERSIAN, 78]]
    },
:ARENA_TRAINER_TEAMROCKET_M_41 => {
      :name => "Ettore", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:UMBREON, 80], [:HYPNO, 83], [:EXEGGUTOR, 83], [:PERSIAN, 87]]
    },
:ARENA_TRAINER_TEAMROCKET_M_42 => {
      :name => "Marcello", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:DUGTRIO, 80], [:MAROWAK, 86], [:NINETALES, 86], [:RATICATE, 90]]
    },
:ARENA_TRAINER_TEAMROCKET_M_43 => {
      :name => "Paulie", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:ELECTABUZZ, 81], [:NINETALES, 83], [:MUK, 86], [:MAROWAK, 89]]
    },
:ARENA_TRAINER_TEAMROCKET_M_44 => {
      :name => "Ottavio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:PRIMEAPE, 83], [:GENGAR, 84], [:GOLEM, 84], [:KANGASKHAN, 85], [:HITMONLEE, 90]]
    },
:ARENA_TRAINER_TEAMROCKET_M_45 => {
      :name => "Vito", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:DRAGONITE, 81], [:WOBBUFFET, 86], [:CROBAT, 87]]
    },
:ARENA_TRAINER_TEAMROCKET_M_46 => {
      :name => "Silvio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:PRIMEAPE, 95]]
    },
:ARENA_TRAINER_TEAMROCKET_M_47 => {
      :name => "Sergei", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:DUGTRIO, 95]]
    },
:ARENA_TRAINER_TEAMROCKET_M_48 => {
      :name => "Antonio", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:QWILFISH, 91], [:TYRANITAR, 95], [:PORYGON2, 96], [:PINSIR, 97], [:MISMAGIUS, 97]]
    },
:ARENA_TRAINER_TEAMROCKET_M_49 => {
      :name => "Carmine", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:HITMONCHAN, 92], [:EXEGGUTOR, 93], [:SLOWBRO, 97]]
    },
:ARENA_TRAINER_TEAMROCKET_M_50 => {
      :name => "Carlo", :sprite => "trainer_TEAMROCKET_M", :type => :TEAMROCKET_M,
      :team => [[:PINSIR, 90], [:UMBREON, 90], [:PORYGON2, 91], [:HOUNDOOM, 95], [:MACHAMP, 96], [:EXEGGUTOR, 99]]
    },
:ARENA_TRAINER_TUBER_M_1 => {
      :name => "Léo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:MAGIKARP, 5], [:TENTACOOL, 4]]
    },
:ARENA_TRAINER_TUBER_M_2 => {
      :name => "Arthur", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CORPHISH, 2], [:TOTODILE, 3], [:BUIZEL, 5], [:MANTYKE, 9]]
    },
:ARENA_TRAINER_TUBER_M_3 => {
      :name => "Mattéo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:OSHAWOTT, 7], [:REMORAID, 9]]
    },
:ARENA_TRAINER_TUBER_M_4 => {
      :name => "Valentin", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CARVANHA, 2], [:SEEL, 3], [:WINGULL, 6]]
    },
:ARENA_TRAINER_TUBER_M_5 => {
      :name => "Enzo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SLOWPOKE, 6]]
    },
:ARENA_TRAINER_TUBER_M_6 => {
      :name => "Nathan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:REMORAID, 10], [:MARSHTOMP, 17]]
    },
:ARENA_TRAINER_TUBER_M_7 => {
      :name => "Kylian", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SQUIRTLE, 10], [:SPHEAL, 10], [:OSHAWOTT, 14], [:MAGIKARP, 15], [:FEEBAS, 17], [:CHINCHOU, 18]]
    },
:ARENA_TRAINER_TUBER_M_8 => {
      :name => "Raphaël", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CARVANHA, 17], [:DEWOTT, 20], [:CHINCHOU, 20]]
    },
:ARENA_TRAINER_TUBER_M_9 => {
      :name => "Tanguy", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:BUIZEL, 10], [:QWILFISH, 12], [:MARILL, 13], [:SEEL, 13], [:CARVANHA, 15], [:RELICANTH, 19]]
    },
:ARENA_TRAINER_TUBER_M_10 => {
      :name => "Théo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:TIRTOUGA, 15], [:CROCONAW, 19], [:WAILMER, 20]]
    },
:ARENA_TRAINER_TUBER_M_11 => {
      :name => "Ethan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:TIRTOUGA, 20], [:LUVDISC, 21], [:WAILMER, 21], [:VAPOREON, 22], [:CARVANHA, 27], [:SHELLOS, 30]]
    },
:ARENA_TRAINER_TUBER_M_12 => {
      :name => "Bastien", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:FEEBAS, 22], [:FINNEON, 30]]
    },
:ARENA_TRAINER_TUBER_M_13 => {
      :name => "Victor", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:REMORAID, 21], [:RELICANTH, 28]]
    },
:ARENA_TRAINER_TUBER_M_14 => {
      :name => "Yanis", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:FEEBAS, 20], [:CHINCHOU, 27], [:PELIPPER, 30], [:HUNTAIL, 30]]
    },
:ARENA_TRAINER_TUBER_M_15 => {
      :name => "Clément", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:RELICANTH, 23], [:CLAMPERL, 25], [:LUVDISC, 27]]
    },
:ARENA_TRAINER_TUBER_M_16 => {
      :name => "Timéo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SEALEO, 37], [:GYARADOS, 38], [:LAPRAS, 39], [:SHARPEDO, 40]]
    },
:ARENA_TRAINER_TUBER_M_17 => {
      :name => "Yann", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:LUVDISC, 35], [:SWAMPERT, 39]]
    },
:ARENA_TRAINER_TUBER_M_18 => {
      :name => "Lenny", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:PRINPLUP, 30], [:HORSEA, 30], [:AZUMARILL, 31], [:MANTINE, 34], [:CRAWDAUNT, 35], [:CLOYSTER, 39]]
    },
:ARENA_TRAINER_TUBER_M_19 => {
      :name => "Ilan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:ALOMOMOLA, 30], [:PELIPPER, 30], [:MARSHTOMP, 30], [:WAILMER, 36], [:EMPOLEON, 36], [:SAMUROTT, 37]]
    },
:ARENA_TRAINER_TUBER_M_20 => {
      :name => "Antoine", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:LUMINEON, 32], [:SEADRA, 33], [:AZUMARILL, 37], [:FLOATZEL, 39], [:CRAWDAUNT, 40]]
    },
:ARENA_TRAINER_TUBER_M_21 => {
      :name => "Gabriel", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:VAPOREON, 43], [:STARMIE, 43], [:LUMINEON, 46], [:DEWGONG, 47], [:GASTRODON, 49]]
    },
:ARENA_TRAINER_TUBER_M_22 => {
      :name => "Eliott", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:HUNTAIL, 41], [:TENTACRUEL, 47]]
    },
:ARENA_TRAINER_TUBER_M_23 => {
      :name => "Briac", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:FRILLISH, 40], [:FLOATZEL, 40], [:KINGDRA, 50]]
    },
:ARENA_TRAINER_TUBER_M_24 => {
      :name => "Erwan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:MILOTIC, 41], [:JELLICENT, 42], [:CLOYSTER, 42], [:SAMUROTT, 49]]
    },
:ARENA_TRAINER_TUBER_M_25 => {
      :name => "Jules", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:ALOMOMOLA, 42], [:QWILFISH, 45]]
    },
:ARENA_TRAINER_TUBER_M_26 => {
      :name => "Nolan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:HUNTAIL, 59]]
    },
:ARENA_TRAINER_TUBER_M_27 => {
      :name => "Noé", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:WAILORD, 51], [:RELICANTH, 55], [:CORSOLA, 56], [:BLASTOISE, 56], [:FERALIGATR, 59], [:KINGLER, 59]]
    },
:ARENA_TRAINER_TUBER_M_28 => {
      :name => "Mathis", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:QWILFISH, 52], [:KINGDRA, 54], [:EMPOLEON, 55], [:SEADRA, 55], [:WALREIN, 60], [:GASTRODON, 60]]
    },
:ARENA_TRAINER_TUBER_M_29 => {
      :name => "Évan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:WAILORD, 51], [:AZUMARILL, 51], [:CRAWDAUNT, 53], [:GOREBYSS, 56]]
    },
:ARENA_TRAINER_TUBER_M_30 => {
      :name => "Titouan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:PELIPPER, 56]]
    },
:ARENA_TRAINER_TUBER_M_31 => {
      :name => "Armel", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:MILOTIC, 65], [:STARMIE, 65], [:KINGDRA, 66], [:GASTRODON, 69]]
    },
:ARENA_TRAINER_TUBER_M_32 => {
      :name => "Anthony", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:QWILFISH, 62], [:CORSOLA, 67], [:DEWGONG, 69]]
    },
:ARENA_TRAINER_TUBER_M_33 => {
      :name => "Kerian", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SEADRA, 65]]
    },
:ARENA_TRAINER_TUBER_M_34 => {
      :name => "Hugo", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:BLASTOISE, 65]]
    },
:ARENA_TRAINER_TUBER_M_35 => {
      :name => "Louis", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:STARMIE, 60], [:MILOTIC, 62], [:LUVDISC, 66], [:GASTRODON, 66], [:PELIPPER, 67], [:SEAKING, 67]]
    },
:ARENA_TRAINER_TUBER_M_36 => {
      :name => "Lucas", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CLOYSTER, 70], [:LAPRAS, 71], [:HUNTAIL, 74], [:BLASTOISE, 76], [:SEAKING, 79]]
    },
:ARENA_TRAINER_TUBER_M_37 => {
      :name => "Ronan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:LANTURN, 70], [:HUNTAIL, 71], [:BLASTOISE, 74], [:SEADRA, 80]]
    },
:ARENA_TRAINER_TUBER_M_38 => {
      :name => "Noah", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:ALOMOMOLA, 78]]
    },
:ARENA_TRAINER_TUBER_M_39 => {
      :name => "Axel", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:AZUMARILL, 70], [:TENTACRUEL, 72], [:GASTRODON, 73], [:LUMINEON, 74], [:GYARADOS, 79], [:RELICANTH, 80]]
    },
:ARENA_TRAINER_TUBER_M_40 => {
      :name => "Paul", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:GASTRODON, 73], [:LUMINEON, 74], [:JELLICENT, 76], [:KINGDRA, 77]]
    },
:ARENA_TRAINER_TUBER_M_41 => {
      :name => "Romain", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:LUMINEON, 81], [:SEAKING, 83], [:STARMIE, 84], [:OCTILLERY, 86], [:DEWGONG, 86], [:CARRACOSTA, 90]]
    },
:ARENA_TRAINER_TUBER_M_42 => {
      :name => "Sacha", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SEAKING, 86]]
    },
:ARENA_TRAINER_TUBER_M_43 => {
      :name => "Corentin", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:LAPRAS, 80], [:OCTILLERY, 85]]
    },
:ARENA_TRAINER_TUBER_M_44 => {
      :name => "Baptiste", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CLOYSTER, 87]]
    },
:ARENA_TRAINER_TUBER_M_45 => {
      :name => "Loïc", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SWAMPERT, 82], [:QWILFISH, 85]]
    },
:ARENA_TRAINER_TUBER_M_46 => {
      :name => "Gaël", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:GYARADOS, 90], [:FERALIGATR, 94], [:KINGLER, 98]]
    },
:ARENA_TRAINER_TUBER_M_47 => {
      :name => "Rayan", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SWAMPERT, 91], [:RELICANTH, 92], [:VAPOREON, 95], [:CRAWDAUNT, 95], [:GYARADOS, 96]]
    },
:ARENA_TRAINER_TUBER_M_48 => {
      :name => "Marin", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:SAMUROTT, 90], [:SEADRA, 96], [:KINGDRA, 97], [:JELLICENT, 98]]
    },
:ARENA_TRAINER_TUBER_M_49 => {
      :name => "Tiago", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:CORSOLA, 90], [:STARMIE, 95]]
    },
:ARENA_TRAINER_TUBER_M_50 => {
      :name => "Liam", :sprite => "trainer_TUBER_M", :type => :TUBER_M,
      :team => [[:TENTACRUEL, 91], [:OCTILLERY, 91], [:WAILORD, 94], [:SEAKING, 97]]
    },
:ARENA_TRAINER_TUBER_F_1 => {
      :name => "Sasha", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:MAGIKARP, 2], [:MUDKIP, 3], [:SPHEAL, 7], [:FRILLISH, 8], [:PSYDUCK, 10]]
    },
:ARENA_TRAINER_TUBER_F_2 => {
      :name => "Maya", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:BUIZEL, 5], [:CARVANHA, 5], [:MAGIKARP, 10]]
    },
:ARENA_TRAINER_TUBER_F_3 => {
      :name => "Salomé", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:AZURILL, 7], [:MUDKIP, 8]]
    },
:ARENA_TRAINER_TUBER_F_4 => {
      :name => "Chloé", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:POLIWAG, 2], [:CHINCHOU, 6], [:CARVANHA, 9]]
    },
:ARENA_TRAINER_TUBER_F_5 => {
      :name => "Suzanne", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LOTAD, 3], [:WAILMER, 3], [:GOLDEEN, 5], [:HORSEA, 8]]
    },
:ARENA_TRAINER_TUBER_F_6 => {
      :name => "Clémence", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:HORSEA, 17], [:CLAMPERL, 17], [:PSYDUCK, 18], [:WAILMER, 19], [:FEEBAS, 19], [:SHELLOS, 19]]
    },
:ARENA_TRAINER_TUBER_F_7 => {
      :name => "Manon", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LUVDISC, 10], [:FRILLISH, 17], [:CLAMPERL, 18], [:QWILFISH, 19]]
    },
:ARENA_TRAINER_TUBER_F_8 => {
      :name => "Ninon", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:CORPHISH, 15], [:FRILLISH, 17], [:FEEBAS, 18]]
    },
:ARENA_TRAINER_TUBER_F_9 => {
      :name => "Lou", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:CHINCHOU, 11], [:HORSEA, 20]]
    },
:ARENA_TRAINER_TUBER_F_10 => {
      :name => "Rose", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:FEEBAS, 15]]
    },
:ARENA_TRAINER_TUBER_F_11 => {
      :name => "Armelle", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:TENTACOOL, 21], [:AZUMARILL, 25], [:LAPRAS, 26], [:PRINPLUP, 27], [:PSYDUCK, 29]]
    },
:ARENA_TRAINER_TUBER_F_12 => {
      :name => "Ella", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SEEL, 25], [:ALOMOMOLA, 28], [:AZUMARILL, 29], [:CARVANHA, 29]]
    },
:ARENA_TRAINER_TUBER_F_13 => {
      :name => "Apolline", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:WAILMER, 20], [:LUVDISC, 24], [:FEEBAS, 25], [:PELIPPER, 28], [:STARMIE, 28], [:FINNEON, 30]]
    },
:ARENA_TRAINER_TUBER_F_14 => {
      :name => "Louise", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:CORPHISH, 23], [:KRABBY, 25]]
    },
:ARENA_TRAINER_TUBER_F_15 => {
      :name => "Livia", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LUVDISC, 22], [:CROCONAW, 26], [:PRINPLUP, 29], [:VAPOREON, 30]]
    },
:ARENA_TRAINER_TUBER_F_16 => {
      :name => "Zoé", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:HUNTAIL, 32], [:PELIPPER, 36], [:SEADRA, 37], [:CARRACOSTA, 38]]
    },
:ARENA_TRAINER_TUBER_F_17 => {
      :name => "Nolwenn", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:GASTRODON, 35]]
    },
:ARENA_TRAINER_TUBER_F_18 => {
      :name => "Jeanne", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:CRAWDAUNT, 30], [:RELICANTH, 32], [:LUVDISC, 33], [:LAPRAS, 35]]
    },
:ARENA_TRAINER_TUBER_F_19 => {
      :name => "Thaïs", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:HUNTAIL, 35]]
    },
:ARENA_TRAINER_TUBER_F_20 => {
      :name => "Margaux", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LANTURN, 31], [:QWILFISH, 35]]
    },
:ARENA_TRAINER_TUBER_F_21 => {
      :name => "Mélia", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SHARPEDO, 41], [:STARMIE, 46], [:LANTURN, 49]]
    },
:ARENA_TRAINER_TUBER_F_22 => {
      :name => "Océane", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:ALOMOMOLA, 40], [:LUMINEON, 43], [:SEAKING, 44], [:SAMUROTT, 47], [:KINGDRA, 48], [:WALREIN, 49]]
    },
:ARENA_TRAINER_TUBER_F_23 => {
      :name => "Noémie", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:RELICANTH, 43], [:PELIPPER, 48], [:BLASTOISE, 50]]
    },
:ARENA_TRAINER_TUBER_F_24 => {
      :name => "Lucie", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:BLASTOISE, 41], [:MANTINE, 41], [:SEADRA, 44], [:KINGLER, 46]]
    },
:ARENA_TRAINER_TUBER_F_25 => {
      :name => "Mila", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SEALEO, 40], [:LANTURN, 42], [:SHARPEDO, 43], [:WAILORD, 49]]
    },
:ARENA_TRAINER_TUBER_F_26 => {
      :name => "Romane", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:JELLICENT, 51], [:KINGDRA, 52], [:VAPOREON, 54], [:AZUMARILL, 57], [:WALREIN, 58]]
    },
:ARENA_TRAINER_TUBER_F_27 => {
      :name => "Eden", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:GYARADOS, 50], [:CARRACOSTA, 51], [:FERALIGATR, 55]]
    },
:ARENA_TRAINER_TUBER_F_28 => {
      :name => "Léonie", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:EMPOLEON, 54], [:KINGDRA, 55]]
    },
:ARENA_TRAINER_TUBER_F_29 => {
      :name => "Iris", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:RELICANTH, 59], [:FERALIGATR, 60]]
    },
:ARENA_TRAINER_TUBER_F_30 => {
      :name => "Agathe", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:JELLICENT, 52], [:RELICANTH, 54], [:LANTURN, 57], [:SWAMPERT, 58]]
    },
:ARENA_TRAINER_TUBER_F_31 => {
      :name => "Tess", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:GOREBYSS, 60], [:GASTRODON, 61], [:LAPRAS, 66]]
    },
:ARENA_TRAINER_TUBER_F_32 => {
      :name => "Faustine", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LANTURN, 61], [:FLOATZEL, 62], [:HUNTAIL, 68], [:GOREBYSS, 70]]
    },
:ARENA_TRAINER_TUBER_F_33 => {
      :name => "Lina", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SWAMPERT, 61], [:SEAKING, 62], [:SHARPEDO, 62], [:FLOATZEL, 63], [:KINGDRA, 68]]
    },
:ARENA_TRAINER_TUBER_F_34 => {
      :name => "Morgane", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SWAMPERT, 68]]
    },
:ARENA_TRAINER_TUBER_F_35 => {
      :name => "Victoire", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:PELIPPER, 60], [:TENTACRUEL, 65], [:SEAKING, 68]]
    },
:ARENA_TRAINER_TUBER_F_36 => {
      :name => "Capucine", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:KINGDRA, 71], [:GASTRODON, 74], [:CLOYSTER, 75]]
    },
:ARENA_TRAINER_TUBER_F_37 => {
      :name => "Ambre", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:JELLICENT, 76]]
    },
:ARENA_TRAINER_TUBER_F_38 => {
      :name => "Camille", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:CLOYSTER, 75]]
    },
:ARENA_TRAINER_TUBER_F_39 => {
      :name => "Elsa", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SWAMPERT, 71], [:SAMUROTT, 72], [:VAPOREON, 78], [:LANTURN, 78], [:GOREBYSS, 79]]
    },
:ARENA_TRAINER_TUBER_F_40 => {
      :name => "Maëlys", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:FLOATZEL, 70], [:SWAMPERT, 70], [:RELICANTH, 71], [:EMPOLEON, 76], [:QWILFISH, 77], [:OCTILLERY, 79]]
    },
:ARENA_TRAINER_TUBER_F_41 => {
      :name => "Sofia", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:BLASTOISE, 83], [:SEADRA, 84], [:WALREIN, 85]]
    },
:ARENA_TRAINER_TUBER_F_42 => {
      :name => "Inès", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SEAKING, 80], [:SEADRA, 85]]
    },
:ARENA_TRAINER_TUBER_F_43 => {
      :name => "Juliette", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:SWAMPERT, 80], [:FERALIGATR, 80], [:DEWGONG, 81], [:SEADRA, 85], [:SAMUROTT, 86], [:AZUMARILL, 88]]
    },
:ARENA_TRAINER_TUBER_F_44 => {
      :name => "Lyna", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:WALREIN, 85]]
    },
:ARENA_TRAINER_TUBER_F_45 => {
      :name => "Maïwenn", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:WALREIN, 83], [:ALOMOMOLA, 85]]
    },
:ARENA_TRAINER_TUBER_F_46 => {
      :name => "Maëlle", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:GYARADOS, 90], [:SEADRA, 90], [:LANTURN, 91], [:STARMIE, 92], [:TENTACRUEL, 92], [:CORSOLA, 97]]
    },
:ARENA_TRAINER_TUBER_F_47 => {
      :name => "Gaëlle", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:WAILORD, 93], [:LAPRAS, 96], [:SHARPEDO, 98], [:JELLICENT, 98]]
    },
:ARENA_TRAINER_TUBER_F_48 => {
      :name => "Gaïa", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:EMPOLEON, 90], [:KINGDRA, 92], [:SAMUROTT, 92], [:KINGLER, 97], [:SEADRA, 97], [:WALREIN, 100]]
    },
:ARENA_TRAINER_TUBER_F_49 => {
      :name => "Jade", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LAPRAS, 93], [:PELIPPER, 94], [:LANTURN, 97], [:EMPOLEON, 98], [:CLOYSTER, 98], [:TENTACRUEL, 99]]
    },
:ARENA_TRAINER_TUBER_F_50 => {
      :name => "Lison", :sprite => "trainer_TUBER_F", :type => :TUBER_F,
      :team => [[:LAPRAS, 90], [:CORSOLA, 91], [:DEWGONG, 92], [:MANTINE, 98]]
    },
:ARENA_TRAINER_YOUNGSTER_1 => {
      :name => "Ezzio", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:RATTATA, 5], [:PIDGEY, 4]]
    },
:ARENA_TRAINER_YOUNGSTER_2 => {
      :name => "Sam", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PURRLOIN, 3], [:PIDOVE, 4], [:DROWZEE, 4], [:EEVEE, 5], [:COMBEE, 7]]
    },
:ARENA_TRAINER_YOUNGSTER_3 => {
      :name => "Marco", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PACHIRISU, 8], [:SEWADDLE, 8]]
    },
:ARENA_TRAINER_YOUNGSTER_4 => {
      :name => "Mathis", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:MAREEP, 8], [:EEVEE, 10]]
    },
:ARENA_TRAINER_YOUNGSTER_5 => {
      :name => "Mattéo", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PIDGEY, 6], [:POOCHYENA, 6]]
    },
:ARENA_TRAINER_YOUNGSTER_6 => {
      :name => "Lenny", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:SURSKIT, 10], [:SENTRET, 11], [:CHERUBI, 12], [:LUXIO, 15], [:BUTTERFREE, 19]]
    },
:ARENA_TRAINER_YOUNGSTER_7 => {
      :name => "Ethan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BUDEW, 12], [:BUIZEL, 13], [:GEODUDE, 15], [:CASCOON, 17], [:PURRLOIN, 19]]
    },
:ARENA_TRAINER_YOUNGSTER_8 => {
      :name => "Tiago", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:KAKUNA, 11], [:WEEDLE, 12], [:SURSKIT, 15], [:BEEDRILL, 18], [:BUNEARY, 18], [:LEDYBA, 18]]
    },
:ARENA_TRAINER_YOUNGSTER_9 => {
      :name => "Anthony", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BUDEW, 10], [:PATRAT, 19], [:SHROOMISH, 20]]
    },
:ARENA_TRAINER_YOUNGSTER_10 => {
      :name => "Maxime", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:DRILBUR, 14], [:KAKUNA, 15], [:COMBEE, 16], [:SKITTY, 20]]
    },
:ARENA_TRAINER_YOUNGSTER_11 => {
      :name => "Romain", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BUIZEL, 24], [:PIKACHU, 27], [:BEAUTIFLY, 30]]
    },
:ARENA_TRAINER_YOUNGSTER_12 => {
      :name => "Erwan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:SANDSHREW, 21], [:BIBAREL, 25], [:DUSTOX, 26], [:PERSIAN, 29], [:PIKACHU, 29]]
    },
:ARENA_TRAINER_YOUNGSTER_13 => {
      :name => "Nathan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:TIMBURR, 25], [:BEEDRILL, 26], [:BIBAREL, 26], [:SWELLOW, 29], [:SANDSLASH, 30], [:PERSIAN, 30]]
    },
:ARENA_TRAINER_YOUNGSTER_14 => {
      :name => "Ronny", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:FEAROW, 21], [:BLITZLE, 24], [:NOCTOWL, 29]]
    },
:ARENA_TRAINER_YOUNGSTER_15 => {
      :name => "Clément", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:FURRET, 29], [:DRILBUR, 30]]
    },
:ARENA_TRAINER_YOUNGSTER_16 => {
      :name => "Yanis", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:STARAVIA, 35], [:NINJASK, 36], [:PIDGEOTTO, 36]]
    },
:ARENA_TRAINER_YOUNGSTER_17 => {
      :name => "Sacha", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BEEDRILL, 30], [:ARIADOS, 32], [:EEVEE, 32], [:LINOONE, 35], [:STARAPTOR, 35], [:BUTTERFREE, 35]]
    },
:ARENA_TRAINER_YOUNGSTER_18 => {
      :name => "Timmy", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BIBAREL, 31], [:PACHIRISU, 33], [:NOCTOWL, 34], [:BUTTERFREE, 38]]
    },
:ARENA_TRAINER_YOUNGSTER_19 => {
      :name => "Antoine", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:NINJASK, 30], [:BEAUTIFLY, 34], [:SANDSLASH, 37], [:TRANQUILL, 39]]
    },
:ARENA_TRAINER_YOUNGSTER_20 => {
      :name => "Raphaël", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:RATICATE, 31], [:ARIADOS, 32], [:PIKACHU, 34], [:DUGTRIO, 34], [:BEAUTIFLY, 35]]
    },
:ARENA_TRAINER_YOUNGSTER_21 => {
      :name => "Adam", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BUTTERFREE, 40], [:PACHIRISU, 41], [:DUGTRIO, 42], [:WATCHOG, 45], [:KRICKETUNE, 50]]
    },
:ARENA_TRAINER_YOUNGSTER_22 => {
      :name => "Mathéo", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:EEVEE, 43], [:GYARADOS, 49], [:BUTTERFREE, 50]]
    },
:ARENA_TRAINER_YOUNGSTER_23 => {
      :name => "Danny", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:ARIADOS, 45]]
    },
:ARENA_TRAINER_YOUNGSTER_24 => {
      :name => "Tommy", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BUTTERFREE, 42], [:SWELLOW, 46], [:NOCTOWL, 46], [:RATICATE, 47], [:PIKACHU, 48]]
    },
:ARENA_TRAINER_YOUNGSTER_25 => {
      :name => "Valentin", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PERSIAN, 41], [:BUTTERFREE, 46], [:EEVEE, 47], [:ARIADOS, 48], [:PRIMEAPE, 48]]
    },
:ARENA_TRAINER_YOUNGSTER_26 => {
      :name => "Tim", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:LEDIAN, 54], [:SWELLOW, 56], [:STARAPTOR, 57], [:SANDSLASH, 57]]
    },
:ARENA_TRAINER_YOUNGSTER_27 => {
      :name => "Jules", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:NOCTOWL, 51], [:RATICATE, 53], [:BIBAREL, 54], [:MIGHTYENA, 56]]
    },
:ARENA_TRAINER_YOUNGSTER_28 => {
      :name => "Gabriel", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PERSIAN, 51], [:DUSTOX, 55], [:FURRET, 56], [:MIGHTYENA, 57], [:KRICKETUNE, 59]]
    },
:ARENA_TRAINER_YOUNGSTER_29 => {
      :name => "Bobby", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BEAUTIFLY, 51], [:BUTTERFREE, 52], [:STARAPTOR, 52], [:FURRET, 54], [:RATICATE, 55], [:PIDGEOT, 59]]
    },
:ARENA_TRAINER_YOUNGSTER_30 => {
      :name => "Louis", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BIBAREL, 50], [:DUSTOX, 50], [:MIGHTYENA, 58], [:KRICKETUNE, 60]]
    },
:ARENA_TRAINER_YOUNGSTER_31 => {
      :name => "Lucas", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:STARAPTOR, 63], [:FURRET, 64], [:SANDSLASH, 67], [:PIKACHU, 67], [:PRIMEAPE, 70]]
    },
:ARENA_TRAINER_YOUNGSTER_32 => {
      :name => "Tanguy", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:LUXRAY, 60], [:PIKACHU, 62], [:RATICATE, 66], [:WATCHOG, 69], [:BIBAREL, 69]]
    },
:ARENA_TRAINER_YOUNGSTER_33 => {
      :name => "Kévin", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PRIMEAPE, 62], [:BIBAREL, 68]]
    },
:ARENA_TRAINER_YOUNGSTER_34 => {
      :name => "Gaël", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:DUSTOX, 61], [:PACHIRISU, 63], [:BEAUTIFLY, 64], [:PIKACHU, 70]]
    },
:ARENA_TRAINER_YOUNGSTER_35 => {
      :name => "Ilan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:RATICATE, 65]]
    },
:ARENA_TRAINER_YOUNGSTER_36 => {
      :name => "Max", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:NOCTOWL, 70], [:LINOONE, 72], [:FURRET, 74], [:FEAROW, 80]]
    },
:ARENA_TRAINER_YOUNGSTER_37 => {
      :name => "Corentin", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:LEDIAN, 77]]
    },
:ARENA_TRAINER_YOUNGSTER_38 => {
      :name => "Alex", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:FEAROW, 70], [:BIBAREL, 72], [:WATCHOG, 73], [:NINJASK, 73], [:PERSIAN, 74], [:SWELLOW, 80]]
    },
:ARENA_TRAINER_YOUNGSTER_39 => {
      :name => "Steeve", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:LEDIAN, 71], [:NINJASK, 72], [:PIDGEOT, 73], [:RATICATE, 74], [:BEAUTIFLY, 78]]
    },
:ARENA_TRAINER_YOUNGSTER_40 => {
      :name => "Nolan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PERSIAN, 77], [:LUXRAY, 78], [:SANDSLASH, 79], [:PACHIRISU, 80]]
    },
:ARENA_TRAINER_YOUNGSTER_41 => {
      :name => "Noé", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BIBAREL, 85]]
    },
:ARENA_TRAINER_YOUNGSTER_42 => {
      :name => "Rayan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PRIMEAPE, 82], [:LINOONE, 85]]
    },
:ARENA_TRAINER_YOUNGSTER_43 => {
      :name => "Liam", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:NINJASK, 80], [:SANDSLASH, 81], [:BUTTERFREE, 82], [:LINOONE, 84], [:MIGHTYENA, 85], [:DUGTRIO, 85]]
    },
:ARENA_TRAINER_YOUNGSTER_44 => {
      :name => "Timéo", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:NOCTOWL, 80], [:FEAROW, 89]]
    },
:ARENA_TRAINER_YOUNGSTER_45 => {
      :name => "Jordan", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:ARIADOS, 80], [:LEDIAN, 85], [:RATICATE, 88]]
    },
:ARENA_TRAINER_YOUNGSTER_46 => {
      :name => "Axel", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PIDGEOT, 95]]
    },
:ARENA_TRAINER_YOUNGSTER_47 => {
      :name => "Victor", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:PRIMEAPE, 92], [:FURRET, 97], [:ARIADOS, 100]]
    },
:ARENA_TRAINER_YOUNGSTER_48 => {
      :name => "Bastien", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:SANDSLASH, 98], [:BEAUTIFLY, 99]]
    },
:ARENA_TRAINER_YOUNGSTER_49 => {
      :name => "Arthur", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:BEAUTIFLY, 100]]
    },
:ARENA_TRAINER_YOUNGSTER_50 => {
      :name => "Ben", :sprite => "trainer_YOUNGSTER", :type => :YOUNGSTER,
      :team => [[:FURRET, 91], [:BUTTERFREE, 94], [:LINOONE, 97]]
    },
:ARENA_TRAINER_GOLD => {
      :name => "Gold", :sprite => "trainer_GOLD", :type => :GOLD,
      :team => [[:GYARADOS, 82, true], [:TYPHLOSION, 85], [:TOGEKISS, 83], [:RAIKOU, 87]]
    },
:ARENA_TRAINER_CYNTHIA => {
      :name => "Cynthia", :sprite => "trainer_CYNTHIA", :type => :CYNTHIA,
      :team => [[:SPIRITOMB, 100], [:MILOTIC, 100], [:LUCARIO, 100], [:EELEKTROSS, 100], [:GLACEON, 100], [:GARCHOMP, 100]]
    },
 :ARENA_TRAINER_N => {
      :name => "N", :sprite => "trainer_N", :type => :N,
      :team => [[:ZOROARK, 72], [:RESHIRAM, 75], [:ZEKROM, 75]]
    },
:ARENA_TRAINER_GHETIS => {
      :name => "Ghetis", :sprite => "trainer_GHETIS", :type => :GHETIS,
      :team => [[:COFAGRIGUS, 82], [:SEISMITOAD, 85], [:HYDREIGON, 87], [:KYUREM, 90]]
    },
:ARENA_TRAINER_GOYAH => {
      :name => "Goyah", :sprite => "trainer_GOYAH", :type => :GOYAH,
      :team => [[:ACCELGOR, 51], [:ESCAVALIER, 51], [:DRUDDIGON, 52], [:BOUFFALANT, 54], [:CONKELDURR, 53], [:VOLCARONA, 55]]
    },
:ARENA_TRAINER_GUAJAVA => {
      :name => "Guajava", :sprite => "trainer_GUAJAVA", :type => :GUAJAVA,
      :team => [[:VOLCARONA, 70], [:LATIAS, 72], [:LATIOS, 72]]
    },
:ARENA_TRAINER_IRIS => {
      :name => "Iris", :sprite => "trainer_IRIS", :type => :IRIS,
      :team => [[:AXEW, 60], [:DRUDDIGON, 62], [:HYDREIGON, 64], [:HAXORUS, 67]]
    },
:ARENA_TRAINER_SILVER => {
      :name => "Silver", :sprite => "trainer_SILVER", :type => :SILVER,
      :team => [[:FERALIGATR, 42], [:GENGAR, 40], [:WEAVILE, 44], [:ENTEI, 45]]
    },
:ARENA_TRAINER_CELESTA => {
      :name => "Célesta", :sprite => "trainer_CELESTA", :type => :CELESTA,
      :team => [[:BAYLEEF, 24], [:MARILL, 22], [:GIRAFARIG, 24], [:SUICUNE, 25]]
    },
:ARENA_TRAINER_LOUKA => {
      :name => "Louka", :sprite => "trainer_LOUKA", :type => :LOUKA,
      :team => [[:TURTWIG, 15], [:BIDOOF, 12], [:STARLY, 14], [:ROTOM, 15]]
    },
:ARENA_TRAINER_AURORE => {
      :name => "Aurore", :sprite => "trainer_AURORE", :type => :AURORE,
      :team => [[:PIPLUP, 36], [:LUXRAY, 34], [:STARAVIA, 32], [:BUNEARY, 35]]
    },
:ARENA_TRAINER_MATIS => {
      :name => "Matis", :sprite => "trainer_MATIS", :type => :MATIS,
      :team => [[:PIGNITE, 26], [:TRANQUILL, 22], [:BOUFFALANT, 24], [:SIMIPOUR, 25]]
    },
:ARENA_TRAINER_ARIANE => {
      :name => "Ariane", :sprite => "trainer_ARIANE", :type => :ARIANE,
      :team => [[:ARBOK, 26], [:MURKROW, 23], [:GLOOM, 24]]
    },
:ARENA_TRAINER_APOLLON => {
      :name => "Apollon", :sprite => "trainer_APOLLON", :type => :APOLLON,
      :team => [[:ARBOK, 36], [:KOFFING, 33], [:RATICATE, 34]]
    },
:ARENA_TRAINER_PETROS => {
      :name => "Petros", :sprite => "trainer_PETROS", :type => :PETROS,
      :team => [[:ARBOK, 46], [:MUK, 43], [:GOLBAT, 44]]
    },
:ARENA_TRAINER_LAMBDA => {
      :name => "LAMBDA", :sprite => "trainer_LAMBDA", :type => :LAMBDA,
      :team => [[:EKANS, 16], [:KOFFING, 13], [:RATTATA, 14]]
    },
:ARENA_TRAINER_BIANCA => {
      :name => "BIANCA", :sprite => "trainer_BIANCA", :type => :BIANCA,
      :team => [[:MINCCINO, 16], [:MUNNA, 15]]
    }
  }.freeze

  module_function

  def register_bag_items
    FURNITURE_STOCK.each do |item, data|
      register_custom_bag_item(item, data[0], FURNITURE_POCKET,
                                "Place this furniture in your offline arena.")
    end
    TRAINER_PROFILES.each do |item, profile|
      register_custom_bag_item(item, profile[:name], TRAINER_POCKET,
                               "A trainer recruited to your offline arena.")
    end
  end

  def register_custom_bag_item(id, name, pocket, description)
    return if GameData::Item.exists?(id)
    GameData::Item.register({
      :id => id, :id_number => 9900 + GameData::Item::DATA.length,
      :real_name => name, :real_name_plural => name,
      :real_portion_name => name, :real_portion_name_plural => name,
      :pocket => pocket, :price => 0, :sell_price => 0, :bp_price => 0,
      :field_use => 0, :battle_use => 0, :flags => ["KeyItem"],
      :consumable => false, :show_quantity => true,
      :real_description => description
    })
  end

  def ensure_bag_pockets(bag = $bag, fresh = false)
    return unless bag && bag.respond_to?(:pockets)
    if fresh
      bag.instance_variable_set(:@arena_lab_bag_layout, 2)
    else
      migrate_bag_layout(bag)
    end
    (0..PokemonBag.pocket_count).each do |pocket|
      bag.pockets[pocket] ||= []
    end
    selections = bag.last_pocket_selections
    unless selections.is_a?(Array)
      selections = []
      bag.last_pocket_selections = selections
    end
    (0..PokemonBag.pocket_count).each do |pocket|
      value = selections[pocket]
      selections[pocket] = 0 unless value.is_a?(Integer) && value >= 0
    end
    viewed = bag.last_viewed_pocket
    unless viewed.is_a?(Integer) && viewed.between?(1, PokemonBag.pocket_count)
      bag.last_viewed_pocket = 1
    end
  end

  def migrate_bag_layout(bag)
    return if bag.instance_variable_get(:@arena_lab_bag_layout) == 2
    old = bag.pockets
    old_selections = bag.last_pocket_selections
    old_selections = [] unless old_selections.is_a?(Array)
    # Legacy pockets: 1 Items, 2 Medicine, 3 Balls, 4 TMs, 5 Berries,
    # 6 Mail, 7 Battle Items, 8 Key Items, then the two Arena pockets.
    remap = { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5,
              6 => 1, 7 => 1, 8 => 6, 9 => 7, 10 => 8 }
    migrated = Array.new(9) { [] }
    (1..10).each do |old_pocket|
      target = remap[old_pocket]
      next unless target && old[old_pocket].is_a?(Array)
      old[old_pocket].each do |entry|
        next unless entry.is_a?(Array) && entry.length >= 2
        found = migrated[target].find { |item| item[0] == entry[0] }
        found ? found[1] += entry[1].to_i : migrated[target] << [entry[0], entry[1].to_i]
      end
    end
    migrated[0] = old[0].is_a?(Array) ? old[0] : []
    bag.pockets.replace(migrated)
    selections = Array.new(9, 0)
    (1..5).each { |p| selections[p] = old_selections[p].to_i if old_selections[p].is_a?(Numeric) }
    selections[6] = old_selections[8].to_i if old_selections[8].is_a?(Numeric)
    selections[7] = old_selections[9].to_i if old_selections[9].is_a?(Numeric)
    selections[8] = old_selections[10].to_i if old_selections[10].is_a?(Numeric)
    bag.last_pocket_selections = selections
    viewed = bag.last_viewed_pocket
    bag.last_viewed_pocket = case viewed
                             when 1..5 then viewed
                             when 8 then 6
                             when 9 then 7
                             when 10 then 8
                             else 1
                             end
    bag.instance_variable_set(:@arena_lab_bag_layout, 2)
  end

  def ensure_custom_inventory
    return unless $PokemonGlobal && $bag
    ensure_bag_pockets($bag)
    return if $PokemonGlobal.arena_custom_stock_added
    FURNITURE_STOCK.each do |item, data|
      $bag.add(item, data[2]) unless $bag.has?(item)
    end
    $PokemonGlobal.arena_custom_stock_added = true
  end

  def furniture_placements(placements = custom_placements)
    placements.select { |placement| placement["kind"] == "furniture" }
  end

  def trainer_placements(placements = custom_placements)
    placements.select { |placement| placement["kind"] == "trainer" }
  end

  def custom_placements
    visit = defined?(Visits) && Visits.snapshot
    return visit[:placements] if visit && visit[:placements].is_a?(Array)
    ensure_custom_inventory
    values = $PokemonGlobal.arena_demo_placements
    unless values.is_a?(Array)
      values = []
      $PokemonGlobal.arena_demo_placements = values
    end
    values
  end

  def placement_item(placement)
    placement["item"].to_s.to_sym
  end

  def placement_sprite(placement)
    item = placement_item(placement)
    if placement["kind"] == "furniture"
      data = FURNITURE_STOCK[item]
      return data && data[1]
    end
    profile = TRAINER_PROFILES[item]
    profile && profile[:sprite]
  end

  def tile_edit_key(x, y)
    "#{x},#{y}"
  end

  def tile_edit_records
    visit = defined?(Visits) && Visits.snapshot
    return visit[:tile_edits] if visit && visit[:tile_edits].is_a?(Hash)
    return {} unless $PokemonGlobal
    records = $PokemonGlobal.arena_demo_tile_edits
    unless records.is_a?(Hash)
      records = {}
      $PokemonGlobal.arena_demo_tile_edits = records
    end
    # A broken editor build could persist an entire grid of explicit void
    # tiles. Clear only that unmistakably corrupt state once; normal layouts
    # and deliberate small void edits remain intact.
    unless $PokemonGlobal.arena_demo_void_recovery_version.to_i >= TILE_EDIT_MIGRATION_VERSION
      valid_records = records.count do |key, record|
        coords = key.to_s.split(",")
        record.is_a?(Hash) && coords.length == 2 &&
          coords.all? { |value| value.match?(/\A\d+\z/) } &&
          coords[0].to_i.between?(0, MAP_WIDTH - 1) &&
          coords[1].to_i.between?(0, MAP_HEIGHT - 1)
      end
      void_records = records.count { |_key, record| record.is_a?(Hash) && record["floor"] == "void" }
      if valid_records >= 100 && void_records.to_f / valid_records >= 0.90
        records = {}
        $PokemonGlobal.arena_demo_tile_edits = records
      end
      $PokemonGlobal.arena_demo_void_recovery_version = TILE_EDIT_MIGRATION_VERSION
    end
    records
  end

  def initial_field_tile?(x, y)
    x.is_a?(Integer) && y.is_a?(Integer) &&
      x.between?(INITIAL_FIELD_X, INITIAL_FIELD_X + INITIAL_FIELD_SIZE - 1) &&
      y.between?(INITIAL_FIELD_Y, INITIAL_FIELD_Y + INITIAL_FIELD_SIZE - 1)
  end

  # Saves made before the starting field was centered stored arena contents in
  # the old top-left 25x25 area. Move those contents once, along with a player
  # saved inside the old field, so they remain on walkable ground.
  def migrate_centered_arena_layout
    return unless $PokemonGlobal
    return if defined?(Visits) && Visits.snapshot
    return if $PokemonGlobal.arena_demo_centered_layout_migration_version.to_i >= 3
    dx = INITIAL_FIELD_X
    dy = INITIAL_FIELD_Y
    placements = $PokemonGlobal.arena_demo_placements
    if placements.is_a?(Array)
      placements.each do |placement|
        next unless placement.is_a?(Hash)
        next unless placement["x"].is_a?(Integer) && placement["y"].is_a?(Integer)
        next unless placement["x"].between?(0, INITIAL_FIELD_SIZE - 1) &&
                    placement["y"].between?(0, INITIAL_FIELD_SIZE - 1)
        placement["x"] += dx
        placement["y"] += dy
      end
    end
    records = $PokemonGlobal.arena_demo_tile_edits
    if records.is_a?(Hash)
      moved = records.dup
      records.each do |key, value|
        coords = key.to_s.split(",").map(&:to_i)
        next unless coords.length == 2 && coords[0].between?(0, INITIAL_FIELD_SIZE - 1) &&
                    coords[1].between?(0, INITIAL_FIELD_SIZE - 1)
        target = tile_edit_key(coords[0] + dx, coords[1] + dy)
        moved[target] = value unless moved.key?(target)
        moved.delete(key)
      end
      $PokemonGlobal.arena_demo_tile_edits = moved
    end
    if $game_map && $game_map.map_id == MAP_ID && $game_player &&
       $game_player.x.between?(0, INITIAL_FIELD_SIZE - 1) &&
       $game_player.y.between?(0, INITIAL_FIELD_SIZE - 1)
      $game_player.moveto($game_player.x + dx, $game_player.y + dy)
    end
    $PokemonGlobal.arena_demo_centered_layout_migration_version = 3
  end

  def normalize_fixed_arena_events(map)
    return unless map && map.map_id == MAP_ID
    map.events.each do |id, event|
      next unless id.between?(1, 9)
      next unless event.x.between?(0, INITIAL_FIELD_SIZE - 1) &&
                  event.y.between?(0, INITIAL_FIELD_SIZE - 1)
      event.moveto(event.x + INITIAL_FIELD_X, event.y + INITIAL_FIELD_Y)
    end
  end

  def recover_player_from_void(map)
    return unless map && map.map_id == MAP_ID && $game_player
    return if $PokemonGlobal.respond_to?(:surfing) && $PokemonGlobal.surfing &&
              surf_ground?(tile_edit_records, $game_player.x, $game_player.y) &&
              !relief_wall?(tile_edit_records, $game_player.x, $game_player.y)
    return unless tile_is_void?($game_player.x, $game_player.y) ||
                  !map.passableStrict?($game_player.x, $game_player.y, 0, $game_player)
    start = map_start
    candidates = [[start[0], start[1]]]
    INITIAL_FIELD_SIZE.times do |dy|
      INITIAL_FIELD_SIZE.times do |dx|
        candidates << [INITIAL_FIELD_X + dx, INITIAL_FIELD_Y + dy]
      end
    end
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times { |x| candidates << [x, y] }
    end
    destination = candidates.uniq.find do |x, y|
      !tile_is_void?(x, y) && map.passableStrict?(x, y, 0, $game_player)
    end
    $game_player.moveto(*destination) if destination
  end

  def recover_centered_arena_state(map = $game_map)
    return unless map && map.map_id == MAP_ID
    migrate_centered_arena_layout
    normalize_fixed_arena_events(map)
    apply_tile_edits(map)
    refresh_objects if respond_to?(:refresh_objects)
    recover_player_from_void(map)
    write_floor_map_diagnostic(map)
  end

  # Essentials can load a serialized Game_Map directly when its save magic
  # number matches, bypassing Game_Map#setup. Re-setup Map 100 from the freshly
  # generated Data/Map100.rxdata instead of trying to patch potentially stale
  # serialized Table data in place. Player progression and arena edits live in
  # Game_Player/PokemonGlobal, so retain those and the player's current tile.
  def reload_saved_arena_map_from_data
    return unless $game_map && [MAP_ID, TOWN_MAP_ID, ENTRANCE_MAP_ID].include?($game_map.map_id) && $game_player
    return if instance_variable_get(:@reloading_saved_arena_map)
    instance_variable_set(:@reloading_saved_arena_map, true)
    map = $game_map
    map_id = map.map_id
    position = [$game_player.x, $game_player.y, $game_player.direction]
    reset_saved_player_movement
    map.setup(map_id)
    $game_map = map
    $game_player.moveto(position[0], position[1])
    $game_player.direction = position[2]
    recover_centered_arena_state(map) if map_id == MAP_ID
    $game_player.center($game_player.x, $game_player.y)
    map.autoplay
    write_floor_map_diagnostic(map) if map_id == MAP_ID
  ensure
    instance_variable_set(:@reloading_saved_arena_map, false)
  end

  def reset_saved_player_movement
    # Ice/forced routes are transient. A serialized flag can otherwise keep
    # calling move_forward without input after loading or repositioning.
    [:ice_sliding, :descending_waterfall, :ascending_waterfall].each do |flag|
      $PokemonGlobal.public_send("#{flag}=", false) if $PokemonGlobal.respond_to?("#{flag}=")
    end
    { :move_route_forcing => false, :move_route => nil, :original_move_route => nil,
      :move_route_index => 0, :original_move_route_index => 0,
      :move_timer => nil, :wait_count => 0, :wait_start => nil,
      :jump_count => 0, :jump_distance => 0, :jumping_on_spot => false,
      :through => false, :walk_anime => true, :direction_fix => false }.each do |key, value|
      $game_player.instance_variable_set("@#{key}", value)
    end
  end

  def write_floor_map_diagnostic(map)
    return unless map && map.map_id == MAP_ID
    path = File.join("Data", "ArenaFloorDiagnostic.txt")
    stack = 3.times.map { |z| map.data[INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 12, z] || 0 }
    nonempty = 0
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        nonempty += 1 if map.data[x, y, 0].to_i >= 48
      end
    end
    File.write(path, [
      "map_id=#{map.map_id} size=#{map.width}x#{map.height} tileset_id=#{map.tileset_id} tileset=#{map.tileset_name.inspect}",
      "center_stack=#{stack.inspect} generated_stack=#{base_ground_stack(map).inspect}",
      "renderable_layer0_tiles=#{nonempty}/#{MAP_WIDTH * MAP_HEIGHT}",
      "ground_file_paths=#{ground_file_paths.map { |file| [file, File.file?(file)] }.inspect}"
    ].join("\n") + "\n")
  rescue StandardError => error
    File.write(File.join("Data", "ArenaFloorDiagnostic.txt"), "diagnostic_error=#{error.class}: #{error.message}\n") rescue nil
  end

  def tile_surface_state(records, x, y)
    record = records[tile_edit_key(x, y)]
    unless record.is_a?(Hash)
      return { "floor" => (initial_field_tile?(x, y) ? "field" : "void"),
               "ground" => "plain" }
    end
    floor = record["floor"] == "void" ? "void" : "field"
    ground = SURFACE_NAMES.key?(record["ground"]) ? record["ground"] : "plain"
    { "floor" => floor, "ground" => ground,
      "height" => record["height"] == 1 ? 1 : 0,
      "stair" => ArenaRelief::DIRECTIONS.key?(record["stair"]) ? record["stair"] : nil,
      "platform_style" => ArenaRelief::STYLES.include?(record["platform_style"]) ? record["platform_style"] : "mountain" }
  end

  # Network snapshot: 10,000 one-byte surface codes and at most 96 placements.
  def visit_snapshot_payload
    surface = String.new(capacity: MAP_WIDTH * MAP_HEIGHT)
    records = tile_edit_records
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        state = tile_surface_state(records, x, y)
        code = state["floor"] == "void" ? "void" : state["ground"]
        surface << VISIT_SURFACE_CODES.fetch(code, "1")
      end
    end
    placements = custom_placements.filter_map do |placement|
      next unless placement.is_a?(Hash)
      kind = { "furniture" => 0, "trainer" => 1 }[placement["kind"]]
      item = placement["item"].to_s
      x, y = placement.values_at("x", "y")
      next unless kind && item.match?(/\A[A-Z0-9_]{1,48}\z/) &&
                  x.is_a?(Integer) && x.between?(0, MAP_WIDTH - 1) &&
                  y.is_a?(Integer) && y.between?(0, MAP_HEIGHT - 1)
      next unless kind == 0 ? FURNITURE_STOCK.key?(item.to_sym) : TRAINER_PROFILES.key?(item.to_sym)
      [kind, item, x, y]
    end.first(MAX_ARENA_FURNITURE + MAX_ARENA_TRAINERS)
    { :surface => surface, :placements => placements, :relief => relief_grid(records), :styles => platform_style_grid(records) }
  end

  def decode_visit_snapshot(surface, placements, relief = "0" * (MAP_WIDTH * MAP_HEIGHT), styles = "0" * (MAP_WIDTH * MAP_HEIGHT))
    return nil unless surface.is_a?(String) && surface.bytesize == MAP_WIDTH * MAP_HEIGHT
    codes = VISIT_SURFACE_CODES.invert
    bytes = surface.bytes
    return nil unless ArenaMaterials.valid_surface?(surface)
    return nil unless placements.is_a?(Array) && placements.length <= MAX_ARENA_FURNITURE + MAX_ARENA_TRAINERS
    tile_edits = {}
    bytes.each_with_index do |byte, index|
      x = index % MAP_WIDTH
      y = index / MAP_WIDTH
      state_name = codes[byte.chr]
      return nil unless state_name
      default = initial_field_tile?(x, y) ? "plain" : "void"
      next if state_name == default
      tile_edits[tile_edit_key(x, y)] = if state_name == "void"
                                           { "floor" => "void", "ground" => "plain" }
                                         else
                                           { "floor" => "field", "ground" => state_name }
                                         end
    end
    reserved = [[INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 16],
                [INITIAL_FIELD_X + 10, INITIAL_FIELD_Y + 16],
                [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 4],
                [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 18]]
    seen = {}
    decoded_placements = placements.map do |entry|
      return nil unless entry.is_a?(Array) && entry.length == 4
      kind_id, item, x, y = entry
      kind = { 0 => "furniture", 1 => "trainer" }[kind_id]
      return nil unless kind && item.is_a?(String) && item.match?(/\A[A-Z0-9_]{1,48}\z/) &&
                        x.is_a?(Integer) && x.between?(0, MAP_WIDTH - 1) &&
                        y.is_a?(Integer) && y.between?(0, MAP_HEIGHT - 1)
      known = kind == "furniture" ? FURNITURE_STOCK.key?(item.to_sym) : TRAINER_PROFILES.key?(item.to_sym)
      point = [x, y]
      return nil unless known && !seen[point] && !reserved.include?(point)
      return nil if ArenaRelief.blocked_surface?(surface, x, y)
      seen[point] = true
      { "kind" => kind, "item" => item, "x" => x, "y" => y }
    end
    return nil unless ArenaRelief.valid?(relief, surface, reserved, placements)
    return nil if reserved.any? { |x, y| ArenaRelief.blocked_surface?(surface, x, y) }
    return nil unless ArenaRelief.valid_styles?(styles, relief)
    relief.bytes.each_with_index do |byte, index|
      next if byte == 48
      key = tile_edit_key(index % MAP_WIDTH, index / MAP_WIDTH)
      record = tile_edits[key] ||= { "floor" => "field", "ground" => "plain" }
      record["height"] = 1
      record["stair"] = byte > 49 ? byte - 48 : nil
      record["platform_style"] = ArenaRelief::STYLES[ArenaMaterials::ALPHABET.index(styles[index])]
    end
    tile_edits.each_value(&:freeze)
    { :tile_edits => tile_edits.freeze, :placements => decoded_placements.freeze }
  rescue StandardError
    nil
  end

  def surface_records_for_render
    draft = instance_variable_get(:@editor_surface_edits)
    draft.is_a?(Hash) ? draft : tile_edit_records
  end

  def tile_is_void?(x, y, records = tile_edit_records)
    return true unless x.is_a?(Integer) && y.is_a?(Integer)
    return true unless x.between?(0, MAP_WIDTH - 1) && y.between?(0, MAP_HEIGHT - 1)
    record = records[tile_edit_key(x, y)]
    return record["floor"] == "void" || ArenaMaterials::BLOCKED_GROUNDS.include?(record["ground"]) if record.is_a?(Hash) && record.key?("floor")
    return !initial_field_tile?(x, y)
  end

  def base_ground_stack(map = $game_map)
    return nil unless map && map.map_id == MAP_ID
    cached = map.instance_variable_get(:@arena_demo_base_ground_stack)
    return cached.dup if valid_ground_stack?(map, cached)
    map.remove_instance_variable(:@arena_demo_base_ground_stack) if
      map.instance_variable_defined?(:@arena_demo_base_ground_stack)
    ground_file_paths.each do |ground_path|
      next unless File.file?(ground_path)
      stored = File.read(ground_path).strip.split(",").map { |value| Integer(value, 10) rescue nil }
      if valid_ground_stack?(map, stored)
        map.instance_variable_set(:@arena_demo_base_ground_stack, stored)
        return stored.dup
      end
    end
    best = nil
    regions = [[INITIAL_FIELD_X, INITIAL_FIELD_Y,
                [INITIAL_FIELD_X + INITIAL_FIELD_SIZE, map.width].min,
                [INITIAL_FIELD_Y + INITIAL_FIELD_SIZE, map.height].min],
               [0, 0, map.width, map.height]]
    regions.each do |left, top, right, bottom|
      (top...bottom).each do |y|
        (left...right).each do |x|
          stack = 3.times.map { |z| map.data[x, y, z] || 0 }
          if valid_ground_stack?(map, stack)
            best = stack
            break
          end
        end
        break if best
      end
      break if best
    end
    # Do not silently convert a missing floor into an empty stack (void).
    return nil unless best
    map.instance_variable_set(:@arena_demo_base_ground_stack, best)
    best.dup
  end

  def ground_file_paths
    paths = [GROUND_FILE, File.expand_path("../../Data/ArenaDemoGround.txt", __dir__)]
    if defined?(System) && System.respond_to?(:data_directory)
      paths << File.join(System.data_directory, "ArenaDemoGround.txt")
    end
    paths.map { |path| File.expand_path(path) }.uniq
  end

  def valid_ground_stack?(map, stack)
    return false unless map && stack.is_a?(Array) && stack.length == 3 && stack.any?(&:positive?)
    stack.all? do |tile_id|
      next true if tile_id == 0
      # Essentials' TilemapRenderer treats IDs 0..47 as the blank autotile
      # block. Such tiles can be passable and priority zero, but render black.
      next false if tile_id < 48
      passage = map.passages[tile_id]
      next false if passage.nil? || (passage & 0x0f) != 0
      next false if map.priorities[tile_id].to_i != 0
      true
    end
  end

  def terrain_tile_id(map, terrain_id)
    cache = map.instance_variable_get(:@arena_demo_terrain_tile_cache) || {}
    return cache[terrain_id] if cache.key?(terrain_id)
    tags = map.terrain_tags
    count = tags.respond_to?(:xsize) ? tags.xsize : tags.length
    tile_id = (0...count).find do |id|
      next false if id == 0
      next false unless GameData::TerrainTag.try_get(tags[id]).id == terrain_id
      passage = map.passages[id]
      next false if !passage || passage & 0x0f != 0
      map.priorities[id].to_i == 0
    end
    cache[terrain_id] = tile_id
    map.instance_variable_set(:@arena_demo_terrain_tile_cache, cache)
    tile_id
  end

  def surface_options(map = $game_map)
    SURFACE_NAMES.map { |key, name| [name, key] }
  end

  def surface_stack(map, ground)
    return base_ground_stack(map) if ground == "plain"
    # The arena uses Lappet Town's tileset, which has no dependable Ice floor
    # art. Render Ice with the editor's dedicated tile bitmap instead.
    return base_ground_stack(map) if ground == "ice"
    terrain_id = SURFACE_TAGS[ground]
    tile_id = terrain_id && terrain_tile_id(map, terrain_id)
    return base_ground_stack(map) unless tile_id
    [tile_id, 0, 0]
  end

  def apply_tile_surface(map, x, y, record)
    return unless map && map.map_id == MAP_ID && map.data
    stack = if record["floor"] == "void"
              [0, 0, 0]
            elsif record["height"] == 1 || record["stair"]
              # The transparent summit contour must reveal the lower field,
              # rather than another copy of the summit material underneath.
              base_ground_stack(map)
            else
              surface_stack(map, record["ground"] || "plain")
            end
    3.times { |z| map.data[x, y, z] = stack[z] || 0 }
    refresh_map_renderer
  end

  def refresh_map_renderer
    return unless $scene && $scene.respond_to?(:map_renderer)
    renderer = $scene.map_renderer
    renderer.refresh if renderer && renderer.respond_to?(:refresh)
  end

  def ice_surface_bitmap
    bitmap = instance_variable_get(:@ice_surface_bitmap)
    return bitmap if bitmap && !bitmap.disposed?
    bitmap = Bitmap.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
    bitmap.fill_rect(0, 0, 32, 32, Color.new(142, 210, 234))
    bitmap.fill_rect(4, 4, 10, 2, Color.new(205, 241, 250))
    bitmap.fill_rect(18, 6, 8, 2, Color.new(194, 235, 247))
    bitmap.fill_rect(19, 25, 8, 2, Color.new(112, 185, 215))
    instance_variable_set(:@ice_surface_bitmap, bitmap)
    bitmap
  end

  def reset_surface_map(map)
    return unless map && map.map_id == MAP_ID && map.data
    ground = base_ground_stack(map)
    return unless ground
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        stack = initial_field_tile?(x, y) ? ground : [0, 0, 0]
        3.times { |z| map.data[x, y, z] = stack[z] || 0 }
      end
    end
  end

  def apply_tile_edits(map, records = tile_edit_records)
    return unless map && map.map_id == MAP_ID && records.is_a?(Hash)
    return unless base_ground_stack(map)
    reset_surface_map(map)
    records.each do |key, record|
      next unless record.is_a?(Hash)
      coords = key.to_s.split(",").map(&:to_i)
      next unless coords.length == 2 && coords[0].between?(0, MAP_WIDTH - 1) &&
                  coords[1].between?(0, MAP_HEIGHT - 1)
      apply_tile_surface(map, coords[0], coords[1], record)
    end
  end

  def fixed_event_tile?(x, y)
    return false unless $game_map && $game_map.map_id == MAP_ID
    return true if [x, y] == [INITIAL_FIELD_X + 12, INITIAL_FIELD_Y + 16]
    $game_map.events.values.any? do |event|
      [1, 2, 9].include?(event.id) && event.x == x && event.y == y
    end
  end

  def refresh_custom_placements(placements = custom_placements)
    return unless $game_map && $game_map.map_id == MAP_ID
    furniture = furniture_placements(placements)
    trainers = trainer_placements(placements)
    MAX_ARENA_FURNITURE.times do |slot|
      event = $game_map.events[FURNITURE_SLOT_BASE + slot]
      next unless event
      placement = furniture[slot]
      if placement && (sprite = placement_sprite(placement))
        event.moveto(placement["x"], placement["y"])
        event.character_name = sprite
        event.transparent = false
        event.through = false
      else
        event.character_name = ""
        event.transparent = true
        event.through = true
      end
    end
    MAX_ARENA_TRAINERS.times do |slot|
      event = $game_map.events[TRAINER_SLOT_BASE + slot]
      next unless event
      placement = trainers[slot]
      if placement && (profile = TRAINER_PROFILES[placement_item(placement)])
        event.moveto(placement["x"], placement["y"])
        event.character_name = profile[:sprite]
        event.transparent = false
        event.through = false
        event.walk_anime = true
        event.instance_variable_set(:@step_anime, false)
        event.pattern = 0
        event.instance_variable_set(:@original_pattern, 0)
        event.instance_variable_set(:@direction_fix, false)
        commands = [
          RPG::EventCommand.new(355, 0, ["ArenaDemo.challenge_recruited_trainer(#{slot})"]),
          RPG::EventCommand.new(0, 0, [])
        ]
        event.instance_variable_set(:@list, commands)
      else
        event.character_name = ""
        event.transparent = true
        event.through = true
        event.instance_variable_set(:@list, [RPG::EventCommand.new(0, 0, [])])
      end
    end
  end

  def editor_selectable_tile?(x, y)
    return false unless x.is_a?(Integer) && y.is_a?(Integer)
    return false unless x.between?(0, MAP_WIDTH - 1) && y.between?(0, MAP_HEIGHT - 1)
    return false if $game_player && [$game_player.x, $game_player.y] == [x, y]
    return false if defined?(Visits) && Visits.locked?
    true
  end

  def valid_editor_tile?(x, y)
    return false unless editor_selectable_tile?(x, y)
    return false if fixed_event_tile?(x, y)
    true
  end

  def editor_occupied(placements, x, y)
    placements.find { |placement| placement["x"] == x && placement["y"] == y }
  end

  def editor_choose_mode
    choice = pbMessage("Que souhaitez-vous modifier ?", ["Changer le sol", "Dresseurs", "Meubles", "Plateformes et escaliers", "Style de plateforme entière", "Terminer"], -1)
    return nil unless choice && choice >= 0 && choice <= 4
    [:ground, :trainer, :furniture, :relief, :platform_style][choice]
  end

  def editor_choose_ground
    entry = choose_material_catalog(material_floor_entries, 'Choisissez le sol à appliquer.')
    return nil unless entry
    return { :floor => 'void' } if entry[:ground] == 'void'
    { :floor => 'field', :ground => entry[:ground] }
  end

  def editor_choose_placement(kind, placements)
    entries = bag_catalog(kind).map(&:dup)
    entries << { :action => :remove, :name => "Remove an existing #{kind}", :qty => "" } if placements.any? { |p| p["kind"] == kind }
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer from the arena guide first." : "There is no furniture in this Bag pocket.")
      return nil
    end
    choose_catalog(entries, kind == "trainer" ? "Choose a trainer you own" : "Choose furniture you own")
  end

  def editor_apply_ground(surface_edits, placements, x, y, selected)
    return editor_apply_platform_style(surface_edits, x, y, selected[:platform_style]) if selected.key?(:platform_style)
    return editor_apply_relief(surface_edits, placements, x, y, selected[:relief]) if selected.key?(:relief)
    return false unless editor_selectable_tile?(x, y)
    blocked = selected[:floor] == "void" || ArenaMaterials::UNSAFE_GROUNDS.include?(selected[:ground])
    if blocked && (editor_occupied(placements, x, y) || fixed_event_tile?(x, y) || relief_reserved.include?([x, y]))
      pbMessage("Remove the occupant or move the arena event before making this tile void.")
      return false
    end
    state = tile_surface_state(surface_edits, x, y)
    state["floor"] = selected[:floor]
    state["ground"] = selected[:floor] == "void" ? "plain" : selected[:ground]
    preserve_water_top = ArenaMaterials::CASCADE_GROUNDS.include?(selected[:ground]) && state['height'] == 1 && !state['stair']
    state["height"], state["stair"] = 0, nil if blocked && !preserve_water_top
    candidate = surface_edits.merge(tile_edit_key(x, y) => state)
    unless valid_relief_records?(candidate, placements)
      pbMessage("Retirez d'abord l'escalier qui utilise cette case.")
      return false
    end
    surface_edits[tile_edit_key(x, y)] = state
    apply_tile_surface($game_map, x, y, state)
    true
  end

  def editor_apply_placement(placements, surface_edits, kind, selected, x, y)
    return unless valid_editor_tile?(x, y)
    current = editor_occupied(placements, x, y)
    if selected[:action] == :remove
      unless current && current["kind"] == kind
        pbMessage("Select a tile containing a #{kind} to remove.")
        return
      end
      $bag.add(placement_item(current), 1)
      placements.delete(current)
      refresh_custom_placements(placements)
      return
    end
    if tile_surface_state(surface_edits, x, y)["ground"] == 'quicksand'
      pbMessage("Les sables mouvants doivent rester libres.")
      return
    end
    if tile_surface_state(surface_edits, x, y)["stair"] || relief_wall?(surface_edits, x, y)
      pbMessage("Les escaliers et les parois doivent rester libres. Choisissez le sol ou le dessus d'une plateforme.")
      return
    end
    if tile_is_void?(x, y, surface_edits)
      pbMessage("Make this tile a normal field before placing a trainer or furniture.")
      return
    end
    if current
      action = pbMessage("This tile already has #{current['kind']}.", ["Replace it", "Remove it", "Cancel"], -1)
      if action == 1
        $bag.add(placement_item(current), 1)
        placements.delete(current)
        refresh_custom_placements(placements)
        return
      end
      return unless action == 0
    end
    same_kind_occupant = current && current["kind"] == kind
    if kind == "furniture" && furniture_placements(placements).length >= MAX_ARENA_FURNITURE && !same_kind_occupant
      pbMessage("Your arena has reached its furniture capacity.")
      return
    elsif kind == "trainer" && trainer_placements(placements).length >= MAX_ARENA_TRAINERS && !same_kind_occupant
      pbMessage("Your arena has reached its trainer capacity.")
      return
    end
    unless $bag.remove(selected[:item], 1)
      pbMessage("You have no more of that item in your Bag.")
      return
    end
    $bag.add(placement_item(current), 1) if current
    placements.delete(current) if current
    placements << { "kind" => kind, "item" => selected[:item].to_s, "x" => x, "y" => y }
    refresh_custom_placements(placements)
  end

  def edit_tile(placements, surface_edits, x, y)
    occupied = editor_occupied(placements, x, y)
    state = tile_surface_state(surface_edits, x, y)
    floor_label = state["floor"] == "void" ? "Make normal field" : "Make void"
    remove_label = occupied && occupied["kind"] == "trainer" ? "Kick trainer" : "Remove"
    actions = occupied ? ["Change ground type", remove_label, "Replace", floor_label,
                          "Done", "Validate edit", "Cancel custom mode"] :
                         ["Add object", "Add trainer", "Change ground type", floor_label,
                          "Done", "Validate edit", "Cancel custom mode"]
    status = state["floor"] == "void" ? "Void tile." : "Field tile: #{SURFACE_NAMES[state['ground']]}."
    choice = pbMessage("#{status} Tile (#{x}, #{y}).", actions, -1)
    return :commit if choice == 5
    return :cancel if choice == 6
    return :continue if choice == 4
    if choice == 3
      if state["floor"] == "field" && (occupied || fixed_event_tile?(x, y))
        pbMessage("Remove the occupant or move the arena event before making this tile void.")
        return :continue
      end
      state["floor"] = state["floor"] == "void" ? "field" : "void"
      state["ground"] = "plain" if state["floor"] == "field"
      surface_edits[tile_edit_key(x, y)] = state
      apply_tile_surface($game_map, x, y, state)
      return :continue
    elsif (occupied && choice == 0) || (!occupied && choice == 2)
      options = surface_options
      labels = options.map(&:first) + ["Cancel"]
      selected = pbMessage("Choose a ground type for tile (#{x}, #{y}).", labels, -1)
      if selected >= 0 && selected < options.length
        state["floor"] = "field"
        state["ground"] = options[selected][1]
        surface_edits[tile_edit_key(x, y)] = state
        apply_tile_surface($game_map, x, y, state)
      end
      return :continue
    end
    if occupied
      if choice == 1
        $bag.add(placement_item(occupied), 1)
        placements.delete(occupied)
        refresh_custom_placements(placements)
      elsif choice == 2
        replace_placement(placements, occupied)
      end
    elsif choice == 0
      place_from_bag(placements, "furniture", x, y, surface_edits)
    elsif choice == 1
      place_from_bag(placements, "trainer", x, y, surface_edits)
    end
    return :continue
  end

  def place_from_bag(placements, kind, x, y, surface_edits = tile_edit_records)
    return unless valid_editor_tile?(x, y)
    if tile_is_void?(x, y, surface_edits) || tile_surface_state(surface_edits, x, y)['ground'] == 'quicksand'
      pbMessage("Make this tile a normal field before placing an object or trainer.")
      return
    end
    if kind == "furniture" && furniture_placements(placements).length >= MAX_ARENA_FURNITURE
      pbMessage("Your arena has reached its furniture capacity.")
      return
    elsif kind == "trainer" && trainer_placements(placements).length >= MAX_ARENA_TRAINERS
      pbMessage("Your arena has reached its trainer capacity.")
      return
    end
    entries = bag_catalog(kind)
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer from the arena guide first." :
                                      "There is no furniture in this Bag pocket.")
      return
    end
    entry = choose_catalog(entries, kind == "trainer" ? "Recruited trainers" : "Arena furniture")
    return unless entry
    return unless $bag.remove(entry[:item], 1)
    placements << { "kind" => kind, "item" => entry[:item].to_s,
                    "x" => x, "y" => y }
    refresh_custom_placements(placements)
  end

  def replace_placement(placements, old_placement)
    kind_choice = pbMessage("Replace with which Bag tab?", ["Arena furniture", "Recruited trainers", "Cancel"], -1)
    return unless kind_choice == 0 || kind_choice == 1
    kind = kind_choice == 0 ? "furniture" : "trainer"
    entries = bag_catalog(kind)
    if entries.empty?
      pbMessage(kind == "trainer" ? "Recruit a trainer first." : "There is no furniture in this Bag pocket.")
      return
    end
    entry = choose_catalog(entries, kind == "trainer" ? "Recruited trainers" : "Arena furniture")
    return unless entry
    return unless $bag.remove(entry[:item], 1)
    $bag.add(placement_item(old_placement), 1)
    index = placements.index(old_placement)
    placements[index] = { "kind" => kind, "item" => entry[:item].to_s,
                          "x" => old_placement["x"], "y" => old_placement["y"] }
    refresh_custom_placements(placements)
  end

  def bag_catalog(kind)
    if kind == "furniture"
      FURNITURE_STOCK.map do |item, data|
        next if !$bag.has?(item)
        { :item => item, :name => data[0], :sprite => data[1], :qty => $bag.quantity(item) }
      end.compact
    else
      TRAINER_PROFILES.map do |item, profile|
        next if !$bag.has?(item)
        { :item => item, :name => profile[:name], :sprite => profile[:sprite], :qty => $bag.quantity(item) }
      end.compact
    end
  end

  def choose_catalog(entries, title)
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 100_000
    commands = entries.map { |entry| "#{entry[:name]}  x#{entry[:qty]}" }
    window = ArenaCatalogWindow.new(entries, commands)
    window.viewport = viewport
    window.x = [(Graphics.width - window.width) / 2, 0].max
    window.y = [(Graphics.height - window.height) / 2, 0].max
    window.z = viewport.z + 1
    title = French.text(title) if defined?(French)
    help = Window_UnformattedTextPokemon.newWithSize(title, 0, 0, Graphics.width, 72, viewport)
    help.z = viewport.z + 1
    result = nil
    loop do
      Graphics.update
      Input.update
      window.update
      pbUpdateSceneMap
      # Window_CommandPokemon handles directional movement in update. Do not
      # apply the same key a second time here or rows will skip/wrap.
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::USE)
        result = entries[window.index]
        pbPlayDecisionSE
        break
      end
    end
    result
  ensure
    help&.dispose
    window&.dispose
    viewport&.dispose
  end

  def recruit_trainer
    return pbMessage("Trainers can only be recruited while your arena is offline.") if multiplayer?
    ensure_custom_inventory
    available = TRAINER_PROFILES.reject do |item, _profile|
      $bag.has?(item) || trainer_placements.any? { |placement| placement_item(placement) == item }
    end
    if available.empty?
      pbMessage("You have already recruited every trainer available here.")
      return
    end
    entries = available.map do |item, profile|
      { :item => item, :name => profile[:name], :sprite => profile[:sprite], :qty => 1 }
    end
    entry = choose_catalog(entries, "Choose a trainer to recruit")
    return unless entry
    $bag.add(entry[:item], 1)
    pbMessage("#{entry[:name]} joined your arena staff!")
  end

  def challenge_recruited_trainer(slot)
    return unless $game_map && $game_map.map_id == MAP_ID
    return if $game_temp && $game_temp.in_battle
    placement = trainer_placements[slot]
    return unless placement
    profile = TRAINER_PROFILES[placement_item(placement)]
    return unless profile
    return pbMessage("You need a Pokemon able to battle first.") if !$player || $player.able_pokemon_count == 0
    return unless pbConfirmMessage("#{profile[:name]} is ready for a practice battle. Challenge them?")
    foe = NPCTrainer.new(profile[:name], profile[:type])
    foe.party = profile[:team].map do |species, level, shiny|
      pkmn = Pokemon.new(species, level, foe)
      pkmn.shiny = true if shiny
      pkmn
    end
    TrainerBattle.start(foe)
  end

  def copy_tile_edits(records)
    return {} unless records.is_a?(Hash)
    records.each_with_object({}) do |(key, value), copy|
      copy[key] = value.dup if value.is_a?(Hash)
    end
  end

  def editor_zoom_key?
    Input.respond_to?(:triggerex?) && Input.triggerex?(:U)
  end

  def draw_global_overview(bitmap, surface_edits, placements)
    colors = {
      "void" => Color.new(14, 20, 31),
      "plain" => Color.new(126, 137, 143),
      "grass" => Color.new(64, 151, 78),
      "desert" => Color.new(207, 157, 75),
      "ice" => Color.new(100, 187, 220),
      "rock" => Color.new(115, 117, 125),
      "volcanic" => Color.new(127, 61, 48), "lava" => Color.new(245, 104, 28)
    }
    bitmap.clear
    MAP_HEIGHT.times do |y|
      MAP_WIDTH.times do |x|
        state = tile_surface_state(surface_edits, x, y)
        key = state["floor"] == "void" ? "void" : state["ground"]
        bitmap.fill_rect(x * 2, y * 2, 2, 2, colors[key] || Color.new(*material_overview_color(key)))
      end
    end
    # Subtle ten-tile guides make large edits easier to orient, while a bright
    # outline shows the original 25x25 building footprint without fragmenting
    # every tile into a noisy checkerboard.
    grid = Color.new(34, 43, 57)
    0.step(MAP_WIDTH, 10) do |tile|
      bitmap.fill_rect(tile * 2, 0, 1, MAP_HEIGHT * 2, grid) if tile < MAP_WIDTH
      bitmap.fill_rect(0, tile * 2, MAP_WIDTH * 2, 1, grid) if tile < MAP_HEIGHT
    end
    field_border = Color.new(249, 225, 139)
    field_left = INITIAL_FIELD_X * 2
    field_top = INITIAL_FIELD_Y * 2
    field_size = INITIAL_FIELD_SIZE * 2
    bitmap.fill_rect(field_left, field_top, field_size, 2, field_border)
    bitmap.fill_rect(field_left, field_top + field_size - 2, field_size, 2, field_border)
    bitmap.fill_rect(field_left, field_top, 2, field_size, field_border)
    bitmap.fill_rect(field_left + field_size - 2, field_top, 2, field_size, field_border)
    placements.each do |placement|
      color = placement["kind"] == "trainer" ? Color.new(255, 96, 120) : Color.new(255, 236, 88)
      bitmap.fill_rect(placement["x"] * 2, placement["y"] * 2, 2, 2, color)
    end
  end

  def set_editor_zoom(index, cursor, marker, overview_marker, overview,
                      map_viewport, surface_edits, placements)
    renderer = $scene.map_renderer if $scene && $scene.respond_to?(:map_renderer)
    if index == 2
      renderer.arena_demo_set_zoom(1.0) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
      map_viewport.visible = false
      overview.visible = true
      overview_scale = [Graphics.width * 0.9,
                        Graphics.height * 0.9].min / [MAP_WIDTH * 2, MAP_HEIGHT * 2].max
      overview.zoom_x = overview_scale
      overview.zoom_y = overview_scale
      overview.x = (Graphics.width - overview.bitmap.width * overview.zoom_x) / 2
      overview.y = (Graphics.height - overview.bitmap.height * overview.zoom_y) / 2
      draw_global_overview(overview.bitmap, surface_edits, placements)
      marker.visible = false
      overview_marker.zoom_x = overview.zoom_x / 3.0
      overview_marker.zoom_y = overview.zoom_y / 3.0
      overview_marker.x = overview.x + cursor[0] * 2 * overview.zoom_x
      overview_marker.y = overview.y + cursor[1] * 2 * overview.zoom_y
      overview_marker.visible = true
    else
      scale = index == 1 ? 0.5 : 1.0
      map_viewport.visible = true
      overview.visible = false
      overview_marker.visible = false
      marker.visible = true
      renderer.arena_demo_set_zoom(scale) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
      center_camera_on(cursor[0], cursor[1], scale)
      marker.zoom_x = scale
      marker.zoom_y = scale
      marker.x = (Graphics.width / 2) - (Game_Map::TILE_WIDTH * scale / 2)
      marker.y = (Graphics.height / 2) - (Game_Map::TILE_HEIGHT * scale / 2)
    end
  end

  def editor_dialog(viewport, map_viewport, global_view)
    unless global_view
      viewport.visible = false
      map_viewport.visible = true
    end
    yield
  ensure
    unless global_view
      viewport.visible = true
      map_viewport.visible = true
    end
  end

  def reset_editor_zoom(map_viewport)
    renderer = $scene.map_renderer if $scene && $scene.respond_to?(:map_renderer)
    renderer.arena_demo_set_zoom(1.0) if renderer && renderer.respond_to?(:arena_demo_set_zoom)
    map_viewport.visible = true
  end

  def custom_mode
    player = original_player = original_camera = old_menu_state = nil
    menu_state_captured = false
    viewport = marker = overview_marker = overview = nil
    original_surface_edits = draft_surface_edits = nil
    map_viewport = nil
    return pbMessage("Custom mode is available only while your arena is offline.") if multiplayer?
    return unless $game_map && $game_map.map_id == MAP_ID
    ensure_custom_inventory
    original = custom_placements.map(&:dup)
    draft = original.map(&:dup)
    original_surface_edits = copy_tile_edits(tile_edit_records)
    draft_surface_edits = copy_tile_edits(original_surface_edits)
    @editor_surface_edits = draft_surface_edits
    @editor_placements = draft
    apply_tile_edits($game_map, draft_surface_edits)
    player = $game_player
    original_player = [player.x, player.y, player.direction, player.transparent, player.through]
    original_camera = [$game_map.display_x, $game_map.display_y]
    cursor = [player.x, player.y]
    old_menu_state = $game_temp.in_menu
    menu_state_captured = true
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    # Essentials message windows use z=99999. Keep the overview behind them so
    # text and command prompts remain readable at the farthest zoom.
    viewport.z = 99_998
    marker = Sprite.new(viewport)
    marker.bitmap = Bitmap.new(Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
    marker.bitmap.fill_rect(0, 0, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, Game_Map::TILE_HEIGHT - 3, Game_Map::TILE_WIDTH, 3, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(0, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    marker.bitmap.fill_rect(Game_Map::TILE_WIDTH - 3, 0, 3, Game_Map::TILE_HEIGHT, Color.new(255, 220, 64, 255))
    overview_marker = Sprite.new(viewport)
    overview_marker.bitmap = Bitmap.new(6, 6)
    cursor_shadow = Color.new(10, 18, 24, 255)
    cursor_highlight = Color.new(255, 250, 196, 255)
    overview_marker.bitmap.fill_rect(0, 0, 6, 1, cursor_shadow)
    overview_marker.bitmap.fill_rect(0, 5, 6, 1, cursor_shadow)
    overview_marker.bitmap.fill_rect(0, 0, 1, 6, cursor_shadow)
    overview_marker.bitmap.fill_rect(5, 0, 1, 6, cursor_shadow)
    overview_marker.bitmap.fill_rect(1, 1, 4, 1, cursor_highlight)
    overview_marker.bitmap.fill_rect(1, 4, 4, 1, cursor_highlight)
    overview_marker.bitmap.fill_rect(1, 1, 1, 4, cursor_highlight)
    overview_marker.bitmap.fill_rect(4, 1, 1, 4, cursor_highlight)
    overview_marker.z = viewport.z + 2
    overview_marker.visible = false
    overview = Sprite.new(viewport)
    overview.bitmap = Bitmap.new(MAP_WIDTH * 2, MAP_HEIGHT * 2)
    overview.visible = false
    marker.z = viewport.z + 1
    overview.z = viewport.z
    map_viewport = $scene.map_renderer.viewport
    map_viewport.visible = true
    player.transparent = true
    player.through = true
    $game_temp.in_menu = true
    refresh_custom_placements(draft)
    editor_dialog(viewport, map_viewport, false) do
      pbMessage("Choisissez une case avec les flèches. U change le zoom. Entrée choisit le mode sol, relief, style de plateforme, Dresseur ou mobilier, puis applique votre choix aux cases. X quitte le mode ou termine les modifications.")
    end
    zoom_index = 0
    active_tool = nil
    reset_editor_zoom(map_viewport)
    draw_global_overview(overview.bitmap, draft_surface_edits, draft)
    result = :cancel
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      moved = false
      if Input.repeat?(Input::UP)
        cursor[1] -= 1
        moved = true
      elsif Input.repeat?(Input::DOWN)
        cursor[1] += 1
        moved = true
      elsif Input.repeat?(Input::LEFT)
        cursor[0] -= 1
        moved = true
      elsif Input.repeat?(Input::RIGHT)
        cursor[0] += 1
        moved = true
      end
      if moved
        cursor[0] = [[cursor[0], 0].max, MAP_WIDTH - 1].min
        cursor[1] = [[cursor[1], 0].max, MAP_HEIGHT - 1].min
        center_camera_on(cursor[0], cursor[1], (zoom_index == 1 ? 0.5 : 1.0)) if zoom_index != 2
      end
      if zoom_index == 2
        overview_marker.x = overview.x + cursor[0] * 2 * overview.zoom_x
        overview_marker.y = overview.y + cursor[1] * 2 * overview.zoom_y
      else
        scale = zoom_index == 1 ? 0.5 : 1.0
        tile_x = cursor[0] * Game_Map::TILE_WIDTH - ($game_map.display_x / Game_Map::X_SUBPIXELS)
        tile_y = cursor[1] * Game_Map::TILE_HEIGHT - ($game_map.display_y / Game_Map::Y_SUBPIXELS)
        marker.x = tile_x * scale
        marker.y = tile_y * scale
      end
      if editor_zoom_key?
        zoom_index = (zoom_index + 1) % 3
        set_editor_zoom(zoom_index, cursor, marker, overview_marker, overview,
                        map_viewport, draft_surface_edits, draft)
      end
      if Input.trigger?(Input::USE)
        unless editor_selectable_tile?(cursor[0], cursor[1])
          pbMessage("This tile can't be edited right now.")
          next
        end
        editor_dialog(viewport, map_viewport, zoom_index == 2) do
          if active_tool.nil?
            mode = editor_choose_mode
            if [:ground, :relief, :platform_style].include?(mode)
              selected = case mode
                         when :relief then editor_choose_relief
                         when :platform_style then editor_choose_platform_style
                         else editor_choose_ground
                         end
              if selected
                active_tool = { :kind => :ground, :selection => selected }
                label = if selected[:platform_style]
                          "style de plateforme : #{PLATFORM_STYLES[selected[:platform_style]][0]}"
                        elsif selected.key?(:relief)
                          relief_tool_name(selected[:relief])
                        else
                          selected[:floor] == "void" ? "void" : SURFACE_NAMES[selected[:ground]]
                        end
                pbMessage("Painting #{label}. Move with the arrows and press Enter on each tile. Press X to choose another mode.")
              end
            elsif mode == :trainer || mode == :furniture
              selected = editor_choose_placement(mode.to_s, draft)
              if selected
                active_tool = { :kind => mode, :selection => selected }
                label = selected[:action] == :remove ? "removing #{mode}s" : "placing #{selected[:name]}"
                pbMessage("#{label}. Move with the arrows and press Enter on each tile. Press X to choose another mode.")
              end
            end
          elsif active_tool[:kind] == :ground
            editor_apply_ground(draft_surface_edits, draft, cursor[0], cursor[1], active_tool[:selection])
          else
            editor_apply_placement(draft, draft_surface_edits, active_tool[:kind].to_s,
                                   active_tool[:selection], cursor[0], cursor[1])
          end
        end
        draw_global_overview(overview.bitmap, draft_surface_edits, draft)
      elsif (Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)) && active_tool
        active_tool = nil
        editor_dialog(viewport, map_viewport, zoom_index == 2) do
          pbMessage("Edit mode closed. Choose another category with Enter.")
        end
      elsif Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        choice = editor_dialog(viewport, map_viewport, zoom_index == 2) do
          pbMessage("Finish custom mode?", ["Validate and save", "Cancel all edits", "Keep editing"], -1)
        end
        if choice == 0
          result = :commit
          break
        elsif choice == 1
          result = :cancel
          break
        end
      end
    end
    viewport.visible = false
    map_viewport.visible = true
    @editor_placements = @editor_surface_edits = nil
    if result == :commit
      restore_editor_player(player, original_player, original_camera, old_menu_state)
      previous = $PokemonGlobal.arena_demo_placements
      previous_surface_edits = $PokemonGlobal.arena_demo_tile_edits
      $PokemonGlobal.arena_demo_placements = draft.map(&:dup)
      $PokemonGlobal.arena_demo_tile_edits = copy_tile_edits(draft_surface_edits)
      refresh_custom_placements
      unless Game.save
        $PokemonGlobal.arena_demo_placements = previous
        $PokemonGlobal.arena_demo_tile_edits = previous_surface_edits
        apply_tile_edits($game_map, original_surface_edits)
        reconcile_editor_inventory(original, draft)
        refresh_custom_placements
        pbMessage("The edit could not be saved. Your previous arena layout was restored.")
      else
        pbMessage("Arena custom mode saved.")
      end
    else
      $PokemonGlobal.arena_demo_placements = original
      apply_tile_edits($game_map, original_surface_edits)
      refresh_custom_placements
      # Reconcile the Bag pocket to the saved placements, preserving recruited
      # stock that was already available when the edit started.
      reconcile_editor_inventory(original, draft)
      pbMessage("Custom mode cancelled. Your previous arena was restored.") if draft != original
    end
  rescue StandardError => error
    if original && draft && $PokemonGlobal
      @editor_placements = @editor_surface_edits = nil
      $PokemonGlobal.arena_demo_placements = original
      $PokemonGlobal.arena_demo_tile_edits = original_surface_edits if original_surface_edits
      apply_tile_edits($game_map, original_surface_edits) if original_surface_edits
      reconcile_editor_inventory(original, draft)
      refresh_custom_placements
    end
    viewport.visible = false if viewport
    map_viewport.visible = true if map_viewport
    pbMessage("Custom mode closed safely: #{error.message}")
  ensure
    @editor_surface_edits = nil
    @editor_placements = nil
    reset_editor_zoom(map_viewport) if map_viewport
    restore_editor_player(player, original_player, original_camera, old_menu_state) if menu_state_captured
    overview.bitmap.dispose if overview && overview.bitmap && !overview.bitmap.disposed?
    overview&.dispose
    overview_marker.bitmap.dispose if overview_marker && overview_marker.bitmap && !overview_marker.bitmap.disposed?
    overview_marker&.dispose
    marker.bitmap.dispose if marker && marker.bitmap && !marker.bitmap.disposed?
    marker&.dispose
    viewport&.dispose
  end

  def center_camera_on(x, y, zoom = 1.0)
    center_x = x * Game_Map::TILE_WIDTH + Game_Map::TILE_WIDTH / 2
    center_y = y * Game_Map::TILE_HEIGHT + Game_Map::TILE_HEIGHT / 2
    $game_map.display_x = ((center_x - Graphics.width / (2.0 * zoom)) * Game_Map::X_SUBPIXELS).round
    $game_map.display_y = ((center_y - Graphics.height / (2.0 * zoom)) * Game_Map::Y_SUBPIXELS).round
  end

  def restore_editor_player(player, position, camera, menu_state)
    if player && position
      player.transparent = position[3]
      player.through = position[4]
      player.moveto(position[0], position[1])
      player.turn_down if position[2] == 2
      player.turn_left if position[2] == 4
      player.turn_right if position[2] == 6
      player.turn_up if position[2] == 8
    end
    if $game_map && camera
      $game_map.display_x = camera[0]
      $game_map.display_y = camera[1]
    end
    $game_temp.in_menu = menu_state if $game_temp
  end

  def reconcile_editor_inventory(original, draft)
    return unless $bag
    original_counts = Hash.new(0)
    draft_counts = Hash.new(0)
    original.each { |placement| original_counts[placement_item(placement)] += 1 }
    draft.each { |placement| draft_counts[placement_item(placement)] += 1 }
    (original_counts.keys | draft_counts.keys).each do |item|
      difference = draft_counts[item] - original_counts[item]
      $bag.add(item, difference) if difference > 0
      $bag.remove(item, -difference) if difference < 0
    end
  end
end

class ArenaCatalogWindow < Window_CommandPokemon
  @@arena_sprite_bitmaps = {}

  def initialize(entries, commands)
    @entries = entries
    super(commands, 360)
    self.rowHeight = 56
    resizeToFit(commands, 360)
    refresh
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    entry = @entries[index]
    path = entry[:sprite] ? "Graphics/Characters/#{entry[:sprite]}" : nil
    if path && pbResolveBitmap(path)
      bitmap = @@arena_sprite_bitmaps[entry[:sprite]]
      if !bitmap || bitmap.disposed?
        bitmap = RPG::Cache.load_bitmap("Graphics/Characters/", entry[:sprite])
        @@arena_sprite_bitmaps[entry[:sprite]] = bitmap
      end
      frame_width = [bitmap.width / 4, 32].min
      frame_height = bitmap.height / 4
      contents.blt(rect.x + 8, rect.y + 2, bitmap,
                   Rect.new(frame_width, 0, frame_width, frame_height))
    end
    pbDrawShadowText(contents, rect.x + 54,
                     rect.y + (contents.text_offset_y || 0),
                     rect.width - 54, rect.height,
                     @commands[index], baseColor, shadowColor)
  end
end

class PokemonGlobalMetadata
  attr_accessor :arena_demo_placements
  attr_accessor :arena_custom_stock_added
  attr_accessor :arena_demo_tile_edits
  attr_accessor :arena_demo_centered_layout_migrated
  attr_accessor :arena_demo_centered_layout_migration_version
  attr_accessor :arena_demo_void_recovery_version
end

if defined?(Settings)
  module ArenaDemo::ExtraBagPockets
    def bag_pocket_names
      names = super
      [names[0], names[1], names[2], names[3], names[4], names[7],
       _INTL("Arena Furniture"), _INTL("Recruited Trainers")]
    end
  end
  Settings.singleton_class.prepend(ArenaDemo::ExtraBagPockets)
end

# Keep the original item data intact while routing retired Mail and Battle
# Items pockets into Items in the Bag UI.
if defined?(GameData::Item)
  module ArenaDemo::RemappedItemPockets
    def pocket
      return ArenaDemo::FURNITURE_POCKET if ArenaDemo::FURNITURE_STOCK.key?(@id)
      return ArenaDemo::TRAINER_POCKET if ArenaDemo::TRAINER_PROFILES.key?(@id)
      raw_pocket = super
      return 1 if raw_pocket == 6 || raw_pocket == 7
      return 6 if raw_pocket == 8
      raw_pocket
    end
  end
  GameData::Item.prepend(ArenaDemo::RemappedItemPockets)
end

if defined?(PokemonBag)
  module ArenaDemo::BagPocketSizing
    def initialize(*args)
      super
      ArenaDemo.ensure_bag_pockets(self, true)
    end

    def last_viewed_index(pocket)
      ArenaDemo.ensure_bag_pockets(self)
      super
    end
  end
  PokemonBag.prepend(ArenaDemo::BagPocketSizing)
end

if defined?(PokemonBag_Scene)
  module ArenaDemo::BagTabDisplay
    def pbStartScene(bag, *args)
      ArenaDemo.ensure_bag_pockets(bag)
      ArenaDemo.ensure_custom_inventory if bag.equal?($bag)
      super
      width = [186, 12 + PokemonBag.pocket_count * 22].max
      icon = @sprites["pocketicon"]
      if icon && icon.bitmap.width < width
        replacement = BitmapSprite.new(width, icon.bitmap.height, @viewport)
        replacement.x, replacement.y, replacement.z = icon.x, icon.y, icon.z
        icon.dispose
        @sprites["pocketicon"] = replacement
        pbRefresh
      end
    end

    def pbRefresh
      pocket = @bag.last_viewed_pocket
      if pocket >= 9
        @bag.last_viewed_pocket = 8
        begin
          super
        ensure
          @bag.last_viewed_pocket = pocket
        end
        pbRefreshIndexChanged
      else
        super
      end
      return if !@sprites["pocketicon"]
      icon = @sprites["pocketicon"]
      return if icon.bitmap.width < 12 + PokemonBag.pocket_count * 22
      source = @pocketbitmap.bitmap
      pocket = @sprites["itemlist"].pocket
      if pocket >= 9
        icon.bitmap.clear
        other_pocket = pocket == 9 ? 10 : 9
        icon.bitmap.blt(6 + ((other_pocket - 1) * 22), 6, source, Rect.new(140, 28, 20, 20))
        icon.bitmap.blt(2 + ((pocket - 1) * 22), 2, source, Rect.new(196, 0, 28, 28))
      end
    end
  end
  PokemonBag_Scene.prepend(ArenaDemo::BagTabDisplay)
end

if defined?(GameData::Item)
  ArenaDemo.register_bag_items
end

if defined?(GameData)
  module ArenaDemo::RegisterCustomItemsAfterLoad
    def load_all(*args)
      result = super
      ArenaDemo.register_bag_items
      result
    end
  end
  GameData.singleton_class.prepend(ArenaDemo::RegisterCustomItemsAfterLoad)
end

module ArenaDemo::CustomModeRefresh
  def refresh_objects
    return super unless $game_map
    unless $game_map.map_id == ArenaDemo::MAP_ID
      if $game_map.map_id == ArenaDemo::ENTRANCE_MAP_ID
        $game_map.events.each_value do |event|
          next unless event.name == "Foyer boundary"
          event.transparent = false
          event.through = false
        end
      end
      return super
    end
    super
    [3, 4, 5, 6, 7, 8].each do |id|
      event = $game_map.events[id]
      next unless event
      event.transparent = true
      event.through = true
    end
    ArenaDemo.refresh_custom_placements
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeRefresh)

module ArenaDemo::CustomModeReception
  def arena_reception
    if multiplayer?
      pbMessage("La personnalisation et le recrutement sont disponibles hors ligne. Je peux toutefois soigner votre équipe.")
      heal_team if pbConfirmMessage("Voulez-vous que je soigne votre équipe ?")
      return
    end
    ArenaDemo.ensure_custom_inventory
    loop do
      choice = pbMessage("Bienvenue dans votre arène. Que souhaitez-vous faire ?",
                         ["Personnalisation", "Recruter un Dresseur", "Soigner mon équipe", "Retour"], -1)
      case choice
      when 0 then ArenaDemo.custom_mode
      when 1 then ArenaDemo.recruit_trainer
      when 2 then heal_team
      else break
      end
    end
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeReception)

module ArenaDemo::FreezePlayerInEditor
  def update(*args)
    return if ArenaDemo.instance_variable_get(:@custom_mode_active)
    super
  end
end
Game_Player.prepend(ArenaDemo::FreezePlayerInEditor) if defined?(Game_Player)

if defined?(Game_Map)
  module ArenaDemo::VoidTileCollision
    def passable?(x, y, direction, self_event = nil)
      if @map_id == ArenaDemo::MAP_ID
        offsets = { 1 => [-1, 1], 2 => [0, 1], 3 => [1, 1],
                    4 => [-1, 0], 6 => [1, 0],
                    7 => [-1, -1], 8 => [0, -1], 9 => [1, -1] }
        offset = offsets[direction]
        return false if offset && ArenaDemo.runtime_tile_blocked?(x + offset[0], y + offset[1], self_event)
      end
      super
    end

    def passableStrict?(x, y, direction, self_event = nil)
      return false if @map_id == ArenaDemo::MAP_ID && ArenaDemo.tile_is_void?(x, y)
      super
    end

    def terrain_tag(x, y, count_bridge = false)
      if @map_id == ArenaDemo::MAP_ID
        state = ArenaDemo.tile_surface_state(ArenaDemo.tile_edit_records, x, y)
        terrain_id = ArenaDemo::SURFACE_TAGS[state["ground"]]
        return GameData::TerrainTag.get(terrain_id) if state["floor"] == "field" && terrain_id
      end
      super
    end

    def setup(map_id)
      result = super
      ArenaDemo.recover_centered_arena_state(self) if map_id == ArenaDemo::MAP_ID
      result
    end
  end
  Game_Map.prepend(ArenaDemo::VoidTileCollision)
end

if defined?(Game) && Game.respond_to?(:load)
  module ArenaDemo::SavedArenaRecovery
    def load(*args)
      result = super
      ArenaDemo.reload_saved_arena_map_from_data
      result
    end
  end
  Game.singleton_class.prepend(ArenaDemo::SavedArenaRecovery)
end

if defined?(TilemapRenderer)
  module ArenaDemo::EditorTilemapZoom
    def arena_demo_set_zoom(scale)
      scale = scale.to_f
      @arena_demo_base_columns ||= @tiles_horizontal_count
      @arena_demo_base_rows ||= @tiles_vertical_count
      target_columns = [@arena_demo_base_columns,
                        (Graphics.width.to_f / (Game_Map::TILE_WIDTH * scale)).ceil + 2].max
      target_rows = [@arena_demo_base_rows,
                     (Graphics.height.to_f / (Game_Map::TILE_HEIGHT * scale)).ceil + 2].max
      while @tiles.length > target_columns
        @tiles.pop.each { |coord| coord.each(&:dispose) }
      end
      while @tiles.length < target_columns
        @tiles << Array.new(@tiles_vertical_count) do
          Array.new(3) { TilemapRenderer::TileSprite.new(@viewport) }
        end
      end
      @tiles.each do |column|
        while column.length > target_rows
          column.pop.each(&:dispose)
        end
        while column.length < target_rows
          column << Array.new(3) { TilemapRenderer::TileSprite.new(@viewport) }
        end
      end
      @tiles_horizontal_count = target_columns
      @tiles_vertical_count = target_rows
      @arena_demo_zoom_scale = scale
      ArenaDemo.instance_variable_set(:@editor_zoom_scale, scale)
      @tiles.each do |column|
        column.each do |coord|
          coord.each do |tile|
            tile.tone = @tone.clone
            tile.color = @color.clone
            tile.need_refresh = true
          end
        end
      end
      @need_refresh = true
    end

    def refresh_tile_coordinates(tile, x, y)
      scale = @arena_demo_zoom_scale || 1.0
      tile.x = ((x * TilemapRenderer::DISPLAY_TILE_WIDTH) - @pixel_offset_x) * scale
      tile.y = ((y * TilemapRenderer::DISPLAY_TILE_HEIGHT) - @pixel_offset_y) * scale
      tile.zoom_x = TilemapRenderer::ZOOM_X * scale
      tile.zoom_y = TilemapRenderer::ZOOM_Y * scale
    end

    def refresh_tile(tile, x, y, map, layer, tile_id)
      super
      if map.map_id == ArenaDemo::MAP_ID && layer == 0 && tile_id.to_i >= 48 &&
         !ArenaDemo.instance_variable_get(:@floor_renderer_diagnostic_written)
        ArenaDemo.instance_variable_set(:@floor_renderer_diagnostic_written, true)
        bitmap = tile.bitmap
        File.open(File.join("Data", "ArenaFloorDiagnostic.txt"), "a") do |file|
          file.puts "renderer_tile_id=#{tile_id} file=#{tile.filename.inspect} visible=#{tile.visible} bitmap=#{bitmap && [bitmap.width, bitmap.height].inspect} src=#{tile.src_rect.inspect}"
        end
      end
      return unless map.map_id == ArenaDemo::MAP_ID && layer == 0
      map_display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      map_display_x = ((map_display_x + (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) -
                      (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
      map_display_y = ((map_display_y + (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) -
                      (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
      map_x = x + map_display_x / TilemapRenderer::DISPLAY_TILE_WIDTH
      map_y = y + map_display_y / TilemapRenderer::DISPLAY_TILE_HEIGHT
      state = ArenaDemo.tile_surface_state(ArenaDemo.surface_records_for_render, map_x, map_y)
      return unless state["floor"] == "field" && state["height"] != 1 && ArenaMaterials::FLOORS.key?(state["ground"]) && !["plain", "grass", "desert", "rock"].include?(state["ground"])
      tile.bitmap = state["ground"] == "ice" ? ArenaDemo.ice_surface_bitmap : ArenaDemo.platform_floor_bitmap(state["ground"])
      tile.src_rect = Rect.new(0, 0, Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT)
      tile.animated = false
      tile.is_autotile = false
      tile.filename = ""
    end
  end
  TilemapRenderer.prepend(ArenaDemo::EditorTilemapZoom)
end

if defined?(Sprite_Character)
  module ArenaDemo::EditorCharacterZoom
    def update(*args)
      super
      scale = ArenaDemo.instance_variable_get(:@editor_zoom_scale) || 1.0
      self.x *= scale
      self.y *= scale
      self.zoom_x = TilemapRenderer::ZOOM_X * scale
      self.zoom_y = TilemapRenderer::ZOOM_Y * scale
    end
  end
  Sprite_Character.prepend(ArenaDemo::EditorCharacterZoom)
end

module ArenaDemo::CustomModeFlag
  def custom_mode
    ArenaDemo.instance_variable_set(:@custom_mode_active, true)
    super
  ensure
    ArenaDemo.instance_variable_set(:@custom_mode_active, false)
  end
end
ArenaDemo.singleton_class.prepend(ArenaDemo::CustomModeFlag)

# The desktop launcher sets this flag so an existing local save opens directly
# into the game. This avoids leaving the player at a black title transition
# where they believe another Enter press is needed. New installs still see the
# normal title menu because there is no save to continue.
if defined?(PokemonLoadScreen)
  module ArenaDemo::AutoContinueExistingSave
    def pbStartLoadScreen
      if ENV["ARENA_AUTO_CONTINUE"] == "1" && @save_data && !@save_data.empty?
        Game.load(@save_data)
        return
      end
      super
    end
  end
  PokemonLoadScreen.prepend(ArenaDemo::AutoContinueExistingSave)
end
