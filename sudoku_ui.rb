# frozen_string_literal: true

require "io/console"

class SudokuUI
  # ANSI Colors
  RESET       = "\e[0m" # Reset all attributes
  CURSOR      = "\e[7m" # Inverted colors
  RED         = "\e[31m"
  GREEN       = "\e[32m"
  YELLOW      = "\e[33m"
  BLUE        = "\e[34m"
  MAGENTA     = "\e[35m"
  CYAN        = "\e[36m"
  WHITE       = "\e[37m"
  GRAY        = "\e[90m"
  # Input keys
  BACKSPACE   = "\177"
  DELETE      = "\004"
  ARROW_UP    = "\e[A"
  ARROW_DOWN  = "\e[B"
  ARROW_LEFT  = "\e[D"
  ARROW_RIGHT = "\e[C"
  # Unicode
  HYPHEN      = "\u2013"

  def initialize(generator, difficulty)
    @generator = generator
    @board = generator.board
    @solution = generator.solution
    @initial_board = generator.initial_board
    @difficulty = difficulty
    @cursor_x = 0
    @cursor_y = 0
    @message = ""
  end

  def start
    loop do
      render

      action = handle_input
      break if action == :quit

      next unless action == :new

      @generator.run(@difficulty, reset: true)
      @board = @generator.board
      @solution = @generator.solution
      @initial_board = @generator.initial_board
      @message = "New Game Started!"
    end
  end

  private

  def render
    system("clear") || system("cls")

    # Header
    puts ""

    board_lines = []

    # Top border
    board_lines << border_line(0)

    # Rows with borders
    (0...9).each do |i|
      board_lines.concat(generate_row_lines(i))
    end

    # Print sudoku board and sidebar
    board_lines.each_with_index do |board_line, i|
      sidebar_line = sidebar[i] || ""
      puts "#{board_line}   #{sidebar_line}"
    end
  end

  # Sidebar content
  def sidebar
    [
      "#{GREEN}RUBY SUDOKU#{RESET}",
      "#{CYAN}difficulty: #{@difficulty}#{RESET}",
      "",
      "#{GREEN}Movement#{RESET}",
      "  Arrows - Move",
      "",
      "#{GREEN}Commands#{RESET}",
      "  1-9 - Enter Number",
      "  c   - Submit Solution",
      "  x   - Delete Number",
      "  n   - New Game",
      "  q   - Quit",
      "",
      @message.to_s,
    ]
  end

  def border_line(row_index)
    # Determine if it's a outer or inner line
    is_major_row = (row_index % 3 == 0)
    horizontal_color = is_major_row ? GREEN : BLUE

    # Left border is always green (major vertical)
    line = "#{GREEN}+#{RESET}"

    9.times do |j|
      line += "#{horizontal_color}#{HYPHEN * 5}#{RESET}"

      # Intersection:
      # Major column boundaries (3, 6, 9) are always green.
      # Minor column boundaries follow the row color (green if major row, blue if minor row).
      is_major_col = ((j + 1) % 3 == 0)
      sep_color = is_major_col ? GREEN : horizontal_color

      line += "#{sep_color}+#{RESET}"
    end
    line
  end

  def generate_row_lines(i)
    lines = []

    # Row content
    line = ""
    (0...9).each do |j|
      line += vertical_separator(j)
      line += cell_content(i, j)
    end

    # Final vertical separator
    line += "#{GREEN}|#{RESET}"
    lines << line

    # Bottom border for this row
    lines << border_line(i + 1)

    lines
  end

  def vertical_separator(j)
    j % 3 == 0 ? "#{GREEN}|#{RESET}" : "#{BLUE}|#{RESET}"
  end

  def cell_content(i, j)
    val = @board[i][j]
    display_val = val == 0 ? " " : val.to_s

    cursor_position = i == @cursor_y && j == @cursor_x
    prefilled_number = @initial_board[i][j] != 0

    # Color
    if cursor_position
      "#{CURSOR}  #{display_val}  #{RESET}"
    elsif prefilled_number
      "  #{display_val}  "
    else
      # User input
      "  #{YELLOW}#{display_val}#{RESET}  "
    end
  end

  def handle_input
    key = read_key
    @message = ""

    case key
    when ARROW_UP then move_up
    when ARROW_DOWN then move_down
    when ARROW_LEFT then move_left
    when ARROW_RIGHT then move_right
    when "1".."9" then input_number(key)
    when "x", BACKSPACE, DELETE then input_delete
    when "c" then input_submit_solution
    when "q" then :quit
    when "n" then :new
    end
  end

  def move_up
    @cursor_y = [@cursor_y - 1, 0].max
  end

  def move_down
    @cursor_y = [@cursor_y + 1, 8].min
  end

  def move_left
    @cursor_x = [@cursor_x - 1, 0].max
  end

  def move_right
    @cursor_x = [@cursor_x + 1, 8].min
  end

  def input_number(key)
    if @initial_board[@cursor_y][@cursor_x] == 0
      @board[@cursor_y][@cursor_x] = key.to_i
    else
      @message = "#{RED}⚠️ Fixed cell!#{RESET}"
    end
  end

  def input_delete
    if @initial_board[@cursor_y][@cursor_x] == 0
      @board[@cursor_y][@cursor_x] = 0
    else
      @message = "#{RED}⚠️ Fixed cell!#{RESET}"
    end
  end

  def input_submit_solution
    @message = if @board == @solution
      "🎉 #{GREEN}SOLVED!#{RESET} 🎉"
    else
      "❌ #{RED}Incorrect#{RESET} ❌"
    end
  end

  def read_key
    # Disable echo and enable raw mode to capture single keypresses
    $stdin.echo = false
    $stdin.raw!

    # Read the first character
    input = $stdin.getc.chr

    # Handle escape sequences for arrow keys to allow cursor movement
    if input == "\e"
      begin
        input << $stdin.read_nonblock(3)
        input << $stdin.read_nonblock(2)
      rescue StandardError
        nil
      end
    end

    input
  ensure
    # Restore terminal settings
    $stdin.echo = true
    $stdin.cooked!
  end
end
