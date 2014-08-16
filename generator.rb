class Board
  def initialize
    @board = (0..8).map { |c| [nil]*8 }
  end
end


class BoardSolver

  def self.solve(board)
    self.new board
  end

  def initialize(board)
    @board = board
  end

  def solve
  end
end

class BoardGenerator

  def self.generate
  end
end
