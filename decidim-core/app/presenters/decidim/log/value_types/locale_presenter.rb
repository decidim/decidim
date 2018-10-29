# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a locale. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class LocalePresenter < DefaultPresenter
        # Public: Presents the value as a locale.
        #
        # Returns an HTML-safe String.
        def present
          return unless value

          I18n.with_locale(value) { I18n.t("locale.name") }
        end
      end
    end
  end
end
