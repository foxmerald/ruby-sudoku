# frozen_string_literal: true

# This class is responsible for generating a complete Sudoku board and then removing digits
# to create a puzzle based on the selected difficulty level.
class SudokuGenerator
  attr_reader :board, :solution, :initial_board

  def initialize
    prepare_board
    @solution = nil
    @initial_board = nil
  end

  def run(difficulty, reset: false)
    prepare_board if reset

    fill_diagonal_boxes
    fill_remaining(0, 3)

    # Save the solution
    @solution = @board.map(&:dup)

    # 3. Remove digits to create the puzzle
    remove_digits(difficulty)

    # Save the initial puzzle state (immutable cells)
    @initial_board = @board.map(&:dup)
  end

  private

  # Creates an empty 9x9 board filled with zeros
  def prepare_board
    @board = Array.new(9) { Array.new(9, 0) }
  end

  # Fill diagonal 3x3 boxes independent of each other
  def fill_diagonal_boxes
    (0...9).step(3) do |x|
      fill_box(x, x)
    end
  end

  # Fill a 3x3 box starting at (row_start, column_start) with random numbers
  def fill_box(row_start, column_start)
    num = 0
    (0...3).each do |x|
      (0...3).each do |y|
        loop do
          num = rand(1..9)
          break if unused_in_box?(row_start, column_start, num)
        end

        @board[row_start + x][column_start + y] = num
      end
    end
  end

  # Check if a number is not used in the 3x3 box yet
  def unused_in_box?(row_start, column_start, num)
    (0...3).each do |x|
      (0...3).each do |y|
        return false if @board[row_start + x][column_start + y] == num
      end
    end

    true
  end

  # Check if it's safe to place a number in the given cell
  def safe?(x, y, num)
    return false if used_in_row?(x, num)
    return false if used_in_col?(y, num)
    return false unless unused_in_box?(x - x % 3, y - y % 3, num)

    true
  end

  def used_in_row?(x, num)
    (0...9).any? { |y| @board[x][y] == num }
  end

  def used_in_col?(y, num)
    (0...9).any? { |x| @board[x][y] == num }
  end

  # Fill the remaining cells
  def fill_remaining(x, y)
    # Check if end of row and column reached
    return true if y >= 9 && x >= 8

    # Move to the next row if we reached the end of the current row
    if y >= 9
      x += 1
      y = 0
    end

    # Skip cells that are already filled (like the diagonal boxes)
    return fill_remaining(x, y + 1) if @board[x][y].nonzero?

    # Try placing numbers 1-9 in the current cell and recursively fill the next cells
    (1..9).each do |num|
      next unless safe?(x, y, num)

      @board[x][y] = num
      return true if fill_remaining(x, y + 1)

      @board[x][y] = 0
    end

    false
  end

  # Remove digits from the filled board based on the difficulty level
  def remove_digits(difficulty)
    count = case difficulty
    when "easy" then 30
    when "moderate" then 45
    when "hard" then 55
    end

    while count.positive?
      x = rand(0...9)
      y = rand(0...9)

      if @board[x][y].nonzero?
        @board[x][y] = 0
        count -= 1
      end
    end
  end
end
