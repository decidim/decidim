# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers::UrlHelper

    #
    # nickname presented in a twitter-like style
    #
    def nickname
      "@#{__getobj__.nickname}"
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

    def display_mention
      link_to nickname, profile_path, class: "user-mention"
    end

    def followers_count
      __getobj__.followers.count
    end

    def following_count
      __getobj__.following_users.count
    end

    def can_be_contacted?
      true
    end

    def officialization_text
      translated_attribute(profile_user.officialized_as).presence ||
        I18n.t("decidim.profiles.default_officialization_text_for_users")
    end
  end
end
