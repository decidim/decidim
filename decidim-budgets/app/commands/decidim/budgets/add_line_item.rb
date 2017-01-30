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
        begin
          transaction do
            find_or_create_order
            add_line_item
            broadcast(:ok, @order)
          end
        rescue
          return broadcast(:invalid)
        end
      end

      private

      def find_or_create_order
        @order ||= Order.create!(user: @current_user, feature: @project.feature)
      end

      def add_line_item
        @order.projects << @project
        @order.save!
      end
    end
  end
end
