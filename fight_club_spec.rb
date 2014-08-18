require 'minitest/autorun'
require 'minitest/spec'
require './fight_club'

describe PuzzleGenerator do
  let(:puzzle_generator) { PuzzleGenerator.new }

  describe "#generate_puzzle" do
    subject { puzzle_generator.generate_puzzle }

    it "creates a board" do
      subject.must_be_kind_of DefaultBoard
    end

    it "creates a non-solved board" do
      subject.solved?.must_equal false
    end

    it "creates a non-blank board" do
      subject.blank?.must_equal false
    end
  end
end

describe PuzzleDeducer do
  let(:deducer) { PuzzleDeducer.new(board) }
  let(:board) { DefaultBoard.new }

  describe "#bits_to_numbers" do
    subject { deducer.bits_to_numbers(number) }

    describe "with 511" do
      let(:number) { 511 }
      it "converts correctly" do
        subject.must_equal [0, 1, 2, 3, 4, 5, 6, 7, 8]
      end
    end
  end
end

describe PuzzleSolver do

  let(:solver) { PuzzleSolver.new(board) }

  describe "#solve" do
    describe "with a blank board" do
      subject { solver.solve }
      let(:board) { DefaultBoard.new }

      it "should return a board" do
        subject.must_be_instance_of DefaultBoard
      end

      it "should return a solved board" do
        subject.solved?.must_equal true
      end
    end
  end
end

describe DefaultBoard do
  let(:board) { DefaultBoard.from_number number }
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

  describe '#solved?' do

    it 'works for a solved board' do
      board.solved?.must_equal true
    end

    describe "fails for a board that is incomplete" do
      let(:number) { '13-856072706312458528470631813205746240768315675134280067541823452083167381627504' }
      it 'fails' do
        board.solved?.must_equal false
      end
    end

    describe "fails for a board with a 9" do
      let(:number) { '934856072706312458528470631813205746240768315675134280067541823452083167381627504' }
      it 'fails' do
        board.solved?.must_equal false
      end
    end

    describe "fails for a board which has conflicts" do
      let(:number) { '334856072706312458528470631813205746240768315675134280067541823452083167381627504' }
      it 'fails' do
        board.solved?.must_equal false
      end
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
    let(:board) { DefaultBoard.new }

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
    subject { board.solved? }
    it "returns true" do
      board.solved?.must_equal true
    end

    describe 'with number conflict' do
      let(:number) { '234856072706312458528470631813205746240768315675134280067541823452083167381627504' }

      it 'returns false' do
        board.solved?.must_equal false
      end
    end

    describe "with a duplication" do
      let(:number) { "375016432026458701184723856648302517702541683531687240860174325453260178217835064" }

      it 'returns false' do
        board.solved?.must_equal false
      end
    end
  end

  describe "#duplicate" do
    subject { board.duplicate }

    it "returns a board" do
      subject.duplicate.must_be_instance_of DefaultBoard
    end

    it "copies the board" do
      subject.duplicate.board.must_equal board.board
    end

    it "doesn't keep the same board object" do
      subject.duplicate.board.wont_be_same_as board.board
    end
  end
end
