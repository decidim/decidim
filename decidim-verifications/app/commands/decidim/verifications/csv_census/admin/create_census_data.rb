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
          end

          # Executes the command. Broadcast this events:
          # - :ok when everything is valid
          # - :invalid when the form wasn't valid and couldn't proceed-
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) unless @form.file

            # rubocop:disable Rails/SkipsModelValidations
            CsvDatum.insert_all(@organization, @form.data.values)
            # rubocop:enable Rails/SkipsModelValidations
            RemoveDuplicatesJob.perform_later(@organization)

            broadcast(:ok)
          end
        end
      end
    end
  end
end
