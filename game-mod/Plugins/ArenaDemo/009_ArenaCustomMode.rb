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
    :ARENA_FURNITURE_BOULDER => ["Boulder", "Object boulder", 2],
    :ARENA_FURNITURE_ROCK    => ["Rock", "Object rock", 2],
    :ARENA_FURNITURE_TREE    => ["Tree", "Object tree 1", 2]
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
      :team => [[:CHARIZARD, 100], [:PIKACHU, 100], [:MEW, 100]]
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
    preserve_water_top = selected[:ground] == 'water' && state['height'] == 1 && !state['stair']
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
    foe.party = profile[:team].map { |species, level| Pokemon.new(species, level, foe) }
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
