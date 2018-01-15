# frozen-string_literal: true

module Decidim
  class ProfileUpdatedEvent < Decidim::Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent

    def email_subject
      I18n.t(
        "decidim.events.profile_updated_event.email_subject",
        profile_path: updated_user.profile_path,
        nickname: updated_user.nickname,
        name: updated_user.name
      )
    end

    def email_intro
      I18n.t(
        "decidim.events.profile_updated_event.email_intro",
        profile_path: updated_user.profile_path,
        nickname: updated_user.nickname,
        name: updated_user.name
      )
    end

    def email_outro
      I18n.t(
        "decidim.events.profile_updated_event.email_outro",
        profile_path: updated_user.profile_path,
        nickname: updated_user.nickname,
        name: updated_user.name
      )
    end

    def notification_title
      I18n.t(
        "decidim.events.profile_updated_event.notification_title",
        profile_path: updated_user.profile_path,
        nickname: updated_user.nickname,
        name: updated_user.name
      ).html_safe
    end

    private

    def updated_user
      @updated_user ||= Decidim::UserPresenter.new(resource)
    end
  end
end
