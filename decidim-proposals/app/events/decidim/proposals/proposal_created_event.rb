# frozen-string_literal: true

module Decidim
  module Proposals
    class ProposalCreatedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def notification_title
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.notification_title",
          resource_title: resource_title,
          resource_path: resource_locator.path(url_params),
          author_name: comment.author.name
        ).html_safe
      end

      def email_moderation_intro
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.moderation.email_intro",
          resource_title: resource_title
        ).html_safe
      end

      def email_moderation_subject
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.moderation.email_subject",
          resource_title: resource_title,
          resource_url: resource_locator.url(url_params),
          author_name: comment.author.name
        ).html_safe
      end

      private

      def proposal
        @proposal ||= Decidim::Proposals::Proposal.find(proposal)
      end

      def url_params
        proposal_type == :proposal ? {} : { anchor: "proposal_#{proposal.id}" }
      end
    end
  end
end
