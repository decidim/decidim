# frozen_string_literal: true

# require_relative "./db/dictionary.txt"

module Decidim
  class KnownPasswords
    include Singleton

    attr_reader :dictionary

    def initialize
      File.open(File.join(__dir__, "db", "dictionary.txt"), "r") do |file|
        @dictionary = file.read.split
      end
    end
  end
end
