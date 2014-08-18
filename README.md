## Sudoku Fight Club
A project for finding the fastest and shortest ruby programs to solve sudoku puzzles.

### Instructions

- Create a fork of the project [here](https://github.com/zimkies/sudoku-fight-club)
- Give your self a team name and copy `contestants/skeleton.rb` into `contestants/team_name.rb`.  You're also permitted to put any files you want in `contestants/team_name/`.
- Come up with the fastest or shortest solution you can and submit a pull request
- Profit

Create a new puzzle with:
```
# Create a single puzzle and prints it to stdout
rake puzzle:generate
# Create 2 puzzles and prints them to stdout
rake puzzle:generate[2]
# Create one puzzle and prints it into the file puzzle.txt
rake puzzle:generate[1,puzzle.txt]
# Create 3 puzzles and places them in files called sudoku0.txt...sudoku2.txt in the directory puzzles
rake puzzle:generate[3,puzzles]
```

Solve existing puzzles with
```
# Solve the puzzle in ./puzzle.txt
rake puzzle:solve
# Solve the puzzle in dir/my_puzzle.txt
rake puzzle:solve[dir/my_puzzle.txt]
# Solve all puzzles in the puzzle directory
rake puzzle:solve[puzzle]
```

Test the length of your solution
```
# Set a team name, checks for team_name.rb and team_name/ in
# the contestants/ directory and sums the length
rake solution:length[skeleton]
```

Test the speed of your solution
```
# Test your solution against puzzle.txt and print the time
rake solution:verify[SkeletonSolver]
# Test your solution against all the provided puzzles and print the average time
rake solution:verify[SkeletonSolver,puzzles]
```

### Testing
Run the following command to test the codebase
```ruby
ruby fight_club_spec.rb
```
