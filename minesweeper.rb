require "./board"

class Minesweeper

  def initialize
    @board = Board.new
    @board.make_board
  end

  def play
    while true
      @board.display
      puts "What is your move? (h for help, and q for quit)"
      print ">"

      begin
        input = gets.chomp
        coords = /[fru]\((\d*)\,(\d*)\)/.match(input)
        x, y = coords[1].to_i, coords[2].to_i unless coords.nil?
        system "clear"

        case input[0]
        when "f"
          @board[x,y].mark
        when "r"
          break if lose?(x, y)
          reveal_neighbors(@board[x, y])
        when "h"
          help
        when "q"
          break
        when "u"
          @board[x,y].unmark
        else
          raise "Invalid input"
        end
      rescue
        puts "Invalid input!"
        print ">"
        retry
      end
    end
  end

  def inspect
  end

  private

  def won?
  end

  def help
    puts "F - flagged tile"
    puts "* - Unmarked tile"
    puts "r(coordinates) - reveals a tile"
    puts "f(coordinates) - flags a tile"
    puts "u(coordinates) - unmarks a tile"
  end

  def reveal_neighbors(tile)
    tile.reveal
    return if tile.neighbor_bomb_count > 0

    tile.neighbors.each do |neighbor|
      reveal_neighbors(neighbor) unless neighbor.marked || neighbor.revealed
    end
  end

  def lose?(x, y)
    @board[x, y].bombed
  end

end
