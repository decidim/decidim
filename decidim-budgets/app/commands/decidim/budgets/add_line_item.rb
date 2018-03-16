# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to add new line items to orders
    class AddLineItem < Rectify::Command
      # Public: Initializes the command.
      #
      # order - The current order for the user or nil if it is not created yet.
      # project - The the project to include in the order
      # current_user - The current user logged in
      def initialize(current_order, project, current_user)
        @order = current_order
        @project = project
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the there is an error.
      #
      # Returns nothing.
      def call
        transaction do
          return broadcast(:invalid) if votes_disabled? || order.checked_out?
          add_line_item
          broadcast(:ok, order)
        end
      end

      private

      def order
        @order ||= Order.create!(user: @current_user, component: @project.component)
      end

      def add_line_item
        order.with_lock do
          order.projects << @project
          order.save!
        end
      end

      def component
        @project.component
      end

      def votes_disabled?
        !component.current_settings.votes_enabled?
      end
    end
  end
end
