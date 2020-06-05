# frozen_string_literal: true

module Decidim
  module Log
    module ValueTypes
      # This class presents the given value as a user group. Check
      # the `DefaultPresenter` for more info on how value
      # presenters work.
      class UserGroupPresenter < DefaultPresenter
        # Public: Presents the value as a user group.
        #
        # Returns an HTML-safe String.
        def present
          return unless value

          value
        end
      end
    end
  end
end
