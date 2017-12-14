# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    #
    def nickname
      "@#{super}"
    end

    delegate :url, to: :avatar, prefix: true
  end
end
