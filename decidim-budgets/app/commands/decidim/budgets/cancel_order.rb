# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to cancel an order.
    class CancelOrder < Decidim::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user.
      def initialize(order)
        @order = order
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the there is an error.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid_order?
        return broadcast(:invalid) unless voting_open?

        cancel_order!
        broadcast(:ok, @order)
      end

      private

      def invalid_order?
        !@order&.checked_out?
      end

      def cancel_order!
        @order.destroy!
      end

      def voting_open?
        @order.budget.component.current_settings.votes == "enabled"
      end
    end
  end
end
