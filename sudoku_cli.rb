# frozen_string_literal: true

require "optparse"
require_relative "sudoku_generator"
require_relative "sudoku_ui"

class SudokuCLI
  VALID_INPUTS = {
    "easy" => "easy",
    "moderate" => "moderate",
    "hard" => "hard",
    "e" => "easy",
    "m" => "moderate",
    "h" => "hard",
  }.freeze

  class << self
    def start
      new.start
    end
  end

  def start
    options = handle_user_input

    if options[:print]
      start_print_mode(options[:difficulty])
    else
      start_interactive_mode
    end
  end

  private

  def handle_user_input
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: main.rb [options]"

      opts.on("-p", "--print [DIFFICULTY]", "Print the sudoku into the terminal (easy/e, moderate/m, hard/h)") do |d|
        options[:print] = true
        options[:difficulty] = normalize_difficulty(d)
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    parser.parse!

    options
  end

  def start_print_mode(difficulty = "moderate")
    generator = SudokuGenerator.new
    generator.run(difficulty)
    print_board(generator.board)
  end

  def normalize_difficulty(input)
    return "moderate" if input.nil?

    formatted_input = input.downcase
    VALID_INPUTS[formatted_input] || "moderate"
  end

  def start_interactive_mode
    # Ensure terminal is in a known state
    if $stdin.tty?
      system("stty sane")
    end

    puts "Please select a difficulty level: easy/e, moderate/m, hard/h"

    input = gets
    difficulty = normalize_difficulty(input&.chomp)

    puts "Generating #{difficulty} sudoku..."
    generator = SudokuGenerator.new
    generator.run(difficulty)

    game = SudokuUI.new(generator, difficulty)
    game.start
  end

  def print_board(board)
    horizontal_line = "+⎯⎯⎯⎯⎯⎯⎯+⎯⎯⎯⎯⎯⎯⎯+⎯⎯⎯⎯⎯⎯⎯+"
    puts horizontal_line

    board.each_with_index do |row, i|
      print("│ ")

      row.each_with_index do |cell, j|
        print(cell == 0 ? ". " : "#{cell} ")
        print("│ ") if (j + 1) % 3 == 0
      end

      puts ""
      puts horizontal_line if (i + 1) % 3 == 0
    end
  end
end
