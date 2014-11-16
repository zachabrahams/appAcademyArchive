class Hangman

  attr_accessor :board, :master, :guesser, :current_turn
  MAX_TURNS = 10

  def initialize(master, guesser)
    @master = master
    @guesser = guesser
  end

  def run
    master.pick_secret_word
    @board = Array.new(master.secret_length)
    @current_turn = 0

    until (won? || current_turn == MAX_TURNS)
      play_turn
    end

    if won?
      puts "You did it! You guessed '#{render_board}'"
    else
     word = master.reveal_word(board_to_regexp)
     puts "You couldn't even get an easy word like '#{word}'. Shame on you."
   end
  end

  def play_turn
    puts "#{render_board}    Guesses Left: #{MAX_TURNS - current_turn}"
    guess = guesser.guess
    guess_indices = master.check_guess(guess)

    if guess_indices.empty?
      self.current_turn += 1
    else
      update_board(guess, guess_indices)
    end
  end

  def won?
    board.none?(&:nil?)
  end

  def update_board(guess, indices)
    indices.each { |i| board[i] = guess }
  end

  def render_board
    board.map { |letter| letter.nil? ? "_" : letter }.join("")
  end

  def board_to_regexp
    pattern = board.map { |letter| letter.nil? ? "\\w" : letter}.join("")
    pattern = "\\A#{pattern}\\z"
    Regexp.new(pattern)
  end

end

class HumanPlayer

  def pick_secret_word
    puts "Please come up with a secret word! It does have to be a real word"
  end

  def secret_length
   puts "How many letter-occurences are in your secret word?"
   begin
     number_of_letters = Integer(gets.chomp)
   rescue
     puts "Please enter an integer!"
     retry
   end
  end

  def guess
    puts "Please make a guess!"
    begin
      guess = gets.chomp.downcase

      raise "Error - Input Too long!" unless guess.length == 1
      raise "Error - Input Not a Letter" unless ("a".."z").include?(guess)

      guess

    rescue Exception => err
      puts err.message
      puts "Please try your input again."
      retry
    end
  end

  def check_guess(guess)
    puts "The other player guessed #{guess}."
    puts "Please write the locations in the word where #{guess} is found"
    puts "separated by commas. (Like '0,1,5')  Leave the line blank if #{guess}"
    puts "isn't in the word."

    begin
      letter_indices = gets.chomp.split(",").uniq
      letter_indices.map { |index| Integer(index) }
      # need to raise exception is any integer is higher than secret_word
      # length.  But it involves accessing secret word length from here...
      # Maybe pass it to guess?
    rescue
      puts "Improper input format! Try again!"
      retry
    end
  end

  def reveal_word(pattern)
    puts "What is your word?"

    begin
      word = gets.chomp
      raise "Improper word" unless word =~ pattern
    rescue
      puts "Word doesn't match current board. Please input again"
      retry
    end

    word
  end

  def handle_guess_response
  end

end

class ComputerPlayer
  DICT_FILE = "dictionary.txt"

  def pick_secret_word
    dictionary = load_dictionary
    @secret_word = dictionary.sample
  end

  def secret_length
    secret_word.length
  end

  def guess
    ("a".."z").to_a.sample
  end

  def check_guess(guess)
    (0...secret_word.length).select { |i| secret_word[i] == guess }
  end

  def reveal_word(pattern)
    secret_word
  end

  def handle_guess_response(guess)

  end

  private
  attr_reader :secret_word

  def load_dictionary
    File.readlines(DICT_FILE).map(&:chomp)
  end

end

if __FILE__ == $PROGRAM_NAME
  hum = HumanPlayer.new
  comp = ComputerPlayer.new
  game = Hangman.new(hum, comp)
  game.run
end
