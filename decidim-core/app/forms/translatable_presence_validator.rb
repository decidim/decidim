# frozen_string_literal: true

# A custom validator to check for presence in I18n-enabled fields. In order to
# use it do the following:
#
#   validates :my_i18n_field, translatable_presence: true
#
# This will automatically check for presence for the default locale of the form
# object (or the `default_locale` of the form's organization) for the given field.
class TranslatablePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    translated_attr = "#{attribute}_#{default_locale_for(record)}"
    record.errors.add(translated_attr, :blank) if record.send(translated_attr).blank?
  end

  private

  def default_locale_for(record)
    return record.default_locale if record.respond_to?(:default_locale)

    if record.current_organization
      record.current_organization.default_locale
    else
      record.errors.add(:current_organization, :blank)
      []
    end
  end
end
