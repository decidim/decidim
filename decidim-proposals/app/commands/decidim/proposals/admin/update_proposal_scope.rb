# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin batch updates proposals scope.
      class UpdateProposalScope < Decidim::Command
        include TranslatableAttributes
        # Public: Initializes the command.
        #
        # scope_id - the scope id to update
        # proposal_ids - the proposals ids to update.
        def initialize(scope_id, proposal_ids)
          @scope = Decidim::Scope.find_by id: scope_id
          @proposal_ids = proposal_ids
          @response = { scope_name: "", successful: [], errored: [] }
        end

        # Executes the command. Broadcasts these events:
        #
        # - :update_proposals_scope - when everything is ok, returns @response.
        # - :invalid_scope - if the scope is blank.
        # - :invalid_proposal_ids - if the proposal_ids is blank.
        #
        # Returns @response hash:
        #
        # - :scope_name - the translated_name of the scope assigned
        # - :successful - Array of names of the updated proposals
        # - :errored - Array of names of the proposals not updated because they already had the scope assigned
        def call
          return broadcast(:invalid_scope) if @scope.blank?
          return broadcast(:invalid_proposal_ids) if @proposal_ids.blank?

          update_proposals_scope

          broadcast(:update_proposals_scope, @response)
        end

        private

        attr_reader :scope, :proposal_ids

        def update_proposals_scope
          @response[:scope_name] = translated_attribute(scope.name, scope.organization)
          Proposal.where(id: proposal_ids).find_each do |proposal|
            if scope == proposal.scope
              @response[:errored] << translated_attribute(proposal.title)
            else
              transaction do
                update_proposal_scope proposal
                notify_author proposal if proposal.coauthorships.any?
              end
              @response[:successful] << translated_attribute(proposal.title)
            end
          end
        end

        def update_proposal_scope(proposal)
          proposal.update!(
            scope: scope
          )
        end

        def notify_author(proposal)
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_update_scope",
            event_class: Decidim::Proposals::Admin::UpdateProposalScopeEvent,
            resource: proposal,
            affected_users: proposal.notifiable_identities
          )
        end
      end
    end
  end
end
