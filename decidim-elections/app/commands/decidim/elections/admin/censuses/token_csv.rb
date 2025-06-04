# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module Censuses
        # A command with the business logic to create census data for an
        # election.
        class TokenCsv < Decidim::Command
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
            return broadcast(:invalid) if @form.invalid?
            return broadcast(:invalid) if @form.remove_all && @election.census.blank?

            # If the form is set to remove all, we just delete all voters
            if @form.remove_all
              @election.voters.delete_all
              return broadcast(:ok)
            end
            return broadcast(:invalid) unless @form.file

            rows = @form.data
            return broadcast(:invalid) if rows.blank?

            Voter.bulk_insert(@election, rows.map { |row| { email: row.first.downcase, token: row.second } })
            broadcast(:ok)
          end
        end
      end
    end
  end
end
