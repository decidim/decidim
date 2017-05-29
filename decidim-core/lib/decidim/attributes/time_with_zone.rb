# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom Virtus value to parse a String representing a Time using
    # the app TimeZone.
    class TimeWithZone < Virtus::Attribute
      def coerce(value)
        return value unless value.is_a?(String)
        Time.zone.parse(value)
      end
    end
  end
end
