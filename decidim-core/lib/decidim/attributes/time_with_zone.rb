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
        begin
          fallback = coercer.coercers[Time].public_send(type.coercion_method, value)
          return Time.zone.strptime(value.split(".").first, "%FT%R:%S") if fallback.is_a?(String)
          return nil unless fallback.is_a?(Time)

          ActiveSupport::TimeWithZone.new(fallback, Time.zone)
        rescue ArgumentError
          nil
        end
      end

      def type
        Axiom::Types::Time
      end
    end
  end
end
