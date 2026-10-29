require 'minitest/autorun'
require_relative '../Plugins/ArenaDemo/000_ArenaMusicSelection'

class MusicSelectionTest < Minitest::Test
  def test_battle_template_is_replaced_with_overworld_audio
    assert_equal 'Town.ogg', ArenaDemo::MusicSelection.select(
      ['001 Battle.ogg', 'Town.ogg', 'Trainer Battle.ogg'], '001 Battle')
  end

  def test_decoded_battle_does_not_displace_an_overworld_midi
    assert_equal 'Town.mid', ArenaDemo::MusicSelection.select(['Battle.ogg', 'Town.mid'])
  end

  def test_overworld_words_do_not_allow_battle_or_victory_tracks
    assert_nil ArenaDemo::MusicSelection.select(['Route Battle.ogg', 'Gym Victory.mp3'])
  end

  def test_existing_overworld_track_is_preserved
    assert_equal 'Village.ogg', ArenaDemo::MusicSelection.select(['Route.ogg', 'Village.ogg'], 'Village')
  end
end
