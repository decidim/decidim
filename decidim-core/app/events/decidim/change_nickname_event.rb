# frozen-string_literal: true

module Decidim
  class ChangeNicknameEvent < Decidim::Events::SimpleEvent
    include Decidim::Events::NotificationEvent
    delegate :organization, to: :user, prefix: false
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    i18n_attributes :old_nickname, :new_nickname

    def notification_title
      I18n.t("decidim.events.nickname_event.notification_title", i18n_options).to_s.html_safe
    end

    def resource_path
      nil
    end

    def resource_title
      nil
    end

    def i18n_options
      {
        old_nickname: extra["old_nickname"],
        new_nickname: extra["new_nickname"]
      }
    end
  end
end
