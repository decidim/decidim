# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a currency. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class CurrencyPresenter < DefaultPresenter
        # Public: Presents the value as a currency.
        #
        # Returns an HTML-safe String.
        def present
          return unless value

          h.number_to_currency(value, unit: Decidim.currency_unit)
        end
      end
    end
  end
end
