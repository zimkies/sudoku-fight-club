#
# Skeleton working solver
#
class SkeletonSolver

  attr_accessor :starting_board, :raw_board

  # Takes a sudoku represented by 81 character string.
  #
  # The string is read left to right, top to bottom.
  # The digits 0-8 represent filled in sudoku digits
  # The character '-' represents a blank space
  # eg
  # Example puzzle input "1--856-72---3124--52-470631-132-5--62--7-83156751342800675418234520-316738162-504"
  def initialize(raw_board)
    @starting_board = Board.from_number(raw_board)
  end

  # Returns a string representing the solved solution according to the
  # above format
  def solve
    recursive_solve @starting_board.duplicate
  end

  def recursive_solve(board, depth=0)
    return board if board.solved?
    return nil if board.invalid?

    top_ordered_guesses(board).each do |guess|
      new_board = board.duplicate
      new_board.board[guess[0]] = guess[1]
      solution =  recursive_solve(new_board, depth+1)
      return solution if solution
    end

    return nil
  end

  def top_ordered_guesses(board)
    guesses = ordered_guesses(board)
    return [] if guesses.length == 0
    guesses.select { |g| g[0] == guesses[0][0]}
  end

  def ordered_guesses(board)
    board.allowed_numbers.each_with_index.map { |a, i| [i, a] } # index
      .select { |i, a| board.board[i].nil? }
      .sort_by { |i, a| a.length } # sort by length of guesses
      .map { |i, a| a.shuffle.map { |n| [i, n] } } # shuffle guess
      .flatten(1)
  end
end

class Board
  attr_accessor :board

  def initialize
    @board = [nil] * 81
  end

  # The board has a direct conflict
  def invalid?
    allowed_numbers.each_with_index
      .select { |n, i| board[i].nil? }
      .any? { |n, i| n.length == 0 }
  end

  def self.from_number(number)
    raise 'Number must be of length 81' unless number.size == 81
    new_board = new
    number.split('').each_with_index { |n, i| new_board.board[i] = n.to_i if n != '-' }
    new_board
  end

  def self.from_file(file)
    new_board = new
    x_ind = 0
    y_ind = 0
    file.each_line do |line|
      next if line.strip == ''
      line.strip.split(' ').each_with_index do |n, i|
        new_board.board[y_ind * 9 + i] = (n.to_i - 1) if n != '_'
      end
      y_ind += 1
    end
    new_board
  end

  def duplicate
    new_board = self.class.new
    board.each_with_index do |n, i|
      new_board.board[i] = n
    end
    new_board
  end

  def to_number
    @board.map{ |s| s.nil? ? '-' : s.to_s }.join
  end

  def print(handle=$stdout)
    handle.puts to_s
  end

  def to_s
    out = ""
    (0..8).each do |row|
      (0..8).each do |col|
        out += [""," "," ","  "," "," ","  "," "," "][col]
        out += print_number lookup(row, col)
      end
      out += ["\n","\n","\n\n","\n","\n","\n\n","\n","\n","\n"][row]
    end
    out
  end

  # 3 different co-ordinate systems for lookups
  def coordinate_systems
    [:row_col, :col_row, :box]
  end

  # Looks up the value at (x,y) on the relevant coordinate_system
  # 0: (row, column)
  # 1: (column, row)
  # 2: (box number, element number. left->right, top->down)
  def lookup(x, y, coordinate_system=:row_col)
    @board[index_for(x, y, coordinate_system)]
  end

  # Calculate the index at (x,y) in the relevant coordinate_system
  # 0: (row, column)
  # 1: (column, row)
  # 2: (box number, element number. left->right, top->down)
  def index_for(x, y, coordinate_system=:row_col)
    case coordinate_system
    when :row_col
      x * 9 + y
    when :col_row
      y * 9 + x
    when :box
      [0,3,6,27,30,33,54,57,60][x] + [0,1,2,9,10,11,18,19,20][y]
    end
  end

  # All allowed numbers for that position given the other numbers
  # along it's axes.
  # Returned as a bitmask (number)
  # eg 214
  def allowed(index)
    bits = 511
    coordinate_systems.each do |c|
      axis_index = first_axis_index(index)
      bits &= axis_missing(axis_index, c)
    end
    bits
  end

  # Takes a board and returns in bitmask format:
  #   needed: A list of missing numbers for each row/axis combination
  #   eg [123, 511, 234, 1 ...] columns, then rows, then boxes. (Should be 27)
  def needed_numbers
    needed = []
    coordinate_systems.each do |c|
      (0..8).each do |x|
        bits = axis_missing(x, c)
        needed << bits
      end
    end
    needed
  end

  # bitmask of which numbers are accounted for in this row
  # eg 234 (in binary 01110101101)
  def axis_missing(x, coordinate_system)
    bits = 0
    (0..8).each do |y|
      e = lookup(x, y, coordinate_system)
      bits |= 1 << e unless e.nil?
    end
    511 ^ bits
  end

  # Takes a board and returns in bitmask format:
  #   allowed: A list of all directly allowed numbers for each position
  #     eg [123, 231, 231 ...] 81 of them in linear order.
  def allowed_numbers
    allowed = @board.map { |n| n.nil? ? 511 : 0 }
    coordinate_systems.each do |c|
      (0..8).each do |x|
        bits = axis_missing(x, c)
        (0..8).each { |y| allowed[index_for(x, y, c)] &= bits }
      end
    end
    allowed.map { |a| bits_to_numbers(a) }
  end

  def bits_to_numbers(bits)
    (0..8).select { |n| (bits & (1 << n)) != 0 }
  end

  def solved?
    needed_numbers.all? { |bits| bits == 0 }
  end

  def blank?
    board.all? { |n| n.nil? }
  end

  # The printed version of our heroku number
  def print_number(number)
    number.nil? ? "_" : (number + 1).to_s
  end

  # what is first co-ordinate of position in this axis
  def first_axis_index(index, coordinate_system=:row_col)
    case coordinate_system
    when :row_col
      (index / 9)
    when :col_row
      index % 9
    when :box
      (index / 27) * 3 + (index / 3) % 3
    end
  end
end

