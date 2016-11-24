# frozen_string_literal: true

# A custom validator to check for presence in I18n-enabled fields. In order to
# use it do the following:
#
#   validates :my_i18n_field, translatable_presence: true
#
# This will automatically check for presence for each of the
# `available_locales` of the form object (or the `available_locales` of the
# form's organization) for the given field.
class TranslatablePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    available_locales_for(record).each do |locale|
      translated_attr = "#{attribute}_#{locale}"
      record.errors.add(translated_attr, :blank) unless record.send(translated_attr).present?
    end
  end

  private

  def available_locales_for(record)
    return record.available_locales if record.respond_to?(:available_locales)

    if record.current_organization
      record.current_organization.available_locales
    else
      record.errors.add(:current_organization, :blank)
      []
    end
  end
end
