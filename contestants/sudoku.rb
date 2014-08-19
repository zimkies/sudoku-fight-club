class Sudoku

  attr_accessor :aar
  def initialize(r)
    @aar = SBoard.aad(r)
  end
  def solve
    recursive_solve @aar.aae
  end
  def recursive_solve(aaq, depth=0)
    return aaq if aaq.aam
    return nil if aaq.aac

    aaa(aaq).each do |guess|
      aap = aaq.aae
      aap.aaq[guess[0]] = guess[1]
      solution =  recursive_solve(aap, depth+1)
      return solution if solution
    end

    return nil
  end

  def aaa(aaq)
    guesses = aab(aaq)
    return [] if guesses.length == 0
    guesses.select { |g| g[0] == guesses[0][0]}
  end

  def aab(aaq)
    aaq.aai.each_with_index.map { |a, i| [i, a] }
      .select { |i, a| aaq.aaq[i].nil? }
      .sort_by { |i, a| a.length }
      .map { |i, a| a.shuffle.map { |n| [i, n] } }
      .flatten(1)
  end
end

class SBoard
  attr_accessor :aaq

  def initialize
    @aaq = [nil] * 81
  end

  def to_number
    @aaq.map{ |s| s.nil? ? '-' : s.to_s }.join
  end

  def aac
    aai.each_with_index
      .select { |n, i| aaq[i].nil? }
      .any? { |n, i| n.length == 0 }
  end

  def self.aad(number)
    aap = new
    number.split('').each_with_index { |n, i| aap.aaq[i] = n.to_i if n != '-' }
    aap
  end

  def aae
    aap = self.class.new
    aaq.each_with_index do |n, i|
      aap.aaq[i] = n
    end
    aap
  end

  def aag
    [:row_col, :col_row, :box]
  end

  def aaf(x, y, aao=:row_col)
    @aaq[aah(x, y, aao)]
  end

  def aah(x, y, aao=:row_col)
    case aao
    when :row_col
      x * 9 + y
    when :col_row
      y * 9 + x
    when :box
      [0,3,6,27,30,33,54,57,60][x] + [0,1,2,9,10,11,18,19,20][y]
    end
  end

  def aaj(index)
    bits = 511
    aag.each do |c|
      axis_index = aan(index)
      bits &= aal(axis_index, c)
    end
    bits
  end

  def aak
    needed = []
    aag.each do |c|
      (0..8).each do |x|
        bits = aal(x, c)
        needed << bits
      end
    end
    needed
  end

  def aal(x, aao)
    bits = 0
    (0..8).each do |y|
      e = aaf(x, y, aao)
      bits |= 1 << e unless e.nil?
    end
    511 ^ bits
  end

  def aai
    aaj = @aaq.map { |n| n.nil? ? 511 : 0 }
    aag.each do |c|
      (0..8).each do |x|
        bits = aal(x, c)
        (0..8).each { |y| aaj[aah(x, y, c)] &= bits }
      end
    end
    aaj.map { |a| lok(a) }
  end

  def lok(bits)
    (0..8).select { |n| (bits & (1 << n)) != 0 }
  end

  def aam
    aak.all? { |bits| bits == 0 }
  end

  def aan(index, aao=:row_col)
    case aao
    when :row_col
      (index / 9)
    when :col_row
      index % 9
    when :box
      (index / 27) * 3 + (index / 3) % 3
    end
  end
end

