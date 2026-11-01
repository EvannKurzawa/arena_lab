# Short field prompts from HGSS's French script, text file 211.
# Adapt only typography, line breaks and Essentials' split Strength messages.
module ArenaDemo::French
  <<~'TRANSLATIONS'.each_line do |line|
This tree looks like it can be cut down. ||| Cet arbre semble pouvoir être coupé.
This tree looks like it can be cut down!\nWould you like to cut it? ||| Cet arbre semble pouvoir être coupé.\nUtiliser Coupe ?
It's a rugged rock, but a Pokémon may be able to smash it. ||| C'est un bloc de pierre solide, mais un Pokémon peut être apte à le pulvériser.
This rock seems breakable with a hidden move.\nWould you like to use Rock Smash? ||| Ce bloc de pierre peut être brisé.\nVoulez-vous utiliser Éclate-Roc ?
It's a big boulder, but a Pokémon may be able to push it aside. ||| C'est un gros rocher, mais un Pokémon peut être apte à le déplacer.
It's a big boulder, but you may be able to push it aside with a hidden move. ||| C'est un gros rocher, mais un Pokémon peut être apte à le déplacer.
Would you like to use Strength? ||| Voulez-vous utiliser Force ?
Strength made it possible to move boulders around. ||| Force permet de déplacer le rocher.
Strength made it possible to move boulders around! ||| Force permet de déplacer le rocher.
TRANSLATIONS
    original, translated = line.chomp.split(' ||| ', 2)
    TEXT[original.gsub('\\n', "\n")] = translated.gsub('\\n', "\n")
  end
  @script_alias_size = nil
end
