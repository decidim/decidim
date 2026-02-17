# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      class AdminCalloutAntipattern < RuboCop::Cop::Base
        MIN_LENGTH_THRESHOLD = 12
        SINGLE_WORD_ANTI_PATTERNS = %w(
          successfully
          problem
          error
          warning
          done
          complete
          finished
          ok
          okay
          saved
          updated
          created
          deleted
          removed
          published
          unpublished
        ).freeze

        MSG = "Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. " \
              "Use the full admin flash message, e.g. 'Meeting successfully published'."

        def on_send(node)
          return unless node.method_name == :have_admin_callout

          first_argument = node.first_argument
          return unless first_argument

          if first_argument.nil_type?
            add_offense(first_argument, message: MSG)
            return
          end
          return unless first_argument.str_type?

          text = first_argument.value
          return unless antipattern_text?(text)

          add_offense(first_argument, message: MSG)
        end

        private

        def antipattern_text?(text)
          return true if text.nil?
          return true if text.empty?

          stripped_text = text.gsub(/[[:punct:]\s]/, "")
          single_word = text.strip !~ /\s/
          too_short = stripped_text.length < MIN_LENGTH_THRESHOLD

          return true if single_word && too_short
          return true if single_word && SINGLE_WORD_ANTI_PATTERNS.include?(stripped_text.downcase)
          return true if too_short

          false
        end
      end
    end
  end
end
