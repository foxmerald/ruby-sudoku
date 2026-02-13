# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default, :development)

require_relative "sudoku_generator"
require_relative "sudoku_ui"

VALID_INPUTS = {
  "easy" => "easy",
  "moderate" => "moderate",
  "hard" => "hard",
  "e" => "easy",
  "m" => "moderate",
  "h" => "hard",
}

# Main execution logic
if __FILE__ == $PROGRAM_NAME
  puts "Please select a difficulty level: e (easy), m (moderate), h (hard) "

  input = gets
  input = input.chomp.downcase
  difficulty = VALID_INPUTS.include?(input) ? VALID_INPUTS[input] : "moderate"

  puts "Generating #{difficulty} sudoku..."
  generator = SudokuGenerator.new
  generator.run(difficulty)

  game = SudokuUI.new(generator, difficulty)
  game.start
end
