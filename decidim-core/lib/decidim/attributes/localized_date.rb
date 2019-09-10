# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom Virtus value to parse a String representing a Date using
    # the app localization format.
    class LocalizedDate < Virtus::Attribute
      def coerce(value)
        return value unless value.is_a?(String)

        Date.strptime(value, I18n.t("date.formats.decidim_short"))
      rescue ArgumentError
        nil
      end

      def type
        Axiom::Types::Date
      end
    end
  end
end
