# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin batch updates proposals scope.
      class UpdateProposalTaxonomies < Decidim::Command
        include TranslatableAttributes
        # Public: Initializes the command.
        #
        # taxonomy_ids - the taxonomy ids to update
        # proposal_ids - the proposals ids to update.
        def initialize(taxonomy_ids, proposal_ids, organization)
          @organization = organization
          @taxonomies = Decidim::Taxonomy.non_roots.where(organization:, id: taxonomy_ids)
          @proposals = Decidim::Proposals::Proposal.where(id: proposal_ids)
          @response = { taxonomies: [], successful: [], errored: [] }
        end

        # Executes the command. Broadcasts these events:
        #
        # - :update_proposals_taxonomies - when everything is ok, returns @response.
        # - :invalid_taxonomy - if the taxonomy is blank.
        # - :invalid_proposal_ids - if the proposal_ids is blank.
        #
        # Returns @response hash:
        #
        # - :taxonomies - Array of the translated names of the updated taxonomies
        # - :successful - Array of names of the updated proposals
        # - :errored - Array of names of the proposals not updated because they already had the scope assigned
        def call
          return broadcast(:invalid_taxonomy) if @taxonomies.blank?
          return broadcast(:invalid_proposals) if @proposals.blank?

          update_proposals_taxonomies

          broadcast(:update_proposals_taxonomies, @response)
        end

        private

        attr_reader :taxonomies, :proposals, :organization

        def update_proposals_taxonomies
          @response[:taxonomies] = taxonomies.map { |taxonomy| translated_attribute(taxonomy.name, organization) }
          proposals.find_each do |proposal|
            if taxonomies == proposal.taxonomies
              @response[:errored] << translated_attribute(proposal.title)
            else
              transaction do
                update_proposal_taxonomies proposal
                notify_author proposal if proposal.coauthorships.any?
              end
              @response[:successful] << translated_attribute(proposal.title)
            end
          end
        end

        def update_proposal_taxonomies(proposal)
          proposal.update!(
            taxonomies:
          )
        end

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
