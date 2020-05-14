# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to cancel an order.
    class CancelOrder < Rectify::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user.
      def initialize(order)
        @order = order
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @order.present?

        cancel_order!
        broadcast(:ok, @order)
      end

      private

      def cancel_order!
        @order.destroy!
      end
    end
  end
end
