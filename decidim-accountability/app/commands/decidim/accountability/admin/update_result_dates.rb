# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin batch updates results dates.
      class UpdateResultDates < Decidim::Command
        # Public: Initializes the command.
        #
        # start_date - the start date to update
        # end_date - the end date to update
        # result_ids - the results ids to update
        # current_user - the user performing the action
        def initialize(start_date, end_date, result_ids, current_user)
          @start_date = start_date
          @end_date = end_date
          @result_ids = result_ids
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if (start_date.blank? && end_date.blank?) || result_ids.blank?

          update_results_dates

          broadcast(:ok)
        end

        private

        attr_reader :start_date, :end_date, :result_ids, :current_user

        def update_results_dates
          Decidim::Accountability::Result.where(id: result_ids).find_each do |result|
            next if result.start_date == start_date && result.end_date == end_date

            result.update!(start_date:, end_date:)

            # Trace the action to keep track of changes
            Decidim.traceability.perform_action!(
              "update",
              result,
              current_user
            )
          end
        end
      end
    end
  end
end
