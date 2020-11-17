# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the user updates a trustee
      # status from the admin panel.
      class UpdateTrusteeParticipatorySpace < Rectify::Command
        # Public: Initializes the command.
        #
        # trustee_participatory_space - A trustee_participatory_space
        def initialize(trustee_participatory_space)
          @trustee_participatory_space = trustee_participatory_space
        end

        # Toggle the considered attr if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) unless trustee_participatory_space

          update_trustee_participatory_space!

          broadcast(:ok, trustee_participatory_space.trustee)
        end

        private

        attr_reader :trustee_participatory_space

        # Toggle the considered attribute
        def update_trustee_participatory_space!
          trustee_participatory_space.update!(
            considered: !trustee_participatory_space.considered
          )
        end
      end
    end
  end
end
