# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to add remove line items from orders
    class RemoveLineItem < Rectify::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user
      # project - The the project to remove from the order
      def initialize(order, project)
        @order = order
        @project = project
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the there is an error.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @order.checked_out?

        remove_line_item
        broadcast(:ok, @order)
      end

      private

      attr_reader :project

      def remove_line_item
        @order.projects.destroy(project)
      end
    end
  end
end
