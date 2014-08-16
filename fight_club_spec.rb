require 'minitest/spec'
require 'minitest/autorun'
require './generator'

describe PuzzleGenerator do
  let(:puzzle_generator) { BoardGenerator.new }

  describe "#generate_solution" do
    let(:board) { puzzle_generator.generate_solution }

    it "creates a board" do
      board.must_be_kind_of Board
    end

    it "creates a valid board" do
      board.valid?.must_equal true
    end
  end

 describe "#generate_puzzle" do
    let(:board) { BoardGenerator.new.generate_puzzle }

    it "creates a new board" do
      pending
      board.must_be_kind_of Board
    end
  end
end


describe Board do
  let(:board) { Board.from_number number }
  let(:number) { '134856072706312458528470631813205746240768315675134280067541823452083167381627504' }

  describe "#valid?" do
    it "is valid" do
      board.valid?.must_equal true
    end

    describe 'double number' do
      let(:number) { '234856072706312458528470631813205746240768315675134280067541823452083167381627504' }
      it 'is invalid' do
        board.valid?.must_equal false
      end
    end
  end

  describe '#lookup' do
    it 'works for row_col' do
      board.lookup(1, 0, :row_col).must_equal "7"
    end
    it 'works for col_row' do
      board.lookup(0, 1, :col_row).must_equal "7"
    end
    it 'works for box' do
      board.lookup(0, 3, :box).must_equal "7"
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
end
