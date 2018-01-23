# frozen-string_literal: true

module Decidim
  class FeaturePublishedEvent < Decidim::Events::BaseEvent
    include Decidim::Events::EmailEvent
    include Decidim::Events::NotificationEvent
    include Decidim::FeaturePathHelper

    def email_subject
      I18n.t(
        "decidim.events.feature_published_event.email_subject",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def email_intro
      I18n.t(
        "decidim.events.feature_published_event.email_intro",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def email_outro
      I18n.t(
        "decidim.events.feature_published_event.email_outro",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      )
    end

    def notification_title
      I18n.t(
        "decidim.events.feature_published_event.notification_title",
        resource_title: resource_title,
        resource_path: resource_path,
        participatory_space_title: participatory_space_title
      ).html_safe
    end

    private

    def resource_path
      @resource_path ||= main_feature_path(resource)
    end

    def participatory_space_title
      resource.participatory_space.title[I18n.locale.to_s]
    end

    def resource_title
      @resource_title ||= resource.name[I18n.locale.to_s]
    end
  end
end
