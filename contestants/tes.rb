class TES
  def initialize(board_string)
    @sudoku_board = []
    until board_string.length == 0
        row = board_string.slice!(0, 9).split("")
        row.map! { |num| num.to_i }
        @sudoku_board << row
    end
  end

  def display_board(sboard = @sudoku_board)
    board_string = ""
    sboard.each_with_index do |row, row_index|
      board_string << "-"*21 + "\n" if row_index % 3 == 0
      row.each_with_index do |cell, cell_index|
        board_string << "| " if cell_index % 3 == 0 && cell_index != 0
        board_string << cell.to_s + " " unless cell == 0
        board_string << "  " if cell == 0
      end
      board_string << "\n"
    end
    board_string << "-"*21
    return board_string
  end

  def all_cells_filled?(sboard)
    empty_cells = 0
    sboard.each do |row|
      row.each { |cell| return false if cell == 0 }
    end
    return true
  end

  def get_empty_cells(sboard)
    empty_cells = []
    sboard.each_with_index do |row, row_index|
      row.each_with_index do |cell, column_index|
        empty_cells << [row_index, column_index] if cell == 0
      end
    end
    return empty_cells
  end

  def all_relevant_coordinates(coord)
    raise 'row out of bounds' unless (0..8).to_a.include?(coord[0])
    raise 'Column out of bounds' unless (0..8).to_a.include?(coord[1])
    relevant_coords = Array.new(3) { [] }
    for index in 0..8 do
      relevant_coords[0] << [coord[0], index]
      relevant_coords[1] << [index, coord[1]]
      relevant_coords[2] << [(coord[0]/3)*3 + index/3, (coord[1]/3)*3 + index%3]
    end
    return relevant_coords
  end

  def possible_numbers(coord, sboard)
    possibilities = (0..9).to_a
    used = []
    all_relevant_coordinates(coord).each do |section|
      section.each { |coord| used << (sboard[coord[0]][coord[1]]) }
    end
    used.uniq.each { |num| possibilities.delete(num) }
    return possibilities
  end

  def solve
    @sudoku_board = by_elimination(@sudoku_board)
    puts @sudoku_board.flatten.join
    Board.new(@sudoku_board.flatten.map{|i| i - 1}.join)
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
          sboard[coords[0]][coords[1]] = possibilities.first
          changed = true
        end
     end
    end
    sboard = by_common_possibles(sboard) if !(all_cells_filled?(sboard))
    return sboard
  end

  def by_common_possibles(sboard)
    changed = false
    empty_cells = get_empty_cells(sboard)
    empty_cells.each do |empty_coord|
      break if changed
      all_coords = all_relevant_coordinates(empty_coord)
      all_coords.each_with_index do |section, i|
        section_coords = all_coords[i]
        empty_section_coords = []
        section_coords.each { |coord| empty_section_coords << coord if sboard[coord[0]][coord[1]] == 0 }
        possibilities_counter = Hash.new
        for num in 1..9 do 
          possibilities_counter[num] = 0 
        end
        empty_section_coords.each do |coords|
          possibilities = possible_numbers(coords, sboard)
          possibilities.each do |num| 
            possibilities_counter[num] += 1 
          end
        end
        empty_section_coords.each do |coords|
          if possibilities_counter.has_value?(1)
            possibilities_counter.each do |number, occurances|
              if occurances == 1
                pos = possible_numbers(coords, sboard)
                if pos.include?(number)
                  sboard[coords[0]][coords[1]] = number
                  changed = true
                end
              end
            end
          end
        end
      end
    end
    sboard = by_elimination(sboard) if changed && !(all_cells_filled?(sboard))
    sboard = guess(sboard) if !(changed) && !(all_cells_filled?(sboard))
    return sboard
  end

  def guess(sboard)
    cell = get_empty_cells(sboard).sample
    new_sboard = Marshal.load(Marshal.dump(sboard))
    guess = possible_numbers(cell, new_sboard).sample
    cell = [3,0]
    guess = 8
    new_sboard[cell[0]][cell[1]] = guess
    puts "Coordinate: #{cell} Guess: #{guess}"
    return new_sboard if by_elimination(new_sboard) != -1
    return sboard
  end
end

class Board
  def initialize(n)
    @n = n
  end

  def self.from_file(file)
    new(file.map{|l|l.strip.gsub('_','0').gsub(' ','')}.join(''))
  end

  def to_number;@n;end
end
