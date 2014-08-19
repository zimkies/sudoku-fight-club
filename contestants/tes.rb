class TES
  attr_accessor :board
  def initialize(board)
    @board = board.split("").map {|num| num.to_i}
  end

  def solved?
    !self.board.include? 0
  end

  def empty_cells
    self.board.map.with_index {|cell, i| cell == 0 ? i : nil}.select {|cell| cell }
  end

  def get_row index
    remainder = index % 9
    start = index - remainder
    (start...start+9).to_a.map {|i| self.board[i]}
  end

  def get_column index
    self.board.select.with_index {|cell, i| i%9 == index % 9}
  end

  def get_square index
    self.board.select.with_index {|cell, i| (i/27)*3 + (i/3)%3 == (index/27)*3 + (index/3)%3}
  end

  def possible_numbers index
    (1..9).to_a - self.get_row(index) - self.get_column(index) - self.get_square(index)
  end

  def solve
    self.by_elimination
    self.guess unless self.solved?
    self.board.join("")
  end

  def by_elimination
    self.empty_cells.each do |index|
      pos = self.possible_numbers index
      if pos.length == 1
        self.board[index] = pos[0]
        self.by_elimination
        break
      end
    end
  end

  def guess
    cell = self.empty_cells.min_by {|pos| self.possible_numbers pos}
    self.possible_numbers(cell).each do |pos|
      test_board = TES.new(self.board.map {|cell| cell.to_s}.join(""))
      test_board.board[cell] = pos
      test_board.solve
      if test_board.solved?
        self.board = test_board.board
        break
      end
    end
    self.board
  end

  def valid?
    self.board.each_with_index do |cell, i|
      return false if self.get_row(i).select {|c| c == cell }.length > 1
      return false if self.get_column(i).select {|c| c == cell }.length > 1
      return false if self.get_square(i).select {|c| c == cell }.length > 1
    end
    return true
  end

end

easy_game = TES.new("105802000090076405200400819019007306762083090000061050007600030430020501600308900")
p easy_game.solve


# "
# 105 802 000
# 090 076 405
# 200 400 819

# 019 007 306
# 762 083 090
# 000 061 050

# 007 600 030
# 430 020 501
# 600 308 900
# "

class Board
  def initialize n;@n=n;end
  def self.from_file f;new(f.map{|l|l.strip.gsub(' ','').gsub('_','0')}.join);end
  def to_number;@n;end
end
