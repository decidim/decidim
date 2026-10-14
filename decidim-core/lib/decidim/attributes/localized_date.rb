# frozen_string_literal: true

module Decidim
  module Attributes
    # Custom attributes value to parse a String representing a Date using
    # the app localization format.
    class LocalizedDate < ActiveModel::Type::Date
      def type
        :"decidim/attributes/localized_date"
      end

      private

      def cast_value(value)
        return value unless value.is_a?(String)

        # The date picker provides calendar years. Treat an ISO week-year in a
        # locale format as its calendar-year equivalent when parsing that input.
        Date.strptime(value, I18n.t("date.formats.decidim_short").gsub("%G", "%Y"))
      rescue ArgumentError
        super
      end
    end
  end
end
