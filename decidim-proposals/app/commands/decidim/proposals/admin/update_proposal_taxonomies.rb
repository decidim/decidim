# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin batch updates proposals scope.
      class UpdateProposalTaxonomies < UpdateResourcesTaxonomies
        include TranslatableAttributes
        # Public: Initializes the command.
        #
        # taxonomy_ids - the taxonomy ids to update
        # proposal_ids - the proposals ids to update.
        def initialize(taxonomy_ids, proposal_ids, organization)
          super(taxonomy_ids, Decidim::Proposals::Proposal.where(id: proposal_ids), organization)
        end

        def run_after_hooks(resource)
          notify_author(resource) if resource.coauthorships.any?
        end

        private

        def notify_author(proposal)
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_update_taxonomies",
            event_class: Decidim::Proposals::Admin::UpdateProposalTaxonomiesEvent,
            resource: proposal,
            affected_users: proposal.notifiable_identities
          )
        end
      end
    end
  end
end
