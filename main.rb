# frozen_string_literal: true

require_relative 'lib/game_state'

dictionary_file_path = 'dir/google-10000-english-no-swears.txt'
game = GameState.new(dictionary_file_path)

loop do
  break unless game.update.zero?
end
