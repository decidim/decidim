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

    # The private "split" method SplitDiff needs to be overriden to take into
    # account the new :unescaped_html format, and the fact that the tags
    # <ins> <del> are not there anymore
    Diffy::SplitDiff.module_eval do
      private

      def split
        return [split_left, split_right] unless @format == :unescaped_html

        [unescaped_split_left, unescaped_split_right]
      end

      def unescaped_split_left
        @diff.gsub(%r{<li class="ins">([\s\S]*?)</li>}, "")
      end

      def unescaped_split_right
        @diff.gsub(%r{<li class="del">([\s\S]*?)</li>}, "")
      end
    end
  end
end
