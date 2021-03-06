class Board

  BOARD_SIZE = 8
  ROWS_OF_PIECES = 3

  def self.starting_position
    position = { :white => [], :black => [] }

    (0...BOARD_SIZE).each do |x|
      (0...ROWS_OF_PIECES).each do |y|
        white_square = [x, y]
        black_square = [x, BOARD_SIZE - y - 1]
        position[:white] << white_square if Board.is_dark?(white_square)
        position[:black] << black_square if Board.is_dark?(black_square)
      end
    end

    position
  end

  def self.is_dark?(pos)
    x, y = pos
    (x + y) % 2 == 0
  end

  def self.on_board?(pos)
    pos.all? { |coord| coord.between?(0, BOARD_SIZE - 1) }
  end

  def initialize(position = Board.starting_position)
    @grid = make_board(position)
  end

  def [](pos)
    unless pos.all? { |coord| coord.between?(0, Board::BOARD_SIZE - 1)}
      raise InvalidMoveError.new "Position off board."
    end
    x, y = pos
    @grid[y][x]
  end

  def []=(pos, piece)
    x, y = pos
    @grid[y][x] = piece
    piece.pos = pos if piece
  end

  def slide(start_pos, end_pos)
    self[end_pos] = self[start_pos]
    self[start_pos] = nil
  end

  def jump(start_pos, jump_pos, end_pos)
    self[end_pos] = self[start_pos]
    self[start_pos] = nil
    self[jump_pos] = nil
  end

  def dup
    position = self.extract_position
    Board.new(position)
  end

  def extract_position
    position = Hash.new { |h, v| h[v] = [] }

    kings = pieces.select { |piece| piece.king }
    peons = pieces.reject { |piece| piece.king }

    peons.each do |piece|
      position[piece.color] << piece.pos.dup
    end

    kings.each do |king|
      label = (king.color == :white ? :white_king : :black_king)
      position[label] << king.pos.dup
    end

  position
  end

  def pieces(color = nil)
    pieces = @grid.flatten.compact
    if color == :white
      pieces.select { |piece| piece.color == :white }
    elsif color == :black
      pieces.select { |piece| piece.color == :black }
    else
      pieces
    end
  end

  def empty?(pos)
    self[pos].nil?
  end

  def over?
    pieces(:white).empty? or pieces(:black).empty?
  end

  def winner
    if pieces(:white).empty?
      :black
    elsif pieces(:black).empty?
      :white
    else
      nil
    end
  end

  def display
    puts render
  end

  def inspect
    render
  end

  private

  def make_board(position)
    grid = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE) }
    position.each do |color, squares|
      !squares.empty? &&
      squares.each do |square|
        is_king = ([:white_king, :black_king].include?(color) ? true : false)
        if is_king
          color = (color == :white_king ? :white : :black)
        end
        x, y = square
        grid[y][x] = Piece.new(square, color, self, is_king)
      end
    end

    grid
  end

  def render
    render_str = hori_border
    switch = true

    @grid.reverse.each_with_index do |row, index|
      switch = !switch
      render_row = " #{reverse_index(index)} ".on_light_white <<
      row.map do |square|
        switch = !switch
        square ? " #{square.render} ".checker(switch) : "   ".checker(switch)
      end.join("") << " #{reverse_index(index)} \n".on_light_white

      render_str << render_row
    end

    (render_str << hori_border)
  end

  def hori_border
    ("   " << ("A".."Z").to_a[0...Board::BOARD_SIZE].map do |letter|
      " #{letter} "
    end.join("") << "   \n").on_light_white
  end

  def reverse_index(index)
    reversed = (0..Board::BOARD_SIZE + 1).to_a.reverse
    reversed.index(index + 1)
  end

end
