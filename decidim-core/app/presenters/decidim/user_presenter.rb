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

    def badge
      return "" unless officialized?

      "verified-badge"
    end

    delegate :url, to: :avatar, prefix: true

    def profile_url
      return "" if deleted?

      decidim.profile_url(__getobj__.nickname, host: __getobj__.organization.host)
    end

    def profile_path
      return "" if deleted?

      decidim.profile_path(__getobj__.nickname)
    end
  end
end
