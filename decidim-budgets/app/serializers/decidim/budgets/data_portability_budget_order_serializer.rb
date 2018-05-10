# frozen_string_literal: true

module Decidim
  module Budgets
    class DataPortabilityBudgetOrderSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a conversation.
      def initialize(order)
        @order = order
      end

      # Serializes a Debate for data portability
      def serialize
        {
          id: order.id,
          component: order.component.name,
          checked_out_at: order.checked_out_at,
          projects: all_projects,
          created_at: order.created_at,
          updated_at: order.updated_at
        }
      end

      private

      attr_reader :order

      def all_projects
        order.projects.map do |project|
          {
            id: project.id,
            title: project.title,
            description: project.description,
            budget: project.budget,
            component: project.component.name,
            scope: project.scope.name,
            reference: project.reference,
            created_at: project.created_at,
            updated_at: project.updated_at
          }
        end
      end
    end
  end
end
