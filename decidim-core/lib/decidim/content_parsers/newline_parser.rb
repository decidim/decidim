# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches newline escape sequences in content.
    #
    # The escape sequences `\r\n` and `\r` will be replaced by `\n`.
    #
    # @see BaseParser Examples of how to use a content parser
    class NewlineParser < BaseParser
      ESCAPE_SEQUENCES = ["\r\n", "\r"].freeze
      REGEX = Regexp.union(ESCAPE_SEQUENCES)

      # @return [String] the content with the escape sequences replaced.
      def rewrite
        content.gsub(REGEX, "\n")
      end
    end
  end
end
