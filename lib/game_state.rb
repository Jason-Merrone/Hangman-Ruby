require_relative "dictionary"
require_relative "game_states_enum"
require "json"

class GameState
include GameStatesEnum

  private def input_command
    @last_user_input = gets.downcase
  end

  private def process_menu
    puts""
    puts "Welcome to Hangman! Enter '0' to begin a new round or '1' to load your previous save"
    input_command

    ((@game_state_curr = GameStatesEnum::GAME) && (return 0)) unless @last_user_input.chomp != "0"

    ((@game_state_curr = GameStatesEnum::LOAD) && (return 0)) unless @last_user_input.chomp != "1"

    puts "Invalid input"
    return 0
  end

  private def process_game
    
    puts ""
    puts "#{@word_to_guess.tr(@characters_to_remove,'_')} You have #{@num_tries_remaining} tries remaining. Please enter your guess or type '1' to save and exit"
    input_command

    (@game_state_curr = GameStatesEnum::SAVE) && (return 0) unless @last_user_input.chomp != "1"

    unless @last_user_input.chomp.length == 1 || @last_user_input.chomp.length == @word_to_guess.length
      puts "Invalid input. Please enter a single character or guess the entire #{@word_to_guess.length} character word."
      return 0
    end

    @num_tries_remaining -= 1

    @characters_to_remove.gsub!(@last_user_input.chomp,"")

    @game_state_curr = GameStatesEnum::LOSE unless @num_tries_remaining > 0
    @game_state_curr = GameStatesEnum::WIN unless @last_user_input.chomp != @word_to_guess && @word_to_guess.tr(@characters_to_remove,'_') != @word_to_guess
    return 0
  end

  private def process_win
    puts ""
    puts "'#{@word_to_guess}' was the correct word! You win!"
    puts "Enter '0' to play again or enter any other key to exit."
    input_command

    return 1 unless @last_user_input.chomp == "0"
    (@game_state_curr = GameStatesEnum::RESET) && (return 0)
  end

  private def process_lose
    puts ""
    puts "GAMEOVER: '#{@word_to_guess}' was the correct word. You ran out of guesses!"
    puts "Enter '0' to play again or enter any other key to exit."
    input_command

    return 1 unless @last_user_input.chomp == "0"
    (@game_state_curr = GameStatesEnum::RESET) && (return 0)
  end

  private def process_reset
    puts ""
    reusable_init && (return 0)
  end

  private def to_json
    {'characters_to_remove' =>@characters_to_remove, 'game_state_curr' => 2, 'word_to_guess' => @word_to_guess, 'num_tries_remaining' => @num_tries_remaining}.to_json
  end

  private def from_json(data)
    @characters_to_remove = data["characters_to_remove"]
    @game_state_curr = data["game_state_curr"].to_i
    @word_to_guess = data["word_to_guess"]
    @num_tries_remaining = data["num_tries_remaining"].to_i
  end

  private def process_save
    f = File.new 'saves/save', 'w'

    f.puts self.to_json
    return 1
  end

  private def process_load

    unless File.exist?('saves/save') && !File.empty?('saves/save')
      puts "No saved games detected"
      @game_state_curr = GameStatesEnum::MENU
      return 0
    end

    f = File.open('saves/save')

    from_json(JSON.load File.read(f))

    f.close
    return 0
  end

  private def reusable_init
    @word_to_guess = @dictionary.get_random_word
    @characters_to_remove = "abcdefghijklmnopqrstuvwxyz"
    @last_user_input = ""
    @num_tries_remaining = @word_to_guess.length * 2
    @game_state_curr = GameStatesEnum::MENU
    @game_state_map = {
      GameStatesEnum::MENU => -> {process_menu},
      GameStatesEnum::GAME => -> {process_game},
      GameStatesEnum::WIN => -> {process_win},
      GameStatesEnum::RESET => -> {process_reset},
      GameStatesEnum::LOSE => -> {process_lose},
      GameStatesEnum::SAVE => -> {process_save},
      GameStatesEnum::LOAD => -> {process_load}
    }
  end

  def initialize(file_containing_dictionary)
    @dictionary = Dictionary.new(file_containing_dictionary)
    reusable_init
  end

  def update()
    return 1 unless @game_state_map[@game_state_curr].call == 0

    return 0
  end
end