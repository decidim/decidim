# frozen_string_literal: true

module Decidim
  # Extending Diffy gem to accomodate the needs of app/cells/decidim/diff_cell.rb
  module DiffyExtension
    # HtmlFormatter that returns basic html output (no inline highlighting)
    # and does not escape HTML tags.
    class UnescapedHtmlFormatter < Diffy::HtmlFormatter
      # We exclude the tags `del` and `ins` so the diffy styling does not apply.
      TAGS = (UserInputScrubber.new.tags.to_a - %w(del ins)).freeze

      def to_s
        str = wrap_lines(@diff.map { |line| wrap_line(line) })
        ActionView::Base.new.sanitize(str, tags: TAGS)
      end
    end

    # Adding a new method to Diffy::Format so we can pass the
    # `:unescaped_html` option when calling Diffy::Diff#to_s.
    Diffy::Format.module_eval do
      def unescaped_html
        UnescapedHtmlFormatter.new(self, options).to_s
      end
    end
  end
end
