# frozen_string_literal: true

module Decidim
  #
  # Decorator for user groups
  #
  class UserGroupPresenter < SimpleDelegator
    def nickname
      ""
    end

    def deleted?
      false
    end

    delegate :url, to: :avatar, prefix: true
  end
end
