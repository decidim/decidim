# frozen_string_literal: true

module Decidim
  # This cell renders the diff between `:old_data` and `:new_data`.
  class DiffCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include ::HtmlToPlainText # from the premailer gem
    include LanguageChooserHelper
    include LayoutHelper

    def attribute(data, format)
      render locals: { data: data, format: format }
    end

    def diff_unified(data, format)
      render locals: { data: data, format: format }
    end

    def diff_split(data, direction, format)
      render locals: { data: data, direction: direction, format: format }
    end

    private

    # A PaperTrail::Version.
    def current_version
      model
    end

    # The item associated with the current_version.
    def item
      current_version.item
    end

    # preview (if associated item allows it)
    def preview
      diff_renderer.preview
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

    def available_locales_for(data)
      locales = { I18n.locale.to_s => true }

      locales.merge! valid_locale_keys(data[:old_value]) if data[:old_value].is_a?(Hash)
      locales.merge! valid_locale_keys(data[:new_value]) if data[:new_value].is_a?(Hash)

      locales.filter { |k| I18n.locale_available?(k) }
    end

    def valid_locale_keys(input)
      locales = input.transform_values(&:present?)
      locales.merge!(input["machine_translations"].transform_values(&:present?)) if input["machine_translations"].is_a?(Hash)
      locales
    end

    # Outputs the diff as HTML with inline highlighting of the character
    # changes between lines.
    #
    # Returns an HTML-safe string.
    def output_unified_diff(data, format, locale)
      Diffy::Diff.new(
        old_new_values(data, format, locale)[0],
        old_new_values(data, format, locale)[1],
        allow_empty_diff: false,
        include_plus_and_minus_in_html: true
      ).to_s(:html)
    end

    # Outputs the diff as HTML with side-by-side changes between lines.
    # Splits it in two parts (or two sides): left and right.
    # The left side represents deletions while the right side represents insertions.
    #
    # Returns an HTML-safe string.
    def output_split_diff(data, direction, format, locale)
      Diffy::SplitDiff.new(
        old_new_values(data, format, locale)[0],
        old_new_values(data, format, locale)[1],
        allow_empty_diff: false,
        format: :html,
        include_plus_and_minus_in_html: true
      ).send(direction)
    end

    def old_new_values(data, format, locale)
      original_translations = data[:old_value].filter { |key, value| value.present? && key != "machine_translations" }
      [
        value_from_locale(data[:old_value], format, locale),
        value_from_locale(data[:new_value], format, locale, original_translations)
      ]
    end

    def value_from_locale(value, format, locale, skip_machine_keys = {})
      text = value.is_a?(Hash) ? find_locale_value(value, locale, skip_machine_keys).dup : value.dup

      return text.to_s if format == :html || text.blank?

      convert_to_text(text, 100)
    end

    def find_locale_value(input, locale, skip_machine_keys = {})
      input[locale].presence || skip_machine_keys[locale].presence || input.dig("machine_translations", locale)
    end

    # Gives the option to view HTML unescaped for better user experience.
    # Official means created from admin (where rich text editor is enabled).
    def show_html_view_dropdown?
      item.try(:official?) || current_organization.rich_text_editor_in_public_views?
    end
  end
end
