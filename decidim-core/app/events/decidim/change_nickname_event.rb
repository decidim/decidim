# frozen-string_literal: true

module Decidim
  class ChangeNicknameEvent < Decidim::Events::SimpleEvent
    include Decidim::Events::NotificationEvent
    delegate :organization, to: :user, prefix: false
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :link_to_account_settings

    def notification_title
      I18n.t("decidim.events.nickname_event.notification_body", **i18n_options).to_s.html_safe
    end

    def i18n_options
      {
        link_to_account_settings: url_helpers.account_path
      }
    end
  end
end
