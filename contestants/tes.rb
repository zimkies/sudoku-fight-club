require 'benchmark'

class TES
  attr_accessor :board
  def initialize(board)
    @board = board.split("").map {|num| num.to_i}
  end

  def solved?
    !board.include? 0
  end

  def empty_cells
    board.map.with_index {|cell, i| cell == 0 ? i : nil}.select {|cell| cell }
  end

  def get_row index
    remainder = index % 9
    start = index - remainder
    (start...start+9).to_a.map {|i| board[i]}
  end

  def get_column index
    board.select.with_index {|cell, i| i%9 == index % 9}
  end

  def get_square index
    board.select.with_index {|cell, i| (i/27)*3 + (i/3)%3 == (index/27)*3 + (index/3)%3}
  end

  def possible_numbers index
    (1..9).to_a - get_row(index) - get_column(index) - get_square(index)
  end

  def solve
    by_elimination
    guess unless solved? || !valid?
    Board.new(board.join(""))
  end

  def by_elimination
    empty_cells.each do |index|
      pos = possible_numbers index
      if pos.length == 0
        board[index] = -1
        break
      end
      if pos.length == 1
        board[index] = pos[0]
        by_elimination
        break
      end
    end
  end

  def guess
    cell = empty_cells.min_by {|pos| possible_numbers(pos).length}
    possible_numbers(cell).each do |pos|
      test_board = TES.new(self.board.map {|cell| cell.to_s}.join(""))
      test_board.board[cell] = pos
      test_board.solve
      if test_board.solved? && test_board.valid?
        self.board = test_board.board
        break
      end
    end
    self.board
  end

  def valid?
    !self.board.include? -1
  end

end

class Board
  def initialize n;@n=n;end
  def self.from_file f;new(f.map{|l|l.strip.gsub(' ','').gsub('_','0')}.join);end
  def to_number;@n;end
end