# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the admin user removes a trustee
      # from a participatory space from the admin panel.
      class RemoveTrusteeFromParticipatorySpace < Rectify::Command
        def initialize(trustee, current_user, current_participatory_space)
          @trustee = trustee
          @current_user = current_user
          @current_participatory_space = current_participatory_space
        end

        # Removes the trustee from participatory space if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if trustee.elections.any?

          remove_trustee_from_participatory_space!

          broadcast(:ok, trustee)
        end

        private

        attr_reader :trustee, :current_user, :current_participatory_space

        def participatory_space_to_get_removed
          trustee.trustees_participatory_spaces.where(participatory_space: current_participatory_space)
        end

        def remove_trustee_from_participatory_space!
          trustee.trustees_participatory_spaces.delete(participatory_space_to_get_removed)
        end
      end
    end
  end
end
