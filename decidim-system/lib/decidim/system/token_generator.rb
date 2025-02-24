# frozen_string_literal: true

module Decidim
  module System
    module TokenGenerator
      def generate_token(length = 32)
        length.times.map { characters.sample }.join
      end

      private

      def characters
        ("A".."Z").to_a + ("a".."z").to_a + (0..9).to_a
      end
    end
  end
end
