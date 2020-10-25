# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the admin user removes a trustee
      # from a participatory space from the admin panel.
      class RemoveTrusteeFromParticipatorySpace < Rectify::Command
        # Public: Initializes the command.
        #
        # trustee_participatory_space - A trustee_participatory_space
        def initialize(trustee_participatory_space)
          @trustee_participatory_space = trustee_participatory_space
        end

        # Removes the trustee from participatory space if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if !trustee_participatory_space || trustee_participatory_space.trustee.elections.any?

          remove_trustee_from_participatory_space!

          broadcast(:ok, trustee_participatory_space.trustee)
        end

        private

        attr_reader :trustee_participatory_space

        def remove_trustee_from_participatory_space!
          trustee_participatory_space.trustee.delete
        end
      end
    end
  end
end
