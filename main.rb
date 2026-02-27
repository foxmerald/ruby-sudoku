# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default, :development)

require_relative "sudoku_cli"

# Main execution logic
if __FILE__ == $PROGRAM_NAME
  SudokuCLI.start
end
