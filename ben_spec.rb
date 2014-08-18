require 'minitest/spec'
require 'minitest/autorun'
require './contestants/ben'

describe BenSolver do

  let(:solver) { BenSolver.new(number) }

  describe "#solve" do
    subject { solver.solve }
    let(:number) { "-581---32-3---7-5-------8-657-832--------1-8--84--527----6----8-47--------23-04--" }

    describe "with an easy board" do

      it "should return a board" do
        subject.must_be_instance_of Board
      end

      it "should return a solve board" do
        subject.solved?.must_equal true
      end
    end

    describe "with a blank board" do
      subject { solver.solve }
      let(:board) { Board.new }

      it "should return a board" do
        subject.must_be_instance_of Board
      end

      it "should return a solved board" do
        subject.solved?.must_equal true
      end
    end
  end
end
