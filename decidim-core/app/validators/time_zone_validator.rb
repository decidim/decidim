# frozen_string_literal: true

# This validator ensures timezones ara valed
class TimeZoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, options[:message] || :invalid_time_zone) unless ActiveSupport::TimeZone[value]
  end
end
