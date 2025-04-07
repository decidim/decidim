# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusRecord < Decidim::Commands::CreateResource
          fetch_form_attributes :email, :organization

          private

          def resource_class = Decidim::Verifications::CsvDatum

          def run_after_hooks
            ProcessCensusDataJob.perform_now([resource.email], resource.organization)
          end
        end
      end
    end
  end
end
