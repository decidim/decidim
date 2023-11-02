# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class DestroyProposalState < Decidim::Command
        # Initializes an UpdateResult Command.
        #
        # result - The current instance of the result to be destroyed.
        # current_user - the user performing the action
        def initialize(state, current_user)
          @state = state
          @current_user = current_user
        end

        # Destroys the state.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if state.system?

          destroy_state

          broadcast(:ok)
        rescue ActiveRecord::InvalidForeignKey
          broadcast(:invalid)
        end

        private

        attr_reader :state, :current_user

        def destroy_state
          Decidim.traceability.perform_action!(
            :delete,
            state,
            current_user
          ) do
            state.destroy!
          end
        end
      end
    end
  end
end
