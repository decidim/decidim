# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalEndorsedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.proposals.events.proposal_endorsed_event.email_subject",
          endorser_nickname: endorser.nickname
        )
      end

      def email_intro
        I18n.t(
          "decidim.proposals.events.proposal_endorsed_event.email_intro",
          endorser_nickname: endorser.nickname,
          endorser_name: endorser.name
        )
      end

      def email_outro
        I18n.t(
          "decidim.proposals.events.proposal_endorsed_event.email_outro",
          endorser_nickname: endorser.nickname
        )
      end

      def notification_title
        I18n.t(
          "decidim.proposals.events.proposal_endorsed_event.notification_title",
          resource_title: resource_title,
          resource_path: resource_path,
          endorser_nickname: endorser.nickname,
          endorser_name: endorser.name,
          endorser_path: endorser.profile_path
        ).html_safe
      end

      private

      def endorser
        @endorser ||= Decidim::UserPresenter.new(extra[:endorser])
      end
    end
  end
end
