# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      #  A command with all the business logic when an admin updates a proposal.
      class UpdateProposalCategory < Rectify::Command
        # Public: Initializes the command.
        #
        # category     - the category to update
        # proposal - the proposal to update.
        def initialize(category, proposal)
          @category = category
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the category is blank or the same.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if category.blank?
          return broadcast(:invalid) if category == proposal.category

          transaction do
            update_proposal_category
            notify_author
          end

          broadcast(:ok)
        end

        private

        attr_reader :category, :proposal

        def update_proposal_category
          proposal.update_attributes!(
            category: category
          )
        end

        def notify_author
          publish_event(
            "decidim.events.proposals.proposal_update_category",
            Decidim::Proposals::Admin::UpdateProposalCategoryEvent
          )
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event: event,
            event_class: event_class,
            resource: proposal,
            recipient_ids: [proposal.decidim_author_id]
          )
        end

      end
    end
  end
end
