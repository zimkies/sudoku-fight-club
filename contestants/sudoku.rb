class Sudoku
  attr_accessor :board
  def initialize(board_string)
    @board_string = parse(board_string)
    @board_string = @board_string.split("")
    @board = Array.new(9) { Array.new(9)}

    build_board
    @boxes = [[[0,0],[1,0],[2,0],[0,1],[1,1],[2,1],[0,2],[1,2],[2,2]],
              [[3,0],[4,0],[5,0],[3,1],[4,1],[5,1],[3,2],[4,2],[5,2]],
              [[6,0],[7,0],[8,0],[6,1],[7,1],[8,1],[6,2],[7,2],[8,2]],
              [[0,3],[1,3],[2,3],[0,4],[1,4],[2,4],[0,5],[1,5],[2,5]],
              [[3,3],[4,3],[5,3],[3,4],[4,4],[5,4],[3,5],[4,5],[5,5]],
              [[6,3],[7,3],[8,3],[6,4],[7,4],[8,4],[6,5],[7,5],[8,5]],
              [[0,6],[1,6],[2,6],[0,7],[1,7],[2,7],[0,8],[1,8],[2,8]],
              [[3,6],[4,6],[5,6],[3,7],[4,7],[5,7],[3,8],[4,8],[5,8]],
              [[6,6],[7,6],[8,6],[6,7],[7,7],[8,7],[6,8],[7,8],[8,8]]]
  end

  def valid_move?(num,x,y)
    return false if in_row?(num, x, y)
    return false if in_col?(num, x, y)
    return false if in_box?(num, x, y)
    true
  end

  # -128676758
  def parse board
    board.split('').map { |c| c == '-' ? 0 : c.to_i + 1}.join
  end

  def solve
    solve!
    to_s
  end

  def solve!(x=0,y=0)
    if y == 9
      y = 0
      x += 1
    end
    if x == 9
      return true
    end
    if board[x][y] == 0
      (1..9).each do |try|
        board[x][y] = try
        if valid_move?(try,x,y)
          return true if solve!(x,y+1)
        end
        board[x][y] = 0
      end
    else
      return true if solve!(x,y+1)
    end
    false
  end

  def build_board
    9.times{|x|
      row = @board_string.shift(9)
      9.times{|y|
        board[x][y] = row[y].to_i
      }
    }
  end

  def in_row?(num,x,y)
    9.times{|index| return true if board[x][index] == num && index != y }
    false
  end

  def in_col?(num,x,y)
    9.times{|index| return true if @board[index][y] == num && index != x }
    false
  end

  def in_box?(num,x,y)
    check_box = @boxes.select{ |box| box.include?([x,y]) }[0]
    check_box.each{ |ix,iy| return true if @board[ix][iy] == num  &&  ix != x && iy != y}
    false
  end

  def to_s
    @board.flatten.map{|c| c - 1 }.join
  end
end