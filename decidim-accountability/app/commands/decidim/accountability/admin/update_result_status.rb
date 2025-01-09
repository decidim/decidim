# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin batch updates results status.
      class UpdateResultStatus < Decidim::Command
        # Public: Initializes the command.
        #
        # status_id - the status id to update
        # result_ids - the results ids to update
        # current_user - the user performing the action
        def initialize(status_id, result_ids, current_user)
          @status_id = status_id
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
          return broadcast(:invalid) if status_id.blank? || result_ids.blank?

          update_results_status

          broadcast(:ok)
        end

        private

        attr_reader :status_id, :result_ids, :current_user

        def update_results_status
          Decidim::Accountability::Result.where(id: result_ids).find_each do |result|
            next if result.decidim_accountability_status_id == status_id

            status = Decidim::Accountability::Status.find_by(id: status_id)

            next if status.blank?

            result.update!(
              decidim_accountability_status_id: status_id,
              progress: status.progress
            )

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
