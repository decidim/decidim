# frozen_string_literal: true
module Decidim
  module Budgets
    # A command with all the business to checkout.
    class Checkout < Rectify::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user.
      # feature - The current feature.
      def initialize(order, feature)
        @order = order
        @feature = feature
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the there is an error.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @order&.can_checkout?
        checkout!
        broadcast(:ok, @order)
      end

      private

      def checkout!
        @order.update_attributes!(checked_out_at: Time.current)
      end
    end
  end
end
