# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when creating a closure for a polling station
    class CreateClosure < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # closure - A closure object.
      def initialize(form, closure)
        @form = form
        @closure = closure
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
          closure.update!(polling_officer_notes: form.polling_officer_notes)

          create_total_ballot_results!
        end

        broadcast(:ok)
      end

      private

      attr_reader :form
      attr_accessor :closure

      def create_total_ballot_results!
        closure.results.create!(
          votes_count: form.total_ballots_count,
          result_type: "total_ballots"
        )
      end
    end
  end
end
