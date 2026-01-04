# frozen_string_literal: true

class Dictionary
  def initialize(file_containing_dictionary)
    @dict_array = ['default']

    return 1 unless File.exist? file_containing_dictionary

    f = File.open(file_containing_dictionary)

    while (line = f.gets)
      @dict_array << line.chomp.downcase unless line.length > 12 || line.length < 5
    end
  end

  def get_random_word
    @dict_array[rand(0...@dict_array.length)]
  end
end
