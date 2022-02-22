# frozen_string_literal: true

require "csv"

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to destroy a census dataset
        # from the admin panel.
        class DestroyDataset < Decidim::Command
          def initialize(dataset, current_user)
            @dataset = dataset
            @current_user = current_user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless dataset || current_user

            destroy_census_dataset!

            broadcast(:ok)
          end

          attr_reader :dataset, :current_user

          def destroy_census_dataset!
            Decidim.traceability.perform_action!(
              :delete,
              dataset,
              current_user
            ) do
              dataset.destroy!
            end
          end
        end
      end
    end
  end
end
