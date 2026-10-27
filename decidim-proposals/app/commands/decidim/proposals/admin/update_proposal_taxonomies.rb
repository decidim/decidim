# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin batch updates proposals taxonomies.
      class UpdateProposalTaxonomies < UpdateResourcesTaxonomies
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # taxonomy_ids - the taxonomy ids to update
        # proposal_ids - the proposals ids to update.
        # current_component - the component where the proposals belong to.
        def initialize(taxonomy_ids, proposal_ids, current_component, organization)
          @proposal_ids = proposal_ids
          @current_component = current_component
          super(taxonomy_ids, proposals, organization)
        end

        def run_after_hooks(resource)
          notify_author(resource) if resource.coauthorships.any?
        end

        private

        attr_reader :proposal_ids, :current_component

        def proposals
          Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids)
        end

        def notify_author(proposal)
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_update_taxonomies",
            event_class: Decidim::Proposals::UpdateProposalTaxonomiesEvent,
            resource: proposal,
            affected_users: proposal.notifiable_identities
          )
        end
      end
    end
  end
end
