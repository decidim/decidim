# frozen_string_literal: true

require "decidim/dev/test/rspec_support/helpers"

MIN_LENGTH_THRESHOLD = 12

SINGLE_WORD_ANTI_PATTERNS = %w(
  successfully
  successfully.
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

RSpec::Matchers.define :have_admin_callout do |expected|
  include Decidim::ComponentTestHelpers

  match do |_page|
    # Short-circuit for nil/symbols to avoid calling within_flash_messages
    return true if expected.nil? || expected.is_a?(Symbol)

    validate_text(expected)

    within_flash_messages do
      have_content expected
    end
  end

  def validate_text(text)
    return true if text.nil? || text.is_a?(Symbol)

    stripped_text = text.to_s.gsub(/[[:punct:]]/, "")
    is_single_word = text.to_s.strip !~ /\s/
    is_too_short = stripped_text.length < MIN_LENGTH_THRESHOLD

    if is_single_word && is_too_short
      raise <<~ERROR
        Anti-pattern detected: Using generic single-word text "#{text}" in admin callout assertions.

        Problem: Generic single-word messages don't verify the actual feedback shown to users.

        #{format_find_command(text)}
      ERROR
    end

    if is_single_word && SINGLE_WORD_ANTI_PATTERNS.include?(stripped_text.downcase)
      raise <<~ERROR
        Anti-pattern detected: Using generic single-word text "#{text}" in admin callout assertions.

        Problem: Generic single-word messages don't verify the actual feedback shown to users.
        Single-word messages like "successfully" or "problem" are too vague.

        Example: "Meeting successfully published" is better than just "successfully"

        #{format_find_command(text)}
      ERROR
    end

    if is_too_short
      raise <<~ERROR
        Anti-pattern detected: Using very short text "#{text}" (#{stripped_text.length} chars) in admin callout assertions.

        Problem: Very short messages are likely generic and don't provide meaningful feedback.
        Messages should be at least #{MIN_LENGTH_THRESHOLD} characters to convey useful information.

        Examples of proper messages:
          - "Meeting successfully published"
          - "Budget successfully created."
          - "There was a problem saving the form"
          - "Your changes have been saved successfully"

        #{format_find_command(text)}
      ERROR
    end

    true
  end

  def format_find_command(text)
    <<~COMMAND

      To find similar instances:
        grep -r 'have_admin_callout.*#{text}' --include="*.rb" decidim-*/
    COMMAND
  end

  failure_message do
    @failure_message || super()
  end

  diffable
end
