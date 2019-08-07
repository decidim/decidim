# frozen_string_literal: true

module Decidim
  module Initiatives
    # Current locale related functions
    module CurrentLocale
      # PUBLIC: Returns the current locale as a String
      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
