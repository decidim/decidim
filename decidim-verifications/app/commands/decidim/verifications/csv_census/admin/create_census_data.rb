# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusData < Decidim::Command
          def initialize(form, current_user)
            @form = form
            @current_user = current_user
            @organization = current_user.organization
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

            ProcessCensusDataJob.perform_later(data.values, @current_user)
            broadcast(:ok)
          end
        end
      end
    end
  end
end
