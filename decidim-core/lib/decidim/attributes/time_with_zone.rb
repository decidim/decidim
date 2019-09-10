# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom Virtus value to parse a String representing a Time using
    # the app TimeZone.
    class TimeWithZone < Virtus::Attribute
      def coerce(value)
        return value unless value.is_a?(String)

        Time.zone.strptime(value, I18n.t("time.formats.decidim_short"))
      rescue ArgumentError
        nil
      end

      def type
        Axiom::Types::Time
      end
    end
  end
end
