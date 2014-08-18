require './fight_club'

namespace :puzzle do
  desc "Generate a puzzle"
  task :generate, [:number, :destination] do |t, args|
    args.with_defaults(number: 1, destination: $stdout)
    is_directory = false
    is_file = false

    if args.destination != $stdout
      if File.directory?(args.destination)
        is_directory = true
      elsif File.file?(args.destination) || !args.destination.empty?
        is_file = true
        raise "Can't write multiple puzzles to the same file" unless args.number.to_i <= 1
      end
    end

    args.number.to_i.times do |i|
      puzzle = PuzzleGenerator.new.generate_puzzle
      output = begin
        if is_directory
          File.new(File.join(args.destination, "sudoku#{i}.txt"), 'w')
        elsif is_file
          File.new(args.destination, 'w')
        else
          args.destination
        end
      end
      puzzle.print(output)
    end
  end

  task :solve, [:input] do |t,args|
    args.with_defaults(input: 'puzzle.txt')
    all_files = []

    if File.directory?(args.input)
      Dir.foreach(args.input) do |item|
        next if item == '.' or item == '..'
        all_files << File.open(File.join(args.input, item))
      end
    elsif File.file?(args.input)
      all_files << File.open(args.input)
    else
      raise "Must enter a valid file, or puzzle.txt must exist"
    end

    all_files.each do |file|
      solver = PuzzleSolver.new(Board.from_file(file))
      puts solver.solve
    end
  end
end

task default: 'puzzle:generate'
