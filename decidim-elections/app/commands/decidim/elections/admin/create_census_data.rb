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

          Voter.insert_all(@election, rows)
          update_census_type

          broadcast(:ok)
        end

        private

        def update_census_type
          @election.update!(internal_census: false)
        end
      end
    end
  end
end
