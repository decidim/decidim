# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    #
    # nickname presented in a twitter-like style
    #
    def nickname
      "@#{super}"
    end

    delegate :url, to: :avatar, prefix: true
  end
end
