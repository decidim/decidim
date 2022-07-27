# frozen-string_literal: true

module Decidim
  module Initiatives
    class SpawnCommitteeRequestEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.initiatives.events.spawn_committee_request_event.email_subject",
          applicant_nickname:
        )
      end

      def email_intro
        I18n.t(
          "decidim.initiatives.events.spawn_committee_request_event.email_intro",
          resource_title:,
          resource_url:,
          applicant_profile_url:,
          applicant_nickname:
        )
      end

      def email_outro
        I18n.t(
          "decidim.initiatives.events.spawn_committee_request_event.email_outro",
          resource_title:,
          resource_url:
        )
      end

      def notification_title
        I18n.t(
          "decidim.initiatives.events.spawn_committee_request_event.notification_title",
          resource_title:,
          resource_url:,
          applicant_profile_url:,
          applicant_nickname:
        ).html_safe
      end

      private

      def applicant_nickname
        applicant.nickname
      end

      def applicant_profile_url
        applicant.profile_url
      end

      def applicant
        @applicant ||= Decidim::UserPresenter.new(
          Decidim::User.find(@extra["applicant"]["id"])
        )
      end
    end
  end
end
