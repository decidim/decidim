# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A command with the business logic to create increment the dataset
        # processed rows and change the state when the last is processed
        class IncrementDatasetProcessedRows < Decidim::Command
          def initialize(dataset)
            @dataset = dataset
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless dataset

            # rubocop:disable Rails/SkipsModelValidations
            Dataset.increment_counter(:csv_row_processed_count, dataset.id)
            # rubocop:enable Rails/SkipsModelValidations

            dataset.data_created! if all_rows_processed?

            broadcast(:ok)
          end

          attr_accessor :dataset

          def all_rows_processed?
            dataset.reload
            return unless dataset.creating_data?

            dataset.csv_row_raw_count == dataset.csv_row_processed_count
          end
        end
      end
    end
  end
end
