# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when creating a closure for a polling station
    class CreatePollingStationClosure < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          closure.save!
          create_total_ballot_results!
        end

        broadcast(:ok)
      end

      private

      attr_reader :form

      def closure
        @closure ||= PollingStationClosure.new(
          phase: :results,
          election: form.election,
          polling_station: form.polling_station,
          polling_officer: form.context.polling_officer,
          polling_officer_notes: form.polling_officer_notes
        )
      end

      def create_total_ballot_results!
        closure.results.create!(
          value: form.total_ballots_count,
          result_type: :total_ballots
        )
      end
    end
  end
end
