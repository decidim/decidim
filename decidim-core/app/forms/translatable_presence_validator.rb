# frozen_string_literal: true
class TranslatablePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    available_locales_for(record).each do |locale|
      translated_attr = "#{attribute}_#{locale}"
      record.errors.add(translated_attr, :blank) unless record.send(translated_attr).present?
    end
  end

  private

  def available_locales_for(record)
    return record.current_organization.available_locales unless record.respond_to?(:available_locales)
    [
      record.current_organization.available_locales,
      record.available_locales
    ].sort_by(&:count).first
  end
end
