# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with the business logic to delete the ballot style
      class DestroyBallotStyle < Rectify::Command
        def initialize(ballot_style)
          @ballot_style = ballot_style
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

        attr_reader :ballot_style

        def destroy_ballot_style!
          ballot_style.destroy
        end
      end
    end
  end
end
