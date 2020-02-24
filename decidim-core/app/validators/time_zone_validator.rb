# frozen_string_literal: true

# This validator ensures timezones are valid. This is, supported by ActiveSupport::TimeZone
class TimeZoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, options[:message] || :invalid_time_zone) unless ActiveSupport::TimeZone[value]
  end
end
