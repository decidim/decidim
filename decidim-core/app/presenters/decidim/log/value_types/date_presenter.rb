# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a date. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class DatePresenter < DefaultPresenter
        # Public: Presents the value as a date.
        #
        # Returns an HTML-safe String.
        def present
          return unless value

          h.l(value, format: :long)
        end
      end
    end
  end
end
