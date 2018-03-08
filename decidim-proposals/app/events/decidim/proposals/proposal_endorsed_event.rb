# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalEndorsedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :endorser_nickname, :endorser_name, :endorser_path

      delegate :nickname, :name, to: :endorser, prefix: true

      def endorser_path
        endorser.profile_path
      end

      def email_subject
        I18n.t(
          "decidim.events.proposals.proposal_endorsed.email_subject",
          endorser_nickname: endorser.nickname
        )
      end

      def email_intro
        I18n.t(
          "decidim.events.proposals.proposal_endorsed.email_intro",
          endorser_nickname: endorser.nickname,
          endorser_name: endorser.name
        )
      end

      def notification_title
        I18n.t(
          "decidim.events.proposals.proposal_endorsed.notification_title",
          resource_title: resource_title,
          resource_path: resource_path,
          endorser_nickname: endorser.nickname,
          endorser_name: endorser.name,
          endorser_path: endorser.profile_path
        ).html_safe
      end

      def i18n_options
        super().merge(nickname: endorser_nickname)
      end

      private

      def endorser
        @endorser ||= Decidim::UserPresenter.new(extra[:endorser])
      end
    end
  end
end
