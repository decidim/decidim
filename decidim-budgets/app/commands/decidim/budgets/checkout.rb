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
        return broadcast(:invalid) if invalid_order?
        checkout!
        broadcast(:ok, @order)
      end

      private

      def invalid_order?
        return true unless @order
        @order.total_budget.to_f < (@feature.settings.total_budget.to_f * (@feature.settings.vote_threshold_percent.to_f / 100))
      end

      def checkout!
        @order.update_attributes!(checked_out_at: Time.zone.now)
      end
    end
  end
end
