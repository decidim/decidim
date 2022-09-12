# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command to launch the access codes generation
        class LaunchAccessCodesGeneration < Decidim::Command
          def initialize(dataset, user)
            @dataset = dataset
            @user = user
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the user is not present
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless valid?

            update_dataset_status(dataset, :generating_codes, user)

            GenerateAccessCodesJob.perform_later(dataset, user)

            broadcast(:ok)
          end

          attr_reader :user, :dataset

          private

          def valid?
            user.present? && dataset&.data&.exists? && dataset.data_created?
          end

          def update_dataset_status(dataset, status, user)
            UpdateDataset.call(dataset, { status: status }, user)
          end
        end
      end
    end
  end
end
