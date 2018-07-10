# frozen_string_literal: true

require "securerandom"

module Decidim
  module Meetings
    module Registrations
      # This class handles the generation of meeting registration codes
      class CodeGenerator
        # excluded digits: 0, 1, excluded letters: O, I
        ALPHABET = [*"A".."Z", *"2".."9"] - %w(O I)
        LENGTH = 8

        def initialize(options = {})
          @length = options[:length] || LENGTH
        end

        def generate(registration)
          loop do
            registration_code = choose(@length)

            # Use the random number if no other registration exists with it.
            break registration_code unless registration.class.exists?(meeting: registration.meeting, code: registration_code)
          end
        end

        private

        def choose(length)
          limit = ALPHABET.size

          (1..length).map do
            ALPHABET[SecureRandom.random_number(limit)]
          end.join
        end
      end
    end
  end
end
