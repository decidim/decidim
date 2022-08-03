# frozen_string_literal: true

module Decidim
  module Votings
    # A command with all the business logic when deleting a closure for a polling station
    class DestroyPollingStationClosure < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(closure, current_user)
        @closure = closure
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid?

        destroy_closure!

        broadcast(:ok, closure)
      end

      private

      attr_reader :closure, :current_user

      def invalid?
        closure.complete_phase?
      end

      def destroy_closure!
        Decidim.traceability.perform_action!(
          :delete,
          closure,
          current_user,
          visibility: "all"
        ) do
          closure.results.destroy_all
          closure.destroy!
        end
      end
    end
  end
end
