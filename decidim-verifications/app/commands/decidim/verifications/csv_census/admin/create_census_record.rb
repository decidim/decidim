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
            create_action_log
            broadcast(:ok)
          end

          private

          def create_action_log
            Decidim::ActionLogger.log(
              "create",
              current_user,
              @form.email,
              nil,
              {}
            )
          end
        end
      end
    end
  end
end
