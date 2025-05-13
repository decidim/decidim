# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to parse a String representing a Time using
    # the app TimeZone.
    class TimeWithZone < ActiveModel::Type::DateTime
      # Date format: 2020-06-20T, 2020-06-20, 20/06/2020T or 20/06/2020
      # Time format: 10:20, 10:20:30 or 10:20:30.123456
      ISO_DATETIME_WITHOUT_TIMEZONE = %r{
        \A
        ((\d{4})-(\d\d)-(\d\d)|(\d\d)/(\d\d)/(\d{4}))(?:T|\s)
        (\d\d):(\d\d)(:(\d\d)(?:\.(\d{1,6})\d*)?)?
        \z
      }x

      def type
        :"decidim/attributes/time_with_zone"
      end

      private

      def cast_value(value)
        return value unless value.is_a?(String)

        if Date._iso8601(value).present?
          Time.zone.iso8601(value)
        else
          Time.zone.strptime(value, I18n.t("time.formats.decidim_short"))
        end
      rescue ArgumentError
        fallback = super
        return fallback unless fallback.is_a?(Time)
        return Time.zone.parse(fallback.strftime("%F %T")) if ISO_DATETIME_WITHOUT_TIMEZONE.match?(value)

        ActiveSupport::TimeWithZone.new(fallback, Time.zone)
      end
    end
  end
end
