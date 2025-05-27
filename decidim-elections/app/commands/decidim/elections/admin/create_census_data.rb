# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class CreateCensusData < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed-
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.file

          rows = @form.data
          return broadcast(:invalid) if rows.blank?

          # rubocop:disable Rails/SkipsModelValidations
          Voter.insert_all(@election, rows)
          # rubocop:enable Rails/SkipsModelValidations
          update_census_type
          clean_verification_types

          broadcast(:ok)
        end

        private

        def update_census_type
          @election.update!(internal_census: false)
        end

        def clean_verification_types
          @election.update!(verification_types: [])
        end
      end
    end
  end
end
