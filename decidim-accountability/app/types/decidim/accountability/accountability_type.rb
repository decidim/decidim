# frozen_string_literal: true

module Decidim
  module Accountability
    AccountabilityType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Accountability"
      description "An accountability component of a participatory space."

      connection :results, ResultType.connection_type do
        resolve ->(component, _args, _ctx) {
                  ResultTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:result, ResultType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          ResultTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module ResultTypeHelper
      def self.base_scope(component)
        Result.where(component: component)
      end
    end
  end
end
