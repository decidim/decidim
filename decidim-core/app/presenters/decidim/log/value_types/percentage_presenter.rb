# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a percentage. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class PercentagePresenter < DefaultPresenter
        # Public: Presents the value as a percentage. For clarity,
        # it strips the insignificant zeros.
        #
        # Returns an HTML-safe String.
        def present
          return unless value

          h.number_to_percentage(value, strip_insignificant_zeros: true)
        end
      end
    end
  end
end
