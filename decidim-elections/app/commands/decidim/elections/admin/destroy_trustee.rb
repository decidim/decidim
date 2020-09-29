# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command is executed when the admin user destroys a trustee
      # from the admin panel.
      class DestroyTrustee < Rectify::Command
        def initialize(trustee, current_user)
          @trustee = trustee
          @current_user = current_user
        end

        # Destroys the trustee if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          destroy_trustee!

          broadcast(:ok, trustee)
        end

        private

        attr_reader :trustee, :current_user

        def invalid?
          started_elections = []
          if trustee.elections.any?
            trustee.elections.each do |election|
              started_elections << election if election.started? || election.ongoing?
            end
          end

          if trustee.trustees_participatory_spaces.any?
            trustee.trustees_participatory_spaces.each do |pps|
              next unless pps.participatory_space.components.where(manifest_name: "elections").any?

              pps.participatory_space.components.where(manifest_name: "elections").each do |component|
                next unless Decidim::Elections::Election.where(decidim_component_id: component.id).any?

                Decidim::Elections::Election.where(decidim_component_id: component.id).each do |election|
                  started_elections << election if election.started? || election.ongoing?
                end
              end
            end
          end
          started_elections.any?
        end

        def destroy_trustee!
          Decidim.traceability.perform_action!(
            :delete,
            trustee,
            current_user,
            visibility: "all"
          ) do
            trustee.destroy!
          end
        end
      end
    end
  end
end
