class TES
  def initialize(board_string)
    @sudoku_board = []
    9.times { @sudoku_board<<board_string.slice!(0, 9).split("").map(&:to_i) }
  end

  def all_cells_filled?(sboard)
    sboard.none?{|r| r.include?(0) }
  end

  def get_empty_cells(sboard)
    empty_cells = []
    sboard.each_with_index {|r,i| r.each_with_index { |c,j| empty_cells << [i,j] if c == 0}}
    empty_cells
  end

  def all_relevant_coordinates(coord)
    relevant_coords = Array.new(3){[]}
    (0..8).map do |i|
      relevant_coords[0] << [coord[0], i]
      relevant_coords[1] << [i, coord[1]]
      relevant_coords[2] << [(coord[0]/3)*3+i/3,(coord[1]/3)*3+i%3]
    end
    return relevant_coords
  end

  def possible_numbers(coord, sboard)
    (0..9).to_a.reject{|i|
      all_relevant_coordinates(coord).inject([]){|a,s| a + s.map{|c| sboard[c[0]][c[1]]}}.include?(i)
    }
  end

  def solve
    Board.new(by_elimination(@sudoku_board).flatten.map{|i| i - 1}.join)
  end

  def by_elimination(sboard)
    changed = true
    while changed do
      changed = false
      empty_cells = get_empty_cells(sboard)
      empty_cells.each do |coords|
        possibilities = possible_numbers(coords, sboard)
        return -1 if possibilities.length < 1
        if possibilities.length == 1
          sboard[coords[0]][coords[1]] = possibilities[0]
          changed = true
        end
      end
    end
    sboard = guess(sboard) if !(all_cells_filled?(sboard))
    return sboard
  end

  def guess(sboard)
    b = -1
    cell = get_empty_cells(sboard).first
    new_sboard = Marshal.load(Marshal.dump(sboard))
    possible_numbers(cell, new_sboard).each do |guess|
      new_sboard[cell[0]][cell[1]] = guess
      b = by_elimination(new_sboard)
      break if b != -1
    end
    return b
  end

end

class Board
  def initialize n;@n=n;end
  def self.from_file f;new(f.map{|l|l.strip.gsub(' ','').gsub('_','0')}.join);end
  def to_number;@n;end
end
