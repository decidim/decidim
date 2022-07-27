# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when signing a closure of a polling station
    class SignPollingStationClosure < Decidim::Command
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

        closure.update!(signed_at:, phase: :complete)

        broadcast(:ok)
      end

      private

      attr_reader :form, :closure

      def signed_at
        return unless form.signed

        Time.current
      end
    end
  end
end
