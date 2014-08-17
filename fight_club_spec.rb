require 'minitest/spec'
require 'minitest/autorun'
require './generator'

# describe PuzzleGenerator do
#   let(:puzzle_generator) { BoardGenerator.new }

#   describe "#generate_solution" do
#     let(:board) { puzzle_generator.generate_solution }

#     it "creates a board" do
#       board.must_be_kind_of Board
#     end

#     it "creates a valid board" do
#       board.valid?.must_equal true
#     end
#   end

#  describe "#generate_puzzle" do
#     let(:board) { BoardGenerator.new.generate_puzzle }

#     it "creates a new board" do
#       pending
#       board.must_be_kind_of Board
#     end
#   end
# end

describe PuzzleSolver do

  let(:solver) { PuzzleSolver.new(board) }

  describe "#solve" do
    describe "with a blank board" do
      subject { solver.solve }
      let(:board) { Board.new }

      it "should return a board" do
        subject.must_be_instance_of Board
      end

      it "should return a solved board" do
        subject.solved?.must_equal true
        p subject
        p subject.needed_numbers
      end
    end
  end

  describe "#bits_to_numbers" do
    subject { PuzzleSolver.new(Board.new).bits_to_numbers(number) }

    describe "with 511" do
      let(:number) { 511 }
      it "converts correctly" do
        subject.must_equal [0, 1, 2, 3, 4, 5, 6, 7, 8]
      end
    end
  end
end


describe Board do
  let(:board) { Board.from_number number }
  let(:number) { '134856072706312458528470631813205746240768315675134280067541823452083167381627504' }

  describe '#lookup' do
    it 'works for row_col' do
      board.lookup(1, 0, :row_col).must_equal 7
    end
    it 'works for col_row' do
      board.lookup(0, 1, :col_row).must_equal 7
    end
    it 'works for box' do
      board.lookup(0, 3, :box).must_equal 7
    end
  end


  describe '#first_axis_index' do
    it 'works for row_col' do
      board.first_axis_index(36, :row_col).must_equal 4
    end

    it 'works for col_row' do
      board.first_axis_index(36, :col_row).must_equal 0
    end

    it 'works for box' do
      board.first_axis_index(36, :box).must_equal 3
    end
  end

  describe "#needed_numbers" do
    let(:board) { Board.new }

    it "returns all 511s" do
      board.needed_numbers.must_equal [511]*27
    end
  end

  describe "#axis_missing" do
    let(:number) { '---856072706312458528470631813205746240768315675134280067541823452083167381627504' }
    subject { board.axis_missing(0, :row_col) }

    it "misses 1,3,4" do
      subject.must_equal 26
    end

  end

  describe "#solved?" do
    it "returns true" do
      board.solved?.must_equal true
    end

    describe 'with number conflict' do
      let(:number) { '234856072706312458528470631813205746240768315675134280067541823452083167381627504' }
      it 'returns false' do
        board.solved?.must_equal false
      end
    end
  end
end
