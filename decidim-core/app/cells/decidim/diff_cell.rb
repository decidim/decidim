# frozen_string_literal: true

require "decidim/diffy_extension"

module Decidim
  # This cell renders the diff between `:old_data` and `:new_data`.
  class DiffCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include LayoutHelper

    def attribute(data)
      render locals: { data: }
    end

    def diff_unified(data, format)
      render locals: { data:, format: }
    end

    def diff_split(data, direction, format)
      render locals: { data:, direction:, format: }
    end

    private

    # Adds a unique ID prefix for the attribute div IDs to avoid duplicate IDs
    # in the DOM.
    def attribute_diff_id(id)
      "#{SecureRandom.uuid}_#{id}"
    end

    # A PaperTrail::Version.
    def current_version
      model
    end

    # The item associated with the current_version.
    def item
      current_version.item
    end

    # DiffRenderer class for the current_version's item; falls back to `BaseDiffRenderer`.
    def diff_renderer_class
      if current_version.item_type.deconstantize == "Decidim"
        "#{current_version.item_type.pluralize}::DiffRenderer".constantize
      else
        "#{current_version.item_type.deconstantize}::DiffRenderer".constantize
      end
    rescue NameError
      Decidim::BaseDiffRenderer
    end

    # Caches a DiffRenderer instance for the current_version.
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
    def output_unified_diff(data, format)
      Diffy::Diff.new(
        data[:old_value].to_s,
        data[:new_value].to_s,
        allow_empty_diff: false,
        include_plus_and_minus_in_html: true
      ).to_s(format)
    end

    # Outputs the diff as HTML with side-by-side changes between lines.
    # Splits it in two parts (or two sides): left and right.
    # The left side represents deletions while the right side represents insertions.
    #
    # Returns an HTML-safe string.
    def output_split_diff(data, direction, format)
      Diffy::SplitDiff.new(
        data[:old_value].to_s,
        data[:new_value].to_s,
        allow_empty_diff: false,
        format:,
        include_plus_and_minus_in_html: true
      ).send(direction)
    end

    # Gives the option to view HTML unescaped for better user experience.
    # Official means created from admin (where rich text editor is enabled).
    def show_html_view_dropdown?
      item.try(:official?) || current_organization.rich_text_editor_in_public_views?
    end
  end
end
