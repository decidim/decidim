# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command updates the status of the action and the election if it got changed
      class UpdateActionStatus < Rectify::Command
        # Public: Initializes the command.
        #
        # action - The pending action to be updated
        def initialize(action)
          @action = action
        end

        # Update the statuses of the action and the election if pending message status got changed.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:ok) unless action.pending?

          transaction do
            update_pending_message_status
            update_election_status if action.accepted?
          end

          broadcast(:ok)
        end

        private

        attr_reader :action

        delegate :election, to: :action

        def update_pending_message_status
          action.status = Decidim::Elections.bulletin_board.get_pending_message_status(action.message_id)
          action.save!
        end

        def update_election_status
          election.bb_status = Decidim::Elections.bulletin_board.get_election_status(election.id)
          election.save!
        end
      end
    end
  end
end
