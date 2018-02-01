# frozen_string_literal: true
# This module is use to add customs methods to the original "create_proposal.rb"

module CreateProposalExtend
  def self.included(base)
    base.send(:include, ProposalsNotifications)

    base.class_eval do
      alias_method :send_notification, :send_notification_to_moderators
    end
  end

  module ProposalsNotifications
    def send_notification_to_moderators
      Decidim::EventsManager.publish(
        event: "decidim.events.proposals.proposal_created",
        event_class: Decidim::Proposals::ProposalCreatedEvent,
        resource: @proposal,
        recipient_ids: (@proposal.users_to_notify_on_proposal_created - [@proposal.author]).pluck(:id),
        extra: {
          moderation_event: @proposal.moderation.upstream_activated? ? true : false,
          new_content: true,
          process_slug: @proposal.feature.participatory_space.slug
        }
      )
    end
  end
end

Decidim::Proposals::CreateProposal.send(:include, CreateProposalExtend)
