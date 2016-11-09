# frozen_string_literal: true
# A collection of methods to help dealing with translated attributes.
module TranslationHelpers
  # Gives the localized version of the attribute for the given locale. The
  # locale defaults to the application's default one.
  #
  # It is intended to be used to avoid the implementation details, so that the
  # translated attributes implementation can change more easily.
  def translated(field, locale: I18n.locale)
    field.try(:[], locale.to_s)
  end

  # Handles how to fill in i18n form fields.
  #
  # field - the name of the field that should be filled, without the
  #   locale-related part (e.g. `:participatory_process_title`)
  # tab_slector - a String representing the ID of the HTML element that holds
  #   the tabs for this input. It ususally is `"#<attribute_name>-tabs" (e.g.
  #   "#title-tabs")
  # localized_values - a Hash where the keys are the locales IDs and the values
  #   are the values that will be entered in the form field.
  def fill_in_i18n(field, tab_selector, localized_values)
    localized_values.each do |locale, value|
      within tab_selector do
        click_link I18n.t(locale, scope: "locales")
      end
      fill_in "#{field}_#{locale}", with: value
    end
  end
end
