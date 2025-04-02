# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class CreateCensusRecord < Decidim::Command
          def initialize(form)
            @form = form
          end

          def call
            return broadcast(:invalid) if @form.invalid?

            ProcessCensusDataJob.perform_now([@form.email], @form.current_organization)
            broadcast(:ok)
          end
        end
      end
    end
  end
end
