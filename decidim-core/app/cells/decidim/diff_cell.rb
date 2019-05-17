# frozen_string_literal: true

module Decidim
  # This cell renders the diff between `:old_data` and `:new_data`.
  # model - A Hash with `old_data`, `:new_data` and `:type` keys.
  class DiffCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include LayoutHelper

    def attribute(data)
      render locals: { data: data }
    end

    def diff_unified(data)
      render locals: { data: data }
    end

    def diff_split(data, direction)
      render locals: { data: data, direction: direction }
    end

    private

    # Outputs the diff as HTML with inline highlighting of the character
    # changes between lines.
    #
    # Returns an HTML-safe string.
    def output_unified_diff(data)
      return unless data

      Diffy::Diff.new(
        data[:old_value],
        data[:new_value],
        format: :html,
        include_plus_and_minus_in_html: true
      ).to_s(:html).html_safe
    end

    # Outputs the diff as HTML with side-by-side changes between lines.
    # Splits it in two parts (or two sides): left and right.
    # The left side represents deletions while the right side represents insertions.
    #
    # Returns an HTML-safe string.
    def output_split_diff(data, direction)
      return unless data
      return unless direction

      Diffy::SplitDiff.new(
        data[:old_value],
        data[:new_value],
        format: :html,
        include_plus_and_minus_in_html: true
      ).send(direction)
    end
  end
end
