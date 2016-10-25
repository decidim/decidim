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
end
