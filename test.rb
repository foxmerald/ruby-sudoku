# frozen_string_literal: true

puts "Starting test execution..."
require_relative "sudoku_generator"

class SudokuTester
  def self.run
    new.run_tests
  end

  def run_tests
    puts "Running Sudoku Tests..."

    # 1. Initialization
    setup
    test_initialization

    # 2. Structure & Generation
    setup
    test_structure

    # 3. Difficulty Levels
    setup
    test_difficulties

    # 4. Validity
    setup
    test_solution_validity

    # 5. Immutability
    setup
    test_immutability

    puts "\n🎉 All tests passed successfully!"
  rescue StandardError => e
    puts "\n❌ Test Failed: #{e.message}"
    puts e.backtrace
    exit(1)
  end

  private

  def setup
    @generator = SudokuGenerator.new
  end

  def assert(condition, message = "Assertion failed")
    unless condition
      raise "Assertion Failed: #{message}"
    end

    print(".")
  end

  def assert_equal(expected, actual, message = nil)
    msg = message || "Expected #{expected.inspect}, got #{actual.inspect}"
    unless expected == actual
      raise "Assertion Failed: #{msg}"
    end

    print(".")
  end

  def test_initialization
    assert_equal(9, @generator.board.length, "Board rows should be 9")
    assert_equal(9, @generator.board[0].length, "Board cols should be 9")
    # Actually, initialize sets @board to array of 9 arrays of 9 zeros.
    assert_equal(0, @generator.board[0][0], "Initial board cell should be 0")
  end

  def test_structure
    @generator.generate("easy")
    assert_equal(9, @generator.board.length)
    assert_equal(9, @generator.board[0].length)

    flattened_sol = @generator.solution.flatten
    assert(flattened_sol.none? { |x| x == 0 }, "Solution should be fully filled")
    assert_equal(81, flattened_sol.length)
  end

  def test_difficulties
    # Test Easy
    @generator.generate("easy")
    holes = @generator.board.flatten.count(0)
    assert_equal(30, holes, "Easy difficulty hole count mismatch")

    # Test Moderate
    @generator.generate("moderate")
    holes = @generator.board.flatten.count(0)
    assert_equal(45, holes, "Moderate difficulty hole count mismatch")

    # Test Hard
    @generator.generate("hard")
    holes = @generator.board.flatten.count(0)
    assert_equal(55, holes, "Hard difficulty hole count mismatch")
  end

  def test_solution_validity
    @generator.generate("easy")
    sol = @generator.solution # Access the stored solution

    # Rows
    sol.each do |row|
      assert_equal((1..9).to_a, row.sort, "Row check failed: #{row}")
    end

    # Columns
    (0...9).each do |j|
      col = sol.map { |row| row[j] }
      assert_equal((1..9).to_a, col.sort, "Column check failed for col #{j}")
    end

    # Boxes
    (0...9).step(3) do |row_start|
      (0...9).step(3) do |col_start|
        box = []
        (0...3).each do |i|
          (0...3).each do |j|
            box << sol[row_start + i][col_start + j]
          end
        end
        assert_equal((1..9).to_a, box.sort, "Box check failed at #{row_start},#{col_start}")
      end
    end
  end

  def test_immutability
    @generator.generate("easy")
    initial = @generator.initial_board
    current = @generator.board

    # Content should match initially
    assert_equal(current, initial, "Initial board content mismatch")

    # References should differ (deep copy check)
    assert(current.object_id != initial.object_id, "Board object reference should be different")
    assert(current[0].object_id != initial[0].object_id, "Row object reference should be different")
  end
end

if __FILE__ == $0
  SudokuTester.run
end
