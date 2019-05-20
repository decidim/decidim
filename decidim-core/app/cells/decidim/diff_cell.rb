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

    def current_version
      model
    end

    # The DiffRenderer class for the `current_version` model namespace.
    def diff_renderer_class
      namespace ||= current_version.item_type.deconstantize

      "#{namespace}::DiffRenderer".constantize
    end

    # Caches a DiffRenderer instance for the `current_version`.
    def diff_renderer
      @diff_renderer ||= diff_renderer_class.new(current_version)
    end

    # The changesets for each attribute.
    #
    # Each changeset has the following information: type, label, old_value, new_value.
    #
    # Returns an Array of Hashes.
    def diff_data
      diff_renderer.diff.values
    end

    # Outputs the diff as HTML with inline highlighting of the character
    # changes between lines.
    #
    # Returns an HTML-safe string.
    def output_unified_diff(data)
      return unless data

      Diffy::Diff.new(
        data[:old_value],
        data[:new_value],
        allow_empty_diff: false,
        include_plus_and_minus_in_html: true
      ).to_s(:html).html_safe
    end

    # Outputs the diff as HTML with side-by-side changes between lines.
    # Splits it in two parts (or two sides): left and right.
    # The left side represents deletions while the right side represents insertions.
    #
    # Returns an HTML-safe string.
    def output_split_diff(data, direction)
      return unless data && direction

      Diffy::SplitDiff.new(
        data[:old_value],
        data[:new_value],
        allow_empty_diff: false,
        format: :html,
        include_plus_and_minus_in_html: true
      ).send(direction)
    end
  end
end
