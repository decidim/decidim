# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Cop
    module Decidim
      class MessageAntipattern < RuboCop::Cop::Base
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

        MSG = "Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. " \
              "Use the full admin flash message, e.g. 'Meeting successfully published'. " \
              "Exception: when used inside `within` blocks (e.g., for checking `.label` elements)."

        def on_send(node)
          return unless [:have_callout, :have_admin_callout, :have_content].include?(node.method_name)
          return if within_block?(node)

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

        def within_block?(node)
          node.each_ancestor(:block).any? do |ancestor|
            ancestor.send_node&.method_name == :within
          end
        end

        def antipattern_text?(text)
          return true if text.nil?
          return true if text.empty?

          stripped_text = text.gsub(/[[:punct:]\s]/, "")
          return true if stripped_text.empty?

          single_word = text.strip !~ /\s/
          return false unless single_word

          return true if SINGLE_WORD_ANTI_PATTERNS.include?(stripped_text.downcase)

          false
        end
      end
    end
  end
end
