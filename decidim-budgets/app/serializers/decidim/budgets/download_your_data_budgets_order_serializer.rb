# frozen_string_literal: true

module Decidim
  module Budgets
    class DownloadYourDataBudgetsOrderSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a conversation.
      def initialize(order)
        @order = order
      end

      # Serializes a Debate for download your data
      def serialize
        {
          id: order.id,
          budget: order.budget.title,
          component: order.budget.component.name,
          checked_out_at: order.checked_out_at,
          projects: all_projects,
          created_at: order.created_at,
          updated_at: order.updated_at
        }
      end

      private

      attr_reader :order
      alias resource order

      def all_projects
        order.projects.map do |project|
          {
            id: project.id,
            title: project.title,
            description: project.description,
            budget_amount: project.budget_amount,
            scope: project.try(:scope).try(:name),
            reference: project.reference,
            created_at: project.created_at,
            updated_at: project.updated_at
          }
        end
      end
    end
  end
end
