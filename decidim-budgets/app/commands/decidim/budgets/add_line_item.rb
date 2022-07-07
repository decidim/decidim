# frozen_string_literal: true

module Decidim
  module Budgets
    # A command with all the business to add new line items to orders
    class AddLineItem < Decidim::Command
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
          raise ActiveRecord::RecordInvalid if voting_not_enabled? || order.checked_out? || exceeds_budget?

          add_line_item
          broadcast(:ok, order)
        end
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      attr_reader :current_user, :project

      def order
        @order ||= Order.create!(user: current_user, budget: project.budget)
      end

      def add_line_item
        order.with_lock do
          order.projects << project
        end
      end

      def exceeds_budget?
        order.allocation_for(project) + order.total > order.available_allocation
      end

      def voting_not_enabled?
        project.component.current_settings.votes != "enabled"
      end
    end
  end
end
