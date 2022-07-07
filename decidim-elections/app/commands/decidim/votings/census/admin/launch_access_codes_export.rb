# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command to launch the access codes export
        class LaunchAccessCodesExport < Decidim::Command
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

            UpdateDataset.call(dataset, { status: :exporting_codes }, user)

            ExportAccessCodesJob.perform_later(dataset, user)

            broadcast(:ok)
          end

          attr_reader :user, :dataset

          private

          def valid?
            user.present? && dataset&.data&.present? && dataset.codes_generated?
          end
        end
      end
    end
  end
end
