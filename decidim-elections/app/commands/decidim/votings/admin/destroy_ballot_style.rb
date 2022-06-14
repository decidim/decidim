# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to delete the ballot style
      class DestroyBallotStyle < Rectify::Command
        def initialize(ballot_style, current_user)
          @ballot_style = ballot_style
          @current_user = current_user
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed
        #
        # Returns nothing.
        def call
          destroy_ballot_style!

          broadcast(:ok)
        end

        private

        attr_reader :ballot_style, :current_user

        def destroy_ballot_style!
          Decidim.traceability.perform_action!(
            :delete,
            ballot_style,
            current_user,
            { visibility: "all", code: ballot_style.code }
          ) do
            ballot_style.destroy!
          end
        end
      end
    end
  end
end
