# frozen_string_literal: true

module Decidim
  module Budgets
    BudgetsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Budgets"
      description "A budget component of a participatory space."

      connection :projects, ProjectType.connection_type do
        resolve ->(component, _args, _ctx) {
                  ProjectTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:project, ProjectType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          ProjectTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module ProjectTypeHelper
      def self.base_scope(component)
        Project.where(component: component)
      end
    end
  end
end
