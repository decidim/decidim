# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to checkout.
    class Checkout < Rectify::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user.
      # component - The current component.
      def initialize(order, component)
        @order = order
        @component = component
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the there is an error.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid, @order) unless checkout!

        notify_user

        broadcast(:ok, @order)
      end

      private

      def checkout!
        return unless @order

        @order.with_lock do
          @order.checked_out_at = Time.current
          @order.save
        end
      end

      def notify_user
        Decidim::EventsManager.publish(
          event: "decidim.events.budgets.order_checkout",
          event_class: Decidim::Budgets::CheckoutOrderEvent,
          resource: @order.component,
          affected_users: [@order.user]
        )
      end
    end
  end
end
