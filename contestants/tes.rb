class TES
  attr_accessor :board
  def initialize(board)
    @board = board.split("")
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
    self.board.select.with_index {|cell, i| i/27 + (i%9)/3 == index/27 + (index%9)/3}
  end

  def possible_numbers index
    (1..9).to_a - self.get_row(index) - self.get_column(index) - self.get_square(index)
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

  # def possible_numbers(coord, sboard)
  #   (0..9).to_a.reject{|i|
  #     all_relevant_coordinates(coord).inject([]){|a,s| a + s.map{|c| sboard[c[0]][c[1]]}}.include?(i)
  #   }
  # end

  # def solve
  #   Board.new(by_elimination(@sudoku_board).flatten.map{|i| i - 1}.join)
  # end

  # def by_elimination(sboard)
  #   changed = true
  #   while changed do
  #     changed = false
  #     empty_cells = get_empty_cells(sboard)
  #     empty_cells.each do |coords|
  #       possibilities = possible_numbers(coords, sboard)
  #       return -1 if possibilities.length < 1
  #       if possibilities.length == 1
  #         sboard[coords[0]][coords[1]] = possibilities[0]
  #         changed = true
  #       end
  #     end
  #   end
  #   sboard = guess(sboard) if !(all_cells_filled?(sboard))
  #   return sboard
  # end

  # def guess(sboard)
  #   b = -1
  #   cell = get_empty_cells(sboard).first
  #   new_sboard = Marshal.load(Marshal.dump(sboard))
  #   possible_numbers(cell, new_sboard).each do |guess|
  #     new_sboard[cell[0]][cell[1]] = guess
  #     b = by_elimination(new_sboard)
  #     break if b != -1
  #   end
  #   return b
  # end

end

class Board
  def initialize n;@n=n;end
  def self.from_file f;new(f.map{|l|l.strip.gsub(' ','').gsub('_','0')}.join);end
  def to_number;@n;end
end
