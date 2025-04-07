# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusData < Decidim::Command
          def initialize(form, organization)
            @form = form
            @organization = organization
            @result = { ok: [], ko: [] }
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form was not valid and could not proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless @form.file

            data = @form.data
            return broadcast(:invalid) if data.blank? || data.values.empty?

            # rubocop:disable Rails/SkipsModelValidations
            CsvDatum.insert_all(@organization, data.values)
            # rubocop:enable Rails/SkipsModelValidations

            ProcessCensusDataJob.perform_later(data.values, @organization)
            create_action_log
            broadcast(:ok, **result)
          end

          private

          attr_reader :result

          def create_action_log
            Decidim::ActionLogger.log(
              "import",
              current_user,
              @form.data.first,
              nil,
              extra: {
                imported_data_count: result[:ok].count
              }
            )
          end
        end
      end
    end
  end
end
