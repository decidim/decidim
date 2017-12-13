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

    def avatar_url
      avatar.url
    end
  end
end
