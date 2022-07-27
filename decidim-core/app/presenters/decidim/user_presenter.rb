# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers::UrlHelper
    include Decidim::TranslatableAttributes

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

    def profile_url
      return "" if respond_to?(:deleted?) && deleted?

      decidim.profile_url(__getobj__.nickname, host: __getobj__.organization.host)
    end

    def avatar
      attached_uploader(:avatar)
    end

    def avatar_url(variant = nil)
      return avatar.default_url unless avatar.attached?

      avatar.path(variant:)
    end

    def default_avatar_url
      attached_uploader.default_url
    end

    def profile_path
      return "" if respond_to?(:deleted?) && deleted?

      decidim.profile_path(__getobj__.nickname)
    end

    def direct_messages_enabled?(context)
      return false unless __getobj__.respond_to?(:accepts_conversation?)

      __getobj__.accepts_conversation?(context[:current_user])
    end

    def display_mention
      link_to nickname, profile_url, class: "user-mention"
    end

    def can_be_contacted?
      true
    end

    def officialization_text
      translated_attribute(officialized_as).presence ||
        I18n.t("decidim.profiles.default_officialization_text_for_users")
    end

    def can_follow?
      true
    end

    def has_tooltip?
      true
    end
  end
end
