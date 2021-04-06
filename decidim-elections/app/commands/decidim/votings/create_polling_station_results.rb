# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when creating results for a polling station
    class CreatePollingStationResults < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, polling_officer)
        @form = form
        @polling_officer = polling_officer
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        form.answer_results.each do |answer_result|
          create_answer_result_for(answer_result)
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :polling_officer

      def create_answer_result_for(answer_result)
        params = {
          decidim_votings_polling_station_id: form.polling_station_id,
          votes_count: answer_result.votes_count,
          decidim_elections_answer_id: answer_result.id
        }

        Decidim.traceability.create!(
          Decidim::Elections::Result,
          polling_officer.user,
          params,
          visibility: "admin-only"
        )
      end
    end
  end
end
