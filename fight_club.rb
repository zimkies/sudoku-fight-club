#
# Represents a 9x9 Sudoku Board
#
#
class Board
  attr_accessor :board

  def initialize
    @board = [nil] * 81
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
      line.strip.split(' ').each_with_index do |n, i|
        new_board.board[y_ind * 9 + i] = n.to_i if n != '_'
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

  def print(handle)
    out = ""
    (0..8).each do |row|
      (0..8).each do |col|
        out += [""," "," ","  "," "," ","  "," "," "][col]
        out += print_number lookup(row, col)
      end
      out += ["\n","\n","\n\n","\n","\n","\n\n","\n","\n","\n"][row]
    end
    handle.puts out
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
    allowed
  end

  def solved?
    needed_numbers.all? { |bits| bits == 0 }
  end

  def blank?
    board.all? { |n| n.nil? }
  end

  # The printed version of our sudoku number
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

#
# Responsible for solving the puzzle as far as it can
# can be logically deduced without guessing
#
class PuzzleDeducer

  attr_accessor :board

  def initialize(board)
    @board = board
  end

  # Returns:
  #   a best guess for the next spot to try,
  #   or nil if it is solved
  #   or [] if it is in an invalid state (no legal moves)
  #
  # Deduction is done first by looking for direct conflicts at every spot
  # And then by eliminating other locations along a column.
  def deduce
    while true
      stuck, guess, count = true, nil, 0
      # fill in any spots determined by direct conflicts
      allowed = board.allowed_numbers
      (0..80).each do |index|
        if board.board[index].nil?
          numbers = bits_to_numbers(allowed[index])
          if numbers.size == 0
            return [] # Return nothing if no possibilitie E
          elsif numbers.size == 1
            board.board[index] = numbers[0]
            stuck = false
            break
          elsif stuck
            new_guesses = numbers.map { |n| [index, n] }
            guess, count = pickbetter(guess, count, new_guesses)
          end
        end
      end

      if !stuck
        allowed = board.allowed_numbers
      end
      needed = board.needed_numbers

      # fill in any spots determined by elimination of other locations.
      # For any given column, find which numbers it is missing,
      # And figure out which positions allow those numbers - if only
      # one position allows it, the number goes there.
      #
      # If more than one spot is available, add to the guesses.
      board.coordinate_systems.each do |axis|
        (0..8).each do |x|
          numbers = bits_to_numbers(needed[axis_index(x, axis)])
          numbers.each do |n|
            bit = 1 << n
            # spots =for this number & col, all positions that allow the needed
            # numbers
            spots = []

            (0..8).each do |y|
              index = board.index_for(x, y, axis)
              # if this position allows the needed number, add it to spots
              if allowed[index] & bit
                spots << index
              end
            end

            if spots.length == 0
              return []
            elsif spots.length == 1
              board.board[spots[0]] = n
              stuck = False
              break
            elsif stuck
              new_guesses = spots.map { |index| [index, n] }
              guess, count = pickbetter(guess, count, new_guesses)
            end
          end
        end
      end

      if stuck
        guess.shuffle! unless guess.nil?
        return guess
      end
    end
  end

  #  lookup an axis based on it's 0-9 index and coordinate system.
  def axis_index(index, coordinate_system)
    case coordinate_system
    when :row_col
      index
    when :col_row
      9 + index
    when :box
      18 + index
    end
  end

   # Return the list of numbers that a bitmask represents
  # eg bits_to_numbers(511) -> [0, 1, ... 8]
  def bits_to_numbers(bits)
    (0..8).select { |n| (bits & (1 << n)) != 0 }
  end

  # b is guess
  # c is count
  # t is a list of [(integer_position, allowed_number)]
  # SO t could be [(25, 1), (25, 2), (25, 8)]
  #
  # Returns (guess, count) eg ([(25, 1), (25, 2)], 1)
  # If we have no guess, just return the list of t with count 1
  # If we
  def pickbetter(b, c, t)
    if b.nil? || (t.length < b.length)
      [t, 1]
    elsif t.length > b.length
      [b, c]
    elsif rand(c + 1) == 0
      [t, c + 1]
    else
      [b, c + 1]
    end
  end
end

class PuzzleSolver
  attr_accessor :stack

  def initialize(board, stack=[])
    @starting_board = board
    @stack = stack
  end

  def solve
    board = @starting_board.duplicate
    guesses = PuzzleDeducer.new(board).deduce

    return board unless guesses

    @stack << [guesses, 0, board]
    solve_next[1]
  end

  # takes a stack of tuples [(guesses, guesses_index, board)]
  # returns [stack, solution]
  #
  # Uses DFS - keeps appending guesses to the stack. If there are
  # If we have gone through all guesses, ignore this board state
  # Otherwise put the next guess on the stack
  # Otherwise, try the current guess, deduce it (return if won),
  # and append each of it's guesses to the stack.
  def solve_next
    while stack.length > 0
      guesses, guesses_index, board = stack.pop
      # skip if all possible guesses at this level are done
      next if guesses_index >= guesses.size
      stack << [guesses, guesses_index + 1, board]
      board = board.duplicate
      guess = guesses[guesses_index]
      board.board[guess[0]] =  guess[1]
      guesses =  PuzzleDeducer.new(board).deduce
      return [stack, board] if guesses.nil?
      stack << [guesses, 0, board]
    end
    [[], nil]
  end

end

class PuzzleGenerator

  def generate_puzzle
    solution = generate_solution
    puzzle = []
    deduced = Board.new

    (0..80).to_a.shuffle.each do |index|
      if deduced.board[index].nil?
        puzzle << [index, solution.board[index]]
        deduced.board[index] = solution.board[index]
        PuzzleDeducer.new(deduced).deduce
      end
    end

    puzzle.shuffle!

    puzzle.reverse.each_with_index do |hint, i|
      puzzle.delete_at i
      rating = check_puzzle(board_from_entries(puzzle), solution)
      puzzle << hint if rating == -1
    end

    sudoku = board_from_entries puzzle
    sudoku
  end

  private

  def board_from_entries(entries)
    board = Board.new
    entries.each do |entry|
      index, n = entry
      board.board[index] = n
    end
    board
  end

  def generate_solution(seed_board=nil)
    PuzzleSolver.new(seed_board || Board.new).solve
  end

  # Returns the difficulty rating of a puzzle or -1 if it is not valid.
  # Takes an option 'board' parameter which is the puzzle's solution.
  #
  # If you pass in a solution, it checks that our solver gives that solution.
  # It also makes sure that there are no alternative solutions by solving
  # from the remaining state.
  def check_puzzle(puzzle, board=Nil)
    solver = PuzzleSolver.new(puzzle)
    answer = solver.solve
    stack = solver.stack

    if answer.nil?
      return -1
    end
    if !board.nil? && !board_matches(board, answer)
      return -1
    end
    difficulty = stack.length
    state, second = PuzzleSolver.new(board, stack).solve_next # TODO CLEANUP
    if !second.nil?
      return -1
    end

    difficulty
  end

  # Tests equivalence of 2 boards.
  def board_matches(b1, b2)
    b1.board == b2.board
  end
end
