# frozen_string_literal: true

module Decidim
  module NeedsRtlDirection
    extend ActiveSupport::Concern

    included do
      helper_method :rtl_direction

      def rtl_direction
        return "rtl" if rtl_languages_codes.include?(I18n.locale.to_s)

        "ltr"
      end

      private

      def rtl_languages_codes
        %w(ar ar-BH ar-EG ar-SA ar-YE dv he fa ks ks-PK ug ur-IN ur-PK ydd)
      end
    end
  end
end
