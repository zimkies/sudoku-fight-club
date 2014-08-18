## Sudoku Fight Club
A project for finding the fastest and shortest ruby programs to solve sudoku puzzles.

### Instructions
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

### Testing
Run the following command to test the codebase
```ruby
ruby fight_club_spec.rb
```
