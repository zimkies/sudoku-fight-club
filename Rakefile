require './fight_club'
require 'benchmark'

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

namespace :solution do
  task :length, [:team_name] do |t,args|
    args.with_defaults(team_name: 'fake_team')
    files = []
    file_path = File.dirname(__FILE__) + "/contestants/#{args.team_name}.rb"
    folder_path = File.dirname(__FILE__) + "/contestants/#{args.team_name}"
    if File.file?(file_path)
      files << File.open(file_path)
    end

    if File.directory?(folder_path)
      Dir.foreach(folder_path) do |item|
        next if item == '.' or item == '..'
        files << File.open(File.join(folder_path, item))
      end
    end

    if files.empty?
      raise "Could not find an entry for team name: #{args.team_name}"
    end

    char_count = 0
    files.each do |file|
      solution = file.read
      solution.gsub(/\s/,"")
      char_count += solution.length
    end

    puts "-----------------------------------------------"
    puts "| Congratulations, we've read your solution    "
    puts "| Total characters: #{char_count}              "
    puts "-----------------------------------------------"
  end

  # Raises an error if a solution is not valid
  task :verify, [:solution_class, :input] do |t,args|
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

    # Load all the contestants
    Dir["./contestants/*.rb"].each {|file| require file }

    begin
      SolutionClass = Kernel.const_get(args.solution_class)
    rescue LoadError => e
      raise "Couldn't load Solution Class. Is it defined in ./contestants/?", e
    end

    total_time = 0
    all_files.each do |file|
      board = Board.from_file(file)
      solution = nil
      measure = Benchmark.measure do
        solution = SolutionClass.new(board.to_number).solve
      end
      total_time += measure.real
      solved = DefaultBoard.from_number(solution.to_number).solved?
      raise "Solution is not valid:\nPUZZLE: \n#{board.to_s}\nSOLUTION: \n#{solution.to_s}" if not solved
    end
    average_time = all_files.length == 0 ? 0 : total_time / all_files.length
    puts "All #{all_files.count} test puzzles were correctly solved in an average of #{average_time} seconds"
  end
end

task default: 'puzzle:generate'
