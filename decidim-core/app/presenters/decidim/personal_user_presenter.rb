# frozen_string_literal: true

module Decidim
  #
  # Decorator for users when they can see the user details themselves, i.e.
  # when the user is logged in themselves.
  #
  class PersonalUserPresenter < UserPresenter
    def nickname
      return "" if blocked?

      "@#{__getobj__.nickname}"
    end

    def name
      return "" if blocked?

      __getobj__.name
    end
  end
end
