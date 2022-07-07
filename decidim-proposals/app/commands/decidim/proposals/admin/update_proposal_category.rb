# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin batch updates proposals category.
      class UpdateProposalCategory < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # category_id - the category id to update
        # proposal_ids - the proposals ids to update.
        def initialize(category_id, proposal_ids)
          @category = Decidim::Category.find_by id: category_id
          @proposal_ids = proposal_ids
          @response = { category_name: "", successful: [], errored: [] }
        end

        # Executes the command. Broadcasts these events:
        #
        # - :update_proposals_category - when everything is ok, returns @response.
        # - :invalid_category - if the category is blank.
        # - :invalid_proposal_ids - if the proposal_ids is blank.
        #
        # Returns @response hash:
        #
        # - :category_name - the translated_name of the category assigned
        # - :successful - Array of names of the updated proposals
        # - :errored - Array of names of the proposals not updated because they already had the category assigned
        def call
          return broadcast(:invalid_category) if @category.blank?
          return broadcast(:invalid_proposal_ids) if @proposal_ids.blank?

          @response[:category_name] = @category.translated_name
          Proposal.where(id: @proposal_ids).find_each do |proposal|
            if @category == proposal.category
              @response[:errored] << translated_attribute(proposal.title)
            else
              transaction do
                update_proposal_category proposal
                notify_author proposal if proposal.coauthorships.any?
              end
              @response[:successful] << translated_attribute(proposal.title)
            end
          end

          broadcast(:update_proposals_category, @response)
        end

        private

        def update_proposal_category(proposal)
          proposal.update!(
            category: @category
          )
        end

        def notify_author(proposal)
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_update_category",
            event_class: Decidim::Proposals::Admin::UpdateProposalCategoryEvent,
            resource: proposal,
            affected_users: proposal.notifiable_identities
          )
        end
      end
    end
  end
end
