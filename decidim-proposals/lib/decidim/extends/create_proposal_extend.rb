# frozen_string_literal: true

# This module is use to add customs methods to the original "create_proposal.rb"

module CreateProposalExtend
  # send notification to moderators
  def send_notification
    Decidim::EventsManager.publish(
      event: "decidim.events.proposals.proposal_created",
      event_class: Decidim::Proposals::ProposalCreatedEvent,
      resource: @proposal,
      recipient_ids: (@proposal.users_to_notify_on_proposal_created - [@proposal.author]).pluck(:id),
      extra: {
        new_content: true,
        process_slug: @proposal.feature.participatory_space.slug
      }
    )
  end
end

Decidim::Proposals::CreateProposal.class_eval do
  prepend(CreateProposalExtend)
end
