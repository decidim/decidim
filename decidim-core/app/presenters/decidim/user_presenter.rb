# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class UserPresenter < SimpleDelegator
    include ActionView::Helpers::UrlHelper
    include Decidim::TranslatableAttributes

    #
    # nickname presented in a twitter-like style
    #
    def nickname
      return "" if __getobj__.blocked?

      "@#{__getobj__.nickname}"
    end

    def badge
      return "" unless officialized?

      "verified-badge"
    end

    def profile_url
      return "" if respond_to?(:deleted?) && deleted?

      decidim.profile_url(__getobj__.nickname)
    end

    def avatar
      attached_uploader(:avatar)
    end

    def avatar_url(variant = nil)
      return default_avatar_url if __getobj__.blocked?
      return default_avatar_url unless avatar.attached?

      avatar.path(variant:)
    end

    def default_avatar_url
      avatar.default_url
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

    private

    def decidim
      @decidim ||= Decidim::EngineRouter.new("decidim", { host: __getobj__.organization.host })
    end
  end
end
