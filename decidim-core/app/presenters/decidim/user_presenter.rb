# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers

    #
    # nickname presented in a twitter-like style
    #
    def nickname
      "@#{super}"
    end

    def badge_path
      return "" unless officialized?

      "#{ActionController::Base.helpers.asset_path("decidim/icons.svg")}#icon-verified-badge"
    end

    delegate :url, to: :avatar, prefix: true

    def profile_path
      return "" if deleted?

      decidim.profile_path(__getobj__.nickname)
    end
  end
end
