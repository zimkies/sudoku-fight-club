class Board
  attr_accessor :board
  def initialize
    @board = [nil] * 81
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

  def print
    out = ""
    (0..8).each do |row|
      (0..8).each do |col|
        out += [""," "," ","  "," "," ","  "," "," "][col]
        out += print_number lookup(row, col)
      end
      out += ["\n","\n","\n\n","\n","\n","\n\n","\n","\n","\n"][row]
    end
    puts out
  end

  # The printed version of our heroku number
  def print_number(number)
    number.nil? ? "_" : (number + 1).to_s
  end

  def self.from_number(number)
    raise 'Number must be of length 81' unless number.size == 81
    new_board = new
    number.split('').each_with_index { |n, i| new_board.board[i] = n.to_i if n != '-' }
    new_board
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

  def coordinate_systems
    [:row_col, :col_row, :box]
  end

  # Return the list of numbers that a bitmask represents
  # eg bits_to_numbers(511) -> [0, 1, ... 8]
  def bits_to_numbers(bits)
    (0..8).select { |n| (bits & (1 << n)) == 1 }
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
end

class PuzzleSolver

  def initialize(board)
    @starting_board = board
    @guess_stack = []
  end

  def solve
    board = @starting_board.duplicate
    guesses = deduce(board)

    return [[], board][1] unless guesses

    solve_next([[guesses, 0, board]])[1]
  end

  # deduce(board):
  # Take a board and solve it as far as can be deduced without guessing.
  # Returns:
  #   a best guess for the next spot to try,
  #   or None if it is solved
  #   or [] if it is in an invalid state (no legal moves)
  #
  # Deduction is done first by looking for direct conflicts at every spot
  # And then by eliminating other locations along a column.
  def deduce(board)
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
          numbers = bits_to_numbers(needed[needed_index(x, axis)])
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

 # Return the list of numbers that a bitmask represents
  # eg bits_to_numbers(511) -> [0, 1, ... 8]
  def bits_to_numbers(bits)
    (0..8).select { |n| (bits & (1 << n)) != 0 }
  end

  # takes a stack of tuples [(guesses, guesses_index, board)]
  # returns [stack, solution]
  #
  # Uses DFS - keeps appending guesses to the stack. If there are
  # If we have gone through all guesses, ignore this board state
  # Otherwise put the next guess on the stack
  # Otherwise, try the current guess, deduce it (return if won),
  # and append each of it's guesses to the stack.
  def solve_next(stack)
    while stack.length > 0
      guesses, guesses_index, board = stack.pop
      # skip if all possible guesses at this level are done
      next if guesses_index >= guesses.size
      stack << [guesses, guesses_index + 1, board]
      board = board.duplicate
      guess = guesses[guesses_index]
      # p "assigning #{guess}"
      board.board[guess[0]] =  guess[1]
      guesses = deduce(board)
      p "board #{board.to_number}"
      return [stack, board] if guesses.nil?
      stack << [guesses, 0, board]
    end
    [[], Nil]
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

  # TODO rename
  def needed_index(index, coordinate_system)
    case coordinate_system
    when :row_col
      index
    when :col_row
      9 + index
    when :box
      18 + index
    end
  end
end

class PuzzleGenerator

  def generate_puzzle
    solution = generate_solution
  end

  private

  def generate_solution
  end
end
