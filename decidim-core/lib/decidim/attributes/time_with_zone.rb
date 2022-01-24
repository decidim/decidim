# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to parse a String representing a Time using
    # the app TimeZone.
    class TimeWithZone < ActiveModel::Type::Time
      def type
        :"decidim/attributes/time_with_zone"
      end

      private

      def cast_value(value)
        return value unless value.is_a?(String)

        Time.zone.strptime(value, I18n.t("time.formats.decidim_short"))
      rescue ArgumentError
        nil
      end
    end
  end
end
