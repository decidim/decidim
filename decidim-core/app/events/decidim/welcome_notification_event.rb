# frozen_string_literal: true

module Decidim
  class WelcomeNotificationEvent < Decidim::Events::SimpleEvent
    include TranslationsHelper

    delegate :organization, to: :user, prefix: false
    delegate :url_helpers, to: "Decidim::Core::Engine.routes"

    def subject
      interpolate(organization.welcome_notification_subject.symbolize_keys[I18n.locale])
    end

    def body
      interpolate(organization.welcome_notification_body.symbolize_keys[I18n.locale])
    end

    def email_subject
      subject
    end

    def email_greeting; end

    def email_intro
      body
    end

    def email_outro; end

    def notification_title
      ("<p><strong>#{subject}</strong></p>" + body).html_safe
    end

    def resource_path
      nil
    end

    def resource_title
      nil
    end

    private

    def interpolate(template)
      template
        .gsub("{{name}}", user.name)
        .gsub("{{organization}}", organization_name(organization))
        .gsub("{{help_url}}", url_helpers.pages_url(host: organization.host, locale: I18n.locale))
        .gsub("{{badges_url}}", url_helpers.gamification_badges_url(host: organization.host))
        .html_safe
    end
  end
end
