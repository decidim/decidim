# frozen_string_literal: true

module Decidim
  #
  # Decorator for user groups when the user is a member of that group. These
  # groups are hidden from others in case they have not yet been verified.
  #
  class HiddenUserGroupPresenter < UserGroupPresenter
    delegate :name, to: :__getobj__

    def nickname
      "@#{__getobj__.nickname}"
    end
  end
end
